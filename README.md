# TictacToe-using-solidity
A basic two player command line tic tac toe game backend in node js with ethereum based payment state channel.
APPPROCH:
In this program, firstly player1  request palyer2 to join the game.
Then player1 sent invitation to player2 and function sendInvite() is called. In sendInvite() function, player1 set the bet amount, stores it in Game_bet variable and set the no. of rounds, stores it in no_of_rounds variable.
Then acceptInvite() function called and player2 accept the invitation.
At each round of the game, winner player get rewarded and balance is updated locally.
As all the round finishes(no_of_rounds==0) or any player leave the game(gameRunningStatus==false)the balance in wallet of each player get updated.
