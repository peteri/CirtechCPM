namespace CpmDsk;
internal class CpmDisk
{
    public static DiskParameterBlock DiskIIDPB = new DiskParameterBlock
    (
        SectorsPerTrack: 0x20,
        BlockShift: 3,
        BlockMask: 7,
        ExtentMask: 0,
        DriveSectorsMax: 35 * 4 - 1,
        DirectorEntriesMax: 63,
        AL0: 0xc0,
        AL1: 0x00,
        CheckVectorSize: 0x10,
        ReservedTracksOffset: 0x03,
        PhysicalRecordShift: 0x01,
        PhysicalRecordMask: 0x01
    );
    private DiskParameterBlock dpb;
    private const int CpmSectorSize = 128;
    public const byte CpmEmptyByte = 0xE5;
    private ushort blockSize;
    private readonly ushort startOfDirOffset;
    byte userNumber;
    static SortedSet<ushort> freeBlocks = new();
    static SortedSet<ushort> usedBlocks = new();
    private FileInfo diskFileInfo;
    private (ushort block, byte[] data) emptyBlock = (0, Array.Empty<byte>());
    private byte[] diskImageData;
    private IDiskImage diskImage;

    /// <summary>
    /// Constructor for the in memory CPM disk image.
    /// </summary>
    /// <param name="diskFileInfo">Disk image to use.</param>
    public CpmDisk(FileInfo diskFileInfo, long numberOfProDosBlocks, int userNumber)
    {
        this.diskFileInfo = diskFileInfo;
        this.userNumber = (byte)userNumber;
        dpb = ComputeDPB(numberOfProDosBlocks);
        blockSize = (ushort)(CpmSectorSize << dpb.BlockShift);
        startOfDirOffset = (ushort)(dpb.ReservedTracksOffset
                    * CpmSectorSize
                    * dpb.SectorsPerTrack);
        diskImageData = new byte[numberOfProDosBlocks * 512];
        // Fill all of the directory with empty bytes...
        for (int entry = 0; entry <= dpb.DirectorEntriesMax; entry++)
            GetDirectoryEntry(entry).MarkAsEmpty();
        diskImage = (numberOfProDosBlocks == 280L) ? new DskImage(dpb) : new ProdosImage();
    }

    public CpmDisk(FileInfo diskFileInfo, int userNumber) : this(diskFileInfo, diskFileInfo.Length / 512, userNumber)
    {
    }

    /// <summary>
    /// Compute the DPB in the same way as the Cirtech loader BIOS.
    /// </summary>
    /// <param name="numberOfProDosBlocks">Number of prodos blocks</param>
    /// <returns>Either a computed DPB OR the Disk II dpb if size is 280 blocks.</returns>
    public static DiskParameterBlock ComputeDPB(long numberOfProDosBlocks)
    {
        if (numberOfProDosBlocks == 280)
            return DiskIIDPB;
        ushort numOfBlocks = (ushort)((numberOfProDosBlocks - 0x18L) >> 2);
        byte blockHighByte = (byte)(numOfBlocks >> 8);
        if (blockHighByte >= 0x10)
            blockHighByte = (blockHighByte >= 0x20) ? (byte)0x14 : (byte)0x10;
        bool directoryBump = (blockHighByte & 0x4) == 0x4;
        byte bshift = (byte)((blockHighByte >> 3) + 1);
        numOfBlocks = (ushort)((numOfBlocks >> bshift) - 1);
        byte blockShift = (byte)(bshift + 4);
        byte blockMask = (byte)((0x01 << (bshift + 4)) - 1);
        byte EXM = (byte)((1 << bshift) - 1);
        if (numOfBlocks < 256) EXM = (byte)((EXM << 1) + 1);
        ushort numOfDirEntries = (ushort)(((directoryBump ? 0x80 : 0x40) << bshift) - 1);
        byte AL0 = directoryBump ? (byte)0xc0 : (byte)0x80;
        byte AL1 = 0x0;
        ushort CKS = (ushort)((numOfDirEntries + 1) >> 2);
        return new DiskParameterBlock
        (
            SectorsPerTrack: 0x20,
            BlockShift: blockShift,
            BlockMask: blockMask,
            ExtentMask: EXM,
            DriveSectorsMax: numOfBlocks,
            DirectorEntriesMax: numOfDirEntries,
            AL0: AL0,
            AL1: AL1,
            CheckVectorSize: CKS,
            ReservedTracksOffset: 0x03,
            PhysicalRecordShift: 0x02,  // 512 byte sectors
            PhysicalRecordMask: 0x03
        );
    }

