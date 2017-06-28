using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;



namespace CAIRS
{
    public partial class DDL_Site : System.Web.UI.UserControl
    {
        // Required Site defaulted to false
        public bool IsSiteRequired = false;

        // AutoPostBack
        public bool AutoPostBack = true;
        public string FieldName = "Site";
        public string ValidationGroup = "";
        public bool EnableClientScript = true;

        // Used to handle event that needs to be fired after a site has been selected
        public event EventHandler SelectedIndexChanged_DDL_Site;

        public string SelectedValue
        {
            get
            {
                return ddlSite.SelectedValue;
            }
            set
            {
                //Check to see if the selected value exists before setting it.
                ListItem i = ddlSite.Items.FindByValue(value);
                if (ddlSite.Items.Contains(i))
                {
                    ddlSite.SelectedValue = value;
                }
            }
        }


        public string SelectedText
        {
            get
            {
                return ddlSite.SelectedItem.Text;
            }
            set
            {
                ddlSite.SelectedItem.Text = value;
            }
        }


        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ddlSite.AutoPostBack = AutoPostBack;
                reqSite.Visible = IsSiteRequired;
                reqSite.ErrorMessage = "Required Field: " + FieldName;
                reqSite.ValidationGroup = ValidationGroup;
                reqSite.EnableClientScript = EnableClientScript;
            }
        }

        private void SavePreferences()
        {
            string empid = Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());
            string preference = Constants.APP_PREFERENCE_TYPE_Default_Site;
            string selectedsite = ddlSite.SelectedValue;

            DatabaseUtilities.Upsert_App_User_Preference(empid, preference, selectedsite);
        }

        public void LoadDDLSite(bool isApplySiteSecurity, bool isApplySiteSecurityToReadOnly, bool isDisplayActiveOnly, bool isDisplayPleaseSelectOption, bool isDisplayAllOption, bool isSelectUserPreferenceSite, bool isDisplaySetDefaultLink)
        {
            //This is to handle the case where security only applies to read only roles. IE the Asset Search page.
            if (isApplySiteSecurity && isApplySiteSecurityToReadOnly)
            {
                //Apply security if the current role is read only
                isApplySiteSecurity = AppSecurity.Current_User_Access_Level().Equals(AppSecurity.ROLE_READ_ONLY);
            }

            //If Role is district staff or director, they have access to all sites regardless of accessible site(s)
            if (AppSecurity.Current_User_Access_Level().Equals(AppSecurity.ROLE_DISTRICT_TECH) || AppSecurity.Current_User_Access_Level().Equals(AppSecurity.ROLE_DIRECTOR))
            {
                isApplySiteSecurity = false;
            }

            DataSet ds = DatabaseUtilities.DsGetCTSiteInfo(isDisplayActiveOnly, isApplySiteSecurity);
            int iRecordCount = ds.Tables[0].Rows.Count;
            if (iRecordCount> 0)
            {
                ddlSite.DataSource = ds;
                ddlSite.DataTextField = Constants.COLUMN_CT_SITE_Name;
                ddlSite.DataValueField = Constants.COLUMN_CT_SITE_ID; ;
                ddlSite.DataBind();
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayAllOption)
            {
                ddlSite.Items.Insert(0, new ListItem(Constants._OPTION_ALL_TEXT + "Sites ---", Constants._OPTION_ALL_VALUE));
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayPleaseSelectOption)
            {
                ddlSite.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Site ---", Constants._OPTION_PLEASE_SELECT_VALUE));
            }

            if (isSelectUserPreferenceSite)
            {
                string empid = Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());
                DataSet dsDefaultSite = DatabaseUtilities.DsGetUserPreference(empid, Constants.APP_PREFERENCE_TYPE_Default_Site);
                if (dsDefaultSite.Tables[0].Rows.Count > 0)
                {
                    string preferenceValue = dsDefaultSite.Tables[0].Rows[0]["Preference_Value"].ToString();
                    if (!Utilities.isNull(preferenceValue))
                    {
                        ListItem i = ddlSite.Items.FindByValue(preferenceValue);
                        if (ddlSite.Items.Contains(i))
                        {
                            ddlSite.SelectedValue = preferenceValue;
                        }
                    }
                }
            }
        }

        protected void SelectedIndexChanged(object sender, EventArgs e)
        {
            //Save the preference on change selected index change event
            SavePreferences();

            if (SelectedIndexChanged_DDL_Site != null)
            {
                SelectedIndexChanged_DDL_Site(sender, EventArgs.Empty);
            }
        }
    }
}