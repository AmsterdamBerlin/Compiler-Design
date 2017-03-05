/*
  Test 1, uninitialized variables.
*/
#include <stdio.h>

int main()
{
    int k;    //allocate    kill k
    float f;  // allocate   kill f

    printf("%d %f\n", k, f);  // load   gen k, f

    return 0;
}


// allocate: gen
// store: gen, kill
// load: kill
// gen(n) - kill(n) >=0 other wise error!
