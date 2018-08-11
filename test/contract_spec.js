// /*global contract, config, it, assert*/
/*const SimpleStorage = require('Embark/contracts/SimpleStorage');

config({
  contracts: {
    "SimpleStorage": {
      args: [100]
    }
  }
});

contract("SimpleStorage", function () {
  this.timeout(0);

  it("should set constructor value", async function () {
    let result = await SimpleStorage.methods.storedData().call();
    assert.strictEqual(parseInt(result, 10), 100);
  });

  it("set storage value", async function () {
    await SimpleStorage.methods.set(150).send();
    let result = await SimpleStorage.methods.get().call();
    assert.strictEqual(parseInt(result, 10), 150);
  });
});*/


/* const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const compiledFactory = require('../ethereum/build/campaignFactory.json');
const compiledCampaign = require('../ethereum/build/Campaign.json');


let accounts;
let factory;
let campaignAddress;
let campaign;

beforeEach(async ()=>{
	accounts  = await web3.eth.getAccounts();

	factory = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
		.deploy({data:'0x' + compiledFactory.bytecode})
		.send({from:accounts[0],gas:'1000000'});
	//create a campaign to test
	await factory.methods.createCampaign('100').send({from:accounts[0],gas:'1000000'});
	[campaignAddress] = await factory.methods.getDeployedCampaigns().call();
	campaign = await new web3.eth.Contract(JSON.parse(compiledCampaign.interface),campaignAddress);
});

describe('Campaign',()=>{
	it('deploy',() => {
		assert.ok(factory.options.address);
		assert.ok(campaign.options.address);
	});
	it('manager is the caller of the SC',async ()=>{
		const manager = await campaign.methods.manager().call();
		assert.equal(manager,accounts[0]);
	});
	it('able to contribute',async ()=>{
		await campaign.methods.contribute().send({from:accounts[1],value:'101'});
		const isApprover = await campaign.methods.approvers(accounts[1]).call();
		assert(isApprover);
	});
	it('requires minimum contribution',async ()=>{
		try{
			await campaign.methods.contribute().send({from:accounts[1],value:'50'});
			assert(false);
		}
		catch(err){
			assert(err);
		}
		

	});
	it('allows a manager to make a request',async ()=>{
		await campaign.methods.createRequest('test',"100",accounts[1]).send({from:accounts[0],gas:"1000000"});
		const req = await campaign.methods.requests(0).call();
		assert.equal('test',req.description);

	});
	it('process request',async ()=>{
		await campaign.methods.contribute().send({from:accounts[0],value:web3.utils.toWei('10','ether')});
		await campaign.methods.createRequest('test',web3.utils.toWei('5','ether'),accounts[1]).send({from:accounts[0],gas:'1000000'});
		await campaign.methods.approveRequest(0).send({from:accounts[0],gas:'1000000'});
		await campaign.methods.finalizeRequest(0).send({from:accounts[0],gas:'1000000'});
		const balance = parseFloat(web3.utils.fromWei(await web3.eth.getBalance(accounts[1]),'ether'));
		console.log(balance);
		assert(balance > 104);


	});
}); */