    /// <summary>
    /// DPB test routine. Prints out a DPB for various disk sizes.
    /// Matches the code in dpbtest assembler code.
    /// </summary>
    public static void DPBTest()
    {
        long[] sizes =
        [
		// 4K block sizes (0x640 is 1600 or 800K 3.5 superdrive)
		0x3ff,0x420,0x640,0x7ff,0x820,0xfff,0x1020,0x1FFF,
		// 8K block sizes
		0x2018,0x3FFF,0x4017,
		// 16k block sizes
		 0x4018,0x7FFF,0x8019,0xA000,0xFFFF
        ];

        Console.WriteLine("Cirtech DPB test (Size is 512 byte blocks)");
        Console.WriteLine("| Size| SPT | BSH| BLM| EXM| DSM | DRM | AL0| AL1| CKS | OFF | PSH| PHM| ALV |");
        Console.WriteLine("|-----|-----|----|----|----|-----|-----|----|----|-----|-----|----|----|-----|");
        foreach (var size in sizes)
        {
            var dpb = ComputeDPB(size);
            Console.Write("| {0:X4}|", size);
            Console.Write(" {0:X4}|", dpb.SectorsPerTrack);
            Console.Write(" {0:X2} |", dpb.BlockShift);
            Console.Write(" {0:X2} |", dpb.BlockMask);
            Console.Write(" {0:X2} |", dpb.ExtentMask);
            Console.Write(" {0:X4}|", dpb.DriveSectorsMax);
            Console.Write(" {0:X4}|", dpb.DirectorEntriesMax);
            Console.Write(" {0:X2} |", dpb.AL0);
            Console.Write(" {0:X2} |", dpb.AL1);
            Console.Write(" {0:X4}|", dpb.CheckVectorSize);
            Console.Write(" {0:X4}|", dpb.ReservedTracksOffset);
            Console.Write(" {0:X2} |", dpb.PhysicalRecordShift);
            Console.Write(" {0:X2} |", dpb.PhysicalRecordMask);
            Console.Write(" {0:X4}|", ((dpb.DriveSectorsMax + 1) / 4) + 1);
            Console.WriteLine();
        }
    }


    /// <summary>
    /// Writes a block of data back to the in memory image
    /// </summary>
    /// <param name="currentBlock">Tuple of the block number and data</param>
    private void WriteBlock((ushort block, byte[] data) currentBlock)
    {
        if (currentBlock == emptyBlock)
            return;
        var destinationOffset = startOfDirOffset + currentBlock.block * blockSize;
        // Adjust for boot track wrap around for DiskII
        if ((currentBlock.block >= 128) && (dpb == DiskIIDPB))
            destinationOffset = (currentBlock.block - 128) * blockSize;
        currentBlock.data.CopyTo(diskImageData, destinationOffset);
    }

    /// <summary>
    /// Reads a block of data from the in memory image, creates a new copy
    /// </summary>
    /// <param name="block">Block number to read</param>
    /// <returns>Copy of data from disk image.</returns>
    private (ushort block, byte[] data) ReadBlock(ushort block)
    {
        var data = new byte[blockSize];
        var sourceOffset = startOfDirOffset + block * blockSize;
        // Adjust for boot track wrap around for DiskII
        if ((block >= 128) && (dpb == DiskIIDPB))
            sourceOffset = (block - 128) * blockSize;
        diskImageData.AsSpan(sourceOffset, blockSize)
            .CopyTo(data);
        return (block, data);
    }

    /// <summary>
    /// Gets a block of data from the free block list.
    /// </summary>
    /// <returns>Copy of the data from the in memory image.</returns>
    /// <exception cref="Exception">Throws an exception if there is no disk image.</exception>
    private (ushort block, byte[] data) ReadNextFreeBlock()
    {
        if (freeBlocks.Count == 0)
            throw new Exception("Out of disk image space.");
        ushort block = freeBlocks.First();
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
        for (int i = 0; i < dpb.DirectorEntriesMax; i++)
        {
            var entry = GetDirectoryEntry(i);
            if (entry.IsAvailable)
                return entry;
        }
        throw new Exception("Out of directory entries");
    }

    /// <summary>
    /// Reads the directory and computes a list of free and 
    /// used blocks on the disk from the allocation
    /// in the directory blocks.
    /// </summary>
    private void ReadDirectoryFreeBlocks()
    {
        // Go home if we've already read everything
        if ((freeBlocks.Count != 0) || (usedBlocks.Count != 0))
            return;
        ushort startBlock = (ushort)(Byte.PopCount(dpb.AL0) + Byte.PopCount(dpb.AL1));
        for (ushort i = startBlock; i <= dpb.DriveSectorsMax; i++)
            freeBlocks.Add(i);
        // Mark directory blocks as used
        for (ushort i = 0; i < startBlock; i++)
            usedBlocks.Add(i);
        for (int i = 0; i < dpb.DirectorEntriesMax; i++)
        {
            var directoryEntry = GetDirectoryEntry(i);
            if (directoryEntry.IsNotFile) // Skip everything 
                continue;
            IterateAllocationBlocks(directoryEntry, usedBlocks, freeBlocks);
        }
    }

