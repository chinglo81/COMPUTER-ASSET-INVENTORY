<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AddAssetAttachment.ascx.cs" Inherits="CAIRS.Controls.AddAssetAttachement" %>
<asp:UpdatePanel runat="server" ID="updateAttachment" UpdateMode="Conditional">
    <ContentTemplate>

    

<asp:HiddenField runat="server" ID="hdnAssetId" />
<asp:HiddenField runat="server" ID="hdnAssetTamperID" />

<!-- Checkbox to toggle add attachment form -->
<label id="lblAddAttachment" runat="server">
    <input 
        id="chkAddAttachment" 
        name="chkAddAttachment" 
        type="checkbox" 
        class="chkAddAttachment"
        value="Add Attachments" 
        data-toggle="collapse" 
        data-target=".divCheckinAttachments" 
        aria-expanded="false" 
        aria-controls="divCheckinAttachments"
        runat="server" />
    Add Attachments
</label>

<div class="collapse divCheckinAttachments">
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

        <asp:FileUpload ID="FileUploadAttachment" CssClass="form-control" runat="server" />
        <strong>Accepted file types:</strong> jpg, jpeg, doc, docx, xls, xlsx, pdf, csv

        <asp:RequiredFieldValidator
            Text="Required" 
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

    </div>

    <div class="form-group">

        <asp:Button
            ID="btnAddAttachment"
            CssClass="btn btn-default btn-sm"
            Text="Add Attachment"
            Security_Level_Disabled="10,20,30"
            OnClick="btnAddAttachment_Click"
            CausesValidation="true"
            runat="server" />

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
            <asp:TemplateColumn HeaderText="File Name">
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
                        Text='<%# DataBinder.Eval(Container.DataItem, "File_Name")%>' />

			    </ItemTemplate>
		    </asp:TemplateColumn>

            <asp:TemplateColumn HeaderText="File Type">
			    <ItemTemplate>

				    <%# DataBinder.Eval(Container.DataItem, "File_Type")%>

			    </ItemTemplate>
		    </asp:TemplateColumn>

            <asp:TemplateColumn HeaderText="File Description">
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

        </ContentTemplate>
    <Triggers>
        <asp:PostBackTrigger ControlID="btnAddAttachment" />
    </Triggers>
</asp:UpdatePanel>