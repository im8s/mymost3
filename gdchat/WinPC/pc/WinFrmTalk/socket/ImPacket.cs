using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace TestSocket.socket
{
    class ImPacket
    {
        //消息体;
        public byte[] body;

        //消息命令
        public short command;

        // 同步消息
        public int synSeq = 0;

        public int version = 0;

        public ImPacket(byte[] body, short command)
        {
            this.body = body;
            this.command = command;
        }

        // 编码加密

        public static byte EncodeEncrypt(byte bs, bool isEncrypt)
        {
            if (isEncrypt)
            {
                return (byte)(bs | Protocol.FIRST_BYTE_MASK_ENCRYPT);
            }
            else
            {
                return (byte)(Protocol.FIRST_BYTE_MASK_ENCRYPT & 0b01111111);
            }
        }

        // 编码命令
        public static byte EncodeCompress(byte bs, bool isCompress)
        {
            if (isCompress)
            {
                return (byte)(bs | Protocol.FIRST_BYTE_MASK_COMPRESS);
            }
            else
            {
                return (byte)(bs & (Protocol.FIRST_BYTE_MASK_COMPRESS ^ 0b01111111));
            }
        }

        // 编码同步号
        public static byte EncodeHasSynSeq(byte bs, bool hasSynSeq)
        {
            if (hasSynSeq)
            {
                return (byte)(bs | Protocol.FIRST_BYTE_MASK_HAS_SYNSEQ);
            }
            else
            {
                return (byte)(bs & (Protocol.FIRST_BYTE_MASK_HAS_SYNSEQ ^ 0b01111111));
            }
        }


        // 编码长度
        public static byte Encode4ByteLength(byte bs, bool is4ByteLength)
        {
            if (is4ByteLength)
            {
                return (byte)(bs | Protocol.FIRST_BYTE_MASK_4_BYTE_LENGTH);
            }
            else
            {
                return (byte)(bs & (Protocol.FIRST_BYTE_MASK_4_BYTE_LENGTH ^ 0b01111111));
            }
        }


        //-----------------------------------------------------------


        // 是否同步包
        public static bool DecodeHasSynSeq(byte maskByte)
        {
            return (Protocol.FIRST_BYTE_MASK_HAS_SYNSEQ & maskByte) != 0;
        }



        //// 解码命令
        //public bool DecodeCompress(byte version)
        //{
        //    return (Protocol.FIRST_BYTE_MASK_COMPRESS & version) != 0;
        //}



        //public static bool DecodeHasSynSeq(byte maskByte)
        //{
        //    return (Protocol.FIRST_BYTE_MASK_HAS_SYNSEQ & maskByte) != 0;
        //}




        //public static byte encode4ByteLength(byte bs, boolean is4ByteLength)
        //{
        //    if (is4ByteLength)
        //    {
        //        return (byte)(bs | Protocol.FIRST_BYTE_MASK_4_BYTE_LENGTH);
        //    }
        //    else
        //    {
        //        return (byte)(bs & (Protocol.FIRST_BYTE_MASK_4_BYTE_LENGTH ^ 0b01111111));
        //    }
        //}


        //public static byte DecodeVersion(byte version)
        //{
        //    return (byte)(Protocol.FIRST_BYTE_MASK_VERSION & version);
        //}



        ///**
        // * 计算消息头占用了多少字节数
        // *
        // * @return 2017年1月31日 下午5:32:26
        // */
        //public int CalcHeaderLength(bool is4byteLength)
        //{
        //    int ret = Protocol.LEAST_HEADER_LENGHT;
        //    if (is4byteLength)
        //    {
        //        ret += 2;
        //    }
        //    if (this.getSynSeq() > 0)
        //    {
        //        ret += 4;
        //    }
        //    return ret;
        //}


        ///*释放message的body*/
        //public void ReleaseMessageBody()
        //{
        //    this.bytes = null;
        //}
    }
}
