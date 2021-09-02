using System;
using System.Drawing;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using WinFrmTalk;
using WinFrmTalk.Helper.MVVM;

public partial class ShotCutWindow : Form
{
    float x, y, nowX, nowY, width, height;
    bool isMouthDown = false;
    Graphics g;
    private static ShotCutWindow screenBody = null;
    /// <summary>
    /// 截图完成
    /// </summary>
    public Action<Bitmap> ShotCutComplete;

    /// <summary>
    /// 主窗口
    /// </summary>
    public Form MainWindow;

    public ShotCutWindow()
    {
        InitializeComponent();
        this.SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint | ControlStyles.OptimizedDoubleBuffer, true);//加载背景图片避免闪烁
        //this.Location = new Point(0, 0);
        //this.Width = Screen.PrimaryScreen.Bounds.Width;
        //this.Height = Screen.PrimaryScreen.Bounds.Height;
        //  this.Bounds = new Rectangle(0, 0, Screen.PrimaryScreen.Bounds.Width, Screen.PrimaryScreen.Bounds.Height);

    }
    //问题点：1.加载进入截图的时候默认选中的是当前屏幕，如同QQ，在响应鼠标事件之前

       

    /// <summary>
    /// 获取当前屏幕
    /// </summary>
    /// <returns></returns>
    public Bitmap getScreen()
    {
        Bitmap myImage = new Bitmap(this.Width, this.Height);
        Graphics g = Graphics.FromImage(myImage);

        g.CopyFromScreen(this.Location, new Point(0, 0), this.Size);
        IntPtr dc1 = g.GetHdc();
        g.ReleaseHdc(dc1);
        //String path = "d:\\image\\";
        // if (!Directory.Exists(path)) Directory.CreateDirectory(path);
        Random objRand = new Random();
        String pic_name = DateTime.Now.ToString("yyyyMMddHHmmssffff") + ".jpg";
        //string allpathname = path + pic_name;
        //myImage.Save(allpathname);
        return myImage;

    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    private void Form2_MouseDown(object sender, MouseEventArgs e)
    {
        if (e.Button == MouseButtons.Right)
            return;
        x = Cursor.Position.X;

        y =  Cursor.Position.Y;
      // LogUtils.Log("X坐标"+x.ToString(), y.ToString());
        float t = x * ScreenUtils.ScaleX();
       LogUtils.Log("缩放后坐标" + t.ToString());
        isMouthDown = true;
    }

    public static ShotCutWindow GetSingle()
    {
        if (screenBody == null)
        {
            screenBody = new ShotCutWindow();
        }
        return screenBody;
    }
    private void Form2_MouseMove(object sender, MouseEventArgs e)
    {
        if (e.Button == MouseButtons.Right)
            return;
        if (isMouthDown)
        {
            width = Math.Abs(Cursor.Position.X - x);
            height = Math.Abs(Cursor.Position.Y - y);
            g = CreateGraphics();
            g.Clear(BackColor);
            Pen p = new Pen(Color.Blue, 1);//设置截图边框的颜色和边框大小
            g.DrawRectangle(p, x < (Cursor.Position.X-1 )?( x-1) : (Cursor.Position.X-1),( y-1) < (Cursor.Position.Y-1) ?( y-1) :( Cursor.Position.Y+1), width + 1, height + 1);
        }
    }
    #region 截图完成后
    public void Snap(int x, int y, int width, int height)
    {
        var image = new Bitmap(this.Width, this.Height); 
       if (width == 0 && height == 0)
        {
            image = getScreen();
        }
        else
        {
            image = new Bitmap(width, height);
        }
        
        Graphics g = Graphics.FromImage(image);
        g.CopyFromScreen(x, y, 0, 0, new Size(width, height));
        ShotCutComplete?.Invoke(image);//获取到图片并显示
        //lblPicPosition.Text = "Start Position:  ( " + x.ToString() + ", " + y.ToString() + " )";
        //lblPicSize.Text = "Size:  " + width.ToString() + " * " + height.ToString();
       // originBmp = null;
    }

    #endregion

    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    private void Form2_MouseUp(object sender, MouseEventArgs e)
    {
        if (e.Button == MouseButtons.Right)
            return;
        nowX = e.X* ScreenUtils.ScaleX();
        nowY = e.Y * ScreenUtils.ScaleY();
        this.Close();
        Console.Write("缩放比例："+ ScreenUtils.ScaleX().ToString());
    
        x =x * ScreenUtils.ScaleX();//是因为缩放比例？？？？？

       LogUtils.Log("缩放后坐标２" +x.ToString());
        y = y * ScreenUtils.ScaleY();
        Snap((int)x < (int)nowX ? (int)x : (int)nowX, (int)y < (int)nowY ? (int)y : (int)nowY, Math.Abs((int)nowX - (int)x), Math.Abs((int)nowY - (int)y));//???
        //MainWindow?.Show();
    }
  
    // 用来保存原始图像
   // private Bitmap originBmp;
    private void ShotCutWindow_Paint(object sender, PaintEventArgs e)
    {
        e.Graphics.DrawRectangle(Pens.Green, 0, 0, this.Width - 1, this.Height - 1);
    }

    private void ShotCutWindow_Load(object sender, EventArgs e)
    {
       
        //this.SetStyle(ControlStyles.OptimizedDoubleBuffer | ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint, true);
        //this.UpdateStyles();
      //  originBmp = new Bitmap(this.BackgroundImage);
    }

    

}
