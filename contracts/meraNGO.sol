pragma solidity ^0.4.17;

//single NGO
contract NGO {
    //new custom type
    struct DonationRequest{
        string description;
        uint value;
        address recipient;
        bool complete;
        uint rejectionStake;
        mapping (address => bool) approvals;
    }

    address public NGOaddress;
    mapping (address => uint256) public contributers;
    uint public minContribution;
    DonationRequest[] public donationRequests;
    uint public contributerCount = 0;
    uint public totalAmountContributed = 0;

    //define a function modifier to be used by any function
    modifier restricted(){
        // make sure it's authentic NGO  i
        require(msg.sender == NGOaddress);
        //_ is all the code inside the function that uses this modifier
        _;
    }
    
    constructor(uint contribution, address creator) public {
        //creator comes from campaignFactory
        NGOaddress  = creator;
        minContribution = contribution;
    }

    function contribute() public payable {
        //if require evaluates to true then only contributer is added(code below require is executed) else exception is thrown
        require(msg.value > minContribution, "Your contribution has to be greater than minContribution");
        contributers[msg.sender] = msg.value;
        contributerCount++;
        totalAmountContributed+=msg.value;
    }
    //these arguments are all memory type(temparary in memory)
    function createDonationRequest(string des,uint val,address rec) public restricted { 
        
        require(contributers[rec] == 0, "A contributer cannot be a recipient");
        
        //RHS is created in memory so LHS also needs to be a memory variable,
        //if we simply do Request req in LHS then it gives an error as LHS becomes 
        //storage type that can't point to something in memory
        DonationRequest memory donationRequest = DonationRequest({
            description:des,
            value:val,
            recipient:rec,
            complete:false,
            rejectionStake:0
            });
        donationRequests.push(donationRequest);
    }
    
    function rejectExpendRequest(uint index) public {
        //check if the user is a contibuter
        require(contributers[msg.sender] > 0, "Sorry, you aren't a contributer");
        //check if the user has not voted before for this request
        require(!donationRequests[index].approvals[msg.sender]);
        //check if the request has not been approved/finalized
        require (!donationRequests[index].complete);
        //add user to approvals for this request
        donationRequests[index].approvals[msg.sender] = true;
        //increment the approvalCount for the request
        donationRequests[index].rejectionStake += contributers[msg.sender];

    }
    
    //only NGO
    function finalizeRequest(uint index) public restricted{
        //check if the request is not completed
        require (!donationRequests[index].complete);
        //check if count of total approvers is greater than 50% of contibuters
        require(donationRequests[index].rejectionStake < (totalAmountContributed/2));
        //check if SC has enough contibution to transfer money

        require(address(this).balance >= donationRequests[index].value);
        
        //transfer money to the recipient
        donationRequests[index].recipient.transfer(donationRequests[index].value);
        donationRequests[index].complete = true;

        
    }
}
