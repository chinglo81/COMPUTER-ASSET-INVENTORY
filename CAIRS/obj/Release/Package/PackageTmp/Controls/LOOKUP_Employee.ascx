<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="LOOKUP_Employee.ascx.cs" Inherits="CAIRS.Controls.LOOKUP_Employee" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajax" %>

<asp:HiddenField runat="server" ID="hdnSelectedEmployee" />
<asp:HiddenField runat="server" ID="hdnSelectedEmployeeDesc" />
<table>
    <tr id="trSearchType" runat="server">
        <td colspan="2">
            <asp:RadioButtonList runat="server" ID="radList" CssClass="spaced" RepeatDirection="Horizontal"> 
                <asp:ListItem Text="All" Value="1"></asp:ListItem>
                <asp:ListItem Selected="True" Text="Active" Value="2"></asp:ListItem>
                <asp:ListItem Text="Inactive" Value="3"></asp:ListItem>
            </asp:RadioButtonList>
        </td>
    </tr>
    <tr id="trSearchEmployee" runat="server">
        <td style="vertical-align:top">
            <asp:TextBox runat="server" ID="txtEmployeeLookup" CssClass="form-control ui-autocomplete-input" Width="400px" placeholder="Employee ID or Employee Last, First Name" onkeyup="SetContextKey()"></asp:TextBox>
            <ajax:AutoCompleteExtender
                runat="server"
                ID="acxEmployeeLookup"
                TargetControlID="txtEmployeeLookup"
                CompletionInterval="100" 
                EnableCaching="false"
                ServiceMethod="GetEmployeeName"
                UseContextKey="false"
                FirstRowSelected="true"
                CompletionListHighlightedItemCssClass=""
                ShowOnlyCurrentWordInCompletionListItem="true"
                ServicePath="../Controls/WebServiceGetEmployeeInfo.asmx"
                MinimumPrefixLength="2"/>
            <asp:LinkButton Runat="server" ID="lnkModalReturn" OnClick="lnkModalReturn_Click"></asp:LinkButton>
        </td>
        <td>
            <asp:Button runat="server" ID="btnSearch" CssClass="btn" Text="Search" OnClick="btnSearch_Click"/>
        </td>
    </tr>
    <tr id="trEmployeeSelected" runat="server">
        <td>
            <asp:Label runat="server" ID="lblSelectedEmployee"></asp:Label>
            <asp:Button runat="server" ID="btnChangeEmployee" Text ="Lookup Employee" OnClick="btnChangeEmployee_Click" CssClass="btn" UseSubmitBehavior="false" />
        </td>
    </tr>
</table>

<div>
    <asp:Label runat="server" ID="lblResults" CssClass="invalid"></asp:Label>
    <asp:RequiredFieldValidator runat="server" ID="reqEmployeeId" CssClass="invalid" ControlToValidate="txtEmployeeLookup" EnableClientScript="false" Display="Dynamic" Text="Required"></asp:RequiredFieldValidator>
    <asp:RequiredFieldValidator runat="server" ID="reqEmployeeLook" CssClass="invalid" ControlToValidate="txtEmployeeLookup" EnableClientScript="false" Display="Dynamic" Text="Required"></asp:RequiredFieldValidator>
</div>
