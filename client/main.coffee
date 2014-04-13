Meteor.subscribe 'pages'
Meteor.subscribe 'objects'
Meteor.subscribe 'history'
Meteor.subscribe 'logs'


eColl = {
  pages: Pages,
  objects: Objects
}

Session.setDefault('mapLoaded', false)



Meteor.startup ->
  console.log 'startup'
  Deps.autorun ->
    if Session.get('admin.editMode') is true
      $('[contenteditable]').each ->
        $(this).attr('contenteditable', 'true')
    else
      $('[contenteditable]').each ->
        $(this).attr('contenteditable', 'false')


Template.main.helpers {

  footer: ->

    Pages.findOne {name: 'footer'}

}


Template.timeline.helpers {

  getId: (str)->
    str.replace(" ","")

  gotSeveralPics: (pics)->
    if pics.length > 1
      true
    else
      false

}

Template.about.helpers {
  about: ->
    Pages.findOne {name: 'about'}
}

Template.services.helpers {
  services: ->
    Pages.findOne {name: 'services'}
}

Template.price.helpers {
  price: ->
    Pages.findOne {name: 'price'}
}

Template.objects.helpers {
  objects: ->
    Pages.findOne {name: 'objects'}

  objectList: ->
    Objects.find()

  getAnim: ->
    _.random(0, 1.3)
}

Template.contacts.helpers {
  contacts: ->
    Pages.findOne {name: 'contacts'}
}



Template.main.events {
  'click #top nav ul li': (e)->
    e.preventDefault()
    target = $(e.target).closest('li').data('target')
    $.scrollTo $('#' + target), {offset: -50, duration: 500}

  'click #top-nav .for-devices button': ->
    $('#top-nav').find('ul').toggleClass('_expanded')

  'click #top-nav ul li': ->
    $('#top-nav').find('ul').removeClass('_expanded')

  'click #objects .item>.thumbnail': (e)->
    expander.open($(e.target).closest('.item'))

  'click #objects .item .expandable .close-it': ()->
    expander.flatten()

}

Template.adminPanel.events {
  'click #edit-mode': (e)->
    if $(e.target).is(':checked')
      Session.set('admin.editMode', true)
    else
      Session.set('admin.editMode', false)

  'mouseenter #history-cont li': (e)->
    path = $(e.target).data('selector-path')
    if $(path).length > 0
      $(path).addClass('_focus')
      Meteor.setTimeout ->
        if $(e.target).is(':hover')
          $.scrollTo $(path), 500, {offset: -150}
      , 500

  'click #history-cont li': (e)->
    target = $(e.target).closest('li').data('id')
    Aura._historyRestore(target)
}

Template.adminPanel.helpers {
  history: ->
    History.find({}, {sort: {date: -1}})
  getDate: (date)->
    moment(date).lang('ru').format('DD.MM.YYYY HH:MM')
}

Template.modal.events {
  'click .r-modal .ovrl, click .r-modal .close-me': (e)->
    $(e.target).closest('.r-modal').removeClass '_opened'
}

Template.services.events {

  'click .item .thumbnail': (e)->
    if $(e.target).closest('.thumbnail').parent().attr('contenteditable') isnt 'true'
      $elTarget = $('.r-modal').find('.container')
      target = $(e.target).closest('.thumbnail').data('target')
      $elTarget.html('')
      UI.insert(UI.renderWithData(Template.modalContent, Pages.findOne({name: target})), $elTarget.get(0))
      $('.r-modal').addClass('_opened')

}

@Loader = {
  count: 0
  more: ->
    @count++
    @isLoaded()
  isLoaded: ->
    if @count >= 6
      Meteor.setTimeout ->
        MainCtrl.render()
      , 1500

}


#Rendered

Template.main.rendered = ->

  console.log 'main rendered'

#  $(window).on 'beforeload', ->"Нахуй?"
  window.onbeforeunload = ->if Aura._historyBuffer.length > 0 or $('[contenteditable]:focus').length > 0 then "У вас есть несохраненные данные!"
  $('#top').attr('data-stellar-background-ratio', .6)
  $.stellar()

  Mousetrap.bind 'q w e', (e)->
    Aura.showAdminModal()

  Mousetrap.bind 'й ц у', (e)->
    Aura.showAdminModal()

  Loader.more()

  if Session.get('admin.editMode') is true
    $('[contenteditable]').attr('contenteditable', 'true')
  else if Session.get('admin.editMode') is false
    $('[contenteditable]').attr('contenteditable', 'false')


Template.timeline.rendered = ->
  $('.carousel-inner').each ->
    $(this).find('.item').first().addClass('active')
  $('.carousel').carousel()
  if Session.get('admin.editMode') is true
    $('[contenteditable]').attr('contenteditable', 'true')
  else if Session.get('admin.editMode') is false
    $('[contenteditable]').attr('contenteditable', 'false')

