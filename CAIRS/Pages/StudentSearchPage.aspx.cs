using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Text;

namespace CAIRS.Pages
{
    public partial class StudentSearchPage : _CAIRSBasePage
    {
        private const string SELECTION_TYPE_SINGLE = "SINGLE";

        private const string SELECTION_TYPE_MULTIPLE = "MULTIPLE";

        private string GetStudentIDs()
        {
            string studentid = "";
            if (radSingleMultipleStudent.SelectedValue.Equals(SELECTION_TYPE_SINGLE))
            {
                studentid = txtStudentLookup.SelectedStudentID;
            }
            else
            {
                studentid = txtStudentIds.Text.Replace("\n", ",").Replace(" ", "");
            }

            return studentid;
        }

        private void ShowHideStudentColumnInDg()
        {
            foreach (DataGridColumn col in dgStudentSearch.Columns)
            {
                // Show column
                if (col.HeaderText.Equals("Student ID") || col.HeaderText.Equals("Student"))
                {
                    col.Visible = radSingleMultipleStudent.SelectedValue.Equals(SELECTION_TYPE_MULTIPLE);
                }
            }
        }

        private void LoadStudentSearchDG(string studentid)
        {
            //GetStudentIDs()
            string orderby = SortCriteria + " " + SortDir;
            DataSet ds = DatabaseUtilities.DsGetStudentSearch(studentid, orderby);

            dgStudentSearch.Visible = false;
            headerStudentSearch.Visible = false;
            lblResults.Text = "No Records Found";

            int iRowCount = ds.Tables[0].Rows.Count;
            if (iRowCount > 0)
            {
                dgStudentSearch.Visible = true;
                headerStudentSearch.Visible = true;
                lblResults.Text = "Total Records: " + iRowCount.ToString();

                int iPageIndex = 0;
                if (!isNull(PageIndex) && Utilities.IsNumeric(PageIndex))
                {
                    iPageIndex = int.Parse(PageIndex);
                }

                dgStudentSearch.CurrentPageIndex = iPageIndex;
                dgStudentSearch.DataSource = ds;
                dgStudentSearch.DataBind();

                ShowHideStudentColumnInDg();
            }
            
        }

        private void LoadStudentAssetDetails(string asset_student_transaction_id)
        {
            
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_STUDENT_ASSET_SEARCH, "Asset_Student_Transaction_ID", asset_student_transaction_id, "");
            Utilities.DataBindForm(divStudentTransactionDetails, ds);

            string found_date = "";

            //load Student Info Control
            if (ds.Tables[0].Rows.Count > 0)
            {
                string studentid = ds.Tables[0].Rows[0]["Student_ID"].ToString();
                found_date = ds.Tables[0].Rows[0]["Date_Found_Formatted"].ToString();

                if (!isNull(studentid))
                {
                    Student_Info.LoadStudentInfo(studentid);
                }
            }

            bool isDisplayFoundInfo = !isNull(found_date);

            trFoundDisposition.Visible = isDisplayFoundInfo;
            trFoundCondition.Visible = isDisplayFoundInfo;
            trFoundDate.Visible = isDisplayFoundInfo;

        }

        private void DisplayWarningMessageForReadOnlyUser()
        {
            bool isCurrentUserReadOnly = AppSecurity.Current_User_Access_Level().Equals(AppSecurity.ROLE_READ_ONLY);
            if (isCurrentUserReadOnly)
            {
                DataSet ds = DatabaseUtilities.DsGetUserAccessibleStudentSearch(GetStudentIDs());
                int iRowCount = int.Parse(ds.Tables[0].Rows[0]["Total"].ToString());
                if (iRowCount > 0)
                {
                    DisplayMessage("Please Note ", "You can only view student(s) at the following site location: <br /><br />" + AppSecurity.Get_Current_User_Accessible_Site_Desc());
                }
                
            }
        }

        private void DisplayDetails(string asset_student_transaction_id)
        {
            lblModalTitle.Text = "Student Asset Info";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupDisplayStudentAssetDetail').modal();", true);
            LoadStudentAssetDetails(asset_student_transaction_id);
            updateStudentDetails.Update();
        }

