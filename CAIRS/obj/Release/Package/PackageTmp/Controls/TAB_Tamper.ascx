<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TAB_Tamper.ascx.cs" Inherits="CAIRS.Controls.TAB_Tamper" %>

<%@ Register Src="~/Controls/AddAssetAttachment.ascx" TagName="Add_Attachment" TagPrefix="UC" %>
<%@ Register Src="~/Controls/LOOKUP_Student.ascx" TagName="LookUp_Student" TagPrefix="UC" %>

        <asp:HiddenField ID="hdnAssetTamperID" Value="-1" runat="server" />

        <asp:Label runat="server" ID="lblResults" />

        <br />

         <asp:DataGrid 
            ID="dgTamper" 
            AutoGenerateColumns="false" 
            CssClass="table table-hover table-striped"
            OnItemDataBound="dgTamper_ItemDataBound"
            GridLines="None"
            UseAccessibleHeader="true"
            runat="server" >

            <Columns>
           
                <asp:TemplateColumn HeaderText="Student">
				    <ItemTemplate>

					    <%# DataBinder.Eval(Container.DataItem, "Student_Name")%>

				    </ItemTemplate>
			    </asp:TemplateColumn> 

                <asp:TemplateColumn HeaderText="School">
				    <ItemTemplate>

					    <%# DataBinder.Eval(Container.DataItem, "Student_School_Desc")%>

				    </ItemTemplate>
			    </asp:TemplateColumn> 

                <asp:TemplateColumn HeaderText="Comment">
				    <ItemTemplate>

					    <%# DataBinder.Eval(Container.DataItem, "Comment_Short")%>

				    </ItemTemplate>
			    </asp:TemplateColumn> 
            
                <asp:TemplateColumn HeaderText="Added By">
				    <ItemTemplate>

					    <%# DataBinder.Eval(Container.DataItem, "Added_By_Emp_Name")%>

				    </ItemTemplate>
			    </asp:TemplateColumn>
            
                <asp:TemplateColumn HeaderText="Date" Visible="true">
				    <ItemTemplate>

					    <%# DataBinder.Eval(Container.DataItem, "Date_Added_Formatted")%>

				    </ItemTemplate>
			    </asp:TemplateColumn>

                <asp:TemplateColumn HeaderText="Has Attachment" Visible="true">
				    <ItemTemplate>

					    <%# DataBinder.Eval(Container.DataItem, "Has_Attachment")%>

				    </ItemTemplate>
			    </asp:TemplateColumn>

                <asp:TemplateColumn HeaderText="Date Processed" Visible="true">
				    <ItemTemplate>

					    <%# DataBinder.Eval(Container.DataItem, "Processed")%>

				    </ItemTemplate>
			    </asp:TemplateColumn>

                <asp:TemplateColumn>
                    <ItemStyle HorizontalAlign="right" />
				    <ItemTemplate>

                        <asp:Button
						    ID="btnViewTamper"
                            Text="Details"
                            CssClass="btn btn-primary btn-xs"
						    OnClick="btnViewTamper_Click"
						    Tamper_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                            CausesValidation="false"
						    runat="server" />

					    <asp:Button
                            Visible='<%# IsDisplayDelete(Container.DataItem)%>'
						    ID="btnDelete"
                            Text="Delete"
                            CssClass="btn btn-default btn-xs"
						    OnClick="btnDeleteTamper_Click"
                            OnClientClick="return confirm('Are you sure you want to delete this?')"
                            Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
                            Security_Level_Disabled="10,20,30"
						    Tamper_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                            CausesValidation="false"
						    runat="server" />

				    </ItemTemplate>
			    </asp:TemplateColumn>
            </Columns>
        </asp:DataGrid>

        <asp:LinkButton
            ID="btnAddTamper"
            Text="Add Tamper"
            CssClass="btn btn-default btn-sm"
            OnClick="btnAddTamper_Click"
            CausesValidation="false"
            Security_Level_Disabled="10,20,30"
            runat="server" />

        <asp:Label runat="server" ID="lblNotAllowCreateMsg" CssClass="invalid"></asp:Label>


