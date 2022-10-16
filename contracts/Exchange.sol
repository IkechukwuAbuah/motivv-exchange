// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol"; //imports out Token smart contract

contract Exchange {
    address public feeAccount; //account that receives exchange fees
    uint256 public feePercent; //% charge on transactions
    mapping (address => mapping(address => uint256)) public tokens;
    mapping (uint256 => _Order)public orders;
    uint256 public orderCount;
    //Orders mapping 

    event Deposit(
        address token, 
        address user, 
        uint256 amount, 
        uint256 balance);

    event Withdraw(
        address token, 
        address user, 
        uint256 amount,
        uint256 balance);

    event Order(
        uint256 id,        
        address user,   
        address tokenGet,
        uint amountGet, 
        address tokenGive,  
        uint amountGive, 
        uint256 timestamp);

    //A way to model the order
    struct _Order{
        //Attributes of an order
        uint256 id;         //Unique order identifier for order
        address user;       //User who made order
        address tokenGet;   //Address of the token they receive
        uint amountGet;     //Amount they receive
        address tokenGive;   //Address of token they give
        uint amountGive;    //Amount they give
        uint256 timestamp;  //When order was created
    }

    constructor (address _feeAccount, uint256 _feePercent){
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }
    //-------------------------
    //DEPOSIT & WITHDRAW TOKENS

    function depositToken(
        address _token, 
        uint256 _amount) 
        public{
        //Transfer tokens to exchange
       require(Token(_token).transferFrom(msg.sender,address(this), _amount)); //transferFrom was previously created and has 3 variables
        
        //Update Balance
        tokens[_token][msg.sender]=tokens[_token][msg.sender]+_amount;
      
        //Emit event
        emit Deposit(_token, msg.sender,_amount,tokens[_token][msg.sender]);
        

    }
    function withdrawToken(
        address _token, 
        uint256 _amount) 
        public{
        //Ensure user has enough tokens to withdraw
       require(tokens[_token][msg.sender]>=_amount); //must have more tokens than what they are trying to withdraw
        //Transfer tokens to the user
        Token(_token).transfer(msg.sender, _amount);
        
        //Update user balance
        tokens[_token][msg.sender]=tokens[_token][msg.sender]- _amount;

        //Emit event
        emit Withdraw(_token, msg.sender,_amount,tokens[_token][msg.sender]);
    }

    //Check Balances
    function balanceOf(
        address _token, 
        address _user)
    public
    view
    returns(uint256){
        return tokens[_token][_user];
    }

    //-------------------------------
    //MAKE & CANCEL ORDERS

    function makeOrder(
        address _tokenGet, 
        uint256 _amountGet, 
        address _tokenGive, 
        uint256 _amountGive) 
        public {
            //Require Token Balance - prevent orders if tokens arent on exchange
            require(balanceOf(_tokenGive,msg.sender)>=_amountGive);


            //Istatiate ORDER
            orderCount = orderCount + 1;

            //Token Give (the token they want to sepend) - which token and how much?
            //Token Get (the token they want to receive) - which token and how much?
           orders[orderCount]= _Order(
                orderCount, //id - counts everytime there is a new order
                msg.sender, //user
                _tokenGet, //tokenGet
                _amountGet, //amountGet
                _tokenGive, //tokenGive
                _amountGive, //amountGive
                block.timestamp //epoch time - current time
            );

            //Emit Event
            emit Order(
                orderCount, 
                msg.sender,
                _tokenGet,
                _amountGet,
                _tokenGive,
                _amountGive,
                block.timestamp); 
        }        
}
