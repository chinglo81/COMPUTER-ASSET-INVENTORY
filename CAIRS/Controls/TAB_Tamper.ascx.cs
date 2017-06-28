using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class TAB_Tamper : System.Web.UI.UserControl
    {

        public event EventHandler btnSaveTamperClick;
        public event EventHandler btnDeleteTamperClick;

        public void RefreshForm()
        {
            LoadTamperDG();
        }

        public string GetSetTamperID
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

        public bool IsInsert()
        {
            return GetSetTamperID.Equals("-1");
        }
        
        protected string QS_ASSET_ID
        {
            get
            {
                return Request.QueryString["Asset_ID"];
            }
        }
        
        private DataSet dsGetAssetInfo()
        {
            return DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_MASTER_LIST, "Asset_ID", QS_ASSET_ID, "");
        }

        private void ApplySecurityToControl()
        {
            DataSet ds = dsGetAssetInfo();
            if (ds.Tables[0].Rows.Count > 0)
            {
                string site_code = ds.Tables[0].Rows[0]["Asset_Site_Code"].ToString();

                btnAddTamper.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
                btnSaveManagePropertiesModal.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;

                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnAddTamper);
                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnSaveManagePropertiesModal);
            }
        }

        private void ShowHideEditControl()
        {
            trDateProcessed.Visible = !IsInsert();
            trAddedBy.Visible = !IsInsert();
            trDateAdded.Visible = !IsInsert();
            trModifiedBy.Visible = !IsInsert() && !Utilities.isNull(lblModifiedBy.Text);
            trDateModified.Visible = !IsInsert() && !Utilities.isNull(lblModifiedBy.Text);
            trExistingAttachments.Visible = !IsInsert();
        }

        private void InitilizeControlForEditModal()
        {
            lblTamperedStudent.Visible = true;
            radCorrectStudent.SelectedValue = "Yes";
            txtComment.Text = "";
            txtStudentLookup.txtStudentLookup.Text = "";
            txtStudentLookup.SelectedStudentID = "";
            txtStudentLookup.SetSelectedStudent();
            txtStudentLookup.Visible = false;
            trPreviousStudentAssigned.Visible = IsInsert();
            uc_TamperAttachment.ClearAttachments();
        }

        private void ShowHideLoadControl()
        {
            DataSet ds = dsGetAssetInfo();
            if (ds.Tables[0].Rows.Count > 0)
            {
                string sStudentID = ds.Tables[0].Rows[0]["Student_ID"].ToString().Trim();

                if (Utilities.isNull(sStudentID))
                {
                    trPreviousStudentAssigned.Visible = false;
                    txtStudentLookup.Visible = true;
                    lblTamperedStudent.Visible = false;
                }
                
             }
        }

        private void LoadTamperInfo()
        {
            DataSet ds = dsGetAssetInfo();
            if (!IsInsert())
            {
                ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_TAMPER, "", GetSetTamperID, "");
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                string sStudentID = ds.Tables[0].Rows[0]["Student_ID"].ToString().Trim();

                if (Utilities.isNull(sStudentID))
                {
                    trPreviousStudentAssigned.Visible = false;
                    txtStudentLookup.Visible = true;
                    lblTamperedStudent.Visible = false;
                }

            }
            
            Utilities.DataBindForm(divTamperInfo, ds);

            uc_TamperAttachment.GetSetAssetID = QS_ASSET_ID;
            uc_TamperAttachment.GetSetAssetTamperID = GetSetTamperID;

            ShowHideEditControl();
        }

        private void DisplayDetails(bool isReload)
        {
            if (isReload)
            {
                string title = "Add Tamper";
                if (!IsInsert())
                {
                    title = "Edit Tamper";
                }
                lblManagePropertiesTitle.Text = title;

                InitilizeControlForEditModal();

                LoadTamperInfo();

                LoadTamperAttachmentDG();
            }

            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupTamperModal", "$('#popupManagePropertiesModal').modal();", true);
            
            //updatePanelManageProperties.Update();
        }

        private void LoadTamperDG()
        {
            string sortby = "v.ID desc";
            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_TAMPER, QS_ASSET_ID, "", sortby);

            dgTamper.Visible = false;
            lblResults.Text = "No Tamper(s) found for this asset";
            if (ds.Tables[0].Rows.Count > 0)
            {
                lblResults.Text = "";
                dgTamper.Visible = true;
                dgTamper.DataSource = ds;
                dgTamper.DataBind();

                //Initial load will be take care of the first security
                AppSecurity.Apply_CAIRS_Security_To_UserControls(dgTamper.Controls);
            }

            //updateTamper.Update();
        }

        private void LoadTamperAttachmentDG()
        {
            string sortby = "Date_Added desc";
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_TAB_ATTACHMENTS, "Asset_Tamper_ID", GetSetTamperID, sortby);

            dgTamperAttachment.Visible = false;
            lblResultsAttachment.Text = "No attachments(s) found";
            if (ds.Tables[0].Rows.Count > 0)
            {
                lblResultsAttachment.Text = "";
                dgTamperAttachment.Visible = true;
                dgTamperAttachment.DataSource = ds;
                dgTamperAttachment.DataBind();

                AppSecurity.Apply_CAIRS_Security_To_UserControls(dgTamperAttachment.Controls);
            }
        }

        private void DisplayNoFileFound()
        {
            lblNoFileTitle.Text = "No File Found.";
            lblNoFileBody.Text = "Please contact <a href='mailto:ProgrammerSupport@monet.k12.ca.us' class='btn btn-default btn-xs'>Programmer Support</a>";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupFileNotFoundTamper", "$('#popupNoFileFoundTamper').modal();", true);
            updatePanelFileNotFound.Update();
        }

        private void SaveTamper()
        {
            string emp_id = Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());
            string date_time = DateTime.Now.ToString();

            string p_ID = GetSetTamperID;
            string p_Asset_ID = QS_ASSET_ID;
            string p_Student_ID = hdnStudentID.Value;
            if (txtStudentLookup.Visible)
            {
                p_Student_ID = txtStudentLookup.SelectedStudentID;
            }
            string p_Comment = txtComment.Text;
            string p_Added_By_Emp_ID = emp_id;
            string p_Date_Added = date_time;
            string p_Modified_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Date_Modified = Constants.MCSDBNOPARAM;
            string p_Attachments = uc_TamperAttachment.GetAttachmentXML();

            //Upoload files to server
            uc_TamperAttachment.UploadFileFromGridToServer();

            //Remove Asset from Temp location
            string asset_id = uc_TamperAttachment.GetSetAssetID;
            if (!Utilities.isNull(asset_id))
            {
                Utilities.RemoveAssetTempFolderByID(asset_id);
            }

            if (!IsInsert())
            {
                p_Student_ID = Constants.MCSDBNOPARAM; //Student ID not editable
                p_Added_By_Emp_ID = Constants.MCSDBNOPARAM;
                p_Date_Added = Constants.MCSDBNOPARAM;
                p_Modified_By_Emp_ID = emp_id;
                p_Date_Modified = date_time;
            }

            DatabaseUtilities.Upsert_Asset_Tamper(
                p_ID,
                p_Asset_ID,
                p_Student_ID,
                p_Comment,
                p_Added_By_Emp_ID,
                p_Date_Added,
                p_Modified_By_Emp_ID,
                p_Date_Modified,
                p_Attachments
            );
        }

        private void DeleteTamperedAttachmentByTamperID(string tamper_id)
        {
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_TAB_ATTACHMENTS, "Asset_Tamper_ID", tamper_id, "");
            foreach (DataRow row in ds.Tables[0].Rows)
            {
                string attachement_id = row["ID"].ToString();
                string asset_id = row["Asset_ID"].ToString();

                Utilities.DeleteAssetAttachmentByID(attachement_id, asset_id);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!Utilities.isNull(QS_ASSET_ID))
                {
                    uc_TamperAttachment.GetSetAssetID = QS_ASSET_ID;
                    ApplySecurityToControl();
                    ShowHideLoadControl();
                }
                
               
            }

            uc_TamperAttachment.AddAttachment_Click += btnAddAttachmentTamper_Click;
            uc_TamperAttachment.Delete_Click += btnAddAttachmentTamper_Click; 
            
            txtStudentLookup.btnChangeStudentClick += btnStudentLookup_Click;
            txtStudentLookup.btnSearchStudentClick += btnStudentLookup_Click;
        }

        protected void btnAddAttachmentTamper_Click(object sender, EventArgs e)
        {
            DisplayDetails(false);
        }
        protected void btnStudentLookup_Click(object sender, EventArgs e)
        {
            DisplayDetails(false);
        }

        protected bool IsDisplayDelete(object o)
        {
            string processed = ((DataRowView)o)["Processed"].ToString().ToLower().Trim();

            return processed.ToLower().Trim().Equals("not processed");
        }

        protected void dgTamper_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            if (e.Item.ItemIndex >= 0)
            {
                //Button btnDelete = ((Button)e.Item.FindControl("btnDelete"));
                //AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnDelete);
            }
        }

        protected void dgTamperAttachment_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            if (e.Item.ItemIndex >= 0)
            {
                //Button btnDelete = ((Button)e.Item.FindControl("btnDeleteTamperAttachment"));
                //AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnDelete);
            }
        }
        
        

        protected void btnViewTamper_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string ID = btn.Attributes["Tamper_ID"];
            GetSetTamperID = ID;
            DisplayDetails(true);

        }

        protected void btnAddTamper_Click(object sender, EventArgs e)
        {
            GetSetTamperID = "-1";
            DisplayDetails(true);
        }

        protected void btnDeleteTamper_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string tamper_id = btn.Attributes["Tamper_ID"];

            //Remove attachment first
            DeleteTamperedAttachmentByTamperID(tamper_id);
            
            //Delete record 2nd
            DatabaseUtilities.DeleteAsset_Tamper(tamper_id);

            LoadTamperDG();

            if (btnDeleteTamperClick != null)
            {
                btnDeleteTamperClick(sender, EventArgs.Empty);
            }
        }

        protected void btnDeleteTamperAttachment_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string ID = btn.Attributes["Asset_Attachment_ID"];

            Utilities.DeleteAssetAttachmentByID(ID, QS_ASSET_ID);

            LoadTamperAttachmentDG();

            DisplayDetails(false);
        }

        protected void btnSaveManagePropertiesModal_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                SaveTamper();
                Utilities.CloseModal(Page, "popupManagePropertiesModal");

                if (btnSaveTamperClick != null)
                {
                    btnSaveTamperClick(sender, EventArgs.Empty);
                }
            }
        }

        protected void btnViewAttachment_Click(object sender, EventArgs e)
        {
            //Open Attachment
            Button btn = (Button)sender;
            string FileName = btn.Attributes["Asset_File_Name"];
            string FileType = btn.Attributes["Asset_File_Type"];

            string Folder_Location = Utilities.GetAssetAttachmentFolderLocation();
            string filePath = Folder_Location + "\\" + QS_ASSET_ID + "\\" + FileName + "." + FileType;

            if (!Utilities.ViewAnyDocument(filePath, Response))
            {
                DisplayNoFileFound();
            }
        }

        protected void radCorrectStudent_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtStudentLookup.Visible = radCorrectStudent.SelectedValue.Equals("No");
            DisplayDetails(false);

            lblTamperedStudent.Visible = radCorrectStudent.SelectedValue.Equals("Yes");
            
            if (txtStudentLookup.Visible)
            {
                txtStudentLookup.txtStudentLookup.Focus();
                
            }
        }

    }
}