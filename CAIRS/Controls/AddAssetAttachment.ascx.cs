using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Text;
using System.IO;

namespace CAIRS.Controls
{
    public partial class AddAssetAttachement : System.Web.UI.UserControl
    {
        private string ValidationGroupAdd = "vgAddAttachment_";
        private string Temp_Folder_Location()
        {
            return Utilities.GetAssetAttachmentFolderLocation() + "\\TEMP\\" + GetSetAssetID;
        }
        public string GetSetAssetID
        {
            get
            {
                return hdnAssetId.Value;
            }
            set
            {
                hdnAssetId.Value = value;
            }
        }
        public string GetSetAssetTamperID
        {
            get
            {
                return hdnAssetTamperID.Value;
            }
            set
            {
                hdnAssetTamperID.Value = value;
            }
        }
        public string GetAttachmentXML()
        {
            StringBuilder sb = new StringBuilder();

            DataSet ds = dsAttachment(false);
            if (ds.Tables[0].Rows.Count > 0)
            {
                sb.Append("<Attachments>");

                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    sb.Append("<Attachment>");
                    foreach (DataColumn c in ds.Tables[0].Columns)
                    {
                        sb.Append("<" + c.ColumnName + ">" + row[c.ColumnName].ToString() + "</" + c.ColumnName + ">");
                    }
                    sb.Append("</Attachment>");
                }

                sb.Append("</Attachments>");
            }

