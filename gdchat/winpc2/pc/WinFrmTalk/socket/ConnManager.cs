using PBMessage;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using TestSocket.socket;


namespace WinFrmTalk.socket
{
    // socket 连接管理器-重连，ping机制
    class ConnectManager
    {
        //private SocketPingThread mPningThread;
        private ReconnecThread mReconnectThread;
        private SocketCore mSocket;
        private bool isReconnecting;
        //private bool mAlive;

        public int PING_INTERVAL { get; set; } // ping消息间隔 毫秒

        //private int mPingFailedCount; // 失败次数
        private int mLoginFailedCount; // 失败次数

        public ConnectManager(SocketCore socketCore)
        {
            mSocket = socketCore;
        }

        // 收到login 消息
        public void OnReceLoginMessage(bool state)
        {
            if (state)
            {
                // 登陆成功
                isReconnecting = false;
                mLoginFailedCount = 0;
                //////StartPint(); // 开始ping
            }
            else
            {
                // 开始 重连
                //if (mAlive)
                {
                    StartReconnect();
                }
            }
        }

        // 收到ping 消息
        //public void OnRecePingMessage(int state)
        //{
        //    if (state == 0) // ping失败
        //    {
        //        Console.WriteLine("ConnectManager：  ping消息发送失败 " + mPingFailedCount);

        //        if (mPingFailedCount++ >= 2)
        //        {
        //            // 开始 重连
        //            StartReconnect();
        //        }
        //    }
        //    else
        //    {
        //        Console.WriteLine("ConnectManager：  ping消息发送成功");

        //        mPingFailedCount = 0;
        //    }
        //}
        

        private void StartReconnect()
        {
            if (mReconnectThread != null)
            {
                mReconnectThread.StopReconn();
            }

            //if (!mAlive)
            //{
            //    return;
            //}

            Console.WriteLine("ConnectManager：  触发重连");
            mReconnectThread = new ReconnecThread(OnLoopLogin);
            mReconnectThread.StartReconn();
        }

        /// <summary>
        /// 停止 Reconnect 消息
        /// </summary>
        public void StopReconnect()
        {
            Console.WriteLine("StopReconnect");
            
            if (mReconnectThread != null)
            {
                mReconnectThread.StopReconn();
                mReconnectThread = null;
            }
            
            mReconnectThread = null;
        }

        /// <summary>
        /// 停止ping消息
        /// </summary>
        //public void StopPING(bool reconn)
        //{
        //    Console.WriteLine("StopPint" + reconn);
        //    if (mPningThread != null)
        //    {
        //        mPningThread.StopPing();
        //    }

        //    if (mReconnectThread != null && !reconn)
        //    {
        //        mReconnectThread.StopReconn();
        //        mReconnectThread = null;
        //    }

        //    mAlive = reconn;
        //    mPningThread = null;
        //}

        // 开始ping
        //private void StartPint()
        //{
        //    Console.WriteLine("StartPint");

        //    if (PING_INTERVAL == 0)
        //    {
        //        return;
        //    }

        //    // 停止之前的ping 线程
        //    if (mPningThread != null)
        //    {
        //        mPningThread.StopPing();
        //    }

        //    // 停止之前的 login 线程
        //    if (mReconnectThread != null)
        //    {
        //        mReconnectThread.StopReconn();
        //    }

        //    mAlive = true;
        //    mPningThread = new SocketPingThread(OnLoopPING);
        //    mPningThread.StartPing(PING_INTERVAL);
        //}

        // 循环ping回调
        //private void OnLoopPING()
        //{
        //    if (mSocket != null && mSocket.ConnectState == SocketConnectionState.Authenticated)
        //    {
        //        SendPingMessage();
        //    }
        //    else
        //    {   // 发送ping消息失败
        //        OnRecePingMessage(0);
        //    }
        //}

        // 循环登陆回掉
        private void OnLoopLogin()
        {
            Console.WriteLine("OnLoopLogin" + isReconnecting);

            if (isReconnecting)
                return;

            mLoginFailedCount++;
            isReconnecting = true;
            // 自动重连
            //Thread.Sleep(500);
            if (mSocket != null)
            {
                mSocket.Disconnect(true);
            }
            //Thread.Sleep(200);
            if (mSocket != null)
            {
                mSocket.Connect();
            }

            isReconnecting = false;
        }

        // 发送ping消息
        //private void SendPingMessage()
        //{
        //    MessageHead head = new MessageHead();
        //    head.chatType = 1;
        //    head.from = mSocket.userId + "/pc";
        //    head.to = "service";
        //    head.messageId = Guid.NewGuid().ToString("N");

        //    PingMessageProBuf ping = new PingMessageProBuf();
        //    ping.messageHead = head;

        //    mSocket.SendMessage(ping,Command.COMMAND_PING_REQ);
        //    Console.WriteLine("发送 ping 消息");
        //}
    }


    /// <summary>
    /// SocketPingThread  线程类
    /// </summary>
    class SocketPingThread
    {
        private Thread mPningThread;
        private int INTERVAL = 10;
        private ThreadStart mAction;

        public SocketPingThread(ThreadStart action)
        {
            mAction = action;
        }

        public void StartPing(int time)
        {
            INTERVAL = time;

            if (mPningThread == null)
            {
                mPningThread = new Thread(OnLoop);
                mPningThread.Start();
            }
            else
            {
                if (!mPningThread.IsAlive)
                {
                    mPningThread = new Thread(OnLoop);
                    mPningThread.Start();
                }
            }
        }

        public void StopPing()
        {
            mAction = null;
        }

        private void OnLoop()
        {
            while (mAction != null)
            {
                Thread.Sleep(INTERVAL);
                mAction?.Invoke();
            }
        }
    }

    /// <summary>
    /// ReconnecThread  重连 线程类
    /// </summary>
    class ReconnecThread
    {
        private Thread mThread;
        private int INTERVAL = 3 * 1000; // 重连间隔
        private ThreadStart mAction;

        public ReconnecThread(ThreadStart action)
        {
            mAction = action;
        }

        public void StartReconn()
        {
            Console.WriteLine("StartReconn");

            if (mThread == null)
            {
                mThread = new Thread(OnLoop);
                mThread.Start();
            }
            else
            {
                if (!mThread.IsAlive)
                {
                    mThread = new Thread(OnLoop);
                    mThread.Start();
                }
            }
        }

        public void StopReconn()
        {
            Console.WriteLine("StopReconn");

            mAction = null;
        }

        private void OnLoop()
        {
            while (mAction != null)
            {
                Thread.Sleep(INTERVAL);
                mAction?.Invoke();
            }
        }
    }

    //
    // 摘要:
    //     Represents the current state of a Connection
    public enum SocketConnectionState
    {
        //
        // 摘要:
        //     未连接
        Disconnected = 0,
        //
        // 摘要:
        //     连接中
        Connecting = 1,
        //
        // 摘要:
        //    已连接
        Connected = 2,
        //
        // 摘要:
        //     登陆中
        Authenticating = 3,
        //
        // 摘要:
        //     已登录
        Authenticated = 4,

        //
        // 摘要:
        //     被挤下线
        LoginConflict = 5,
    }

}
