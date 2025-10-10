############################################################################################
# Input : 20bits unsigned integer e.g. 1000000(0xF4240)
# Output :
#   Input Value(dec/hex)
#   Encoded uf8 (dec/hex)
#   Decoded Value (dec/hex)
############################################################################################

############################################################################################
# Test Value and msg setting
.data  
test_values:  .word 0, 15, 16, 255, 1024, 65535, 1000000  
case_count:   .word 7

msg_in:       .string "Input value: "
msg_enc:      .string "Encoded uf8: "
msg_dec:      .string "Decoded value: "
msg_hex:      .string " (hex) = 0x"
nl:           .string "\n"
hexchars:     .string "0123456789ABCDEF"
############################################################################################

############################################################################################
.text
.globl main
############################################################################################

################################### Main Code ##############################################
main:
    la   s0, test_values      # s0 = start address of test data
    la   s1, case_count
    lw   s1, 0(s1)            # s1 = test data count
    li   s2, 0                # i = 0

loop_values:
    beq  s2, s1, end          # end the code when all data finished

    # load value
    lw   s3, 0(s0)            # s3 = input value (20bits value)

    # print msg_in
    la   a0, msg_in
    li   a7, 4                # system call print string
    ecall

    # print decimal value
    mv   a0, s3
    li   a7, 1                # system call print int
    ecall

    # print msg_hex
    la   a0, msg_hex
    li   a7, 4                # system call print string
    ecall

    # print hex value in 20bits
    mv   a0, s3
    jal  ra, print_hex20bits

    # print next line
    la   a0, nl
    li   a7, 4
    ecall

    ################ Encode (20-bit to 8-bit) ####################
    mv   a0, s3
    jal  ra, uf8_encode        # jump to uf8_encode and save the adress to ra
    mv   s4, a0                # s4 = uf8 code (8bits)

    # �L encoded uf8
    la   a0, msg_enc
    li   a7, 4                 # system call print string
    ecall

    mv   a0, s4
    li   a7, 1                 # system call print int
    ecall

    la   a0, msg_hex
    li   a7, 4                 # system call print string
    ecall
    
    #call function
    mv   a0, s4
    jal  ra, print_hex2bits        # jump to print_hex2 and save the adress to ra
    
    la   a0, nl                # system call print string
    li   a7, 4
    ecall
    
    ################# Decode (8bits to 20bits) ####################
    mv   a0, s4
    jal  ra, uf8_decode
    mv   s5, a0                # s5 = decoded value

    # print decoded value
    la   a0, msg_dec
    li   a7, 4
    ecall

    mv   a0, s5
    li   a7, 1
    ecall

    la   a0, msg_hex
    li   a7, 4
    ecall

    mv   a0, s5
    jal  ra, print_hex20bits


    la   a0, nl
    li   a7, 4
    ecall
    la   a0, nl
    li   a7, 4
    ecall

    # next test data
    addi s0, s0, 4
    addi s2, s2, 1
    j    loop_values
end:
    li   a7, 10                 #system call exit
    ecall
############################################################################################




uf8_decode:
    andi    t0, a0, 0x0f   # mantissa = b & 0x0F
    srli    t1, a0, 4      # exponent = b >> 4
    li      t2, 1          # init t2
    sll     t2, t2, t1     # t2 = 2^e
    addi    t2, t2, -1     # t2 = 2^e - 1
    slli    t2, t2, 4      # t2 = (2^e - 1) * 16
    sll     t0, t0, t1     # t0 = m * 2^e
    add     a0, t0, t2     # a0 = m*2^e + (2^e -1)*16
    ret
    
