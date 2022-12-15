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
    mapping(uint256 => bool) public orderCancelled; // boolean -  true or false 
    mapping(uint256 => bool) public orderFilled; // boolean -  true or false whether the order has been filled

    //Orders mapping 

    event Deposit(
        address token, 
        address user, 
        uint256 amount, 
        uint256 balance
    );

    event Withdraw(
        address token, 
        address user, 
        uint256 amount,
        uint256 balance
    );

    event Order(
        uint256 id,        
        address user,   
        address tokenGet,
        uint amountGet, 
        address tokenGive,  
        uint amountGive, 
        uint256 timestamp
    );

    event Cancel(
        uint256 id,        
        address user,   
        address tokenGet,
        uint amountGet, 
        address tokenGive,  
        uint amountGive, 
        uint256 timestamp
    );

    event Trade(
        uint256 id,
        address user,   
        address tokenGet,
        uint amountGet, 
        address tokenGive,  
        uint amountGive, 
        address creator,
        uint256 timestamp
    );

    
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


            //Instatiate ORDER
            orderCount++;

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
                block.timestamp
            ); 
        }        

        function cancelOrder(uint256 _id) 
        public {
            //Fetch order
            _Order storage _order = orders[_id];

            
             //Order must exist
            require(_order.id == _id);

            //Ensure the caller of the function is the owner of the order
           require(address(_order.user)==msg.sender);
            
            //Cancel order
            orderCancelled[_id] = true;

             //Emit Event
            emit Cancel(
                orderCount, 
                msg.sender,
                _order.tokenGet,
                _order.amountGet,
                _order.tokenGive,
                _order.amountGive,
                block.timestamp
            );
        }
    //-----------------------------------------
    //EXECUTING ORDERS
    function fillOrder(uint256 _id) public {

    //1. Mustbe valid orderID
    require(_id>0 && _id <=orderCount, "Order does not exist");
    //2. Order can't be filled
    require(!orderFilled[_id]);
    //3. Order can't be cancelled
    require(!orderCancelled[_id]);
    //Fetch Order from Storage
    _Order storage _order = orders[_id];

    //Execute trades
    _trade(
        _order.id, 
        _order.user,
        _order.tokenGet,
        _order.amountGet,
        _order.tokenGive,
        _order.amountGive
        );

    //Mark Order as Filled
    orderFilled[_order.id] = true;


    }

    //Trading/Swapping Tokens
    function _trade(
        uint256 _orderId, 
        address _user, //Order's user i.e the person filling the order
        address _tokenGet,
        uint256 _amountGet,
        address _tokenGive,
        uint256 _amountGive
        ) internal{

            //Fee is paid by the user who filled the order (msg.sender)
            //Fee is deducted from _amountGet
            uint256 _feeAmount = (_amountGet * feePercent) /100;

            //Trades happen here
            //msg.sender filled the order, _user created the order
            tokens[_tokenGet][msg.sender]=tokens[_tokenGet][msg.sender] - (_amountGet + _feeAmount); //reduce tokenget from msg.sender's tokens
            tokens[_tokenGet][_user]= tokens[_tokenGet][_user]+_amountGet; //add tokenget deducted from msg.sender to _user's tokens

            //Charge Fees
            tokens[_tokenGet][feeAccount] = tokens[_tokenGet][feeAccount] + _feeAmount;

            //Token Giving

            tokens[_tokenGive][_user]= tokens[_tokenGive][_user] - _amountGive;
            tokens[_tokenGive][msg.sender] = tokens[_tokenGive][msg.sender] + _amountGive;

            //Emit trade Event
            emit Trade(
                _orderId,
                msg.sender, //user
                _tokenGet,
                _amountGet,
                _tokenGive,
                _amountGive,
                _user, //creator
                block.timestamp
            );
    }

}   


