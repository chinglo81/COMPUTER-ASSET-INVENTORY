using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class DDL_InteractionType : System.Web.UI.UserControl
    {
        /// <summary>
        /// Required Site defaulted to false
        /// </summary>
        public bool IsInteractionTypeRequired = false;

        /// <summary>
        /// AutoPostBack
        /// </summary>
        public bool AutoPostBack = false;
        public string FieldName = "Interaction Type";
        public string ValidationGroup = "";
        /// <summary>
        /// Used to handle event that needs to be fired after this a site has been selected
        /// </summary>
        public event EventHandler SelectedIndexChanged_DDL_InteractionType;
        public string SelectedValue
        {
            get
            {
                return ddlInteractionType.SelectedValue;
            }
            set
            {
                //Check to see if the selected value exists before setting it.
                ListItem i = ddlInteractionType.Items.FindByValue(value);
                if (ddlInteractionType.Items.Contains(i))
                {
                    ddlInteractionType.SelectedValue = value;
                }
            }
        }
        public string SelectedText
        {
            get
            {
                return ddlInteractionType.SelectedItem.Text;
            }
            set
            {
                ddlInteractionType.SelectedItem.Text = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Utilities.AddBootStrapCSSForDDL(ddlInteractionType);
                ddlInteractionType.AutoPostBack = AutoPostBack;
                ddlInteractionType.Visible = IsInteractionTypeRequired;
                reqInteractionType.ErrorMessage = "Required Field: " + FieldName;
                reqInteractionType.ValidationGroup = ValidationGroup;
            }
        }

        public void LoadDDLInteractionType(string businessRuleList, bool isDisplayActiveOnly, bool isDisplayPleaseSelectOption, bool isDisplayAllOption)
        {
            DataSet ds = DatabaseUtilities.DsGetInteractionType(isDisplayActiveOnly, businessRuleList, Constants.COLUMN_CT_INTERACTION_TYPE_Name);
            int iRecordCount = ds.Tables[0].Rows.Count;
            if (iRecordCount > 0)
            {
                ddlInteractionType.DataSource = ds;
                ddlInteractionType.DataTextField = Constants.COLUMN_CT_INTERACTION_TYPE_Name;
                ddlInteractionType.DataValueField = Constants.COLUMN_CT_INTERACTION_TYPE_ID;
                ddlInteractionType.DataBind();
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayAllOption)
            {
                ddlInteractionType.Items.Insert(0, new ListItem(Constants._OPTION_ALL_TEXT, Constants._OPTION_ALL_VALUE));
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayPleaseSelectOption)
            {
                ddlInteractionType.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT, Constants._OPTION_PLEASE_SELECT_VALUE));
            }
        }

        protected void SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SelectedIndexChanged_DDL_InteractionType != null)
            {
                SelectedIndexChanged_DDL_InteractionType(sender, EventArgs.Empty);
            }
        }
    }
}