using System.CommandLine;

namespace CpmDsk;

/// <summary>
/// Tool to write Disk II Cirtech format Disks. 
/// Does not support disks that are not for a Disk II.
/// 
/// For wider support look at CiderPress instead.
/// 
/// </summary>
class Program
{
    static void Main(string[] args)
    {
        var diskImageOption = new Option<FileInfo>(
            name: "--disk-image",
            description: "Disk II disk image to modify / create.")
        {
            IsRequired = true
        };
        var binaryFolderOption = new Option<DirectoryInfo>(
            name: "--binaries-folder",
            description: "Folder for boot track binaries to copy to a disk. If missing data disk is created.")
        {
            IsRequired = false
        };
        var fileFilterOption = new Argument<List<string>>(
            name: "files",
            description: "Files to extract or add.",
            getDefaultValue: () => new List<string> { "*.*" });
        // Setup commands
        var directoryCommand = new Command("directory", "Directory of the disk image.")
            { diskImageOption, fileFilterOption};
        var extractCommand = new Command("extract", "Extract files from disk image.")
            { diskImageOption, fileFilterOption};
        var removeCommand = new Command("remove", "Remove files from disk image.")
            { diskImageOption, fileFilterOption};
        var addCommand = new Command("add", "Add files to disk image.")
            { diskImageOption, fileFilterOption};
        var createCommand = new Command("create", "Create a bootable disk image.")
            { diskImageOption, binaryFolderOption };
        // Set handlers
        directoryCommand.SetHandler(
            (diskImage, fileFilter) => ShowDirectory(diskImage, fileFilter),
            diskImageOption,
            fileFilterOption);
        extractCommand.SetHandler(
            (diskImage, fileFilter) => ExtractFiles(diskImage, fileFilter),
            diskImageOption,
            fileFilterOption);
        removeCommand.SetHandler(
            (diskImage, fileFilter) => RemoveFiles(diskImage, fileFilter),
            diskImageOption,
            fileFilterOption);
        addCommand.SetHandler(
            (diskImage, fileFilter) => AddFiles(diskImage, fileFilter),
            diskImageOption,
            fileFilterOption);
        createCommand.SetHandler(
            (diskImage, binaryFolder) => Create(diskImage, binaryFolder),
            diskImageOption,
            binaryFolderOption);
        var rootCommand = new RootCommand("CpmDsk - a tool for creating Apple ][ emulator disks")
            { createCommand, addCommand, directoryCommand, extractCommand, removeCommand };
        rootCommand.Invoke(args);
    }

    private static void ShowDirectory(FileInfo diskImage, List<string> fileFilter)
    {
        var cpmDisk = new CpmDisk(diskImage);
        cpmDisk.ReadImage();
        cpmDisk.DirectoryFiles(fileFilter);
    }

    private static void AddFiles(FileInfo diskImage, List<string> fileFilter)
    {
        var cpmDisk = new CpmDisk(diskImage);
        cpmDisk.ReadImage();
        cpmDisk.AddFiles(fileFilter);
        cpmDisk.WriteImage();
    }

    private static void RemoveFiles(FileInfo diskImage, List<string> fileFilter)
    {
        var cpmDisk = new CpmDisk(diskImage);
        cpmDisk.ReadImage();
        cpmDisk.RemoveFiles(fileFilter);
        cpmDisk.WriteImage();
    }

    private static void ExtractFiles(FileInfo diskImage, List<string> fileFilter)
    {
        var cpmDisk = new CpmDisk(diskImage);
        cpmDisk.ReadImage();
        cpmDisk.ExtractFiles(fileFilter);
    }

    private static void Create(FileInfo diskImage, DirectoryInfo? binariesDirectory)
    {
        var cpmDisk = new CpmDisk(diskImage);
        if (binariesDirectory!=null)
            cpmDisk.CopyBootable(binariesDirectory);
        cpmDisk.WriteImage();
    }
}