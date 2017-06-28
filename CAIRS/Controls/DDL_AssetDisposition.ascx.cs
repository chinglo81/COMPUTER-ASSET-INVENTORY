using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class DDL_AssetDisposition : System.Web.UI.UserControl
    {
        /// <summary>
        /// Required Site defaulted to false
        /// </summary>
        public bool IsAssetDispositionRequired = false;

        /// <summary>
        /// AutoPostBack
        /// </summary>
        public bool AutoPostBack = false;
        public string FieldName = "Asset Disposition";
        public string ValidationGroup = "";
        /// <summary>
        /// Used to handle event that needs to be fired after this a site has been selected
        /// </summary>
        public event EventHandler SelectedIndexChanged_DDL_AssetDisposition;
        public string SelectedValue
        {
            get
            {
                return ddlAssetDisposition.SelectedValue;
            }
            set
            {
                //Check to see if the selected value exists before setting it.
                ListItem i = ddlAssetDisposition.Items.FindByValue(value);
                if (ddlAssetDisposition.Items.Contains(i))
                {
                    ddlAssetDisposition.SelectedValue = value;
                }
            }
        }
        public string SelectedText
        {
            get
            {
                return ddlAssetDisposition.SelectedItem.Text;
            }
            set
            {
                ddlAssetDisposition.SelectedItem.Text = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Utilities.AddBootStrapCSSForDDL(ddlAssetDisposition);
                ddlAssetDisposition.AutoPostBack = AutoPostBack;
                reqAssetDisposition.Visible = IsAssetDispositionRequired;
                reqAssetDisposition.ErrorMessage = "Required Field: " + FieldName;
                reqAssetDisposition.ValidationGroup = ValidationGroup;
            }
        }

        public void LoadDDLAssetDisposition(string businessRuleList, bool isDisplayActiveOnly, bool isDisplayPleaseSelectOption, bool isDisplayAllOption)
        {
            DataSet ds = DatabaseUtilities.DsGetDisposition(isDisplayActiveOnly, businessRuleList, Constants.COLUMN_CT_ASSET_DISPOSITION_Name);
            int iRecordCount = ds.Tables[0].Rows.Count;
            if (iRecordCount > 0)
            {
                ddlAssetDisposition.DataSource = ds;
                ddlAssetDisposition.DataTextField = Constants.COLUMN_CT_ASSET_DISPOSITION_Name;
                ddlAssetDisposition.DataValueField = Constants.COLUMN_CT_ASSET_DISPOSITION_ID;
                ddlAssetDisposition.DataBind();
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayAllOption)
            {
                ddlAssetDisposition.Items.Insert(0, new ListItem(Constants._OPTION_ALL_TEXT + "Dispositions ---", Constants._OPTION_ALL_VALUE));
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayPleaseSelectOption)
            {
                ddlAssetDisposition.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Disposition ---", Constants._OPTION_PLEASE_SELECT_VALUE));
            }
        }

        protected void SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SelectedIndexChanged_DDL_AssetDisposition != null)
            {
                SelectedIndexChanged_DDL_AssetDisposition(sender, EventArgs.Empty);
            }
        }
    }
}