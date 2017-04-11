/*************************
common.js

common.js -> module.js 연동처리
*************************/
(function($) {
    /*setup*/
    var _setup = function() {
        var beepOne = $("#snd_over")[0];
        //        $('a').bind('mouseenter', function (event) {
        //            beepOne.pause();
        //            beepOne.play();
        //        });
    };
    $.COM = {};
    $.COM = {
        setup: function() {
            $.COM._logo = $('header .logo a');
            $.COM._new = $('article.new');
            $.COM._main = $('article.main');
            $.COM._dash = $('section.da');
            $.COM._account = $('section.ac');
            $.COM._blockInfo = $('section.bl');
            $.COM._config = $('section.co');
            $.COM._wallet = $('ul.account');
            $.COM._walletAddBtn = $('nav .wallet ');
            $.COM._popup = $('article.popup');
            $.COM._toggle = $.COM._account.find('.toggle dl');
            $.COM._receiveBos = '';
            /*  init  ************************/
            $.COM._accountAddress = '';
            $.COM._passPhraseStr = '';
            $.COM._passPhrase = [];

            var _mode="test";
            if(_mode=="test"){
              $.COM._new.hide();
              $.COM._main.show();
              $.COM.setLayout("dash");
            }else{
              $.COM.setLoginMode("start");
            }
        },
        createPhrase: function() {
            $.FUNC.creatSeed(function(data) {
                $.COM._passPhraseStr = data.passphrase + "";
                var _word = data.passphrase.split(" ");
                var _ul = $.COM._new.find('> section.phrase ul.list');
                $.COM._passPhrase = [];
                _ul.children().remove();
                var _ele = '';
                for (var i in _word) {
                    _ele += '<li><span>' + _word[i] + '</span></li>';
                    $.COM._passPhrase.push(_word[i]);
                }
                _ul.append(_ele);
            });
        },
        writePhrase: function() {
            var _ele = '';
            var _ul = $.COM._new.find('> section.check ul.write');
            _ul.children().remove();
            for (var i in $.COM._passPhrase) {
                _ele += '<li><input type="text" data-val=' + $.COM._passPhrase[i] + '></li>';
            }
            _ul.append(_ele);
        },
        loading: function() {
            $.COM._new.addClass('loading');
            var _param = '{ "passphrase" : "' + $.COM._passPhraseStr + '"}';
            $.FUNC.confirmSeed(function(data) {
                // Create Complete
                var _time = 1000;
                var _st = setTimeout(function() {
                    clearTimeout(_st);
                    _time = null;
                    $.COM._new.hide();
                    $.COM._new.removeClass('loading');
                    $.COM._main.show();
                    $.COM.setLayout("dash");
                }, _time);
            }, _param);
        },
        /*
        login / New Accout / passPhrase
         */
        setLoginMode: function(mode) {
            $.COM._new.find('> section').removeClass('on');
            var _target = $.COM._new.find('section.' + mode).addClass('on');
            if (mode == "start") {
                /* recvAccountInforamation으로 수신한  addres count가 “0” 인 경우에만 이 화면이 나타나게 되고 1개 이상이면 받은
                address로   getAccount Rest API로 call하여 대쉬보드 화면이  나타나면 됩니다.*/
                $.COM._new.show();
                $.COM._main.hide();
            } else if (mode == "create") {
                $.COM._new.show();
                $.COM._main.hide();
                var _time = 3000;
                var _st = setTimeout(function() {
                    clearTimeout(_st);
                    _time = null;
                    $.COM.setLoginMode('phrase');
                }, _time);
            } else if (mode == "phrase") {
                $.COM.createPhrase();
                //$.COM._new.find('section.' + mode).fadeIn();
            } else if (mode == "check") {
                $.COM.writePhrase();
            } else if (mode == "loading") {
    /*12개 단어 모두 맞아야 이동합니다.   현재는 next 누르면 넘어가게 하시면 되지만
     며칠내로 실제 데이타 송수신될테니 그 때는 test가   아닌 정상적인 절차로 처리 되어야 합니다.
     "You have not typed the passphrase correctly, please try again! "  */
                $.COM.loading();
            }
        },
        /*
            Dashboard / Account / Block Mode
        */
        setLayout: function(mode) {
            $.COM._main.find('> section').removeClass('on');
            if (mode == "dash") {
                $.COM._dash.addClass('on');
                //--대쉬보드
                var _list = $.COM._dash.find('nav > section'); //account계정리스트
                /*
                https://github.com/owlchain/owlchain-core/tree/PoC0/source/owlchain/ui#recvaccountinformation
                상기 내용 참고 : 전달될 account count와 그에 해당하는 account address 전달
               */
                if (_list.length == 0) {
                    $.FUNC.createCount(function(data) {
                        $.COM._accountAddress = data.accountAddress;
                        $.COM.addCount($.COM._accountAddress);
                        //-------------------------------------------------------
                        $.FUNC.getAccount(function(data) {
                            $.COM._dash.find('.address').text(data.accountAddress);
                            $.COM._dash.find('.coin').text(data.accountBalance.toLocaleString());
                        }, $.COM._accountAddress);
                    });
                }
            } else if (mode == "account") {
                $.COM._account.addClass('on');
                var _address = '';
                $.FUNC.getAccount(function(data) {
                    //acount
                    $.COM._account.find('.address em').text(data.accountAddress.toLocaleString());
                    $.COM._account.find('.account span').text(data.accountBalance.toLocaleString());
                    $.COM._account.find('.available span').text(data.availableBalance.toLocaleString());
                    $.COM._account.find('.pending span').text(data.pendingBalance.toLocaleString());
                    //전역변수
                    $.COM._accountAddress = data.accountAddress;
                    //freezingStatus
                    if (Boolean(data.freezingStatus)) {
                        $('nav.freezing-cont').addClass('freezing');
                    } else {
                        $('nav.freezing-cont').removeClass('freezing');
                    }
                }, $.COM._accountAddress);
            } else if (mode == "block") {
                $.COM._blockInfo.addClass('on');
                $.FUNC.getBlockInformation(function(data) {
                    var _ele = '';
                    var _tbody = $.COM._blockInfo.find('table tbody');
                    _tbody.children().remove();
                    for (var i in data) {
                        _ele += '<tr><td>' + data[i].blockHeight + '</td><td>' + data[i].timestamp + '</td><td>' + data[i].amount.toLocaleString() + '</td><td>' + data[i].fee + '</td><td>' + data[i].generator + '</td></tr>';
                    }
                    _tbody.append(_ele);
                });
            } else if (mode == "config") {
                $.COM._config.addClass('on');
            }
        },
        /*
            Set Layer Popup
        */
        setPopup: function(mode) {
            if (mode == "close") {
                $.COM._popup.removeClass('on');
                $.COM._popup.find('section.layer').hide();
            } else {
                $.COM._popup.addClass('on');
                $(mode).fadeIn('fast');
            }
        },
        /*
         */
        setToggleMenu: function(mode) {
            if (mode == "init") {
                $.COM._toggle.removeClass('on');
            } else if (mode == "receive") {
                $.COM._toggle.eq(0).addClass('on').siblings().removeClass('on');
            } else if (mode == "send") {
                $.COM._toggle.eq(1).addClass('on').siblings().removeClass('on');
            } else if (mode == "transaction") {
                $.COM._toggle.eq(2).addClass('on').siblings().removeClass('on');
                //myTransaction
                $.FUNC.getAccountTransaction(function(data) {
                    var _ele = '';
                    for (var i = 0; i < data.length; i++) {
                        _ele += '<tr><td>' + data[i].type + '</td><td>' + data[i].timestamp + '</td><td>' + data[i].amount.toLocaleString() + '</td><td>' + data[i].feeOrReward + '</td> <td>' + data[i].accountAddress + '<em></em></td></tr>';
                    }
                    $('.my-transaction table tbody').children().remove();
                    $('.my-transaction table tbody').append(_ele)
                }, $.COM._accountAddress);
            }
        },
        /*
        receiveBos
        websocket.js 에서 받은 return 값
        */
        receiveBos: function(param) {
            if (param.isTrusted) { //유효성체크
                //{TEXT} 형태로 받은것을 REG 및 object로 치환
                var _re = /[{"}]/gi,
                    _data = {};
                var _ary = param.data.replace(_re, '').split(',');
                for (var i = 0; i < _ary.length; i++) {
                    var filter = _ary[i].replace(_re, '').split(":");
                    _data[filter[0]] = filter[1];
                };
                $.COM._receiveBos = _data;
                var _receiveAddrs = _data.receiverAccountAddress;
                var _div = $.COM._dash.find('div.address').filter(function(index) {
                    return $(this).text() == _receiveAddrs;
                });
                $.COM.addReceiveBos(_data);
                //$.COM.setLayout("account");
                //$.COM.setToggleMenu("receive");
                $.COM._dash.find('section').find('.receive').after('<i class="receive">2</i>');
                $.COM._account.find('.toggle dl:eq(0) dt span').append('<i class="receive">2</i>');
            }
        },
        /*
        add Receive BOS
        */
        addReceiveBos: function(data) {
            var _ele = '<tr><td><i><img src="./images/ac_ico_receive_arrow.png"></i>Receiving..</td> <td>' + data.amount + '<em>BOS</em></td> <td>Show Detail</td></tr>';
            $.COM._account.find('dl.receive table tbody').append(_ele);
        },
        /**/
        addCount: function(address) {
            var _ele = '<section class="clfix"><div class="pay"><a href="#"><div class="address">' + address + '</div><p class="coin">0<em>BOS</em></p></a></div><ul class="ctl clfix"> <li> <a href="#" class="receive"><img src="/images/ico_receive.png"></a> </li> <li> <a href="#" class="send"><img src="/images/ico_send.png"></a> </li> <li class="freez"> <a href="#"><img src="/images/ico_freezing.png"></a> </li> </ul> </section>';
            $('.da nav').append(_ele);
        },
        end: function() {}
    }
    /*
    Binding
    */
    var _bind = function() {
        /*테스트코드*/
        /*login passPhrase*/
        $.COM._new.on('click', 'a.link', function(event) {
            var _cls = $(this).attr('data-val');
            var _section = $.COM._new.find('>section');
            $.COM.setLoginMode(_cls);
        });
        /*대쉬보드 이동*/
        $.COM._main.on('click', 'header .close', function(event) {
            $.COM.setLayout("dash");
        });
        /*Configuration 이동*/
        $.COM._main.on('click', 'a.config', function(event) {
            $.COM.setLayout("config");
        });
        /*계정추가 add_new_account*/
        $.COM._wallet.on('click', '.add', function(event) {
            $.COM.setLoginMode("create");
        });
        /*Block Info*/
        $.COM._dash.on('click', '.info-wrap a', function(event) {
            $.COM.setLayout("block");
        });
        /*계정자세히보기*/
        $.COM._dash.on('click', '.pay>a', function(event) {
            $.COM.setLayout("account");
            $.COM.setToggleMenu("init");
            //-
        });
        /*Receive*/
        $.COM._dash.on('click', '.ctl .receive', function(event) {
            $.COM.setLayout("account");
            $.COM.setToggleMenu("receive");
        });
        /*Send*/
        $.COM._dash.on('click', '.ctl .send', function(event) {
            $.COM.setLayout("account");
            $.COM.setToggleMenu("send");
        });
        /*Toggle Freezing*/
        $.COM._dash.on('click', '.ctl .freez', function(event) {
            $.COM.setLayout("account");
            $.COM.setPopup('section.un-freezing');
        });
        /*Set Freezing*/
        $.COM._account.on('click', 'button.freezing', function(event) {
            $.COM.setPopup('section.freezing');
        });
        /*Send BOS*/
        $.COM._account.on('click', 'ul.form button.send', function(event) {
            $.COM.setPopup('section.send-bos');
        });
        /*Send BOS Cancel*/
        $.COM._account.on('click', 'ul.form button.cancel', function(event) {
            $.COM.setPopup('section.send-bos-cancel');
        });
        /*BOS Receive,Send,Transaction,Backup*/
        $.COM._account.on('click', '.toggle dl dt', function(event) {
            var _dl = $(this).parents('dl');
            var _idx = _dl.index();
            var _param = ["receive", "send", "transaction", "backup"];
            if (_dl.hasClass('on')) {
                _dl.removeClass('on');
            } else {
                $.COM.setToggleMenu(_param[_idx]);
            }

            //		$(this).parents('dl').toggleClass('on');
        });
        /*Configuration Toggle*/
        $.COM._config.on('click', '.toggle dl dt', function(event) {
            $(this).parents('dl').toggleClass('on');
        });
        /*팝업닫기*/
        $.COM._popup.on('click', '.layer footer a', function(event) {
            $.COM.setPopup('close');
        });
        /*프리징하기*/
        $.COM._popup.on('click', '.freezing footer a', function(event) {
            $.COM.setPopup('close');
            //calc
            $('.freezing-cont').addClass('freezing');
        });
        /*언프리징하기*/
        $.COM._popup.on('click', '.un-freezing footer a', function(event) {
            $.COM.setPopup('close');
            //calc
            $('.freezing-cont').removeClass('freezing');
        });
        /*BOS보내기*/
        $.COM._popup.on('click', '.send-bos footer a', function(event) {
            var _params = '';
            _params = $.COM._account.find('.account .address').text();
            _params += "/" + $('ul.form input.receiver').val();
            _params += "/" + $('ul.form input.amount').val();
            _params += "/" + $('ul.form input.memo').val();
            $.FUNC.sendBos(function(data) {
                // Object {sendBos: true}    false일경우 필요.
                var _chk = Boolean(data.sendBos);
                if (_chk) {
                    $.COM.setPopup('section.send-bos-ok');
                } else {
                    $.COM.setPopup('section.send-bos-cancel');
                }
            }, _params);
        });
    }

    /*ADD_ACCOUNT
     */
    $(document).ready(function() {
        _setup();

        $.COM.setup();
        _bind();
    });
})($);
