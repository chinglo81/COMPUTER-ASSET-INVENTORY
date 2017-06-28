using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class MULTI_SELECT_AssetDisposition : System.Web.UI.UserControl
    {
        public string SetSelectedValuePageLoad = "";
        public string GetSelectedValue
        {
            get
            {
                return Utilities.GetListItemFromListBox(lstBox, true);
            }
        }
        public string GetSelectedText
        {
            get
            {
                return Utilities.GetListItemFromListBox(lstBox, false);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //used to set the selected value on page load
                hdnValues.Value = SetSelectedValuePageLoad;

                //set jquery attribute
                //lstBox.Attributes.Add("multiple", "multiple");

                //load data for ddl
                LoadData();
            }

            //needed to maintain selected values on every page load
            LoadSelectedItem();
        }

        private void LoadData()
        {
            //Load Data into Listbox
            DataSet ds = DatabaseUtilities.DsGet_CTByTableName(Constants.TBL_CT_ASSET_DISPOSITION, false);

            //Only load if data exist
            if (ds.Tables[0].Rows.Count > 0)
            {
                lstBox.DataSource = ds;
                lstBox.DataTextField = Constants.COLUMN_CT_ASSET_DISPOSITION_Name;
                lstBox.DataValueField = Constants.COLUMN_CT_ASSET_DISPOSITION_ID;
                lstBox.DataBind();
            }
        }

        /// <summary>
        /// Load selected value from hdn field
        /// </summary>
        public void LoadSelectedItem()
        {
            string selectedValues = hdnValues.Value;
            if (!Utilities.isNull(selectedValues))
            {
                string[] arrSelectedValues = selectedValues.Split(',');
                foreach (string singleValue in arrSelectedValues)
                {
                    foreach (ListItem single_item in lstBox.Items)
                    {
                        if (single_item.Value.Equals(singleValue))
                        {
                            single_item.Selected = true;
                        }
                    }
                }
            }
        }
    }
}