window.Clatter.NavigationComponent = Vue.extend
  template: '#navigation-template'
  replace: true

  props: [
    {
      name: 'search'
      type: Object
      validator: (value) -> value.text?
    }
  ]

  data: ->
    search: { text: '' }

  methods:
    isActiveMenu: (url) ->
      @$interpolate(url) is location.pathname

    onClickNewMessageButton: (args...) ->
      @$dispatch('_navigation.click-new-message-button', args...)
      false
