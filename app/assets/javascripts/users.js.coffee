# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  # when clicked 'message to <screen-name>',
  # set '@<screen_name> ' to the value of message dialog textarea

  # in content navigation
  $(document)
    .on 'click', '.content-navigation .open-reply-to', () ->
      screen_name = $('#profile-user-data').data('screen-name')
      $('#modal-message-form-text').val("@#{screen_name} ")

  # in user panel
  $(document)
    .on 'click', '.user-panel .open-reply-to', () ->
      screen_name = $(this).closest('.user-data').data('screen-name')
      $('#modal-message-form-text').val("@#{screen_name} ")
