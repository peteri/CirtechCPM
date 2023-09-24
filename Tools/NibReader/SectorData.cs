using System.Data;

namespace NibReader;

public class SectorData
{
    public Memory<byte> RawData { get; private set; }
    private byte[]? _data;
    private static Lazy<byte[]> _conversionTable = new Lazy<byte[]>(InitConversion);
    private bool _error;

    private static byte[] InitConversion()
    {
        // Literal conversion of the Apple Disk II boot ROM code.
        byte[] convTab = new byte[128];
        byte yreg = 0;
        byte xreg = 3;
        byte acc;
        byte bits;
        bool carry;
        while (xreg < 128)
        {
            bits = xreg;
            acc = xreg;
            carry = (acc & 0x80) == 0x80;
            acc = (byte)(acc << 1);
            if ((bits & acc) == 0) goto reject;
            acc |= bits;
            acc ^= 0xff;
            acc &= 0x7e;
        check_dub0:
            if (carry) goto reject;
            carry = (acc & 0x01) == 0x01;
            acc = (byte)(acc >> 1);
            if (acc != 0) goto check_dub0;
            acc = yreg;
            convTab[xreg] = acc;
            yreg++;
        reject:
            xreg++;
        }
        return convTab;
    }

    public SectorData(Memory<byte> header)
    {
        RawData = header;
    }

    public byte[] Data
    {
        get
        {
            if (_data == null)
                _data = DecodeData();
            return _data;
        }
    }

    public bool Error
    {
        get
        {
            if (_data == null)
                _data = DecodeData();
            return _error;
        }
    }

    // Code based on the boot rom
    private byte[] DecodeData()
    {
        var data = new byte[256];
        var twos = new byte[86];
        int bits = 86;
        int dataIndex = 0;
        byte acc = 0;
        byte rawData;
        // Read in the two bits
        while (bits != 0)
        {
            rawData = RawData.Span[dataIndex++];
            acc ^= _conversionTable.Value[rawData - 128];
            bits = bits - 1;
            twos[bits] = acc;
        }
        // Read in the six bits
        while (bits != 256)
        {
            rawData = RawData.Span[dataIndex++];
            acc ^= _conversionTable.Value[rawData - 128];
            data[bits] = acc;
            bits = bits + 1;
        }
        // Check the checksum
        rawData = RawData.Span[dataIndex++];
        acc ^= _conversionTable.Value[rawData - 128];
        if (acc != 0)
        {
            // Bad checksum set the error flag
            _error = true;
        }
        // Do the six and two merge regardless
        int twosIndex = 86;
        for (int i = 0; i < 256; i++)
        {
            twosIndex--;
            if (twosIndex < 0) twosIndex = 85;
            data[i] = (byte)(data[i] << 1 | twos[twosIndex] & 0x01);
            twos[twosIndex] = (byte)(twos[twosIndex] >> 1);
            data[i] = (byte)(data[i] << 1 | twos[twosIndex] & 0x01);
            twos[twosIndex] = (byte)(twos[twosIndex] >> 1);
        }
        return data;
    }

    public override string ToString()
    {
        if (Error)
            return "Error";
        return String.Join(" ", Data.Take(16).Select(b => b.ToString("X2")));
    }
}
