namespace GenDsk;
internal class CpmDisk
{
    private const int SectorsPerTrack = 16;
    private const int SectorSize = 256;
    private const int Tracks = 35;
    private const int BootTracks = 3;
    private const int DirectorySectors = 8;
    private const int DirectoryEntries = DirectorySectors * 8;
    private const byte CpmEmptyByte = 0xE5;
    static int[] prodosSectorMap = { 0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15 };
    static int[] cpmSectorMap = { 0, 3, 6, 9, 12, 15, 2, 5, 8, 11, 14, 1, 4, 7, 10, 13 };
    static int[] rawToDos33Map = { 0, 7, 14, 6, 13, 5, 12, 4, 11, 3, 10, 2, 9, 1, 8, 15 };
    static SortedSet<int> freeBlocks = new();
    static SortedSet<int> usedBlocks = new();
    private FileInfo diskFileInfo;
    private (int block, byte[] data) emptyBlock = (0, Array.Empty<byte>());
    private byte[] diskImageData;
    // These files are written out in order to
    // the first three tracks of our image.
    private readonly string[] bootTrackFilenames =
    [
        "BOOTSECT.BIN",
        "BIOSVID.BIN",
        "BIOSDISK.BIN",
        "BIOSCHAR.BIN",
        "CCP.COM",
        "TOOLKEY.BIN",
        "CPMLDR.BIN"
    ];

    public CpmDisk(FileInfo diskFileInfo)
    {
        this.diskFileInfo = diskFileInfo;
        diskImageData = new byte[Tracks * SectorsPerTrack * SectorSize];
        var emptySector = new byte[SectorSize];
        Array.Fill(emptySector, CpmEmptyByte);
        // Fill all of the directory with empty bytes...
        for (int sector = 0; sector < DirectorySectors; sector++)
            WriteCpmSector(BootTracks, sector, emptySector.AsSpan());
    }

    internal void CopyBootable(DirectoryInfo binariesDirectory)
    {
        if (!binariesDirectory.Exists)
            throw new Exception("Cannot find binaries directory");

        var files = binariesDirectory.GetFiles();
        // Do we have all the files we need ?
        var bootTrackFiles = ValidateBootFiles(files);
        WriteBootTrack(bootTrackFiles);
        // Check for CPM3.SYS
        FileInfo? cpm3sys = files.FirstOrDefault(f => f.Name.Equals("CPM3.SYS", StringComparison.OrdinalIgnoreCase));
        if (cpm3sys == null) throw new Exception("Could not find file CPM3.SYS");
        WriteFile(cpm3sys);
    }

    // See https://github.com/fadden/CiderPress2/blob/main/DiskArc/FS/CPM-notes.md
    private void WriteFile(FileInfo fileInfo)
    {
        ReadDirectoryBlocks();
        var extent = CreateExtent(fileInfo);
        DeleteExtents(extent);
        Span<byte> currentExtent = FindBlankEntry();
        if (currentExtent == Span<byte>.Empty)
            throw new Exception("Out of directory entries");
        int length = (int)fileInfo.Length;
        var fileData = File.ReadAllBytes(fileInfo.FullName);
        int fileOffset = 0;
        (int block, byte[] data) currentBlock = emptyBlock;
        while (length > 0)
        {
            byte currentRc = extent[0x0f];
            // Do we need to get a new entry?
            if (currentRc == 0x80)
            {
                extent.CopyTo(currentExtent);   // Save extent to in memory image
                extent[0x0f] = 0x00;            // Mark the current one as empty
                currentRc = 0;
                extent[0x0c]++;         // Advance the extent
                for (int i=16;i<32;i++) // Clear all the current blocks
                    extent[i]=0x00;
                // Get a blank directory entry.
                currentExtent = FindBlankEntry();
                if (currentExtent == Span<byte>.Empty)
                    throw new Exception("Out of directory entries");
            }
            // Do we need to get a block?
            if ((currentRc & 0x07) == 0x00)
            {
                WriteBlock(currentBlock);
                currentBlock = ReadFreeBlock();
                extent[0x10 + (currentRc / 8)] = (byte)currentBlock.block;
            }
            // Copy some data into the block
            int len = (length > 128) ? 128 : length;
            length -= len;
            var srcSpan = fileData.AsSpan(fileOffset, len);
            var dstSpan = currentBlock.data.AsSpan((currentRc & 0x07) * 0x80, 0x80);
            srcSpan.CopyTo(dstSpan);
            currentRc++;
            fileOffset += 0x80;
            extent[0x0f] = currentRc;
        }
        WriteBlock(currentBlock);
        extent.CopyTo(currentExtent);
    }