<!-- Bootstrap Modal Dialog -->
<div class="modal fade" id="popupManagePropertiesModal" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
   
    <div class="modal-dialog modal-lg" role="document">
        <div class="panel panel-info" runat="server" id="Div1">

            <div class="panel-heading">
                <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                <h4 class="modal-title">
                    <asp:Label ID="lblManagePropertiesTitle" runat="server" />
                </h4>
            </div>

            <div class="panel-body modal-body" id="divTamperInfo" runat="server">
                        
                <table class="table table-form table-valign-middle">
                    <tr runat="server" id="trPreviousStudentAssigned">
                        <td colspan="2">
                            <table>
                                <tr>
                                    <td>
                                        Did most recently assigned student "<asp:Label runat="server" ID="lblStudent" data_column="Student_Name"></asp:Label>" tamper with this asset?
                                        <asp:HiddenField runat="server" ID="hdnStudentID" value="Student_ID" />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="vertical-align: top">
                                        <asp:RadioButtonList runat="server" ID="radCorrectStudent" RepeatDirection="Horizontal" CssClass="spaced" AutoPostBack="true" OnSelectedIndexChanged="radCorrectStudent_SelectedIndexChanged">
                                            <asp:ListItem>Yes</asp:ListItem>
                                            <asp:ListItem>No</asp:ListItem>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <strong>
                                Student
                            </strong>
                        </td>
                        <td>
                            <asp:Label runat="server" ID="lblTamperedStudent" data_column="Student_Name"></asp:Label>
                            <UC:LookUp_Student 
                                runat="server" 
                                ID="txtStudentLookup" 
                                IsControlOnModal="true"
                                btnChangeStudentClick="btnStudentLookup_Click"
                                btnSearchStudentClick="btnStudentLookup_Click"
                            />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <strong>
                                Comment
                            </strong>
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtComment" data_column="Comment" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
                            <asp:CustomValidator
                                runat="server"
                                ID="cvComment"
                                CssClass="invalid"
                                Text="Required if a student is not selected"
                                ErrorMessage="Required if a student is not selected"
                                ValidationGroup="vgSaveTamper"
                                >
                            </asp:CustomValidator>
                        </td>
                    </tr>
                    <tr runat="server" id="trDateProcessed">
                        <td>
                            <strong>
                                Date Processed
                            </strong>
                        </td>
                        <td>
                            <asp:Label runat="server" ID="Label4" data_column="Processed"></asp:Label>
                        </td>
                    </tr>
                    <tr runat="server" id="trAddedBy">
                        <td>
                            <strong>
                                Added By
                            </strong>
                        </td>
                        <td>
                            <asp:Label runat="server" ID="Label2" data_column="Added_By_Emp_Name"></asp:Label>
                        </td>
                    </tr>
                    <tr runat="server" id="trDateAdded">
                        <td>
                            <strong>
                                Date Added
                            </strong>
                        </td>
                        <td>
                            <asp:Label runat="server" ID="Label3" data_column="Date_Added_Formatted"></asp:Label>
                        </td>
                    </tr>
                    <tr runat="server" id="trModifiedBy">
                        <td>
                            <strong>
                                Modified By
                            </strong>
                        </td>
                        <td>
                            <asp:Label runat="server" ID="lblModifiedBy" data_column="Modified_By_Emp_Name"></asp:Label>
                        </td>
                    </tr>
                    <tr runat="server" id="trDateModified">
                        <td>
                            <strong>
                                Date Modified
                            </strong>
                        </td>
                        <td>
                            <asp:Label runat="server" ID="lblDateMofiied" data_column="Date_Modified_Formatted"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div class="form-group">
					            <UC:Add_Attachment runat="server" ID="uc_TamperAttachment" />
                            </div>
                        </td>
                    </tr>
                    <tr runat="server" id="trExistingAttachments">
                        <td colspan="2">
                            <h4>Existing Attachment</h4>

                            <asp:Label runat="server" ID="lblResultsAttachment"></asp:Label>

                            <asp:DataGrid  
                                ID="dgTamperAttachment" 
                                AutoGenerateColumns="false" 
                                CssClass="table table-hover table-striped" 
                                GridLines="None"
                                OnItemDataBound="dgTamperAttachment_ItemDataBound"
                                UseAccessibleHeader="true"
                                runat="server">

                            <Columns>
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

                                <asp:TemplateColumn HeaderText="Description">
				                    <ItemTemplate>

					                    <%# DataBinder.Eval(Container.DataItem, "Description")%>

				                    </ItemTemplate>
			                    </asp:TemplateColumn>

                                <asp:TemplateColumn>
                                    <ItemStyle HorizontalAlign="right" />
				                    <ItemTemplate>

					                    <asp:Button
						                    ID="btnViewAttachment"
                                            Text="View"
                                            CssClass="btn btn-primary btn-xs"
						                    Asset_Attachment_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                            Asset_File_Name='<%# DataBinder.Eval(Container.DataItem, "Name")%>'
                                            Asset_File_Type='<%# DataBinder.Eval(Container.DataItem, "File_Type_Desc")%>'
                                            CausesValidation="false"
						                    OnClick="btnViewAttachment_Click"
						                    runat="server" />

					                    <asp:Button
						                    ID="btnDeleteTamperAttachment"
                                            CssClass="btn btn-default btn-xs"
                                            Text="Delete"
						                    OnClick="btnDeleteTamperAttachment_Click"
                                            OnClientClick="return confirm('Are you sure you want to delete this?')"
						                    Asset_Attachment_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                            CausesValidation="false"
                                            Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
                                            Security_Level_Disabled="10,20,30"
						                    runat="server" />

				                    </ItemTemplate>
			                    </asp:TemplateColumn>
                            </Columns>
                        </asp:DataGrid>
                            </td>
                    </tr>
                </table>
            </div>

            <div class="modal-footer">
  
                <asp:Button 
                    ID="btnSaveManagePropertiesModal" 
                    Text="Save" 
                    CssClass="btn btn-default"
                    OnClick="btnSaveManagePropertiesModal_Click" 
                    CausesValidation="true"
                    Security_Level_Disabled="10,20,30"
                    ValidationGroup="vgSaveTamper"
                    runat="server" />
                   
                <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

            </div>

        </div>
    </div>

 </div>

<!-- Bootstrap Modal Dialog -->
<div class="modal fade" id="popupNoFileFoundTamper" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog custom-class">
        <asp:UpdatePanel ID="updatePanelFileNotFound" runat="server" UpdateMode="Conditional">
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