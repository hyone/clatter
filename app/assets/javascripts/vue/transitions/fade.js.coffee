Vue.transition 'fade',
  beforeEnter: (el) ->
  enter: (el, done) ->
    $(el).css('opacity', 0).animate({ opacity: 1 }, 1000, done)
    -> $(el).stop()
  leave: (el, done) ->
    $(el).animate({ opacity: 0 }, 1000, done)
    -> $(el).stop()
