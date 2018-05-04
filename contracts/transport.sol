//공급계약서의 API를 호출하기 위해, contract를 import한다.
import "./supply.sol";


//공급계약서에서 해당 인터페이스로 공급계약서의 API를 호출하므로 상속해서 구현해주어야한다.
contract ITransport {
	
	//공급사로부터 새로운 운송요청이 들어온다.
    function CreateNewDelievery(address aContractAddr, address aSupplierAddr, uint aOrderId, bytes32 aSrc, bytes32 aPart, uint aQty, bytes32 aDest, bytes32 aDate)
	returns (uint rDelieveryId);
	
	//제조사로부터 물품을 정상적으로 인도받았음을 확인한다.(운송완료되었음을 알려준다.)
    function ConfirmDelievery(uint aDelieveryId);
}


contract TransportContract is ITransport{
	
	// Event ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
	//주문의 상태가 변경되었을 때 이벤트를 발생시킨다.
	event EventStatusChange(uint id, uint status);
	
	//새로운 운송요청이 들어왔을 때 이벤트를 발생시킨다.
	event NewDelievery(uint eDelieveryId, bytes32 eSrc, bytes32 ePart, uint eQty, bytes32 eDest, bytes32 eDate, uint eStatus);

	// 운송정보 관리 Structure ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
	//운송정보
	struct Delievery{
		address contractAddr;	//주문이 들어올 시 어떤 공급계약서로부터 요청되었는지 설정
		address supplierAddr;	//주문이 들어올 시 어떤 공급사가 요청한 주문인지 확인
		uint orderId;			//주문번호
		bytes32 src;			//출하장소
		bytes32 part;			//품목
		uint qty;				//수량
		bytes32 dest;			//인도처		
		bytes32 date;			//인도기한		
		uint status;			//상태		0: 운송요청 1: 운송중 2: 운송완료
	}
	
	//운송번호를 토대로 map에 접근해서 운송상세정보를 확인할 수 있다.
	mapping(uint => Delievery) mapDelievery;		
	
	//운송번호를 배열로 관리하여, map에 접근하기 용이하도록 도와준다.
	uint[] delieverIdArray; 			

	// 공급사 Action ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
	
	//새 운송정보 생성
	function CreateNewDelievery(address aContractAddr, address aSupplierAddr, uint aOrderId, bytes32 aSrc, bytes32 aPart, uint aQty, bytes32 aDest, bytes32 aDate)
	returns (uint rDelieveryId){
	
		//새 운송번호를 할당.
		uint id = delieverIdArray.length;
		rDelieveryId = id;
		
		//새 운송정보 생성
		mapDelievery[id].contractAddr = aContractAddr;
		mapDelievery[id].supplierAddr = aSupplierAddr;
		mapDelievery[id].orderId = aOrderId;		
		mapDelievery[id].src = aSrc;		
		mapDelievery[id].part = aPart;		
		mapDelievery[id].qty = aQty;			
		mapDelievery[id].dest = aDest;		
		mapDelievery[id].date = aDate;			
		mapDelievery[id].status = 0;
		
		//새로운 주문이 운송요청이 들어왔음을 이벤트로 알려준다.
		NewDelievery(id, aSrc, aPart, aQty, aDest, aDate, 0);
	
		//새로운 운송을 추후 관리를 위해 운송번호를 배열에 추가해준다.
		delieverIdArray.push(id);
	}

	// 제조사 Action ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
	
	//제조사가 인수확인시 운송계약서의 이 API를 호출함으로써, 운송이 완료되었음을 알려준다.
	function ConfirmDelievery(uint aDelieveryId){
		//aDelieveryId에 해당하는 운송정보를 운송완료로 상태변경
		SetStatus(aDelieveryId, 2);
	}

	// 운송사 Action ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
	
	//운송지시(aDelieveryId : 운송번호)
	function ExecuteDelievery(uint aDelieveryId){
	
		//aDelieveryId에 해당하는 운송정보를 운송중으로 상태변경
		SetStatus(aDelieveryId, 1);
	
		//공급계약서쪽에 운송이 시작되었음을 알려준다.
		SupplyContract sc;
		sc = SupplyContract(mapDelievery[aDelieveryId].contractAddr);
		sc.StartTransport(aDelieveryId, mapDelievery[aDelieveryId].orderId);
	}

	//각 사의 Action에 따른 상태변경 ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
	//운송상태 변경(aDelieveryId : 운송번호, aStatus : 상태)
	function SetStatus(uint aDelieveryId, uint aStatus){
	
		// 0: 운송요청 1: 운송중 2: 운송완료
		mapDelievery[aDelieveryId].status = aStatus;
	
		//운송상태가 변경되었음을 이벤트로 알려준다.
		EventStatusChange(aDelieveryId, aStatus);
	}
	
	// UI표출을 위한 정보조회 ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
	
	//운송정보 가져오기(aDelieveryId : 운송번호)
	//페이지를 기준으로 최대 10개의 운송정보를 리턴해준다.(aPage : 0 base)
	function GetDelieveryInfo(uint aPage) constant returns
		(uint[10] rDelieveryId, bytes32[10] rSrc, bytes32[10] rPart, uint[10] rQty, bytes32[10] rDest, bytes32[10] rDate, uint[10] rStatus){
		uint index = aPage * 10;
		for(uint i = 0 ; i < 10 ; i ++){
			rDelieveryId[i] = index; 
			rSrc[i] = mapDelievery[index].src; 
			rPart[i] = mapDelievery[index].part; 
			rQty[i] = mapDelievery[index].qty; 
			rDest[i] = mapDelievery[index].dest; 
			rDate[i] = mapDelievery[index].date; 
			rStatus[i] = mapDelievery[index].status; 
			index++;
		}
	}

	// 등록한 운송정보의 전체 갯수를 토대로, 화면에 표출할 페이지 수를 리턴한다.
	function GetPageCountForDelieveries() constant returns (uint cnt){
		if(delieverIdArray.length == 0){	// 등록된 운송정보가 하나도 없을 경우에는 1 을 리턴하도록 한다.
			cnt = 1;
		}else{
			cnt = (delieverIdArray.length-1)/10 + 1;
		}
	}
}