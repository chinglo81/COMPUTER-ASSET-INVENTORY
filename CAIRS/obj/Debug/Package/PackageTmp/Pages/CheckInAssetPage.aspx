<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CheckInAssetPage.aspx.cs" Inherits="CAIRS.Pages.CheckInAssetPage" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" MaintainScrollPositionOnPostback="true" EnableEventValidation="false"%>
<%@ MasterType VirtualPath="~/MasterPages/CAIRSMasterPage.Master" %>

<%@ Register Src="~/Controls/DDL_Site.ascx" TagName="DDL_Site" TagPrefix="UC" %>
<%@ Register Src="~/Controls/LOOKUP_Student.ascx" TagName="LookUp_Student" TagPrefix="UC" %>
<%@ Register Src="~/Controls/StudentInfoControl.ascx" TagName="Student_Info" TagPrefix="UC" %>
<%@ Register Src="~/Controls/TXT_TagID.ascx" TagName="Tag_ID" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_Bin.ascx" TagName="DDL_Bin" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AssetCondition.ascx" TagName="DDL_AssetCondition" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AssetDisposition.ascx" TagName="DDL_AssetDisposition" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_InteractionType.ascx" TagName="DDL_InteractionType" TagPrefix="UC" %>
<%@ Register Src="~/Controls/AddAssetAttachment.ascx" TagName="Add_Attachment" TagPrefix="UC" %>
<%@ Register Src="~/Controls/TXT_SerialNumber.ascx" TagName="Serial_Number" TagPrefix="UC" %>

