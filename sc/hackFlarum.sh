#!/usr/bin/bash
#
# 大部分来自 https://vivaldi.club & 针对性修改 & 添加

# 逢千貼不縮寫為「n 千」，而改為逢萬縮寫「n 萬」
echo '逢千貼不縮寫為「n 千」，而改為逢萬縮寫「n 萬」'
sed -i -r 's#([=\/] 1000)\) #\10)#' \
    vendor/flarum/core/js/forum/dist/app.js \
    vendor/flarum/core/js/admin/dist/app.js \
    vendor/flarum/core/js/lib/utils/abbreviateNumber.js
sed -i -r 's#(kilo_text: )千#\1万#' \
    vendor/csineneo/flarum-ext-simplified-chinese/locale/core.yml
sed -i -r 's#(kilo_text: )千#\1萬#' \
    vendor/csineneo/flarum-ext-traditional-chinese/locale/core.yml

# 取消標題及用戶名最小長度限制
echo '取消標題及用戶名最小長度限制'
sed -i 's#min:3#min:1#' \
    vendor/flarum/core/src/Core/Validator/UserValidator.php \
    vendor/flarum/core/src/Core/Validator/DiscussionValidator.php

# 啟用 Pusher 後不隱藏刷新按鈕
echo '啟用 Pusher 後不隱藏刷新按鈕'
sed -i "/actionItems/,+2d" \
    vendor/flarum/flarum-ext-pusher/js/forum/dist/extension.js

# emoji 資源替換為本地鏡像（并修改 Emojiarea 改用本地）
echo 'emoji 資源替換為本地鏡像'
sed -i 's#//cdn.jsdelivr.net/emojione/assets/png#/assets/emoji/png#' \
    vendor/flarum/flarum-ext-emoji/js/forum/dist/extension.js
sed -i 's#//cdn.jsdelivr.net/emojione/assets#/assets/emoji#; s#abcdef#ABCDEF#; s#ABCDEF#abcdef#' \
    vendor/s9e/text-formatter/src/Plugins/Emoji/Configurator.php
sed -i 's#//cdn.jsdelivr.net/emojione/assets/png#/assets/emoji/png#' \
    vendor/flarum/flarum-ext-emoji/js/forum/src/addComposerAutocomplete.js
sed -i \
    -e "s/window.emojioneVersion\s||\s'2.1.4'/'2.1.4'/" \
    -e 's#defaultBase:\s"https://cdnjs.cloudflare.com/ajax/libs/emojione/"#defaultBase: "/assets/emojiarea/"#' \
    vendor/clarkwinkelmann/flarum-ext-emojionearea/js/forum/dist/extension.js

# 老外們總喜歡把文章標題給弄到 url 裡面，美其名曰 seo，可是對於 CJK 一點都不友好。移除 discussion slug 讓 URL 簡短清爽
echo '移除 discussion slug 讓 URL 簡短清爽'
sed -i "s# + '-' + discussion.slug()##" \
    vendor/flarum/core/js/forum/dist/app.js \
    vendor/flarum/core/js/forum/src/initializers/routes.js
sed -i "s# . '-'.*##" \
    vendor/flarum/core/views/index.blade.php

# 優化日期顯示
echo '優化日期顯示'
sed -i "s#-30#-1#; s#D MMM#L#; s#MMM \\\'YY#LL#" \
    vendor/flarum/core/js/forum/dist/app.js \
    vendor/flarum/core/js/lib/utils/humanTime.js

# 允許搜尋長度小於三個字符的 ID
echo '允許搜尋長度小於三個字符的 ID'
sed -i 's#query.length >= 3#query.length >= 1#' \
    vendor/flarum/core/js/forum/src/components/Search.js \
    vendor/flarum/core/js/forum/dist/app.js
sed -i 's#&& this.value().length >= 3 ##' \
    vendor/flagrow/byobu/js/forum/dist/extension.js \
#    vendor/flagrow/byobu/js/forum/src/components/RecipientSearch.js

