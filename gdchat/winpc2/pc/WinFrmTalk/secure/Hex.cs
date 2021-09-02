using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


class HEX
{

    static readonly char[] HEX_DIGITS = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

    /// <summary>
    /// hex 编码
    /// </summary>
    /// <param name="data"></param>
    /// <returns></returns>
    public static string Encode(byte[] data)
    {
        char[] result = new char[data.Length * 2];
        int c = 0;

        foreach (byte b in data)
        {
            result[c++] = HEX_DIGITS[(b >> 4) & 0xf];
            result[c++] = HEX_DIGITS[b & 0xf];
        }
        return new string(result);
    }

    /// <summary>
    /// hex 解码
    /// </summary>
    /// <param name="hex"></param>
    /// <returns></returns>
    public static byte[] Decode(string hex)
    {
        if (hex == null)
        {
            throw new Exception("hex == null");
        }

        if (hex.Length % 2 != 0)
        {
            throw new Exception("Unexpected hex string: " + hex);
        }


        byte[] result = new byte[hex.Length / 2];

        for (int i = 0; i < result.Length; i++)
        {
            int d1 = DecodeHexDigit(hex.ElementAt(i * 2)) << 4;
            int d2 = DecodeHexDigit(hex.ElementAt(i * 2 + 1));
            result[i] = (byte)(d1 + d2);
        }
        return result;
    }

    private static int DecodeHexDigit(char c)
    {
        if (c >= '0' && c <= '9') return c - '0';
        if (c >= 'a' && c <= 'f') return c - 'a' + 10;
        if (c >= 'A' && c <= 'F') return c - 'A' + 10;

        throw new Exception("Unexpected hex digit: " + c);
    }


}
