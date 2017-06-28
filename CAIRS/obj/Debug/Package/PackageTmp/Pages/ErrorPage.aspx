<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ErrorPage.aspx.cs" Inherits="CAIRS.Pages.ErrorPage" MasterPageFile="~/MasterPages/CAIRSMasterPage.Master" MaintainScrollPositionOnPostback="true" %>
<%@ MasterType VirtualPath="~/MasterPages/CAIRSMasterPage.Master" %>

<asp:Content id="Content1" ContentPlaceHolderid="cph_Body" Runat="server">
    <div>
        <table style="width: 100%">
			<tr>
				<td>
					<table>
						<tr>
							<td class="tdSeparator">
								<asp:Label Runat="server" ID="lblTitle"></asp:Label>
							</td>
						</tr>
						<tr>
							<td>
								<table>
									<tr>
										<td style="width: 600px">
											<asp:Label Runat="server" ID="lblInstructions"></asp:Label>
										</td>
									</tr>
									<tr>
										<td>
											<asp:TextBox Runat="server" ID="txtDescription" width="600px" height="200px" TextMode="MultiLine"></asp:TextBox>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<table>
						<tr>
							<td style="width: 213px">
								<asp:LinkButton Runat="server" ID="lnkBtnSend" OnClick="lnkBtnSend_Click"> Submit Feedback
							</asp:LinkButton>&nbsp;
							</td>
							<td>
								<asp:LinkButton Runat="server" ID="lnkBtnHome" OnClick="lnkBtnHome_Click">
								Don't 
								submit. Return To Application
							</asp:LinkButton>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
    </div>
</asp:Content>
