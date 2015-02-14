TwitterApp.FavoriteButtonComponent = Vue.extend
  template: '#favorite-button-template'
  replace: true

  data: ->
    message: undefined

  computed:
    isFavorited: ->
      !!@message.favorited?.id
    hasFavorites: ->
      @message.favorited_count > 0

  compiled: ->
    @setupAjaxEventListeners()

  ready: ->
    # @$log @message.favorited

  methods:
    setupAjaxEventListeners: ->
      $(@$el).on 'ajax:success', (event, data, status, xhr) =>
        unless data.response.status == 'success'
          @$dispatch 'app.alert', event, data.response
          return false
        json = data.results.favorite
        # console.log json
        @updateButtonStatus(json)
        @updateUserStat(json)
        false

      $(@$el).on 'ajax:complete', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').removeAttr('disabled')
        false

      $(@$el).on 'ajax:before', (event, data, status, xhr) =>
        $(event.target).find('button[type="submit"]').attr('disabled', 'disabled')

      $(@$el).on 'ajax:error', (event, xhr, status, error) =>
        @$dispatch 'app.alert', event,
          status: status,
          message: "#{I18n.t('views.alert.failed_favorite_message')}: #{error}"
        false

    updateButtonStatus: (data) ->
       @message.favorited.id    = data.message.favorited.id
       @message.favorited_count = data.message.favorited_count

    updateUserStat: (data) ->
      if TwitterApp.profileUser and
         TwitterApp.currentUser and
         TwitterApp.profileUser.id == TwitterApp.currentUser.id
        @$dispatch('favorite.update-stats', event, favorites: data.user.favorites_count)