Template.about.rendered = ->

  console.log 'about rendered'
  Loader.more()

Template.services.rendered = ->

  console.log 'services rendered'
  Loader.more()

Template.objects.rendered = ->

  console.log 'objects rendered'
  Loader.more()

Template.price.rendered = ->

  console.log 'prices rendered'
  Loader.more()

Template.contacts.rendered = ->

  console.log 'contacts rendered'
  Loader.more()

  if Session.get('mapLoaded') is false

    Meteor.setTimeout ->

      script = document.createElement("script")
      script.type = "text/javascript"
      script.src = "http://maps.google.com/maps/api/js?sensor=false&libraries=places&callback=initializeMap"
      document.body.appendChild(script)
      Session.set('mapLoaded', true)
    , 2500



@initializeMap = ->

  myLatlng = new google.maps.LatLng(55.893921, 37.720258)

  mapOptions = {
    zoom: 15,
    center: myLatlng
    zoomControl:true,
    zoomControlOpt:{
      style:"MEDIUM",
      position:"RIGHT_TOP"
    },
    panControl:true,
    streetViewControl:false,
    mapTypeControl:false,
    overviewMapControl:false,
    scrollwheel:false
  }

  styles = [
    {
      stylers:[
        { hue:"#6599c0" },
        { saturation:120 }
      ]
    },
    {
      featureType:"road",
      elementType:"geometry",
      stylers:[
        { lightness:100 }      ]
    },
    {
      featureType:"road",
      elementType:"labels",
      stylers:[
        { hue:"green" },
        { saturation:50 }
      ]
    }
  ]

  styledMap = new google.maps.StyledMapType styles, {name: "Styled Map"}

  @map  = new google.maps.Map document.getElementById('map'), mapOptions

  @map.mapTypes.set('map_style', styledMap)

  @map.setMapTypeId('map_style')

  marker = new google.maps.Marker({
    position: myLatlng,
    map: map
  })



expander = {

  current: 0

  settings: {
    expHeight: 600
  }

  open: (thumb)->

    current = thumb.index()

    if $('#objects').find('.item').eq(@current).offset().top is thumb.offset().top

      @openNew(thumb)

    else

      @openNew(thumb)

  openNew: (thumb)->

    if $('.expandable._opened').length > 0

      @flatten(thumb)
      Meteor.setTimeout =>
        @expand(thumb)
      , 800

    else

      @expand(thumb)


  expand: (thumb)->

    $exp = thumb.find('.expandable')
    scrollPosition = $exp.offset().top - 50
#    html = @getContent(thumb)
#    $exp.find('.container').html html
    id = thumb.data('id')
    data = Objects.findOne({_id: id})
    $exp.find('.container').html('')
    UI.insert(UI.renderWithData(Template.timeline, {currentObject: data}), $exp.find('.container').get(0))

    thumb.css('margin-bottom', @settings.expHeight + 'px')
    $exp.css('height', @settings.expHeight + 'px')

    $('#objects').find('.item').find('.thumbnail').removeClass('_active')
    thumb.find('.thumbnail').addClass('_active')

    $exp.addClass('_opened')
    @current = thumb.index()

    Meteor.setTimeout =>
      $.scrollTo scrollPosition, 400
      $exp.find('.container').css('opacity', '1')
    ,400

  flatten: ()->

    $this = $('.expandable._opened')
    $this.find('.container').css('opacity', '0')
    Meteor.setTimeout =>
      $this.css('height', '0')
      $this.closest('.item').css('margin-bottom', '0')
      $this.removeClass('_opened')
      $.scrollTo $('#objects'), 400
    ,400

    $('#objects').find('.item').find('.thumbnail').removeClass('_active')


}


animatePage = (elem, dur)->

  $allElems = elem.find('[data-animate]')
  $allElems.each ->
    speed = $(this).data('animate')
    $elem = $(this)
    setTimeout ->
      $elem.addClass('_animated')
    , dur * parseFloat(speed, 10)