uf8_encode:
    li      t4, 16
    bltu    a0, t4, v_small   # if v < 16 return v

    addi    sp, sp, -8        #
    sw      ra, 4(sp)         #
    sw      s0, 0(sp)         #
    mv      s0, a0            #
    mv      a0, s0            #
    jal     ra, clz           # call clz(count leading zeros) to find leading 1 position

    li      t0, 31            #
    sub     t3, t0, a0        # t3 = msb postion
    li      t4, 0             # e = 0
    li      t5, 0             # offset = 0
    li      t0, 5             #
    blt     t3, t0, Lskip_est # jump to skip when msb < 5 (msb < 5 is mean that the value is in the safe range)

    li      t0, 4             #
    sub     t4, t3, t0        # e = msb - 4
    li      t0, 15            #
    ble     t4, t0, Lcap_ok   #
    li      t4, 15            # if e > 15, then set e = 15

Lcap_ok:
    li      t5, 0
    li      t1, 0
Lmk_off:                            # t5 = (2^e ? 1)��16
    bge     t1, t4, Lmk_off_end     # do e times
    slli    t5, t5, 1
    addi    t5, t5, 16              # t5 = (t5<<1) + 16
    addi    t1, t1, 1
    j       Lmk_off
Lmk_off_end:
    
###########################
# if v ? next offset do grow, else do shrink
# ensure offset(e) ? v < offset(e+1)
###########################
Lshrink:
    beqz    t4, Lafter_shrink
    bge     s0, t5, Lafter_shrink
    addi    t5, t5, -16
    srli    t5, t5, 1
    addi    t4, t4, -1
    j       Lshrink
Lafter_shrink:
Lskip_est:
Lgrow:
    li      t0, 15
    bge     t4, t0, Lgrow_end
    slli    t2, t5, 1
    addi    t2, t2, 16
    bltu    s0, t2, Lgrow_end
    mv      t5, t2
    addi    t4, t4, 1
    j       Lgrow
Lgrow_end:
    sub     t1, s0, t5        # v - offset
    srl     t1, t1, t4        # floor((v-offset)/2^e)
    slli    t4, t4, 4         # e << 4
    or      a0, t4, t1        # (e << 4) | mantissa (combine mantissa and exponent)
    lw      s0, 0(sp)
    lw      ra, 4(sp)
    addi    sp, sp, 8
    ret
v_small:
    ret

#########################################################
# count leading zeros and return the leading 1 position #
#########################################################
clz:
    li      t0, 32
    li      t1, 16
clz_loop:
    srl     t2, a0, t1
    beqz    t2, no_sub
    sub     t0, t0, t1
    mv      a0, t2
no_sub:
    srli    t1, t1, 1
    bnez    t1, clz_loop
    sub     a0, t0, a0
    ret

##############################
# print value in 0xFF format #
##############################
print_hex2bits:
    addi    sp, sp, -8
    sw      t0, 4(sp)
    sw      t1, 0(sp)
    mv      t1, a0
    srli    t0, t1, 4
    andi    t0, t0, 0xF
    la      a0, hexchars
    add     a0, a0, t0
    lbu     a0, 0(a0)
    li      a7, 11
    ecall
    andi    t0, t1, 0xF
    la      a0, hexchars
    add     a0, a0, t0
    lbu     a0, 0(a0)
    li      a7, 11
    ecall
    lw      t1, 0(sp)
    lw      t0, 4(sp)
    addi    sp, sp, 8
    ret
#################################
# print value in 0xFFFFF format #
#################################
print_hex20bits:
    addi    sp, sp, -12
    sw      ra, 8(sp)
    sw      t0, 4(sp)
    sw      t1, 0(sp)

    mv      t3, a0            
    li      t1, 16            
hex20_loop:
    srl     t0, t3, t1        
    andi    t0, t0, 0xF
    la      t2, hexchars
    add     t2, t2, t0
    lbu     t2, 0(t2)

    mv      a0, t2            
    li      a7, 11
    ecall

    addi    t1, t1, -4
    bgez    t1, hex20_loop

    mv      a0, t3            
    lw      ra, 8(sp)
    lw      t0, 4(sp)
    lw      t1, 0(sp)
    addi    sp, sp, 12
    ret


