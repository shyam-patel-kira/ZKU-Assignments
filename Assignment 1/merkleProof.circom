pragma circom 2.0.0;

include "node_modules/circomlib/circuits/mimc.circom";
// Helper template that computes hashes of the next tree layer
template branch(height) {
  var items = 1 << height;
  // input array
  signal input ins[items * 2];
  // output array
  signal output outs[items];

  component hash[items];
  for(var i = 0; i < items; i++) {
    hash[i] = MultiMiMC7(2,91);
    hash[i].in[0] <== ins[i * 2];
    hash[i].in[1] <== ins[i * 2 + 1];
    hash[i].k <== 0;
    hash[i].out ==> outs[i];
  }
}

// Builds a merkle tree from leaf array
template merkleProof(levels) {
  signal input leaves[1 << levels];
  signal output root;

  component layers[levels];
  for(var level = levels - 1; level >= 0; level--) {
    layers[level] = branch(level);
    for(var i = 0; i < (1 << (level + 1)); i++) {
      layers[level].ins[i] <== level == levels - 1 ? leaves[i] : layers[level + 1].outs[i];
    }
  }
  root <== levels > 0 ? layers[0].outs[0] : leaves[0];
}

component main = merkleProof(3);