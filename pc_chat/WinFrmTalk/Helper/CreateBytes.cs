using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;

namespace WinFrmTalk.Helper
{
    class CreateBytes
    {
        Encoding encoding = Encoding.UTF8;

        /**//// <summary>
        /// 拼接所有的二进制数组为一个数组
        /// </summary>
        /// <param name="byteArrays">数组</param>
        /// <returns></returns>
        /// <remarks>加上结束边界</remarks>
        public byte[] JoinBytes(ArrayList byteArrays)
        {
            int length = 0;
            int readLength = 0;

            // 加上结束边界
            string endBoundary = Boundary + "--\r\n"; //结束边界
            byte[] endBoundaryBytes = encoding.GetBytes(endBoundary);
            byteArrays.Add(endBoundaryBytes);

            foreach (byte[] b in byteArrays)
            {
                length += b.Length;
            }
            byte[] bytes = new byte[length];

            // 遍历复制
            //
            foreach (byte[] b in byteArrays)
            {
                b.CopyTo(bytes, readLength);
                readLength += b.Length;
            }

            return bytes;
        }

        public WebClient UploadData(string uploadUrl, byte[] bytes)
        {
            WebClient webClient = new WebClient();
            webClient.Headers.Add("Content-Type", ContentType);
            webClient.UploadDataCompleted += (sen, eve) =>
            {
                string temp = Encoding.UTF8.GetString(eve.Result);
            };
            webClient.UploadDataAsync(new Uri(uploadUrl), bytes);
            return webClient;
        }

        /// <summary>
        /// 获取普通表单区域二进制数组
        /// </summary>
        /// <param name="fieldName">表单名</param>
        /// <param name="fieldValue">表单值</param>
        /// <returns></returns>
        /// <remarks>
        /// -----------------------------7d52ee27210a3c\r\nContent-Disposition: form-data; name=\"表单名\"\r\n\r\n表单值\r\n
        /// </remarks>
        public byte[] CreateFieldData(string fieldName, string fieldValue)
        {
            string textTemplate = Boundary + "\r\nContent-Disposition: form-data; name=\"{0}\"\r\n\r\n{1}\r\n";
            string text = String.Format(textTemplate, fieldName, fieldValue);
            byte[] bytes = encoding.GetBytes(text);
            return bytes;
        }


        /**//// <summary>
            /// 获取文件上传表单区域二进制数组
            /// </summary>
            /// <param name="fieldName">表单名</param>
            /// <param name="filename">文件名</param>
            /// <param name="contentType">文件类型</param>
            /// <param name="contentLength">文件长度</param>
            /// <param name="stream">文件流</param>
            /// <returns>二进制数组</returns>
        public byte[] CreateFieldData(string fieldName, string filename, string contentType, byte[] fileBytes)
        {
            string end = "\r\n";
            string textTemplate = Boundary + "\r\nContent-Disposition: form-data; name=\"{0}\"; filename=\"{1}\"\r\nContent-Type: {2}\r\n\r\n";

            // 头数据
            string data = String.Format(textTemplate, fieldName, filename, contentType);
            byte[] bytes = encoding.GetBytes(data);



            // 尾数据
            byte[] endBytes = encoding.GetBytes(end);

            // 合成后的数组
            byte[] fieldData = new byte[bytes.Length + fileBytes.Length + endBytes.Length];

            bytes.CopyTo(fieldData, 0); // 头数据
            fileBytes.CopyTo(fieldData, bytes.Length); // 文件的二进制数据
            endBytes.CopyTo(fieldData, bytes.Length + fileBytes.Length); // \r\n

            return fieldData;
        }

        //属性
        #region 属性
        public string Boundary
        {
            get
            {
                string[] bArray, ctArray;
                string contentType = ContentType;
                ctArray = contentType.Split(';');
                if (ctArray[0].Trim().ToLower() == "multipart/form-data")
                {
                    bArray = ctArray[1].Split('=');
                    return "--" + bArray[1];
                }
                return null;
            }
        }

        public string ContentType
        {
            get
            {
                if (HttpContext.Current == null)
                {
                    return "multipart/form-data; boundary=---------------------------7d5b915500cee";
                }
                return HttpContext.Current.Request.ContentType;
            }
        }
        #endregion
    }
}
