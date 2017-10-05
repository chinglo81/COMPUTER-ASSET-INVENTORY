<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AddAssetAttachment.ascx.cs" Inherits="CAIRS.Controls.AddAssetAttachement" %>

<%@ Register Src="~/Controls/DDL_AttachmentType.ascx" TagName="DDL_AttachmentType" TagPrefix="UC" %>

<asp:UpdatePanel runat="server" ID="updateAttachment">
    <ContentTemplate>

    

<asp:HiddenField runat="server" ID="hdnAssetId" />
<asp:HiddenField runat="server" ID="hdnAssetTamperID" />


    <fieldset class="scheduler-border"">
        <legend class="scheduler-border h1">Attachments</legend>
        <div>

            <div class="form-group">

                <UC:DDL_AttachmentType ID="ddlAttachmentType" runat="server" IsAttachmentTypeRequired="true"/>

            </div>

            <div class="form-group">

                <asp:TextBox runat="server" ID="txtFileName" CssClass="form-control ui-autocomplete-input" placeholder="Name" />

                <asp:RequiredFieldValidator 
                    ID="reqName" 
                    Text="Required"
                    CssClass="invalid" 
                    Display="Dynamic"
                    ControlToValidate="txtFileName" 
                    EnableClientScript="true"
                    runat="server" />

                <asp:RegularExpressionValidator 
                    ID="regExName" 
                    CssClass="invalid"
                    Display="Dynamic"
                    EnableClientScript="true"
                    ValidationExpression="[a-zA-Z0-9_. \\]*$" 
                    ControlToValidate="txtFileName" 
                    ErrorMessage="Special characters not allowed" 
                    runat="server"/>

                <asp:CustomValidator 
                    ID="cvDuplicateName" 
                    Text="Duplicate File Name. Please Change" 
                    CssClass="invalid" 
                    Display="Dynamic"
                    runat="server" />

            </div>

            <div class="form-group">

                <asp:TextBox runat="server" ID="txtDescription" CssClass="form-control ui-autocomplete-input" placeholder="Description" />

            </div>

            <div class="form-group">

                <strong>Accepted file types:</strong> jpg, jpeg, doc, docx, xls, xlsx, pdf, csv
                <br />
                <strong>Maximum File Size:</strong> 4MB

                <table style="width:100%">
                    <tr>
                        <td>
                            <asp:FileUpload ID="FileUploadAttachment" CssClass="form-control" runat="server"   />
                        </td>
                        <td>
                            <asp:Button
                                ID="btnAddAttachment"
                                CssClass="btn btn-default btn-sm"
                                Text="Upload"
                                Security_Level_Disabled="10,20,30"
                                OnClick="btnAddAttachment_Click"
                                CausesValidation="true"
                                runat="server" 
                            />
                        </td>
                    </tr>
                </table>
                
                <asp:RequiredFieldValidator
                    Text="File is required" 
                    ID="reqFile" 
                    CssClass="invalid" 
                    EnableClientScript="true"
                    ControlToValidate="FileUploadAttachment"
                    Display="Dynamic" 
                    runat="server" />

                <asp:RegularExpressionValidator 
                    ID="regExFileType" 
                    CssClass="invalid"
                    EnableClientScript="true"
                    Display="Dynamic"
                    ValidationExpression="[a-zA-Z0-9\\].*(.doc|.DOC|.docx|.DOCX|.pdf|.PDF|.xls|.XLS|.xlsx|.XLSX|.jpg|.JPG|.csv|.CSV|.jpeg|.JPEG)$" 
                    ControlToValidate="FileUploadAttachment" 
                    ErrorMessage="Invalid File type" 
                    runat="server" />
                
                <asp:CustomValidator 
                    ID="cVUploadFileSize"
                    CssClass="invalid" 
                    EnableClientScript="true"
                    Display="Dynamic"
                    runat="server" 
                    ErrorMessage="Your file is too big. Maximum File Size: 4MB." 
                    ControlToValidate="FileUploadAttachment"/>


            </div>


            <!-- Current Attachments -->
            <asp:Label ID="lblAttachmentResults" runat="server" />

            <asp:DataGrid 
                ID="dgAttachment" 
                AutoGenerateColumns="false" 
                CssClass="table table-hover table-striped" 
                UseAccessibleHeader="true"
                GridLines="None"
                runat="server" >

                <Columns> 
                    <asp:TemplateColumn HeaderText="Attachment Type">
			            <ItemTemplate>

				            <%# DataBinder.Eval(Container.DataItem, "Attachment_Type_Desc")%>

			            </ItemTemplate>
		            </asp:TemplateColumn>
                    
                    <asp:TemplateColumn HeaderText="Name">
			            <ItemTemplate>

                            <asp:Label
                                runat="server"
                                ID="lblFileType"
                                Attachment_ID='<%# DataBinder.Eval(Container.DataItem, "Attachment_ID")%>'
                                Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
                                File_Name='<%# DataBinder.Eval(Container.DataItem, "File_Name")%>'
                                File_Type='<%# DataBinder.Eval(Container.DataItem, "File_Type")%>'
                                File_Desc='<%# DataBinder.Eval(Container.DataItem, "File_Desc")%>'
                                File_Path='<%# DataBinder.Eval(Container.DataItem, "File_Path")%>'
                                Attachment_Type_ID='<%# DataBinder.Eval(Container.DataItem, "Attachment_Type_ID")%>'
                                Attachment_Type_Desc='<%# DataBinder.Eval(Container.DataItem, "Attachment_Type_Desc")%>'
                                Text='<%# DataBinder.Eval(Container.DataItem, "File_Name")%>' />

			            </ItemTemplate>
		            </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="File Type">
			            <ItemTemplate>

				            <%# DataBinder.Eval(Container.DataItem, "File_Type")%>

			            </ItemTemplate>
		            </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Description">
			            <ItemTemplate>

				            <%# DataBinder.Eval(Container.DataItem, "File_Desc")%>

			            </ItemTemplate>
		            </asp:TemplateColumn>

                    <asp:TemplateColumn>
			            <ItemTemplate>

				            <asp:Button
					            ID="btnDelete"
                                Text="Delete"
                                CssClass="btn btn-default btn-xs"
					            OnClick="btnDelete_Click"
                                OnClientClick="return confirm('Are you sure you want to delete this?')"
					            Asset_Attachment_ID='<%# DataBinder.Eval(Container.DataItem, "Attachment_ID")%>'
                                File_Path='<%# DataBinder.Eval(Container.DataItem, "File_Path")%>'
                                CausesValidation="false"
					            runat="server" />

			            </ItemTemplate>
		            </asp:TemplateColumn>
                </Columns>
            </asp:DataGrid>
        </div>
    </fieldset>

        </ContentTemplate>
    <Triggers>
        <asp:PostBackTrigger ControlID="btnAddAttachment" />
    </Triggers>
</asp:UpdatePanel>