using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.IO;

namespace CAIRS.Controls
{
    public partial class TAB_Attachment : System.Web.UI.UserControl
    {
        public string GetSetStudentID
        {
            get
            {
                return hdnStudentID.Value;
            }
            set
            {
                hdnStudentID.Value = value;
            }
        }

        public string GetSetAssetID
        {
            get
            {
                return hdnAssetID.Value;
            }
            set
            {
                hdnAssetID.Value = value;
            }
        }

        protected string QS_ASSET_ID
        {
            get
            {
                return Request.QueryString["Asset_ID"];
            }
        }

        protected string ASSET_ATTACHMENT_ID
        {
            get
            {
                return hdnID.Value;
            }
            set
            {
                hdnID.Value = value;
            }
        }

        private string GetFileTypeFromUploadControl(FileUpload fupload)
        {
            string filetype = "";
            if (fupload.HasFile)
            {
                string[] parts = fupload.FileName.Split('.');
                filetype = parts[parts.Length - 1];
            }
            return filetype;
        }

        private bool hasDuplicateFileName()
        {
            bool hasDuplicate = false;

            //Check for Duplicate Name for Same File type
            string id = "";
            if (!IsInsert())
            {
                id = ASSET_ATTACHMENT_ID;
            }
            string asset_id = GetSetAssetID;
            string filename = txtNameEdit.Text;
            
            string filetype = hdnFileType.Value;
            string fileUploadType = Utilities.GetFileTypeFromUploadControl(FileUploadAttachment);
            if (!Utilities.isNull(fileUploadType))
            {
                filetype = fileUploadType;
            }

            //only validate if a file has been attachched
            if (!Utilities.isNull(filetype))
            {
                DataSet ds = DatabaseUtilities.DsValidateDuplicateAttachmentName(asset_id, id, filename, filetype);
                if (ds.Tables[0].Rows.Count > 0)
                {
                    hasDuplicate = true;
                    cvDuplicateName.IsValid = false;
                }
            }
            
            return hasDuplicate;
        }

        private bool ValidateSaveAttachment()
        {
            bool IsValid = true;

            //Check for duplicate file name
            if (hasDuplicateFileName())
            {
                IsValid = false;
            }

            return IsValid;
        }

        private bool ValidateFileSize()
        {
            bool IsValid = true;
            if (FileUploadAttachment.HasFile)
            {
                HttpPostedFile file = (HttpPostedFile)(FileUploadAttachment.PostedFile);

                int iMaxFileSIze = int.Parse(Utilities.GetAppSettingFromConfig("MAX_FILE_SIZE_UPLOAD"));

                int iFileSize = file.ContentLength;
                if (iFileSize > iMaxFileSIze)
                {
                    IsValid = false;
                }

            }

            cvUploadFileSize.IsValid = IsValid;

            return IsValid;
        }

        protected bool IsInsert()
        {
            return ASSET_ATTACHMENT_ID.Equals("-1");
        }

        public void DisplayDetails(bool isReload)
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupAttachmentDetails').modal();", true);
            if (isReload)
            {
                //Load attachment type
                ddlAttachmentType.LoadddlAttachmentType(true, true, false); 
                LoadStudentAssetTransactionDDL();
                LoadAttachment(ASSET_ATTACHMENT_ID);
            }
            divTamperInfo.Visible = false;
            reqFile.Visible = true;
            string title = "Add Attachment";
            if (!IsInsert())
            {
                title = "Edit Attachment";
                reqFile.Visible = false; //Not required on edit
                divTamperInfo.Visible = true;
                divStudentTamperInfo.Visible = false;
                if (lblIsTampered.Text.ToLower().Trim().Equals("yes"))
                {
                    divStudentTamperInfo.Visible = true;
                }
            }
            lblModalTitle.Text = title;
        }

        public void DisplayNoFileFound()
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupNoFileFound').modal();", true);

