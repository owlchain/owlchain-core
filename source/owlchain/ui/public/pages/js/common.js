/*************************
trust.js
*************************/
(function($) {
   "use strict";
   const CONTRACT_LIST_LOAD = "/blockchain/trustcontract/reqTrustContractList";
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
      var _testVisualBtn = $('.s4 .visual_exe');
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
      });
      /*=== main ===============================================*/
      $('.main a.create').bind('click', function(event) {
         var _data = {};
         _data.no = window.DATA_LIST.length;
         window.DATA_LIST.push(_data);
         console.log(window.DATA_LIST);
      });
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
         $('.s1 .anc_gb').removeClass('on');
      });
      $('.s1 a.anc_gb').bind('click', function(event) {
         event.preventDefault();
         var _chk = $(this).hasClass('on');
         if (!_chk) {
            $('p.ui-visual').show();
         } else {}
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
         var _chk = $(this).hasClass('disabled');
         if (!_chk) {
            $('.s4 .ui-visual').append('<iframe width="100%" height="400px" src="./libs/webvowl/index.html" frameborder="0"></iframe>');
         }
      });
      /*=== s4 =================================================*/

      /*init*/
      //setDisplay(_cls);
   }
   /*ADD_ACCOUNT
    */
   $(document).ready(function() {
      _bind();
   });
})($);
