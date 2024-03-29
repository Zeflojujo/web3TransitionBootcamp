//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ProposalContract {
    address owner;

    uint256 private counter; // Counter variable for tracking proposal ids

    struct Proposal {
        string description; // Description of the proposal
        string title; // Title of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
    }

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals
    address[] private voted_addresses;

    // constructor
     constructor() {
        owner = msg.sender;
        voted_addresses.push(msg.sender);
    }


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true, "The proposal is not active");
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has already voted");
        _;
    }


    // ****************** Execute Functions ***********************

    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    function calculateCurrentState() private view returns(bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;

        if( (pass % 2) == 1 ) {
            pass += 1;
        }

        pass /= 2;


        // Calculate the total votes (approve + reject + pass )
        uint256 totalVotes = approve + reject + pass;

        // Calculate the minimum required votes for the proposal to pass
        uint256 minimumVotesToPass = totalVotes / 2 + 1;


        // Check if the number of approvals plus pass votes is greater than or equal to the minimum required votes to pass
        if (approve + pass >= minimumVotesToPass) {
            return true; // Proposal passed
        } else {
            return false; // Proposal failed
        }


    }

    function create(string calldata _description, string calldata _title, uint256 _total_vote_to_end) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(_description, _title, 0, 0, 0, _total_vote_to_end, false, true);
    }

    function vote(uint8 choice) external active newVoter(msg.sender){
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if(choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if(choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        }
        else if(choice == 3) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        if((proposal.total_vote_to_end - total_vote == 1) && ( choice == 1 || choice == 2 || choice ==3 )) {
            proposal.is_active = false;
            voted_addresses = [owner];
        }
    }

}