            return sb.ToString(); 
        }
        public void UploadFileFromGridToServer()
        {
            string folder = Utilities.GetAssetAttachmentFolderLocation() + "\\" + GetSetAssetID + "\\";
            DataSet ds = dsAttachment(false);
            if (ds.Tables[0].Rows.Count > 0)
            {
                //Check to see if the asset folder exist
                if (!Directory.Exists(folder))
                {
                    Directory.CreateDirectory(folder);
                }

                //loop thru each row in the datagrid.
                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    string fileUploadPath = row["File_Path"].ToString();
                    string fileName = row["File_Name"].ToString();
                    string fileType = row["File_Type"].ToString();

                    if (!Utilities.isNull(fileName) && !Utilities.isNull(fileType))
                    {
                        string fileNameType = folder + fileName + "." + fileType;
                        if (File.Exists(fileUploadPath))
                        {
                            File.Copy(fileUploadPath, fileNameType, true);
                        }
                    }
                }
            }
        }
        public void ClearAttachments()
        {
            
            if (!Utilities.isNull(GetSetAssetID))
            {   
                //remove files from temp location
                Utilities.RemoveAssetTempFolderByID(GetSetAssetID);
            }
            txtDescription.Text = "";
            txtFileName.Text = "";
            FileUploadAttachment.Dispose();
            //chkAddAttachment.Checked = false;
            dgAttachment.DataSource = null;
            dgAttachment.DataBind();
        }
        public event EventHandler AddAttachment_Click;
        public event EventHandler Delete_Click;

        protected DataSet dsAttachment(bool isAdd)
        {
            DataSet ds = new DataSet();
            DataTable table = ds.Tables.Add();

            //-- Add columns to the data table
            table.Columns.Add("Attachment_ID", typeof(string));
            table.Columns.Add("Asset_ID", typeof(string));
            table.Columns.Add("File_Name", typeof(string));
            table.Columns.Add("File_Type", typeof(string));
            table.Columns.Add("File_Desc", typeof(string));
            table.Columns.Add("File_Path", typeof(string));
            table.Columns.Add("Attachment_Type_ID", typeof(string));
            table.Columns.Add("Attachment_Type_Desc", typeof(string));

            int iIDBuilder = 0;

            foreach (DataGridItem item in dgAttachment.Items)
            {
                //Build the dataset from the grid
                Label lbl = ((Label)item.FindControl("lblFileType"));

                string Asset_ID = lbl.Attributes["Asset_ID"].ToString();
                string FileName = lbl.Attributes["File_Name"].ToString();
                string FileType = lbl.Attributes["File_Type"].ToString();
                string FileDesc = lbl.Attributes["File_Desc"].ToString();
                string FilePath = lbl.Attributes["File_Path"].ToString();
                string Attachment_Type_ID = lbl.Attributes["Attachment_Type_ID"].ToString();
                string Attachment_Type_Desc = lbl.Attributes["Attachment_Type_Desc"].ToString();

                //used to build unique ID
                iIDBuilder = iIDBuilder + 1;
                table.Rows.Add(iIDBuilder, Asset_ID, FileName, FileType, FileDesc, FilePath, Attachment_Type_ID, Attachment_Type_Desc);
            }

            if (isAdd)
            {
                string p_FileName = txtFileName.Text;
                string p_FileType = Utilities.GetFileTypeFromUploadControl(FileUploadAttachment);
                string p_FileDesc = txtDescription.Text;
                string p_FilePath = Temp_Folder_Location() + "\\" + p_FileName + "." + p_FileType; //FileUploadAttachment.PostedFile.FileName;
                string p_Attachment_Type_ID = ddlAttachmentType.SelectedValue;
                string p_Attachment_Type_Desc = ddlAttachmentType.SelectedText;

                if (!Utilities.isNull(GetSetAssetID) && !Utilities.isNull(p_FileName))
                {
                    table.Rows.Add(iIDBuilder + 1, GetSetAssetID, p_FileName, p_FileType, p_FileDesc, p_FilePath, p_Attachment_Type_ID, p_Attachment_Type_Desc);
                }
            }

            return ds;
        }

        private void DeleteAttachment(string id, string file_path)
        {
            //remove from temp location
            FileInfo f = new FileInfo(file_path);
            if (f.Exists)
            {
                f.Delete();
            }

            //Delete from dataset
            DataSet ds = dsAttachment(false);
            int count = ds.Tables[0].Rows.Count;
            int rowCount = 0;
            foreach (DataRow dr in ds.Tables[0].Rows)
            {
                if (id.Equals(dr["Attachment_ID"].ToString()))
                {
                    ds.Tables[0].Rows[rowCount].Delete();
                    break;
                }
                rowCount++;
            }

            dgAttachment.DataSource = ds;
            dgAttachment.DataBind();

        }

        private bool hasDuplicateFileName()
        {
            bool hasDuplicate = false;

            string sErrorMsg = "";
            string br = "<br/>";

            //Check for Duplicate Name for Same File type
            string asset_id = GetSetAssetID;
            string filename = txtFileName.Text.Trim();
            string filetype = Utilities.GetFileTypeFromUploadControl(FileUploadAttachment).Trim();

            DataSet ds = DatabaseUtilities.DsValidateDuplicateAttachmentName(asset_id, "", filename, filetype);
            if (ds.Tables[0].Rows.Count > 0)
            {
                sErrorMsg += "Duplicate file name and type. Please Change." + br;
                hasDuplicate = true;
                cvDuplicateName.IsValid = false;
            }

            DataSet dsGrid = dsAttachment(false);
            if (dsGrid.Tables[0].Rows.Count > 0)
            {
                //Check to see if there are duplicates within the batch
                foreach (DataRow row in dsGrid.Tables[0].Rows)
                {
                    string rFileName = row["File_Name"].ToString().Trim().ToLower();
                    string rFileType = row["File_Type"].ToString().Trim().ToLower();
                    if (filename.ToLower().Equals(rFileName) && filetype.ToLower().Equals(rFileType))
                    {
                        sErrorMsg += "Duplicate file name and type. Please Change.";
                        hasDuplicate = true;
                        cvDuplicateName.IsValid = false;
                    }
                }
            }

            if (hasDuplicate)
            {
                cvDuplicateName.ErrorMessage = sErrorMsg;
                cvDuplicateName.Text = sErrorMsg;
            }

            return hasDuplicate;
        }

        private bool ValidateFileSize()
        {
            bool IsValid = true;
            if (FileUploadAttachment.HasFile) { 
                HttpPostedFile file = (HttpPostedFile)(FileUploadAttachment.PostedFile);

                int iMaxFileSIze = int.Parse(Utilities.GetAppSettingFromConfig("MAX_FILE_SIZE_UPLOAD"));

                int iFileSize = file.ContentLength;
                if (iFileSize > iMaxFileSIze)
                {
                    IsValid = false;
                }

            }

            cVUploadFileSize.IsValid = IsValid;

            return IsValid;
        }

        private void UploadFileTempLocation()
        {
            string file_name = txtFileName.Text;
            string file_type = Utilities.GetFileTypeFromUploadControl(FileUploadAttachment);
            string new_file_name = Temp_Folder_Location() + "\\" + file_name + "." + file_type;

            if (FileUploadAttachment.HasFile && !Utilities.isNull(file_name))
            {
                if (!Directory.Exists(Temp_Folder_Location()))
                {
                    Directory.CreateDirectory(Temp_Folder_Location());
                }
                FileUploadAttachment.SaveAs(new_file_name);
            }
        }

        private void ApplySecurityToControl()
        {
            string site_code = "";

            if (!Utilities.isNull(GetSetAssetID))
            {
                site_code = Utilities.GetAssetSiteCodeByAssetID(GetSetAssetID);
            }

            btnAddAttachment.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
            AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnAddAttachment);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                //Needed for control to function properly when this control is used twice on a page.
                string vg = ValidationGroupAdd + this.ID.ToString();
                reqName.ValidationGroup = vg;
                regExName.ValidationGroup = vg;
                cvDuplicateName.ValidationGroup = vg;
                reqFile.ValidationGroup = vg;
                regExFileType.ValidationGroup = vg;
                btnAddAttachment.ValidationGroup = vg;

                //Load attachment type
                ddlAttachmentType.LoadddlAttachmentType(true, true, false);

                ddlAttachmentType.ValidationGroup = vg;

            }

            ApplySecurityToControl();
        }

        protected void btnAddAttachment_Click(object sender, EventArgs e)
        {
            if (!hasDuplicateFileName() && ValidateFileSize() && Page.IsValid)
            {
                //upload file to temp location
                UploadFileTempLocation();

                DataSet ds = dsAttachment(true);
                dgAttachment.Visible = false;
                if (ds.Tables[0].Rows.Count > 0)
                {
                    dgAttachment.Visible = true;
                    dgAttachment.DataSource = ds;
                    dgAttachment.DataBind();
                }

                //Initialize Control
                txtDescription.Text = "";
                txtFileName.Text = "";

                ddlAttachmentType.ddlAttachmentType.SelectedIndex = 0; //Reset index back to the first option
            }

            if (AddAttachment_Click != null)
            {
                AddAttachment_Click(sender, EventArgs.Empty);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            string id = ((Button)sender).Attributes["Asset_Attachment_ID"];
            string temp_file_path = ((Button)sender).Attributes["File_Path"];

            DeleteAttachment(id, temp_file_path);

            //updateAttachment.Update();

            if (Delete_Click != null)
            {
                Delete_Click(sender, EventArgs.Empty);
            }
        }
    }
}