Template.editor.events {

  'click button': (e)->
    $(e.target).closest('button').toggleClass('_active')

  'click #b-html': (e)->
    if $(e.target).hasClass('_active')
      $('.editor .html-cont').css('visibility', 'visible').removeClass('flipOutX').addClass('animated flipInX')
      console.log 'this ' + editor._editingItem
    else
      $('.editor .html-cont').removeClass('flipInX').addClass('flipOutX')

  'click .editor .html-cont button': (e)->
    target = $(e.target).siblings('textarea')
    target.val(target.data('resetData'))
    console.log target.data('resetData')
    $(target.data('path')).html(target.val())

  'input .editor .html-cont textarea': (e)->
    path = $(e.target).data('path')
    $(path).html($(e.target).val().trim())

  'blur .editor .html-cont textarea': (e)->
#    index = $(e.target).data('index')
#    html = $(e.target).val()
#    console.log index
#    console.log Aura._historyBuffer[index].newData
#    Aura._historyBuffer[index].newData = html
#    editor._changedBuffer[index].data = html
    $($(e.target).data('path')).trigger('blur')



  'click #b-bold': ->
    editor.commands.bold()

  'click #b-italic': ->
    editor.commands.italic()

  'click #b-sub': ->
    editor.commands.sub()

  'click #b-sup': ->
    editor.commands.sup()

  'click #b-ul': ->
    editor.commands.ul()

  'click #b-ol': ->
    editor.commands.ol()

  'click #b-h1': ->
    editor.commands.h1()

  'click #b-h2': ->
    editor.commands.h2()

  'click #b-h3': ->
    editor.commands.h3()

  'click #b-h4': ->
    editor.commands.h4()

  'click #b-h5': ->
    editor.commands.h5()

  'click #b-h6': ->
    editor.commands.h6()

  'click #b-span': ->
    editor.commands.span()

  'click #b-link': ->
    editor.commands.link()

  'click #b-save': (e)->


    editor.hideEditor()
    editor.save()

}



UI.body.events {

  'mouseover [contenteditable="true"]': (e)->
    target = $(e.target).closest('[contenteditable="true"]')
    target.addClass('_editor-hover')
    Meteor.setTimeout ->
      target.removeClass('_editor-hover')
    , 600

  'click [contenteditable="true"]': (e)->
    e.stopPropagation()

  'focus [contenteditable="true"]': (e)->
    editor.showEditor()
    editor._trackChanges.currentValue = $(e.target).closest('[contenteditable="true"]').html()
    editor.editingItem = $(e.target).closest('[contenteditable="true"]').html()
    $('.editor .html-cont textarea').val(editor.editingItem.trim())
    $('.editor .html-cont textarea').data('resetData', editor.editingItem.trim())
    $('.editor .html-cont textarea').data('path', $(e.target).closest('[contenteditable="true"]').getPath())

  'input [contenteditable="true"]': (e)->
    markup = $(e.target).html()
    $('.editor .html-cont textarea').val(markup.trim())

  'click #login-buttons-logout, click #login-buttons-password': ->
    Aura.hideAdminModal()

  'blur [contenteditable="true"]': (e)->
    currentState = $(e.target).closest('[contenteditable="true"]').html()
    if currentState isnt editor.editingItem
      fieldData = $(e.target).data('field')
      $('.editor .html-cont textarea').data('index', Aura._historyBuffer.length)
      fields = do ->
        if fieldData.match /^\$/
          id = $(e.target).closest('[data-nested-id]').data('nested-id')
          {
          field: fieldData.split('.')[2]
          nested: {
            id: id
            type: 'array'
            field: fieldData.split('.')[1]
          }
          }
        else if fieldData.match /\./
          {
          field: fieldData.split('.')[1]
          nested: {
            type: 'prop'
            field: fieldData.split('.')[0]
          }
          }
        else
          {
          field: fieldData
          nested: null
          }


      Aura._historyBuffer.push {
        field: $(e.target).data('field')
        document: $(e.target).closest('[data-document]').data('document')
        collection: $(e.target).closest('[data-collection]').data('collection')
        data: editor.editingItem
        newData: $(e.target).closest('[contenteditable="true"]').html()
        selectorPath: $(e.target).getPath()
        type: 'text'
        rolledBack: false
        nested: fields.nested
      }
      editor._changedBuffer.push {
        field: fields.field
        document: $(e.target).closest('[data-document]').data('document')
        collection: $(e.target).closest('[data-collection]').data('collection')
        data: $(e.target).closest('[contenteditable="true"]').html()
        nested: fields.nested
      }
      console.log editor._changedBuffer
      $(e.target).closest('[contenteditable="true"]').addClass('_changed')

  'click #admin-login-modal .close': ->
    Aura.hideAdminModal()
}




