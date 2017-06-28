using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.OleDb;
using Excel = Microsoft.Office.Interop.Excel;

namespace CAIRS.Pages
{
    public partial class TestPage : _CAIRSBasePage
    {
        private string getValue()
        {
            string sVal = "";

            return sVal;
        }

        protected new void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                MULTI_DDL_AssetDisposition.SetSelectedValuePageLoad = "1,2,3";

                multi_assetCondition.SetSelectedValuePageLoad = "1,2";

                //testInvalidDataset();

                //dgTest.DataSource = test();
                //dgTest.DataBind();
            }
        }

        private void loadData()
        {
            
        }

        private void testInvalidDataset()
        {
            string sSQL = "select 123 from dude";
            DataSet ds = DatabaseUtilities.ExecuteSQLStatement(sSQL);
        }

        protected void btn_Click(object sender, EventArgs e)
        {
            string test = getValue();

            DisplayMessage("Selected Values", "Selected Values are: " + MULTI_DDL_AssetDisposition.GetSelectedValue + "||" + multi_assetCondition.GetSelectedValue);
        }

        public DataTable test()
        {
            DataTable dtResult = null;
            string FileName = @"C:\Project\CAIRS_Documentation\ASBWorks\Davis.xlsx";
            //OleDbConnection objConn = new OleDbConnection(@"Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FileName + ";Extended Properties='Excel 12.0;HDR=YES;IMEX=1;';");

            int totalSheet = 0; //No of sheets on excel file  
            using(OleDbConnection objConn = new OleDbConnection(@"Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FileName + ";Extended Properties='Excel 12.0;HDR=YES;IMEX=1;';"))  
            {  
                objConn.Open();  
                OleDbCommand cmd = new OleDbCommand();  
                OleDbDataAdapter oleda = new OleDbDataAdapter();  
                DataSet ds = new DataSet();  
                DataTable dt = objConn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);  
                string sheetName = string.Empty;  
                if (dt != null)  
                {  
                    var tempDataTable = (from dataRow in dt.AsEnumerable()  
                    where!dataRow["TABLE_NAME"].ToString().Contains("FilterDatabase")  
                    select dataRow).CopyToDataTable();  
                    dt = tempDataTable;  
                    totalSheet = dt.Rows.Count;  
                    sheetName = dt.Rows[0]["TABLE_NAME"].ToString();  
                }  
                cmd.Connection = objConn;  
                cmd.CommandType = CommandType.Text;

                string sColumns =           "1 as Config_ID," +
                                            @"
                                            [Student ID], 
                                            Last,
                                            First,
                                            Product,
                                            Price,
                                            Payments,
                                            Date,
                                            0 as IsProcessed,
                                            null as Comment,
                                            '" + DateTime.Now.ToString() + @"' as Date_Imported
                                            ";

                cmd.CommandText = "SELECT " + sColumns + " FROM [" + sheetName + "] " ;  
                oleda = new OleDbDataAdapter(cmd);  
                oleda.Fill(ds, "excelData");  
                DataView dv = new DataView(ds.Tables[0]);
                dv.RowFilter = "isnull([Student ID], '') != ''";

                
                dtResult = dv.ToTable();  
                objConn.Close();  
                
            }
            return dtResult; //Returning Dattable  
        }

    }
}