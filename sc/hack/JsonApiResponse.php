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

    /*
     * 繁简判断说明：
     * 判断文字是繁是简的方法是将内容去 ASCII 表 0-127 字符后对其进行转 GB2312 处理，剔除无法转义的字符后根据实际转义字符数/转义前字符数比例来判断的。
     * GB2312 完全没有编码繁体字并且简体也漏了一部分，我多次尝试了一下，一般来说比例达到 0.65 左右可以判断为简体文本
     * （但是不排除极个别情况，这种情况那就是繁体字非常非常少夹杂在简体文本中，则忽略了）
     * 我这边主要是简体主流，所以我判断下降到了 0.6，可以根据实际情况修改
     */
    $cNum = strlen(iconv("UTF-8", "GB2312//IGNORE", $str_t));
    $sNum = strlen($str_t);
    if($cNum != 0 && $sNum != 0 && $cNum / $sNum < 0.6 && $lang === 'zh-cn'){
      // traditional source to simplified
      $ccconfig = opencc_open('tw2sp.json');
    }elseif($cNum === 0 && $sNum != 0 && $lang === 'zh-cn'){
      // traditional source to simplified
      $ccconfig = opencc_open('tw2sp.json');
    }elseif($lang === 'zh-tw'){
      // simplified source to traditional TW
      $ccconfig = opencc_open('s2twp.json');
    }elseif($lang === 'zh-hk'){
      // simplified source to traditional HK
      $ccconfig = opencc_open('s2hk.json');
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
