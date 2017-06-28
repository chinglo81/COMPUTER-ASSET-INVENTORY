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
	public partial class CheckOutAssetPage : _CAIRSBasePage
	{
		private void LoadCurrentAssignmentDG(string studentid)
		{
			DataSet ds = DatabaseUtilities.DsGetCheckOutAssignment(studentid, "", "");

			dgAssignment.Visible = false;
			lblResults.Text = "No asset(s) assignment found for this student.";
			if (ds.Tables[0].Rows.Count > 0)
			{
				lblResults.Text = "";
				dgAssignment.Visible = true;
				dgAssignment.DataSource = ds;
				dgAssignment.DataBind();
			}
		}

        private DataSet dsPendingAssignment()
        {
            DataSet ds = null;
            string list_tag_ids = hdnPendingTagIds.Value;
            if (!isNull(list_tag_ids))
            {
                ds = DatabaseUtilities.DsGetPendingAssignmentForCheckOut(list_tag_ids);
            }
            return ds;
        }

		private void LoadPendingAssignment()
		{
            lblResultsPendingAssignment.Text = "No pending asset(s) assignment";
            dgPendingAssignment.Visible = false;
            btnSubmitPendingAssignment.Visible = false;

            string list_tag_ids = hdnPendingTagIds.Value;

            DataSet ds = dsPendingAssignment();
            if (ds != null)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    dgPendingAssignment.Visible = true;
                    lblResultsPendingAssignment.Text = "";
                    dgPendingAssignment.DataSource = ds;
                    dgPendingAssignment.DataBind();

                    btnSubmitPendingAssignment.Visible = true;
                }
            }
		}

        private void SubmitPendingAssignments()
        {
            string student_id = txtStudentLookup.SelectedStudentID;
            string empid = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
            string dateNow = DateTime.Now.ToString();

            DataSet ds = dsPendingAssignment();

            if (ds != null)
            {
                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    string tagid = row["Tag_ID"].ToString();
                    DatabaseUtilities.StudentCheckOut(student_id, tagid, empid, dateNow);
                }
            }
        }

		private bool ValidateCheckOutAsset()
		{
			bool IsValid = true;
			string errorMsg = "";
			string separator = "<br>";
            string new_tag_list = "";
            string student_id = txtStudentLookup.SelectedStudentID;
            string single_tag = txtTagID.Text;
            string tag_list = hdnPendingTagIds.Value;
            string serial_number = hdnSerialNumber.Value;

            if (txtSerialNumber.txtSerialNumber.Visible)
            {
                hdnSerialNumber.Value = txtSerialNumber.Text;
            }

            //Check to see if that tag was already added
            if (tag_list.Contains(single_tag))
            {
                IsValid = false;
                errorMsg += "Tag ID: " + single_tag + " has already been added to this student." + separator;
            }
            else
            {
                new_tag_list = tag_list + single_tag + ',';

                //Database check
                DataSet ds = DatabaseUtilities.DsValidateCheckOutAsset(new_tag_list, hdnSerialNumber.Value, student_id);
                if (ds.Tables[0].Rows.Count > 0)
                {
                    IsValid = false;
                    foreach (DataRow r in ds.Tables[0].Rows)
                    {
                        errorMsg += r["Error"].ToString() + separator;
                    }
                }
            }

            if (errorMsg.Length > 0)
            {
                errorMsg = errorMsg.Substring(0, errorMsg.Length - separator.Length);
            }
            
            //Check to see if the maximum availability has been reached
			if (!IsValid)
			{
				cvCheckOutAsset.IsValid = false;
				cvCheckOutAsset.ErrorMessage = errorMsg;
				cvCheckOutAsset.Text = errorMsg;
				//divAssetInfo.Visible = false;

            }
            else
            {
                hdnPendingTagIds.Value = new_tag_list;
            }

			return IsValid;
		}

		private void loadStudentInfo()
		{
			lblSuccessMessage.Visible = false;
			divStudentInfo.Visible = false;
			divCheckOutSection.Visible = false;
			btnSearchAsset.Visible = false;
			txtTagID.Visible = false;

			string selected_studentid = txtStudentLookup.SelectedStudentID;
			
			if (!isNull(selected_studentid))
			{
				txtTagID.Visible = true;
				txtStudentLookup.Visible = false;
				divStudentInfo.Visible = true;
				btnSearchAsset.Visible = true;
				divCheckOutSection.Visible = true;
				
				txtTagID.txtTagID.Focus();
				Student_Info.LoadStudentInfo(selected_studentid);

				LoadCurrentAssignmentDG(selected_studentid);
                LoadPendingAssignment();
			}
		}

		private void LoadPrevDetailByID(string id)
		{
			DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_STUDENT_ASSIGNMENT, "ID", id, "");
			Utilities.DataBindForm(divStudentTransactionDetails, ds);
		}

		private void DisplayPreviousAssignmentDetails(string id)
		{
			lblModalTitle.Text = "Assignment Details";
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupViewDetailsStudentTransaction').modal();", true);
			LoadPrevDetailByID(id);
		}

		private void DisplayConfirmation()
		{
            string caption = "Not Submitted";
            string message = "The Pending Assignments were not submitted. Click \"Cancel\" to go back and submit checkout. Click \"Continue\" performing another checkout.";
			
            confirmTitle.Text = caption;
			confirmBody.Text = message;
			
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "confirmPopup", "$('#confirmPopup').modal();", true);
		}

		private void ApplySecurityToControl()
		{
			//None
		}

		protected new void Page_Load(object sender, EventArgs e)
		{
			loadStudentInfo();

			if (!IsPostBack)
			{
                //initilize pending assignment value
                hdnPendingTagIds.Value = "";

                //set focus to student control
				txtStudentLookup.SetFocusOnTextBox = true;

				//Display Success Message
				lblSuccessMessage.Visible = !isNull(QS_SUCCESS);
                
                //hide serial number
                txtSerialNumber.Visible = false;

				//Apply Security
				ApplySecurityToControl();
			}

			//this needs to load on every Postback to function correctly.
			txtStudentLookup.btnSearchStudentClick += btnStudentSearch_Click;
			txtStudentLookup.btnChangeStudentClick += btnLookupStudent_Click;
			Student_Info.OnClickChangeStudent_Btn += OnChangeStudent;

		}

		protected void OnChangeStudent(object o, EventArgs e)
		{
            if (dgPendingAssignment.Visible)
            {
                DisplayConfirmation();
            }
            else
            {
                NavigateTo(Constants.PAGES_CHECK_OUT_ASSET_PAGE, false);
            }
		}

		protected void lnkChangeStudent_Click(object sender, EventArgs e)
		{
			//NavigateTo(Constants.PAGES_CHECK_OUT_ASSET_PAGE, false);
		}

		protected void btnStudentSearch_Click(object sender, EventArgs e)
		{
			lblSuccessMessage.Visible = false;
			if (IsValid)
			{
				txtTagID.Text = "";
				txtTagID.txtTagID.Focus();
				loadStudentInfo();
			}
		}

		protected void btnLookupStudent_Click(object sender, EventArgs e)
		{
			if (dgPendingAssignment.Visible)
			{
				DisplayConfirmation();
			}
			else
			{
				NavigateTo(Constants.PAGES_CHECK_OUT_ASSET_PAGE, false);
			}
		}

		protected void btnSearchAsset_Click(object sender, EventArgs e)
		{
            string student_id = txtStudentLookup.SelectedStudentID;
            string tagid = txtTagID.Text;
            string serial_number = txtSerialNumber.Text;

            if (!isNull(tagid))
            {
                //Check to see if serial is required
                if (!txtSerialNumber.Visible)
                {
                    //Check to see if the base type is laptop
                    DataSet ds = DatabaseUtilities.DsGetAssetInfoByTagID(tagid);
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        string asset_base_type = ds.Tables[0].Rows[0][Constants.COLUMN_V_ASSET_MASTER_LIST_Asset_Base_Type_ID].ToString();

                        if (asset_base_type.Equals(Constants.CT_ASSET_BASE_TYPE_ID_Laptop))
                        {
                            txtSerialNumber.Text = "";
                            txtSerialNumber.Visible = true;
                            txtSerialNumber.txtSerialNumber.Focus();
                            return;
                        }
                    }
                }

                if (ValidateCheckOutAsset() && Page.IsValid)
                {
                    LoadPendingAssignment();
                    
                    txtSerialNumber.Text = "";
                    txtSerialNumber.Visible = false;
                }

            }

            Utilities.SelectTextBox(txtTagID.txtTagID);
            txtTagID.txtTagID.Focus();
           
		}

		protected void btnOkCancelOutOfChanges_Click(object sender, EventArgs e)
		{
			string sIsChangeStudent = hdnIsChangeStudent.Value;
			bool isChangeStudent = true;

			if (!isNull(sIsChangeStudent))
			{
				isChangeStudent = bool.Parse(sIsChangeStudent);
			}

			if (isChangeStudent)
			{
				NavigateTo(Constants.PAGES_CHECK_OUT_ASSET_PAGE, false);
			}
			else
			{
				if (Page.IsValid)
				{
					string tagid = txtTagID.Text;
					string student_id = txtStudentLookup.SelectedStudentID;
					if (ValidateCheckOutAsset() && Page.IsValid)
					{
						//LoadAssetInfo();
					}
					Utilities.SelectTextBox(txtTagID.txtTagID);
					txtTagID.txtTagID.Focus();
				}
			}
		}
        
        protected void btnRemovePendingAsset_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string tag = btn.Attributes["Tag_ID"];

            hdnPendingTagIds.Value = hdnPendingTagIds.Value.Replace(tag, "");
            LoadPendingAssignment();

        }

        protected void btnSubmitPendingAssignment_Click(object sender, EventArgs e)
        {
            SubmitPendingAssignments();
            NavigateTo(Constants.PAGES_CHECK_OUT_ASSET_PAGE + "?Success=true", false);
        }
	}
}