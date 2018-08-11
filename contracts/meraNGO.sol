pragma solidity ^0.4.17;

//single NGO
contract NGO {
    
    //new custom type
    struct DonationRequest{
        string description;
        int value;
        address recipient;
        bool complete;
        int rejectionStake;
        mapping (address => bool) approvals;
    }

    address public NGOaddress;
    mapping (address => int256) public contributers;
    int public minContribution;
    DonationRequest[] public donationRequests;
    int public contributerCount = 0;
    int public totalAmountContributed = 0;
    int public reliabilityFactor = 10;
    
    //define a function modifier to be used by any function
    modifier restricted(){
        // make sure it's authentic NGO  i
        require(msg.sender == NGOaddress);
        //_ is all the code inside the function that uses this modifier
        _;
    }
    
    constructor(int contribution, address creator) public {
        //creator comes from campaignFactory
        NGOaddress  = creator;
        minContribution = contribution;
    }

    function contribute() public payable {
        //if require evaluates to true then only contributer is added(code below require is executed) else exception is thrown

        require(int(msg.value) > minContribution, "Your contribution has to be greater than minContribution");
        contributers[msg.sender] = int(msg.value);
        contributerCount++;
        totalAmountContributed+=int(msg.value);
    }
    //these arguments are all memory type(temparary in memory)
    function createDonationRequest(string des,int val,address rec) public restricted { 
        
        require(contributers[rec] == 0, "A contributer cannot be a recipient");
        
        require(val*100<=totalAmountContributed*reliabilityFactor, "Value raised more than the max permitted");
        
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
    
    function rejectExpendRequest(int index) public {
        //check if the user is a contibuter
        require(contributers[msg.sender] > 0, "Sorry, you aren't a contributer");
        //check if the user has not voted before for this request
        require(!donationRequests[uint(index)].approvals[msg.sender]);
        //check if the request has not been approved/finalized
        require (!donationRequests[uint(index)].complete);
        //add user to approvals for this request
        donationRequests[uint(index)].approvals[msg.sender] = true;
        //increment the approvalCount for the request
        donationRequests[uint(index)].rejectionStake += contributers[msg.sender];
        
    }
    
    function updateReliabilityFactor(int rejections) private
    {
        reliabilityFactor = reliabilityFactor + (reliabilityFactor*(totalAmountContributed-2*rejections))/(totalAmountContributed);
        reliabilityFactor = min(99,reliabilityFactor);
        reliabilityFactor = max(1,reliabilityFactor);
    }
    
    //only NGO
    function finalizeRequest(int index) public restricted{
        //check if the request is not completed
        require (!donationRequests[uint(index)].complete);
        
        //check if count of total approvers is greater than 50% of contibuters
        if(donationRequests[uint(index)].rejectionStake < (totalAmountContributed/2) )
        {
            updateReliabilityFactor(donationRequests[uint(index)].rejectionStake);
            //check if SC has enough contibution to transfer money
            require( int(address(this).balance) >= donationRequests[uint(index)].value , 'Not enough balance!' );
            //transfer money to the recipient
            donationRequests[uint(index)].recipient.transfer(uint(donationRequests[uint(index)].value));
            donationRequests[uint(index)].complete = true;
        }
        else
        {
            updateReliabilityFactor(donationRequests[uint(index)].rejectionStake);
            donationRequests[uint(index)].complete = false;
        }
    }
    
    function max(int a , int b) public pure returns (int){
        if(a>b)
            return a;
        else
            return b;
    }
    function min(int a , int b) public pure returns (int){
        if(a>b)
            return b;
        else
            return a;
    }
}