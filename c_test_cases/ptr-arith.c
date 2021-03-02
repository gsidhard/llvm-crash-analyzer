/* This is difficult for PAC to identify. 

Any of the below could be a blame. Can we say any pointer arithmetic cases cannot be accurately determined ?

1) arg pointer in test_cf could be bad
2) arg = arg + 3;
3) arg arg +2 in while loop
*/

#include <stdio.h>

char *foo = "hello";

void test_cf(char *arg, int val1, int val2) {
switch(val1) {
  case 0: 
   arg = arg + 3; // this also could be a blame
    while (val2--) {
	arg=arg+20; // Blame : pointer becomes bad during one of the iterations
    }
    printf("\n Bad %c", *arg); // crash here bt #0
  break;
  case 1: printf("\n Good %c", *arg);
  break;
  default: ;
} 
 
}

int main() {
 char *good = foo;
 test_cf(good,0,1000); // bt #2
 return 0;
}