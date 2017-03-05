/*
  Test 2, uninitialized variables with simple branch.
*/
#include <stdio.h>

int main()
{
    int k;   // allocate, kill, 0  [0]
    int t = 30; // allocate, kill, 0; store, kill, 0  [00]

    if(k > t){   // load, gen 1; load, gen, 1   [11]    ERROR: k uninitialized
        printf("%d ", k); // load, gen, 1     [11]     ERROR: k uninitialized
    }
    else {
        k = t; // load, store // load, gen, 1 ; store, kill, 0  [01]
    }

    printf("%d %d\n", k, t); // load, gen, 1; load, gen, 1  [11]     ERROR: k uninitialized

    return 0;
}


// NOTE: allocated without storing following, this variable cannot be loaded
