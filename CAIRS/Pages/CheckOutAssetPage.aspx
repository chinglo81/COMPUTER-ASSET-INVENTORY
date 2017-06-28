<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CheckOutAssetPage.aspx.cs" Inherits="CAIRS.Pages.CheckOutAssetPage"  MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" MaintainScrollPositionOnPostback="true" EnableEventValidation="false"%>
<%@ MasterType VirtualPath="~/MasterPages/CAIRSMasterPage.Master" %>

<%@ Register Src="~/Controls/LOOKUP_Student.ascx" TagName="LookUp_Student" TagPrefix="UC" %>
<%@ Register Src="~/Controls/StudentInfoControl.ascx" TagName="Student_Info" TagPrefix="UC" %>
<%@ Register Src="~/Controls/TXT_TagID.ascx" TagName="Tag_ID" TagPrefix="UC" %>
<%@ Register Src="~/Controls/TXT_SerialNumber.ascx" TagName="Serial_Number" TagPrefix="UC" %>

<asp:Content id="Content1" ContentPlaceHolderid="cph_Body" Runat="server">

    <h1>Asset Checkout</h1>
    
    <!-- Success message for checkout asset -->
	<asp:Label runat="server" ID="lblSuccessMessage" CssClass="alert alert-success center-block" Text="Asset(s) checkout successful."></asp:Label>

	<!-- Student Lookup -->
	<UC:LookUp_Student ID="txtStudentLookup" IsStudentLookupRequired="false" ValidationGroup="vgCheckout" btnSearchStudentClick="btnStudentSearch_Click" IsApplySiteLevelSecurity="true" EnableRadioSearchType="false" runat="server" />


	<!-- Asset Search -->
	<div class="form-group row">

		<div class="col-xs-10">

			<UC:Tag_ID ID="txtTagID" IsTagIDRequired="true" ValidationGroup="vgSearchAsset" runat="server" />

            <br />
            <br />

            <UC:Serial_Number runat="server" ID="txtSerialNumber" IsSerialNumRequired="true" ValidationGroup="vgSearchAsset" />

		</div>

		<div class="col-xs-2">

			<asp:Button ID="btnSearchAsset" ValidationGroup="vgSearchAsset" Text="Search" OnClick="btnSearchAsset_Click" CssClass="btn btn-default" runat="server" />

		</div>

	</div>


	<!-- Student info and Asset info -->
    <div class="row">

        <div class="col-sm-6">
            
            <!-- Student Info -->
            <div id="divStudentInfo" runat="server">
                <UC:Student_Info runat="server" ID="Student_Info" showChangeStudentBtn="true" />
            </div>

        </div>
        
        <div class="col-sm-6">

			<!-- Validation message for Asset -->
			<asp:CustomValidator runat="server" ID="cvCheckOutAsset" ValidationGroup="vgCheckout" CssClass="alert alert-danger center-block" Display="Dynamic" />

			

        </div>
    </div>

    <br /><br />

    <div id="divCheckOutSection" runat="server">
        
        <div id="divPendingAssignment" runat="server">
            <asp:HiddenField runat="server" ID="hdnPendingTagIds" />
            <asp:HiddenField runat="server" ID="hdnSerialNumber" />

            <div class="navbar navbar-default navbar-table">
                <span class="navbar-brand pull-left">Pending Assignments</span>

            </div>

            <asp:Label runat="server" ID="lblResultsPendingAssignment"></asp:Label>

            <asp:DataGrid 
                runat="server" 
                ID="dgPendingAssignment" 
                AutoGenerateColumns="false" 
                CssClass="table table-hover table-striped table-border" 
                UseAccessibleHeader="true"
                GridLines="None">

                <Columns>
                    <asp:TemplateColumn HeaderText="Year">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "School_Year")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Site">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Asset_Site_Desc")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Tag ID">
				        <ItemTemplate>

                            <asp:Label 
                                runat="server"
                                ID="lblTagIDPendingAssignment" 
                                Tag_ID='<%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>'
                                Text='<%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>'
                                >
                            </asp:Label>

                        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Serial #">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Serial_Number")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Base Type">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Asset_Base_Type_Desc")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Asset Type">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Asset_Type_Desc")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn>
					    <ItemTemplate>

						    <asp:Button
							    ID="btnRemovePendingAsset"
							    Text="Remove"
							    OnClick="btnRemovePendingAsset_Click"
							    CssClass="btn btn-default btn-xs"
							    Tag_ID='<%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>'
							    OnClientClick="return confirm('Are you sure you want to remove this asset?')"
							    runat="server" />

					    </ItemTemplate>
				    </asp:TemplateColumn>

                </Columns>
            </asp:DataGrid>

            <div>

                <asp:Button runat="server" ID="btnSubmitPendingAssignment" Text="Submit Checkout" CssClass="btn btn-default pull-right" OnClick="btnSubmitPendingAssignment_Click" />
                
            </div>
        </div>

        <br />
        <br />
        <br />

        <div id="divCurrentlyAssigned" runat="server">

            <div class="navbar navbar-default navbar-table">
                <span class="navbar-brand pull-left">Current Assignments</span>
            </div>

            <asp:Label runat="server" ID="lblResults"></asp:Label>

            <asp:DataGrid 
                runat="server" 
                ID="dgAssignment" 
                AutoGenerateColumns="false" 
                CssClass="table table-hover table-striped table-border" 
                UseAccessibleHeader="true"
                GridLines="None">

                <Columns>
                    <asp:TemplateColumn HeaderText="Year">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "School_Year")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Site">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Student_School_Name")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Tag ID">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Base Type">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Asset_Base_Type_Desc")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Asset Type">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Asset_Type_Desc")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>
                    
                    <asp:TemplateColumn HeaderText="Checkout Date">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Date_Check_Out_Formatted")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                </Columns>
            </asp:DataGrid>
        </div>
    </div>

    <!-- Bootstrap Modal Dialog -->
    <div class="modal fade" id="popupViewDetailsStudentTransaction" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-class">
                <div class="panel panel-info" runat="server" id="modalTitle">

                <div class="panel-heading">
                    <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                    <h4 class="modal-title">
                        <asp:Label ID="lblModalTitle" runat="server" Text="" />
                    </h4>
                </div>

                <div class="panel-body">
                    <div id="divStudentTransactionDetails" runat="server">
                        <table>
                            <tr>
                                <td><strong>Student ID</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblStudentID_astDetail" data_column="Student_ID"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Name</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblStudentName_astDetail" data_column="Student_Name"></asp:Label>
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
                                <td><strong>Checkout By</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblCheckOutBy" data_column="Check_Out_By_Emp_Name"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>

                <div class="modal-footer">
                    <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                </div>

            </div>
        </div>
    </div>


    <!-- Bootstrap Modal Dialog -->
    <div class="modal fade" id="confirmPopup" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="panel panel-info" runat="server" id="Div1">
                <div class="panel-heading">
                    <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                    <h4 class="modal-title">
                        <asp:Label ID="confirmTitle" runat="server" Text=""></asp:Label></h4>
                </div>
                <div class="panel-body">
                    <asp:Label ID="confirmBody" runat="server" Text=""></asp:Label>
                </div>
                <asp:HiddenField runat="server" ID="hdnIsChangeStudent" />
                <div class="modal-footer">
                    <button class="btn" data-dismiss="modal" aria-hidden="true">Cancel</button>
                    <asp:Button ID="btnOkCancelOutOfChanges" CssClass="btn btn-default" runat="server" OnClick="btnOkCancelOutOfChanges_Click" Text="Continue" />
                </div>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function () {
            // Add Asset - Capture enter fire from scanner, refocus to Tag ID
            $('#cph_Body_txtTagID_txtTagID').on('keypress', function (e) {
                HandleNumberEnteredTagId(e);
            });
            // Add Asset - Capture enter fire from scanner, refocus to Tag ID
            $('#cph_Body_txtSerialNumber_txtSerialNumber').on('keypress', function (e) {
                HandleNumberEnteredTagId(e);
            });
        });

        var submit_count = 0;

        function HandleNumberEnteredTagId(e) {
            if (e.keyCode == 96) {
                e.preventDefault();
                submit_count++;

                if (submit_count == 3) {
                    $('#cph_Body_btnSubmitPendingAssignment').focus().click();
                    submit_count = 0
                }
            }

            if (e.keyCode == 35 || e.keyCode == 13 || e.keyCode == 59) {
                e.preventDefault();
                $('#cph_Body_btnSearchAsset').focus().click();
            }
        }
    </script>

</asp:Content>