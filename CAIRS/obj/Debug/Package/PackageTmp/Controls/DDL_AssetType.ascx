<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DDL_AssetType.ascx.cs" Inherits="CAIRS.Controls.DDL_AssetType" %>
<asp:DropDownList runat="server" ID="ddlAssetType" OnSelectedIndexChanged="SelectedIndexChanged"></asp:DropDownList>
<asp:RequiredFieldValidator runat="server" ID="reqAssetType" ControlToValidate="ddlAssetType" CssClass="invalid" InitialValue="-1" Display="Dynamic" EnableClientScript="true" Text="Required"></asp:RequiredFieldValidator>
   