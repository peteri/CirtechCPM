namespace NibReader;

public class SectorHeader
{
    public SectorHeader(Memory<byte> header)
    {
        Volume = (byte)((header.Span[0] << 1 | 1) & header.Span[1]);
        Track = (byte)((header.Span[2] << 1 | 1) & header.Span[3]);
        Sector = (byte)((header.Span[4] << 1 | 1) & header.Span[5]);
        Checksum = (byte)((header.Span[6] << 1 | 1) & header.Span[7]);
        Error = (byte)(Volume ^ Track ^ Sector) != Checksum;
    }

    public byte Volume { get; private set; }
    public byte Track { get; private set; }
    public byte Sector { get; private set; }
    public byte Checksum { get; private set; }
    public bool Error { get; private set; }

    public override string ToString()
    {
        if (Error)
            return $"Error V:{Volume} T:{Track} S:{Sector}";
        return $"T:{Track:X2} S:{Sector:X2}";
    }
}
