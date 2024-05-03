# Reversed-depth-in-RDS-to-reavel-central-peripheral-difference
This is an implementation of experiment 1 in Li Zhaoping's paper "Reversed depth in anti-correlated random dot stereograms and the central-peripheral difference in visual inference" with a bit flaw(See below).
This is an very interesting paper. It reveals the existance of a backforward mechanism in the higher visual center in the brain as a cause of central-peripheral difference in visual inference. I found there is no implementation online so I post it here for your reference. Hope you enjoy it. Just run the "maincode_Liao" in matlab!

Note: 
1) you can follow the "How to run the code.txt" file to run the code and see how the experiment goes on
2) the implementation of the "dynamics" is wrong. I implement it as a random generated disparity. However, it should be implemented as a gradually increasing disparity with a certain step. And it should be implemented differently when the step order is odd and even as stated in the paper. You can modify it and see how the real expereiment works.
3) It should work like this:
