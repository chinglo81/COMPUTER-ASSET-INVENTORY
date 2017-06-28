<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DDL_InteractionType.ascx.cs" Inherits="CAIRS.Controls.DDL_InteractionType" %>
<asp:DropDownList runat="server" ID="ddlInteractionType" OnSelectedIndexChanged="SelectedIndexChanged"></asp:DropDownList>
<asp:RequiredFieldValidator runat="server" ID="reqInteractionType" ControlToValidate="ddlInteractionType" CssClass="invalid" InitialValue="-1" Display="Dynamic" EnableClientScript="true" Text="Required"></asp:RequiredFieldValidator>
