/*************************
common.js
*************************/
(function ($) {
    /*setup*/
    var _setup = function () {
        var beepOne = $("#snd_over")[0];
        //        $('a').bind('mouseenter', function (event) {
        //            beepOne.pause();
        //            beepOne.play();
        //        });
    };
    var _bind = function () {
            /*Wallet*/
            _wallet = $('nav .wallet');
            _walletAddBtn = $('nav .wallet ');
            _dash = $('section.da');
            _account = $('section.ac');
            _toggle = _account.find('.toggle dl');
            /*계정추가 add_new_account*/
            _wallet.on('click', '.add', function (event) {
                addCount();
            });
            /*계정자세히보기*/
            _dash.on('click', '.pay>a', function (event) {
                setLayout("account");
                setToggleMenu("init");
            });
            /*Receive*/
            _dash.on('click', '.ctl .receive', function (event) {
                setLayout("account");
                setToggleMenu("receive");
            });
            /*Send*/
            _dash.on('click', '.ctl .send', function (event) {
                setLayout("account");
                setToggleMenu("send");
            });
            /*대쉬보드가기*/
            _account.on('click', 'header .close', function (event) {
                setLayout("dash");
            });
            /*BOS Receive,Send,Transaction,Backup*/
            _account.on('click', '.toggle dl dt', function (event) {
                $(this).parents('dl').toggleClass('on');
            });
        }
        /*
    set layout
	*/
    function setLayout(mode) {
        if (mode == "dash") {
            //            _dash.addClass('on');
            //            _account.removeClass('on');
            _account.removeClass('on');
        }
        else if (mode = "accout") {
            _account.addClass('on');
            /*
            _dash.hide();
            _account.fadeIn();
            */
        }
    }

    function setToggleMenu(mode) {
        if (mode == "init") {
            _toggle.removeClass('on');
        }
        else if (mode == "receive") {
            _toggle.eq(0).addClass('on').siblings().removeClass('on');
        }
        else if (mode == "send") {
            _toggle.eq(1).addClass('on').siblings().removeClass('on');
        }
    }

    function addCount() {
        var _ele = '<section class="content clfix">' + '<div class="pay">' + '<div class="address">*AAAAAAAfg59fhsp4qper</div>' + '<p class="coin">100.000 <em>BOS</em></p>' + '</div>' + '<ul class="ctl">' + '<li><a href="#"><img src="/images/ico_receive.png"></a></li>' + '<li><a href="#"><img src="/images/ico_send.png"></a></li>' + '<li class="freez"><a href="#"><img src="/images/ico_freezing.png"></a></li>' + '</ul>' + '</section>';
        $('.da > article').append(_ele);
    }
    /*ADD_ACCOUNT
     */
    $(document).ready(function () {
        _bind();
    });
})($);