using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class DDL_RepairType : System.Web.UI.UserControl
    {
        /// <summary>
        /// Required Site defaulted to false
        /// </summary>
        public bool IsRepairTypeRequired = false;

        /// <summary>
        /// AutoPostBack
        /// </summary>
        public bool AutoPostBack = false;
        public string FieldName = "Repair Type";
        public string ValidationGroup = "";
        /// <summary>
        /// Used to handle event that needs to be fired after this a site has been selected
        /// </summary>
        public event EventHandler SelectedIndexChanged_DDL_RepairType;
        public string SelectedValue
        {
            get
            {
                return ddlRepairType.SelectedValue;
            }
            set
            {
                //Check to see if the selected value exists before setting it.
                ListItem i = ddlRepairType.Items.FindByValue(value);
                if (ddlRepairType.Items.Contains(i))
                {
                    ddlRepairType.SelectedValue = value;
                }
            }
        }
        public string SelectedText
        {
            get
            {
                return ddlRepairType.SelectedItem.Text;
            }
            set
            {
                ddlRepairType.SelectedItem.Text = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Utilities.AddBootStrapCSSForDDL(ddlRepairType);
                ddlRepairType.AutoPostBack = AutoPostBack;
                reqRepairType.Visible = IsRepairTypeRequired;
                reqRepairType.ErrorMessage = "Required Field: " + FieldName;
                reqRepairType.ValidationGroup = ValidationGroup;
            }
        }

        public void LoadDDLRepairType(string businessRuleList, bool isDisplayActiveOnly, bool isDisplayPleaseSelectOption, bool isDisplayAllOption)
        {
            DataSet ds = DatabaseUtilities.DsGetRepair(isDisplayActiveOnly, businessRuleList, Constants.COLUMN_CT_REPAIR_TYPE_Name);
            int iRecordCount = ds.Tables[0].Rows.Count;
            if (iRecordCount > 0)
            {
                ddlRepairType.DataSource = ds;
                ddlRepairType.DataTextField = Constants.COLUMN_CT_REPAIR_TYPE_Name;
                ddlRepairType.DataValueField = Constants.COLUMN_CT_REPAIR_TYPE_ID;
                ddlRepairType.DataBind();
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayAllOption)
            {
                ddlRepairType.Items.Insert(0, new ListItem(Constants._OPTION_ALL_TEXT, Constants._OPTION_ALL_VALUE));
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayPleaseSelectOption)
            {
                ddlRepairType.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Repair Type ---", Constants._OPTION_PLEASE_SELECT_VALUE));
            }
        }

        protected void SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SelectedIndexChanged_DDL_RepairType != null)
            {
                SelectedIndexChanged_DDL_RepairType(sender, EventArgs.Empty);
            }
        }
    }
}