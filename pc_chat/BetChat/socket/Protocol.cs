using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace TestSocket.socket
{
    class Protocol
    {
        /**
     * 心跳字节
     */
        public const byte HEARTBEAT_BYTE = 0B10000000;

        /**
         * 握手字节
         */
        public const byte HANDSHAKE_BYTE = 0B10000001;

        /**
         * 协议版本号
         */
        public const byte VERSION = 0x01;

        public const byte TCP = 1;

        public const byte WEBSOCKET = 2;

        public const byte HTTP = 3;

        public const String COOKIE_NAME_FOR_SESSION = "jim-s";
        /**
         * 消息体最多为多少
         */
        public const int MAX_LENGTH_OF_BODY = (int)(1024 * 1024 * 2.1); //只支持多少M数据

        /**
         * 消息头最少为多少个字节
         */
        public const int LEAST_HEADER_LENGHT = 4;//1+1+2 + (2+4)

        /**
         * 加密标识位mask，1为加密，否则不加密
         */
        public const byte FIRST_BYTE_MASK_ENCRYPT = 128;

        /**
         * 压缩标识位mask，1为压缩，否则不压缩
         */
        public const byte FIRST_BYTE_MASK_COMPRESS = 0B01000000;

        /**
         * 是否有同步序列号标识位mask，如果有同步序列号，则消息头会带有同步序列号，否则不带
         */
        public const byte FIRST_BYTE_MASK_HAS_SYNSEQ = 0B00100000;

        /**
         * 是否是用4字节来表示消息体的长度
         */
        public const byte FIRST_BYTE_MASK_4_BYTE_LENGTH = 0B00010000;

        /**
         * 版本号mask
         */
        public const byte FIRST_BYTE_MASK_VERSION = 0B00001111;

    }
}
