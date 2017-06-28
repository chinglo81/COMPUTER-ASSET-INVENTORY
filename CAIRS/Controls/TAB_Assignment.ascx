<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TAB_Assignment.ascx.cs" Inherits="CAIRS.Controls.TAB_Assignment" %>

    <asp:Label runat="server" ID="lblResults"></asp:Label>
    
    <br />

    <asp:DataGrid 
        ID="dgAssignment" 
        AutoGenerateColumns="false" 
        CssClass="table table-hover table-striped" 
        GridLines="None"
        UseAccessibleHeader="true"
        runat="server">

        <Columns>
            <asp:TemplateColumn HeaderText="Student ID">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Student_ID")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn HeaderText="Assigned To">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Assigned_To_Student")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn HeaderText="Checked Out">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Date_Check_Out_Formatted")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn HeaderText="Checked In">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Date_Check_In_Formatted")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn>
                <ItemStyle HorizontalAlign="right" />
				<ItemTemplate>

					<asp:Button
						runat="server"
						ID="btnViewDetails"
                        CssClass="btn btn-primary btn-xs"
						Asset_Student_Transaction_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                        CausesValidation="false"
                        Text="Details"
						OnClick="btnViewDetails_Click" />

				</ItemTemplate>
			</asp:TemplateColumn>
        </Columns>
    </asp:DataGrid>

<!-- Bootstrap Modal Dialog -->
    <div class="modal fade" id="popupAssignmentDetails" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg custom-class">
            <div class="panel panel-info" runat="server" id="modalTitle">

                <div class="panel-heading">
                    <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                    <h4 class="modal-title">
                        <asp:Label ID="lblModalTitle" runat="server" Text="" /></h4>
                </div>

                <div class="panel-body">
                    <div id="divStudentAssetInfo" runat="server">
                        <table class="table">
                            <tr>
                                <td style="width:200px;"><strong>Student</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblStudentName" data_column="Assigned_To_Student" />
                                </td>
                                <td rowspan="10">
                                    <asp:Image 
                                        id="imgStudentPhoto" 
                                        CssClass="img-responsive img-thumbnail pull-right"
                                        AlternateText="Unable to Display Student Photo"
                                        runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Student ID</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblStudentID" data_column="Student_ID" />
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Year</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblSchoolYear" data_column="School_Year" />
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Site</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblCheckOutSchool" data_column="Student_Check_Out_School" />
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Checkout Condition</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblCheckOutCondition" data_column="Check_Out_Asset_Condition_Desc" />
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Checkout Date</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblDateCheckOut" data_column="Date_Check_Out_Formatted" />
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Checkout Employee</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblCheckOutByEmp" data_column="Check_Out_By_Emp_Name" />
                                </td>
                            </tr>
                            <tr runat="server" id="trChkInCondition" visible="false">
                                <td><strong>Check-in Condition</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblCheckInCondition" data_column="Check_In_Asset_Condition_Desc" />
                                </td>
                            </tr>
                            <tr runat="server" id="trChkInBy" visible="false">
                                <td><strong>Check-in By</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblCheckInByEmp" data_column="Check_In_By_Emp_Name" />
                                </td>
                            </tr>
                            <tr runat="server" id="trChkInDate" visible="false">
                                <td><strong>Check-in Date</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblDateCheckIn" data_column="Date_Check_In_Formatted" />
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