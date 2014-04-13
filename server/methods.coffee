eColl = {
  pages: Pages,
  objects: Objects
}

Meteor.methods {
  editorSaveText: (changedBuffer)->

    user = Meteor.user()

    if Roles.userIsInRole user, ['adminer']

      console.log 'triggered saveText'

      _.each changedBuffer, (change)->

        if !change.nested

          console.log 'triggered saveText iterate'

          newData = {}

          pageId = eColl[change.collection].findOne({'name': change.document})._id

          newData[change.field] = change.data

          eColl[change.collection].update pageId, {$set: newData}, ->
            console.log 'saved'

            console.log change.data


        else if change.nested.type is 'array'

          console.log 'triggered saveText iterate array'

          newData = {}

          updateObj = {}

          updateObj['_id'] = eColl[change.collection].findOne({'name': change.document})._id

          console.log eColl[change.collection].findOne({'name': change.document})._id

          updateObj[change.nested.field + '.id'] = change.nested.id

          newData[change.nested.field + '.$.' + change.field] = change.data

          eColl[change.collection].update updateObj, {$set: newData}, ->
            console.log 'saved'

    else

      Meteor.Error(403, 'Not allowed')
}