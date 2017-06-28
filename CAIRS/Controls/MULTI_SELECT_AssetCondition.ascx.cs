using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class MULTI_SELECT_AssetCondition : System.Web.UI.UserControl
    {
        public string SetSelectedValuePageLoad = "";
        public string GetSelectedValue
        {
            get
            {
                return Utilities.GetListItemFromListBox(lstBox, true);
            }
            set
            {
                hdnValues.Value = value;
                LoadSelectedItem();
            }
        }
        public string GetSetSelectedText
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

                //load data for ddl
                LoadData();
            }
            LoadSelectedItem();
        }

        private void LoadData()
        {
            DataSet ds = DatabaseUtilities.DsGet_CTByTableName(Constants.TBL_CT_ASSET_CONDITION, false);
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