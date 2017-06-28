using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Pages
{
    public partial class AssetFollowUpPage : _CAIRSBasePage
    {
        protected void DDLLoadSite_Filter()
        {
            ddlSite.IsSiteRequired = false;
            ddlSite.LoadDDLSite(true, false, false, false, true, true, false);
            ddlSite.AutoPostBack = false;
            SetFocus(ddlSite.ddlSite);
        }

        private void DDLLoadAssetDisposition_Filter()
        {
            ddlAssetDisposition.IsAssetDispositionRequired = true;
            ddlAssetDisposition.LoadDDLAssetDisposition(Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_FOLLOW_UP_FILTER, true, false, true);
            ddlAssetDisposition.AutoPostBack = false;
        }

        private void LoadFollowUpDg()
        {
            string p_site_ids = Utilities.buildListInDropDownList(ddlSite.ddlSite, true, ",");
            string p_dispositions = Utilities.buildListInDropDownList(ddlAssetDisposition.ddlAssetDisposition, true, ",");
            string p_tag_id = txtTagID.Text; 
            string p_serial_number = txtSerialNumber.Text;
            string p_sort_order = SortCriteria + " " + SortDir;
            string selected_site = ddlSite.SelectedValue;
            string selected_disposition = ddlAssetDisposition.SelectedValue;

            if (!selected_site.Equals(Constants._OPTION_ALL_VALUE))
            {
                p_site_ids = selected_site;
            }
            if (!selected_disposition.Equals(Constants._OPTION_ALL_VALUE))
            {
                p_dispositions = selected_disposition;
            }


            divGrid.Visible = false;
            alertAssetSearchResults.Visible = true;
            lblResults.Text = "No Recounds Found";

            DataSet ds = DatabaseUtilities.DsGetAssetFollowUp(p_site_ids, p_dispositions, p_tag_id, p_serial_number, p_sort_order);
            int iRowCount = ds.Tables[0].Rows.Count;

            if (iRowCount > 0)
            {
                divGrid.Visible = true;
                alertAssetSearchResults.Visible = false;
                lblResults.Text = "Total Recounds: " + iRowCount.ToString();

                dgAssetResults.CurrentPageIndex = int.Parse(PageIndex);
                dgAssetResults.DataSource = ds;
                dgAssetResults.DataBind();
            }
        }

        private void DDLLoadDisposition_Followup()
        {
            string disposition = hdn_Disposition_ID.Value;
            string busines_rule_disposition = "";

            switch (disposition)
            {
                case Constants.DISP_UNIDENTIFIED:
                    busines_rule_disposition = Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_FOLLOW_UP_UNIDENTIFIED;
                    break;
                case Constants.DISP_RESEARCH:
                    busines_rule_disposition = Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_FOLLOW_UP_RESEARCH;
                    break;
                case Constants.DISP_EVALUATE_CONDITION:
                    busines_rule_disposition = Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_FOLLOW_UP_EVALUATE_CONDITION;
                    break;
                default:
                    throw new Exception("Invalid Disposition For Followup: " + hdn_Disposition_Desc.Value);
            }

            ddlDisposition_Followup.LoadDDLAssetDisposition(busines_rule_disposition, true, true, false);
        }

        private void DDLLoadCondition_Followup()
        {
            string busines_rule_condition = Constants.BUSINESS_RULE_CONDITION_AVAILABLE_FOLLOW_UP;
            string selected_disposition = ddlDisposition_Followup.SelectedValue;
            ddlCondition_Followup.Visible = false;

            //Only display if option value is not "Please Select"
            if (!selected_disposition.Equals(Constants._OPTION_PLEASE_SELECT_VALUE))
            {
                ddlCondition_Followup.Visible = true;
                if (selected_disposition.Equals(Constants.DISP_BROKEN))
                {
                    busines_rule_condition = Constants.BUSINESS_RULE_CONDITION_AVAILABLE_FOLLOW_UP_BROKEN;
                }

                ddlCondition_Followup.LoadDDLAssetCondition(busines_rule_condition, true, true, false);
            }
        }

        private void LoadControlForFollowUpModal()
        {
            //Load Controls
            DDLLoadDisposition_Followup();
            DDLLoadCondition_Followup();
            ddlBin_Followup.LoadDDLBin(hdn_Asset_Site_ID.Value, true, true, true, false);

            uc_AddAttachment_Followup.GetSetAssetID = hdn_Asset_ID.Value;

            //Is Unidentified 
            bool isUnidentifiedFollowup = hdn_Disposition_ID.Value.Equals(Constants.DISP_UNIDENTIFIED);

            //Show Hide Unidentified Info
            divUnidentifiedFollowup.Visible = isUnidentifiedFollowup;
            divStandardFollowup.Visible = !isUnidentifiedFollowup;

            if (isUnidentifiedFollowup)
            {
                lblAssetBelongToStudent.Text = "Was this asset previously assigned to " + hdn_Student_Name.Value + "?";
            }

        }

        private void ShowHideStudentResponsibleForDamage()
        {
            string selected_disposition = ddlDisposition_Followup.SelectedValue;
            bool isDisplayStudentResponsibleForDamage = selected_disposition.Equals(Constants.DISP_BROKEN);
            divStudentResponsibleForBroken.Visible = isDisplayStudentResponsibleForDamage;

            if (isDisplayStudentResponsibleForDamage)
            {
                chkIsStudentResponsibleForDamage.Text = "&nbsp;&nbsp;Is student (" + hdn_Student_Name.Value + ") responsible for damage?";
            }
        }

        private bool ValidateIsBelongToStudentSelected()
        {
            bool IsSelected = true;

            //This is only required for unidentified followup
            string disposition = hdn_Disposition_ID.Value;
            if (disposition.Equals(Constants.DISP_UNIDENTIFIED))
            {
                IsSelected = !isNull(radLstAssetBelongToStudent.SelectedValue);
            }

            cvRadLstAssetBelongToStudent.IsValid = IsSelected;

            return IsSelected;

        }

        private bool ValidateIsAssignedNewTagSelected()
        {
            bool IsSelected = true;

            //This is only required for unidentified followup
            string disposition = hdn_Disposition_ID.Value;
            if (disposition.Equals(Constants.DISP_UNIDENTIFIED) && radLstAssetBelongToStudent.SelectedValue.Equals("1"))
            {
                IsSelected = !isNull(radAssignedNewTagID.SelectedValue);
            }

            cvNewTagId.IsValid = IsSelected;

            return IsSelected;

        }

        private bool ValidateDuplicateNewTagID()
        {
            bool isValid = true;
            string new_tag_id = txtNewTagID.Text.Trim();

            if (txtNewTagID.Visible && !isNull(new_tag_id))
            {
                DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.TBL_ASSET, Constants.COLUMN_ASSET_Tag_ID, new_tag_id, "");
                bool IsTagExist = ds.Tables[0].Rows.Count > 0;
                
                isValid = !IsTagExist;
            }
            cvDuplicateTagId.IsValid = isValid;
            
            return isValid;
        }

        private bool ValidateSubmitFollowUp()
        {
            bool IsPageValid = true;

            //Is Belong to student selected
            if (!ValidateIsBelongToStudentSelected())
            {
                IsPageValid = false;
            }
            //Is Assign New Tag Selected must be selected
            if (!ValidateIsAssignedNewTagSelected())
            {
                IsPageValid = false;
            }
            //Duplicate Tag ID 
            if (!ValidateDuplicateNewTagID())
            {
                IsPageValid = false;
            }

            return IsPageValid;
        }

        private void ClearModalControl()
        {
            radLstAssetBelongToStudent.ClearSelection();
            radAssignedNewTagID.ClearSelection();
            uc_AddAttachment_Followup.ClearAttachments();
            
            txtComments_Followup.Text = "";
            lblAssetBelongToStudent.Text = "";
            lblMsgNoSelectedforAssetBelongToStudent.Text = "";
            txtNewTagID.Text = "";

            divStudentResponsibleForBroken.Visible = false;
            divUnidentifiedFollowup.Visible = false;
            ddlCondition_Followup.Visible = false;
            spNewTag.Visible = false;
            txtNewTagID.Visible = false;
            divMsgNoSelectedForAssetBelongToStudent.Visible = false;
            chkStartFoundProcess.Visible = false;
            chkStartFoundProcess.Checked = false;

            
        }

        private void DisplayFollowup(string header_caption, bool isReload)
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupModal", "$('#popupFollowUp').modal();", true);
            if (isReload)
            {
                lblModalFollowupTitle.Text = header_caption;
                ClearModalControl();
                LoadControlForFollowUpModal();
                panelFollowUpModal.Update();
            }
        }

        private void SaveFollowup()
        {
            string p_Asset_Student_Transaction_ID = hdn_Asset_Student_Transaction_ID.Value;
            string p_Is_Asset_Belong_To_Student = Constants.MCSDBNOPARAM;
            string p_New_Tag_ID = Constants.MCSDBNOPARAM;
            string p_Disposition_ID = Constants.MCSDBNOPARAM;
            string p_Condition_ID = Constants.MCSDBNOPARAM;
            string p_Bin_ID = Constants.MCSDBNOPARAM;
            string p_Comments = Constants.MCSDBNOPARAM;
            string p_Attachments = uc_AddAttachment_Followup.GetAttachmentXML();
            string p_Stu_Responsible_For_Damage = "0";
            string p_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
            string p_Date = DateTime.Now.ToString();

            if (divUnidentifiedFollowup.Visible)
            {
                string asset_belong_to_student = radLstAssetBelongToStudent.SelectedValue;
                p_Is_Asset_Belong_To_Student = asset_belong_to_student;

                //Asset belongs to the reported student and asset assigned a new tag both equals "Yes"
                if (asset_belong_to_student.Equals("1") && radAssignedNewTagID.SelectedValue.Equals("1"))
                {
                    p_New_Tag_ID = txtNewTagID.Text;
                }
            }

            if (divStandardFollowup.Visible)
            {
                p_Disposition_ID = ddlDisposition_Followup.SelectedValue;
                if (p_Disposition_ID.Equals(Constants.DISP_BROKEN))
                {
                    p_Condition_ID = ddlCondition_Followup.SelectedValue;
                    if(chkIsStudentResponsibleForDamage.Checked)
                    {
                        p_Stu_Responsible_For_Damage = "1";
                    }
                }
                p_Bin_ID = ddlBin_Followup.SelectedValue;
                p_Comments = txtComments_Followup.Text;
            }


            //Upoload files to server
            uc_AddAttachment_Followup.UploadFileFromGridToServer();

            //Remove Asset from Temp location
            string asset_id = uc_AddAttachment_Followup.GetSetAssetID;
            if (!isNull(asset_id))
            {
                Utilities.RemoveAssetTempFolderByID(asset_id);
            }

            //Save Followup
            DatabaseUtilities.StudentFollowUp(
                p_Asset_Student_Transaction_ID,
                p_Is_Asset_Belong_To_Student,
                p_New_Tag_ID,
                p_Disposition_ID,
                p_Condition_ID,
                p_Bin_ID,
                p_Comments,
                p_Attachments,
                p_Stu_Responsible_For_Damage,
                p_Emp_ID,
                p_Date
            );
        }

        private void StartFoundProcessForUnidentified()
        {
            if (chkStartFoundProcess.Checked)
            {
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "redirect", "window.open('CheckInAssetPage.aspx?Check_In_Type=4')", true);
            }
        }

        protected new void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SortCriteria = "Asset_Site_Desc, Asset_Disposition_Desc";
                SortDir = "asc";
                PageIndex = "0";

                DDLLoadSite_Filter();
                DDLLoadAssetDisposition_Filter();
                LoadFollowUpDg();
            }

            ddlDisposition_Followup.SelectedIndexChanged_DDL_AssetDisposition += onSelectedIndexChange_DispositionFollowup;
            uc_AddAttachment_Followup.AddAttachment_Click += btnAddDeleteAttachment;
            uc_AddAttachment_Followup.Delete_Click += btnAddDeleteAttachment;
        }

        protected void onSelectedIndexChange_DispositionFollowup(object sender, EventArgs e)
        {
            DDLLoadCondition_Followup();
            ShowHideStudentResponsibleForDamage();
        }

        protected void btnAddDeleteAttachment(object sender, EventArgs e)
        {
            DisplayFollowup("",false);
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            SortCriteria = "Asset_Site_Desc, Asset_Disposition_Desc";
            SortDir = "asc";
            PageIndex = "0";

            LoadFollowUpDg();
        }

        protected void btnFollowUp_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;

            string asset_id = btn.Attributes["Asset_ID"];
            string asset_student_transaction_id = btn.Attributes["Asset_Student_Transaction_ID"];
            string asset_site_id = btn.Attributes["Asset_Site_ID"];
            string dispoistion_id = btn.Attributes["Asset_Disposition_ID"];
            string disposition_desc = btn.Attributes["Asset_Disposition_Desc"];
            string tag_id = btn.Attributes["Tag_ID"];
            string student_name = btn.Attributes["Student_Name"];
            string header_caption = "Follow-up - " + disposition_desc + " (Tag ID: " + tag_id + ")";

            hdn_Asset_ID.Value = asset_id;
            hdn_Asset_Student_Transaction_ID.Value = asset_student_transaction_id;
            hdn_Asset_Site_ID.Value = asset_site_id;
            hdn_Disposition_ID.Value = dispoistion_id;
            hdn_Disposition_Desc.Value = disposition_desc;
            hdn_Student_Name.Value = student_name;
            hdn_Tag_ID.Value = tag_id;

            DisplayFollowup(header_caption, true);
        }
        
        protected void dgAssetResults_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            //show hide check in button
            Label lbl = e.Item.FindControl("lblSiteBin") as Label;
            lblSiteMismatchLegend.Visible = false;

            if (lbl != null)
            {
                string asset_site_id = lbl.Attributes["Asset_Site_ID"];
                string bin_site_id = lbl.Attributes["Bin_Site_ID"];

                if (!asset_site_id.Equals(bin_site_id))
                {
                    lblSiteMismatchLegend.Visible = true;
                    e.Item.Cells[0].BackColor = System.Drawing.Color.LightPink;
                    e.Item.Cells[1].BackColor = System.Drawing.Color.LightPink;
                }
            }
        }
        
        protected void dgAssetResults_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            PageIndex = e.NewPageIndex.ToString();
            LoadFollowUpDg();
        }

        protected void dgAssetResults_SortCommand(object source, DataGridSortCommandEventArgs e)
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
            LoadFollowUpDg();
        }

        protected void btnSubmitFollowup_Click(object sender, EventArgs e)
        {
            if (ValidateSubmitFollowUp() && Page.IsValid)
            {
                SaveFollowup();
                StartFoundProcessForUnidentified();
                LoadFollowUpDg();
                CloseModal("popupFollowUp");
            }
        }

        protected void radLstAssetBelongToStudent_SelectedIndexChanged(object sender, EventArgs e)
        {
            bool IsYesSelected = radLstAssetBelongToStudent.SelectedValue.Equals("1");

            divStandardFollowup.Visible = IsYesSelected;
            spNewTag.Visible = IsYesSelected;
            
            divMsgNoSelectedForAssetBelongToStudent.Visible = !IsYesSelected;
            if (!IsYesSelected)
            {
                string msg = "NOTE: This asset will be flagged as \"Lost\" and student (" + hdn_Student_Name.Value + ") will be assessed a fee." ;
                lblMsgNoSelectedforAssetBelongToStudent.Text = msg;

                string msg_start_found = "<br/>&nbsp;&nbsp;After Submit, start \"Found Process\" in another tab for the asset in hand.";
                chkStartFoundProcess.Text = msg_start_found;
            }
            chkStartFoundProcess.Visible = !IsYesSelected;
        }

        protected void radAssignedNewTagID_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtNewTagID.Visible = radAssignedNewTagID.SelectedValue.Equals("1");
            txtNewTagID.txtTagID.Focus();
        }

    }
}