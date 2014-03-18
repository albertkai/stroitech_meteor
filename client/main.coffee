Meteor.startup ->
  console.log 'startup'
  Session.setDefault('mapLoaded', false)

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

  if Session.get('mapLoaded') is false

    console.log 'yo'

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

  'click #objects .item>.thumbnail': (e)->
    expander.open($(e.target).closest('.item'))

  'click #objects .item .expandable .close-it': ()->
    expander.flatten()
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
  });


#  @map.addStyle({
#    styledMapName:"Styled Map",
#    styles:styles,
#    mapTypeId:"map_style"
#  })
#
#  @map.setStyle("map_style")
#
#
#  @map.drawOverlay({
#    lat:59.9386505,
#    lng:30.3730258,
#    content:'<div class="overlay"></div>',
#    verticalAlign:'top'
#  })




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
