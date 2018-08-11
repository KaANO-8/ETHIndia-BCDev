pragma solidity ^0.4.17;

//Campaign factory to create contracts
/**
 * The campaignFactory contract creates campaigns when the user submits a request and deployes on the BC...
 */
contract campaignFactory {

    address[] public deployedCampaigns;
    //to create a new Campaign by providing address and minimimum contribution
    function createCampaign (uint minimimum) public{
        address newCampaign = new Campaign(minimimum,msg.sender);
        deployedCampaigns.push(newCampaign);
        
    } 
    function getDeployedCampaigns () public view returns(address[]) {
        return deployedCampaigns;
           
       }
          
}

//sinle Campaign
contract Campaign {
    //new custom type
    struct Request{
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping (address => bool) approvals;
    }
    address public manager;
    mapping (address => bool) public approvers;
    uint public minContribution;
    Request[] public requests;
    uint public approversCount = 0;

    //define a function modifier to be used by any function
    modifier restricted(){
        //make sure the person calling is the manager
        require(msg.sender == manager);
        //_ is all the code inside the function that uses this modifier
        _;
    }
    
    constructor(uint contribution, address creator) public {
        //creator comes from campaignFactory
        manager  = creator;
        minContribution = contribution;
    }

    function contribute() public payable {
        //if require evaluates to true then only contributer is added(code below require is executed) else exception is thrown
        require(msg.value > minContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }
    //these arguments are all memory type(temparary in memory)
    function createRequest(string des,uint val,address rec) public restricted { 
        //RHS is created in memory so LHS also needs to be a memory variable,
        //if we simply do Request req in LHS then it gives an error as LHS becomes 
        //storage type that can't point to something in memory
        Request memory req = Request({
            description:des,
            value:val,
            recipient:rec,
            complete:false,
            approvalCount:0
            });
        requests.push(req);
    }
    function approveRequest(uint index) public {
        //check if the user is a contibuter
        require(approvers[msg.sender]);
        //check if the user has not voted before for this request
        require(!requests[index].approvals[msg.sender]);
        //check if the request has not been approved/finalized
        require (!requests[index].complete);
        //add user to approvals for this request
        requests[index].approvals[msg.sender] = true;
        //increment the approvalCount for the request
        requests[index].approvalCount++;

    }
    //only manager
    function finalizeRequest(uint index) public restricted{
        //check if the request is not completed
        require (!requests[index].complete);
        //check if count of total approvers is greater than 50% of contibuters
        require(requests[index].approvalCount > (approversCount/2));
        //check if SC has enough contibution to transfer money

        require(address(this).balance >= requests[index].value);
        
        //transfer money to the recipient
        requests[index].recipient.transfer(requests[index].value);
        requests[index].complete = true;

        
    }
    
    
    
    
}
