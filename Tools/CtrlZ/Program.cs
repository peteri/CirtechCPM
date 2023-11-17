namespace CtrlZ;

class Program
{
    private static void Usage()
    {
        Console.WriteLine("Usage: CtrlZ [Add | Remove] filename");
        Console.WriteLine("Adds or removes Ctrl-Z the CP/M end of file character to a file,");
        Console.WriteLine(" padding to a 128 byte boundary");
    }

    static void Main(string[] args)
    {
        if (args.Length != 2)
        {
            Usage();
            return;
        }
        try
        {
            var fileContents = File.ReadAllBytes(args[1]);
            var command = args[0].ToLower();
            var len = fileContents.Length;
            if (len > 0xfff00)
                throw new Exception("File too big.");
            while (len != 0 && fileContents[len - 1] == 26)
                len--;
            byte[] outputBytes;
            switch (command)
            {
                case "remove":
                    outputBytes = new byte[len];
                    Array.Copy(fileContents, outputBytes, len);
                    break;
                case "add":
                    outputBytes = new byte[(len + 128) & 0xfff80];
                    Array.Copy(fileContents, outputBytes, len);
                    while (len < outputBytes.Length)
                        outputBytes[len++] = 26;
                    break;
                default:
                    Usage();
                    return;
            }
            File.WriteAllBytes(args[1], outputBytes);
        }
        catch (Exception ex)
        {
            Console.WriteLine("Exception thrown {0}", ex.ToString());
        }
    }
}
