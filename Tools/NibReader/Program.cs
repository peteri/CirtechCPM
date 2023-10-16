using System.Reflection.Metadata;
using System.Runtime.CompilerServices;

namespace NibReader;
class Program
{
    static int[] prodosSectorMap = { 0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15 };
    static int[] cpmSectorMap = { 0, 3, 6, 9, 12, 15, 2, 5, 8, 11, 14, 1, 4, 7, 10, 13 };


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
            var CpmDirectory = CreateTrackSectors(3, 0, 8);
            var cpmDir = ReadSectors(tracks, CpmDirectory, cpmSectorMap);
            SaveCpmFile("CPM3.SYS", cpmDir, tracks, cpmSectorMap);
            // Strip off high bits and display the Toolkey messages
            DumpToolkitMessages();
        }
    }

    private static bool NameEquals(byte[] name, Span<byte> dirEntry)
    {
        return MemoryExtensions.SequenceEqual(name.AsSpan(), dirEntry);
    }

    private static void SaveCpmFile(string filename, byte[] cpmDir, List<NibSector>[] nibTracks, int[] sectorMap)
    {
        var cpmSectors = GetCpmSectors(filename, cpmDir);
        using (var stream = File.Open(filename, FileMode.Create))
        {
            using (var writer = new BinaryWriter(stream))
            {
                foreach (int cpmSector in cpmSectors)
                {
                    int track = cpmSector / 32 + 3;
                    int sector128 = cpmSector % 32;
                    int sector = sectorMap[sector128 / 2];
                    var dataOffs = (sector128 & 0x01) == 0x01 ? 0x80 : 00;

                    var sect = nibTracks[track].Where(s => s.Header.Sector == sector).First();
                    writer.Write(sect.Data.Bytes.AsSpan(dataOffs, 128));
                }
            }
        }
    }

    // This only works for a 143K apple ][ disk.
    // File name must be 8.3
    // Converts 1K disk blocks in CP/M directory into
    // 128 byte CP/M sectors 
    // Doesn't deal with wrap around > 35 tracks
    private static IEnumerable<int> GetCpmSectors(string filename, byte[] cpmDir)
    {
        List<int> sectors = new();
        int currentExtent = 0;
        byte[] name = [0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20];
        // Copy file name into the name.
        int i = 0;
        foreach (var c in filename)
            if (c == '.') i = 8; else name[i++] = (byte)c;

        // Scan the directory looking for our file bits
        bool scanAgain = true;   // If we found some extents, then keep scanning
        while (scanAgain)        // as we the extents might be out of order.
        {
            for (int x = 0; x < 64; x++)
            {
                scanAgain = false;  // We might have done everything
                int currentEntryOffs = x * 32;
                if (cpmDir[currentEntryOffs] == 0 && // User area 0
                    NameEquals(name, cpmDir.AsSpan(currentEntryOffs + 1, 11)) &&
                    cpmDir[currentEntryOffs + 12] == currentExtent)
                {
                    scanAgain = true; // Force a rescan.
                    currentExtent++;
                    int sectorCount = cpmDir[currentEntryOffs + 15];
                    for (int b = 16; b < 32; b++)
                    {
                        int block = cpmDir[currentEntryOffs + b];
                        if (block != 0)
                        {
                            int sectOffs = 0;
                            while ((sectorCount > 0) && (sectOffs != 8))
                            {
                                sectors.Add(block * 8 + sectOffs);
                                sectorCount--;
                                sectOffs++;
                            }
                        }
                    }
                }
            }
        }
        return sectors;
    }

    private static void DumpToolkitMessages()
    {
        var data = File.ReadAllBytes("Toolkey.bin");
        int i = 0;
        Console.WriteLine();
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
                if (((i - 42 * 5) % 38) == 0)
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

    private static byte[] ReadSectors(
        List<NibSector>[] nibTracks,
        IEnumerable<(int sector, int track)> trackSectors,
        int[] sectorMap)
    {
        using (var stream = new MemoryStream(0x8000))
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
            return stream.ToArray();
        }
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
                writer.Write(ReadSectors(nibTracks, trackSectors, sectorMap));
            }
        }
        Console.WriteLine(" Done.");
    }
}
