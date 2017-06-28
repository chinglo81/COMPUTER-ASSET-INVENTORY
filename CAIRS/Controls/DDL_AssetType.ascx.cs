using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class DDL_AssetType : System.Web.UI.UserControl
    {
        /// <summary>
        /// Required Site defaulted to false
        /// </summary>
        public bool IsAssetTypeRequired = false;

        /// <summary>
        /// AutoPostBack
        /// </summary>
        public bool AutoPostBack = false;
        public string FieldName = "Asset Type";
        public string ValidationGroup = "";
        /// <summary>
        /// Used to handle event that needs to be fired after this a site has been selected
        /// </summary>
        public event EventHandler SelectedIndexChanged_DDL_AssetType;
        public string SelectedValue
        {
            get
            {
                return ddlAssetType.SelectedValue;
            }
            set
            {
                //Check to see if the selected value exists before setting it.
                ListItem i = ddlAssetType.Items.FindByValue(value);
                if (ddlAssetType.Items.Contains(i))
                {
                    ddlAssetType.SelectedValue = value;
                }
            }
        }
        public string SelectedText
        {
            get
            {
                return ddlAssetType.SelectedItem.Text;
            }
            set
            {
                ddlAssetType.SelectedItem.Text = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Utilities.AddBootStrapCSSForDDL(ddlAssetType);
                ddlAssetType.AutoPostBack = AutoPostBack;
                reqAssetType.Visible = IsAssetTypeRequired;
                reqAssetType.ErrorMessage = "Required Field: " + FieldName;
                reqAssetType.ValidationGroup = ValidationGroup;
            }
        }

        public void LoadDDLAssetType(string Asset_base_Type_ID, bool isDisplayActiveOnly, bool isDisplayPleaseSelectOption, bool isDisplayAllOption)
        {
            DataSet ds = DatabaseUtilities.DsGetAssetTypeByBaseTypeDDL(isDisplayActiveOnly, Asset_base_Type_ID);
            int iRecordCount = ds.Tables[0].Rows.Count;
            if (iRecordCount > 0)
            {
                ddlAssetType.DataSource = ds;
                ddlAssetType.DataTextField = Constants.COLUMN_CT_ASSET_TYPE_Name;
                ddlAssetType.DataValueField = Constants.COLUMN_CT_ASSET_TYPE_ID;
                ddlAssetType.DataBind();
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayAllOption)
            {
                ddlAssetType.Items.Insert(0, new ListItem(Constants._OPTION_ALL_TEXT + "Types ---", Constants._OPTION_ALL_VALUE));
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayPleaseSelectOption)
            {
                ddlAssetType.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Type ---", Constants._OPTION_PLEASE_SELECT_VALUE));
            }
        }

        protected void SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SelectedIndexChanged_DDL_AssetType != null)
            {
                SelectedIndexChanged_DDL_AssetType(sender, EventArgs.Empty);
            }
        }
    }
}