using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace WinFrmTalk
{
    public class LocalConfig
    {
        #region Private Member
        private string chatDownloadPath;
        private string userAvatorPath;
        private string tempFilepath;
        private string chatPath;
        private string catchPath;
        private string catchDownPath;
        private string videoPath;
        private string voicePath;
        private string filePath;
        private string locationPath;
        private string imagePath;
        private string messageDatabasePath;
        private string emojiFolderPath;
        private string gifFolderPath;
        private string constantDatabasePath;
        private string roomFileFolderPath;
        #endregion

        #region Public Member

        /// <summary>
        /// 用户头像路径
        /// </summary>
        public string UserAvatorFolderPath
        {
            get { return userAvatorPath; }
            set
            {
                userAvatorPath = value;
            }
        }

        /// <summary>
        /// 聊天记录下载路径
        /// </summary>
        public string ChatDownloadPath
        {
            get { return chatDownloadPath; }
            set
            {
                chatDownloadPath = value;
            }
        }

        /// <summary>
        /// 聊天记录下载临时数据路径
        /// </summary>
        public string TempFilepath
        {
            get
            {
                if (!Directory.Exists(tempFilepath))
                {
                    Directory.CreateDirectory(tempFilepath);
                }
                return tempFilepath;
            }

            set => tempFilepath = value;
        }

        /// <summary>
        /// 聊天文件
        /// </summary>
        public string ChatPath
        {
            get { return chatPath; }
            set { chatPath = value; }
        }

        /// <summary>
        /// 缓存目录
        /// </summary>
        public string CatchPath
        {
            get { return catchPath; }
            set { catchPath = value; }
        }

        /// <summary>
        /// 消息数据库路径
        /// </summary>
        public string MessageDatabasePath
        {
            get
            {
                if (!Directory.Exists(messageDatabasePath))
                {
                    Directory.CreateDirectory(messageDatabasePath);
                }
                return messageDatabasePath;
            }
            set { messageDatabasePath = value; }
        }

        /// <summary>
        /// emoji表情目录
        /// </summary>
        public string EmojiFolderPath
        {
            get
            {
                if (!Directory.Exists(emojiFolderPath))
                {
                    Directory.CreateDirectory(emojiFolderPath);
                }
                return emojiFolderPath;
            }
            set => emojiFolderPath = value;
        }

        /// <summary>
        /// 动画图片目录
        /// </summary>
        public string GifFolderPath
        {
            get
            {
                if (!Directory.Exists(gifFolderPath))
                {
                    Directory.CreateDirectory(gifFolderPath);
                }
                return gifFolderPath;
            }
            set => gifFolderPath = value;
        }


        /// <summary>
        /// 视频目录
        /// </summary>
        public string VideoFolderPath
        {
            get
            {
                if (!Directory.Exists(videoPath))
                {
                    Directory.CreateDirectory(videoPath);
                }
                return videoPath;
            }
            set => videoPath = value;
        }

        /// <summary>
        /// 坐标图片目录
        /// </summary>
        public string LocationFolderPath
        {
            get
            {
                if (!Directory.Exists(locationPath))
                {
                    Directory.CreateDirectory(locationPath);
                }
                return locationPath;
            }
            set => locationPath = value;
        }

        /// <summary>
        /// 下载图片目录
        /// </summary>
        public string ImageFolderPath
        {
            get
            {
                if (!Directory.Exists(imagePath))
                {
                    Directory.CreateDirectory(imagePath);
                }
                return imagePath;
            }
            set => imagePath = value;
        }

        /// <summary>
        /// 
        /// </summary>
        public string ConstantDatabasePath
        {
            get
            {
                if (!Directory.Exists(constantDatabasePath))
                {
                    Directory.CreateDirectory(constantDatabasePath);
                }
                return constantDatabasePath;
            }
            set { constantDatabasePath = value; }
        }

        /// <summary>
        /// 音频路径
        /// </summary>
        public string VoiceFolderPath
        {
            get
            {
                if (!Directory.Exists(voicePath))
                {
                    Directory.CreateDirectory(voicePath);
                }
                return voicePath;
            }
            set { voicePath = value; }
        }

        /// <summary>
        /// 文件路径
        /// </summary>
        public string FileFolderPath
        {
            get
            {
                if (!Directory.Exists(filePath))
                {
                    Directory.CreateDirectory(filePath);
                }
                return filePath;
            }
            set { filePath = value; }
        }

        /// <summary>
        /// 群文件路径
        /// </summary>
        public string RoomFileFolderPath
        {
            get
            {
                if (!Directory.Exists(roomFileFolderPath))
                {
                    Directory.CreateDirectory(roomFileFolderPath);
                }
                return roomFileFolderPath;
            }
            set { roomFileFolderPath = value; }
        }


        /// <summary>
        /// 群文件路径
        /// </summary>
        public string CacheFolderPath
        {
            get
            {
                if (!Directory.Exists(catchDownPath))
                {
                    Directory.CreateDirectory(catchDownPath);
                }
                return catchDownPath;
            }
            set { catchDownPath = value; }
        }


        #endregion


        #region Method

        /// <summary>
        /// 根据UserId获取对应头像路径
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>拼接好的头像路径</returns>
        public string GetDisplayAvatorPath(string userId)
        {
            if (!Directory.Exists(UserAvatorFolderPath))
            {
                Directory.CreateDirectory(UserAvatorFolderPath);
            }
            string avatarpath = UserAvatorFolderPath + userId + ".png";
            if (userId.Length < 15)
            {
                if (userId.Length < 7)
                {
                    switch (userId)
                    {
                        case "10000"://1000号为系统公众号
                            return Helpers.GetCurrentProjectPath() + "\\Resources\\Avator\\avatar_notice.png";//系统公众号
                        case "10001"://10001为好友验证账号
                            return Helpers.GetCurrentProjectPath() + "\\Resources\\Avator\\avatar_newfriends.png";//系统公众号
                        default:
                            return Helpers.GetCurrentProjectPath() + "\\Resources\\Avator\\avatar_default.png";
                    }
                }
                else
                {
                    if (File.Exists(avatarpath))//如果头像存在则返回原始头像
                    {
                        return avatarpath;//返回用户自定义头像
                    }
                    else//不存在则返回默认头像
                    {
                        return Helpers.GetCurrentProjectPath() + "\\Resource\\Avator\\avatar_default.png";
                    }
                }
            }
            else
            {
                return Helpers.GetCurrentProjectPath() + "\\Resource\\Avator\\avatar_group.png";
            }
        }


        /// <summary>
        /// 根据UserId获取对应头像路径
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>拼接好的头像路径</returns>
        public string GetAvatorPath(string userId)
        {
            if (!Directory.Exists(UserAvatorFolderPath))
            {
                Directory.CreateDirectory(UserAvatorFolderPath);
            }

            return UserAvatorFolderPath + userId + ".png";
        }

        #endregion



    }
}
