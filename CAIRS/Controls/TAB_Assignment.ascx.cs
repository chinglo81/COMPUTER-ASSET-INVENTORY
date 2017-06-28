using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.IO;
using System.Net;

namespace CAIRS.Controls
{
    public partial class TAB_Assignment : System.Web.UI.UserControl
    {
        protected string QS_ASSET_ID
        {
            get
            {
                return Request.QueryString["Asset_ID"];
            }
        }

        public void DisplayDetails(string id)
        {
            lblModalTitle.Text = "Assignment Details";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupAssignmentDetails').modal();", true);
            LoadDetails(id);
        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        private void LoadDetails(string id)
        {

            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_ASSIGNMENT, QS_ASSET_ID, id, "");

            Utilities.DataBindForm(divStudentAssetInfo, ds);

            string studentid = lblStudentID.Text;
            if (!Utilities.isNull(studentid))
            {
                LoadStudentImage(studentid);
            }

            trChkInCondition.Visible = !Utilities.isNull(lblCheckInCondition.Text);
            trChkInBy.Visible = !Utilities.isNull(lblCheckInByEmp.Text);
            trChkInDate.Visible = !Utilities.isNull(lblDateCheckIn.Text);

        }

        private void LoadStudentImage(string studentid)
        {
            string StudentPhotoFolder = Utilities.GetAppSettingFromConfig("STUDENTPHOTOS_FOLDER");
            string photoFilePath = StudentPhotoFolder + studentid + ".jpg";

            //Check to see if the student phote exist.
            FileInfo f = new FileInfo(photoFilePath);
            if (!f.Exists)
            {
                photoFilePath = StudentPhotoFolder + "NoPicture.jpg";
            }

            //check to see if photo exist
            FileInfo fExist = new FileInfo(photoFilePath);

            if (fExist.Exists)
            {
                WebClient wc = new WebClient();
                byte[] imageBytes = wc.DownloadData(photoFilePath);

                //create memory stream of the bytes ad convert to image to base 64 to display
                MemoryStream imgStream = new MemoryStream(imageBytes);
                imgStudentPhoto.ImageUrl = "data:image/jpg;base64," + Convert.ToBase64String(imgStream.ToArray(), 0, imgStream.ToArray().Length);

                //imgStudentPhoto.ImageUrl = photoFilePath;
            }
            
        }

        public void LoadAssignmentDG()
        {
            string Asset_ID = QS_ASSET_ID;
            string sortby = "v.Date_Check_Out desc";
            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_ASSIGNMENT, Asset_ID, "", sortby);

            dgAssignment.Visible = false;
            lblResults.Text = "No assignment(s) found for this asset";
            if (ds.Tables[0].Rows.Count > 0)
            {
                lblResults.Text = "";
                dgAssignment.Visible = true;
                dgAssignment.DataSource = ds;
                dgAssignment.DataBind();
            }
        }

        protected void btnViewDetails_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string ID = btn.Attributes["Asset_Student_Transaction_ID"];
            DisplayDetails(ID);
        }
    }
}