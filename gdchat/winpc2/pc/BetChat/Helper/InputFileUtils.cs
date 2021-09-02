using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Helper
{
   public class InputFileUtils
    {
        /// <summary>
        /// 选择文件路径
        /// </summary>
        /// <returns></returns>
        //internal static string GetImagePath()
        //{
        //    string personImgPath = "";
        //    FolderBrowserDialog dialog = new FolderBrowserDialog();
        //    dialog.Description = "请选择文件路径";

        //    if (dialog.ShowDialog() == DialogResult.OK)
        //    {
        //        personImgPath = dialog.SelectedPath;

        //    }

        //    return personImgPath;
        //}

        /// <summary>
        /// 
        /// </summary>
        /// <param name="filePath"> 文件路径</param>
        /// <param name="dataTable">数据集</param>
        /// <param name="isShowExcle">是否直接打开</param>
        /// <returns></returns>
        internal static bool DataTableToExcel(string filePath, System.Data.DataTable dataTable, bool isShowExcle)
        {
            //System.Data.DataTable dataTable = dataSet.Tables[0];
            int rowNumber = dataTable.Rows.Count;//行
            int columnNumber = dataTable.Columns.Count;//列
            int colIndex = 0;
            if (rowNumber == 0)
            {
                return false;
            }

            Microsoft.Office.Interop.Excel.Application excel = new Microsoft.Office.Interop.Excel.Application();
            Microsoft.Office.Interop.Excel.Workbook workbook = excel.Workbooks.Add(Microsoft.Office.Interop.Excel.XlWBATemplate.xlWBATWorksheet);
            Microsoft.Office.Interop.Excel.Worksheet worksheet = (Microsoft.Office.Interop.Excel.Worksheet)workbook.Worksheets[1];
            
            excel.Visible = isShowExcle;
         

            Microsoft.Office.Interop.Excel.Range range;
            foreach (DataColumn col in dataTable.Columns)
            {
                colIndex++;
                excel.Cells[1, colIndex] = col.ColumnName;
            }
            
            object[,] objData = new object[rowNumber, columnNumber];

            for (int r = 0; r < rowNumber; r++)
            {
                for (int c = 0; c < columnNumber; c++)
                {
                    objData[r, c] = dataTable.Rows[r][c];
                }
            }


             range = worksheet.Range[excel.Cells[2, 1], excel.Cells[rowNumber + 1, columnNumber]];
           
            range = worksheet.Range[worksheet.Cells[2, 1], worksheet.Cells[rowNumber + 1, columnNumber]];
            range.NumberFormat = "@";//设置数字文本格式
            
            Microsoft.Office.Interop.Excel.Range rangeinfo = worksheet.Range[worksheet.Cells[2, 3], worksheet.Cells[rowNumber + 1, 3]];
            rangeinfo.NumberFormat = "yyyy年m月d日 HH: mm:ss";
            
            range.Value2 = objData;

            Microsoft.Office.Interop.Excel.Range allColumn = worksheet.Columns;
            allColumn.AutoFit();//列宽自适应
           

            worksheet.SaveAs(filePath, Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing);

            excel.Quit();
            return true;
        }
        public bool DataSetToExcel(DataTable dataTable, string fileName, bool isShowExcle)
        {
          
            int rowNumber = dataTable.Rows.Count;//不包括字段名
            int columnNumber = dataTable.Columns.Count;
            int colIndex = 0;

            if (rowNumber == 0)
            {
                System.Windows.MessageBox.Show("没有任何数据可以导入到Excel文件！");
                return false;
            }

            //建立Excel对象 
            Microsoft.Office.Interop.Excel.Application excel = new Microsoft.Office.Interop.Excel.Application();
            //excel.Application.Workbooks.Add(true);
            Microsoft.Office.Interop.Excel.Workbook workbook = excel.Workbooks.Add(Microsoft.Office.Interop.Excel.XlWBATemplate.xlWBATWorksheet);
            Microsoft.Office.Interop.Excel.Worksheet worksheet = (Microsoft.Office.Interop.Excel.Worksheet)workbook.Worksheets[1];
            excel.Visible = false;
            //Microsoft.Office.Interop.Excel.Worksheet worksheet = (Microsoft.Office.Interop.Excel.Worksheet)excel.Worksheets[1];
            Microsoft.Office.Interop.Excel.Range range;

            //生成字段名称 
            foreach (DataColumn col in dataTable.Columns)
            {
                colIndex++;
                excel.Cells[1, colIndex] = col.ColumnName;
            }

            object[,] objData = new object[rowNumber, columnNumber];

            for (int r = 0; r < rowNumber; r++)
            {
                for (int c = 0; c < columnNumber; c++)
                {
                    objData[r, c] = dataTable.Rows[r][c];
                }
                //Application.DoEvents();
            }

            // 写入Excel 
            range = worksheet.get_Range(excel.Cells[2, 1], excel.Cells[rowNumber + 1, columnNumber]);
            range.NumberFormat = "@";//设置单元格为文本格式
            //Microsoft.Office.Interop.Excel.Range rangeinfo = worksheet.get_Range(worksheet.Cells[2, 3], worksheet.Cells[rowNumber , 3]);
           // rangeinfo.NumberFormat = "00";
            range.Value2 = objData;
            
            //worksheet.get_Range(excel.Cells[2, 1], excel.Cells[rowNumber + 1, 1]).NumberFormat = "yyyy-m-d h:mm";

            //string fileName = path + "\\" + DateTime.Now.ToString().Replace(':', '_') + ".xls"; 
            workbook.SaveAs(fileName, Missing.Value, Missing.Value, Missing.Value, Missing.Value, Missing.Value, Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlNoChange, Missing.Value, Missing.Value, Missing.Value, Missing.Value, Missing.Value);

            try
            {
                workbook.Saved = true;
                excel.UserControl = false;
                //excelapp.Quit();
            }
            catch (Exception exception)
            {
                System.Windows.MessageBox.Show(exception.Message);
            }
            finally
            {
                workbook.Close(Microsoft.Office.Interop.Excel.XlSaveAction.xlSaveChanges, Missing.Value, Missing.Value);
                excel.Quit();
            }

            if (isShowExcle)
            {
                System.Diagnostics.Process.Start(fileName);
            }
            return true;
        }
        /// <summary>
        /// 保存txt文件
        /// </summary>
        /// <param name="Alllist">messageobject 集合</param>
        /// <param name="fileName">文件路径</param>
        internal static void SaveTxtFile(List<MessageObject> Alllist, string fileName)
        {
            ArrayList list = new ArrayList();
            for (int i = 0; i < Alllist.Count; i++)
            {
                list.Add(Alllist[i].fromUserName + "(" + Alllist[i].fromUserId + ")" + " " + TimeUtils.FromatTime(Convert.ToInt64(Alllist[i].timeSend), "yyyy / MM / dd HH: mm:ss"));
                if(Alllist[i].content==null)
                {
                    Alllist[i].content = "";
                }
                list.Add(Alllist[i].content);
                list.Add("");
            }
            using (FileStream fs = File.Open(fileName, FileMode.Create))
            {
                StreamWriter sw = new StreamWriter(fs);
                foreach (var v in list)
                {
                    // 一个元素占文件的一行
                    sw.WriteLine(v.ToString());
                }
                sw.Flush();
                sw.Close();
            }
        }
    }
} 
   