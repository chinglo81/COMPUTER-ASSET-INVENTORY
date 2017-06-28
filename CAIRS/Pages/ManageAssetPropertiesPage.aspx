<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageAssetPropertiesPage.aspx.cs" Inherits="CAIRS.Pages.ManageAssetPropertiesPage" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" MaintainScrollPositionOnPostback="true"%>
<%@ MasterType VirtualPath="~/MasterPages/CAIRSMasterPage.Master" %>

<%@ Register Src="~/Controls/TAB_Assignment.ascx" TagName="TAB_Assignment" TagPrefix="TAB" %>
<%@ Register Src="~/Controls/TAB_Attachment.ascx" TagName="TAB_Attachment" TagPrefix="TAB" %>
<%@ Register Src="~/Controls/TAB_Changes.ascx" TagName="TAB_Changes" TagPrefix="TAB" %>
<%@ Register Src="~/Controls/TAB_Comments.ascx" TagName="TAB_Comments" TagPrefix="TAB" %>
<%@ Register Src="~/Controls/TAB_Repair.ascx" TagName="TAB_Repair" TagPrefix="TAB" %>
<%@ Register Src="~/Controls/TAB_Tamper.ascx" TagName="TAB_Tamper" TagPrefix="TAB" %>
<%@ Register Src="~/Controls/TXT_TagID.ascx" TagName="TXT_TagID" TagPrefix="UC" %>
<%@ Register Src="~/Controls/TXT_SerialNumber.ascx" TagName="TXT_SerialNumber" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AssetCondition.ascx" TagName="DDL_AssetCondition" TagPrefix="UC_DDL_AssetCondition" %>
<%@ Register Src="~/Controls/TXT_Date.ascx" TagName="Date" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_Site.ascx" TagName="DDL_Site" TagPrefix="UC_DDL_SITE" %>

<asp:Content ID="Content2" runat="server" contentplaceholderid="head">
</asp:Content>

