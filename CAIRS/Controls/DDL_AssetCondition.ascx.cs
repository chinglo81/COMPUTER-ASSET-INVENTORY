using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class DDL_AssetCondition : System.Web.UI.UserControl
    {
        /// <summary>
        /// Required Site defaulted to false
        /// </summary>
        public bool IsAssetConditionRequired = false;

        /// <summary>
        /// AutoPostBack
        /// </summary>
        public bool AutoPostBack = false;
        public string FieldName = "Asset Condition";
        public string ValidationGroup = "";

        /// <summary>
        /// Used to handle event that needs to be fired after this a site has been selected
        /// </summary>
        public event EventHandler SelectedIndexChanged_DDL_AssetCondition;
        public string SelectedValue
        {
            get
            {
                return ddlAssetCondition.SelectedValue;
            }
            set
            {
                //Check to see if the selected value exists before setting it.
                ListItem i = ddlAssetCondition.Items.FindByValue(value);
                if (ddlAssetCondition.Items.Contains(i))
                {
                    ddlAssetCondition.SelectedValue = value;
                }
            }
        }
        public string SelectedText
        {
            get
            {
                return ddlAssetCondition.SelectedItem.Text;
            }
            set
            {
                ddlAssetCondition.SelectedItem.Text = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Utilities.AddBootStrapCSSForDDL(ddlAssetCondition);
                ddlAssetCondition.AutoPostBack = AutoPostBack;
                reqAssetCondition.Visible = IsAssetConditionRequired;
                reqAssetCondition.ErrorMessage = "Required Field: " + FieldName;
                reqAssetCondition.ValidationGroup = ValidationGroup;
            }
        }

        public void LoadDDLAssetCondition(string businessRuleList, bool isDisplayActiveOnly, bool isDisplayPleaseSelectOption, bool isDisplayAllOption)
        {
            string orderby = "Name";
            DataSet ds = DatabaseUtilities.DsGetCondition(isDisplayActiveOnly, businessRuleList, orderby);
            int iRecordCount = ds.Tables[0].Rows.Count;
            if (iRecordCount > 0)
            {
                ddlAssetCondition.DataSource = ds;
                ddlAssetCondition.DataTextField = Constants.COLUMN_CT_ASSET_CONDITION_Name;
                ddlAssetCondition.DataValueField = Constants.COLUMN_CT_ASSET_CONDITION_ID;
                ddlAssetCondition.DataBind();
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayAllOption)
            {
                ddlAssetCondition.Items.Insert(0, new ListItem(Constants._OPTION_ALL_TEXT + "Conditions ---", Constants._OPTION_ALL_VALUE));
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayPleaseSelectOption)
            {
                ddlAssetCondition.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Condition ---", Constants._OPTION_PLEASE_SELECT_VALUE));
            }
        }

        protected void SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SelectedIndexChanged_DDL_AssetCondition != null)
            {
                SelectedIndexChanged_DDL_AssetCondition(sender, EventArgs.Empty);
            }
        }
    }
}