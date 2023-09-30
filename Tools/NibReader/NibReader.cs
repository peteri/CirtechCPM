namespace NibReader;

public class NibReader
{
    public const int NumberOfTracks = 35;
    private const int HeaderLength = 8;
    private const int DataLength = 342;

    public static List<NibSector>[] ReadTracks(Memory<byte> data)
    {
        var trackLength = data.Length / NumberOfTracks;
        var tracks = new List<NibSector>[NumberOfTracks];
        for (int i = 0; i < NumberOfTracks; i++)
            tracks[i] = ReadTrack(data.Slice(trackLength * i, trackLength));
        return tracks;
    }

    private enum ReaderState
    {
        FindSectorHeader,
        FindSectorData,
    }

    // Header starts with D5 AA 96 Ends with DE AA EB
    // Data starts D5 AA AD data[342] checksum DE AA EB
    // Trailing byte seems to be variable on the real data.
    private static List<NibSector> ReadTrack(Memory<byte> trackData)
    {
        var readerState = ReaderState.FindSectorHeader;
        var sectors = new List<NibSector>();
        Memory<byte> header = Memory<byte>.Empty;
        int dataIndex = 2;
        while (dataIndex < trackData.Length)
        {
            switch (readerState)
            {
                case ReaderState.FindSectorHeader:
                    if ((trackData.Span[dataIndex - 2] == 0xD5) &&
                        (trackData.Span[dataIndex - 1] == 0xAA) &&
                        (trackData.Span[dataIndex - 0] == 0x96) &&
                        (trackData.Span[dataIndex + HeaderLength + 1] == 0xDE) &&
                        (trackData.Span[dataIndex + HeaderLength + 2] == 0xAA))
                    {
                        header = trackData.Slice(dataIndex + 1, HeaderLength);
                        readerState = ReaderState.FindSectorData;
                        dataIndex += HeaderLength + 6;
                    };
                    break;
                case ReaderState.FindSectorData:
                    if ((trackData.Span[dataIndex - 2] == 0xD5) &&
                        (trackData.Span[dataIndex - 1] == 0xAA) &&
                        (trackData.Span[dataIndex - 0] == 0xAD) &&
                        (trackData.Span[dataIndex + DataLength + 2] == 0xDE) &&
                        (trackData.Span[dataIndex + DataLength + 3] == 0xAA))
                    {
                        // Grab the data including checksum
                        var data = trackData.Slice(dataIndex + 1, DataLength+1);
                        if (!header.IsEmpty)
                            sectors.Add(new NibSector(header, data));
                        header = Memory<byte>.Empty;
                        dataIndex += DataLength + 6;
                        readerState = ReaderState.FindSectorHeader;
                    };
                    break;
            }
            dataIndex++;
        }
        return sectors;
    }
}