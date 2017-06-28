using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class DDL_AssetBaseType : System.Web.UI.UserControl
    {
        /// <summary>
        /// Required Site defaulted to false
        /// </summary>
        public bool IsAssetBaseTypeRequired = false;

        /// <summary>
        /// AutoPostBack
        /// </summary>
        public bool AutoPostBack = false;
        public string FieldName = "Asset Base Type";
        public string ValidationGroup = "";
        /// <summary>
        /// Used to handle event that needs to be fired after this a site has been selected
        /// </summary>
        public event EventHandler SelectedIndexChanged_DDL_AssetBaseType;
        public string SelectedValue
        {
            get
            {
                return ddlAssetBaseType.SelectedValue;
            }
            set
            {
                //Check to see if the selected value exists before setting it.
                ListItem i = ddlAssetBaseType.Items.FindByValue(value);
                if (ddlAssetBaseType.Items.Contains(i))
                {
                    ddlAssetBaseType.SelectedValue = value;
                }
            }
        }
        public string SelectedText
        {
            get
            {
                return ddlAssetBaseType.SelectedItem.Text;
            }
            set
            {
                ddlAssetBaseType.SelectedItem.Text = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Utilities.AddBootStrapCSSForDDL(ddlAssetBaseType);
                ddlAssetBaseType.AutoPostBack = AutoPostBack;
                reqAssetBaseType.Visible = IsAssetBaseTypeRequired;
                reqAssetBaseType.ErrorMessage = "Required Field: " + FieldName;
                reqAssetBaseType.ValidationGroup = ValidationGroup;
            }
        }

        public void LoadDDLAssetBaseType(bool isDisplayActiveOnly, bool isDisplayPleaseSelectOption, bool isDisplayAllOption)
        {
            DataSet ds = DatabaseUtilities.DsGet_CTByTableName(Constants.TBL_CT_ASSET_BASE_TYPE, isDisplayActiveOnly);
            int iRecordCount = ds.Tables[0].Rows.Count;
            if (iRecordCount > 0)
            {
                ddlAssetBaseType.DataSource = ds;
                ddlAssetBaseType.DataTextField = Constants.COLUMN_CT_ASSET_BASE_TYPE_Name;
                ddlAssetBaseType.DataValueField = Constants.COLUMN_CT_ASSET_BASE_TYPE_ID;
                ddlAssetBaseType.DataBind();
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayAllOption)
            {
                ddlAssetBaseType.Items.Insert(0, new ListItem(Constants._OPTION_ALL_TEXT + "Base Types ---", Constants._OPTION_ALL_VALUE));
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayPleaseSelectOption)        
            {
                ddlAssetBaseType.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Base Type ---", Constants._OPTION_PLEASE_SELECT_VALUE));
            }
        }

        protected void SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SelectedIndexChanged_DDL_AssetBaseType != null)
            {
                SelectedIndexChanged_DDL_AssetBaseType(sender, EventArgs.Empty);
            }
        }
    }
}