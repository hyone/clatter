Clatter.FavoriteButtonComponent = Vue.extend
  template: '#favorite-button-template'
  replace: true

  paramAttributes: ['data-show-count']

  data: ->
    message: undefined
    showCount: true

  computed:
    isFavorited: ->
      !!@message.favorited?.id
    hasFavorites: ->
      @message.favorited_count > 0
    canFavorite: ->
      @message.permissions.favorite

  compiled: ->
    @setupAjaxEventListeners()

  methods:
    setupAjaxEventListeners: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        unless data.response.status == 'success'
          @$dispatch '_app.alert', event, data.response
          return false
        json = data.results.favorite
        inc  = if data.response.request_method is "DELETE" then -1 else 1
        @updateButtonStatus(json, inc)
        @updateUserStat(json, inc)
        false

      $(@$el).on 'ajax:complete', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').removeAttr('disabled')
        false

      $(@$el).on 'ajax:before', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').attr('disabled', 'disabled')

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch '_app.alert', event,
          status: status,
          message: "#{I18n.t('views.alert.failed_favorite_message')}: #{error}"
        false

    updateButtonStatus: (data, inc) ->
       @message.favorited.id    = data.message.favorited.id
       @message.favorited_count += inc

    updateUserStat: (data, inc) ->
      if Clatter.profileUser and
         Clatter.currentUser and
         Clatter.profileUser.id == Clatter.currentUser.id
        @$dispatch('_app.update-stats', event, favorites: inc)
