const Certificate = artifacts.require("./CertificateV1.sol");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

let certificateInstance;

contract("Contract Certificate", (accounts) => {
  it("Contract deployment", () => {
    Certificate.deployed().then((instance) => {
      certificateInstance = instance;
      assert(instance !== undefined, "Certificate contract should be defined");
    });
  });
  
  it("Get Owner", () => {
    return certificateInstance.getOwner()
    .then((result) => {
      assert.equal(result, accounts[0], "Account is not equal");
    });
  });

  it("Add admin", () => {
    return certificateInstance.addAdmin('doan', accounts[2], {from: accounts[0]})
    .then((result) => { 
      return certificateInstance.getAdminById(1, {from: accounts[0]});
    })
    .then((result) => {
      assert.equal(result[1], 'doan', "Add name admin failed");
      assert.equal(result[2], accounts[2], "Add address admin failed");
    });
  });

  it("Update admin", () => {
    return certificateInstance.updateAdmin(1, 'Hai', accounts[1], {from: accounts[0]})
    .then((result) => {
      return certificateInstance.getAdminById(1, {from: accounts[0]});
    })
    .then((result) => {
      assert.equal(result[1], 'Hai', "Name not updated");
      assert.equal(result[2], accounts[1], "Address not updated");
    });
  });

  it("Delete admin", () => {
    return certificateInstance.removeAdmin(1, {from: accounts[0]})
    .then((result) => {
      return certificateInstance.getAdminById(1, {from: accounts[0]});
    })
    .then((result) => {
      assert.equal(result.id, 0, "Delete person failed");
    });
  });

  it("Change Owner", () => { 
    return certificateInstance.updateOwner(accounts[1], {from: accounts[0]})
    .then((result) => {
      return certificateInstance.getOwner({from: accounts[1]});
    })
    .then((result) => {
      assert.equal(result, accounts[1], "Owner hasn't been updated")
    });
  });

  it("Shoult not allowed no owner add admin", () => { 
    return certificateInstance.addAdmin('kha', accounts[3], {from: accounts[2]})
    .then((result) => { 
      throw "Add admin failed"
    })
    .catch((e) => {
      if(e.toString() === "Add admin failed")
        assert(false);
      else
        assert(true);
    });
  });

  it("Shoult not allowed no owner update admin", () => { 
    return certificateInstance.updateAdmin(2, 'Hung', accounts[1], {from: accounts[2]})
    .then((result) => { 
      throw "Update admin failed"
    })
    .catch((e) => {
      if(e.toString() === "Update admin failed")
        assert(false);
      else
        assert(true);
    });
  });

  it("Update admin by id has been delete", () => { 
    return certificateInstance.updateAdmin(1, 'Hung', accounts[2], {from: accounts[1]})
    .then((result) => { 
      throw "Update admin by id has been delete"
    })
    .catch((e) => {
      if(e.toString() === "Update admin by id has been delete")
        assert(false);
      else
        assert(true);
    });
  });

  it("Update admin not exist by id", () => { 
    return certificateInstance.updateAdmin(3, 'Hung', accounts[2], {from: accounts[1]})
    .then((result) => { 
      throw "Update admin not exist by id"
    })
    .catch((e) => {
      if(e.toString() === "Update admin not exist by id")
        assert(false);
      else
        assert(true);
    });
  });

  it("Shoult not allowed no owner delete admin", () => { 
    return certificateInstance.updateAdmin(2, {from: accounts[2]})
    .then((result) => { 
      throw "Delete admin failed"
    })
    .catch((e) => {
      if(e.toString() === "Delete admin failed")
        assert(false);
      else
        assert(true);
    });
  });

  it("Delete admin not exist by id", () => { 
    return certificateInstance.updateAdmin(2, {from: accounts[1]})
    .then((result) => { 
      throw "Delete admin not exist by id"
    })
    .catch((e) => {
      if(e.toString() === "Delete admin not exist by id")
        assert(false);
      else
        assert(true);
    });
  });

  it("Add Person", () => {
    return certificateInstance.addPerson('Hahahah', 'test@gmail.com', '12/3/2000', accounts[0], {from: accounts[1]})
    .then((result) => {
      return certificateInstance.getPersonById(1, {from: accounts[1]});
    })
    .then((result) => {
      assert.notEqual(result, undefined, "Add person failed");
      assert.equal(result[1], 'Hahahah', 'Add name person failed');
      assert.equal(result[2], 'test@gmail.com', 'Add email person failed');
      assert.equal(result[3], '12/3/2000', 'Add birthday person failed');
      assert.equal(result[4], accounts[0], 'Add address person failed');
    });
  });

  it("Update Person", () => {
    return certificateInstance.updatePerson(1, 'Hahahah1', 'test1@gmail.com', '1/3/2000', accounts[2], {from: accounts[1]})
    .then(() => {
      return certificateInstance.getPersonById(1, {from: accounts[1]});
    })
    .then((result) => {
      assert.notEqual(result, undefined, "Person is undefined by id");
      assert.equal(result[1], 'Hahahah1', 'Update name person failed');
      assert.equal(result[2], 'test1@gmail.com', 'Update email person failed');
      assert.equal(result[3], '1/3/2000', 'Update birthday person failed');
      assert.equal(result[4], accounts[2], 'Update address person failed');
    });
  });

  it("Delete Person", () => {
    return certificateInstance.removePerson(1, {from: accounts[1]})
    .then(() => {
      return certificateInstance.getPersonById(1, {from: accounts[1]});
    })
    .then((result) => {
      assert.equal(result.id, 0, "Delete person failed");
    })
    .catch((err) => {
      console.error(err);
    });
  });

  it("Delete Person not exists by id", () => {
    return certificateInstance.removePerson(2, {from: accounts[1]})
    .then((result) => {
      throw "Delete Person not exists by id"
    })
    .catch((err) => {
      if(err.toString() === "Delete Person not exists by id")
        assert(false);
      else
        assert(true);
    });
  });

});
