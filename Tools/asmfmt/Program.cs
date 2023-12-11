using System.Text;

namespace asmfmt;

/// <summary>
/// Program to reformat the assembler files.
/// Turn all spaces into tabs with a 8 character interval
/// Columns should look this:
///          1         2         3         4
/// 1234567890123456789012345678901234567890123456789012345678901234567890
/// LABEL:          op   operand            ; Comment           
/// LABEL:          ; Comment      
/// ; Comment      
/// ;* Comment      
/// 
/// Spaces are stripped from the end of a comment field.
/// Probably a bit sleazy but works okay.
/// </summary>
class Program
{
    static void Main(string[] args)
    {
        string filePattern = args[0];
        var path = Path.GetDirectoryName(filePattern);
        if (string.IsNullOrEmpty(path))
            path = Directory.GetCurrentDirectory();
        var dir = new DirectoryInfo(path);
        foreach (var fileInfo in dir.GetFiles(Path.GetFileName(filePattern)))
            AsmFormat(fileInfo);
    }

    private static void AsmFormat(FileInfo fileInfo)
    {
        string srcFile=fileInfo.FullName;
        string bakFile=Path.ChangeExtension(srcFile,"BAK");

        var lines = File.ReadAllLines(srcFile);
        var results = new List<string>(lines.Length);
        foreach (var line in lines)
            results.Add(FormatLine(ParseLine(ExpandTabs(line))));
        if (File.Exists(bakFile))
            File.Delete(bakFile);
        File.Move(srcFile,bakFile);
        File.WriteAllLines(srcFile, results, Encoding.ASCII);
    }

    private static string ExpandTabs(string line)
    {
        int inPos = 0;
        string result = string.Empty;
        while (inPos < line.Length)
        {
            if (line[inPos] == '\t')
            {
                do
                {
                    result = result + ' ';
                }
                while ((result.Length & 7) != 0);
                inPos++;
            }
            else
            {
                result = result + line[inPos++];
            }
        }
        return result;
    }

    private static string FormatLine((LineType linetype, string label, string opcode, string operand, string comment) line)
    {
        if (line.linetype == LineType.Blank)
            return string.Empty;
        if (line.linetype == LineType.CommentPos1)
            return ";" + line.comment;
        if (line.linetype == LineType.Label)
            return line.label;
        string label = "\t\t";
        if ((line.linetype & LineType.Label) == LineType.Label)
        {
            switch (line.label.Length)
            {
                case >= 16: label = line.label + " "; break;
                case >= 8: label = line.label + "\t"; break;
                default: label = line.label + "\t\t"; break;
            }
        }
        if (line.linetype == LineType.CommentOpcode)
            return label + ";" + line.comment;
        if ((line.linetype & ~LineType.Label) == LineType.Comment)
            return label + "\t\t\t;" + line.comment;
        var opcode = (line.opcode.Length < 5) ? (line.opcode + "     ")[..5] : line.opcode + ' ';
        var operand = "\t\t\t";
        if ((line.linetype & LineType.Operand) == LineType.Operand)
        {
            switch (line.operand.Length)
            {
                case >= 19: operand = line.operand + " "; break;
                case >= 11: operand = line.operand + "\t"; break;
                case >= 3: operand = line.operand + "\t\t"; break;
                default: operand = line.operand + "\t\t\t"; break;
            }
        }
        else
        {
            opcode = opcode.TrimEnd();
        }
        if ((line.linetype & LineType.Comment) == LineType.Comment)
            return label + opcode + operand + ";" + line.comment;
        else
            return (label + opcode + operand).TrimEnd();
    }

    [Flags]
    enum LineType
    {
        Blank = 0x00,
        Label = 0x01,
        OpCode = 0x02,
        Operand = 0x04,
        Comment = 0x08,
        CommentPos1 = 0x10,
        CommentOpcode = 0x20
    };

    private static (LineType linetype, string label, string opcode, string operand, string comment) ParseLine(string lineIn)
    {
        var line = lineIn.Replace('\t', ' ').TrimEnd();
        if (line.Length == 0)
            return (LineType.Blank, string.Empty, string.Empty, string.Empty, string.Empty);
        if (line[0] == ';')
        {
            // box of stars around a comment 
            if ((line.Length > 1) && (line[1] == '*'))
                return (LineType.CommentPos1, string.Empty, string.Empty, string.Empty, line.Substring(1));
            // Line of equals force to 60
            if ((line.Length > 1) && (line[1] == '='))
                return (LineType.CommentPos1, string.Empty, string.Empty, string.Empty, new string('=', 60));
            // Comment is of the form ';dfdf' change to '; dfdf'    
            if ((line.Length > 1) && (line[1] != ' '))
                return (LineType.CommentPos1, string.Empty, string.Empty, string.Empty, " " + line.Substring(1));
            // Return what we have.
            return (LineType.CommentPos1, string.Empty, string.Empty, string.Empty, line.Substring(1));
        }
        var linetype = LineType.Blank;
        int curPos = 0;
        string label = "";
        string opcode = "";
        string operand = "";
        string comment = "";
        if (line[curPos] != ' ')
        {
            while (curPos < line.Length && line[curPos] != ' ')
                label += line[curPos++];
            curPos++;
            linetype |= LineType.Label;
        }
        // Do opcode
        while ((curPos < line.Length) && char.IsWhiteSpace(line[curPos])) curPos++;
        if ((curPos < line.Length) && (line[curPos] == ';'))
        {
            comment = line[(curPos + 1)..];
            if ((comment.Length > 0) && (comment[0] != ' '))
                comment = " " + comment;
            var commentType = curPos < 20 ? LineType.CommentOpcode : LineType.Comment;
            return (linetype | commentType, label, string.Empty, string.Empty, comment);
        }
        else
        {
            while ((curPos < line.Length) && !char.IsWhiteSpace(line[curPos]))
                opcode += line[curPos++];
            linetype |= LineType.OpCode;
        }
        // Do operand
        while ((curPos < line.Length) && char.IsWhiteSpace(line[curPos])) curPos++;
        while ((curPos < line.Length) && (line[curPos] != ';'))
            operand += line[curPos++];
        operand = operand.Trim();
        if (operand != string.Empty)
            linetype |= LineType.Operand;
        if ((curPos < line.Length) && (line[curPos] == ';'))
        {
            if (((curPos + 1) < line.Length) && (line[curPos + 1] == ' '))
                curPos++;
            linetype |= LineType.Comment;
            comment = (" " + line[(curPos + 1)..]).TrimEnd();
        }
        return (linetype, label, opcode, operand, comment);
    }
}
