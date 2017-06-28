using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Text;
using System.Collections.Specialized;
using System.Xml;

namespace CAIRS.Pages
{
	public partial class AssetSearchPage : _CAIRSBasePage
	{
		private string ASSET_SEARCH_ID
		{
			get
			{
				if (!isNull(QS_ASSET_SEARCH_ID))
				{
					return QS_ASSET_SEARCH_ID;
				}
				return "-1";
			}
		}

		protected string qsApplyFilters
		{
			get
			{
				return Request.QueryString["Apply_Filters"];
			}
		}

		protected string qsShowFilter
		{
			get
			{
				return Request.QueryString["Show_Filters"];
			}
		}

		protected string qsPageIndex
		{
			get
			{
				return Request.QueryString["Page_Index"];
			}
		}

		protected string qsSortColumn
		{
			get
			{
				return Request.QueryString["Sort_Column"];
			}
		}

		protected string qsSortDirection
		{
			get
			{
				return Request.QueryString["Sort_Direction"];
			}
		}

		protected string qsIsCheckAll
		{
			get
			{
				return Request.QueryString["Is_Check_All"];
			}
		}

		protected string GetCheckAllValue()
		{
			string isChecked = "0";
			if (chkAll.Checked)
			{
				isChecked = "1";
			}

			return isChecked;
		}

		protected string BuildQueryStringParam(string SortColumn, string SortDir, string PageIndex, string showFilters)
		{
			StringBuilder sb = new StringBuilder();

			//Asset_Search_ID
			if (!isNull(QS_ASSET_SEARCH_ID))
			{
				sb.Append("&Asset_Search_ID=" + QS_ASSET_SEARCH_ID);
			}
			//Show Hide filters
			if (!isNull(showFilters))
			{
				sb.Append("&Show_Filters=" + showFilters);
			}

			//Sort Column
			if (!isNull(SortColumn))
			{
				sb.Append("&Sort_Column=" + SortColumn);
			}
			//Sort Direction
			if (!isNull(SortDir))
			{
				sb.Append("&Sort_Direction=" + SortDir);
			}
			//Page Index for paging
			if (!isNull(PageIndex))
			{
				sb.Append("&Page_Index=" + PageIndex);
			}
			//Check All Option for Grid
			string IsCheckAll = GetCheckAllValue();

			if (!isNull(IsCheckAll))
			{
				sb.Append("&Is_Check_All=" + IsCheckAll);
			}

			return sb.ToString();
		}

		/// <summary>
		/// Initial Load
		/// </summary>
		protected void DDLLoadSite()
		{
			ddlSite.IsSiteRequired = false;
			ddlSite.LoadDDLSite(true, true, false, false, true, false, false);
			ddlSite.AutoPostBack = false;
			SetFocus(ddlSite.ddlSite);
		}

		protected void DDLLoadBin_Assign_Asset_To_Bin()
		{
			string selectedsite = lblSite_Assign_Asset_To_Bin.Attributes["Site_ID"];

			ddlBin_Assign_Asset_To_Bin.IsBinRequired = true;
			ddlBin_Assign_Asset_To_Bin.LoadDDLBin(selectedsite, true, true, true, false);
			ddlBin_Assign_Asset_To_Bin.reqBin.EnableClientScript = false;
		}

		protected void DDLLoadAssetBaseType()
		{
			ddlAssetBaseType.IsAssetBaseTypeRequired = false;
			ddlAssetBaseType.LoadDDLAssetBaseType(false, false, true);
			ddlAssetBaseType.AutoPostBack = true;
		}

		/// <summary>
		/// Initial Load
		/// </summary>
		/// </summary>
		

		/// <summary>
		/// Initial Load
		/// </summary>
		/// </summary>
		protected void DDLLoadAssetType(string AssetBaseTypeID)
		{
			ddlAssetType.IsAssetTypeRequired = false;
			ddlAssetType.LoadDDLAssetType(AssetBaseTypeID, false, false, true);
			ddlAssetType.AutoPostBack = false;
		}

		protected bool IsInsert()
		{
			return ASSET_SEARCH_ID.Equals("-1");
		}

		protected bool IsAllAssetCheckFromPageDG()
		{
			//Loop thru each of the check box to see if all are check
			foreach (DataGridItem item in dgAssetResults.Items)
			{
				CheckBox chk = ((CheckBox)item.FindControl("chkAsset"));
				if (!chk.Checked)
				{
					return false;
				}
			}
			return true;
		}

		protected string GetSelectAllAssetIDFromPageDG(bool isCheck)
		{
			string sbAssetIds = "";

			foreach (DataGridItem item in dgAssetResults.Items)
			{
                CheckBox chk = ((CheckBox)item.FindControl("chkAsset"));
                string AssetID = chk.Attributes["Asset_ID"];
				if (!isNull(AssetID)) 
				{ 
					sbAssetIds += AssetID + ",";
				}
                chk.Checked = isCheck;
			}

			//Remove the last comma
			if (!isNull(sbAssetIds))
			{
				sbAssetIds = sbAssetIds.Substring(0, sbAssetIds.Length - 1);
			}

			return sbAssetIds;
		}

