// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {ThetreTicket} from "./ThetreTicket.sol";

contract Thetre {
    event MovieListed(string movieName, address ticketAddress);
    event BoughtTicket(string movieName, address indexed buyer);

    mapping(string => address) public movieTicket;
    mapping(string => string) public movieVideos;
    mapping(address => uint256) private subscriptions;
    mapping(address => uint256) private discountTickets;

    TimelockController private timelock;
    address private owner;
    uint256 private ticketPrice;
    uint256 private subscriptionPrice;
    uint256 private subscriptionDuration;

    constructor (TimelockController _timelock, uint256 _subscriptionDuration) {
        timelock = _timelock;
        owner = msg.sender;
        subscriptionDuration = _subscriptionDuration;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function listMovie(string memory _movieName, string memory baseTokenURI) public onlyOwner {
        require(movieTicket[_movieName] == address(0), "Movie already listed");
        require(msg.sender == address(timelock) || msg.sender == owner, "Not authorized");
        
        ThetreTicket newTicket = new ThetreTicket();
        newTicket.initialize("Thetre Movie Token", "TMT", baseTokenURI, address(this));
        movieTicket[_movieName] = address(newTicket);

        emit MovieListed(_movieName, address(newTicket));
    }

    function buyTicket(string memory _movieName) public payable{
        require(movieTicket[_movieName] != address(0), "Movie Not listed");
        require(msg.value >= ticketPrice, "Insufficient funds");

        ThetreTicket ticketNFT = ThetreTicket(movieTicket[_movieName]);
        ticketNFT.mint(msg.sender);

        emit BoughtTicket(_movieName, msg.sender);
    }

    function buySubscription() public payable{
        require(msg.value >= subscriptionPrice, "Insufficient funds");
        subscriptions[msg.sender] = block.timestamp + subscriptionDuration;

        emit BoughtTicket("Subscription", msg.sender);
    }

    function buyDiscountedTicket(string memory _movieName, address discountNFT) public payable{
        require(movieTicket[_movieName] != address(0), "Movie Not listed");
        require(discountTickets[discountNFT] != 0, "No Discount");
        require(msg.value > ticketPrice, "Insufficient funds");
        require(ERC721(discountNFT).balanceOf(msg.sender) > 0, "No Discount NFT");

        ThetreTicket ticketNFT = ThetreTicket(movieTicket[_movieName]);
        ticketNFT.mint(msg.sender);
        (bool success, ) = payable(msg.sender). call{value: discountTickets[discountNFT]}("");
        require(success, "Cashback failed.");

        emit BoughtTicket(_movieName, msg.sender);
    }

    function setMovieVideo(string memory _movieName, string memory videoId) public onlyOwner {
        movieVideos[_movieName] = videoId;
    }

    function addDiscountTicket(address discountNFT, uint256 discount) public onlyOwner {
        discountTickets[discountNFT] = discount;
    }

    function setTicketPrice(uint256 _ticketPrice) public onlyOwner {
        ticketPrice = _ticketPrice;
    }

    function setSubscriptionPrice(uint256 _subscriptionPrice) public onlyOwner {
        subscriptionPrice = _subscriptionPrice;
    }

    function balanceOf(address _owner) public view virtual returns(uint256) {
        return subscriptions[_owner] > block.timestamp ? 1 : 0;
    }
}