// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract ReentrancyGuard {
    bool private _nonReentrant;
    constructor() { _nonReentrant = false; }
    modifier nonReentrant() {
        require(!_nonReentrant, "ReentrancyGuard: reentrant call");
        _nonReentrant = true;
        _;
        _nonReentrant = false;
    }
}

contract Crowdfunding is ReentrancyGuard {
    struct Campaign {
        address creator;
        string title;
        string description;
        uint256 goal;
        uint256 raised;
        uint256 deadline;
        bool released;
        bool refunding;
        uint256 backerCount;
    }

    Campaign[] public campaigns;
    mapping(uint256 => mapping(address => uint256)) public backed;
    mapping(uint256 => mapping(address => bool)) public refundedOf;

    event CampaignCreated(uint256 indexed cid, address indexed creator, string title, uint256 goal, uint256 deadline);
    event Pledged(uint256 indexed cid, address indexed backer, uint256 amount);
    event Released(uint256 indexed cid, address indexed creator, uint256 amount);
    event Refunded(uint256 indexed cid, address indexed backer, uint256 amount);

    function createCampaign(string calldata title, string calldata description, uint256 goal, uint256 durationSeconds) external returns (uint256) {
        require(goal > 0, "Zero goal");
        require(durationSeconds > 0, "Zero duration");
        Campaign storage c = campaigns.push();
        c.creator = msg.sender;
        c.title = title;
        c.description = description;
        c.goal = goal;
        c.deadline = block.timestamp + durationSeconds;
        uint256 cid = campaigns.length - 1;
        emit CampaignCreated(cid, msg.sender, title, goal, c.deadline);
        return cid;
    }

    function pledge(uint256 cid) external payable nonReentrant {
        Campaign storage c = campaigns[cid];
        require(!c.released && !c.refunding, "Campaign closed");
        require(msg.value > 0, "Zero pledge");
        // FIX: pledges must close at deadline — the old `|| raised < goal` arm let
        // users pledge into failed campaigns forever, poisoning the refund state.
        require(block.timestamp < c.deadline, "Deadline passed");
        if (backed[cid][msg.sender] == 0) c.backerCount += 1;
        backed[cid][msg.sender] += msg.value;
        c.raised += msg.value;
        emit Pledged(cid, msg.sender, msg.value);
    }

    function release(uint256 cid) external nonReentrant {
        Campaign storage c = campaigns[cid];
        require(msg.sender == c.creator, "Creator only");
        require(!c.released, "Already released");
        require(c.raised >= c.goal, "Goal not met");
        c.released = true;
        uint256 amount = c.raised;
        // FIX: call{value} instead of transfer (2300 gas cap); revert on failure.
        (bool ok, ) = payable(c.creator).call{value: amount}("");
        require(ok, "Release transfer failed");
        emit Released(cid, c.creator, amount);
    }

    function refund(uint256 cid) external nonReentrant {
        Campaign storage c = campaigns[cid];
        require(!c.released, "Campaign released");
        require(block.timestamp >= c.deadline, "Deadline not passed");
        require(c.raised < c.goal, "Goal met");
        require(!refundedOf[cid][msg.sender], "Already refunded");
        uint256 amount = backed[cid][msg.sender];
        require(amount > 0, "Nothing to refund");
        refundedOf[cid][msg.sender] = true;
        // FIX: call{value} instead of transfer.
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "Refund transfer failed");
        emit Refunded(cid, msg.sender, amount);
    }

    function campaignInfo(uint256 cid) external view returns (address creator, string memory title, uint256 goal, uint256 raised, uint256 deadline, bool released, uint256 backers) {
        Campaign storage c = campaigns[cid];
        return (c.creator, c.title, c.goal, c.raised, c.deadline, c.released, c.backerCount);
    }

    function campaignCount() external view returns (uint256) {
        return campaigns.length;
    }
}
