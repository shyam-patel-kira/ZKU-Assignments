# Question 1: Intro to circom
First, go through the circom [docs](https://docs.circom.io/getting-started/installation/) and understand how to compile circuits, generate witness and verify proofs.

You may also watch this [video](https://youtu.be/9s1VLrjk5L4) demonstration that covers the same information.

Circomlib: https://github.com/iden3/circomlib

1. Construct a circuit using circom that takes a list of numbers input as leaves of a Merkle tree (Note that the numbers will be public inputs) and outputs the Merkle root. For the Merkle hash function, you may use the MiMCsponge hash function from circomlib. For simplicity, you may assume that the number of leaves will be a power of 2 (say 4) and the input will look like this {“leaves”:[1,2,3,4]}
2. Now try to generate the proof using a list of 8 numbers. Document any errors (if any) you encounter when increasing the size and explain how you fixed them.
3. Do we really need zero-knowledge proof for this? Can a publicly verifiable smart contract that computes Merkle root achieve the same? If so, give a scenario where Zero-Knowledge proofs like this might be useful. Are there any technologies implementing this type of proof? Elaborate in 100 words on how they work.
4. [_Bonus_] As you may have noticed, compiling circuits and generating the witness is an elaborate process. Explain what each step is doing. Optionally, you may create a bash script and comment on each step in it. This script will be useful later on to quickly compile circuits.

Add screenshots of the execution and the generated public.json file.