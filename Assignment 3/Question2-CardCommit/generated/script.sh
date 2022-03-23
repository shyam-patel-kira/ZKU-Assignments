echo "\n\n-----------------------Compiling circom circuit---------------------\n"

circom CardCommit.circom --r1cs --wasm --sym --c

cd CardCommit_js/
node generate_witness.js CardCommit.wasm ../input.json witness.wtns
cd ..

echo "<===============Phase-1==================>\n \n"
echo "-----Creating the tau ceremony------\n \n"
snarkjs powersoftau new bn128 14 pot12_0000.ptau -v
echo "-------Making the first contribution tau ceremony-----\n\n"
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v -e="kira"

# Phase 2 is circuit-specific and is used to generate a .zkey file.
# This file contains proving and verification keys.

echo "<===============Phase-2==================>\n \n"
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup CardCommit.r1cs pot12_final.ptau CardCommit_0000.zkey

echo "-------Making the contribution tau ceremony Phase-2-----\n\n"
snarkjs zkey contribute CardCommit_0000.zkey CardCommit_0001.zkey --name="1st Contributor Name" -v -e="kira"
snarkjs zkey export verificationkey CardCommit_0001.zkey verification_key.json

