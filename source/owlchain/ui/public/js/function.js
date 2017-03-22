/*

 */
(function ($) {
	"use strict";
	/*****CONST*****/
	/*OPERATION*/
	const OPER_CREATE_ACCOUNT = "/blockchain/AccountOperations/createAccount";
	const OPER_GET_ACCOUNT = "/blockchain/AccountOperations/getAccount/";
	const OPER_GET_ACCOUNT_TRANSACTION = "/blockchain/AccountOperations/getAccountTransaction/";

	/*TRANSACTION*/
	const TRAN_SEND_BOS = "/blockchain/transactions/sendTransaction/sendBOS/";


	//	"/blockchain/transactions/sendTransaction/:type/:sender/:receiver/:amount/:fee/:memo"

	$.FUNC = {};
	$.FUNC.init = function () {
		$.FUNC.setup();
	};
	var _ajax = function (url, callBack) {
		console.log('%c'+url+'','font-size:16px;color:red');
		$.get(url, function (data, status) {
			console.log(data);
			//console.log("Data: " + data + "\nStatus: " + status);
			callBack.call(this, data);
		});
	};
	/*transactions*/
	$.FUNC = {
		/*
		 */
		createCount: function (callBack) {
			_ajax(OPER_CREATE_ACCOUNT, callBack);
		},
		/*
		 */
		getAccount: function (callBack) {
			var _account = "TEST_ACCOUNT";
			_ajax(OPER_GET_ACCOUNT + _account, callBack);
		},
		/*
		트렌젹션 MY-TRANSACTION
		*/
		getAccountTransaction: function (callBack, param) {
			_ajax(OPER_GET_ACCOUNT_TRANSACTION + param, callBack);
		},
		/*
		 */
		sendBos: function (callBack, param) {
			_ajax(TRAN_SEND_BOS + param, callBack);
		},
		end: function () {}
	};
	// 나의메뉴 스크립트(개발 ajax 호출 콜백에서 실행)
	$.FUNC.setup = function () {
		console.log('setup');
	};
}($));
