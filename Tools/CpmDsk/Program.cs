using System.CommandLine;

namespace CpmDsk;

class Program
{
    static void Main(string[] args)
    {
        var destDiskOption = new Option<FileInfo>(name: "--disk-image", description: "Disk II disk image to modify / create.");
        var binaryFolderOption = new Option<DirectoryInfo>(name: "--binaries-folder", description: "Folder for boot track binaries to copy to a disk.");
        var createCommand = new Command("create", "Create a bootable disk image.")
            { destDiskOption, binaryFolderOption };
        createCommand.SetHandler(
            (destDisk, binaryFolder) => Create(destDisk, binaryFolder),
            destDiskOption,
            binaryFolderOption);
        var rootCommand = new RootCommand("CpmDsk - a tool for creating Apple ][ emulator disks")
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