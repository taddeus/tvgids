#
# Config
#

HOUR_WIDTH = 200
CHANNEL_LABEL_WIDTH = 180
STORAGE_CHANNELS = 'tvgids-channels'
STORAGE_PROGRAMS = 'tvgids-programs'
HOURS_BEFORE = HOURS_AFTER = 2
DEFAULT_CHANNELS = [1, 2, 3, 4, 31, 46, 92, 36, 37, 34, 29, 18, 91]
DEFAULT_CHANNELS = _.map(DEFAULT_CHANNELS, String)
DETAILS_WINDOW_PADDING = 22  # top/bottom margin between details div and window edge

#
# Utils
#

day_start = -> (new Date()).setHours(0, 0, 0, 0)
day_offset = -> Settings.get('day') * 24 * 60 * 60 * 1000
seconds_today = (time) -> (time - day_start() - day_offset()) / 1000
time2px = (seconds) -> HOUR_WIDTH / 3600 * seconds
zeropad = (digit) -> if digit < 10 then '0' + digit else String(digit)
format_time = (time) ->
    date = new Date(time)
    zeropad(date.getHours()) + ':' + zeropad(date.getMinutes())
parse_date = (str) ->
    [date, time] = str.split(' ')
    [year, month, day] = date.split('-')
    [hours, minutes, seconds] = time.split(':')
    (new Date(year, month - 1, day, hours, minutes, seconds)).getTime()

store_list = (name, values) -> localStorage.setItem(name, values.join(';'))
load_stored_list = (name, def) ->
    store_list(name, def) if not localStorage.hasOwnProperty(name)
    value = localStorage.getItem(name)
    if value.length > 0 then value.split(';') else []

#
# Models & collections
#

Channel = Backbone.Model.extend
    defaults:
        id: null
        name: 'Some channel'
        visible: true
        programs: []


Program = Backbone.Model.extend
    defaults:
        id: null
        title: 'Some program'
        genre: ''
        sort: ''
        start: 0
        end: 0
        article_id: null
        article_title: null


ChannelList = Backbone.Collection.extend
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
        # Sometimes a program list is an object (PHP's json_encode() is
        # probably given an associative array)
        to_array = (o) -> if o.length? then o else _.map(o, ((v, k) -> v))

        $('#loading-screen').show()
        $.getJSON(
            'programs.php'
            channels: Settings.get('favourite_channels').join(','), day: day
            (channels) ->
                _.each channels, (programs, id) ->
                    channel = Channels.findWhere(id: id)
                    channel.set(programs: (
                        new Program(
                            id: p.db_id
                            title: p.titel
                            genre: p.genre
                            sort: p.soort
                            start: parse_date(p.datum_start)
                            end: parse_date(p.datum_end)
                            article_id: p.artikel_id
                            article_title: p.artikel_titel
                        ) for p in to_array(programs)
                    )) if channel?
                $('#loading-screen').hide()
        )

#
# Views
#

ChannelView = Backbone.View.extend
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


ProgramView = Backbone.View.extend
    tagName: 'div'
    className: 'program'

    events:
        'click .favlink': 'toggleFavourite'
        'click': -> Settings.set(selected_program: @model.get('id'))

    initialize: ->
        $('<span class="title"/>').text(@model.get('title')).appendTo(@el)
        from = format_time(@model.get('start'))
        to = format_time(@model.get('end'))
        @$el.attr('title', @model.get('title') + " (#{from} - #{to})")

        @$fav = $('<a class="favlink icon-heart"/>').appendTo(@el)
        @$fav.attr('title', 'Als favoriet instellen')
        @updateFavlink()

        left = time2px(Math.max(-HOURS_BEFORE * 60 * 60,
                                seconds_today(@model.get('start'))))
        width = time2px(seconds_today(@model.get('end'))) - left
        @$el.css(
            left: ((HOURS_BEFORE * HOUR_WIDTH) + left) + 'px'
            width: (width - 10) + 'px'
        )

        @listenTo(Settings, 'change:favourite_programs', @updateFavlink)
        @listenTo(Clock, 'tick', @render)

    toggleFavourite: (e) ->
        Settings.toggleFavouriteProgram(@model.get('title'))
        e.stopPropagation()

    updateFavlink: ->
        isfav = Settings.isFavouriteProgram(@model.get('title'))
        @$el.toggleClass('favourite', isfav)

    render: ->
        if @model.get('start') <= Date.now()
            if @model.get('end') < Date.now()
                @$el.removeClass('current').addClass('past')
                @stopListening(Clock, 'tick')
            else
                @$el.addClass('current')