# 帖子編輯器按鈕中文化
echo '帖子編輯器按鈕中文化'
sed -i -e 's#Strong#\\u7c97\\u4f53#;'\
    -e 's#strong text#\\u7c97\\u4f53\\u5b57#;'\
    -e 's#"Emphasis#"\\u659c\\u4f53#;'\
    -e 's#emphasized text#\\u659c\\u4f53\\u5b57#;'\
    -e 's#"Hyperlink#"\\u8d85\\u94fe\\u63a5#;'\
    -e 's#enter link description here#\\u5728\\u6b64\\u5904\\u8f93\\u5165\\u94fe\\u63a5\\u63cf\\u8ff0#;'\
    -e 's#Insert Hyperlink#\\u63d2\\u5165\\u94fe\\u63a5#;'\
    -e 's#Blockquote#\\u5f15\\u7528#g;'\
    -e 's#Code Sample#\\u4ee3\\u7801#;'\
    -e 's#enter code here#\\u5728\\u6b64\\u5904\\u8f93\\u5165\\u4ee3\\u7801#;'\
    -e 's#"Image#"\\u56fe\\u7247#;'\
    -e 's#enter image description here#\\u5728\\u6b64\\u5904\\u8f93\\u5165\\u56fe\\u7247\\u63cf\\u8ff0#;'\
    -e 's#Insert Image#\\u63d2\\u5165\\u56fe\\u7247#;'\
    -e 's#optional title#\\u53ef\\u9009\\u6807\\u9898#g;'\
    -e 's#Numbered List#\\u6709\\u5e8f\\u5217\\u8868#;'\
    -e 's#Bulleted List#\\u65e0\\u5e8f\\u5217\\u8868#;'\
    -e 's#List item#\\u5217\\u8868\\u9879#;'\
    -e 's#"Heading#"\\u6807\\u9898#g;'\
    -e 's#Horizontal Rule#\\u6c34\\u5e73\\u5206\\u5206\\u5272#;'\
    -e 's#"Undo#"\\u8fd8\\u539f#;'\
    -e 's#"Redo#"\\u91cd\\u505a#g;'\
    -e 's#Markdown Editing Help#Markdown \\u7f16\\u8f91\\u5e2e\\u52a9#;'\
    -e 's#OK#\\u597d#;'\
    -e 's#Cancel#\\u53d6\\u6d88#' \
		vendor/xengine/flarum-ext-markdown-editor/js/forum/dist/extension.js

# 不再使用 google font
echo '不再使用 google font'
sed -i "/fonts.googleapis.com/d" \
    vendor/flarum/core/views/install/app.php \
    vendor/flarum/core/src/Http/WebApp/WebAppView.php
    #vendor/flarum/core/src/Http/Controller/ClientView.php \

# emoji 選擇框中文化
echo 'emoji 選擇框中文化'
sed -i "s#title: \"Diversity\"#title: \"种类\"#; \
    s#title: \"Recent\"#title: \"最近\"#; \
    s#title: \"Smileys & People\"#title: \"笑脸与人\"#; \
    s#title: \"Animals & Nature\"#title: \"动物与自然\"#; \
    s#title: \"Food & Drink\"#title: \"食物与饮品\"#; \
    s#title: \"Activity\"#title: \"活动\"#; \
    s#title: \"Travel & Places\"#title: \"旅游与景点\"#; \
    s#title: \"Objects\"#title: \"物体\"#; \
    s#title: \"Symbols\"#title: \"符号\"#; \
    s#title: \"Flags\"#title: \"国旗\"#" \
    vendor/clarkwinkelmann/flarum-ext-emojionearea/js/forum/dist/extension.js

# 修復無法使用 CJK 字符註冊的問題
echo '修復無法使用 CJK 字符註冊的問題'
sed -i "s#a-z0-9_-#-_a-z0-9\\\x7f-\\\xff#" \
    vendor/flarum/core/src/Core/Validator/UserValidator.php

# 修正 terabin/flarum-ext-sitemap 不支援 CJK 字符的問題
echo '修正 terabin/flarum-ext-sitemap 不支援 CJK 字符的問題'
sed -i '/>validateLocation/d' \
    vendor/samdark/sitemap/Sitemap.php

