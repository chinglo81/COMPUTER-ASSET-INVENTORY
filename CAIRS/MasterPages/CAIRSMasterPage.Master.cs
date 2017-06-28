using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Configuration;
using System.Collections;

namespace CAIRS
{
    public partial class CAIRSMasterPage : System.Web.UI.MasterPage
    {
        protected void MenuItemDataBound(object o, MenuEventArgs e)
        {
            Menu menu = (Menu)o;
            SiteMapNode mapNode = (SiteMapNode)e.Item.DataItem;

            if (e.Item.Text.Equals("Home"))
            {
                menu.Target = "_parent";
            }

        }

        public void ShowHideErrorModal(bool showModal, string validationgroup)
        {
            vsValidationSummary.ValidationGroup = validationgroup;
            mpxValidation.Hide();
            if (showModal)
            {
                mpxValidation.Show();
                btnOkValidation.Focus();
            }
        }

        public bool IsDisplayHideNavigation = true;

        private void ShowHideChangeLogin(bool IsShow)
        {
            lnkBtnChangeLogin.Visible = !IsShow;
            divChangeLogin.Visible = IsShow;

            //Clear employee 
            txtEmployeeLookup.ClearSelection();

            if (IsShow)
            {
                txtEmployeeLookup.txtEmployeeLookup.Focus();
            }
        }

        private void SaveSessionInfo()
        {
            //Store new login in session
            Session["login"] = Utilities.GetEmployeeLoginById(txtEmployeeLookup.SelectedEmployeeID);
            Utilities.GetSetLoggedOnUser = Session["login"].ToString();

            //Refresh security credentials
            //Access Role
            int current_user_security = AppSecurity.Get_Current_User_Access_Level();
            Session["current_user_access_level"] = current_user_security.ToString();
            AppSecurity.Current_Login_Security_Access_Level = current_user_security;

            //Accessible Sites
            string session_accessible_sites = AppSecurity.Get_Current_User_Accessible_Site();
            Session["current_user_accessible_sites"] = session_accessible_sites;
            AppSecurity.Current_Login_Accessible_Sites = session_accessible_sites;

            //Reload logged on user
            lblLoggedOnUser.Text = "Welcome " + Utilities.GetEmployeeDisplayName(Utilities.GetLoggedOnUser()) + "!";


            //Apply security to navigation. 
            AppSecurity.Apply_CAIRS_Security_To_UserControls(menu.Controls);
        }

        private void SetDevHeaderMenuStyle()
        {
            //Only set this if environment is not production
            string dbserver = Utilities.GetAppSettingFromConfig("DB_SERVER").Trim().ToUpper();
            bool IsProdEnvironment = Utilities.IsEnvironmentProductionMode();
            
            if (!IsProdEnvironment || !dbserver.Equals("RENO-SQLIS"))
            {
                string jquery = @"  $('#global-header').css('background-color', '#FF8C00');
                                $('#divDevelopment').css('background-color', '#FFD700');
                            ";

                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "DevelopmentStyle", jquery, true);

                
                string dbType = "";
                if (dbserver.Equals("RENO-SQLIS"))
                {
                    dbType = "****WARNING PROD DB****";
                }

                string environment = "DEVELOPMENT";
                if (IsProdEnvironment)
                {
                    environment = "PRODUCTION";
                }

                lblDatabase.ForeColor = System.Drawing.Color.Black;
                lblDatabase.Text =  environment + " - " + dbType  + dbserver;
            }
            
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            SetDevHeaderMenuStyle();
            
            string page = Path.GetFileName(Request.Path);
            if (!IsPostBack)
            {
                if (Session["login"] != null)
                {
                    Utilities.GetSetLoggedOnUser = Session["login"].ToString();
                }

                lblLoggedOnUser.Text = "Welcome " + Utilities.GetEmployeeDisplayName(Utilities.GetLoggedOnUser()) + "!";
                menu.Visible = IsDisplayHideNavigation;
                divMenuPlaceHolder.Visible = !IsDisplayHideNavigation;

                bool Is_Security_Admin = AppSecurity.Is_User_Security_Admin();
                lnkBtnChangeLogin.Visible = !Utilities.IsEnvironmentProductionMode() && Is_Security_Admin;

                //Apply security to navigation. 
                AppSecurity.Apply_CAIRS_Security_To_UserControls(menu.Controls);
            }

        }

        protected void lnkBtnChangeLogin_Click(object sender, EventArgs e)
        {
            ShowHideChangeLogin(true);
        }

        protected void lnkSaveChangeLogin_Click(object sender, EventArgs e)
        {
            SaveSessionInfo();
            
            ShowHideChangeLogin(false);

            //Redirect user to the same page
            Response.Redirect(HttpContext.Current.Request.Url.AbsoluteUri);
        }

        protected void lnkCancelChangeLogin_Click(object sender, EventArgs e)
        {
            ShowHideChangeLogin(false);
        }
    }
}