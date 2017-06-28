using System;
using System.Data;
using System.Web.UI.WebControls;
using System.Web.UI;

namespace CAIRS.Pages
{
	public partial class AddAssetPage : _CAIRSBasePage
	{
		protected string qsHeaderID
		{
			get
			{
				return Request.QueryString["asset_temp_header_id"];
			}
		}
		protected string qsBatchStatus
		{
			get
			{
				return Request.QueryString["Batch_Status"];
			}
		}
		protected string qsSite
		{
			get
			{
				return Request.QueryString["Site"];
			}
		}
        protected string qsEnteredByEmpID
        {
            get
            {
                return Request.QueryString["EnteredByEmpID"];
            }
        }
		protected string qsShowHeaderSection
		{
			get
			{
				return Request.QueryString["show_header"];
			}
		}
        protected string qsApplyFilter
        {
            get
            {
                return Request.QueryString["apply_filter"];
            }
        }

		/// <summary>
		/// Check to see if this form is an edit
		/// </summary>
		/// <returns></returns>
		protected bool IsInsert()
		{
			return !isNull(qsHeaderID);
		}

		/// <summary>
		/// Show or Hide Header section based on query string parameter
		/// </summary>
		/// <returns></returns>
		protected bool ShowHeader()
		{
			if (!isNull(qsShowHeaderSection))
			{
				return bool.Parse(qsShowHeaderSection);
			}
			return true;
		}

		private void ApplySecurityToControl()
		{
			AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnContinue);
		}

        private void LoadJsOnChange()
        {
            ddlBatchStatus.Attributes.Add("onchange", "DisplayProgressLoader();");
            ddlSitePreviousBatch.ddlSite.Attributes.Add("onchange", "DisplayProgressLoader();");
            ddlEnteredByEmployee.Attributes.Add("onchange", "DisplayProgressLoader();");
        }


		//using new because Page_Load is also being called from _CAIRSBasePage.cs
		protected new void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				//Hide Navigation
				HideNavigation(true);

				//Load Controls
				DDLLoadSite();

				//Load Site for previous batches
				DDLLoadSitePrevoiusBatch();

				//Load from Query String
				LoadControlForQueryStringParam();

