<?php

function clean_tag_content($text) {
    $text = html_entity_decode(utf8_encode($text), ENT_COMPAT | ENT_XHTML, 'utf-8');
    return htmlentities($text, ENT_COMPAT | ENT_HTML5 | ENT_SUBSTITUTE, 'utf-8');
}

function clean_html($html) {
    $html = preg_replace('/\s+/', ' ', $html);

    $in_tag = false;
    $stack = '';
    $cleaned = '';

    for ($i = 0, $l = strlen($html); $i < $l; $i++) {
        switch ($html[$i]) {
        case '<':
            $in_tag = true;
            $cleaned .= clean_tag_content($stack) . '<';
            break;
        case '>':
            $in_tag = false;
            $cleaned .= '>';
            $stack = '';
            break;
        default:
            if ($in_tag)
                $cleaned .= $html[$i];
            else
                $stack .= $html[$i];
        }
    }

    if (!$in_tag)
        $cleaned .= clean_tag_content($stack);

    return $cleaned;
}

// Fetch details page
assert(isset($_GET['id']));
assert(is_numeric($_GET['id']));
$url = 'http://www.tvgids.nl/programma/' . $_GET['id'];
$page = file_get_contents($url);

// Parse detailed description, preserving a selected set of HTML tags
assert(preg_match('/<div\s+id="prog-content">\s*(.*?)\s*<div\s+class="prog-functionbar">/s', $page, $m1));
$description = strip_tags($m1[1], '<p><strong><em><b><i><font><a><span><img><br>');
$description = str_replace('showVideoPlaybutton()', '', $description);
$description = clean_html($description);
//$description = preg_replace('/\s+/', ' ', $description);
//$description = htmlentities($description, ENT_COMPAT | ENT_HTML5 | ENT_SUBSTITUTE, 'ISO-8859-1');
//$description = str_replace(array('&lt;', '&gt;', '&sol;'), array('<', '>', '/'), $description);

// Parse properties list
assert(preg_match('/<ul\s+id="prog-info-content-colleft">\s*(.*?)\s*<\/ul>/s', $page, $m2));
assert(preg_match_all('/<li><strong>(\w+):<\/strong>(.*?)<\/li>/', $m2[1], $m3));
$properties = array();
foreach ($m3[1] as $i => $name)
    $properties[] = array('name' => $name, 'value' => $m3[2][$i]);

header('Content-Type: application/json; charset=utf-8');
echo json_encode(compact('description', 'properties'), JSON_UNESCAPED_SLASHES);

?>
