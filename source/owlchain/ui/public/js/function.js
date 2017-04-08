/*
https://github.com/owlchain/owlchain-core/blob/PoC0/source/owlchain/api/readme.md

	/blockchain/AccountOperations/createSeed
	/blockchain/AccountOperations/confirmSeed
	/blockchain/AccountOperations/getAccount
	/blockchain/transactions/sendTransaction
	/blockchain/AccountOperation/getAccountTransaction
	/blockchain/AccountOperations/getBlockInformation

	/blockchain/FreezingOperations/setFreezing
	/blockchain/AccountOperations/getBlockSynchronization

 */
(function ($) {
    "use strict";
    /*****CONST*****/
    /*OPERATION*/
    const OPER_CREATE_SEED = "/blockchain/AccountOperations/createSeed";
    const OPER_CONFIRM_SEED = "/blockchain/AccountOperations/confirmSeed/";
    const OPER_CREATE_ACCOUNT = "/blockchain/AccountOperations/createAccount";/*삭제예정*/
    const OPER_GET_ACCOUNT = "/blockchain/AccountOperations/getAccount/";
    const OPER_GET_ACCOUNT_TRANSACTION = "/blockchain/AccountOperations/getAccountTransaction/";
    const OPER_GET_BLOCK_INFOMATION = "/blockchain/AccountOperations/getBlockInformation";

    /*TRANSACTION*/
    const TRAN_SEND_BOS = "/blockchain/transactions/sendTransaction/sendBOS/";

    //	"/blockchain/transactions/sendTransaction/:type/:sender/:receiver/:amount/:fee/:memo"

    $.FUNC = {};
    var _ajax = function (url, callBack) {
        console.log('%c "url: ' + url + '', 'font-size:12px;color:brown;');
        $.get(url, function (data, status) {
            //			console.log(data);
            //          console.log("Data: " + data + "\nStatus: " + status);
            callBack.call(this, data);
        });
    };
    /*transactions*/
    $.FUNC = {
        /*
        @example
        @use:OPER_CREATE_SEED
        @result:{"passphrase":"Animal Body Class Dragon Elephant Fool Growl Human Icon Jewlry King Loop"}
         */
        creatSeed: function (callBack, param) {
            _ajax(OPER_CREATE_SEED, callBack);
        },
        /*
        @example
        @use:OPER_CONFIRM_SEED/{"passphrase":"Animal Body Class Dragon Elephant Fool Growl Human Icon Jewlry King Loop"}
        @result:{"freezingStatus":false,"accountAddress":"BOS-AAAAA-BBBBB-CCCCCCC","accountBlance":0}
         */
        confirmSeed: function (callBack, param) {
            _ajax(OPER_CONFIRM_SEED+param, callBack);
        },
        /*
         */
        createCount: function (callBack) {
            _ajax(OPER_CREATE_ACCOUNT, callBack);
        },
        /*
         */
        getAccount: function (callBack, param) {
            _ajax(OPER_GET_ACCOUNT + param, callBack);
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
        /*
        RECEIVE BOS
        */
        receiveBos: function (callBack, param) {
            console.log('----');
            //_ajax(TRAN_SEND_BOS + param, callBack);
        },
        /*
        Block Information
        */
        getBlockInformation:function(callBack){
            _ajax(OPER_GET_BLOCK_INFOMATION, callBack);
        },
        end: function () {}
    };
    // 나의메뉴 스크립트(개발 ajax 호출 콜백에서 실행)
    $.FUNC.setup = function () {
        console.log('setup');
    };
}($));
