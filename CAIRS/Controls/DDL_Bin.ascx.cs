using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class DDL_Bin : System.Web.UI.UserControl
    {
        public bool IsBinRequired = false;
        public bool AutoPostBack = false;
        public string FieldName = "Bin";
        public string ValidationGroup = "";
        /// <summary>
        /// Set site specific for bin
        /// </summary>
        public string SiteForBin = "";

        /// <summary>
        /// Used to handle event that needs to be fired after this a site has been selected.s
        /// </summary>
        public event EventHandler SelectedIndexChanged_DDL_Bin;

        /// <summary>
        /// Get or Set the Selected Value
        /// </summary>
        public string SelectedValue
        {
            get
            {
                return ddlBin.SelectedValue;
            }
            set
            {
                //Check to see if the selected value exists before setting it.
                ListItem i = ddlBin.Items.FindByValue(value);
                if (ddlBin.Items.Contains(i))
                {
                    ddlBin.SelectedValue = value;
                }
            }
        }

        /// <summary>
        /// Get or Set the Selected Text
        /// </summary>
        public string SelectedText
        {
            get
            {
                return ddlBin.SelectedItem.Text;
            }
            set
            {
                ddlBin.SelectedItem.Text = value;
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Utilities.AddBootStrapCSSForDDL(ddlBin);
                ddlBin.AutoPostBack = AutoPostBack;
                reqBin.Visible = IsBinRequired;
                reqBin.ErrorMessage = "Required Field: " + FieldName;
                reqBin.ValidationGroup = ValidationGroup;
            }
        }

        public void LoadDDLBin(string site, bool isDisplayActiveOnly, bool isDisplayAvailableBin, bool isDisplayPleaseSelectOption, bool isDisplayAllOption)
        {
            Utilities.Assert(!Utilities.isNull(site), "Please pass in site to populate Bin");
            ddlBin.Items.Clear();
            reqBin.InitialValue = "-1";

            DataSet ds = DatabaseUtilities.DsGetBinBySiteForDDL(isDisplayActiveOnly, isDisplayAvailableBin, site);
            int iRecordCount = ds.Tables[0].Rows.Count;
            if (iRecordCount > 0)
            {
                ddlBin.DataSource = ds;
                ddlBin.DataTextField = "bin_desc";
                ddlBin.DataValueField = "bin_id";
                ddlBin.DataBind();
            }
            else
            {
                if (site.Equals(Constants._OPTION_PLEASE_SELECT_VALUE))
                {
                    ddlBin.Items.Insert(0, new ListItem(Constants._OPTION_SELECT_SITE_TEXT + "Bin", Constants._OPTION_SELECT_SITE_VALUE));
                    reqBin.InitialValue = Constants._OPTION_SELECT_SITE_VALUE;
                }else{
                    ddlBin.Items.Insert(0, new ListItem(Constants._OPTION_NO_DATA_FOUND_TEXT, Constants._OPTION_NO_DATA_FOUND_VALUE));
                    reqBin.InitialValue = Constants._OPTION_NO_DATA_FOUND_VALUE;
                }
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayAllOption)
            {
                ddlBin.Items.Insert(0, new ListItem(Constants._OPTION_ALL_TEXT, Constants._OPTION_ALL_TEXT));
            }

            //Only display select option if return more than one record and isDisplayPleaseSelectOption = true
            if (iRecordCount > 1 && isDisplayPleaseSelectOption)
            {
                ddlBin.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Bins ---", Constants._OPTION_PLEASE_SELECT_VALUE));
            }
        }

        protected void SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SelectedIndexChanged_DDL_Bin != null)
            {
                SelectedIndexChanged_DDL_Bin(sender, EventArgs.Empty);
            }
        }
    }
}