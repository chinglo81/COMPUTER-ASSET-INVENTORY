<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TXT_TagID.ascx.cs" Inherits="CAIRS.Controls.TXT_TagID" %>

<asp:TextBox ID="txtTagID" MaxLength="100" CssClass="form-control" data_column="Tag_ID" placeholder="Tag ID" runat="server" />

<asp:RequiredFieldValidator ID="reqTagID" CssClass="invalid" ControlToValidate="txtTagID" EnableClientScript="false" Display="Dynamic" Text="Required" runat="server" />