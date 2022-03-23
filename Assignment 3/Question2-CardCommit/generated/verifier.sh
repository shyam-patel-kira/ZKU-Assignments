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

## ["0x14dd61af06a21faec4b1e31ec847547b7b94579c700c528f6ef301099f7220ad", "0x207478d2a851b4fd5dc3b92e95afd8a99195a5440721aea4774feb2d6edc2f73"],[["0x16a8d9658adec186253d87b482cc1e8bed2606e56ad671caa810ab58ecd90212", "0x0e83bce4ee7aab5697b7b0f5fc002f69d5e5c71edd5fdab0d4b813371d6fb36f"],["0x1a1d89e12e563237cc39e0445b761db19b02069d81bfc3a99fa71bde12f21810", "0x002099430231e46b87096612efd3599da507db8523b94dd04cbd37f0e40a9ac7"]],["0x045537db2e910763da7c163b63dd0f6ff3e38be55d1e5d4f094ac2f16538da7f", "0x010240a295a85dec7fd67077a1e9128294e96b5eb03714658219e7c3bab1fa74"],["0x168ff624b686b39957d52c5a053d3858456ffbfae51530b5321a96cbb1cd62c2","0x0000000000000000000000000000000000000000000000000000000000000003"]