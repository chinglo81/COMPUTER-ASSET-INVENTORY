<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" AutoEventWireup="true" CodeBehind="StudentSearchPage.aspx.cs" Inherits="CAIRS.Pages.StudentSearchPage" EnableEventValidation="false" MaintainScrollPositionOnPostback="true"%>

<%@ Register Src="~/Controls/LOOKUP_Student.ascx" TagName="LookUp_Student" TagPrefix="UC" %>
<%@ Register Src="~/Controls/StudentInfoControl.ascx" TagName="Student_Info" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_Site.ascx" TagName="DDL_Site" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_Bin.ascx" TagName="DDL_Bin" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AssetCondition.ascx" TagName="DDL_AssetCondition" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AssetDisposition.ascx" TagName="DDL_AssetDisposition" TagPrefix="UC" %>
<%@ Register Src="~/Controls/AddAssetAttachment.ascx" TagName="Add_Attachment" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AttachmentType.ascx" TagName="DDL_AttachmentType" TagPrefix="UC" %>

<%@ Register Src="~/Controls/DDL_AssetBaseType.ascx" TagName="DDL_AssetBaseType" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AssetType.ascx" TagName="DDL_AssetType" TagPrefix="UC" %>
<%@ Register Src="~/Controls/MULTI_SELECT_AssetCondition.ascx" TagName="AssetCondition" TagPrefix="MULTI" %>
<%@ Register Src="~/Controls/MULTI_SELECT_AssetDisposition.ascx" TagName="AssetDisposition" TagPrefix="MULTI" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph_Body" runat="server">

	<h1>Student Asset Search</h1>

	<div class="alert alert-info">
		<strong>Note:</strong> This search returns the history of assets assigned to the requested student(s).
	</div>

	<div id="divSearch">
        
        <table>
            <tr>
                <td style="vertical-align:top">

                    <div class="form-group">
			            <asp:RadioButtonList 
				            runat="server" 
				            ID="radSingleMultipleStudent" 
				            CssClass="spaced" 
				            RepeatDirection="Horizontal" 
				            AutoPostBack="true"
			            >
				            <asp:ListItem Value="SINGLE" Text="Single Student" Selected="True"></asp:ListItem>
				            <asp:ListItem Value="MULTIPLE" Text="Multiple Students"></asp:ListItem>
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

                </td>
                <td style="width:10px"></td>
                <td style="vertical-align:top">
                    <div id="divAdditionalFilters" runat="server">
                        <div class="row">
                            <div class="col-sm-6">

                                <div class="form-group">
                                    <UC:DDL_Site ID="ddlSite" SelectedIndexChanged_DDL_Site="SelectedIndexChangedDDLSite" runat="server" />
                                </div>

                                <div class="form-group">
                                    <MULTI:AssetDisposition runat="server" ID="multiAssetDisposition" Business_Rule_Code="Disp_Option_Avail_Student_Asset_Search"></MULTI:AssetDisposition>
                                    <asp:HiddenField ID="hdnSelectedAssetDisposition" runat="server" />
                                </div>

                            </div>

                            <div class="col-sm-6">
                                <asp:UpdatePanel ID="updatePanelBaseAssetType" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <div class="form-group">
                                            <UC:DDL_AssetBaseType ID="ddlAssetBaseType" runat="server" />
                                        </div>

                                        <div class="form-group">
                                            <UC:DDL_AssetType ID="ddlAssetType" runat="server" />
                                        </div>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="3">
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
                </td>
            </tr>
        </table>

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

            <asp:TemplateColumn SortExpression="Asset_Base_Type_Desc" HeaderText="Base Type">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Asset_Base_Type_Desc")%>

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
                    
                    <asp:Button 
						ID="btnEditCheckIn" 
                        Visible='<%# AllowEditEditCheckIn(Container.DataItem)%>'
						CssClass="btn btn-default btn-xs" 
						Text="Edit Check-In" 
						OnClick="btnEditCheckIn_Click" 
                        Student_ID='<%# DataBinder.Eval(Container.DataItem, "Student_ID")%>'
                        Student_Name_ID='<%# DataBinder.Eval(Container.DataItem, "Student_Name_And_ID")%>'
                        Asset_Site_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_ID")%>'
                        Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
						Asset_Student_Transaction_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_Student_Transaction_ID")%>'
						CausesValidation="false" 
						runat="server" />

				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</asp:DataGrid>
	
	<!-- Search Results -->
	<asp:Label runat="server" ID="lblResults" CssClass="label label-default pull-right"></asp:Label>

	<!-- Detail Modal Dialog -->
	<div class="modal fade" id="popupDisplayStudentAssetDetail" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<asp:UpdatePanel runat="server" ID="updateStudentDetails" UpdateMode="Conditional">
			<ContentTemplate>
				<div class="modal-dialog modal-lg" role="document">
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
							        <td><strong>Check-in Type</strong></td>
							        <td>
								        <asp:Label runat="server" ID="lblCheckInType" data_column="Check_In_Type_Desc"></asp:Label>
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
	
    <!-- Edit Check-In Modal Dialog -->
    <div class="modal fade" id="popupEditStudentCheckIn" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" style="overflow: auto;" data-backdrop="static">
        <asp:UpdatePanel runat="server" ID="updatePanelStudentCheckIn" UpdateMode="Conditional">
            <ContentTemplate>

                <asp:HiddenField runat="server" ID="hdnAssetStudentTransactionID"/>
                <asp:HiddenField runat="server" ID="hdnAssetID"/>
                <asp:HiddenField runat="server" ID="hdnAssetSiteID"/>
                <asp:HiddenField runat="server" ID="hdnStudentID"/>
                <asp:HiddenField runat="server" ID="hdnStudentNameID"/>
                <asp:HiddenField runat="server" ID="hdnConditionBusinessRule" />
                
                <div class="modal-dialog modal-lg" role="document">

		            <div class="panel panel-info">

			            <div class="panel-heading">

				            <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>

				            <h4 class="modal-title">
                                <asp:Label runat="server" ID="lblModalCheckInTitle" Text="Edit Check-In"></asp:Label>
				            </h4>

			            </div>

			            <div class="panel-body" >
                            <div runat="server" id="divStudentCheckInModal">
                                

                                <div class="alert alert-warning">
						            <h4>WARNING!!!</h4>
						            The changes you make will re-assess the fines associated to this student.
					            </div>

                                 <fieldset class="scheduler-border"">
                                    <legend class="scheduler-border h1">Student Asset Info</legend>

                                    <div class="container"> 
                                        <div class="row">
                                            <div class="col-sm-2">
                                                <strong>Student:</strong>
                                            </div>
                                            <div class="col-sm-4">
                                                <asp:Label runat="server" ID="lblStudent" data_column="Student_Name_And_ID"></asp:Label>
                                            </div>
                                            <div class="col-sm-2">
                                                <strong>Bin:</strong>
                                            </div>
                                            <div class="col-sm-4">
                                                <asp:Label runat="server" ID="lblCurrentBinAssignment" data_column="Bin_Number_And_Desc"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-sm-2">
                                                <strong>Asset Site:</strong>
                                            </div>
                                            <div class="col-sm-4">
                                                <asp:Label runat="server" ID="lblAssetSite" data_column="Asset_Site_Desc"></asp:Label>
                                            </div>
                                            <div class="col-sm-2">
                                                <strong>Base Type:</strong>
                                            </div>
                                            <div class="col-sm-4">
                                                <asp:Label runat="server" ID="lblBaseType" data_column="Asset_Base_Type_Desc"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-sm-2">
                                                <strong>Tag ID:</strong>
                                            </div>
                                            <div class="col-sm-4">
                                                <asp:Label runat="server" ID="lblTagID" data_column="Tag_ID"></asp:Label>
                                            </div>
                                            <div class="col-sm-2">
                                                <strong>Serial #:</strong>
                                            </div>
                                            <div class="col-sm-4">
                                                <asp:Label runat="server" ID="lblSerial" data_column="Serial_Number"></asp:Label>
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>
                                
                                <br />


                                <fieldset class="scheduler-border">
                                    <legend  class="scheduler-border h1">
                                        Check-in Info
                                    </legend>

                                    <div class="alert alert-info" runat="server" id="divImportantAffixSticker">
						                    <h4>IMPORTANT!!!</h4>
						                    Please affix sticker with Student ID and Name. You are checking in an item without a Tag ID.
					                </div>

                                    <div>
                                        <asp:DropDownList 
                                            runat="server" 
                                            ID="ddlCheckInType" 
                                            CssClass="form-control" 
                                            data_column="Check_In_Type_ID"
                                            AutoPostBack="true"
                                            OnSelectedIndexChanged="ddlCheckInType_SelectedIndexChanged" 
                                        />
                                    

                                        <asp:RequiredFieldValidator
					                        ID="reqCheckInType"
					                        Text="Required"
					                        CssClass="invalid"
					                        Display="Dynamic" 
					                        InitialValue="-98" 
					                        EnableClientScript="true"
					                        ValidationGroup="vgSearchAsset"
					                        ControlToValidate="ddlCheckInType"
					                        runat="server" />

                                        <br />
                                        <br />

                                    </div>

                                    <div runat="server" id="divDisposition">
                                        
                                        <UC:DDL_AssetDisposition runat="server" ID="ddlDisposition_CheckIn" EnableClientScript="true" IsAssetDispositionRequired="true" ValidationGroup="vgSaveCheckIn" AutoPostBack="true" data_column="Asset_Disposition_ID" SelectedIndexChanged_DDL_AssetDisposition="ddlDisposition_Check_In_SelectedIndexChanged" />
                                        
                                        <br />
                                        <br />

                                    </div>
                                    
                                    <div class="form-group" runat="server" id="divAssetCondition_CheckIn">
						                <UC:DDL_AssetCondition runat="server" ID="ddlCondition_CheckIn" IsAssetConditionRequired="true" ValidationGroup="vgSaveCheckIn" data_column="Check_In_Asset_Condition_ID" />
					                </div>
                                    
                                    <div class="form-group" id="divStudentResponsibleForBroken" runat="server">
                                        <asp:CheckBox runat="server" ID="chkIsStudentResponsibleForDamage" CssClass="space-check-box" data_column="Stu_Responsible_For_Damage" />
                                    </div>

                                    <div class="form-group" runat="server" id="divPoliceReport">

						                <asp:CheckBox runat="server" ID="chkPoliceReport" Text="&nbsp; Is Police Report Provided?" CssClass="space-check-box" data_column="Is_Police_Report_Provided"/>
                            
                                        <div class="alert alert-info">
                                            Note: Please remember to attach police report if you checked the box above.
                                        </div>

					                </div>

                                    <div class="form-group">
						                <asp:TextBox runat="server" ID="txtComments_CheckIn" CssClass="form-control" Placeholder="Comment" TextMode="MultiLine" data_column="Asset_Student_Fee_Comment" />
					                </div>

                                </fieldset>

                                 <br />

                            </div>
                            
                            <!--Attachment-->
                            <div runat="server" id="divExistingAttachment">
                                <fieldset class="scheduler-border"">
                                    <legend class="scheduler-border h1">Attachment(s)

                                        <asp:Button runat="server" ID="btnAddAttachment" CssClass="btn btn-default btn-xs" OnClick="btnAddAttachment_Click" Text="Add Attachment" />
                                    </legend>
                                    
                                    <asp:Label runat="server" ID="lblNoExistingAttachment"></asp:Label>

                                
                                    <asp:DataGrid  
                                        ID="dgExistingAttachment" 
                                        AutoGenerateColumns="false"
                                        OnItemDataBound="dgExistingAttachment_ItemDataBound"
                                        CssClass="table table-hover table-striped" 
                                        GridLines="None"
                                        UseAccessibleHeader="true"
                                        runat="server">

                                        <Columns>
                                                <asp:TemplateColumn HeaderText="Attachment Type">
				                                <ItemTemplate>

					                                <%# DataBinder.Eval(Container.DataItem, "Attachment_Type_Desc")%>

				                                </ItemTemplate>
			                                    </asp:TemplateColumn>

                                                <asp:TemplateColumn HeaderText="File Type">
				                                <ItemTemplate>

					                                <%# DataBinder.Eval(Container.DataItem, "File_Type_Desc")%>

				                                </ItemTemplate>
			                                </asp:TemplateColumn>
                                            <asp:TemplateColumn HeaderText="Name">
				                                <ItemTemplate>

					                                <%# DataBinder.Eval(Container.DataItem, "Name")%>

				                                </ItemTemplate>
			                                </asp:TemplateColumn>

                                            <asp:TemplateColumn HeaderText="Date Added">
				                                <ItemTemplate>

					                                <%# DataBinder.Eval(Container.DataItem, "Date_Added_Formatted")%>

				                                </ItemTemplate>
			                                </asp:TemplateColumn>

                                            <asp:TemplateColumn>
                                                <ItemStyle HorizontalAlign="right" />
				                                <ItemTemplate>

					                                <asp:Button
						                                ID="btnView"
                                                        Text="View"
                                                        CssClass="btn btn-primary btn-xs"
                                                        Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
						                                Asset_Attachment_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                                        Asset_File_Name='<%# DataBinder.Eval(Container.DataItem, "Name")%>'
                                                        Asset_File_Type='<%# DataBinder.Eval(Container.DataItem, "File_Type_Desc")%>'
                                                        CausesValidation="false"
						                                OnClick="btnView_Click"
						                                runat="server" />

					                                <asp:Button
						                                ID="btnDelete"
                                                        CssClass="btn btn-default btn-xs"
                                                        Text="Delete"
						                                OnClick="btnDelete_Click"
                                                        OnClientClick="return confirm('Are you sure you want to delete this?')"
						                                Asset_Attachment_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                                        Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
                                                        CausesValidation="false"
                                                        Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
                                                        Security_Level_Disabled="10,20,30"
						                                runat="server" />

				                                </ItemTemplate>
			                                </asp:TemplateColumn>
                                        </Columns>
                                    </asp:DataGrid>


                                </fieldset>

                            </div>

			            </div>

			            <div class="modal-footer">

                            <asp:Button runat="server" ID="btnSubmitCheckIn" CssClass="btn btn-default" Text="Save" OnClick="btnSubmitCheckIn_Click" ValidationGroup="vgSaveCheckIn"  />

			                <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

		                </div>
                
		            </div>

	            </div>

            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="btnSaveAttachment"/>
            </Triggers>
        </asp:UpdatePanel>
    </div>

    <!-- Add New Attachment Modal Dialog -->
    <div class="modal fade" id="modalAddNewAttachment" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
        <div class="modal-dialog custom-class">
            <div class="panel panel-info" runat="server" id="div1">
                <div class="panel-heading">
                    <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                    <h4 class="modal-title">
                        <asp:Label ID="Label14" runat="server" Text="Add Attachment"></asp:Label></h4>
                </div>
                <div class="panel-body">
                    <div id="divAddAttachment">

                        <div class="form-group">
                            <UC:DDL_AttachmentType ID="ddlAttachmentType" runat="server" IsAttachmentTypeRequired="true" ValidationGroup="vgEditAttachement" EnableClientScript="true"/>
                        </div>

                        <div class="form-group">
                            <asp:HiddenField runat="server" ID="hdnFileType" Value="File_Type_Desc" />
                            <asp:TextBox ID="txtAttachmentNameEdit" CssClass="form-control" Placeholder="Filename" data_column="Name" runat="server" />

                            <asp:RequiredFieldValidator 
                                ID="reqName" 
                                ControlToValidate="txtAttachmentNameEdit" 
                                Display="Dynamic"
                                Text="Required" 
                                EnableClientScript="true"
                                CssClass="invalid" 
                                ValidationGroup="vgEditAttachement"
                                runat="server" />

                            <asp:CustomValidator 
                                runat="server" 
                                CssClass="invalid" 
                                Display="Dynamic"
                                ID="cvDuplicateName" 
                                EnableClientScript="true"
                                Text="Duplicate File Name. Please Change" 
                                ValidationGroup="vgEditAttachement" />

                            <asp:RegularExpressionValidator 
                                ID="regExName" 
                                CssClass="invalid"
                                Display="Dynamic"
                                runat="server" 
                                EnableClientScript="true"
                                ValidationExpression="[a-zA-Z0-9_. \\]*$" 
                                ControlToValidate="txtAttachmentNameEdit" 
                                ErrorMessage="Special characters not allowed" 
                                ValidationGroup="vgEditAttachement" />
                        </div>

                        <div class="form-group">
                            <asp:TextBox ID="txtAttachmentDescEdit" CssClass="form-control" Placeholder="Description" TextMode="MultiLine" data_column="Description" runat="server" />
                        </div>
                        
                        <div> 
                                                
                            <table class="table table-responsive">
                                <tr>
                                    <td>
                                        <asp:FileUpload ID="FileUploadAttachment" CssClass="form-control" runat="server" />

                                        <div>
                                            <asp:RequiredFieldValidator 
                                                ID="ReqFile" 
                                                Visible="true"
                                                Text="Required" 
                                                CssClass="invalid"
                                                Display="Dynamic"
                                                ControlToValidate="FileUploadAttachment"
                                                EnableClientScript="true"
                                                ValidationGroup="vgEditAttachement"
                                                runat="server"  />
                                        </div>  
                                        
                                        <div>       
                                            <asp:RegularExpressionValidator 
                                                ID="regExFileType" 
                                                CssClass="invalid"
                                                Display="Dynamic"
                                                EnableClientScript="true"
                                                ValidationExpression="[a-zA-Z0-9\\].*(.doc|.DOC|.docx|.DOCX|.pdf|.PDF|.xls|.XLS|.xlsx|.XLSX|.jpg|.JPG|.csv|.CSV|.jpeg|.JPEG)$" 
                                                ControlToValidate="FileUploadAttachment" 
                                                ErrorMessage="Invalid File type" 
                                                ValidationGroup="vgEditAttachement"
                                                runat="server"  />
                                        </div> 

                                        <div>
                                            <asp:CustomValidator 
                                                ID="cvUploadFileSize"
                                                CssClass="invalid" 
                                                EnableClientScript="true"
                                                Display="Dynamic"
                                                runat="server" 
                                                ValidationGroup="vgEditAttachement"
                                                ErrorMessage="Your file is too big. Maximum File Size: 4MB." 
                                                ControlToValidate="FileUploadAttachment"/>
                                        </div>

                                        <div>
                                                <asp:CustomValidator 
                                                runat="server" 
                                                CssClass="invalid" 
                                                EnableClientScript="true"
                                                Display="Dynamic"
                                                ID="cvDuplicateFileName" 
                                                Text="Duplicate File Name. Please Change" 
                                                ValidationGroup="vgEditAttachement" />

                                        </div>

                                    </td>
                                    <td>
                                        <input type="button" onclick="ClearAttachmentValue()" value="Clear" class="btn" />
                                    </td>
                                </tr>
                            </table>

                            <small><strong>Accepted file types:</strong> jpg, jpeg, doc, docx, pdf, xls, xlsx, csv</small>
                            <br />
                            <strong>Maximum File Size:</strong> 4MB
                            <br />

                        </div>


                    </div>
                </div>
                <div class="modal-footer">

                    <asp:Button 
                        ID="btnSaveAttachment" 
                        Text="Add"
                        CssClass="btn btn-default"
                        OnClick="btnSaveAttachment_Click"
                        ValidationGroup="vgEditAttachement"
                        runat="server" 
                    />

                    <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

                    <asp:Button runat="server" ID="btnCloseAddAttachment" Style="Display:none" Text="Close" OnClick="btnCloseAddAttachment_Click"></asp:Button>
                </div>
            </div>
        </div>
    </div>

    <!-- No File Found Modal Dialog -->
    <div class="modal fade" id="popupNoFileFound" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-class">
            <asp:UpdatePanel ID="upModal" runat="server" ChildrenAsTriggers="false" UpdateMode="Conditional">
                <ContentTemplate>
                    <div class="panel panel-info" runat="server" id="divNoFileTitle">
                        <div class="panel-heading">
                            <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                            <h4 class="modal-title">
                                <asp:Label ID="lblNoFileTitle" runat="server" Text=""></asp:Label></h4>
                        </div>
                        <div class="panel-body">
                            <asp:Label ID="lblNoFileBody" runat="server" Text=""></asp:Label>
                        </div>
                        <div class="modal-footer">
                            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <!-- Confirmation Save Edit Modal Dialog -->
    <div class="modal fade" id="popupConfirmSaveCheckIn" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" style="z-index: 9999;" data-backdrop="static">
        <div class="modal-dialog custom-class">
            <div class="panel panel-info" runat="server" id="div2">
                
                <div class="panel-heading" style="background-color: #f39c12;">
                    <h4 class="modal-title ">
                        <asp:Label ID="Label15" runat="server" Text="Confirm"></asp:Label></h4>
                </div>
                <div class="panel-body">
                    <asp:Label ID="Label16" runat="server" Text="The changes you are making will re-assess the fine associated to this student. Are you sure you want to proceed? "></asp:Label>
                    <div>
                        <br />
                        <br />
                        <strong>Reason for making this change:</strong>
                        <asp:TextBox runat="server" ID="txtEditReason" TextMode="MultiLine" CssClass="form-control ui-autocomplete-input"></asp:TextBox>
                         <asp:RequiredFieldValidator 
                                ID="reqEditReqson" 
                                ControlToValidate="txtEditReason" 
                                Display="Dynamic"
                                Text="Required" 
                                EnableClientScript="true"
                                CssClass="invalid" 
                                ValidationGroup="vgEditReason"
                                runat="server" />
                    </div>
                
                </div>
                <div class="modal-footer">
                    
                    <asp:Button runat="server" ID="btnConfirmSave" CssClass="btn btn-danger" Text="Yes" ValidationGroup="vgEditReason" OnClick="btnConfirmSave_Click" />
                    <button class="btn" data-dismiss="modal" aria-hidden="true">No</button>
                </div>
            </div>
        </div>
    </div>
	 
    <script>

        function ClearAttachmentValue() {
            $("#" + "<%=FileUploadAttachment.ClientID %>").val("");
        }


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
