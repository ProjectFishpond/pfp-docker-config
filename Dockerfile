
FROM centos:latest
LABEL maintainer "Bekcpear i@ume.ink"

LABEL Description="这是一个运行 Flarum 论坛的 Docker 镜像，并针对中文进行了一些优化" \
      Version="v0.1.0-beta.6"

ENV DOCKER_MAKE_PROXY 10.0.7.19:8123

ADD ./sc/installNginxAndPhpfpmFromSource.sh /opt/sc/installNginxAndPhpfpmFromSource.sh
RUN set -x \
      && { [ "$DOCKER_MAKE_PROXY"x == x ] && /opt/sc/installNginxAndPhpfpmFromSource.sh -e -y || /opt/sc/installNginxAndPhpfpmFromSource.sh -e -y -x $DOCKER_MAKE_PROXY; } \
      && yum clean all \
      && rm -rf /opt/src/*

ADD ./sc/installComposer.sh /opt/sc/installComposer.sh
RUN set -x \
      && mkdir -p /opt/flarum /opt/run /opt/logs /opt/keys \
      && chmod 2750 /opt/flarum /opt/run /opt/logs /opt/keys \
      && chown php-fpm:webService -R /opt/flarum \
      && chown root:webService /opt/run /opt/logs /opt/keys \
      && cd /opt/src \
      && https_proxy=$DOCKER_MAKE_PROXY http_proxy=$DOCKER_MAKE_PROXY \
         /opt/sc/installComposer.sh \
      && rm -f composer-setup.php \
      && useradd tempuser -g users -s /usr/bin/bash \
      && chown tempuser -R /opt/flarum

USER tempuser
RUN set -x \
      && cd /opt/flarum \
#      && setfacl -d -m mask::r-x /opt/flarum \
      && umask 0027 \
      && https_proxy=$DOCKER_MAKE_PROXY http_proxy=$DOCKER_MAKE_PROXY \
         /opt/local/php/bin/php /opt/src/composer.phar create-project flarum/flarum . --stability=beta
USER tempuser
RUN set -x \
      && ls -ld /opt/flarum /opt/run /opt/logs /opt/keys \
#      && setfacl -d -m mask::r-x /opt/flarum \
      && cd /opt/flarum \
      && umask 0027 \
      && sed -i -e '/"require": {/a\ \ \ \ \ \ \ \ "csineneo/flarum-ext-traditional-chinese": "v0.1.0-beta.6.8",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "csineneo/flarum-ext-simplified-chinese": "v0.1.0-beta.6.7",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "terabin/flarum-ext-sitemap": "^1.0@beta",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "flagrow/flarum-ext-analytics": "^0.5.0",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "flagrow/byobu": "^0.1.0",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "flagrow/upload": "^0.4.7",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "vingle/flarum-share-social": "^0.1.0",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "sijad/flarum-ext-pages": "^0.1.0@beta",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "sijad/flarum-ext-links": "^0.1.0@beta",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "sijad/flarum-ext-github-autolink": "^0.1.1@beta",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "avatar4eg/flarum-ext-users-list": "^0.1.1",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "xengine/flarum-ext-markdown-editor": "^1.3",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "clarkwinkelmann/flarum-ext-emojionearea": "^v0.1.1",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "wiwatsrt/flarum-ext-best-answer": "^0.1.0@beta",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "datitisev/flarum-ext-dashboard": "^0.1.0@beta",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "davis/flarum-ext-socialprofile": "^0.2.2",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "davis/flarum-ext-customfooter": "^0.1.0",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "davis/flarum-ext-split": "^v0.1.0",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "amaurycarrade/flarum-ext-syndication": "^v0.1.5",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "xengine/flarum-ext-signature": "^0.1.2",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "matpompili/flarum-imgur-upload": "^1.0",'\
                -e '#zendframework/zend-stratigility#d'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "zendframework/zend-stratigility": "1.2.1",'\
                -e '/"require": {/a\ \ \ \ \ \ \ \ "http-interop/http-middleware": "^0.2.0",'\
                composer.json \
      && rm -f composer.lock \
      && https_proxy=$DOCKER_MAKE_PROXY http_proxy=$DOCKER_MAKE_PROXY \
         /opt/local/php/bin/php /opt/src/composer.phar update \
      && umask 0022

ADD ./sc/hackFlarum.sh /opt/sc/hackFlarum.sh
ADD ./sc/404.html /opt/sc/404.html
ADD ./sc/403.html /opt/sc/403.html
ADD ./sc/500.html /opt/sc/500.html
ADD ./sc/503.html /opt/sc/503.html
ADD ./sc/JsonApiResponse.php /opt/sc/JsonApiResponse.php
USER root
RUN set -x \
      && userdel tempuser \
      && rm -rf /home/tempuser \
#      && setfacl -d -m mask::r-x /opt/flarum \
#      && setfacl -d -m mask::rwx /opt/run \
#      && setfacl -d -m mask::rwx /opt/logs \
#      && setfacl -d -m mask::r-x /opt/keys \
#      && ls -ld /opt/flarum /opt/run /opt/logs /opt/keys \
      && cd /opt/flarum \
      && https_proxy=$DOCKER_MAKE_PROXY http_proxy=$DOCKER_MAKE_PROXY \
         /opt/sc/hackFlarum.sh \
      && ln -s /opt/conf/flarum/config.php /opt/flarum/config.php \
      && ln -s /opt/conf/flarum/sitemap.xml /opt/flarum/sitemap.xml \
      && chown php-fpm -R /opt/flarum
RUN set -x \
      && https_proxy=$DOCKER_MAKE_PROXY http_proxy=$DOCKER_MAKE_PROXY \
         yum install vim-enhanced bind-utils net-tools -y && yum clean all

VOLUME /opt/conf /opt/logs /opt/keys /opt/flarum/assets /opt/flarum/storage
EXPOSE 80
EXPOSE 443
# use network driver 'host' better
ADD ./sc/start.sh /opt/sc/start.sh
CMD /opt/sc/start.sh