<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DDL_AssetDisposition.ascx.cs" Inherits="CAIRS.Controls.DDL_AssetDisposition" %>
<asp:DropDownList runat="server" ID="ddlAssetDisposition" OnSelectedIndexChanged="SelectedIndexChanged"></asp:DropDownList>
<asp:RequiredFieldValidator runat="server" ID="reqAssetDisposition" CssClass="invalid" ControlToValidate="ddlAssetDisposition" EnableClientScript="true" InitialValue="-1" Display="Dynamic" Text="Required"></asp:RequiredFieldValidator>
        

