/*************************
trust.js
*************************/
(function($) {
  "use strict";
  /*setup*/
  var _setup = function() {

  };
  /*trust-contract*/
  var _bind = function() {
    /*************************
    화면전환될때 슬라이드
    *************************/
    function setDisplay(cls) {
      // _section.removeClass('on');
      var _sec = _section.siblings('.' + cls);
      _sec.addClass('on').siblings('section').removeClass('on');
      _menu.val(cls);
      var _height = _sec.height();
    };
    /*************************
    팝업 슬라이드
    *************************/
    function showPopup(cls) {
      _popup.addClass('on');
    }

    function hidePopup(cls) {
      _popup.removeClass('on');
    }

    var _menu = $('header select');
    var _section = $('article.wrap > section');
    var _link = $('a.link');
    var _winPop = $('a.winPop'); /* windows popup */
    var _popup = $('article.popup');

    _menu.bind('change', function(event) {
      var _val = $(this).val();
      setDisplay(_val);
    });
    /*공통UI*/
    _link.bind('click', function(event) {
      var _val = $(this).attr('data-val');
      var _isOn = $(this).hasClass('on');
      if (!_isOn) {
        setDisplay(_val);
        $(this).addClass('on').siblings('a').removeClass('on');
      }
    });
    _winPop.bind('click', function(event) {
      window.open("vocabulary.html", "windowNewPop", "toolbar=yes,scrollbars=yes,resizable=yes,top=0,left=0,width=1000,height=800");
    });
    /**/
    $('.popup-link').bind('click', function(event) {
      showPopup();
    });
    _popup.bind('click', function(event) {
      hidePopup();
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
