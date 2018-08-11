pragma solidity ^0.4.17;

//List of NGOs
import "meraNGO.sol";

contract NGOs {

    address[] public onboardedNGOs;
    //to create a new Campaign by providing address and minimimum contribution
    function onboardNGO (uint minimimum) public{
        address newNGO = new NGO(minimimum, msg.sender);
        onboardedNGOs.push(newNGO);
    } 
    function getOnBoardedNGOs () public view returns(address[]) {
        return onboardedNGOs;
    }     
}