TwitterApp.UserPanelComponent = Vue.extend
  template: '#user-panel-template'

  replace: true

  data: ->
    user: undefined

Vue.component('user-panel', TwitterApp.UserPanelComponent)
