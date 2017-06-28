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
    public partial class ErrorPage : _CAIRSBasePage
    {
        protected string qsExceptionID
        {
            get
            {
                return Request.QueryString["Exception_ID"];
            }
        }

        protected DataSet DsGetException()
        {
            DataSet ds = null;
            string sExceptionID = qsExceptionID;
            if (!isNull(sExceptionID))
            {
                ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DBNAME_SECURITY, Constants.SECURITY_TBL_APPLICATIONEXCEPTIONS, "ID", sExceptionID, "");
            }
            return ds;
        }

        protected bool SendEmail()
        {
            string to = "ProgrammerSupport"; 
            string subject = "CAIRS - Application Error - Exception ID: " + qsExceptionID;  
            StringBuilder sbBody = new StringBuilder();

            DataSet ds = DsGetException();
            if (ds.Tables[0].Rows.Count > 0)
            {
                string page_name = ds.Tables[0].Rows[0]["pagename"].ToString();
                string exception_type = ds.Tables[0].Rows[0]["exceptiontype"].ToString();
                string stack_track = ds.Tables[0].Rows[0]["stacktrace"].ToString();
                string exception_msg = ds.Tables[0].Rows[0]["exceptionmessage"].ToString();
                string exception_date = ds.Tables[0].Rows[0]["exceptiondate"].ToString();
                string login = ds.Tables[0].Rows[0]["networklogin"].ToString();

                sbBody.Append("<table>");
                    sbBody.Append("<tr>");
                        sbBody.Append("<td colspan='2'>");
                            sbBody.Append("<h2>CAIRS Application Error</h2>");
                        sbBody.Append("</td>");
                    sbBody.Append("</tr>");
                    sbBody.Append("<tr>");
                        sbBody.Append("<td>Page Name:</td>");
                        sbBody.Append("<td>" + page_name + "</td>");
                    sbBody.Append("</tr>");
                    sbBody.Append("<tr>");
                        sbBody.Append("<td>Exception Type:</td>");
                        sbBody.Append("<td>" + exception_type + "</td>");
                    sbBody.Append("</tr>");
                    sbBody.Append("<tr>");
                        sbBody.Append("<td>Stack Track:</td>");
                        sbBody.Append("<td>" + stack_track + "</td>");
                    sbBody.Append("</tr>");
                    sbBody.Append("<tr>");
                        sbBody.Append("<td>Exception Message:</td>");
                        sbBody.Append("<td>" + exception_msg + "</td>");
                    sbBody.Append("</tr>");
                    sbBody.Append("<tr>");
                        sbBody.Append("<td>Exception Date:</td>");
                        sbBody.Append("<td>" + exception_date + "</td>");
                    sbBody.Append("</tr>");
                    sbBody.Append("<tr>");
                        sbBody.Append("<td>Logged On User:</td>");
                        sbBody.Append("<td>" + login + "</td>");
                    sbBody.Append("</tr>");
                sbBody.Append("</table>");
            }

            sbBody.Append("<p>User Message: <br/>" + txtDescription.Text + "</p>");

            return Utilities.SendEmail(to, subject, sbBody.ToString(), null, true);
        }

        private void LoadExceptionInformation()
        {
            DataSet ds = DsGetException();
            if (ds.Tables[0].Rows.Count > 0)
            {
                string exceptiontype = ds.Tables[0].Rows[0]["exceptiontype"].ToString();

                lblTitle.Text = "You encountered an unexpected exception: <font color='#333399'>" + exceptiontype + "</font>.  Exception ID#: <font color='#333399'>" + qsExceptionID + "</font>";
                lblInstructions.Text = "If you would like us to investigate the issue, please use the form below to provide us with a brief description of what you were attempting to do. You will receive an email with a call ticket that you can use to follow up on the status of this issue.";
            }
        }

        protected new void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //HideNavigation(false);
                if (!isNull(qsExceptionID))
                {
                    LoadExceptionInformation();
                }
            }
        }

        protected void lnkBtnSend_Click(object sender, EventArgs e)
        {
            bool isEmailSuccessfullySent = SendEmail();
            string sCaption = "Email Success";
            string sMsg = "Email Successfully Sent";

            if (!isEmailSuccessfullySent)
            {
                sCaption = "Email Failure";
                sMsg = "There was an error sending your message. Please send an email to <a href='mailto:ProgrammerSupport@" + Utilities.GetAppSettingFromConfig("EMAIL_DOMAIN") + "'>ProgrammerSupport</a>";
            }

            DisplayMessage(sCaption, sMsg);

            lnkBtnSend.Enabled = false; //Disable button after user already clicks.
            txtDescription.Text = ""; //Clear Text
        }

        protected void lnkBtnHome_Click(object sender, EventArgs e)
        {
            NavigateBack();
        }
    }
}