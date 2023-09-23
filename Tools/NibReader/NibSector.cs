namespace NibReader;

public class NibSector
{
    Memory<byte> _header;
    Memory<byte> _data;
    public NibSector(Memory<byte> header, Memory<byte> data)
    {
        _header = header;
        _data = data;
    }

    public override string ToString()
    {
        return "NibSector";
    }
}