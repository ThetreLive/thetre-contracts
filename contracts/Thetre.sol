// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {ThetreTicket} from "./ThetreTicket.sol";

contract Thetre {
    event MovieListed(string movieName, address ticketAddress);
    event BoughtTicket(string movieName, address indexed buyer);

    mapping(string => address) private movieTicket;
    mapping(address => uint256) private discountTickets;

    TimelockController private timelock;
    address private owner;
    uint256 private ticketPrice;

    constructor (TimelockController _timelock) {
        timelock = _timelock;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function listMovie(string memory _movieName, string memory baseTokenURI) public {
        require(movieTicket[_movieName] == address(0), "Movie already listed");
        require(msg.sender == address(timelock), "Only timelock can perform this action");
        ThetreTicket newTicket = new ThetreTicket();
        newTicket.initialize(_movieName, _movieName, baseTokenURI, address(this));
        movieTicket[_movieName] = address(newTicket);

        emit MovieListed(_movieName, address(newTicket));
    }

    function buyTicket(string memory _movieName, address discountNFT) public payable{
        require(movieTicket[_movieName] != address(0), "Movie Not listed");
        require(discountTickets[discountNFT] != 0, "No Discount");
        require(msg.value > ticketPrice, "Insufficient funds");
        ThetreTicket ticketNFT = ThetreTicket(movieTicket[_movieName]);
        ticketNFT.safeMint(block.timestamp + 365 days);
        (bool success, ) = payable(msg.sender). call{value: discountTickets[discountNFT]}("");
        require(success, "Cashback failed.");

        emit BoughtTicket(_movieName, msg.sender);
    }

    function addDiscountTicket(address discountNFT, uint256 discount) public onlyOwner {
        discountTickets[discountNFT] = discount;
    }

    function setTicketPrice(uint256 _ticketPrice) public onlyOwner {
        ticketPrice = _ticketPrice;
    }
}