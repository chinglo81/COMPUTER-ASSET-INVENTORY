using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CAIRS.Controls
{
    public partial class TXT_SerialNumber : System.Web.UI.UserControl
    {
        public bool IsSerialNumRequired = false;
        public string FieldName = "Serial Number";
        public string ValidationGroup = "";
        public string PlaceHolder = "Serial #";

        public string Text
        {
            get
            {
                return txtSerialNumber.Text;
            }
            set
            {
                txtSerialNumber.Text = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Utilities.AddBootStrapCSSForTXT(txtSerialNumber);
                reqSerialNum.Visible = IsSerialNumRequired;
                reqSerialNum.ErrorMessage = "Required Field: " + FieldName;
                reqSerialNum.ValidationGroup = ValidationGroup;

                txtSerialNumber.Attributes.Add("placeholder", PlaceHolder);
            }
        }
    }
}