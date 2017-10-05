// Asset Followup specific JavaScript
$(document).ready(function () {

    // Add Asset - Capture enter fire from scanner, refocus to Tag ID
    $(document).on('keypress', '#cph_Body_txtTagID_txtTagID', function (e) {
        if (e.keyCode == 35 || e.keyCode == 13 || e.keyCode == 59) {
            e.preventDefault();
            $('#cph_Body_txtSerialNumber_txtSerialNumber').focus();
        }
    });

    // Add Asset - Capture enter fire from scanner, refocus to Add Asset button
    $(document).on('keypress', '#cph_Body_txtSerialNumber_txtSerialNumber', function (e) {
        if (e.keyCode == 35 || e.keyCode == 13 || e.keyCode == 59) {
            e.preventDefault();
            $('#cph_Body_btnApplyFilters').focus().click();
        }
    });


});
