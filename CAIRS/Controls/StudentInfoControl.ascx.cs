using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Net;
using System.Data;

namespace CAIRS.Controls
{
    public partial class StudentInfoControl : System.Web.UI.UserControl
    {

        public bool showChangeStudentBtn = false;

        /// <summary>
        /// Used to handle event that needs to be fired after this a site has been selected.s
        /// </summary>
        public event EventHandler OnClickChangeStudent_Btn;

        protected string qs_StudentID
        {
            get
            {
                return Request.QueryString["Student_ID"];
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!Utilities.isNull(qs_StudentID))
                {
                    LoadStudentInfo(qs_StudentID);
                }
            }
            btnChangeStudent.Visible = showChangeStudentBtn;

        }

        protected void OnClickChangeStudent(object sender, EventArgs e)
        {
            if (OnClickChangeStudent_Btn != null)
            {
                OnClickChangeStudent_Btn(sender, EventArgs.Empty);
            }
        }

        public void LoadStudentInfo(string studentid)
        {
            DataSet ds = DatabaseUtilities.DsGetStudentInfo("", "", studentid, false);
            if (ds.Tables[0].Rows.Count > 0)
            {
                Utilities.DataBindForm(divStudentInfoControl, ds);
                lblStudentStatus.CssClass = "";
                if (lblStudentStatus.Text.Trim().ToLower().Equals("inactive"))
                {
                    lblStudentStatus.CssClass = "invalid";
                }
            }

            LoadStudentImage(studentid);
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
    }
}