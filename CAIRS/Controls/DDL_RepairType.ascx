<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DDL_RepairType.ascx.cs" Inherits="CAIRS.Controls.DDL_RepairType" %>
<asp:DropDownList runat="server" ID="ddlRepairType" OnSelectedIndexChanged="SelectedIndexChanged" data_column="Repair_Type_ID"></asp:DropDownList>
<asp:RequiredFieldValidator runat="server" ID="reqRepairType" ControlToValidate="ddlRepairType" CssClass="invalid" InitialValue="-1" Display="Dynamic" EnableClientScript="true" Text="Required"></asp:RequiredFieldValidator>
   