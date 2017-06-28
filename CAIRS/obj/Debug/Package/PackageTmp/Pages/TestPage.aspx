<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" AutoEventWireup="true" CodeBehind="TestPage.aspx.cs" Inherits="CAIRS.Pages.TestPage" EnableEventValidation="false" %>

<%@ Register Src="~/Controls/TXT_Date.ascx" TagName="Date" TagPrefix="UC" %>
<%@ Register Src="~/Controls/LOOKUP_Employee.ascx" TagName="Employee_lookup" TagPrefix="UC" %>
<%@ Register Src="~/Controls/MULTI_SELECT_AssetCondition.ascx" TagName="AssetCondition" TagPrefix="MULTI" %>
<%@ Register Src="~/Controls/MULTI_SELECT_AssetDisposition.ascx" TagName="AssetDisposition" TagPrefix="MULTI" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style type="text/css">
        .tbl {
            border: 1px solid black;
            padding: 5px;
        }

        .tbl th {
            padding: 5px;
            border: thin solid black;
            background-color: orangered;
            color: lightgoldenrodyellow;
        }

        .tbl td {
            padding: 5px;
            border: 1px solid black;
            background-color: HighlightText;
        }

        .center_text {
            text-align:center;
        }
	                                       
    </style>
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="cph_Body" runat="server">
    <UC:Date runat="server" ID="txtTestDate" ValidationGroup="vgTest" IsDateRequired="true" PlaceHolder="Ching is da bomb"/>
    <UC:Date runat="server" ID="Date1" ValidationGroup="vgTest" IsDateRequired="true"  PlaceHolder="Ching is da bomb2"/>
    <asp:Button runat="server" ID="btnTest" Text="test" ValidationGroup="vgTest" />


    <div>
        <UC:Employee_lookup runat="server" ID="txtEmployeeLookup" />
        <UC:Employee_lookup runat="server" ID="Employee_lookup1" />
    </div>

    <MULTI:AssetCondition runat="server" ID="multi_assetCondition"></MULTI:AssetCondition>
    <MULTI:AssetDisposition runat="server" ID="MULTI_DDL_AssetDisposition"></MULTI:AssetDisposition>

    <asp:Button runat="server" ID="btn"  Text="test" OnClientClick="HandleMath();" />

    <input type="text" onkeypress="HandleNumberEntered(event);" /> 

    <asp:DataGrid 
		runat="server" 
		ID="dgTest" 
		CssClass="table table-hover table-striped table-border" 
		AutoGenerateColumns="true">
	</asp:DataGrid>



    <%-- <!--**************************************************** CHECK IN  MODAL *************************************************-->
	<div class="modal fade" id="popupCheckInUnidentifiedAsset" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="panel panel-info" runat="server" id="modalTitle">

				<div class="panel-heading">

					<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>

					<h4 class="modal-title">
						Check-in Unidentified Asset

                        <asp:Label runat="server" ID="lblModalCheckInTitle"></asp:Label>
					</h4>

				</div>

				<div runat="server" id="divStudentTransactionDetails" class="panel-body">

					<div class="alert alert-info" runat="server" id="divImportantAffixSticker">
						<h4>IMPORTANT!!!</h4>
						Please affix sticker with Student ID and Name. You are checking in an item without a Tag ID.
					</div>

                    <div class="form-group" runat="server" id="divAssetStoredSite">
                        Asset Stored Site <asp:Label runat="server" ID="lblAsset_Stored_Site"></asp:Label>
                    </div>

					<div class="form-group">
						<UC:DDL_AssetDisposition runat="server" ID="ddlDisposition_CheckIn" IsAssetDispositionRequired="true" ValidationGroup="vgCheckinSubmit" />
					</div>

					<div class="form-group" runat="server" id="divAssetCondition_CheckIn">
						<UC:DDL_AssetCondition runat="server" ID="ddlAssetCondition_CheckIn" IsAssetConditionRequired="true" ValidationGroup="vgCheckinSubmit" />
					</div>

					<div class="form-group" runat="server" id="divBin_CheckIn">
						<UC:DDL_Bin runat="server" ID="ddlBin_CheckIn" IsBinRequired="true" ValidationGroup="vgCheckinSubmit"/>
					</div>

					<div class="form-group" runat="server" id="divInteractionType_CheckIn">
						<UC:DDL_InteractionType runat="server" ID="ddlInteractionType_CheckIn" IsInteractionTypeRequired="true" ValidationGroup="vgCheckinSubmit"/>
					</div>

					<div class="form-group">
						<asp:TextBox runat="server" ID="txtInteractionComments_CheckIn" CssClass="form-control" Placeholder="Comment" TextMode="MultiLine" />
					</div>

					<UC:Add_Attachment runat="server" ID="uc_AddAttachment_CheckIn" />

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

    <!--**************************************************** CHECK IN  MODAL *************************************************-->








    <!--BackUp-->

    <!-- Bootstrap Modal Dialog -->
	<div class="modal fade" id="popupCheckInUnidentifiedAsset" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="panel panel-info" runat="server" id="Div1">

				<div class="panel-heading">

					<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>

					<h4 class="modal-title">
						Check-in Unidentified Asset
					</h4>

				</div>

				<div runat="server" id="div2" class="panel-body">

					<div class="alert alert-info">
						<h4>IMPORTANT!!!</h4>
						Please affix sticker with Student ID and Name. You are checking in an item without a Tag ID.
					</div>

					<div class="form-group">
						<UC:DDL_AssetDisposition runat="server" ID="ddlDisposition" IsAssetDispositionRequired="true" ValidationGroup="vgCheckinSubmitUnidentify" />
					</div>

					<div class="form-group">
						<UC:DDL_AssetCondition runat="server" ID="ddlAssetCondition" IsAssetConditionRequired="true" ValidationGroup="vgCheckinSubmitUnidentify" />
					</div>

					<div class="form-group">
						<UC:DDL_Bin runat="server" ID="ddlBin" IsBinRequired="true" ValidationGroup="vgCheckinSubmitUnidentify"/>
					</div>

					<div class="form-group">
						<UC:DDL_InteractionType runat="server" ID="ddlInteractionType" IsInteractionTypeRequired="true" ValidationGroup="vgCheckinSubmitUnidentify"/>
					</div>

					<div class="form-group">
						<asp:TextBox runat="server" ID="txtInteractionComments" CssClass="form-control" Placeholder="Comment" TextMode="MultiLine" />
					</div>

					<UC:Add_Attachment runat="server" ID="uc_AddAttachment_Unidentified" />

				</div>

				<div class="modal-footer">

					<asp:Button 
						ID="btnSubmitCheckInUnidentified" 
						Text="Submit Check-in" 
						CssClass="btn btn-default" 
						OnClick="btnSubmitCheckInUnidentified_Click" 
						OnClientClick="return confirm('Are you sure you want to check-in this asset?')"
						CausesValidation="true" 
						ValidationGroup="vgCheckinSubmitUnidentify" 
						runat="server" />

					<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

				</div>

			</div>
		</div>
	</div>

	<!-- Bootstrap Modal Dialog -->
	<div class="modal" id="popupStudentCheckIn" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="panel panel-info" runat="server" id="Div3">

				<div class="panel-heading">

					<button type="button" class="close" data-dismiss="modal">
						<span class="material-icons">cancel</span>
					</button>

					<h4 class="modal-title">
                        <asp:Label runat="server" ID="lblCheckInTitle"></asp:Label>
					</h4>

				</div>

				<div runat="server" id="divStudentCheckIn" class="panel-body">

					<div class="form-group">

						<UC:DDL_AssetDisposition runat="server" ID="ddlAssetDisposition_CheckIn" IsAssetDispositionRequired="true" ValidationGroup="vgCheckinSubmit" />

					</div>
					<div class="form-group">

						<UC:DDL_AssetCondition runat="server" ID="DDL_AssetCondition1" IsAssetConditionRequired="true" ValidationGroup="vgCheckinSubmit" />

					</div>
					<div class="form-group">

						<UC:DDL_Bin runat="server" ID="DDL_Bin1" IsBinRequired="true" ValidationGroup="vgCheckinSubmit"/>

					</div>
					<div class="form-group">

						<asp:TextBox ID="txtComments_CheckIn" CssClass="form-control" Placeholder="Comment" TextMode="MultiLine" runat="server" />

					</div>

					<div>

						<UC:Add_Attachment runat="server" ID="uc_Attachment_CheckIn" />

					</div>
				</div>

				<div class="modal-footer">

					<asp:Button 
						ID="Button1" 
						Text="Submit Check-In" 
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

	<!-- Bootstrap Modal Dialog -->
	<div class="modal fade" id="popupFlagResearch" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="panel panel-info" runat="server" id="Div4">

				<div class="panel-heading">

					<button type="button" class="close" data-dismiss="modal">
						<span class="material-icons">cancel</span>
					</button>

					<h4 class="modal-title">
						Research Check-in
					</h4>

				</div>

				<div runat="server" id="divResearchAssetInfo" class="panel-body">

					<table class="table">
						<tr runat="server" id="trAsset_Stored_Location" visible="false">
							<td class="col-xs-4"><strong>Asset Stored Site</strong></td>
							<td>
								<asp:Label runat="server" ID="Label1"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Disposition</strong></td>
							<td>
								<UC:DDL_AssetDisposition runat="server" ID="ddlAssetDisposition_Research" IsAssetDispositionRequired="true" ValidationGroup="vgResearchSubmit" />
							</td>
						</tr>
						<tr>
							<td><strong>Bin</strong></td>
							<td>
								<UC:DDL_Bin runat="server" ID="ddlBin_Research" IsBinRequired="true" ValidationGroup="vgResearchSubmit"/>
							</td>
						</tr>
						<tr>
							<td><strong>Comment</strong></td>
							<td>
								<asp:TextBox ID="txtComment_Research" CssClass="form-control" TextMode="MultiLine" runat="server" />
							</td>
						</tr>
					</table>

				</div>

				<div class="modal-footer">

					<asp:Button 
						ID="btnSubmitResearch" 
						CausesValidation="true" 
						CssClass="btn btn-default" 
						ValidationGroup="vgResearchSubmit" 
						OnClick="btnSubmitResearch_Click" 
						Text="Submit Research Check-in" 
						OnClientClick="return confirm('Are you sure you want to flag this asset as research?')" 
						runat="server" />

					<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

				</div>

			</div>
		</div>
	</div>


    <!--BackUp-->









--%>



    <script>
        function HandleNumberEntered(e) {
            alert(e.keyCode);
        }

        function HandleMath() {
            var sNum1 = "29.81";
            var sNum2 = "1.5";

            var num1 = parseFloat(sNum1);
            var num2 = parseFloat(sNum2);

            var calculate = Math.round(num1 * num2 * 100) / 100;

            var total = num1 * num2;

            alert(total);
            alert(calculate);
        }
    </script>
</asp:Content>
