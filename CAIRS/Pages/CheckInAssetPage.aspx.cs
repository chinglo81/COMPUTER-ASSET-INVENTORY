using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Pages
{
	public partial class CheckInAssetPage : _CAIRSBasePage
	{
		private const string SELECT_TAG_ID = "TAGID";

		private const string SELECT_SERIAL_NUMBER = "SERIAL_NUMBER";

		private string Qs_Check_In_Type
		{
			get
			{
				return Request.QueryString["Check_In_Type"];
			}
		}

        private string Qs_Success_Message
        {
            get
            {
                return Request.QueryString["Sucess_Message"];
            }
        }

		private void LoadDisposition_DDL_CheckIn(string business_rule)
		{
			ddlDisposition_CheckIn.IsAssetDispositionRequired = true;
            ddlDisposition_CheckIn.LoadDDLAssetDisposition(business_rule, true, true, false);
		}

        private void LoadCondition_DDL_CheckIn(string business_rule)
		{
			ddlCondition_CheckIn.IsAssetConditionRequired = true;
            ddlCondition_CheckIn.LoadDDLAssetCondition(business_rule, true, true, false);
            
		}

        private void LoadBin_DDL_CheckIn()
        {
            string siteid = ddlSite.SelectedValue;
            ddlBin_CheckIn.IsBinRequired = true;
            ddlBin_CheckIn.LoadDDLBin(siteid, true, true, true, false);
        }
		
		private void LoadSite_DDL()
		{
			ddlSite.AutoPostBack = true;
			ddlSite.IsSiteRequired = true;
			ddlSite.LoadDDLSite(true, false, true, true, false, true, true);
			ddlSite.reqSite.EnableClientScript = false;
		}

		private void LoadCheckInType_DDL()
		{
			DataSet ds = DatabaseUtilities.DsGet_CTByTableName(Constants.TBL_CT_CHECK_IN_TYPE, true);
			int iRowCount = ds.Tables[0].Rows.Count;

			if (iRowCount > 0)
			{
				ddlCheckInType.DataSource = ds;
				ddlCheckInType.DataTextField = Constants.COLUMN_CT_CHECK_IN_TYPE_Name;
				ddlCheckInType.DataValueField = Constants.COLUMN_CT_CHECK_IN_TYPE_ID;
				ddlCheckInType.DataBind();

				ddlCheckInType.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Check-in Type ---", "-98"));

				//Default selected option to standard
				Utilities.DDL_SetValueIfExist(ddlCheckInType, Constants.CHECK_IN_TYPE_CODE_STANDARD);
			}
		}

		private void ShowHideDgAssignmentColumn(int iRowCount)
		{
			foreach (DataGridColumn col in dgAssignment.Columns)
			{
				// Show column
				if (col.HeaderText == "Student")
				{
					col.Visible = iRowCount > 1 && IsCheckInTypeStandard() && radSearchType.SelectedValue.Equals(SELECT_SERIAL_NUMBER);
				}
			}
		}

        private void LoadAssignmentDG()
        {
            string tag_id = txtTagID.Text;
            string serial_number = txtSerialNumber.Text;
            string student_id = Student_Info.lblStudentID.Text;
            string check_in_type = ddlCheckInType.SelectedValue;

            switch (check_in_type)
            {
                case Constants.CHECK_IN_TYPE_CODE_STANDARD:
                case Constants.CHECK_IN_TYPE_CODE_FOUND:
                    if (radSearchType.SelectedValue.Equals(SELECT_TAG_ID) && !isNull(tag_id))
                    {
                        LoadCurrentAssignmentDGBySearch("", "", tag_id, false);
                    }

                    if (radSearchType.SelectedValue.Equals(SELECT_SERIAL_NUMBER) && !isNull(serial_number))
                    {
                        LoadCurrentAssignmentDGBySearch("", serial_number, "", false);
                    }
                    break;
                case Constants.CHECK_IN_TYPE_CODE_UNIDENTIFIED:
                case Constants.CHECK_IN_TYPE_CODE_LOST:
                case Constants.CHECK_IN_TYPE_CODE_STOLEN:
                    if (!isNull(student_id))
                    {
                        LoadCurrentAssignmentDGBySearch(student_id, "", "", false);
                    }
                    break;
            }

        }

        private void LoadAssetInfoForInvalidCheckIn(string tag_id, string serial_number)
        {
            //initilize control
            divAssetInfo.Visible = true;
            lblResults.Text = "";

            //default search by tag id
            DataSet dsAssetInfo = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_MASTER_LIST, Constants.COLUMN_V_ASSET_MASTER_LIST_Tag_ID, tag_id, "");
            if (!isNull(serial_number))
            {
                //search by serial
                dsAssetInfo = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_MASTER_LIST, Constants.COLUMN_V_ASSET_MASTER_LIST_Serial_Number, serial_number, "");
            }

            string msg_alert = "";

            if (dsAssetInfo.Tables[0].Rows.Count > 0)
            {
                divAssetInfoImportantMessage.Visible = true;
                btnProcesssFound.Visible = false;
                tblAssetInfo.Visible = true;
                msg_alert = "Please keep asset. This asset was not assigned to a student.";
                Utilities.DataBindForm(tblAssetInfo, dsAssetInfo);

                string disposition = dsAssetInfo.Tables[0].Rows[0]["Asset_Disposition_ID"].ToString();
                string disposition_desc = dsAssetInfo.Tables[0].Rows[0]["Asset_Disposition_Desc"].ToString();
                string asset_transaction_id = dsAssetInfo.Tables[0].Rows[0]["Asset_Student_Transaction_ID"].ToString();

                //Disposition is Lost or stolen and was previously assigned to a student
                if ((disposition.Equals(Constants.DISP_LOST) || disposition.Equals(Constants.DISP_STOLEN)) && !isNull(asset_transaction_id))
                {
                    hdnAssetStudentTransactionID.Value = asset_transaction_id;

                    if (!ddlCheckInType.SelectedValue.Equals(Constants.CHECK_IN_TYPE_CODE_FOUND))
                    {
                        string caption = "Please Note";
                        string msg = "The Check-in Type has been switched from " + ddlCheckInType.SelectedItem.Text + " to \"Found\". This asset was previously marked as \"" + disposition_desc + "\".";

                        DisplayMessage(caption, msg);
                        ddlCheckInType.SelectedValue = Constants.CHECK_IN_TYPE_CODE_FOUND;
                    }

                    divAssetInfoImportantMessage.Visible = false;
                    btnProcesssFound.Visible = true;
                }
            }
            else
            {
                tblAssetInfo.Visible = false;
                msg_alert = "Please keep asset. The Tag ID (" + tag_id + ") you entered does not exist in the database. ";
                if (!isNull(serial_number))
                {
                    msg_alert = "Please keep asset. The Serial # (" + serial_number + ") you entered does not exist in the database.";
                }
            }

            lblAssetInfoAlertMessage.Text = msg_alert;
        }

		private void LoadCurrentAssignmentDGBySearch(string studentid, string serialNumber, string tag_id, bool displaySuccessMessage)
		{
            //Search by tag id or Serial
            if (!Utilities.isNull(tag_id) || !Utilities.isNull(serialNumber))
            {
                DataSet dsCheckTag = DatabaseUtilities.DsGetCheckOutAssignment("", serialNumber, tag_id);
                
                //Only load student info if one records is return. You can potential return multiple records when searching by serial number.
                if (dsCheckTag.Tables[0].Rows.Count.Equals(1))
                {
                    //reload the same method by now use student id. This will allow the grid to populate all the currently check out asset to the given student
                    string stuid = dsCheckTag.Tables[0].Rows[0]["Student_ID"].ToString();
                    //Load same method using student id search
                    LoadCurrentAssignmentDGBySearch(stuid, "", "", displaySuccessMessage);
                    return;
                }
            }

			//only apply when searching by student or serial number
            //Will only display assets that are "Checkedout"
			DataSet ds = DatabaseUtilities.DsGetCheckOutAssignment(studentid, serialNumber, tag_id);
			divCurrentlyAssigned.Visible = false;
			dgAssignment.Visible = false;
			lblResults.Text = "No asset assignments found.";
			lblSuccessfullySubmitted.Visible = displaySuccessMessage;
            divStudentInfo.Visible = false;
            divAssetInfo.Visible = false;

			int iRowCount = ds.Tables[0].Rows.Count;

			if (iRowCount > 0)
			{
				lblResults.Text = "";
				divCurrentlyAssigned.Visible = true;
				dgAssignment.Visible = true;
				dgAssignment.DataSource = ds;
				dgAssignment.DataBind();

				//Load Student Info if the records only return 1 record or the search was for a specific studentid
                if (iRowCount.Equals(1) || !Utilities.isNull(studentid))
				{
					string stu_id = ds.Tables[0].Rows[0]["Student_ID"].ToString();
					if (!isNull(stu_id))
					{
						LoadStudentInfo(stu_id);
					}
                }
                else
                {
                    Student_Info.Visible = false;
                }

				ShowHideDgAssignmentColumn(iRowCount);

            }
            else
            {
                //only perform this search for tag_id or serial_number
                if (isNull(studentid))
                {
                    LoadAssetInfoForInvalidCheckIn(tag_id, serialNumber);
                }
                else
                {
                    LoadStudentInfo(studentid);
                }
            }
		}

		private void LoadStudentInfo(string studentid)
		{
			divStudentInfo.Visible = false;
			btnSearchTagID.Visible = false;
			txtTagID.Visible = false;
            txtSerialNumber.Visible = false;
			divCurrentlyAssigned.Visible = false;
			hdnStudentID.Value = "";
            Student_Info.Visible = false;

			if (!isNull(studentid))
			{
				hdnStudentID.Value = studentid;
				txtTagID.Visible = true;
				divStudentInfo.Visible = true;
				btnSearchTagID.Visible = true;
				divCurrentlyAssigned.Visible = true;
                Student_Info.Visible = true;

				txtTagID.txtTagID.Focus();
				Student_Info.LoadStudentInfo(studentid);
			}
		}
		
		private void LoadResearchAsset(string asset_id)
		{
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_INFO_CHECKIN, "Asset_ID", asset_id, "");
            Utilities.DataBindForm(divAssetStoredSite, ds);

			//initialize control
            divAssetStoredSite.Visible = false;
			lblAsset_Stored_Site.Text = "";
			lblAsset_Stored_Site.Attributes["Asset_Stored_Site_ID"] = "";

			//need to load the stored site location. It may be different than the asset site location
			if (ds.Tables[0].Rows.Count > 0)
			{
				//Site match
				string asset_site = ds.Tables[0].Rows[0]["Asset_Site_ID"].ToString();
                string asset_site_desc = ds.Tables[0].Rows[0]["Asset_Site_Desc"].ToString();
                bool IsSiteMatch = asset_site.Equals(ddlSite.SelectedValue);
				if (!IsSiteMatch)
				{
                    string note = "<br/><span class='text-warning'>Note: the site asset (" + asset_site_desc + ") does not match the check-in site. A storage location will be created for this asset at </span>";
                    divAssetStoredSite.Visible = true;
					lblAsset_Stored_Site.Text = note + ddlSite.SelectedText;
					lblAsset_Stored_Site.Attributes["Asset_Stored_Site_ID"] = ddlSite.SelectedValue;
				}
			}
		}

		private void LoadControlsForCheckIn(string asset_id)
		{
            Initialize_Controls_CheckIn_Modal();
            bool is_flag_research = bool.Parse(hdnIsFlagForResearch.Value);
            
            string check_in_type = ddlCheckInType.SelectedValue;
            string title = "";
            string disposition_business_rule = "";
            string condition_business_rule = "";

            switch (check_in_type)
            {
                case Constants.CHECK_IN_TYPE_CODE_STANDARD:
                    divBin_CheckIn.Visible = true;

                    title = "Standard Check-in";
                    disposition_business_rule = Constants.BUSINESS_RULE_DISPOSITION_CHECK_IN_STANDARD;
                    condition_business_rule = Constants.BUSINESS_RULE_CONDITION_AVAILABLE_CHECK_IN_STANDARD;

                    if (is_flag_research)
                    {
                        disposition_business_rule = Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_RESEARCH;

                        divAssetStoredSite.Visible = true;
                        LoadResearchAsset(asset_id);
                    }

                    break;
                case Constants.CHECK_IN_TYPE_CODE_FOUND:
                    
                    divBin_CheckIn.Visible = true;

                    title = "Found Check-in";
                    disposition_business_rule = Constants.BUSINESS_RULE_DISPOSITION_CHECK_IN_FOUND;
                    condition_business_rule = Constants.BUSINESS_RULE_CONDITION_AVAILABLE_CHECK_IN_FOUND;

                    if (is_flag_research)
                    {
                        disposition_business_rule = Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_RESEARCH;

                        divAssetStoredSite.Visible = true;
                        LoadResearchAsset(asset_id);
                    }
                    break;
                case Constants.CHECK_IN_TYPE_CODE_UNIDENTIFIED:
                    divImportantAffixSticker.Visible = true;
                    divBin_CheckIn.Visible = true;

                    title = "Unidentified Check-in";
                    disposition_business_rule = Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_CHECK_IN_UNIDENTIFIED;
                    condition_business_rule = Constants.BUSINESS_RULE_CONDITION_AVAILABLE_CHECK_IN_UNIDENTIFIED;

                    ddlCondition_CheckIn.ddlAssetCondition.Focus();
                    break;
                case Constants.CHECK_IN_TYPE_CODE_LOST:
                    title = "Lost Check-in";
                    disposition_business_rule = Constants.BUSINESS_RULE_DISPOSITION_CHECK_IN_LOST;
                    //condition_business_rule - does not exist for lost 

                    txtComments_CheckIn.Focus();
                    break;
                case Constants.CHECK_IN_TYPE_CODE_STOLEN:
                    divPoliceReport.Visible = true;
                    
                    title = "Stolen Check-in";
                    disposition_business_rule = Constants.BUSINESS_RULE_DISPOSITION_CHECK_IN_STOLEN;
                    //condition_business_rule - does not exist for stolen 
                    
                    txtComments_CheckIn.Focus();
                    
                    break;
            }

            hdnConditionBusinessRule.Value = condition_business_rule;

            lblModalCheckInTitle.Text = title;

            LoadDisposition_DDL_CheckIn(disposition_business_rule);
            ChangeDisposition();
			LoadBin_DDL_CheckIn();

            uc_AddAttachment_CheckIn.GetSetAssetID = asset_id;
            
		}
        
        private void LoadControlByCheckInType()
        {
            string student_id = Student_Info.lblStudentID.Text;

            Initialize_Controls();

            string check_in_type = ddlCheckInType.SelectedValue;
            switch (check_in_type)
            {
                case Constants.CHECK_IN_TYPE_CODE_UNIDENTIFIED:
                case Constants.CHECK_IN_TYPE_CODE_LOST:
                case Constants.CHECK_IN_TYPE_CODE_STOLEN:
                    divStudentLookup.Visible = true;

                    if (!isNull(student_id))
                    {
                        divStudentInfo.Visible = true;
                        txtStudentLookup.Visible = false;
                        Student_Info.LoadStudentInfo(student_id);
                        LoadAssignmentDG();
                    }
                    else
                    {
                        txtStudentLookup.Visible = true;
                        txtStudentLookup.txtStudentLookup.Focus();
                    }
                    
                    break;

                case Constants.CHECK_IN_TYPE_CODE_STANDARD:
                case Constants.CHECK_IN_TYPE_CODE_FOUND:
                    divSearchBy.Visible = true;
                    LoadControlByRadioSearchType();
                    break;
            }

            //updatePanelStudentInfo.Update();
        }

        private void LoadControlByRadioSearchType()
        {
            //Only apply if check in is standard
            //if (IsCheckInTypeStandard())
            //{ 
                Initialize_Controls();
                string selectedSearchType = radSearchType.SelectedValue;
                
                switch (selectedSearchType)
                {
                    case SELECT_TAG_ID:
                        divSearchBy.Visible = true;
                        divTagId.Visible = true;
                        txtTagID.txtTagID.Focus();
                        break;
                    case SELECT_SERIAL_NUMBER:
                        divSearchBy.Visible = true;
                        divSerialNumber.Visible = true;
                        txtSerialNumber.txtSerialNumber.Focus();
                        break;
                    default:
                        //This should not happen
                        break;
                }
            //}
               // updatePanelStudentInfo.Update();
        }

        private void Initialize_Controls_CheckIn_Modal()
        {
            divImportantAffixSticker.Visible = false;
            divAssetStoredSite.Visible = false;
            divPoliceReport.Visible = false;
            divAssetCondition_CheckIn.Visible = false;
            divBin_CheckIn.Visible = false;

            txtComments_CheckIn.Text = "";
            hdnConditionBusinessRule.Value = "";

            uc_AddAttachment_CheckIn.ClearAttachments();

        }

		private void Initialize_Controls()
		{
			//initilize
			//divAssetInfo.Visible = false;
            
			divCurrentlyAssigned.Visible = false;
			divStudentInfo.Visible = false;
			
			divSerialNumber.Visible = false;
			divStudentLookup.Visible = false;
			divTagId.Visible = false;
			divSearchBy.Visible = false;
			divWarningMsg.Visible = false;
            divAssetInfo.Visible = false;

			lblWarningMsg.Text = "";
			txtSerialNumber.Text = "";
			txtStudentLookup.ClearSelection();
			txtTagID.Text = "";
            Student_Info.lblStudentID.Text = "";
		}

		private void DisplayCheckIn(string asset_id, bool isReload)
		{
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupCheckIn').modal();", true);
			if (isReload)
			{
                LoadControlsForCheckIn(asset_id);
                updatePanelCheckInModal.Update();
			}
		}

        private void SaveCheckIn()
        {
            string p_Asset_Student_Transaction_ID = hdnAssetStudentTransactionID.Value;
	        string p_Check_In_Type_Code = ddlCheckInType.SelectedValue;
	        string p_Disposition_ID = ddlDisposition_CheckIn.SelectedValue;
	        string p_Check_In_Condition_ID = Constants.MCSDBNOPARAM;
            string p_Police_Report_Provided = Constants.MCSDBNOPARAM;
            string p_Bin_ID = Constants.MCSDBNOPARAM;
	        string p_Comments = txtComments_CheckIn.Text;
            string p_Attachments = uc_AddAttachment_CheckIn.GetAttachmentXML();
            string p_Stu_Responsible_For_Damage = "0";
            string p_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
            string p_Date = DateTime.Now.ToString();

            if (divAssetCondition_CheckIn.Visible)
            {
                p_Check_In_Condition_ID = ddlCondition_CheckIn.SelectedValue;
            }

            if (p_Check_In_Type_Code.Equals(Constants.CHECK_IN_TYPE_CODE_STOLEN) && chkPoliceReport.Checked)
            {
                p_Police_Report_Provided = "1";
            }

            if (divBin_CheckIn.Visible)
            {
                p_Bin_ID = ddlBin_CheckIn.SelectedValue;
            }

            //If disposition is broken. Student will be responsible for the damage.
            if (p_Disposition_ID.Equals(Constants.DISP_BROKEN))
            {
                p_Stu_Responsible_For_Damage = "1";
            }
            
            //Upoload files to server
            uc_AddAttachment_CheckIn.UploadFileFromGridToServer();

            //Remove Asset from Temp location
            string asset_id = uc_AddAttachment_CheckIn.GetSetAssetID;
            if (!isNull(asset_id))
            {
                Utilities.RemoveAssetTempFolderByID(asset_id);
            }

            //Save Checkin
            DatabaseUtilities.StudentCheckIn(
                p_Asset_Student_Transaction_ID,
                p_Check_In_Type_Code,
                p_Disposition_ID,
                p_Police_Report_Provided,
                p_Check_In_Condition_ID,
                p_Bin_ID,
                p_Comments,
                p_Attachments,
                p_Stu_Responsible_For_Damage,
                p_Emp_ID,
                p_Date
            );
        }

		private void LoadQueryParam()
		{
			//Check In Type
			if (!isNull(Qs_Check_In_Type))
			{
				ListItem iCheckInType = ddlCheckInType.Items.FindByValue(Qs_Check_In_Type);
				if (ddlCheckInType.Items.Contains(iCheckInType))
				{
					ddlCheckInType.SelectedValue = Qs_Check_In_Type;
					txtStudentLookup.SetFocusOnTextBox = true;
				}    
			}

            //Success Message
            lblSuccessfullySubmitted.Visible = !isNull(QS_SUCCESS);
		}

		private void ShowHideChangeStudentBTN()
		{
            string check_in_type = ddlCheckInType.SelectedValue;
            switch (check_in_type)
            {
                case Constants.CHECK_IN_TYPE_CODE_UNIDENTIFIED:
                case Constants.CHECK_IN_TYPE_CODE_LOST:
                case Constants.CHECK_IN_TYPE_CODE_STOLEN:
                    Student_Info.showChangeStudentBtn = true;
                    break;
                default:
                    Student_Info.showChangeStudentBtn = false;
                    break;
            }
		}

        private void ChangeDisposition()
        {
            //Display Condition when Disposition:
            string selected_disposition = ddlDisposition_CheckIn.SelectedValue;
            bool isDisplayCondition = selected_disposition.Equals(Constants.DISP_AVAILABLE) || selected_disposition.Equals(Constants.DISP_BROKEN) || selected_disposition.Equals(Constants.DISP_UNIDENTIFIED);

            divAssetCondition_CheckIn.Visible = isDisplayCondition;

            if (selected_disposition.Equals(Constants.DISP_BROKEN))
            {
                LoadCondition_DDL_CheckIn(Constants.BUSINESS_RULE_CONDITION_AVAILABLE_CHECK_IN_DISP_BROKEN);
            }
            else
            {
                LoadCondition_DDL_CheckIn(hdnConditionBusinessRule.Value);
            }

            updatePanelCheckInModal.Update();
        }

		private bool IsDisplayStudentLookUp()
		{
			string Selected_Check_In_Type = ddlCheckInType.SelectedValue;
			if (
				Selected_Check_In_Type.Equals(Constants.CHECK_IN_TYPE_CODE_LOST) ||
				Selected_Check_In_Type.Equals(Constants.CHECK_IN_TYPE_CODE_STOLEN) ||
				Selected_Check_In_Type.Equals(Constants.CHECK_IN_TYPE_CODE_UNIDENTIFIED)
			)
			{
				return true;
			}
			return false;
		}

		private bool IsAllowCheckin(string disAllowCheckin)
		{
			return disAllowCheckin.Equals("1");
		}

		private bool IsSiteMatch(string assetSiteId)
		{
			return assetSiteId.Equals(ddlSite.SelectedValue);
		}

		private bool ValidateCheckIn(string check_In_Site_ID, string asset_Site_ID)
		{
            bool IsValid = true;
            string check_in_type = ddlCheckInType.SelectedValue;
            bool IsSiteMatch = check_In_Site_ID.Equals(asset_Site_ID);

            //Research 
            //When the check in type is standard and the processing site does not match the site asset.
            bool IsResearch = check_in_type.Equals(Constants.CHECK_IN_TYPE_CODE_STANDARD) && !IsSiteMatch;


            //Check for site mismatch on processing site and site asset.
                //Only when check in type is not equal to found
                //Not equal to research
            if (!check_in_type.Equals(Constants.CHECK_IN_TYPE_CODE_FOUND) && !IsResearch && !IsSiteMatch)
            {
                string check_in_site_desc = Utilities.GetSiteNameByID(check_In_Site_ID);
                if (!isNull(check_in_site_desc))
                {
                    check_in_site_desc = "(" + check_in_site_desc + ") ";
                }
                string asset_site_desc = Utilities.GetSiteNameByID(asset_Site_ID);
                string errMsg = "Site Mismatch. The check-in site " + check_in_site_desc + "and the asset site (" + asset_site_desc + ") does not match.";

                cvCheckInValidator.IsValid = false;
                cvCheckInValidator.Text = errMsg;
                cvCheckInValidator.ErrorMessage = errMsg;

                IsValid = false;
            }

            return IsValid;
		}

		private bool IsCheckInTypeStandard()
		{
			return ddlCheckInType.SelectedValue.Equals(Constants.CHECK_IN_TYPE_CODE_STANDARD);
		}

        private bool IsCheckInTypeLost()
        {
            return ddlCheckInType.SelectedValue.Equals(Constants.CHECK_IN_TYPE_CODE_LOST);
        }

        private bool IsCheckInTypeStolen()
        {
            return ddlCheckInType.SelectedValue.Equals(Constants.CHECK_IN_TYPE_CODE_STOLEN);
        }

        private bool IsCheckInTypeFound()
        {
            return ddlCheckInType.SelectedValue.Equals(Constants.CHECK_IN_TYPE_CODE_FOUND);
        }

		private bool IsCheckInTypeUnidentified()
		{
			return ddlCheckInType.SelectedValue.Equals(Constants.CHECK_IN_TYPE_CODE_UNIDENTIFIED);
		}

        private bool IsTagOrSeralMatch(string tag_id, string serial_number)
        {
            return txtTagID.Text.Equals(tag_id) || txtSerialNumber.Text.Equals(serial_number);
        }

		protected new void Page_Load(object sender, EventArgs e)
		{
			string selectedStudent = txtStudentLookup.SelectedStudentID;
			string selectedSearchType = radSearchType.SelectedValue;
			txtStudentLookup.Visible = true;
			if (!isNull(selectedStudent))
			{
				LoadStudentInfo(selectedStudent);
                LoadAssignmentDG();
				txtStudentLookup.Visible = false;
			}

            if (!IsPostBack)
            {
                LoadSite_DDL();
                LoadCheckInType_DDL();
                LoadQueryParam();
                LoadControlByCheckInType();

                divWarningMsg.Visible = false;
            }
            else 
            { 
                lblSuccessfullySubmitted.Visible = false; 
            }
			
			ShowHideChangeStudentBTN();

			//this needs to load on every Postback to function correctly.
			txtStudentLookup.btnSearchStudentClick += btnStudentSearch_Click;
			txtStudentLookup.btnChangeStudentClick += btnLookupStudent_Click;
			ddlSite.SelectedIndexChanged_DDL_Site += OnSelectedSiteChange;
			uc_AddAttachment_CheckIn.AddAttachment_Click += btnAddAttachmentUnidentified_Click;
            uc_AddAttachment_CheckIn.Delete_Click += btnAddAttachmentUnidentified_Click;
			Student_Info.OnClickChangeStudent_Btn += btnChangeStudent_Click;
            ddlDisposition_CheckIn.SelectedIndexChanged_DDL_AssetDisposition += OnSelectedDispositionChange;
		}

		protected string GetCheckInText(object o)
		{
			if (radSearchType.SelectedValue.Equals(SELECT_SERIAL_NUMBER))
			{
				return "Select";
			}
			return "Check-In";
		}

		protected void OnSelectedSiteChange(object sender, EventArgs e)
		{
            LoadAssignmentDG();
		}

        protected void OnSelectedDispositionChange(object sender, EventArgs e)
        {
            ChangeDisposition();
        }

		protected void ddlCheckInType_SelectedIndexChanged(object sender, EventArgs e)
		{
            LoadControlByCheckInType();
		}

		protected void dgAssignment_ItemDataBound(object sender, DataGridItemEventArgs e)
		{
            Button btn_checkin = e.Item.FindControl("btnCheckin") as Button;

            if (btn_checkin != null)
            {
                btn_checkin.Visible = false;
                
                string tag_id = btn_checkin.Attributes["Tag_ID"].Trim().ToUpper();
                string serial_number = btn_checkin.Attributes["Serial_Number"].Trim().ToUpper();
                string asset_site_id = btn_checkin.Attributes["Asset_Site_ID"];
                string btn_text = "";
                string check_in_type = ddlCheckInType.SelectedItem.Text;

                if (!check_in_type.Contains("-"))
                {
                    btn_text = check_in_type;
                    btn_checkin.Text = btn_text;
                    btn_checkin.Visible = true;

                    if (divSearchBy.Visible)
                    {
                        string form_tagid = txtTagID.Text.Trim().ToUpper();
                        string form_serial_number = txtSerialNumber.Text.Trim().ToUpper();

                        if (radSearchType.SelectedValue.Equals(SELECT_TAG_ID))
                        {
                            btn_checkin.Visible = form_tagid.Equals(tag_id);
                        }

                        if (radSearchType.SelectedValue.Equals(SELECT_SERIAL_NUMBER))
                        {
                            btn_checkin.Visible = form_serial_number.Equals(serial_number);
                        }
                    }
                }
            }
        }

		protected void btnChangeStudent_Click(object sender, EventArgs e)
		{
			string qs_check_in_type = "?Check_In_Type=" + ddlCheckInType.SelectedValue;

			NavigateTo(Constants.PAGES_CHECK_IN_ASSET_PAGE + qs_check_in_type, false);
		}

		protected void btnStudentSearch_Click(object sender, EventArgs e)
		{
			string selectedStudent = txtStudentLookup.SelectedStudentID;
			if (!isNull(selectedStudent))
			{
				LoadStudentInfo(selectedStudent);
				txtStudentLookup.Visible = false;
                LoadAssignmentDG();
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

		protected void radSearchType_SelectedIndexChanged(object sender, EventArgs e)
		{
            LoadControlByRadioSearchType();
		}

		protected void btnSearchTagID_Click(object sender, EventArgs e)
		{
			if (Page.IsValid)
			{
                LoadAssignmentDG();
			}
            Utilities.SelectTextBox(txtTagID.txtTagID);
			txtTagID.txtTagID.Focus();
		}

		protected void btnSerialNumberSearch_Click(object sender, EventArgs e)
		{
			if (Page.IsValid)
			{
                LoadAssignmentDG();
			}
			Utilities.SelectTextBox(txtSerialNumber.txtSerialNumber);
			txtSerialNumber.txtSerialNumber.Focus();
		}

		protected void btnConfirmCheckin_Click(object sender, EventArgs e)
		{

		}

		protected void btnOkCancelOutOfChanges_Click(object sender, EventArgs e)
		{
			string sIsChangeSite = hdnIsChangeSite.Value;
			bool isChangeSite = true;

			if (!isNull(sIsChangeSite))
			{
				isChangeSite = bool.Parse(sIsChangeSite);
			}

			if (isChangeSite)
			{
				NavigateTo(Constants.PAGES_CHECK_IN_ASSET_PAGE, false);
			}
			else
			{

			}
		}

		protected void btnAddAttachmentUnidentified_Click(object sender, EventArgs e)
		{
			DisplayCheckIn("", false);
		}

		protected void btnCheckInAsset_Click(object sender, EventArgs e)
		{
			Button btn = (Button)sender;

            string asset_id = btn.Attributes["Asset_ID"];
            string asset_student_transaction_id = btn.Attributes["Asset_Student_Transaction_ID"];
			string assetSiteID = btn.Attributes["Asset_Site_ID"];
			string checkInSiteID = ddlSite.SelectedValue;
			string tagId = btn.Attributes["Tag_ID"];

            bool flagResearch = (IsCheckInTypeStandard() || IsCheckInTypeFound()) && !assetSiteID.Equals(ddlSite.SelectedValue);

            hdnIsFlagForResearch.Value = flagResearch.ToString();
			
                //Set hidden value
            hdnAssetStudentTransactionID.Value = asset_student_transaction_id;
			hdnTagId.Value = tagId;

			if (ValidateCheckIn(checkInSiteID, assetSiteID) && IsValid)
			{
                DisplayCheckIn(asset_id, true);
			}
			else
			{
				DisplayErrorModal("vgCheckin");
			}
		}

		protected void btnSubmitCheckIn_Click(object sender, EventArgs e)
		{
			if (IsValid)
			{
                SaveCheckIn();

                string qs_checkintype = "?Check_In_Type=" + ddlCheckInType.SelectedValue;
                string qs_success = "&Success=true";
                NavigateTo(Constants.PAGES_CHECK_IN_ASSET_PAGE + qs_checkintype + qs_success, false);
			}
			else
			{
                DisplayCheckIn("", false);
			}
		}

        protected void btnProcesssFound_Click(object sender, EventArgs e)
        {
            string assetSiteID = hdnAssetInfo_Asset_Site_ID.Value;
            string checkInSiteID = ddlSite.SelectedValue;
            string asset_id = hdnAssetInfo_Asset_ID.Value;
            bool flagResearch = (IsCheckInTypeStandard() || IsCheckInTypeFound()) && !assetSiteID.Equals(ddlSite.SelectedValue);

            hdnIsFlagForResearch.Value = flagResearch.ToString();

            DisplayCheckIn(asset_id, true);
        }
	}
}