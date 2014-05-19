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
                <div class="hour">22:00</div>
                <div class="hour">23:00</div>

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

                <div class="hour">00:00</div>
                <div class="hour">01:00</div>
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
                    <%= p.value %>
                </li>
                <% }) %>
            </ul>
            <div class="description"><%= description %></div>
            <p>Zie ook de <a href="http://www.tvgids.nl/programma/<%= id %>"
                target="_blank">details</a> op tvgids.nl.</p>
        </script>

        <script src="lib/jquery-1.10.2.min.js" type="text/javascript"></script>
        <script src="lib/underscore-min.js" type="text/javascript"></script>
        <script src="lib/backbone-min.js" type="text/javascript"></script>

        <!--<script src="lib/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
        <script src="lib/jquery.kinetic.min.js" type="text/javascript"></script>
        <script src="lib/jquery.smoothTouchScroll.min.js" type="text/javascript"></script>

        <script src="lib/iscroll-lite.js" type="text/javascript"></script>-->

        <script src="channels.js" type="text/javascript"></script>
        <script src="guide.js" type="text/javascript"></script>

        <script>
            (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
            })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
            ga('create', 'UA-13215444-2', 'tkroes.nl');
            ga('send', 'pageview');
        </script>
    </body>
</html>
