#
# Config
#

#FETCH_URL = 'http://www.tvgids.nl/json/lists/programs.php'
FETCH_URL = 'programs.php'
HOUR_WIDTH = 200
SCROLL_MULTIPLIER = HOUR_WIDTH

#
# Utils
#

seconds_today = (time) -> (time - (new Date()).setHours(0, 0, 0, 0)) / 1000
time2px = (seconds) -> HOUR_WIDTH / 3600 * seconds
zeropad = (digit) -> if digit < 10 then '0' + digit else String(digit)
format_time = (time) ->
    date = new Date(time)
    zeropad(date.getHours()) + ':' + zeropad(date.getMinutes())

#
# Models & collections
#

Channel = Backbone.Model.extend(
    defaults: ->
        id: null
        name: 'Some channel'
        visible: true
        programs: []
)

Program = Backbone.Model.extend(
    defaults: ->
        title: 'Some program'
        genre: ''
        sort: ''
        start: 0
        end: 0
        #article_id: null
        #article_title: null
)

ChannelList = Backbone.Collection.extend(
    model: Channel
    comparator: 'id'

    initialize: (models, options) ->
        #_.each(CHANNELS, (props, id) => @add(_.extend({id: id}, props)))

        @fetchVisible()
        #@fetchPrograms(0)

    fetch: ->
        @reset(CHANNELS)
        #@reset(CHANNELS.slice(0,3))
        #$.getJSON('channels.php', (data) => @reset(data))

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

    fetchPrograms: (day) ->
        $.getJSON(
            FETCH_URL
            channels: @pluck('id').join(','), day: day
            (channels) ->
                _.each channels, (programs, id) ->
                    channel = Channels.findWhere(id: id)
                    channel.set('programs', (
                        new Program(
                            title: p.titel
                            genre: p.genre
                            sort: p.soort
                            start: Date.parse(p.datum_start)
                            end: Date.parse(p.datum_end)
                            #article_id: p.artikel_id
                            #article_title: p.artikel_titel
                        ) for p in programs
                    ))
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
        @listenTo(@model, 'change:programs', @render)
        @listenTo(@model, 'change:visible', @toggleVisible)
        #@$el.text(@model.get('title'))

    render: ->
        @$el.empty()
        _.each @model.get('programs'), (program) =>
            view = new ProgramView(model: program)
            view.render()
            @$el.append(view.el)

    toggleVisible: ->
        @$el.toggle(@model.get('visible'))
)

ProgramView = Backbone.View.extend(
    tagName: 'div'
    className: 'program'

    initialize: ->
        @$el.text(@model.get('title'))
        from = format_time(@model.get('start'))
        to = format_time(@model.get('end'))
        @$el.attr('title', @model.get('title') + " (#{from} - #{to})")

        left = time2px(Math.max(0, seconds_today(@model.get('start'))))
        width = time2px(seconds_today(@model.get('end'))) - left
        @$el.css(
            left: left + 'px'
            width: (width - 10) + 'px'
        )

    render: ->
        if @model.get('start') <= Date.now()
            if @model.get('end') < Date.now()
                @$el.removeClass('current').addClass('past')
            else
                @$el.addClass('current')
)

AppView = Backbone.View.extend(
    el: $('#guide')

    events:
        'click #yesterday': -> @loadDay(-1)
        'click #today': -> @loadDay(0)
        'click #tomorrow': -> @loadDay(1)

    initialize: ->
        @updateIndicator()
        @listenTo(Channels, 'reset', @addChannels)

        Channels.fetch()
        @listenTo(Settings, 'change:day', @fetchPrograms)

        setInterval((=> @updateIndicator()), 3600000 / HOUR_WIDTH)

    addChannels: () ->
        @$('.channels').empty()
        Channels.each((channel) ->
            view = new ChannelView(model: channel)
            view.render()
            @$('.channels').append(view.el)
        , @)
        @$('.indicator').height(@$('.channels').height())
        @fetchPrograms()

    loadDay: (day) ->
        Settings.set(day: day)
        @$('.navbar .active').removeClass('active')
        $(@$('.navbar .navitem')[day + 1]).addClass('active')

    updateIndicator: ->
        @$('.indicator').css('left', time2px(seconds_today(Date.now())) + 'px')

    fetchPrograms: ->
        Channels.fetchPrograms(Settings.get('day'))
)

#
# Main
#

Settings = new (Backbone.Model.extend(
    defaults: ->
        day: 0
))()
Channels = new ChannelList()
App = new AppView()
