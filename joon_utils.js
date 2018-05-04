function SX() {}

var Converter = SX.Converter = function () {
	return {
		"name":"Joon
	}
}


// Converter
Converter.cleanHexString = function(strHex) {
    var ret = strHex.trim().toLowerCase();
    if (!ret.startsWith("0x"))
        ret = "0x" + ret;

    return ret;
}

Converter.clearHexPrefix = function(strHex) {
    var ret = strHex.trim().toLowerCase();
    if (ret.startsWith("0x"))
        ret = ret.replace("0x","");

    return ret;
}

var Inspector = SX.Inspector = function() {}
/*
Inspector.getMethods = function(object, maxDepth, currentDepth) {
    var strMethods = "";
    var depth = maxDepth-1;
    var curDepth = currentDepth;

    if (maxDepth == undefined || maxDepth == -1) {
        depth = 0;
        curDepth = 0;
    }

    var strMethods = "";
    var spaces = "";
    for (var i = 0 ; i < curDepth ; i++)
        spaces += "  ";

    for (var m in object) {
        strMethods += spaces + m + "\n";

        if (depth > curDepth)
            strMethods += Inspector.getMethods(object[m],maxDepth, curDepth+1);
    }

    return strMethods;
}*/

Inspector.getMethods = function(object) {
    var strMethods = "";
    for (var m in object) {
        strMethods += m + "\n";
    }

    return strMethods;
}

var Logger = SX.Logger = function() {}
// Logger
Logger.logTextarea = function(strSelector,log) {
    var logger = $(strSelector).append(log).append("\n");
    logger.scrollTop(logger[0].scrollHeight);
}

Logger.clearText = function(strSelector) {
    $(strSelector).text("");
}

// Web3 Util
var Web3Util = SX.Web3Util = function(web3) {
    if (web3 == undefined) {
        console.warn("web3 객체가 지정되지 않음. 원격 호출 함수들은 작동 안함");
        return;
    }
    var web3 = web3;
    this.getWeb3 = function() {
        return web3;
    };
}



