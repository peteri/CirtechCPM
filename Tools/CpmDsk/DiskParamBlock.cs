using System.Text;

namespace CpmDsk;

/// <summary>
/// CP/M Disk parameter block.
/// </summary>
/// <param name="SectorsPerTrack">SPT Number of 128 byte records per track.</param>
/// <param name="BlockShift">BSH Block shift factor.</param>
/// <param name="BlockMask">BLM Block mask.</param>
/// <param name="ExtentMask">EXM Extent mask.</param>
/// <param name="DriveSectorsMax">DSM Blocks on drive-1.</param>
/// <param name="DirectorEntriesMax">DRM Number of directory entries-1.</param>
/// <param name="AL0">AL0 reserved directory blocks.</param>
/// <param name="AL1">AL1 reserved directory blocks.</param>
/// <param name="CheckVectorSize">CKS size of directory check vector.</param>
/// <param name="ReservedTracksOffset">OFF Reserved tracks (boot)</param>
/// <param name="PhysicalRecordShift">PSH Physical Shift.</param>
/// <param name="PhysicalRecordMask">PHM Physical Mask.</param>
public record DiskParameterBlock
(
    ushort SectorsPerTrack,
    byte BlockShift,
    byte BlockMask,
    byte ExtentMask,
    ushort DriveSectorsMax,
    ushort DirectorEntriesMax,
    byte AL0,
    byte AL1,
    ushort CheckVectorSize,
    ushort ReservedTracksOffset,
    byte PhysicalRecordShift,
    byte PhysicalRecordMask
)
{
    protected virtual bool PrintMembers(StringBuilder stringBuilder)
    {
        stringBuilder.Append($"BLS:{128<<BlockShift} ");
        stringBuilder.Append($"SPT:{SectorsPerTrack:X4} ");
        stringBuilder.Append($"BSH:{BlockShift:X2} ");
        stringBuilder.Append($"BLM:{BlockMask:X2} ");
        stringBuilder.Append($"EXM:{ExtentMask:X2} ");
        stringBuilder.Append($"DSM:{DriveSectorsMax:X4} ");
        stringBuilder.Append($"DRM:{DirectorEntriesMax:X4} ");
        stringBuilder.Append($"AL0:{AL0:X2} ");
        stringBuilder.Append($"AL1:{AL1:X2} ");
        stringBuilder.Append($"CKS:{CheckVectorSize:X4} ");
        stringBuilder.Append($"OFF:{ReservedTracksOffset:X4} ");
        stringBuilder.Append($"PSH:{PhysicalRecordShift:X2} ");
        stringBuilder.Append($"PHM:{PhysicalRecordMask:X2}");
        return true;
    }
};