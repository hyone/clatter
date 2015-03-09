TwitterApp.UserComponent = Vue.extend
  template: '#user-template'
  replace: true

  components:
    'follow-button': TwitterApp.FollowButtonComponent
    'user-actions-button': TwitterApp.UserActionsButtonComponent

  data: ->
    user: {}
