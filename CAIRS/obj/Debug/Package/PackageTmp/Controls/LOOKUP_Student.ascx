<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="LOOKUP_Student.ascx.cs" Inherits="CAIRS.Controls.LOOKUP_Student" ValidateRequestMode="Disabled" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajax" %>

<asp:HiddenField runat="server" ID="hdnSelectedStudent" />
<asp:HiddenField runat="server" ID="hdnSelectedStudentDesc" />

<div id="divSearchType" runat="server">

    <asp:RadioButtonList runat="server" ID="radList" CssClass="spaced" RepeatDirection="Horizontal"> 
        <asp:ListItem Text="All" Value="1"></asp:ListItem>
        <asp:ListItem Selected="True" Text="Active" Value="2"></asp:ListItem>
        <asp:ListItem Text="Inactive" Value="3"></asp:ListItem>
    </asp:RadioButtonList>

</div>

<div runat="server" id="divSearchStudent" class="row">

    <div class="col-xs-7">

        <asp:TextBox 
            ID="txtStudentLookup" 
            CssClass="form-control" 
            placeholder="Student ID or Student Last, First Name" 
            onkeyup="SetContextKey()" 
            runat="server" />

        <ajax:AutoCompleteExtender
            ID="acxStudentLookup"
            TargetControlID="txtStudentLookup"
            CompletionInterval="100" 
            EnableCaching="false"
            ServiceMethod="GetStudentName"
            UseContextKey="false"
            OnClientItemSelected="OnSelectedStudent"
            OnClientPopulated="OnPopulatedStudent"
            FirstRowSelected="true"
            OnClientShowing="clientShowing"
			CompletionListCssClass="search-autocomplete"
            ShowOnlyCurrentWordInCompletionListItem="true"
            MinimumPrefixLength="2" 
            runat="server" />

        <asp:LinkButton ID="lnkModalReturn" OnClick="lnkModalReturn_Click" Runat="server" />

    </div>

    <div class="col-xs-2">

        <asp:Button ID="btnSearch" CssClass="btn btn-default" Text="Search" OnClick="btnSearch_Click" ValidationGroup="vgStudentlookupSearch" runat="server" />

    </div>

</div>

<div id="divStudentSelected" runat="server">

    <asp:Label runat="server" ID="lblSelectedEmployee" />

    <asp:Button runat="server" ID="btnChangeStudent" Text ="Lookup Student" OnClick="btnChangeStudent_Click" CssClass="btn" UseSubmitBehavior="false" />

</div>

<div>
    <asp:Label runat="server" ID="lblResults" CssClass="invalid" />

    <asp:RequiredFieldValidator runat="server" ID="reqStudentId" CssClass="invalid" ControlToValidate="txtStudentLookup" EnableClientScript="false" Display="Dynamic" ValidationGroup="vgStudentlookupSearch" Text="Required" />

    <asp:RequiredFieldValidator runat="server" ID="reqStudentLook" CssClass="invalid" ControlToValidate="txtStudentLookup" EnableClientScript="false" Display="Dynamic" Text="Required" />
</div>

<script>
    function clientShowing(source, args) {
        source._popupBehavior._element.style.zIndex = 100000;
    }

    function SetFocusOnTextBox() {
        document.getElementById('<%= txtStudentLookup.ClientID %>').focus();
    }
    function SetContextKey() {
        var selectedvalue = $('#<%= radList.ClientID %> input:checked').val()
        $find('<%=acxStudentLookup.ClientID %>').set_contextKey(selectedvalue);
    }

    function OnSelectedStudent(source, eventArgs) {

        var selectedStudentID = eventArgs.get_value();
        var selectedText = eventArgs.get_text();

        if (selectedStudentID == null || selectedStudentID == "") {
            if (selectedText != null) {
                selectedStudentID = selectedText.substring(0, selectedText.indexOf("-"));
            }
        }

        var hdnStudentID = document.getElementById('<%= hdnSelectedStudent.ClientID %>');

        hdnStudentID.value = selectedStudentID.trim();
       __doPostBack('<%= btnSearch.ClientID %>', '');

         <%--document.getElementById("cph_Body_tabTamper_txtStudentLookup_btnSearch").click();--%>

    }

    function OnPopulatedStudent(sender, e) {
        var searchList = sender.get_completionList().childNodes;
        var searchText = sender.get_element().value;
        for (var i = 0; i < searchList.length; i++) {
            var search = searchList[i];
            var text = search.innerText;
            search.innerHTML = text;
        }
    }

    $(document).ready(function () {
        // Add Asset - Capture enter fire from scanner, refocus to Tag ID
        $('#' + '<%= txtStudentLookup.ClientID %>').on('keypress', function (e) {
            if (e.keyCode == 35 || e.keyCode == 59) {
                HandleNumberEnteredStudentTxt(e)
            }
        });


        function HandleNumberEnteredStudentTxt(e) {
            if (e.keyCode == 35 || e.keyCode == 59) {
                e.preventDefault();

                $('#' + '<%= btnSearch.ClientID %>').focus().click();
            }
        }

    });

</script>