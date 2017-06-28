using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class LOOKUP_Employee : System.Web.UI.UserControl
    {
        public event EventHandler btnSearchEmployeeClick;
        public event EventHandler btnChangeEmployeeClick;

        public bool SetFocusOnTextBox = false;

        public bool IsEmployeeLookupRequired = false;

        public string FieldName = "Employee ID";
        public string ValidationGroup = "";

        public string SelectedEmployeeID
        {
            get
            {
                return hdnSelectedEmployee.Value;
            }
            set
            {
                hdnSelectedEmployee.Value = value;
            }
        }

        public string SelectedEmployeeDesc
        {
            get
            {
                return hdnSelectedEmployeeDesc.Value;
            }
            set
            {
                hdnSelectedEmployeeDesc.Value = value;
            }
        }

        public void ClearSelection()
        {
            //Initialize
            SelectedEmployeeID = "";
            SelectedEmployeeDesc = "";
            txtEmployeeLookup.Text = "";
            lblSelectedEmployee.Text = "";
        }

        public void SetSelectedEmployee()
        {
            //initilize control
            lblResults.Text = "";

            //if Employee is selected
            if (!Utilities.isNull(SelectedEmployeeID))
            {
                trSearchType.Visible = false;
                trSearchEmployee.Visible = false;
                trEmployeeSelected.Visible = true;
                DataSet ds = DatabaseUtilities.DsGetEmployeeInfoForLookup("", "", SelectedEmployeeID);
                if (ds.Tables[0].Rows.Count > 0)
                {
                    bool isTerm = bool.Parse(ds.Tables[0].Rows[0]["Is_Term"].ToString());
                    lblSelectedEmployee.CssClass = "";
                    if (isTerm)
                    {
                        lblSelectedEmployee.CssClass = "invalid";
                    }

                    lblSelectedEmployee.Text = ds.Tables[0].Rows[0]["EmployeeDisplayName"].ToString();
                }
            }
            else
            {
                trSearchType.Visible = true;
                trSearchEmployee.Visible = true;
                trEmployeeSelected.Visible = false;
            }
        }

        private string CLIENTID
        {
            get
            {
                return ClientID.ToString();
            }
        }

        private void LoadAjaxMethod()
        {
            acxEmployeeLookup.OnClientItemSelected = "OnSelectedEmployee_" + CLIENTID;
            acxEmployeeLookup.OnClientPopulated = "OnPopulatedEmployee_" + CLIENTID;
        }

        private void LoadJavascript()
        {
            string jScript = @"
                function SetFocusOnTextBox_" + CLIENTID + @"() {
                    document.getElementById('" + txtEmployeeLookup.ClientID.ToString() + @"').focus();
                }
                function SetContextKey_" + CLIENTID + @"() {
                    var selectedvalue = $('#" + radList.ClientID.ToString() + @" input:checked').val()
                    $find('" + acxEmployeeLookup.ClientID.ToString() + @"').set_contextKey(selectedvalue);
                }

                function OnSelectedEmployee_" + CLIENTID + @"(source, eventArgs) {

                    var selectedEmployeeID = eventArgs.get_value();
                    var selectedText = eventArgs.get_text();

                    if (selectedEmployeeID == null || selectedEmployeeID == '') {
                        if (selectedText != null) {
                            selectedEmployeeID = selectedText.substring(0, selectedText.indexOf('-'));
                        }
                    }

                    var hdnEmployeeID = document.getElementById('" + hdnSelectedEmployee.ClientID + @"');

                    hdnEmployeeID.value = selectedEmployeeID.trim();
        
                    __doPostBack('" + lnkModalReturn.ClientID.ToString() + @"', '');

                }

                function OnPopulatedEmployee_" + CLIENTID + @"(sender, e) {
                    var searchList = sender.get_completionList().childNodes;
                    var searchText = sender.get_element().value;
                    for (var i = 0; i < searchList.length; i++) {
                        var search = searchList[i];
                        var text = search.innerText;
                        search.innerHTML = text;
                    }
                }
            ";

            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "jscript_" + CLIENTID , jScript, true);

            txtEmployeeLookup.Attributes.Add("onkeyup", "SetContextKey_" + CLIENTID + "()");
            radList.Attributes.Add("onclick", "SetFocusOnTextBox_" + CLIENTID + "();");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            SetSelectedEmployee();

            //Need to generate these javascript dynamically so this control can be used on multiple times on a single page. 
            LoadAjaxMethod();
            LoadJavascript();
            
            if (!Page.IsPostBack)
            {
                string validationgroup = "vgEmployeelookupSearch_" + CLIENTID;
                btnSearch.ValidationGroup = validationgroup;
                reqEmployeeId.ValidationGroup = validationgroup;

                reqEmployeeLook.Visible = IsEmployeeLookupRequired;
                reqEmployeeLook.ValidationGroup = ValidationGroup + CLIENTID;
                reqEmployeeLook.ErrorMessage = "Required Field: " + FieldName;


                if (SetFocusOnTextBox)
                {
                    txtEmployeeLookup.Focus();
                }
            }
        }

        protected void lnkModalReturn_Click(object sender, EventArgs e)
        {
            string test = SelectedEmployeeID;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string Employeeid = txtEmployeeLookup.Text;
            bool isNumber = Utilities.IsNumeric(Employeeid);
            if (Page.IsValid)
            {
                if (!isNumber)
                {
                    string errorMsg = "";
                    if (radList.SelectedValue.Equals("2")) //active selected
                    {
                        errorMsg = " If the employee is not in the list, try searching for inactive employee.";
                    }
                    if (radList.SelectedValue.Equals("3")) //inactive selected
                    {
                        errorMsg = " If the employee is not in the list, try searching for active employee.";
                    }

                    lblResults.Text = "You must selected a Employee from the list." + errorMsg;
                }
                else
                {
                    DataSet ds = DatabaseUtilities.DsGetEmployeeInfoForLookup("", "", Employeeid);

                    lblResults.Text = "Employee ID: " + Employeeid + " not found.";
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        lblResults.Text = "";
                        SelectedEmployeeID = ds.Tables[0].Rows[0]["EmpDistID"].ToString();

                        SetSelectedEmployee();

                        if (btnSearchEmployeeClick != null)
                        {
                            btnSearchEmployeeClick(sender, EventArgs.Empty);
                        }
                    }
                }
            }
            else
            {
                txtEmployeeLookup.Focus();
            }

        }

        protected void btnChangeEmployee_Click(object sender, EventArgs e)
        {
            txtEmployeeLookup.Text = "";
            SelectedEmployeeID = "";
            SetSelectedEmployee();
            txtEmployeeLookup.Focus();

            if (btnChangeEmployeeClick != null)
            {
                btnChangeEmployeeClick(sender, EventArgs.Empty);
            }
        }
    }
}