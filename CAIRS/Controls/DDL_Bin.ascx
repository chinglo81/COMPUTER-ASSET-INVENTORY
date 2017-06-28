<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DDL_Bin.ascx.cs" Inherits="CAIRS.Controls.DDL_Bin" %>

<asp:DropDownList runat="server" ID="ddlBin" OnSelectedIndexChanged="SelectedIndexChanged" data_column="Bin_ID" />

<asp:RequiredFieldValidator runat="server" ID="reqBin" ControlToValidate="ddlBin" Display="Dynamic" CssClass="invalid" InitialValue="-1" Text="Required" EnableClientScript="true" />