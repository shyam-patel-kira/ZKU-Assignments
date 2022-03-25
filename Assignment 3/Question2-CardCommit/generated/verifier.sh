cp CardCommit_js/witness.wtns .

echo "<===============Generating Proof==================>\n \n"
snarkjs groth16 prove CardCommit_0001.zkey witness.wtns proof.json public.json

echo "<===============Verifying Proof==================>\n \n"
snarkjs groth16 verify verification_key.json public.json proof.json

# for generating a smart contract to verify the proof
echo "<===============Generating Smart Contract==================>\n \n"
snarkjs zkey export solidityverifier CardCommit_0001.zkey verifier.sol
echo "<===============Smart Contract Generated==================>\n \n"

# for generating valid params to verify through smart Contract
echo "<===============Generating Parameters==================>\n \n"
snarkjs generatecall
echo "<===============Parameters Generated==================>\n \n"

### params

## ["0x010f2e55e856ada50f8f941442fee95dff6ab9f8d6c71a644e749a5800f3fd15", "0x11951df25cdb12ecff302c64751462722040fec19bba82806db1337ff0001967"],[["0x19acb47a9b79dd3678143a0d117c339d030e1fdd3c7302b4d8d441ab6232660e", "0x27c42ade867f845919d1cc93f76c7b75bc62bb640990ff2ec7777a4f8ca952c9"],["0x11c587ee469db9857e6bffd796723295a37f2bc9da464dfa55c7033aa23b8048", "0x052baad4d317520118e98de1b70a6de4a36c9e7c468438fa790fc7aa6a67c475"]],["0x1441334aaa2ce44be2e05ae5bc1ccc154052fac5febed0ccbfab09e28dce3df3", "0x254c824d69a465c0c1adf7bdf75b8f0ed8c8d0d3623ceee194394309cdd5fa14"],["0x0e6561198eddabf00e65880181a4fcbbc317920cfad8a85a335d31c15facf47c","0x0000000000000000000000000000000000000000000000000000000000000003"]