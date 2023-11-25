using System.Reflection.Metadata;
using System.Security.Authentication.ExtendedProtection;
using System.Transactions;

namespace CpmDsk;
internal class CpmDisk
{
    private const int SectorsPerTrack = 16;
    private const int SectorSize = 256;
    private const int Tracks = 35;
    private const int BootTracks = 3;
    private const int DirectorySectors = 8;
    private const int DirectoryEntries = DirectorySectors * 8;
    public const byte CpmEmptyByte = 0xE5;
    static int[] prodosSectorMap = { 0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15 };
    static int[] cpmSectorMap = { 0, 3, 6, 9, 12, 15, 2, 5, 8, 11, 14, 1, 4, 7, 10, 13 };
    static int[] rawToDos33Map = { 0, 7, 14, 6, 13, 5, 12, 4, 11, 3, 10, 2, 9, 1, 8, 15 };
    static SortedSet<byte> freeBlocks = new();
    static SortedSet<byte> usedBlocks = new();
    private FileInfo diskFileInfo;
    private (byte block, byte[] data) emptyBlock = (0, Array.Empty<byte>());
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

    private void WriteFile(FileInfo fileInfo)
    {
        ReadDirectoryFreeBlocks();
        var memoryDirEntry = new DirectoryEntry(fileInfo.Name);
        RemoveFile(memoryDirEntry);
        var diskDirEntry = FindBlankEntry();
        int length = (int)fileInfo.Length;
        var fileData = File.ReadAllBytes(fileInfo.FullName);
        int fileOffset = 0;
        (byte block, byte[] data) currentBlock = emptyBlock;
        while (length > 0)
        {
            // Do we need to get a new entry?
            if (memoryDirEntry.RecordCount == 0x80)
            {
                memoryDirEntry.CopyTo(diskDirEntry);  // Save extent to in memory image
                memoryDirEntry.RecordCount = 0x00;     // Mark the current one as empty
                memoryDirEntry.Extent++;               // Advance the extent
                for (int i = 0; i < 16; i++)   // Clear all the current blocks
                    memoryDirEntry.SetBlock(i, 0x00);
                // Get a blank directory entry.
                diskDirEntry = FindBlankEntry();
            }

            // Do we need to get a block?
            if ((memoryDirEntry.RecordCount & 0x07) == 0x00)
            {
                WriteBlock(currentBlock);
                currentBlock = ReadFreeBlock();
                memoryDirEntry.SetBlock(memoryDirEntry.RecordCount / 8, currentBlock.block);
            }

            // Copy some data into the block
            int len = (length > 128) ? 128 : length;
            length -= len;
            var srcSpan = fileData.AsSpan(fileOffset, len);
            var dstSpan = currentBlock.data.AsSpan((memoryDirEntry.RecordCount & 0x07) * 0x80, 0x80);
            srcSpan.CopyTo(dstSpan);
            fileOffset += 0x80;
            memoryDirEntry.RecordCount++;
        }
        WriteBlock(currentBlock);
        memoryDirEntry.CopyTo(diskDirEntry);
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

    private (byte block, byte[] data) ReadFreeBlock()
    {
        if (freeBlocks.Count == 0)
            throw new Exception("Out of disk image space.");
        byte block = freeBlocks.First();
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

    DirectoryEntry FindBlankEntry()
    {
        for (int i = 0; i < DirectoryEntries; i++)
        {
            var entry = GetDirectoryEntry(i);
            if (entry.IsAvailable)
                return entry;
        }
        throw new Exception("Out of directory entries");
    }

    private void RemoveFile(DirectoryEntry extent)
    {
        for (int i = 0; i < DirectoryEntries; i++)
        {
            var directoryEntry = GetDirectoryEntry(i);
            if (extent.Match(directoryEntry))
            {
                int rc = directoryEntry.RecordCount;
                int j = -1;
                while (rc > 0)
                {
                    rc -= 8;
                    j++;
                    if (directoryEntry.GetBlock(j) != 0)
                    {
                        freeBlocks.Add(directoryEntry.GetBlock(j));
                        usedBlocks.Remove(directoryEntry.GetBlock(j));
                    }
                }
            }
            directoryEntry.MarkAsEmpty();
        }
    }

    private void ReadFile(DirectoryEntry file)
    {
        using var stream = File.Open(file.Name, FileMode.Create);
        using var writer = new BinaryWriter(stream);
        bool more = true;
        while (more)
        {
            more = false;
            for (int i = 0; i < DirectoryEntries; i++)
            {
                var diskEntry = GetDirectoryEntry(i);
                if (file.Match(diskEntry) && (file.Extent == diskEntry.Extent))
                {
                    file.Extent++;
                    more=true;
                    int rc=diskEntry.RecordCount;
                    int j=0;
                }
            }
        }
    }

    private void ReadDirectoryFreeBlocks()
    {
        // Go home if we've already ready everything
        if ((freeBlocks.Count != 0) || (usedBlocks.Count != 0))
            return;
        for (int i = 2; i < (Tracks * SectorsPerTrack / 2); i++)
            freeBlocks.Add((byte)i);
        // Mark directory blocks as used
        usedBlocks.Add(0);
        usedBlocks.Add(1);
        for (int i = 0; i < DirectoryEntries; i++)
        {
            var directoryEntry = GetDirectoryEntry(i);
            if (directoryEntry.IsNotFile) // Skip everything 
                continue;
            int rc = directoryEntry.RecordCount;
            int j = -1;
            while (rc > 0)
            {
                rc -= 8;
                j++;
                if (directoryEntry.GetBlock(j) != 0)
                {
                    usedBlocks.Add(directoryEntry.GetBlock(j));
                    freeBlocks.Remove(directoryEntry.GetBlock(j));
                }
            }
        }
    }

    private DirectoryEntry GetDirectoryEntry(int entry)
    {
        var sectorData = ReadCpmSector(BootTracks, entry / 8);
        return new DirectoryEntry(sectorData.Slice((entry & 0x07) * 0x20, 0x20));
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

    internal void WriteImage()
    {
        File.WriteAllBytes(diskFileInfo.FullName, diskImageData);
    }

    internal void ReadImage()
    {
        diskImageData = File.ReadAllBytes(diskFileInfo.FullName);
    }


    private bool DirMatches(DirectoryEntry dirEntry, List<string> filters)
    {
        if (dirEntry.IsNotFile) return false;
        foreach (var filter in filters)
        {
            if (new DirectoryEntry(filter).Match(dirEntry))
                return true;
        }
        return false;
    }

    Dictionary<string, int> GetCpmFiles(List<string> filters)
    {
        var results = new Dictionary<string, int>();
        for (int i = 0; i < DirectoryEntries; i++)
        {
            var entry = GetDirectoryEntry(i);
            if (DirMatches(entry, filters))
            {
                string fname = entry.Name;
                int curEntrySize = entry.Extent * 0x4000 + entry.RecordCount * 0x80;
                if (results.TryGetValue(fname, out var size) && size > curEntrySize)
                    curEntrySize = size;
                results[fname] = curEntrySize;
            }
        }
        return results;
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

    internal void CopyBootable(DirectoryInfo binariesDirectory)
    {
        if (!binariesDirectory.Exists)
            throw new Exception("Cannot find binaries directory");

        var files = binariesDirectory.GetFiles();
        // Do we have all the files we need ?
        var bootTrackFiles = ValidateBootFiles(files);
        WriteBootTrack(bootTrackFiles);
    }

    internal void CpmWildcardAction(List<string> fileFilters, Action<string, int> action)
    {
        foreach (var KV in GetCpmFiles(fileFilters))
        {
            action(KV.Key, KV.Value);
        }
    }

    internal void DirectoryFiles(List<string> fileFilters)
    {
        CpmWildcardAction(
            fileFilters,
            (name, size) => Console.WriteLine("{0,-14} {1,6}", name, size));
    }

    internal void RemoveFiles(List<string> fileFilters)
    {
        ReadDirectoryFreeBlocks();
        CpmWildcardAction(
            fileFilters,
            (name, _) => RemoveFile(new DirectoryEntry(name)));
    }

    internal void ExtractFiles(List<string> fileFilters)
    {
        CpmWildcardAction(
            fileFilters,
            (name, _) => ReadFile(new DirectoryEntry(name)));
    }

    internal void AddFiles(List<string> filePatterns)
    {
        foreach (var filePattern in filePatterns)
        {
            // foreach(var fileInfo in DirectoryInfo.GetFiles(filePattern))
            //     WriteFile(fileInfo);
        }
    }
}
