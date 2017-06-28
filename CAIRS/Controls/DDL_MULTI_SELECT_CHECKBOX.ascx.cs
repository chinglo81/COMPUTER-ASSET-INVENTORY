using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class DDL_MULTI_SELECT_CHECKBOX : System.Web.UI.UserControl
    {
        public string SelectedText
        {
            get
            {
                return GetSelectedValueOrText(false);
            }
        }

        public string SelectedValue
        {
            get
            {
                return GetSelectedValueOrText(true);
            }
        }

        private string GetSelectedValueOrText(bool isValue)
        {
            string sVal = "";

            foreach (ListItem item in ChkBoxList.Items)
            {
                if (item.Selected)
                {
                    if (isValue)
                    {
                        sVal = sVal + item.Value + ",";
                    }
                    else
                    {
                        sVal = sVal + item.Text + ", ";
                    }
                }
            }
            if (!Utilities.isNull(sVal))
            {
                if (isValue)
                {
                    sVal = sVal.Substring(0, sVal.Length - 1);
                }
                else
                {
                    sVal = sVal.Substring(0, sVal.Length - 2);
                }
            }

            return sVal;
        }

        public void SetSelectedValue(string sValues)
        {
            hdnSelectedValue.Value = sValues;
            string[] arrValues = sValues.Split(',');
            foreach (string s in arrValues)
            {
                foreach (ListItem item in ChkBoxList.Items)
                {
                    if (s.Trim().Equals(item.Value))
                    {
                        item.Selected = true;
                    }
                }
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ChkBoxList.Attributes.Add("onclick", "FindSelectedItems();");
                ChkAll.Attributes.Add("onclick", "SelectDeselectAll();");

                //divCustomCheckBoxList.Attributes.Add("class", "form-control");
                //tblDDL.Attributes.Add("class", "dropdown");
                //ChkBoxList.Attributes.Add("class", "checkbox");
                loadData();
            }
        }

        private void loadData()
        {
            DataSet ds = DatabaseUtilities.DsGet_CTByTableName(Constants.TBL_CT_ASSET_DISPOSITION, true);
            if (ds.Tables[0].Rows.Count > 0)
            {
                ChkBoxList.DataSource = ds;
                ChkBoxList.DataTextField = Constants.COLUMN_CT_ASSET_DISPOSITION_Name;
                ChkBoxList.DataValueField = Constants.COLUMN_CT_ASSET_DISPOSITION_ID;
                ChkBoxList.DataBind();
            }
        }

        public void LoadMultiSelectDDL(DataSet ds, string dataTextField, string dataValueField)
        {
            int iRecordCount = ds.Tables[0].Rows.Count;
            if (iRecordCount > 0)
            {
                ChkBoxList.DataSource = ds;
                ChkBoxList.DataTextField = dataTextField;
                ChkBoxList.DataValueField = dataValueField;
                ChkBoxList.DataBind();
            }
        }
    }
}