Clatter.PasswordDialogComponent = Vue.extend
  template: '#password-dialog-template'
  replace: true

  compiled: ->
    $(@$el).on 'shown.bs.modal', (event) =>
      $('input[name="user[current_password]"]').focus()
