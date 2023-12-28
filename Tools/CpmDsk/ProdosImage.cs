namespace CpmDsk;

public class ProdosImage : IDiskImage
{
    public void ReadImage(string name, byte[] diskImageData)
    {
        byte[] diskData = File.ReadAllBytes(name);
        Array.Copy(diskData,diskImageData,diskData.Length);
    }

    public void WriteBootTrack(byte[] bootTrackData, byte[] diskImageData)
    {
        Array.Copy(bootTrackData,diskImageData,bootTrackData.Length);
    }

    public void WriteImage(string name, byte[] diskImageData)
    {
        File.WriteAllBytes(name,diskImageData);
    }
}