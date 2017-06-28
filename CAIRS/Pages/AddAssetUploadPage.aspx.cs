using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Pages
{
    public partial class AddAssetUploadPage : _CAIRSBasePage
    {
        protected new void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Hide Navigation
                HideNavigation(true);
            }
        }

        protected void chkLstAddType_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selectedAddType = chkLstAddType.SelectedValue;
            if(selectedAddType.Equals(Constants.ADD_ASSET_TYPE_SCAN)){
                NavigateTo(Constants.PAGES_ADD_ASSET_PAGE, false);
            }
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            string filename = FileUploadAddAsset.FileName;
            DisplayMessage("Not Implemented", "This has not been implemented. Please come back to see this feature in future releases.");
        }
    }
}