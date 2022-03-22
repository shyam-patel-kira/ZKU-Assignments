pragma circom 2.0.3;

/*** 

Firstly, we would need a distance functions that returns the distance between 2 points

=>  First condition for forming triangle would be distance between any 2 points would not be 0.

(x1 - y1) + (x2 - y2) != 0
(y1 - z1) + (y2 - z2) != 0
(x1 - z1) + (x2 - z2) != 0

=>  Second condition to ensure 3 points to be a triangle is that 
    All 3 of them would never be on the same line

if x1 == y1 then y1 != z1
if x1 == z1 then y1 != z1
if z1 == y1 then x1 != z1

if x2 == y2 then y2 != z2
if x2 == z2 then y2 != z2
if z2 == y2 then x2 != z2

***/

function isValidTriangle(x1, x2, y1, y2, z1, z2) {
    if (x1 == y1) {
        assert(x2 != y2);
        assert(y1 != z1);
    }
    if (y1 == z1) {
        assert(y2 != z2);
        assert(x1 != z1);   
    }
    if (z1 == x1) {
        assert(z2 != x2);
        assert(y1 != z1);
    }
    if (x2 == y2) {
        assert(z2 != x2);
        assert(y1 != x1);
    }
    if (x2 == z2) {
        assert(y2 != z2);
        assert(x1 != z1);
    }
    if (y2 == z2) {
        assert(x2 != z2);
        assert(y1 != z1);
    }
    return 1;
}


function isJumpPossible(energy, x0, y0, x1, y1) {
    var distance = (x0 - x1)*(x0 - x1) + (y0 - y1)*(y0 - y1);
    assert(distance <= energy*energy);
    return 1;
}

template triangleJumpVerifier() {
    signal input x[2];
    signal input y[2];
    signal input z[2];
    signal input energy;
    signal output out;
    out <== isValidTriangle(x[0], x[1], y[0], y[1], z[0], z[1]);
    assert(isValidTriangle(x[0], x[1], y[0], y[1], z[0], z[1]));
    assert(isJumpPossible(energy, x[0], x[1], y[0], y[1]));
    assert(isJumpPossible(energy, y[0], y[1], z[0], z[1]));
    assert(isJumpPossible(energy, z[0], z[1], x[0], x[1]));
}

component main = triangleJumpVerifier();