
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
# CLZ Binary Search
###############################################################
clz:
    addi  sp, sp, -20
    sw    ra, 16(sp)
    sw    t0, 12(sp)
    sw    t1, 8(sp)
    sw    t2, 4(sp)
    sw    t3, 0(sp)

    beqz  a0, clz_zero         # if x == 0 → return 32

    li    t3, 0                # n = 0

    # Step 1: check upper 16 bits
    srli  t1, a0, 16
    beqz  t1, clz_step2
    mv    a0, t1               # x = x >> 16
    li    t2, 16
    add   t3, t3, t2           # n += 16
clz_step2:
    # Step 2: check upper 8 bits
    srli  t1, a0, 8
    beqz  t1, clz_step3
    mv    a0, t1
    li    t2, 8
    add   t3, t3, t2
clz_step3:
    # Step 3: check upper 4 bits
    srli  t1, a0, 4
    beqz  t1, clz_step4
    mv    a0, t1
    li    t2, 4
    add   t3, t3, t2
clz_step4:
    # Step 4: check upper 2 bits
    srli  t1, a0, 2
    beqz  t1, clz_step5
    mv    a0, t1
    li    t2, 2
    add   t3, t3, t2
clz_step5:
    # Step 5: final correction
    srli  t1, a0, 1
    beqz  t1, clz_done
    li    t2, 1
    add   t3, t3, t2

clz_done:
    li    t2, 31
    sub   a0, t2, t3           # a0 = 31 - n
    j     clz_exit

clz_zero:
    li    a0, 32
clz_exit:
    lw    t3, 0(sp)
    lw    t2, 4(sp)
    lw    t1, 8(sp)
    lw    t0, 12(sp)
    lw    ra, 16(sp)
    addi  sp, sp, 20
    ret