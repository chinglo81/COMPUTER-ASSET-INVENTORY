<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddAssetPage.aspx.cs" Inherits="CAIRS.Pages.AddAssetPage" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" MaintainScrollPositionOnPostback="true" %>

<%@ MasterType VirtualPath="~/MasterPages/CAIRSMasterPage.Master" %>
<%@ Register Src="~/Controls/DDL_Site.ascx" TagName="DDL_Site" TagPrefix="UC_DDL_SITE" %>
<%@ Register Src="~/Controls/DDL_Bin.ascx" TagName="DDL_Bin" TagPrefix="UC_DDL_Bin" %>
<%@ Register Src="~/Controls/DDL_AssetType.ascx" TagName="DDL_AssetType" TagPrefix="UC_DDL_AssetType" %>
<%@ Register Src="~/Controls/DDL_AssetCondition.ascx" TagName="DDL_AssetCondition" TagPrefix="UC_DDL_AssetCondition" %>
<%@ Register Src="~/Controls/DDL_AssetDisposition.ascx" TagName="DDL_AssetDisposition" TagPrefix="UC_DDL_AssetDisposition" %>
<%@ Register Src="~/Controls/TXT_SerialNumber.ascx" TagName="TXT_SerialNum" TagPrefix="UC_TXT_SerialNum" %>
<%@ Register Src="~/Controls/TXT_TagID.ascx" TagName="TXT_TagID" TagPrefix="UC_TXT_TagID" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cph_Body" runat="server">

	<input type="hidden" runat="server" id="hdnTempHeaderID" value="-1" />
	<asp:HiddenField runat="server" ID="hdnIsAddTempDetailValid" Value="true" />


	<!-- Add Asset Form -->
	<h1 runat="server" id="divAddAssetHeader">Add Assets</h1>

	<div class="row">
		<div class="col-sm-6">

			<!-- Radio button list to select add asset method -->
			<asp:RadioButtonList runat="server" ID="chkLstAddType" CssClass="radio" AutoPostBack="true" OnSelectedIndexChanged="chkLstAddType_SelectedIndexChanged" RepeatDirection="Vertical">
				<asp:ListItem Value="SCAN" Text="Scan Asset" Selected="True"></asp:ListItem>
				<asp:ListItem Value="UPLOAD" Text="Upload File"></asp:ListItem>
			</asp:RadioButtonList>

		</div>
		<br />
	</div>

	<div id="divHeader" runat="server">

		<div class="form-group row">
			<div class="col-sm-6">

				<UC_DDL_SITE:DDL_Site runat="server" ID="ddlSite" SelectedIndexChanged_DDL_Site="SelectedIndexChangedDDLSite" />
				<asp:Label runat="server" ID="lblSelectedSiteValue"></asp:Label>

			</div>
		</div>

		<div class="form-group row">
			<div class="col-sm-6">

				<asp:TextBox runat="server" TextMode="MultiLine" PlaceHolder="Description" CssClass="form-control" ID="txtDescription" MaxLength="1000"></asp:TextBox>

			</div>
		</div>

		<div class="form-group row">
			<div class="col-sm-6">

				<asp:Button runat="server" ID="btnContinue" CausesValidation="true" Text="Create Batch" CssClass="btn btn-default" OnClick="btnContinue_Click" Security_Level_Disabled="30" />

			</div>
		</div>

		<br />
		<br />

	</div>

	<!-- List Asset Batches -->
	<div id="divPreviousLoad" runat="server">

		<div class="navbar navbar-default navbar-table">
			<span class="navbar-brand pull-left">Previous Batches</span>
			<UC_DDL_SITE:DDL_Site runat="server" ID="ddlSitePreviousBatch" AutoPostBack="True" />
			<asp:DropDownList runat="server" CssClass="form-control pull-left" ID="ddlBatchStatus" AutoPostBack="true" OnSelectedIndexChanged="ddlBatchStatus_SelectedIndexChanged">
				<asp:ListItem Value="3" Text="All" />
				<asp:ListItem Value="1" Text="Pending" Selected="True" />
				<asp:ListItem Value="2" Text="Submitted" />
			</asp:DropDownList>
            <asp:DropDownList 
                runat="server" 
                CssClass="form-control" 
                ID="ddlEnteredByEmployee" 
                AutoPostBack="true" 
                OnSelectedIndexChanged="ddlEnteredByEmployee_SelectedIndexChanged">
            </asp:DropDownList>
		</div>

		<asp:DataGrid
			runat="server"
			ID="dgPreviousLoad"
			AutoGenerateColumns="false"
			CssClass="table table-hover table-striped table-border"
			GridLines="None"
			OnItemDataBound="dgPreviousLoad_ItemDataBound"
            AllowPaging="true"
		    AllowSorting="true"
		    PagerStyle-Mode="NumericPages"
		    PagerStyle-CssClass="pagination"
		    OnPageIndexChanged="dgPreviousLoad_PageIndexChanged" 
            OnSortCommand="dgPreviousLoad_SortCommand"
			UseAccessibleHeader="true">

			<Columns>
				<asp:TemplateColumn HeaderText="Site" SortExpression="Asset_Site_Name_Desc">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Name_Desc")%>
					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="Modified Date" SortExpression="Update_Date">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Update_Date")%>
					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="Assets" SortExpression="Total_Asset">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Total_Asset")%>
					</ItemTemplate>
					<ItemStyle HorizontalAlign="Center" />
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="Status" SortExpression="Batch_Status">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Batch_Status")%>
					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="Entered By" SortExpression="Added_By_Emp_Name">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Added_By_Emp_Name")%>
					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn ItemStyle-HorizontalAlign="Right">
					<ItemTemplate>

						<asp:Button
							runat="server"
							ID="btnPreviousLoad"
							CssClass="btn btn-primary btn-xs"
							HeaderID='<%# DataBinder.Eval(Container.DataItem, "Asset_Temp_Header_ID")%>'
							CausesValidation="false"
							Text="View"
							OnClick="btnPreviousLoad_Click" />

						<asp:Button
							runat="server"
							ID="btnDelete"
							HasSubmit='<%# DataBinder.Eval(Container.DataItem, "Has_Submit")%>'
							CssClass="btn btn-default btn-xs"
							HeaderID='<%# DataBinder.Eval(Container.DataItem, "Asset_Temp_Header_ID")%>'
							CausesValidation="false"
							Text="Delete"
							Security_Level_Disabled="30"
							Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
							OnClientClick="return confirm('Are you sure you want to delete this batch?');"
							OnClick="btnDelete_Click" />

					</ItemTemplate>
				</asp:TemplateColumn>

			</Columns>
		</asp:DataGrid>

		<asp:Label runat="server" ID="lblResults" CssClass="label label-default pull-right"></asp:Label>
        <div id="divHere"></div>
        <a name="anchorName">..</a>
	</div>

</asp:Content>
