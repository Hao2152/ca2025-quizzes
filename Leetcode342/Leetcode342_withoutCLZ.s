.data
nums:        .word 1, 2, 4, 8, 16, 32, 64, 0, -4, 5
nums_size:   .word 10
msg_true:    .string "True\n"
msg_false:   .string "False\n"

.text
.globl main

###############################################################
# main
###############################################################
main:
    la   s0, nums
    la   s1, nums_size
    lw   s1, 0(s1)
    li   s2, 0

loop_start:
    bge  s2, s1, done

    slli t0, s2, 2
    add  t0, t0, s0
    lw   a0, 0(t0)
    jal  ra, isPowerOfFour

    beqz a0, print_false
    la   a0, msg_true
    li   a7, 4
    ecall
    j    next
print_false:
    la   a0, msg_false
    li   a7, 4
    ecall
next:
    addi s2, s2, 1
    j    loop_start

done:
    li   a7, 10
    ecall

###############################################################
# isPowerOfFour(int n)
###############################################################
isPowerOfFour:
    blez a0, ret_false

div_loop:
    # t0 = n % 4
    andi t0, a0, 3         
    bnez t0, check_one

    # n /= 4
    srli a0, a0, 2
    j    div_loop

check_one:
    li   t0, 1
    beq  a0, t0, ret_true
    j    ret_false

ret_true:
    li   a0, 1
    ret
ret_false:
    li   a0, 0
    ret
