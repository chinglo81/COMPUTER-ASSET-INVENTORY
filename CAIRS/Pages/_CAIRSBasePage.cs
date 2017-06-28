using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Data;
using CAIRS.Navigation;
using CAIRS.Exceptions;
using System.IO;

namespace CAIRS.Pages
{
	public class _CAIRSBasePage : System.Web.UI.Page
	{
		public _CAIRSBasePage()
		{
			this.Load += new EventHandler(Page_Load);
		}
		protected string QS_ASSET_SEARCH_ID
		{
			get
			{
				return Request.QueryString["Asset_Search_ID"];
			}
		}
		protected string QS_ASSET_ID
		{
			get
			{
				return Request.QueryString["Asset_ID"];
			}
		}
		protected string QS_ASSET_SELECTED_TAB
		{
			get
			{
				return Request.QueryString["Asset_Selected_Tab"];
			}
		}
		protected string QS_STUDENT_ID
		{
			get
			{
				return Request.QueryString["Student_ID"];
			}
		}
		protected string QS_SUCCESS
		{
			get
			{
				return Request.QueryString["Success"];
			}
		}
        protected string QS_SORT_CRITERIA
        {
            get
            {
                return Request.QueryString["sort_criteria"];
            }
        }
        protected string QS_SORT_DIR
        {
            get
            {
                return Request.QueryString["sort_dir"];
            }
        }
        protected string QS_PAGE_INDEX
        {
            get
            {
                return Request.QueryString["page_index"];
            }
        }

		protected string SortCriteria
		{
			get
			{
				return ViewState["sortCriteria"].ToString();
			}
			set
			{
				ViewState["sortCriteria"] = value;
			}
		}

		protected string SortDir
		{
			get
			{
				return ViewState["sortDir"].ToString();
			}
			set
			{
				ViewState["sortDir"] = value;
			}
		}

		protected string PageIndex
		{
			get
			{
				return ViewState["PageIdex"].ToString();
			}
			set
			{
				ViewState["PageIdex"] = value;
			}
		}

		public string LoggedOnUser
		{
			get
			{
				return Utilities.GetLoggedOnUser();
			}
		}

		public string GetAppSettingFromConfig(string sKey)
		{
			return ConfigurationManager.AppSettings[sKey]; 
		}

		public static bool isNull(string sText)
		{
			return Utilities.isNull(sText);
		}

		private bool isTurnAppOffOrOn()
		{
			return Utilities.IsAppOffLine();
		}

		public static void TurnAppOffLine()
		{
			if (!Utilities.IsEnvironmentProductionMode())
			{
				if (!Utilities.IsAppOffLine())
				{
					// we still want qa and dev builds to be available when the application is offline
					return;
				}
			}
			//checks to see if application is on or offline(if it's not MCSWeb).
			if (Utilities.IsAppOffLine())
			{
				
			}
		}

		protected static string ApplicationID
		{
			get
			{
				if (!isNull(Utilities.GetApplicationID()))
				{
					return Utilities.GetApplicationID();
				}
				return "";
			}
		}

        protected void ReDrawToolTip()
        {
            string jScript = "$('[data-toggle=\"tooltip\"]').tooltip();";
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "Redraw_ToolTip", jScript, true);
        }