<asp:Content id="Content1" ContentPlaceHolderid="cph_Body" Runat="server">

    <asp:UpdateProgress ID="updateTransferAssetModalProgress" runat="server" DisplayAfter="1" AssociatedUpdatePanelID="updatePanelManageProperties">
        <ProgressTemplate>
            <div class="divWaiting">
                <img src="../Images/ajax-loader.gif" />
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdatePanel runat="server" ID="updatePanelManageProperties">
        <ContentTemplate>

            <asp:HiddenField runat="server" ID="hdnPageNavigation" />
            <asp:HiddenField runat="server" ID="hdnAssetLawEnforcementID" />

            <!-- Asset Detail Header -->
            <div class="navbar navbar-default navbar-table">
                <span class="navbar-brand pull-left">Asset Details</span>
                <ul class="nav navbar-nav">
                    <li class="dropdown">
                        <a class="dropdown-toggle" role="button" aria-expanded="false" href="#" data-toggle="dropdown">
                            Actions
                            <span class="caret"></span>
                        </a>
                        <ul class="dropdown-menu" role="menu">
                            <li>
                                <asp:LinkButton 
                                    runat="server" 
                                    data-toggle="tooltip"
                                    ID="lnkBtnTransferAsset" 
                                    Security_Level_Disabled="10,20,40"
                                    OnClick="lnkBtnTransferAsset_Click"
                                    Text="Transfer">
                                </asp:LinkButton>
                            </li>
                            <li class="divider"></li>
                            <li>
                                <asp:LinkButton 
                                    runat="server"
                                    data-toggle="tooltip"
                                    ID="lnkBtnEdit"
                                    OnClick="lnkBtnEdit_Click" 
                                    Text="Edit Asset"
                                    Security_Level_Disabled="10,20,30">
                                </asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton 
                                    runat="server" 
                                    data-toggle="tooltip"
                                    ID="lnkBtnDeadPoolAsset"
                                    OnClick="lnkBtnDeadPoolAsset_Click"
                                    Text="Deadpool"
                                    OnClientClick="return confirm('Are you sure you want to Deadpool this asset?')"
                                    Security_Level_Disabled="10,20,30">
                                </asp:LinkButton>
                                <asp:LinkButton 
                                    runat="server"
                                    data-toggle="tooltip"
                                    ID="lnkBtnDeadPoolAssetRevert" 
                                    OnClick="lnkBtnRevertDeadPoolOrEwaste_Click" 
                                    OnClientClick="return confirm('Are you sure you want to Revert Deadpool this asset?')"
                                    Text="Revert Deadpool"
                                    Security_Level_Disabled="10,20,30">
                                </asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton 
                                    runat="server" 
                                    data-toggle="tooltip"
                                    ID="lnkBtnEwaste" 
                                    OnClick="lnkBtnEwaste_Click" 
                                    OnClientClick="return confirm('Are you sure you want to Ewaste this asset?')"
                                    Text="Ewaste"
                                    Security_Level_Disabled="10,20,30">
                                </asp:LinkButton>
                                <asp:LinkButton 
                                    runat="server" 
                                    data-toggle="tooltip"
                                    ID="lnkBtnEwasteRevert" 
                                    OnClick="lnkBtnRevertDeadPoolOrEwaste_Click"
                                    OnClientClick="return confirm('Are you sure you want to Revert Ewaste this asset?')"
                                    Text="Revert Ewaste"
                                    Security_Level_Disabled="10,20,30">
                                </asp:LinkButton>
                            </li>
                            <li>
                                <asp:LinkButton 
                                    runat="server"
                                    data-toggle="tooltip"
                                    ID="lnkBtnLawEnforcement" 
                                    OnClick="lnkBtnLawEnforcement_Click" 
                                    Text="Law Enforcement"
                                    Security_Level_Disabled="10,20,30">
                                </asp:LinkButton>
                            </li>
                        </ul>
                    </li>
                </ul>
            </div>

            <!-- Asset Detail -->
            <asp:Panel runat="server" ID="pnlAssetInfo">
                <div id="divAssetInfo" class="well" runat="server">
                    <div class="row">
                        <div class="col-sm-6">

                            <table class="table table-asset-details">
                                <tr>
                                    <td><strong>Base Type</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="Label1" data_column="Asset_Base_Type_Desc"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Asset Type</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblAssetType" data_column="Asset_Type_Desc"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Tag ID</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblTagID" data_column="Tag_ID"></asp:Label>
                                        <UC:TXT_TagID runat="server" ID="txtTagIDEdit" Visible="false" IsTagIDRequired="true" ValidationGroup="vgEditAsset" />
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Serial #</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblSerialNumber" data_column="Serial_Number"></asp:Label>
                                        <UC:TXT_SerialNumber runat="server" ID="txtSerialNumberEdit" Visible="false" IsSerialNumRequired="true" ValidationGroup="vgEditAsset" />
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Condition</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblCondition" data_column="Asset_Condition_Desc"></asp:Label>
                                        <UC_DDL_AssetCondition:DDL_AssetCondition runat="server" ID="ddlCondition" Visible="false" IsAssetConditionRequired="true" ValidationGroup="vgEditAsset" />
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Disposition</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblDisposition" data_column="Asset_Disposition_Desc"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Assignment Type</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblAssignmentType" data_column="Asset_Assignment_Type_Desc"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Site</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblSite" data_column="Asset_Site_Desc"></asp:Label>
                                    </td>
                                </tr>
                            </table>

                        </div>
                        <div class="col-sm-6">

                            <table class="table table-asset-details">
                                
                                <tr>
                                    <td><strong>Bin #</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblBin" data_column="Bin_Site_Desc"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Purchase Date</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblPurchaseDate" data_column="Date_Purchased"></asp:Label>
                                        <UC:Date 
                                            runat="server" 
                                            ID="txtPurchaseDate" 
                                            Visible="false" 
                                            EnableClientScript="false" 
                                            ValidationGroup="vgEditAsset" 
                                            IsDateRequired="false" 
                                            PlaceHolder="" 
                                            data_column="Date_Purchased"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Lease Term (Days)</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblLeasedTermDays" data_column="Leased_Term_Date_Desc"></asp:Label>
                                        <asp:TextBox 
                                            runat="server" 
                                            ID="txtLeasedTermDays" 
                                            placeholder="Lease Term in Days" 
                                            MaxLength="4" 
                                            CssClass="form-control" 
                                            Visible="false"
                                            data_column="Leased_Term_Days">
                                        </asp:TextBox>

                                        <asp:CompareValidator
						                        ID="CompareValidator1"
						                        Text="Must be numeric."
						                        ErrorMessage="Must be numeric."
						                        CssClass="invalid"
						                        Display="Dynamic"
						                        Operator="DataTypeCheck"
						                        EnableClientScript="true"
						                        ControlToValidate="txtLeasedTermDays"
						                        Type="Integer"
						                        ValidationGroup="vgEditAsset"
						                        runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Warranty Term (Days)</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblWarrantyTermDays" data_column="Warranty_Term_Date_Desc"></asp:Label>
                                        <asp:TextBox 
                                            runat="server" 
                                            ID="txtWarrantyTerm" 
                                            placeholder="Warranty Term in Days" 
                                            MaxLength="4" 
                                            Visible="false"
                                            CssClass="form-control" 
                                            data_column="Warranty_Term_Days">
                                        </asp:TextBox>
                                        <asp:CompareValidator
						                        ID="CompareValidator2"
						                        Text="Must be numeric."
						                        ErrorMessage="Must be numeric."
						                        CssClass="invalid"
						                        Display="Dynamic"
						                        Operator="DataTypeCheck"
						                        EnableClientScript="true"
						                        ControlToValidate="txtWarrantyTerm"
						                        Type="Integer"
						                        ValidationGroup="vgEditAsset"
						                        runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Is Leased</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblIsLeased" data_column="Is_Leased"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Is Active</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblIsActive" data_column="Is_Active_Desc"></asp:Label>
                                        <asp:CheckBox runat="server" ID="chkIsActiveEdit" Visible="false" data_column="Is_Active"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Added By</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblAddedBy" data_column="Added_By_Emp_Desc"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td><strong>Updated By</strong></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblUpdatedBy" data_column="Modified_By_Emp_Desc"></asp:Label>
                                    </td>
                                </tr>
                                <tr runat="server" id="trViewLawEnforcement">
                                    <td colspan="2">

                                        <asp:LinkButton 
                                            runat="server" 
                                            ID="lnkBtnViewLawEnforcement" 
                                            OnClick="lnkBtnViewLawEnforcement_Click" 
                                            Text="View Law Enforcement">
                                        </asp:LinkButton>
                                        
                                    </td>
                                </tr>

                                <tr runat="server" id="trSaveEditAsset" visible="false">
                                    <td style="text-align:right;" colspan="2">
                                        <asp:Button 
                                            CssClass="btn btn-default" 
                                            CausesValidation="true" 
                                            runat="server" 
                                            ID="btnSaveAsset" 
                                            OnClick="btnSaveAsset_Click" 
                                            Security_Level_Disabled="10,20,30" 
                                            OnClientClick="return confirm('Are you sure you want to save these changes?');" 
                                            Text="Save" 
                                            ValidationGroup="vgEditAsset" />

                                        <asp:Button 
                                            CssClass="btn btn-primary" 
                                            CausesValidation="false" 
                                            runat="server" 
                                            ID="btnCancelSave" 
                                            OnClick="btnCancelSave_Click" 
                                            Text="Cancel" />
                                    </td>
                                </tr>
                            </table>

                             <asp:CustomValidator 
                                runat="server" 
                                ID="cvErrorEditAsset"
                                Display="Dynamic"
                                CssClass="invalid"
                                ValidationGroup="vgEditAsset"
                                >
                            </asp:CustomValidator>

                        </div>
                    </div>
                </div>
            </asp:Panel>
    </ContentTemplate>
