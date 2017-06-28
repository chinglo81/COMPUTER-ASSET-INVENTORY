﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DDL_AssetCondition.ascx.cs" Inherits="CAIRS.Controls.DDL_AssetCondition" %>
<asp:DropDownList runat="server" ID="ddlAssetCondition" OnSelectedIndexChanged="SelectedIndexChanged" data_column="Asset_Condition_ID"></asp:DropDownList>
<asp:RequiredFieldValidator runat="server" ID="reqAssetCondition" CssClass="invalid" ControlToValidate="ddlAssetCondition" Display="Dynamic" EnableClientScript="true" InitialValue="-1" Text="Required"></asp:RequiredFieldValidator>