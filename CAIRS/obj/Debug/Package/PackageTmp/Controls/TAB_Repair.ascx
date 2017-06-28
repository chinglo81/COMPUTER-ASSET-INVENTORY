<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TAB_Repair.ascx.cs" Inherits="CAIRS.Controls.TAB_Repair" %>

<%@ Register Src="~/Controls/DDL_RepairType.ascx" TagName="DDL_REPAIR_TYPE" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AssetDisposition.ascx" TagName="DDL_Disposition" TagPrefix="UC" %>
<%@ Register Src="~/Controls/TXT_Date.ascx" TagName="TXT_DATE" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_Bin.ascx" TagName="DDL_Bin" TagPrefix="UC" %>

    <asp:UpdatePanel runat="server" ID="updatePanelAssetRepairID" UpdateMode="Always">
        <ContentTemplate>
            
            <asp:HiddenField runat="server" ID="hdnAssetRepairID" />
            <asp:HiddenField runat="server" ID="hdnIsLeasedDevice" />
        
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:UpdatePanel runat="server" ID="updateAddRepair" UpdateMode="Conditional">
        <ContentTemplate>

            <asp:Label runat="server" ID="lblResults"></asp:Label>

            <asp:DataGrid 
                ID="dgRepair" 
                CssClass="table table-hover table-striped" 
                GridLines="None"
                OnItemDataBound="dgRepair_ItemDataBound"
                AutoGenerateColumns="false" 
                UseAccessibleHeader="true"
                runat="server" >

                <Columns>
                    <asp:TemplateColumn HeaderText="Repair Type">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Repair_Type_Desc")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Send Date">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Date_Sent_Formatted")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Date Received" Visible="true">
				        <ItemTemplate>

                            <asp:Label runat="server" ID="lblDateRecivedGird" Text='<%# DataBinder.Eval(Container.DataItem, "Date_Received_Formatted")%>' Visible='<%# MarkReceived(Container.DataItem)%>'></asp:Label>

                            <asp:Button
                                Visible='<%# !MarkReceived(Container.DataItem)%>'
						        ID="btnMarkRecieved"
                                Text="Mark Received"
                                CssClass="btn btn-default btn-xs"
						        OnClick="btnMarkRecieved_Click"
						        Asset_Repair_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                CausesValidation="false"
                                Security_Level_Disabled="10,20,30"
                                Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
						        runat="server" />

				        </ItemTemplate>
			        </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Received By" Visible="true">
				        <ItemTemplate>

					        <%# DataBinder.Eval(Container.DataItem, "Received_By_Emp_Name")%>

				        </ItemTemplate>
			        </asp:TemplateColumn>
                    <asp:TemplateColumn>
				        <ItemTemplate>

					        <asp:Button
						        ID="btnViewDetails"
                                Text="Details"
                                CssClass="btn btn-primary btn-xs"
						        OnClick="btnViewDetails_Click"
						        Asset_Repair_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                CausesValidation="false"
						        runat="server" />

					        <asp:Button
                                Visible='<%# ShowHideDelete(Container.DataItem)%>'
						        ID="btnDelete"
                                Text="Delete"
                                CssClass="btn btn-default btn-xs"
						        OnClick="btnDelete_Click"
                                OnClientClick="return confirm('Are you sure you want to delete this?')"
						        Asset_Repair_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                CausesValidation="false"
                                Security_Site_Code='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_Code")%>'
                                Security_Level_Disabled="10,20,30"
						        runat="server" />

				        </ItemTemplate>
			        </asp:TemplateColumn>

                </Columns>
            </asp:DataGrid>

            <br />
                <asp:LinkButton
                    ID="btnAddRepair"
                    Text="Add Repair"
                    CssClass="btn btn-default btn-sm"
                    OnClick="btnAddRepair_Click"
                    CausesValidation="false"
                    Security_Level_Disabled="10,20,30"
                    runat="server" />

                <asp:Label runat="server" ID="lblNotAllowCreateMsg" CssClass="invalid"></asp:Label>

            <div class="alert alert-info" runat="server" id="divLeasedPeriodMet">
                <asp:Label runat="server" ID="lblLeasedPeriodMet" Text="You cannot create a repair. Leased term period has been met"></asp:Label>
	        </div>

        </ContentTemplate> 
    </asp:UpdatePanel>

