<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DDL_AssetBaseType.ascx.cs" Inherits="CAIRS.Controls.DDL_AssetBaseType" %>
<asp:DropDownList runat="server" ID="ddlAssetBaseType" OnSelectedIndexChanged="SelectedIndexChanged"></asp:DropDownList>
<asp:RequiredFieldValidator runat="server" ID="reqAssetBaseType" ControlToValidate="ddlAssetBaseType" CssClass="invalid" InitialValue="-1" Display="Dynamic" EnableClientScript="true" Text="Required"></asp:RequiredFieldValidator>
   