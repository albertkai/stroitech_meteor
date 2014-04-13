Meteor.startup ->

  Meteor.publish 'pages', ->
    Pages.find()

  Meteor.publish 'history', ->
    History.find()

  Meteor.publish 'objects', ->
    Objects.find()

  Meteor.publish 'logs', ->
    Logs.find()