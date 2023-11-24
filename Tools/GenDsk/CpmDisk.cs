namespace GenDsk;
internal class CpmDisk
{
    private const int SectorsPerTrack = 16;
    private const int SectorSize = 256;
    private const int Tracks = 35;
    private const int BootTracks = 3;
    private const byte CpmEmptyByte = 0xE5;
    static int[] prodosSectorMap = { 0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15 };
    static int[] cpmSectorMap = { 0, 3, 6, 9, 12, 15, 2, 5, 8, 11, 14, 1, 4, 7, 10, 13 };
    static int[] rawToDos33Map = { 0, 7, 14, 6, 13, 5, 12, 4, 11, 3, 10, 2, 9, 1, 8, 15 };

    private FileInfo diskFileInfo;
    private byte[] data;
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
        data = new byte[Tracks * SectorsPerTrack * SectorSize];
        // Fill all of the directory with empty bytes...
        Array.Fill(data, CpmEmptyByte, BootTracks * SectorsPerTrack * SectorSize, SectorsPerTrack * SectorSize);
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
        // FileInfo? cpm3sys = files.FirstOrDefault(f => f.Name.Equals("CPM3.SYS", StringComparison.OrdinalIgnoreCase));
        // if (cpm3sys == null) throw new Exception("Could not find file CPM3.SYS");
        // WriteFile(cpm3sys);
    }

    private void WriteFile(FileInfo cpm3sys)
    {
        throw new NotImplementedException();
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
        while (track != 3)
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
        // Todo write out the system track into the CP/M directory
    }

    private void WriteProdosSector(int track, int sector, Span<byte> span)
    {
        WriteRawSector(track, prodosSectorMap[sector], span);
    }

    private void WriteRawSector(int track, int rawSector, Span<byte> span)
    {
        int sector = rawToDos33Map[rawSector];
        span.CopyTo(data.AsSpan((track * SectorsPerTrack + sector) * SectorSize, SectorSize));
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
        File.WriteAllBytes(diskFileInfo.FullName, data);
    }
}
