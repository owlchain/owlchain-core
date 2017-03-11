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
		var _wallet = $('nav .wallet');
		var _walletAddBtn = $('nav .wallet ');
		/*계정추가 add_new_account*/		
		_wallet.on('click','.add',function(event){
			addCount();
		});
	}
	/*ADD_ACCOUNT
	*/
	function addCount(){
		var _ele=
			'<section class="content clfix">'+		
			'<div class="pay">'+
			'<div class="address">*AAAAAAAfg59fhsp4qper</div>'+
			'<p class="coin">100.000 <em>BOS</em></p>'+
			'</div>'+
			'<ul class="ctl">'+
			'<li><a href="#"><img src="/images/ico_receive.png"></a></li>'+
			'<li><a href="#"><img src="/images/ico_send.png"></a></li>'+
			'<li class="freez"><a href="#"><img src="/images/ico_freezing.png"></a></li>'+
			'</ul>'+
			'</section>';
		$('article').append(_ele);
	}
	$(document).ready(function () {
		_bind();
	});
})($);