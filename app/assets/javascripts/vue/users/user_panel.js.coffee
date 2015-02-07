TwitterApp.UserPanelComponent = Vue.extend
  template: '#user-panel-template'
  replace: true

  components:
    'follow-button': TwitterApp.FollowButtonComponent
    'user-actions-button': TwitterApp.UserActionsButtonComponent

  data: ->
    user: undefined
