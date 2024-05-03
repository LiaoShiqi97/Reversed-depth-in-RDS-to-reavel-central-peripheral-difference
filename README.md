# Reversed-depth-in-RDS-to-reavel-central-peripheral-difference
This is an implementation of experiment 1 in Li Zhaoping's paper "Reversed depth in anti-correlated random dot stereograms and the central-peripheral difference in visual inference" with a bit flaw(See below).
This is an very interesting paper. It reveals the existance of a backforward mechanism in the higher visual center in the brain as a cause of central-peripheral difference in visual inference. I found there is no implementation online so I post it here for your reference. Hope you enjoy it. Just run the "maincode_Liao" in matlab!

Note: 
1) you can follow the "How to run the code.txt" file to run the code and see how the experiment goes on

2) the implementation of the "dynamics" is wrong. I implement it as a random generated disparity. However, it should be implemented as a gradually increasing disparity with a certain step. And it should be implemented differently when the step order is odd and even as stated in the paper. You can modify it and see how the real expereiment works.

3) It should work like this:<img src="https://github.com/LiaoShiqi97/Reversed-depth-in-RDS-to-reavel-central-peripheral-difference/blob/main/screenshot.png">

4）The paper is Zhaoping L. and Ackermann J. (2018) Reversed Depth in Anticorrelated Random-Dot Stereograms and the Central-Peripheral Difference in Visual Inference Perception, 47(5) 531-539, https://doi.org/10.1177/0301006618758571

5) If you want to know more about this area. Here is a MOOC and lectures (https://zhaoping.thinkific.com/ and https://www.lizhaoping.org/zhaoping/AGZL_HumanVisual.html), If you are more like a reader (https://www.lizhaoping.org/zhaoping/VisionBook.html), contact me if you want a PDF version.

6) If you meet problem in using the PTB toolbox, see here(https://www.lizhaoping.org/zhaoping/VisualPsychophysicsTrainingCourse_UTuebingen_2020.html) and its offical online tutorial(https://peterscarfe.com/ptbtutorials.html)

7) Note yourself you may have to run the "SetupPsychtoolbox.m" under path AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\Psychtoolbox-3 everytime you restart Matlab to initialize the PTB toolbox. This will modifies the path in Matlab to the right order. Yes, this is a bug and should be fixed !!!!

8) This experiment brought me a lot fun and hope it works well on you as well. Enjoy it!
