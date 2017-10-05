<%@ Page Title="CAIRS - Asset Follow-up" Language="C#" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" AutoEventWireup="true" CodeBehind="AssetFollowUpPage.aspx.cs" Inherits="CAIRS.Pages.AssetFollowUpPage" ValidateRequest="false"%>

<%@ Register Src="~/Controls/DDL_Site.ascx" TagName="DDL_Site" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AssetDisposition.ascx" TagName="DDL_AssetDisposition" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AssetCondition.ascx" TagName="DDL_AssetCondition" TagPrefix="UC" %>
<%@ Register Src="~/Controls/TXT_TagID.ascx" TagName="Tag_ID" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_Bin.ascx" TagName="DDL_Bin" TagPrefix="UC" %>
<%@ Register Src="~/Controls/TXT_SerialNumber.ascx" TagName="Serial_Number" TagPrefix="UC" %>
<%@ Register Src="~/Controls/AddAssetAttachment.ascx" TagName="Add_Attachment" TagPrefix="UC" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Add Asset specific javascript -->
	<script src="../js/assetFollowUp.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph_Body" runat="server">
    <asp:UpdatePanel runat="server" ID="updatePanelAssetFollowup">
        <ContentTemplate>
        
            <h1>Asset Follow-up</h1>

            <!-- Filters Container -->
            <div id="divFilters">
                <div class="row">

                    <div class="col-sm-6">

                       <div class="form-group">
                            <UC:DDL_Site ID="ddlSite" SelectedIndexChanged_DDL_Site="SelectedIndexChangedDDLSite" runat="server" />
                       </div>
               
                       <div class="form-group">
               
                           <UC:DDL_AssetDisposition ID="ddlAssetDisposition" runat="server"/>
                    
                        </div>
                    </div>

                    <div class="col-sm-6">

                        <div class="form-group">
                    
                            <UC:Tag_ID ID="txtTagID" IsTagIDRequired="false" runat="server" />
                
                        </div>

                        <div class="form-group">
                    
                            <UC:Serial_Number runat="server" ID="txtSerialNumber" IsSerialNumRequired="false" />
                    
                        </div>
                    </div>

                    <div class="col-sm-6">

                        <asp:Button 
                            ID="btnApplyFilters" 
                            Text="Apply Filters" 
                            OnClick="btnApplyFilters_Click" 
                            CausesValidation="false"
                            CssClass="btn btn-default" 
                            runat="server"/>
            
                    </div>
                </div>

            </div>

           
            <asp:Label 
                runat="server"
                Visible="false"
                ID="lblSiteMismatchLegend"
                Text="* Site Mismatch"
                BackColor="LightPink"
                >
            </asp:Label>
                

             <br />

            <!-- Asset Search Results Header -->
            <div runat="server" id="divGrid" visible="false">

                <div class="navbar navbar-default navbar-table" runat="server" id="divHeaderGridInfo" >
                    <ul class="nav navbar-nav">
          
                    </ul>
                </div>

                <!-- Asset Search Results Details -->
	            <asp:DataGrid 
		            ID="dgAssetResults" 
		            CssClass="table table-hover table-striped table-border" 
		            AutoGenerateColumns="false"
		            AllowPaging="true"
		            AllowSorting="true"
		            PagerStyle-Mode="NumericPages"
		            PagerStyle-CssClass="pagination"
                    OnItemDataBound="dgAssetResults_ItemDataBound"
                    OnPageIndexChanged="dgAssetResults_PageIndexChanged"
                    OnSortCommand="dgAssetResults_SortCommand"
		            PageSize="15"
                    UseAccessibleHeader="true" 
		            runat="server" >
		        <Columns>
            
                    <asp:TemplateColumn SortExpression="Asset_Site_Desc" HeaderText="Site Asset">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Asset_Site_Desc")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn SortExpression="Bin_Site_Desc" HeaderText="Site Bin">
				        <ItemTemplate>

                            <asp:Label 
                                runat="server" 
                                ID="lblSiteBin" 
                                Text='<%# DataBinder.Eval(Container.DataItem, "Bin_Site_Desc")%>'
                                Asset_Site_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_ID")%>'
                                Bin_Site_ID='<%# DataBinder.Eval(Container.DataItem, "Bin_Site_ID")%>'
                                >
                            </asp:Label>

				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn SortExpression="Asset_Disposition_Desc" HeaderText="Disposition">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Asset_Disposition_Desc")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>

			        <asp:TemplateColumn HeaderText="Tag ID" SortExpression="Tag_ID">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>

                    <asp:TemplateColumn HeaderText="Serial #" SortExpression="Serial_Number">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Serial_Number")%>
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
			
			        <asp:TemplateColumn SortExpression="Student_Assigned_To_And_ID" HeaderText="Student">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Student_Assigned_To_And_ID")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>

			        <asp:TemplateColumn>
				        <ItemTemplate>

					        <asp:Button 
						        runat="server" 
						        ID="btnFollowUp" 
						        CssClass="btn btn-primary btn-xs"
                                Student_Name='<%# DataBinder.Eval(Container.DataItem, "Student_Assigned_To_And_ID")%>'
                                Asset_Site_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_ID")%>'
                                Asset_Student_Transaction_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_Student_Transaction_ID")%>'
						        Asset_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_ID")%>'
                                Asset_Disposition_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_Disposition_ID")%>'
                                Asset_Disposition_Desc='<%# DataBinder.Eval(Container.DataItem, "Asset_Disposition_Desc")%>'
                                Tag_ID='<%# DataBinder.Eval(Container.DataItem, "Tag_ID")%>'
						        CausesValidation="false" 
						        Text="Follow-up" 
						        OnClick="btnFollowUp_Click"/>

				        </ItemTemplate>
			        </asp:TemplateColumn>

		        </Columns>
	        </asp:DataGrid>

                <!-- Asset Search Result Totals -->
                <asp:Label ID="lblResults" CssClass="label label-default pull-right" runat="server" />
    
            </div>
            <!-- No Results -->
	        <asp:Label id="alertAssetSearchResults" class="alert alert-danger col-xs-12" runat="server">No assets found.</asp:Label>

        </ContentTemplate>
    </asp:UpdatePanel>

   
    <!-- START FOLLOWUP  MODAL -->
	<div class="modal fade" id="popupFollowUp" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog" role="document">
            <asp:UpdatePanel runat="server" ID="panelFollowUpModal" UpdateMode="Conditional">
                <ContentTemplate>
			        <div class="panel panel-info" runat="server" id="modalTitle">

				        <div class="panel-heading">

					        <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>

					        <h4 class="modal-title">
                                <asp:Label runat="server" ID="lblModalFollowupTitle"></asp:Label>
					        </h4>

				        </div>

				        <div class="panel-body">
                            <asp:HiddenField runat="server" ID="hdn_Asset_ID" />
                            <asp:HiddenField runat="server" ID="hdn_Asset_Student_Transaction_ID" />
                            <asp:HiddenField runat="server" ID="hdn_Student_Name" />
                            <asp:HiddenField runat="server" ID="hdn_Asset_Site_ID" />
                            <asp:HiddenField runat="server" ID="hdn_Disposition_ID" />
                            <asp:HiddenField runat="server" ID="hdn_Disposition_Desc" />
                            <asp:HiddenField runat="server" ID="hdn_Tag_ID" />
                            
                            <!--START Unidentified Followup-->

                            <div runat="server" id="divUnidentifiedFollowup">
    
                                <asp:Label runat="server" ID="lblAssetBelongToStudent"></asp:Label>

                                <asp:CustomValidator 
                                    runat="server" 
                                    ID="cvRadLstAssetBelongToStudent" 
                                    Display="Dynamic"
                                    Text="Required"
                                    CssClass="invalid"
                                    ErrorMessage="Required">
                                </asp:CustomValidator>

                                <asp:RadioButtonList 
                                    runat="server" 
                                    ID="radLstAssetBelongToStudent" 
                                    OnSelectedIndexChanged="radLstAssetBelongToStudent_SelectedIndexChanged" 
                                    AutoPostBack="true"
                                    RepeatDirection="Horizontal"
                                >
                                    <asp:ListItem Text="&nbsp;&nbsp;Yes&nbsp;&nbsp;&nbsp;" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="&nbsp;&nbsp;No" Value="0"></asp:ListItem>
                                </asp:RadioButtonList>

                                
                                <div class="alert alert-info" runat="server" id="divMsgNoSelectedForAssetBelongToStudent">
                                    <asp:Label runat="server" ID="lblMsgNoSelectedforAssetBelongToStudent"></asp:Label>
                                </div>

                                <span runat="server" id="spNewTag">
                                    Will this asset be assigned a new Tag ID?

                                    <asp:CustomValidator 
                                        runat="server" 
                                        ID="cvNewTagId" 
                                        Display="Dynamic"
                                        Text="Required"
                                        CssClass="invalid"
                                        ErrorMessage="Required">
                                    </asp:CustomValidator>

                                    <asp:RadioButtonList 
                                        runat="server" 
                                        ID="radAssignedNewTagID" 
                                        OnSelectedIndexChanged="radAssignedNewTagID_SelectedIndexChanged" 
                                        AutoPostBack="true"
                                        RepeatDirection="Horizontal"
                                    >
                                        <asp:ListItem Text="&nbsp;&nbsp;Yes&nbsp;&nbsp;&nbsp;" Value="1"></asp:ListItem>
                                        <asp:ListItem Text="&nbsp;&nbsp;No" Value="0"></asp:ListItem>
                                    </asp:RadioButtonList>
                                    
                                    <UC:Tag_ID ID="txtNewTagID" IsTagIDRequired="true" runat="server" ValidationGroup="vgSubmitFollowup" />

                                    <asp:CustomValidator 
                                        runat="server" 
                                        ID="cvDuplicateTagId" 
                                        Display="Dynamic"
                                        Text="This Tag ID already exist. Please chose another one"
                                        CssClass="invalid"
                                        ErrorMessage="This Tag ID already exist. Please chose another one">
                                    </asp:CustomValidator>
                                </span>
                            </div>

                            <!--END Unidentified Followup-->
                            <div runat="server" id="divStandardFollowup">

                                <div class="form-group">
                                    <asp:Label runat="server" ID="lblAsset_Stored_Site"></asp:Label>
                                </div>

					            <div class="form-group">
						            <UC:DDL_AssetDisposition runat="server" ID="ddlDisposition_Followup" IsAssetDispositionRequired="true" ValidationGroup="vgSubmitFollowup" AutoPostBack="true" />
					            </div>

                                <div class="form-group" id="divStudentResponsibleForBroken" runat="server">
                                    <asp:CheckBox runat="server" ID="chkIsStudentResponsibleForDamage" />
                                </div>

					            <div class="form-group">
						            <UC:DDL_AssetCondition runat="server" ID="ddlCondition_Followup" IsAssetConditionRequired="true" ValidationGroup="vgSubmitFollowup" />
					            </div>

					            <div class="form-group">
						            <UC:DDL_Bin runat="server" ID="ddlBin_Followup" IsBinRequired="true" ValidationGroup="vgSubmitFollowup"/>
					            </div>

					            <div class="form-group">
						            <asp:TextBox runat="server" ID="txtComments_Followup" CssClass="form-control" Placeholder="Comment" TextMode="MultiLine" />
					            </div>

                                <div class="form-group">
					                <UC:Add_Attachment runat="server" ID="uc_AddAttachment_Followup" />
                                </div>

                            </div>

                           
				        </div>

				        <div class="modal-footer">

				        <asp:Button 
					        ID="btnSubmitFollowup"
					        Text="Submit" 
					        CssClass="btn btn-default" 
					        OnClick="btnSubmitFollowup_Click" 
					        OnClientClick="return ValidateUploadDocument();"
					        CausesValidation="true" 
					        ValidationGroup="vgSubmitFollowup" 
					        runat="server" />

				        <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

			        </div>
                
			        </div>
		        </ContentTemplate>
            </asp:UpdatePanel>

        </div>
	</div>
    <!-- END FOLLOWUP  MODAL -->


    <!-- MARK RECEIVED Bootstrap Modal Dialog -->
    <div class="modal fade" id="popupStartFoundProcessModal" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-class">
            <div class="panel panel-info" runat="server" id="Div1">

                <div class="panel-heading">
                    <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                    <h4 class="modal-title">
                        <asp:Label ID="Label1" runat="server" Text="Start Found Process" />
                    </h4>
                </div>

                <div class="panel-body">
                    Do you want to start the “Found Process” for the previously unidentified asset in hand?
                </div>

                <div class="modal-footer">
                    
                    <asp:Button 
                        ID="btnStartFoundProcess" 
                        Text="Yes" 
                        CssClass="btn btn-default"
                        OnClick="btnStartFoundProcess_Click" 
                        runat="server" />
                   
                    <button class="btn" data-dismiss="modal" aria-hidden="true">No</button>

                </div>

            </div>
        </div>
            
    </div>

    <script>
        function ValidateUploadDocument() {
            var fuData = document.getElementById("cph_Body_uc_AddAttachment_Followup_FileUploadAttachment");
            var FileUploadPath = fuData.value;
            if (FileUploadPath != '') {
                alert("You selected a file but did not upload. Please upload your document before submitting.");
                return false;
            }
            return confirm('Are you sure you want to save these changes?');
        }
    </script>

</asp:Content>
