pragma solidity ^0.4.0;
//운송계약서의 API를 호출하기 위해, contract를 import한다.
import "./transport.sol";
//contract abstract {}

//contract를 deploy 한 사람을 기록한다.
contract owned  {	
	address owner; 
	bytes32 ownerName;
	function owned() {
		owner = msg.sender;
	}
	modifier onlyowner() {
		if (msg.sender==owner) 
			_;
	}
	//contract deploy 한 사람의 이름을 설정한다.
	function setOwnerName(bytes32 _name) onlyowner {
		ownerName = _name;
	}
	//contract deploy 한 사람의 이름을 가져온다.
	function getOwnerName() constant returns (bytes32) {
		return ownerName;
	}
}

//Contract를 deploy한 사람만이 contract를 삭제할 수 있다.
contract mortal is owned {	
	function kill() {
		if (msg.sender == owner) 
			selfdestruct(owner);
	}

	function() { // fallback
		log0("No contract method in Tx");
		return;
	}
}

contract ISupply {		//운송계약서에서 해당 인터페이스로 공급계약서의 API를 호출하므로 상속해서 구현해주어야한다.
		function StartTransport(uint _delieveryId, uint _orderId);
}

contract SupplyContract is mortal, ISupply {
	
	// 공급자 계약대상 정의
	struct Supplier { // 을
		address addr;							//공급자 Address
		bytes32 name;							//공급자 이름
		TransportContract tc;			//공급자와 연관된 운송계약서 Address
		uint[] partIds; 					// 1 이상으로 시작되는 물품 ID
		mapping(uint => Part) parts;	//제공하는 물품들을 맵 형태로 관리한다.
	}

	
	// 공급 물품 정의
	struct Part {
		uint id;					//공급물품 ID
		bytes32 name; 		// 품명
		uint unitPrice; 	// 단가
		uint duration; 		// 납기
	}

	enum OrderState {
			Ordered,								//EventStatusChange status : 0	//제조사 - 발주완료,  공급사 - 출고대기
			Preparing,							//EventStatusChange status : 1	//제조사 - 출고중,		공급사 - 출고완료
			Transfering,						//EventStatusChange status : 2 //제조사 - 운송중,		공급사 - 운송중
			Delievered,							//EventStatusChange status : 3 //제조사 - 인수완료,	공급사 - 인수완료
			Completed								//EventStatusChange status : 4 //제조사 - 검수완료,	공급사 - 검수완료
	}

	// 주문 정의
	struct Order {
		uint orderNumber;					//주문번호
		address supplierAddr;			//공급자 Address
		uint partId;							//물품 ID
		uint delieveryId;					//주문번호
		uint qty;									//주문수량
		bytes32 orderTimestamp;		//주문시간
		bytes32 place;						//인도장소
		OrderState state;					//주문상태
	}

	//공급자로 등록된 sender만이 함수를 실행할 수 있게하는 modifier.
	modifier onlycontractee() {
			if (suppliers[msg.sender].addr == 0) {
					Error(102, "You're not a contractee.");
					return;
			}
			_;
	}
	//제조사에 등록된 공급자를 배열 형태로 관리한다.
	address[] private supplierAddresses;

	//공급사 주소를 이용해, 등록된 공급자의 상세정보를 접근할 수 있다.
	mapping(address => Supplier) suppliers;

	//주문관리배열, mapping 자료구조의 orders를 이용하기 용이하게 해준다.
	uint[] private orderNumbers;

	//주문번호를 이용해 발주된 주문의 상세정보를 접근할 수 있다.
	mapping(uint => Order) orders;

	//공급자가 등록되었음을 알려준다.
	event SupplierRegistered(address supplierAddr, bytes32 supplierName);

	//물품이 새로 등록되었음을 알려준다.
	event PartRegistered(address supplierAddr, bytes32 supplierName, bytes32 partName, uint totalItems);

	//새로운 주문이 발주되었음을 알려준다.
	event NewOrderPlaced(uint newOrderNumber);

	//Contract 호출간 에러가 발생했음을 알려준다.
	event Error(uint code, bytes32 msg);

	//Debug용 이벤트 메세지
	event Message(bytes32 message);
	event MessageUint(bytes32 message, uint val);
	event MessageAddress(bytes32 message, address addr);

	//발주된 주문의 진행상태가 변경되었음을 알려준다.
	event EventStatusChange(uint orderId, uint status);	//status 는 enum OrderState 참조
	
	//공급사에 어떤 운송계약서를 이용할 것인지 설정해준다.
	//운송계약서는 운송사 입장에서 deploy된다.
	function SetTransportContract(address _transportContractAddr){
		suppliers[msg.sender].tc = TransportContract(_transportContractAddr);
	}

	//운송사에 출고완료되었음을 알려준다.
	//SetTransportContract가 선행되어야 한다.
	function CreateNewDelievery(uint _orderId, bytes32 _src, bytes32 _part, uint _qty, bytes32 _dest, bytes32 _date){
		orders[_orderId].state = OrderState.Preparing;
		EventStatusChange(_orderId, 1);
		suppliers[msg.sender].tc.CreateNewDelievery(this, msg.sender, _orderId, _src, _part, _qty, _dest, _date);
	}
	
	//제조사가 운송을 확인하여 운송완료되었음을 운송사에 알려준다.
	//SetTransportContract가 선행되어야 한다.
	function ConfirmDelievery(uint orderId){
			orders[orderId].state = OrderState.Delievered;
			EventStatusChange(orderId, 3);
			suppliers[orders[orderId].supplierAddr].tc.ConfirmDelievery(orders[orderId].delieveryId);
	}

	//제조사가 최종 검수를 완료한다.
	function FinalConfirm(uint orderId){
	
			//최종 검수 지급금 확인
			Order order = orders[orderId];
			Part part = suppliers[order.supplierAddr].parts[order.partId];
			uint money = part.unitPrice * order.qty/2;

			//검수지급금은 물품대금의 절반이 되어야 한다.
			//절반이상의 돈을 송금받지 못했음을 에러로 리턴한다.
			if(msg.value < money){
					refundAll();
					Error(0, "Not enough money. (50% order)");
					return;
			}
	
			//검수금액 전송.
			order.supplierAddr.send(money);
	
			//상태 변경(검수완료)
			orders[orderId].state = OrderState.Completed;
			EventStatusChange(orderId, 4);
	}

	//운송사 입장에서 운송을 시작한다.
	function StartTransport(uint _delieveryId, uint _orderId){
			orders[_orderId].delieveryId = _delieveryId;
			orders[_orderId].state = OrderState.Transfering;
			EventStatusChange(_orderId, 2);
	}

	// 공급자를 신규등록한다.(_name 공급자 식별 이름)	
	function registerSupply(bytes32 _name) {
		if (suppliers[msg.sender].addr != 0 ) {
				Error(101, "Supplier already registered");
				return;
		}
		suppliers[msg.sender].addr = msg.sender;
		suppliers[msg.sender].name = _name;
	
		//공급자들 정보를 조회할 수 있도록 배열에 추가해준다.
		supplierAddresses.push(msg.sender);
	
		//공급자가 신규등록되었음을 알려준다.
		SupplierRegistered(msg.sender, _name);
	}

	// 공급자 목록을 조회한다.(_page : 0 base)
	// 페이지 번호를 기준으로 10개를 한꺼번에 가져온다.
	function getSupplierList(uint _page) onlyowner constant returns (int items_, address[10] supplierAddrs_, bytes32[10] supplierNames_) {
	
			//가져올 공급자 정보의 인덱스를 parsing 한다.
			uint startIndex; uint endIndex; int itemsToRead;
			(startIndex, endIndex, itemsToRead) = getPageItemIndex(_page, 10, supplierAddresses.length);
			if (itemsToRead <= 0) {
				items_ = 0;
				return;
			}
			address addr = 0;
			uint outIndex = 0;

			//parsing된 index정보를 토대로 리턴할 공급자 정보를 설정해준다.
			for (uint nIndex = startIndex ; nIndex <= endIndex ; nIndex++) {
					addr = supplierAddresses[nIndex];
					if (addr != 0)
						items_++;
					supplierAddrs_[outIndex] = addr;
					supplierNames_[outIndex] = suppliers[addr].name;
					outIndex++;
			}
			return;
	}

	// 공급물품을 등록한다.
	function registerPart(bytes32 _name, uint _unitPrice, uint _duration) onlycontractee returns (uint id_){
			Supplier supplier = suppliers[msg.sender];
			uint newId = supplier.partIds.length + 1;
			id_ = newId;
			supplier.parts[newId].id = newId;
			supplier.parts[newId].name = _name;
			supplier.parts[newId].unitPrice = _unitPrice;
			supplier.parts[newId].duration = _duration;
			supplier.partIds.push(newId);
	
			//공급물품이 신규등록되었음을 알려준다.
			PartRegistered(msg.sender, supplier.name, _name, supplier.partIds.length);
			return;
	}

	// 물품 목록을 조회한다.( _page : 0 base)
	function getPartList(uint _page, address _supplierAddress)
	 returns (int items_, uint[10] id_, bytes32[10] productName_, uint[10] unitPrice_, uint[10] duration_) {
	
			//물품목록을 조회하고자 하는 사람이 기 등록된 공급자인지 검증한다.
			if (!isSupplierExists(_supplierAddress)) {
					Error(0, "No Supplier Exists");
					return;
			}
	
			//가져올 물품정보들의 index를 parsing한다.
			Supplier supplier = suppliers[_supplierAddress];
			uint startIndex; uint endIndex; int itemsToRead;
			(startIndex, endIndex, itemsToRead) = getPageItemIndex(_page, 10, supplier.partIds.length);
			if (itemsToRead < 0) {
					items_ = 0;
					return;
			}
			uint partId = 0;
			uint outIndex = 0;

			//parsing된 index정보를 토대로 리턴할 물품 정보를 설정해준다.
			for (uint nIndex = startIndex ; nIndex <= endIndex ; nIndex++) {
					partId = supplier.partIds[nIndex];
					if (partId > 0)
						items_++;
					id_[outIndex] = supplier.parts[partId].id;
					productName_[outIndex] = supplier.parts[partId].name;
					unitPrice_[outIndex] = supplier.parts[partId].unitPrice;
					duration_[outIndex] = supplier.parts[partId].duration;

					outIndex++;
			}
			return;
	}

	// 제조사가 물품을 발주한다.
	function placeOrder(address _supplierAddress, uint _partId, uint _qty, bytes32 _timeStamp, bytes32 _place) payable onlyowner
	returns (uint orderNumber_) 
	{	
			//새로운 발주번호 설정
			uint newOrderNumber = orderNumbers.length +1;

			// 공급사 / 물품 유무 등록여부 검증
			if (!isSupplierExists(_supplierAddress) || !isPartExists(_supplierAddress, _partId)) {
					refundAll();
					Error(0, "No supplier/part. Refunding ALL");
					return;
			}

			Part part = suppliers[_supplierAddress].parts[_partId];

			// 물품대금의 50%를 보냈는지 검증
			if (msg.value < (part.unitPrice * _qty)/2) { // all in Wei
					refundAll();
					Error(0, "Not enough deposit. (50% order)");
					return;
			}
	
			//제조사로부터 받은 물품대금의 50%를 공급사에 전달한다.
			_supplierAddress.send(part.unitPrice * _qty / 2);

			//Parameter를 토대로 새로운 주문을 생성한다.
			Order order = orders[newOrderNumber];
			order.supplierAddr = _supplierAddress;
			order.orderNumber = orderNumber_ = newOrderNumber;
			order.partId = _partId;
			order.qty = _qty;
			order.orderTimestamp = _timeStamp;
			order.place = _place;
			order.state = OrderState.Ordered;
	
			//주문들의 관리를 위해 주문번호를 주문관리배열에 추가해준다.
			orderNumbers.push(newOrderNumber);
	
			//새로운 주문이 발주되었음을 이벤트로 알려준다.
			NewOrderPlaced(newOrderNumber);
			return;
	}
	
	//제조사가 발주한 전체 목록을 가져온다. (_page : 0 base)
	function getAllOrderList(uint _page) onlyowner
	constant returns (int items_, bool nextAvail_,
		uint[10] orderNumber_, bytes32[10] supplierName_, bytes32[10] partName_,
		uint[10] qty_, bytes32[10] orderTimestamp_, OrderState[10] orderState_, 
		uint[10] price_) {
				uint startIndex; uint endIndex;

				//한 함수 내에서 너무 많은 로컬변수(리턴변수 포함)들이 있을 경우에는 Stack Error가 발생한다.
				//-- Stack 이 깊어져서 오류 발생하므로 index parsing하는 함수를 호출하지 않고 여기에 직접 기술한다.
				//페이지에 따른 표출정보 대상 index parsing
					startIndex = _page * 10;
					if (startIndex >= orderNumbers.length) {
							items_ = 0;
							Message("All Order List : Nothing to List");
							return;
					}
					items_ = int(orderNumbers.length) - int(startIndex);
					if (items_ > 10)
						items_ = 10;
					endIndex = startIndex + uint(items_ );
				

				//parsing 된 index정보들을 토대로, 리턴할 정보들의 값을 설정해준다.
				if (endIndex < orderNumbers.length-1) nextAvail_ = true;
				uint outIndex = 0;  
				for (uint nIndex = startIndex ; nIndex < endIndex ; nIndex++) {
						Order order = orders[orderNumbers[nIndex]];
						orderNumber_[outIndex] = order.orderNumber;
						supplierName_[outIndex] = suppliers[order.supplierAddr].name;
						partName_[outIndex] = suppliers[order.supplierAddr].parts[order.partId].name;
						qty_[outIndex] = order.qty;
						orderTimestamp_[outIndex] = order.orderTimestamp;
						orderState_[outIndex] = order.state;
						price_[outIndex] = suppliers[order.supplierAddr].parts[order.partId].unitPrice;
						outIndex++;
				}

				return;
	}

	// 등록한 공급물품의 전체 갯수를 토대로, 화면에 표출할 페이지 수를 리턴한다.
	function GetPageCountForParts() constant returns (uint cnt){
		Supplier supplier = suppliers[msg.sender];
		if(supplier.partIds.length == 0){	// 등록된 물품이 하나도 없을 경우에는 1 을 리턴하도록 한다.
				cnt = 1;
		}else{
				cnt = (supplier.partIds.length-1)/10 + 1;
		}
	}

	// 전체 발주 주문의 갯수를 토대로, 화면에 표출할 페이지 수를 리턴한다.
	function GetPageCountForAllOrder() onlyowner constant returns (uint cnt){
			if(orderNumbers.length == 0){	// 발주한 내역이 하나도 없을 경우에는 1을 리턴하도록 한다.
				cnt = 1;
			}else{
				cnt = (orderNumbers.length-1)/10 + 1;	
			}
	}
	
	// 전체 수주 주문의 갯수를 토대로, 화면에 표출할 페이지 수를 리턴한다.
	function GetPageCountForOrder() onlycontractee constant returns (uint cnt){
		cnt = 0;
	
		//전체 주문 목록을 순회하면서, 공급자 정보가 매칭되는지 확인한다.
		//(주문이 발주되면 별도로 공급자 정보를 기준으로 관리하는 것이 아니라 전체를 하나로 관리하고 있다. )
		for (uint nIndex = 0 ; nIndex < orderNumbers.length ; nIndex++) {
			Order order = orders[orderNumbers[nIndex]];
			if (order.supplierAddr == msg.sender) {
				cnt++;
			}
		}
		if(cnt ==0){		// 수주한 내역이 하나도 없을 경우에는 1을 리턴하도록 한다.
				cnt = 1;
		}else{
				cnt = (cnt - 1)/10 + 1;
		}
	}
	
	//공급자에게 수주된 주문들의 목록을 불러온다.(_page : 0 base)
	//cnt_ : 리턴되는 항목의 주문정보의 개수(최대 10)
	function getOrderList(uint _page) onlycontractee constant returns (uint cnt_, bool nextAvail_, 
		uint[10] orderNumber_, bytes32[10] ordererName_, bytes32[10] partName_,
		uint[10] qty_, bytes32[10] orderTimestamp_, OrderState[10] orderState_) {
	
				//요청한 페이지 정보에 따라서 시작 인덱스 번호를 설정한다.
				uint startIndex = _page * 10;
				uint orderIdxForContractee;
				cnt_ = 0;
	
				//주문관리배열을 순회하면서 리턴할 정보들을 설정한다.
				for (uint nIndex = 0 ; nIndex < orderNumbers.length ; nIndex++) {
						Order order = orders[orderNumbers[nIndex]];
						if (order.supplierAddr == msg.sender) {	//등록된 주문의 공급자 정보와 정보요청하는 주체가 일치하는지 확인
	
								//최대 10개까지만 리턴하도록 되어있으므로, 더 이상 순회하지 않는다.
								if (orderIdxForContractee == startIndex + 10) {
										nextAvail_ = true;
										break;
								}
	
								//요청한 페이지에 유효한 인덱스에 해당되는지 확인 후 정보를 설정해준다.
								if( orderIdxForContractee >= startIndex ) {
										orderNumber_[orderIdxForContractee - startIndex] = order.orderNumber;
										ordererName_[orderIdxForContractee - startIndex] = getOwnerName();
										partName_[orderIdxForContractee - startIndex] = suppliers[msg.sender].parts[order.partId].name;
										qty_[orderIdxForContractee - startIndex] = order.qty;
										orderTimestamp_[orderIdxForContractee - startIndex] = order.orderTimestamp;
										orderState_[orderIdxForContractee - startIndex] = order.state;
										cnt_ ++;
								}
								orderIdxForContractee++;
						}
				}
		}
	
		//주문 번호를 토대로, 주문상세정보들을 리턴한다.
		//getOrderList에 포함되어서 같이 리턴되면, 주문번호마다 상세내역을 전부 조회할 수는 있지만
		//현재 solidity에서는 너무많은 로컬변수(리턴변수 포함)가 있을 경우에는 에러(stack)가 발생한다.
		function GetOrderDetail(uint orderNumber) onlycontractee constant returns (uint price_, uint duration_, bytes32 place_){
				if(!isOrderExist(orderNumber)){
						Error(0, "No Order Exist");
				}
				address addr = orders[orderNumber].supplierAddr;
				Part part = suppliers[addr].parts[orders[orderNumber].partId];
				price_ = part.unitPrice;
				duration_ = part.duration;
				place_ = orders[orderNumber].place;
		}

	// INTERNAL FUNCTIONS ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

	//리턴할 정보들의 구조체 내에서의 index를 parsing한다.
	//_page : 페이지번호 0 base, _itemsPerPage : 페이지당 아이템 수, _length : 구조체 배열 길이
	function getPageItemIndex(uint _page, uint _itemsPerPage, uint _length)
	internal returns (uint startIndex_, uint endIndex_, int itemsToRead_) {
			startIndex_ = _page * _itemsPerPage;
			if (startIndex_ >= _length) {
					itemsToRead_ = -1;
					return;
			}
			itemsToRead_ = int(_length) - int(startIndex_);
			if (itemsToRead_ > int(_itemsPerPage))
				itemsToRead_ = int(_itemsPerPage);

			endIndex_ = startIndex_ + uint(itemsToRead_ - 1);

			return;
	}
	
	//주문(id)이 존재하는지 확인한다.
	function isOrderExist(uint _id) internal returns (bool){
			if(orders[_id].orderNumber == 0){
				return false;
			}
			return true;
	}
	
	//공급자(_supplierAddress)가 등록되어 있음을 확인한다.
	function isSupplierExists(address _supplierAddress) internal returns (bool) {
			if (suppliers[_supplierAddress].addr == 0)
				return false;
			return true;
	}
	
	//공급자(_supplierAddress)에 물품(_partId)이 존재하는지 확인한다.
	function isPartExists(address _supplierAddress, uint _partId) internal returns (bool) {
			if (suppliers[_supplierAddress].parts[_partId].id == 0)
				return false;
			return true;
	}
	
	//sender가 보낸 금액이 요구사항에 미치지 못했을 때, 전액을 환불해주도록 한다.
	function refundAll() internal {
			msg.sender.send(msg.value);
			MessageUint("Refunding ALL", msg.value);
			return;
	}
}