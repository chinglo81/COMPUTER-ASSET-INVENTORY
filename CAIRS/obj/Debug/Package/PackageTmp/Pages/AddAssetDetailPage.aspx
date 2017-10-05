<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" AutoEventWireup="true" CodeBehind="AddAssetDetailPage.aspx.cs" Inherits="CAIRS.Pages.AddAssetDetailPage" EnableEventValidation="false" %>

<%@ Register Src="~/Controls/DDL_Site.ascx" TagName="DDL_Site" TagPrefix="UC_DDL_SITE" %>
<%@ Register Src="~/Controls/DDL_Bin.ascx" TagName="DDL_Bin" TagPrefix="UC_DDL_Bin" %>
<%@ Register Src="~/Controls/DDL_AssetBaseType.ascx" TagName="DDL_AssetBaseType" TagPrefix="UC_DDL_AssetBaseType" %>
<%@ Register Src="~/Controls/DDL_AssetType.ascx" TagName="DDL_AssetType" TagPrefix="UC_DDL_AssetType" %>
<%@ Register Src="~/Controls/DDL_AssetCondition.ascx" TagName="DDL_AssetCondition" TagPrefix="UC_DDL_AssetCondition" %>
<%@ Register Src="~/Controls/DDL_AssetDisposition.ascx" TagName="DDL_AssetDisposition" TagPrefix="UC_DDL_AssetDisposition" %>
<%@ Register Src="~/Controls/TXT_SerialNumber.ascx" TagName="TXT_SerialNum" TagPrefix="UC_TXT_SerialNum" %>
<%@ Register Src="~/Controls/TXT_TagID.ascx" TagName="TXT_TagID" TagPrefix="UC_TXT_TagID" %>
<%@ Register Src="~/Controls/TXT_Date.ascx" TagName="TXT_Date" TagPrefix="UC" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

	<!-- Add Asset specific javascript -->
	<script src="../js/addAsset.js"></script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cph_Body" runat="server">

	<asp:HiddenField ID="hdnIsAddTempDetailValid" Value="true" runat="server" />

	<!-- Page Header -->
	<div class="page-header row">
		<div class="col-sm-10">
			<asp:UpdatePanel ID="updatePanel2" runat="server">
				<ContentTemplate>
					<span class="h1">Add Asset - </span>
					<asp:Label ID="lblDetailSiteName" CssClass="h1" runat="server" />

					<asp:LinkButton
						ID="lnkEditHeader"
						Text="edit"
						CssClass="btn btn-link btn-sm btn-align-top"
						CausesValidation="false"
						OnClick="lnkEditHeader_Click"
						runat="server" />

					<br />

					<asp:Label runat="server" ID="lblDetailDescription" />
				</ContentTemplate>
			</asp:UpdatePanel>
		</div>
	</div>

	<!-- Add Asset Form -->
	<div id="divAddDetailSection" class="row" runat="server">
		<div class="col-sm-6">
            <asp:UpdatePanel runat="server" ID="updatePanelBaseAndType" UpdateMode="Always">
                <ContentTemplate>
                    <UC_DDL_AssetBaseType:DDL_AssetBaseType ID="ddlBaseType" ValidationGroup="vgAddAsset" runat="server" />

			        <br />
			        <br />

			        <UC_DDL_AssetType:DDL_AssetType ID="ddlAssetType" ValidationGroup="vgAddAsset" runat="server" />

			        <br />
			        <br />
                </ContentTemplate>
            </asp:UpdatePanel>

			<UC_DDL_AssetCondition:DDL_AssetCondition ID="ddlAssetCondition" ValidationGroup="vgAddAsset" runat="server" />

			<br />
			<br />

			<UC_DDL_Bin:DDL_Bin ID="ddlBin" ValidationGroup="vgAddAsset" runat="server" />

			<br />
			<br />

			<UC:TXT_Date
				ID="txtPurchasedDate"
				runat="server"
				placeholder="Purchased Date"
				IsDateRequired="true"
				EnableClientScript="true"
				ValidationGroup="vgAddAsset"></UC:TXT_Date>



		</div>

		<div class="col-sm-6">

			<asp:UpdatePanel runat="server" ID="updatePanelLeasedInfo" UpdateMode="Conditional">
				<ContentTemplate>
					<div class="row add-asset-leased">

						<asp:CheckBox ID="chkIsLeased" Text="&nbsp;&nbsp;Leased" runat="server" AutoPostBack="true" OnCheckedChanged="chkIsLeased_CheckedChanged" CssClass="col-sm-2" />

						<span runat="server" id="spLeasedTermDays" visible="false">

							<div class="col-sm-5">

								<asp:TextBox runat="server" ID="txtLeasedTermDays" placeholder="Lease Term (Days)" MaxLength="4" CssClass="form-control"></asp:TextBox>

								<asp:RequiredFieldValidator
									runat="server"
									ID="reqLeasedTermDays"
									ControlToValidate="txtLeasedTermDays"
									CssClass="invalid"
									Display="Dynamic"
									Text="Required"
									ErrorMessage="Required"
									ValidationGroup="vgAddAsset">
								</asp:RequiredFieldValidator>

								<asp:CompareValidator
									ID="cvLeasedTermDays"
									Text="Must be numeric."
									ErrorMessage="Must be numeric."
									CssClass="invalid"
									Display="Dynamic"
									Operator="DataTypeCheck"
									EnableClientScript="true"
									ControlToValidate="txtLeasedTermDays"
									Type="Integer"
									ValidationGroup="vgAddAsset"
									runat="server" />

							</div>


						</span>
					</div>
				</ContentTemplate>
			</asp:UpdatePanel>

			<br />

			<asp:TextBox runat="server" ID="txtWarrantyTermDays" placeholder="Warranty Term (Days)" MaxLength="4" CssClass="form-control"></asp:TextBox>

			<asp:RequiredFieldValidator
				runat="server"
				ID="reqWarrantTermDays"
				ControlToValidate="txtWarrantyTermDays"
				CssClass="invalid"
				Display="Dynamic"
				Text="Required"
				Visible="false"
				ErrorMessage="Required"
				ValidationGroup="vgAddAsset">
			</asp:RequiredFieldValidator>

			<asp:CompareValidator
				ID="cvWarrantyTermDays"
				Text="Must be numeric."
				ErrorMessage="Must be numeric."
				CssClass="invalid"
				Display="Dynamic"
				Operator="DataTypeCheck"
				EnableClientScript="true"
				ControlToValidate="txtWarrantyTermDays"
				Type="Integer"
				ValidationGroup="vgAddAsset"
				runat="server" />

			<br />
			<br />
            
            <asp:TextBox runat="server" ID="tagIDTemp" CssClass="form-control" placeholder="Tag ID"></asp:TextBox>

			<asp:RequiredFieldValidator
				runat="server"
				ID="reqTagIdTemp"
				ControlToValidate="tagIDTemp"
				Display="Dynamic"
				CssClass="invalid"
				Text="Required"
				ErrorMessage="Required"
				ValidationGroup="vgAddAsset">
			</asp:RequiredFieldValidator>
            
            <br />
			<br />
            
            <asp:UpdatePanel runat="server" ID="updatePanelSerialNumber" UpdateMode="Conditional">
                <ContentTemplate>

			            <asp:TextBox runat="server" ID="serialNumberTemp" CssClass="form-control" placeholder="Serial #"></asp:TextBox>

			            <asp:RequiredFieldValidator
				            runat="server"
				            ID="reqSerialNumberTemp"
				            ControlToValidate="serialNumberTemp"
				            CssClass="invalid"
				            Display="Dynamic"
				            Text="Required"
				            ErrorMessage="Required"
				            ValidationGroup="vgAddAsset">
			            </asp:RequiredFieldValidator>

                </ContentTemplate>
            </asp:UpdatePanel>


			<asp:UpdatePanel ID="updatePanelDuplicateValidator" runat="server" UpdateMode="Always">
				<ContentTemplate>

					<asp:CustomValidator ID="cvDuplicateTagID" CssClass="invalid" EnableClientScript="false" Display="Dynamic" ValidationGroup="vgAddAsset" runat="server"></asp:CustomValidator>

					<br />

					<asp:Button
						ID="btnAddAssetTemp"
						CausesValidation="true"
						Text="Add Asset"
						OnClientClick="submitAddAsset()"
						CssClass="btn btn-default"
						Security_Level_Disabled="30"
						ValidationGroup="vgAddAsset"
						UseSubmitBehavior="false"
						runat="server" />

				</ContentTemplate>
			</asp:UpdatePanel>
		</div>
	</div>


	<!-- Hidden form to process add asset while asset scanning continues -->
	<asp:UpdatePanel ID="updatePanelAddAsset" runat="server" style="display: none;">
		<ContentTemplate>

			<UC_TXT_SerialNum:TXT_SerialNum ID="txt_SerialNum" ValidationGroup="vgAddAsset1" runat="server" />

			<UC_TXT_TagID:TXT_TagID ID="txt_TagID" ValidationGroup="vgAddAsset1" runat="server" />

			<asp:Button
				ID="btnAddAsset"
				CausesValidation="true"
				Text="Add Asset"
				CssClass="btn btn-default"
				OnClick="btnAddAsset_Click"
				Security_Level_Disabled="30"
				ValidationGroup="vgAddAsset"
				runat="server" />

		</ContentTemplate>
	</asp:UpdatePanel>

	<br />
	<br />

	<!-- Asset Table Header -->
	<asp:UpdatePanel ID="updatePanelTempAsset" runat="server">
		<ContentTemplate>

			<div id="divHeaderGridInfo" class="navbar navbar-default navbar-table" visible="false" runat="server">

				<asp:CheckBox
					ID="chkAll"
					Text="Select All"
					CssClass="header_select-all pull-left"
					OnCheckedChanged="chkAll_CheckedChanged"
					Security_Level_Disabled="30"
					AutoPostBack="true"
					runat="server" />

				<asp:CheckBox
					ID="chkSelectAllFromPage"
					Visible="false"
					Text="Select this page"
					CssClass="header_select-all pull-left"
					Security_Level_Disabled="30"
					OnCheckedChanged="chkSelectAllFromPage_CheckedChanged"
					AutoPostBack="true"
					runat="server" />


				<ul class="nav navbar-nav">
					<li class="dropdown">

						<a class="dropdown-toggle" role="button" aria-expanded="false" href="#" data-toggle="dropdown">Actions <span class="caret"></span>
						</a>

						<ul class="dropdown-menu" role="menu">
							<li>
								<asp:LinkButton
									ID="lnkBtnEditSelected"
									Text="Edit"
									OnClick="lnkBtnEditSelected_Click"
									Security_Level_Disabled="30"
									runat="server" />
							</li>
							<li>
								<asp:LinkButton
									ID="lnkBtnAssignBinAssetTempToBin"
									Text="Assign Bin"
									OnClick="lnkBtnAssignBinAssetTempToBin_Click"
									Security_Level_Disabled="30"
									runat="server" />
							</li>
							<li>
								<asp:LinkButton
									ID="btnDeleteSelectedAsset"
									OnClientClick="return confirm('Are you sure you want to remove the selected asset(s)?')"
									Text="Delete"
									OnClick="btnDeleteSelectedAsset_Click"
									Security_Level_Disabled="30"
									runat="server" />
							</li>
							<li>
								<asp:LinkButton
									runat="server"
									ID="lnkExportToExcel"
									Text="Export List"
									OnClick="lnkExportToExcel_Click"> 
								</asp:LinkButton>
							</li>
						</ul>

					</li>
				</ul>

			</div>

			<div id="divHeaderSubmittedAssets" class="navbar navbar-default navbar-table" visible="false" runat="server">
				<span class="navbar-brand pull-left">Submitted Assets</span>
			</div>

			<!-- Asset Table -->

			<asp:DataGrid
				ID="dgTempAsset"
				CssClass="table table-hover table-striped table-border"
				AutoGenerateColumns="false"
				AllowPaging="false"
				PagerStyle-CssClass="pagination"
				OnPageIndexChanged="dgTempAsset_PageIndexChanged"
				PagerStyle-Mode="NumericPages"
				PageSize="15"
				OnItemDataBound="dgTempAsset_ItemDataBound"
				UseAccessibleHeader="true"
				runat="server">

				<Columns>

					<asp:TemplateColumn>
						<ItemTemplate>

							<asp:CheckBox
								ID="chkAsset"
								HasSubmitted='<%# DataBinder.Eval(Container.DataItem, "Has_Submit")%>'
								Detailed_ID='<%# DataBinder.Eval(Container.DataItem, "Detail_ID")%>'
								Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Site_Code")%>'
								Security_Level_Disabled="30"
								runat="server" />

						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn HeaderText="Tag ID">
						<ItemTemplate>

							<%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>
						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn HeaderText="Serial #">
						<ItemTemplate>

							<%# DataBinder.Eval(Container.DataItem, "Serial_Number")%>
						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn HeaderText="Type">
						<ItemTemplate>

							<%# DataBinder.Eval(Container.DataItem, "Asset_Type_Name")%>
						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn HeaderText="Bin">
						<ItemTemplate>

							<%# DataBinder.Eval(Container.DataItem, "Bin_Number")%>
						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn HeaderText="Condition">
						<ItemTemplate>

							<%# DataBinder.Eval(Container.DataItem, "Asset_Condition_Name")%>
						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn HeaderText="Leased">
						<ItemTemplate>

							<%# DataBinder.Eval(Container.DataItem, "Is_Leased")%>
						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn HeaderText="Purchased">
						<ItemTemplate>

							<%# DataBinder.Eval(Container.DataItem, "Date_Purchased_Formatted")%>
						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn HeaderText="Lease Term">
						<ItemTemplate>

							<%# DataBinder.Eval(Container.DataItem, "Leased_Term_Days")%>
						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn HeaderText="Warranty Term">
						<ItemTemplate>

							<%# DataBinder.Eval(Container.DataItem, "Warranty_Term_Days")%>
						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn ItemStyle-CssClass="invalid">
						<ItemTemplate>
							<asp:Label
								ID="lblErrorMessage"
								CssClass="material-icons"
								Text="error"
								data-toggle="popover"
								data-trigger="hover"
								data-placement="top"
								data-content='<%# DataBinder.Eval(Container.DataItem, "Message_Error")%>'
								HasSubmitted='<%# DataBinder.Eval(Container.DataItem, "Has_Submit")%>'
								Visible="false"
								runat="server" />

						</ItemTemplate>
					</asp:TemplateColumn>

					<asp:TemplateColumn>
						<ItemTemplate>

							<asp:LinkButton
								ID="btnDeleteAsset"
								Text="Delete"
								CssClass="btn btn-default btn-xs"
								OnClientClick="return confirm('Are you sure you want to remove this asset?')"
								OnClick="btnDeleteAsset_Click"
								Detail_ID='<%# DataBinder.Eval(Container.DataItem, "Detail_ID")%>'
								HasSubmitted='<%# DataBinder.Eval(Container.DataItem, "Has_Submit")%>'
								CausesValidation="false"
								Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Site_Code")%>'
								Security_Level_Disabled="30"
								runat="server" />

						</ItemTemplate>
					</asp:TemplateColumn>

				</Columns>
			</asp:DataGrid>

			<asp:Label ID="lblResults" CssClass="label label-default pull-right" runat="server"></asp:Label>

			<asp:Button
				ID="btnSubmit"
				Text="Confirm & Submit Asset(s)"
				CssClass="btn btn-default"
				OnClientClick="return confirm('Are you sure you want to submit these assets?')"
				OnClick="btnSubmit_Click"
				CausesValidation="false"
				Security_Level_Disabled="30"
				runat="server" />

			<asp:Button
				ID="btnReturn"
				Text="Return"
				CssClass="btn btn-primary"
				OnClick="btnReturn_Click"
				runat="server" />

			<asp:CustomValidator
				ID="cvSubmitAsset"
				CssClass="invalid"
				Display="None"
				EnableClientScript="false"
				ValidationGroup="vgSubmitAsset"
				runat="server" />

			<input type="hidden" id="hdnSelectedSite" runat="server" />
			<input type="hidden" id="hdnHasAssetInBin" runat="server" />
		</ContentTemplate>
		<Triggers>
			<asp:PostBackTrigger ControlID="lnkExportToExcel" />
		</Triggers>
	</asp:UpdatePanel>

	<!-- Bootstrap Modal Dialog -->
	<div class="modal fade" id="popupUpdateHeader" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog custom-class">
			<asp:UpdatePanel ID="updatePanelEditHeader" runat="server" UpdateMode="Conditional">
				<ContentTemplate>
					<div class="panel panel-info" runat="server" id="modalTitle">

						<div class="panel-heading">
							<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
							<h4 class="modal-title">
								<asp:Label ID="lblModalTitle" runat="server" Text="" />
							</h4>
						</div>

						<div class="panel-body">
							<table class="table">
								<tr>
									<td><strong>Site</strong></td>
									<td>
										<UC_DDL_SITE:DDL_Site ID="ddlSiteEdit" ValidationGroup="vgEditHeaderInfo" IsSiteRequired="true" runat="server" />
									</td>
								</tr>
								<tr>
									<td><strong>Description</strong></td>
									<td>
										<asp:TextBox ID="txtDescriptionEdit" TextMode="MultiLine" CssClass="form-control" MaxLength="1000" Rows="5" runat="server" />
									</td>
								</tr>
							</table>
						</div>

						<div class="modal-footer">
							<asp:Button
								ID="btnUpdateHeader"
								Text="Update"
								CssClass="btn btn-default"
								OnClick="btnUpdateHeader_Click"
								OnClientClick="return ConfirmUpdateAssetTemp();"
								CausesValidation="true"
								ValidationGroup="vgEditHeaderInfo"
								Security_Level_Disabled="30"
								runat="server" />

							<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
						</div>

					</div>
				</ContentTemplate>
			</asp:UpdatePanel>

		</div>
	</div>



	<!-- Bootstrap Modal Dialog -->
	<div class="modal" id="popupEditAssetDetail" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog custom-class">

			<asp:UpdateProgress ID="updateAssetSearchGridProgress" runat="server" DisplayAfter="10" AssociatedUpdatePanelID="updatePanelEditAssetDetail">
				<ProgressTemplate>
					<div class="divWaiting">
						<img src="../Images/ajax-loader.gif" />
					</div>
				</ProgressTemplate>
			</asp:UpdateProgress>

			<asp:UpdatePanel ID="updatePanelEditAssetDetail" runat="server" UpdateMode="Conditional">
				<ContentTemplate>
					<div class="panel panel-info" runat="server" id="Div1">

						<div class="panel-heading">
							<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
							<h4 class="modal-title">
								<asp:Label ID="lblEditAssetDetailHeader" Text="Edit" runat="server"></asp:Label>
							</h4>
						</div>

						<div class="panel-body">
							<div id="divAssetDetailEdit" runat="server">
								<asp:HiddenField ID="hdnAvailableCapacityEditAssetTemp" runat="server" />
								<asp:HiddenField ID="hdnSelectedCapacityEditAssetTemp" runat="server" />
								<asp:HiddenField ID="hdnIsEditAssetTemp" runat="server" />
								<table>
									<tr>
										<td id="td_EditAssetTempBin" runat="server">Available Bin:
										</td>
										<td>
											<UC_DDL_Bin:DDL_Bin ID="DDL_BinEditAsset" ValidationGroup="vgEditAssetDetail" runat="server" />

											<asp:CustomValidator
												ID="cvEditAssetTemp"
												CssClass="invalid"
												EnableClientScript="false"
												Display="Dynamic"
												ValidationGroup="vgEditAssetDetail"
												runat="server" />
										</td>
									</tr>
									<tr id="trEditAssetTemp_AssetType" runat="server">
										<td class="control-label text-required">Asset Type:
										</td>
										<td>
											<UC_DDL_AssetType:DDL_AssetType ID="DDL_AssetTypeEditAsset" ValidationGroup="vgEditAssetDetail" runat="server" />
										</td>
									</tr>
									<tr id="trEditAssetTemp_AssetCondition" runat="server">
										<td class="control-label text-required">Condition:</td>
										<td>
											<UC_DDL_AssetCondition:DDL_AssetCondition ID="DDL_AssetConditionEditAsset" ValidationGroup="vgEditAssetDetail" runat="server" />
										</td>
									</tr>
									<tr id="trEditAssetTemp_IsLeased" runat="server">
										<td colspan="2">
											<div class="row add-asset-leased">
												<asp:CheckBox ID="chkIsLeasedEditAsset" Text="&nbsp;&nbsp;Leased?" runat="server" AutoPostBack="true" OnCheckedChanged="chkIsLeasedEditAsset_CheckedChanged" CssClass="col-sm-3" />

												<span runat="server" id="spEditAssetLeasedInfo" visible="false">
													<div class="col-sm-4">

														<asp:TextBox runat="server" ID="txtLeasedTermEditAsset" placeholder="Lease Term in Days" MaxLength="4" CssClass="form-control"></asp:TextBox>

														<asp:RequiredFieldValidator
															runat="server"
															ID="RequiredFieldValidator1"
															ControlToValidate="txtLeasedTermEditAsset"
															CssClass="invalid"
															Display="Dynamic"
															Text="Required"
															ErrorMessage="Required"
															ValidationGroup="vgEditAssetDetail">
														</asp:RequiredFieldValidator>

														<asp:CompareValidator
															ID="CompareValidator1"
															Text="Must be numeric."
															ErrorMessage="Must be numeric."
															CssClass="invalid"
															Display="Dynamic"
															Operator="DataTypeCheck"
															ControlToValidate="txtLeasedTermEditAsset"
															Type="Integer"
															ValidationGroup="vgEditAssetDetail"
															runat="server" />
													</div>

												</span>
											</div>
										</td>
									</tr>
									<tr runat="server" id="trEditAssetTemp_PurchasedDate">
										<td colspan="2">
											<UC:TXT_Date
												ID="txtPurchasedDateEditAsset"
												runat="server"
												placeholder="Purchased Date"
												IsDateRequired="true"
												EnableClientScript="true"
												ValidationGroup="vgEditAssetDetail"></UC:TXT_Date>
										</td>
									</tr>
									<tr runat="server" id="trEditAssetTemp_WarrantyTermDays">
										<td colspan="2">
											<asp:TextBox runat="server" ID="txtWarrantyTermDaysEditAsset" placeholder="Warranty Term in Days" MaxLength="4" CssClass="form-control"></asp:TextBox>

											<asp:RequiredFieldValidator
												runat="server"
												ID="RequiredFieldValidator2"
												ControlToValidate="txtWarrantyTermDaysEditAsset"
												CssClass="invalid"
												Display="Dynamic"
												Text="Required"
												ErrorMessage="Required"
												Visible="false"
												ValidationGroup="vgEditAssetDetail">
											</asp:RequiredFieldValidator>

											<asp:CompareValidator
												ID="CompareValidator2"
												Text="Must be numeric."
												ErrorMessage="Must be numeric."
												CssClass="invalid"
												Display="Dynamic"
												Operator="DataTypeCheck"
												EnableClientScript="true"
												ControlToValidate="txtWarrantyTermDaysEditAsset"
												Type="Integer"
												ValidationGroup="vgEditAssetDetail"
												runat="server" />
										</td>
									</tr>
								</table>
							</div>
						</div>

						<div class="modal-footer">
							<asp:Button
								ID="btnSaveAssetDetail"
								Text="Update"
								CssClass="btn btn-default"
								OnClick="btnSaveAssetDetail_Click"
								OnClientClick="return confirm('Are you sure you want to override your existing changes?');"
								CausesValidation="true"
								ValidationGroup="vgEditAssetDetail"
								Security_Level_Disabled="30"
								runat="server" />
							<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
						</div>

					</div>
				</ContentTemplate>
			</asp:UpdatePanel>

		</div>
	</div>

	<!-- Bootstrap Modal Dialog -->
	<div class="modal fade" id="popupSubmitSuccessMessage" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog custom-class">
			<asp:UpdatePanel ID="upModal" runat="server" ChildrenAsTriggers="false" UpdateMode="Conditional">
				<ContentTemplate>
					<div class="panel panel-info" runat="server" id="Div2">
						<div class="panel-heading">
							<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
							<h4 class="modal-title">
								<asp:Label ID="lblSuccessTitle" runat="server" Text="Successfully Submitted"></asp:Label></h4>
						</div>
						<div class="panel-body">
							<asp:Label ID="lblSuccessBody" runat="server" Text="Your batch has been loaded."></asp:Label>
						</div>
						<div class="modal-footer">
							<asp:Button
								ID="BtnOkSubmitSuccess"
								Text="Ok"
								CssClass="btn btn-default"
								OnClick="BtnOkSubmitSuccess_Click"
								CausesValidation="false"
								runat="server" />
						</div>
					</div>
				</ContentTemplate>
			</asp:UpdatePanel>
		</div>
	</div>

	<script>
		function ConfirmUpdateAssetTemp() {
			var dbSiteID = $("#cph_Body_ddlSiteEdit_ddlSite").attr("db_site_id");
			var selectedDDLSite = $('#cph_Body_ddlSiteEdit_ddlSite').find('option:selected').val();
			var dbHasSiteInBin = $("#cph_Body_ddlSiteEdit_ddlSite").attr("has_site_in_bin");
			var msg_Warning_Bin_Cleared = "";

			if (dbSiteID != selectedDDLSite && dbHasSiteInBin == "1") {
				msg_Warning_Bin_Cleared = "WARNING: This will unassigned all asset(s) from their assigned bin. \n\n";
			}

			return confirm(msg_Warning_Bin_Cleared + "Are you sure you want to save this?");
		}
	</script>
</asp:Content>