		protected void Load_Assign_Asset_To_Bin_Site()
		{
			DataSet ds = DatabaseUtilities.DsGetCheckedAssetSiteIDFromAssetSearch(ASSET_SEARCH_ID);
			if (ds.Tables[0].Rows.Count > 0)
			{
				lblSite_Assign_Asset_To_Bin.Text = ds.Tables[0].Rows[0]["Site_Desc"].ToString();
				lblSite_Assign_Asset_To_Bin.Attributes["Site_ID"] = ds.Tables[0].Rows[0]["Site_ID"].ToString();
			}
		}

        protected void LoadTransferAsset()
        {
            //Load Datagrid

            string sort_criteria = hdnTransferGrid_SortCriteria.Value;
            string sort_dir = hdnTransferGrid_SortDir.Value;
            string page_index = hdnTransferGrid_PageIndex.Value;
            string transfer_site_id = ddlSiteTransferAsset.SelectedValue;

            string sort_by = "";
            int iPageIndex = 0;
            
            if (!isNull(sort_criteria))
            {
                sort_by = sort_criteria + " " + sort_dir;
            }
            if (!isNull(page_index) && Utilities.IsNumeric(page_index))
            {
                iPageIndex = int.Parse(page_index);
            }

            DataSet ds = DatabaseUtilities.DsGetCheckItemFromAssetSearch(ASSET_SEARCH_ID, transfer_site_id, sort_by);

            int iRowCount = ds.Tables[0].Rows.Count;
            int iCountError = 0;

            double dTotalRowCount = iRowCount;
            double dPageSize = dgTransferAsset.PageSize;

            lblResultsTransferInvalidCount.Visible = false;
            lblResultsTransferAssetCount.Text = "";
            dgTransferAsset.Visible = false;

            if (dTotalRowCount > 0)
            {
                dgTransferAsset.Visible = true;

                int iPageSize = dgTransferAsset.PageSize;
                double iMaxCurrentPageIndex = 0.0;

                if (!iPageSize.Equals(0))
                {
                    iMaxCurrentPageIndex = dTotalRowCount / dPageSize;
                }

                if (iPageIndex >= iMaxCurrentPageIndex && !iPageIndex.Equals(0))
                {
                    iPageIndex = iPageIndex - 1;
                }

                dgTransferAsset.CurrentPageIndex = iPageIndex;
                dgTransferAsset.DataSource = ds;
                dgTransferAsset.DataBind();

                lblResultsTransferAssetCount.Text = "Total Asset(s): " + iRowCount.ToString();
                
                ReDrawPopover();//Need to redraw popover javascript method to work properly.

                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    string sErrorMsg = row["Message_Error"].ToString();
                    if (!isNull(sErrorMsg))
                    {
                        iCountError++;
                    }
                }

                if (iCountError > 0)
                {
                    lblResultsTransferInvalidCount.Visible = true;
                    lblResultsTransferInvalidCount.Text = "Invalid Asset(s): " + iCountError.ToString();
                }

                btnSaveTransfer.Attributes.Add("onclick", "return confirm('Are you sure you want to transfer these asset(s)? \\n\\n   Total: " + dTotalRowCount.ToString() + "');");
            }
            else
            {
                //Close modal if no asset(s) is selected.
                CloseModal("divTransferAssetModal");
            }

            //updateTransferAssetModal.Update();

        }

		protected void DisplayAssignAssetToBinModal(bool isReload)
		{
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupAssignAssetToBin", "$('#popupAssignAssetToBin').modal();", true);
			if (isReload)
			{
				Load_Assign_Asset_To_Bin_Site();
				DDLLoadBin_Assign_Asset_To_Bin();
			}
		}

        protected void DisplayTransferAssetModal()
        {
            //Open modal
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "popupTransferAsset", "$('#divTransferAssetModal').modal();", true);
            
            //Load Site
            ddlSiteTransferAsset.LoadDDLSite(false, false, true, true, false, false, false);

            //Initialize sort and paging when displaying modal
            hdnTransferGrid_SortCriteria.Value = "";
            hdnTransferGrid_SortDir.Value = "";
            hdnTransferGrid_PageIndex.Value = "0";

