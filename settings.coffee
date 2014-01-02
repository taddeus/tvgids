STORAGE_CHANNELS = 'tvgids-channels'
DEFAULT_CHANNELS = [1, 2, 3, 4, 31, 46, 92, 36, 37, 34, 29, 18, 91]
DEFAULT_CHANNELS = _.map(DEFAULT_CHANNELS, String)

visible = if localStorage.hasOwnProperty(STORAGE_CHANNELS) \
    then localStorage.getItem(STORAGE_CHANNELS).split(';') \
    else _.pluck(CHANNELS, 'id')

_.each CHANNELS, (channel) ->
    is_visible = _.contains(visible, channel.id)

    input = $('<input type="checkbox" name="channels[]" value="' + channel.id + '">')
    input.attr('checked', is_visible)
    input.change(-> $(@).parent().toggleClass('disabled', not $(@).is(':checked')))
    input.change(-> $('#select-channels').submit())

    elem = $('<label/>').html(channel.name)
    elem.prepend(input)
    elem.toggleClass('disabled', not is_visible)
    elem.appendTo('#select-channels .options')

$('#select-channels').submit (e) ->
    e.preventDefault()
    selected = ($(i).val() for i in $('input', @) when $(i).is(':checked'))
    localStorage.setItem(STORAGE_CHANNELS, selected.join(';'))

setall = (c) -> $('#select-channels input').prop(checked: c).change()
$('#select-all').click -> setall(true)
$('#select-none').click -> setall(false)
$('#select-default').click ->
    $('#select-channels input').each ->
        $(@).prop(checked: _.contains(DEFAULT_CHANNELS, $(@).val())).change()
