window.TwitterApp.NavigationComponent = Vue.extend
  template: '#navigation-template'
  replace: true

  methods:
    isActiveMenu: (url) ->
      @$interpolate(url) is location.pathname

    onClickNewMessageButton: (args...) ->
      @$dispatch('navigation.click-new-message-button', args...)
      false