<!--EDIT REPAIR Bootstrap Modal Dialog -->
    <div class="modal fade" id="popupRepairDetails" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <asp:UpdatePanel runat="server" ID="updateRepairDetailModal" UpdateMode="Conditional">
            <ContentTemplate>
                <div class="modal-dialog custom-class">
            <div class="panel panel-info" runat="server" id="modalTitle">

                <div class="panel-heading">
                    <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                    <h4 class="modal-title">
                        <asp:Label ID="lblModalTitle" runat="server" Text="" />
                    </h4>
                </div>

                <div class="panel-body">
                    <div id="divAssetRepairInfo" runat="server">

                        <table class="table table-form table-valign-middle">
                            <tr>
                                <td><strong>Repair Type</strong></td>
                                <td>
                                    <asp:Label ID="lblRepairType" data_column="Repair_Type_Desc" runat="server" />
                                    <UC:DDL_REPAIR_TYPE runat="server" ID="ddlRepairType" IsRepairTypeRequired="true" ValidationGroup="vgRepair" AutoPostBack="true" />
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Bin</strong></td>
                                <td>
                                    <asp:Label ID="lblCurrentBinDesc" runat="server" />
                                    <asp:CheckBox runat="server" ID="chkAssignNewBin" Text="&nbsp;Assign New Bin" OnCheckedChanged="chkAssignNewBin_CheckedChanged" AutoPostBack="true"/>
                                    <UC:DDL_Bin runat="server" ID="ddlBin" IsBinRequired="false" ValidationGroup="vgRepair"/>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Comment</strong></td>
                                <td>
                                    <asp:TextBox ID="txtComment" CssClass="form-control" data_column="Comment" TextMode="MultiLine" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Send Date</strong></td>
                                <td>
                                    <UC:TXT_DATE runat="server" ID="txtDateSent" ValidationGroup="vgRepair" data_column="Date_Sent_Formatted"  />
                                </td>
                            </tr>
                            <tr runat="server" id="trDateReceived">
                                <td><strong>Date Received</strong></td>
                                <td>
                                    <asp:Label ID="lblDateReceived" data_column="Date_Received_Formatted" runat="server" />
                                </td>
                            </tr>
                            <tr runat="server" id="trReceivedByEmp">
                                <td><strong>Received By</strong></td>
                                <td>
                                    <asp:Label ID="lblReceivedByEmp" data_column="Received_By_Emp_Name" runat="server" />
                                </td>
                            </tr>
                            <tr runat="server" id="trAddedBy">
                                <td><strong>Added By</strong></td>
                                <td>
                                    <asp:Label ID="lblAddedBy" data_column="Added_By_Emp_Name" runat="server" />
                                </td>
                            </tr>
                            <tr runat="server" id="trDateAdded">
                                <td><strong>Date Added</strong></td>
                                <td>
                                    <asp:Label ID="lblDateAdded" data_column="Date_Added_Formatted" runat="server" />
                                </td>
                            </tr>
                            <tr runat="server" id="trModifiedBy">
                                <td><strong>Modified By</strong></td>
                                <td>
                                    <asp:Label ID="lblModifiedBy" data_column="Modified_By_Emp_Name" runat="server" />
                                </td>
                            </tr>
                            <tr runat="server" id="trDateModified">
                                <td><strong>Date Modified</strong></td>
                                <td>
                                    <asp:Label ID="lblDateModified" data_column="Date_Modified_Formatted" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>

                <div class="modal-footer">
                    
                    <asp:Button 
                        ID="btnSave" 
                        Text="Save" 
                        CssClass="btn btn-default"
                        OnClick="btnSave_Click" 
                        CausesValidation="true" 
                        ValidationGroup="vgRepair" 
                        Security_Level_Disabled="10,20,30"
                        runat="server" />
                   
                    <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

                </div>

            </div>
        </div>
            </ContentTemplate> 
        </asp:UpdatePanel>
    </div>

<!-- MARK RECEIVED Bootstrap Modal Dialog -->
    <div class="modal fade" id="popupRepairMarkReceivedModal" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <asp:UpdatePanel runat="server" ID="updatePanelMarkedReceived" UpdateMode="Conditional">
            <ContentTemplate>
                <div class="modal-dialog custom-class">
                    <div class="panel panel-info" runat="server" id="Div1">

                        <div class="panel-heading">
                            <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                            <h4 class="modal-title">
                                <asp:Label ID="Label1" runat="server" Text="Mark Received" />
                            </h4>
                        </div>

                        <div class="panel-body">

                            <UC:DDL_Disposition runat="server" ID="ddlDisposition_MarkReceived" IsAssetDispositionRequired="true" ValidationGroup="vgMarkReceived" />
                        
                        </div>

                        <div class="modal-footer">
                    
                            <asp:Button 
                                ID="btnSaveMarkReceivedModal" 
                                Text="Save" 
                                CssClass="btn btn-default"
                                OnClick="btnSaveMarkReceivedModal_Click" 
                                CausesValidation="true" 
                                ValidationGroup="vgMarkReceived" 
                                OnClientClick="return confirm('Are you sure you want to mark as received?')"
                                Security_Level_Disabled="10,20,30"
                                runat="server" />
                   
                            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>

                        </div>

                    </div>
                </div>
            </ContentTemplate> 
        </asp:UpdatePanel>
    </div>