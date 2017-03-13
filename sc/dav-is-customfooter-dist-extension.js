'use strict';

System.register('Davis/CustomFooter/main', ['flarum/app', 'flarum/extend', 'flarum/components/HeaderPrimary', 'flarum/helpers/icon'], function (_export, _context) {
    var app, extend, HeaderPrimary, icon;
    return {
        setters: [function (_flarumApp) {
            app = _flarumApp.default;
        }, function (_flarumExtend) {
            extend = _flarumExtend.extend;
        }, function (_flarumComponentsHeaderPrimary) {
            HeaderPrimary = _flarumComponentsHeaderPrimary.default;
        }, function (_flarumHelpersIcon) {
            icon = _flarumHelpersIcon.default;
        }],
        execute: function () {

            app.initializers.add('davis-customfooter-forum', function () {
                extend(HeaderPrimary.prototype, 'init', function () {
                    var _this = this;

                    this.isopen = true;
                    $('body').append('<div id="customFooter" style="width: 100%;"><div class="footercontent" style="display:block;height:' + app.forum.attribute("davis-customfooter.heightofheader") + 'px;">' + app.forum.attribute('davis-customfooter.customtext') + '</div></div>');
                    $('head').append('<style>' + app.forum.attribute("davis-customfooter.cssofheader") + '</style>');
                    $('head').append('<script>' + app.forum.attribute("davis-customfooter.jsofheader") + '</script>');
                });
            });
        }
    };
});
