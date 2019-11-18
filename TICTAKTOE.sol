  
pragma solidity 0.4.25;

contract Dice {
    address public player1;
    address public player2;
    uint256 public player1Escrow;
    uint256 public player2Escrow;

    uint256 public player1Balance;
    uint256 public player2Balance;
    bool public isPlayer1Setup;
    bool public isPlayer2Setup;
    uint256 public player1FinalBalance;
    uint256 public player2FinalBalance;
    uint256 public Game_Bet;
    uint256 public no_of_rounds;
    


    constructor () public payable {
        require(msg.value > 0);
        player1 = msg.sender;
        player1Escrow = msg.value;
        player1Status="Undefined"
    }

    function setupPlayer2() public payable {
        require(msg.value > 0);
        player2 = msg.sender;
        player2Escrow = msg.value;
        player2Status="undefined"
    }
    function sendInvite(bytes playerMessage,uint256 n_rounds,uint256 bet,uint256 playerBalance,uint256 playerNonce, uint256 playerSequence, address addressOfMessage) public {
        require(playerMessage.length == 65, '#2 The length of the message is invalid');
        require(addressOfMessage == player1 , '#3 You must use a valid address of player1');
        require(playerBalance>=bet*n_rounds, '#4 Appropriate balance should be there');
        uint256 escrowToUse = player1Escrow;

        // Recreate the signed message for the first player to verify that the parameters are correct
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(playerNonce, playerCall, playerBet, playerBalance, playerSequence))));
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(playerMessage, 32))
            s := mload(add(playerMessage, 64))
            v := byte(0, mload(add(playerMessage, 96)))
        }

        address originalSigner = ecrecover(message, v, r, s);
        require(originalSigner == addressOfMessage, '#4 The signer must be the original address');
        no_of_rounds=n_rounds;
        Game_bet=bet;
        player1Balance=playerBalance;
        isPlayer1Setup=true;


    
    }
    function acceptInvite(bytes playerMessage,uint256 playerBalance,uint256 playerNonce, uint256 playerSequence, address addressOfMessage) public {
        require(playerMessage.length == 65, '#2 The length of the message is invalid');
        require(addressOfMessage == player2 , '#3 You must use a valid address of player1');
        require(playerBalance>=Game_bet*n_rounds, '#4 Appropriate balance should be there');
        require(isPlayer1Setup==true,'#4 Is invite sent by player 1 or not?');

        // Recreate the signed message for the first player to verify that the parameters are correct
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(playerNonce, playerCall, playerBet, playerBalance, playerSequence))));
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(playerMessage, 32))
            s := mload(add(playerMessage, 64))
            v := byte(0, mload(add(playerMessage, 96)))
        }

        address originalSigner = ecrecover(message, v, r, s);
        require(originalSigner == addressOfMessage, '#4 The signer must be the original address');
        player2Balance=playerBalance;
        isPlayer2setup=true;






    }
    /// @notice To verify and save the player balance to distribute it later when the game is completed. The addressOfMessage is important to decide which balance is being updated
    function verifyPlayerBalance(bytes playerMessage,string result,bool gameRunningStatus uint256 playerNonce, uint256 playerSequence, address addressOfMessage) public {
        require(player2 != address(0), '#1 The address of the player is invalid');
        require(playerMessage.length == 65, '#2 The length of the message is invalid');
        require(addressOfMessage == player1 || addressOfMessage == player2, '#3 You must use a valid address of one of the players');
        require(isPlayer1Setup==true && isPlayer2Setup==true,'#4 game has started')

        // Recreate the signed message for the first player to verify that the parameters are correct
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(playerNonce, playerCall, playerBet, playerBalance, playerSequence))));
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(playerMessage, 32))
            s := mload(add(playerMessage, 64))
            v := byte(0, mload(add(playerMessage, 96)))
        }

        address originalSigner = ecrecover(message, v, r, s);
        require(originalSigner == addressOfMessage, '#4 The signer must be the original address');


        if(result=="Player1"){
            player1FinalBalance=player1Balance+Game_bet;
            player2FinalBalance=player2Balance-Game_bet;
        }
        else if(result=="Player2"){
            player1FinalBalance=player1Balance-Game_bet;
            player2FinalBalance=player2Balance+Game_bet;
        }
        no_of_rounds--;
        if(no_of_rounds==0||gameRunningStatus==false){
            player1.transfer(player1FinalBalance);
            player2.transfer(player2FinalBalance);
        }
    }

}


