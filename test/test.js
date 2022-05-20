const PrivateSale = artifacts.require("PrivateSale");
const { time, BN , expectRevert} = require('@openzeppelin/test-helpers');
const { assertion } = require('@openzeppelin/test-helpers/src/expectRevert');
const { web3 } = require('@openzeppelin/test-helpers/src/setup');


contract("PrivateSale", async accounts => {


    let owner = accounts[0];
    let payee_2 = accounts[1];
    let alice = accounts[2];
    let bob = accounts[3];
    let jack = accounts[4];    
    
    let current_time = 0;

    let privateSale;

    

    before('Initial Setup', async () => {

        // TODO : manage current time to avoid Trader Joe expired errors

        privateSale = await PrivateSale.deployed();
        
        const currentBlock = await web3.eth.getBlock("latest");
        const startPresale = currentBlock.timestamp-100; // TMP fix : remove 100s


        await privateSale.setPresaleStartTimestamp.sendTransaction(startPresale, {from:owner})

        const startVesting = startPresale + 7*24*60*60; // In one week from now

        await privateSale.setVestingStartTimestamp.sendTransaction(startVesting, {from:owner}) 

        // Whitelist Alice and Bob but not Jack
        await privateSale.addToWL.sendTransaction([alice, bob], {from:owner}) 



      });




    it ("prints the balances of the SC", async() => {
        let balance_SC_Avax = await web3.eth.getBalance(privateSale.address);
        let balance_SC_MNT = await privateSale.balanceOf(privateSale.address) 
        console.log(`balance SC AVAX: ${web3.utils.fromWei(balance_SC_Avax)}`); 
        console.log(`balance SC MNT: ${web3.utils.fromWei(balance_SC_MNT)}`); 
    })


    it("Alice buys aToken", async() => {

		
		balance = await privateSale.balanceOf.call(alice);
		console.log(`Balance of alice before : ${web3.utils.fromWei(balance)}`); 
		
		let cost = "1";
        const amountToSend = web3.utils.toWei(cost, "ether"); // Convert to wei value
        await web3.eth.sendTransaction({ from: alice, to: privateSale.address, value: amountToSend , gas:8000000});        

		balance = await privateSale.balanceOf.call(alice);
		console.log(`Balance of alice after : ${web3.utils.fromWei(balance)}`); 

    }); 

    it("Bob buys aToken", async() => {

		
		balance = await privateSale.balanceOf.call(bob);
		console.log(`Balance of Bob before : ${web3.utils.fromWei(balance)}`); 
		
		
		let cost  = "1";
        const amountToSend = web3.utils.toWei(cost, "ether"); // Convert to wei value
        await web3.eth.sendTransaction({ from: bob, to: privateSale.address, value: amountToSend , gas:8000000 });        


		balance = await privateSale.balanceOf.call(bob);
		console.log(`Balance of Bob after : ${web3.utils.fromWei(balance)}`); 

    });  
    
    it("Jack tries to buy aToken but fails because not WLed", async() => {

		
		balance = await privateSale.balanceOf.call(jack);
		console.log(`Balance of Jack before : ${web3.utils.fromWei(balance)}`); 
		
		
		let cost  = "1";
        const amountToSend = web3.utils.toWei(cost, "ether"); // Convert to wei value
        await web3.eth.sendTransaction({ from: jack, to: privateSale.address, value: amountToSend , gas:8000000 });        


		balance = await privateSale.balanceOf.call(jack);
		console.log(`Balance of Jack after : ${web3.utils.fromWei(balance)}`); 

    });        

    it ("prints the balances of the SC", async() => {
        let balance_SC_Avax = await web3.eth.getBalance(privateSale.address);
        let balance_SC_MNT = await privateSale.balanceOf(privateSale.address) 
        console.log(`balance SC AVAX: ${web3.utils.fromWei(balance_SC_Avax)}`); 
        console.log(`balance SC MNT: ${web3.utils.fromWei(balance_SC_MNT)}`); 
    })


    it(" one week has passed Alice and bob try to buy but fail", async () => {

        // 7 day has passed 
        current_time+=7*60*60*24
        await time.increase(current_time);

		let cost  = "1";
        const amountToSend = web3.utils.toWei(cost, "ether"); // Convert to wei value
        await web3.eth.sendTransaction({ from: bob, to: privateSale.address, value: amountToSend , gas:8000000 });        
        await web3.eth.sendTransaction({ from: alice, to: privateSale.address, value: amountToSend , gas:8000000 });        

        
    });

    it(" one week has passed Alice and bob try to withdraw but fail", async () => {


            await privateSale.withdraw.sendTransaction({from:alice}) 
            await privateSale.withdraw.sendTransaction({from:bob}) 

            
    });

    it(" three more days have passed Alice and bob withdraw", async () => {
        // 3 day has passed 
        current_time+=3*60*60*24
        await time.increase(current_time);

        await privateSale.withdraw.sendTransaction({from:alice}) 
        await privateSale.withdraw.sendTransaction({from:bob}) 

        
});    

    it(" Alice and bob try to withdraw but fail because already withdrawn", async () => {

        await privateSale.withdraw.sendTransaction({from:alice}) 
        await privateSale.withdraw.sendTransaction({from:bob}) 

        
    });   
 


    it ("prints the balances of the SC", async() => {
        let balance_SC_Avax = await web3.eth.getBalance(privateSale.address);
        let balance_SC_MNT = await privateSale.balanceOf(privateSale.address) 
        console.log(`balance SC AVAX: ${web3.utils.fromWei(balance_SC_Avax)}`); 
        console.log(`balance SC MNT: ${web3.utils.fromWei(balance_SC_MNT)}`); 
    })

    
    
    
  
   
    
});