				ApplySecurityToControl();
			}

            LoadJsOnChange();

			ddlSitePreviousBatch.SelectedIndexChanged_DDL_Site += OnSelectedIndexChange_DDLSite_Previous_Batch;

			//Need to be called to disable/enable control based on security access
			//Page_Load_Complete(sender, e);
		}

		private void ApplyFilterToPreviousGrid(string sort_criteria, string sort_dir, string page_index)
		{
			string selectedBatchStatus = ddlBatchStatus.SelectedValue;
			string selectedSite = ddlSitePreviousBatch.SelectedValue;
            string selectedEmployee = ddlEnteredByEmployee.SelectedValue;

			NavigateTo(
                    Constants.PAGES_ADD_ASSET_PAGE
                        + "?apply_filter=true"
                        + "&Batch_Status=" + selectedBatchStatus 
                        + "&Site=" + selectedSite
                        + "&EnteredByEmpID=" + selectedEmployee 
                        + "&sort_criteria=" + sort_criteria
                        + "&sort_dir=" + sort_dir
                        + "&page_index=" + page_index
                    ,true
            );
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
		/// Load the Previous Load DDL
		/// </summary>
		private void LoadPreviousDG()
		{
			lblResults.Text = "No Results Found";
			string sSiteList = ddlSitePreviousBatch.SelectedValue;
			if (sSiteList.Equals(Constants._OPTION_ALL_VALUE))
			{
				sSiteList = Utilities.buildListInDropDownList(ddlSitePreviousBatch.ddlSite, true, ",");
			}
			string sBatchStatus = ddlBatchStatus.SelectedValue;
            string sEnteredByEmp = ddlEnteredByEmployee.SelectedValue;
            string sOrderBy = SortCriteria + " " + SortDir;

            DataSet ds = DatabaseUtilities.DsGetPreviousAssetTempLoad(sSiteList, sBatchStatus, sEnteredByEmp, sOrderBy);
			int iRowCount = ds.Tables[0].Rows.Count;


			if (iRowCount > 0)
			{
				lblResults.Text = "Total Batches: " + iRowCount.ToString();
                dgPreviousLoad.CurrentPageIndex = int.Parse(PageIndex);
				dgPreviousLoad.DataSource = ds;
				dgPreviousLoad.DataBind();

                dgPreviousLoad.Focus();
			}
		}

		/// <summary>
		/// Initial Load
		/// </summary>
		protected void DDLLoadSite()
		{
			ddlSite.IsSiteRequired = true;
			ddlSite.LoadDDLSite(true, false, true, true, false, true, true);
			ddlSite.AutoPostBack = false;
			SetFocus(ddlSite.ddlSite);

		}

        private void DDLLoadEnteredByEmployee()
        {
            string site_id = ddlSitePreviousBatch.SelectedValue;
            if(site_id.Contains("-")){
                site_id = Utilities.buildListInDropDownList(ddlSitePreviousBatch.ddlSite, true, ",");
            }
            
            string batch_status = ddlBatchStatus.SelectedValue;

            DataSet ds = DatabaseUtilities.DsGetEnteredByEmpForAddAsset(site_id, batch_status);

            ddlEnteredByEmployee.Visible = false;

            int iTotalRowCount = ds.Tables[0].Rows.Count;

            if (iTotalRowCount > 0)
            {
                ddlEnteredByEmployee.Visible = true;

                ddlEnteredByEmployee.DataSource = ds;
                ddlEnteredByEmployee.DataTextField = "Added_By_Emp_Name";
                ddlEnteredByEmployee.DataValueField = "Added_By_Emp_ID";
                ddlEnteredByEmployee.DataBind();

                if (iTotalRowCount > 1)
                {
                    ddlEnteredByEmployee.Items.Insert(0, new ListItem(Constants._OPTION_ALL_TEXT + "Employees ---", Constants._OPTION_ALL_VALUE));
                }
            }
        }

		protected void DDLLoadSitePrevoiusBatch()
		{
			ddlSitePreviousBatch.LoadDDLSite(true, false, true, false, true, true, false);
			ddlSitePreviousBatch.AutoPostBack = true;
		}

		/// <summary>
		/// Load Control based on Query String Parameters
		/// </summary>
		protected void LoadControlForQueryStringParam()
		{
			//Load Batch Status
			if (!isNull(qsBatchStatus))
			{
				ListItem li = ddlBatchStatus.Items.FindByValue(qsBatchStatus);
				if (ddlBatchStatus.Items.Contains(li))
				{
					ddlBatchStatus.SelectedValue = qsBatchStatus;
				}
			}

			//Load Selected Site
			if (!isNull(qsSite))
			{
				ListItem li = ddlSitePreviousBatch.ddlSite.Items.FindByValue(qsSite);
				if (ddlSitePreviousBatch.ddlSite.Items.Contains(li))
				{
					ddlSitePreviousBatch.SelectedValue = qsSite;
				}
			}

            //Load Employee DDL
            DDLLoadEnteredByEmployee();

            if (!isNull(qsEnteredByEmpID))
            {
                ListItem li = ddlEnteredByEmployee.Items.FindByValue(qsSite);
                if (ddlEnteredByEmployee.Items.Contains(li))
                {
                    ddlEnteredByEmployee.SelectedValue = qsEnteredByEmpID;
                }
            }

            SortCriteria = "";
            SortDir = "";
            PageIndex = "0";

            if (!isNull(QS_SORT_CRITERIA))
            {
                SortCriteria = QS_SORT_CRITERIA;
            }
            if (!isNull(QS_SORT_DIR))
            {
                SortDir = QS_SORT_DIR;
            }
            if (!isNull(QS_PAGE_INDEX))
            {
                PageIndex = QS_PAGE_INDEX;
            }


			//Is Show Header
			divAddAssetHeader.Visible = ShowHeader();
			LoadPreviousDG();

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

		protected void dgPreviousLoad_ItemDataBound(object sender, DataGridItemEventArgs e)
		{
			if (e.Item.ItemIndex >= 0)
			{
				Button btnDelete = ((Button)e.Item.FindControl("btnDelete"));
				if (btnDelete != null)
				{
					bool HasBeenSubmiited = bool.Parse(btnDelete.Attributes["HasSubmit"]);
					//Only need to apply security to button that has not been submitted. 
					//Delete will be hidden if the button has been submitted.

					btnDelete.Visible = !HasBeenSubmiited;

					if (!HasBeenSubmiited)
					{
						AppSecurity.Apply_CAIRS_Security_To_Single_Control(btnDelete);
					}
				}
			}
		}

        protected void dgPreviousLoad_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            ApplyFilterToPreviousGrid(QS_SORT_CRITERIA, QS_SORT_DIR, e.NewPageIndex.ToString());
        }

        protected void dgPreviousLoad_SortCommand(object source, DataGridSortCommandEventArgs e)
        {
            if (QS_SORT_CRITERIA == e.SortExpression)
            {
                if (QS_SORT_DIR == "desc")
                {
                    SortDir = "asc";
                }
                else
                {
                    SortDir = "desc";
                }
            }

            ApplyFilterToPreviousGrid(e.SortExpression, SortDir, "0");
        }

		//Event method
		protected void chkLstAddType_SelectedIndexChanged(object sender, EventArgs e)
		{
			string selectedAddType = chkLstAddType.SelectedValue;
			if (selectedAddType.Equals(Constants.ADD_ASSET_TYPE_UPLOAD))
			{
				NavigateTo(Constants.PAGES_ADD_ASSET_UPLOAD_PAGE, false);
			}
		}

		protected void btnContinue_Click(object sender, EventArgs e)
		{
			if (IsValid)
			{
				string sHeaderID = SaveTempHeaderTbl(ddlSite.SelectedValue, txtDescription.Text);
				NavigateTo(Constants.PAGES_ADD_ASSET_DETAIL_PAGE + "?asset_temp_header_id=" + sHeaderID, true);
			}
		}

		protected void btnPreviousLoad_Click(object sender, EventArgs e)
		{
			string id = ((Button)sender).Attributes["HeaderID"];
			NavigateTo(Constants.PAGES_ADD_ASSET_DETAIL_PAGE + "?asset_temp_header_id=" + id, true);
		}

		protected void btnReturn_Click(object sender, EventArgs e)
		{
			NavigateBack();
		}

		protected void ddlBatchStatus_SelectedIndexChanged(object sender, EventArgs e)
		{
            ApplyFilterToPreviousGrid(QS_SORT_CRITERIA, QS_SORT_DIR, QS_PAGE_INDEX);
		}

		protected void OnSelectedIndexChange_DDLSite_Previous_Batch(object sender, EventArgs args)
		{
            ApplyFilterToPreviousGrid(QS_SORT_CRITERIA, QS_SORT_DIR, QS_PAGE_INDEX);
		}
        protected void ddlEnteredByEmployee_SelectedIndexChanged(object sender, EventArgs e)
        {
            ApplyFilterToPreviousGrid(QS_SORT_CRITERIA, QS_SORT_DIR, QS_PAGE_INDEX);
        }

		protected void btnDelete_Click(object sender, EventArgs e)
		{
			string id = ((Button)sender).Attributes["HeaderID"];
			if (!isNull(id))
			{
				DatabaseUtilities.DeleteAsset_Temp_Header(id);
                ApplyFilterToPreviousGrid(QS_SORT_CRITERIA, QS_SORT_DIR, QS_PAGE_INDEX);
			}
		}

        
	}

}