cp triangleJumpVerifier_js/witness.wtns .

echo "<===============Generating Proof==================>\n \n"
snarkjs groth16 prove triangleJumpVerifier_0001.zkey witness.wtns proof.json public.json

echo "<===============Verifying Proof==================>\n \n"
snarkjs groth16 verify verification_key.json public.json proof.json

# for generating a smart contract to verify the proof
echo "<===============Generating Smart Contract==================>\n \n"
snarkjs zkey export solidityverifier triangleJumpVerifier_0001.zkey verifier.sol
echo "<===============Smart Contract Generated==================>\n \n"

# for generating valid params to verify through smart Contract
echo "<===============Generating Parameters==================>\n \n"
snarkjs generatecall
echo "<===============Parameters Generated==================>\n \n"

### params
#  ["0x23db1d6014a3dcc0e76960b7a0b98b52bbb9c4aa666acb5d8573b066e82fb061", "0x08ccf8209eb72e99302ab3836e36b0918db3cd3abc2399f635dc6467a3bc517e"],[["0x164bbaa909b6108196ee02ea3eea5d8311bb3fc2f22d1c3cb976594f56973dad", "0x064716ee01cbaf427080970ed0fe334ceb6cc220c847a520e6a253e70844f77a"],["0x187abaf65fa22467d5098f41060302856553da8158bc175bbfa622fd9744be8f", "0x2d46a8b1a4a6e90ca6a41cc988c6a79531dc338f5f4c2ba8d3a6e5674d8e3782"]],["0x19ff2e7995f8f417afc31675ada16189c28baa0f53d977d434331587c8d0ac28", "0x2b075f7785e7f44173e2b1db946bccb94224aa078a345317fa73bb400a4ff969"],["0x0000000000000000000000000000000000000000000000000000000000000001"]