/*************************
trust.js
*************************/
(function($) {
    "use strict";
    const CONTRACT_LIST_LOAD = "/blockchain/trustcontract/reqTrustContractList";
    const CONTRACT_VALIDATE_LOAD = "/blockchain/trustcontract/validateTrustContract";
    const CONTRACT_CONFIRM_LOAD = "/blockchain/trustcontract/confirmedTrustContract";
    const CONTRACT_RUN_TEST = "/blockchain/trustcontract/runTrustContract";

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
            //nav
            _nav.removeClass('on').siblings('a[data-val=' + cls + ']').addClass('on');
            //section
            var _sec = _section.siblings('.' + cls);
            _sec.addClass('on').siblings('section').removeClass('on');
            if (cls == "s2") {
                $.get(CONTRACT_LIST_LOAD, function(data, status) {
                    data = data.reverse(); //역순출력
                    var _target = $('.s2 table tbody');
                    _target.children().remove();
                    var _ele = '';
                    for (var i = 0; i < data.length; i++) {
                        _ele += '<tr><td class="no">' + data[i].no + '</td><td class="title">' + data[i].title + '</td> <td class="address">' + data[i].contractID + '</td><td class="txs">' + data[i].txCount + '</td> </tr>';
                    }
                    _target.append(_ele);
                });
            } else if (cls == "s3") {}
        };
        /*=== init =================================================*/
        var _init = function() {
            console.log('%c ## init ## ', 'font-size:14px;color:blue;');
            $('textarea').text('');
            $('textarea').val('');
            $('input').val('');
            $('.s1 a.submit').removeClass('disabled');
            $('.s1 a.confirm').addClass('disabled');
            $('.s1 a.visual_exe').addClass('disabled').attr('disabled', 'disabled');
            $('.s1 .ui-visual').children().remove();
            $('.s1 .info ul.list').hide().children().remove();
            $('.s3 .toggle dl').removeClass('on');
        };
        /*=== Ajax Function =================================================*/
        var _ajax = function(url, callBack) {
            console.log('%c "url: ' + url + '', 'font-size:12px;color:brown;');
            $.get(url, function(data, status) {
                console.log(data);
                //  callBack.call(this, data);
            }).done(function(data) {
                if (typeof(data) != "string") {
                    //  data.mode = "done";
                }
                callBack.call(this, data);
            }).fail(function(data) {
                //  data.mode = "fail";
                callBack.call(this, data);
            });
        };
        /*=== Selector =================================================*/
        window.DATA_LIST = []; //Contract Address:
        var _nav = $('header nav a');
        var _link = $('a.link');
        var _select = $('select.select-value');
        var _section = $('article.wrap > section');
        var _winPop = $('a.link-winPop'); /* windows popup */
        var _popup = $('article.popup');
        var _testCode = $('.s1 textarea');
        var _testRun = $('.s4 .submit');
        var _testVisualBtn = $('.s2 .visual_exe');
        /*=== common =================================================*/
        /*공통UI*/
        _link.bind('click', function(event) {
            var _val = $(this).attr('data-val');
            setDisplay(_val);
            $(this).addClass('on').siblings('a').removeClass('on');
        });
        _select.bind('change', function(event) { // Select Option value에 의한 textarea 출력
            var _val = $(this).find('option:selected').val();
            var _textarea = $(this).parents('article.content').find('textarea');
            var _str = _textarea.val() + "\n";
            _textarea.val(_str + _val);
            console.log(_val);
        });
        _winPop.bind('click', function(event) {
            window.open("vocabulary.html", "windowNewPop", "toolbar=yes,scrollbars=yes,resizable=yes,top=0,left=0,width=1000,height=800");
        });
        /*=== main ===============================================*/
        $('.main a.create').bind('click', function(event) {
            var _data = {};
            _data.no = window.DATA_LIST.length;
            window.DATA_LIST.push(_data);
            $('.s1 textarea').text(''); //초기화
            _init();
        });
        /*=== s1 =================================================*/
        // Submit
        $('.s1 .submit-wrap a').bind('click', function(event) {
            event.preventDefault();
            var _this = $(this);
            var _title = $('#s1_tit').val();
            $('.s1 a.visual_exe').removeClass('disabled').removeAttr('disabled', 'disabled');
            function appendElements(data) {
                var _ul = $('.s1 .info ul.list').show();
                _ul.children().remove();
                var _ele = '';
                for (var i in data) {
                    _ele += '<li><span class="tit">' + i + '</span><span class="value">' + data[i] + '</span></li>';
                }
                _ul.append(_ele);
            }
            if ($(this).hasClass('submit')) {
                $('.s1 .anc_gb').removeClass('on');
                $('.s1 a.submit').addClass('disabled');
                $('.s1 a.confirm').removeClass('disabled');
                _ajax(CONTRACT_VALIDATE_LOAD + "/" + _title, function(data) {
                    window.ContractID = data.tempContractID;
                    window.contractAddress = data.address;
                    $('.s1 textarea').text(data.statusMsg);
                    appendElements(data);

                });
            }
            if ($(this).hasClass('confirm')) {
                $('.s1 a.submit').addClass('disabled');
                _ajax(CONTRACT_CONFIRM_LOAD + "/" + window.contractAddress + "/" + _title, function(data) {
                    $('.s1 textarea').text(data.statusMsg);
                    appendElements(data);
                });
            }
        });
        /*
        $('.s1 a.submit').bind('click', function(event) {
            event.preventDefault();
            var _this = $(this);
            var _title = $('#s1_tit').val();
            $('.s1 .anc_gb').removeClass('on');
            $('.s1 a.submit').addClass('disabled');
            $('.s1 a.confirm').removeClass('disabled');
            _ajax(CONTRACT_VALIDATE_LOAD + "/" + _title, function(data) {
                window.ContractID = data.tempContractID;
                window.contractAddress = data.address;
                $('.s1 textarea').text(data.statusMsg);
                var _ul = $('.s1 .info ul.list').show();
                _ul.children().remove();
                var _ele = '';
                for (var i in data) {
                    _ele += '<li><span class="tit">' + i + '</span><span class="value">' + data[i] + '</span></li>';
                }
                _ul.append(_ele);
            });
        });
        // Confirm
        $('.s1 a.confirm').bind('click', function(event) {
            event.preventDefault();
            var _this = $(this);
            var _title = $('#s1_tit').val();
            $('.s1 a.submit').addClass('disabled');
            _ajax(CONTRACT_CONFIRM_LOAD + "/" + window.contractAddress + "/" + _title, function(data) {
                $('.s1 textarea').text(data.statusMsg);
                var _ul = $('.s1 .info ul.list').show();
                _ul.children().remove();
                var _ele = '';
                for (var i in data) {
                    _ele += '<li><span class="tit">' + i + '</span><span class="value">' + data[i] + '</span></li>';
                }
                _ul.append(_ele);
                $('.s1 a.visual_exe').removeClass('disabled').removeAttr('disabled', 'disabled');
            });
        });
        */
        $('.s1 dd a.anc_gb').bind('click', function(event) {
            event.preventDefault();
            var _chk = $(this).hasClass('on');
            if (!_chk) {} else {}
        });
        $('.s1 a.visual_exe').bind('click', function(event) {
            event.preventDefault();
            var _title = $('#s1_tit').val();
            var _chk = $(this).hasClass('disabled');
            if (!_chk) {
                $('p.ui-visual').show();
                if (_title.indexOf("Coin") !== -1) {
                    var _load = '<iframe width="100%" height="400px" src="./libs/webvowl/index.html" frameborder="0"></iframe>';
                } else if (_title.indexOf("Real") !== -1) {
                    var _load = '<iframe width="100%" height="400px" src="./libs/webvowl2/index.html" frameborder="0"></iframe>';
                } else {
                    return false;
                }
                $('.s1 .ui-visual').children().remove();
                $('.s1 .ui-visual').append(_load);
                $('.s1 a.visual_exe').addClass('disabled').attr('disabled', 'disabled');
                setTimeout(function() {
                    $('.s1 iframe').contents().find('#graph').css('height', '400px');
                    $('.s1 iframe').contents().find('.vowlGraph').attr('width', '784px').attr('height', '400px').css('border', '1px solid #242a42');
                }, 500);

            }
        });
        /*=== s2 =================================================*/
        /*=== s3 =================================================*/
        $('.s3 .toggle dl dt').bind('click', function(event) {
            $(this).parents('dl').toggleClass('on');
            var _dl = $(this).parents('dl');
            var _textarea = _dl.find('dd textarea');
            var _idx = _dl.index();
            var _url = '';
            if (_idx == 0) {
                _url = "./ajax/RealEstateLeaseContract6.sdl";
            } else if (_idx == 1) {
                _url = "./ajax/voting.sdl";
            } else if (_idx == 2) {
                _url = "./ajax/Crowdfunding.sdl";
            } else if (_idx == 3) {
                _url = "./ajax/HelloCoin.sdl";
            }
            _ajax(_url, function(data) {
                _textarea.val(data);
            });
        });
        $('.s3 a.copy-code').bind('click', function(event) {
            var _code = $(this).parents('dd').find('textarea').val();
            _init(); //초기화이후
            _testCode.val(_code);
        });
        _testRun.bind('click', function(event) {
            _testVisualBtn.removeClass('disabled');
        });
        _testVisualBtn.bind('click', function(event) {

        });
        /*=== s4 =================================================*/
        $('.s4 .submit').bind('click', function(event) {
            var _title = $('#s2_tit').val();
            var _textarea = $('.s4 textarea');
            _ajax(CONTRACT_RUN_TEST + "/" + _title + "/" + _textarea.val(), function(data) {
                var _ul = $('.s4 .info ul.list');
                _ul.children().remove();
                var _ele = '';
                for (var i in data) {
                    _ele += '<li><span class="tit">' + i + '</span><span class="value">' + data[i] + '</span></li>';
                }
                _ul.append(_ele);
                $('.s4 .info').show();
            });
        })
        //init
        _init();
    }
    $(document).ready(function() {
        //  _setup();
        _bind();
    });
})($);
