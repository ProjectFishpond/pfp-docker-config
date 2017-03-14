<?php

/* Written by Bekcpear
 * 
 */
 
namespace Flarum\Api;

use Tobscure\JsonApi\Document;
use Zend\Diactoros\Response\JsonResponse;

class JsonApiResponse extends JsonResponse {

  protected function cc($includeC, $config){
    $ccconfig = opencc_open($config);
    $cctext = opencc_convert($includeC, $ccconfig);
    opencc_close($ccconfig);
    return $cctext;
  }

  public function __construct(Document $document, $status = 200, array $headers = [], $encodingOptions = 15) {
    $headers['content-type'] = 'application/vnd.api+json';

    $lang="";
    $cNeeded = false;
    $content = $document->jsonSerialize();

    if(isset($_SERVER["HTTP_ACCEPT_LANGUAGE"])) {
      preg_match_all('/([a-z\-]+)/i', $_SERVER['HTTP_ACCEPT_LANGUAGE'], $matches);
      $lang = strtolower($matches[0][0]);
      if($lang === 'zh'){
        if(isset($matches[0][1]) && strpos(strtolower($matches[0][1]), 'zh') === 0){
          $lang = strtolower($matches[0][1]);
        }else{
          $lang = 'zh-cn';
        }
      }
    }

    if(isset($content["included"])){
      $len = count($include = $content["included"]);
      for($i=0; $i<$len; $i++){
        if($include[$i]["type"] === "posts" && $include[$i]["attributes"]["contentType"] === "comment"){
          $str_t = preg_replace('~[\x00-\x7f]+~i', '', $include[$i]["attributes"]["contentHtml"]);
          $cNum = strlen(iconv("UTF-8", "GB2312//IGNORE", $str_t));
          $sNum = strlen($str_t);
          if($cNum != 0 && $sNum != 0 && $cNum / $sNum < 0.6 && $lang === 'zh-cn'){
            // traditional source to simplified 
            $content["included"][$i]["attributes"]["contentHtml"] = $this->cc($content["included"][$i]["attributes"]["contentHtml"], 'tw2sp.json');
          }elseif($lang === 'zh-tw' || $lang === 'zh-hk'){
            $content["included"][$i]["attributes"]["contentHtml"] = $this->cc($content["included"][$i]["attributes"]["contentHtml"], 's2twp.json');
          }
        }
      }
    }

    parent::__construct($content, $status, $headers, $encodingOptions);
  }
}
