using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Text;
using System.Collections;
using System.Web.UI.HtmlControls;

namespace CAIRS.Pages
{
    public partial class StudentSearchPage : _CAIRSBasePage
    {
        protected new void Page_Load(object sender, EventArgs e)
        {
            ShowHideFilterControl();

            string selectedStudent = txtStudentLookup.SelectedStudentID;
            txtStudentLookup.Visible = true;
            if (!isNull(selectedStudent))
            {
                LoadStudentSearchDG();
                DisplayWarningMessageForReadOnlyUser();
            }

            if (!IsPostBack)
            {
                DDLLoadSite();
                DDLLoadAssetBaseType();
                DDLLoadAssetType(ddlAssetBaseType.SelectedValue);

                InitilizeSortPaging();

                txtStudentLookup.Focus();

                ApplySecurityToControl();

                headerStudentSearch.Visible = false;
            }
            txtStudentLookup.btnSearchStudentClick += btnStudentSearch_Click;
            txtStudentLookup.btnChangeStudentClick += btnLookupStudent_Click;
            txtStudentLookup.txtStudentLookup.Attributes.Add("onkeypress", "HandleNumberEnteredStudentLookup(event)");
            ddlDisposition_CheckIn.SelectedIndexChanged_DDL_AssetDisposition += ddlDisposition_Check_In_SelectedIndexChanged;
            ddlAssetBaseType.SelectedIndexChanged_DDL_AssetBaseType += onSelectedIndexChange_ddlAssetBaseType;
        }

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
                studentid = txtStudentIds.Text.Replace("\r\n", ",").Replace(" ", "").Replace("\n", ",");
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

        private DataSet DsStudentSearch(bool is_export)
        {
            string orderby = SortCriteria + " " + SortDir;

            string site = Utilities.getDbValueNull(ddlSite.SelectedValue);
            string base_type = Utilities.getDbValueNull(ddlAssetBaseType.SelectedValue);
            string asset_type = Utilities.getDbValueNull(ddlAssetType.SelectedValue);

            return DatabaseUtilities.DsGetStudentSearch(GetStudentIDs(), site, base_type, asset_type, multiAssetDisposition.GetSelectedValue, orderby, is_export);
        }

        protected void DDLLoadSite()
        {
            ddlSite.IsSiteRequired = false;
            ddlSite.LoadDDLSite(true, true, false, false, true, false, false);
            ddlSite.AutoPostBack = false;
            SetFocus(ddlSite.ddlSite);
        }

        protected void DDLLoadAssetBaseType()
        {
            ddlAssetBaseType.IsAssetBaseTypeRequired = false;
            ddlAssetBaseType.LoadDDLAssetBaseType(false, false, true);
            ddlAssetBaseType.AutoPostBack = true;
        }

        protected void DDLLoadAssetType(string AssetBaseTypeID)
        {
            ddlAssetType.IsAssetTypeRequired = false;
            ddlAssetType.LoadDDLAssetType(AssetBaseTypeID, false, false, true);
            ddlAssetType.AutoPostBack = false;
        }

        protected void onSelectedIndexChange_ddlAssetBaseType(object sender, EventArgs e)
        {
            string selectedBaseType = ddlAssetBaseType.SelectedValue;
            DDLLoadAssetType(selectedBaseType);
            updatePanelBaseAssetType.Update();
        }

        private void LoadStudentSearchDG()
        {
            DataSet ds = DsStudentSearch(false);

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

        private void LoadAttachmentDG()
        {
            string Asset_Student_Transaction_ID = hdnAssetStudentTransactionID.Value;
            string sortby = "Date_Added desc";
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_TAB_ATTACHMENTS, Constants.COLUMN_V_ASSET_TAB_ATTACHMENTS_Asset_Student_Transaction_ID, Asset_Student_Transaction_ID, sortby);

            dgExistingAttachment.Visible = false;
            lblNoExistingAttachment.Text = "No attachments(s) found <br><br>";
            if (ds.Tables[0].Rows.Count > 0)
            {
                lblNoExistingAttachment.Text = "";
                dgExistingAttachment.Visible = true;
                dgExistingAttachment.DataSource = ds;
                dgExistingAttachment.DataBind();
            }
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
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupDisplayStudentAssetDetail').modal();HideProgressLoader();", true);
            LoadStudentAssetDetails(asset_student_transaction_id);
            updateStudentDetails.Update();
        }

        private void DisplayEditCheckIn(bool IsReload)
        {
            lblModalTitle.Text = "Edit Check-In";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupEditStudentCheckIn').modal();HideProgressLoader()", true);

            if (IsReload)
            {
                InitilizeCheckInControls();
                LoadCheckInInfo();
            }

            updatePanelStudentCheckIn.Update();
        }

