<?php

require_once 'lib/simple_html_dom.php';

$assert_counter = 0;

function check($condition, $bad_request=false) {
    global $assert_counter;
    $assert_counter++;

    if (!$condition) {
        if ($bad_request) {
            header('HTTP/1.1 400 Bad Request');
        } else {
            header('HTTP/1.1 500 Internal Server Error');
            echo 'failed to parse scraped data ' . $assert_counter;
        }
        exit;
    }

    return $condition;
}

// Fetch details page
check(isset($_GET['id']), true);
check(is_numeric($_GET['id']), true);
$url = 'http://www.tvgids.nl/programma/' . $_GET['id'] . '?cookieoptin=true';
$dom = file_get_html($url);

$response = compact('url');

foreach ($dom->find('head meta[property^=og:]') as $tag) {
    $key = substr($tag->property, 3);
    if ($key == 'title' || $key == 'description' || $key == 'url')
        $response[$key] = $tag->content;
}

if ($prog = $dom->getElementById('prog-content')) {
    //if ($video = $prog->getElementById('prog-video')) {
    //    $response['media'] = $video->outertext;
    //} else if ($carousel = $prog->find('.owl-carousel', 0)) {
    //    //$images = array();
    //    //foreach ($carousel->find('div[style^=background:]') as $img) {
    //    //    check(preg_match('/^background:\s*url\(\'(.*?)\'\).*$/', $img->style, $m));
    //    //    $images[] = $m[1];
    //    //}

    //    $response['media'] = $carousel->outertext;
    //}

    $response['properties'] = array();

    foreach ($prog->find('.programmering_info_detail li') as $tag) {
        $response['properties'][] = array(
            'name' => preg_replace('/:\s+$/', '', $tag->children(0)->plaintext),
            'description' => $tag->children(1)->innertext,
        );
    }
}

header('Content-Type: application/json; charset=utf-8');
echo json_encode($response, JSON_UNESCAPED_SLASHES);

?>
