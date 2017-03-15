<?php

/* Written by Bekcpear
 *
 */

namespace Flarum\Api;

use Tobscure\JsonApi\Document;
use Zend\Diactoros\Response\JsonResponse;

class JsonApiResponse extends JsonResponse {

  protected $tran_content;

  protected function cc($rKey, $cKey, $lang, $i = null){
    if($i === null){
      if(! isset($this->tran_content[$rKey]["attributes"])) return;
      $str_t = preg_replace('~[\x00-\x7f]+~i', '', $this->tran_content[$rKey]["attributes"][$cKey]);
    }else{
      if(! isset($this->tran_content[$rKey][$i]["attributes"])) return;
      $str_t = preg_replace('~[\x00-\x7f]+~i', '', $this->tran_content[$rKey][$i]["attributes"][$cKey]);
    }

    $cNum = strlen(iconv("UTF-8", "GB2312//IGNORE", $str_t));
    $sNum = strlen($str_t);
    if($cNum != 0 && $sNum != 0 && $cNum / $sNum < 0.6 && $lang === 'zh-cn'){
      // traditional source to simplified
      $ccconfig = opencc_open('tw2sp.json');
    }elseif($cNum === 0 && $sNum != 0 && $lang === 'zh-cn'){
      // traditional source to simplified
      $ccconfig = opencc_open('tw2sp.json');
    }elseif($lang === 'zh-tw' || $lang === 'zh-hk'){
      // simplified source to traditional
      $ccconfig = opencc_open('s2twp.json');
    }else{
      return;
    }
    if($i === null){
      $cctext = opencc_convert($this->tran_content[$rKey]["attributes"][$cKey], $ccconfig);
      $this->tran_content[$rKey]["attributes"][$cKey] = $cctext;
    }else{
      $cctext = opencc_convert($this->tran_content[$rKey][$i]["attributes"][$cKey], $ccconfig);
      $this->tran_content[$rKey][$i]["attributes"][$cKey] = $cctext;
    }
    opencc_close($ccconfig);
  }

  protected function judge($lang, $rKey, $i = null){
    if($i === null && isset($this->tran_content[$rKey]["type"])){
        $content = $this->tran_content[$rKey];
    }elseif($i !== null && isset($this->tran_content[$rKey][$i]["type"])){
        $content = $this->tran_content[$rKey][$i];
    }
    if(isset($content)){
      if(! isset($content["attributes"])) return;
      if($content["type"] === "posts" && $content["attributes"]["contentType"] === "comment"){
        $cKey = 'contentHtml';
      }elseif($content["type"] === "discussions"){
        $cKey = 'title';
      }else{
        return;
      }
      $this->cc($rKey, $cKey, $lang, $i);
    }
  }

  public function __construct(Document $document, $status = 200, array $headers = [], $encodingOptions = 15) {
    $headers['content-type'] = 'application/vnd.api+json';

    $lang="";
    $cNeeded = false;
    $this->tran_content = $document->jsonSerialize();

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

    if(isset($this->tran_content["data"])){
      if(isset($this->tran_content["data"]["type"]) && $this->tran_content["data"]["type"] === "discussions" && isset($this->tran_content["data"]["attributes"]) && isset($this->tran_content["data"]["attributes"]["title"])){
        $this->judge($lang, 'data');
      }else{
        $len = count($this->tran_content["data"]);
        for($i=0; $i<$len; $i++){
          $this->judge($lang, 'data', $i);
        }
      }
    }

    if(isset($this->tran_content["included"])){
      $len = count($this->tran_content["included"]);
      for($i=0; $i<$len; $i++){
        $this->judge($lang, 'included', $i);
      }
    }

    parent::__construct($this->tran_content, $status, $headers, $encodingOptions);
  }
}