        private void DisplayAddNewAttachment()
        {
            string jQuery = @"$('#modalAddNewAttachment').modal();
                              $('#popupEditStudentCheckIn').modal('hide');
                              HideProgressLoader();
                            ";

            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "AddNewAttachment", jQuery, true);
        }

        private void DisplayConfirmationSaveCheckIn()
        {
            string jQuery = @"$('#popupConfirmSaveCheckIn').modal();";

            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "AddNewAttachment", jQuery, true);
        }

        private void InitilizeCheckInControls()
        {
            divPoliceReport.Visible = false;
            divDisposition.Visible = false;
            divImportantAffixSticker.Visible = false;
            divPoliceReport.Visible = false;
            divAssetCondition_CheckIn.Visible = false;

            txtComments_CheckIn.Text = "";
            hdnConditionBusinessRule.Value = "";
        }

        private void LoadCheckInInfo()
        {
            ddlAttachmentType.LoadddlAttachmentType(true, true, false); 

            string Asset_Student_Transaction_ID = hdnAssetStudentTransactionID.Value;
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_STUDENT_ASSIGNMENT, Constants.COLUMN_V_ASSET_STUDENT_ASSIGNMENT_ID, Asset_Student_Transaction_ID, "");
            //Should always return 1 record
            Utilities.Assert(ds.Tables[0].Rows.Count == 1, "No records return for Asset_Student_Transaction_ID = " + Asset_Student_Transaction_ID);

            string asset_id = ds.Tables[0].Rows[0][Constants.COLUMN_V_ASSET_STUDENT_ASSIGNMENT_Asset_ID].ToString();
            string check_in_type = ds.Tables[0].Rows[0][Constants.COLUMN_V_ASSET_STUDENT_ASSIGNMENT_Check_In_Type_ID].ToString();
            string check_in_disposition = ds.Tables[0].Rows[0][Constants.COLUMN_V_ASSET_STUDENT_ASSIGNMENT_Check_In_Disposition_ID].ToString();
            string asset_site = ds.Tables[0].Rows[0][Constants.COLUMN_V_ASSET_STUDENT_ASSIGNMENT_Asset_Site_ID].ToString();
            string check_in_condition = ds.Tables[0].Rows[0][Constants.COLUMN_V_ASSET_STUDENT_ASSIGNMENT_Check_In_Asset_Condition_ID].ToString();

            LoadCheckInType_DDL();

            ShowHideControlForEditCheckIn(check_in_type, check_in_disposition);

            Utilities.DataBindForm(divStudentCheckInModal, ds);
            
            LoadAttachmentDG();
        }

        private void LoadDisposition_CheckIn_DDL(string business_rule)
        {
            ddlDisposition_CheckIn.IsAssetDispositionRequired = true;
            ddlDisposition_CheckIn.LoadDDLAssetDisposition(business_rule, true, true, false);
        }

        private void LoadCondition_CheckIn_DDL(string business_rule)
        {
            ddlCondition_CheckIn.IsAssetConditionRequired = true;
            ddlCondition_CheckIn.LoadDDLAssetCondition(business_rule, true, true, false);
        }

        private void ChangeDisposition()
        {
            string selected_disposition = ddlDisposition_CheckIn.SelectedValue;

            divImportantAffixSticker.Visible = selected_disposition.Equals(Constants.DISP_UNIDENTIFIED);

            bool isDisplayCondition = selected_disposition.Equals(Constants.DISP_AVAILABLE) || selected_disposition.Equals(Constants.DISP_BROKEN) || selected_disposition.Equals(Constants.DISP_UNIDENTIFIED);
          
            divAssetCondition_CheckIn.Visible = isDisplayCondition;

            divStudentResponsibleForBroken.Visible = false;
            if (selected_disposition.Equals(Constants.DISP_BROKEN))
            {
                LoadCondition_CheckIn_DDL(Constants.BUSINESS_RULE_CONDITION_AVAILABLE_CHECK_IN_DISP_BROKEN);
                //Display Is student responsible for damage
                divStudentResponsibleForBroken.Visible = true;
            }
            else
            {
                LoadCondition_CheckIn_DDL(hdnConditionBusinessRule.Value);
            }
            
            
        }

        private void ShowHideControlForEditCheckIn(string check_in_type, string set_disposition_id)
        {
            //InitilizeCheckInControls();

            chkIsStudentResponsibleForDamage.Text = "&nbsp;Is Student (" + hdnStudentNameID.Value + ") responsible for damage?";

            string business_rule_disposition = "";
            string business_rule_condition = "";

            switch (check_in_type)
            {
                case Constants.CHECK_IN_TYPE_CODE_FOUND:
                    business_rule_disposition = Constants.BUSINESS_RULE_DISPOSITION_CHECK_IN_FOUND;
                    business_rule_condition = Constants.BUSINESS_RULE_CONDITION_AVAILABLE_CHECK_IN_FOUND;

                    divDisposition.Visible = true;
                    break;
                
                case Constants.CHECK_IN_TYPE_CODE_RETURN:
                    business_rule_disposition = Constants.BUSINESS_RULE_DISPOSITION_CHECK_IN_RETURN;
                    business_rule_condition = Constants.BUSINESS_RULE_CONDITION_AVAILABLE_CHECK_IN_RETURN;

                    divDisposition.Visible = true;
                    break;
                case Constants.CHECK_IN_TYPE_CODE_STANDARD:
                    business_rule_disposition = Constants.BUSINESS_RULE_DISPOSITION_CHECK_IN_STANDARD;
                    business_rule_condition = Constants.BUSINESS_RULE_CONDITION_AVAILABLE_CHECK_IN_STANDARD;

                    divDisposition.Visible = true;
                    break;
                
                case Constants.CHECK_IN_TYPE_CODE_LOST:
                    business_rule_disposition = Constants.BUSINESS_RULE_DISPOSITION_CHECK_IN_LOST;
                    business_rule_condition = ""; //Does not exist for lost 

                    divDisposition.Visible = true;
                    break;
                
                case Constants.CHECK_IN_TYPE_CODE_STOLEN:
                    business_rule_disposition = Constants.BUSINESS_RULE_DISPOSITION_CHECK_IN_STOLEN;
                    business_rule_condition = "";//Does not exist for stolen 

                    divDisposition.Visible = true;
                    divPoliceReport.Visible = true;
                    break;
                case Constants.CHECK_IN_TYPE_CODE_UNIDENTIFIED:
                    business_rule_disposition = Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_CHECK_IN_UNIDENTIFIED;
                    business_rule_condition = Constants.BUSINESS_RULE_CONDITION_AVAILABLE_CHECK_IN_UNIDENTIFIED;

                    divImportantAffixSticker.Visible = true;
                    divDisposition.Visible = true;

                    break;
                default:
                    //do nothing
                    break;
            }

            hdnConditionBusinessRule.Value = business_rule_condition;

            LoadDisposition_CheckIn_DDL(business_rule_disposition);

            //check to see if the value exist before setting
            if (ddlDisposition_CheckIn.ddlAssetDisposition.Items.Contains(ddlDisposition_CheckIn.ddlAssetDisposition.Items.FindByValue(set_disposition_id)))
            {
                ddlDisposition_CheckIn.SelectedValue = set_disposition_id;
            }

            ChangeDisposition();
            //LoadBin_CheckIn_DDL();

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
            SortCriteria = "Student_Name, Date_Check_In";
            SortDir = "asc";
            PageIndex = "0";

        }

        private void LoadCheckInType_DDL()
        {
            string business_rule = Constants.BUSINESS_RULE_CHECK_IN_TYPE_AVAILABLE_EDIT;

            DataSet ds = DatabaseUtilities.DsGetCheckInType(true, business_rule, "Name");
            int iRowCount = ds.Tables[0].Rows.Count;

            if (iRowCount > 0)
            {
                ddlCheckInType.DataSource = ds;
                ddlCheckInType.DataTextField = Constants.COLUMN_CT_CHECK_IN_TYPE_Name;
                ddlCheckInType.DataValueField = Constants.COLUMN_CT_CHECK_IN_TYPE_ID;
                ddlCheckInType.DataBind();

                ddlCheckInType.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Check-in Type ---", "-98"));

                //Default selected option to standard
                //Utilities.DDL_SetValueIfExist(ddlCheckInType, Constants.CHECK_IN_TYPE_CODE_STANDARD);
            }

        }

        private void SaveAttachment()
        {
            //Variable to process
            string s_file_type = Utilities.GetFileTypeFromUploadControl(FileUploadAttachment);

            //Paramters for Save
            string p_ID = "-1";
            string p_Asset_Student_Transaction_ID = hdnAssetStudentTransactionID.Value;
            string p_Asset_ID = hdnAssetID.Value;
            string p_Student_ID = hdnStudentID.Value;
            string p_Asset_Tamper_ID = Constants.MCSDBNOPARAM;
            string p_Attachment_Type_ID = ddlAttachmentType.SelectedValue;
            string p_File_Type_ID = Constants.MCSDBNOPARAM;
            string p_File_Name = txtAttachmentNameEdit.Text;
            string p_Description = txtAttachmentDescEdit.Text;
            string p_Added_By_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());
            string p_Date_Added = DateTime.Now.ToString();
            string p_Modified_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Date_Modifed = Constants.MCSDBNOPARAM;

            if (FileUploadAttachment.HasFile)
            {
                p_File_Type_ID = Utilities.GetFileTypeIDFromName(s_file_type);
            }

            Utilities.Assert(!isNull(p_File_Type_ID), "Was not able to determine File Type from the selection.");

            //Saving Database changes
            string new_attachment_id = DatabaseUtilities.Upsert_Asset_Attachment(
                                        p_ID,
                                        p_Asset_Student_Transaction_ID,
                                        p_Asset_ID,
                                        p_Student_ID,
                                        p_Asset_Tamper_ID,
                                        p_Attachment_Type_ID,
                                        p_File_Type_ID,
                                        p_File_Name,
                                        p_Description,
                                        p_Added_By_Emp_ID,
                                        p_Date_Added,
                                        p_Modified_By_Emp_ID,
                                        p_Date_Modifed
                                    );

            string filenametype = p_File_Name + '.' + s_file_type;

            Utilities.UploadFileToServer(p_Asset_ID, new_attachment_id, filenametype, true, FileUploadAttachment);

        }

        private void SaveCheckIn()
        {
            string p_Asset_Student_Transaction_ID = hdnAssetStudentTransactionID.Value;
            string p_Check_In_Type_ID = ddlCheckInType.SelectedValue;
            string p_Disposition_ID = ddlDisposition_CheckIn.SelectedValue;
            string p_Check_In_Condition_ID = Constants.MCSDBNOPARAM;
            string p_Stu_Responsible_For_Damage = "0";
            string p_Is_Police_Report_Provided = "0";
            string p_Comments = txtComments_CheckIn.Text;
            string p_Edit_Reason = txtEditReason.Text;
            string p_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());
            string p_Date = DateTime.Now.ToString();

            if (divAssetCondition_CheckIn.Visible)
            {
                p_Check_In_Condition_ID = ddlCondition_CheckIn.SelectedValue;
            }

            if (divStudentResponsibleForBroken.Visible && chkIsStudentResponsibleForDamage.Checked)
            {
                p_Stu_Responsible_For_Damage = "1";
            }

            if (divPoliceReport.Visible && chkPoliceReport.Checked)
            {
                p_Is_Police_Report_Provided = "1";
            }

            /**/
            DatabaseUtilities.EditStudentCheckIn(
                p_Asset_Student_Transaction_ID,
                p_Check_In_Type_ID,
                p_Disposition_ID,
                p_Check_In_Condition_ID,
                p_Stu_Responsible_For_Damage,
                p_Is_Police_Report_Provided,
                p_Comments,
                p_Edit_Reason,
                p_Emp_ID,
                p_Date
            );
             
        }

        protected void dgStudentSearch_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            PageIndex = e.NewPageIndex.ToString();
            LoadStudentSearchDG();
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
            LoadStudentSearchDG();
        }

        protected void dgStudentSearch_ItemDataBound(object sender, DataGridItemEventArgs e)
        {

        }

        protected void dgExistingAttachment_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            if (e.Item.ItemIndex >= 0)
            {
                Button btnView = ((Button)e.Item.FindControl("btnView"));
                ScriptManager.GetCurrent(this).RegisterPostBackControl(btnView);
            }
        }

        protected bool AllowEditEditCheckIn(object o)
        {
            string allow_edit_check_in = ((DataRowView)o)["Allow_Edit_Check_In"].ToString();
            return allow_edit_check_in.Equals("1");
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

        private void ShowHideFilterControl()
        {
            string sSelectedType = radSingleMultipleStudent.SelectedValue;
            divSingleStudent.Visible = sSelectedType.Equals(SELECTION_TYPE_SINGLE);
            divMultipleStudent.Visible = sSelectedType.Equals(SELECTION_TYPE_MULTIPLE);
            divSearchClearButton.Visible = false;
            divAdditionalFilters.Visible = false;
            //dgStudentSearch.Visible = false;
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
                divAdditionalFilters.Visible = true;
                txtStudentIds.Focus();
            }
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            if (IsValid)
            {
                //Default Sort
                InitilizeSortPaging();

                LoadStudentSearchDG();

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

        protected void lnkExportToExcel_Click(object sender, EventArgs e)
        {
            Utilities.ExportDataSetToExcel(DsStudentSearch(true), Response, "Student_Asset_History");
        }

        protected void btnEditCheckIn_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string Asset_Student_Transaction_ID = btn.Attributes["Asset_Student_Transaction_ID"];
            string Asset_Site_ID = btn.Attributes["Asset_Site_ID"];
            string Student_ID = btn.Attributes["Student_ID"];
            string Student_Name_ID = btn.Attributes["Student_Name_ID"];
            string Asset_ID = btn.Attributes["Asset_ID"];

            hdnAssetStudentTransactionID.Value = Asset_Student_Transaction_ID;
            hdnAssetSiteID.Value = Asset_Site_ID;
            hdnStudentID.Value = Student_ID;
            hdnStudentNameID.Value = Student_Name_ID;
            hdnAssetID.Value = Asset_ID;

            DisplayEditCheckIn(true);
        }

        protected void ddlDisposition_Check_In_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selected_disposition = "";
            if (ddlDisposition_CheckIn.Visible)
            {
                selected_disposition = ddlDisposition_CheckIn.SelectedValue;
            }
            ShowHideControlForEditCheckIn(ddlCheckInType.SelectedValue, selected_disposition);
        }

        protected void ddlCheckInType_SelectedIndexChanged(object sender, EventArgs e)
        {
            ShowHideControlForEditCheckIn(ddlCheckInType.SelectedValue, "");
        }

        protected void btnAddDeleteAttachment_Click(object sender, EventArgs e)
        {
            DisplayEditCheckIn(false);
        }

        protected void btnSubmitCheckIn_Click(object sender, EventArgs e)
        {
            if (IsValid)
            {
                DisplayConfirmationSaveCheckIn();
            }
            else
            {
                DisplayEditCheckIn(false);
            }
        }

        protected void btnConfirmSave_Click(object sender, EventArgs e)
        {
            if (IsValid)
            {
                SaveCheckIn();
                LoadStudentSearchDG();
                CloseModal("popupEditStudentCheckIn");
                DisplayMessage("Successfully Submitted", "Saved.");
            }
            
        }

        public void DisplayNoFileFound()
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupEditStudentCheckIn').modal();$('#popupNoFileFound').modal();", true);

            lblNoFileTitle.Text = "No File Found.";
            lblNoFileBody.Text = "Please contact <a href='mailto:ProgrammerSupport@monet.k12.ca.us' class='btn btn-default btn-xs'>Programmer Support</a>";
        }

        protected void btnView_Click(object sender, EventArgs e)
        {
            //Open Attachment
            Button btn = (Button)sender;
            string Asset_ID = btn.Attributes["Asset_ID"];
            string FileName = btn.Attributes["Asset_File_Name"];
            string FileType = btn.Attributes["Asset_File_Type"];

            string Folder_Location = Utilities.GetAssetAttachmentFolderLocation();
            string filePath = Folder_Location + "\\" + Asset_ID + "\\" + FileName + "." + FileType;

            if (!Utilities.ViewAnyDocument(filePath, Response))
            {
                DisplayNoFileFound();
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;

            string Attachment_ID = btn.Attributes["Asset_Attachment_ID"];
            string Asset_ID = btn.Attributes["Asset_Attachment_ID"];

            Utilities.DeleteAssetAttachmentByID(Attachment_ID, Asset_ID);

            LoadAttachmentDG();

            DisplayEditCheckIn(false);
        }

        private void InitilizePostAddAttachment()
        {
            //initialize control after add attachment
            ddlAttachmentType.ddlAttachmentType.SelectedIndex = 0;
            txtAttachmentNameEdit.Text = "";
            txtAttachmentDescEdit.Text = "";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ShowDiv", "$('#divAddAttachment').attr('class', 'collapse in');", true);
        }

        protected void btnSaveAttachment_Click(object sender, EventArgs e)
        {
            string fileType = Utilities.GetFileTypeFromUploadControl(FileUploadAttachment);

            bool ValidateAttachment = Utilities.ValidateSaveAttachment("-1", hdnAssetID.Value, txtAttachmentNameEdit.Text, fileType, cvDuplicateFileName, cvUploadFileSize, FileUploadAttachment);

            if (ValidateAttachment && IsValid)
            {
                //Save Attachment
                SaveAttachment();
                LoadAttachmentDG();
                InitilizePostAddAttachment();
                DisplayEditCheckIn(false);
            }
            else
            {
                DisplayAddNewAttachment();
            }
        }

        protected void btnAddAttachment_Click(object sender, EventArgs e)
        {
            DisplayAddNewAttachment();
        }

        protected void btnCloseAddAttachment_Click(object sender, EventArgs e)
        {
            LoadAttachmentDG();
            DisplayEditCheckIn(false);
        }

    }
}