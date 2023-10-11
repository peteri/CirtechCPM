namespace NibReader;
class Program
{
    static int[] prodosSectorMap = { 0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15 };

    static void Main(string[] args)
    {
        if (args.Length != 0)
        {
            // Read in our nibbles
            var tracks = NibReader.ReadTracks(File.ReadAllBytes(args[0]));
            // Save away the prodos ordered sectors
            var bootList = CreateTrackSectors(0, 0, 2);
            SaveSectors("CPMBoot.bin", tracks, bootList, prodosSectorMap);
            var d000List = CreateTrackSectors(0, 2, 14);
            SaveSectors("D000.bin", tracks, d000List, prodosSectorMap);
            var CCP = CreateTrackSectors(1, 0, 13);
            SaveSectors("CCP.bin", tracks, CCP, prodosSectorMap);
            var Toolkey = CreateTrackSectors(1, 13, 3);
            SaveSectors("Toolkey.bin", tracks, Toolkey, prodosSectorMap);
            var CpmLdr = CreateTrackSectors(2, 0, 16);
            SaveSectors("CPMLDR.bin", tracks, CpmLdr, prodosSectorMap);
            // Now do the CPM bits
            // Strip off high bits and display the Toolkey messages
            DumpToolkitMessages();
        }
    }

    private static void DumpToolkitMessages()
    {
        var data = File.ReadAllBytes("Toolkey.bin");
        int i = 0;
        Console.WriteLine();
        int l = 0;
        while (data[i] != 0x1a)
        {
            Console.Write("{0}", (char)(data[i] & 0x7f));
            i++;
            if (i <= 42 * 5)
            {
                if ((i % 42) == 0)
                    Console.WriteLine();
            }
            else
            {
                if (((i - 42 * 5) % 38)== 0)
                    Console.WriteLine();
            }
        }
        Console.WriteLine();
    }

    private static IEnumerable<(int sector, int track)> CreateTrackSectors(int track, int sector, int numberOfSectors)
    {
        var sectors = new List<(int sector, int track)>();
        while (numberOfSectors > 0)
        {
            sectors.Add((sector: sector, track: track));
            numberOfSectors--;
            sector++;
            if (sector == 16)
            {
                track++;
                sector = 0;
            }
        }
        return sectors;
    }

    private static void SaveSectors(
        string filename,
        List<NibSector>[] nibTracks,
        IEnumerable<(int sector, int track)> trackSectors,
        int[] sectorMap)
    {
        Console.Write("Writing to {0} ", filename);
        using (var stream = File.Open(filename, FileMode.Create))
        {
            using (var writer = new BinaryWriter(stream))
            {
                foreach (var ts in trackSectors)
                {
                    var mappedSector = sectorMap[ts.sector];
                    Console.Write("(T:{0:X2} S:{1:X} M:{2:X}) ", ts.track, ts.sector, mappedSector);
                    var sector = nibTracks[ts.track].Where(s => s.Header.Sector == mappedSector).First();
                    writer.Write(sector.Data.Bytes);
                }
            }
        }
        Console.WriteLine(" Done.");
    }
}