        private void ApplySecurityToControl()
        {
            //None. All Roles have access to all controls for this page.
        }

        private void ClearStudentLookup()
        {
            //Clear student selected 
            txtStudentLookup.SelectedStudentID = "";
            txtStudentLookup.txtStudentLookup.Text = "";
            txtStudentLookup.SetSelectedStudent();
        }

        private void InitilizeSortPaging()
        {
            //Default Sort
            SortCriteria = "Student_Name, isnull(Date_Check_In, getdate()) ";
            SortDir = "desc";
            PageIndex = "0";

        }

        protected new void Page_Load(object sender, EventArgs e)
        {
            string selectedStudent = txtStudentLookup.SelectedStudentID;
            txtStudentLookup.Visible = true;
            if (!isNull(selectedStudent))
            {
                LoadStudentSearchDG(selectedStudent);
                DisplayWarningMessageForReadOnlyUser();
            }

            if (!IsPostBack)
            {
                InitilizeSortPaging();

                txtStudentLookup.Focus();

                ApplySecurityToControl();

                headerStudentSearch.Visible = false;
            }
            txtStudentLookup.btnSearchStudentClick += btnStudentSearch_Click;
            txtStudentLookup.btnChangeStudentClick += btnLookupStudent_Click;
            txtStudentLookup.txtStudentLookup.Attributes.Add("onkeypress", "HandleNumberEnteredStudentLookup(event)");


        }
        
        protected void dgStudentSearch_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            PageIndex = e.NewPageIndex.ToString();
            LoadStudentSearchDG(GetStudentIDs());
        }

        protected void dgStudentSearch_SortCommand(object source, DataGridSortCommandEventArgs e)
        {
            if (SortCriteria == e.SortExpression)
            {
                if (SortDir == "desc")
                {
                    SortDir = "asc";
                }
                else
                {
                    SortDir = "desc";
                }
            }
            SortCriteria = e.SortExpression;
            LoadStudentSearchDG(GetStudentIDs());
        }

        protected void dgStudentSearch_ItemDataBound(object sender, DataGridItemEventArgs e)
        {

        }

        protected void btnStudentSearch_Click(object sender, EventArgs e)
        {
            btnApplyFilters_Click(sender, e);
        }

        protected void btnLookupStudent_Click(object sender, EventArgs e)
        {
            ClearStudentLookup();
            lblResults.Text = "";
            dgStudentSearch.Visible = false;
            headerStudentSearch.Visible = false;
        }

        protected void radSingleMultipleStudent_SelectedIndexChanged(object sender, EventArgs e)
        {
            string sSelectedType = radSingleMultipleStudent.SelectedValue;
            divSingleStudent.Visible = sSelectedType.Equals(SELECTION_TYPE_SINGLE);
            divMultipleStudent.Visible = sSelectedType.Equals(SELECTION_TYPE_MULTIPLE);
            divSearchClearButton.Visible = false;
            dgStudentSearch.Visible = false;
            headerStudentSearch.Visible = false;
            ClearStudentLookup();
            lblResults.Text = ""; 

            if (sSelectedType.Equals(SELECTION_TYPE_SINGLE))
            {
                txtStudentLookup.txtStudentLookup.Focus();
            }

            if (sSelectedType.Equals(SELECTION_TYPE_MULTIPLE))
            {
                divSearchClearButton.Visible = true;
                txtStudentIds.Focus();
            }
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            if (IsValid)
            {
                //Default Sort
                InitilizeSortPaging();

                LoadStudentSearchDG(GetStudentIDs());

                DisplayWarningMessageForReadOnlyUser();
            }
        }

        protected void btnDetails_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string Asset_Student_Transaction_ID = btn.Attributes["Asset_Student_Transaction_ID"];
            DisplayDetails(Asset_Student_Transaction_ID);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtStudentIds.Text = "";
            dgStudentSearch.Visible = false;
            headerStudentSearch.Visible = false;
            lblResults.Text = "";
            txtStudentIds.Focus();
        }
    }
}