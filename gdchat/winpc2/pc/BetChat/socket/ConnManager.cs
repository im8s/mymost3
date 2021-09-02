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
        private ReconnecThread mReconnectThread;
        private SocketCore mSocket;
        private bool isReconnecting;
       
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
            }
            else
            {
                // 开始 重连
                
                 StartReconnect();
            }
        }
        
        private void StartReconnect()
        {
            if (mReconnectThread != null)
            {
                mReconnectThread.StopReconn();
            }
            
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
        
        // 循环登陆回掉
        private void OnLoopLogin()
        {
            Console.WriteLine("OnLoopLogin" + isReconnecting);

            if (isReconnecting)
                return;

            mLoginFailedCount++;
            isReconnecting = true;
            // 自动重连
           
            if (mSocket != null)
            {
                mSocket.Disconnect(true);
            }
           
            if (mSocket != null)
            {
                mSocket.Connect();
            }

            isReconnecting = false;
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
