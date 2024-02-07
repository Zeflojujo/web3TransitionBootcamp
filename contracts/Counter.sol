//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

contract Counter {
    address owner;

    struct Count {
        uint number;
        string description;
    }

    Count count;

    modifier onlyOnwer {
        require( msg.sender == owner, "Only the owner can increment or decrement the counter");
        _;
    }

    constructor(uint initial_value, string memory _description) {
        owner = msg.sender;
        count = Count(initial_value, _description);
    }

    function increment_counter_value() external {
        count.number += 1;
    }

    function decrement_counter_value() external {
        count.number -= 1;
    }

    function get_number_value() external view returns(uint){
        return count.number;
    }

    function get_description_value() external view returns( string memory ) {
        return count.description;
    }

}