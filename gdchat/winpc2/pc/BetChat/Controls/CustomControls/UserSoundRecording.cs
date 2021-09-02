using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class UserSoundRecording : UserControl
    {
        public bool SoundState = false;
        public Action<string, TimeSpan> PathCallback { get; set; }
        NAudioRecorder nr = new NAudioRecorder();
        public UserSoundRecording()
        {
            InitializeComponent();
        }

        /// <summary>
        /// 是否可以录音（成功则直接开始录音）
        /// </summary>
        /// <returns></returns>
        public bool IsCanSoundRecord()
        {
            if (nr.StartRec())
            {
                SoundState = true;
                return true;
            }
            else
            {
                File.Delete(nr.FilePath);
                return false;
            }
        }

        private void btnSend_Click(object sender, EventArgs e)
        {
            nr.StopRec();
            SoundState = false;
            if (PathCallback!=null)
            {
                //0秒结束
                int secoudes = nr.stopWatch.Elapsed.Seconds;
                if (secoudes==0)
                {
                    HttpUtils.Instance.ShowTip("录音时间过短！");
                    StopSound();
                    return;
                    
                }
                PathCallback(nr.FilePath,nr.stopWatch.Elapsed);
                
            }
            this.SendToBack();
        }
        public void StopSound()
        {
            SoundState = false;
            this.SendToBack();
            nr.StopRec();
            File.Delete(nr.FilePath);
        }

        private void lblClose_Click(object sender, EventArgs e)
        {
            StopSound();
        }
    }
}
