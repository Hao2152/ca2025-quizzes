.data
nums:        .word 64
nums_size:   .word 1
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
    addi  sp, sp, -8
    sw    ra, 4(sp)
    sw    t0, 0(sp)

    blez  a0, ret_false_body
    addi  t0, a0, -1
    and   t1, a0, t0
    bnez  t1, ret_false_body

    mv    t2, a0
    jal   ra, clz           # call CLZ
    li    t3, 31
    sub   t3, t3, a0        # msb = 31 - clz(n)
    andi  t4, t3, 1
    bnez  t4, ret_false_body

    li    a0, 1
    j     ret_exit

ret_false_body:
    li    a0, 0
ret_exit:
    lw    t0, 0(sp)
    lw    ra, 4(sp)
    addi  sp, sp, 8
    ret
###############################################################
# CLZ
###############################################################
clz:
    addi  sp, sp, -12
    sw    ra, 8(sp)
    sw    t0, 4(sp)
    sw    t1, 0(sp)

    beqz  a0, clz_zero        # if x==0 -> return 32

    li    t0, 0               # count = 0
    li    t2, 0x20            # limit = 32
clz_loop:
    sll  t1, a0, t0           # left shift to leading 1
    bltz  t1, clz_done        # if sign bit=1 -> found MSB
    addi  t0, t0, 1           # count++
    blt   t0, t2, clz_loop    # count < 32 → continue
clz_done:
    mv    a0, t0
    j     clz_exit

clz_zero:
    li    a0, 0x20            # return 32

clz_exit:
    lw    t1, 0(sp)
    lw    t0, 4(sp)
    lw    ra, 8(sp)
    addi  sp, sp, 12
    ret
