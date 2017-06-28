using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Text;

namespace CAIRS.Pages
{
    public partial class ManageAssetPropertiesPage : _CAIRSBasePage
    {
        /// <summary>
        /// Query string for the selected tab
        /// </summary>
        protected string qsSelectedTab
        {
            get
            {
                return Request.QueryString["Selected_Tab"];
            }
        }

        /// <summary>
        /// Getter and Setter for Law Enfocement ID in a hidden field
        /// </summary>
        protected string Asset_Law_Enforcement_ID
        {
            get
            {
                return hdnAssetLawEnforcementID.Value;
            }
            set
            {
                hdnAssetLawEnforcementID.Value = value;
            }
        }

        /// <summary>
        /// This function will build out the query string needed for this page to load data to this page correctly. This is primary used to page thru the set of asset id from user's 
        /// search results.
        /// </summary>
        /// <param name="asset_id">Asset ID</param>
        /// <param name="selectedtab">Tab</param>
        /// <returns>String value for all the querystring parameter</returns>
        private string BuildQueryStringParam(string asset_id, string selectedtab)
        {
            StringBuilder sbQueryStringParam = new StringBuilder();

            sbQueryStringParam.Append("?Asset_ID=" + asset_id);
            sbQueryStringParam.Append("&Asset_Search_ID=" + QS_ASSET_SEARCH_ID);
            sbQueryStringParam.Append("&Selected_Tab=" + selectedtab);

            return sbQueryStringParam.ToString();

        }

        /// <summary>
        /// Load form based on query strings
        /// </summary>
        private void LoadControlsFromQueryStringParam()
        {
            //Load Asset Info
            if (!isNull(QS_ASSET_ID))
            {
                LoadAssetInfo();
                LoadAssetNavigation();
            }

            //Load the selected Tab
            string selectedTab = Constants.VIEW_ASSET_TAB_ASSIGNMENTS; //Default Selected Tab
            if (!isNull(qsSelectedTab))
            {
                selectedTab = qsSelectedTab;
            }

            //based on the selected tab, load data and set the active css class
            switch (selectedTab)
            {
                case Constants.VIEW_ASSET_TAB_ATTACHMENT:
                    liTab_Attachment.Attributes.Add("class", "active");
                    divAttachment.Attributes.Add("class", "active");
                    tabAttachment.LoadAttachmentDG();
                    break;
                case Constants.VIEW_ASSET_TAB_COMMENTS:
                    liTab_Comments.Attributes.Add("class", "active");
                    divComments.Attributes.Add("class", "active");
                    tabComments.LoadCommentsDG();
                    break;
                case Constants.VIEW_ASSET_TAB_CHANGES:
                    liTab_Changes.Attributes.Add("class", "active");
                    divChanges.Attributes.Add("class", "active");
                    tabChanges.LoadChangesDG(0);
                    break;
                case Constants.VIEW_ASSET_TAB_REPAIR:
                    liTab_Repair.Attributes.Add("class", "active");
                    divRepair.Attributes.Add("class", "active");
                    tabRepair.RefreshForm();
                    break;
                case Constants.VIEW_ASSET_TAB_TAMPER:
                    liTab_Tamper.Attributes.Add("class", "active");
                    divTamper.Attributes.Add("class", "active");
                    tabTamper.RefreshForm();
                    break;
                default:
                    liTab_Assignment.Attributes.Add("class", "active");
                    divAssignment.Attributes.Add("class", "active");
                    tabAssignment.LoadAssignmentDG();
                    break;
            }

        }

        /// <summary>
        /// modal used to display confirmation message 
        /// </summary>
        /// <param name="caption">caption</param>
        /// <param name="message">message</param>
        private void DisplayConfirmation(string caption, string message)
        {
            confirmTitle.Text = caption;
            confirmBody.Text = message;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "confirmPopup", "$('#confirmPopup').modal();", true);
            confirmModal.Update();
        }

