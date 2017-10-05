<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddBinPage.aspx.cs" Inherits="CAIRS.Pages.AddBinPage" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" MaintainScrollPositionOnPostback="true" %>
<%@ MasterType VirtualPath="~/MasterPages/CAIRSMasterPage.Master" %>

<%@ Register Src="~/Controls/DDL_Site.ascx" TagName="DDL_Site" TagPrefix="UC" %>
<%@ Register Src="~/Controls/TXT_TagID.ascx" TagName="TXT_TagID" TagPrefix="UC" %>

<asp:Content id="Content1" ContentPlaceHolderid="cph_Body" Runat="server">

<asp:UpdateProgress ID="updateFiltersGrid" runat="server" DisplayAfter="100" AssociatedUpdatePanelID="updatePanelFiltersGrid">
    <ProgressTemplate>
        <div class="divWaiting">
            <img src="../Images/ajax-loader.gif"  />
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>

<asp:UpdatePanel runat="server" ID="updatePanelFiltersGrid" UpdateMode="Always">
	<ContentTemplate>

	<!-- Bin Search Form -->
	<asp:HiddenField ID="hdnBinID" Value="-1" runat="server" />

	<h1>
		Bin Management
		<asp:Button
			ID="btnAddBin"
			Text="Add Bin"
			CssClass="btn btn-default btn-xs"
			OnClick="btnAddBin_Click"
			CausesValidation="false"
			Security_Level_Disabled="10,20,30"
			runat="server" />
	</h1>

	<asp:Label ID="lblSuccessAddBin" CssClass="alert alert-success center-block col-md-7" runat="server" />

	<div class="form-group row">
		<div class="col-xs-7">
			<UC:DDL_Site ID="ddlSite" runat="server" /> 
		</div>
	</div>

	<div class="form-group row">
		<div class="col-xs-7">

			<asp:Textbox ID="txtDescription" CssClass="form-control" placeholder="Bin Description" TextMode="MultiLine" MaxLength="100" runat="server" />

		</div>
	</div>

	<div class="form-group form-inline row">
		<div class="col-xs-7">

			<asp:TextBox 
				ID="txtStartNumber" 
				CssClass="form-control ui-autocomplete-input" 
				placeholder="Bin Start #" 
				MaxLength="6" 
				runat="server" /> &mdash;

			<asp:CompareValidator 
				ID="cvStartNumberDataType" 
				ErrorMessage="Must be numeric." 
				Text="Must be numeric." 
				CssClass="invalid" 
				Operator="DataTypeCheck" 
				Display="Dynamic" 
				ControlToValidate="txtStartNumber" 
				Type="Integer" 
				ValidationGroup="vgApplyFilters" 
				runat="server"  />

			<asp:CompareValidator 
				ID="cvStartNumberGreaterThan" 
				ErrorMessage="Must be less than End Number."
				Text="Must be less than End Number."
				CssClass="invalid"
				Display="Dynamic"
				Operator="LessThanEqual" 
				ControlToValidate="txtStartNumber"
				ControlToCompare="txtEndNumber"
				Type="Integer"
				ValidationGroup="vgApplyFilters"
				runat="server"  />

			<asp:TextBox ID="txtEndNumber" CssClass="form-control ui-autocomplete-input" placeholder="Bin End #" MaxLength="6" runat="server" />

			<asp:CompareValidator 
				ID="cvEndNumberDataType" 
				ErrorMessage="Must be numeric."
				Text="Must be numeric."
				CssClass="invalid"
				Display="Dynamic"
				Operator="DataTypeCheck" 
				ControlToValidate="txtEndNumber"
				Type="Integer"
				ValidationGroup="vgApplyFilters" 
				runat="server" />

		</div>
	</div>

	<div class="form-group row">

		<strong class="col-xs-2 pull-left">Capacity:</strong>

		<asp:RadioButtonList ID="radCapacityList" CssClass="spaced" RepeatDirection="Horizontal" runat="server">
			<asp:ListItem Text="Any" Value="1" Selected="True" />
			<asp:ListItem Text="Available" Value="2" />
			<%-- <asp:ListItem Text="Used" Value="3" /> //unnecessary? --%>
			<asp:ListItem Text="Full" Value="4" />
		</asp:RadioButtonList>

	</div>

	<asp:Button
		ID="btnApplyFilter"
		Text="Search"
		CssClass="btn btn-default"
		OnClick="btnApplyFilter_Click"
		CausesValidation="true"
		ValidationGroup="vgApplyFilters"
		runat="server" />

	<asp:Button id="btnClearSelection" Text="Clear" CssClass="btn" OnClick="btnClearSelection_Click" runat="server" UseSubmitBehavior="false" />

	<br /><br /><br />


	<%--Bin Search Results--%>
	<div>

		<div id="headerResults" class="navbar navbar-default navbar-table" runat="server">
			<span class="navbar-brand pull-left">Bin Results</span>
		</div>
	   
		<asp:DataGrid 
			ID="dgBin" 
			AutoGenerateColumns="false" 
			CssClass="table table-hover table-striped table-border"
			AllowSorting="true"
			AllowPaging="true"
			PageSize="20" 
			OnItemDataBound="dgBin_ItemDataBound"
			PagerStyle-Mode="NumericPages"
			OnPageIndexChanged="dgBin_PageIndexChanged"
			OnSortCommand="dgBin_SortCommand"
			GridLines="None"
			UseAccessibleHeader="true"
			runat="server" >

			<Columns>
				<asp:TemplateColumn HeaderText="Bin #" SortExpression="Number">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Number")%>

					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="Site" SortExpression="Site_Name">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Site_Name")%>

					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="Description" SortExpression="Bin_Description_Short">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Bin_Description_Short")%>

					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="Capacity" SortExpression="Capacity">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Capacity")%>

					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="Available" SortExpression="Available_Capacity">
					<ItemTemplate>

						<%# GetStyleForAvailCapacity(Container.DataItem) %>

					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn ItemStyle-HorizontalAlign="Right">
					<ItemTemplate>

						<asp:Button
							ID="btnViewDetails"
							Text="Details"
							OnClick="btnViewDetails_Click"
							CssClass="btn btn-primary btn-xs"
							Bin_ID='<%# DataBinder.Eval(Container.DataItem, "Bin_ID")%>'
							CausesValidation="false"
							UseSubmitBehavior="false"
							runat="server" />

						<asp:Button
							ID="btnViewAssignAssetToBin"
							IsActive='<%# DataBinder.Eval(Container.DataItem, "Is_Active")%>'
							Text='<%# DataBinder.Eval(Container.DataItem, "Btn_Asset_Desc")%>'
							OnClick="btnViewAssignAssetToBin_Click"
							CssClass="btn btn-default btn-xs"
							Bin_ID='<%# DataBinder.Eval(Container.DataItem, "Bin_ID")%>'
							CausesValidation="false"
							UseSubmitBehavior="false"
							runat="server" />

					</ItemTemplate>
				</asp:TemplateColumn>

			</Columns>
		</asp:DataGrid>

		<asp:Label ID="lblResults" CssClass="label label-default pull-left" runat="server"></asp:Label>
			
	</div>

	</ContentTemplate>
