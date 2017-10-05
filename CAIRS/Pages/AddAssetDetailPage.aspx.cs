using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CAIRS.Pages
{
	public partial class AddAssetDetailPage : _CAIRSBasePage
	{
		private string qsHeaderID
		{
			get
			{
				return Request.QueryString["asset_temp_header_id"];
			}
		}

		/// <summary>
		/// Used to set the selected site on the modal for editing
		/// </summary>
		private string SELECT_SITE
		{
			get
			{
				return hdnSelectedSite.Value;
			}
			set
			{
				hdnSelectedSite.Value = value;
			}
		}

		/// <summary>
		/// Used to set the selected site on the modal for editing
		/// </summary>
		private string HAS_ASSET_IN_BIN
		{
			get
			{
				return hdnHasAssetInBin.Value;
			}
			set
			{
				hdnHasAssetInBin.Value = value;
			}
		}

		/// <summary>
		/// Display Modal for updating Site and Description for Batch
		/// </summary>
		/// <param name="IsUpdate">True will update the values to what is set in the database</param>
		private void DisplayHeaderInfoForUpdate(bool IsUpdate)
		{
			lblModalTitle.Text = "Edit Batch";
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupUpdateHeader", "$('#popupUpdateHeader').modal();", true);

			if (IsUpdate)
			{
				//Load Drop Down
				ddlSiteEdit.IsSiteRequired = true;
				ddlSiteEdit.LoadDDLSite(true, false, true, true, false, true, true);
				ddlSiteEdit.SelectedValue = SELECT_SITE;
				ddlSiteEdit.ddlSite.Attributes["DB_Site_ID"] = SELECT_SITE;
				ddlSiteEdit.ddlSite.Attributes["HAS_SITE_IN_BIN"] = HAS_ASSET_IN_BIN;

				updatePanelEditHeader.Update();
			}
		}

		/// <summary>
		/// Save Temp Header Info
		/// </summary>
		/// <param name="site">Site Parameter</param>
		/// <param name="description">Description Param</param>
		/// <returns>ID for the record that has been inserted or updated</returns>
		private string SaveTempHeaderTbl(string site, string description)
		{
			string p_ID = "-1";
			if (!isNull(qsHeaderID))
			{
				p_ID = qsHeaderID;
			}
			string p_Asset_Site_ID = site;
			string p_Name = ""; //Not saving name for now
			string p_Description = description;
			string p_Added_By_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
			string p_Date_Added = DateTime.Now.ToString();
			string p_Modified_By_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
			string p_Date_Modified = DateTime.Now.ToString(); ;
			string p_Has_Submit = "0";
			string p_Date_Submit = Constants.MCSDBNULL;
			string p_Submitted_By_Emp_ID = Constants.MCSDBNULL;

			return DatabaseUtilities.Upsert_Asset_Temp_Header(
				p_ID,
				p_Asset_Site_ID,
				p_Name,
				p_Description,
				p_Added_By_Emp_ID,
				p_Date_Added,
				p_Modified_By_Emp_ID,
				p_Date_Modified,
				p_Has_Submit,
				p_Date_Submit,
				p_Submitted_By_Emp_ID
			);

		}

        protected void DDLLoadBaseType()
        {
            ddlBaseType.IsAssetBaseTypeRequired = true;
            ddlBaseType.LoadDDLAssetBaseType(false, true, false);
            ddlBaseType.AutoPostBack = true;
        }

		/// <summary>
		/// Initial Load
		/// </summary>
		/// </summary>
		protected void DDLLoadAssetType()
		{
            string selectedBaseType = ddlBaseType.SelectedValue;
           
			ddlAssetType.IsAssetTypeRequired = true;
            ddlAssetType.LoadDDLAssetType(selectedBaseType, true, true, false);
			ddlAssetType.AutoPostBack = false;

            if (selectedBaseType.Contains("-"))
            {
                ddlAssetType.ddlAssetType.Items.Clear();
                ddlAssetType.ddlAssetType.Items.Insert(0, new ListItem("--- Select Base Type to Populate ---", "-1"));
            }

            bool isBaseTypePowerAdapter = selectedBaseType.Equals("3");

            serialNumberTemp.Visible = !isBaseTypePowerAdapter;
            txt_SerialNum.IsSerialNumRequired = !isBaseTypePowerAdapter;
            reqSerialNumberTemp.Visible = !isBaseTypePowerAdapter;

            updatePanelSerialNumber.Update();

		}

		/// <summary>
		/// Initial Load
		/// </summary>
		/// </summary>
		private void DDLLoadAssetCondition()
		{
			ddlAssetCondition.IsAssetConditionRequired = true;
			ddlAssetCondition.LoadDDLAssetCondition(Constants.BUSINESS_RULE_CONDITION_AVAILABLE_ADD_ASSET, true, true, false);
			ddlAssetCondition.AutoPostBack = false;

			//Default to New
			ddlAssetCondition.SelectedValue = "1";
		}

		/// <summary>
		/// Initial Load
		/// </summary>
		private void TXTSerialNumLoad()
		{
			txt_SerialNum.IsSerialNumRequired = false;
		}

		/// <summary>
		/// Initial Load
		/// </summary>
		private void TXTTagIDLoad()
		{
			txt_TagID.IsTagIDRequired = true;
		}

		/// <summary>
		/// Initial Load
		/// </summary>
		/// </summary>
		private void DDLLoadBin()
		{
			ddlBin.IsBinRequired = false;
			ddlBin.LoadDDLBin(SELECT_SITE, true, true, true, false);
			//ddlBin.AutoPostBack = true;
		}

		/// <summary>
		/// Load Detail Information. Populate control based on the last load
		/// </summary>
		private void LoadDetailInfo()
		{
			DataSet ds = DatabaseUtilities.DsGetAssetHeaderMostRecentDetail(qsHeaderID);

			if (ds.Tables[0].Rows.Count > 0)
			{
				SELECT_SITE = ds.Tables[0].Rows[0]["Asset_Site_ID"].ToString();
				HAS_ASSET_IN_BIN = ds.Tables[0].Rows[0]["HasAssetInBin"].ToString();
				string siteName = ds.Tables[0].Rows[0]["Asset_Site_Desc"].ToString();
				string sitecode = ds.Tables[0].Rows[0]["Asset_Site_Code"].ToString();
				string description = ds.Tables[0].Rows[0]["Description"].ToString();
				string bin = ds.Tables[0].Rows[0]["Bin_ID"].ToString();
                string asset_base_type_id = ds.Tables[0].Rows[0]["Asset_Base_Type_ID"].ToString();
				string assetType = ds.Tables[0].Rows[0]["Asset_Type_ID"].ToString();
				string condition = ds.Tables[0].Rows[0]["Asset_Condition_ID"].ToString();
				string disposition = ds.Tables[0].Rows[0]["Asset_Disposition_ID"].ToString();
				string isLeased = ds.Tables[0].Rows[0]["Is_Leased"].ToString();
				string hasSubmitted = ds.Tables[0].Rows[0]["Has_Submit"].ToString();
				string date_purchased = ds.Tables[0].Rows[0]["Date_Purchased"].ToString();
				string leased_term_days = ds.Tables[0].Rows[0]["Leased_Term_Days"].ToString();
				string warranty_term_days = ds.Tables[0].Rows[0]["Warranty_Term_Days"].ToString();
                

				bool HasSubmit = false;

				if (!isNull(hasSubmitted))
				{
					HasSubmit = bool.Parse(hasSubmitted);
				}

				lblDetailSiteName.Text = siteName;
				lblDetailDescription.Text = description;
				txtDescriptionEdit.Text = description;
				txtLeasedTermDays.Text = leased_term_days;
				txtPurchasedDate.Text = date_purchased;
				txtWarrantyTermDays.Text = warranty_term_days;

				DDLLoadBin();

				ddlBin.SelectedValue = bin;
                ddlBaseType.SelectedValue = asset_base_type_id;
                //reload asset type base on selected base type
                DDLLoadAssetType();
				ddlAssetType.SelectedValue = assetType;
				ddlAssetCondition.SelectedValue = condition;

				//Used for site level security
				lnkEditHeader.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				btnAddAsset.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				chkAll.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				lnkBtnEditSelected.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				lnkBtnAssignBinAssetTempToBin.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				btnSaveAssetDetail.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				btnUpdateHeader.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				btnSubmit.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				btnAddAssetTemp.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				btnDeleteSelectedAsset.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;

				//Hide edit if batch has been submitted
				lnkEditHeader.Visible = !HasSubmit;

				if (!isNull(isLeased))
				{
					chkIsLeased.Checked = bool.Parse(isLeased);
				}

			}
		}

		/// <summary>
		/// Load Asset Temp Detail Datagrid
		/// </summary>
		private void LoadAssetTempDG()
		{
			string sHeaderId = qsHeaderID;
			DataSet ds = DatabaseUtilities.DsGetAssetTempHeaderDetailByHeaderID(sHeaderId);

			int iRowCount = ds.Tables[0].Rows.Count;

			//initialize
			divHeaderGridInfo.Visible = false;
			dgTempAsset.Visible = false;
			lblResults.Text = "";
			btnSubmit.Visible = false;

			if (iRowCount > 0)
			{
				divHeaderGridInfo.Visible = true;
				dgTempAsset.Visible = true;
				lblResults.Text = "Total asset(s): " + iRowCount.ToString();
				dgTempAsset.CurrentPageIndex = int.Parse(PageIndex);
				dgTempAsset.DataSource = ds;
				dgTempAsset.DataBind();

				LoadDetailInfo();
				updatePanelEditHeader.Update();
			}
		}

		private void LoadEditAssetControls()
		{
			//Bin
			DDL_BinEditAsset.IsBinRequired = false;
			DDL_BinEditAsset.LoadDDLBin(SELECT_SITE, true, true, true, false);
			//DDL_BinEditAsset.AutoPostBack = true;

			//Asset Type
			DDL_AssetTypeEditAsset.IsAssetTypeRequired = true;
			DDL_AssetTypeEditAsset.LoadDDLAssetType(Constants._OPTION_ALL_VALUE, true, true, false);
			DDL_AssetTypeEditAsset.AutoPostBack = false;

			//Condition
			DDL_AssetConditionEditAsset.IsAssetConditionRequired = true;
			DDL_AssetConditionEditAsset.LoadDDLAssetCondition(Constants.BUSINESS_RULE_CONDITION_AVAILABLE_ADD_ASSET, true, true, false);
			DDL_AssetConditionEditAsset.AutoPostBack = false;

		}

		private void LoadControlForQueryStringParam()
		{
			//Detail Section
			LoadDetailInfo();
			//Load Asset Detail Grid
			LoadAssetTempDG();
			//Load Edit Controls
			LoadEditAssetControls();
			//show/hide leased info
			ShowHideLeasedInfo();
		}

		/// <summary>
		/// Validate on adding an asset to the temp table
		/// </summary>
		/// <returns></returns>
		private bool ValidateOnAddAsset()
		{
			bool IsAddValid = true;

			string sHeaderID = qsHeaderID;
			string sTagID = txt_TagID.Text;
			string sSerialNumber = txt_SerialNum.Text;
            if (ddlBaseType.SelectedValue.Equals("3"))
            {
                sSerialNumber = sTagID;
            }
			string sBinId = ddlBin.SelectedValue;
			string sIsLeased = "0";
			string sSelectedType = ddlAssetType.SelectedValue;
			if (chkIsLeased.Checked)
			{
				sIsLeased = "1";
			}

			string sErrorMsg = Utilities.ValidateOnAddAssetToTemp(sHeaderID, sTagID, sSerialNumber, sBinId, sIsLeased, sSelectedType);

			if (!isNull(sErrorMsg))
			{
				LoadMasterPageValidationGroup("vgAddAsset");
				cvDuplicateTagID.IsValid = false;
				cvDuplicateTagID.ErrorMessage = sErrorMsg;
				IsAddValid = false;
			}

			hdnIsAddTempDetailValid.Value = IsAddValid.ToString();
			return IsAddValid;
		}

		/// <summary>
		/// Loading Validation Group from the master page
		/// </summary>
		/// <param name="vgName">Name of Group</param>
		private void LoadMasterPageValidationGroup(string vgName)
		{
			CAIRSMasterPage ms = this.Master as CAIRSMasterPage;
			ms.vsValidationSummary.ValidationGroup = vgName;
		}

		/// <summary>
		/// Save Method for Asset_Temp_Detail
		/// </summary>
		private void SaveTempDetailTbl()
		{
			string p_ID = "-1";//Negative one (-1) indicates insert for upsert stored proc
			string p_Asset_Temp_Header_ID = qsHeaderID;
			string p_Tag_ID = txt_TagID.Text;
			string p_Asset_Disposition_ID = "5"; //Available
			string p_Asset_Condition_ID = ddlAssetCondition.SelectedValue;
			string p_Asset_Type_ID = ddlAssetType.SelectedValue;
			string p_Asset_Assignment_Type_ID = "1"; //1 for student
			string p_Bin_ID = ddlBin.SelectedValue;

			string p_Date_Added = DateTime.Now.ToString();
			string p_Added_By_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);

			//No Option was selected
			if (p_Bin_ID.Contains("-"))
			{
				p_Bin_ID = Constants.MCSDBNOPARAM;
			}

			string p_Serial_Number = txt_SerialNum.Text;
            if (!serialNumberTemp.Visible)
            {
                p_Serial_Number = p_Tag_ID;
            }
			string p_Date_Purchased = txtPurchasedDate.Text;
			string p_Is_Leased = Utilities.ConvertCheckBoxToBitField(chkIsLeased);
			string p_Leased_Term_Days = Constants.MCSDBNULL;
			string p_Warranty_Term_Days = Utilities.ConvertStringToDBNull(txtWarrantyTermDays.Text);

			if (chkIsLeased.Checked)
			{
				p_Leased_Term_Days = txtLeasedTermDays.Text.Trim();

			}

			DatabaseUtilities.Upsert_Asset_Temp_Detail(
				p_ID,
				p_Asset_Temp_Header_ID,
				p_Tag_ID,
				p_Asset_Disposition_ID,
				p_Asset_Condition_ID,
				p_Asset_Type_ID,
				p_Asset_Assignment_Type_ID,
				p_Bin_ID,
				p_Serial_Number,
				p_Date_Purchased,
				p_Is_Leased,
				p_Leased_Term_Days,
				p_Warranty_Term_Days,
				p_Date_Added,
				p_Added_By_Emp_ID
			);
		}

		private void SaveEditDetailByID(string p_ID)
		{
			//Default to no param
			string p_Asset_Temp_Header_ID = Constants.MCSDBNOPARAM;
			string p_Tag_ID = Constants.MCSDBNOPARAM;
			string p_Asset_Assignment_Type_ID = Constants.MCSDBNOPARAM;
			string p_Serial_Number = Constants.MCSDBNOPARAM;
			string p_Date_Purchased = Constants.MCSDBNOPARAM;
			string p_Asset_Disposition_ID = "5"; //Default to Available 
			string p_Asset_Condition_ID = Constants.MCSDBNOPARAM;
			string p_Asset_Type_ID = Constants.MCSDBNOPARAM;
			string p_Is_Leased = Constants.MCSDBNOPARAM;
			string p_Leased_Term_Days = Constants.MCSDBNOPARAM;
			string p_Warranty_Term_Days = Constants.MCSDBNOPARAM;

			//Bin is always visible
			string p_Bin_ID = DDL_BinEditAsset.SelectedValue;
			//No Option was selected
			if (p_Bin_ID.Contains("-"))
			{
				p_Bin_ID = Constants.MCSDBNULL;
			}

			//Auditing fields
			string p_Date_Added = DateTime.Now.ToString();
			string p_Added_By_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);

			//Check edit mode
			string sIsedit = hdnIsEditAssetTemp.Value;
			bool isEdit = false;
			if (!isNull(sIsedit))
			{
				isEdit = bool.Parse(sIsedit);
			}

			//If Edit update fields
			if (isEdit)
			{
				p_Asset_Condition_ID = DDL_AssetConditionEditAsset.SelectedValue;
				p_Asset_Type_ID = DDL_AssetTypeEditAsset.SelectedValue;
				p_Is_Leased = Utilities.ConvertCheckBoxToBitField(chkIsLeasedEditAsset);
				p_Date_Purchased = txtPurchasedDateEditAsset.Text;
				p_Warranty_Term_Days = Utilities.ConvertStringToDBNull(txtWarrantyTermDaysEditAsset.Text);

				if (chkIsLeasedEditAsset.Checked)
				{
					p_Leased_Term_Days = txtLeasedTermEditAsset.Text.Trim();
				}
			}

			DatabaseUtilities.Upsert_Asset_Temp_Detail(
				p_ID,
				p_Asset_Temp_Header_ID,
				p_Tag_ID,
				p_Asset_Disposition_ID,
				p_Asset_Condition_ID,
				p_Asset_Type_ID,
				p_Asset_Assignment_Type_ID,
				p_Bin_ID,
				p_Serial_Number,
				p_Date_Purchased,
				p_Is_Leased,
				p_Leased_Term_Days,
				p_Warranty_Term_Days,
				p_Date_Added,
				p_Added_By_Emp_ID
			);
		}

		/// <summary>
		/// Initial Control after loading. This is used for scanning so the user can move to the next scan without any key strokes
		/// </summary>
		private void IntializeControlAfterAdd()
		{
			chkAll.Checked = false;
			txt_SerialNum.Text = "";
			txt_TagID.Text = "";
			//SetFocus(txt_SerialNum.txtSerialNumber);
		}

		private void DisplayCapacityMessage(DropDownList ddl, bool isEditAssetTemp)
		{
			//initialize
			//lbl.Text = "";
			string bin_id = ddl.SelectedValue;
			DataSet ds = DatabaseUtilities.DsGetAvaiableCapacity(qsHeaderID, bin_id);
			hdnAvailableCapacityEditAssetTemp.Value = "0";

			if (ds.Tables[0].Rows.Count > 0)
			{
				string available = ds.Tables[0].Rows[0]["Available"].ToString();
				if (isEditAssetTemp)
				{
					hdnAvailableCapacityEditAssetTemp.Value = available;
				}

				string current_batch = ds.Tables[0].Rows[0]["Current_Batch_Total"].ToString();
				if (int.Parse(available).Equals(0))
				{
					available = "<span class='invalid'>" + available + " (FULL)<span>";
				}
				//lbl.Text = "Capacity Used for this batch: " + current_batch + " Available: " + available;


			}

		}

		private void DisplaySubmitSuccessMessage()
		{
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupMessage", "$('#popupSubmitSuccessMessage').modal();", true);
		}

		/// <summary>
		/// Clear form for adding new asset
		/// </summary>
		private void ClearForm()
		{
			ddlBin.ddlBin.SelectedIndex = 0;
			ddlAssetType.ddlAssetType.SelectedIndex = 0;
			ddlAssetCondition.ddlAssetCondition.SelectedIndex = 0;
			chkIsLeased.Checked = false;
			txt_SerialNum.Text = "";
			txt_TagID.Text = "";
			//lblCapacityMessage.Text = "";
			serialNumberTemp.Text = "";
			tagIDTemp.Text = "";
		}

		private bool ValidateIsAtLeastOneItemCheck()
		{
			int iCountOfSelectedItemInGrid = Utilities.GetCountOfCheckItemInInDatagrid(dgTempAsset, "chkAsset");

			hdnSelectedCapacityEditAssetTemp.Value = iCountOfSelectedItemInGrid.ToString();

			return iCountOfSelectedItemInGrid > 0;
		}

		private void ClearEditAssetTempControl()
		{
			//lblCapacityEditAsset.Text = "";
			DDL_BinEditAsset.ddlBin.SelectedIndex = 0;
			DDL_AssetTypeEditAsset.ddlAssetType.SelectedIndex = 0;
			DDL_AssetConditionEditAsset.ddlAssetCondition.SelectedIndex = 0;
			chkIsLeasedEditAsset.Checked = false;
			txtPurchasedDateEditAsset.Text = "";
			txtWarrantyTermDaysEditAsset.Text = "";
		}

		private void DisplayEditAsset()
		{
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupEditAssetDetail", "$('#popupEditAssetDetail').modal();", true);
			string sIsedit = hdnIsEditAssetTemp.Value;
			bool isEdit = false;
			if (!isNull(sIsedit))
			{
				isEdit = bool.Parse(sIsedit);
			}

			trEditAssetTemp_AssetCondition.Visible = isEdit;
			trEditAssetTemp_AssetType.Visible = isEdit;
			trEditAssetTemp_IsLeased.Visible = isEdit;
			trEditAssetTemp_PurchasedDate.Visible = isEdit;
			trEditAssetTemp_WarrantyTermDays.Visible = isEdit;

			updatePanelEditAssetDetail.Update();

		}

		private void ShowEditAssetTempModal(bool isEdit)
		{
			//initilize control
			spEditAssetLeasedInfo.Visible = false;
			txtLeasedTermEditAsset.Text = "";
			txtPurchasedDateEditAsset.Text = "";

			hdnAvailableCapacityEditAssetTemp.Value = "0";
			hdnSelectedCapacityEditAssetTemp.Value = "0";
			hdnIsEditAssetTemp.Value = isEdit.ToString();

			if (ValidateIsAtLeastOneItemCheck())
			{
				ClearEditAssetTempControl();
				DisplayEditAsset();
			}
			else
			{
				DisplayMessage("Validation", "Please select at least one item from the grid to peform an action");
			}
		}

		/// <summary>
		/// Validate data on submiting data
		/// </summary>
		/// <returns></returns>
		private bool ValidateOnSubmitAsset()
		{
			bool IsAddValid = true;
			string sHeaderID = qsHeaderID;

			//string sErrorMsg = Utilities.ValidateOnSubmitAdd(sHeaderID);
			bool isValidForSubmit = Utilities.ValidateOnSubmitAdd(sHeaderID);

			//if (!isNull(sErrorMsg))
			if (!isValidForSubmit)
			{
				string msg = "Please fix the error(s) according to the grid before submitting.";
				//Set Validation Group
				LoadMasterPageValidationGroup("vgSubmitAsset");

				cvSubmitAsset.IsValid = false;
				cvDuplicateTagID.Text = "*";
				cvSubmitAsset.ErrorMessage = msg;
				IsAddValid = false;
			}

			return IsAddValid;
		}

		private void SaveEditAssetDetailTemp()
		{
			//loop thru each of the check box on the grid and save
			foreach (DataGridItem item in dgTempAsset.Items)
			{
				CheckBox chk = (CheckBox)item.FindControl("chkAsset");
				if (chk != null)
				{
					if (chk.Checked)
					{
						string asset_detail_id = chk.Attributes["Detailed_ID"];
						if (!isNull(asset_detail_id))
						{
							SaveEditDetailByID(asset_detail_id);
						}
					}
				}
			}
		}

		private bool ValidateOnEditAssetTempDetail(string bin_id)
		{
			bool IsEditValid = true;
			string sHeaderID = qsHeaderID;
			string TooManySelectedForCapacity = "";

			string sCapacity = hdnAvailableCapacityEditAssetTemp.Value;
			string sSelectedItemCount = hdnSelectedCapacityEditAssetTemp.Value;
			int iCapacity = 0;
			int iSelectedItemCount = 0;
			string selectedBin = DDL_BinEditAsset.SelectedValue;

			//only validate against bin when one has been selected
			if (!selectedBin.Contains("-"))
			{
				if (Utilities.IsNumeric(sCapacity))
				{
					iCapacity = int.Parse(sCapacity);
				}
				if (Utilities.IsNumeric(sSelectedItemCount))
				{
					iSelectedItemCount = int.Parse(sSelectedItemCount);
				}

				if (iSelectedItemCount > iCapacity)
				{
					TooManySelectedForCapacity = "- Too many item(s) have been assigned to this bin. Available capacity is " + iCapacity.ToString() + ". You selected: " + iSelectedItemCount.ToString();
				}
			}

			string sErrorMsg = Utilities.ValidateOnEditAssetTemp(sHeaderID, bin_id, "<br />");

			if (!isNull(TooManySelectedForCapacity))
			{
				sErrorMsg = sErrorMsg + "<br>" + TooManySelectedForCapacity;
			}


			if (!isNull(sErrorMsg))
			{
				cvEditAssetTemp.IsValid = false;
				cvEditAssetTemp.Text = sErrorMsg;
				cvEditAssetTemp.ErrorMessage = sErrorMsg;
				IsEditValid = false;
			}

			return IsEditValid;
		}

		private void ApplySecurityToControl()
		{
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkEditHeader);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnAddAsset);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnAddAssetTemp);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(chkAll);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnEditSelected);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnAssignBinAssetTempToBin);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnSubmit);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnDeleteSelectedAsset);
		}

		private ArrayList arrBuildCheckBoxArray()
		{
			ArrayList CheckBoxArray;
			if (ViewState["CheckBoxArray"] != null)
			{
				CheckBoxArray = (ArrayList)ViewState["CheckBoxArray"];
			}
			else
			{
				CheckBoxArray = new ArrayList();
			}
			return CheckBoxArray;
		}

		/// <summary>
		/// Delete selected asset from the grid
		/// </summary>
		private void DeleteSelectedAssetFromGrid()
		{
			//loop the grid and get the selected item
			foreach (DataGridItem item in dgTempAsset.Items)
			{
				CheckBox chk = (CheckBox)item.FindControl("chkAsset");
				if (chk != null)
				{
					//only delete if item is checked
					if (chk.Checked)
					{
						//get the detail id to delete
						string detail_id = chk.Attributes["Detailed_ID"];
						if (!isNull(detail_id))
						{
							DatabaseUtilities.DeleteAsset_Temp_Detail(detail_id);
						}
					}
				}
			}
		}

		private void ShowHideLeasedInfo()
		{
			spLeasedTermDays.Visible = chkIsLeased.Checked;
			//updatePanelLeasedInfo.Update();
		}

		protected new void Page_Load(object sender, EventArgs e)
		{
			//Security check for user manipulate query string paramter to access 
			bool CanUserAccessAsset = AppSecurity.Can_View_Asset_Temp_Header(qsHeaderID);
			if (!CanUserAccessAsset)
			{
				string description = "CAIRS - Unauthorized Access - User trying to access Asset Temp Header ID: " + qsHeaderID;
				//process unauthorized access
				Unauthorized_Access(description);
			}

			if (!IsPostBack)
			{
				//Hide Navigation
				HideNavigation(true);

				PageIndex = "0";

                DDLLoadBaseType();
				DDLLoadAssetType();
				DDLLoadAssetCondition();
				TXTSerialNumLoad();
				TXTTagIDLoad();
				//Load from Query String
				LoadControlForQueryStringParam();

				//Load bin message
				SelectedIndexChangeDDLBin(sender, e);

				//Apply security to control
				ApplySecurityToControl();

				tagIDTemp.Focus();
			}

			ddlBin.SelectedIndexChanged_DDL_Bin += SelectedIndexChangeDDLBin;
			DDL_BinEditAsset.SelectedIndexChanged_DDL_Bin += SelectedIndexChangeDDLBinEdit;
            ddlBaseType.SelectedIndexChanged_DDL_AssetBaseType += onSelectedIndexChange_ddlAssetBaseType;

		}

        protected void onSelectedIndexChange_ddlAssetBaseType(object sender, EventArgs e)
        {
            DDLLoadAssetType();
            ddlBaseType.reqAssetBaseType.Validate(); //needs to validate this so to handle the recalculation of placeholder.
        }

		protected void SelectedIndexChangeDDLBin(object sender, EventArgs e)
		{
			//DisplayCapacityMessage(lblCapacityMessage, ddlBin.ddlBin, false);
			DisplayCapacityMessage(ddlBin.ddlBin, false);

			string isValidAddTempDetail = hdnIsAddTempDetailValid.Value;
			if (!isNull(isValidAddTempDetail))
			{
				if (!bool.Parse(hdnIsAddTempDetailValid.Value))
				{
					txt_TagID.txtTagID.Focus();
				}
			}
		}

		protected void SelectedIndexChangeDDLBinEdit(object sender, EventArgs e)
		{
			//DisplayCapacityMessage(lblCapacityEditAsset, DDL_BinEditAsset.ddlBin, true);
			DisplayCapacityMessage(DDL_BinEditAsset.ddlBin, true);
			DisplayEditAsset();
		}

		protected void dgTempAsset_ItemDataBound(object sender, DataGridItemEventArgs e)
		{
			if (e.Item.ItemIndex >= 0)
			{
				LinkButton btnDelete = ((LinkButton)e.Item.FindControl("btnDeleteAsset"));
				Label lbl = ((Label)e.Item.FindControl("lblErrorMessage"));
				CheckBox chk = ((CheckBox)e.Item.FindControl("chkAsset"));

				string sHasSubmitted = chk.Attributes["HasSubmitted"];
				bool IsSubmitted = sHasSubmitted.ToLower().Equals("yes");

				btnDelete.Visible = !IsSubmitted;
				/*
				if (IsSubmitted)
				{
					lbl.Text = "Submitted";
				}
				*/

				string hasError = lbl.Attributes["data-content"];
				if (hasError.Length != 0)
					lbl.Visible = true;

				btnSubmit.Visible = !IsSubmitted;
				btnAddAsset.Visible = !IsSubmitted;
				//btnClearForm.Visible = !IsSubmitted;
				divAddDetailSection.Visible = !IsSubmitted;
				chk.Visible = !IsSubmitted;
				//divHeaderGridInfo.Visible = !IsSubmitted;
				chkAll.Visible = !IsSubmitted;
				lnkBtnEditSelected.Visible = !IsSubmitted;
				lnkBtnAssignBinAssetTempToBin.Visible = !IsSubmitted;
				btnDeleteSelectedAsset.Visible = !IsSubmitted;

				//Enable role of user is not director.
				chk.Enabled = !AppSecurity.Current_User_Access_Level().Equals(AppSecurity.ROLE_DIRECTOR);


				AppSecurity.Apply_CAIRS_Security_To_Single_Control(chk);
				AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnDelete);

			}
		}

		protected void chkAll_CheckedChanged(object sender, EventArgs e)
		{
			//loop thru each of the check box on the grid and set it to the same value as the select all
			Utilities.SelectAllFromPage(dgTempAsset, chkAll.Checked, "chkAsset");
		}

		protected void btnClearForm_Click(object sender, EventArgs e)
		{
			ClearForm();
		}

		protected void lnkEditHeader_Click(object sender, EventArgs e)
		{
			DisplayHeaderInfoForUpdate(true);
		}

		protected void btnUpdateHeader_Click(object sender, EventArgs e)
		{
			if (Page.IsValid)
			{
				string sSelectedSite = ddlSiteEdit.SelectedValue;
				string sHeaderID = SaveTempHeaderTbl(sSelectedSite, txtDescriptionEdit.Text);
				DatabaseUtilities.Unassign_All_Bin_From_Asset_Temp_Detail(sHeaderID);
				NavigateTo(Constants.PAGES_ADD_ASSET_DETAIL_PAGE + "?asset_temp_header_id=" + sHeaderID, false);
			}
			else
			{
				DisplayHeaderInfoForUpdate(false);
			}
		}

		protected void btnAddAsset_Click(object sender, EventArgs e)
		{
			if (ValidateOnAddAsset())
			{
				SaveTempDetailTbl();
				LoadAssetTempDG();
				IntializeControlAfterAdd();
				SelectedIndexChangeDDLBin(sender, e);

				//NavigateTo(Constants.PAGES_ADD_ASSET_DETAIL_PAGE + "?" + Request.QueryString.ToString(), false);
				serialNumberTemp.Text = "";
				tagIDTemp.Text = "";
			}
		}

		protected void lnkBtnEditSelected_Click(object sender, EventArgs e)
		{
			ShowEditAssetTempModal(true);
		}

		protected void lnkBtnAssignBinAssetTempToBin_Click(object sender, EventArgs e)
		{
			ShowEditAssetTempModal(false);
		}

		protected void btnDeleteAsset_Click(object sender, EventArgs e)
		{
			string id = ((LinkButton)sender).Attributes["Detail_ID"];
			DatabaseUtilities.DeleteAsset_Temp_Detail(id);
			LoadAssetTempDG();
			SelectedIndexChangeDDLBin(sender, e);
		}

		protected void btnReturn_Click(object sender, EventArgs e)
		{
			NavigateBack();
		}

		protected void btnSubmit_Click(object sender, EventArgs e)
		{
			string headerid = qsHeaderID;
			bool isValidForSubmit = Utilities.ValidateOnSubmitAdd(headerid);

			if (isValidForSubmit)
			{
				string submittedByDate = DateTime.Now.ToString();
				string submittedByEmpID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);

				DatabaseUtilities.SubmitAssetTempToAsset(headerid, submittedByDate, submittedByEmpID);
				LoadAssetTempDG();

				DisplaySubmitSuccessMessage();
			}
			else
			{
				string caption = "Unable to Submit";
				string message = "Please review the list of error(s) in the grid before submitting.";
				DisplayMessage(caption, message);
			}
		}

		protected void btnSaveAssetDetail_Click(object sender, EventArgs e)
		{
			string selectedbin = DDL_BinEditAsset.SelectedValue;
			if (ValidateOnEditAssetTempDetail(selectedbin) && Page.IsValid)
			{
				SaveEditAssetDetailTemp();
				ReDrawPopover();
				DDLLoadBin();
				LoadAssetTempDG();
				chkAll.Checked = false;//initialize control
				CloseModal("popupEditAssetDetail");
				DisplayMessage("Success", "Successfully updated.");
			}
			else
			{
				DisplayEditAsset();
			}
		}

		protected void btnDeleteSelectedAsset_Click(object sender, EventArgs e)
		{
			if (ValidateIsAtLeastOneItemCheck())
			{
				DeleteSelectedAssetFromGrid();
				LoadAssetTempDG();
				SelectedIndexChangeDDLBin(sender, e);
			}
			else
			{
				DisplayMessage("Validation", "Please select at least one item from the grid to peform an action");
			}
		}

		protected void BtnOkSubmitSuccess_Click(object sender, EventArgs e)
		{
			NavigateBack();
		}

		protected void chkSelectAllFromPage_CheckedChanged(object sender, EventArgs e)
		{
			//string isChecked = "0";
			//if (chkSelectAllFromPage.Checked)
			//{
			//	isChecked = "1";
			//}

		}

		protected void dgTempAsset_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
		{
			PageIndex = e.NewPageIndex.ToString();
			LoadAssetTempDG();
		}

		protected void chkIsLeased_CheckedChanged(object sender, EventArgs e)
		{
			ShowHideLeasedInfo();
			txtLeasedTermDays.Focus();
		}

		protected void chkIsLeasedEditAsset_CheckedChanged(object sender, EventArgs e)
		{
			spEditAssetLeasedInfo.Visible = chkIsLeasedEditAsset.Checked;
			txtLeasedTermEditAsset.Focus();
			updatePanelEditAssetDetail.Update();
		}

		protected void lnkExportToExcel_Click(object sender, EventArgs e)
		{
			string file_name = "Add_Asset_Results";
			DataSet ds = DatabaseUtilities.DsGetAssetTempHeaderDetailByHeaderIDForExport(qsHeaderID);
			Utilities.ExportDataSetToExcel(ds, Response, file_name);
		}

	}
}