/*************************
trust.js
*************************/
(function ($) {
    /*setup*/
    var _setup = function () {

    };
    /*trust-contract*/
    var _bind = function () {
        function setDisplay(cls) {
            _section.hide();
            _section.siblings('.' + cls).show()
        }
        var _menu = $('header select');
        var _artivle
        var _section = $('article.wrap > section');
        var _link = $('a.link');

        _menu.bind('change', function (event) {
            console.log($(this).val());
            var _val = $(this).val();
            setDisplay(_val);
        });


        _link.bind('click', function (event) {
            var _val = $(this).attr('data-val');
             setDisplay(_val);

        });
    }
    /*ADD_ACCOUNT
     */
    $(document).ready(function () {
        _bind();
    });
})($);