        protected void ReDrawPopover()
        {
            string jScript = "$('[data-toggle=popover]').popover({html: true});";
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "Redraw_Popover", jScript, true);
        }
	  
		#region Navgation
		public void HideNavigation(bool isShow)
		{
			CAIRSMasterPage ms = this.Master as CAIRSMasterPage;
			ms.IsDisplayHideNavigation = isShow;
		}

		private bool p_isPageModal = false;

		protected const string QS_ISPAGEMODAL = "isPageModal";

		protected long returnUrlId = -1;

		protected string prevUrlId
		{
			get
			{
				return Request.QueryString["prevurlid"];
			}
		}

		public MCSUrl _PageUrl;

		public MCSUrl PageUrl
		{
			get
			{
				if (_PageUrl == null)
				{
					_PageUrl = new MCSUrl(HttpContext.Current.Request.RawUrl);
				}

				return _PageUrl;
			}
		}

		protected bool IsPageModalprotected
		{
			get { return p_isPageModal; }
			set { p_isPageModal = value; }
		}

		public bool IsPageModal
		{
			get { return IsPageModalprotected; }
		}

		public long AddUrlToHistory(string sUrl)
		{
			return URLManager.InsertUrl(sUrl);
		}

		public string GetUrlById(long id)
		{
			return URLManager.GetUrl(id);
		}

		public string GetUrlById(string id)
		{
			return URLManager.GetUrl(long.Parse(id));
		}

		public void SetUrlInHistory(long id, string sUrl)
		{
			URLManager.SetUrl(id, sUrl);
		}

		public void SetUrlInHistory(long id, MCSUrl url)
		{
			URLManager.SetUrl(id, url);
		}

		/// <summary>
		/// defaults include addSelfToHistory = true and add sessionInfo= true
		/// </summary>
		/// <param name="url"></param>
		public void NavigateTo(MCSUrl url)
		{
			NavigateTo(url.ToString());
		}

		/// <summary>
		/// defaults add sessionInfo = true
		/// </summary>
		/// <param name="url"></param>
		/// <param name="addSelfToHistory"></param>
		public void NavigateTo(MCSUrl url, bool addSelfToHistory)
		{
			NavigateTo(url.ToString(), addSelfToHistory);
		}

		public void NavigateTo(string sUrl)
		{
			NavigateTo(sUrl, true);
		}

		/// <summary>
		/// defaults add sessionInfo = true
		/// </summary>
		/// <param name="sUrl"></param>
		/// <param name="addSelfToHistory"></param>
		public void NavigateTo(string sUrl, bool addSelfToHistory)
		{
			string returnId = null;
			string navigateUrl = "";

			if (IsPageModal)
			{
				MCSUrl url = new MCSUrl(sUrl);
				url.SetParameter(QS_ISPAGEMODAL, "true");
				sUrl = url.ToString();
			}

			#region Add to History
			if (addSelfToHistory)
			{
				returnId = "" + AddUrlToHistory(PageUrl.ToString());
			}
			else
			{
				returnId = returnUrlId.ToString();
			}
			#endregion

			

			#region Build return URL
			MCSUrl newUrl = new MCSUrl(sUrl);
			newUrl.SetParameter(MCSUrl.ReturnUrl, returnId);
			navigateUrl = newUrl.ToString();
			#endregion

			navigateUrl = Utilities.BuildURL(navigateUrl);
			Response.Redirect(navigateUrl);
		}

		/// <summary>
		/// Return to the calling   The calling page must add itself to the history cache before calling this page (see NavigateTo)
		/// </summary>
		public void NavigateBack()
		{
			if (returnUrlId == -1)
			{
				Response.Redirect(Utilities.GetApplicationHomePage(ApplicationID));
			}
			try
			{
				string sURL = GetUrlById(returnUrlId);
				if (!isNull(sURL))
				{
					Response.Redirect(sURL);
				}
				else
				{
					Response.Redirect(Utilities.GetApplicationHomePage(ApplicationID));
				}
			}
			catch (NoPageInHistoryException)
			{
				Response.Redirect(Utilities.GetApplicationHomePage(ApplicationID));
			}

		}

		private void processReturnURL()
		{
			string prevUrl = Request.QueryString[MCSUrl.ReturnUrl];
			if (prevUrl != null && prevUrl.Length > 0)
			{
				try
				{
					long urlId = long.Parse(prevUrl);
					try
					{
						prevUrl = GetUrlById(urlId);
					}
					catch (NoPageInHistoryException)
					{
						prevUrl = PageUrl.ToString();
					}
					returnUrlId = urlId;
				}
				catch (FormatException)
				{
					// the parameter contains the full url.  store it in the url manager.
					long urlId = AddUrlToHistory(HttpUtility.UrlDecode(prevUrl));
					PageUrl.SetParameter(MCSUrl.ReturnUrl, urlId.ToString());
					returnUrlId = urlId;
				}
			}
			else
			{
				MCSUrl eu = new MCSUrl("http://www.monet.k12.ca.us");
				prevUrl = eu.BuildURL(); //TODO make a contstant
			}
			ClientScript.RegisterHiddenField("PreviousUrl", prevUrl);
			ClientScript.RegisterHiddenField("MyUrl", PageUrl.ToString());
			ClientScript.RegisterHiddenField("ServerUrl", Utilities.GetAppPathURL());
		}

		#endregion

		/// <summary>
		/// display pop up message
		/// </summary>
		/// <param name="caption">message</param>
		/// <param name="message">message</param>
		public void DisplayMessage(string caption, string message)
		{
			CAIRSMasterPage ms = this.Master as CAIRSMasterPage;

			ms.lblModalTitle.Text = caption;
			ms.lblModalBody.Text = message;
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupMessage", "$('#popupMessage').modal();", true);
			ms.upModal.Update();
		}

		public void DisplayErrorModal(string ValidationGroup)
		{
			CAIRSMasterPage ms = this.Master as CAIRSMasterPage;
			ms.ShowHideErrorModal(true, ValidationGroup);
		}

		private string Save_Exception()
		{
				string pagename = Path.GetFileName(Request.Path);
				Exception exc = Server.GetLastError();
				return Utilities.RecordApplicationException(exc);
		}

		private void Application_Error_Logging()
		{
			//Application logging for errors
			string application_logging = GetAppSettingFromConfig("APPLICATION_ERROR_LOGGING").ToLower().Trim();

			//Check to see if the config key is set correctly. Empty string will default to false
			bool isAppLoggingSetValid = isNull(application_logging) || application_logging.Equals("true") || application_logging.Equals("false");

			//throw error for config key set incorrectly
			Utilities.Assert(isAppLoggingSetValid, "WebConfig key=APPLICATION_ERROR_LOGGING set incorrectly. Must be true or false. The key is currently set to: " + application_logging);

			//check to see if application logging is turned on
			bool is_App_Loggin_On = false;
			if (!isNull(application_logging))
			{
				is_App_Loggin_On = bool.Parse(application_logging);
			}

			if (is_App_Loggin_On)
			{
				//save exeception
				string exception_id = Save_Exception();
				NavigateTo(Constants.PAGES_ERROR_PAGE + "?Exception_ID=" + exception_id);
			}
		}

		public void Unauthorized_Access(string description)
		{
			if (isNull(description))
			{
				description = "CAIRS - Unauthorized Access";
			}

			string page_name = Path.GetFileName(Request.Path);
			string recordtype = Constants.SECURITY_RECORDTYPE_SECURITY_VIOLATION;
			string module = Constants.CAIRS_APP_MODULE_ACCESS_DENIED + " - " + page_name;
			

			//Save event
			Utilities.LogEvent(
				recordtype,
				module,
				description
			);

			//Navigate user to access denied page
			NavigateTo(Constants.PAGES_ACCESS_DENIED_PAGE, false);
		}

		private void Apply_CAIRS_To_Pages()
		{
			//Current Page
			string current_page_name = Path.GetFileName(Request.Path);

			//need to append addition string before comparing to match correctly.
			string prefix = "/Pages/";
			current_page_name = prefix + current_page_name;

			//Get the logged on user access level to process
			int iUserAccessLevel = AppSecurity.Current_User_Access_Level();

			switch (current_page_name)
			{
				//Manage Asset Site Bin 
				case Constants.PAGES_ADD_BIN_PAGE:
				
					//Access denied for read only user and below
					if (iUserAccessLevel.Equals(AppSecurity.ROLE_READ_ONLY))
					{
						Unauthorized_Access("");
					}
					break;
				case Constants.PAGES_CHECK_OUT_ASSET_PAGE:
                case Constants.PAGES_ASSET_FOLLOW_UP_PAGE:
					//Access denided for read only and director role
					if (iUserAccessLevel.Equals(AppSecurity.ROLE_READ_ONLY) || iUserAccessLevel.Equals(AppSecurity.ROLE_DIRECTOR))
					{
						Unauthorized_Access("");
					}
					break;
				case Constants.PAGES_ADD_ASSET_PAGE:
				case Constants.PAGES_CHECK_IN_ASSET_PAGE:
					//Access denied for Site Staff user and below
					if (iUserAccessLevel <= AppSecurity.ROLE_SITE_STAFF)
					{
						Unauthorized_Access("");
					}
					break;
				default:
					break;
			}
		}

		protected void CloseModal(string modalid)
		{
            Utilities.CloseModal(Page, modalid);
		}

		/// <summary>
		/// Collection of pages to ignore for security processing
		/// </summary>
		/// <returns></returns>
		private ListItemCollection liPagesToIgnoreSecurity()
		{
			ListItemCollection collection = new ListItemCollection();

			collection.Add(Constants.PAGES_ACCESS_DENIED_PAGE);

			return collection;
		}

		private void Apply_CAIRS_Page_Access_Security()
		{
			//Current Page
			string current_page_name = Path.GetFileName(Request.Path);

			//need to append addition string before comparing to match correctly.
			string prefix = "/Pages/";
			current_page_name = prefix + current_page_name;

			ListItem liCurrentPage = liPagesToIgnoreSecurity().FindByValue(current_page_name);

			//Ignore the page if they are in the list of pages to ignore security
			//if user does not have access
			if (!AppSecurity.hasAccess() && !liPagesToIgnoreSecurity().Contains(liCurrentPage))
			{
				Unauthorized_Access("");
			}
			else
			{
				//Don't allow access to page
				Apply_CAIRS_To_Pages();
			}
		}
		
		/// <summary>
		/// This method is to prevent security creditials to call the database multiple times. Once the creditial is stored in session, it will only query the database again once the session expires
		/// </summary>
		private void SetCurrentUserSecurityCredentials()
		{
			//This is to prevent security call multiple times
			//Access Level
			if (Session["current_user_access_level"] != null)
			{
				string session_current_user_level = Session["current_user_access_level"].ToString();
				AppSecurity.Current_Login_Security_Access_Level = int.Parse(session_current_user_level);
			}
			else
			{
				int current_user_security = AppSecurity.Get_Current_User_Access_Level();
				Session["current_user_access_level"] = current_user_security.ToString();
				AppSecurity.Current_Login_Security_Access_Level = current_user_security;
			}

			//Accessible Sites
			if (Session["current_user_accessible_sites"] != null)
			{
				string session_accessible_sites = Session["current_user_accessible_sites"].ToString();
				AppSecurity.Current_Login_Accessible_Sites = session_accessible_sites;
			}
			else
			{
				string session_accessible_sites = AppSecurity.Get_Current_User_Accessible_Site();
				Session["current_user_accessible_sites"] = session_accessible_sites;
				AppSecurity.Current_Login_Accessible_Sites = session_accessible_sites;
			}
		}

		protected override void OnError(EventArgs e)
		{
			Application_Error_Logging();
		}

		protected override void OnInit(EventArgs e)
		{
			if (Utilities.IsAppOffLine())
			{
				NavigateTo(Constants.PAGES_APPLICATION_OFFLINE_PAGE, false);
			}
		}

		protected void Page_Load(object sender, EventArgs args)
		{
			if (!IsPostBack) 
			{ 
				//Set current user security credentials
				SetCurrentUserSecurityCredentials();

				//Apply Page Security
				Apply_CAIRS_Page_Access_Security();
				Utilities.Log_App_Activity(Request);
			}

			//This needs to be called on every postback for navigation to work properly
			processReturnURL();
		}
	}
}