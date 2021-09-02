using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace TestSocket.socket
{
    class ProBufUtils
    {

        // 编码 将 协议类打包成传输流
        public static byte[] EncodePacket(ImPacket packet)
        {
            byte[] _bytes;

            int bodyLen = 0;

            if (packet.body != null)
            {
                bodyLen = packet.body.Length;
            }

            bool isCompress = true;
            bool is4ByteLength = true;
            bool isEncrypt = true;
            bool isHasSynSeq = false;

            //协议版本号
            byte version = Protocol.VERSION;

            //协议标志位mask
            byte maskByte = ImPacket.EncodeEncrypt(version, isEncrypt);
            maskByte = ImPacket.EncodeCompress(maskByte, isCompress);
            maskByte = ImPacket.EncodeHasSynSeq(maskByte, isHasSynSeq);
            maskByte = ImPacket.Encode4ByteLength(maskByte, is4ByteLength);


            //byteBuffer的总长度是 = 1byte协议版本号+1byte消息标志位+4byte同步序列号(如果是同步发送则都4byte同步序列号,否则无4byte序列号)+2byte命令码+4byte消息的长度+消息体
            int allLen = 1 + 1;
            if (isHasSynSeq)
            {
                allLen += 4;
            }
            allLen += 2 + 4 + bodyLen;

            using (MemoryStream memoryStream = new MemoryStream()) //创建内存流
            {
                //以二进制写入器往这个流里写内容
                BinaryWriter binaryWriter = new BinaryWriter(memoryStream, UTF8Encoding.UTF8);

                binaryWriter.Write(version);
                binaryWriter.Write(maskByte);

                //同步发送设置4byte，同步序列号;
                if (isHasSynSeq)
                {
                    binaryWriter.Write(WriterInt(maskByte));
                }

                binaryWriter.Write(WriteShort(packet.command));
                binaryWriter.Write(WriterInt(bodyLen));
                binaryWriter.Write(packet.body);

                _bytes = memoryStream.ToArray(); //将流内容写入自定义字节数组
                binaryWriter.Close(); //关闭写入器释放资源  
            }

            return _bytes;
        }

        // 解码 将传输流解码成协议类
        public static ImPacket EncodeData(byte[] data)
        {
            // 校验协议头 & 版本号
            if (IsErrorData(data))
            {
                return null;
            }

            using (MemoryStream memoryStream = new MemoryStream(data)) //创建内存流
            {
                //以二进制写入器往这个流里写内容
                BinaryReader buffers = new BinaryReader(memoryStream, UTF8Encoding.UTF8);

                //协议版本号;
                byte version = buffers.ReadByte();

                //标志位
                byte maskByte = buffers.ReadByte();

                //同步发送设 同步序列号;
                int synSeq = 0;
                if (ImPacket.DecodeHasSynSeq(maskByte))
                {
                    synSeq = buffers.ReadInt32();
                }
                // 命令号
                short command = ReadShort(buffers.ReadBytes(2));  

                // 内容长度
                int bodyLen = ReadInt(buffers.ReadBytes(4)); 
                if (bodyLen <= 0)
                {
                    return null;
                }

                byte[] body = new byte[bodyLen];
                buffers.Read(body, 0, bodyLen);

                ImPacket packet = new ImPacket(body, command);
                packet.synSeq = synSeq;

                return packet;
            }
        }

        public static bool IsErrorData(byte[] data)
        {
            if (data == null || data.Length == 0)
            {
                return true;
            }

            //if (data[0] != Protocol.VERSION)
            //{
            //    return true;
            //}

            return false;
        }

   
        public static byte[] WriterInt(int value)
        {
            byte[] bs = BitConverter.GetBytes(value);
            Array.Reverse(bs);
            return bs;
        }

        public static byte[] WriteShort(short value)
        {
            byte[] bs = BitConverter.GetBytes(value);
            Array.Reverse(bs);
            return bs;
        }
        public static byte[] WriterString(string value)
        {

            byte[] result = Encoding.UTF8.GetBytes(value);
            return result;
        }
        public static byte[] WriterLong(long value)
        {
            byte[] result = BitConverter.GetBytes(value);
            Array.Reverse(result);
            return result;
        }



        public static int ReadInt(byte[] data)
        {
            Array.Reverse(data);
            return BitConverter.ToInt32(data, 0); 
        }

        public static short ReadShort(byte[] value)
        {
            Array.Reverse(value);
            return BitConverter.ToInt16(value, 0);
        }

    
        public static long ReadLong(byte[] value)
        {
            Array.Reverse(value);
            return BitConverter.ToInt64(value, 0);
        }

    }
}
