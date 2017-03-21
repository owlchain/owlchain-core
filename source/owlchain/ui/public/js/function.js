/*

 */
(function ($) {
	"use strict";
	/*CONST*/
	const TRAN_SEND_BOS = "/blockchain/transactions/sendTransaction/sendBOS/sender/receiver/1000/100";
	$.FUNC = {};
	$.FUNC.init = function () {
		$.FUNC.setup();
	};
	var _ajax = function (url, callBack) {
		$.get(url, function (data, status) {
			console.log("Data: " + data + "\nStatus: " + status);
			callBack.call(this, data);
		});
	};
	/*transactions*/
	$.FUNC = {
		addCount: function () {
			$.get(ADD_NEW_COUNT, function (data, status) {
				console.log("Data: " + data + "\nStatus: " + status);
				console.log(data);
			});
		},
		sendBos: function (callBack) {
			_ajax(TRAN_SEND_BOS, callBack);
		},
		end: function () {}
	};
	// 나의메뉴 스크립트(개발 ajax 호출 콜백에서 실행)
	$.FUNC.setup = function () {
		console.log('setup');
	};
}($));
