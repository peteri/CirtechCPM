namespace CpmDsk;

/// <summary>
/// This wraps a backing span containing a CP/M format directory entry.
/// It only understands about simple entries and ignores anything with
/// a 16 bit block number. Designed for use with Apple ][ disk formats.
/// </summary>
public ref struct DirectoryEntry
{
    private Span<byte> entry;
    private readonly DiskParameterBlock dpb;

    /// <summary>
    /// Blank constructor.
    /// </summary>
    /// <param name="dpb">Disk Parameter block</param>
    public DirectoryEntry(DiskParameterBlock dpb)
    {
        entry = new byte[32].AsSpan();
        this.dpb = dpb;
    }

    /// <summary>
    /// Constructor used to create a disk entry from a block read.
    /// of a directory entry.
    /// </summary>
    /// <param name="dpb">Disk Parameter block</param>
    /// <param name="entry">Span of bytes for a directory entry from disk.</param>
    public DirectoryEntry(DiskParameterBlock dpb, Span<byte> entry)
    {
        this.entry = entry;
        this.dpb = dpb;
    }

    /// <summary>
    /// Constructor used to create a blank entry from a file name.
    /// Supports wild cards i.e. it extends P*.C* to P???????.C??
    /// Throws exceptions if file name is too big
    /// </summary>
    /// <param name="dpb">Disk Parameter block</param>
    /// <param name="userNumber">CP/M usernumber</param>
    /// <param name="filename">Filename to use</param>
    /// <exception cref="Exception">Exception for when the file name is too big.</exception>
    public DirectoryEntry(DiskParameterBlock dpb, byte userNumber, string filename)
    {
        this.dpb = dpb;
        int i = 0;
        int j = 1;
        filename = filename.ToUpper();
        entry = new byte[32].AsSpan();
        entry[0] = userNumber;
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

    /// <summary>
    /// Returns true if a directory entry is not a file
    /// OR if it is a password entry, date, label.
    /// </summary>
    public bool IsNotFile
        => entry[0] >= 0x10;

    /// <summary>
    /// Returns true if a file is marked as Hidden
    /// </summary>
    public bool IsHidden
        => (entry[11] & 0x80) == 0x80;

    /// <summary>
    /// Returns true if a directory starts with the CP/M empty byte character.
    /// </summary>
    public bool IsAvailable
        => entry[0] == CpmDisk.CpmEmptyByte;

    /// <summary>
    /// Marks a directory entry as deleted.
    /// </summary>
    public void MarkAsEmpty()
        => entry[0] = CpmDisk.CpmEmptyByte;

    /// <summary>
    /// Gets the block number for directory entry
    /// </summary>
    /// <param name="dpb">Disk Parameter block</param>
    /// <param name="index">Index of the block allocation</param>
    /// <returns>Block allocation for a directory entry.</returns>
    public ushort GetBlock(int index)
        => (dpb.DriveSectorsMax < 0x100) ?
            entry[0x10 + index] :
            (ushort)(entry[0x10 + (index >> 1)] + (entry[0x11 + (index >> 1)] << 8));

    /// <summary>
    /// Sets the block number for a directory entry
    /// </summary>
    /// <param name="dpb">Disk Parameter block</param>
    /// <param name="index">Index of the block allocation</param>
    /// <param name="value">New value of block</param>
    /// <returns>Block number</returns>
    public void SetBlock(int index, ushort value)
    {
        if (dpb.DriveSectorsMax < 0x100)
        {
            entry[0x10 + index] = (byte)value;
        }
        else
        {
            entry[0x10 + (index >> 1)] = (byte)(value & 0xff);
            entry[0x11 + (index >> 1)] = (byte)(value >> 8);
        }
    }
    
    /// <summary>
    /// Gets or sets the record count of the directory entry.
    /// </summary>
    public byte RecordCount
    {
        get => entry[0x0f];
        set => entry[0x0f] = value;
    }

    /// <summary>
    /// Gets or sets the extent field of the directory entry.
    /// </summary>
    public byte Extent
    {
        get => entry[0x0c];
        set => entry[0x0c] = value;
    }

    /// <summary>
    /// Copies a directory entry into another directory entry.
    /// Used during the write process.
    /// </summary>
    /// <param name="destination">Destination directory entry.</param>
    public void CopyTo(DirectoryEntry destination)
    {
        entry.CopyTo(destination.entry);
    }

    /// <summary>
    /// Gets the name from the directory entry as a name without spaces
    /// but a dot between the extensions and name.
    /// </summary>
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

    /// <summary>
    /// Compares a directory entry with another, supports question mark as 
    /// a wild card character.
    /// </summary>
    /// <param name="fromDisk">Entry from disk</param>
    /// <returns>true if names match.</returns>
    public bool Match(DirectoryEntry fromDisk)
    {
        if (fromDisk.IsNotFile) return false;
        for (int i = 0; i < 12; i++)
            if ((entry[i] != '?') && (entry[i] != (fromDisk.entry[i] & 0x7f)))
                return false;
        return true;
    }
}
