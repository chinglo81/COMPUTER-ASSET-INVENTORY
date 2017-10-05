<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TXT_SerialNumber.ascx.cs" Inherits="CAIRS.Controls.TXT_SerialNumber" %>

<asp:TextBox runat="server" ID="txtSerialNumber" CssClass="form-control" MaxLength="100" data_column="Serial_Number" />

<asp:RequiredFieldValidator runat="server" ID="reqSerialNum" CssClass="invalid" ControlToValidate="txtSerialNumber" EnableClientScript="false" Display="Dynamic" Text="Required" />
