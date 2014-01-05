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
        <title>TV gids - Selecteer zenders</title>
        <meta charset="utf-8">
        <meta name="robots" content="noindex, nofollow">
        <link href="style.css" type="text/css" rel="stylesheet">
    </head>
    <body>
        <div class="navbar">
            <a href="javascript:void(0);" id="beforeyesterday"
                class="navitem disabled"><?php echo getwday(-2) ?></a>
            <a href="javascript:void(0);" id="yesterday" class="navitem disabled">Gisteren</a>
            <a href="index.php" id="today" class="navitem">Vandaag</a>
            <a href="javascript:void(0);" id="tomorrow" class="navitem disabled">Morgen</a>
            <a href="javascript:void(0);" id="overmorrow"
                class="navitem disabled"><?php echo getwday(2) ?></a>
            <a href="settings.php" class="navitem active">Selecteer zenders</a>
        </div>

        <form id="select-channels" class="select-channels">
            <div class="options"></div>
            <span class="select-label">Selecteer:</span>
            <button id="select-all">Alle</button>
            <button id="select-none">Geen</button>
            <button id="select-default">Standaard</button>
        </form>

        <div class="copyright">
            &copy; <a href="mailto:taddeus@kompiler.org">Tadde&uuml;s Kroes</a> 2013
            - data wordt verzorgd door
            <a href="http://www.tvgids.nl" target="_blank">TVGids.nl</a>
            - source code is te vinden op
            <a href="https://github.com/taddeus/tvgids" target="_blank">Github</a>
        </div>

        <script src="lib/jquery-1.10.2.min.js" type="text/javascript"></script>
        <script src="lib/underscore-min.js" type="text/javascript"></script>
        <script src="channels.js" type="text/javascript"></script>
        <script src="settings.js" type="text/javascript"></script>
    </body>
</html>
