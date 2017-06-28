<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="menu.ascx.cs" Inherits="CAIRS.Pages._partials.menu" %>

<nav class="nav-drawer" id="global-menu">

	<div class="nav-drawer-header">Menu</div>

	<ul class="nav-drawer-menu" runat="server">
		<li><asp:HyperLink runat="server" ID="hypLinkAddAsset" Security_Level_Disabled="10,20" NavigateUrl="~/Pages/AddAssetPage.aspx">Add Asset</asp:HyperLink></li>
		<li><asp:HyperLink runat="server" ID="hypCheckOutAsset" Security_Level_Disabled="10,30" NavigateUrl="~/Pages/CheckOutAssetPage.aspx">Asset Checkout</asp:HyperLink></li>
		<li><asp:HyperLink runat="server" ID="hypCheckInAsset" Security_Level_Disabled="10,20,30" NavigateUrl="~/Pages/CheckInAssetPage.aspx">Asset Check-in</asp:HyperLink></li>
		<li><asp:HyperLink runat="server" ID="hypLinkAddBin" Security_Level_Disabled="10" NavigateUrl="~/Pages/AddBinPage.aspx">Bin Management</asp:HyperLink></li>
		<li><asp:HyperLink runat="server" ID="hypSearchAsset" NavigateUrl="~/Pages/AssetSearchPage.aspx">Asset Search</asp:HyperLink></li>
        <li><asp:HyperLink runat="server" ID="hypAssetFollowup" Security_Level_Disabled="10,30" NavigateUrl="~/Pages/AssetFollowUpPage.aspx">Asset Follow-up</asp:HyperLink></li>
		<li><asp:HyperLink runat="server" ID="hypLinkStudentSearch" NavigateUrl="~/Pages/StudentSearchPage.aspx">Student Asset History</asp:HyperLink></li>
        <li><asp:HyperLink runat="server" ID="hypLinkReports" NavigateUrl="~/Pages/AssetReportPage.aspx">Reports</asp:HyperLink></li>
	</ul>

	<%--Barcode Scanner Documentation--%>
	<div class="nav-drawer-header">Barcode Scanner</div>

	<ul class="nav-drawer-menu">
        <li><asp:LinkButton runat="server" ID="lnkBtnUserGuide" Text="User Guide" OnClick="lnkBtnUserGuide_Click"></asp:LinkButton></li>
		<li><asp:LinkButton runat="server" ID="lnkBtnDocumentProgramBarcode" Text="How-to Program" OnClick="lnkBtnDocumentProgramBarcode_Click"></asp:LinkButton></li>
		<li><asp:LinkButton runat="server" ID="lnkBtnDocumentBarcodeManual" Text="User Manual" OnClick="lnkBtnDocumentBarcodeManual_Click"></asp:LinkButton></li>
	</ul>

</nav>
<div class="nav-drawer-mask"></div>