ChannelLabelsView = Backbone.View.extend
    el: $('#channel-labels')

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


ProgramDetailsView = Backbone.View.extend
    el: $('#program-details')
    template: _.template($('#details-template').html())

    events:
        'click .bg': -> Settings.set(selected_program: null)

    initialize: (options) ->
        @listenTo(Settings, 'change:selected_program', @toggleDetails)
        @setBounds()
        $(window).resize(=> @setBounds())

    toggleDetails: ->
        id = Settings.get('selected_program')

        if id
            $('#loading-screen').show()
            $.getJSON(
                'details.php'
                id: id
                (data) =>
                    $('#loading-screen').hide()
                    @$el.show()
                    @$('.content').html(@template(_.extend(id: id, data)))
                    @alignMiddle()

                    # Align again after images are loaded
                    @$('.content img').load(-> $(@).css(height: 'auto'))
                    @$('.content img').load(=> @alignMiddle())
            )
        else
            @$el.hide()
            @$('.content').empty()

    setBounds: ->
        max = $(window).height() - 2 * DETAILS_WINDOW_PADDING
        @$('.content').css(maxHeight: max)
        @alignMiddle()

    alignMiddle: ->
        height = @$('.content').outerHeight()
        @$('.content').css(marginTop: "-#{height / 2}px")


AppView = Backbone.View.extend
    el: $('#guide')

    events:
        # TODO: move to initialize
        'scroll': 'moveTimeline'

    initialize: ->
        @prevScrollTop = null

        @listenTo(Channels, 'reset', @addChannels)
        @listenTo(Settings, 'change:day', @fetchPrograms)

        @labelview = new ChannelLabelsView(app: @)
        @detailsview = new ProgramDetailsView(app: @)

        #@$el.smoothTouchScroll(
        #    scrollableAreaClass: 'channels'
        #    scrollWrapperClass: 'guide'
        #)
        #@iscroll = new iScroll('guide', vScroll: false, hScrollbar: true)

        $('#beforeyesterday').click(-> Settings.set(day: -2))
        $('#yesterday').click(-> Settings.set(day: -1))
        $('#today').click(-> Settings.set(day: 0))
        $('#tomorrow').click(-> Settings.set(day: 1))
        $('#overmorrow').click(-> Settings.set(day: 2))

        $('#help').click((e) -> e.stopPropagation(); $('#help-popup').show())
        $(document).click(-> $('#help-popup').hide())

        Channels.fetch()
        @centerIndicator()
        @updateIndicator()
        @listenTo(Clock, 'tick', @updateIndicator)

    addChannels: ->
        @$('.channels > .channel').remove()
        Channels.each((channel) ->
            view = new ChannelView(model: channel)
            view.render()
            @$('.channels').append(view.el)
        , @)
        @fetchPrograms()

    updateIndicator: ->
        if Settings.get('day') == 0
            left = time2px(seconds_today(Date.now())) + CHANNEL_LABEL_WIDTH - 1
            @$('.indicator')
                .css(left: ((HOURS_BEFORE * HOUR_WIDTH) + left) + 'px')
                .height(@$('.channels').height() - 2)
                .show()
        else
            @$('.indicator').hide()

    centerIndicator: ->
        @$el.scrollLeft(@$('.indicator').position().left - @$el.width() / 2)

    fetchPrograms: ->
        day = Settings.get('day')
        Channels.fetchPrograms(day)
        @updateIndicator()
        $('.navbar .active').removeClass('active')
        $($('.navbar .navitem')[day + 2]).addClass('active')

    moveTimeline: ->
        if @$el.scrollTop() != @prevScrollTop
            @trigger('scroll', @$el.scrollTop() - @prevScrollTop)
            @prevScrollTop = @$el.scrollTop()
            @$('.timeline').css('top', (@$el.scrollTop() + 37) + 'px')

#
# Main
#

Settings = new (Backbone.Model.extend
    defaults:
        day: 0
        favourite_channels: load_stored_list(STORAGE_CHANNELS, DEFAULT_CHANNELS)
        favourite_programs: load_stored_list(STORAGE_PROGRAMS, [])
        selected_program: null

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
)()

Clock = new (->
    _.extend(@, Backbone.Events)
    setInterval((=> @trigger('tick')), 60 * 60 * 1000 / HOUR_WIDTH)
)()

Channels = new ChannelList()
App = new AppView()
