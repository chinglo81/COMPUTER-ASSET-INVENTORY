using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Data;

namespace CAIRS.Controls
{
    /// <summary>
    /// Summary description for WebServiceGetEmployeeInfo
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    [System.Web.Script.Services.ScriptService]
    public class WebServiceGetEmployeeInfo : System.Web.Services.WebService
    {

        [WebMethod]
        public string HelloWorld()
        {
            return "Hello World";
        }

        [WebMethod]
        [System.Web.Script.Services.ScriptMethod]
        public string[] GetEmployeeName(string prefixText, int count, string contextKey)
        {
            DataSet ds = DatabaseUtilities.DsGetEmployeeInfoForLookup(prefixText, contextKey, "");

            var list = new System.Collections.Generic.Dictionary<string, string>(count);

            foreach (DataRow dr in ds.Tables[0].Rows)
            {
                string sIsTerm = dr["Is_Term"].ToString();
                string sEmployeeID = dr["EmpDistID"].ToString();
                string sEmployeeDisplayName = dr["EmployeeDisplayName"].ToString();

                bool IsTerm = bool.Parse(sIsTerm);

                if (IsTerm)
                {
                    sEmployeeDisplayName = "<span class='invalid'>" + sEmployeeDisplayName + "</span>";
                }

                list.Add(sEmployeeID, sEmployeeDisplayName);
            }

            return list
                    .Select(p => AjaxControlToolkit.AutoCompleteExtender
                    .CreateAutoCompleteItem(p.Value, p.Key.ToString()))
                    .ToArray<string>();
        }
    }
}
