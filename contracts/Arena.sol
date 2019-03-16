pragma solidity ^0.4.24;

import "./MarxCoin.sol";


contract Arena is ERC165, IERC721{
	using SafeMath for uint256;
	using Address for address;


	mapping public (uint256 => address) fightersOwner;

	uint256[] public fighters;

	function receive(){}

	function herosReturn(){}

	function fakeRand() internal returns(uint256){
    if (count==51){
      count=0;
    }
    return pi[count];
  }
	 function fight(uint256 _id1, uint256 _id2) internal returns (uint256 _winnerId){
	 	//return fakeRand();
	 }
}