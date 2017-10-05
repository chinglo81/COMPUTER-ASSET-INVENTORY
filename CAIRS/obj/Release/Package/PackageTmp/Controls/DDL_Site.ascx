<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DDL_Site.ascx.cs" Inherits="CAIRS.DDL_Site" %>


<asp:DropDownList runat="server" ID="ddlSite" CssClass="form-control" OnSelectedIndexChanged="SelectedIndexChanged" data_column="Site_ID"></asp:DropDownList>

<small>
    <strong>
        <asp:RequiredFieldValidator runat="server" ID="reqSite" ControlToValidate="ddlSite" InitialValue="-1" Text="Required" CssClass="invalid" Display="Dynamic" />
    </strong>
</small>