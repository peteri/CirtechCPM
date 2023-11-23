using System.CommandLine;

namespace GenDsk;

class Program
{
    static void Main(string[] args)
    {
        var destDiskOption = new Option<FileInfo>(name: "--destination-disk", description: "Destination disk image to create.");
        var binaryFolderOption = new Option<DirectoryInfo>(name: "--binaries-folder", description: "Folder for binaries to copy to a disk.");
        var createCommand = new Command("create", "Create a bootable disk image.")
            { destDiskOption, binaryFolderOption };
        createCommand.SetHandler(
            (destDisk, binaryFolder) => Create(destDisk, binaryFolder),
            destDiskOption,
            binaryFolderOption);
        var rootCommand = new RootCommand("GenDsk - a tool for creating Apple ][ emulator disks")
            { createCommand };
        rootCommand.Invoke(args);
    }

    static public int Create(FileInfo destinationDisk, DirectoryInfo binariesDirectory)
    {
        try
        {
            var cpmDisk = new CpmDisk(destinationDisk);
            cpmDisk.CopyBootable(binariesDirectory);
            cpmDisk.Write();
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine("Create threw an exception {0}", ex.Message);
            return 1;
        }
    }
}

internal class CpmDisk
{
    private const int SectorsPerTrack = 16;
    private const int SectorSize = 256;
    private const int Tracks = 35;
    private const int BootTracks = 3;
    private const byte CpmEmptyByte = 0xE5;
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
        FileInfo? cpm3sys = files.FirstOrDefault(f => f.Name.Equals("CPM3.SYS", StringComparison.OrdinalIgnoreCase));
        if (cpm3sys == null) throw new Exception("Could not find file CPM3.SYS");
        WriteFile(cpm3sys);
    }

    private void WriteFile(FileInfo cpm3sys)
    {
        throw new NotImplementedException();
    }

    private void WriteBootTrack(List<FileInfo> bootTrackFiles)
    {
        throw new NotImplementedException();
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
        return bootTrackFilenames;
    }

    internal void Write()
    {
        File.WriteAllBytes(diskFileInfo.FullName, data);
    }
}