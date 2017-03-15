<?php
/*
 * This file is part of Flarum.
 *
 * (c) Toby Zerner <toby.zerner@gmail.com>
 * Modified by Bekcpear <i@ume.ink>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Flarum\Core\Search\Discussion\Fulltext;

use Flarum\Core\Post;

class MySqlFulltextDriver implements DriverInterface
{
    /**
     * {@inheritdoc}
     */
    public function match($string)
    {
        $str_t = preg_replace('~[\x00-\x7f]+~i', '', $string);
        $cNum = strlen(iconv("UTF-8", "GB2312//IGNORE", $str_t));
        $sNum = strlen($str_t);
        if($cNum != 0 && $sNum != 0 && $cNum / $sNum < 0.6){
          $ccconfig = opencc_open('tw2sp.json');
        }elseif($cNum === 0 && $sNum !== 0){
          $ccconfig = opencc_open('tw2sp.json');
        }else{
          $ccconfig = opencc_open('s2twp.json');
        }
        $discussionIds = Post::where('type', 'comment')
                ->where('content', 'like', '%'.$string.'%')
            ->lists('discussion_id', 'id');
        if($sNum !== 0){
          $string_add = opencc_convert($string, $ccconfig);
          $discussionIds_add = Post::where('type', 'comment')
                ->where('content', 'like', '%'.$string_add.'%')
            ->lists('discussion_id', 'id');
        }
        opencc_close($ccconfig);

        $relevantPostIds = [];

        if(count($discussionIds) !== 0){
          foreach ($discussionIds as $postId => $discussionId) {
            $relevantPostIds[$discussionId][] = $postId;
          }
        }
        if(isset($discussionIds_add) && count($discussionIds_add) !== 0){
          foreach ($discussionIds_add as $postId => $discussionId) {
            $relevantPostIds[$discussionId][] = $postId;
          }
        }

        return $relevantPostIds;
    }
}