    /// <summary>
    /// Removes a file from in memory disk image.
    /// Returns blocks to the free list, removing them from the used list.
    /// </summary>
    /// <param name="file">Directory entry of the file.</param>
    private void RemoveFile(DirectoryEntry file)
    {
        bool firstTime = true;
        for (int i = 0; i < dpb.DirectorEntriesMax; i++)
        {
            var directoryEntry = GetDirectoryEntry(i);
            if (file.Match(directoryEntry))
            {
                if (firstTime)
                {
                    Console.WriteLine("Removing file {0}", file.Name);
                    firstTime = false;
                }
                IterateAllocationBlocks(directoryEntry, freeBlocks, usedBlocks);
                directoryEntry.MarkAsEmpty();
            }
        }
    }

    /// <summary>
    /// Iterate through the allocations for a directory entry.
    /// </summary>
    /// <param name="directoryEntry">directory entry.</param>
    /// <param name="addBlocks">Sorted set to add any blocks found to.</param>
    /// <param name="removeBlocks">Sorted set to add remove blocks found from.</param>
    private void IterateAllocationBlocks(DirectoryEntry directoryEntry, SortedSet<ushort> addBlocks, SortedSet<ushort> removeBlocks)
    {
        int rc = directoryEntry.RecordCount;
        // clip record count into range
        if (rc > 0x80) rc = 0x80;
        // If we have multiple logical extents then add them into the record count
        rc += (directoryEntry.Extent & dpb.ExtentMask) * 0x80;
        int j = -1;
        while (rc > 0)
        {
            rc -= 1 << dpb.BlockShift;
            j++;
            if (directoryEntry.GetBlock(j) != 0)
            {
                addBlocks.Add(directoryEntry.GetBlock(j));
                removeBlocks.Remove(directoryEntry.GetBlock(j));
            }
        }
    }