    private void WriteBlock((int block, byte[] data) currentBlock)
    {
        if (currentBlock == emptyBlock)
            return;
        int track = currentBlock.block / 4 + BootTracks;
        int sector = (currentBlock.block * 4) & 0x0f;
        for (int i = 0; i < 4; i++)
            WriteCpmSector(track, sector + i, currentBlock.data.AsSpan(i * 0x100, 0x100));
    }

    private (int block, byte[] data) ReadFreeBlock()
    {
        if (freeBlocks.Count == 0)
            throw new Exception("Out of disk image space.");
        int block = freeBlocks.First();
        usedBlocks.Add(block);
        freeBlocks.Remove(block);
        var data = new byte[0x400];
        int track = block / 4 + BootTracks;
        int sector = (block * 4) & 0x0f;
        if (track >= Tracks)
            track = track - Tracks;
        for (int i = 0; i < 4; i++)
        {
            var src = ReadCpmSector(track, sector + i);
            var dst = data.AsSpan(i * 0x100, 0x100);
            src.CopyTo(dst);
        }
        return (block, data);
    }

    Span<byte> FindBlankEntry()
    {
        for (int i = 0; i < DirectoryEntries; i++)
        {
            var entry = GetDirectoryEntry(i);
            if (entry[0] == CpmEmptyByte)
                return entry;
        }
        return Span<byte>.Empty;
    }

    private void DeleteExtents(byte[] extent)
    {
        for (int i = 0; i < DirectoryEntries; i++)
        {
            var directoryEntry = GetDirectoryEntry(i);
            if (DirMatch(extent, directoryEntry))
            {
                int rc = directoryEntry[0x0f];
                int j = 15;
                while (rc > 0)
                {
                    rc -= 8;
                    j++;
                    if (directoryEntry[j] != 0)
                    {
                        freeBlocks.Add(directoryEntry[j]);
                        usedBlocks.Remove(directoryEntry[j]);
                    }
                }
            }
            directoryEntry[0] = CpmEmptyByte;
        }
    }

    private bool DirMatch(byte[] extent, Span<byte> directoryEntry)
    {
        if (directoryEntry[0] >= 0x10)
            return false;
        for (int i = 1; i < 12; i++)
            if (extent[i] != (directoryEntry[i] & 0x7f))
                return false;
        return true;
    }

    private byte[] CreateExtent(FileInfo fileInfo)
    {
        var extent = new byte[0x20];
        for (int x = 1; x < 12; x++)
            extent[x] = 0x20;
        int i = 0;
        int j = 1;
        while ((i < 8) && (i < fileInfo.Name.Length) && (fileInfo.Name[i] != '.'))
            extent[j++] = (byte)char.ToUpper(fileInfo.Name[i++]);
        // No extension go home
        if (i == fileInfo.Name.Length)
            return extent;
        // Filled in everything, filename > 8 characters
        if ((i == 8) && (i < fileInfo.Name.Length) && (fileInfo.Name[i] != '.'))
            throw new Exception("Filename too big " + fileInfo.Name);
        // copy extension
        j = 9;
        i++;    // Skip period
        while ((i < 11) && (i < fileInfo.Name.Length))
            extent[j++] = (byte)char.ToUpper(fileInfo.Name[i++]);
        if (i != fileInfo.Name.Length)
            throw new Exception("Extension too big " + fileInfo.Name);
        return extent;
    }

