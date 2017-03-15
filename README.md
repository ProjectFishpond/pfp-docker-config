### Project Fishpond 的 Docker 镜像配置文件

使用了 PHP 7.1.2 和 Nginx 1.11.10
添加了 nginx-ct 扩展和静态的 openssl-1.1.0e

#### 相对于默认的 Flarum 添加的扩展有：

- csineneo/flarum-ext-traditional-chinese
- csineneo/flarum-ext-simplified-chinese
- terabin/flarum-ext-sitemap
- flagrow/flarum-ext-analytics
- flagrow/byobu
- flagrow/upload
- vingle/flarum-share-social
- sijad/flarum-ext-pages
- sijad/flarum-ext-links
- sijad/flarum-ext-github-autolink
- avatar4eg/flarum-ext-users-list
- xengine/flarum-ext-markdown-editor
- clarkwinkelmann/flarum-ext-emojionearea
- wiwatsrt/flarum-ext-best-answer
- datitisev/flarum-ext-dashboard
- davis/flarum-ext-socialprofile
- davis/flarum-ext-customfooter
- davis/flarum-ext-split
- amaurycarrade/flarum-ext-syndication
- xengine/flarum-ext-signature
- matpompili/flarum-imgur-upload

#### 在此基础上所做的修改：

- 根据浏览器的本地语言设置自动翻译贴文繁简
- 添加繁簡互通搜尋特性
- 中文用户注册实现 & 基本无 Bug
- 实现中文搜索（搜索/注册字符数限制从最少 3 个改为最少一个，以满足中文要求）
- 帖子编辑器按钮中文化
- 逢千帖不缩进为 n 千而是改为逢万帖缩进为 n 万
- 日期针对中文进行显示优化（不会出现「6 5月」这种奇怪的东西了）
- 不再使用 Google font 以减少延迟
- emoji 缓存改为本地 `/assets/emoji/png` 目录
- Emoji 选择框 js 文件改为本地 `/assets/emojiarea/2.1.4` 目录
- 修改 Footer 插件为固定显示到论坛底部而不是悬浮
- 替换 404 403 500 503 界面


#### 部署方法：

- 准备好 Mysql/MariaDB 服务
- 复制本项目目录 `conf` & `files` 到 `/path/to` 下
- 将设置好的 Nginx 所有配置文件放到 `/path/to/conf/nginx` 目录下，如下：
```
/path/to/conf/nginx/
├── conf.d
│   └── yourweb.conf
├── fastcgi_params
├── nginx.conf
...
```
- 将设置好的 PHP 所有配置文件放到 `/path/to/conf/php` 目录下，如下：
```
/path/to/conf/php/
├── php-fpm.conf
├── php-fpm.d
│   └── www.conf
└── php.ini
```
- 若有 Flarum 的配置文件 `config.php` 则放于 `/path/to/conf/flarum` 目录下
- 将所有的 emoji png 格式的图放到 `/path/to/files/assets/emoji/png` 目录下
- 将 [emojione.sprites.css][emojicss] 和 [emojione.sprites.svg][emojisvg] 放到 `/path/to/files/assets/emojiarea/2.1.4/assets/sprites` 目录下
- 启动本机 Docker 服务后创建好 docker image 或 pull from [docker hub][hub]
```
docker build . -t tag:version
```
- 创建一个 volume container:
```
docker creat --name pfpstore \
         -v /path/to/conf:/opt/conf \
         -v /path/to/files/assets:/opt/flarum/assets \
         -v /path/to/files/storage:/opt/flarum/storage \
         -v /path/to/files/keys:/opt/keys \
         -v /path/to/files/logs:/opt/logs training/postgres /bin/true
```
- 运行本镜像:
```
docker run -dit --volumes-from pfpstore --network host tag:version
```


### LICENSE

MIT

[emojicss]: https://cdnjs.cloudflare.com/ajax/libs/emojione/2.1.4/assets/sprites/emojione.sprites.css
[emojisvg]: https://cdnjs.cloudflare.com/ajax/libs/emojione/2.1.4/assets/sprites/emojione.sprites.svg
[hub]: https://hub.docker.com/r/bekcpear/pfp/
