<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddAssetUploadPage.aspx.cs" Inherits="CAIRS.Pages.AddAssetUploadPage" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" MaintainScrollPositionOnPostback="true" %>
<%@ MasterType VirtualPath="~/MasterPages/CAIRSMasterPage.Master" %>

<asp:Content id="Content1" ContentPlaceHolderid="cph_Body" Runat="server">
    <div class="h1" runat="server" id="divAddAssetHeader">
        Add Asset
    </div>
    <hr />
    <div>
        <asp:RadioButtonList runat="server" ID="chkLstAddType" CssClass="radio" AutoPostBack="true" OnSelectedIndexChanged="chkLstAddType_SelectedIndexChanged" RepeatDirection="Vertical">
            <asp:ListItem Value="SCAN" Text="Scan Asset"></asp:ListItem>
            <asp:ListItem Value="UPLOAD" Text="Upload File" Selected="True"></asp:ListItem>
        </asp:RadioButtonList>
    </div>
    
    <div>
        <asp:FileUpload ID="FileUploadAddAsset" runat="server" Width="500px" />
    </div>

    <div style="padding:10px;">
        <asp:Button runat="server" ID="btnUpload" CssClass="btn btn-primary" Text="Upload" OnClick="btnUpload_Click"/>
    </div>
</asp:Content>
