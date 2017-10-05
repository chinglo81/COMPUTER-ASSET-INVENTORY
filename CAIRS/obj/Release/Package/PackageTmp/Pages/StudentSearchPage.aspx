<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" AutoEventWireup="true" CodeBehind="StudentSearchPage.aspx.cs" Inherits="CAIRS.Pages.StudentSearchPage" EnableEventValidation="false" %>

<%@ Register Src="~/Controls/LOOKUP_Student.ascx" TagName="LookUp_Student" TagPrefix="UC" %>
<%@ Register Src="~/Controls/StudentInfoControl.ascx" TagName="Student_Info" TagPrefix="UC" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph_Body" runat="server">
<%--<asp:UpdatePanel runat="server" ID="updatePanelStudentSearch" UpdateMode="Always">
	<ContentTemplate>--%>
   
	<h1>Student Asset Search</h1>

	<div class="alert alert-info">
		<strong>Note:</strong> This search returns the history of assets assigned to the requested student(s).
	</div>

	<div id="divSearch">

		<div class="form-group">
			<asp:RadioButtonList 
				runat="server" 
				ID="radSingleMultipleStudent" 
				CssClass="spaced" 
				RepeatDirection="Horizontal" 
				AutoPostBack="true" 
				OnSelectedIndexChanged="radSingleMultipleStudent_SelectedIndexChanged"
			>
				<asp:ListItem Value="SINGLE" Text="Single Student" Selected="True"></asp:ListItem>
				<asp:ListItem Value="MULTIPLE" Text="Multiple Student"></asp:ListItem>
			</asp:RadioButtonList>
		</div>

		<div runat="server" id="divSingleStudent" class="form-group">

			<UC:LookUp_Student runat="server" ID="txtStudentLookup" IsStudentLookupRequired="false" ValidationGroup="vgApplyFilters" SetFocusOnTextBox="true" />

		</div>

		<div runat="server" id="divMultipleStudent" visible="false" class="form-group">
			
			<asp:TextBox 
				runat="server" 
				ID="txtStudentIds" 
				CssClass="form-control ui-autocomplete-input" 
				Width="400px" 
				onkeypress="HandleNumberEntered(event);"
				placeholder="(New line or comma separated)" 
				TextMode="MultiLine">
			</asp:TextBox>

			<asp:RequiredFieldValidator 
				runat="server" 
				ID="reqStudentIds" 
				CssClass="invalid" 
				ControlToValidate="txtStudentIds" 
				EnableClientScript="false" 
				Display="Dynamic" 
				Visible="false"
				Text="Required" 
				ValidationGroup="vgApplyFilters" />

		</div>

		<div class="form-group" id="divSearchClearButton" runat="server" visible="false">

			<asp:Button 
				runat="server" 
				id="btnApplyFilters" 
				Text="Search" 
				OnClick="btnApplyFilters_Click" 
				CausesValidation="true" 
				ValidationGroup="vgApplyFilters" 
				CssClass="btn btn-default"
			/>

			<asp:Button 
				runat="server" 
				id="btnClear" 
				CausesValidation="false" 
				Text="Clear" 
				OnClick="btnClear_Click" 
				CssClass="btn"
			/>

		</div>
	</div>

	<br /><br />

	
	<div runat="server" id="headerStudentSearch" class="navbar navbar-default navbar-table">
		<span class="navbar-brand pull-left">Search Results</span>

         <ul class="nav navbar-nav">
            <li class="dropdown">

                <a class="dropdown-toggle" role="button" aria-expanded="false" href="#" data-toggle="dropdown">Actions <span class="caret"></span></a>

                <ul class="dropdown-menu" role="menu">
                    <li>
                        <asp:LinkButton 
                            runat="server" 
                            ID="lnkExportToExcel" 
                            Text="Export List" 
                            OnClick="lnkExportToExcel_Click"> 
                        </asp:LinkButton>
                    </li>
                </ul>

            </li>
        </ul>

	</div>

	<asp:DataGrid 
		runat="server" 
		ID="dgStudentSearch" 
		CssClass="table table-hover table-striped table-border" 
		AutoGenerateColumns="false"
		AllowPaging="true"
		AllowSorting="true"
		PagerStyle-Mode="NumericPages"
		PagerStyle-CssClass="pagination"
		OnPageIndexChanged="dgStudentSearch_PageIndexChanged" 
		PageSize="10"
		OnSortCommand="dgStudentSearch_SortCommand"
		OnItemDataBound="dgStudentSearch_ItemDataBound"
		UseAccessibleHeader="true">

		<Columns>

			<asp:TemplateColumn HeaderText="Year" SortExpression="School_Year">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "School_Year")%>

				</ItemTemplate>
			</asp:TemplateColumn>

			<asp:TemplateColumn HeaderText="Student ID" SortExpression="Student_ID">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Student_ID")%>

				</ItemTemplate>
			</asp:TemplateColumn>

			<asp:TemplateColumn HeaderText="Student" SortExpression="Student_Name">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Student_Name")%>

				</ItemTemplate>
			</asp:TemplateColumn>

			<asp:TemplateColumn HeaderText="Site" SortExpression="Asset_Site_Desc">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Desc")%>

				</ItemTemplate>
			</asp:TemplateColumn>

			<asp:TemplateColumn HeaderText="Tag ID" SortExpression="Tag_ID">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>

				</ItemTemplate>
			</asp:TemplateColumn>

			<asp:TemplateColumn SortExpression="Asset_Type_Desc" HeaderText="Asset Type">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Asset_Type_Desc")%>

				</ItemTemplate>
			</asp:TemplateColumn>

		   <%-- <asp:TemplateColumn SortExpression="Check_In_Asset_Disposition_Desc" HeaderText="Check-in Disposition">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Check_In_Asset_Disposition_Desc")%>

				</ItemTemplate>
			</asp:TemplateColumn>--%>

			<asp:TemplateColumn SortExpression="Date_Check_Out" HeaderText="Checkout">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Date_Check_Out_Formatted")%>

				</ItemTemplate>
			</asp:TemplateColumn>

			<asp:TemplateColumn SortExpression="Date_Check_In" HeaderText="Check-in">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Date_Check_In_Formatted")%>

				</ItemTemplate>
			</asp:TemplateColumn>

            <asp:TemplateColumn SortExpression="Check_In_Asset_Disposition_Desc" HeaderText="Check-in Disp">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Check_In_Asset_Disposition_Desc")%>

				</ItemTemplate>
			</asp:TemplateColumn>
			 

			<asp:TemplateColumn>
				<ItemTemplate>

					<asp:Button 
						ID="btnDetails" 
						CssClass="btn btn-primary btn-xs" 
						Text="Details" 
						OnClick="btnDetails_Click" 
						Asset_Student_Transaction_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_Student_Transaction_ID")%>'
						CausesValidation="false" 
						runat="server" />

				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</asp:DataGrid>
	
	<!-- Search Results -->
	<asp:Label runat="server" ID="lblResults" CssClass="label label-default pull-right"></asp:Label>

