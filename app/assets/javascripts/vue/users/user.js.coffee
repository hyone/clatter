Clatter.UserComponent = Vue.extend
  template: '#user-template'
  replace: true

  components:
    'follow-button': Clatter.FollowButtonComponent
    'user-actions-button': Clatter.UserActionsButtonComponent

  data: ->
    user: {}
