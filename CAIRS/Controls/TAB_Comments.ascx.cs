using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class TAB_Comments : System.Web.UI.UserControl
    {
        protected string QS_ASSET_ID
        {
            get
            {
                return Request.QueryString["Asset_ID"];
            }
        }

        protected string ASSET_COMMENT_ID
        {
            get
            {
                return hdnCommentID.Value;
            }
            set
            {
                hdnCommentID.Value = value;
            }
        }

        protected string ADDED_BY_EMP_ID
        {
            get
            {
                return hdnAddedByEmpID.Value;
            }
            set
            {
                hdnAddedByEmpID.Value = value;
            }

        }

        protected bool IsInsert()
        {
            return ASSET_COMMENT_ID.Equals("-1");
        }

        private void ApplySecurityToControl()
        {
            DataSet ds = DatabaseUtilities.DsGetAssetInfoByID(QS_ASSET_ID);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string site_code = ds.Tables[0].Rows[0]["Asset_Site_Code"].ToString();

                btnAddComment.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
                btnSaveComment.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;

                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnAddComment);
                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnSaveComment);

            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!Utilities.isNull(QS_ASSET_ID))
                {
                    ApplySecurityToControl();
                }
            }
        }

        private void SaveComments()
        {
            string datetimenow = DateTime.Now.ToString();
            string empid = Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());

            string p_ID = ASSET_COMMENT_ID;
            string p_Asset_ID = QS_ASSET_ID; 
            string p_Comment = txtComment.Text; 
            string p_Added_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Date_Added = Constants.MCSDBNOPARAM;
            string p_Modified_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Date_Modified = Constants.MCSDBNOPARAM;

            if (IsInsert())
            {
                p_Added_By_Emp_ID = empid;
                p_Date_Added = datetimenow;
            }
            else
            {
                p_Modified_By_Emp_ID = empid;
                p_Date_Modified = datetimenow;
            }

            DatabaseUtilities.Upsert_Asset_Comment(
                p_ID,
                p_Asset_ID,
                p_Comment,
                p_Added_By_Emp_ID,
                p_Date_Added,
                p_Modified_By_Emp_ID,
                p_Date_Modified
            );
        }


        /// <summary>
        /// User must have access to edit asset and be the one who created the record.
        /// </summary>
        /// <param name="o"></param>
        /// <returns>boolean value</returns>
        protected bool CanModified(object o)
        {
            bool isAddedByMatchLogin = false;
            string addedbyemp = ((DataRowView)o)["Added_By_Emp_ID"].ToString();
            if (!Utilities.isNull(addedbyemp))
            {
                isAddedByMatchLogin = addedbyemp.Equals(Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser()));
            }

            //User must have ability to edit the site asset and be the one that created the comment
            if (AppSecurity.Can_Edit_Site_Asset(QS_ASSET_ID) && isAddedByMatchLogin)
            {
                return true;
            }

            return false;
        }

        public void LoadCommentsDG()
        {
            string sortby = "v.Recent_Date desc";
            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_COMMENTS, QS_ASSET_ID, "", sortby);

            dgComments.Visible = false;
            lblResults.Text = "No comment(s) found for this asset";
            if (ds.Tables[0].Rows.Count > 0)
            {
                lblResults.Text = "";
                dgComments.Visible = true;
                dgComments.DataSource = ds;
                dgComments.DataBind();

                //Initial load will be take care of the first security
                if (IsPostBack)
                {
                    AppSecurity.Apply_CAIRS_Security_To_UserControls(dgComments.Controls);
                }
            }
        }

        private void ShowHideControlForEdit()
        {
            bool IsLoggedOnEmpMatchAddedByEmp = ADDED_BY_EMP_ID.Equals(Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser()));

            txtComment.Visible = IsLoggedOnEmpMatchAddedByEmp || IsInsert();
            btnSaveComment.Visible = IsLoggedOnEmpMatchAddedByEmp || IsInsert();
            lblComment.Visible = !txtComment.Visible;

            trAddedBy.Visible = !IsInsert();
            trDateAdded.Visible = !IsInsert();
            trDateModified.Visible = !IsInsert() && !Utilities.isNull(lblDateModified.Text);
            trModifiedBy.Visible = !IsInsert() && !Utilities.isNull(lblModifiedBy.Text);

            if (txtComment.Visible)
            {
                txtComment.Focus();
            }
        }

        private void DisplayDetails(bool isReload)
        {
            lblModalTitle.Text = "Comment Details";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupCommentMessage", "$('#popupCommentDetails').modal();", true);
            if (isReload)
            {
                LoadDetails();
            }
            ShowHideControlForEdit();
        }

        private void LoadDetails()
        {
            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_COMMENTS, QS_ASSET_ID, ASSET_COMMENT_ID, "");

            Utilities.DataBindForm(divAssetCommentInfo, ds);
            ADDED_BY_EMP_ID = "";
            if (ds.Tables[0].Rows.Count > 0)
            {
                ADDED_BY_EMP_ID = ds.Tables[0].Rows[0]["Added_By_Emp_ID"].ToString();
            }

            
        }

        protected void btnViewDetails_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string ID = btn.Attributes["Comment_ID"];
            ASSET_COMMENT_ID = ID;

            DisplayDetails(true);
        }

        protected void btnSaveComment_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                SaveComments();
                LoadCommentsDG();
            }
            else
            {
                DisplayDetails(false);
            }
        }

        protected void btnAddComment_Click(object sender, EventArgs e)
        {
            ASSET_COMMENT_ID = "-1";
            DisplayDetails(true);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string id = btn.Attributes["Comment_ID"];

            //Delete comment
            DatabaseUtilities.DeleteAsset_Comment(id);

            //reload datagrid
            LoadCommentsDG();
        }

        protected void dgComments_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            if (e.Item.ItemIndex >= 0)
            {
                Button btnDelete = ((Button)e.Item.FindControl("btnDelete"));
                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnDelete);

                //If delete is enable make sure the logged on user matches the person who created the comment before they can delete.
                if (btnDelete.Enabled)
                {
                    string entered_by_emp_id = btnDelete.Attributes["Added_By_Emp_ID"];
                    string logged_on_user_emp_id = Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());

                    btnDelete.Enabled = entered_by_emp_id.Equals(logged_on_user_emp_id);
                }
            }
        }

    }
}