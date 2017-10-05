<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DDL_AttachmentType.ascx.cs" Inherits="CAIRS.Controls.DDL_AttachmentType" %>
<asp:DropDownList runat="server" ID="ddlAttachmentType" OnSelectedIndexChanged="SelectedIndexChanged" data_column="Attachment_Type_ID"></asp:DropDownList>
<asp:RequiredFieldValidator runat="server" ID="reqAttachmentType" ControlToValidate="ddlAttachmentType" CssClass="invalid" InitialValue="-1" Display="Dynamic" Text="Required"></asp:RequiredFieldValidator>
   