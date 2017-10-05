<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomePage.aspx.cs" Inherits="CAIRS.Pages.HomePage" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master"%>
<%@ MasterType VirtualPath="~/MasterPages/CAIRSMasterPage.Master" %>

<asp:Content id="Content1" ContentPlaceHolderid="cph_Body" Runat="server">

	<div class="row nav-homepage">
		<div class="col-xs-6 col-sm-4">
            
			<a href="../Pages/AddAssetPage.aspx" class="btn btn-default btn-lg col-xs-12">Add Asset</a>
			<a href="../Pages/CheckOutAssetPage.aspx" class="btn btn-default btn-lg col-xs-12">Asset Checkout</a>
			<a href="../Pages/AssetSearchPage.aspx" class="btn btn-default btn-lg col-xs-12">Asset Search</a>
            <a href="../Pages/AssetFollowUpPage.aspx" class="btn btn-default btn-lg col-xs-12">Asset Follow-up</a>
		
        </div>
		<div class="col-xs-6 col-sm-4">

			<a href="../Pages/AddBinPage.aspx" class="btn btn-default btn-lg col-xs-12">Bin Management</a>
			<a href="../Pages/CheckInAssetPage.aspx" class="btn btn-default btn-lg col-xs-12">Asset Check-in</a>
			<a href="../Pages/StudentSearchPage.aspx" class="btn btn-default btn-lg col-xs-12">Student Asset History</a>
            <a href="../Pages/AssetReportPage.aspx" class="btn btn-default btn-lg col-xs-12">Reports</a>
		</div>
        
	</div>

</asp:Content>