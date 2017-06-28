using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class LOOKUP_Student : System.Web.UI.UserControl
    {
        public event EventHandler btnSearchStudentClick;
        public event EventHandler btnChangeStudentClick;

        public bool IsControlOnModal = false;
        public bool SetFocusOnTextBox = false;
        public bool IsApplySiteLevelSecurity = false;
        public bool EnableRadioSearchType = true;

        public bool IsStudentLookupRequired = false;

        public string FieldName = "Student ID";

        public string ValidationGroup = "";

        public string SelectedStudentID
        {
            get
            {
                return hdnSelectedStudent.Value;
            }
            set
            {
                hdnSelectedStudent.Value = value;
            }
        }

        public string SelectedStudentDesc
        {
            get
            {
                return hdnSelectedStudentDesc.Value;
            }
            set
            {
                hdnSelectedStudentDesc.Value = value;
            }
        }

        public void ClearSelection()
        {
            //Initialize
            SelectedStudentID = "";
            SelectedStudentDesc = "";
            txtStudentLookup.Text = "";
            lblSelectedEmployee.Text = "";
        }

        public void SetSelectedStudent()
        {
            //initilize control
            lblResults.Text = "";

            //if student is selected
            if (!Utilities.isNull(SelectedStudentID))
            {
                divSearchType.Visible = false;
                divSearchStudent.Visible = false;
                divStudentSelected.Visible = true;

                DataSet ds = DatabaseUtilities.DsGetStudentInfo("", "", SelectedStudentID, false);
                if (ds.Tables[0].Rows.Count > 0)
                {
                    string isActive = ds.Tables[0].Rows[0]["StudentStatus"].ToString();
                    lblSelectedEmployee.CssClass = "";
                    if (!Utilities.isNull(isActive))
                    {
                        lblSelectedEmployee.CssClass = "invalid";
                    }

                    lblSelectedEmployee.Text = ds.Tables[0].Rows[0]["StudentDesc"].ToString();
                }
            }
            else
            {
                divSearchType.Visible = true;
                divSearchStudent.Visible = true;
                divStudentSelected.Visible = false;
            }

        }

        protected void Page_Load(object sender, EventArgs e)
        {
            SetSelectedStudent();

            if (!Page.IsPostBack)
            {
                if (IsApplySiteLevelSecurity)
                {
                    acxStudentLookup.ServicePath = "../Controls/WebServiceGetStudentInfoWithSecurity.asmx";
                }
                else
                {
                    acxStudentLookup.ServicePath = "../Controls/WebServiceGetStudentInfo.asmx";
                }

                reqStudentLook.Visible = IsStudentLookupRequired;
                reqStudentLook.ValidationGroup = ValidationGroup;
                reqStudentLook.ErrorMessage = "Required Field: " + FieldName;

                if (SetFocusOnTextBox)
                {
                    txtStudentLookup.Focus();
                }
                
                radList.Attributes.Add("onclick", "SetFocusOnTextBox();");
                radList.Enabled = EnableRadioSearchType;
            }
        }

        protected void lnkModalReturn_Click(object sender, EventArgs e)
        {
            string test = SelectedStudentID;
        }

        private string FirstArrayBySpace(string s)
        {
            if (!Utilities.isNull(s))
            {
                foreach (string sVal in s.Split(' '))
                {
                    return sVal;
                }
            }

            return "";
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string studentid = txtStudentLookup.Text.Trim();
            //this code is needed to handle a student control on a modal popup
            string s_id = FirstArrayBySpace(studentid);
            if (Utilities.IsNumeric(s_id))
            {
                studentid = s_id;
            }

            bool isNumber = Utilities.IsNumeric(studentid);


            if (Page.IsValid)
            {
                if (!isNumber)
                {
                    string errorMsg = "";
                    if (radList.SelectedValue.Equals("2")) //active selected
                    {
                        errorMsg = " If the student is not in the list, try searching for inactive student.";
                    }
                    if (radList.SelectedValue.Equals("3")) //inactive selected
                    {
                        errorMsg = " If the student is not in the list, try searching for active student.";
                    }

                    lblResults.Text = "You must selected a student from the list." + errorMsg;
                }
                else
                {
                    string isActive = "";

                    //Only search for active if the radio button are not enabled.
                    if (!EnableRadioSearchType)
                    {
                        isActive = "2";
                    }

                    DataSet ds = DatabaseUtilities.DsGetStudentInfo("", isActive, studentid, IsApplySiteLevelSecurity);

                    lblResults.Text = "Student ID: " + studentid + " not found or you do not have access to this student.";
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        lblResults.Text = "";
                        SelectedStudentID = ds.Tables[0].Rows[0]["StudentID"].ToString();

                        SetSelectedStudent();
                    }
                }
                
            }
            else
            {
                txtStudentLookup.Focus();
            }

            if (btnSearchStudentClick != null)
            {
                btnSearchStudentClick(sender, EventArgs.Empty);
            }
        }

        protected void btnChangeStudent_Click(object sender, EventArgs e)
        {
            txtStudentLookup.Text = "";
            SelectedStudentID = "";
            SetSelectedStudent();
            txtStudentLookup.Focus();

            if (btnChangeStudentClick != null)
            {
                btnChangeStudentClick(sender, EventArgs.Empty);
            }
        }
    }
}