contract ConditionTest {
    struct Some {
        uint id;
        address addr;
        bytes32 data;
    }

    mapping(uint => Some) many;

    event Message(bytes32 condition);

    function addSome(uint _id) {
        many[_id].id = _id;
        many[_id].addr = msg.sender;
        many[_id].data = "string data";
    }

    function getSome(uint _id) constant returns (uint id){
        return many[_id].id;
    }

    function isExist(uint _id) constant returns (bool) {
        bool ret = true;
        if (many[_id].id == 0) {
            ret = false;
            Message("id(uint) == 0");
        }

        if (many[_id].addr == 0) {
            ret = false;
            Message("addr(address) == 0");
        }

        if (many[_id].data == 0) {
            ret = false;
            Message("data(bytes32) == 0");
        }

        return ret;
    }
}