            LoadTransferAsset();
        }

		private bool ValidateAssignAssetToBin(string bin_id, bool isModal)
		{
			bool IsAssignAssetToBinValid = true;
			string errorMsg = "";
			string br = "<br>";

			DataSet ds = DatabaseUtilities.DsValidateMassetAssignAssetToBin(ASSET_SEARCH_ID, bin_id);
			if (ds.Tables[0].Rows.Count > 0)
			{
				IsAssignAssetToBinValid = false;
				foreach (DataRow row in ds.Tables[0].Rows)
				{
					errorMsg += row["Error_Msg"].ToString() + br;
				}
			}

			//Trim off the last br
			if (!isNull(errorMsg))
			{
				errorMsg = errorMsg.Substring(0, errorMsg.Length - br.Length);
			}

			if (!IsAssignAssetToBinValid)
			{
				if (isModal)
				{
					cvModal.IsValid = false;
					cvModal.ErrorMessage = errorMsg;
					cvModal.Text = errorMsg;
				}
				else
				{
					//cvAssignAssetToBin.IsValid = false;
					//cvAssignAssetToBin.ErrorMessage = errorMsg;
					//cvAssignAssetToBin.Text = errorMsg;
				}
			}

			return IsAssignAssetToBinValid;
		}

        private bool ValidateSubmitTransfer()
        {
            bool IsAllAssetValidToTransfer = true;
            string transfer_site_id = ddlSiteTransferAsset.SelectedValue;
            DataSet ds = DatabaseUtilities.DsGetCheckItemFromAssetSearch(ASSET_SEARCH_ID, transfer_site_id, "");

            //Validate to see if there are any error message from the grid
            foreach (DataRow row in ds.Tables[0].Rows)
            {
                string sErrorMsg = row["Message_Error"].ToString();
                if (!isNull(sErrorMsg))
                {
                    IsAllAssetValidToTransfer = false;
                }
            }

            if (!IsAllAssetValidToTransfer)
            {
                LoadTransferAsset(); //Reload grid in case any of the asset has been updated.
            }

            cvInvalidAssetToTransfer.IsValid = IsAllAssetValidToTransfer;

            return IsAllAssetValidToTransfer;
        }

        private string TransferModalErrorMessage()
        {
            string sErrorMsg = "";
            DataSet ds = DatabaseUtilities.DsGetCheckItemCountFromAssetSearch(ASSET_SEARCH_ID);

            string sTotal_Checked = ds.Tables[0].Rows[0]["Total_Checked"].ToString();
            
            int iMaxCount = Utilities.MaxAllowAssetTransfer();
            int iRowCountOfSelectedItem = 0;

            if (Utilities.IsNumeric(sTotal_Checked))
            {
                iRowCountOfSelectedItem = int.Parse(sTotal_Checked);
            }

            if (iRowCountOfSelectedItem.Equals(0))
            {
                sErrorMsg += "<li>Please select at least one item from the grid to peform an action</li>"; 
            }

            if (iRowCountOfSelectedItem > iMaxCount)
            {
                sErrorMsg += "<li>You are only allow to transfer a maxumimum of " + iMaxCount.ToString() + " assets. You selected " + iRowCountOfSelectedItem.ToString() + ".</li>"; 
            }

            if (sErrorMsg.Length > 0)
            {
                sErrorMsg = "<ul>" + sErrorMsg + "</ul>";
            }

            return sErrorMsg;
        }

		private void MassAssignAssetToBin()
		{
			string p_Asset_Search_ID = QS_ASSET_SEARCH_ID;
			string p_Bin_ID = ddlBin_Assign_Asset_To_Bin.SelectedValue;
			string p_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
			string p_Date = DateTime.Now.ToString();

			DatabaseUtilities.AssignAssetToBinMassFromAssetSearch(
				p_Asset_Search_ID,
				p_Bin_ID,
				p_Emp_ID,
				p_Date
			);
		}

		private void ApplySecurityToControl()
		{
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(chkAll);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(chkSelectAllFromPage);
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(lnkBtnTransfer);
		}

		private void LoadAssetTypeByBaseType()
		{
			string selectedBaseType = ddlAssetBaseType.SelectedValue;
			DDLLoadAssetType(selectedBaseType);
		}

		protected new void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				//HideNavigation(false);
				DDLLoadSite();
				DDLLoadAssetBaseType();
				DDLLoadAssetType(ddlAssetBaseType.SelectedValue);

				//Defaul Sort for Grid
				SortCriteria = "Asset_Site_Desc, Asset_Type_Desc";
				SortDir = "asc";
				PageIndex = "0";

				alertAssetSearchResults.Visible = false;
                lblSuccessfullySubmitted.Visible = false;
				
                LoadFromQSParam();

				ApplySecurityToControl();

				//Set default focus
				txtIds.Focus();
			}

			ddlAssetBaseType.SelectedIndexChanged_DDL_AssetBaseType += onSelectedIndexChange_ddlAssetBaseType;
            ddlSiteTransferAsset.SelectedIndexChanged_DDL_Site += onSelectedIndexChange_ddlSiteTransferAsset;
		}

		protected void onSelectedIndexChange_ddlAssetBaseType(object sender, EventArgs e)
		{
			LoadAssetTypeByBaseType();
			updatePanelBaseAssetType.Update();
		}

        protected void onSelectedIndexChange_ddlSiteTransferAsset(object sender, EventArgs e)
        {
            LoadTransferAsset();
        }

		private void LoadFromQSParam()
		{
			//Load Filters
			if (!isNull(QS_ASSET_SEARCH_ID))
			{
				LoadAssetSearch();
			}


			//show hide filters
			if (!isNull(qsShowFilter))
			{
				ShowAdditionFilter(bool.Parse(qsShowFilter));
			}

			//Load Grid
			if (!isNull(qsApplyFilters))
			{
				if (!isNull(qsSortColumn))
				{
					SortCriteria = qsSortColumn;
					if (!isNull(qsSortDirection))
					{
						SortDir = qsSortDirection;
					}
				}

				if (!isNull(qsPageIndex))
				{
					PageIndex = qsPageIndex;
				}
				LoadAssetSearchDG();
			}

			//load Check All
			chkAll.Checked = false; //Default to false
			if (!isNull(qsIsCheckAll))
			{
				chkAll.Checked = qsIsCheckAll.Equals("1");
			}

            //load success message 
            if (!isNull(QS_SUCCESS))
            {
                lblSuccessfullySubmitted.Visible = true;
            }
		}

		private void LoadAssetSearch()
		{
			//Initialize hidden control to get multi select to function properly
			hdnSelectedAssetCondition.Value = "";
			hdnSelectedAssetDisposition.Value = "";

			DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(
								Constants.DBNAME_ASSET_TRACKING, 
								Constants.TBL_ASSET_SEARCH, 
								Constants.COLUMN_ASSET_SEARCH_ID,
								QS_ASSET_SEARCH_ID,  
								""
						);
			if (ds.Tables[0].Rows.Count > 0)
			{
				string sFilterValue = ds.Tables[0].Rows[0][Constants.COLUMN_ASSET_SEARCH_Filter_Value].ToString();
				string sFilterText = ds.Tables[0].Rows[0][Constants.COLUMN_ASSET_SEARCH_Filter_Text].ToString();

				if (!isNull(sFilterValue))
				{
					XmlDocument doc = new XmlDocument();
					doc.LoadXml(sFilterValue);
					XmlNodeList nodeList = doc.SelectNodes("//Filter");
					foreach (XmlNode node in nodeList)
					{
						string sName = node.Attributes.GetNamedItem("FilterName").Value;
						string sValue = node.Attributes.GetNamedItem("FilterValue").Value;

						//Show Hide Filter
						if (sName.Equals(Constants.SEARCH_FILTER_SHOW_HIDE_FILTER))
						{
							if (!isNull(sValue))
							{
								bool isShowFilter = bool.Parse(sValue);
								ShowAdditionFilter(isShowFilter);
							}
						}

						//ID Search Type
						if (sName.Equals(Constants.SEARCH_FILTER_ID_SEARCH_TYPE))
						{
							radLstIDType.SelectedValue = sValue;
						}
						//ID Lists
						if (sName.Equals(Constants.SEARCH_FILTER_ID_LIST))
						{
							txtIds.Text = sValue;
						}
						//Site
						if (sName.Equals(Constants.SEARCH_FILTER_SITE))
						{
							ddlSite.SelectedValue = sValue;
						}
						//Asset Unassign To Bin
						if (sName.Equals(Constants.SEARCH_FILTER_ASSET_UNASSIGN_TO_BIN))
						{
							if (!isNull(sValue))
							{
								chkAssetUnassignToBin.Checked = bool.Parse(sValue);
							}
						}

						//Asset Base Type
						if (sName.Equals(Constants.SEARCH_FILTER_ASSET_BASE_TYPE))
						{
							if (!sValue.Contains("-"))
							{
								ddlAssetBaseType.SelectedValue = sValue;
								//reload asset type by base type
								LoadAssetTypeByBaseType();
							}
						}

						//Asset Type
						if (sName.Equals(Constants.SEARCH_FILTER_ASSET_TYPE))
						{
							if (!sValue.Contains("-"))
							{
								ddlAssetType.SelectedValue = sValue;
							}
						}

						//Disposition
						if (sName.Equals(Constants.SEARCH_FILTER_ASSET_DISPOSITION))
						{
							multiAssetDisposition.SetSelectedValuePageLoad = sValue;
							hdnSelectedAssetDisposition.Value = sValue;
						}
						//Condition
						if (sName.Equals(Constants.SEARCH_FILTER_ASSET_CONDITION))
						{
							multiAssetCondition.SetSelectedValuePageLoad = sValue;
							hdnSelectedAssetCondition.Value = sValue;
						}
					}
				}
			}
			
		}

		private string BuildWhereClauseForSearch()
		{
			StringBuilder sbWhereClause = new StringBuilder();
			string sIDSearchType = radLstIDType.SelectedValue;
			string sIDList = txtIds.Text;
			string sSite = ddlSite.SelectedValue;
			if (sSite.Equals(Constants._OPTION_ALL_VALUE))
			{
				sSite = Utilities.buildListInDropDownList(ddlSite.ddlSite, true, ",");
			}
			string sAssetBaseType = ddlAssetBaseType.SelectedValue;
			string sAssetType = ddlAssetType.SelectedValue;
			string sDisposition = hdnSelectedAssetDisposition.Value;
			string sCondition = hdnSelectedAssetCondition.Value;
			string sAssetUnassignToBin = chkAssetUnassignToBin.Checked.ToString();

			//Default
			string sWhereClause = " WHERE 1=1 ";

			//IDs
			if (!isNull(sIDList))
			{
				if (!isNull(sIDSearchType))
				{
					//Replace spaces with no space
					//Replace new line with comma
					sIDList = sIDList.Replace(" ", "").Replace("\r\n", ",").Replace("\n", ",");

					if (sIDSearchType.Equals(Constants.SEARCH_TYPE_TAG_ID))
					{
						sbWhereClause.Append(" AND v.Tag_ID in (select * from dbo.CSVToTable('" + sIDList + "',','))");
					}
					if (sIDSearchType.Equals(Constants.SEARCH_TYPE_SERIAL_NUMBER))
					{
						sbWhereClause.Append(" AND v.Serial_Number in (select * from dbo.CSVToTable('" + sIDList + "',','))");
					}
					if (sIDSearchType.Equals(Constants.SEARCH_TYPE_STUDENT_ID))
					{
						sbWhereClause.Append(" AND v.Student_ID in (select * from dbo.CSVToTable('" + sIDList + "',','))");
					}
				}
			}
			//Site
			if (!isNull(sSite))
			{
				sbWhereClause.Append(" AND v.Asset_Site_ID in (select * from dbo.CSVToTable('" + sSite + "',','))");
			}
			//Asset Base Type
			if (!isNull(sAssetBaseType) && !sAssetBaseType.Contains("-"))
			{
				sbWhereClause.Append(" AND v.Asset_Base_Type_ID in (select * from dbo.CSVToTable('" + sAssetBaseType + "',','))");
			}

			//Asset Type
			if (!isNull(sAssetType) && !sAssetType.Contains("-"))
			{
				sbWhereClause.Append(" AND v.Asset_Type_ID in (select * from dbo.CSVToTable('" + sAssetType + "',','))");
			}
			//Disposition
			if (!isNull(sDisposition))
			{
				sbWhereClause.Append(" AND v.Asset_Disposition_ID in (select * from dbo.CSVToTable('" + sDisposition + "',','))");
			}
			//Condition
			if (!isNull(sCondition))
			{
				sbWhereClause.Append(" AND v.Asset_Condition_ID in (select * from dbo.CSVToTable('" + sCondition + "',','))");
			}

			if (chkAssetUnassignToBin.Checked)
			{
				sbWhereClause.Append(" AND v.Bin_ID is null ");
			}

			return sWhereClause + sbWhereClause.ToString();
		}

		protected bool IsChecked(object o)
		{
			string isCheck = ((DataRowView)o)["Is_Checked"].ToString();
			if (!Utilities.isNull(isCheck))
			{
				return bool.Parse(isCheck);
			}
			return false;
		}

		private void ShowHideStudentColumnInDg()
		{
			foreach (DataGridColumn col in dgAssetResults.Columns)
			{
				//Student Column
				if (col.HeaderText.Equals("Student ID") || col.HeaderText.Equals("Last Assigned Student"))
				{
					col.Visible = radLstIDType.SelectedValue.Equals("STUID");
				}

                //Serial Number
                if (col.HeaderText.Equals("Serial #"))
                {
                    col.Visible = radLstIDType.SelectedValue.Equals("SERNUM");
                }
			}
		}

        private void LoadSelectedCount()
        {
            DataSet ds = DatabaseUtilities.DsGetAssetSearchByID(QS_ASSET_SEARCH_ID, "", true);
            int iGetSelectedRowCount = ds.Tables[0].Rows.Count;
            string SelectedRecordMsg = "Selected Records: <strong>" + iGetSelectedRowCount.ToString() + "</strong>&nbsp;&nbsp;";
            lblSelected.Text = SelectedRecordMsg;
        }

		private void LoadAssetSearchDG()
		{

			string whereClause = BuildWhereClauseForSearch();
            //string sortorder = SortCriteria + " " + SortDir;
            string sortorder = " ORDER BY " + SortCriteria + " " + SortDir;
			
            //Save Asset Search Detail and check status
            DatabaseUtilities.SaveAssetSearchDetail(QS_ASSET_SEARCH_ID, whereClause, sortorder);

            //Data Set to load grid
            DataSet ds = DatabaseUtilities.DsGetAssetMasterList(whereClause, QS_ASSET_SEARCH_ID);
            
            /*Old code to refresh filters.
            string sortorder = SortCriteria + " " + SortDir;
            DataSet ds = DatabaseUtilities.DsGetAssetSearchByID(QS_ASSET_SEARCH_ID, sortorder, false);
			*/

            //Get Record count from the search filters
			int iRecordCount = ds.Tables[0].Rows.Count;
			
			//Initialize 
			dgAssetResults.Visible = false;
			lblResults.Text = "No Records Found";
			divHeaderGridInfo.Visible = false;

			if (iRecordCount > 0)
			{
				//Check all if all rows are check
				bool isAllRowCheck = true;
				int iGetSelectedRowCount = 0;

				//Check to see if all rows are checked
				foreach (DataRow r in ds.Tables[0].Rows)
				{
					bool isChk = bool.Parse(r["Is_Checked"].ToString());
					if (!isChk)
					{
						isAllRowCheck = false;
					}
					else
					{
						iGetSelectedRowCount = iGetSelectedRowCount + 1;
					}
				}

				//Check to see if all items are check on the datagrid
				chkAll.Checked = isAllRowCheck;
				
				divHeaderGridInfo.Visible = true;
				dgAssetResults.Visible = true;
				string SelectedRecordMsg = "Selected Records: <strong>" + iGetSelectedRowCount.ToString() + "</strong>&nbsp;&nbsp;";

				lblSelected.Text = SelectedRecordMsg;
				lblResults.Text = "Total Records: <strong>" + iRecordCount.ToString() + "</strong>";

				int iPageIndex = 0;
				if (!isNull(PageIndex) && Utilities.IsNumeric(PageIndex))
				{
					iPageIndex = int.Parse(PageIndex);
				}

				dgAssetResults.CurrentPageIndex = iPageIndex;
				dgAssetResults.DataSource = ds;
				dgAssetResults.DataBind();
				
				//This needs to load after the grid is loaded
				chkSelectAllFromPage.Checked = IsAllAssetCheckFromPageDG();

				ShowHideStudentColumnInDg();
			}
			else
			{
				alertAssetSearchResults.Visible = true;
			}
		}

		private string SaveAssetSearch()
		{
			NameValueCollection AssetSearchFilters_Value = new NameValueCollection();
			NameValueCollection AssetSearchFilters_Desc = new NameValueCollection();

			//Filters
			//ShowHideFilter
			string showfilter = divAdditionalFilters.Visible.ToString();
			AssetSearchFilters_Value.Add(Constants.SEARCH_FILTER_SHOW_HIDE_FILTER, showfilter);
			AssetSearchFilters_Desc.Add(Constants.SEARCH_FILTER_SHOW_HIDE_FILTER, showfilter);

			string sIDSearchType = radLstIDType.SelectedValue;
			string sIDSearchTypeDesc = radLstIDType.SelectedItem.Text;
			AssetSearchFilters_Value.Add(Constants.SEARCH_FILTER_ID_SEARCH_TYPE, sIDSearchType);
			AssetSearchFilters_Desc.Add(Constants.SEARCH_FILTER_ID_SEARCH_TYPE, sIDSearchTypeDesc);

			string sIDList = txtIds.Text;
			AssetSearchFilters_Value.Add(Constants.SEARCH_FILTER_ID_LIST, sIDList);
			AssetSearchFilters_Desc.Add(Constants.SEARCH_FILTER_ID_LIST, sIDList);

			string sSite = ddlSite.SelectedValue;
			string sSiteDesc = ddlSite.SelectedText;
			AssetSearchFilters_Value.Add(Constants.SEARCH_FILTER_SITE, sSite);
			AssetSearchFilters_Desc.Add(Constants.SEARCH_FILTER_SITE, sSiteDesc);

			string sAssetUnassignToBin = chkAssetUnassignToBin.Checked.ToString();
			AssetSearchFilters_Value.Add(Constants.SEARCH_FILTER_ASSET_UNASSIGN_TO_BIN, sAssetUnassignToBin);
			AssetSearchFilters_Desc.Add(Constants.SEARCH_FILTER_ASSET_UNASSIGN_TO_BIN, sAssetUnassignToBin);

			string sAssetBaseType = ddlAssetBaseType.SelectedValue;
			string sAssetBaseTypeDesc = ddlAssetBaseType.SelectedText;
			AssetSearchFilters_Value.Add(Constants.SEARCH_FILTER_ASSET_BASE_TYPE, sAssetBaseType);
			AssetSearchFilters_Desc.Add(Constants.SEARCH_FILTER_ASSET_BASE_TYPE, sAssetBaseTypeDesc);

			string sAssetType = ddlAssetType.SelectedValue;
			string sAssetTypeDesc = ddlAssetType.SelectedText;
			AssetSearchFilters_Value.Add(Constants.SEARCH_FILTER_ASSET_TYPE, sAssetType);
			AssetSearchFilters_Desc.Add(Constants.SEARCH_FILTER_ASSET_TYPE, sAssetTypeDesc);
			
			string sDisposition = multiAssetDisposition.GetSelectedValue;
			string sDispositionDesc = multiAssetDisposition.GetSelectedText;
			AssetSearchFilters_Value.Add(Constants.SEARCH_FILTER_ASSET_DISPOSITION, sDisposition);
			AssetSearchFilters_Desc.Add(Constants.SEARCH_FILTER_ASSET_DISPOSITION, sDispositionDesc);

			string sCondition = multiAssetCondition.GetSelectedValue;
			string sConditionDesc = multiAssetCondition.GetSetSelectedText;
			AssetSearchFilters_Value.Add(Constants.SEARCH_FILTER_ASSET_CONDITION, sCondition);
			AssetSearchFilters_Desc.Add(Constants.SEARCH_FILTER_ASSET_CONDITION, sConditionDesc);
			
			string sDate = DateTime.Now.ToString();

			//audit user info
			string sAuditEmpID = Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
		   
			string FilterValues = Utilities.CreateFiltersXML(AssetSearchFilters_Value);
			string FilterDesc = Utilities.CreateFiltersXML(AssetSearchFilters_Desc);

			return DatabaseUtilities.Upsert_Asset_Search(ASSET_SEARCH_ID, FilterValues, FilterDesc, sAuditEmpID, sDate, sAuditEmpID, sDate);;
		}

        private void SaveTransferAsset()
        {
            string p_Asset_Search_ID = ASSET_SEARCH_ID;
            string p_Asset_ID = Constants.MCSDBNOPARAM;
            string p_Transfer_Site_ID = ddlSiteTransferAsset.SelectedValue; 
            string p_Emp_ID =  Utilities.GetEmployeeIdByLoggedOn(LoggedOnUser);
            string p_Date = DateTime.Now.ToString();

            DatabaseUtilities.SaveTransferAsset(p_Asset_Search_ID, p_Asset_ID, p_Transfer_Site_ID, p_Emp_ID, p_Date);
        }

        private bool IsAllCheckedDgAssetSearch()
        {
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.TBL_ASSET_SEARCH_DETAIL, Constants.COLUMN_ASSET_SEARCH_DETAIL_Asset_Search_ID, ASSET_SEARCH_ID, "");
            if (ds.Tables[0].Rows.Count > 0)
            {
                foreach (DataRow r in ds.Tables[0].Rows)
                {
                    string sIsCheck = r[Constants.COLUMN_ASSET_SEARCH_DETAIL_Is_Checked].ToString();
                    if(isNull(sIsCheck) )
                    {
                        return false;
                    }
                    else
                    {
                        bool isChecked = bool.Parse(sIsCheck);
                        if (!isChecked)
                        {
                            return false;
                        }
                    }
                }
            }
            return true;
        }

		//Event method
		private void ShowAdditionFilter(bool IsShow)
		{
			lnkBtnHideFilters.Visible = IsShow;
			lnkBtnShowFilters.Visible = !IsShow;

			divAdditionalFilters.Visible = IsShow;
		}

		protected void lnkBtnShowFilters_Click(object sender, EventArgs e)
		{
			if (!isNull(QS_ASSET_SEARCH_ID))
			{
				NavigateTo(Constants.PAGES_ASSET_SEARCH_PAGE + "?Apply_Filters=true" + BuildQueryStringParam(qsSortColumn, qsSortDirection, qsPageIndex, "True"), false);
			}
			ShowAdditionFilter(true);
		}

		protected void lnkBtnHideFilters_Click(object sender, EventArgs e)
		{
			if (!isNull(QS_ASSET_SEARCH_ID))
			{
				NavigateTo(Constants.PAGES_ASSET_SEARCH_PAGE + "?Apply_Filters=true" + BuildQueryStringParam(qsSortColumn, qsSortDirection, qsPageIndex, "False"), false);
			}
			ShowAdditionFilter(false);
		}

		protected void btnClear_Click(object sender, EventArgs e)
		{
			//default show filters to false
			string showfilters = "";
			//if filters is visible, append parameter
			if (divAdditionalFilters.Visible)
			{
				showfilters = "?Show_Filters=true";
			}
			//Navigate back to the same page
			NavigateTo(Constants.PAGES_ASSET_SEARCH_PAGE + showfilters, false);
		}

		protected void btnApplyFilters_Click(object sender, EventArgs e)
		{
			if (IsValid)
			{
				string AssetSearchID = SaveAssetSearch();
                string whereClause = BuildWhereClauseForSearch();
                string sortorder = " ORDER BY " + SortCriteria + " " + SortDir;

				DatabaseUtilities.UpdateAssetSearchDetailCheck(AssetSearchID, "-1", "0");
                //DatabaseUtilities.SaveAssetSearchDetail(AssetSearchID, whereClause, sortorder);
                
				NavigateTo(Constants.PAGES_ASSET_SEARCH_PAGE + "?Apply_Filters=true&Asset_Search_ID=" + AssetSearchID, false);
			}
		}

        protected void btnViewAsset_Click(object sender, EventArgs e)
		{
			Button btn = (Button)sender;
			string Asset_ID = btn.Attributes["Asset_ID"];
			NavigateTo(Constants.PAGES_MANAGE_ASSET_PROPERTIES_PAGE + "?Asset_ID=" + Asset_ID + "&Asset_Search_ID=" + QS_ASSET_SEARCH_ID, true);
		}

		protected void dgAssetResults_ItemDataBound(object sender, DataGridItemEventArgs e)
		{
			//show hide check in button
			CheckBox chk = e.Item.FindControl("chkAsset") as CheckBox;

			if (chk != null)
			{
				bool IsDistrictTechOrDirector = AppSecurity.Current_User_Access_Level().Equals(AppSecurity.ROLE_DISTRICT_TECH) || AppSecurity.Current_User_Access_Level().Equals(AppSecurity.ROLE_DIRECTOR);
				chk.Enabled = IsDistrictTechOrDirector;
			}
		}

		protected void dgAssetResults_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
		{
			NavigateTo(Constants.PAGES_ASSET_SEARCH_PAGE + "?Apply_Filters=true" + BuildQueryStringParam(qsSortColumn, qsSortDirection, e.NewPageIndex.ToString(), qsShowFilter), false);
		}

		protected void dgAssetResults_SortCommand(object source, DataGridSortCommandEventArgs e)
		{
			if (qsSortColumn == e.SortExpression)
			{
				if (qsSortDirection == "desc")
				{
					SortDir = "asc";
				}
				else
				{
					SortDir = "desc";
				}
			}

			SortCriteria = e.SortExpression;
			NavigateTo(Constants.PAGES_ASSET_SEARCH_PAGE + "?Apply_Filters=true" + BuildQueryStringParam(SortCriteria, SortDir, "0", qsShowFilter), false);
		}

        protected void dgTransferAsset_ItemDataBound(object sender, DataGridItemEventArgs e)
        {
            if (e.Item.ItemIndex >= 0)
            {
                Label lbl = ((Label)e.Item.FindControl("lblErrorMessage"));
                string hasError = lbl.Attributes["data-content"];
                if (hasError.Length != 0)
                {
                    lbl.Visible = true;
                }
            }
        }

        protected void dgTransferAsset_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            int iPageIndex = e.NewPageIndex;
            hdnTransferGrid_PageIndex.Value = iPageIndex.ToString();

            LoadTransferAsset();
        }

        protected void dgTransferAsset_SortCommand(object source, DataGridSortCommandEventArgs e)
        {
            if (hdnTransferGrid_SortCriteria.Value == e.SortExpression)
            {
                if (hdnTransferGrid_SortDir.Value == "desc")
                {
                    hdnTransferGrid_SortDir.Value = "asc";
                }
                else
                {
                    hdnTransferGrid_SortDir.Value = "desc";
                }
            }

            hdnTransferGrid_SortCriteria.Value = e.SortExpression;
            LoadTransferAsset();
        }

        protected void chkAsset_CheckedChanged(object sender, EventArgs e)
		{
            lblSuccessfullySubmitted.Visible = false;

			CheckBox chk = (CheckBox)sender;
			string Asset_ID = chk.Attributes["Asset_ID"];

			string isChecked = "0";
			if (chk.Checked)
			{
				isChecked = "1";
            }

			DatabaseUtilities.UpdateAssetSearchDetailCheck(QS_ASSET_SEARCH_ID, Asset_ID, isChecked);
            
            chkSelectAllFromPage.Checked = IsAllAssetCheckFromPageDG();
            LoadSelectedCount();
            //LoadAssetSearchDG();
		}
		
		protected void chkSelectAllFromPage_CheckedChanged(object sender, EventArgs e)
		{
            lblSuccessfullySubmitted.Visible = false;

			string isChecked = "0";
			if (chkSelectAllFromPage.Checked)
			{
				isChecked = "1";
			}

            string asset_Ids = GetSelectAllAssetIDFromPageDG(chkSelectAllFromPage.Checked);

			DatabaseUtilities.UpdateAssetSearchDetailCheck(QS_ASSET_SEARCH_ID, asset_Ids, isChecked);
            //chkAll.Checked = IsAllCheckedDgAssetSearch();
            LoadAssetSearchDG();
		}
        
        protected void chkAll_CheckedChanged(object sender, EventArgs e)
		{
            lblSuccessfullySubmitted.Visible = false;

			DatabaseUtilities.UpdateAssetSearchDetailCheck(QS_ASSET_SEARCH_ID, "-1", GetCheckAllValue());
            GetSelectAllAssetIDFromPageDG(chkAll.Checked); //This will selected all items from grid without querying the database
            chkSelectAllFromPage.Checked = chkAll.Checked;
            LoadAssetSearchDG();
		}
		
        protected void lnkBtnTransfer_Click(object sender, EventArgs e)
		{
            string error_msg = TransferModalErrorMessage();

            if (!isNull(error_msg))
            {
                DisplayMessage("Validation", error_msg);
            }
            else
            {
                DisplayTransferAssetModal();
            }
		}

		protected void lnkAssignBin_Click(object sender, EventArgs e)
		{
			//Validate at least one item selected
			if (ValidateAssignAssetToBin("-1", false) && IsValid)
			{
				DisplayAssignAssetToBinModal(true);
			}
			else
			{
				DisplayErrorModal("vgAssignAssetToBin");
			}
		}

		protected void btnSaveAssignToBin_Click(object sender, EventArgs e)
		{
			string selectedbin = ddlBin_Assign_Asset_To_Bin.SelectedValue;
			if (ValidateAssignAssetToBin(selectedbin, true) && IsValid)
			{
				MassAssignAssetToBin();
                LoadAssetSearchDG();
				lblSuccessfullySubmitted.Visible = true;
			}
			else
			{
				DisplayAssignAssetToBinModal(false);
			}
		}

        protected void btnRemoveAssetFromTransfer_Click(object sender, EventArgs e)
        {
            LinkButton lnkbtn = (LinkButton)sender;
            string Asset_ID = lnkbtn.Attributes["Asset_ID"];

            string isChecked = "0";

            DatabaseUtilities.UpdateAssetSearchDetailCheck(QS_ASSET_SEARCH_ID, Asset_ID, isChecked);
            
            LoadTransferAsset();
            LoadAssetSearchDG();
            
        }

        protected void btnSaveTransfer_Click(object sender, EventArgs e)
        {
            if (ValidateSubmitTransfer() && Page.IsValid)
            {
                SaveTransferAsset();
                DatabaseUtilities.UpdateAssetSearchDetailCheck(QS_ASSET_SEARCH_ID, "-1", "0");
                lblSuccessfullySubmitted.Visible = true;
                LoadAssetSearchDG();
                CloseModal("divTransferAssetModal");
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadAssetSearchDG();
        }

	}
}