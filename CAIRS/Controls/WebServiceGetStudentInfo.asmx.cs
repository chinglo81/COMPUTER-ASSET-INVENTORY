using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Text;
using System.Data;

namespace CAIRS.Controls
{
    /// <summary>
    /// Summary description for WebServiceGetStudentInfo
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    [System.Web.Script.Services.ScriptService]
    public class WebServiceGetStudentInfo : System.Web.Services.WebService
    {

        [WebMethod]
        public string HelloWorld()
        {
            return "Hello World";
        }

        [WebMethod]
        [System.Web.Script.Services.ScriptMethod]
        public string[] GetStudentName(string prefixText, int count, string contextKey)
        {
            DataSet ds = DatabaseUtilities.DsGetStudentInfo(prefixText, contextKey, "", false);

            var list = new System.Collections.Generic.Dictionary<string, string>(count);

            foreach (DataRow dr in ds.Tables[0].Rows)
            {
                string sStudentStatus = dr["StudentStatus"].ToString();
                string sStudentid = dr["StudentId"].ToString();
                string sStudentdesc = dr["StudentDesc"].ToString();

                if (!Utilities.isNull(sStudentStatus))
                {
                    sStudentdesc = "<span class='invalid'>" + sStudentdesc + "</span>";
                }

                list.Add(sStudentid, sStudentdesc);
            }

            return list
                    .Select(p => AjaxControlToolkit.AutoCompleteExtender
                    .CreateAutoCompleteItem(p.Value, p.Key.ToString()))
                    .ToArray<string>();
        }
    }
}
