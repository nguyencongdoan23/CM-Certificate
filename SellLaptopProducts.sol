// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0 < 0.9.0;

contract SellLaptopProducts {
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

    struct Admin {
        uint id;
        string name;
        address addr;
    }

    Admin[] internal _admins;
    mapping (uint => Admin) internal _mpAdminDetails;

    Item[] internal _items;
    mapping (uint => Item) internal _mpItemDetails;

    Customer[] internal _customers;
    mapping (uint => Customer) _mpCustomerDetails;

    uint private _adminIdCount;
    uint private _itemIdCount;
    uint private _customerIdCount;

    modifier onlyAdmin() {
        require(_isAdmin(), "No permission!");
        _;
    }

    modifier isExistAddress(address addr) {
        require(!_isExistAddressCustomerByAddress(addr, 0), "Address has been used!");
        _;
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

    function nListAdmin() public view returns (uint) {
        return _admins.length;
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

    function getListItem() public view onlyAdmin returns (Item[] memory) {
        return _items;
    }

    // customer
    function addCustomer (string memory name, string memory phone, address addr) public isExistAddress(addr) {
        Customer memory newCustomer = Customer(++_customerIdCount, name, phone, addr);
        _customers.push(newCustomer);
        
        _mpCustomerDetails[_customerIdCount] = newCustomer;
    }

    function updateCustomer (uint id, string memory name, string memory phone, address addr) public {
        uint index = _getIndexCustomerById(id);
        require(!_isExistAddressCustomerByAddress(addr, id), "Address has been used!");
        _customers[index].name = name;
        _customers[index].phone = phone;
        _customers[index].addr = addr;

        _mpCustomerDetails[id] = _customers[index];
    }

    function removeCustomer (uint id) public {
        uint index = _getIndexCustomerById(id);
        _customers[index] = _customers[_customers.length - 1];
        _customers.pop();

        delete _mpCustomerDetails[id];
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
        require(_customers.length > 0, "No list customers!");
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
}