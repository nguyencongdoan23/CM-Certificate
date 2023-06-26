// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0 < 0.9.0;

contract SellLaptopProducts {
    struct Admin {
        uint id;
        string name;
        address addr;
    }

    struct Item {
        uint id;
        string name;
        string imageUrl;
        uint pricePerItem;
        uint itemLeft;
        string descriptionUrl;
    }

    struct Customer {
        uint id;
        string name;
        string phone;
        address addr;
    }

    struct Order {
        uint id;
        uint customerId;
        uint itemId;
        uint quantity;
        uint priceToPay;
        Status status;
    }

    Admin[] internal _admins;
    mapping (uint => Admin) internal _mpAdminDetails;

    Item[] internal _items;
    mapping (uint => Item) internal _mpItemDetails;

    Customer[] internal _customers;
    mapping (uint => Customer) internal _mpCustomerDetails;
    mapping (address => Customer) internal _mpCustomers;

    Order[] internal _orders;
    // orderId => Order
    mapping (uint => Order) internal _mpOrderDetails;
    // customerId => Order[]
    mapping (uint => Order[]) internal _mpOrdersCustomer;

    enum Status {Bought, Complete}
    uint private _adminIdCount;
    uint private _itemIdCount;
    uint private _customerIdCount;
    uint private _orderIdCount;
    address private _receiverValue;

    event boughtSuccess(Order);
    event transferSuccess(Order);
    event completeSuccess(Order);

    constructor() {
        _receiverValue = msg.sender;
    }

    modifier onlyReceiver {
        require(_receiverValue == msg.sender, "No ReceiverValue!");
        _;
    }

    modifier isExistItem(uint id) {
        require(_isExistItemById(id), "Not found item by id!");
        _;
    }

    modifier isExistAddress(address addr, uint id) {
        require(!_isExistAddressCustomerByAddress(addr, id), "Address has been used!");
        _;
    }

    modifier isExistOrderId(uint orderId) {
        require(_mpOrderDetails[orderId].id > 0, "Not found order by id!");
        _;
    }
    
    modifier isExistCustomer(address addr) {
        require(_mpCustomers[addr].id > 0, "No customer!");
        _;
    }

    modifier onlyAdmin() {
        require(_isAdmin(), "No permission!");
        _;
    }

    function updateReceiver(address to) public onlyReceiver {
        require(_receiverValue != to, "Receiver already exist!");
        _receiverValue = to;
    }

    // admin
    function addAdmin(string memory name, address addr) public {
        Admin memory _newAdmin = Admin(++_adminIdCount, name, addr);
        _admins.push(_newAdmin);
        _mpAdminDetails[_adminIdCount] = _newAdmin;
    }

    function updateAdmin(uint id, string memory name, address addr) public {
        uint index = _getIndexAdminById(id);
        _admins[index].name = name;
        _admins[index].addr = addr;

        _mpAdminDetails[_admins[index].id] = _admins[index];
    }

    function removeAdmin(uint id) public {
        uint index = _getIndexAdminById(id);
        delete _mpAdminDetails[_admins[index].id];
        _admins[index] = _admins[_admins.length - 1];
        _admins.pop();
    }

    function _getIndexAdminById(uint id) internal view returns(uint) {
        for(uint i = 0; i < _admins.length; i++) {
            if(_admins[i].id == id)
                return i;
        }
        revert("Not found admin by id!");
    }

    function getListAdmin() public view returns (Admin[] memory) {
        return _admins;
    }

    function getAdminById(uint id) public view returns (Admin memory) {
        return _mpAdminDetails[id];
    }

    function _isAdmin() internal view returns(bool) {
        for(uint i = 0; i < _admins.length; i++) {
            if(_admins[i].addr == msg.sender)
                return true;
        }
        return false;
    }

    // item laptop
    function addItem(string memory name, string memory imageUrl, uint pricePerItem, uint itemLeft, string memory descriptionUrl) 
    public onlyAdmin {
        Item memory newItem = Item(++_itemIdCount, name, imageUrl, pricePerItem, itemLeft, descriptionUrl);
        _items.push(newItem);

        _mpItemDetails[_itemIdCount] = newItem;
    }

    function updateItem(uint id, string memory name, string memory imageUrl, uint pricePerItem, uint itemLeft, string memory descriptionUrl)
    public onlyAdmin {
        uint index = _getIndexItemById(id);
        _items[index].name = name;
        _items[index].imageUrl = imageUrl;
        _items[index].pricePerItem = pricePerItem;
        _items[index].itemLeft = itemLeft;
        _items[index].descriptionUrl = descriptionUrl;

        _mpItemDetails[id] = _items[index];
    }

    function removeItem(uint id) public onlyAdmin {
        uint index = _getIndexItemById(id);
        _items[index] = _items[_items.length - 1];
        _items.pop();

        delete _mpItemDetails[id]; 
    }

    function _getIndexItemById(uint id) internal view returns (uint) {
        for (uint i = 0; i < _items.length; i++) {
            if(_items[i].id == id)
                return i;
        }
        revert("Not found item by id!");
    }

    function _isExistItemById(uint id) internal view returns (bool) {
        for (uint i = 0; i < _items.length; i++) {
            if(_items[i].id == id)
                return true;
        }
        return false;
    }

    function getListItem() public view onlyAdmin returns (Item[] memory) {
        return _items;
    }

    function getItemById(uint id) public view onlyAdmin isExistItem(id) returns (Item memory) {
        return _mpItemDetails[id];
    }

    // customer
    function addCustomer (string memory name, string memory phone, address addr) public isExistAddress(addr, 0) {
        Customer memory newCustomer = Customer(++_customerIdCount, name, phone, addr);
        _customers.push(newCustomer);
        
        _mpCustomerDetails[_customerIdCount] = _mpCustomers[addr] = newCustomer;
    }

    function updateCustomer (uint id, string memory name, string memory phone, address addr) public isExistAddress(addr, id) {
        uint index = _getIndexCustomerById(id);
        _customers[index].name = name;
        _customers[index].phone = phone;
        _customers[index].addr = addr;

        _mpCustomerDetails[id] = _mpCustomers[addr] = _customers[index];
    }

    function removeCustomer (uint id) public {
        uint index = _getIndexCustomerById(id);
        _customers[index] = _customers[_customers.length - 1];
        _customers.pop();

        delete _mpCustomers[_mpCustomerDetails[id].addr];
        delete _mpCustomerDetails[id];

        delete _mpOrdersCustomer[id];
    }

    function getCustomerById(uint id) public view returns (Customer memory) {
        return _mpCustomerDetails[id];
    }

    function getListCustomer() public view returns (Customer[] memory) {
        return _customers;
    }

    function getBalanceOfCustomerByAddress(address addr) public view returns (uint) {
        return addr.balance;
    }

    function _getIndexCustomerById(uint id) internal view returns (uint) {
        require(_customers.length > 0, "No list customers!");
        for (uint i = 0; i < _customers.length; i++) {
            if(_customers[i].id == id) 
                return i;
        }
        revert("Not found customer by id!");
    }
  
    function _isExistAddressCustomerByAddress(address addr, uint id) internal view returns (bool) {
        for (uint i = 0; i < _customers.length; i++) {
            if (id > 0) {
                if(_customers[i].addr == addr && _customers[i].id != id)
                    return true; 
            }
            else if(_customers[i].addr == addr) 
                return true;
        }
        return false;
    }

    // Buy Item
    function buyItem(uint itemId, uint quantity) payable public isExistCustomer(msg.sender) isExistItem(itemId) {
        require(msg.value > 0, "Balance in wallet must be > 0!");
        require(_mpItemDetails[itemId].itemLeft >= quantity, "Invalid quantity!");
        uint priceToPay = _mpItemDetails[itemId].pricePerItem * quantity;
        require(msg.value >= priceToPay, "Insufficient wallet balance!");

        payable(_receiverValue).transfer(priceToPay);

        uint orderId = _createOrder(itemId, quantity, priceToPay, msg.sender);
        emit boughtSuccess(_mpOrderDetails[orderId]);
    }
    
    function transferItem(uint itemId, uint quantity, address customerAddr) public onlyAdmin isExistCustomer(customerAddr) isExistItem(itemId) {
        require(_mpItemDetails[itemId].itemLeft >= quantity, "Invalid quantity!");

        uint priceToPay = _mpItemDetails[itemId].pricePerItem * quantity;
        uint orderId = _createOrder(itemId, quantity, priceToPay, customerAddr);
        emit transferSuccess(_mpOrderDetails[orderId]);
    }

    function _createOrder(uint itemId, uint quantity, uint priceToPay, address customerAddr) internal returns (uint) {
        uint customerId = _mpCustomers[customerAddr].id;
        Order memory newOrder = Order(++_orderIdCount, customerId, itemId, quantity, priceToPay, Status.Bought);
        _orders.push(newOrder);

        _mpOrderDetails[_orderIdCount] = newOrder;
        _mpOrdersCustomer[customerId].push(newOrder);

        uint indexItem = _getIndexItemById(itemId);
        _items[indexItem].itemLeft -= quantity;
        _mpItemDetails[itemId] = _items[indexItem];
        return newOrder.id;
    }

    function completeItem(uint orderId) public onlyAdmin isExistOrderId(orderId) {
        Order memory order = _mpOrderDetails[orderId];

        if(order.status == Status.Complete)
            revert("Order has been status complete!");

        uint customerId = order.customerId;
        uint indexOrder = _getIndexOrderById(orderId);
        uint indexOrderCus = _getIndexOrderCustomerByParams(customerId, orderId);

        _orders[indexOrder].status = Status.Complete;
        _mpOrderDetails[orderId] = _mpOrdersCustomer[customerId][indexOrderCus] = _orders[indexOrder];

        emit completeSuccess(_orders[indexOrder]);
    }

    function _getIndexOrderCustomerByParams(uint customerId, uint orderId) internal view onlyAdmin returns (uint) {
        for (uint i = 0; i < _mpOrdersCustomer[customerId].length; i++) {
            if(_mpOrdersCustomer[customerId][i].id == orderId)
                return i;
        }
        revert("Not found order customer by params!");
    }

    function _getIndexOrderCustomerById(uint customerId) internal view onlyAdmin returns (uint) {
        for (uint i = 0; i < _mpOrdersCustomer[customerId].length; i++) {
            if(_mpOrdersCustomer[customerId][i].customerId == customerId)
                return i;
        }
        revert("Not found order customer by id!");
    }

    function _getIndexOrderById(uint id) internal view onlyAdmin returns (uint) {
        for (uint i = 0; i < _orders.length; i++) {
            if(_orders[i].id == id)
                return i;
        }
        revert("Not found order customer by id!");
    }

    function getAllOrder() public view returns (Order[] memory) {
        return _orders;
    }

    function getAllOrderCustomerById(uint id) public view returns (Order[] memory) {
        return _mpOrdersCustomer[id];
    }
}