<asp:Content id="Content1" ContentPlaceHolderid="cph_Body" Runat="server">
    
	<asp:HiddenField runat="server" ID="hdnStudentID" />
	<asp:HiddenField runat="server" ID="hdnAssetStudentTransactionID" />
	<asp:HiddenField runat="server" ID="hdnTagId" />

	<h1>Check-in</h1>

	<asp:Label runat="server" ID="lblSuccessfullySubmitted" CssClass="alert alert-success center-block" Visible="false" Text="Successfully Checked-in Asset"></asp:Label>


	<!-- Alert: Warning message -->
	<div runat="server" id="divWarningMsg" class="alert alert-info">
		<h4>Warning</h4>
		<ul><asp:Label runat="server" ID="lblWarningMsg" /></ul>
	</div>

	<!-- Asset Search -->
	<div runat="server" id="divSearchInfo" class="row">
		
		<!-- Student Info -->
		<div runat="server" id="divStudentInfo" class="col-sm-6 pull-right">

				<UC:Student_Info runat="server" ID="Student_Info" />
						
		</div>

		<div class="col-sm-6">

			<div class="form-group">
                
				<UC:DDL_Site ID="ddlSite" ValidationGroup="vgCheckin" AutoPostBack="true" runat="server" />
       
				<asp:CustomValidator ID="cvCheckInValidator" CssClass="invalid" ValidationGroup="vgCheckin" Display="Dynamic" runat="server" />
 
			</div>

			<div class="form-group">

				<asp:DropDownList runat="server" ID="ddlCheckInType" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlCheckInType_SelectedIndexChanged" />

				<asp:RequiredFieldValidator
					ID="reqCheckInType"
					Text="Required"
					CssClass="invalid"
					Display="Dynamic" 
					InitialValue="-98" 
					EnableClientScript="false"
					ValidationGroup="vgSearchAsset"
					ControlToValidate="ddlCheckInType"
					runat="server" />

			</div>

			<div class="row">
				<div class="form-group">

					<div runat="server" id="divSearchBy" visible="false">

						<strong class="col-xs-4 pull-left">Search By:</strong>
						
						<asp:RadioButtonList 
						ID="radSearchType" 
						CssClass="spaced" 
						RepeatDirection="Horizontal" 
						AutoPostBack="true" 
						OnSelectedIndexChanged="radSearchType_SelectedIndexChanged" 
						runat="server">
							<asp:ListItem Value="TAGID" Text="Tag ID" Selected="True" />
							<asp:ListItem Value="SERIAL_NUMBER" Text="Serial #" />
					</asp:RadioButtonList>

					</div>
					
					<div runat="server" id="divTagId" class="col-xs-12">

						<UC:Tag_ID ID="txtTagID" IsTagIDRequired="true" ValidationGroup="vgSearchAsset" runat="server" />

						<br /><br />

						<asp:Button ID="btnSearchTagID" CssClass="btn btn-default" Text="Find Asset" OnClick="btnSearchTagID_Click" ValidationGroup="vgSearchAsset" runat="server" />

					</div>

					<div runat="server" id="divSerialNumber" class="col-xs-12">

						<UC:Serial_Number runat="server" ID="txtSerialNumber" IsSerialNumRequired="true" ValidationGroup="vgSearchAsset" />

						<br /><br />

						<asp:Button runat="server" ID="btnSerialNumberSearch" CssClass="btn btn-default" Text="Find Asset" OnClick="btnSerialNumberSearch_Click" ValidationGroup="vgSearchAsset"/>

					</div>

					<div runat="server" id="divStudentLookup" class="col-xs-12">

						<UC:LookUp_Student runat="server" ID="txtStudentLookup" IsStudentLookupRequired="true" ValidationGroup="vgSearchStudent" btnSearchStudentClick="btnStudentSearch_Click" />

						<asp:Label runat="server" ID="lblNoResults" CssClass="text-info"></asp:Label>

					</div>

				</div>
			</div>
		</div>
	</div>

	<br />
	<br />

	<!-- Current Asset Assignments -->
			
	<asp:Label runat="server" ID="lblResults" CssClass="text-info" />

	<div id="divCurrentlyAssigned" runat="server">

		<div class="navbar navbar-default navbar-table">
			<span class="navbar-brand pull-left">Current Assignments</span>
		</div>

		<asp:DataGrid 
			ID="dgAssignment" 
			CssClass="table table-hover table-striped table-border" 
			GridLines="None"
			AutoGenerateColumns="false"
			OnItemDataBound="dgAssignment_ItemDataBound" 
			UseAccessibleHeader="true"
			runat="server" >

			<Columns>

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

				<asp:TemplateColumn HeaderText="Base Type">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Asset_Base_Type_Desc")%>

					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="Asset Type">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Asset_Type_Desc")%>

					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="School">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Student_School_Name")%>

					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn HeaderText="Student">
					<ItemTemplate>

						<%# DataBinder.Eval(Container.DataItem, "Student_Name")%>

					</ItemTemplate>
				</asp:TemplateColumn>

				<asp:TemplateColumn>
					<ItemTemplate>

						<asp:Button
							ID="btnCheckin"
							Text="Check-In"
							OnClick="btnCheckInAsset_Click"
							CssClass="btn btn-default btn-xs"
							Tag_ID='<%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>'
							Serial_Number='<%# DataBinder.Eval(Container.DataItem, "Serial_Number")%>'
							Disp_Allow_Checkin ='<%# DataBinder.Eval(Container.DataItem, "Disposition_Allow_CheckIn")%>' 
							Asset_Site_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_ID")%>'
                            Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
							Asset_Student_Transaction_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
							CausesValidation="true"
							ValidationGroup="vgCheckin"
							runat="server" />

					</ItemTemplate>
				</asp:TemplateColumn>
			</Columns>
		</asp:DataGrid>
	</div>

    <!-- Asset Info -->
    <div id="divAssetInfo" runat="server" class="row">
        
        <div class="form-group">
                
            <div class="col-sm-4">
                
                <div class="panel panel-info">

                    <div class="panel-heading">Asset Info</div>

                    <div class="panel-body">

                        <div class="alert alert-info" runat="server" id="divAssetInfoImportantMessage">
				            <h4>IMPORTANT!!!</h4>
                            <asp:Label runat="server" ID="lblAssetInfoAlertMessage"></asp:Label>
			            </div>

                        <table class="table" id="tblAssetInfo" runat="server">
                            <tr>
                                <td><strong>Tag ID</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblTagID" data_column="Tag_ID"></asp:Label>
                                    <asp:HiddenField runat="server" ID="hdnAssetInfo_Asset_ID" Value="Asset_ID" />
                                    <asp:HiddenField runat="server" ID="hdnAssetInfo_Asset_Site_ID" Value="Asset_Site_ID" />
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Serial #</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblSerialNumber" data_column="Serial_Number"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Base Type</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="Label2" data_column="Asset_Base_Type_Desc"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Asset Type</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="Label1" data_column="Asset_Type_Desc"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Asset Site</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblAssetSite" data_column="Asset_Site_Desc"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Disposition</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="Label3" data_column="Asset_Disposition_Desc"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Condition</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="Label4" data_column="Asset_Condition_Desc"></asp:Label>
                                </td>
                            </tr>
                            <tr runat="server" id="trProcessFound">
                                <td colspan="2">
                                    <asp:Button 
					                    ID="btnProcesssFound" 
					                    Text="Found" 
					                    CssClass="btn btn-default pull-right" 
					                    OnClick="btnProcesssFound_Click" 
					                    runat="server" />
                                </td>
                            </tr>
                        </table>

                    </div>
       
                </div>

            </div>

        </div>

    </div>

	<!-- START CHECK IN  MODAL -->

	<div class="modal fade" id="popupCheckIn" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog" role="document">

			<div class="panel panel-info" runat="server" id="modalTitle">

				<div class="panel-heading">

					<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>

					<h4 class="modal-title">
                        <asp:Label runat="server" ID="lblModalCheckInTitle"></asp:Label>
					</h4>

				</div>

				<div runat="server" id="divStudentTransactionDetails" class="panel-body">
                    <asp:UpdatePanel runat="server" ID="updatePanelCheckInModal" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:HiddenField runat="server" ID="hdnIsFlagForResearch" />
                            <asp:HiddenField runat="server" ID="hdnConditionBusinessRule" />

					        <div class="alert alert-info" runat="server" id="divImportantAffixSticker">
						        <h4>IMPORTANT!!!</h4>
						        Please affix sticker with Student ID and Name. You are checking in an item without a Tag ID.
					        </div>

                            <div class="form-group" runat="server" id="divAssetStoredSite">
                                <asp:Label runat="server" ID="lblAsset_Stored_Site"></asp:Label>
                            </div>

					        <div class="form-group">
						        <UC:DDL_AssetDisposition runat="server" ID="ddlDisposition_CheckIn" IsAssetDispositionRequired="true" ValidationGroup="vgCheckinSubmit" AutoPostBack="true" />
					        </div>

                            <div class="form-group" runat="server" id="divPoliceReport">
						        <asp:CheckBox runat="server" ID="chkPoliceReport" Text="Police Report Provided?" CssClass="space-check-box" />
                            
                                <div class="alert alert-info">
                                    Note: Please remember to attach police report if you checked the box above.
                                </div>

					        </div>

					        <div class="form-group" runat="server" id="divAssetCondition_CheckIn">
						        <UC:DDL_AssetCondition runat="server" ID="ddlCondition_CheckIn" IsAssetConditionRequired="true" ValidationGroup="vgCheckinSubmit" />
					        </div>

					        <div class="form-group" runat="server" id="divBin_CheckIn">
						        <UC:DDL_Bin runat="server" ID="ddlBin_CheckIn" IsBinRequired="true" ValidationGroup="vgCheckinSubmit"/>
					        </div>

					        <div class="form-group">
						        <asp:TextBox runat="server" ID="txtComments_CheckIn" CssClass="form-control" Placeholder="Comment" TextMode="MultiLine" />
					        </div>
                    
                            </ContentTemplate>
                        </asp:UpdatePanel>

                    <div class="form-group">
					    <UC:Add_Attachment runat="server" ID="uc_AddAttachment_CheckIn" />
                    </div>

				</div>

				<div class="modal-footer">

				<asp:Button 
					ID="btnSubmitCheckIn" 
					Text="Submit Check-in" 
					CssClass="btn btn-default" 
					OnClick="btnSubmitCheckIn_Click" 
					OnClientClick="return confirm('Are you sure you want to check-in this asset?')"
					CausesValidation="true" 
					ValidationGroup="vgCheckinSubmit" 
					runat="server" />

				<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

			</div>
                
			</div>
		</div>
	</div>

    <!-- END CHECK IN  MODAL -->


	<!-- Bootstrap Modal Dialog -->
	<div class="modal fade" id="confirmPopup" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="panel panel-info" runat="server" id="Div1">

				<div class="panel-heading">
					<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
					<h4 class="modal-title">
						<asp:Label ID="confirmTitle" runat="server" Text="" />
					</h4>
				</div>

				<div class="panel-body">
					<asp:Label ID="confirmBody" runat="server" Text="" />
				</div>

				<asp:HiddenField runat="server" ID="hdnIsChangeSite" />

				<div class="modal-footer">

					<asp:Button ID="btnOkCancelOutOfChanges" CssClass="btn btn-default" runat="server" OnClick="btnOkCancelOutOfChanges_Click" Text="Continue" />

					<button class="btn" data-dismiss="modal" aria-hidden="true">Cancel</button>

				</div>

			</div>
		</div>
	</div>

	<script>
		$(document).ready(function () {
			// Add Asset - Capture enter fire from scanner, refocus to Tag ID
			$('#cph_Body_txtTagID_txtTagID').on('keypress', function (e) {
			    if (e.keyCode == 35 || e.keyCode == 59) {
					HandleNumberEnteredTagId(e)
				}
			});

			// Add Asset - Capture enter fire from scanner, refocus to Serial Number
			$('#cph_Body_txtSerialNumber_txtSerialNumber').on('keypress', function (e) {
			    if (e.keyCode == 35 || e.keyCode == 59) {
					HandleNumberEnteredSerialNumber(e)
				}
			});


			function HandleNumberEnteredTagId(e) {
			    if (e.keyCode == 35 || e.keyCode == 59) {
					e.preventDefault();

					$('#cph_Body_btnSearchTagID').focus().click();
				}
			}

			function HandleNumberEnteredSerialNumber(e) {
			    if (e.keyCode == 35 || e.keyCode == 59) {
					e.preventDefault();

					$('#cph_Body_btnSerialNumberSearch').focus().click();
				}
			}

			$('#cph_Body_txtTagID_txtTagID').focus();
		});
	</script>

</asp:Content>