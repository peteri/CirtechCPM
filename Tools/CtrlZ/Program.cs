using System.CommandLine;

namespace CtrlZ;

class Program
{
    static void Main(string[] args)
    {
        var fileFilterOption = new Argument<List<string>>(
            name: "files",
            description: "Files to extract or add.",
            getDefaultValue: () => new List<string> { "*.MAC" });
        var addCommand = new Command("add", "Add padding ctrl-z to 128 byte boundary to files.")
            { fileFilterOption };
        var removeCommand = new Command("remove", "Remove ctrl-z from files.")
            { fileFilterOption };
        var rootCommand = new RootCommand("CtrlZ - a tool for adding and removing ctrl-z padding.")
            { addCommand, removeCommand};
        addCommand.SetHandler(Add, fileFilterOption);
        removeCommand.SetHandler(Remove, fileFilterOption);
        rootCommand.Invoke(args);
    }

    private static void DoStuff(List<string> filePatterns, Func<byte[], int, byte[]> action)
    {
        foreach (var filePattern in filePatterns)
        {
            var path = Path.GetDirectoryName(filePattern);
            if (string.IsNullOrEmpty(path))
                path = Directory.GetCurrentDirectory();
            var dir = new DirectoryInfo(path);
            foreach (var fileInfo in dir.GetFiles(Path.GetFileName(filePattern)))
            {
                var fileContents = File.ReadAllBytes(fileInfo.FullName);
                var len = fileContents.Length;
                if (len > 0xfff00)
                    throw new Exception("File too big.");
                while (len != 0 && fileContents[len - 1] == 26)
                    len--;
                byte[] outputBytes = action(fileContents, len);
                File.WriteAllBytes(fileInfo.FullName, outputBytes);
            }
        }
    }

    private static void Add(List<string> files)
    {
        DoStuff(files, (fileContents, len) =>
        {
            var outputBytes = new byte[(len + 128) & 0xfff80];
            Array.Copy(fileContents, outputBytes, len);
            while (len < outputBytes.Length)
                outputBytes[len++] = 26;
            return outputBytes;
        });
    }

    private static void Remove(List<string> files)
    {
        DoStuff(files, (fileContents, len) =>
        {
            var outputBytes = new byte[len];
            Array.Copy(fileContents, outputBytes, len);
            return outputBytes;
        });
    }
}