</asp:UpdatePanel>

    <!-- Asset Tabs -->
    <div class="row">
        <div class="col-xs-12">

            <ul class="nav nav-tabs">
                <li id="liTab_Assignment" runat="server">
                    <asp:LinkButton runat="server" ID="lnkBtnTAB_Assignment" OnClick="lnkBtnTAB_Assignments_Click" Text="Assignments" />
                </li>
                <li id="liTab_Attachment" runat="server">
                    <asp:LinkButton runat="server" ID="lnkBtnTAB_Attachment" OnClick="lnkBtnTAB_Attachment_Click" Text="Attachment" />
                </li>
                <li id="liTab_Comments" runat="server">
                    <asp:LinkButton runat="server" ID="lnkBtnTAB_Comments" OnClick="lnkBtnTAB_Comments_Click" Text="Comments" />
                </li>
                <li id="liTab_Changes" runat="server">
                    <asp:LinkButton runat="server" ID="lnkBtnTAB_Changes" OnClick="lnkBtnTAB_Changes_Click" Text="Changes" />
                </li>
                <li id="liTab_Repair" runat="server">
                    <asp:LinkButton runat="server" ID="lnkBtnTAB_Repair" OnClick="lnkBtnTAB_Repair_Click" Text="Repair" />
                </li>
                <li id="liTab_Tamper" runat="server">
                    <asp:LinkButton runat="server" ID="lnkBtnTAB_Tamper" OnClick="lnkBtnTAB_Tamper_Click" Text="Tamper" />
                </li>
            </ul>

            <div class="tab-content" id="myTabContent">

                <!-- TAB Assignment -->
                <div class="tab-pane" id="divAssignment" runat="server">
                    <TAB:TAB_Assignment ID="tabAssignment" runat="server" />
                </div>

                <!-- TAB Attachment -->
                <div class="tab-pane" id="divAttachment" runat="server">
                    <TAB:TAB_Attachment ID="tabAttachment" runat="server" />
                </div>

                <!-- TAB Comments -->
                <div class="tab-pane" id="divComments" runat="server">
                    <TAB:TAB_Comments ID="tabComments" runat="server" />
                </div>

                <!-- TAB Changes -->
                <div class="tab-pane" id="divChanges" runat="server">
                    <TAB:TAB_Changes ID="tabChanges" runat="server" />
                </div>

                <!-- TAB Repair -->
                <div class="tab-pane" id="divRepair" runat="server">
                    <TAB:TAB_Repair ID="tabRepair" runat="server" />
                </div> 

                <!-- TAB Tampered -->
                <div class="tab-pane" id="divTamper" runat="server">
                    <TAB:TAB_Tamper ID="tabTamper" runat="server" />
                </div> 

            </div>
        </div>
    </div>
        


    <br /><br />

    

    <!-- Asset List Paging -->
    <div class="row text-center">
        <asp:Button ID="btnFirst" Text="&laquo; First" CssClass="btn btn-primary btn-sm" OnClick="btnFirst_Click" runat="server" />
        <asp:Button ID="btnPrevious" Text="&lsaquo; Prev" CssClass="btn btn-primary btn-sm" OnClick="btnPrevious_Click" runat="server" />
        <asp:Button ID="btnReturn" CssClass="btn btn-default btn-sm" Text="Asset List" OnClick="btnReturn_Click" runat="server" />
        <asp:Button ID="btnNext" Text="Next &rsaquo;" CssClass="btn btn-primary btn-sm" OnClick="btnNext_Click" runat="server" />
        <asp:Button ID="btnLast" Text="Last &raquo;" CssClass="btn btn-primary btn-sm" OnClick="btnLast_Click" runat="server" />   
    </div>
   
    
    <!-- Bootstrap Modal Dialog -->
    <div class="modal fade" id="confirmPopup" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <asp:UpdatePanel ID="confirmModal" ChildrenAsTriggers="false" UpdateMode="Conditional" runat="server">
                <ContentTemplate>
                    <div id="Div1" class="panel panel-info" runat="server">
                        <div class="panel-heading">
                            <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                            <h4 class="modal-title">
                                <asp:Label ID="confirmTitle" Text="" runat="server"></asp:Label></h4>
                        </div>
                        <div class="panel-body">
                            <asp:Label ID="confirmBody" Text="" runat="server"></asp:Label>
                        </div>

                        <div class="modal-footer">
                            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                            <asp:Button ID="btnSubmit" Text="Confirm & Return" runat="server" CssClass="btn btn-default" OnClick="btnSubmit_Click" />
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <!-- Bootstrap Modal Dialog -->
    <div class="modal fade" id="TransferAssetModal" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <asp:UpdatePanel ID="updatePanelTransferModal" UpdateMode="Conditional" runat="server">
                <ContentTemplate>
                    <div id="Div2" class="panel panel-info" runat="server">
                        <div class="panel-heading">
                            <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                            <h4 class="modal-title">
                                <asp:Label ID="Label2" Text="Transfer Asset" runat="server"></asp:Label></h4>
                        </div>
                        <div class="panel-body">
                            <UC_DDL_SITE:DDL_Site IsSiteRequired="true" ID="ddlSiteTransfer" ValidationGroup="vgTransferAsset" runat="server" EnableClientScript="true" />
                        </div>

                        <div class="modal-footer">
                            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                            <asp:Button 
                                ID="btnSaveTransfer" 
                                Text="Save" 
                                ValidationGroup="vgTransferAsset" 
                                runat="server"
                                OnClientClick="ConfirmTransferAsset()"
                                CssClass="btn btn-default" 
                                OnClick="btnSaveTransfer_Click" />
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <!-- Bootstrap Modal Dialog -->
    <div class="modal fade" id="divLawEnforcementManagePropertiesModal" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <asp:UpdatePanel ID="updatePanelLawEnforcementManageProperties" UpdateMode="Conditional" runat="server">
                <ContentTemplate>
                    <div id="Div3" class="panel panel-info" runat="server">
                        <div class="panel-heading">
                            <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                            <h4 class="modal-title">
                                <asp:Label ID="Label3" Text="Law Enforcement" runat="server"></asp:Label></h4>
                        </div>
                        <div class="panel-body" id="divLawEnforcementInfo" runat="server">
                            <div class="table-responsive modal-body">

                            <table class="table table-form table-condensed table-valign-middle">
                                <tr>
                                    <td>
                                        <strong>
                                            Law Enforcement Agency
                                        </strong>
                                    </td>
                                    <td>
                                        <asp:DropDownList runat="server" ID="ddlLawEnforcementAgency" CssClass="form-control" data_column="Law_Enforcement_Agency_ID"></asp:DropDownList>
                                        
                                        <asp:RequiredFieldValidator
                                            ID="reqDdlLawEnforcement"
                                            runat="server"
                                            InitialValue="-1"
                                            ControlToValidate="ddlLawEnforcementAgency"
                                            CssClass="invalid"
                                            ErrorMessage="Required"
                                            Text="Required"
                                            ValidationGroup="vgLawEnforcement"
                                        />

                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>
                                            Officer First Name
                                        </strong>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtOfficerFirstName" CssClass="form-control" MaxLength="100" data_column="Officer_First_Name"></asp:TextBox>

                                        <asp:RequiredFieldValidator
                                            ID="reqOfficerFirstName"
                                            runat="server"
                                            ControlToValidate="txtOfficerFirstName"
                                            CssClass="invalid"
                                            ErrorMessage="Required"
                                            Text="Required"
                                            ValidationGroup="vgLawEnforcement"
                                        />

                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>
                                            Officer Last Name
                                        </strong>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtOfficerLastName" CssClass="form-control" MaxLength="100" data_column="Officer_Last_Name"></asp:TextBox>

                                        <asp:RequiredFieldValidator
                                            ID="reqOfficerLastName"
                                            runat="server"
                                            ControlToValidate="txtOfficerLastName"
                                            CssClass="invalid"
                                            ErrorMessage="Required"
                                            Text="Required"
                                            ValidationGroup="vgLawEnforcement"
                                        />

                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>
                                            Case Number
                                        </strong>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtCaseNumber" CssClass="form-control" MaxLength="100" data_column="Case_Number"></asp:TextBox>

                                        <asp:RequiredFieldValidator
                                            ID="reqCaseNumber"
                                            runat="server"
                                            ControlToValidate="txtCaseNumber"
                                            CssClass="invalid"
                                            ErrorMessage="Required"
                                            Text="Required"
                                            ValidationGroup="vgLawEnforcement"
                                        />

                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>
                                            Comment
                                        </strong>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtComment" CssClass="form-control" TextMode="MultiLine" data_column="Comment"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>
                                            Date Pickup
                                        </strong>
                                    </td>
                                    <td>
                                         <UC:Date 
                                            runat="server" 
                                            ID="txtDatePickup" 
                                            EnableClientScript="false" 
                                            ValidationGroup="vgLawEnforcement" 
                                            IsDateRequired="true" 
                                            PlaceHolder="" 
                                            data_column="Date_Picked_Up_Formatted"
                                            />
                                    </td>
                                </tr>
                                <tr runat="server" id="trDateReturned">
                                    <td>
                                        <strong>
                                            Date Returned
                                        </strong>
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="lblDateReturned" data_column="Date_Returned_Formatted"></asp:Label>
                                    </td>
                                </tr>
                            </table>

                            </div>
                        </div>

                        <div class="modal-footer">
                            <button 
                                class="btn" 
                                data-dismiss="modal" 
                                aria-hidden="true">
                                Close
                            </button>

                            <asp:Button 
                                ID="btnSaveLawEnforcement" 
                                Text="Save" 
                                ValidationGroup="vgLawEnforcement" 
                                runat="server"
                                CssClass="btn btn-default" 
                                OnClick="btnSaveLawEnforcement_Click" 
                            />

                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <!-- Bootstrap Modal Dialog -->
	<div class="modal fade" id="divViewLawEnforcement"  role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<asp:UpdatePanel runat="server" ID="updatePanelViewLawEnforcement">
			<ContentTemplate>
				<div class="modal-dialog modal-lg" role="document"> 
					<div id="divModalTitle" class="panel panel-info" runat="server">

						<div class="panel-heading">

							<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>

							<h4 class="modal-title">
								<asp:Label ID="lblLawEnforcementTitle" runat="server" Text="Law Enforcement" />
							</h4>

						</div>

						<div class="panel-body">

					    	<asp:DataGrid 
								ID="dgLawEnforcement" 
								CssClass="table table-hover table-striped table-border"
								AutoGenerateColumns="false"
                                OnItemDataBound="dgLawEnforcement_ItemDataBound"
								GridLines="None"
								UseAccessibleHeader="true"
								runat="server" >

								<Columns>

									<asp:TemplateColumn HeaderText="Agency">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Law_Enforcement_Agency_Name")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Officer">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Officer_Full_Name")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Case #">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Case_Number")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Comment">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Comment_Short")%>

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn HeaderText="Pickup Date">
										<ItemTemplate>

											<%# DataBinder.Eval(Container.DataItem, "Date_Picked_Up_Formatted")%>

										</ItemTemplate>
									</asp:TemplateColumn>

                                    <asp:TemplateColumn HeaderText="Return Date">
										<ItemTemplate>

                                            <asp:Label runat="server" ID="lblDateReturned" Text='<%# DataBinder.Eval(Container.DataItem, "Date_Returned_Formatted")%>' Visible='<%# IsAssetReturned(Container.DataItem)%>'></asp:Label>

                                            <asp:Button
                                                Visible='<%# !IsAssetReturned(Container.DataItem)%>'
						                        ID="btnMarkAssetLawEnforcementReturn"
                                                Text="Mark Return"
                                                CssClass="btn btn-default btn-xs"
						                        OnClick="btnMarkAssetLawEnforcementReturn_Click"
						                        Asset_Law_Enforcement_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                                CausesValidation="false"
                                                Security_Level_Disabled="10,20,30"
                                                Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
						                        runat="server" />

										</ItemTemplate>
									</asp:TemplateColumn>

									<asp:TemplateColumn>
										<ItemTemplate>

											<asp:Button
						                        ID="btnViewAssetLawEnforcementDetails"
                                                Text="Details"
                                                CssClass="btn btn-primary btn-xs"
						                        OnClick="btnViewAssetLawEnforcementDetails_Click"
						                        Asset_Law_Enforcement_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                                CausesValidation="false"
						                        runat="server" />

					                        <asp:Button
                                                Visible='<%# !IsAssetReturned(Container.DataItem)%>'
						                        ID="btnDeleteAssetLawEnforcement"
                                                Text="Delete"
                                                CssClass="btn btn-default btn-xs"
						                        OnClick="btnDeleteAssetLawEnforcement_Click"
                                                OnClientClick="return confirm('Are you sure you want to delete this?')"
						                        Asset_Law_Enforcement_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                                CausesValidation="false"
                                                Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
                                                Security_Level_Disabled="10,20,30"
						                        runat="server" />

										</ItemTemplate>
									</asp:TemplateColumn>

								</Columns>
							</asp:DataGrid>

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

        $(document).on('hide.bs.modal', '#divLawEnforcementManagePropertiesModal', function () {
            OpenViewLawEnforcementModal();
        });


        function OpenViewLawEnforcementModal() {
            asset_law_enforcement_id = $('#' + '<%=hdnAssetLawEnforcementID.ClientID %>').val();
            if(asset_law_enforcement_id != "-1"){
                ShowModal("divViewLawEnforcement");
            }
        }
    </script>


</asp:Content>

