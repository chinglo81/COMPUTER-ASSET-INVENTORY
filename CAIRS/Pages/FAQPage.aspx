<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" AutoEventWireup="true" CodeBehind="FAQPage.aspx.cs" Inherits="CAIRS.Pages.FAQPage" EnableEventValidation="false" %>
<%@ Register TagPrefix="ajax" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit" %>
<%@ Register assembly="FreeTextBox" namespace="FreeTextBoxControls" tagprefix="FTB" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Add specific javascript -->
	<script src="../js/FAQ.js"></script>
    <script src="../ckeditor.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph_Body" runat="server">
    <asp:UpdatePanel runat="server" ID="pnlUpdateFAQ" UpdateMode="Always">
        <ContentTemplate>

       
         <h1>Frequently Asked Questions</h1>

        <%-- Add Questions & Subscribe Buttons --%>
        <div class="form-inline pull-right">
            <button type="button" id="btnSubscribe" class="btn btn-xs btn-warning pull-right valign-center" title="Email Notifications on New Posts: Subscribe/Unsubscribe"><i class="material-icons">rss_feed</i>&nbsp;Subscribe</button>
            <button type="button" id="btnAddNewQandA" class="btn btn-xs btn-primary pull-right valign-center" style="margin-right: 6px;" title="Create a New Q and A"><i class="material-icons">add_circle_outline</i>&nbsp;Add New</button>
    
            <asp:Button runat="server" ID="btnHdnSubscribe" OnClick="btnHdnSubscribe_Click" Style="display:none;" />
            <asp:Button runat="server" ID="btnHdnAddNewQandA" OnClick="btnHdnAddNewQandA_Click" Style="display:none;" />
        </div>

        <div runat="server" id="divFAQ"></div>

          

     </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Manage Q and A Dialog -->
    <div class="modal fade" id="divManageQandADialog" role="dialog" aria-hidden="true">
        <div class="modal-dialog custom-class" style="width: 70%">
            <asp:UpdatePanel runat="server">
                <ContentTemplate>
                    <div class="panel panel-primary" runat="server" id="Div1">
                        <div class="panel-heading">
                            <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                            <h4 class="modal-title">
                                <asp:Label ID="lblManageQandATitleModal" runat="server" ></asp:Label>
                            </h4>
                        </div>
                        <div class="panel-body">
                            <FTB:FreeTextBox 
                                ID="ApplicationNotes" 
                                runat="server" 
                                ButtonSet="Office2003" 
                                Width="100%" 
                                Height="200px" 
                                ToolbarLayout="ParagraphMenu,FontFacesMenu,FontSizesMenu,FontForeColorsMenu|Bold,Italic,Underline,Strikethrough;Superscript,Subscript,RemoveFormat|JustifyLeft,JustifyRight,JustifyCenter,JustifyFull;BulletedList,NumberedList,Indent,Outdent;CreateLink,Unlink|Cut,Copy,Paste;Undo,Redo">
                            </FTB:FreeTextBox>

                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                            <asp:Button ID="btnSave" runat="server" CssClass="btn btn-default" OnClick="btnSave_Click" UseSubmitBehavior="false" OnClientClick="this.disabled=true; this.value='Processing...';" />
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
    <!--  Manage Q and A Dialog -->

</asp:Content>
