@History = new Meteor.Collection('history')


History.allow {
  insert: (userId)->
    if Roles.userIsInRole userId, ['admin']
      true

  update: (userId)->
    if Roles.userIsInRole userId, ['admin']
      true

  remove: (userId)->
    false
}