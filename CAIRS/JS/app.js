// App specific JavaScript
$(document).ready(function () {
    $('[data-toggle="tooltip"]').tooltip();

	$(document).on('keypress', '.search-autocomplete', function(e) {
		console.log(e.keyCode);
	});

	$(document).on('click', '#MainContent_passwordResetHelp', function () {
		$('#MainContent_title').text("Password Guidelines");
		$('#MainContent_passwordHelpPanel').attr('class', 'panel panel-info');
	});

	$(document).on('click', '#MainContent_Submit', function () {
		$('#confirmPopup, .modal-backdrop').hide().removeClass('in');
	});

	$(document).on('click', '.close-iframe button[data-dismiss="modal"], #popupMessage', function () {
		parent.postMessage("close", "*");
	});

	$("[data-toggle=popover]").popover({
		html: true
	});

	$(".divCheckinAttachments").on('shown.bs.collapse', function () {
		$(".divCheckinAttachments").collapse(($('.chkAddAttachment').is(':checked') ? 'show' : 'hide'));
	});

	$(".divCheckinAttachments").on('hidden.bs.collapse', function () {
		$(".divCheckinAttachments").collapse(($('.chkAddAttachment').is(':checked') ? 'show' : 'hide'));
	});

	$(".divCheckinAttachments").collapse(($('.chkAddAttachment').is(':checked') ? 'show' : 'hide'));

	$('#divViewAssignAssets').on('shown.bs.modal', function () {
		$('#cph_Body_txtTagIdAdd_txtTagID').focus();
	});

	// Asp.NET UpdatePanel apply jQuery fix (pass function in add_endRequest() method)
	Sys.WebForms.PageRequestManager.getInstance().add_endRequest(iePlaceholderFix);
});


function disableControl(id) {
	if (id != null) {
		id.disabled = true;
	}
}


// Placeholder fix for IE
function iePlaceholderFix() {
	$.placeholder.shim()
}

function DisplayProgressLoader() {
    $('#divLoading').modal();
}

function ConfirmTransferAsset() {
    if (Page_ClientValidate("vgTransferAsset")) {
        if (confirm('Are you sure you want to transfer this asset?')) {
            DisplayProgressLoader();
            return true;
        }
    }
    return false;
}

function ShowModal(modal_id) {
    $("#" + modal_id).modal();
}

function CloseModal(modal_id) {
    $("#" + modal_id).modal('hide');
}

function ScrollToDiv(div_id) {
    document.getElementById(div_id).scrollIntoView();
}

function GetQueryStringValue(key) {
    return decodeURIComponent(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURIComponent(key).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));
}