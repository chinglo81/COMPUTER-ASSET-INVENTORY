using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace CAIRS.Pages
{
	public partial class AddBinPage : _CAIRSBasePage
	{
		protected bool IsInsertBin()
		{
			return hdnBinID.Value.Equals("-1");
		}

		protected bool ValidateAssignAsset(string tag_id, string bin_id)
		{
			bool IsValid = true;
			string errormsg = "";
			string separator = "<br>";

			DataSet ds = DatabaseUtilities.DsValidateAssignAssetToBin(tag_id, bin_id);
			if (ds.Tables[0].Rows.Count > 0)
			{
				IsValid = false;
				foreach (DataRow r in ds.Tables[0].Rows)
				{
					errormsg += r["Error"].ToString() + separator;
				}

				errormsg = errormsg.Substring(0, errormsg.Length - separator.Length);
			}

			if (!IsValid)
			{
				cvAddAssetToBin.IsValid = false;
				cvAddAssetToBin.ErrorMessage = errormsg;
				cvAddAssetToBin.Text = errormsg;
			}

			return IsValid;
		}

		private void DisableSubmitBehaviorForAddingAsset(bool useSubmiBehavior)
		{
			btnAddBin.UseSubmitBehavior = useSubmiBehavior;
			btnApplyFilter.UseSubmitBehavior = useSubmiBehavior;
			btnSaveAssetBin.UseSubmitBehavior = !useSubmiBehavior;
		}

		private void LoadEnterBehaviorOnAssignBin()
		{
			txtTagIdAdd.txtTagID.Attributes.Add("onkeypress", "AssignAssetOnEnterKeyPress(event);");
		}

		private void DisplayAddViewAsset(bool isReload)
		{
			string title = "Bin Info";
			lblViewAssetBinTitle.Text = title;
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupBinMessage", "$('#divViewAssignAssets').modal(); ", true);
			if (isReload)
			{
				chkAll.Checked = false;
				DisableSubmitBehaviorForAddingAsset(false);
				LoadBinInfoForViewAndAssignAssets();
				LoadAssetBinDG();
				LoadEnterBehaviorOnAssignBin();
				updateAssignBinModal.Update();
			}
		}

		private void DisplayDetails(bool isReload)
		{
			lblModalTitle.Text = "Bin Details";
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupBinMessage", "$('#popupBinDetails').modal();", true);
			if (isReload)
			{
				ShowHideEditBinControls();
				LoadBinDetails();
				
				if (IsInsertBin())
				{
					btnSaveBin.Attributes.Add("onclick", "");
					ddlSiteAdd.LoadDDLSite(true, false,  true, true, false, true, true);
				}

				chkIsBinActive.Enabled = true;
				spDisabledBinIsActiveOption.Visible = false;

				string sUsedCapacity = lblUsedCapacityDetails.Text;

				if(!isNull(sUsedCapacity) && Utilities.IsNumeric(sUsedCapacity))
				{
					if (int.Parse(sUsedCapacity) > 0)
					{
						chkIsBinActive.Enabled = false;
						spDisabledBinIsActiveOption.Visible = true;
					}
				}

				updatePanelBinDetail.Update();
			}

		}

		private void LoadBinDetails()
		{
			string binID = hdnBinID.Value;
			DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DBNAME_ASSET_TRACKING, Constants.DB_VIEW_BIN, "Bin_ID", binID, "");

			Utilities.DataBindForm(divBinInfo, ds);

			//Apply security to save button
			btnSaveBin.Enabled = true;

			if(ds.Tables[0].Rows.Count > 0)
			{
				btnSaveBin.Attributes[AppSecurity.SECURITY_SITE_CODE] = ds.Tables[0].Rows[0]["Site_Code"].ToString();
				AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnSaveBin);
			}

			
		}

		private void LoadBinInfoForViewAndAssignAssets()
		{
			string binID = hdnBinID.Value;
			DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DBNAME_ASSET_TRACKING, Constants.DB_VIEW_BIN, "Bin_ID", binID, "");

			Utilities.DataBindForm(divBinInfoViewAssignAssets, ds);

			if (ds.Tables[0].Rows.Count > 0)
			{
				bool HasAvailCapacity = true;
				string availCapacity = lblAvailCap.Text;
				if (!isNull(availCapacity) && Utilities.IsNumeric(availCapacity))
				{
					HasAvailCapacity = int.Parse(availCapacity) > 0;
				}
				divAddAssetToBin.Visible = HasAvailCapacity;

				lblBinFull.Text = "";
				if (!HasAvailCapacity)
				{
					lblBinFull.Text = " (FULL)";
				}

				string sitecode = ds.Tables[0].Rows[0]["Site_Code"].ToString();

				btnSaveAssetBin.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				chkAll.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;
				lnkBtnRemoveSelectedAssetFromBin.Attributes[AppSecurity.SECURITY_SITE_CODE] = sitecode;

				AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnSaveAssetBin);
				AppSecurity.Apply_CAIRS_Security_To_Single_Control(chkAll);
				AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnRemoveSelectedAssetFromBin);
			}
		}

		private void LoadSite_DDL()
		{
			ddlSite.LoadDDLSite(false, false, false, false, true, true, true);
		}

		private void LoadBinDG()
		{
			string selectedSite = ddlSite.SelectedValue;
			if (selectedSite.Equals(Constants._OPTION_ALL_VALUE))
			{
				selectedSite = Utilities.buildListInDropDownList(ddlSite.ddlSite, true, ",");
			}
			string bin_number_start = txtStartNumber.Text;
			string bin_number_end = txtEndNumber.Text;
			string capacity = radCapacityList.SelectedValue;
			string description = txtDescription.Text;
			string sortorder = SortCriteria + " " + SortDir;
			
			DataSet ds = DatabaseUtilities.DsGetBinInfo(selectedSite, bin_number_start, bin_number_end, capacity, description, sortorder);

			lblResults.Text = "No Data Found";
			int iRowCount = ds.Tables[0].Rows.Count;
			dgBin.Visible = false;

			if (iRowCount > 0)
			{
				lblResults.Text = "Total Count: " + iRowCount.ToString();
				headerResults.Visible = true;
				dgBin.Visible = true;
				dgBin.CurrentPageIndex = int.Parse(PageIndex);
				dgBin.DataSource = ds;
				dgBin.DataBind();
			}

		}

		private void LoadAssetBinDG()
		{
			string binID = hdnBinID.Value;
			string sortorder = "Asset_Site_Desc, Asset_Disposition_Desc";
			DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DBNAME_ASSET_TRACKING, Constants.DB_VIEW_ASSET_BIN, "Bin_ID", binID, sortorder);

			dgAssetBin.Visible = false;
			headerAssignedAssets.Visible = false;
			lblResultsAssetBin.Text = "";

			int iRowCount = ds.Tables[0].Rows.Count;

			if (iRowCount > 0)
			{
				lblResultsAssetBin.Text = "Total: " + iRowCount.ToString();
				headerAssignedAssets.Visible = true;
				dgAssetBin.Visible = true;
				dgAssetBin.DataSource = ds;
				dgAssetBin.DataBind();
			}

		}

		protected string GetStyleForAvailCapacity(object o)
		{
			string Avail_capcity = ((DataRowView)o)["Available_Capacity"].ToString();

			if (!isNull(Avail_capcity) && Utilities.IsNumeric(Avail_capcity))
			{
				if (int.Parse(Avail_capcity) <= 0)
				{
					return "<span class='control-label invalid'>" + Avail_capcity + "</span>";
				}
			}

			return Avail_capcity;
		}

		private void ShowHideEditBinControls()
		{
			trBinNumberAddEdiBin.Visible = !IsInsertBin();
			trUsedCapacity.Visible = !IsInsertBin();
			trAvailableCapacity.Visible = !IsInsertBin();
			trAddedBy.Visible = !IsInsertBin();
			trDateAdded.Visible = !IsInsertBin();
			trModifiedBy.Visible = !IsInsertBin();
			trDateModified.Visible = !IsInsertBin();
			trIsActive.Visible = !IsInsertBin();

			ddlSiteAdd.Visible = IsInsertBin();
			lblSite.Visible = !IsInsertBin();
			
			//Validator
			cvCapacityCompareToUsed.Visible = !IsInsertBin();
		}

		private void DisplayNewBinNumberOnAdd(string bin_id)
		{
			lblSuccessAddBin.Text = "";
			lblSuccessAddBin.Visible = false;
			if (!isNull(bin_id))
			{
				if (IsInsertBin())
				{
					DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.TBL_V_BIN, "Bin_ID", bin_id, "");
					if (ds.Tables[0].Rows.Count > 0)
					{
						string binnumber = ds.Tables[0].Rows[0]["Number"].ToString();
						string sitename = ds.Tables[0].Rows[0]["Site_Name"].ToString();
						lblSuccessAddBin.Text = "Successfully added Bin Number " + binnumber + " to " + sitename;
						lblSuccessAddBin.Visible = true;
					}
				}
			}
		}

		private void SaveBin()
		{
			string datetimenow = DateTime.Now.ToString();
			string empid = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);

			string p_ID = hdnBinID.Value;
			string p_Site_ID = ddlSiteAdd.SelectedValue; 
			string p_Description = txtDescriptionDetails.Text;
			string p_Capacity = txtCapacityDetails.Text;
			string p_Is_Active = "1";
			string p_Added_By_Emp_ID = empid;
			string p_Date_Added = datetimenow;
			string p_Modified_By_Emp_ID = empid;
			string p_Date_Modified = datetimenow;

			if (!IsInsertBin())
			{
				p_Site_ID = Constants.MCSDBNOPARAM;
				p_Is_Active = "1";
				if (!chkIsBinActive.Checked)
				{
					p_Is_Active = "0";
				}
			}

			string bin_id = DatabaseUtilities.Upsert_Bin(
				p_ID, 
				p_Site_ID, 
				p_Description,
				p_Capacity,
				p_Is_Active,
				p_Added_By_Emp_ID,
				p_Date_Added,
				p_Modified_By_Emp_ID,
				p_Date_Modified
			);

			DisplayNewBinNumberOnAdd(bin_id);
		}

		private void ActiveBin(string ID)
		{
			string dbnullvalue = Constants.MCSDBNOPARAM;
			string activate = "1";
			string datetimenow = DateTime.Now.ToString();
			string empid = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);

			DatabaseUtilities.Upsert_Bin(
				ID,
				dbnullvalue,
				dbnullvalue,
				dbnullvalue,
				activate,
				dbnullvalue,
				dbnullvalue,
				empid,
				datetimenow
			);
		}

		private void AssignBin(string bin_id, string asset_id)
		{
			string datetimenow = DateTime.Now.ToString();
			string empid = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);

			DatabaseUtilities.AssignAssetToBin(bin_id, asset_id, empid, datetimenow);
		}

		private void ClearSelection()
		{
			ddlSite.ddlSite.SelectedIndex = 0;
			txtStartNumber.Text = "";
			txtEndNumber.Text = "";
			radCapacityList.SelectedIndex = 0;
			txtDescription.Text = "";

			dgBin.Visible = false;
			lblResults.Text = "";
		}

		private void ApplySecurityToControl()
		{
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnAddBin);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnSaveBin);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnSaveAssetBin);
		}

		private void UnAssignedSelectedAssetFromBin()
		{
			foreach (DataGridItem item in dgAssetBin.Items)
			{
				CheckBox chk = (CheckBox)item.FindControl("chkAsset");
				if (chk != null)
				{
					string asset_id = chk.Attributes["Asset_ID"];
					string bin_id = Constants.MCSDBNULL;

					if (chk.Checked && !isNull(asset_id))
					{
						AssignBin(bin_id, asset_id);
					}
				}
			}
		}

		protected new void Page_Load(object sender, EventArgs e)
		{
			lblSuccessAddBin.Text = "";

			if (!IsPostBack)
			{
				LoadSite_DDL();
				SortCriteria = "b.Site_Name, b.Number";
				SortDir = "asc";
				PageIndex = "0";
				headerResults.Visible = false;
				ApplySecurityToControl();
				btnApplyFilter_Click(sender, e);
				lblSuccessAddBin.Visible = false;
			}
		}

		protected void btnAddBin_Click(object sender, EventArgs e)
		{
			string sAddValue = "-1";
			hdnBinID.Value = sAddValue;

			DisplayDetails(true);
		}

		protected void btnSaveBin_Click(object sender, EventArgs e)
		{
			if (IsValid)
			{
				SaveBin();
				LoadBinDG();
				CloseModal("popupBinDetails");
			}
			else
			{
				DisplayDetails(false);
			}
		}

		protected void btnViewDetails_Click(object sender, EventArgs e)
		{
			Button btn = (Button)sender;
			string id = btn.Attributes["Bin_ID"];

			hdnBinID.Value = id;
			DisplayDetails(true);
		}

		protected void btnApplyFilter_Click(object sender, EventArgs e)
		{
			//Reset Sort and Paging
			SortCriteria = "b.Site_Name, b.Number";
			SortDir = "asc";
			PageIndex = "0";

			LoadBinDG();
		}

		protected void dgBin_SortCommand(object source, DataGridSortCommandEventArgs e)
		{
			if (SortCriteria == e.SortExpression)
			{
				if (SortDir == "desc")
				{
					SortDir = "asc";
				}
				else
				{
					SortDir = "desc";
				}
			}
			SortCriteria = e.SortExpression;

			//reset page index on each sort
			PageIndex = "0";

			LoadBinDG();
		}

		protected void btnViewAssignAssetToBin_Click(object sender, EventArgs e)
		{
			Button btn = (Button)sender;
			string id = btn.Attributes["Bin_ID"];
			bool isActive = bool.Parse(btn.Attributes["IsActive"]);

			//Activate bin and escape out of method
			if (!isActive)
			{
				ActiveBin(id);
				LoadBinDG();
				DisplayMessage("Asset Activated", "Asset has been activated. You can now assign asset(s) to this bin.");
				return;
			}
			
			hdnBinID.Value = id;

			DisplayAddViewAsset(true);

			//Initialize control
			divSuccess.Visible = false;
			txtTagIdAdd.Text = "";
			txtTagIdAdd.txtTagID.Focus();

			updateAssignBinModal.Update();
		}

		protected void btnSaveAssetBin_Click(object sender, EventArgs e)
		{
			string bin_id = hdnBinID.Value;
			string tag_id = txtTagIdAdd.Text;
			
			if (isNull(tag_id))
			{
				DisplayAddViewAsset(false);
				txtTagIdAdd.txtTagID.Focus();
				return;
			}

			if (ValidateAssignAsset(tag_id, bin_id) && Page.IsValid)
			{
				string asset_id = DatabaseUtilities.GetAssetIDByTagID(tag_id);
				AssignBin(bin_id, asset_id);
				LoadAssetBinDG();
				//Reload main bin grid
				LoadBinDG();
				DisplayAddViewAsset(true);

				//initilize control
				txtTagIdAdd.Text = "";
				txtTagIdAdd.txtTagID.Focus();
				//Utilities.SelectTextBox(txtTagIdAdd.txtTagID);
				divSuccess.Visible = true;
			}
			else
			{
				DisplayAddViewAsset(false);
				txtTagIdAdd.Text = "";
				txtTagIdAdd.txtTagID.Focus();
				//Utilities.SelectTextBox(txtTagIdAdd.txtTagID);
				divSuccess.Visible = false;
			} 
		}

		protected void dgBin_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
		{
			PageIndex = e.NewPageIndex.ToString();
			LoadBinDG();
		}

		protected void btnUnassignFromBin_Click(object sender, EventArgs e)
		{
			Button btn = (Button)sender;
			string asset_id = btn.Attributes["Asset_ID"];
			string bin_id = Constants.MCSDBNULL;

			AssignBin(bin_id, asset_id);
			LoadBinDG();
			DisplayAddViewAsset(true);
			
		}

		protected void btnClearSelection_Click(object sender, EventArgs e)
		{
			ClearSelection();
		}

		protected void dgAssetBin_ItemDataBound(object sender, DataGridItemEventArgs e)
		{
			Button btn = e.Item.FindControl("btnUnassignFromBin") as Button;

			if (btn != null)
			{
				AppSecurity.Apply_CAIRS_Security_To_Single_Control(btn);
			}

			CheckBox chk = e.Item.FindControl("chkAsset") as CheckBox;
			if (chk != null)
			{
				AppSecurity.Apply_CAIRS_Security_To_Single_Control(chk);
			}
		}

		protected void dgBin_ItemDataBound(object sender, DataGridItemEventArgs e)
		{
			if (e.Item.ItemIndex >= 0)
			{
				Button btnViewAssignAssetToBin = ((Button)e.Item.FindControl("btnViewAssignAssetToBin"));

				if (btnViewAssignAssetToBin != null)
				{
					bool isBinActive = bool.Parse(btnViewAssignAssetToBin.Attributes["IsActive"]);

					//Security only apply if bin is inactivated.
					if (!isBinActive)
					{
						DataRowView row = (DataRowView)e.Item.DataItem;
						btnViewAssignAssetToBin.Attributes[AppSecurity.SECURITY_SITE_CODE] = row["Site_Code"].ToString();
						btnViewAssignAssetToBin.Attributes[AppSecurity.SECURITY_LEVEL_DISABLED] = "10,20,30";
						AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnViewAssignAssetToBin);
					}
				}
			}
		}

		protected void chkAll_CheckedChanged(object sender, EventArgs e)
		{
			Utilities.SelectAllFromPage(dgAssetBin, chkAll.Checked, "chkAsset");
		}

		protected void lnkBtnRemoveSelectedAssetFromBin_Click(object sender, EventArgs e)
		{
			if (Utilities.ValidateIsAtLeastOneItemCheckFromGrid(dgAssetBin, "chkAsset", null))
			{
				UnAssignedSelectedAssetFromBin();
				LoadBinDG();
				DisplayAddViewAsset(true);
				chkAll.Checked = false;
			}
			else
			{
				DisplayMessage("Validation", "Please select at least one item from the grid to peform an action");
			}
		}
	}
}