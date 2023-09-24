namespace NibReader;

public class NibSector
{
    public SectorHeader Header {get;private set;}
    public SectorData Data{get;private set;}
    public NibSector(Memory<byte> header, Memory<byte> data)
    {
        Header = new SectorHeader(header);
        Data = new SectorData(data);
    }

    public override string ToString()
    {
        return $"NibSector Header={Header} Data={Data}";
    }
}