// Add Asset specific JavaScript
$(document).ready(function () {

	// Add Asset - Capture enter fire from scanner, refocus to Tag ID
	$(document).on('keypress','#cph_Body_serialNumberTemp', function (e) {
	    if (e.keyCode == 35 || e.keyCode == 13 || e.keyCode == 59) {
			e.preventDefault();
			$('#cph_Body_tagIDTemp').focus();
		}
	});

	// Add Asset - Capture enter fire from scanner, refocus to Add Asset button
	$(document).on('keypress','#cph_Body_tagIDTemp', function (e) {
	    if (e.keyCode == 35 || e.keyCode == 13 || e.keyCode == 59) {
			e.preventDefault();
			submitAddAsset();
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
	serialNum = $('#cph_Body_serialNumberTemp').val();
	tagID = $('#cph_Body_tagIDTemp').val();

	$('#cph_Body_txt_SerialNum_txtSerialNumber').val(serialNum);
	$('#cph_Body_txt_TagID_txtTagID').val(tagID);

	$('#cph_Body_btnAddAsset').focus().click();

	$('#cph_Body_serialNumberTemp').val('');
	$('#cph_Body_tagIDTemp').val('');

	$('#cph_Body_serialNumberTemp').focus();

	return false;
}