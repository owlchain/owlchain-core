/*************************
trust.js
*************************/
(function($) {
    /*setup*/
    var _setup = function() {

    };
    /*trust-contract*/
    var _bind = function() {
        function setDisplay(cls) {
            var _old = _section.siblings('.on');
            var _sec = _section.siblings('.' + cls);
            var _height = parseInt(_sec.height()) + 100;
            $('article.wrap').css('height', _height);
            //  _section.removeClass('on');  bounceInRight  bounceOutLeft
            _sec.addClass('on bounceInRight animated').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
                $(this).removeClass('bounceInRight animated');
            });
            _old.addClass('bounceOutLeft animated').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
                $(this).removeClass('on bounceOutLeft animated');
            });
            _menu.val(cls);
            var _t = _section.siblings('.' + cls);
            if (cls == "s1") {
                $('.CodeMirror').focus();
            } else if (cls == "s2") {
                setTimeout(function() {
                    _t.find('.list').addClass('on');
                }, 2000);
            } else {}
            //$(window).trigger('resize');
            //$("#selectBox option:eq(2)").attr("selected", "selected");
        }
        var _menu = $('header select');
        var _section = $('article.wrap > section');
        var _link = $('a.link');

        _menu.bind('change', function(event) {
            var _val = $(this).val();
            setDisplay(_val);
        });
        /*공통UI*/
        _link.bind('click', function(event) {
            var _val = $(this).attr('data-val');
            setDisplay(_val);
        });
        /**/
        $('.popup-link').bind('click', function(event) {
            var _popup = $('.s1 .popup');
            _popup.addClass('on');
        });
        $('.toggle dl dt').bind('click', function(event) {
            $(this).parents('dl').toggleClass('on');
        });

        /*init*/
        var _cls = $('section.on').attr('class').split('on')[0].replace(/\s+/g, '');
        var _height = parseInt($('section.on').height()) + 100;
        $('article.wrap').css('height', _height);
        $('section.on').addClass('on bounceInRight animated').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
            $(this).removeClass('bounceInRight animated');
        });
        //setDisplay(_cls);
    }
    /*ADD_ACCOUNT
     */
    $(document).ready(function() {
        _bind();
    });
})($);
