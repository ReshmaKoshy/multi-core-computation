# multi-core-computation
In this project, we explore leveraging Pony's actor model to efficiently perform arithmetic computations across multiple cores. By distributing tasks through actors, we aim to demonstrate how concurrent execution can improve performance, particularly in handling complex calculations. The problem we are particularly computing is ann interesting problem in arithmetic with deep implications to elliptic curve theory is the problem of finding perfect squares that are sums of consecutive squares. 

A classic example is the Pythagorean identity:
3^2 + 4^2 = 5^2 (1)
that reveals that the sum of squares of 3, 4 is itself a square. 

A more interesting example is Lucas‘ Square Pyramid :
1^2 + 2^2 + ... + 24^2 = 70^2 (2)
In both of these examples, sums of squares of consecutive integers form the
square of another integer.

Input: The input provided (as command line to your program, e.g.  lukas)
will be two numbers: N and k. The overall goal of your program is to find all
k consecutive numbers starting at 1 or higher and up to N , such that the sum of squares
is itself a perfect square (square of an integer).

Output: Print, on independent lines, the first number in the sequence for each

Example:
lukas 3 2
3
indicates that sequences of length 2 with start point between 1 and 3 contain
3,4 as a solution since 3^2 + 4^2 = 5^2.

The goal of this project is to use Pony and the actor model to build a
good solution to this problem that runs well on multi-core machines.

# Case1: single machine multiple cores. 

To see the code in action, cd into the single-machine folder, then compile and run the program using the following arguments:
./single-machine lukas <n> <k> $(sysctl -n hw.ncpu)

The below experiment has been conducted on an 8 core machine

/usr/bin/time ./single-machine lukas 1000000 24 $(sysctl -n hw.ncpu)

![alt text](<Screenshot 2024-09-18 at 9.30.46 AM.png>)

Here, the ratio of user time to real time (CPU utilization) is ≈ 7.3 indicates that the program is effectively using the processing power of about 7.3 cores.


# Case2: Distributed actors - multiple machine multiple cores. 
We can increase the problem size 𝑛 that we can solve by adding more computational resources. In this example, I will introduce an additional worker machine. You’ll see that both machines collaborate effectively, achieving results comparable to those produced by a 16-core machine.

To see the code in action, compile and run the program using the following arguments:

The client needs to run the code in distributed-actors/client folder as follows:
./client lukas <n> <k> $(sysctl -n hw.ncpu) <remote_ip> <remote_port>

The worker needs to run the code in distributed-actors/server folder as follows:
./server <server_ip> <server_port> $(sysctl -n hw.ncpu)



