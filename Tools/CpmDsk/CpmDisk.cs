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

    /// <summary>
    /// Constructor for the in memory CPM disk image.
    /// </summary>
    /// <param name="diskFileInfo">Disk image to use.</param>
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

    /// <summary>
    /// Writes a file from the host system to the in memory disk image.
    /// </summary>
    /// <param name="fileInfo">File to write.</param>
    private void WriteFile(FileInfo fileInfo)
    {
        ReadDirectoryFreeBlocks();
        var memoryDirEntry = new DirectoryEntry(fileInfo.Name);
        RemoveFile(memoryDirEntry);
        Console.WriteLine("Adding file {0}", memoryDirEntry.Name);
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
                currentBlock = ReadNextFreeBlock();
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

    /// <summary>
    /// Writes a block of data back to the in memory image
    /// </summary>
    /// <param name="currentBlock">Tuple of the block number and data</param>
    private void WriteBlock((byte block, byte[] data) currentBlock)
    {
        if (currentBlock == emptyBlock)
            return;
        int track = currentBlock.block / 4 + BootTracks;
        int sector = (currentBlock.block * 4) & 0x0f;
        for (int i = 0; i < 4; i++)
            WriteCpmSector(track, sector + i, currentBlock.data.AsSpan(i * 0x100, 0x100));
    }

    /// <summary>
    /// Reads a block of data from the in memory image, creates a new copy
    /// </summary>
    /// <param name="block">Block number to read</param>
    /// <returns>Copy of data from disk image.</returns>
    private (byte block, byte[] data) ReadBlock(byte block)
    {
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

    /// <summary>
    /// Gets a block of data from the free block list.
    /// </summary>
    /// <returns>Copy of the data from the in memory image.</returns>
    /// <exception cref="Exception">Throws an exception if there is no disk image.</exception>
    private (byte block, byte[] data) ReadNextFreeBlock()
    {
        if (freeBlocks.Count == 0)
            throw new Exception("Out of disk image space.");
        byte block = freeBlocks.First();
        usedBlocks.Add(block);
        freeBlocks.Remove(block);
        return ReadBlock(block);
    }

    /// <summary>
    /// Returns a blank directory entry from the in memory image.
    /// </summary>
    /// <returns>Blank directory entry.</returns>
    /// <exception cref="Exception">Throws an exception if out directory entries</exception>
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

    /// <summary>
    /// Removes a file from in memory disk image.
    /// Returns blocks to the free list, removing them from the used list.
    /// </summary>
    /// <param name="file">Directory entry of the file.</param>
    private void RemoveFile(DirectoryEntry file)
    {
        bool firstTime = true;
        for (int i = 0; i < DirectoryEntries; i++)
        {
            var directoryEntry = GetDirectoryEntry(i);
            if (file.Match(directoryEntry))
            {
                if (firstTime)
                {
                    Console.WriteLine("Removing file {0}", file.Name);
                    firstTime = false;
                }
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
                directoryEntry.MarkAsEmpty();
            }
        }
    }

    /// <summary>
    /// Reads a file from the disk image and writes it to host file system.
    /// </summary>
    /// <param name="file">Directory entry of the file.</param>
    private void ReadFile(DirectoryEntry file)
    {
        Console.WriteLine("Extracting file {0}", file.Name);
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
                    more = true;
                    int rc = 0;
                    int j = 0;
                    (byte block, byte[] data) block = emptyBlock;

                    while (rc < diskEntry.RecordCount)
                    {
                        if ((rc & 0x07) == 0)
                        {
                            // Doesn't cope with sparse files
                            block = ReadBlock(diskEntry.GetBlock(j));
                            j++;
                        }
                        writer.Write(block.data.AsSpan((rc & 0x07) * 0x80, 0x80));
                        rc++;
                    }
                }
            }
        }
    }

    /// <summary>
    /// Reads the directory and computes a list of free and 
    /// used blocks on the disk from the allocation
    /// in the directory blocks.
    /// </summary>
    private void ReadDirectoryFreeBlocks()
    {
        // Go home if we've already ready everything
        if ((freeBlocks.Count != 0) || (usedBlocks.Count != 0))
            return;
        for (int i = 2; i < (Tracks * SectorsPerTrack / 4); i++)
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

    /// <summary>
    /// Reads a directory entry from the in memory disk image.
    /// </summary>
    /// <param name="entry">Directory entry to read</param>
    /// <returns>Directory entry.</returns>
    private DirectoryEntry GetDirectoryEntry(int entry)
    {
        var sectorData = ReadCpmSector(BootTracks, entry / 8);
        return new DirectoryEntry(sectorData.Slice((entry & 0x07) * 0x20, 0x20));
    }

    /// <summary>
    /// Write to a sector on the in memory disk image in prodos order.
    /// </summary>
    /// <param name="track">Track to write to.</param>
    /// <param name="sector">Sector to write to.</param>
    /// <param name="span">Data to write.</param>
    private void WriteProdosSector(int track, int sector, Span<byte> span)
    {
        WriteRawSector(track, prodosSectorMap[sector], span);
    }

    /// <summary>
    /// Write to a sector on the in memory disk image in CPM order.
    /// </summary>
    /// <param name="track">Track to write to.</param>
    /// <param name="sector">Sector to write to.</param>
    /// <param name="span">Data to write.</param>
    private void WriteCpmSector(int track, int sector, Span<byte> span)
    {
        WriteRawSector(track, cpmSectorMap[sector], span);
    }

    /// <summary>
    /// Read from a sector on the in memory disk image in CPM order
    /// </summary>
    /// <param name="track">Track to write to.</param>
    /// <param name="sector">Sector to write to.</param>
    /// <returns>Span of data from the in memory image.</returns>
    private Span<byte> ReadCpmSector(int track, int sector)
    {
        return ReadRawSector(track, cpmSectorMap[sector]);
    }

    /// <summary>
    /// Read from a sector on the in memory disk image in Raw order
    /// Note translates to Apple DOS 3.3 order before reading.
    /// </summary>
    /// <param name="track">Track to write to.</param>
    /// <param name="sector">Sector to write to.</param>
    /// <returns>Span of data from the in memory image.</returns>
    private Span<byte> ReadRawSector(int track, int rawSector)
    {
        int sector = rawToDos33Map[rawSector];
        return diskImageData.AsSpan((track * SectorsPerTrack + sector) * SectorSize, SectorSize);
    }

    /// <summary>
    /// Writes to a sector on the in memory disk image in Raw order
    /// Note translates to Apple DOS 3.3 order before writing.
    /// </summary>
    /// <param name="track">Track to write to.</param>
    /// <param name="sector">Sector to write to.</param>
    /// <param name="span">Data to write.</param>
    private void WriteRawSector(int track, int rawSector, Span<byte> span)
    {
        int sector = rawToDos33Map[rawSector];
        span.CopyTo(diskImageData.AsSpan((track * SectorsPerTrack + sector) * SectorSize, SectorSize));
    }

    /// <summary>
    /// Writes in memory image to disk.
    /// </summary>
    internal void WriteImage()
    {
        File.WriteAllBytes(diskFileInfo.FullName, diskImageData);
    }

    /// <summary>
    /// Reads in memory image from disk.
    /// </summary>
    internal void ReadImage()
    {
        diskImageData = File.ReadAllBytes(diskFileInfo.FullName);
    }

    /// <summary>
    /// Checks if a directory entry matches a list of filters.
    /// </summary>
    /// <param name="dirEntry">Directory entry to check.</param>
    /// <param name="filters">List of filters (wildcard allows)</param>
    /// <returns>True if file matches.</returns>
    private bool DirMatches(DirectoryEntry dirEntry, List<string> filters)
    {
        if (dirEntry.IsNotFile) return false;
        if (dirEntry.IsHidden) return false;
        foreach (var filter in filters)
        {
            if (new DirectoryEntry(filter).Match(dirEntry))
                return true;
        }
        return false;
    }

    /// <summary>
    /// Get a list of files and sizes from the CPM image in memory.
    /// </summary>
    /// <param name="filters">List of filters (wildcard allowed)</param>
    /// <returns>Dictionary where the key value is the name, value is the file size.</returns>
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

    /// <summary>
    /// Validates all the boot track files are in a directory.
    /// </summary>
    /// <param name="files">List of files in the directory.</param>
    /// <returns>List of FileInfo entires for the binary files.</returns>
    /// <exception cref="Exception">Throws an exception if a file is missing or total size is not 12K.</exception>
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

    /// <summary>
    /// Writes out the boot track for the Cirtech CPM system
    /// </summary>
    /// <param name="bootTrackFiles">List of fileInfo entries in order.</param>
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

    /// <summary>
    /// Copies the individual files from a binary directory into a disk image.
    /// </summary>
    /// <param name="binariesDirectory">Binaries directory</param>
    /// <exception cref="Exception">Throws an exception if the binary directory does not exist</exception>
    internal void CopyBootable(DirectoryInfo binariesDirectory)
    {
        if (!binariesDirectory.Exists)
            throw new Exception("Cannot find binaries directory");

        var files = binariesDirectory.GetFiles();
        // Do we have all the files we need ?
        var bootTrackFiles = ValidateBootFiles(files);
        WriteBootTrack(bootTrackFiles);
    }

    /// <summary>
    /// Perform an action against a wild card search on a CP/M disk.
    /// </summary>
    /// <param name="fileFilters">List of files to filter against.</param>
    /// <param name="action">Action to perform, takes a string for the file name and an integer for the file size.</param>
    internal void CpmWildcardAction(List<string> fileFilters, Action<string, int> action)
    {
        foreach (var KV in GetCpmFiles(fileFilters))
        {
            action(KV.Key, KV.Value);
        }
    }

    /// <summary>
    /// Displays a directory of files on a disk image.
    /// </summary>
    /// <param name="fileFilters">List of files to filter against.</param>
    internal void DirectoryFiles(List<string> fileFilters)
    {
        CpmWildcardAction(
            fileFilters,
            (name, size) => Console.WriteLine("{0,-14} {1,6}", name, size));
    }

    /// <summary>
    /// Deletes files from the disk image.
    /// </summary>
    /// <param name="fileFilters">List of files to filter against.</param>
    internal void RemoveFiles(List<string> fileFilters)
    {
        ReadDirectoryFreeBlocks();
        CpmWildcardAction(
            fileFilters,
            (name, _) => RemoveFile(new DirectoryEntry(name)));
    }

    /// <summary>
    /// Extracts files from the disk image.
    /// </summary>
    /// <param name="fileFilters">List of files to filter against.</param>
    internal void ExtractFiles(List<string> fileFilters)
    {
        CpmWildcardAction(
            fileFilters,
            (name, _) => ReadFile(new DirectoryEntry(name)));
    }

    /// <summary>
    /// Add files from the host file system to the disk image.
    /// </summary>
    /// <param name="filePatterns">List of files to copy to the disk image.</param>
    internal void AddFiles(List<string> filePatterns)
    {
        foreach (var filePattern in filePatterns)
        {
            var path = Path.GetDirectoryName(filePattern);
            if (string.IsNullOrEmpty(path))
                path = Directory.GetCurrentDirectory();
            var dir = new DirectoryInfo(path);
            foreach (var fileInfo in dir.GetFiles(Path.GetFileName(filePattern)))
                WriteFile(fileInfo);
        }
    }
}
