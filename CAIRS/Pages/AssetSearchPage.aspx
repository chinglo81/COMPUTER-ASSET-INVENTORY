<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AssetSearchPage.aspx.cs" Inherits="CAIRS.Pages.AssetSearchPage"  MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" MaintainScrollPositionOnPostback="true" %>

<%@ MasterType VirtualPath="~/MasterPages/CAIRSMasterPage.Master" %>

<%@ Register Src="~/Controls/DDL_Site.ascx" TagName="DDL_Site" TagPrefix="UC_DDL_SITE" %>
<%@ Register Src="~/Controls/DDL_Bin.ascx" TagName="DDL_Bin" TagPrefix="UC_DDL_Bin" %>
<%@ Register Src="~/Controls/DDL_AssetBaseType.ascx" TagName="DDL_AssetBaseType" TagPrefix="UC_DDL_AssetBaseType" %>
<%@ Register Src="~/Controls/DDL_AssetType.ascx" TagName="DDL_AssetType" TagPrefix="UC_DDL_AssetType" %>
<%@ Register Src="~/Controls/TXT_SerialNumber.ascx" TagName="TXT_SerialNum" TagPrefix="UC_TXT_SerialNum" %>
<%@ Register Src="~/Controls/TXT_TagID.ascx" TagName="TXT_TagID" TagPrefix="UC_TXT_TagID" %>
<%@ Register Src="~/Controls/DDL_MULTI_SELECT_CHECKBOX.ascx" TagName="DDL_MULTI" TagPrefix="UC_MULTI_SELECT" %>
<%@ Register Src="~/Controls/TXT_Date.ascx" TagName="Date" TagPrefix="UC" %>
<%@ Register Src="~/Controls/LOOKUP_Employee.ascx" TagName="Employee_lookup" TagPrefix="UC" %>
<%@ Register Src="~/Controls/MULTI_SELECT_AssetCondition.ascx" TagName="AssetCondition" TagPrefix="MULTI" %>
<%@ Register Src="~/Controls/MULTI_SELECT_AssetDisposition.ascx" TagName="AssetDisposition" TagPrefix="MULTI" %>

