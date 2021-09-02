using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace TestSocket.socket
{
    class Command
    {
        /**
    * <code>COMMAND_UNKNOW = 0;</code>
    */
        public const short COMMAND_UNKNOW = 0;

        /**
         * <pre>
         * 握手请求，含http的websocket握手请求
         * </pre>
         * <p>
         * <code>COMMAND_HANDSHAKE_REQ = 1;</code>
         */
        public const short COMMAND_HANDSHAKE_REQ = 1;

        /**
         * <pre>
         * 握手响应，含http的websocket握手响应
         * </pre>
         * <p>
         * <code>COMMAND_HANDSHAKE_RESP = 2;</code>
         */
        public const short COMMAND_HANDSHAKE_RESP = 2;

        /**
         * 登录消息请求
         */
        public const short COMMAND_AUTH_REQ = 5;

        /**
         * 登录消息结果
         */
        public const short COMMAND_AUTH_RESP = 6;

        /**
         * <pre>
         * 关闭请求
         * </pre>
         * <code>COMMAND_CLOSE = 7;</code>
         */
        public const short COMMAND_CLOSE = 7;

        /**
         * <pre>
         * 失败错误
         * </pre>
         * <p>
         * <code>ERROR = -1;</code>
         */
        public const short COMMAND_ERROR = -1;

        /**
         * <pre>
         * 登陆 被挤下线
         * </pre>
         * <p>
         * <code>LOGIN_CONFLICT_RESP = -3;</code>
         */
        public const short COMMAND_LOGIN_CONFLICT_RESP = -3;

        /**
         * <pre>
         * 聊天请求
         * </pre>
         * <p>
         * <code>COMMAND_CHAT_REQ = 11;</code>
         */
        public const short COMMAND_CHAT_REQ = 10;

        /**
         * <pre>
         * 消息回执
         * </pre>
         * <p>
         * <code>MESSAGE_RECEIPT = 11;</code>
         */
        public const short COMMAND_MESSAGE_RECEIPT_REQ = 11;

        /**
         * <pre>
         * 批量拉取群组消息
         * </pre>
         * <p>
         * <code>COMMAND_BATCH_JOIN_GROUP_REQ = 14;</code>
         */
        public const short COMMAND_BATCH_JOIN_GROUP_REQ = 14;

        /**
         * <pre>
         * 批量拉取群组消息结果
         * </pre>
         * <p>
         * <code>COMMAND_BATCH_JOIN_GROUP_RESP = 15;</code>
         */
        public const short COMMAND_BATCH_JOIN_GROUP_RESP = 15;

        /**
         * <pre>
         * 加入群组
         * </pre>
         * <p>
         * <code>JOIN_GROUP_REQ=20;</code>
         */
        public const short COMMAND_JOIN_GROUP_REQ = 20;

        /**
         * <pre>
         * 退出群组
         * </pre>
         * <p>
         * <code>EXIT_GROUP_REQ=20;</code>
         */
        public const short COMMAND_EXIT_GROUP_REQ = 21;


        /**
         * 心跳消息
         */
        public const short COMMAND_PING_REQ = 99;

        /**
         * <pre>
         * 成功请求
         * </pre>
         * <p>
         * <code>SUCCESS = 100;</code>
         */
        public const short COMMAND_SUCCESS = 100;
    }
}
