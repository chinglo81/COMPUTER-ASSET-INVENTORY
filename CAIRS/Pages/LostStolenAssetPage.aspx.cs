using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Pages
{
    public partial class LostStolenAssetPage : _CAIRSBasePage
    {
        private void LoadSite_DDL()
        {
            ddlSite.AutoPostBack = true;
            ddlSite.IsSiteRequired = true;
            ddlSite.LoadDDLSite(true, false, true, true, false, true, true);
            ddlSite.reqSite.EnableClientScript = false;
        }

        private void LoadLostFoundDisposition_DDL()
        {
            ddlDisposition.IsAssetDispositionRequired = true;
            ddlDisposition.LoadDDLAssetDisposition(Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_LOST_STOLEN, true, true, false);
        }

        private void LoadStudentInfo(string studentid)
        {
            divStudentInfo.Visible = false;
            divCurrentlyAssigned.Visible = false;

            if (!isNull(studentid))
            {
                divStudentInfo.Visible = true;
                divCurrentlyAssigned.Visible = true;
                Student_Info.LoadStudentInfo(studentid);
                LoadCurrentAssignmentDG(studentid, "", "", false);
            }
        }

        private void LoadCurrentAssignmentDG(string studentid, string serialNumber, string tag_id, bool displaySuccessMessage)
        {
            DataSet ds = DatabaseUtilities.DsGetCheckOutAssignment(studentid, serialNumber, tag_id);

            dgAssignment.Visible = false;
            lblResults.Text = "No asset(s) assignment found for this student.";

            lblSuccessfullySubmitted.Visible = displaySuccessMessage;

            if (ds.Tables[0].Rows.Count > 0)
            {
                lblResults.Text = "";
                dgAssignment.Visible = true;
                dgAssignment.DataSource = ds;
                dgAssignment.DataBind();
            }
        }

        private void LoadStudentLostStolenAssetInfo(string Student_Asset_Transaction_ID)
        {
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_STUDENT_ASSIGNMENT, "ID", Student_Asset_Transaction_ID, "");
            Utilities.DataBindForm(divStudentLostStolenInfo, ds);

            string assetid = ds.Tables[0].Rows[0]["Asset_ID"].ToString();

            if (!isNull(assetid))
            {
                uc_AddAttachment_LostStolen.GetSetAssetID = assetid;
            }
        }

        private void LoadControlsForLostStolen(string Student_Asset_Transaction_ID)
        {
            LoadLostFoundDisposition_DDL();
            LoadStudentLostStolenAssetInfo(Student_Asset_Transaction_ID);

            //Initilize control
            txtComments.Text = "";
            trPoliceReportProvided.Visible = false;
            uc_AddAttachment_LostStolen.ClearAttachments();
        }

        private void DisplayLostStolen(string id, bool isReload)
        {
            lblModalTitle.Text = "Transaction Details";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupLostStolen').modal();", true);
            if (isReload)
            {
                LoadControlsForLostStolen(id);
            }
        }

        private bool ValidateCheckIn(string check_In_Site_ID, string asset_Site_ID)
        {
            bool isSiteMatch = check_In_Site_ID.Equals(asset_Site_ID);

            if (!isSiteMatch)
            {
                string check_in_site_desc = Utilities.GetSiteNameByID(check_In_Site_ID);
                if (!isNull(check_in_site_desc))
                {
                    check_in_site_desc = "(" + check_in_site_desc + ") ";
                }
                string asset_site_desc = Utilities.GetSiteNameByID(asset_Site_ID);
                string errMsg = "Site Mistmatch. The processing site " + check_in_site_desc + "and the site asset (" + asset_site_desc + ") does not match.";

                cvCheckInValidator.IsValid = false;
                cvCheckInValidator.Text = errMsg;
                cvCheckInValidator.ErrorMessage = errMsg;
            }

            return isSiteMatch;
        }

        private void ApplySecurityToControl()
        {
            //None
        }


        protected new void Page_Load(object sender, EventArgs e)
        {
            string selectedStudent = txtStudentLookup.SelectedStudentID;
            if (!isNull(selectedStudent))
            {
                LoadStudentInfo(selectedStudent);
            }

            if (!IsPostBack)
            {
                LoadSite_DDL();
                ApplySecurityToControl();
            }

            //this needs to load on every Postback to function correctly.
            txtStudentLookup.btnSearchStudentClick += btnStudentSearch_Click;
            txtStudentLookup.btnChangeStudentClick += btnLookupStudent_Click;
            uc_AddAttachment_LostStolen.AddAttachment_Click += addAttachment_Click;
            uc_AddAttachment_LostStolen.Delete_Click += addAttachment_Click;
            ddlDisposition.SelectedIndexChanged_DDL_AssetDisposition += OnSelected_ddlDisposition;
        }

        protected void btnStudentSearch_Click(object sender, EventArgs e)
        {
            string selectedStudent = txtStudentLookup.SelectedStudentID;
            if (!isNull(selectedStudent))
            {
                LoadStudentInfo(selectedStudent);
            }
        }

        protected void btnLookupStudent_Click(object sender, EventArgs e)
        {
            //Clear student selected 
            txtStudentLookup.SelectedStudentID = "";
            txtStudentLookup.SetSelectedStudent();
            divStudentInfo.Visible = false;
            divCurrentlyAssigned.Visible = false;
        }

        protected void addAttachment_Click(object sender, EventArgs e)
        {
            DisplayLostStolen("", false);
        }

        protected void OnSelected_ddlDisposition(object sender, EventArgs e)
        {
            //Display if reported stolen
            trPoliceReportProvided.Visible = ddlDisposition.SelectedValue.Equals(Constants.DISP_STOLEN);
            DisplayLostStolen("", false);
        }

        protected void btnProcessLostStolen_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string id = btn.Attributes["Asset_Student_Transaction_ID"];

            string assetSiteID = btn.Attributes["Asset_Site_ID"];
            string checkInSiteID = ddlSite.SelectedValue;
            if (ValidateCheckIn(checkInSiteID, assetSiteID) && IsValid)
            {
                DisplayLostStolen(id, true);
            }
            else
            {
                DisplayErrorModal("vgProcessLostStolen");
            }
        }

        protected void btnSubmitLostStolen_Click(object sender, EventArgs e)
        {
            if (IsValid)
            {

            }
            else
            {
                DisplayLostStolen("", false);
            }
        }
    }
}