<asp:Content id="Content1" ContentPlaceHolderid="cph_Body" Runat="server">
    
	<h1>Asset Search</h1>     

            <div class="row">
    	        <div class="col-xs-12">
                    <div>
                        <asp:RadioButtonList runat="server" ID="radSingleMultiple" CssClass="spaced" RepeatDirection="Horizontal" OnSelectedIndexChanged="radSingleMultiple_SelectedIndexChanged" AutoPostBack="true">
                            <asp:ListItem Text="Single Asset" Value="SINGLE" Selected="True"></asp:ListItem>
	                        <asp:ListItem Text="Multiple Assets" Value="MULTIPLE"></asp:ListItem>
                        </asp:RadioButtonList>
                    </div>

                    <div>
                        <!-- Search Type Radio List -->
                        <asp:RadioButtonList runat="server" ID="radLstIDType" CssClass="spaced" RepeatDirection="Horizontal">
	                        <asp:ListItem Text="Tag ID" Value="TAGID" Selected="True"></asp:ListItem>
	                        <asp:ListItem Text="Serial #" Value="SERNUM"></asp:ListItem>
	                        <asp:ListItem Text="Student ID" Value="STUID"></asp:ListItem>
                        </asp:RadioButtonList>
                    </div>

                    <!-- Search Box -->
                    <div class="form-group">
                        <asp:TextBox runat="server" ID="txtSingleId" CssClass="form-control" MaxLength="100" Width="300px"></asp:TextBox>
                        <asp:TextBox Visible="false" runat="server" ID="txtIds" CssClass="form-control ui-autocomplete-input" placeholder="(New line or comma separated)" TextMode="MultiLine" />
                    </div>
                    <!-- Search Buttons -->
                    <asp:Button runat="server" ID="btnSearch" CssClass="btn btn-default" Text="Search" OnClick="btnApplyFilters_Click" OnClientClick="DisplayProgressLoader();" />
                    <asp:Button runat="server" id="Button" Text="Clear" CssClass="btn btn-primary" OnClick="btnClear_Click"/>

                    <!-- Enable/Disable Search Filters -->
	                <asp:LinkButton CausesValidation="false" runat="server" ID="lnkBtnShowFilters" Text="[ + Enable Filters ]" CssClass="btn btn-link btn-sm btn-align-top" OnClick="lnkBtnShowFilters_Click" OnClientClick="DisplayProgressLoader();"></asp:LinkButton>
	                <asp:LinkButton CausesValidation="false" runat="server" ID="lnkBtnHideFilters" Text="[ - Disable Filters ]" CssClass="btn btn-link btn-sm btn-align-top" OnClick="lnkBtnHideFilters_Click" Visible="false" OnClientClick="DisplayProgressLoader();"></asp:LinkButton>
           
                </div>
            </div>

    <br />
    

    <!-- Filters Container -->
    <div id="divAdditionalFilters" runat="server" visible="false" class="well">
        <div class="row">

            <div class="col-sm-6">

                <div class="form-group">
                    <UC_DDL_SITE:DDL_Site ID="ddlSite" SelectedIndexChanged_DDL_Site="SelectedIndexChangedDDLSite" runat="server" />
                </div>

                <asp:UpdatePanel ID="updatePanelBaseAssetType" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="form-group">
                            <UC_DDL_AssetBaseType:DDL_AssetBaseType ID="ddlAssetBaseType" runat="server" />
                        </div>

                        <div class="form-group">
                            <UC_DDL_AssetType:DDL_AssetType ID="ddlAssetType" runat="server" />
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>

            </div>

            <div class="col-sm-6">

                <div class="form-group">
                    <MULTI:AssetCondition runat="server" ID="multiAssetCondition"></MULTI:AssetCondition>
                    <asp:HiddenField ID="hdnSelectedAssetCondition" runat="server" />
                </div>

                <div class="form-group">
                    <MULTI:AssetDisposition runat="server" ID="multiAssetDisposition"></MULTI:AssetDisposition>
                    <asp:HiddenField ID="hdnSelectedAssetDisposition" runat="server" />
                </div>

                <div class="form-group">
                    <asp:CheckBox ID="chkAssetUnassignToBin" Text="&nbsp;&nbsp;Asset(s) Not Assigned to a Bin" runat="server" />
                </div>

            </div>
        </div>

        <asp:Button 
            ID="btnApplyFilters" 
            Text="Apply Filters" 
            OnClick="btnApplyFilters_Click" 
            CausesValidation="true" 
            OnClientClick="DisplayProgressLoader();" 
            ValidationGroup="vgApplyFilters" 
            CssClass="btn btn-default" 
            runat="server"/>

		<asp:Button ID="btnClear" Text="Clear" CssClass="btn btn-primary" OnClick="btnClear_Click" runat="server" />

    </div>

    <br />
    <asp:UpdateProgress ID="updateAssetSearchGridProgress" runat="server" DisplayAfter="1" AssociatedUpdatePanelID="updateAssetSearchGrid">
        <ProgressTemplate>
            <div class="divWaiting">
                <img src="../Images/ajax-loader.gif"  />
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>


    <asp:UpdatePanel runat="server" ID="updateAssetSearchGrid">
        <ContentTemplate>

            <asp:Button runat="server" ID="btnRefresh" CssClass="btn btn-default" Text="Refresh" OnClick="btnRefresh_Click" style="display: none" />

            <!-- Action result labels & validation -->
	        <asp:Label runat="server" ID="lblSuccessfullySubmitted" CssClass="alert alert-success center-block" Text="Successfully Submitted"></asp:Label>
	        <!-- No Results -->
	        <asp:Label id="alertAssetSearchResults" class="alert alert-danger col-xs-12" runat="server">No assets found.</asp:Label>

            <!-- Asset Search Results Header -->
            <div class="navbar navbar-default navbar-table" runat="server" id="divHeaderGridInfo" visible="false">

                <asp:CheckBox ID="chkAll" Text="Select all" CssClass="header_select-all pull-left" OnCheckedChanged="chkAll_CheckedChanged" Security_Level_Disabled="10,20,40" AutoPostBack="true" runat="server"  />

                <asp:CheckBox ID="chkSelectAllFromPage" Text="Select this page" CssClass="header_select-all pull-left" Security_Level_Disabled="10,20,40" OnCheckedChanged="chkSelectAllFromPage_CheckedChanged" AutoPostBack="true" runat="server" />

                <ul class="nav navbar-nav">
                    <li class="dropdown">

                        <a class="dropdown-toggle" role="button" aria-expanded="false" href="#" data-toggle="dropdown">Actions <span class="caret"></span></a>

                        <ul class="dropdown-menu" role="menu">
                            <li>
                                <asp:LinkButton 
                                    runat="server" 
                                    ID="lnkBtnTransfer" 
                                    Text="Transfer" 
                                    OnClick="lnkBtnTransfer_Click" 
                                    Security_Level_Disabled="10,20,40">
                                </asp:LinkButton>
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
	
            <!-- Asset Search Results Details -->
	        <asp:DataGrid 
		        ID="dgAssetResults" 
		        CssClass="table table-hover table-striped table-border" 
		        AutoGenerateColumns="false"
		        AllowPaging="true"
		        AllowSorting="true"
		        PagerStyle-Mode="NumericPages"
		        PagerStyle-CssClass="pagination"
		        OnPageIndexChanged="dgAssetResults_PageIndexChanged" 
		        PageSize="15"
		        OnSortCommand="dgAssetResults_SortCommand"
		        OnItemDataBound="dgAssetResults_ItemDataBound"
                UseAccessibleHeader="true" 
		        runat="server" >
		        <Columns>
			        <asp:TemplateColumn>
				        <ItemTemplate>
					        <asp:CheckBox 
						        runat="server"
						        Security_Level_Disabled="10,20,40"
						        ID="chkAsset"
						        Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
						        Checked='<%# IsChecked(Container.DataItem)%>'
						        OnCheckedChanged="chkAsset_CheckedChanged"
						        AutoPostBack="true"
                            />
				        </ItemTemplate>
			        </asp:TemplateColumn>
			        <asp:TemplateColumn HeaderText="Tag ID" SortExpression="Tag_ID">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Serial #" SortExpression="Serial_Number">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Serial_Number")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
			        <asp:TemplateColumn SortExpression="Asset_Type_Desc" HeaderText="Asset Type">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Asset_Type_Desc")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
			        <asp:TemplateColumn SortExpression="Asset_Disposition_Desc" HeaderText="Disposition">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Asset_Disposition_Desc")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
			        <asp:TemplateColumn SortExpression="Asset_Condition_Desc" HeaderText="Condition">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Asset_Condition_Desc")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
			        <asp:TemplateColumn SortExpression="Asset_Site_Desc" HeaderText="Site">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Asset_Site_Desc")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
			        <asp:TemplateColumn SortExpression="Bin_Site_Desc" HeaderText="Site Bin">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Bin_Site_Desc")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
			        <asp:TemplateColumn SortExpression="Student_ID" HeaderText="Student ID">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Student_ID")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
			        <asp:TemplateColumn SortExpression="Student_Assigned_To" HeaderText="Last Assigned Student">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Student_Assigned_To")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
			        <asp:TemplateColumn>
				        <ItemTemplate>
					        <asp:Button 
						        runat="server" 
						        ID="btnViewAsset" 
						        CssClass="btn btn-primary btn-xs"
						        Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
						        CausesValidation="false" 
						        Text="View" 
						        OnClick="btnViewAsset_Click"/>
				        </ItemTemplate>
			        </asp:TemplateColumn>

		        </Columns>
	        </asp:DataGrid>

            <!-- Asset Search Result Totals -->
            <asp:Label ID="lblResults" CssClass="label label-default pull-right" runat="server" />

            <asp:Label ID="lblSelected" CssClass="label label-success pull-right" runat="server" />

        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="lnkExportToExcel"/>
        </Triggers>
    </asp:UpdatePanel>

	<!-- Assign Asset to Bin - Bootstrap Modal Dialog 
        Currently not used. We were planning to used this but decided user can just use bin management to move asset around-->
	<div class="modal fade" id="popupAssignAssetToBin" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog custom-class">
			<div>
				<div class="panel panel-info" runat="server" id="Div1">
				<div class="panel-heading">
					<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
					<h4 class="modal-title">
						<asp:Label ID="lblEditAssetDetailHeader" runat="server" Text="Assign Selected Asset(s) To Bin"></asp:Label></h4>
				</div>
				<div class="panel-body">
					<div id="divAssignAssetToBin" runat="server">
						<table>
							<tr>
								<td>
									Site:
								</td>
								<td>
									<asp:Label runat="server" ID="lblSite_Assign_Asset_To_Bin"></asp:Label>
								</td>
							</tr>
							<tr>
								<td>
									Available Bin:
								</td>
								<td>
									<UC_DDL_Bin:DDL_Bin runat="server" ID="ddlBin_Assign_Asset_To_Bin" ValidationGroup="vgAssignAssetToBin" IsBinRequired="true" />
									<asp:Label runat="server" ID="lblCapacityAssignToBin"></asp:Label>
									<asp:CustomValidator runat="server" ID="cvModal" CssClass="invalid" EnableClientScript="false" Display="Dynamic" ValidationGroup="vgAssignAssetToBin"></asp:CustomValidator>
								</td>
							</tr>
						</table>
					</div>
				</div>
				<div class="modal-footer">
					<asp:Button CssClass="btn btn-default" CausesValidation="true" ValidationGroup="vgAssignAssetToBin" runat="server" ID="btnSaveAssignToBin" OnClick="btnSaveAssignToBin_Click" Text="Assign To Bin" OnClientClick="return confirm('Are you sure you want to assign these asset to the selected bin?');"  />
					<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
				</div>
			</div>
			</div>
		</div>
	</div>


    <!-- Transfer Asset - Bootstrap Modal Dialog -->
	<div class="modal" id="divTransferAssetModal"  role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <asp:UpdateProgress ID="updateTransferAssetModalProgress" runat="server" DisplayAfter="1" AssociatedUpdatePanelID="updateTransferAssetModal">
            <ProgressTemplate>
                <div class="divWaiting">
                    <img src="../Images/ajax-loader.gif" />
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>


		<asp:UpdatePanel runat="server" ID="updateTransferAssetModal">
			<ContentTemplate>
				<div class="modal-dialog modal-lg" role="document"> 
					<div id="divModalTitle" class="panel panel-info" runat="server">

						<div class="panel-heading">

							<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>

							<h4 class="modal-title">
								<asp:Label ID="lblTransferAssetTitle" runat="server" Text="Transfer Asset(s)" />
							</h4>

						</div>

						<div class="panel-body">
                            <asp:HiddenField ID="hdnIsTransferAssetAllValid" runat="server" />
                            <asp:HiddenField ID="hdnTransferGrid_SortCriteria" runat="server" />
                            <asp:HiddenField ID="hdnTransferGrid_SortDir" runat="server" />
                            <asp:HiddenField ID="hdnTransferGrid_PageIndex" runat="server" />

							<div class="navbar navbar-default navbar-table">
								 <span class="navbar-brand pull-left">Selected Asset(s) to Transfer</span>
							</div>

                            <br />

                            <table>
                                <tr>
                                    <td>
                                        <label class="control-label" for="cph_Body_ddlSiteTransferAsset_ddlSite">Transfer Site: </label>
                                    </td>
                                    <td style="width:10px;"></td>
                                    <td>
                                        <UC_DDL_SITE:DDL_Site 
                                            ID="ddlSiteTransferAsset" 
                                            runat="server"
                                            AutoPostBack="true"
                                            ValidationGroup="vgTransferAsset" 
                                            IsSiteRequired="true" 
                                            EnableClientScript="true" 
                                        />
                                    </td>
                                </tr>
                            </table>

                            <br />

							<asp:DataGrid 
								ID="dgTransferAsset" 
								CssClass="table table-hover table-striped table-border"
                                OnItemDataBound="dgTransferAsset_ItemDataBound"
								AutoGenerateColumns="false" 
								GridLines="None"
                                AllowPaging="True"
                                AllowSorting="true"
                                OnPageIndexChanged="dgTransferAsset_PageIndexChanged"
                                OnSortCommand="dgTransferAsset_SortCommand"
                                PageSize="10"
                                PagerStyle-Mode="NumericPages"
		                        PagerStyle-CssClass="pagination"
								UseAccessibleHeader="true"
								runat="server" 
                            >

								<Columns>

									<asp:TemplateColumn HeaderText="Asset Site" SortExpression="Asset_Site_Desc">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Desc")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Tag ID" SortExpression="Tag_ID">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Asset Type" SortExpression="Asset_Type_Desc">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Asset_Type_Desc")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Disposition" SortExpression="Asset_Disposition_Desc">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Asset_Disposition_Desc")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Condition" SortExpression="Asset_Condition_Desc">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Asset_Condition_Desc")%>

										</ItemTemplate>
									</asp:TemplateColumn>

                                    <asp:TemplateColumn ItemStyle-CssClass="invalid" HeaderText="Error Message" SortExpression="Message_Error">
						                <ItemTemplate>

							                <asp:Label
								                ID="lblErrorMessage"
								                CssClass="material-icons"
								                Text="error"
								                data-toggle="popover"
								                data-trigger="hover"
								                data-placement="top"
								                data-content='<%# DataBinder.Eval(Container.DataItem, "Message_Error")%>'
								                Visible="false"
								                runat="server" 
                                            />

						                </ItemTemplate>
					                </asp:TemplateColumn>

					                <asp:TemplateColumn>
						                <ItemTemplate>

							                <asp:LinkButton
								                ID="btnRemoveAssetFromTransfer"
								                Text="Remove"
                                                Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
								                CssClass="btn btn-default btn-xs"
								                OnClientClick="return confirm('Are you sure you want to remove this asset?')"
								                OnClick="btnRemoveAssetFromTransfer_Click"
								                runat="server" />

						                </ItemTemplate>
					                </asp:TemplateColumn>

								</Columns>
							</asp:DataGrid>
                            
                            <asp:CustomValidator 
                                CssClass="invalid"
                                runat="server" 
                                ID="cvInvalidAssetToTransfer" 
                                ValidationGroup="vgTransferAsset"
                                Text="* Error Transferring asset(s). Please hover over red icon to review Error Message."
                                ErrorMessage="* Error Transferring asset(s). Please hover over red icon to review Error Message."    
                            />

                            <br />

					        <asp:Label ID="lblResultsTransferAssetCount" CssClass="label label-default pull-right" runat="server" />
                            <asp:Label ID="lblResultsTransferInvalidCount" CssClass="label label-danger pull-right" runat="server" />
                            

                            <br />

						</div>

						<div class="modal-footer">

                            <asp:Button 
                                runat="server" 
                                ID="btnSaveTransfer" 
                                OnClick="btnSaveTransfer_Click" 
                                Text="Submit Transfer" 
                                CssClass="btn btn-default" 
                                CausesValidation="true"
                                ValidationGroup="vgTransferAsset"
                            />

							<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
					
						</div>

					</div>
				</div>
			</ContentTemplate>
		</asp:UpdatePanel>
	</div>

    <script>

        function ConfirmTransferAsset() {
            if (Page_ClientValidate("vgTransferAsset"))
            {
                return confirm('Are you sure you want to transfer these assets?');
            }
            return false;
        }

        function HandleNumberEntered(e) {
            if (e.keyCode == 35 || e.keyCode == 59) {
                e.preventDefault();

                var sValue = $("#" + "<%=txtIds.ClientID %>").val();
                $("#" + "<%=txtIds.ClientID %>").val(sValue + "\r\n");
            }
        }

        function HandleSingleNumberEntered(e) {
            if (e.keyCode == 35 || e.keyCode == 59) {
                e.preventDefault();

                $('#cph_Body_btnSearch').focus().click();
            }
        }
        

        $(document).ready(function () {
            // Add Asset - Capture enter fire from scanner, refocus to Tag ID
            $('#cph_Body_txtIds').on('keypress', function (e) {
               HandleNumberEntered(e)
            });

            $('#cph_Body_txtSingleId').on('keypress', function (e) {
                HandleSingleNumberEntered(e)
            });

            $('#divTransferAssetModal').on('hidden.bs.modal', function () {
               <%-- $("#" + "<%=btnRefresh.ClientID %>").focus().click();--%>
            })

        });


    </script>

</asp:Content>