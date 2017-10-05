using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CAIRS.Controls
{
    public partial class TXT_TagID : System.Web.UI.UserControl
    {
        public bool IsTagIDRequired = false;
        public string FieldName = "Tag ID";
        public string ValidationGroup = "";
        public bool IsSetFocusOnTxtBox = false;
        public string PlaceHolder = "Tag ID";

        public string Text
        {
            get
            {
                return txtTagID.Text;
            }
            set
            {
                txtTagID.Text = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Utilities.AddBootStrapCSSForTXT(txtTagID);
                reqTagID.Visible = IsTagIDRequired;
                reqTagID.ErrorMessage = "Required Field: " + FieldName;
                reqTagID.ValidationGroup = ValidationGroup;
                if (IsSetFocusOnTxtBox)
                {
                    txtTagID.Focus();
                }

                txtTagID.Attributes.Add("placeholder", PlaceHolder);
            }
        }
    }
}