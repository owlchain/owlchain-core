/*************************
trust.js
*************************/
(function($) {
    "use strict";
    /*setup*/
    var _setup = function() {

    };
    /*trust-contract*/
    var _bind = function() {
        var _isMotion = false;

        function setDisplay(cls) {
            var _old = _section.siblings('.on');
            var _sec = _section.siblings('.' + cls);
            _isMotion = true;
            _sec.show().addClass('on bounceInRight animated').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
                $(this).removeClass('bounceInRight animated');
                _isMotion = false;
            });
            _old.addClass('bounceOutLeft animated').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
                $(this).removeClass('on bounceOutLeft animated').hide();
            });
            _menu.val(cls);

            //  var _height = _sec.height();
        };
        var _menu = $('header select');
        var _section = $('article.wrap > section');
        var _link = $('a.link');
        var _winPop = $('a.winPop');


        _menu.bind('change', function(event) {
            var _val = $(this).val();
            setDisplay(_val);
        });
        /*공통UI*/
        _link.bind('click', function(event) {
            if (_isMotion) {
                return false;
            }
            var _val = $(this).attr('data-val');
            var _isOn = $(this).hasClass('on');
            if (!_isOn) {
                setDisplay(_val);
                $(this).addClass('on').siblings('a').removeClass('on');
            }
        });
        _winPop.bind('click',function(event){
            window.open("vocabulary.html", "windowNewPop", "toolbar=yes,scrollbars=yes,resizable=yes,top=0,left=0,width=1000,height=800");
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