<%-- </ContentTemplate>
<Triggers>
    <asp:PostBackTrigger ControlID="lnkExportToExcel" />
</Triggers>
</asp:UpdatePanel>--%>

	<!-- Bootstrap Modal Dialog -->
	<div class="modal fade" id="popupDisplayStudentAssetDetail" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<asp:UpdatePanel runat="server" ID="updateStudentDetails" UpdateMode="Conditional">
			<ContentTemplate>
				<div class="modal-dialog" role="document">
			<div class="panel panel-info" runat="server" id="modalTitle">

				<div class="panel-heading">

					<button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>

					<h4 class="modal-title">
						<asp:Label ID="lblModalTitle" runat="server" Text="" />
					</h4>

				</div>

				<div runat="server" id="divStudentTransactionDetails" class="panel-body modal-body">
					<table class="table">
						<tr>
							<td colspan="2">
								<UC:Student_Info runat="server" ID="Student_Info" />
							</td>
						</tr>
						<tr>
							<td><strong>Student School</strong></td>
							<td>
								<asp:Label runat="server" ID="Label5" data_column="Student_School_Name"></asp:Label>
							</td>
						</tr>
                        <tr>
							<td><strong>Asset Site</strong></td>
							<td>
								<asp:Label runat="server" ID="Label13" data_column="Asset_Site_Desc"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Tag ID</strong></td>
							<td>
								<asp:Label runat="server" ID="Label9" data_column="Tag_ID"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Base Type</strong></td>
							<td>
								<asp:Label runat="server" ID="lblBaseType_astDetail" data_column="Asset_Base_Type_Desc"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Asset Type</strong></td>
							<td>
								<asp:Label runat="server" ID="lblAssetType_astDetail" data_column="Asset_Type_Desc"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Year</strong></td>
							<td>
								<asp:Label runat="server" ID="Label7" data_column="School_Year"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Checkout By</strong></td>
							<td>
								<asp:Label runat="server" ID="lblCheckOutBy" data_column="Check_Out_By_Emp_Name"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Checkout Condition</strong></td>
							<td>
								<asp:Label runat="server" ID="Label8" data_column="Check_Out_Asset_Condition_Desc"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Checkout Date</strong></td>
							<td>
								<asp:Label runat="server" ID="Label6" data_column="Date_Check_Out_Formatted"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Check-in Disposition</strong></td>
							<td>
								<asp:Label runat="server" ID="Label4" data_column="Check_In_Asset_Disposition_Desc"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Check-in Condition</strong></td>
							<td>
								<asp:Label runat="server" ID="Label1" data_column="Check_In_Asset_Condition_Desc"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Check-in Date</strong></td>
							<td>
								<asp:Label runat="server" ID="Label2" data_column="Date_Check_In_Formatted"></asp:Label>
							</td>
						</tr>
						<tr>
							<td><strong>Check-in By</strong></td>
							<td>
								<asp:Label runat="server" ID="Label3" data_column="Check_In_By_Emp_Name"></asp:Label>
							</td>
						</tr>
                        <tr runat="server" id="trFoundDisposition">
							<td><strong>Found Disposition</strong></td>
							<td>
								<asp:Label runat="server" ID="Label10" data_column="Found_Asset_Disposition_Desc"></asp:Label>
							</td>
						</tr>
                        <tr runat="server" id="trFoundCondition">
							<td><strong>Found Condition</strong></td>
							<td>
								<asp:Label runat="server" ID="Label11" data_column="Found_Asset_Condition_Desc"></asp:Label>
							</td>
						</tr>
                        <tr runat="server" id="trFoundDate">
							<td><strong>Found Date</strong></td>
							<td>
								<asp:Label runat="server" ID="Label12" data_column="Date_Found_Formatted"></asp:Label>
							</td>
						</tr>
					</table>
				</div>

				<div class="modal-footer">
					<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
				</div>

			</div>
		</div>
			</ContentTemplate>
		</asp:UpdatePanel>
	</div>
	
	 <script>
		 function HandleNumberEntered(e) {
             if (e.keyCode == 35 || e.keyCode == 59) {
				 e.preventDefault();

				 var sValue = $("#" + "<%=txtStudentIds.ClientID %>").val();
				$("#" + "<%=txtStudentIds.ClientID %>").val(sValue + "\r\n");
			}
		}

		function HandleNumberEnteredStudentLookup(e) {
            if (e.keyCode == 35 || e.keyCode == 13 || e.keyCode == 59) {
				e.preventDefault();
				$('#cph_Body_txtStudentLookup_btnSearch').focus().click();
			}
		}
	</script>

</asp:Content>
