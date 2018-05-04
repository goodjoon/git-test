
import "transport.sol";
contract SupplyContract{
	event EventReport(uint orderId);
	function reportShipped(uint orderId){
		EventReport(orderId);
	}

	function CreateNewDelievery(address aContractAddr, uint aOrderId, bytes32 aSrc, bytes32 aPart, uint aQty, bytes32 aDest, bytes32 aDate, address aSelf){
		TransportContract tc;
		tc = TransportContract(aContractAddr);
		tc.CreateNewDelievery(aSelf, msg.sender, aOrderId, aSrc, aPart, aQty, aDest, aDate);
	}
	function ConfirmDelievery(address aContractAddr, uint aDelieveryId){
		TransportContract tc;
		tc = TransportContract(aContractAddr);
		tc.ConfirmDelievery(aDelieveryId);
	}
}


