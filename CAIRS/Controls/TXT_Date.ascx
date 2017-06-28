﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TXT_Date.ascx.cs" Inherits="CAIRS.Controls.TXT_Date" %>
<asp:TextBox runat="server" ID="txtDate" CssClass="form-control"></asp:TextBox>
<asp:RequiredFieldValidator runat="server" ID="reqDate" CssClass="invalid" ControlToValidate="txtDate" EnableClientScript="false" Display="Dynamic" Text="Required"></asp:RequiredFieldValidator>
<asp:CompareValidator runat="server" ID="cvDate" CssClass="invalid" ControlToValidate="txtDate" EnableClientScript="false" Display="Dynamic" Text="Invalid Date" Operator="DataTypeCheck" Type="Date">Invalid Date</asp:CompareValidator>