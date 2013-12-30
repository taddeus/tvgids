<?php
echo file_get_contents('http://www.tvgids.nl/json/lists/programs.php?channels='
                       . $_GET['channels'] . '&day=' . $_GET['day'])
?>
