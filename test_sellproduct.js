let SellProduct = artifacts.require('SellProduct.sol');
let sellProductInstance;

const address0 = "0x0000000000000000000000000000000000000000";

contract("Sell Product", (accounts) => {
    let receiver = accounts[1];
    it("Contract deployment", () => {
        SellProduct.deployed({from: receiver})
        .then((instance) => {
            sellProductInstance = instance;
            assert.notEqual(sellProductInstance, undefined);
        });
    });

    // it("Check receiver is accounts[1]", () => {
    //     return sellProductInstance.getOwner()
    //     .then((result) => {
    //         console.log(result);
    //         // assert.equal(result, receiver);
    //     });
    // });

    describe("Admins", () => {
        it("Add admin", async () => {
            await sellProductInstance.addAdmin("admin 1", accounts[0], {from: accounts[0]});
            await sellProductInstance.addAdmin("admin 2", accounts[2], {from: accounts[0]});
            await sellProductInstance.addAdmin("admin 3", accounts[3], {from: accounts[0]})
            await sellProductInstance.addAdmin("admin 4", accounts[4], {from: accounts[0]})
            return sellProductInstance.addAdmin("admin 5", accounts[5], {from: accounts[0]})
            .then(() => {
                return sellProductInstance.getListAdmin();
            })
            .then((result) => { 
                assert.equal(result.length, 5);
                assert.equal(result[0].name, "admin 1");
                assert.equal(result[0].addr, accounts[0]);

                assert.equal(result[1].name, "admin 2");
                assert.equal(result[1].addr, accounts[2]);

                assert.equal(result[2].name, "admin 3");
                assert.equal(result[2].addr, accounts[3]);
            });
        });

        it("Update admin", async () => {
            await sellProductInstance.updateAdmin(1, "update admin 1", accounts[1]);
            return sellProductInstance.updateAdmin(3, "update admin 3", accounts[4])
            .then(() => {
                return sellProductInstance.getAdminById(1);
            })
            .then((result) => {
                assert.equal(result.name, "update admin 1");
                assert.equal(result.addr, accounts[1]);
            })
            .then(() => {
                return sellProductInstance.getAdminById(3);
            })
            .then((result) => {
                assert.equal(result.name, "update admin 3");
                assert.equal(result.addr, accounts[4]);
            });
        });

        it("Delete admin", async () => {
            await sellProductInstance.removeAdmin(3);
            return sellProductInstance.removeAdmin(5)
            .then(async () => {
                let result = await sellProductInstance.getAdminById(3);
                assert.equal(result.name, "");
                assert.equal(result.addr, address0);
            })
            .then(async () => {
                let result = await sellProductInstance.getAdminById(5);
                assert.equal(result.name, "");
                assert.equal(result.addr, address0);
            });
        });
    });

    describe("Products", () => {
        it("Add item", async () => {
            await sellProductInstance.addItem("Laptop asus", "https://localhost/asus.png", 1200, 4, "laptop", {from: accounts[1]});
            await sellProductInstance.addItem("Laptop dell", "https://localhost/dell.png", 2400, 10, "laptop", {from: accounts[1]})
            return sellProductInstance.addItem("Laptop 1", "https://localhost/1.png", 6400, 12, "laptop", {from: accounts[1]})
            .then(() => {
                return sellProductInstance.getListItem({from: accounts[1]});
            })
            .then((result) => {
                assert.equal(result.length, 3);

                assert.equal(result[0].name, "Laptop asus");
                assert.equal(result[0].imageUrl, "https://localhost/asus.png");
                assert.equal(result[0].pricePerItem, 1200);
                assert.equal(result[0].itemLeft, 4);
                assert.equal(result[0].descriptionUrl, "laptop");

                assert.equal(result[1].name, "Laptop dell");
                assert.equal(result[1].imageUrl, "https://localhost/dell.png");
                assert.equal(result[1].pricePerItem, 2400);
                assert.equal(result[1].itemLeft, 10);
                assert.equal(result[1].descriptionUrl, "laptop");

                assert.equal(result[2].name, "Laptop 1");
                assert.equal(result[2].imageUrl, "https://localhost/1.png");
                assert.equal(result[2].pricePerItem, 6400);
                assert.equal(result[2].itemLeft, 12);
                assert.equal(result[2].descriptionUrl, "laptop");
            });
        });

        it("Update item", async () => {
            await sellProductInstance.updateItem(1, "Laptop HP", "https://localhost/hp.png", 2200, 8, "laptop", {from: accounts[1]})
            return sellProductInstance.updateItem(2, "Laptop Lenovo", "https://localhost/lenovo.png", 200, 12, "laptop", {from: accounts[1]})
            .then(async () => {
                let result = await sellProductInstance.getItemById(1);

                assert.notEqual(result, undefined);
                assert.equal(result.name, "Laptop HP");
                assert.equal(result.imageUrl, "https://localhost/hp.png");
                assert.equal(result.pricePerItem, 2200);
                assert.equal(result.itemLeft, 8);
                assert.equal(result.descriptionUrl, "laptop");
            })
            .then(async () => {
                let result = await sellProductInstance.getItemById(2);
                
                assert.notEqual(result, undefined);
                assert.equal(result.name, "Laptop Lenovo");
                assert.equal(result.imageUrl, "https://localhost/lenovo.png");
                assert.equal(result.pricePerItem, 200);
                assert.equal(result.itemLeft, 12);
                assert.equal(result.descriptionUrl, "laptop");
            });
        });

        it("Delete item", () => {
            let id = 3;
            return sellProductInstance.removeItem(id, {from: accounts[1]})
            .then(() => {
                return sellProductInstance.getItemById(id);
            })
            .then(() => {
                throw "Delete item failed";
            })
            .catch((err) => {
                if(err.toString() === "Delete item failed")
                    assert(false);
                else
                    assert(true);
            });
        });
    });
    describe("Customers", () => {
        it("Add customers", async () => {
            await sellProductInstance.addCustomer("customer1", "012345678", accounts[6]);
            await sellProductInstance.addCustomer("customer2", "033659415", accounts[7]);
            await sellProductInstance.addCustomer("customer3", "092245624", accounts[8]);
            return sellProductInstance.addCustomer("customer4", "036528711", accounts[9])
            .then(async () => {
                let result = await sellProductInstance.getListCustomer({from: accounts[1]});
                assert.equal(result.length, 4);

                assert.equal(result[0].name, "customer1");
                assert.equal(result[0].phone, "012345678");
                assert.equal(result[0].addr, accounts[6]);                    

                assert.equal(result[1].name, "customer2");
                assert.equal(result[1].phone, "033659415");
                assert.equal(result[1].addr, accounts[7]);

                assert.equal(result[2].name, "customer3");
                assert.equal(result[2].phone, "092245624");
                assert.equal(result[2].addr, accounts[8]);

                assert.equal(result[3].name, "customer4");
                assert.equal(result[3].phone, "036528711");
                assert.equal(result[3].addr, accounts[9]);
            });
        });

        it("Update customer", async () => {
            await sellProductInstance.updateCustomer(1, "customer5", "0123455984", accounts[6], {from: accounts[6]});
            return sellProductInstance.updateCustomer(2, "customer6", "0336694274", accounts[7], {from: accounts[7]})
            .then(async () => {
                let result = await sellProductInstance.getCustomerById(1, {from: accounts[6]});
                assert.notEqual(result, undefined);
                
                assert.equal(result.name, "customer5");
                assert.equal(result.phone, "0123455984");
                assert.equal(result.addr, accounts[6]);
            })
            .then(async () => {
                let result = await sellProductInstance.getCustomerById(2, {from: accounts[2]});
                assert.notEqual(result, undefined);
                
                assert.equal(result.name, "customer6");
                assert.equal(result.phone, "0336694274");
                assert.equal(result.addr, accounts[7]);
            });
        });

        it("Delete customer", () => {
            return sellProductInstance.removeCustomer(4, {from: accounts[2]})
            .then(async () => {
                let result = await sellProductInstance.getCustomerById(4, {from: accounts[2]});
                assert.notEqual(result, undefined);
            });
        });
    });

    describe("Orders", () => {
        it("Buy item", async () => {
            // price item 1: 2200
            // price item 2: 200
            // customer 1 buy item 1 with quantity 2
            await sellProductInstance.buyItem(1, 2, {from: accounts[6], value: 4400});

            // customer 2 buy item 1 with quantity 3
            await sellProductInstance.buyItem(1, 3, {from: accounts[7], value: 6600});
            
            // customer 1 buy item 2 with quantity 4
            await sellProductInstance.buyItem(2, 4, {from: accounts[6], value: 800});

            // customer 3 buy item 2 with quantity 4
            return sellProductInstance.buyItem(2, 6, {from: accounts[8], value: 1200})
            .then(async () => { 
                let customerId = 1;
                let result = await sellProductInstance.getAllOrderCustomerById(customerId, {from: accounts[6]});
                assert.notEqual(result, undefined);
                assert.equal(result.length, 2);
                
                assert.equal(result[0].customerId, customerId);
                assert.equal(result[0].itemId, 1);
                assert.equal(result[0].quantity, 2);
                assert.equal(result[0].priceToPay, 4400);
                
                assert.equal(result[1].customerId, customerId);
                assert.equal(result[1].itemId, 2);
                assert.equal(result[1].quantity, 4);
                assert.equal(result[1].priceToPay, 800);
            })
            .then(async () => { 
                let customerId = 2;
                let result = await sellProductInstance.getAllOrderCustomerById(customerId, {from: accounts[7]});
                assert.notEqual(result, undefined);
                assert.equal(result.length, 1);
                
                assert.equal(result[0].customerId, customerId);
                assert.equal(result[0].itemId, 1);
                assert.equal(result[0].quantity, 3);
                assert.equal(result[0].priceToPay, 6600);
            })
            .then(async () => { 
                let customerId = 3;
                let result = await sellProductInstance.getAllOrderCustomerById(customerId, {from: accounts[8]});
                assert.notEqual(result, undefined);
                assert.equal(result.length, 1);
                
                assert.equal(result[0].customerId, customerId);
                assert.equal(result[0].itemId, 2);
                assert.equal(result[0].quantity, 6);
                assert.equal(result[0].priceToPay, 1200);
            });
        });

        it("Check the number of product items left after the customer buys", async () => {
            return sellProductInstance.getItemById(1)
            .then((result) => {
                assert.equal(Number(result.itemLeft), 3);
            })
            .then((result) => {
                return sellProductInstance.getItemById(2);
            })
            .then((result) => {
                assert.equal(Number(result.itemLeft), 2);
            });
        });

        it("Transfer Item", async () => {
            let addrCustomer2 = accounts[7];
            let addrCustomer3 = accounts[8];
            let customerId;

            await sellProductInstance.transferItem(1, 2, addrCustomer2, {from: accounts[4]});
            return sellProductInstance.transferItem(2, 2, addrCustomer3, {from: accounts[4]})
            .then(async () => {
                customerId = 2;
                let result = await sellProductInstance.getAllOrderCustomerById(customerId, {from: addrCustomer2});
                let lastIndex = result.length - 1;
                assert.equal(result[lastIndex].customerId, customerId);
                assert.equal(result[lastIndex].itemId, 1);
                assert.equal(result[lastIndex].quantity, 2);
                assert.equal(result[lastIndex].priceToPay, 4400);
            })
            .then(async () => {
                customerId = 3;
                let result = await sellProductInstance.getAllOrderCustomerById(customerId, {from: addrCustomer3});
                let lastIndex = result.length - 1;
                assert.equal(result[lastIndex].customerId, customerId);
                assert.equal(result[lastIndex].itemId, 2);
                assert.equal(result[lastIndex].quantity, 2);
                assert.equal(result[lastIndex].priceToPay, 400);
            });
        });

        it("Complete order", async () => {
            let bought = 0;
            let complete = 1;
            await sellProductInstance.completeOrder(1, {from: accounts[1]});
            await sellProductInstance.completeOrder(2, {from: accounts[1]});
            await sellProductInstance.completeOrder(3, {from: accounts[1]});
            return sellProductInstance.completeOrder(4, {from: accounts[1]})
            .then(async () => {
                let result = await sellProductInstance.getAllOrder({from: accounts[1]});
                assert.equal(result.length, 6);

                assert.equal(result[0].status, complete);
                assert.equal(result[1].status, complete);
                assert.equal(result[2].status, complete);
                assert.equal(result[3].status, complete);
                assert.equal(result[4].status, bought);
                assert.equal(result[5].status, bought);
            });
        });
    });
});