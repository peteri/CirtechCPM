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
            switch (command)
            {
                case "remove":
                    break;
                case "add":
                    break;
                default:
                    Usage();
                    break;

            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Exception thrown {0}", ex.ToString());
        }
    }
}
