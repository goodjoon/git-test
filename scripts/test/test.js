function Test() {
    console.log("Test Function");
}

Test.prototype.constructor = function(_param){
    console.log("Function Constructor's Parameter : " + _param);
}

Test.prototype.Method = function() {
    console.log("Method called");
}


var Test1 = Test;
var Test2 = new Test("ABC");
Test2.Method();