@Aura = {

  showAdminModal: ->
    $('#admin-login-modal').css('visibility', 'visible').removeClass('flipOutY').addClass('animated flipInY')

  hideAdminModal: ->
    $('#admin-login-modal').removeClass('flipInY').addClass('flipOutY')
    setTimeout ->
      $('#admin-login-modal').css('visibility', 'hidden')
    , 500


  _logsWrite: (buffer)->

    _.each buffer, (log)->
      Logs.insert {
        field: log.field,
        collection: log.collection,
        date: new Date()
        user: 'Albert Kai'
      }

  _historyBuffer: []

  _saveHistory: (buffer)->

    console.log 'triggered saveHistory'

    historyCount = History.find().count()
    if historyCount + buffer.length > Aura.settings.history.size
      toDeleteSize = historyCount + buffer.length - Aura.settings.history.size
      toDelete = History.find({}, {sort: {date : 1}, limit: toDeleteSize }).fetch()
      toDelete.forEach (item)->
        id = item._id
        History.remove id


    _.each buffer, (history)->
      if !history.rolledBack
        History.insert {
          field: history.field,
          collection: history.collection,
          document: history.document
          date: new Date()
          data: history.data
          selectorPath: history.selectorPath
          newData: history.newData
          type: history.type
          user: Meteor.user()
          rolledBack: history.rolledBack
        }
        console.log 'triggered saveHistory iterate'

      else
        target = History.findOne({_id: history._id})
        target.rolledBack = !buffer.rolledBack
        History.update {_id: history._id}, history


    Aura._historyBuffer = []

  _historyRestore: (id)->

    buffer = History.findOne({_id: id})

    if buffer.rolledBack
      buffer.data = buffer.newData

#    editor._changedBuffer.push {
#      field: buffer.field
#      document: buffer.document
#      collection: buffer.collection
#      data: restoredData
#      nested: buffer.nested
#    }

    History.update {_id: id}, {$set: {rolledBack: !buffer.rolledBack}}

    editor._saveText [buffer], ->
#      History.remove {_id: id}
      console.log 'history restored'

}


@editor = {

  _editingItem: ''

  _changedBuffer: []

  commands: {

    bold: ()->

      document.execCommand('bold', null, null)

    italic: ->

      document.execCommand('italic', null, null)

    sub: ->

      document.execCommand('subscript', null, null)

    sup: ->

      document.execCommand('superscript', null, null)

    ul: ->

      document.execCommand('insertUnorderedList', null, null)

    ol: ->

      document.execCommand('insertOrderedList', null, null)

    h1: ->

      document.execCommand('formatBlock', null, '<h1>')

    h2: ->

      document.execCommand('formatBlock', null, '<h2>')

    h3: ->

      document.execCommand('formatBlock', null, '<h3>')


    h4: ->

      document.execCommand('formatBlock', null, '<h4>')


    h5: ->

      document.execCommand('formatBlock', null, '<h5>')


    h6: ->

      document.execCommand('formatBlock', null, '<h6>')


    span: ->

      document.execCommand('formatBlock', null, '<span>')

    link: ->

      document.execCommand('createLink', false, prompt('Введите URL'))
  }



  save: ->

    if @_changedBuffer.length > 0
      @_saveText(@_changedBuffer)

  _trackChanges:

    currentValue: ''

    check: ($el)->

      console.log @currentValue

      if $el.html() isnt @currentValue

        true

      else

        false


  _saveText: (buffer)->

    Meteor.call 'editorSaveText', buffer, ->


      Aura._logsWrite(Aura._historyBuffer)

      Aura._saveHistory(Aura._historyBuffer)

      editor._changedBuffer = []

      console.log 'changed'

      $.jGrowl('Изменения сохранены!')

    true


  showEditor: ->

    $('.editor').addClass('_opened')
    $('.editor').find('button').removeClass('_active')

  hideEditor: ->
    $('.editor').removeClass('_opened')
    $('.editor').find('.html-cont').removeClass('flipInX').addClass('flipOutX')

}



MainCtrl = {

  render: ->

    Session.set('edit', 'false')

    $('.pages').waypoint (dir)->

      target = $(this).attr('id')

      if dir is 'up'

        if target is 'top'
          $('#top').find('nav ul li').removeClass('_active')
        else
          $('#top').find('nav ul li').removeClass('_active')
          $('#top').find('nav ul').find('[data-target="' + target + '"]').addClass('_active')
    , {offset: -300}

    $('.pages').waypoint (dir)->

      target = $(this).attr('id')

      if dir is 'down'

        $('#top').find('nav ul li').removeClass('_active')
        $('#top').find('nav ul').find('[data-target="' + target + '"]').addClass('_active')

    , {offset: 300}

    $('#about').waypoint (dir)->
      if dir is 'down'
        $('#top').find('nav').addClass('_fixed')
    , {offset: 80}

    $('#about').waypoint (dir)->
      if dir is 'up'
        $('#top').find('nav').removeClass('_fixed')
    , {offset: 50}


    $('.loader').addClass('_loaded')
    $('.loader').find('.loader-gif').css('display', 'none');
    Meteor.setTimeout ->
      $('.loader').css('display', 'none')
    , 1000


    Meteor.setTimeout ->

      $('.pages').waypoint (dir)->

        if dir is 'down'

          animatePage($(this), 400)

      , {offset: 300}
    , 500

}



Aura.settings = {
  history: {
    size: 20
  }
}