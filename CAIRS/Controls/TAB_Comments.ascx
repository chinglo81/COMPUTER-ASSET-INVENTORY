<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TAB_Comments.ascx.cs" Inherits="CAIRS.Controls.TAB_Comments" %>

    <asp:HiddenField ID="hdnCommentID" Value="-1" runat="server" />
    <asp:HiddenField ID="hdnAddedByEmpID" runat="server" />

    <asp:Label runat="server" ID="lblResults" />
    
    <br />

    <asp:DataGrid 
        ID="dgComments" 
        AutoGenerateColumns="false" 
        CssClass="table table-hover table-striped" 
        GridLines="None"
        OnItemDataBound="dgComments_ItemDataBound"
        UseAccessibleHeader="true"
        runat="server" >

        <Columns>
            <asp:TemplateColumn HeaderText="Added By">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Added_By_Emp_Name")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn HeaderText="Comment">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Comment_Short")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn HeaderText="Date" Visible="true">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Recent_Date_Formatted")%>

				</ItemTemplate>
			</asp:TemplateColumn>
            <asp:TemplateColumn>
                <ItemStyle HorizontalAlign="right" />
				<ItemTemplate>

                    <asp:Button
						ID="btnViewDetails"
                        Text="Details"
                        CssClass="btn btn-primary btn-xs"
						OnClick="btnViewDetails_Click"
						Comment_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                        CausesValidation="false"
						runat="server" />

					<asp:Button
						ID="btnDelete"
                        Text="Delete"
                        CssClass="btn btn-default btn-xs"
						OnClick="btnDelete_Click"
                        OnClientClick="return confirm('Are you sure you want to delete this?')"
                        Added_By_Emp_ID='<%# DataBinder.Eval(Container.DataItem, "Added_By_Emp_ID")%>'
                        Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
                        Security_Level_Disabled="10,20,30"
						Comment_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                        CausesValidation="false"
						runat="server" />

				</ItemTemplate>
			</asp:TemplateColumn>
        </Columns>
    </asp:DataGrid>

    <asp:LinkButton
        ID="btnAddComment"
        Text="Add Comment"
        CssClass="btn btn-default btn-sm"
        OnClick="btnAddComment_Click"
        CausesValidation="false"
        Security_Level_Disabled="10,20,30"
        runat="server" />


<!-- Bootstrap Modal Dialog -->
    <div class="modal fade" id="popupCommentDetails" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-class">
            <div class="panel panel-info" runat="server" id="modalTitle">

                <div class="panel-heading">
                    <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                    <h4 class="modal-title">
                        <asp:Label ID="lblModalTitle" runat="server" Text="" />
                    </h4>
                </div>

                <div class="panel-body">
                    <div id="divAssetCommentInfo" runat="server">
                        <table class="table">
                            <tr>
                                <td><strong>Comment</strong></td>
                                <td>

                                    <asp:Label ID="lblComment" data_column="Comment" runat="server" />

                                    <asp:TextBox 
                                        ID="txtComment" 
                                        CssClass="form-control" 
                                        TextMode="MultiLine" 
                                        data_column="Comment" 
                                        Visible="false" 
                                        runat="server" />

                                    <asp:RequiredFieldValidator 
                                        ID="reqComment" 
                                        CssClass="invalid" 
                                        Display="Dynamic" 
                                        Text="Required" 
                                        ControlToValidate="txtComment" 
                                        ValidationGroup="vgEditComment" 
                                        runat="server" />
                                </td>
                            </tr>
                            <tr runat="server" id="trAddedBy">
                                <td><strong>Added By</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblAddedBy" data_column="Added_By_Emp_Name"></asp:Label>
                                </td>
                            </tr>             
                            <tr runat="server" id="trDateAdded">
                                <td><strong>Date Added</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblDataAdded" data_column="Date_Added_Formatted"></asp:Label>
                                </td>
                            </tr>
                            <tr runat="server" id="trModifiedBy">
                                <td><strong>Modified By</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblModifiedBy" data_column="Modified_By_Emp_Name"></asp:Label>
                                </td>
                            </tr>
                            <tr runat="server" id="trDateModified">
                                <td><strong>Date Modified</strong></td>
                                <td>
                                    <asp:Label runat="server" ID="lblDateModified" data_column="Date_Modified_Formatted"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>

                <div class="modal-footer">

                    <asp:Button 
                        ID="btnSaveComment" 
                        CausesValidation="true" 
                        CssClass="btn btn-default" 
                        ValidationGroup="vgEditComment" 
                        Security_Level_Disabled="10,20,30"
                        OnClick="btnSaveComment_Click" 
                        Text="Save"
                        runat="server" />

                    <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

                </div>

            </div>
        </div>
    </div>