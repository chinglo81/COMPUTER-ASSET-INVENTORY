using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class TXT_Date : System.Web.UI.UserControl
    {
        public bool EnableClientScript = false;
        public bool IsDateRequired = false;
        public string FieldName = "Date";
        public string ValidationGroup = "";
        public bool IsSetFocusOnTxtBox = false;
        public string PlaceHolder = "";
        public string Width = "";
        public string data_column = "";

        public string Text
        {
            get
            {
                return txtDate.Text;
            }
            set
            {
                txtDate.Text = value;
            }
        }
        private void LoadDatePicker()
        {
            string dateid = txtDate.ClientID.ToString();
            string jScript = @" $( function() {
                                    $('#" + dateid + @"' ).datepicker();
                                  } );";

            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "DatePicker_" + dateid, jScript, true);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            LoadControls();
        }

        public void LoadControls()
        {
            txtDate.Attributes["placeholder"] = PlaceHolder;
            reqDate.Visible = IsDateRequired;
            reqDate.ErrorMessage = "Required Field: " + FieldName;
            reqDate.ValidationGroup = ValidationGroup;
            reqDate.EnableClientScript = EnableClientScript;

            cvDate.ValidationGroup = ValidationGroup;
            cvDate.EnableClientScript = EnableClientScript;

            if (IsSetFocusOnTxtBox)
            {
                txtDate.Focus();
            }

            if (!Utilities.isNull(Width))
            {
                txtDate.Style.Add("width", Width);
            }

            if (!Utilities.isNull(data_column))
            {
                txtDate.Attributes.Add("data_column", data_column);
            }
            
            LoadDatePicker();
        }
    }
}