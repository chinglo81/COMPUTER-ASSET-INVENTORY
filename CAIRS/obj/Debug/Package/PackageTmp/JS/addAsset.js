// Add Asset specific JavaScript
$(document).ready(function () {

	// Add Asset - Capture enter fire from scanner, refocus to Tag ID
	$(document).on('keypress','#cph_Body_serialNumberTemp', function (e) {
	    if (e.keyCode == 35 || e.keyCode == 13 || e.keyCode == 59) {
	        e.preventDefault();
	        submitAddAsset();
		}
	});

	// Add Asset - Capture enter fire from scanner, refocus to Add Asset button
	$(document).on('keypress','#cph_Body_tagIDTemp', function (e) {
	    if (e.keyCode == 35 || e.keyCode == 13 || e.keyCode == 59) {
	        e.preventDefault();

	        var selectedBaseType = $("select#cph_Body_ddlBaseType_ddlAssetBaseType option").filter(":selected").val();
	        var txtSerialNum = $('#cph_Body_serialNumberTemp');
	        var txtTagId = $("#cph_Body_tagIDTemp");

	        if (selectedBaseType == "3") {
	            //set serial to tag id
	            txtSerialNum.val(txtTagId.val());
	            submitAddAsset();
	        }
	        else {
	            txtSerialNum.focus();
	        }
		}
	});

	$(document).on('click', '#cph_Body_btnAddAssetTemp', function (e) {
	    if (e.keyCode == 35 || e.keyCode == 13 || e.keyCode == 59) {
			e.preventDefault();
		}
		submitAddAsset();
	});

	$('#popupSubmitSuccessMessage').on('hidden.bs.modal', function (e) {
		$('#cph_Body_BtnOkSubmitSuccess').focus().click();
	})

});

function submitAddAsset() {

    var IsSubmitSuccess = Page_ClientValidate("vgAddAsset");
    var serialNum = $('#cph_Body_serialNumberTemp');
    var tagID = $('#cph_Body_tagIDTemp');
    var btnAddAsset = $('#cph_Body_btnAddAsset');

    $('#cph_Body_txt_SerialNum_txtSerialNumber').val(serialNum.val());
    $('#cph_Body_txt_TagID_txtTagID').val(tagID.val());

    var selectedBaseType = $("select#cph_Body_ddlBaseType_ddlAssetBaseType option").filter(":selected").val();
    
    btnAddAsset.focus().click();

    if (tagID.val().trim().length == 0) {
        tagID.focus();
        IsSubmitSuccess = false;
    }

    if (selectedBaseType != "3" && serialNum.val().trim().length == 0) {
        serialNum.focus();
        IsSubmitSuccess = false;
    }

    if (IsSubmitSuccess) {
        tagID.val("");
        serialNum.val("");
        tagID.focus();
    }



    return false;
}