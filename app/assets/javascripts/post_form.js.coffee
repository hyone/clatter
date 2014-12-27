
count = (textarea) ->
  140 - $(textarea).val().length

setPostFormState = ($form) ->
  cnt = count $form.find('.post-text')

  # whether post button is disabled or not
  disabled = if cnt == 140 or cnt < 0 then true else false
  $form.find('div.post-submit > button[type=submit]').prop('disabled', disabled)

  # counter state
  $counter = $form.find('span.post-count').text cnt
  if cnt < 10
    $counter.removeClass('text-muted').addClass('text-danger')
  else
    $counter.removeClass('text-danger').addClass('text-muted')


togglePostFormVisible = ($form, open = false) ->
  if open
    $form.find('.post-text').attr('rows', 3)
    $form.find('.post-submit').css('display', 'block')
  else
    $form.find('.post-text').attr('rows', 1)
    $form.find('.post-submit').css('display', 'none')


$ ->
  # post form in modal dialog
  $modalForm = $('#modal-post-form .post-form')
  togglePostFormVisible($modalForm, true)
  setPostFormState($modalForm)

  $modalForm.find('textarea.post-text')
    .change ->
      setPostFormState($modalForm)
    .keyup  ->
      setPostFormState($modalForm)

  # post form in header of posts list block
  $postForm = $('.posts .posts-head .post-form')
  $postForm.find('textarea.post-text')
    .focus ->
      setPostFormState($postForm)
      togglePostFormVisible($postForm, true)
    .blur ->
      if $(this).val().length == 0
        togglePostFormVisible($postForm, false)
    .change ->
      setPostFormState($postForm)
    .keyup  ->
      setPostFormState($postForm)
