namespace CpmDsk;

public class DskImage : IDiskImage
{
    static int[] prodosSectorMap = { 0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15 };
    static int[] cpmSectorMap = { 0, 3, 6, 9, 12, 15, 2, 5, 8, 11, 14, 1, 4, 7, 10, 13 };
    static int[] rawToDos33Map = { 0, 7, 14, 6, 13, 5, 12, 4, 11, 3, 10, 2, 9, 1, 8, 15 };
    private readonly DiskParameterBlock dpb;
    private const int Disk2SectorsPerTrack = 16;
    private const int Disk2Tracks = 35;
    private const int Disk2SectorSize = 0x100;
    public DskImage(DiskParameterBlock dpb)
    {
        this.dpb = dpb;
        if (this.dpb != CpmDisk.DiskIIDPB)
            throw new Exception("Sorry, you can only use the 'dsk' image format with Disk II DPB.");
    }

    public void ReadImage(string name, byte[] diskImageData)
    {
        byte[] diskData = File.ReadAllBytes(name);
        if (diskData.Length != Disk2SectorsPerTrack * Disk2Tracks * Disk2SectorSize)
            throw new Exception(".dsk format must be a disk II format disk");
        for (int track = 0; track < Disk2Tracks; track++)
        {
            for (int cpmSector = 0; cpmSector < Disk2SectorsPerTrack; cpmSector++)
            {
                int sector = rawToDos33Map[cpmSectorMap[cpmSector]];
                var srcSectorData = diskData.AsSpan((track * Disk2SectorsPerTrack + sector) * Disk2SectorSize, Disk2SectorSize);
                var dstSectorData = diskImageData.AsSpan((track * Disk2SectorsPerTrack + cpmSector) * Disk2SectorSize, Disk2SectorSize);
                srcSectorData.CopyTo(dstSectorData);
            }
        }
    }

    public void WriteImage(string name, byte[] diskImageData)
    {
        byte[] diskData = new byte[Disk2SectorsPerTrack * Disk2Tracks * Disk2SectorSize];
        for (int track = 0; track < Disk2Tracks; track++)
        {
            for (int cpmSector = 0; cpmSector < Disk2SectorsPerTrack; cpmSector++)
            {
                int sector = rawToDos33Map[cpmSectorMap[cpmSector]];
                var dstSectorData = diskData.AsSpan((track * Disk2SectorsPerTrack + sector) * Disk2SectorSize, Disk2SectorSize);
                var srcSectorData = diskImageData.AsSpan((track * Disk2SectorsPerTrack + cpmSector) * Disk2SectorSize, Disk2SectorSize);
                srcSectorData.CopyTo(dstSectorData);
            }
        }
        File.WriteAllBytes(name, diskData);
    }

    public void WriteBootTrack(byte[] bootTrackData, byte[] diskImageData)
    {
        for (int track = 0; track < dpb.ReservedTracksOffset; track++)
        {
            for (int sector = 0; sector < Disk2SectorsPerTrack; sector++)
            {
                var srcSectorData = bootTrackData.AsSpan((track * Disk2SectorsPerTrack + sector) * Disk2SectorSize, Disk2SectorSize);
                var cpmSector = Array.IndexOf(cpmSectorMap, prodosSectorMap[sector]);
                var dstSectorData = diskImageData.AsSpan((track * Disk2SectorsPerTrack + cpmSector) * Disk2SectorSize, Disk2SectorSize);
                srcSectorData.CopyTo(dstSectorData);
            }
        }
    }
}