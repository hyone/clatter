Vue.transition 'slide-down',
  beforeEnter: (el) ->
  enter: (el, done) ->
    $(el).animate(height: 'show', 500)
    # $(el).slideDown(1000)
    -> $(el).stop()
  leave: (el, done) ->
    $(el).slideUp(500)
    # $(el).animate(height: 'hide', 500)
    -> $(el).stop()
