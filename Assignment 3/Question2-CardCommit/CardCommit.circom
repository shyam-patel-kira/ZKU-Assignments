pragma circom 2.0.3;

include "./node_modules/circomlib/circuits/mimcsponge.circom";

/* 
 => This Template is meant to allow a player to commit their card 
    to a smart contract that stores your picked card.
 => The smart contract stores the salted hash of the card
    ( 0 => Ace ... 12 => King) and 
    the card's Suit as a public integer 
     0 => clubs
     1 => spades
     2 => hearts
     3 => diamonds
*/
template CardCommit() {
    signal input previousCardSuit;
    signal input card; // Number in range [0, 12]
    signal input cardSuit; // Number in range [0, 3]
    signal input salt; // salt Secret int254
    signal output outputs[2]; // output containing the hash for the card and the Suit.

    assert(previousCardSuit == cardSuit);
    component saltDigest = MiMCSponge(3, 220, 1);
    saltDigest.k <== 0;
    saltDigest.ins[0] <== card;
    saltDigest.ins[1] <== cardSuit;
    saltDigest.ins[2] <== salt;

    outputs[0] <== saltDigest.outs[0];
    outputs[1] <== cardSuit;
}

component main = CommitCard();