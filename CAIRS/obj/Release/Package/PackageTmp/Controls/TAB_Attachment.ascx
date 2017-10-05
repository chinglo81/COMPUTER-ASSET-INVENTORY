<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TAB_Attachment.ascx.cs" Inherits="CAIRS.Controls.TAB_Attachment" %>

<%@ Register Src="~/Controls/DDL_AttachmentType.ascx" TagName="DDL_AttachmentType" TagPrefix="UC" %>

<!--Hidden value to handle insert and update, -1 Means insert--> 
    <asp:HiddenField ID="hdnID" Value="-1" runat="server" />
    <asp:HiddenField ID="hdnAssetID" runat="server" />
    <asp:HiddenField ID="hdnStudentID" runat="server" />

    <asp:Label runat="server" ID="lblResults" />
    
    <br />    

    <asp:DataGrid  
        ID="dgAttachment" 
        AutoGenerateColumns="false" 
        CssClass="table table-hover table-striped" 
        GridLines="None"
        OnItemDataBound="dgAttachment_ItemDataBound"
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

            <asp:TemplateColumn HeaderText="Is Tampered?">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Is_Tampered_Attachment")%>

				</ItemTemplate>
			</asp:TemplateColumn>

            <asp:TemplateColumn HeaderText="Student">
				<ItemTemplate>

					<%# DataBinder.Eval(Container.DataItem, "Student_Name_ID")%>

				</ItemTemplate>
			</asp:TemplateColumn>

            <asp:TemplateColumn>
                <ItemStyle HorizontalAlign="right" />
				<ItemTemplate>

					<asp:Button
						ID="btnView"
                        Text="View"
                        CssClass="btn btn-primary btn-xs"
						Asset_Attachment_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                        Asset_File_Name='<%# DataBinder.Eval(Container.DataItem, "Name")%>'
                        Asset_File_Type='<%# DataBinder.Eval(Container.DataItem, "File_Type_Desc")%>'
                        CausesValidation="false"
						OnClick="btnView_Click"
						runat="server" />

					<asp:Button
						ID="btnEditDetails"
                        Text="Edit"
                        CssClass="btn btn-primary btn-xs"
						OnClick="btnEditDetails_Click"
                        Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
                        Security_Level_Disabled="10,20,30"
						Asset_Attachment_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                        CausesValidation="false"
						runat="server" />

					<asp:Button
						ID="btnDelete"
                        CssClass="btn btn-default btn-xs"
                        Text="Delete"
						OnClick="btnDelete_Click"
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
    
    <asp:LinkButton
        runat="server"
        ID="btnAddAttachment"
        Text="Add Attachment"
        CssClass="btn btn-default btn-sm"
        OnClick="btnAddAttachment_Click"
        Security_Level_Disabled="10,20,30"
        CausesValidation="false" />

<!-- Bootstrap Alert Modal Dialog -->
    <div class="modal fade" id="popupAttachmentDetails" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-class">
            <div class="panel panel-info" runat="server" id="modalTitle">

                <div class="panel-heading">
                    <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                    <h4 class="modal-title">
                        <asp:Label ID="lblModalTitle" runat="server" Text=""></asp:Label></h4>
                </div>

                <div class="panel-body">
                    <div id="divAssetAttachmentInfo" runat="server">

                        <div class="form-group">
                            <UC:DDL_AttachmentType ID="ddlAttachmentType" runat="server" IsAttachmentTypeRequired="true" ValidationGroup="vgEditAttachement"/>
                        </div>

                        <!-- Attachment Name -->
                        <div class="form-group">
                            <asp:HiddenField runat="server" ID="hdnFileType" Value="File_Type_Desc" />
                            <asp:TextBox ID="txtNameEdit" CssClass="form-control" Placeholder="Filename" data_column="Name" runat="server" />

                            <asp:RequiredFieldValidator 
                                ID="reqName" 
                                ControlToValidate="txtNameEdit" 
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
                                Text="Duplicate File Name. Please Change" 
                                ValidationGroup="vgEditAttachement" />

                            <asp:RegularExpressionValidator 
                                ID="regExName" 
                                CssClass="invalid"
                                Display="Dynamic"
                                runat="server" 
                                EnableClientScript="true"
                                ValidationExpression="[a-zA-Z0-9_. \\]*$" 
                                ControlToValidate="txtNameEdit" 
                                ErrorMessage="Special characters not allowed" 
                                ValidationGroup="vgEditAttachement" />
                        </div>

                        <!-- Attachment Description -->
                        <div class="form-group">
                            <asp:TextBox ID="txtDescriptionEdit" CssClass="form-control" Placeholder="Description" TextMode="MultiLine" data_column="Description" runat="server" />
                        </div>

                        
                        <div class="form-group">

                            <asp:FileUpload ID="FileUploadAttachment" CssClass="form-control" runat="server" />

                            <small><strong>Accepted file types:</strong> jpg, jpeg, doc, docx, pdf, xls, xlsx, csv</small>
                            <br />
                            <strong>Maximum File Size:</strong> 4MB
                            <br />

                            <asp:RequiredFieldValidator 
                                ID="reqFile" 
                                Text="Required" 
                                CssClass="invalid"
                                Display="Dynamic"
                                EnableClientScript="true"
                                ControlToValidate="FileUploadAttachment" 
                                ValidationGroup="vgEditAttachement"
                                runat="server"  />

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

                             <asp:CustomValidator 
                                ID="cvUploadFileSize"
                                CssClass="invalid" 
                                EnableClientScript="true"
                                Display="Dynamic"
                                runat="server" 
                                ErrorMessage="Your file is too big. Maximum File Size: 4MB." 
                                ControlToValidate="FileUploadAttachment"/>

                        </div>

                        <div id="divAssetStudentTransactionInfo" runat="server">
                            <asp:DropDownList runat="server" ID="ddlAssetStudentTransaction" CssClass="form-control" data_column="Asset_Student_Transaction_ID"></asp:DropDownList>
                        </div>

                        <div class="form-group" runat="server" id="divTamperInfo">
                            <strong>Is Tampered?: </strong><asp:Label runat="server" ID="lblIsTampered" data_column="Is_Tampered_Attachment"></asp:Label>
                            <br />
                            <br />
                            <div id="divStudentTamperInfo" runat="server">
                             <strong>Student: </strong><asp:Label runat="server" ID="lblStudent" data_column="Student_Name_ID"></asp:Label>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="modal-footer">

                    <asp:Button 
                        ID="btnSaveAttachment" 
                        Text="Save"
                        CssClass="btn btn-default"  
                        OnClick="btnSaveAttachment_Click" 
                        Security_Level_Disabled="10,20,30"
                        ValidationGroup="vgEditAttachement"
                        runat="server" />

                    <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

                </div>

            </div>
        </div>
    </div>

<!-- Bootstrap Modal Dialog -->
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