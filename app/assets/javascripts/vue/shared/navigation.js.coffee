window.TwitterApp.NavigationComponent = Vue.extend
  template: '#navigation-template'
  replace: true

  methods:
    onClickNewMessageButton: (args...) ->
      @$dispatch('navigation.click-new-message-button', args...)
      false
