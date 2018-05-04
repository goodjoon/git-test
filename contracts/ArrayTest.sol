contract ArrayTest {
    //uint[100] holder; //--> 잘 된다 그런데 length 가 항상 100 이라서 문제지..
    uint[] holder;

    event Message(bytes32 msg, uint value);

    function doSetTest() {
        /*
        holder[0] = 1;
        holder[2] = 2;
        holder[4] = 3;*/
        holder.push(1);
        holder.push(2);
        holder.push(3);

        Message("1-Length", holder.length);
        delete holder[1]; // dynamic array 에서도 동작은 하지만 값만 초기화 된다
        /*
        Message("2-Length", holder.length);*/
    }

    function doGetTest() constant returns (uint) {
        return holder.length;
    }

    function getHolder() constant returns (uint[10]) {
        uint[10] memory ret;

        for (uint i = 0 ; i < holder.length ; i++) {
            ret[i] = holder[i];
        }

        return ret;
    }

    function getVariableHolder() constant returns (uint[]) { // 아무 값도 리턴 안된다
        uint[] memory ret;

        for (uint i = 0 ; i < 10 ; i++) {
            ret[i] = holder[i];
        }

        return ret;
    }

}