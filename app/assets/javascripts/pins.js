// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

jQuery(document).ready(function() {
  jQuery("#objectSelector").change(function() {
    document.location = '/sobjects/' + jQuery(this).val();
  });
});