    private void ReadDirectoryBlocks()
    {
        // Go home if we've already ready everything
        if ((freeBlocks.Count != 0) || (usedBlocks.Count != 0))
            return;
        for (int i = 2; i < (Tracks * SectorsPerTrack / 2); i++)
            freeBlocks.Add(i);
        // Mark directory blocks as used
        usedBlocks.Add(0);
        usedBlocks.Add(1);
        for (int i = 0; i < DirectoryEntries; i++)
        {
            var directoryEntry = GetDirectoryEntry(i);
            if (directoryEntry[0] >= 0x10) // Skip everything 
                continue;
            int rc = directoryEntry[0x0f];
            int j = 15;
            while (rc > 0)
            {
                rc -= 8;
                j++;
                if (directoryEntry[j] != 0)
                {
                    usedBlocks.Add(directoryEntry[j]);
                    freeBlocks.Remove(directoryEntry[j]);
                }
            }
        }
    }

    private Span<byte> GetDirectoryEntry(int entry)
    {
        return diskImageData.AsSpan((BootTracks * SectorsPerTrack * SectorSize) + (entry * 0x20), 0x20);
    }

    private void WriteBootTrack(List<FileInfo> bootTrackFiles)
    {
        byte[] data = new byte[(BootTracks * SectorsPerTrack * SectorSize)];
        int offset = 0;
        foreach (var file in bootTrackFiles)
        {
            var fileData = File.ReadAllBytes(file.FullName);
            fileData.CopyTo(data, offset);
            offset += fileData.Length;
        }
        int track = 0;
        int sector = 0;
        while (track != BootTracks)
        {
            WriteProdosSector(track, sector,
                data.AsSpan((track * SectorsPerTrack + sector) * SectorSize, SectorSize));
            sector++;
            if (sector >= SectorsPerTrack)
            {
                sector = 0;
                track++;
            }
        }
        var lastDirectorySector = ReadCpmSector(BootTracks, DirectorySectors - 1);
        byte[] lastBytes =
        {
            0x00,0x73,0x79,0x73,0x74,0x65,0x6d,0x20,0x20,0xf4,0xf2,0xeb,0x00,0x00,0x00,0x60,
            0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x00,0x00,0x00,0x00
        };
        lastBytes.CopyTo(lastDirectorySector.Slice(7 * 0x20, 0x20));
        WriteCpmSector(3, 7, lastDirectorySector);
    }

    private void WriteProdosSector(int track, int sector, Span<byte> span)
    {
        WriteRawSector(track, prodosSectorMap[sector], span);
    }

    private void WriteCpmSector(int track, int sector, Span<byte> span)
    {
        WriteRawSector(track, cpmSectorMap[sector], span);
    }

    private Span<byte> ReadCpmSector(int track, int sector)
    {
        return ReadRawSector(track, cpmSectorMap[sector]);
    }

    private Span<byte> ReadRawSector(int track, int rawSector)
    {
        int sector = rawToDos33Map[rawSector];
        return diskImageData.AsSpan((track * SectorsPerTrack + sector) * SectorSize, SectorSize);
    }

    private void WriteRawSector(int track, int rawSector, Span<byte> span)
    {
        int sector = rawToDos33Map[rawSector];
        span.CopyTo(diskImageData.AsSpan((track * SectorsPerTrack + sector) * SectorSize, SectorSize));
    }

    private List<FileInfo> ValidateBootFiles(FileInfo[] files)
    {
        var bootTrackFiles = new List<FileInfo>();
        foreach (var name in bootTrackFilenames)
        {
            var file = files.FirstOrDefault(f => f.Name.Equals(name, StringComparison.OrdinalIgnoreCase));
            if (file == null) throw new Exception("Could not find file " + name);
            bootTrackFiles.Add(file);
        }

        // Check size
        if (bootTrackFiles.Sum(f => f.Length) != (BootTracks * SectorsPerTrack * SectorSize))
            throw new Exception("File sizes are wrong for the boot sectors");
        return bootTrackFiles;
    }

    internal void Write()
    {
        File.WriteAllBytes(diskFileInfo.FullName, diskImageData);
    }
}
