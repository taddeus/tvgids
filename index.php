<?php
date_default_timezone_set('Europe/Amsterdam');
function getwday($day) {
    $wdays = array('zondag', 'maandag', 'dinsdag', 'woensdag', 'donderdag',
                   'vrijdag', 'zaterdag');
   return ucfirst($wdays[getdate(time() + $day * 24 * 60 * 60)['wday']]);
}
?>
<!doctype html>
<html>
    <head>
        <title>TV gids</title>
        <link href="style.css" type="text/css" rel="stylesheet">
        <link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.min.css" rel="stylesheet">
    </head>
    <body>
        <div id="guide" class="guide">
            <div class="channels">
            </div>
            <div class="indicator"></div>
            <div class="channel-labels"></div>
            <div class="timeline-bg"></div>
            <div class="timeline">
                <div class="hour">00:00</div>
                <div class="hour">01:00</div>
                <div class="hour">02:00</div>
                <div class="hour">03:00</div>
                <div class="hour">04:00</div>
                <div class="hour">05:00</div>
                <div class="hour">06:00</div>
                <div class="hour">07:00</div>
                <div class="hour">08:00</div>
                <div class="hour">09:00</div>
                <div class="hour">10:00</div>
                <div class="hour">11:00</div>
                <div class="hour">12:00</div>
                <div class="hour">13:00</div>
                <div class="hour">14:00</div>
                <div class="hour">15:00</div>
                <div class="hour">16:00</div>
                <div class="hour">17:00</div>
                <div class="hour">18:00</div>
                <div class="hour">19:00</div>
                <div class="hour">20:00</div>
                <div class="hour">21:00</div>
                <div class="hour">22:00</div>
                <div class="hour">23:00</div>
            </div>
        </div>

        <div id="loading-screen" class="loading-screen">
            <div class="bg"></div>
            <div class="loader"></div>
        </div>

        <div class="navbar">
            <a href="javascript:void(0);" id="beforeyesterday"
                class="navitem"><?php echo getwday(-2) ?></a>
            <a href="javascript:void(0);" id="yesterday" class="navitem">Gisteren</a>
            <a href="javascript:void(0);" id="today" class="navitem active">Vandaag</a>
            <a href="javascript:void(0);" id="tomorrow" class="navitem">Morgen</a>
            <a href="javascript:void(0);" id="overmorrow"
                class="navitem"><?php echo getwday(2) ?></a>
            <a href="settings.php" class="navitem">Selecteer zenders</a>
        </div>

        <script src="lib/jquery-1.10.2.min.js" type="text/javascript"></script>
        <script src="lib/underscore-min.js" type="text/javascript"></script>
        <script src="lib/backbone-min.js" type="text/javascript"></script>

        <script src="channels.js" type="text/javascript"></script>
        <script src="guide.js" type="text/javascript"></script>
    </body>
</html>
