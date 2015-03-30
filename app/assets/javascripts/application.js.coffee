# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery-ujs
#= require bootstrap-sass-official/assets/javascripts/bootstrap-sprockets
#= require find-and-replace-dom-text
#= require i18n
#= require i18n/translations
#= require moment
#= require moment/locale/ja
#= require moment-timezone
#= require underscore
#= require uri.js/src/URI
#= require util
#= require vue
#= require vue/transitions/fade
#= require vue/shared/alert
#= require vue/messages/favorite_button
#= require vue/messages/message_actions_button
#= require vue/messages/retweet_button
#= require vue/messages/form
#= require vue/messages/message
#= require vue/users/follow_button
#= require vue/users/user_actions_button
#= require vue/messages/message_panel
#= require vue/shared/confirm_dialog
#= require vue/shared/modal_dialog
#= require vue/shared/password_dialog
#= require vue/shared/navigation
#= require vue/users/content_navigation
#= require vue/users/user_panel
#= require vue/users/user
#= require vue/app


# initialize tooltips
$ ->
  $('[data-toggle="tooltip"]').tooltip(delay: { "show": 1000, "hide": 100 })
