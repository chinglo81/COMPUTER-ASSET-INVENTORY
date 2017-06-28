<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MULTI_SELECT_AssetDisposition.ascx.cs" Inherits="CAIRS.Controls.MULTI_SELECT_AssetDisposition" %>

<asp:HiddenField ID="hdnValues" runat="server" />

<asp:ListBox runat="server" ID="lstBox" SelectionMode="Multiple" multiple="multiple" onchange="SetSelectedDispositionValues();"></asp:ListBox>


<script type="text/javascript">
    $(document).ready(function () {
        //Set to multivalue

        $("#" + "<%=lstBox.ClientID %>").multiselect({
        	includeSelectAllOption: true,
        	nonSelectedText: 'Select Disposition'
        });
    });

    function SetSelectedDispositionValues() {
        var selected = $("#" + "<%=lstBox.ClientID %>" + " option:selected");
        var hdnValue = "";
        selected.each(function () {
            hdnValue += $(this).val() + ","
        });

        document.getElementById("<%=hdnValues.ClientID %>").value = hdnValue;
    }

</script>