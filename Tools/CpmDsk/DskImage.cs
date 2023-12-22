namespace CpmDsk;

public class DskImage : IDiskImage
{
    static int[] prodosSectorMap = { 0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15 };
    static int[] cpmSectorMap = { 0, 3, 6, 9, 12, 15, 2, 5, 8, 11, 14, 1, 4, 7, 10, 13 };
    static int[] rawToDos33Map = { 0, 7, 14, 6, 13, 5, 12, 4, 11, 3, 10, 2, 9, 1, 8, 15 };
    private readonly DiskParameterBlock dpb;

    public DskImage(DiskParameterBlock dpb)
    {
        this.dpb = dpb;
        if (this.dpb != CpmDisk.DiskIIDPB)
            throw new Exception("Sorry, you can only use the 'dsk' image format with Disk II DPB.");
    }

    public void ReadImage(string name, byte[] diskImageData)
    {

    }

    public void WriteImage(string name, byte[] diskImageData)
    {

    }

    public void WriteBootTrack(byte[] bootTrackData)
    {

    }
}