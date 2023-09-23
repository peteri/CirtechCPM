namespace NibReader;
class Program
{
    static void Main(string[] args)
    {
        if (args.Length != 0)
        {
            var tracks = NibReader.ReadTracks(File.ReadAllBytes(args[0]));
        }
    }
}
