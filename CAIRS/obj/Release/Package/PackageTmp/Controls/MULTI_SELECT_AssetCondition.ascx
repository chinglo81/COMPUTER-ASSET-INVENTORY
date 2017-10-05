<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MULTI_SELECT_AssetCondition.ascx.cs" Inherits="CAIRS.Controls.MULTI_SELECT_AssetCondition" %>
 <asp:HiddenField ID="hdnValues" runat="server" />

 <asp:ListBox runat="server" ID="lstBox" SelectionMode="Multiple" multiple="multiple" onchange="SetSelectedConditionValues();"></asp:ListBox>


<script type="text/javascript">
    $(document).ready(function () {
        //Set to multivalue

        $("#" + "<%=lstBox.ClientID %>").multiselect({
        	includeSelectAllOption: true,
        	nonSelectedText: 'Select Condition'
        });
    });

    function SetSelectedConditionValues() {
        var selected = $("#" + "<%=lstBox.ClientID %>" + " option:selected");
        var hdnValue = "";
        selected.each(function () {
            hdnValue += $(this).val() + ","
        });

        document.getElementById("<%=hdnValues.ClientID %>").value = hdnValue;
    }

</script>