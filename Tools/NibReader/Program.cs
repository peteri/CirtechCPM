
namespace NibReader;
class Program
{
    static void Main(string[] args)
    {
        // TODO Do some proper parsing of stuff to allow dumping of data.
        if (args.Length != 0)
        {
            var tracks = NibReader.ReadTracks(File.ReadAllBytes(args[0]));
            // See if the decode looks right
            DisplaySector(tracks, 0, 0);
            DisplaySector(tracks, 0, 2);
        }
    }

    private static void DisplaySector(List<NibSector>[] nibTracks, int track, int sector)
    {
        Console.WriteLine("Track {0} Sector {1} {2}", track, sector, nibTracks[track].First(s => s.Header.Sector == sector));
    }
}
