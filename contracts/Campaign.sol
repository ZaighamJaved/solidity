// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.5;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint256 minimumContrib) public {
        address newCampaign = address(new Campaign(minimumContrib, msg.sender));
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        address payable recipient;
        uint256 value;
        bool isCompleted;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }

    address public manager;
    uint256 public minimumContribution;
    mapping(address => bool) public approvers;
    uint256 public approversCount;
    uint256 requestCount;
    mapping(uint256 => Request) public requests;

    modifier onlyManager() {
        require(msg.sender == manager, "Unauthorised");
        _;
    }

    constructor(uint256 minimumContrib, address capManager) {
        manager = capManager;
        minimumContribution = minimumContrib;
    }

    function contribute() public payable {
        require(
            msg.value >= minimumContribution,
            "value is less than minimum contribution"
        );
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(
        string memory description,
        address recipient,
        uint256 value
    ) public onlyManager {
        Request storage newRequest = requests[requestCount++];
        newRequest.description = description;
        newRequest.value = value;
        newRequest.recipient = payable(recipient);
        newRequest.isCompleted = false;
        newRequest.approvalCount = 0;
    }

    function approveRequest(uint256 requestNum) public {
        Request storage request = requests[requestNum];
        require(
            request.recipient != 0x0000000000000000000000000000000000000000,
            "Invalid request number"
        );
        require(approvers[msg.sender], "unauthorised");
        require(!request.isCompleted, "Already Completed");
        require(!request.approvals[msg.sender], "Already approved");
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 requestNum) public payable onlyManager {
        Request storage request = requests[requestNum];
        require(
            request.recipient != 0x0000000000000000000000000000000000000000,
            "Invalid request number"
        );
        require(!request.isCompleted, "Already Completed");
        require(
            request.approvalCount > (approversCount / 2),
            "more approvls required"
        );
        request.recipient.transfer(request.value);
        request.isCompleted = true;
    }
}