# 修正無法 @ 中文名的問題
echo '修正無法 @ 中文名的問題'
sed -i "s#a-z0-9_-#-_a-zA-Z0-9\\\x7f-\\\xff#" \
    vendor/flarum/flarum-ext-mentions/src/Listener/FormatPostMentions.php \
    vendor/flarum/flarum-ext-mentions/src/Listener/FormatUserMentions.php
sed -i "s#getIdForUsername(#getIdForUsername(rawurlencode(#; /getIdForUsername/s/'))/')))/" \
    vendor/flarum/flarum-ext-mentions/src/Listener/FormatUserMentions.php

# 增加中文搜索支援
echo '增加中文搜索支援'
sed -i "/AGAINST/d; /discussion_id/i\\\t\\t->where('content', 'like', '%'.\$string.'%')" \
    vendor/flarum/core/src/Core/Search/Discussion/Fulltext/MySqlFulltextDriver.php

# 修正中文名無法獲取 id 的問題
echo '修正中文名無法獲取 id 的問題'
sed -i "78i\\\t\\t\$username = rawurldecode(\$username);" \
    vendor/flarum/core/src/Core/Repository/UserRepository.php

# 替换一些说明
echo '替换一下说明'
sed -i "s/Search recipient by typing first three characters/Search recipient by typing username or groupname/" \
    vendor/flagrow/byobu/locale/en.yml
sed -i "s/输入\sID\s前三个字符进行搜索/输入用户名或组名进行搜索/" \
    vendor/csineneo/flarum-ext-simplified-chinese/locale/flagrow-byobu.yml
sed -i "s/輸入\sID\s前三個字符進行搜尋/輸入帳戶名或組名進行搜尋/" \
    vendor/csineneo/flarum-ext-traditional-chinese/locale/flagrow-byobu.yml

# 根据当前浏览语言设定，使用 OpenCC 进行繁简转换 (注意 PHP 插件配置)
echo "根据当前浏览语言设定，使用 OpenCC 进行繁简转换"
yum install -y cmake gcc-c++ doxygen && yum clean all
cpwd=$(pwd)
wpwd=$(dirname $0)
cd /opt/src
git clone https://github.com/BYVoid/OpenCC.git
cd OpenCC
make && make install
/usr/bin/cp build/rel/src/libopencc.so.2 /usr/lib64/
#
cd ..
git clone https://github.com/NauxLiu/opencc4php.git
cd opencc4php
/opt/local/php/bin/phpize
./configure --with-php-config=/opt/local/php/bin/php-config --prefix=/opt/local
make && make install

eval "cd $cpwd"
eval "/usr/bin/cp -f ${wpwd}/JsonApiResponse.php" vendor/flarum/core/src/Api/JsonApiResponse.php
eval "/usr/bin/cp -f ${wpwd}/MySqlFulltextDriver.php" vendor/flarum/core/src/Core/Search/Discussion/Fulltext/MySqlFulltextDriver.php
yum clean all
rm -rf /opt/src/*

# 替换错误页面
echo "替换错误页面"
eval "/usr/bin/cp -f ${wpwd}/404.html vendor/flarum/core/error/"
eval "/usr/bin/cp -f ${wpwd}/403.html vendor/flarum/core/error/"
eval "/usr/bin/cp -f ${wpwd}/500.html vendor/flarum/core/error/"
eval "/usr/bin/cp -f ${wpwd}/503.html vendor/flarum/core/error/"

# 修改自定义 Footer 默认显示，并取消 fixed 属性以及切换显示按钮
echo "修改自定义 Footer 默认显示，并取消 fixed 属性以及切换显示按钮"
eval "/usr/bin/cp -f ${wpwd}/dav-is-customfooter-dist-extension.js.modified vendor/davis/flarum-ext-customfooter/js/forum/dist/extension.js"
eval "/usr/bin/cp -f ${wpwd}/dav-is-customfooter-src-main.js.modified vendor/davis/flarum-ext-customfooter/js/forum/src/main.js"