    /// <summary>
    /// Writes a file from the host system to the in memory disk image.
    /// </summary>
    /// <param name="fileInfo">File to write.</param>
    private void WriteFile(FileInfo fileInfo)
    {
        ReadDirectoryFreeBlocks();
        var memoryDirEntry = new DirectoryEntry(dpb, userNumber, fileInfo.Name);
        RemoveFile(memoryDirEntry);
        Console.WriteLine("Adding file {0}", memoryDirEntry.Name);
        var diskDirEntry = FindBlankEntry();
        int length = (int)fileInfo.Length;
        var fileData = File.ReadAllBytes(fileInfo.FullName);
        int fileOffset = 0;
        (ushort block, byte[] data) currentBlock = emptyBlock;
        while (length > 0)
        {
            // Do we need to get a new entry?
            if (memoryDirEntry.RecordCount >= 0x80)
            {
                memoryDirEntry.CopyTo(diskDirEntry);  // Save extent to in memory image
                memoryDirEntry.RecordCount = 0x00;     // Mark the current one as empty
                memoryDirEntry.Extent++;               // Advance the extent
                // Out of logical extents?
                if ((memoryDirEntry.Extent & dpb.ExtentMask) == 0)
                {
                    for (int i = 0; i < ((dpb.DriveSectorsMax < 0x100) ? 0x10 : 0x08); i++)   // Clear all the current blocks
                        memoryDirEntry.SetBlock(i, 0x00);
                    // Get a blank directory entry.
                    diskDirEntry = FindBlankEntry();
                }
            }

            // Do we need to get a block?
            if ((memoryDirEntry.RecordCount & dpb.BlockMask) == 0x00)
            {
                WriteBlock(currentBlock);
                currentBlock = ReadNextFreeBlock();
                int blockIndex = (((memoryDirEntry.Extent & dpb.ExtentMask) * 0x80) >> dpb.BlockShift)
                               + (memoryDirEntry.RecordCount >> dpb.BlockShift);
                memoryDirEntry.SetBlock(blockIndex, currentBlock.block);
            }

            // Copy some data into the block
            int len = (length > 128) ? 128 : length;
            length -= len;
            var srcSpan = fileData.AsSpan(fileOffset, len);
            var dstSpan = currentBlock.data.AsSpan((memoryDirEntry.RecordCount & dpb.BlockMask) * 0x80, 0x80);
            srcSpan.CopyTo(dstSpan);
            fileOffset += 0x80;
            memoryDirEntry.RecordCount++;
        }
        WriteBlock(currentBlock);
        memoryDirEntry.CopyTo(diskDirEntry);
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
        ushort extentMask = (ushort)(dpb.ExtentMask ^ 0xffff);
        int cpmSectorsPerBlock = 1 << dpb.BlockShift;
        while (more)
        {
            more = false;
            for (int i = 0; i < dpb.DirectorEntriesMax; i++)
            {
                var diskEntry = GetDirectoryEntry(i);
                if (file.Match(diskEntry) && (file.Extent == (diskEntry.Extent & extentMask)))
                {
                    int rc = diskEntry.RecordCount;
                    // clip record count into range
                    if (rc > 0x80) rc = 0x80;
                    // If we have multiple logical extents then add them into the record count
                    rc += (diskEntry.Extent & dpb.ExtentMask) * 0x80;
                    int j = -1;
                    while (rc > 0)
                    {
                        j++;
                        (ushort block, byte[] data) block = emptyBlock;
                        int size = rc < cpmSectorsPerBlock ? rc : cpmSectorsPerBlock;
                        if (diskEntry.GetBlock(j) != 0)
                        {
                            // Doesn't cope with sparse files
                            block = ReadBlock(diskEntry.GetBlock(j));
                            writer.Write(block.data.AsSpan(0, size * 0x80));
                        }
                        rc -= cpmSectorsPerBlock;
                    }
                    more = true;
                    file.Extent = (ushort)(diskEntry.Extent + 1);
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
        return new DirectoryEntry(dpb,
            diskImageData.AsSpan(startOfDirOffset + entry * 0x20, 0x20));
    }


    /// <summary>
    /// Writes in memory image to disk.
    /// </summary>
    internal void WriteImage()
    {
        diskImage.WriteImage(diskFileInfo.FullName, diskImageData);
    }

    /// <summary>
    /// Reads in memory image from disk.
    /// </summary>
    internal void ReadImage()
    {
        diskImage.ReadImage(diskFileInfo.FullName, diskImageData);
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
            if (new DirectoryEntry(dpb, userNumber, filter).Match(dirEntry))
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
        for (int i = 0; i <= dpb.DirectorEntriesMax; i++)
        {
            var entry = GetDirectoryEntry(i);
            if (DirMatches(entry, filters))
            {
                string fname = entry.Name;
                int curEntrySize = entry.Extent * 0x4000 + (entry.RecordCount < 0x80 ? entry.RecordCount : 0x80) * 0x80;
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

        // Check size (round up to a disk sector)
        if (bootTrackFiles.Sum(f => (f.Length + 255) & 0xff00) != (dpb.SectorsPerTrack * dpb.ReservedTracksOffset * 128))
            throw new Exception("File sizes are wrong for the boot sectors");
        return bootTrackFiles;
    }

    /// <summary>
    /// Writes out the boot track for the Cirtech CPM system
    /// </summary>
    /// <param name="bootTrackFiles">List of fileInfo entries in order.</param>
    private void WriteBootTrack(List<FileInfo> bootTrackFiles)
    {
        byte[] data = new byte[(dpb.SectorsPerTrack * dpb.ReservedTracksOffset * 128)];
        Array.Fill(data, (byte)0x1A);
        int offset = 0;
        foreach (var file in bootTrackFiles)
        {
            var fileData = File.ReadAllBytes(file.FullName);
            fileData.CopyTo(data, offset);
            offset += (fileData.Length + 255) & 0xff00;
        }
        diskImage.WriteBootTrack(data, diskImageData);
        if (dpb != DiskIIDPB)
            return;
        // Write out the dummy file for a disk II 
        var lastDirectoryEntry = GetDirectoryEntry(dpb.DirectorEntriesMax);
        byte[] lastBytes =
        {
            0x00,0x73,0x79,0x73,0x74,0x65,0x6d,0x20,0x20,0xf4,0xf2,0xeb,0x00,0x00,0x00,0x60,
            0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x00,0x00,0x00,0x00
        };
        var dummyEntry = new DirectoryEntry(dpb, lastBytes);
        dummyEntry.CopyTo(lastDirectoryEntry);
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
            (name, _) => RemoveFile(new DirectoryEntry(dpb, userNumber, name)));
    }

    /// <summary>
    /// Extracts files from the disk image.
    /// </summary>
    /// <param name="fileFilters">List of files to filter against.</param>
    internal void ExtractFiles(List<string> fileFilters)
    {
        CpmWildcardAction(
            fileFilters,
            (name, _) => ReadFile(new DirectoryEntry(dpb, userNumber, name)));
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