</asp:UpdatePanel>

	<!-- Bootstrap Modal Dialog -->
	<div class="modal fade" id="popupBinDetails" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<asp:UpdatePanel runat="server" ID="updatePanelBinDetail" UpdateMode="Conditional">
			<ContentTemplate>
				 <div class="modal-dialog" role="document">
					<div class="panel panel-info" runat="server" id="modalTitle">

						<div class="panel-heading">

							<button type="button" class="close" data-dismiss="modal"><i class="material-icons">cancel</i></button>

							<h4 class="modal-title">
								<asp:Label ID="lblModalTitle" Text="" runat="server" />
							</h4>

						</div>

						<div id="divBinInfo" runat="server" class="panel-body">
							<table class="table">
								<tr>
									<td><strong>Site</strong></td>
									<td>

										<UC:DDL_Site runat="server" ID="ddlSiteAdd" IsSiteRequired="true" ValidationGroup="vgAddEditBin" />

										<asp:Label runat="server" ID="lblSiteEdit" data_column="Site_Name" />

										<asp:HiddenField runat="server" ID="hdnSiteID" Value="Site_ID"/>

									</td>
								</tr>
								<tr runat="server" id="trBinNumberAddEdiBin">
									<td><strong>Bin #</strong></td>
									<td>

										<asp:Label runat="server" ID="lblBinNumberDetails" data_column="Number" />

									</td>
								</tr>
								<tr>
									<td><strong>Description</strong></td>
									<td>

										<asp:TextBox ID="txtDescriptionDetails" CssClass="form-control" data_column="Bin_Description" TextMode="MultiLine" MaxLength="100" runat="server" />

									</td>
								</tr>
								<tr>
									<td><strong>Capacity</strong></td>
									<td>

										<asp:Textbox ID="txtCapacityDetails" CssClass="form-control" data_column="Capacity" MaxLength="5" runat="server" />

										<asp:RequiredFieldValidator
											ID="reqCapacity"
											Text="Required"
											CssClass="invalid"
											Display="Dynamic"
											ValidationGroup="vgAddEditBin"
											ControlToValidate="txtCapacityDetails"
											runat="server" />

										<asp:CompareValidator 
											ID="cvCapacittyAddEditBin" 
											Text="Must be numeric."
											ErrorMessage="Must be numeric."
											CssClass="invalid"
											Display="Dynamic"
											Operator="DataTypeCheck" 
											ControlToValidate="txtCapacityDetails"
											Type="Integer"
											ValidationGroup="vgAddEditBin"
											runat="server"  />

										<asp:CompareValidator 
											ID="cvCapacityCompareToUsed" 
											Text="Capacity must be greater than or equal to Used Capacity"
											ErrorMessage="Capacity must be greater than or equal to Used Capacity"
											CssClass="invalid"
											Operator="GreaterThanEqual" 
											Display="Dynamic"
											ControlToValidate="txtCapacityDetails"
											ControlToCompare="txtCapacityUsed"
											Type="Integer"
											ValidationGroup="vgAddEditBin"
											runat="server"  />

											<span style="display:none">
												<asp:TextBox ID="txtCapacityUsed" data_column="Asset_Count" runat="server" />
											</span>

									</td>
								</tr>
								<tr id="trAvailableCapacity" runat="server">
									<td><strong>Available</strong></td>
									<td>

										<asp:Label ID="lblAvailableCapacityDetails" data_column="Available_Capacity" runat="server" />

									</td>
								</tr>
								<tr id="trUsedCapacity" runat="server">
									<td><strong>Used Capacity</strong></td>
									<td>

										<asp:Label ID="lblUsedCapacityDetails" data_column="Asset_Count" runat="server" />

									</td>
								</tr>
								<tr runat="server" id="trIsActive">
									<td><strong>Is Active</strong></td>
									<td>

										<asp:CheckBox ID="chkIsBinActive" data_column="Is_Active" runat="server" />

										<small><strong class="text-danger" runat="server" id="spDisabledBinIsActiveOption" visible="false">
											NOTE: Cannot inactivate a bin with assigned asset(s)
										</strong></small>

									</td>
								</tr>
								<tr runat="server" id="trAddedBy">
									<td><strong>Added By</strong></td>
									<td>

										<asp:Label runat="server" ID="lblAddedByEdit" data_column="Added_By_Emp_Name" />

									</td>
								</tr>             
								<tr runat="server" id="trDateAdded">
									<td><strong>Date Added</strong></td>
									<td>

										<asp:Label runat="server" ID="lblDataAddedEdit" data_column="Date_Added_Formatted"></asp:Label>

									</td>
								</tr>
								<tr runat="server" id="trModifiedBy">
									<td><strong>Modified By</strong></td>
									<td>

										<asp:Label runat="server" ID="lblModifiedByEdit" data_column="Modified_By_Emp_Name"></asp:Label>

									</td>
								</tr>
								<tr runat="server" id="trDateModified">
									<td><strong>Date Modified</strong></td>
									<td>

										<asp:Label runat="server" ID="lblDateModifiedEdit" data_column="Date_Modified_Formatted"></asp:Label>

									</td>
								</tr>
							</table>
						</div>

						<div class="modal-footer">

							<asp:Button 
								ID="btnSaveBin" 
								OnClick="btnSaveBin_Click" 
								Text="Save"
								CssClass="btn btn-default" 
								CausesValidation="true" 
								UseSubmitBehavior="false"
								Security_Level_Disabled="10,20,30"
								ValidationGroup="vgAddEditBin" 
								runat="server" />

							<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

						</div>

					</div>
				</div>
			</ContentTemplate>
		</asp:UpdatePanel>
	</div>

	<!-- Bootstrap Modal Dialog -->
	<div class="modal" id="divViewAssignAssets"  role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<asp:UpdatePanel runat="server" ID="updateAssignBinModal" UpdateMode="Conditional">
			<ContentTemplate>
				<div class="modal-dialog modal-lg" role="document"> 
					<div id="divModalTitle" class="panel panel-info" runat="server">

						<div class="panel-heading">

							<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>

							<h4 class="modal-title">
								<asp:Label ID="lblViewAssetBinTitle" runat="server" Text="" />
							</h4>

						</div>

						<div class="panel-body" id="divBinInfoViewAssignAssets" runat="server">


							<div class="row">
								<div class="col-md-6">

									<table class="table well">
										<tr>
											<td class="col-xs-5"><strong>Site</strong></td>
											<td>
												<asp:Label runat="server" ID="lblSite" data_column="Site_Name"></asp:Label>
											</td>
										</tr>
										<tr>
											<td><strong>Bin Number</strong></td>
											<td>
												<asp:Label runat="server" ID="lblBinNumber" data_column="Number"></asp:Label>
											</td>
										</tr>
										<tr>
											<td><strong>Available Capacity</strong></td>
											<td>
												<asp:Label runat="server" ID="lblAvailCap" data_column="Available_Capacity"></asp:Label> of 
												<asp:Label runat="server" ID="lblCapacity" data_column="Capacity"></asp:Label>
												<asp:Label runat="server" ID="lblBinFull" CssClass="invalid"></asp:Label>
											</td>
										</tr>
										<tr>
											<td><strong>Description</strong></td>
											<td>
												<asp:Label runat="server" ID="lblDescription" data_column="Bin_Description"></asp:Label>
											</td>
										</tr>
									</table>

								</div>

								<div class="col-md-6" id="divAddAssetToBin" runat="server" visible="false">

									<h3>Assign Asset</h3>
  
									<div class="form-group row">

										<div class="col-xs-9">

											<UC:TXT_TagID ID="txtTagIdAdd" IsTagIDRequired="true" ValidationGroup="vgAssignTagToBin" runat="server" /> 

										</div>

										<div class="col-xs-3">

											<asp:Button 
											ID="btnSaveAssetBin" 
											Text="Assign" 
											CssClass="btn btn-default" 
											OnClick="btnSaveAssetBin_Click" 
											CausesValidation="true" 
											ValidationGroup="vgAssignTagToBin" 
											Security_Level_Disabled="10,20,30"
											UseSubmitBehavior="true" 
											runat="server" />

										</div>

									</div>
								

									<asp:CustomValidator runat="server" ID="cvAddAssetToBin" CssClass="alert alert-danger center-block" ValidationGroup="vgAssignTagToBin" Display="Dynamic" />

									<div class="alert alert-success fade in" id="divSuccess" runat="server" visible="false">
										<a href="#" class="close" data-dismiss="alert">&times;</a>
										<strong>Success!</strong> Asset assignment(s) updated.
									</div>

								</div>

							</div>

					

							<!-- Current Assets Assigned To Bin -->
							<div id="headerAssignedAssets" class="navbar navbar-default navbar-table" runat="server">
								 <span class="navbar-brand pull-left">Assigned Assets</span>

								<asp:CheckBox 
									ID="chkAll" 
									Text="Select All" 
									CssClass="header_select-all pull-left" 
									OnCheckedChanged="chkAll_CheckedChanged" 
									Security_Level_Disabled="30" 
									AutoPostBack="true" 
									runat="server" />
							   

								<ul class="nav navbar-nav">
									<li class="dropdown">

										<a class="dropdown-toggle" role="button" aria-expanded="false" href="#" data-toggle="dropdown">
											Actions <span class="caret"></span>
										</a>

										<ul class="dropdown-menu" role="menu">
											<li>
												<asp:LinkButton 
													ID="lnkBtnRemoveSelectedAssetFromBin" 
													Text="Remove" 
													Security_Level_Disabled="30"
													OnClientClick="return confirm('Are you sure you want to selected asset(s) from this bin?');"
													OnClick="lnkBtnRemoveSelectedAssetFromBin_Click"
													runat="server" />
											</li>
											
										</ul>

									</li>
								</ul>

							</div>

							<asp:DataGrid 
								ID="dgAssetBin" 
								CssClass="table table-hover table-striped table-border"
								AutoGenerateColumns="false" 
								GridLines="None"
								OnItemDataBound="dgAssetBin_ItemDataBound"
								UseAccessibleHeader="true"
								runat="server" >

								<Columns>
									<asp:TemplateColumn>
										<ItemTemplate>
											<asp:CheckBox 
												ID="chkAsset" 
												Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
												Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>' 
												Security_Level_Disabled="30"
												runat="server" />

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Asset Site">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Desc")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Tag ID">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Asset Type">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Asset_Type_Desc")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Disposition">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Asset_Disposition_Desc")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Condition">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Asset_Condition_Desc")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn>
										<ItemStyle HorizontalAlign="right" />
										<ItemTemplate>

											<asp:Button
												ID="btnUnassignFromBin"
												Visible="false"
												Text="Remove"
												CssClass="btn btn-default btn-xs"
												OnClick="btnUnassignFromBin_Click"
												OnClientClick="return confirm('Are you sure you want to unassign this asset from this bin?')"
												Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
												CausesValidation="false"
												Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
												Security_Level_Disabled="10,20,30"
												runat="server" />

										</ItemTemplate>
									</asp:TemplateColumn>

								</Columns>
							</asp:DataGrid>
					
							<asp:Label ID="lblResultsAssetBin" CssClass="label label-default pull-left" runat="server" />

						</div>

						<div class="modal-footer">

							<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
					
						</div>

					</div>
				</div>
			</ContentTemplate>
		</asp:UpdatePanel>
	</div>

	<script>
        
		function AssignAssetOnEnterKeyPress(e) {
			if (e.keyCode == 13 || e.keyCode == 35 || e.keyCode == 59) {
				e.preventDefault();
				$('#' + '<%=btnSaveAssetBin.ClientID %>').focus().click();
			}
		}
	</script>

</asp:Content>