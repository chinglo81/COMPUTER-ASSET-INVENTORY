using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class TAB_Changes : System.Web.UI.UserControl
    {
        protected string QS_ASSET_ID
        {
            get
            {
                return Request.QueryString["Asset_ID"];
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        public void LoadChangesDG(int iPageIndex)
        {
            string Asset_ID = QS_ASSET_ID;
            string sortby = "v.id desc";
            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_CHANGES, Asset_ID, "", sortby);

            dgChanges.Visible = false;
            lblResults.Text = "No changes(s) found for this asset";
            if (ds.Tables[0].Rows.Count > 0)
            {
                lblResults.Text = "";
                
                dgChanges.CurrentPageIndex = iPageIndex;
                dgChanges.Visible = true;
                dgChanges.DataSource = ds;
                dgChanges.DataBind();
            }
        }

        protected void dgChanges_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            LoadChangesDG(e.NewPageIndex);
        }
    }
}