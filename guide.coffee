#
# Config
#

HOUR_WIDTH = 200
SCROLL_MULTIPLIER = HOUR_WIDTH

CHANNELS =
    '1':   name: 'Nederland 1'
    '2':   name: 'Nederland 2'
    '3':   name: 'Nederland 3'
    '4':   name: 'RTL 4'
    '5':   name: 'E&eacute;n'
    '6':   name: 'Canvas'
    '18':  name: 'NGC'
    '24':  name: 'Film 1 Premium'
    '29':  name: 'Discovery'
    '31':  name: 'RTL 5'
    '34':  name: 'Veronica'
    '36':  name: 'SBS6'
    '37':  name: 'NET 5'
    '46':  name: 'RTL 7'
    '91':  name: 'Comedy Central'
    '92':  name: 'RTL 8'
    '435': name: '24 Kitchen'
    '438': name: 'TLC'
    '440': name: 'FOX'


#
# Utils
#

tosecs = (date) -> date.getHours() * 60 + date.getSeconds()
now = -> tosecs(new Date())
time2px = (seconds) -> HOUR_WIDTH / 3600 * seconds

#
# Models & collections
#

Channel = Backbone.Model.extend(
    defaults: ->
        id: null
        name: 'Some channel'
        visible: true

    initialize: (attrs, options) ->
        @programs = []
)

Progam = Backbone.Model.extend(
    defaults: ->
        title: 'Some program'
        start: null
        end: null
)

ChannelList = Backbone.Collection.extend(
    model: Channel
    comparator: 'id'

    initialize: (models, options) ->
        _.each(CHANNELS, (props, id) => @add(_.extend({id: id}, props)))
        @fetchVisible()
        #@loadPrograms(0)

    fetchVisible: ->
        visible = if localStorage.hasOwnProperty('channels') \
            then localStorage.getItem('channels').split(',') else @pluck('id')
        @setVisible(visible)

    saveVisible: ->
        selected = (c.id for c in @channels if c.visible)
        localStorage.setItem('channels', selected.join(','))

    setVisible: (visible, save=false) ->
        for id in visible
            @findWhere(id: id).set(visible: true)

        for id in _.difference(@pluck('id'), visible)
            @findWhere(id: id).set(visible: false)

        @saveVisible() if save

    loadPrograms: (day, callback) ->
        $.get(
            'http://www.tvgids.nl/json/lists/programs.php'
            channels: @pluck('id').join(','), day: day
            (channels) ->
                _.each channels, (id, programs) ->
                    channel = Channels.findWhere(id: id)
                    channel.programs = (new Program(p) for p in programs)
                    callback() if callback
            'json'
        )
)

#
# Views
#

ChannelView = Backbone.View.extend(
    tagName: 'div'
    className: 'channel'
    #template: _.template($('#channel-template').html())

    initialize: ->
        $el.text(@model.title)

    render: ->
        $el.toggle(@model.visible)
)

ProgramView = Backbone.View.extend(
    tagName: 'div'
    className: 'program'

    initialize: ->
        $el.text(@model.title)

    render: ->
        # TODO: set highlight to past/present/future
)

AppView = Backbone.View.extend(
    el: $('#guide')

    initialize: ->
        @listenTo(Channels, 'add', @addChannel)
        @listenTo(Channels, 'reset', => Channels.each(@addChannel, @))
        @listenTo(Channels, 'all', @render)

        @setDay(0, => @updateIndicator())

        #setInterval(=> @updateIndicator(), 3600000 / HOUR_WIDTH)

    setDay: (day, callback) ->
        Channels.loadPrograms(@day = day, callback)

    addChannel: (channel) ->
        view = new ChannelView(model: channel)
        @$('.channels').append(view.render().el)

    updateIndicator: ->
        @$('.indicator').css('left', time2px(now()) + 'px')

    render: ->
        hidden
        @$('.channel')
)

#
# Main
#

Channels = new ChannelList()
App = new AppView()
