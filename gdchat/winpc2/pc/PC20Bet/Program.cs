using Microsoft.Win32;
using System;
using System.Configuration;
using System.Diagnostics;
using System.Drawing.Text;
using System.IO;
using System.Security.AccessControl;
using System.Windows.Forms;
using WinFrmTalk.Properties;


namespace WinFrmTalk
{
    public static class Program
    {
        /// <summary>
        /// 判断.Net Framework的Release是否符合需要
        /// (.Net Framework 版本在4.0及以上)
        /// </summary>
        /// <param name="release">需要的版本 version = 4.5 release = 379893</param>
        /// <returns></returns>
        private static bool GetDotNetRelease(int release)
        {
            const string subkey = @"SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\";

            using (RegistryKey ndpKey = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry32).OpenSubKey(subkey))
            {
                if (ndpKey != null && ndpKey.GetValue("Release") != null)
                {
                    return (int)ndpKey.GetValue("Release") >= release ? true : false;
                }

                return false;
            }
        }

        /// <summary>
        /// 判断.Net Framework的Version是否符合需要
        /// (.Net Framework 版本在2.0及以上)
        /// </summary>
        /// <param name="version">需要的版本 version = 4.5</param>
        /// <returns></returns>
        private static bool GetDotNetVersion(string version)
        {
            string oldname = "0";
            using (RegistryKey ndpKey =
                RegistryKey.OpenRemoteBaseKey(RegistryHive.LocalMachine, "").
                OpenSubKey(@"SOFTWARE\Microsoft\NET Framework Setup\NDP\"))
            {
                foreach (string versionKeyName in ndpKey.GetSubKeyNames())
                {
                    if (versionKeyName.StartsWith("v"))
                    {
                        RegistryKey versionKey = ndpKey.OpenSubKey(versionKeyName);
                        string newname = (string)versionKey.GetValue("Version", "");
                        if (string.Compare(newname, oldname) > 0)
                        {
                            oldname = newname;
                        }
                        if (newname != "")
                        {
                            continue;
                        }
                        foreach (string subKeyName in versionKey.GetSubKeyNames())
                        {
                            RegistryKey subKey = versionKey.OpenSubKey(subKeyName);
                            newname = (string)subKey.GetValue("Version", "");
                            if (string.Compare(newname, oldname) > 0)
                            {
                                oldname = newname;
                            }
                        }
                    }
                }
            }

            return string.Compare(oldname, version) > 0 ? true : false;
        }
            
        /// <summary>
        /// 程序内字体集合
        /// </summary>
        public static PrivateFontCollection ApplicationFontCollection { get; set; } = new PrivateFontCollection();

        //string url = "";//官方测试服

        /// <summary>
        /// 应用程序的主入口点。
        /// </summary>
        [STAThread]
        public static void Main()
        {
            try
            {
                SetAccess("Users", Application.StartupPath);
                // 异常处理
                //Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);
                ////处理UI线程异常
                //Application.ThreadException += new System.Threading.ThreadExceptionEventHandler(Application_ThreadException);
                ////处理非UI线程异常
                //AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(CurrentDomain_UnhandledException);

                //创建用户数            
                /*string dbPath = Environment.CurrentDirectory + "\\db\\" + Applicate.UserId + ".db";
                if (!File.Exists(dbPath))
                {  
                    File.Create(dbPath).Dispose();
                }*/

                Helpers.LoadFont(Resources.iconfont); //添加字体图标集合文件
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                Applicate.initSystemVersion();

                bool bCanRun = GetDotNetVersion("4.0");

                if(!bCanRun)
                {
                    if (MessageBox.Show("当前缺少运行环境，是否进行安装！\r\n\r\n安装完成后将自动启动软件", 
                                            "提示", MessageBoxButtons.YesNo) == DialogResult.No)
                        return;

                    Process.Start(@"_framework4.0.exe").WaitForExit(); //一直等待，直到Framework安装完成

                    bCanRun = GetDotNetVersion("4.0");
                }
                
                if(bCanRun)
                {
                    Application.Run(new FrmBetMain());
                }
            }
            catch (Exception e)
            {

            }
        }


        // Ui崩溃回调处理
        static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            LogUtils.Error("UnhandledException : " + e.IsTerminating.ToString());
            LogUtils.Error(e.ExceptionObject.ToString());
        }

        // 线程崩溃回调处理
        static void Application_ThreadException(object sender, System.Threading.ThreadExceptionEventArgs e)
        {
            LogUtils.Error("ThreadException:" + e.Exception.Message);
            LogUtils.Error(e.Exception.ToString());
        }
        /// <summary>
        /// 为指定用户组，授权目录指定完全访问权限
        /// </summary>
        /// <param name="user">用户组，如Users</param>
        /// <param name="folder">实际的目录</param>
        /// <returns></returns>
        private static bool SetAccess(string user, string folder)
        {
            //定义为完全控制的权限
            const FileSystemRights Rights = FileSystemRights.FullControl;

            //添加访问规则到实际目录
            var AccessRule = new FileSystemAccessRule(user, Rights,
                InheritanceFlags.None,
                PropagationFlags.NoPropagateInherit,
                AccessControlType.Allow);

            var Info = new DirectoryInfo(folder);
            var Security = Info.GetAccessControl(AccessControlSections.Access);

            bool Result;
            Security.ModifyAccessRule(AccessControlModification.Set, AccessRule, out Result);
            if (!Result) return false;

            //总是允许再目录上进行对象继承
            const InheritanceFlags iFlags = InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit;

            //为继承关系添加访问规则
            AccessRule = new FileSystemAccessRule(user, Rights,
                iFlags,
                PropagationFlags.InheritOnly,
                AccessControlType.Allow);

            Security.ModifyAccessRule(AccessControlModification.Add, AccessRule, out Result);
            if (!Result) return false;

            Info.SetAccessControl(Security);

            return true;
        }
        
    }
}

