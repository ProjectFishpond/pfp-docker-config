<?php
namespace Flarum\Api;

use Tobscure\JsonApi\Document;
use Zend\Diactoros\Response\JsonResponse;

class JsonApiResponse extends JsonResponse {
  public function __construct(Document $document, $status = 200, array $headers = [], $encodingOptions = 15) {
    $headers['content-type'] = 'application/vnd.api+json';

  $lang="";
  if(isset($_SERVER["HTTP_ACCEPT_LANGUAGE"])) {
    preg_match_all('/([a-z\-]+)/i', $_SERVER['HTTP_ACCEPT_LANGUAGE'], $matches);
    $lang = strtolower($matches[0][0]);
    if($lang === 'zh' && isset($matches[0][1]) && strpos(strtolower($matches[0][1]), 'zh') === 0){
      $lang = strtolower($matches[0][1]);
    }
  }

  switch ($lang) {
    case "zh":
    case "zh-cn":
      $ccconfig = opencc_open("tw2sp.json");
      $cctext = opencc_convert(json_encode($document->jsonSerialize(), 256), $ccconfig);
      opencc_close($ccconfig);
      parent::__construct(json_decode($cctext), $status, $headers, $encodingOptions);
      break;
    case "zh-tw":
      $ccconfig = opencc_open("s2twp.json");
      $cctext = opencc_convert(json_encode($document->jsonSerialize(), 256), $ccconfig);
      opencc_close($ccconfig);
      parent::__construct(json_decode($cctext), $status, $headers, $encodingOptions);
      break;
    case "zh-hk":
      $ccconfig = opencc_open("s2hk.json");
      $cctext = opencc_convert(json_encode($document->jsonSerialize(), 256), $ccconfig);
      opencc_close($ccconfig);
      parent::__construct(json_decode($cctext), $status, $headers, $encodingOptions);
      break;
    default:
      parent::__construct($document->jsonSerialize(), $status, $headers, $encodingOptions);
  }
}
}
