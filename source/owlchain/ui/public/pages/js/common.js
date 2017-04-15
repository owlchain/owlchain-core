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
        /*************************
        화면전환될때 슬라이드
        *************************/
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
            var _height = _sec.height();
            console.log(_height);
        };
        /*************************
        팝업 슬라이드
        *************************/
        function showPopup(cls){
            _popup.addClass('on zoomInRight animated').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
                $(this).removeClass('zoomInRight animated');

            });

        }

        function hidePopup(cls){
            _popup.addClass(' zoomOutLeft animated').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
                $(this).removeClass('zoomOutLeft animated on');

            });
        }

        var _menu = $('header select');
        var _section = $('article.wrap > section');
        var _link = $('a.link');
        var _winPop = $('a.winPop');    /* windows popup */
        var _popup = $('article.popup');

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
            showPopup();
        });
        _popup.bind('click',function(event){
            hidePopup();
        });
        $('.toggle dl dt').bind('click', function(event) {
            $(this).parents('dl').toggleClass('on');
        });

        /*init*/
        if( $('section.on').length>0){
            var _cls = $('section.on').attr('class').split('on')[0].replace(/\s+/g, '');
            $('section.on').addClass('on bounceInRight animated').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
                $(this).removeClass('bounceInRight animated');
            });
        }
        //setDisplay(_cls);
    }
    /*ADD_ACCOUNT
     */
    $(document).ready(function() {
        _bind();
    });
})($);
