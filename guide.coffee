#
# Config
#

FETCH_URL = 'programs.php'
HOUR_WIDTH = 200
CHANNEL_LABEL_WIDTH = 180
STORAGE_CHANNELS = 'tvgids-channels'
STORAGE_PROGRAMS = 'tvgids-programs'
#SCROLL_MULTIPLIER = HOUR_WIDTH

#
# Utils
#

seconds_today = (time) -> (time - (new Date()).setHours(0, 0, 0, 0)) / 1000
time2px = (seconds) -> HOUR_WIDTH / 3600 * seconds
zeropad = (digit) -> if digit < 10 then '0' + digit else String(digit)
format_time = (time) ->
    date = new Date(time)
    zeropad(date.getHours()) + ':' + zeropad(date.getMinutes())

store_list = (name, values) -> localStorage.setItem(name, values.join(';'))
load_stored_list = (name, def) ->
    store_list(name, def) if not localStorage.hasOwnProperty(name)
    value = localStorage.getItem(name)
    if value.length > 0 then value.split(';') else []

#
# Models & collections
#

Channel = Backbone.Model.extend(
    defaults:
        id: null
        name: 'Some channel'
        visible: true
        programs: []
)

Program = Backbone.Model.extend(
    defaults:
        title: 'Some program'
        genre: ''
        sort: ''
        start: 0
        end: 0
        article_id: null
        article_title: null
)

ChannelList = Backbone.Collection.extend(
    model: Channel
    #comparator: (a, b) -> parseInt(a.get('id')) - parseInt(b.get('id'))

    initialize: ->
        @listenTo(Settings, 'change:favourite_channels', @propagateVisible)

    fetch: ->
        @reset(CHANNELS)
        #$.getJSON('channels.php', (data) => @reset(data))
        @propagateVisible()

    propagateVisible: ->
        visible = Settings.get('favourite_channels')

        for id in visible
            @findWhere(id: id)?.set(visible: true)

        for id in _.difference(@pluck('id'), visible)
            @findWhere(id: id)?.set(visible: false)

    fetchPrograms: (day) ->
        $('#loading-screen').show()
        $.getJSON(
            FETCH_URL
            channels: @pluck('id').join(','), day: day
            (channels) ->
                _.each channels, (programs, id) ->
                    channel = Channels.findWhere(id: id)
                    channel.set(programs: (
                        new Program(
                            title: p.titel
                            genre: p.genre
                            sort: p.soort
                            start: Date.parse(p.datum_start)
                            end: Date.parse(p.datum_end)
                            article_id: p.artikel_id
                            article_title: p.artikel_titel
                        ) for p in programs
                    ))
                $('#loading-screen').hide()
        )
)

#
# Views
#

ChannelView = Backbone.View.extend(
    tagName: 'div'
    className: 'channel'

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

    events:
        'click .favlink': 'toggleFavourite'

    initialize: ->
        $('<span class="title"/>').text(@model.get('title')).appendTo(@el)
        from = format_time(@model.get('start'))
        to = format_time(@model.get('end'))
        @$el.attr('title', @model.get('title') + " (#{from} - #{to})")

        @$fav = $('<a class="favlink icon-heart"/>').appendTo(@el)
        @$fav.attr('title', 'Als favoriet instellen')
        @updateFavlink()

        left = time2px(Math.max(0, seconds_today(@model.get('start'))))
        width = time2px(seconds_today(@model.get('end'))) - left
        @$el.css(
            left: left + 'px'
            width: (width - 10) + 'px'
        )

        @listenTo(Settings, 'change:favourite_programs', @updateFavlink)

    toggleFavourite: ->
        Settings.toggleFavouriteProgram(@model.get('title'))

    updateFavlink: ->
        isfav = Settings.isFavouriteProgram(@model.get('title'))
        @$fav.toggleClass('favourite', isfav)

    render: ->
        if @model.get('start') <= Date.now()
            if @model.get('end') < Date.now()
                @$el.removeClass('current').addClass('past')
            else
                @$el.addClass('current')
)

ChannelLabelsView = Backbone.View.extend(
    el: $('.channel-labels')

    initialize: (options) ->
        @listenTo(Channels, 'reset', @addChannels)
        @listenTo(options.app, 'scroll', @moveTop)

    addChannels: ->
        @$el.empty()
        Channels.each((channel) ->
            elem = $('<div id="label-' + channel.get('id') + '" class="label"/>')
            elem.html(channel.get('name')).toggle(channel.get('visible')).appendTo(@el)
            @listenTo(channel, 'change:visible', -> @toggleVisible(channel))
        , @)

    moveTop: (delta) ->
        @$el.css('top', (@$el.position().top - delta) + 'px')

    toggleVisible: (channel) ->
        @$('#label-' + channel.get('id')).toggle(channel.get('visible'))
)

AppView = Backbone.View.extend(
    el: $('#guide')

    events:
        # TODO: move to initialize
        'click #yesterday': -> @loadDay(-1)
        'click #today': -> @loadDay(0)
        'click #tomorrow': -> @loadDay(1)
        'scroll': 'moveTimeline'

    moveTimeline: ->
        if @$el.scrollTop() != @prevScrollTop
            @trigger('scroll', @$el.scrollTop() - @prevScrollTop)
            @prevScrollTop = @$el.scrollTop()
            @$('.timeline').css('top', (@$el.scrollTop() + 37) + 'px')

    initialize: ->
        @prevScrollTop = null

        @listenTo(Channels, 'reset', @addChannels)
        @listenTo(Settings, 'change:day', @fetchPrograms)

        @labelview = new ChannelLabelsView(app: @)

        Channels.fetch()
        @centerIndicator()
        @updateIndicator()
        setInterval((=> @updateIndicator()), 3600000 / HOUR_WIDTH)

    addChannels: ->
        @$('.channels > .channel').remove()
        Channels.each((channel) ->
            view = new ChannelView(model: channel)
            view.render()
            @$('.channels').append(view.el)
        , @)
        @updateIndicator()
        @fetchPrograms()

    loadDay: (day) ->
        Settings.set(day: day)
        @$('.navbar .active').removeClass('active')
        $(@$('.navbar .navitem')[day + 1]).addClass('active')

    updateIndicator: ->
        left = time2px(seconds_today(Date.now())) + CHANNEL_LABEL_WIDTH - 1
        @$('.indicator')
            .css('left', left + 'px')
            .height(@$('.channels').height() - 2)

    centerIndicator: ->
        @$el.scrollLeft(@$('.indicator').position().left - @$el.width() / 2)

    fetchPrograms: ->
        Channels.fetchPrograms(Settings.get('day'))
)

#
# Main
#

Settings = new (Backbone.Model.extend(
    defaults:
        day: 0
        favourite_channels: load_stored_list(STORAGE_CHANNELS,
                                             _.pluck(CHANNELS, 'id'))
        favourite_programs: load_stored_list(STORAGE_PROGRAMS, [])

    toggleFavouriteProgram: (title) ->
        list = @get('favourite_programs')

        if @isFavouriteProgram(title)
            list.splice(list.indexOf(title), 1)
        else
            list.push(title)

        @attributes.favourite_programs = list
        @trigger('change:favourite_programs')
        store_list(STORAGE_PROGRAMS, list)

    isFavouriteProgram: (title) ->
        _.contains(@get('favourite_programs'), title)
))()
Channels = new ChannelList()
App = new AppView()
