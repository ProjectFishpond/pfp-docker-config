## 这是 Project Fishpond 的 Docker 镜像配置文件

本 Docker Image 包括了 Nginx 服务，PHP-FPM 服务，和基本的 Flarum 论坛程序并对 Flarum 及其扩产进行了相关的修改以符合中文使用习惯

部署方法很简单：

1. 启动本机 Docker 服务后创建好 docker image:
```
docker build . -t tag:version
```
2. 创建一个 volume container:
```
docker creat --name pfpstore \
         -v /path/to/conf:/opt/conf \
         -v /path/to/files/assets:/opt/flarum/assets \
         -v /path/to/files/storage:/opt/flarum/storage \
         -v /path/to/files/keys:/opt/keys \
         -v /path/to/files/logs:/opt/logs training/postgres /bin/true
```
4. 修改好 `conf/` 下的 PHP 和 Nginx 配置文件
3. 运行本镜像:
```
docker run -dit --volumes-from pfpstore --network host tag:version
```

