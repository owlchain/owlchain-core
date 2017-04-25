/*************************
trust.js
*************************/
(function($) {
    "use strict";
    const CONTRACT_LIST_LOAD = "/blockchain/trustcontract/reqTrustContractList";
    const CONTRACT_VALIDATE_LOAD = "/blockchain/trustcontract/validateTrustContract";
    const CONTRACT_CONFIRM_LOAD = "/blockchain/trustcontract/confirmedTrustContract";
    const CONTRACT_RUN_TEST = "/blockchain/trustcontract/runTrustContract";
    /*http://127.0.0.1:8080/blockchain/trustcontract/validateTrustContract/aaa/aaa */

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
                    console.log(data);
                    var _target = $('.s2 table tbody');
                    _target.children().remove();
                    var _ele = '';
                    for (var i = 0; i < data.length; i++) {
                        _ele += '<tr><td class="no">' + data[i].no + '</td><td class="title">' + data[i].title + '</td> <td class="address">' + data[i].contractID + '</td> <td class="balance">0 BOS</td> <td class="txs">' + data[i].txCount + '</td> </tr>';
                    }
                    _target.append(_ele);
                    // console.log(data);
                    //console.log("Data: " + data + "\nStatus: " + status);
                });
            }
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
        window.DATA_LIST = []; //Contract Address:

        var _nav = $('header nav a');
        var _link = $('a.link');
        var _select = $('select.select-value');
        var _linkPopup = $('a.link-popup');
        var _section = $('article.wrap > section');
        var _winPop = $('a.winPop'); /* windows popup */
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
            var _val = $(this).find('option:selected').text();
            var _textarea = $(this).parents('article.content').find('textarea');
            var _str = _textarea.text() + "\n";
            _textarea.text(_str + _val);
        });
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
            var _dl = $(this).parents('dl');
            var _textarea = _dl.find('dd textarea');
            var _idx = _dl.index();
            if (_idx == 0) {
                $.ajax({
                    url: "./ajax/RealEstateLease.sdl",
                    success: function(data, xhr) {
                        _textarea.text(data);
                        console.log(data);
                    }
                });
            } else if (_idx == 1) {
                $.ajax({
                    url: "./ajax/voting.sdl",
                    success: function(data, xhr) {
                        _textarea.text(data);
                        console.log(data);
                    }
                });
            } else if (_idx == 2) {
                $.ajax({
                    url: "./ajax/Crowdfunding.sdl",
                    success: function(data, xhr) {
                        _textarea.text(data);
                        console.log(data);
                    }
                });
            } else {

            }
        });
        /*=== main ===============================================*/
        $('.main a.create').bind('click', function(event) {
            var _data = {};
            _data.no = window.DATA_LIST.length;
            window.DATA_LIST.push(_data);
            $('.s1 textarea').text(''); //초기화
        });
        /*=== s1 =================================================*/
        $('.s1 a.submit').bind('click', function(event) { //submit
            event.preventDefault();
            var _this = $(this);
            if (_this.hasClass('confirm')) {
                $.get(CONTRACT_CONFIRM_LOAD + "/" + window.ContractID)
                    .done(function(data) {
                        console.log(data);
                        $('.s1 textarea').text(data.status);
                    });
            } else {
                _this.addClass('confirm');
                $('.s1 .anc_gb').removeClass('on');
                //#
                $.get(CONTRACT_VALIDATE_LOAD + "/aaa/bbb")
                    .done(function(data) {
                        window.ContractID = data.tempContractID;
                        $('.s1 textarea').text(data.statusMsg);
                        $('.s1 a.visual_exe').removeClass('disabled');
                        $('.s1 .info ul.list').hide().eq(1).show();
                        //
                        _this.text('Confirm');
                        console.log(data);
                    });
            }
            //            /blockchain/trustcontract/validateTrustContract

        });
        $('.s1 dd a.anc_gb').bind('click', function(event) {
            event.preventDefault();
            var _chk = $(this).hasClass('on');
            if (!_chk) {} else {}
        });
        $('.s1 a.visual_exe').bind('click', function(event) {
            event.preventDefault();
            var _chk = $(this).hasClass('disabled');
            if (!_chk) {
                //    $(this).text('Confirm');
                $('p.ui-visual').show();
                $('.s1 .ui-visual').append('<iframe width="100%" height="400px" src="./libs/webvowl/index.html" frameborder="0"></iframe>');
            }
        });
        /*=== s2 =================================================*/
        /*=== s3 =================================================*/
        $('.s3 a.copy-code').bind('click', function(event) {
            var _code = $(this).parents('dd').find('textarea').text();
            _testCode.text(_code);
        });
        _testRun.bind('click', function(event) {
            _testVisualBtn.removeClass('disabled');
        });
        _testVisualBtn.bind('click', function(event) {

        });
        /*=== s4 =================================================*/
        $('.s4 .submit').bind('click', function(event) {
            var _textarea = $('.s4 textarea');
            $.get(CONTRACT_RUN_TEST + "/AAA/BBB")
                .done(function(data) {
                    var _data = data.transactionID;
                    _textarea.text(_data);
                    $('.s4 .info').show();
                });
        })
        /*init*/
    }
    /*ADD_ACCOUNT
     */
    $(document).ready(function() {
        _bind();
    });
})($);