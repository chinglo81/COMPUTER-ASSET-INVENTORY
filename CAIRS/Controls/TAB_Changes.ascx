<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TAB_Changes.ascx.cs" Inherits="CAIRS.Controls.TAB_Changes" %>

<asp:UpdatePanel ID="updatePanelChanges" runat="server" UpdateMode="Always">
    <ContentTemplate>

    
    <asp:Label runat="server" ID="lblResults" />

    <br />

    <asp:DataGrid 
        ID="dgChanges" 
        CssClass="table table-hover table-striped" 
        AutoGenerateColumns="false" 
        GridLines="None"
        UseAccessibleHeader="true"
        AllowPaging="true"
        PagerStyle-Mode="NumericPages"
		PagerStyle-CssClass="pagination"
		PageSize="15"
        OnPageIndexChanged="dgChanges_PageIndexChanged"
        runat="server" >

        <Columns>
            <asp:TemplateColumn HeaderText="Column">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Column_Name_Desc")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn HeaderText="Old Value">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Old_Value_Desc")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn HeaderText="New Value">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "New_Value_Desc")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn HeaderText="Modified" Visible="true">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Date_Modified_Formatted")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn HeaderText="Modified By" Visible="true">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Modified_By_Emp_Name")%>

				</ItemTemplate>
			</asp:TemplateColumn>
        </Columns>
    </asp:DataGrid>

    </ContentTemplate>
</asp:UpdatePanel>