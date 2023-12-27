namespace CpmDsk;

public interface IDiskImage
{
    // Read the image from disk removing any skew
    public void ReadImage(string name, byte[] diskImageData);
    // Write the image from disk adding any skew
    public void WriteImage(string name, byte[] diskImageData);
    // Write the boottrack using a prodos skew
    public void WriteBootTrack(byte[] bootTrackData, byte[] diskImageData);
}