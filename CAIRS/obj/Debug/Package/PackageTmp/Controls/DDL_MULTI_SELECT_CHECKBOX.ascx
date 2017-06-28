<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DDL_MULTI_SELECT_CHECKBOX.ascx.cs" Inherits="CAIRS.Controls.DDL_MULTI_SELECT_CHECKBOX" %>

<script type="text/javascript">
    var timoutID;
    function ShowMList(id) {
        
        //var divRef = document.getElementById("divCheckBoxList");
        var divRef = document.getElementById('<%=divCheckBoxList.ClientID %>');
        divRef.style.display = "block";
        //var divRefC = document.getElementById("divCheckBoxListClose");
        var divRefC = document.getElementById('<%=divCheckBoxListClose.ClientID %>');
        divRefC.style.display = "block";
    }

    function HideMList() {
        //document.getElementById("divCheckBoxList").style.display = "none";
        document.getElementById('<%=divCheckBoxList.ClientID %>').style.display = "none";
        
        //document.getElementById("divCheckBoxListClose").style.display = "none";
        document.getElementById('<%=divCheckBoxListClose.ClientID %>').style.display = "none";
    }

    function FindSelectedItems() {
        //var cblstTable = document.getElementById(sender.id);
        var cblstTable = document.getElementById('<%=ChkBoxList.ClientID %>');
        var checkBoxPrefix = '<%=ChkBoxList.ClientID %>' + "_";
        var noOfOptions = cblstTable.rows.length;
        var selectedText = "";
        var selectedValue = "";

        //Reset All Checkbox
        document.getElementById('<%=ChkAll.ClientID %>').checked = false;
        document.getElementById('<%=txtSelectedMLText.ClientID %>').value = "";
        
        //counter use to reselect ALL if every option was selected
        var counter = 0;
        
        for (i = 0; i < noOfOptions ; ++i) {
            if (document.getElementById(checkBoxPrefix + i).checked) {
                counter = counter + 1;
                if (selectedText == "") {
                    selectedText = document.getElementById(checkBoxPrefix + i).parentNode.innerText;
                    selectedValue = document.getElementById(checkBoxPrefix + i).value;
                }
                else {
                    selectedText = selectedText + ", " + document.getElementById(checkBoxPrefix + i).parentNode.innerText;
                    selectedValue = selectedValue + "," + document.getElementById(checkBoxPrefix + i).value;
                }
            }
        }

        document.getElementById('<%=txtSelectedMLText.ClientID %>').title = selectedText;

        if (noOfOptions == counter) {
            document.getElementById('<%=ChkAll.ClientID %>').checked = true;
            SelectDeselectAll();
            selectedText = "All";
        }

        //document.getElementById(textBoxID.id).value = selectedText;
        document.getElementById('<%=txtSelectedMLText.ClientID %>').value = selectedText;
        document.getElementById('<%=hdnSelectedValue.ClientID %>').value = selectedValue;

    }

    function SelectDeselectAll()
    {
        var isCheckAll = document.getElementById('<%=ChkAll.ClientID %>').checked;

        var cblstTable = document.getElementById('<%=ChkBoxList.ClientID %>');
        var checkBoxPrefix = '<%=ChkBoxList.ClientID %>' + "_";
        var noOfOptions = cblstTable.rows.length;
        var selectedValue = "";
        var selectedText = "";

        for (i = 0; i < noOfOptions ; ++i)
        {
            //cph_Body_MDDL_test_ChkBoxList_0
            document.getElementById(checkBoxPrefix + i).checked = isCheckAll;
        }

        for (i = 0; i < noOfOptions ; ++i) {
            if (document.getElementById(checkBoxPrefix + i).checked) {
               
                if (selectedText == "") {
                    selectedText = document.getElementById(checkBoxPrefix + i).parentNode.innerText;
                    selectedValue = document.getElementById(checkBoxPrefix + i).value;
                }
                else {
                    selectedText = selectedText + ", " + document.getElementById(checkBoxPrefix + i).parentNode.innerText;
                    selectedValue = selectedValue + "," + document.getElementById(checkBoxPrefix + i).value;
                }
            }
        }

        document.getElementById('<%=txtSelectedMLText.ClientID %>').title = selectedText;

        if (isCheckAll) {
            selectedValue = "All";
        } 

        document.getElementById('<%=txtSelectedMLText.ClientID %>').value = selectedValue;
    }
</script>

<div id="divCustomCheckBoxList" runat="server" onmouseover="clearTimeout(timoutID);" onmouseout="timoutID = setTimeout('HideMList()', 750);">
    <table runat="server" id="tblDDL">
        <tr>
            <td style="text-align:right;" class="DropDownLook"> 
               <input id="txtSelectedMLText" type="text" readonly="readonly" onclick="ShowMList();" runat="server" data-toggle="tooltip" />
               <input type="hidden" id="hdnSelectedValue" runat="server" />
            </td>
            <td style="text-align:left;" class="DropDownLook">
                <img id="imgShowHide" runat="server" src="~/Images/drop.gif" onclick="ShowMList()" align="left" /> 
            </td>
        </tr>
        <tr>
            <td colspan="2">
               <div>
                   <div runat="server" id="divCheckBoxListClose" class="DivClose">
                    <label runat="server" onclick="HideMList();" class="LabelClose" id="lblClose"> x</label>
                   </div>
                   <div runat="server" id="divCheckBoxList" class="DivCheckBoxList">
                       <table>
                           <tr>
                               <td onclick="SelectDeselectAll();">
                                    <asp:CheckBox runat="server" ID="ChkAll" Text="Select All" />
                               </td>
                           </tr>
                           <tr>
                               <td style="border-top:solid; border-top-color:black">
                                    <asp:CheckBoxList ID="ChkBoxList" runat="server"></asp:CheckBoxList>
                               </td>
                           </tr>
                       </table>
                    </div>
                </div>
            </td>
        </tr>
    </table>
</div> 