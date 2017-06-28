<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" AutoEventWireup="true" CodeBehind="LostStolenAssetPage.aspx.cs" Inherits="CAIRS.Pages.LostStolenAssetPage" EnableEventValidation="false" %>

<%@ Register Src="~/Controls/DDL_Site.ascx" TagName="DDL_Site" TagPrefix="UC" %>
<%@ Register Src="~/Controls/LOOKUP_Student.ascx" TagName="LookUp_Student" TagPrefix="UC" %>
<%@ Register Src="~/Controls/StudentInfoControl.ascx" TagName="Student_Info" TagPrefix="UC" %>
<%@ Register Src="~/Controls/DDL_AssetDisposition.ascx" TagName="DDL_AssetDisposition" TagPrefix="UC" %>
<%@ Register Src="~/Controls/AddAssetAttachment.ascx" TagName="Add_Attachment" TagPrefix="UC" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph_Body" runat="server">
    <div>
        <span class="h1">Lost / Stolen</span>
        <asp:Label runat="server" ID="lblSuccessfullySubmitted" CssClass="text-success" Visible="false" Text="Successfull Submitted"></asp:Label>
    </div>
    <hr />
    <div>
        <table>
            <tr>
                <td style="vertical-align:top;">
                    <table>
                        <tr>
                            <td>
                                Processing Site: 
                            </td>
                            <td style="width:10px"></td>
                            <td style="width:500px;">
                                <UC:DDL_Site runat="server" ID="ddlSite" ValidationGroup="vgProcessLostStolen" AutoPostBack="true" />
                                <div>
                                    <asp:CustomValidator runat="server" ID="cvCheckInValidator" ValidationGroup="vgProcessLostStolen" CssClass="invalid"></asp:CustomValidator>
                                </div>
                            </td>
                        </tr>
                        <tr runat="server" id="trStudentLookup">
                            <td colspan="3">
                                <UC:LookUp_Student runat="server" ID="txtStudentLookup" IsStudentLookupRequired="true" ValidationGroup="vgSearchStudent" btnSearchStudentClick="btnStudentSearch_Click" SetFocusOnTextBox="true" />
                            </td>
                        </tr>
                    </table>
                </td>
                <td style="width:50px"></td>
                <td style="vertical-align:top;">
                    <div id="divStudentInfo" runat="server" visible="false">
                        <UC:Student_Info runat="server" ID="Student_Info" />
                    </div>
                </td>
            </tr>
        </table>
    </div>

    <div id="divCurrentlyAssigned" runat="server" visible="false">
        <div>
            <span class="h3">Current Assignment(s)</span>
        </div>
        <hr />
        <div>
            <asp:Label runat="server" ID="lblResults"></asp:Label>
            <asp:DataGrid 
                runat="server" 
                ID="dgAssignment" 
                AutoGenerateColumns="false" 
                CssClass="table table-hover table-responsive" 
                GridLines="None">
                <Columns>
                    <asp:TemplateColumn HeaderText="School Year">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "School_Year")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="School">
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
                    <asp:TemplateColumn HeaderText="Check Out Condition">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Check_Out_Asset_Condition_Desc")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
                    <asp:TemplateColumn HeaderText="Check Out Date">
				        <ItemTemplate>
					        <%# DataBinder.Eval(Container.DataItem, "Date_Check_Out_Formatted")%>
				        </ItemTemplate>
			        </asp:TemplateColumn>
                    <asp:TemplateColumn>
				        <ItemTemplate>
					        <asp:Button
						        runat="server"
						        ID="btnProcessLostStolen"
                                CssClass="btn-primary"
                                Asset_Site_ID='<%# DataBinder.Eval(Container.DataItem, "Asset_Site_ID")%>'
						        Asset_Student_Transaction_ID='<%# DataBinder.Eval(Container.DataItem, "ID")%>'
                                CausesValidation="true"
                                ValidationGroup="vgProcessLostStolen"
                                Text='Lost / Stolen'
						        OnClick="btnProcessLostStolen_Click" />
				        </ItemTemplate>
			        </asp:TemplateColumn>
                </Columns>
            </asp:DataGrid>
        </div>
    </div>

     <!-- Bootstrap Modal Dialog -->
    <div class="modal fade" id="popupLostStolen" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div>
                <div class="panel panel-info" runat="server" id="modalTitle">
                <div class="panel-heading">
                    <button type="button" class="close" data-dismiss="modal"><span class="material-icons">cancel</span></button>
                    <h4 class="modal-title">
                        <asp:Label ID="lblModalTitle" runat="server" Text=""></asp:Label></h4>
                </div>
                <div class="panel-body">
                    <div id="divStudentLostStolenInfo" runat="server">
                        <table>
                            <tr>
                                <td colspan="2" class="h2">
                                    Check Out Info
                                    <hr />
                                </td>
                            </tr>
                            <tr>
                                <td>Student ID:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblStudentID_astDetail" data_column="Student_ID"></asp:Label>
                                    <asp:HiddenField runat="server" ID="hdnAssetStudentTransactionID" Value="ID" />
                                </td>
                            </tr>
                            <tr>
                                <td>Student Name:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblStudentName_astDetail" data_column="Student_Name"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Tag ID:</td>
                                <td>
                                    <asp:Label runat="server" ID="Label9" data_column="Tag_ID"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Serial #:</td>
                                <td>
                                    <asp:Label runat="server" ID="Label10" data_column="Serial_Number"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Base Type:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblBaseType_astDetail" data_column="Asset_Base_Type_Desc"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Asset Type:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblAssetType_astDetail" data_column="Asset_Type_Desc"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Student School:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblStudentSchool" data_column="Student_School_Name"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Check Out School Year:</td>
                                <td>
                                    <asp:Label runat="server" ID="Label7" data_column="School_Year"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Check Out By:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblCheckOutBy" data_column="Check_Out_By_Emp_Name"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Check Out Condition:</td>
                                <td>
                                    <asp:Label runat="server" ID="Label8" data_column="Check_Out_Asset_Condition_Desc"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Check Out Date:</td>
                                <td>
                                    <asp:Label runat="server" ID="Label6" data_column="Date_Check_Out_Formatted"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" class="h2">
                                    <hr />
                                    Lost / Found Info
                                    <hr />
                                </td>
                            </tr>
                            <tr>
                                <td>Disposition:</td>
                                <td>
                                    <UC:DDL_AssetDisposition runat="server" ID="ddlDisposition" ValidationGroup="vgLostStolen" AutoPostBack="true" IsAssetDispositionRequired="true" />
                                </td>
                            </tr>
                            <tr runat="server" id="trPoliceReportProvided" visible="false">
                                <td></td>
                                <td>
                                    <asp:CheckBox runat="server" ID="chkPoliceReportProvided" Text="&nbsp;&nbsp;Police Report Provided?" />
                                </td>
                            </tr>
                            <tr>
                                <td>Comments:</td>
                                <td>
                                    <asp:TextBox runat="server" ID="txtComments" TextMode="MultiLine" Width="500px" Height="100px"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" class="h4">
                                    <br />
                                    Add Attachments
                                    <hr />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <UC:Add_Attachment runat="server" ID="uc_AddAttachment_LostStolen" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                    <asp:Button 
                        ID="btnSubmitLostStolen" 
                        CausesValidation="true" 
                        CssClass="btn btn-default" 
                        runat="server" 
                        ValidationGroup="vgLostStolen" 
                        OnClick="btnSubmitLostStolen_Click" 
                        Text="Submit" 
                        OnClientClick="return confirm('Are you sure you want to submit this asset as Lost or Stolen?')"/>
                </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
