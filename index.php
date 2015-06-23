<?php
$HOURS_BEFORE = $HOURS_AFTER = 2;

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
        <meta charset="utf-8">
        <meta name="author" content="Taddeus Kroes">
        <meta name="robots" content="index, nofollow">
        <meta name="description" content="Een snelle, makkelijk te gebruiken TV gids voor Nederlandse televisie.">
        <meta name="keywords" content="tvgids, TV, gids, Nederland, zender, programma">
        <link href="style.css" type="text/css" rel="stylesheet">
        <link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.min.css" rel="stylesheet">
    </head>
    <body>
        <div id="guide" class="guide">
            <div class="channels">
            </div>
            <div class="indicator"></div>
            <div class="timeline-bg"></div>
            <div class="timeline">
                <?php
                for ($i = -$HOURS_BEFORE; $i < 24 + $HOURS_AFTER; $i++)
                    printf('<div class="hour">%02d:00</div>', ($i + 24) % 24);
                ?>
            </div>
        </div>
        <div id="channel-labels" class="channel-labels"></div>

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
            <div id="help" class="navitem help">
                <i class="icon-info-sign" title="Gebruiksaanwijzing"></i>
                <div class="popup" id="help-popup">
                    <ul>
                        <li>Klik op een programma om details te zien.</li>
                        <li>Klik op <i class="icon-heart"></i> bij een programma om deze
                            in je favorieten te zetten. Dit wordt lokaal
                            opgeslagen, dus je moet op elke andere computer je
                            favorieten opnieuw instellen.</li>
                    </ul>
                </div>
            </div>
        </div>

        <div id="program-details" class="program-details">
            <div class="bg"></div>
            <div class="content"></div>
        </div>

        <div class="copyright">
            &copy; <a href="mailto:taddeus@kompiler.org">Tadde&uuml;s Kroes</a> 2013
            - data wordt verzorgd door
            <a href="http://www.tvgids.nl" target="_blank">TVGids.nl</a>
            - source code is te vinden op
            <a href="https://github.com/taddeus/tvgids" target="_blank">Github</a>
        </div>

        <script type="text/template" id="details-template">
            <ul class="properties">
                <% _.each(properties, function(p) { %>
                <li>
                    <strong><%= p.name %>:</strong>
                    <%= p.description %>
                </li>
                <% }) %>
            </ul>
            <div class="description">
                <h2><%= title %></h2>
                <p><%= description %></p>
            </div>
            <p>Zie ook de <a href="<%= url %>" target="_blank"
                >details</a> op tvgids.nl.</p>
        </script>

        <script src="lib/jquery-1.10.2.min.js" type="text/javascript"></script>
        <script src="lib/underscore-min.js" type="text/javascript"></script>
        <script src="lib/backbone-min.js" type="text/javascript"></script>
        <script src="channels.js" type="text/javascript"></script>
        <script src="guide.js" type="text/javascript"></script>

        <?php include_once 'analytics.php'; ?>
    </body>
</html>