            lblNoFileTitle.Text = "No File Found.";
            lblNoFileBody.Text = "Please contact <a href='mailto:ProgrammerSupport@monet.k12.ca.us' class='btn btn-default btn-xs'>Programmer Support</a>";
        }

        private void ApplySecurityToControl()
        {
            DataSet ds = DatabaseUtilities.DsGetAssetInfoByID(QS_ASSET_ID);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string site_code = ds.Tables[0].Rows[0]["Asset_Site_Code"].ToString();

                btnAddAttachment.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
                btnSaveAttachment.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;

                //Initial load will be take care of this security. Doing this to prevent the security method from being called multiple times
                if (!IsPostBack)
                {
                    AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnAddAttachment);
                    AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnSaveAttachment);
                }
            }
        }

        private void LoadAttachment(string id)
        {
            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_ATTACHMENTS, GetSetAssetID, id, "");
            Utilities.DataBindForm(divAssetAttachmentInfo, ds);

            //need to set the hidden value for file type to validate duplicate file name
            string filetype = "";
            if (ds.Tables[0].Rows.Count > 0)
            {
                filetype = ds.Tables[0].Rows[0]["File_Type_Desc"].ToString();
            }
            hdnFileType.Value = filetype;
        }

        public void LoadAttachmentDG()
        {
            string asset_id = QS_ASSET_ID;
            string sortby = "v.Date_Added desc";
            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_ATTACHMENTS, asset_id, "", sortby);

            dgAttachment.Visible = false;
            lblResults.Text = "No attachments(s) found for this asset";
            if (ds.Tables[0].Rows.Count > 0)
            {
                lblResults.Text = "";
                dgAttachment.Visible = true;
                dgAttachment.DataSource = ds;
                dgAttachment.DataBind();
            }
        }

        private void LoadStudentAssetTransactionDDL()
        {
            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_ASSIGNMENT, GetSetAssetID, "", "");

            divAssetStudentTransactionInfo.Visible = false;

            if (ds.Tables[0].Rows.Count > 0)
            {
                divAssetStudentTransactionInfo.Visible = true;

                ddlAssetStudentTransaction.DataSource = ds;
                ddlAssetStudentTransaction.DataValueField = "ID";
                ddlAssetStudentTransaction.DataTextField = "Display_Name";
                ddlAssetStudentTransaction.DataBind();

                ddlAssetStudentTransaction.Items.Insert(0, new ListItem("--- No Related Student Transaction ---", "-1"));
            }
        }

        private void SaveAttachment()
        {
            string filename = txtNameEdit.Text;
            string filetype = hdnFileType.Value;
            string controlFileType = Utilities.GetFileTypeFromUploadControl(FileUploadAttachment);
            if (!Utilities.isNull(controlFileType))
            {
                filetype = controlFileType;
            }
            string logonempid = Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());
            string date = DateTime.Now.ToString();

            string p_ID = ASSET_ATTACHMENT_ID;
            string p_Asset_Student_Transaction_ID = Constants.MCSDBNULL;
            string p_Asset_ID = GetSetAssetID;
            string p_Student_ID = Constants.MCSDBNOPARAM;
            string p_Asset_Tamper_ID = Constants.MCSDBNOPARAM;
            string p_Attachment_Type_ID = ddlAttachmentType.SelectedValue;

            if (!Utilities.isNull(GetSetStudentID))
            {
                p_Student_ID = GetSetStudentID;
            }
            string p_File_Type_ID = Constants.MCSDBNOPARAM;
            if (FileUploadAttachment.HasFile)
            {
                p_File_Type_ID = Utilities.GetFileTypeIDFromName(filetype);
            }

            string p_Name = filename;
            string p_Description = txtDescriptionEdit.Text;
            //Default audit columns
            string p_Added_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Date_Added = Constants.MCSDBNOPARAM;
            string p_Modified_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Date_Modifed = Constants.MCSDBNOPARAM;

            //only associate the attachment if the div is visible
            if (divAssetStudentTransactionInfo.Visible)
            {
                string selected_value = ddlAssetStudentTransaction.SelectedValue;
                if (!selected_value.Equals("-1"))
                {
                    p_Asset_Student_Transaction_ID = selected_value;
                }
            }

            if (IsInsert())
            {
                p_Added_By_Emp_ID = logonempid;
                p_Date_Added = date;
            }
            else
            {
                p_Modified_By_Emp_ID = logonempid;
                p_Date_Modifed = date;
            }

            
            //must check to see if the file name on server still matches before saving
            string filenametype = filename + '.' + filetype;
            UploadFileToServer(GetSetAssetID, ASSET_ATTACHMENT_ID, filenametype);

            
            //Saving Database changes
            DatabaseUtilities.Upsert_Asset_Attachment(
                p_ID,
                p_Asset_Student_Transaction_ID,
                p_Asset_ID,
                p_Student_ID,
                p_Asset_Tamper_ID,
                p_Attachment_Type_ID,
                p_File_Type_ID,
                p_Name,
                p_Description,
                p_Added_By_Emp_ID,
                p_Date_Added,
                p_Modified_By_Emp_ID,
                p_Date_Modifed
            );
        }

        private void UploadFileToServer(string assetID, string assetAttachmentID, string fileName)
        {
            string folder = Utilities.GetAssetAttachmentFolderLocation() + "\\" + assetID;
            string oldFileName = Utilities.GetAttachmentFileFullNameByID(assetAttachmentID).ToLower().Trim();
            string sanitizeFileName = fileName.ToLower().Trim();
            bool IsFileNameChanged = !oldFileName.Equals(sanitizeFileName);
            string sOldFileName = folder + "\\" + oldFileName;
            string sNewFileName = folder + "\\" + fileName;
            
            //Check to see if there is a file to be uploaded
            if (FileUploadAttachment.HasFile && !Utilities.isNull(fileName))
            {
                //Check to see if folder exist. If not, create

                if (!Directory.Exists(folder))
                {
                    Directory.CreateDirectory(folder);
                }
                FileUploadAttachment.SaveAs(sNewFileName);
            }
            else
            {
            //Check to see if file needs to be rename for existing attachment
                if (!IsInsert() && IsFileNameChanged)
                {
                    FileInfo f = new FileInfo(sOldFileName);
                    if (f.Exists)
                    {
                        File.Copy(sOldFileName, sNewFileName);
                        f.Delete();
                    }
                }
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!Utilities.isNull(QS_ASSET_ID))
                {
                    GetSetAssetID = QS_ASSET_ID;
                    ApplySecurityToControl();
                }
            }
        }

        protected void btnEditDetails_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string ID = btn.Attributes["Asset_Attachment_ID"];
            string FileName = btn.Attributes["Asset_File_Name"];

            ASSET_ATTACHMENT_ID = ID;
            DisplayDetails(true);
            
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string ID = btn.Attributes["Asset_Attachment_ID"];

            Utilities.DeleteAssetAttachmentByID(ID, QS_ASSET_ID);

            //DeleteAssetAttachment(ID);

            LoadAttachmentDG();
        }

        protected void btnAddAttachment_Click(object sender, EventArgs e)
        {
            ASSET_ATTACHMENT_ID = "-1";
            DisplayDetails(true);
        }

        protected void btnSaveAttachment_Click(object sender, EventArgs e)
        {
            if (ValidateSaveAttachment() && ValidateFileSize() && Page.IsValid)
            {
                SaveAttachment();
                LoadAttachmentDG();
            }
            else
            {
                DisplayDetails(false);
                Utilities.SelectTextBox(txtNameEdit);
                txtNameEdit.Focus();
            }
        }

        protected void btnUploadFile_Click(object sender, EventArgs e)
        {
            DisplayDetails(false);
        }

        protected void btnView_Click(object sender, EventArgs e)
        {
            //Open Attachment
            Button btn = (Button)sender;
            string FileName = btn.Attributes["Asset_File_Name"];
            string FileType = btn.Attributes["Asset_File_Type"];

            string Folder_Location = Utilities.GetAssetAttachmentFolderLocation();
            string filePath = Folder_Location + "\\" + GetSetAssetID + "\\"  + FileName + "." + FileType;

            if (!Utilities.ViewAnyDocument(filePath, Response))
            {
                DisplayNoFileFound();
            }
        }

        protected void dgAttachment_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            if (e.Item.ItemIndex >= 0)
            {
                Button btnEdit = ((Button)e.Item.FindControl("btnEditDetails"));
                Button btnDelete = ((Button)e.Item.FindControl("btnDelete"));

                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnEdit);
                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnDelete);
            }
        }
    }
}