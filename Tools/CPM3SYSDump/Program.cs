
namespace CPM3SYSDump;

class Program
{
    static (int start, int count, byte[] memory) LoadMemory(byte[] filedata, bool resident)
    {
        var memory = new byte[0x10000];
        var filedataOffset = (1 + (resident ? 0 : filedata[1])) * 0x100;
        var pageCount = (resident ? filedata[1] : filedata[3]) * 2;
        var loadAddress = (resident ? filedata[0] : filedata[2]) * 0x100;
        var byteCount = pageCount * 0x80;
        while (pageCount-- > 0)
        {
            loadAddress -= 0x80;
            filedata[filedataOffset..(filedataOffset + 0x80)].CopyTo(memory, loadAddress);
            filedataOffset += 0x80;
        }
        return (loadAddress, byteCount, memory);
    }

    private static void DumpMemory((int start, int count, byte[] memory) memory, string title)
    {
        Console.WriteLine("");
        Console.WriteLine(title);
        Console.WriteLine("------------------------");        
        int count = memory.count / 16;
        int addr = memory.start;
        while (count-- > 0)
        {
            var memline = memory.memory[addr..(addr + 0x10)];
            Console.WriteLine("{0:X4} {1} {2}",
                addr,
                string.Join(" ", memline.Select(m => m.ToString("X2"))),
                string.Join("", memline.Select(m => (m & 0x7f) > 0x1f ? (char)(m & 0x7f) : '.')));
            addr += 16;
        }
    }

    static void Main(string[] args)
    {
        byte[] filedata = File.ReadAllBytes(args[0]);
        var resident = LoadMemory(filedata, resident: true);
        var banked = LoadMemory(filedata, resident: false);
        DumpMemory(resident, "Resident");
        DumpMemory(banked, "Banked");
    }
}
