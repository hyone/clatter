window.Clatter.NavigationComponent = Vue.extend
  template: '#navigation-template'
  replace: true

  data: ->
    search: {}

  methods:
    isActiveMenu: (url) ->
      @$interpolate(url) is location.pathname

    onClickNewMessageButton: (args...) ->
      @$dispatch('_navigation.click-new-message-button', args...)
      false