        /// <summary>
        /// Validate boolean check before saving asset
        /// </summary>
        /// <returns></returns>
        private bool ValidateOnSaveAsset()
        {
            //initilize to true
            bool IsValid = true;
           
            //user data entered
            string tagid = txtTagIDEdit.Text.Trim();
            string serial_number = txtSerialNumberEdit.Text.Trim();

            //String builder to store all the possible validation errors
            StringBuilder sbErrorMessage = new StringBuilder();

            //Dataset return from user input
            DataSet dsValidateEdit = DatabaseUtilities.DsValidateEditAsset(QS_ASSET_ID, tagid, serial_number);

            //Check to see if data returns
            if (dsValidateEdit.Tables[0].Rows.Count > 0)
            {
                //set to false because errrors were found
                IsValid = false;

                //loop thru each error and append to string builder
                foreach (DataRow row in dsValidateEdit.Tables[0].Rows)
                {
                    sbErrorMessage.Append("<li>" + row["Error_Msg"].ToString() + "</li>");
                }
            }

            //Not valid
            if (!IsValid)
            {
                //set the custom validator to false and store the message to display to the user
                cvErrorEditAsset.IsValid = false;
                cvErrorEditAsset.Text = sbErrorMessage.ToString();
                cvErrorEditAsset.ErrorMessage = sbErrorMessage.ToString();
            }

            //return value
            return IsValid;
        }

        /// <summary>
        /// Check to see if the form is in Edit Asset Mode is visible will determine if the form is in edit mode.
        /// </summary>
        /// <returns></returns>
        private bool IsEditAssetMode()
        {
            return btnSaveAsset.Visible;
        }
        
        /// <summary>
        /// Load the drop down list for asset condition
        /// </summary>
        protected void DDLLoadAssetCondition()
        {
            ddlCondition.reqAssetCondition.EnableClientScript = true;
            ddlCondition.LoadDDLAssetCondition("", true, true, false);
            ddlCondition.AutoPostBack = false;
        }

        private void ShowHideActions()
        {
            bool showEwaste = true;
            bool showEwasteRevert = true;
            bool showDeadPool = true;
            bool showDeadPoolRevert = true;
            bool showTransfer = true;
            bool showLawEnforcement = true;

            lnkBtnEwaste.ToolTip = "";
            lnkBtnLawEnforcement.ToolTip = "";
            
            string tool_tip = "";

            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_MASTER_LIST, "Asset_ID", QS_ASSET_ID, "");

            if (ds.Tables[0].Rows.Count > 0)
            {
                string sLeased = ds.Tables[0].Rows[0]["Is_Leased"].ToString().ToLower().Trim();
                string sLeased_ADP_Count = ds.Tables[0].Rows[0]["Leased_ADP_Count"].ToString().ToLower().Trim();
                string sDisposition = ds.Tables[0].Rows[0]["Asset_Disposition_ID"].ToString();
                string sDisposition_Desc = ds.Tables[0].Rows[0]["Asset_Disposition_Desc"].ToString();
                
                string sAllowEwaste = ds.Tables[0].Rows[0]["Allow_Ewaste"].ToString();
                string sAllowDeadpool = ds.Tables[0].Rows[0]["Allow_Deadpool"].ToString();
                string sAllowTransfer = ds.Tables[0].Rows[0]["Allow_Transfer"].ToString();
                string sAllowLawEnforcement = ds.Tables[0].Rows[0]["Allow_Law_Enforcement"].ToString();
                
                int iLeased_ADP_Count = int.Parse(sLeased_ADP_Count);
                bool IsLeased = sLeased.Equals("yes");
                bool IsAllowEwaste = sAllowEwaste.Equals("1");
                bool IsAllowDeadpool = sAllowDeadpool.Equals("1");
                bool IsAllowTransfer = sAllowTransfer.Equals("1");
                bool IsAllowLawEnforcement = sAllowLawEnforcement.Equals("1");

                if (IsLeased)
                {
                    //Should not be visible if not leased
                    lnkBtnEwaste.Visible = false;
                }
                showEwaste = !IsLeased && IsAllowEwaste;
                showEwasteRevert = sDisposition.Equals(Constants.DISP_E_WASTE_WAREHOUSE);
                
                showDeadPool = IsLeased && iLeased_ADP_Count >= 1 && IsAllowDeadpool;
                showDeadPoolRevert = sDisposition.Equals(Constants.DISP_DEAD_POOL);

                showTransfer = IsAllowTransfer;
                showLawEnforcement = IsAllowLawEnforcement;

                tool_tip = "Not allowed when disposition is \"" + sDisposition_Desc + "\"";
            }

            
            lnkBtnEwasteRevert.Visible = showEwasteRevert;
            
            lnkBtnDeadPoolAsset.Visible = showDeadPool;
            lnkBtnDeadPoolAssetRevert.Visible = showDeadPoolRevert;

            //check this first because security may have disabled link
            if (lnkBtnEwaste.Enabled)
            {
                lnkBtnEwaste.Enabled = showEwaste;
            }
            
