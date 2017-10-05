using System;
using System.Collections;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Odbc;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Net.Mail;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Linq;
using System.Security.Principal;

using System.Text.RegularExpressions;

namespace CAIRS
{
    public class AppSecurity
    {
        //Application Role
        /// <summary>
        /// View only access to selected site(s).
        /// </summary>
        public const int ROLE_READ_ONLY = 10;

        /// <summary>
        /// Ability to check out assets from their assigned site(s); Ability to view everything.
        /// </summary>
        public const int ROLE_SITE_STAFF = 20;

        /// <summary>
        /// Ability to transfer assets between sites; Ability to view everything.
        /// </summary>
        public const int ROLE_DIRECTOR = 30;

        /// <summary>
        /// Ability to perform all functions for their assigned site(s); Ability to view everything.
        /// </summary>
        public const int ROLE_SITE_TECH = 40;

        /// <summary>
        /// Ability to perform all functions for all sites; Ability to view everything.
        /// </summary>
        public const int ROLE_DISTRICT_TECH = 50;

        public const string SECURITY_LEVEL_DISABLED = "Security_Level_Disabled";

        public const string SECURITY_SITE_CODE = "Security_Site_Code";

        public static int Current_Login_Security_Access_Level = 0;
        public static string Current_Login_Accessible_Sites = "";

        public static int Current_User_Access_Level()
        {
            int iSecurityLevel = Current_Login_Security_Access_Level;
            if (iSecurityLevel.Equals(0))
            {
                iSecurityLevel = Get_Current_User_Access_Level();
            }
            return iSecurityLevel;
        }

        public static string Current_User_Site_Access()
        {
            //0 - Default - Initialize
            //1 - All Site
            //2 - Work Site
            //3 - Custom

            string site_access = "0";

            DataSet ds = DatabaseUtilities.DsGetUserSecurityInfo(Utilities.GetLoggedOnUser());
            if (ds.Tables[0].Rows.Count > 0)
            {
                site_access = ds.Tables[0].Rows[0]["includedsites"].ToString();
            }
            return site_access;

        }

        public static string Current_User_Accessible_Site()
        {
            string accessibleSites = Current_Login_Accessible_Sites;
            if (Utilities.isNull(accessibleSites))
            {
                accessibleSites = Get_Current_User_Accessible_Site();
            }
            return accessibleSites;
        }

        public static bool hasAccess()
        {
            DataSet ds = DatabaseUtilities.DsGetUserSecurityInfo(Utilities.GetLoggedOnUser());
            return ds.Tables[0].Rows.Count > 0;
        }

        public static int Get_Current_User_Access_Level()
        {
            DataSet ds = DatabaseUtilities.DsGetUserSecurityInfo(Utilities.GetLoggedOnUser());
            if (ds.Tables[0].Rows.Count > 0)
            {
                string accesslevel = ds.Tables[0].Rows[0]["AccessLevel"].ToString();
                Utilities.Assert(Utilities.IsNumeric(accesslevel), "Access Level is not numberic. Please email programmersupport to resolve your issue.");

                return int.Parse(accesslevel);
            }
            return 0;
        }

        public static string Get_Current_User_Accessible_Site()
        {
            string accessible_site = "";
            DataSet ds = DatabaseUtilities.DsGetUserSecurityInfo(Utilities.GetLoggedOnUser());
            if (ds.Tables[0].Rows.Count > 0)
            {
                accessible_site = ds.Tables[0].Rows[0]["User_Access_Site"].ToString();
            }
            return accessible_site;
        }

        public static string Get_Current_User_Accessible_Site_Desc()
        {
            string accessible_site = "";
            DataSet ds = DatabaseUtilities.DsGetUserSecurityInfo(Utilities.GetLoggedOnUser());
            if (ds.Tables[0].Rows.Count > 0)
            {
                accessible_site = ds.Tables[0].Rows[0]["User_Access_Site_Desc"].ToString();
            }
            return accessible_site;
        }

