
count = (textarea) ->
  140 - $(textarea).val().length

setMessageFormState = ($form) ->
  cnt = count $form.find('.message-text')

  # whether message button is disabled or not
  disabled = if cnt == 140 or cnt < 0 then true else false
  $form.find('div.message-submit > button[type=submit]').prop('disabled', disabled)

  # counter state
  $counter = $form.find('span.message-count').text cnt
  if cnt < 10
    $counter.removeClass('text-muted').addClass('text-danger')
  else
    $counter.removeClass('text-danger').addClass('text-muted')


toggleMessageFormVisible = ($form, open = false) ->
  if open
    $form.find('.message-text').attr('rows', 3)
    $form.find('.message-submit').css('display', 'block')
  else
    $form.find('.message-text').attr('rows', 1)
    $form.find('.message-submit').css('display', 'none')


$ ->
  # message form in modal dialog
  $modalForm = $('#modal-message-form .message-form')
  toggleMessageFormVisible($modalForm, true)
  setMessageFormState($modalForm)

  $modalForm.find('textarea.message-text')
    .change ->
      setMessageFormState($modalForm)
    .keyup  ->
      setMessageFormState($modalForm)

  # message form in header of messages list block
  $messageForm = $('.messages-panel .messages-panel-head .message-form')
  $messageForm.find('textarea.message-text')
    .focus ->
      setMessageFormState($messageForm)
      toggleMessageFormVisible($messageForm, true)
    .blur ->
      if $(this).val().length == 0
        toggleMessageFormVisible($messageForm, false)
    .change ->
      setMessageFormState($messageForm)
    .keyup  ->
      setMessageFormState($messageForm)
