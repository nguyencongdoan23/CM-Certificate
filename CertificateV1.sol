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
    // PersonId => Person
    mapping (uint => Person) internal _mpPersonDetails;

    Certificate[] internal _certificates;
    // CertificateId => Certificate
    mapping (uint => Certificate) internal _mpCertificateDetails;

    // certificateId => personId
    mapping (uint => uint) internal _mpCertificateIdToPersonId;

    // PersonId => Certificate
    mapping(uint => Certificate[]) internal _mpCertificateOfPersons;

    uint private _personIdCount = 0;
    uint private _idAdminCount = 0;
    uint private _certificateIdCount = 0;

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

    modifier isPersonExist(uint personId) {
        require(_isPersonExist(personId), "Person not found by id!");
        _;
    }

    modifier checkCertificateExistOfPerson(uint certificateId) {
        require(_checkCertificateExistOfPerson(certificateId), "Certificate has been used!");
        _;
    }

    // Update Owner
    function updateOwner(address to) public onlyOwner {
        require(_owner != to, "Owner already exist!");
        _owner = to;
    }

    // Person
    function addPerson(string memory name, string memory email, string memory birthday, address addr) public onlyAdmin {
        Person memory _newPerson = Person(++_personIdCount, name, email, birthday, addr);  
        _persons.push(_newPerson);
        
        _mpPersonDetails[_personIdCount] = _newPerson;
    }

    function updatePerson(uint id, string memory name, string memory email, string memory birthday, address addr) public onlyAdmin {
        uint index = getIndexPersonById(id);
        _persons[index].name = name;
        _persons[index].email = email;
        _persons[index].birthday = birthday;
        _persons[index].addr = addr;

        _mpPersonDetails[_persons[index].id] = _persons[index];
    }

    function removePerson(uint id) public onlyAdmin {
        uint index = getIndexPersonById(id);
        delete _mpPersonDetails[_persons[index].id];
        _persons[index] = _persons[_persons.length - 1];
        _persons.pop();
    }

    function _isPersonExist(uint personId) internal view returns(bool) {
        if(_mpPersonDetails[personId].id > 0)
            return true;
        return false;
    }

    function getIndexPersonById(uint id) internal view returns(uint) {
        for(uint i = 0; i < _persons.length; i++) {
            if(_persons[i].id == id)
                return i;
        }
        revert("Not found person by id!");
    }

    function getLengthListPerson() public view returns (uint) {
        return _persons.length;
    }

    function getListPerson() public view returns (Person[] memory) {
        return _persons;
    }

    function getPersonById(uint id) public view onlyAdmin returns (Person memory) {
        return _mpPersonDetails[id];
    }

    // Admin
    function addAdmin(string memory name, address addr) public onlyOwner {
        Admin memory _newAdmin = Admin(++_idAdminCount, name,addr);
        _admins.push(_newAdmin);
        _mpAdminDetails[_idAdminCount] = _newAdmin;
    }

    function updateAdmin(uint id, string memory name, address addr) public onlyOwner {
        uint index = _getIndexAdminById(id);
        _admins[index].name = name;
        _admins[index].addr = addr;

        _mpAdminDetails[_admins[index].id] = _admins[index];
    }

    function removeAdmin(uint id) public onlyOwner {
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

    function getLengthListAdmin() public view onlyOwner returns (uint) {
        return _admins.length;
    }

    function getListAdmin() public view onlyOwner returns (Admin[] memory) {
        return (_admins);
    }

    function getAdminById(uint id) public view onlyOwner returns (Admin memory) {
        return _mpAdminDetails[id];
    }

    function _isAdmin() internal view returns(bool) {
        for(uint i = 0; i < _admins.length; i++) {
            if(_admins[i].addr == msg.sender)
                return true;
        }
        return false;
    }

    // Certificate for person
    function addCertificateOfPerson(uint personId, string memory nameCertificate, string memory linkCertificate) public onlyAdmin isPersonExist(personId) {
        Certificate memory _newCertificate = Certificate(++_certificateIdCount, nameCertificate, linkCertificate);
        _certificates.push(_newCertificate);

        uint index = getIndexPersonById(personId);
        _mpCertificateOfPersons[_persons[index].id].push(_newCertificate);

        _mpCertificateIdToPersonId[_newCertificate.id] = personId;
    }

    function updateCertificateOfPerson(uint certificateId, string memory nameCertificate, string memory linkCertificate) public onlyAdmin {
        uint personId = _mpCertificateIdToPersonId[certificateId];
        require(personId > 0, "Person hasn't this certificate by certificateId");
        require(_mpCertificateOfPersons[personId].length > 0, "Certificate hasn't person!");

        updateCertificate(certificateId, nameCertificate, linkCertificate);

        for(uint i = 0; i < _mpCertificateOfPersons[personId].length; i++) {
            if(_mpCertificateOfPersons[personId][i].id == certificateId) {
                _mpCertificateOfPersons[personId][i].name = nameCertificate;
                _mpCertificateOfPersons[personId][i].link = linkCertificate;
                return;
            }
        }
    }

    function removeCertificateOfPerson(uint certificateId) public onlyAdmin {
        uint personId = _mpCertificateIdToPersonId[certificateId];
        require(personId > 0, "Person hasn't this certificate by certificateId");
        require(_mpCertificateOfPersons[personId].length > 0, "Certificate hasn't person!");

        removeCertificate(certificateId);

        delete _mpCertificateIdToPersonId[certificateId];

        uint lastIndex = _mpCertificateOfPersons[personId].length - 1;
        for(uint i = 0; i < _mpCertificateOfPersons[personId].length; i++) {
            if(_mpCertificateOfPersons[personId][i].id == certificateId) {
                _mpCertificateOfPersons[personId][i] = _mpCertificateOfPersons[personId][lastIndex];
                _mpCertificateOfPersons[personId].pop();
                return;
            }
        }
    }

    function getPersonByCertificateId(uint certificateId) public view onlyAdmin returns (Person memory) {
        uint personId = _mpCertificateIdToPersonId[certificateId];
        require(personId > 0, "No person of this certificate by certificateId");
        require(_mpCertificateOfPersons[personId].length > 0, "Certificate hasn't person!");
        return _mpPersonDetails[personId];
    }

    function getListCertificateOfPersonByPersonId(uint personId) public view onlyAdmin returns (Certificate[] memory) {
        require(_mpCertificateOfPersons[personId].length > 0, "Person hasn't certificate!");
        return _mpCertificateOfPersons[personId];
    }

    // Certificate
    function createCertificate(string memory name, string memory link) public onlyOwner {
        Certificate memory _newCertificate = Certificate(++_certificateIdCount, name, link);
        _certificates.push(_newCertificate);
        _mpCertificateDetails[_newCertificate.id] = _newCertificate;
    }

    function updateCertificate(uint certificateId, string memory nameCertificate, string memory linkCertificate) public onlyOwner {
        uint index = _getIndexCertificateById(certificateId);
        _certificates[index].name = nameCertificate;
        _certificates[index].link = linkCertificate;

        _mpCertificateDetails[certificateId] = _certificates[index];
    }

    function removeCertificate(uint certificateId) public onlyOwner {
        uint index = _getIndexCertificateById(certificateId);
        _certificates[index] = _certificates[_certificates.length - 1];
        _certificates.pop();

        delete _mpCertificateDetails[certificateId];
    }

    function _getIndexCertificateById(uint id) internal view onlyOwner returns (uint) {
        require(_certificates.length > 0, "No hasn't certificate");
        for(uint i = 0; i < _certificates.length; i++) {
            if(_certificates[i].id == id) 
                return i;
        }
        revert("Not found certificate by id!");
    }

    function getLengthListCertificate() public view onlyOwner returns (uint) {
        return _certificates.length;
    }

    function getAllCertificate() public view onlyOwner returns (Certificate[] memory) {
        require(_certificates.length > 0);
        return _certificates;
    }

    // tranfer certificate from certificateId to persom
    function tranferCertificateToPerson(uint certificateId, uint personId) public onlyOwner isPersonExist(personId) checkCertificateExistOfPerson(certificateId) {
        require(_mpCertificateDetails[certificateId].id > 0, "Not found certificate by certificateId");
        // get information certificate by certificateId
        Certificate memory certificate = _mpCertificateDetails[certificateId];
        _mpCertificateOfPersons[personId].push(certificate);

        _mpCertificateIdToPersonId[certificateId] = personId;
    }

    // tranfer many certificate from certificateId to persom
    function tranferManyCertificateToPerson(uint[] memory certificateIds, uint personId) public onlyOwner isPersonExist(personId) {
        require(certificateIds.length > 0, "Params false!");
        require(_checkCertificatesExist(certificateIds), "Not found certificate or certificate has been used");
        for (uint i = 0; i < certificateIds.length; i++) {
            tranferCertificateToPerson(certificateIds[i], personId);
        }
    }

    function _checkCertificatesExist(uint[] memory certificateIds) internal view onlyOwner returns (bool) {
        for (uint i = 0; i < certificateIds.length; i++) {
            uint certificateId = certificateIds[i];
            if(_mpCertificateDetails[certificateId].id == 0 || !_checkCertificateExistOfPerson(certificateId))
                return false;
        }
        return true;
    }

    function _checkCertificateExistOfPerson(uint certificateId) internal view onlyOwner returns (bool) {
        if(_mpCertificateIdToPersonId[certificateId] > 0)
            return false;
        return true;
    }
}
