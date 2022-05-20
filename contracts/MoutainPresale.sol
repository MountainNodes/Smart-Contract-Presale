// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ARC20.sol";
import "./Pausable.sol";
import "./PaymentSplitter.sol";

contract PrivateSale is Ownable, ARC20, Pausable, PaymentSplitter {

  string _name = "aMountain";
  string _symbol = "aMTN";

  // Amount of wei raised
  uint256 public weiRaised;
  
  uint256 public _startTime;
  uint256 public _endTime;

  uint256 constant THREE_DAYS = 3*24*60*60;
  uint256 _vestingStartTimestamp = 0;

  uint256 public presaleDuration = 7*24*60*60; // One week

  // How many token units a buyer gets per AVAX
  uint256 public rate = 10;

  // The price for a package (in AVAX)
  uint256 public packagePrice = 1* 10 ** 18; // NOTE : For tests purposes

  // Total amount of aMTN that are available for the presale
  uint256 public presaleAmount = 1_000 * 10 ** 18;

  // For test purposes (testing PaymentSplitter)
  address[] _payees = [0x29Fd00FA40c90aec39AC604D875907874f237baA, 0xf235695A38Cd517eBB66C3af0217d68a192ed8b0];
  uint256[] _shares = [70,30];

  mapping(address => bool) _isWhitelisted;
  
  mapping (address => uint256) tokenHolders;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

 
  constructor()  ARC20(_name, _symbol) PaymentSplitter(_payees, _shares){

    // Note : the total amount of tokens is minted only once in the constructor
    _mint(address(this), presaleAmount);
  }


  fallback () external payable {
    buyTokens(_msgSender());
  }
  
  receive () external payable {
    buyTokens(_msgSender());
 }
    
  // Checks if the presale has started
  modifier hasStarted()
  {
      require(block.timestamp > _startTime, "Presale has not started yet");
      _;
  }
  
  // Checks if the presale has not ended
  modifier hasNotEnded()
  {
      require(block.timestamp < _endTime, "Presale has already finished");
      _;
  }
  
  // Checks that the SC still has tokens 
  modifier hasTokens()
  {
      require (balanceOf(address(this)) > 0 , "No tokens left");
      _;
  }

  // Checks that the SC has not been paused
  modifier isNotPaused()
  {
    require(!paused(), "token transfer while paused");
    _;
  }
  
  // Checks that vesting is over in order to withdraw the last 50% of tokens 
  modifier isVestingFinished()
  {
      require(_vestingStartTimestamp!=0, "Vesting timestamp has not been set yet");
      require(block.timestamp > (_vestingStartTimestamp + THREE_DAYS), "Vesting period is over");
      _;   
      
  }

  /**
   * @param startTime Unix timestamp that define the starting time of the presale
   */ 
  function setStartTime(uint256 startTime) public onlyOwner {
    _startTime = startTime;
    _endTime = startTime + presaleDuration;
  }


  /**
   * @param vestingStartTime Unix timestamp that define the starting time of the vesting phase
   */  
  function startVesting(uint256 vestingStartTime) public onlyOwner {
    _vestingStartTimestamp = vestingStartTime;      
  }

  /**
   * @dev This function is necessary in order to allow investors to purchase tokens
   * @param addresses All the addresses to be whitelisted
   */  
  // TODO : Need to optimize the for loop
  function addToWL(address[] memory addresses) public onlyOwner{
      for (uint8 i = 0; i<addresses.length; i++) {
        _isWhitelisted[addresses[i]] = true;
      }
  }
  
  
  /**
   * @dev low level token purchase 
   * @param _beneficiary The address of the investor
   */  
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;

    // Prevalidate the purchase before buying
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);
    uint256 _50Percent = tokens/2;

    // Half of the tokens is kept in the SC, mapped to the investor's address
    tokenHolders[_beneficiary] = _50Percent;

    // update state to track the total amount raised
    weiRaised = weiRaised+weiAmount;
    
    // Send half of the tokens to the investor 
    _deliverTokens(_beneficiary, _50Percent);

    // Emit an event to track all purchases
    emit TokenPurchase(msg.sender, _beneficiary, weiAmount, _50Percent);

  }

   /**
   * @dev With all the modifiers and requires, this function ensures buying tokens is allowed.
   *      Namely : The presale should be ongoing, there are still tokens in the SC, the SC is not paused,
   *.     The investor is whitelisted, and the amount is correct.
   * @param _beneficiary The address of the investor
   * @param _weiAmount The amount spent by the investor
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    view internal hasStarted hasNotEnded hasTokens isNotPaused
  {
    require(_beneficiary != address(0), "Buyer addess cannot be 0");
    require(_isWhitelisted[_beneficiary], "Buyer not whitelisted");
    require(_weiAmount==packagePrice, "Price not correct");
  }


  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal{
    _transfer(address(this), _beneficiary, _tokenAmount);
  }


  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256){
    return _weiAmount*rate;
  }

  /**
   * @dev Once the vesting is finished, investors can withdraw the 50% left of their tokens
   * @param withdrawer The address of the investor
   */
  function withdraw (address withdrawer) public isVestingFinished
  {
      require(withdrawer != address(0), "BEP20: Transfer to zero address");
      uint256 withdrawnAmount = tokenHolders[withdrawer];
      _deliverTokens(withdrawer, withdrawnAmount);
  }

  /**
   * @dev All unsold tokens can be sent to the owner of the contract, if not sold out
   */
  function sendTokensBack() public onlyOwner hasNotEnded
  {
    transferFrom(address(this), msg.sender, balanceOf(address(this)));
  }
}