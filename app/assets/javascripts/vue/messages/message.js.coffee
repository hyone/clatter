TwitterApp.MessageComponent = Vue.extend
  template: '#message-template'
  replace: true

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
          @$dispatch('message.deleted', event, @message)

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch 'app.alert', event,
          status: status,
          message: "#{I18n.t('views.alert.failed_create_message')}: #{error}"

    onClickReplyButton: (event) ->
      parent = $(@$el).clone()
      parent.find('.message-foot').empty()
      parent_html = parent.wrapAll("<div>").parent().html()
      @$dispatch('message.on-click-reply-button', event, parent_html, @message.user.screen_name)