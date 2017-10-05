<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" AutoEventWireup="true" CodeBehind="AssetReportPage.aspx.cs" Inherits="CAIRS.Pages.AssetReportPage" %>

<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>



<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph_Body" runat="server">
    <asp:UpdateProgress ID="updateAssetSearchGridProgress" runat="server" DisplayAfter="1" AssociatedUpdatePanelID="updatePanelReports">
        <ProgressTemplate>
            <div class="divWaiting">
                <img src="../Images/ajax-loader.gif"  />
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdatePanel runat="server" ID="updatePanelReports">
        <ContentTemplate>

        <h1>Reports</h1>     

        <asp:DropDownList 
            runat="server" 
            ID="ddlReports" 
            AutoPostBack="true"
            Width="250px"
            CssClass="form-control" 
            OnSelectedIndexChanged="ddlReports_SelectedIndexChanged">
        </asp:DropDownList>

        <hr />

        <asp:Label runat="server" ID="lblPleaseSelectReport"></asp:Label>

        <rsweb:ReportViewer
            ID="SSRS_ReportViewer" 
            runat="server" 
            Font-Names="Verdana" 
            Font-Size="11pt"
            Height="1056px" 
            ProcessingMode="Remote" 
            Width="756px" 
            BorderStyle="None" 
            ZoomPercent="100"
            AsyncRendering="false" 
            SizeToReportContent="true" 
            ZoomMode="FullPage">
            <serverreport reportserverurl="" />
        </rsweb:ReportViewer>

        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
