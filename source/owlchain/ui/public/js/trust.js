/*************************
trust.js
*************************/
(function ($) {
    /*setup*/
    var _setup = function () {

    };
    /*trust-contract*/
    var _bind = function () {
        var _menu = $('header select');
        var _artivle
        var _section=$('article.wrap > section');
        console.log(_menu);
        _menu.bind('change', function (event) {
            console.log($(this).val());
            var _val=$(this).val();
            _section.hide();
            _section.siblings('.'+_val).show();
        });
    }
    /*ADD_ACCOUNT
     */
    $(document).ready(function () {
        _bind();
    });
})($);
