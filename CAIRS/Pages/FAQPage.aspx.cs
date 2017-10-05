using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using FreeTextBoxControls.Design;

namespace CAIRS.Pages
{
    public partial class FAQPage : _CAIRSBasePage
    {
        private void DisplayManageQandAModal(bool IsAdd)
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupMessage", "$('#divManageQandADialog').modal();", true);

            string title = "Add";

            if (!IsAdd)
            {
                title = "Edit";
            }

            lblManageQandATitleModal.Text = title + " Question and Answer";
        }

        protected new void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnHdnSubscribe_Click(object sender, EventArgs e)
        {

        }

        protected void btnHdnAddNewQandA_Click(object sender, EventArgs e)
        {
            DisplayManageQandAModal(true);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {

        }
    }
}