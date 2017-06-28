using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CAIRS.Pages
{
    //This page does not inherit the _CAIRSBasePage.cs file because it needs to available when we shut down the app. We handle the app shutdown the base page on_init event.
    public partial class ApplicationOfflinePage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Disable navigation
                CAIRSMasterPage ms = this.Master as CAIRSMasterPage;
                ms.IsDisplayHideNavigation = false;

                //variables to log offline status
                string recordtype = Constants.SECURITY_RECORDTYPE_STANDARD_OPERATION;
                string module = "CAIRS Application Offline";
                string description = "Application is offline";

                //Log event
                Utilities.LogEvent(recordtype, module, description);
            }
        }
    }
}