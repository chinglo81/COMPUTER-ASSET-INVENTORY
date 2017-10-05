using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Reporting.WebForms;
using System.Data;

namespace CAIRS.Pages
{
    public partial class AssetReportPage : _CAIRSBasePage
    {
        private string qsAdvSearch
        {
            get
            {
                if (isNull(Request.QueryString["AdvSearch"]))
                {
                    return "N";
                }
                else
                {
                    return Request.QueryString["AdvSearch"];
                }
            }
        }

        private string qsReportID
        {
            get
            {
                return Request.QueryString["Report_ID"];
            }
        }

        private void DisplayReportSQL(string report_id)
        {
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.TBL_REPORTS, Constants.COLUMN_REPORTS_ID, report_id, "");
            SSRS_ReportViewer.Visible = false;
            if (ds.Tables[0].Rows.Count > 0)
            {
                SSRS_ReportViewer.Visible = true;
                string sReportName = ds.Tables[0].Rows[0][Constants.COLUMN_REPORTS_Report_Name].ToString();
                string sReportFolder = ds.Tables[0].Rows[0][Constants.COLUMN_REPORTS_Report_Folder].ToString();

                string urldbServer = "http://" + System.Configuration.ConfigurationManager.AppSettings.Get("DB_SERVER");
                string reportServerName = System.Configuration.ConfigurationManager.AppSettings.Get("REPORTSERVER_URL");
                string urlReportServer = urldbServer + reportServerName;

                SSRS_ReportViewer.ServerReport.ReportServerUrl = new System.Uri(urlReportServer);

                SSRS_ReportViewer.ServerReport.ReportPath = "/" + sReportFolder + "/" + sReportName;

                SSRS_ReportViewer.PageCountMode = PageCountMode.Estimate;  //Use this to show actual or estimated page count
                SSRS_ReportViewer.ServerReport.Refresh();
                //failed attempt to set focus to the report control and away from the 'Retrieve Report' button
                SSRS_ReportViewer.Focus();

            }

        }

        private void LoadReportsDDL()
        {
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.TBL_REPORTS, Constants.COLUMN_REPORTS_Is_Active, "1", Constants.COLUMN_REPORTS_Report_Display_Name);

            int iRowCount = ds.Tables[0].Rows.Count;

            if (iRowCount > 0)
            {
                ddlReports.DataSource = ds;
                ddlReports.DataValueField = Constants.COLUMN_REPORTS_ID;
                ddlReports.DataTextField = Constants.COLUMN_REPORTS_Report_Display_Name;
                ddlReports.DataBind();

                if (iRowCount > 1)
                {
                    ddlReports.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Report ---", Constants._OPTION_PLEASE_SELECT_VALUE));
                }
            }
        }

        protected new void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SSRS_ReportViewer.Visible = false;
                LoadReportsDDL();

                if (!isNull(qsReportID))
                {
                    ddlReports.SelectedValue = qsReportID;
                    DisplayReportSQL(ddlReports.SelectedValue);
                }

            }
        }

        protected void ddlReports_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selected_report = ddlReports.SelectedValue;
            lblPleaseSelectReport.Text = "Please select a report.";
            SSRS_ReportViewer.Visible = false;

            if (!selected_report.Contains("-"))
            {
                lblPleaseSelectReport.Text = "";
                DisplayReportSQL(selected_report);
            }
        }

    }
}