        /// <summary>
        /// Need to get Real Logged on user for security admin
        /// </summary>
        /// <returns></returns>
        public static bool Is_User_Security_Admin()
        {
            DataSet ds = DatabaseUtilities.DsGetUserSecurityInfo(Utilities.GetRealLoggedOnUser());
            if (ds.Tables[0].Rows.Count > 0)
            {
                return Convert.ToBoolean(ds.Tables[0].Rows[0]["Is_Security_Admin"].ToString());
            }
            return false;
        }


        private static string Get_Asset_Site_Code_By_ID(string asset_id)
        {
            DataSet ds = DatabaseUtilities.DsGetAssetInfoByID(asset_id);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string site_code = ds.Tables[0].Rows[0]["Asset_Site_Code"].ToString();
                if (!Utilities.isNull(site_code))
                {
                    return site_code;
                }
            }
            return "";
        }

        private static string Get_Asset_Temp_Header_Site_Code_By_ID(string header_id)
        {
            DataSet ds = DatabaseUtilities.DsGetAssetHeaderMostRecentDetail(header_id);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string site_code = ds.Tables[0].Rows[0]["Asset_Site_Code"].ToString();
                if (!Utilities.isNull(site_code))
                {
                    return site_code;
                }
            }
            return "";
        }

        private static bool isDisabledControl(int iCurrentUserSecurityAccessLevel, string sCurrentAccessibleSite, string security_level_list, string security_site_code)
        {
            //if user does not have access to the app, return false
            if (iCurrentUserSecurityAccessLevel.Equals(0))
            {
                return false;
            }

            //Return true if security level and security site are both empty
            if (Utilities.isNull(security_level_list) && Utilities.isNull(security_site_code))
            {
                return true;
            }

            //If user do not have access, disable 
            if (iCurrentUserSecurityAccessLevel.Equals(0))
            {
                return false;
            }

            bool isDistrictTech = iCurrentUserSecurityAccessLevel.Equals(ROLE_DISTRICT_TECH);
            bool isSiteTechWithAllSites = iCurrentUserSecurityAccessLevel.Equals(ROLE_SITE_TECH) && Current_User_Site_Access().Equals("1");

            //District tech has full access regardless of selected site(s)
            if (isDistrictTech || isSiteTechWithAllSites)
            {
                return true;
            }

            //Process Role first
            //process only if Security_Level_Disabled attribute value exist 
            if (!Utilities.isNull(security_level_list))
            {
                //Get comma sepearated list and put them into an array to process
                string[] arrLevels = security_level_list.Split(',');

                foreach (string single_security_leve in arrLevels)
                {
                    //check to see if each of the security level is not null and is numeric
                    if (!Utilities.isNull(single_security_leve) && Utilities.IsNumeric(single_security_leve))
                    {
                        int iSecurityLevel = int.Parse(single_security_leve);
                        //if the access level on the attribute matches, disable the control
                        if (iCurrentUserSecurityAccessLevel.Equals(iSecurityLevel))
                        {
                            return false;
                        }
                    }
                }
            }
           
            //Process site security 
            //Check to see if need to disable for site
            //Check to to see if site level security exist
            if (!Utilities.isNull(security_site_code))
            {
                //if the site does not contain in the list of site the user is, disable the control.
                string[] arrSiteLevel = sCurrentAccessibleSite.Split(',');
                if (!arrSiteLevel.Contains(security_site_code))
                {
                    return false;
                }
            }

            //default to true
            return true;
        }

        #region Commented - OLD
        /*
        public static void Apply_CAIRS_Security_To_Control(System.Web.UI.Control cnt)
        {
            //get user security level
            int iCurrentUserSecurityAccessLevel = Current_User_Access_Level();
            string sCurrentAccessibleSite = Current_User_Accessible_Site();

            //Loop thru the control to see if there are child control
            foreach (Control c in cnt.Controls)
            {
                bool hasChildControl = c.HasControls();

                //does control have child control
                if (hasChildControl)
                {
                    //Recursive
                    Apply_CAIRS_Security_To_Control(c);
                }
                else
                {
                    //look for attribute to disable
                    string security_disable = SECURITY_LEVEL_DISABLED;
                    string security_site_code = SECURITY_SITE_CODE;

                    #region Search for Control Type

                    //Datagrid
                    if (c is DataGrid)
                    {
                        DateTime start = DateTime.Now;
                        DataGrid dg = (DataGrid)c;

                        int iControlCont = dg.Controls.Count;

                        foreach (Control dg_control in dg.Controls)
                        {
                            //Recursive
                            //Apply_CAIRS_Security_To_Control(dg_control);
                        }

                        string durartion = DateTime.Now.Subtract(start).TotalSeconds.ToString();
                    }

                    //HyperLink
                    if (c is HyperLink)
                    {
                        HyperLink hyp = (HyperLink)c;

                        //get the security level on the attribute
                        string sSecurityLevel = hyp.Attributes[security_disable];
                        string sSecuritySite = hyp.Attributes[security_site_code];

                        hyp.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                    }

                    //Button
                    if (c is Button)
                    {
                        Button btn = (Button)c;

                        //get the security level on the attribute
                        string sSecurityLevel = btn.Attributes[security_disable];
                        string sSecuritySite = btn.Attributes[security_site_code];

                        //if the button is enabled, run thru logic. If enabled is false, leave it the way it is 
                        if (btn.Enabled)
                        {
                            btn.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                        }
                    }

                    //LinkButton
                    if (c is LinkButton)
                    {
                        LinkButton lnkbtn = (LinkButton)c;

                        //get the security level on the attribute
                        string sSecurityLevel = lnkbtn.Attributes[security_disable];
                        string sSecuritySite = lnkbtn.Attributes[security_site_code];

                        //if the lnkBth is enabled, run thru logic. If enabled is false, leave it the way it is
                        if (lnkbtn.Enabled)
                        {
                            lnkbtn.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                        }
                    }

                    //Textbox
                    if (c is TextBox)
                    {
                        TextBox txt = (TextBox)c;
                        //get the security level on the attribute
                        string sSecurityLevel = txt.Attributes[security_disable];
                        string sSecuritySite = txt.Attributes[security_site_code];

                        txt.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                    }
                    //Drop Down List
                    if (c is DropDownList)
                    {
                        DropDownList ddl = (DropDownList)c;
                        //get the security level on the attribute
                        string sSecurityLevel = ddl.Attributes[security_disable];
                        string sSecuritySite = ddl.Attributes[security_site_code];

                        ddl.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                    }

                    //CheckBox
                    if (c is CheckBox)
                    {
                        CheckBox chk = (CheckBox)c;
                        //get the security level on the attribute
                        string sSecurityLevel = chk.Attributes[security_disable];
                        string sSecuritySite = chk.Attributes[security_site_code];

                        chk.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                    }

                    //Listbox
                    if (c is ListBox)
                    {
                        ListBox lst = (ListBox)c;
                        //get the security level on the attribute
                        string sSecurityLevel = lst.Attributes[security_disable];
                        string sSecuritySite = lst.Attributes[security_site_code];

                        lst.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                    }

                    //CheckBoxList
                    if (c is CheckBoxList)
                    {
                        CheckBoxList chklst = (CheckBoxList)c;
                        //get the security level on the attribute
                        string sSecurityLevel = chklst.Attributes[security_disable];
                        string sSecuritySite = chklst.Attributes[security_site_code];

                        chklst.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                    }

                    #endregion
                }
            }
        }

        */
        #endregion

        public static void Apply_CAIRS_Security_To_Single_Control(System.Web.UI.Control cnt)
        {

            //get user security level
            int iCurrentUserSecurityAccessLevel = Current_User_Access_Level();
            string sCurrentAccessibleSite = Current_User_Accessible_Site();

            bool hasChildControl = cnt.HasControls();
            if (hasChildControl)
            {
                foreach (Control c in cnt.Controls)
                {
                    Apply_CAIRS_Security_To_Single_Control(c);
                }
            }
            else
            {
                //look for attribute to disable
                string security_disable = SECURITY_LEVEL_DISABLED;
                string security_site_code = SECURITY_SITE_CODE;
                string access_msg = "Access Denied";

                #region Search for Control Type

                //Datagrid
                if (cnt is DataGrid)
                {
                    DateTime start = DateTime.Now;
                    DataGrid dg = (DataGrid)cnt;

                    int iControlCont = dg.Controls.Count;

                    foreach (Control dg_control in dg.Controls)
                    {
                        //Recursive
                        Apply_CAIRS_Security_To_Single_Control(dg_control);
                    }
                }

                //HyperLink
                if (cnt is HyperLink)
                {
                    HyperLink hyp = (HyperLink)cnt;

                    //get the security level on the attribute
                    string sSecurityLevel = hyp.Attributes[security_disable];
                    string sSecuritySite = hyp.Attributes[security_site_code];
                    bool isDisabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);

                    hyp.Enabled = isDisabled;

                    if (!isDisabled)
                    {
                        hyp.ToolTip = access_msg;    
                    }
                }

                //Button
                if (cnt is Button)
                {
                    Button btn = (Button)cnt;

                    //get the security level on the attribute
                    string sSecurityLevel = btn.Attributes[security_disable];
                    string sSecuritySite = btn.Attributes[security_site_code];
                    bool isDisabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);

                    //if the button is enabled, run thru logic. If enabled is false, leave it the way it is 
                    //if (btn.Enabled)
                    //{
                    btn.Enabled = isDisabled;
                    //}

                    if (!isDisabled)
                    {
                        btn.ToolTip = access_msg;
                        
                    }
                }

                //LinkButton
                if (cnt is LinkButton)
                {
                    LinkButton lnkbtn = (LinkButton)cnt;

                    //get the security level on the attribute
                    string sSecurityLevel = lnkbtn.Attributes[security_disable];
                    string sSecuritySite = lnkbtn.Attributes[security_site_code];
                    bool isDisabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);

                    //if the lnkBtn is enabled, run thru logic. If enabled is false, leave it the way it is
                    if (lnkbtn.Enabled)
                    {
                        lnkbtn.Enabled = isDisabled;
                        
                        if (!isDisabled)
                        {
                            lnkbtn.ToolTip = access_msg;
                        }
                    }
                }

                //Textbox
                if (cnt is TextBox)
                {
                    TextBox txt = (TextBox)cnt;
                    //get the security level on the attribute
                    string sSecurityLevel = txt.Attributes[security_disable];
                    string sSecuritySite = txt.Attributes[security_site_code];

                    txt.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                }
                //Drop Down List
                if (cnt is DropDownList)
                {
                    DropDownList ddl = (DropDownList)cnt;
                    //get the security level on the attribute
                    string sSecurityLevel = ddl.Attributes[security_disable];
                    string sSecuritySite = ddl.Attributes[security_site_code];

                    ddl.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                }

                //CheckBox
                if (cnt is CheckBox)
                {
                    CheckBox chk = (CheckBox)cnt;
                    //get the security level on the attribute
                    string sSecurityLevel = chk.Attributes[security_disable];
                    string sSecuritySite = chk.Attributes[security_site_code];

                    chk.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                }

                //Listbox
                if (cnt is ListBox)
                {
                    ListBox lst = (ListBox)cnt;
                    //get the security level on the attribute
                    string sSecurityLevel = lst.Attributes[security_disable];
                    string sSecuritySite = lst.Attributes[security_site_code];

                    lst.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                }

                //CheckBoxList
                if (cnt is CheckBoxList)
                {
                    CheckBoxList chklst = (CheckBoxList)cnt;
                    //get the security level on the attribute
                    string sSecurityLevel = chklst.Attributes[security_disable];
                    string sSecuritySite = chklst.Attributes[security_site_code];

                    chklst.Enabled = isDisabledControl(iCurrentUserSecurityAccessLevel, sCurrentAccessibleSite, sSecurityLevel, sSecuritySite);
                }

                #endregion
            }
        }

        public static void Apply_CAIRS_Security_To_UserControls(ControlCollection controlCollection)
        {
            //Disable/Enable control base on security access
            foreach (Control c in controlCollection)
            {
                Apply_CAIRS_Security_To_Single_Control(c);
            }
        }

        public static bool Can_View_Asset_Temp_Header(string headerid)
        {
            //Get the current user role
            int iCurrentSecurityRole = Current_User_Access_Level();

            //District Tech and Director can view all asset temp
            if (iCurrentSecurityRole.Equals(ROLE_DISTRICT_TECH) || iCurrentSecurityRole.Equals(ROLE_DIRECTOR))
            {
                return true;
            }

            //Site role is tech
            if (iCurrentSecurityRole.Equals(ROLE_SITE_TECH))
            {
                string asset_site_code = Get_Asset_Temp_Header_Site_Code_By_ID(headerid);
                //Get User accessible site
                string user_acccessible_site = Current_User_Accessible_Site();

                //Can user access site?
                //Get comma sepearated list and put them into an array to process
                string[] arrAccessibleSite = user_acccessible_site.Split(',');

                //Loop thru the user accessible site(s)
                foreach (string site in arrAccessibleSite)
                {
                    //If matches return true
                    if (site.Equals(asset_site_code))
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        public static bool Can_View_Site_Asset(string asset_id)
        {   
            //Get the current user role
            int iCurrentSecurityRole = Current_User_Access_Level();
            
            //Readonly Role is the only one that cannont view all site asset.
            if (!iCurrentSecurityRole.Equals(ROLE_READ_ONLY))
            {
                return true;
            }
            else
            {
                //Get asset site
                string asset_site_code = Get_Asset_Site_Code_By_ID(asset_id);

                //Get User accessible site
                string user_acccessible_site = Current_User_Accessible_Site();

                //Can user access site?
                //Get comma sepearated list and put them into an array to process
                string[] arrAccessibleSite = user_acccessible_site.Split(',');

                //Loop thru the user accessible site(s)
                foreach (string site in arrAccessibleSite)
                {
                    //If matches return true
                    if (site.Equals(asset_site_code))
                    {
                        return true;
                    }
                }
            }

            //Default to false
            return false;
        }

        public static bool Can_Edit_Site_Asset(string asset_id)
        {
            //Get the current user role
            int iCurrentSecurityRole = Current_User_Access_Level();

            //District tech has access to edit all asset regardless of site
            if (iCurrentSecurityRole.Equals(ROLE_DISTRICT_TECH))
            {
                return true;
            }

            //Site Tech only has access if the asset is part of their accessible site(s)
            if (iCurrentSecurityRole.Equals(ROLE_SITE_TECH))
            {
                //Get asset site
                string asset_site_code = Get_Asset_Site_Code_By_ID(asset_id);

                //Get User accessible site
                string user_acccessible_site = Current_User_Accessible_Site();

                //Get comma sepearated list and put them into an array to process
                string[] arrAccessibleSite = user_acccessible_site.Split(',');

                //Loop thru the user accessible site(s)
                foreach (string site in arrAccessibleSite)
                {
                    //If matches return true
                    if (site.Equals(asset_site_code))
                    {
                        return true;
                    }
                }
            }

            //All other does not have edit rights
            return false;
        }
    }
}