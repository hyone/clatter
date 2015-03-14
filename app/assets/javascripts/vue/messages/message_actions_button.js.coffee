Clatter.MessageActionsButtonComponent = Vue.extend
  template: '#message-actions-button-template'
  replace: true

  data: ->
    message: {}

  compiled: ->
    @setupAjaxEventListeners()

  methods:
    setupAjaxEventListeners: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        if data.response.status isnt 'success'
          @$dispatch 'app.alert', event, data.response
          return

        t = $(event.target)
        if t.hasClass('delete-message')
          @$dispatch('_message.deleted', event, @message)

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch 'app.alert', event,
          status: status,
          message: "#{I18n.t('views.alert.failed_delete_message')}: #{error}"
