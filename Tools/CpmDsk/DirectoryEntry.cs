namespace CpmDsk;

public ref struct DirectoryEntry
{
    private Span<byte> entry;

    public DirectoryEntry()
    {
        entry = new byte[32].AsSpan();
    }

    public DirectoryEntry(Span<byte> entry)
    {
        this.entry = entry;
    }

    public DirectoryEntry(string filename)
    {
        int i = 0;
        int j = 1;
        filename = filename.ToUpper();
        entry = new byte[32].AsSpan();
        for (int x = 1; x < 12; x++) entry[x] = 0x20;
        while ((i < 8) && (i < filename.Length) && (filename[i] != '.'))
        {
            if (filename[i] == '*')
            {
                while ((i < filename.Length) && filename[i] != '.') i++;
                while (j != 9) entry[j++] = (byte)'?';
            }
            else
            {
                entry[j++] = (byte)filename[i++];
            }
        }
        // No extension go home
        if (i == filename.Length) return;
        // Filled in everything, filename > 8 characters
        if ((i == 8) && (i < filename.Length) && (filename[i] != '.'))
            throw new Exception("Filename too big " + filename);
        j = 9;          // copy extension
        i++;            // Skip period
        while ((j < 12) && (i < filename.Length))
        {
            if (filename[i] == '*')
            {
                while (j != 12) entry[j++] = (byte)'?';
            }
            else
            {
                entry[j++] = (byte)filename[i++];
            }
        }
    }

    public bool IsNotFile
        => entry[0] >= 0x10;
    public bool IsHidden
        => (entry[11] & 0x80) == 0x80;
    public bool IsAvailable
        => entry[0] == CpmDisk.CpmEmptyByte;
    public void MarkAsEmpty()
        => entry[0] = CpmDisk.CpmEmptyByte;

    public byte GetBlock(int index)
        => entry[0x10 + index];

    public byte SetBlock(int index, byte value)
        => entry[0x10 + index] = value;

    public byte RecordCount
    {
        get => entry[0x0f];
        set => entry[0x0f] = value;
    }

    public byte Extent
    {
        get => entry[0x0c];
        set => entry[0x0c] = value;
    }

    public void CopyTo(DirectoryEntry destination)
    {
        entry.CopyTo(destination.entry);
    }

    public string Name
    {
        get
        {
            string fname = string.Empty;
            for (int i = 1; i < 9; i++)
                if (entry[i] != 0x20)
                    fname += (char)(entry[i] & 0x7f);
            fname += ".";
            for (int i = 9; i < 12; i++)
                if (entry[i] != 0x20)
                    fname += (char)(entry[i] & 0x7f);
            return fname;
        }
    }

    public bool Match(DirectoryEntry fromDisk)
    {
        if (fromDisk.IsNotFile) return false;
        for (int i = 1; i < 12; i++)
            if ((entry[i] != '?') && (entry[i] != (fromDisk.entry[i] & 0x7f)))
                return false;
        return true;
    }
}
