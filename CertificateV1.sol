// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0 < 0.9.0;

contract CertificateV1 {
    struct Admin {
        uint id;
        string name;
        address addr;
    }

    struct Person {
        uint id;
        string name;
        string email;
        string birthday;
        address addr;
    }

    struct Certificate {
        uint id;
        string name;
        string link;
    }

    address internal _owner;

    Admin[] internal _admins;
    mapping (uint => Admin) internal _mpAdminDetails;

    Person[] internal _persons;
    mapping (uint => Person) public _mpPersonDetails;

    Certificate[] public _certificates;
    mapping (uint => Certificate) public _mpCertificateDetails;

    mapping(uint => Certificate[]) public _mpCertificateOfPersons;

    uint private _idPersonCount = 0;
    uint private _idAdminCount = 0;
    uint private _idCertificateCount = 0;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "No Owner!");
        _;
    }

    modifier onlyAdmin() {
        require(_isAdmin() || _owner == msg.sender, "No permission!");
        _;
    }

    modifier isAdminExist(uint idAdmin) {
        require(_isAdminExist(idAdmin), "Admin not found by id!");
        _;
    }

    modifier isPersonExist(uint idPerson) {
        require(_isPersonExist(idPerson), "Person not found by id!");
        _;
    }

    // Update Owner
    function updateOwner(address to) public onlyOwner {
        require(_owner != to, "Owner already exist!");
        _owner = to;
    }

    // Person
    function addPerson(string memory name, string memory email, string memory birthday, address addr) public onlyAdmin {
        Person memory _newPerson = Person(++_idPersonCount, name, email, birthday, addr);  
        _persons.push(_newPerson);
        
        _mpPersonDetails[_idPersonCount] = _newPerson;
    }

    function updatePerson(uint id, string memory name, string memory email, string memory birthday, address addr) public onlyAdmin isPersonExist(id) {
        uint index = getIndexPersonById(id);
        _persons[index].name = name;
        _persons[index].email = email;
        _persons[index].birthday = birthday;
        _persons[index].addr = addr;

        _mpPersonDetails[_persons[index].id] = _persons[index];
    }

    function removePerson(uint id) public onlyAdmin isPersonExist(id) {
        uint index = getIndexPersonById(id);
        delete _mpPersonDetails[_persons[index].id];
        delete _persons[index];
    }

    function _isPersonExist(uint idPerson) internal view returns(bool) {
        for(uint i = 0; i < _persons.length; i++) {
            if(_persons[i].id == idPerson)
                return true;
        }
        return false;
    }

    function getIndexPersonById(uint id) internal view onlyAdmin isPersonExist(id) returns(uint) {
        for(uint i = 0; i < _persons.length; i++) {
            if(_persons[i].id == id)
                return i;
        }
        revert("No person by id!");
    }

    // Admin
    function addAdmin(string memory name, address addr) public onlyOwner {
        Admin memory _newAdmin = Admin(++_idAdminCount, name,addr);
        _admins.push(_newAdmin);
        _mpAdminDetails[_idAdminCount] = _newAdmin;
    }

    function updateAdmin(uint id, string memory name, address addr) public onlyOwner isAdminExist(id) {
        uint index = getIndexAdminById(id);
        _admins[index].name = name;
        _admins[index].addr = addr;

        _mpAdminDetails[_admins[index].id] = _admins[index];
    }

    function removeAdmin(uint id) public onlyOwner isAdminExist(id) {
        uint index = getIndexAdminById(id);
        delete _mpAdminDetails[_admins[index].id];
        delete _admins[index];
    }

    function getIndexAdminById(uint id) internal view onlyOwner isAdminExist(id) returns(uint) {
        for(uint i = 0; i < _admins.length; i++) {
            if(_admins[i].id == id)
                return i;
        }
        revert("No admin by id!");
    }

    function _isAdmin() internal view returns(bool) {
        for(uint i = 0; i < _admins.length; i++) {
            if(_admins[i].addr == msg.sender)
                return true;
        }
        return false;
    }

    function _isAdminExist(uint id) internal view returns(bool) {
        for(uint i = 0; i < _admins.length; i++) {
            if(_admins[i].id == id)
                return true;
        }
        return false;
    }

    // Certificate for person
    function addCertificateOfPerson(uint idPerson, string memory nameCertificate, string memory linkCertificate) public onlyOwner isPersonExist(idPerson) {
        Certificate memory _newCertificate = Certificate(++_idCertificateCount, nameCertificate, linkCertificate);
        _certificates.push(_newCertificate);

        uint index = getIndexPersonById(idPerson);
        _mpCertificateOfPersons[_persons[index].id].push(_newCertificate);
    }

    function updateCertificateOfPerson(uint idPerson, uint idCertificate, string memory nameCertificate, string memory linkCertificate)
    public onlyOwner isPersonExist(idPerson) {
        uint index = getIndexPersonById(idPerson);
        require(_mpCertificateOfPersons[_persons[index].id].length > 0, "Person hasn't certificate!");
        for(uint i = 0; i < _mpCertificateOfPersons[_persons[index].id].length; i++) {
            if(_mpCertificateOfPersons[_persons[index].id][i].id == idCertificate) {
                _mpCertificateOfPersons[_persons[index].id][i].name = nameCertificate;
                _mpCertificateOfPersons[_persons[index].id][i].link = linkCertificate;
                return;
            }
        }
    }

    function removeCertificateOfPersonByParam(uint idPerson, uint idCertificate) public isPersonExist(idPerson) onlyOwner {
        uint index = getIndexPersonById(idPerson);
        require(_mpCertificateOfPersons[_persons[index].id].length > 0, "Person hasn't certificate!");
        for(uint i = 0; i < _mpCertificateOfPersons[_persons[index].id].length; i++) {
            if(_mpCertificateOfPersons[_persons[index].id][i].id == idCertificate) {
                delete _mpCertificateOfPersons[_persons[index].id][i];
                removeCertificate(idCertificate);
                return;
            }
        }
    }

    // Certificate
    function createCertificate(string memory name, string memory link) public onlyOwner {
        Certificate memory _newCertificate = Certificate(++_idCertificateCount, name, link);
        _certificates.push(_newCertificate);
        _mpCertificateDetails[_newCertificate.id] = _newCertificate;
    }

    function updateCertificate(uint id, string memory name, string memory link) public onlyOwner {
        uint index = getIndexCertificateById(id);
        _certificates[index].name = name;
        _certificates[index].link = link;
    }

    function removeCertificate(uint id) public onlyOwner {
        uint index = getIndexCertificateById(id);
        delete _certificates[index];
    }

    function getIndexCertificateById(uint id) internal view onlyOwner returns (uint) {
        require(_certificates.length > 0, "No hasn't certificate");
        for(uint i = 0; i < _certificates.length; i++) {
            if(_certificates[i].id == id) 
                return i;
        }
        revert("No certificate by id!");
    }
}