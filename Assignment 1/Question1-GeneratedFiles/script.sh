snarkjs powersoftau new bn128 14 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v -e="kira"


snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup merkleProof.r1cs pot12_final.ptau merkleProof_0000.zkey

snarkjs zkey contribute merkleProof_0000.zkey merkleProof_0001.zkey --name="1st Contributor Name" -v -e="kira"
snarkjs zkey export verificationkey merkleProof_0001.zkey verification_key.json

cp merkleProof_js/witness.wtns .

snarkjs groth16 prove merkleProof_0001.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json

#snarkjs zkey export solidityverifier merkleProof_0001.zkey verifier.sol
#snarkjs generatecall
