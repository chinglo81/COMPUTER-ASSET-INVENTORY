// App specific JavaScript

function calcPosition(target) {
	var op = $(target).offsetParent().offset();
	var ot = $(target).offset();

	return {
		top: ot.top - op.top,
		left: ot.left - op.left,
		width: $(target).width()
	};
}


$(document).ready(function () {

	$(document).on('submit', 'form', function () {
		if (typeof Page_IsValid !== 'undefined' && !Page_IsValid) {
			$('.placeholder').each(function () {
				$(this).css(calcPosition('#' + $(this).attr('for')));
			});
		}
	});

	$(document).on('change', 'select', function () {
		$('.placeholder').each(function () {
			$(this).css(calcPosition('#' + $(this).attr('for')));
		});
	});

	$('[data-toggle="tooltip"]').tooltip();

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