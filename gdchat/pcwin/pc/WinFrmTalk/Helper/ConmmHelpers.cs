using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Interop;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    public static class Helpers
    {

        #region 内存回收
        [DllImport("kernel32.dll", EntryPoint = "SetProcessWorkingSetSize")]
        public static extern int SetProcessWorkingSetSize(IntPtr process, int minSize, int maxSize);
        /// <summary> 
        /// 释放内存
        /// </summary> 
        public static void ClearMemory()
        {
            GC.Collect();
            GC.WaitForPendingFinalizers();
            if (Environment.OSVersion.Platform == PlatformID.Win32NT)
            {
                SetProcessWorkingSetSize(System.Diagnostics.Process.GetCurrentProcess().Handle, -1, -1);
            }
        }
        #endregion

        #region 循环释放控件
        public static void DisposeCrl(Control crl)
        {
            for (int index = crl.Controls.Count - 1; index > -1; index--)
            {
                Control item = crl.Controls[index];
                if (item.Controls.Count > 0)        //移除子控件
                    DisposeCrl(item);

                try
                {
                    //if (item.BackgroundImage != null)   //释放背景图片
                    //{
                    //    item.BackgroundImage.Dispose();
                    //    item.BackgroundImage = null;
                    //}
                    //if (item is Label lbl && lbl.Image != null)   //释放背景图片
                    //{
                    //    lbl.Image.Dispose();
                    //    lbl.Image = null;
                    //}
                    crl.Controls.RemoveAt(index);       //从父容器中移除   
                    item.Dispose();     //释放控件
                }
                catch(Exception ex) { LogHelper.log.Error("-----------已经被释放的控件：\n" + ex.Message); }
            }
        }
        #endregion

        #region 按索引移除数组的某一项
        public static int[] RemoveItem(this int[] array, int index)
        {
            var list = array.ToList();
            list.RemoveAt(index);
            return list.ToArray();
        }

        public static Control[] RemoveItem(this Control[] array, int index)
        {
            var list = array.ToList();
            list.RemoveAt(index);
            return list.ToArray();
        }
        #endregion

        #region FriendClone
        /// <summary>
        /// 重新生成一个Friend
        /// </summary>
        /// <param name="source"></param>
        /// <returns></returns>
        public static Friend Clone(this Friend source)
        {
            return new Friend
            {
                AllowConference = source.AllowConference,
                AllowInviteFriend = source.AllowInviteFriend,
                AllowSendCard = source.AllowSendCard,
                AllowSpeakCourse = source.AllowSpeakCourse,
                AllowUploadFile = source.AllowUploadFile,
                AreaCode = source.AreaCode,
                AreaId = source.AreaId,
                CityId = source.CityId,
                Content = source.Content,
                CreateTime = source.CreateTime,
                Description = source.Description,
                IsAtMe = source.IsAtMe,
                UserType = source.UserType,
                IsGroup = source.IsGroup,
                IsNeedVerify = source.IsNeedVerify,
                IsOnLine = source.IsOnLine,
                IsOpenReadDel = source.IsOpenReadDel,
                IsSendRecipt = source.IsSendRecipt,
                LastInput = source.LastInput,
                LastMsgTime = source.LastMsgTime,
                LastMsgType = source.LastMsgType,
                MsgNum = source.MsgNum,
                NickName = source.NickName,
                ProvinceId = source.ProvinceId,
                RemarkName = source.RemarkName,
                Role = source.Role,
                RoomId = source.RoomId,
                Sex = source.Sex,
                ShowMember = source.ShowMember,
                ShowRead = source.ShowRead,
                Status = source.Status,
                Telephone = source.Telephone,
                TopTime = source.TopTime,
                UserId = source.UserId
            };
        }
        #endregion

        #region Json字符串转指定类型
        /// <summary>
        /// Json字符串转指定类型
        /// </summary>
        /// <typeparam name="T">实体类类型</typeparam>
        /// <param name="text">Json字符串</param>
        /// <returns></returns>
        public static T JsonStringToObject<T>(this string text)
        {
            T t = default(T);
            try
            {
                t = JsonConvert.DeserializeObject<T>(text);
            }
            catch (Exception ex)
            {
               LogUtils.Log(ex.Message);
            }
            return t;
        }
        #endregion

        #region 日期转时间戳
        /// <summary>
        /// 日期转时间戳
        /// </summary>
        /// <param name="Datetime">需要转换的时间(空值默认为)</param>
        /// <param name="isMillSeconds">是否为毫秒时间戳</param>
        /// <returns>返回的时间戳</returns>
        public static double DatetimeToStamp(DateTime Datetime, bool isMillSeconds = false)
        {
            DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));//当地时区
            //通过减去初始日期来获取时间戳
            long timeStamp; //相差毫秒数
            //如果Datetime为空的话,,就使用当前的时间
            if (isMillSeconds)
            {
                if (Datetime == null)
                {
                    timeStamp = (long)(DateTime.Now - startTime).TotalMilliseconds;
                }
                else
                {
                    timeStamp = (long)(Datetime - startTime).TotalMilliseconds;
                }
            }
            else
            {
                if (Datetime == null)
                {
                    timeStamp = (long)(DateTime.Now - startTime).TotalSeconds;
                }
                else
                {
                    timeStamp = (long)(Datetime - startTime).TotalSeconds;
                }
            }

            //返回时间戳
            return timeStamp;
        }
        #endregion

        #region 时间戳转换为日期
        /// <summary>
        /// 时间戳转日期
        /// </summary>
        /// <param name="TimeStamp">时间戳</param>
        /// <returns>转换后的日期</returns>
        public static DateTime StampToDatetime(this double TimeStamp)
        {
            DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));//当地时区
            DateTime dt = startTime.AddSeconds(TimeStamp);
            //返回转换后的日期
            return dt;
        }
        #endregion

        #region 流转为图片
        internal static Image ByteToImg(byte[] stream)
        {
            Image img = Image.FromStream(new MemoryStream(stream));//得到对应的图片
            return img;
        }
        #endregion


        [DllImport("gdi32.dll")]
        private static extern IntPtr AddFontMemResourceEx(IntPtr pbFont, uint cbFont, IntPtr pvd, [In] ref uint pcFonts);

        #region 将文件转为字体
        /// <summary>
        /// 将文件转为字体
        /// </summary>
        /// <param name="fontFile">字体文件</param>
        /// <returns>字体类型</returns>
        public static System.Drawing.FontFamily LoadFont(byte[] fontFile)
        {
            int dataLength = fontFile.Length;
            IntPtr fontPtr = Marshal.AllocCoTaskMem(dataLength);
            Marshal.Copy(fontFile, 0, fontPtr, dataLength);
            uint cFonts = 0;
            AddFontMemResourceEx(fontPtr, (uint)fontFile.Length, IntPtr.Zero, ref cFonts);
            Program.ApplicationFontCollection.AddMemoryFont(fontPtr, dataLength);
            return Program.ApplicationFontCollection.Families.Last();
        }
        #endregion

        #region 复制一条消息
        public static agsXMPP.protocol.client.Message Clone(this agsXMPP.protocol.client.Message msg)
        {
            return new agsXMPP.protocol.client.Message
            {
                Body = msg.Body,
                Chatstate = msg.Chatstate,
                From = msg.From,
                Headers = msg.Headers,
                Html = msg.Html,
                Id = msg.Id,
                InnerXml = msg.InnerXml,
                Language = msg.Language,
                Namespace = msg.Namespace,
                Nickname = msg.Nickname,
                NodeType = msg.NodeType,
                Prefix = msg.Prefix,
                Type = msg.Type
            };
        }
        #endregion

        /// <summary>
        /// 字节数组生成图片
        /// </summary>
        /// <param name="Bytes">字节数组</param>
        /// <returns>图片</returns>
        public static Image byteArrayToImage(byte[] Bytes)
        {
            MemoryStream ms = new MemoryStream(Bytes);
            return Image.FromStream(ms, true);
        }

        #region 音频转码
        /// <summary>
        /// 音频转码
        /// </summary>
        /// <param name="pathOld">原有的文件路径</param>
        /// <param name="pathNew">需要新转换的路径</param>
        /// <returns>执行结果</returns>
        public static string AmrConvertToMp3(string pathOld, string pathNew)
        {
            //命令行语句
            string cmdStr = Path.GetFullPath("ffmpeg/ffmpeg.exe") + " -i " + Path.GetFullPath(pathOld) + " " + Path.GetFullPath(pathNew);//
            //新开进程进行转码
            ProcessStartInfo info = new ProcessStartInfo("cmd.exe");
            info.RedirectStandardOutput = false;
            info.UseShellExecute = false;
            info.CreateNoWindow = true;//不显示窗口
            Process p = Process.Start(info);
            try
            {
                //使用进程执行
                p.StartInfo.UseShellExecute = false;
                p.StartInfo.RedirectStandardInput = true;
                p.StartInfo.RedirectStandardOutput = true;
                p.StartInfo.RedirectStandardError = true;
                p.StartInfo.CreateNoWindow = true;//不显示窗口
                p.Start();
                p.StandardInput.WriteLine(cmdStr);
                p.StandardInput.AutoFlush = true;
                while (p.WaitForInputIdle())
                {
                    //等待线程
                    //Thread.Sleep(1000);
                    p.StandardInput.WriteLine("exit");
                    //p.WaitForExit();
                }
                string outStr = p.StandardOutput.ReadToEnd();
                //p.Close();
                return outStr;
            }
            catch (Exception ex)
            {
                ConsoleLog.Output("////////***********从AMR转码为MP3时失败：" + ex.Message);
                return "error" + ex.Message;
            }
            finally
            {
                p.Close();
            }
        }
        #endregion

        #region MD5加密
        /// <summary>
        ///  对字符串进行加密
        /// </summary>
        /// <param name="input">需要加密的字符串</param>
        /// <returns></returns>
        public static string MD5create(this string input)
        {
            if (UIUtils.IsNull(input))
            {
                return "";
            }

            return MD5.StringMD5(input);
        }
        #endregion

        #region 从Http获取图片
        /// <summary>
        /// 从Http获取图片
        /// </summary>
        /// <param name="url">请求的Url</param>
        /// <param name="width">宽度(默认0为原有的宽度)</param>
        /// <returns>获取到的图片</returns>
        public static BitmapImage GetImageHttp(string url, int width)
        {
            BitmapImage image = new BitmapImage();
            int BytesToRead = 100;
            if (!string.IsNullOrEmpty(url))
            {
                WebRequest request = WebRequest.Create(new Uri(url, UriKind.Absolute));
                request.Timeout = -1;


                WebResponse response = request.GetResponse();
                Stream responseStream = response.GetResponseStream();
                BinaryReader reader = new BinaryReader(responseStream);
                MemoryStream memoryStream = new MemoryStream();

                byte[] bytebuffer = new byte[BytesToRead];
                int bytesRead = reader.Read(bytebuffer, 0, BytesToRead);

                while (bytesRead > 0)
                {
                    memoryStream.Write(bytebuffer, 0, bytesRead);
                    bytesRead = reader.Read(bytebuffer, 0, BytesToRead);
                }

                image.BeginInit();
                image.DecodePixelWidth = width;
                image.CacheOption = BitmapCacheOption.OnLoad;
                memoryStream.Seek(0, SeekOrigin.Begin);

                image.StreamSource = memoryStream;
                image.EndInit();
                image.Freeze();
                memoryStream.Close();
                reader.Close();
                response.Close();
            }
            return image;
        }
        #endregion

        #region 是否为小数
        /// <summary>
        /// 是否为小数
        /// </summary>
        /// <param name="value">是否为小数</param>
        /// <returns></returns>
        public static bool IsNumeric(string value)
        {
            return Regex.IsMatch(value, @"^[+-]?/d*[.]?/d*$");
        }
        #endregion

        #region 是否为整数
        /// <summary>
        /// 是否为整数
        /// </summary>
        /// <param name="value">需要判断的字符串</param>
        /// <returns>返回bool类型</returns>
        public static bool IsInt(string value)
        {
            return Regex.IsMatch(value, @"^[+-]?/d*$");
        }
        #endregion

        #region 是否为...(正则匹配)
        /// <summary>
        /// 是否为...(正则匹配)
        /// </summary>
        /// <param name="value">字符串</param>
        /// <returns>返回bool类型</returns>
        public static bool IsUnsign(string value)
        {
            return Regex.IsMatch(value, @"^/d*[.]?/d*$");
        }
        #endregion

        #region 计算长度
        /// <summary>
        /// 计算长度
        /// </summary>
        /// <param name="text">文字</param>
        /// <param name="fontSize">文字大小</param>
        /// <param name="typeFace">字体</param>
        /// <returns>关于字体占用的大小</returns>
        public static System.Drawing.Size MeasureString(string text, double fontSize, string typeFace)
        {
            FormattedText ft = new FormattedText(text, CultureInfo.CurrentCulture, System.Windows.FlowDirection.LeftToRight, new Typeface(typeFace), fontSize, System.Windows.Media.Brushes.Black);
            return new System.Drawing.Size(Convert.ToInt32(ft.Width), Convert.ToInt32(ft.Height));
        }
        #endregion

        #region 计算长度
        /// <summary>
        /// 计算文字长度
        /// </summary>
        /// <param name="text">文字</param>
        /// <param name="fontSize">文字大小</param>
        /// <param name="typeFace">字体</param>
        /// <returns>关于字体占用的大小</returns>
        public static double MeasureString2(string text, float fontSize = 11, string typeFace = Applicate.SetFont)
        {
            Control ctr = new Control();
            Graphics vGraphics = ctr.CreateGraphics();
            vGraphics.PageUnit = GraphicsUnit.Point;
            int n = 0;
            if (text.Contains("[") && text.Contains("]"))
            {
                Regex regex = new Regex(@"\[(\w|\-)*\]");
                MatchCollection matchCollection = regex.Matches(text);
                foreach (Match match in matchCollection)
                {
                    text = text.Replace(match.ToString(), "");
                    n += 20;
                }
            }

            SizeF vSizeF = vGraphics.MeasureString(text, new Font(typeFace, fontSize));
            int dStrLength = Convert.ToInt32(Math.Ceiling(vSizeF.Width));
            ctr.Dispose();

            return Convert.ToDouble(vSizeF.Width) + n;
        }
        #endregion

        #region 过滤HTML标签
        /// <summary>  
        /// 过滤标记  
        /// </summary>  
        /// <param name="NoHTML">包括HTML，脚本，数据库关键字，特殊字符的源码 </param>  
        /// <returns>已经去除标记后的文字</returns>  
        public static string ClearHTML(string Htmlstring)
        {
            if (Htmlstring == null)
            {
                return "";
            }
            else
            {
                //Htmlstring = Htmlstring.Replace("&quot;", "\"");
                //删除脚本
                //Htmlstring = Regex.Replace(Htmlstring, @"<script[^>]*?>.*?</script>", "", RegexOptions.IgnoreCase);
                //删除HTML  
                //Htmlstring = Regex.Replace(Htmlstring, @"<(.[^>]*)>", "", RegexOptions.IgnoreCase);
                //Htmlstring = Regex.Replace(Htmlstring, @"([/r/n])[/s]+", "", RegexOptions.IgnoreCase);
                //Htmlstring = Regex.Replace(Htmlstring, @"-->", "", RegexOptions.IgnoreCase);
                //Htmlstring = Regex.Replace(Htmlstring, @"<!--.*", "", RegexOptions.IgnoreCase);
                //----
                Htmlstring = Regex.Replace(Htmlstring, @"&(quot|#34);", "\'", RegexOptions.None);
                Htmlstring = Regex.Replace(Htmlstring, @"&(amp|#38);", "&", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, @"&(lt|#60);", "<", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, @"&(gt|#62);", ">", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, @"&(nbsp|#160);", " ", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, @"&(iexcl|#161);", "/xa1", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, @"&(cent|#162);", "/xa2", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, @"&(pound|#163);", "/xa3", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, @"&(copy|#169);", "/xa9", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, @"&#(/d+);", "", RegexOptions.IgnoreCase);
                //Htmlstring = Regex.Replace(Htmlstring, "xp_cmdshell", "", RegexOptions.IgnoreCase);
                /*
                //删除与数据库相关的词  
                Htmlstring = Regex.Replace(Htmlstring, "select", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "insert", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "delete from", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "count''", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "drop table", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "truncate", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "asc", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "mid", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "char", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "xp_cmdshell", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "exec master", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "net localgroup administrators", "", RegexOptions.IgnoreCase);
                Htmlstring = Regex.Replace(Htmlstring, "and", "", RegexOptions.IgnoreCase);
                */
                return Htmlstring;

            }

        }
        #endregion

        #region 裁剪字符串
        /// <summary>
        /// 裁剪字符串
        /// </summary>
        /// <param name="texts"></param>
        /// <param name="length"></param>
        public static string formatText(string texts, int length)
        {
            if (texts == null)
            {
                return "";
            }
            string tmpText = "";
            if (texts.Length > length)
            {
                //如果长度太长则截取并追加
                tmpText = texts.Substring(0, length) + "...";
            }
            else
            {
                //如果长度不够就
                tmpText = texts;
            }
            return tmpText;
        }
        #endregion

        #region 从bitmap转换成ImageSource
        /// <summary>
        /// 从bitmap转换成ImageSource
        /// </summary>
        /// <param name="icon"></param>
        /// <returns></returns>
        public static System.Drawing.Bitmap ImageSourceToBitmap(ImageSource imageSource)
        {
            BitmapSource m = (BitmapSource)imageSource;
            Bitmap bmp = new Bitmap(m.PixelWidth, m.PixelHeight, System.Drawing.Imaging.PixelFormat.Format32bppPArgb); // 坑点：选Format32bppRgb将不带透明度
            System.Drawing.Imaging.BitmapData data = bmp.LockBits(
            new Rectangle(System.Drawing.Point.Empty, bmp.Size), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppPArgb);
            m.CopyPixels(Int32Rect.Empty, data.Scan0, data.Height * data.Stride, data.Stride);
            bmp.UnlockBits(data);
            return bmp;
        }
        #endregion

        #region 一般集合转绑定集合
        /// <summary>
        /// 一般集合转绑定集合
        /// </summary>
        /// <typeparam name="T">任意类型</typeparam>
        /// <param name="paras"></param>
        /// <returns></returns>
        public static ObservableCollection<T> ToObservableCollection<T>(this List<T> paras)
        {
            var tmp = new ObservableCollection<T>();
            if (paras != null && paras.Count > 0)//如果不为空 大于0就转换
            {
                for (int i = 0; i < paras.Count; i++)
                {
                    tmp.Add(paras[i]);
                }
            }
            return tmp;
        }
        #endregion

        #region 绑定集合转一般集合
        /// <summary>
        /// 绑定集合转一般集合
        /// </summary>
        /// <typeparam name="T">T类型</typeparam>
        /// <param name="paras">源集合</param>
        /// <returns>转换完成的集合</returns>
        public static List<T> ToList<T>(this ObservableCollection<T> paras)
        {
            var tmp = new List<T>();
            if (paras != null && paras.Count > 0)//如果不为空 大于0就转换
            {
                for (int i = 0; i < paras.Count; i++)
                {
                    tmp.Add(paras[i]);
                }
            }
            return tmp;
        }
        #endregion

        #region 获取当前项目的路径
        /// <summary>
        /// 获取当前项目的路径
        /// </summary>
        /// <returns></returns>
        public static string GetCurrentProjectPath()
        {
            return Environment.CurrentDirectory;
        }
        #endregion

        #region 批量添加
        /// <summary>
        /// 批量添加(倒叙)
        /// </summary>
        /// <typeparam name="T">具体类型</typeparam>
        /// <param name="lists">源集合</param>
        /// <param name="paras">需要添加的集合</param>
        /// <param name="offset">偏移量</param>
        /// <returns>对应集合</returns>
        public static ObservableCollection<T> InsertRange<T>(this ObservableCollection<T> lists, ObservableCollection<T> paras, int offset = 0)
        {
            if (paras == null || paras.Count == 0)
            {
                return lists;
            }
            for (int i = paras.Count - 1; i >= 0; i--)//倒叙插入
            {
                lists.Insert(offset, paras[i]);
            }
            return lists;
        }
        #endregion

        #region 批量添加
        /// <summary>
        /// 批量添加
        /// </summary>
        /// <typeparam name="T">具体类型</typeparam>
        /// <param name="lists">源集合</param>
        /// <param name="paras">需要添加的集合</param>
        /// <returns>对应集合</returns>
        public static ObservableCollection<T> AddRange<T>(this ObservableCollection<T> lists, ObservableCollection<T> paras)
        {
            if (paras == null || paras.Count == 0)
            {
                return lists;
            }
            //App.Current.Dispatcher.Invoke(()=> {
            //}) ;
            for (int i = 0; i < paras.Count; i++)
            {
                lists.Add(paras[i]);
            }
            return lists;
        }
        #endregion

        #region 绑定集合转一般集合
        /// <summary>
        /// 绑定集合转一般集合
        /// </summary>
        /// <typeparam name="T">任意类型</typeparam>
        /// <param name="paras"></param>
        /// <returns></returns>
        public static List<T> ObservableCollectionToList<T>(ObservableCollection<T> paras)
        {
            var tmp = new List<T>();
            if (paras != null && paras.Count > 0)//如果不为空 大于0就转换
            {
                for (int i = 0; i < paras.Count; i++)
                {
                    tmp.Add(paras[i]);
                }
            }
            return tmp;
        }
        #endregion

        #region 正则过滤
        static string[] Extract(string all, string reg)
        {
            return Regex.Matches(all, reg).OfType<Match>().Select(x => x.Groups[1].Value).ToArray();
        }
        #endregion

        #region DateTime To DataTimeOffset
        /// <summary>
        /// <see cref="DateTime"/> 转 <see cref="DataTimeOffset"/>
        /// </summary>
        /// <param name="dateTime">源时间</param>
        /// <returns></returns>
        public static DateTimeOffset ToDateTimeOffset(this DateTime dateTime)
        {
            return dateTime.ToUniversalTime() <= DateTimeOffset.MinValue.UtcDateTime
                       ? DateTimeOffset.MinValue
                       : new DateTimeOffset(dateTime);
        }
        #endregion

        #region 绝对路径转相对路径
        /// <summary>
        /// 绝对路径转相对路径
        /// </summary>
        /// <param name="absolutePath">绝对路径</param>
        /// <param name="relativeTo">相对路径</param>
        /// <returns>转换好的相对路径</returns>
        public static string RelativePath(string absolutePath, string relativeTo)
        {
            //from - www.cnphp6.com
            string[] absoluteDirectories = absolutePath.Split('\\');
            string[] relativeDirectories = relativeTo.Split('\\');

            //Get the shortest of the two paths
            int length = absoluteDirectories.Length < relativeDirectories.Length ? absoluteDirectories.Length : relativeDirectories.Length;

            //Use to determine where in the loop we exited
            int lastCommonRoot = -1;
            int index;

            //Find common root
            for (index = 0; index < length; index++)
            {
                if (absoluteDirectories[index] == relativeDirectories[index])
                {
                    lastCommonRoot = index;
                }
                else
                {
                    break;
                }
            }

            //If we didn't find a common prefix then throw
            if (lastCommonRoot == -1)
            {
                throw new ArgumentException("Paths do not have a common base");
            }

            //Build up the relative path
            StringBuilder relativePath = new StringBuilder();

            //Add on the ..
            for (index = lastCommonRoot + 1; index < absoluteDirectories.Length; index++)
            {
                if (absoluteDirectories[index].Length > 0)
                {
                    relativePath.Append("..\\");
                }
            }

            //Add on the folders
            for (index = lastCommonRoot + 1; index < relativeDirectories.Length - 1; index++)
            {
                relativePath.Append(relativeDirectories[index] + "\\");
            }

            relativePath.Append(relativeDirectories[relativeDirectories.Length - 1]);

            return relativePath.ToString();
        }
        #endregion

        #region BitmapSource转Bitmap
        /// <summary>
        /// BitmapSource转Bitmap
        /// </summary>
        /// <param name="image1"></param>
        /// <returns></returns>
        internal static Bitmap BItmapSourceToBitmap(this BitmapSource image1)
        {
            Bitmap bmp = new Bitmap(image1.PixelWidth, image1.PixelHeight, System.Drawing.Imaging.PixelFormat.Format32bppPArgb);
            System.Drawing.Imaging.BitmapData data = bmp.LockBits(
                new Rectangle(System.Drawing.Point.Empty, bmp.Size),
                System.Drawing.Imaging.ImageLockMode.WriteOnly,
                System.Drawing.Imaging.PixelFormat.Format32bppPArgb);
            image1.CopyPixels(Int32Rect.Empty, data.Scan0, data.Height * data.Stride, data.Stride);
            return bmp;
        }
        #endregion

        #region 将Base64编码文本转换为图片
        /// <summary>
        /// 将Base64编码文本转换为图片
        /// </summary>
        /// <param name="imgstr">转码为base64的图片</param>
        /// <returns>图标类型</returns>
        public static Icon Base64StringToImage(string imgstr)
        {
            //声明新的Ico进行接收
            Icon ico = null;
            try
            {
                string inputStr = imgstr;
                byte[] arr = Convert.FromBase64String(inputStr);
                MemoryStream ms = new MemoryStream(arr);
                ico = new Icon(ms, new System.Drawing.Size(57, 57));
                //bmp.Save(txtFileName + ".jpg", System.Drawing.Imaging.ImageFormat.Jpeg);
                //bmp.Save(txtFileName + ".bmp", ImageFormat.Bmp);
                //bmp.Save(txtFileName + ".gif", ImageFormat.Gif);
                //bmp.Save(txtFileName + ".png", ImageFormat.Png);
                //释放资源
                ms.Close();
                return ico;
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show("Base64StringToImage 转换失败\nException：" + ex.Message);
                return null;
            }
        }
        #endregion

        #region 从资源文件中的Bitmap转为BitmapImage
        /// <summary>
        /// 从资源文件中的Bitmap转为BitmapImage
        /// </summary>
        /// <param name="srcImg">源图片</param>
        /// <returns>转换后的图片</returns>
        public static BitmapSource ConvertBitmapToBitmapSource(Bitmap srcImg)
        {
            try
            {
                //判断非空
                if (srcImg != null)
                {
                    //转换
                    //img = System.Windows.Interop.Imaging.CreateBitmapSourceFromHBitmap(srcImg.GetHbitmap(), IntPtr.Zero, Int32Rect.Empty, BitmapSizeOptions.FromEmptyOptions());
                    return Imaging.CreateBitmapSourceFromHBitmap(srcImg.GetHbitmap(), IntPtr.Zero, Int32Rect.Empty, BitmapSizeOptions.FromEmptyOptions());//并返回
                }
                else
                {
                    return new BitmapImage();
                }
            }
            catch (Exception ex)
            {
                ConsoleLog.Output("转换资源文件中bitmap为bitmapImage时出错：" + ex.Message);
                return new BitmapImage();
            }
        }
        #endregion

        #region 最大公约数
        /// <summary>
        /// 最大公约数
        /// </summary>
        /// <param name="a">数字1</param>
        /// <param name="b">数字2</param>
        /// <returns>算出的最大公约数</returns>
        public static int GCD(int a, int b)
        {
            int gcd = 1;
            int min = a > b ? b : a;
            for (int i = min; i >= 1; i--)
            {
                if (a % i == 0 && b % i == 0)
                {
                    gcd = i;
                    break;
                }
            }
            return gcd;
        }
        #endregion


        public static Dictionary<string, string> Copy(this Dictionary<string, string> dic)
        {
            Dictionary<string, string> result = new Dictionary<string, string>();
            foreach(var key in dic.Keys)
            {
                string value = dic[key];
                result.Add(key, value);
            }
            return result;
        }

        /// <summary>
        /// 判断是否含有该msgId的对象
        /// </summary>
        /// <param name="msg_list"></param>
        /// <param name="msgId"></param>
        /// <returns></returns>
        public static bool ContainsKey(this List<MessageObject> msg_list, string msgId)
        {
            int index = msg_list.FindIndex(m => m.messageId == msgId);
            return index > -1;
        }

        public static int FindMsgIndex(this List<MessageObject> msg_list, string msgId)
        {
            return msg_list.FindIndex(m => m.messageId == msgId);
        }

        public static MessageObject GetMsgById(this List<MessageObject> msg_list, string msgId)
        {
            return msg_list.Find(m => m.messageId == msgId);
        }

        public static void RemoveMsg(this List<MessageObject> msg_list, string msgId)
        {
            msg_list.Remove(msg_list.GetMsgById(msgId));
        }
    }
}
