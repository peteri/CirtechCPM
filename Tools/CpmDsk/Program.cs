using System.CommandLine;

namespace CpmDsk;

/// <summary>
/// Tool to write Cirtech format Disks. 
/// 
/// Cannot be used to create sparse files.
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
            description: "Disk image to modify / create.")
        {
            IsRequired = true
        };
        var binaryFolderOption = new Option<DirectoryInfo>(
            name: "--binaries-folder",
            description: "Folder for boot track binaries to copy to a disk. If missing data disk is created.")
        {
            IsRequired = false
        };
        var userNumOption = new Option<int>(
            name: "--user",
            description: "CP/M user number. Default value is 0.",
            getDefaultValue: () => 0)
        {
            IsRequired = false
        };
        var numBlocksOption = new Option<int>(
            name: "--numBlocks",
            description: "Number of ProDos blocks (512 byte) to create a disk with. Defaults to Disk II 280 blocks",
            getDefaultValue: () => 280)
        {
            IsRequired = false
        };
        var fileFilterOption = new Argument<List<string>>(
            name: "files",
            description: "Files to extract or add.",
            getDefaultValue: () => new List<string> { "*.*" });
        // Setup commands
        var directoryCommand = new Command("directory", "Directory of the disk image.")
            { diskImageOption, fileFilterOption, userNumOption};
        var extractCommand = new Command("extract", "Extract files from disk image.")
            { diskImageOption, fileFilterOption, userNumOption};
        var removeCommand = new Command("remove", "Remove files from disk image.")
            { diskImageOption, fileFilterOption, userNumOption};
        var addCommand = new Command("add", "Add files to disk image.")
            { diskImageOption, fileFilterOption, userNumOption};
        var createCommand = new Command("create", "Create a bootable disk image.")
            { diskImageOption, binaryFolderOption, numBlocksOption };
        var dpbCommand = new Command("dpb", "Display DPB for disk size in ProDOS blocks.")
            { numBlocksOption };
        var dpbTestCommand = new Command("dpbtest", "Test the dpb computation.");
        // Set handlers
        directoryCommand.SetHandler(
            (diskImage, fileFilter, userNumber) => ShowDirectory(diskImage, fileFilter, userNumber),
            diskImageOption,
            fileFilterOption,
            userNumOption);
        extractCommand.SetHandler(
            (diskImage, fileFilter, userNumber) => ExtractFiles(diskImage, fileFilter, userNumber),
            diskImageOption,
            fileFilterOption,
            userNumOption);
        removeCommand.SetHandler(
            (diskImage, fileFilter, userNumber) => RemoveFiles(diskImage, fileFilter, userNumber),
            diskImageOption,
            fileFilterOption,
            userNumOption);
        addCommand.SetHandler(
            (diskImage, fileFilter, userNumber) => AddFiles(diskImage, fileFilter, userNumber),
            diskImageOption,
            fileFilterOption,
            userNumOption);
        createCommand.SetHandler(
            (diskImage, binaryFolder, numBlocks) => Create(diskImage, binaryFolder, numBlocks),
            diskImageOption,
            binaryFolderOption,
            numBlocksOption);
        dpbCommand.SetHandler(
            (numBlocks) => ShowDPB(numBlocks),
            numBlocksOption);
        dpbTestCommand.SetHandler(DPBTest);
        var rootCommand = new RootCommand("CpmDsk - a tool for creating Apple ][ emulator disks")
            { createCommand, addCommand, directoryCommand, extractCommand,
            removeCommand, dpbCommand,dpbTestCommand };
        rootCommand.Invoke(args);
    }

    private static void DPBTest()
    {
        CpmDisk.DPBTest();
    }

    private static void ShowDPB(int numBlocks)
    {
        Console.WriteLine("DPB for {0:X4} is {1}", numBlocks, CpmDisk.ComputeDPB(numBlocks));
    }

    private static void ShowDirectory(FileInfo diskImage, List<string> fileFilter, int userNumber)
    {
        var cpmDisk = new CpmDisk(diskImage, userNumber);
        cpmDisk.ReadImage();
        cpmDisk.DirectoryFiles(fileFilter);
    }

    private static void AddFiles(FileInfo diskImage, List<string> fileFilter, int userNumber)
    {
        var cpmDisk = new CpmDisk(diskImage, userNumber);
        cpmDisk.ReadImage();
        cpmDisk.AddFiles(fileFilter);
        cpmDisk.WriteImage();
    }

    private static void RemoveFiles(FileInfo diskImage, List<string> fileFilter, int userNumber)
    {
        var cpmDisk = new CpmDisk(diskImage, userNumber);
        cpmDisk.ReadImage();
        cpmDisk.RemoveFiles(fileFilter);
        cpmDisk.WriteImage();
    }

    private static void ExtractFiles(FileInfo diskImage, List<string> fileFilter, int userNumber)
    {
        var cpmDisk = new CpmDisk(diskImage, userNumber);
        cpmDisk.ReadImage();
        cpmDisk.ExtractFiles(fileFilter);
    }

    private static void Create(FileInfo diskImage, DirectoryInfo? binariesDirectory, int numberOfBlocks)
    {
        var cpmDisk = new CpmDisk(diskImage, numberOfBlocks, 0);
        if (binariesDirectory != null)
            cpmDisk.CopyBootable(binariesDirectory);
        cpmDisk.WriteImage();
    }
}