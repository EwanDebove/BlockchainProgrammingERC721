pragma solidity ^0.4.24;

import "./token/ERC721/IERC721.sol";
import "./token/ERC721/IERC721Receiver.sol";
import "./math/SafeMath.sol";
import "./utils/Address.sol";
import "./introspection/ERC165.sol";

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract MarxCoin is ERC165, IERC721 {

  using SafeMath for uint256;
  using Address for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
  // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

  // Mapping from token ID to owner
  mapping (uint256 => address) private _tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) private _tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) private _ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) private _operatorApprovals;

  bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
  /*
   * 0x80ac58cd ===
   *   bytes4(keccak256('balanceOf(address)')) ^
   *   bytes4(keccak256('ownerOf(uint256)')) ^
   *   bytes4(keccak256('approve(address,uint256)')) ^
   *   bytes4(keccak256('getApproved(uint256)')) ^
   *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^
   *   bytes4(keccak256('isApprovedForAll(address,address)')) ^
   *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
   */
  mapping (address => bool) Komandarm;
  address[] komandarmsAccs;
  address public Stalin;
  address public Arena;
  struct citizen{
    address owner;
    string name;
    bool isMale;
    uint256 age;
    uint256 strength;
    uint256 hunger;
    uint declarationDate;
    }
  struct Offer{
    address sender;
    address recipient;
    uint256 senderCitID;
    uint256 recipientCitID;
    bool fightOrBreed; //true == fight ; false == breed;

  }
  struct inbox{
    address owner;
    mapping (uint256 => Offer) offers;
    uint256[] offersID;
  }
  mapping (address => inbox) postOffice;

  mapping (uint256 => citizen) public Komrads;
  uint256[] ids;
  uint256[] pi = [3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,0,2,8,8,4,0,1,9,7,1,6,9,3,9,9,3,7,5,1,0];
  uint256 count;

  string Breed = "Breed";
  string Fight = "Fight";

  event result(address owner, uint256 Id);

  constructor()
    public
  {
    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(_InterfaceId_ERC721);
    Stalin = msg.sender;
    count = 0;
    addKomandarm(Stalin);
    declareCitizen("Dimitri", true, 38, 40, 0);
    declareCitizen("Svetlana", false, 38, 40, 0);
  }

  /**
   * @dev Gets the balance of the specified address
   * @param owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address owner) public view returns (uint256) {
    require(owner != address(0));
    return _ownedTokensCount[owner];
  }

  function viewCitizens(address owner) public view returns (uint256[]){
    uint256[] citizens;
    for (uint256 i = 0 ; i < ids.length ; i++){
      if(Komrads[ids[i]].owner == owner){
        citizens.push(ids[i]);
      }
    }
    return citizens;

  }

  /**
   * @dev Gets the owner of the specified token ID
   * @param tokenId uint256 ID of the token to query the owner of
   * @return owner address currently marked as the owner of the given token ID
   */
  function ownerOf(uint256 tokenId) public view returns (address) {
    address owner = _tokenOwner[tokenId];
    require(owner != address(0));
    return owner;
  }

  /**
   * @dev Approves another address to transfer the given token ID
   * The zero address indicates there is no approved address.
   * There can only be one approved address per token at a given time.
   * Can only be called by the token owner or an approved operator.
   * @param to address to be approved for the given token ID
   * @param tokenId uint256 ID of the token to be approved
   */
  function approve(address to, uint256 tokenId) public {
    address owner = ownerOf(tokenId);
    require(to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * Reverts if the token ID does not exist.
   * @param tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for the given token ID
   */
  function getApproved(uint256 tokenId) public view returns (address) {
    require(_exists(tokenId));
    return _tokenApprovals[tokenId];
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * An operator is allowed to transfer all tokens of the sender on their behalf
   * @param to operator address to set the approval
   * @param approved representing the status of the approval to be set
   */
  function setApprovalForAll(address to, bool approved) public {
    require(to != msg.sender);
    _operatorApprovals[msg.sender][to] = approved;
    emit ApprovalForAll(msg.sender, to, approved);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param owner owner address which you want to query the approval of
   * @param operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(
    address owner,
    address operator
  )
    public
    view
    returns (bool)
  {
    return _operatorApprovals[owner][operator];
  }

  /**
   * @dev Transfers the ownership of a given token ID to another address
   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * Requires the msg sender to be the owner, approved, or operator
   * @param from current owner of the token
   * @param to address to receive the ownership of the given token ID
   * @param tokenId uint256 ID of the token to be transferred
  */
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  )
    public
  {
    require(_isApprovedOrOwner(msg.sender, tokenId));
    require(to != address(0));

    _clearApproval(from, tokenId);
    _removeTokenFrom(from, tokenId);
    _addTokenTo(to, tokenId);

    emit Transfer(from, to, tokenId);
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   *
   * Requires the msg sender to be the owner, approved, or operator
   * @param from current owner of the token
   * @param to address to receive the ownership of the given token ID
   * @param tokenId uint256 ID of the token to be transferred
  */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  )
    public
  {
    // solium-disable-next-line arg-overflow
    safeTransferFrom(from, to, tokenId, "");
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   * Requires the msg sender to be the owner, approved, or operator
   * @param from current owner of the token
   * @param to address to receive the ownership of the given token ID
   * @param tokenId uint256 ID of the token to be transferred
   * @param _data bytes data to send along with a safe transfer check
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes _data
  )
    public
  {
    transferFrom(from, to, tokenId);
    // solium-disable-next-line arg-overflow
    require(_checkOnERC721Received(from, to, tokenId, _data));
  }

  /**
   * @dev Returns whether the specified token exists
   * @param tokenId uint256 ID of the token to query the existence of
   * @return whether the token exists
   */
  function _exists(uint256 tokenId) internal view returns (bool) {
    address owner = _tokenOwner[tokenId];
    return owner != address(0);
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param spender address of the spender to query
   * @param tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function _isApprovedOrOwner(
    address spender,
    uint256 tokenId
  )
    internal
    view
    returns (bool)
  {
    address owner = ownerOf(tokenId);
    // Disable solium check because of
    // https://github.com/duaraghav8/Solium/issues/175
    // solium-disable-next-line operator-whitespace
    return (
      spender == owner ||
      getApproved(tokenId) == spender ||
      isApprovedForAll(owner, spender)
    );
  }

  /**
   * @dev Internal function to mint a new token
   * Reverts if the given token ID already exists
   * @param to The address that will own the minted token
   * @param tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address to, uint256 tokenId) internal {
    require(to != address(0));
    _addTokenTo(to, tokenId);
    emit Transfer(address(0), to, tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address owner, uint256 tokenId) internal {
    _clearApproval(owner, tokenId);
    _removeTokenFrom(owner, tokenId);
    emit Transfer(owner, address(0), tokenId);
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * Note that this function is left internal to make ERC721Enumerable possible, but is not
   * intended to be called by custom derived contracts: in particular, it emits no Transfer event.
   * @param to address representing the new owner of the given token ID
   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function _addTokenTo(address to, uint256 tokenId) internal {
    require(_tokenOwner[tokenId] == address(0));
    _tokenOwner[tokenId] = to;
    _ownedTokensCount[to] = _ownedTokensCount[to].add(1);
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * Note that this function is left internal to make ERC721Enumerable possible, but is not
   * intended to be called by custom derived contracts: in particular, it emits no Transfer event,
   * and doesn't clear approvals.
   * @param from address representing the previous owner of the given token ID
   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function _removeTokenFrom(address from, uint256 tokenId) internal {
    require(ownerOf(tokenId) == from);
    _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
    _tokenOwner[tokenId] = address(0);
  }

  /**
   * @dev Internal function to invoke `onERC721Received` on a target address
   * The call is not executed if the target address is not a contract
   * @param from address representing the previous owner of the given token ID
   * @param to target address that will receive the tokens
   * @param tokenId uint256 ID of the token to be transferred
   * @param _data bytes optional data to send along with the call
   * @return whether the call correctly returned the expected magic value
   */
  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!to.isContract()) {
      return true;
    }
    bytes4 retval = IERC721Receiver(to).onERC721Received(
      msg.sender, from, tokenId, _data);
    return (retval == _ERC721_RECEIVED);
  }

  /**
   * @dev Private function to clear current approval of a given token ID
   * Reverts if the given address is not indeed the owner of the token
   * @param owner owner of the token
   * @param tokenId uint256 ID of the token to be transferred
   */
  function _clearApproval(address owner, uint256 tokenId) private {
    require(ownerOf(tokenId) == owner);
    if (_tokenApprovals[tokenId] != address(0)) {
      _tokenApprovals[tokenId] = address(0);
    }
  }

  //takes a number from the 50 first decimals of pi
  //not true random, can easily be predicted if you count the transactions
  function fakeRand() internal returns(uint256){
    if (count==51){
      count=0;
    }
    return pi[count];
  }
  //Declare a new Komandarm to monitor the actions of the citizens of the motherland
  function addKomandarm(address _new) public returns (bool success){
        require(msg.sender == Stalin);
        Komandarm[_new] = true;
        komandarmsAccs.push(_new);
        return true;
  }

  function declareCitizen(string _name, bool _isMale, uint256 _age, uint256 _strength, uint256 _hunger) public returns (bool success){
    require(Komandarm[msg.sender] == true);
    uint256 id = ids.length;
    _tokenOwner[id] = msg.sender;
    ids.push(id);
    citizen newCitizen = Komrads[id];
    newCitizen.owner = msg.sender;
    newCitizen.name = _name;
    newCitizen.isMale = _isMale;
    newCitizen.age = _age;
    newCitizen.strength = _strength;
    newCitizen.hunger = _hunger;
    newCitizen.declarationDate = block.timestamp;
    result(msg.sender, id);
    return true;
  }
  function death(uint256 _id) public returns (bool success){
    require(msg.sender==ownerOf(_id));
    _burn(ownerOf(_id),_id);
    return true;

  }


  function babyProletarian(uint256 _id1,uint256 _id2,string _name)  private {
    uint256 id = ids.length;
    ids.push(id);
    citizen newCitizen = Komrads[id];
    newCitizen.owner = ownerOf(_id2);
    _tokenOwner[id] = ownerOf(_id2);
    newCitizen.name = _name;
    if(fakeRand()>4){
      newCitizen.isMale = true;
    }
    else{
      newCitizen.isMale = false;
    }
    newCitizen.age = 0;
    newCitizen.strength = fakeRand() * 10 + fakeRand();
    newCitizen.hunger = newCitizen.strength - newCitizen.age ;
    newCitizen.declarationDate = block.timestamp;
    result(newCitizen.owner, id);
  }

  function reproduce(uint256 _id1, uint256 _id2, string _name1, string _name2)public {
    babyProletarian(_id1,_id2,_name2);
    babyProletarian(_id2,_id1,_name1);

  }

   function spawn(string _name, address _owner)  public returns (uint256 babyId){
    uint256 id = ids.length;
    ids.push(id);
    citizen newCitizen = Komrads[id];
    newCitizen.owner = _owner;
    newCitizen.name = _name;
    if(fakeRand()>4){
      newCitizen.isMale = true;
    }
    else{
      newCitizen.isMale = false;
    }
    newCitizen.age = fakeRand() * (fakeRand() + 1);
    newCitizen.strength = fakeRand() * 10 + fakeRand();
    newCitizen.hunger = newCitizen.strength - newCitizen.age ;
    newCitizen.declarationDate = block.timestamp;
    return id;
  }

  function aging(uint256 _id) internal returns (bool success){
    citizen citizenToUpdate = Komrads[_id];
    citizenToUpdate.age = now - citizenToUpdate.declarationDate;
    if(citizenToUpdate.age > 80 * 252455616){//80 years in seconds
      if(citizenToUpdate.age >= 90 * 252455616){
        _burn(ownerOf(_id),_id);
        return false;
      }
      else{
        if(fakeRand() < (citizenToUpdate.age - 80 * 252455616)){
          _burn(ownerOf(_id),_id);
          return false;
        }
      }
    }
    else{
          return true;
    }
  }
  function update(uint256 _id)public returns (bool success){
    return aging(_id);
  }

  function viewStats(uint256 _id)public view returns(bool success, string name, uint256 age, bool isMale, uint256 strength, uint256 hunger){
    return(true , Komrads[_id].name , Komrads[_id].age , Komrads[_id].isMale , Komrads[_id].strength , Komrads[_id].hunger);
  }

  function viewInbox() public view returns (uint256[] _offers) {
    
    return 
    postOffice[msg.sender].offersID;
    
  }

  function viewOffer(uint256 _offerID) public view returns (address _sender, uint256 _theirChamp, uint256 _myChamp, string fightOrBreed){
    string _fightOrBreed = Breed;
    if(postOffice[msg.sender].offers[_offerID].fightOrBreed == true){
      _fightOrBreed = Fight;
    }
    return (postOffice[msg.sender].offers[_offerID].sender, postOffice[msg.sender].offers[_offerID].senderCitID, postOffice[msg.sender].offers[_offerID].recipientCitID, _fightOrBreed);

  }




  function proposeFight(address _adversary, uint256 _myChamp, uint256 _theirChamp) public {
    require(Komrads[_myChamp].owner == msg.sender);
    require(Komrads[_theirChamp].owner == _adversary);

    Offer newOffer = postOffice[_adversary].offers[postOffice[_adversary].offersID.length];
    postOffice[_adversary].offersID.push(postOffice[_adversary].offersID.length);
    
    aging(_myChamp);
    aging(_theirChamp);


    newOffer.sender = msg.sender;
    newOffer.recipient = _adversary;
    newOffer.senderCitID = _myChamp;
    newOffer.recipientCitID = _theirChamp;
    newOffer.fightOrBreed = true  ;

  }

  function proposeBreed(address _adversary, uint256 _myChamp, uint256 _theirChamp) public {
    require(Komrads[_myChamp].owner == msg.sender);
    require(Komrads[_theirChamp].owner == _adversary);
    require(Komrads[_myChamp].isMale != Komrads[_theirChamp].isMale);

    Offer newOffer = postOffice[_adversary].offers[postOffice[_adversary].offersID.length];
    postOffice[_adversary].offersID.push(postOffice[_adversary].offersID.length);

    aging(_myChamp);
    aging(_theirChamp);

    newOffer.sender = msg.sender;
    newOffer.recipient = _adversary;
    newOffer.senderCitID = _myChamp;
    newOffer.recipientCitID = _theirChamp;
    newOffer.fightOrBreed = false ;

  }

  function acceptFight(uint256 _offerId) public {
    require(postOffice [msg.sender].offers[_offerId].fightOrBreed == true)
    uint256 win = fight(postOffice[msg.sender].offers[_offerId].senderCitID, postOffice[msg.sender].offers[_offerId].recipientCitID);
    result(ownerOf(win), win);
      
  }
  function acceptBreed(uint256 _offerId, string _name1, string _name2) public {
    require (postOffice [msg.sender].offers[_offerId].fightOrBreed == false);
    reproduce(postOffice[msg.sender].offers[_offerId].senderCitID, postOffice[msg.sender].offers[_offerId].recipientCitID, _name1, _name2);
  }

  function fight(uint256 _id1, uint256 _id2) private returns(uint256 _idWinner){
    if(Komrads[_id1].strength * fakeRand() > Komrads[_id2].strength * fakeRand()){
      return _id1;
    }
    else{
      return _id2;
    }
  }

}