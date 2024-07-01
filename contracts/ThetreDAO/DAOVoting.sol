// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "zk-merkle-tree/contracts/ZKTree.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DAOVoting is ZKTree, ReentrancyGuard {
    address public owner;
    mapping(address => bool) public validators;
    mapping(uint256 => bool) uniqueHashes;
    uint public numOptions;
    mapping(uint => uint) public optionCounter;
    IERC20 public thetreVoteToken;
    uint256 public votingEnd;

    struct Voter {
        uint256 tokensUsed;
        bool hasVoted;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier votingOpen() {
        require(block.timestamp <= votingEnd, "Voting period has ended");
        _;
    }

    constructor(
        uint32 _levels,
        IHasher _hasher,
        IVerifier _verifier,
        uint _numOptions,
        address _thetreVoteToken
    ) ZKTree(_levels, _hasher, _verifier) {
        owner = msg.sender;
        numOptions = _numOptions;
        thetreVoteToken = IERC20(_thetreVoteToken);
    }

    function registerValidator(address _validator) external onlyOwner {
        validators[_validator] = true;
    }

    function startVotingPeriod(uint256 _duration) external onlyOwner {
        require(votingEnd == 0, "Voting period has already started");
        votingEnd = block.timestamp + _duration;
    }

    function registerCommitment(
        uint256 _uniqueHash,
        uint256 _commitment
    ) external {
        require(validators[msg.sender], "Only validator can commit!");
        require(!uniqueHashes[_uniqueHash], "This unique hash is already used!");
        _commit(bytes32(_commitment));
        uniqueHashes[_uniqueHash] = true;
    }

    function voteWithTokens(
        uint _option,
        uint256 _nullifier,
        uint256 _root,
        uint[2] memory _proof_a,
        uint[2][2] memory _proof_b,
        uint[2] memory _proof_c,
        uint256 _tokensToUse
    ) external nonReentrant votingOpen {
        require(_option <= numOptions, "Invalid option!");
        require(thetreVoteToken.balanceOf(msg.sender) >= _tokensToUse, "Insufficient tokens");
        
        thetreVoteToken.transferFrom(msg.sender, address(this), _tokensToUse);

        _nullify(
            bytes32(_nullifier),
            bytes32(_root),
            _proof_a,
            _proof_b,
            _proof_c
        );
        
        optionCounter[_option] += _tokensToUse;
    }

    function endVoting() external onlyOwner {
        require(block.timestamp > votingEnd, "Voting period has not ended yet");

        // Implement logic to select DAO members based on votes
        for (uint i = 1; i <= numOptions; i++) {
            uint256 votes = optionCounter[i];
            // Logic to select DAO members based on votes can be implemented here
            // For example, storing winners or executing another action based on votes
            // Resetting vote counts or performing other cleanup tasks
        }

        // Reset voting state
        votingEnd = 0;
    }

    function getOptionCounter(uint _option) external view returns (uint) {
        return optionCounter[_option];
    }
}
