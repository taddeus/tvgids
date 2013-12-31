<?php
assert(isset($_GET['id']));
assert(is_numeric($_GET['id']));
$url = 'http://www.tvgids.nl/programma/' . $_GET['id'];
$page = file_get_contents($url);

preg_match('/<div\s+id="prog-content">\s*(.*?)\s*<div\s+class="prog-functionbar">/s', $page, $m1);
assert($m1);
$description = trim(strip_tags($m1[1], '<p><strong><em><b><i><font><a><span>'));
$description = str_replace('showVideoPlaybutton()', '', $description);
$description = preg_replace('/\s+/', ' ', $description);

preg_match('/<ul\s+id="prog-info-content-colleft">\s*(.*?)\s*<\/ul>/s', $page, $m2);
assert($m2);
preg_match_all('/<li><strong>(\w+):<\/strong>(.*?)<\/li>/', $m2[1], $m3);
assert($m3);
$props = array();
foreach ($m3[1] as $i => $name)
    $props[] = array('name' => $name, 'value' => $m3[2][$i]);

echo json_encode(array(
    'description' => $description,
    'properties' => $props
));
?>
