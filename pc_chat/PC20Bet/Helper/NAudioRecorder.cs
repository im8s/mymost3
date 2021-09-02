using NAudio.Wave;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    public class NAudioRecorder : ISpeechRecorder
    {
        private WaveIn _waveSource;
        private WaveIn waveSource => _waveSource ?? (_waveSource = new WaveIn());
        private WaveFileWriter waveFile = null;
        /// <summary>
        /// 文件名
        /// </summary>
        public string fileName = string.Empty;
        /// <summary>
        /// 文件路径
        /// </summary>
        public string FilePath;
        public Stopwatch stopWatch = new Stopwatch();
        /// <summary>
        /// 开始录音
        /// </summary>
        public bool StartRec()
        {
            FilePath = Applicate.LocalConfigData.VoiceFolderPath + TimeUtils.CurrentTime() + ".wav ";
            _waveSource = new WaveIn();
            waveSource.WaveFormat = new WaveFormat(8000, 8, 1); // 16bit,16KHz,Mono的录音格式

            waveSource.DataAvailable += new EventHandler<WaveInEventArgs>(waveSource_DataAvailable);
            waveSource.RecordingStopped += new EventHandler<StoppedEventArgs>(waveSource_RecordingStopped);
            //writer = new WaveFileWriter(outputFilePath, capture.WaveFormat);

            //var capture = new WasapiLoopbackCapture();
            waveFile = new WaveFileWriter(FilePath, waveSource.WaveFormat);
            try
            {
                waveSource.StartRecording();
                stopWatch.Restart(); //开始计时
                System.Management.ManagementObjectSearcher searcher = new System.Management.ManagementObjectSearcher("select * from " + "Win32_SoundDevice");
                return true;
            }

            catch (Exception e)
            {
                stopWatch.Reset();
                waveSource.Dispose();
                waveFile.Dispose();
               LogUtils.Log(e.ToString());
                return false;
            }

        }

        /// <summary>
        /// 停止录音
        /// </summary>
        public NAudioRecorder StopRec()
        {
            waveSource.StopRecording();
            if (waveSource != null)
            {
                waveSource.Dispose();
                _waveSource = null;
            }

            if (waveFile != null)
            {
                waveFile.Dispose();
                waveFile = null;
            }
            stopWatch.Stop();
            return this;
        }

        /// <summary>
        /// 录音结束后保存的文件路径
        /// </summary>
        /// <param name="fileName">保存wav文件的路径名</param>
        public void SetFileName(string fileName)
        {
            this.fileName = fileName;
        }

        /// <summary>
        /// 开始录音回调函数
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void waveSource_DataAvailable(object sender, WaveInEventArgs e)
        {
            if (waveFile != null)
            {
                waveFile.Write(e.Buffer, 0, e.BytesRecorded);
                waveFile.Flush();
            }
        }

        /// <summary>
        /// 录音结束回调函数
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void waveSource_RecordingStopped(object sender, StoppedEventArgs e)
        {
            if (waveSource != null)
            {
                waveSource.Dispose();
                _waveSource = null;
            }

            if (waveFile != null)
            {
                waveFile.Dispose();
                waveFile = null;
            }
        }
    }
}