            //check this first because security may have disabled link
            if (lnkBtnTransferAsset.Enabled)
            {
                lnkBtnTransferAsset.Enabled = showTransfer;
            }

            //check this first because security may have disabled link
            if (lnkBtnLawEnforcement.Enabled)
            {
                lnkBtnLawEnforcement.Enabled = showLawEnforcement;
            }

            if (!showEwaste)
            {
                lnkBtnEwaste.ToolTip = tool_tip;
            }

            if (!showTransfer)
            {
                lnkBtnTransferAsset.ToolTip = tool_tip;
            }

            if (!showLawEnforcement)
            {
                lnkBtnLawEnforcement.ToolTip = tool_tip;
            }

        }

        private void ApplySecurityToControl()
        {
            AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnTransferAsset);
            AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnEdit);
            AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnSaveAsset);
            AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnDeadPoolAsset);
            AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnDeadPoolAssetRevert);
            AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnEwaste);
            AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnEwasteRevert);
            AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnLawEnforcement);
        }

        /// <summary>
        /// Refresh the form and loads data based on query string parameters
        /// </summary>
        private void RefreshForm()
        {
            LoadControlsFromQueryStringParam();
            ShowHideActions();
            ReDrawToolTip();
        }

        private void DDLLoadSiteTransfer()
        {
            ddlSiteTransfer.LoadDDLSite(false, false, true, true, false, false, false);
            
            DataSet ds = DatabaseUtilities.DsGetAssetInfoByID(QS_ASSET_ID);
            if(ds.Tables[0].Rows.Count > 0){
                string current_asset_site_id = ds.Tables[0].Rows[0][Constants.COLUMN_V_ASSET_MASTER_LIST_Asset_Site_ID].ToString();
               
                //Check to see if the selected value exists before setting it.
                ListItem i = ddlSiteTransfer.ddlSite.Items.FindByValue(current_asset_site_id);
                if (ddlSiteTransfer.ddlSite.Items.Contains(i))
                {
                    ddlSiteTransfer.ddlSite.Items.Remove(i);
                }
            }
           
        }

        private void load_Law_Enforcement_Agency_DDL()
        {
            DataSet ds = DatabaseUtilities.DsGet_CTByTableName(Constants.TBL_CT_LAW_ENFORCEMENT_AGENCY, true);
            if (ds.Tables[0].Rows.Count > 0)
            {
                ddlLawEnforcementAgency.DataSource = ds;
                ddlLawEnforcementAgency.DataValueField = Constants.COLUMN_CT_LAW_ENFORCEMENT_AGENCY_ID;
                ddlLawEnforcementAgency.DataTextField = Constants.COLUMN_CT_LAW_ENFORCEMENT_AGENCY_Name;
                ddlLawEnforcementAgency.DataBind();

                ddlLawEnforcementAgency.Items.Insert(0, new ListItem(Constants._OPTION_PLEASE_SELECT_TEXT + "Agency ---", Constants._OPTION_PLEASE_SELECT_VALUE));
            }
        }

        private void ShowHideControlForLawEnforcementModal()
        {
            trDateReturned.Visible = !Asset_Law_Enforcement_ID.Equals("-1");
        }

        private void LoadLawEnforcementDG()
        {
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_LAW_ENFORCEMENT, "Asset_ID", QS_ASSET_ID, "ID Desc");

            if (ds.Tables[0].Rows.Count > 0)
            {
                dgLawEnforcement.DataSource = ds;
                dgLawEnforcement.DataBind();

            }
            else
            {
                CloseModal("divViewLawEnforcement");
            }
        }

        private void LoadControlsForLawEnforcementModal()
        {
            load_Law_Enforcement_Agency_DDL();

            LoadLawEnforcementInfo();
            
        }

        private void LoadLawEnforcementInfo()
        {
            string asset_law_enforcement_id = Asset_Law_Enforcement_ID;
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_LAW_ENFORCEMENT, "ID", asset_law_enforcement_id, "");
            
            ClearLawEnforcementForm();
            
            if (ds.Tables[0].Rows.Count > 0)
            {
                Utilities.DataBindForm(divLawEnforcementInfo, ds);
            }

        }

        private void ClearLawEnforcementForm()
        {
            ddlLawEnforcementAgency.SelectedIndex = 0;
            txtOfficerFirstName.Text = "";
            txtOfficerLastName.Text = "";
            txtCaseNumber.Text = "";
            txtComment.Text = "";
            txtDatePickup.Text = "";
        }

        protected bool IsAssetReturned(object o)
        {
            string dateReturned = ((DataRowView)o)["Date_Returned_Formatted"].ToString();

            return !Utilities.isNull(dateReturned);
        }

        private void DisplayTransferAsset()
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "TransferAssetModal", "$('#TransferAssetModal').modal();", true);

            DDLLoadSiteTransfer();

            updatePanelTransferModal.Update();
        }

        private void DisplayLawEnforcementManagePropertiesModal()
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "LawEnforcementManagePropertiesModal", "$('#divLawEnforcementManagePropertiesModal').modal();", true);

            LoadControlsForLawEnforcementModal();

            ShowHideControlForLawEnforcementModal();
            
            updatePanelLawEnforcementManageProperties.Update();
        }

        private void DisplayViewLawEnforcementModal()
        {
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ViewLawEnforcementModal", "$('#divViewLawEnforcement').modal();", true);

            LoadLawEnforcementDG();
        }

        private bool ValidateTransferAsset()
        {
            return true;
        }

        private void SaveTransferAsset()
        {
            string p_Asset_Search_ID = Constants.MCSDBNOPARAM;
            string p_Asset_ID = QS_ASSET_ID;
            string p_Transfer_Site_ID = ddlSiteTransfer.SelectedValue;
            string p_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
            string p_Date = DateTime.Now.ToString();

            DatabaseUtilities.SaveTransferAsset(p_Asset_Search_ID, p_Asset_ID, p_Transfer_Site_ID, p_Emp_ID, p_Date);
        }

        private void SaveAsset()
        {
            Utilities.Assert(!QS_ASSET_ID.Equals("-1"), "Cannot insert Asset");
            if (!isNull(QS_ASSET_ID))
            {
                string p_ID = QS_ASSET_ID;
                string p_Tag_ID = txtTagIDEdit.Text;
                string p_Serial_Number = txtSerialNumberEdit.Text;
                string p_PurchaseDate = txtPurchaseDate.Text;
                if (Utilities.isNull(p_PurchaseDate))
                {
                    p_PurchaseDate = Constants.MCSDBNULL;
                }
                string p_Leased_Term_Days = Utilities.ConvertStringToDBNull(txtLeasedTermDays.Text);
                string p_Warranty_Term_Days = Utilities.ConvertStringToDBNull(txtWarrantyTerm.Text);

                string p_Asset_Condition_ID = ddlCondition.SelectedValue;
                string p_Is_Active = Constants.MCSDBNOPARAM;
                if (chkIsActiveEdit.Enabled)
                {
                    p_Is_Active = "0";
                    if (chkIsActiveEdit.Checked)
                    {
                        p_Is_Active = "1";
                    }
                }
                string p_Modified_By_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
                string p_Date_Modified = DateTime.Now.ToString();

                DatabaseUtilities.Upsert_Asset(
                    QS_ASSET_ID,
                    p_Tag_ID,
                    Constants.MCSDBNOPARAM,
                    p_Asset_Condition_ID,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    p_Serial_Number,
                    p_PurchaseDate,
                    p_Leased_Term_Days,
                    p_Warranty_Term_Days,
                    Constants.MCSDBNOPARAM,
                    p_Is_Active,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    p_Modified_By_Emp_ID,
                    p_Date_Modified
                );
            }
        }

        private void SaveAssetLawEnforcement()
        {
            string empid = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
            string datetimenow = DateTime.Now.ToString();

            string p_ID = Asset_Law_Enforcement_ID;
            string p_Asset_ID = QS_ASSET_ID;
            string p_Law_Enforcement_Agency_ID = ddlLawEnforcementAgency.SelectedValue;
            string p_Officer_First_Name = txtOfficerFirstName.Text;
            string p_Officer_Last_Name = txtOfficerLastName.Text;
            string p_Case_Number = txtCaseNumber.Text;
            string p_Comment = txtComment.Text;
            string p_Date_Picked_Up = txtDatePickup.Text;
            string p_Date_Returned = Constants.MCSDBNOPARAM;
            string p_Received_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Added_By_Emp_ID = empid; 
            string p_Date_Added = datetimenow;
            string p_Modified_By_Emp_ID = Constants.MCSDBNOPARAM;
            string p_Date_Modified = Constants.MCSDBNOPARAM;

            bool IsInsertAssetLawEnforcement = Asset_Law_Enforcement_ID.Equals("-1");

            if (!IsInsertAssetLawEnforcement)
            {
                p_Added_By_Emp_ID = Constants.MCSDBNOPARAM;
                p_Date_Added = Constants.MCSDBNOPARAM;
                p_Modified_By_Emp_ID = empid;
                p_Date_Modified = datetimenow;
            }

            DatabaseUtilities.Upsert_Asset_Law_Enforcement(
                p_ID,
                p_Asset_ID,
                p_Law_Enforcement_Agency_ID,
                p_Officer_First_Name,
                p_Officer_Last_Name,
                p_Case_Number,
                p_Comment,
                p_Date_Picked_Up,
                p_Date_Returned,
                p_Received_By_Emp_ID,
                p_Added_By_Emp_ID,
                p_Date_Added,
                p_Modified_By_Emp_ID,
                p_Date_Modified
           );

            //Update asset disposition on insert
            if (IsInsertAssetLawEnforcement)
            {
                //Update disposition on asset
                DatabaseUtilities.SaveAssetDisposition(QS_ASSET_ID, Constants.DISP_LAW_ENFORCEMENT, Utilities.GetLoggedOnUser());
            }
        }

        private void SaveMarkReturnLawEnforcement(string asset_law_enforcement_id)
        {
            string empid = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
            string datetimenow = DateTime.Now.ToString();

            DatabaseUtilities.Upsert_Asset_Law_Enforcement(
                asset_law_enforcement_id,
                Constants.MCSDBNOPARAM,
                Constants.MCSDBNOPARAM,
                Constants.MCSDBNOPARAM,
                Constants.MCSDBNOPARAM,
                Constants.MCSDBNOPARAM,
                Constants.MCSDBNOPARAM,
                Constants.MCSDBNOPARAM,
                datetimenow,
                empid,
                Constants.MCSDBNOPARAM,
                Constants.MCSDBNOPARAM,
                empid,
                datetimenow
            );
        }

        protected new void Page_Load(object sender, EventArgs e)
        {
            Utilities.Assert(!isNull(QS_ASSET_ID), "You must provide an Asset ID");

            //Check to see if user can access this specific asset
            bool CanUserAccessAsset = AppSecurity.Can_View_Site_Asset(QS_ASSET_ID);
            if (!CanUserAccessAsset)
            {
                string description = "CAIRS - Unauthorized Access - User trying to access Asset ID: " + QS_ASSET_ID;
                //process unauthorized access
                Unauthorized_Access(description);
            }

            if (!IsPostBack)
            {
                //initilize these control when page first loads
                txtTagIDEdit.reqTagID.EnableClientScript = true;
                txtSerialNumberEdit.reqSerialNum.EnableClientScript = true;

                //Load controls
                DDLLoadAssetCondition();
                
                //Refresh Form
                RefreshForm();

                //Security set controls
                ApplySecurityToControl();
            }

            //Events that needs to happen on every postback
            tabRepair.btnSaveRepair_Click += btnRefreshFormClick;
            tabRepair.btnDeleteRepair_Click += btnRefreshFormClick;
            tabRepair.btnSaveMarkReceived_Click += btnRefreshFormClick;
            tabTamper.btnDeleteTamperClick += btnRefreshFormClick;
            tabTamper.btnSaveTamperClick += btnRefreshFormClick;
        }

        protected void dgLawEnforcement_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            if (e.Item.ItemIndex >= 0)
            {
                Button btnMarkReturned = ((Button)e.Item.FindControl("btnMarkAssetLawEnforcementReturn"));
                Button btnDelete = ((Button)e.Item.FindControl("btnDeleteAssetLawEnforcement"));

                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnMarkReturned);
                AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnDelete);
            }
        }

        protected void btnRefreshFormClick(object sender, EventArgs e)
        {
            RefreshForm();
        }

        private void ApplySecurityToControl(string site_code)
        {
            //initialize
            lnkBtnEdit.Enabled = true;
            btnSaveAsset.Enabled = true;
            lnkBtnDeadPoolAsset.Enabled = true;
            lnkBtnDeadPoolAssetRevert.Enabled = true;
            lnkBtnEwaste.Enabled = true;
            lnkBtnEwasteRevert.Enabled = true;
            lnkBtnLawEnforcement.Enabled = true;

            lnkBtnEdit.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
            btnSaveAsset.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
            lnkBtnDeadPoolAsset.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
            lnkBtnDeadPoolAssetRevert.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
            lnkBtnEwaste.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
            lnkBtnEwasteRevert.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
            lnkBtnLawEnforcement.Attributes[AppSecurity.SECURITY_SITE_CODE] = site_code;
        }

        private void LoadAssetInfo()
        {
            DataSet ds = DatabaseUtilities.DsGetAssetInfoByID(QS_ASSET_ID);
            int iRowCount = ds.Tables[0].Rows.Count;
            Utilities.Assert(iRowCount > 0, "No Data found for Asset ID: " + QS_ASSET_ID);

            Utilities.DataBindForm(divAssetInfo, ds);

            string sAllowInactivate = ds.Tables[0].Rows[0]["Allow_Inactivate"].ToString();
            string datePurchased = ds.Tables[0].Rows[0]["Date_Purchased"].ToString();
            string site_code = ds.Tables[0].Rows[0]["Asset_Site_Code"].ToString();
            string law_enforcement_count = ds.Tables[0].Rows[0]["Law_Enforcement_Count"].ToString();

            bool isAllowInactivate = sAllowInactivate.Equals("1");
            chkIsActiveEdit.Enabled = isAllowInactivate;

            trViewLawEnforcement.Visible = !law_enforcement_count.Equals("0");

            txtPurchaseDate.Text = datePurchased;
    
            ApplySecurityToControl(site_code);
        }

        private void LoadAssetNavigation()
        {
            //Update selected asset id
            DatabaseUtilities.UpdateAssetSearchSelectedAsset(QS_ASSET_SEARCH_ID, QS_ASSET_ID);

            //Get Asset Search Info Dataset
            DataSet ds = DatabaseUtilities.DsGetAssetSearchForNavigation(QS_ASSET_SEARCH_ID, QS_ASSET_ID);

            btnFirst.Enabled = false;
            btnPrevious.Enabled = false;
            btnNext.Enabled = false;
            btnLast.Enabled = false;

            if (ds.Tables[0].Rows.Count > 0)
            {
                string current_sort_order = ds.Tables[0].Rows[0]["Selected_Sort_Order"].ToString();
                string totalcount = ds.Tables[0].Rows[0]["Total"].ToString();
                string prev_asset_id = ds.Tables[0].Rows[0]["Previous_Asset_ID"].ToString();
                string next_asset_id = ds.Tables[0].Rows[0]["Next_Asset_ID"].ToString();
                string last_asset_id = ds.Tables[0].Rows[0]["Last_Asset_ID"].ToString();
                string first_asset_id = ds.Tables[0].Rows[0]["First_Asset_ID"].ToString();
                
                //Asset List button text
                string sOutOf = "";
                if (!isNull(current_sort_order) && !isNull(totalcount))
                {
                    sOutOf = " (" + current_sort_order + " of " + totalcount + ")";
                }
                btnReturn.Text = "Asset List" + sOutOf;
                //First 
                if (!isNull(first_asset_id) && !QS_ASSET_ID.Equals(first_asset_id))
                {
                    btnFirst.Enabled = true;
                    btnFirst.Attributes["Asset_ID"] = first_asset_id;
                }
                //Previous
                if (!isNull(prev_asset_id))
                {
                    btnPrevious.Enabled = true;
                    btnPrevious.Attributes["Asset_ID"] = prev_asset_id;
                }
                //Next
                if (!isNull(next_asset_id))
                {
                    btnNext.Enabled = true;
                    btnNext.Attributes["Asset_ID"] = next_asset_id;
                }
                //Last
                if (!isNull(last_asset_id) && !QS_ASSET_ID.Equals(last_asset_id))
                {
                    btnLast.Enabled = true;
                    btnLast.Attributes["Asset_ID"] = last_asset_id;
                }
            }
        }

        private void NavigateThruAsset(string asset_id)
        {
            if (isNull(asset_id))
            {
                asset_id = QS_ASSET_ID;
            }
            string page = Constants.PAGES_MANAGE_ASSET_PROPERTIES_PAGE + BuildQueryStringParam(asset_id, qsSelectedTab);
            if (!IsEditAssetMode())
            {
                NavigateTo(page, false);
            }
            hdnPageNavigation.Value = page;
            DisplayConfirmation("Edit Mode", "You are currently in Edit Mode. If you click on Confirm & Return, your changes will NOT be saved.");
        }

        private void NavigateThruTabs(string tab)
        {
            if (isNull(tab))
            {
                tab = Constants.VIEW_ASSET_TAB_ASSIGNMENTS;
            }
            string page = Constants.PAGES_MANAGE_ASSET_PROPERTIES_PAGE + BuildQueryStringParam(QS_ASSET_ID, tab);
            
            if (!IsEditAssetMode())
            {
                NavigateTo(page, false);
            }

            hdnPageNavigation.Value = page;
            DisplayConfirmation("Edit Mode", "You are currently in Edit Mode. If you click on Confirm & Return, your changes will NOT be saved.");
        }

        private void NavigateToSelfPage()
        {
            //get the query string parameter from Request
            string querystringparam = Request.QueryString.ToString();
            //build page to navigate to
            string page = Constants.PAGES_MANAGE_ASSET_PROPERTIES_PAGE + "?" + querystringparam;

            //Navigate to page
            NavigateTo(page, false);
        }

        private void ShowHideEditAsset(bool ShowEdit)
        {
            //Refresh the form when show/hide edit asset modal because data may have been updated
            RefreshForm();

            //Show these controls on edit
            txtTagIDEdit.Visible = ShowEdit;
            txtSerialNumberEdit.Visible = ShowEdit;
            ddlCondition.Visible = ShowEdit;
            txtPurchaseDate.Visible = ShowEdit;
            txtLeasedTermDays.Visible = ShowEdit;
            txtWarrantyTerm.Visible = ShowEdit;
            chkIsActiveEdit.Visible = ShowEdit;
            trSaveEditAsset.Visible = ShowEdit;

            //Hide these control when not editing
            lblTagID.Visible = !ShowEdit;
            lblSerialNumber.Visible = !ShowEdit;
            lblCondition.Visible = !ShowEdit;
            lblPurchaseDate.Visible = !ShowEdit;
            lblLeasedTermDays.Visible = !ShowEdit;
            lblWarrantyTermDays.Visible = !ShowEdit;
            lblIsActive.Visible = !ShowEdit;
            lnkBtnEdit.Visible = !ShowEdit;
           
        }

        protected void lnkBtnTAB_Assignments_Click(object sender, EventArgs e)
        {
            //NavigateTo(Constants.PAGES_MANAGE_ASSET_PROPERTIES_PAGE + BuildQueryStringParam(QS_ASSET_ID, Constants.VIEW_ASSET_TAB_ASSIGNMENTS), false);
            NavigateThruTabs(Constants.VIEW_ASSET_TAB_ASSIGNMENTS);
        }

        protected void lnkBtnTAB_Attachment_Click(object sender, EventArgs e)
        {
            NavigateThruTabs(Constants.VIEW_ASSET_TAB_ATTACHMENT);
        }

        protected void lnkBtnTAB_Comments_Click(object sender, EventArgs e)
        {
            NavigateThruTabs(Constants.VIEW_ASSET_TAB_COMMENTS);
        }

        protected void lnkBtnTAB_Changes_Click(object sender, EventArgs e)
        {
            NavigateThruTabs(Constants.VIEW_ASSET_TAB_CHANGES);
        }

        protected void lnkBtnTAB_Repair_Click(object sender, EventArgs e)
        {
            NavigateThruTabs(Constants.VIEW_ASSET_TAB_REPAIR);
        }

        protected void lnkBtnTAB_Tamper_Click(object sender, EventArgs e)
        {
            NavigateThruTabs(Constants.VIEW_ASSET_TAB_TAMPER);
        }

        protected void lnkBtnEdit_Click(object sender, EventArgs e)
        {
            ShowHideEditAsset(true);
        }

        protected void btnSaveAsset_Click(object sender, EventArgs e)
        {
            if (ValidateOnSaveAsset() && Page.IsValid)
            {
                SaveAsset();
                ShowHideEditAsset(false);
                NavigateThruTabs(qsSelectedTab);
            }
        }

        protected void btnCancelSave_Click(object sender, EventArgs e)
        {
            //NavigateTo(Constants.PAGES_MANAGE_ASSET_PROPERTIES_PAGE + BuildQueryStringParam(QS_ASSET_ID, qsSelectedTab), false);
            ShowHideEditAsset(false);
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string pagenavigation = hdnPageNavigation.Value;
            if (!isNull(pagenavigation))
            {
                NavigateTo(pagenavigation, false);
            }
            NavigateBack();
        }

        protected void btnFirst_Click(object sender, EventArgs e)
        {
            string asset_id = btnFirst.Attributes["Asset_ID"];
            NavigateThruAsset(asset_id);
        }

        protected void btnPrevious_Click(object sender, EventArgs e)
        {
            string asset_id = btnPrevious.Attributes["Asset_ID"];
            NavigateThruAsset(asset_id);
        }

        protected void btnReturn_Click(object sender, EventArgs e)
        {
            if (!IsEditAssetMode())
            {
                NavigateBack();
            }
            hdnPageNavigation.Value = "";
            DisplayConfirmation("Edit Mode", "You are currently in Edit Mode. If you click on Confirm & Return, your changes will NOT be saved.");
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            string asset_id = btnNext.Attributes["Asset_ID"];
            NavigateThruAsset(asset_id);
        }

        protected void btnLast_Click(object sender, EventArgs e)
        {
            string asset_id = btnLast.Attributes["Asset_ID"];
            NavigateThruAsset(asset_id);
        }

        protected void lnkBtnDeadPoolAsset_Click(object sender, EventArgs e)
        {
            DatabaseUtilities.SaveAssetDisposition(QS_ASSET_ID, Constants.DISP_DEAD_POOL, LoggedOnUser);
            NavigateThruTabs(qsSelectedTab);
        }

        protected void lnkBtnEwaste_Click(object sender, EventArgs e)
        {
            DatabaseUtilities.SaveAssetDisposition(QS_ASSET_ID, Constants.DISP_E_WASTE_WAREHOUSE, LoggedOnUser);
            NavigateThruTabs(qsSelectedTab);
        }

        protected void lnkBtnRevertDeadPoolOrEwaste_Click(object sender, EventArgs e)
        {
            Utilities.RevertPreviousDispositionByAssetID(QS_ASSET_ID);
            NavigateThruTabs(qsSelectedTab);
        }

        protected void lnkBtnTransferAsset_Click(object sender, EventArgs e)
        {
            DisplayTransferAsset();
        }

        protected void btnSaveTransfer_Click(object sender, EventArgs e)
        {
            if (ValidateTransferAsset() && Page.IsValid)
            {
                SaveTransferAsset();
                NavigateThruTabs(qsSelectedTab);
            }
        }

        protected void lnkBtnLawEnforcement_Click(object sender, EventArgs e)
        {
            Asset_Law_Enforcement_ID = "-1"; //indicate insert
            DisplayLawEnforcementManagePropertiesModal();
        }

        protected void btnSaveLawEnforcement_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                //Save Asset_Law_Enforcement
                SaveAssetLawEnforcement();

                RefreshForm();

                CloseModal("divLawEnforcementManagePropertiesModal");

                bool IsInsertAssetLawEnforcement = Asset_Law_Enforcement_ID.Equals("-1");
                if (!IsInsertAssetLawEnforcement)
                {
                    DisplayViewLawEnforcementModal();
                }
            }
        }

        protected void lnkBtnViewLawEnforcement_Click(object sender, EventArgs e)
        {
            DisplayViewLawEnforcementModal();
        }

        protected void btnMarkAssetLawEnforcementReturn_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string asset_law_enforcement_id = btn.Attributes["Asset_Law_Enforcement_ID"];

            //Mark law enforcement record as return
            SaveMarkReturnLawEnforcement(asset_law_enforcement_id);
            
            //Update disposition on asset
            DatabaseUtilities.SaveAssetDisposition(QS_ASSET_ID, Constants.DISP_AVAILABLE, Utilities.GetLoggedOnUser());

            //refresh datagrid
            LoadLawEnforcementDG();

            //refresh form
            RefreshForm();
        }

        protected void btnViewAssetLawEnforcementDetails_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            Asset_Law_Enforcement_ID= btn.Attributes["Asset_Law_Enforcement_ID"];

            CloseModal("divViewLawEnforcement");

            DisplayLawEnforcementManagePropertiesModal();
        }

        protected void btnDeleteAssetLawEnforcement_Click(object sender, EventArgs e)
        {
            //instantiate button to the object
            Button btn = (Button)sender;

            //get id from attribute
            string asset_law_enforcement_id = btn.Attributes["Asset_Law_Enforcement_ID"];

            //delete the law enforcement record by id
            DatabaseUtilities.DeleteAsset_Law_Enforcement(asset_law_enforcement_id);

            //revert the asset's dispoistion to previous disposition
            Utilities.RevertPreviousDispositionByAssetID(QS_ASSET_ID);

            //refresh the datagrid
            LoadLawEnforcementDG();

            //refresh the form 
            RefreshForm();
        }
    }
}