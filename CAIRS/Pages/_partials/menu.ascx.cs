using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CAIRS.Pages._partials
{
	public partial class menu : System.Web.UI.UserControl
	{
		protected void Page_Load(object sender, EventArgs e)
		{

		}

		// Scanner links
		public void DisplayNoFileFound()
		{
			string fileTitle = "No File Found.";
			string body = "Please contact <a href='mailto:ProgrammerSupport@monet.k12.ca.us' class='btn btn-default btn-xs'>Programmer Support</a>";

			_CAIRSBasePage c = new _CAIRSBasePage();
			c.DisplayMessage(fileTitle, body);
		}

		protected void lnkBtnDocumentProgramBarcode_Click(object sender, EventArgs e)
		{
            string file = Utilities.GetAppSettingFromConfig("DOCUMENT_SCANNER_PROGRAM");
            string filePath = Utilities.GetDocumentationFolderLocation() + "\\" + file;

			if (!Utilities.ViewAnyDocument(filePath, Response))
			{
				DisplayNoFileFound();
			}
		}

		protected void lnkBtnDocumentBarcodeManual_Click(object sender, EventArgs e)
		{
			string file = Utilities.GetAppSettingFromConfig("DOCUMENT_SCANNER_MANUAL");
            string filePath = Utilities.GetDocumentationFolderLocation() + "\\" + file;

			if (!Utilities.ViewAnyDocument(filePath, Response))
			{
				DisplayNoFileFound();
			}
		}

        protected void lnkBtnUserGuide_Click(object sender, EventArgs e)
        {
            string file = Utilities.GetAppSettingFromConfig("CAIRS_USER_GUIDE");
            string filePath = Utilities.GetDocumentationFolderLocation() + "\\" + file;

            if (!Utilities.ViewAnyDocument(filePath, Response))
            {
                DisplayNoFileFound();
            }
        }
	}
}