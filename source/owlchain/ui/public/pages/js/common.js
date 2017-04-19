/*************************
trust.js
*************************/
(function($) {
    "use strict";
    /*setup*/
    var _setup = function() {
        var options = {
            valueNames: ['address']
        };
        var hackerList = new List('table-list', options);
    };
    /*trust-contract*/
    var _bind = function() {
        /*************************
        Scene display
        *************************/
        function setDisplay(cls) {
            // _section.removeClass('on');
            var _sec = _section.siblings('.' + cls);
            _sec.addClass('on').siblings('section').removeClass('on');
            var _height = _sec.height();
        };
        /*************************
        popup
        *************************/
        function setPopup(mode) {
            if (mode == "close") {
                _popup.removeClass('on');
            } else {
                _popup.addClass('on');
            }
        }
        /*=== Selector =================================================*/
        var _link = $('a.link');
        var _select = $('select.select-value');
        var _linkPopup = $('a.link-popup');
        var _section = $('article.wrap > section');
        var _winPop = $('a.winPop'); /* windows popup */
        var _popup = $('article.popup');

        /*공통UI*/
        _link.bind('click', function(event) {
            var _val = $(this).attr('data-val');
            var _isOn = $(this).hasClass('on');
            if (!_isOn) {
                setDisplay(_val);
                $(this).addClass('on').siblings('a').removeClass('on');
            }
        });
        // Select Option value에 의한 textarea 출력
        _select.bind('change', function(event) {
            var _val = $(this).find('option:selected').text();
            var _textarea = $(this).parents('article.content').find('textarea');
            var _str = _textarea.text() + "\n";
            _textarea.text(_str + _val);

        });
        /*=== main ===============================================*/
        /*=== s1 =================================================*/
        $('.s1 a.submit').bind('click', function(event) {
            event.preventDefault();
            //title validation
            if ($('#s1_tit').val() == "") {
                alert('Title value empty.');
            }
            if ($('.s1 textarea').text() == "") {
                alert('textarea value empty');
            }
            $('.s1 .btn-visual').addClass('on');
        });
        $('.s1 a.btn-visual').bind('click', function(event) {
            event.preventDefault();
            var _chk = $(this).hasClass('on');
            if (_chk) {
                $('p.ui-visual').show();
            } else {}
        });
        /*=== s2 =================================================*/
        /*=== s3 =================================================*/
        /*=== s4 =================================================*/


        _winPop.bind('click', function(event) {
            window.open("vocabulary.html", "windowNewPop", "toolbar=yes,scrollbars=yes,resizable=yes,top=0,left=0,width=1000,height=800");
        });
        /**/
        _linkPopup.bind('click', function(event) {
            setPopup("open");
        });
        _popup.bind('click', function(event) {
            setPopup("close");
        });
        $('.toggle dl dt').bind('click', function(event) {
            $(this).parents('dl').toggleClass('on');
        });

        /*init*/
        //setDisplay(_cls);
    }
    /*ADD_ACCOUNT
     */
    $(document).ready(function() {
        _bind();
    });
})($);
