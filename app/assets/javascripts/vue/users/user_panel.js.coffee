Clatter.UserPanelComponent = Vue.extend
  template: '#user-panel-template'
  replace: true

  components:
    'follow-button': Clatter.FollowButtonComponent
    'user-actions-button': Clatter.UserActionsButtonComponent

  data: ->
    user: undefined
