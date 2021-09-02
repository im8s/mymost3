using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk
{
    public interface ISpeechRecorder
    {
        void SetFileName(string fileName);
        bool StartRec();
        NAudioRecorder StopRec();
    }
}
