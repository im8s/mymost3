using CCWin;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace WinFrmTalk
{
    public partial class FileShared : CCSkinMain
    {
        RoomShare roomshare = new RoomShare();
        public FileShared()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
        }
        private  void UPloadFile()
        {
            int i = dgvFileList.Rows.Add();
            dgvFileList.Rows[i].Cells[0] .Value= roomshare.name;
            dgvFileList.Rows[i].Cells[1].Value = roomshare.time;
            dgvFileList.Rows[i].Cells[2].Value = roomshare.size;
            dgvFileList.Rows[i].Cells[3].Value = roomshare.nickname;
            dgvFileList.Rows[i].Cells[4].Value = roomshare.name;
          
        }
        //被注释的代码是方便调试
        //需要获取本次登陆者
        private void btnupload_Click(object sender, EventArgs e)
        {
           
          /*  FileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "所有文件|*.*";
            if(openFileDialog.ShowDialog() == DialogResult.OK)
            {
                roomshare.name = openFileDialog.FileName;
                FileInfo file = new FileInfo(roomshare.name);
                roomshare.time =Convert.ToInt64( System.DateTime.Now);
                roomshare.size = file.Length;
                UPloadFile();
            }*/

        }

        private void FileShared_Load(object sender, EventArgs e)
        {
            /* List<RoomShare> shareList = roomshare.GetListByRoomId();
             for(int j =0;j<shareList.Count; j++)
             {
                 dgvFileList.Rows.Add();
                 dgvFileList.Rows[j].Cells[0].Value = shareList[j].name;
                 dgvFileList.Rows[j].Cells[1].Value = shareList[j].time;
                 dgvFileList.Rows[j].Cells[2].Value = shareList[j].size;
                 dgvFileList.Rows[j].Cells[3].Value = shareList[j].nickname;
                 dgvFileList.Rows[j].Cells[4].Value = shareList[j].name;//下载或者删除(根据成员的身份来判定)
             }*/
        }

        private void dgvFileList_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void panel3_Paint(object sender, PaintEventArgs e)
        {

        }
    }
}
