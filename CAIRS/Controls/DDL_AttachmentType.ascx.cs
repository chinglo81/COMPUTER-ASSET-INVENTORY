using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class DDL_AttachmentType : System.Web.UI.UserControl
    {
        /// <summary>
        /// Required Site defaulted to false
        /// </summary>
        public bool IsAttachmentTypeRequired = false;
        public bool EnableClientScript = true;

        /// <summary>
        /// AutoPostBack
        /// </summary>
        public bool AutoPostBack = false;
        public string FieldName = "Attachment Type";
        public string ValidationGroup = "";
        /// <summary>
        /// Used to handle event that needs to be fired after this a site has been selected
        /// </summary>
        public event EventHandler SelectedIndexChanged_DDL_AssetType;
        public string SelectedValue
        {
            get
            {
                return ddlAttachmentType.SelectedValue;
            }
            set
            {
                //Check to see if the selected value exists before setting it.
                ListItem i = ddlAttachmentType.Items.FindByValue(value);
                if (ddlAttachmentType.Items.Contains(i))
                {
                    ddlAttachmentType.SelectedValue = value;
                }
            }
        }
        public string SelectedText
        {
            get
            {
                return ddlAttachmentType.SelectedItem.Text;
            }
            set
            {
                ddlAttachmentType.SelectedItem.Text = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Utilities.AddBootStrapCSSForDDL(ddlAttachmentType);
                ddlAttachmentType.AutoPostBack = AutoPostBack;
                reqAttachmentType.Visible = IsAttachmentTypeRequired;
                reqAttachmentType.ErrorMessage = "Required Field: " + FieldName;
                reqAttachmentType.ValidationGroup = ValidationGroup;

                reqAttachmentType.EnableClientScript = EnableClientScript;
            }
        }

        public void LoadddlAttachmentType(bool isDisplayActiveOnly, bool isDisplayPleaseSelectOption, bool isDisplayAllOption)
        {
            DataSet ds = DatabaseUtilities.DsGet_CTByTableName(Constants.TBL_CT_ATTACHMENT_TYPE, isDisplayActiveOnly);
            int iRecordCount = ds.Tables[0].Rows.Count;
            if (iRecordCount > 0)
            {
                ddlAttachmentType.DataSource = ds;
                ddlAttachmentType.DataTextField = Constants.COLUMN_CT_ATTACHMENT_TYPE_Name;
                ddlAttachmentType.DataValueField = Constants.COLUMN_CT_ATTACHMENT_TYPE_ID;
                ddlAttachmentType.DataBind();
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayAllOption)
            {
                ddlAttachmentType.Items.Insert(0, new ListItem(Constants._OPTION_ALL_TEXT + "Attachment Types ---", Constants._OPTION_ALL_VALUE));
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayPleaseSelectOption)
            {
                ddlAttachmentType.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Attachment Type ---", Constants._OPTION_PLEASE_SELECT_VALUE));
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