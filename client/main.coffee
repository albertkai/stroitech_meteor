Meteor.startup ->
  console.log 'startup'
  Session.setDefault('mapLoaded', false)

Template.main.helpers {

  about: ->

    Pages.findOne {name: 'about'}

  services: ->

    Pages.findOne {name: 'services'}

  objects: ->

    Pages.findOne {name: 'objects'}

  objectList: ->

    Objects.find({}, {fields: {'name':1, 'desc': 1, '_id': 1, 'square': '1', 'status': 1, 'thumb': 1}})

  price: ->

    Pages.findOne {name: 'price'}

  contacts: ->

    Pages.findOne {name: 'contacts'}

  footer: ->

    Pages.findOne {name: 'footer'}

}

Template.main.rendered = ()->

  console.log 'rendered'

  $('#top').attr('data-stellar-background-ratio', .6)
  $.stellar()

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


  $('.pages').waypoint (dir)->

    if dir is 'down'

      animatePage($(this), 400)

  , {offset: 100}

  if Session.get('mapLoaded') is false

    script = document.createElement("script")
    script.type = "text/javascript"
    script.src = "http://maps.google.com/maps/api/js?sensor=false&libraries=places&callback=initializeMap"
    document.body.appendChild(script)
    Session.set('mapLoaded', true)


Template.main.events {
  'click #top nav ul li': (e)->
    e.preventDefault()
    target = $(e.target).closest('li').data('target')
    $.scrollTo $('#' + target), {offset: -50, duration: 500}

  'mouseover [contenteditable="true"]': (e)->
    target = $(e.target).closest('[contenteditable="true"]')
    target.addClass('_editor-hover')
    Meteor.setTimeout ->
      target.removeClass('_editor-hover')
    , 600

  'click [contenteditable="true"]': (e)->
    e.stopPropagation()

  'focus [contenteditable="true"]': (e)->
    $('.editor').addClass('_opened')
    $('#editor-overlay').addClass('_active')
    $(e.target).addClass('_editing')
    $('.editor').find('button').removeClass('_active')
    editor._trackChanges.currentValue = $(e.target).closest('[contenteditable="true"]').html()

  'click #services .item .thumbnail': (e)->
    if $(e.target).closest('.thumbnail').parent().attr('contenteditable') isnt 'true'
      target = $(e.target).closest('.thumbnail').data('target')
      $('.r-modal').addClass('_opened')

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
}

Template.modal.events {
  'click .r-modal .ovrl, click .r-modal .close-me': (e)->
    $(e.target).closest('.r-modal').removeClass '_opened'
}

Template.editor.events {

  'click button': (e)->
    $(e.target).closest('button').toggleClass('_active')

  'click #b-bold': ->
    editor.bold()

  'click #b-italic': ->
    editor.italic()

  'click #b-sub': ->
    editor.sub()

  'click #b-sup': ->
    editor.sup()

  'click #b-ul': ->
    editor.ul()

  'click #b-ol': ->
    editor.ol()

  'click #b-h1': ->
    editor.h1()

  'click #b-h2': ->
    editor.h2()

  'click #b-h3': ->
    editor.h3()

  'click #b-h4': ->
    editor.h4()

  'click #b-h5': ->
    editor.h5()

  'click #b-h6': ->
    editor.h6()

  'click #b-span': ->
    editor.span()

  'click #b-link': ->
    editor.link()

  'click #editor-overlay, click .editor button#save': (e)->

    editingBlock = $('[contenteditable]._editing')
    console.log editingBlock
    $('.editor').removeClass('_opened')
    $('#editor-overlay').removeClass('_opened')
    editingBlock.removeClass('_editing')
    if editor._trackChanges.check(editingBlock)
      editor.save(editingBlock)

}



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
    html = @getContent(thumb)
    $exp.find('.container').html html

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
#      Meteor.setTimeout ->
#        $.scrollTo $('#objects'), 400
#      ,400
      $.scrollTo $('#objects'), 400
    ,400

    $('#objects').find('.item').find('.thumbnail').removeClass('_active')



  getContent: (thumb)->

    html = Meteor.render ->Template.timeline()


}


animatePage = (elem, dur)->

  $allElems = elem.find('[data-animate]')
  $allElems.each ->
    speed = $(this).data('animate')
    $elem = $(this)
    setTimeout ->
      $elem.addClass('_animated')
    , dur * parseFloat(speed, 10)


@editor = {

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

  save: ($el)->

    type = $el.data('type')
    if type is 'text'
      @_saveText($el)

  _trackChanges:

    currentValue: ''

    check: ($el)->

      console.log @currentValue

      if $el.html() isnt @currentValue

        true

      else

        false

  _saveText: ($el)->

    newData = {}

    pageId = Pages.findOne({'name': $el.closest('[data-page]').data('page')})._id

    elemName = $el.attr('id')

    html = $el.html()

    newData[elemName] = html

    console.log pageId

    Pages.update pageId, {$set: newData}, ->
      console.log 'saved'

}

