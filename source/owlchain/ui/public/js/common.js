/*************************
common.js

common.js -> module.js 연동처리
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
    $.COM = {};
    $.COM.init = function () {
        //$.COM.setup();
    };
    $.COM = {
        setPopup:function(){
            
        }
    }
    var _bind = function () {
        /*Wallet*/
        _wrap = $('article.wrap');
        _dash = $('section.da');
        _account = $('section.ac');
        _blockInfo = $('section.bl');
        _config = $('section.co');
        _wallet = $('ul.account');
        _walletAddBtn = $('nav .wallet ');
        _popup = $('article.popup');
        _toggle = _account.find('.toggle dl');
        /*Account*/
        _accountAddress = '';
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
            console.log('-');
            $.FUNC.createCount(function (data) {
                _accountAddress = data.accountAddress;
                addCount(_accountAddress);
            });
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
        _account.on('click', 'ul.form button.send', function (event) {
            setPopup('section.send-bos');
        });
        /*Send BOS Cancel*/
        _account.on('click', 'ul.form button.cancel', function (event) {
            setPopup('section.send-bos-cancel');
        });
        /*BOS Receive,Send,Transaction,Backup*/
        _account.on('click', '.toggle dl dt', function (event) {
            var _dl = $(this).parents('dl');
            var _idx = _dl.index();
            var _param = ["receive", "send", "transaction", "backup"];
            if (_dl.hasClass('on')) {
                _dl.removeClass('on');
            } else {
                setToggleMenu(_param[_idx]);
            }

            //		$(this).parents('dl').toggleClass('on');
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
            //
            var _params = '';
            _params = _account.find('.account .address').text();
            _params += "/" + $('ul.form input.receiver').val();
            _params += "/" + $('ul.form input.amount').val();
            _params += "/" + $('ul.form input.memo').val();
            $.FUNC.sendBos(function (data) {
                console.log(data);
            }, _params);
        });
    }

    var _init = function () {
        setLayout("dash");
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
            //--대쉬보드
            var _list = _dash.find('nav > section'); //account계정리스트
            if (_list.length == 0) {
                $.FUNC.createCount(function (data) {
                    _accountAddress = data.accountAddress;
                    addCount(_accountAddress);
                    //-------------------------------------------------------
                    $.FUNC.getAccount(function (data) {
                        _dash.find('.address').text(data.accountAddress);
                        _dash.find('.coin').text(data.accountBalance);
                    }, _accountAddress);
                });
            }

        } else if (mode == "account") {
            _account.addClass('on');
            var _address = '';
            $.FUNC.getAccount(function (data) {
                //acount
                _account.find('.address em').text(data.accountAddress);
                _account.find('.account span').text(data.accountBalance);
                _account.find('.available span').text(data.availableBalance);
                _account.find('.pending span').text(data.pendingBalance);
                //전역변수
                _accountAddress = data.accountAddress;
                //freezingStatus
                if (Boolean(data.freezingStatus)) {
                    $('nav.freezing-cont').removeClass('freezing');
                } else {
                    $('nav.freezing-cont').addClass('freezing');
                }
            }, _accountAddress);

        } else if (mode == "block") {
            _blockInfo.addClass('on');
        } else if (mode == "config") {
            _config.addClass('on');
        }
    }
    /*
     */
    function setToggleMenu(mode) {
        if (mode == "init") {
            _toggle.removeClass('on');
        } else if (mode == "receive") {
            _toggle.eq(0).addClass('on').siblings().removeClass('on');
        } else if (mode == "send") {
            _toggle.eq(1).addClass('on').siblings().removeClass('on');
        } else if (mode == "transaction") {
            _toggle.eq(2).addClass('on').siblings().removeClass('on');
            //myTransaction
            $.FUNC.getAccountTransaction(function (data) {
                var _ele = '';
                for (var i = 0; i < data.length; i++) {
                    _ele += '<tr><td>' + data[i].timestamp + '</td><td>' + data[i].amount + '</td><td>' + data[i].fee + '</td> <td>' + data[i].accountAddress + '<em></em></td></tr>';
                }
                $('.my-transaction table tbody').children().remove();
                $('.my-transaction table tbody').append(_ele)
            }, _accountAddress);
        }
    }
    /**/
    function addCount(address) {
        var _ele = '<section class="clfix"><div class="pay"><a href="#"><div class="address">' + address + '</div><p class="coin">0<em>BOS</em></p></a></div><ul class="ctl clfix"> <li> <a href="#" class="receive"><img src="/images/ico_receive.png"></a> </li> <li> <a href="#" class="send"><img src="/images/ico_send.png"></a> </li> <li class="freez"> <a href="#"><img src="/images/ico_freezing.png"></a> </li> </ul> </section>';
        $('.da nav').append(_ele);
    }
    /*ADD_ACCOUNT
     */
    $(document).ready(function () {
        _bind();
        _init();
    });
})($);
