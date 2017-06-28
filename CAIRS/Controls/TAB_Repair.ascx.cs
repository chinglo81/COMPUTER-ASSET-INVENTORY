using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Controls
{
    public partial class TAB_Repair : System.Web.UI.UserControl
    {
        public event EventHandler btnSaveRepair_Click;
        public event EventHandler btnDeleteRepair_Click;
        public event EventHandler btnSaveMarkReceived_Click;

        public void RefreshForm()
        {
            LoadRepairDG();
            ApplySecurityToControl();
            ShowHideLoadControl();

            updateAddRepair.Update();
            updateRepairDetailModal.Update();
        }

        protected string QS_ASSET_ID
        {
            get
            {
                return Request.QueryString["Asset_ID"];
            }
        }

        protected string ASSET_REPAIR_ID
        {
            get
            {
                return hdnAssetRepairID.Value;
            }
            set
            {
                hdnAssetRepairID.Value = value;
            }
        }

        protected string GetLoggOnEmployeeID()
        {
            return Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());
        }

        protected bool IsInsert()
        {
            return ASSET_REPAIR_ID.Equals("-1");
        }

        private DataSet dsGetAssetInfo()
        {
            return DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_MASTER_LIST, "Asset_ID", QS_ASSET_ID, "");
        }

        private void ShowHideLoadControl()
        {
            divLeasedPeriodMet.Visible = false;
            btnAddRepair.Visible = true;
            btnAddRepair.Enabled = true;
            lblNotAllowCreateMsg.Text = "";
            hdnIsLeasedDevice.Value = "false";
            chkAssignNewBin.Visible = false;
            ddlBin.Visible = true;

            DataSet ds = dsGetAssetInfo();
            if (ds.Tables[0].Rows.Count > 0)
            {
                string sLeaseDate = ds.Tables[0].Rows[0]["Leased_Term_Date"].ToString().Trim();
                string sLeased = ds.Tables[0].Rows[0]["Is_Leased"].ToString().ToLower().Trim();
                string sAllowCreateRepair = ds.Tables[0].Rows[0]["Allow_Create_Repair"].ToString().ToLower().Trim();
                string disposition = ds.Tables[0].Rows[0]["Asset_Disposition_Desc"].ToString();
                string bin_desc = ds.Tables[0].Rows[0]["Bin_Site_Desc"].ToString();
                string asset_site_id = ds.Tables[0].Rows[0]["Asset_Site_ID"].ToString();

                bool isLeased = sLeased.Equals("yes");
                bool isAllowCreateRepair = sAllowCreateRepair.Equals("1");

                hdnIsLeasedDevice.Value = isLeased.ToString();//Need to be set to load disposition for marked received

                //add must not be disabled from security.
                if (btnAddRepair.Enabled)
                {
                    btnAddRepair.Enabled = isAllowCreateRepair;
                }

                if (!isAllowCreateRepair)
                {
                    lblNotAllowCreateMsg.Text = "* Cannot Add Repair when disposion is \"" + disposition + "\".";
                }

                if (isLeased)
                {
                    string test = DateTime.Parse(sLeaseDate).Date.ToString();
                    string test2 = DateTime.Now.Date.ToString();

                    if(DateTime.Now.Date > DateTime.Parse(sLeaseDate).Date)
                    {
                        divLeasedPeriodMet.Visible = true;
                        btnAddRepair.Visible = false;
                        lblNotAllowCreateMsg.Text = "";
                    }
                }

                lblCurrentBinDesc.Text = "";

                if (!Utilities.isNull(bin_desc))
                {
                    chkAssignNewBin.Visible = true;
                    lblCurrentBinDesc.Text = bin_desc + "<br />";
                    ddlBin.Visible = false;
                }

                ddlBin.LoadDDLBin(asset_site_id, true, true, true, false);
            }
        }

        private void LoadDDL_Disposition_Marked_Received()
        {
            string business_rule = Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_RECEIVED_OWNED_ASSET;
            if (bool.Parse(hdnIsLeasedDevice.Value))
            {
                business_rule = Constants.BUSINESS_RULE_DISPOSITION_AVAILABLE_RECEIVED_LEASED_ASSET;
            }

            ddlDisposition_MarkReceived.LoadDDLAssetDisposition(business_rule, true, true, false);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!Utilities.isNull(QS_ASSET_ID))
                {
                    ApplySecurityToControl();
                    ShowHideLoadControl();
                }
            } 
            //Add event handler to the on change event
            //Needs to happen on every postback to function properly
            //ddlRepairType.SelectedIndexChanged_DDL_RepairType += ddlRepairSelectedIndexChange;
        }

        protected void ddlRepairSelectedIndexChange(object sender, EventArgs args)
        {
            DisplayDetails(false);
            updateRepairDetailModal.Update();
        }

        protected void dgRepair_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            if (e.Item.ItemIndex >= 0)
            {
                Button btnDelete = ((Button)e.Item.FindControl("btnDelete"));
                Button btnMarkReceived = ((Button)e.Item.FindControl("btnMarkRecieved"));

                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnDelete);
                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnMarkReceived);
            }
        }

        protected bool CanModified(object o)
        {
            string addedbyemp = ((DataRowView)o)["Added_By_Emp_ID"].ToString();
            if (!Utilities.isNull(addedbyemp))
            {
                return addedbyemp.Equals(GetLoggOnEmployeeID());
            }
            return false;
        }

        private void InitilizeControlForRepairModal()
        {
            ddlBin.ddlBin.SelectedIndex = 0;
            ddlBin.Visible = true;
            chkAssignNewBin.Checked = false;
            if (!Utilities.isNull(lblCurrentBinDesc.Text))
            {
                ddlBin.Visible = false;
            }

           
        }

        private void ShowHideControlForEdit()
        { 
            ddlRepairType.Visible = IsInsert();
            trAddedBy.Visible = !IsInsert();
            trModifiedBy.Visible = !IsInsert();
            trDateAdded.Visible = !IsInsert();
            trDateModified.Visible = !IsInsert();
            trDateReceived.Visible = !IsInsert();
            trReceivedByEmp.Visible = !IsInsert();
        }

        private void ApplySecurityToControl()
        {
            DataSet ds = DatabaseUtilities.DsGetAssetInfoByID(QS_ASSET_ID);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string site_code = ds.Tables[0].Rows[0]["Asset_Site_Code"].ToString();

                btnAddRepair.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
                btnSave.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;

                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnAddRepair);
                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnSave);
            }
        }

        public void LoadRepairDG()
        {
            string sortby = "v.Date_Sent desc, Repair_Type_Desc";
            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_REPAIRS, QS_ASSET_ID, "", sortby);

            dgRepair.Visible = false;
            lblResults.Text = "No repair(s) found for this asset";
            if (ds.Tables[0].Rows.Count > 0)
            {
                lblResults.Text = "";
                dgRepair.Visible = true;
                dgRepair.DataSource = ds;
                dgRepair.DataBind();
            }
        }

        protected bool MarkReceived(object o)
        {
            string dateReceived = ((DataRowView)o)["Date_Received_Formatted"].ToString();
            string dateSent = ((DataRowView)o)["Date_Sent_Formatted"].ToString();

            if (!Utilities.isNull(dateSent))
            {
                return !Utilities.isNull(dateReceived);
            }
            return true;
        }

        protected bool ShowHideDelete(object o)
        {
            string dateReceived = ((DataRowView)o)["Date_Received_Formatted"].ToString();
            return Utilities.isNull(dateReceived);
        }

        private void CloseEditRepairModal()
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "closePopup", "$('#popupRepairDetails').modal('hide');", true);
        }

        private void CloseMarkReceivedModal()
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "closePopup", "$('#popupRepairMarkReceivedModal').modal('hide');", true);
        }

        private void DisplayDetails(bool isReload)
        {
            lblModalTitle.Text = "Repair Details";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupDetailMessage", "$('#popupRepairDetails').modal();", true);
            if (isReload)
            {
                InitilizeControlForRepairModal();
                ShowHideControlForEdit();
                
                LoadRepair_DDL();
                LoadRepair();
            }

            updateAddRepair.Update();
            updateRepairDetailModal.Update();
        }

        private void DisplayMarkReceivedModal()
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupMarkReceivedModal", "$('#popupRepairMarkReceivedModal').modal();", true);

            LoadDDL_Disposition_Marked_Received();

            updatePanelMarkedReceived.Update();
        }

        private void LoadRepair()
        {
            DataSet ds = DatabaseUtilities.DsGetTabByView(Constants.DB_VIEW_ASSET_TAB_REPAIRS, QS_ASSET_ID, ASSET_REPAIR_ID, "");
            Utilities.DataBindForm(divAssetRepairInfo, ds);
        }

        private string GetBusinessRuleRepairType()
        {
            //Default business rule to owned
            string business_rule = Constants.BUSINESS_RULE_REPAIR_TYPE_AVAILABLE_OWNED;
            DataSet ds = dsGetAssetInfo();
            if (ds.Tables[0].Rows.Count > 0)
            {
                string sLeased = ds.Tables[0].Rows[0]["Is_Leased"].ToString().ToLower().Trim();
                string sLeased_ADP_Count = ds.Tables[0].Rows[0]["Leased_ADP_Count"].ToString().ToLower().Trim();

                bool isLeased = false;
                int iLeased_ADP_Count = int.Parse(sLeased_ADP_Count);

                if (!Utilities.isNull(sLeased))
                {
                    isLeased = sLeased.Equals("yes");
                    //If Leased
                    if (isLeased)
                    {
                        business_rule = Constants.BUSINESS_RULE_REPAIR_TYPE_AVAILABLE_LEASED;
                        if (iLeased_ADP_Count >= 1)
                        {
                            business_rule = Constants.BUSINESS_RULE_REPAIR_TYPE_AVAILABLE_LEASED_ADP;
                        }
                    }
                }
            }

            return business_rule;
        }

        /// <summary>
        /// Initial Load
        /// </summary>
        private void LoadRepair_DDL()
        {
            //only need to be loaded on insert
            if (IsInsert())
            {
                ddlRepairType.IsRepairTypeRequired = true;
                ddlRepairType.LoadDDLRepairType(GetBusinessRuleRepairType(), true, true, false);
            }
        }

        private void SaveRepair()
        {
            string datetimenow = DateTime.Now.ToString();
            string empid = Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());

            string p_ID = ASSET_REPAIR_ID;
            string p_Asset_ID = QS_ASSET_ID;
            string p_Repair_Type_ID = Constants.MCSDBNOPARAM;
            string p_Comment = txtComment.Text;
            string p_Date_Sent = Utilities.ConvertStringToDBNull(txtDateSent.Text);
            string p_Date_Received = Constants.MCSDBNOPARAM;
            string p_Received_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Received_Disposition_ID = Constants.MCSDBNOPARAM;
            string p_Added_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Date_Added = Constants.MCSDBNOPARAM;
            string p_Modified_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Date_Modified = Constants.MCSDBNOPARAM;

            if (IsInsert())
            {
                p_Repair_Type_ID = ddlRepairType.SelectedValue;
                p_Added_By_Emp_ID = empid;
                p_Date_Added = datetimenow;
            }
            else
            {
                p_Modified_By_Emp_ID = empid;
                p_Date_Modified = datetimenow;
            }

            DatabaseUtilities.Upsert_Asset_Repair(
                p_ID,
                p_Asset_ID,
                p_Repair_Type_ID,
                p_Comment,
                p_Date_Sent,
                p_Date_Received,
                p_Received_By_Emp_ID,
                p_Received_Disposition_ID,
                p_Added_By_Emp_ID,
                p_Date_Added,
                p_Modified_By_Emp_ID,
                p_Date_Modified
            );
            
            //Update disposition if insert
            if (IsInsert())
            {
                DatabaseUtilities.SaveAssetDisposition(QS_ASSET_ID, Constants.DISP_SENT_FOR_REPAIR, Utilities.GetLoggedOnUser());
            }
        }

        private void AssignAssetToBin()
        {
            if (ddlBin.Visible)
            {
                string p_Asset_ID = QS_ASSET_ID;
                string p_Bin_ID = ddlBin.SelectedValue;
                string empid = Utilities.GetEmployeeIdByLoggedOn(Utilities.GetLoggedOnUser());
                string datetimenow = DateTime.Now.ToString();

                //If user does not selected a bin, unassign from bin
                if (p_Bin_ID.Contains("-"))
                {
                    p_Bin_ID = Constants.MCSDBNULL;
                }

                DatabaseUtilities.AssignAssetToBin(p_Bin_ID, p_Asset_ID, empid, datetimenow);
            }

        }

        protected void btnViewDetails_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string ID = btn.Attributes["Asset_Repair_ID"];
            ASSET_REPAIR_ID = ID;

            DisplayDetails(true);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string id = btn.Attributes["Asset_Repair_ID"];

            //Delete the repair
            DatabaseUtilities.DeleteAsset_Repair(id);
            
            //Update Asset Disposition to previous disposition using audit log
            Utilities.RevertPreviousDispositionByAssetID(QS_ASSET_ID);

            //Refresh Form
            RefreshForm();

            if (btnDeleteRepair_Click != null)
            {
                btnDeleteRepair_Click(sender, EventArgs.Empty);
            }

            updateAddRepair.Update();
        }

        protected void btnAddRepair_Click(object sender, EventArgs e)
        {
            ASSET_REPAIR_ID = "-1";
            DisplayDetails(true);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                SaveRepair();
                AssignAssetToBin();
                RefreshForm();
                CloseEditRepairModal();

                if (btnSaveRepair_Click != null)
                {
                    btnSaveRepair_Click(sender, EventArgs.Empty);
                }

                updateAddRepair.Update();
                updateRepairDetailModal.Update();
            }
            else
            {
                DisplayDetails(false);
            }
        }

        protected void btnMarkRecieved_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string ID = btn.Attributes["Asset_Repair_ID"];
            ASSET_REPAIR_ID = ID;

            DisplayMarkReceivedModal();
        }

        protected void btnSaveMarkReceivedModal_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                string Asset_Repair_ID = hdnAssetRepairID.Value;
                string disposition = ddlDisposition_MarkReceived.SelectedValue;
                
                //Update Received info from asset repair
                DatabaseUtilities.UpdateAssetRepairReceived(Asset_Repair_ID, disposition, GetLoggOnEmployeeID());

                //Update disposition on asset
                DatabaseUtilities.SaveAssetDisposition(QS_ASSET_ID, disposition, Utilities.GetLoggedOnUser());

                RefreshForm();

                CloseMarkReceivedModal();

                if (btnSaveMarkReceived_Click != null)
                {
                    btnSaveMarkReceived_Click(sender, EventArgs.Empty);
                }
            }

        }

        protected void chkAssignNewBin_CheckedChanged(object sender, EventArgs e)
        {
            ddlBin.Visible = chkAssignNewBin.Checked;
            updateRepairDetailModal.Update();
        }

    }
}