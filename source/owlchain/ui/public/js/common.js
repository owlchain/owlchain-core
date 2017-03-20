/*************************
common.js

common.js -> module.js 연동처리
*************************/
(function ($) {
    /*CONST*/
    const ADD_NEW_COUNT = "/blockchain/blocks/2/2";
    const GET_ACCOUNT_BY_ADDRESS = "/blockchain/AccountOperations/getAccount";

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
        _wrap = $('article.wrap');
        _dash = $('section.da');
        _account = $('section.ac');
        _blockInfo = $('section.bl');
        _config = $('section.co');
        _wallet = $('.account');
        _walletAddBtn = $('nav .wallet ');
        _popup = $('article.popup');
        _toggle = _account.find('.toggle dl');
        /*대쉬보드 이동*/
        _wrap.on('click', 'header .close', function (event) {
            setLayout("dash");
        });
        /*Configuration 이동*/
        _wrap.on('click', 'a.config', function (event) {
            setLayout("config");
        });
        /*계정추가 add_new_account*/
        _wallet.on('click', '.add', function (event) {
            $.get(ADD_NEW_COUNT, function (data, status) {
                console.log("Data: " + data + "\nStatus: " + status);
                console.log(data);
            });
            addCount();

        });
        /*Block Info*/
        _dash.on('click', '.info-wrap a', function (event) {
            setLayout("block");
        });
        /*계정자세히보기*/
        _dash.on('click', '.pay>a', function (event) {
            setLayout("account");
            setToggleMenu("init");
            //-
            $.get(ADD_NEW_COUNT, function (data, status) {
                console.log("Data: " + data + "\nStatus: " + status);
                console.log(data);
            });
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
        /*Toggle Freezing*/
        _dash.on('click', '.ctl .freez', function (event) {
            setLayout("account");
            setPopup('section.un-freezing');
        });
        /*Set Freezing*/
        _account.on('click', 'button.freezing', function (event) {
            setPopup('section.freezing');
        });
        /*Send BOS*/
        _account.on('click', 'ul.form input.send-bos', function (event) {
            setPopup('section.send-bos');
        });
        /*Send BOS Cancel*/
        _account.on('click', 'ul.form input.cancel', function (event) {
            setPopup('section.send-bos-cancel');
        });
        /*BOS Receive,Send,Transaction,Backup*/
        _account.on('click', '.toggle dl dt', function (event) {
            $(this).parents('dl').toggleClass('on');
        });
        /*Configuration Toggle*/
        _config.on('click', '.toggle dl dt', function (event) {
            $(this).parents('dl').toggleClass('on');
        });
        /*팝업닫기*/
        _popup.on('click', '.layer footer a', function (event) {
            setPopup('close');
        });
        /*프리징하기*/
        _popup.on('click', '.freezing footer a', function (event) {
            setPopup('close');
            //calc
            $('.freezing-cont').addClass('freezing');
        });
        /*언프리징하기*/
        _popup.on('click', '.un-freezing footer a', function (event) {
            setPopup('close');
            //calc
            $('.freezing-cont').removeClass('freezing');
        });
        /*BOS보내기*/
        _popup.on('click', '.send-bos footer a', function (event) {
            setPopup('section.send-bos-ok');
        });
    }
    /*
    set popup
	*/
    function setPopup(mode) {
        if (mode == "close") {
            _popup.removeClass('on');
            _popup.find('section.layer').hide();
        } else {
            _popup.addClass('on');
            $(mode).fadeIn('fast');
        }
    }
    /*
    set layout
	*/
    function setLayout(mode) {
        _wrap.find('> section').removeClass('on');
        if (mode == "dash") {
            _dash.addClass('on');
        } else if (mode == "account") {
            _account.addClass('on');
        } else if (mode == "block") {
            _blockInfo.addClass('on');
        } else if (mode == "config") {
            _config.addClass('on');
        }
    }

    function setToggleMenu(mode) {
        if (mode == "init") {
            _toggle.removeClass('on');
        } else if (mode == "receive") {
            _toggle.eq(0).addClass('on').siblings().removeClass('on');
        } else if (mode == "send") {
            _toggle.eq(1).addClass('on').siblings().removeClass('on');
        }
    }
    /**/
    function addCount() {
        var _ele = '<section class="clfix"><div class="pay"><a href="#"><div class="address">test1 *AAAAAAAfg59fhsp4qper</div><p class="coin">100.000 <em>BOS</em></p></a></div><ul class="ctl clfix"> <li> <a href="#" class="receive"><img src="/images/ico_receive.png"></a> </li> <li> <a href="#" class="send"><img src="/images/ico_send.png"></a> </li> <li class="freez"> <a href="#"><img src="/images/ico_freezing.png"></a> </li> </ul> </section>';
        $('nav').append(_ele);
    }
    /*ADD_ACCOUNT
     */
    $(document).ready(function () {
        _bind();
    });
})($);
