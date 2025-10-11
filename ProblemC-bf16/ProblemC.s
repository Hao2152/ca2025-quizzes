.data
test_count:   .word 4
test_inputs:
    .word 0x40800000, 0x40000000     # 1: 4.0, 2.0
    .word 0x41100000, 0x40400000     # 2: 9.0, 3.0
    .word 0x7F7FFFFF, 0x40000000     # 3: inf, 2.0
    .word 0x3F800000, 0x00000000     # 4: 1.0, 0.0

msg_a:       .string "A (f32 hex): 0x"
msg_b:       .string "B (f32 hex): 0x"
msg_to_bf16: .string " -> BF16: 0x"
msg_flags:   .string "  ["
msg_endflag: .string "]\n"

msg_add:     .string "ADD  (A+B)  BF16: 0x"
msg_sub:     .string "SUB  (A-B)  BF16: 0x"
msg_mul:     .string "MUL  (A*B)  BF16: 0x"
msg_div:     .string "DIV  (A/B)  BF16: 0x"
msg_sqrt:    .string "SQRT (A^0.5) BF16: 0x"

msg_zero:    .string "zero"
msg_inf:     .string "inf"
msg_nan:     .string "nan"
msg_norm:    .string "normal"

nl:          .string "\n"
hexchars:    .string "0123456789ABCDEF"
sep_space:   .string " "
comma:       .string ","

#########################
# Constants (masks)
#########################
BF16_SIGN_MASK:  .half 0x8000
BF16_EXP_MASK:   .half 0x7F80
BF16_MANT_MASK:  .half 0x007F
BF16_EXP_BIAS:   .word 127

.text
.globl main

############################################################################################
# main
############################################################################################
main:
    la   s11, test_inputs      # s11 = (a,b) 指標
    la   t3, test_count
    lw   s10, 0(t3)            # s10 = 總筆數
    li   s9, 0                 # s9 = index

main_loop:
    beq  s9, s10, main_done

    lw   s0, 0(s11)            # load a
    lw   s1, 4(s11)            # load b
    
    # --- Print A IEEE754(0xFFFFFFFF) hex and its BF16(0xFFFF) ---
    la   a0, msg_a
    li   a7, 4
    ecall

    mv   a0, s0
    jal  ra, print_hex32bits

    la   a0, msg_to_bf16
    li   a7, 4
    ecall

    mv   a0, s0
    jal  ra, f32_to_bf16
    mv   s2, a0                 # s2 = A_bf16

    mv   a0, s2
    jal  ra, print_hex16bits
    # print flags for A
    la   a0, msg_flags
    li   a7, 4
    ecall
    mv   a0, s2
    jal  ra, print_bf16_flags
    la   a0, msg_endflag
    li   a7, 4
    ecall

    # --- Print B IEEE754(0xFFFFFFFF) hex and its BF16(0xFFFF) ---
    la   a0, msg_b
    li   a7, 4
    ecall

    mv   a0, s1
    jal  ra, print_hex32bits

    la   a0, msg_to_bf16
    li   a7, 4
    ecall

    mv   a0, s1
    jal  ra, f32_to_bf16
    mv   s3, a0                 # s3 = B_bf16

    mv   a0, s3
    jal  ra, print_hex16bits

    # print flags for B
    la   a0, msg_flags
    li   a7, 4
    ecall
    mv   a0, s3
    jal  ra, print_bf16_flags
    la   a0, msg_endflag
    li   a7, 4
    ecall

    # Newline
    la   a0, nl
    li   a7, 4
    ecall

    # ========================
    # Do ADD
    # ========================
    mv   a0, s2
    mv   a1, s3
    jal  ra, bf16_add
    mv   s4, a0

    la   a0, msg_add
    li   a7, 4
    ecall
    mv   a0, s4
    jal  ra, print_hex16bits
    la   a0, msg_flags
    li   a7, 4
    ecall
    mv   a0, s4
    jal  ra, print_bf16_flags
    la   a0, msg_endflag
    li   a7, 4
    ecall

    # ========================
    # Do SUB
    # ========================
    mv   a0, s2
    mv   a1, s3
    jal  ra, bf16_sub
    mv   s5, a0

    la   a0, msg_sub
    li   a7, 4
    ecall
    mv   a0, s5
    jal  ra, print_hex16bits
    la   a0, msg_flags
    li   a7, 4
    ecall
    mv   a0, s5
    jal  ra, print_bf16_flags
    la   a0, msg_endflag
    li   a7, 4
    ecall

    # ========================
    # Do MUL
    # ========================
    mv   a0, s2
    mv   a1, s3
    jal  ra, bf16_mul
    mv   s6, a0

    la   a0, msg_mul
    li   a7, 4
    ecall
    mv   a0, s6
    jal  ra, print_hex16bits
    la   a0, msg_flags
    li   a7, 4
    ecall
    mv   a0, s6
    jal  ra, print_bf16_flags
    la   a0, msg_endflag
    li   a7, 4
    ecall

    # ========================
    # Do DIV
    # ========================
    mv   a0, s2
    mv   a1, s3
    jal  ra, bf16_div
    mv   s7, a0

    la   a0, msg_div
    li   a7, 4
    ecall
    mv   a0, s7
    jal  ra, print_hex16bits
    la   a0, msg_flags
    li   a7, 4
    ecall
    mv   a0, s7
    jal  ra, print_bf16_flags
    la   a0, msg_endflag
    li   a7, 4
    ecall
    
    # ========================
    # Do SQRT
    # ========================
    mv   a0, s2
    jal  ra, bf16_sqrt
    mv   s8, a0

    la   a0, msg_sqrt
    li   a7, 4
    ecall
    mv   a0, s8
    jal  ra, print_hex16bits
    la   a0, msg_flags
    li   a7, 4
    ecall
    mv   a0, s8
    jal  ra, print_bf16_flags
    la   a0, msg_endflag
    li   a7, 4
    ecall
    
    la   a0, nl
    li   a7, 4
    ecall
    la   a0, nl
    li   a7, 4
    ecall

    addi s9,  s9,  1           # index++
    addi s11, s11, 8           # 下一筆
    j    main_loop

main_done:
    li   a7, 10
    ecall
############################################################################################
# Helpers: print_bf16_flags(a0=bf16bits) -> prints "zero"/"inf"/"nan"/"normal"
############################################################################################
print_bf16_flags:
    addi  sp, sp, -16
    sw    ra, 12(sp)
    sw    t0, 8(sp)
    sw    t1, 4(sp)
    sw    t2, 0(sp)

    mv    t0, a0                 # t0 = bf16

    # iszero: (bits & 0x7FFF) == 0
    li    t1, 0x7FFF
    and   t2, t0, t1
    beqz  t2, is_zero

    # isinf / isnan: (exp==0xFF) and (mant==0/!=0)
    # get exp = (bits>>7)&0xFF
    srli  t1, t0, 7
    andi  t1, t1, 0xFF
    li    t2, 0xFF
    bne   t1, t2, is_normal    # exp != 0xFF -> normal

    # exp==0xFF => check mant
    andi  t1, t0, 0x7F          # mant
    beqz  t1, is_inf

    # nan
    la    a0, msg_nan
    li    a7, 4
    ecall
    j     done_flags

is_inf:
    la    a0, msg_inf
    li    a7, 4
    ecall
    j     done_flags

is_zero:
    la    a0, msg_zero
    li    a7, 4
    ecall
    j     done_flags

is_normal:
    la    a0, msg_norm
    li    a7, 4
    ecall

done_flags:
    lw    t2, 0(sp)
    lw    t1, 4(sp)
    lw    t0, 8(sp)
    lw    ra, 12(sp)
    addi  sp, sp, 16
    ret

############################################################################################
# f32_to_bf16(a0 = u32 f32bits) -> a0 = u16 bf16bits
# if (exp==0xFF) return high16; else round-to-nearest-even on low16 then >>16
############################################################################################
f32_to_bf16:
    addi  sp, sp, -16
    sw    ra, 12(sp)
    sw    t0, 8(sp)
    sw    t1, 4(sp)
    sw    t2, 0(sp)

    mv    t0, a0                 # t0 = f32bits
    srli  t1, t0, 23
    andi  t1, t1, 0xFF           # t1 = exp
    li    t2, 0xFF
    beq   t1, t2, f_is_special  # exp==255 => NaN/Inf, just take high16

    # rounding: f32bits += ((f32bits>>16)&1) + 0x7FFF; then >>16
    srli  t1, t0, 16
    andi  t1, t1, 1
    add   t0, t0, t1
    li    t1, 0x7FFF
    add   t0, t0, t1
    srli  t0, t0, 16
    li t1, 0xFFFF
    and t0, t0, t1
    mv    a0, t0
    j     f_ret

f_is_special:
    srli  t0, t0, 16
    li t1, 0xFFFF
    and t0, t0, t1
    mv    a0, t0

f_ret:
    lw    t2, 0(sp)
    lw    t1, 4(sp)
    lw    t0, 8(sp)
    lw    ra, 12(sp)
    addi  sp, sp, 16
    ret
############################################################################################
# bf16_add(a0=a, a1=b) -> a0=result   (integer-only emulate, mirrors your C)
############################################################################################
bf16_add:
    addi  sp, sp, -40
    sw    ra, 36(sp)
    sw    s0, 32(sp)
    sw    s1, 28(sp)
    sw    s2, 24(sp)
    sw    s3, 20(sp)
    sw    s4, 16(sp)
    sw    s5, 12(sp)
    sw    s6, 8(sp)
    sw    s7, 4(sp)

    mv    s0, a0           # a
    mv    s1, a1           # b

    # extract fields
    srli  s2, s0, 15       # sign_a
    andi  s2, s2, 1
    srli  s3, s1, 15       # sign_b
    andi  s3, s3, 1
    srli  s4, s0, 7        # exp_a
    andi  s4, s4, 0xFF
    srli  s5, s1, 7        # exp_b
    andi  s5, s5, 0xFF
    andi  s6, s0, 0x7F     # mant_a
    andi  s7, s1, 0x7F     # mant_b

    # handle specials (NaN/Inf/zero) - same logic as C
    # if exp_a==0xFF:
    li    t0, 0xFF
    bne   s4, t0, add_chk_b_inf
    # exp_a==0xFF
    bnez  s6, add_ret_a     # NaN -> return a
    # a is Inf
    bne   s5, t0, add_ret_a # if b not Inf -> return a
    # both inf
    bnez  s7, add_ret_b     # b NaN -> return b
    # both inf with signs: same sign -> b, else NaN
    bne   s2, s3, add_nan
    j     add_ret_b
add_chk_b_inf:
    bne   s5, t0, add_chk_a_zero
    # b is Inf/NaN
    bnez  s7, add_ret_b
    j     add_ret_b

add_chk_a_zero:
    # if a is zero (exp==0 && mant==0) return b
    bnez  s4, add_chk_b_zero
    beqz  s6, add_ret_b
add_chk_b_zero:
    # if b is zero -> return a
    bnez  s5, add_prep
    beqz  s7, add_ret_a

add_prep:
    # add hidden 1 if normalized
    beqz  s4, add_nohid_a
    ori   s6, s6, 0x80
add_nohid_a:
    beqz  s5, add_nohid_b
    ori   s7, s7, 0x80
add_nohid_b:

    # align exponents
    sub   t0, s4, s5        # exp_diff = exp_a - exp_b
    mv    t1, s4            # result_exp
    bgtz  t0, add_shift_b
    bltz  t0, add_shift_a
    j     add_same_exp

add_shift_b:
    li    t2, 8
    bgt   t0, t2, add_ret_a     # if diff>8 return a (underflow of b side)
    mv    t1, s4
    srl   s7, s7, t0
    j     add_do

add_shift_a:
    neg   t3, t0                 # -exp_diff
    li    t2, 8
    bgt   t3, t2, add_ret_b     # if diff<-8 return b
    mv    t1, s5
    srl   s6, s6, t3
    j     add_do

add_same_exp:
    mv    t1, s4

add_do:
    # same sign -> add mant; else subtract
    bne   s2, s3, add_diff_sign
    # same sign
    add   t4, s6, s7             # result_mant
    # if overflow (bit8)
    li    t5, 0x100
    and   t2, t4, t5
    beqz  t2, add_pack_same
    srli  t4, t4, 1
    addi  t1, t1, 1
    li    t2, 0xFF
    blt   t1, t2, add_pack_same
    # overflow to INF
    slli  t6, s2, 15
    li t1, 0x7F80
    or  t6, t6, t1
    mv    a0, t6
    j     add_epilogue

add_pack_same:
    # pack with same sign
    slli  t6, s2, 15
    slli  t2, t1, 7
    andi  t4, t4, 0x7F
    or    t6, t6, t2
    or    t6, t6, t4
    mv    a0, t6
    j     add_epilogue

add_diff_sign:
    # subtract larger - smaller
    bge   s6, s7, add_a_ge_b
    mv    t6, s3             # result_sign
    sub   t4, s7, s6
    j     add_norm_sub
add_a_ge_b:
    mv    t6, s2
    sub   t4, s6, s7

add_norm_sub:
    beqz  t4, add_zero
    # normalize until mant has bit7 set
    li    t2, 0x80
add_norm_loop:
    and   t5, t4, t2
    bnez  t5, add_pack_sub
    slli  t4, t4, 1
    addi  t1, t1, -1
    blez  t1, add_zero
    j     add_norm_loop

add_pack_sub:
    slli  t5, t6, 15
    slli  t2, t1, 7
    andi  t4, t4, 0x7F
    or    t5, t5, t2
    or    t5, t5, t4
    mv    a0, t5
    j     add_epilogue

add_zero:
    li    a0, 0x0000
    j     add_epilogue

add_nan:
    li    a0, 0x7FC0
    j     add_epilogue

add_ret_a:
    mv    a0, s0
    j     add_epilogue
add_ret_b:
    mv    a0, s1

add_epilogue:
    lw    s7, 4(sp)
    lw    s6, 8(sp)
    lw    s5, 12(sp)
    lw    s4, 16(sp)
    lw    s3, 20(sp)
    lw    s2, 24(sp)
    lw    s1, 28(sp)
    lw    s0, 32(sp)
    lw    ra, 36(sp)
    addi  sp, sp, 40
    ret

############################################################################################
# bf16_sub(a0=a, a1=b) -> a0=a + (-b)
############################################################################################
bf16_sub:
    addi  sp, sp, -8
    sw    ra, 4(sp)
    sw    t1, 0(sp)

    li    t1, 0x8000
    xor   a1, a1, t1
    jal   ra, bf16_add

    lw    t1, 0(sp)
    lw    ra, 4(sp)
    addi  sp, sp, 8
    ret

############################################################################################
# bf16_mul(a0=a, a1=b) -> a0=result   (integer emulate, mirrors your C)
############################################################################################
bf16_mul:
    addi  sp, sp, -48
    sw    ra, 44(sp)
    sw    s0, 40(sp)
    sw    s1, 36(sp)
    sw    s2, 32(sp)
    sw    s3, 28(sp)
    sw    s4, 24(sp)
    sw    s5, 20(sp)
    sw    s6, 16(sp)
    sw    s7, 12(sp)
    sw    s8, 8(sp)
    sw    s9, 4(sp)

    mv    s0, a0         # a
    mv    s1, a1         # b

    # fields
    srli  s2, s0, 15     # sign_a
    andi  s2, s2, 1
    srli  s3, s1, 15     # sign_b
    andi  s3, s3, 1
    xor   s4, s2, s3     # result_sign

    srli  s5, s0, 7      # exp_a
    andi  s5, s5, 0xFF
    srli  s6, s1, 7      # exp_b
    andi  s6, s6, 0xFF
    andi  s7, s0, 0x7F   # mant_a
    andi  s8, s1, 0x7F   # mant_b

    # specials
    li    t0, 0xFF
    beq   s5, t0, mul_a_inf_nan
    beq   s6, t0, mul_b_inf_nan
    # zero check
    beqz  s5, mul_a_sub_chk
    j     mul_a_ok
mul_a_sub_chk:
    beqz  s7, mul_ret_zero
mul_a_ok:
    beqz  s6, mul_b_sub_chk
    j     mul_b_ok
mul_b_sub_chk:
    beqz  s8, mul_ret_zero
mul_b_ok:

    # subnormal normalization + hidden 1
    li    s9, 0           # exp_adjust
    beqz  s5, mul_norm_a
    ori   s7, s7, 0x80
    j     mul_norm_b
mul_norm_a:
    # shift left until bit7 set, dec exp_adjust
    li    t1, 0x80
mul_na_loop:
    and   t2, s7, t1
    bnez  t2, mul_na_done
    slli  s7, s7, 1
    addi  s9, s9, -1
    j     mul_na_loop
mul_na_done:
    li    s5, 1
mul_norm_b:
    beqz  s6, mul_norm_b2
    ori   s8, s8, 0x80
    j     mul_mul
mul_norm_b2:
    li    t1, 0x80
mul_nb_loop:
    and   t2, s8, t1
    bnez  t2, mul_nb_done
    slli  s8, s8, 1
    addi  s9, s9, -1
    j     mul_nb_loop
mul_nb_done:
    li    s6, 1

mul_mul:
    # 8-bit * 8-bit -> up to 16-bit
    mul   t3, s7, s8      # result_mant (16-bit max)
    # result_exp = exp_a + exp_b - 127 + exp_adjust
    la    t4, BF16_EXP_BIAS
    lw    t4, 0(t4)       # 127
    add   t5, s5, s6
    sub   t5, t5, t4
    add   t5, t5, s9      # result_exp

    # normalize: if (mant & 0x8000) -> shift>>8, exp++
    li    t6, 0x8000
    and   t1, t3, t6
    beqz  t1, mul_shift7
    srli  t3, t3, 8
    addi  t5, t5, 1
    j     mul_pack_check
mul_shift7:
    srli  t3, t3, 7

mul_pack_check:
    # overflow / underflow
    li    t1, 0xFF
    bge   t5, t1, mul_ret_inf
    blez  t5, mul_underflow_chk

    # normal pack
    andi  t3, t3, 0x7F
    slli  t0, s4, 15
    slli  t1, t5, 7
    or    t0, t0, t1
    or    t0, t0, t3
    mv    a0, t0
    j     mul_done

mul_underflow_chk:
    # if result_exp < -6 -> zero else shift mant right and set exp=0
    li    t1, -6
    bgt   t5, t1, mul_denorm
mul_ret_zero:
    slli  t0, s4, 15
    mv    a0, t0
    j     mul_done
mul_denorm:
    neg   t2, t5           # 0 - exp
    addi  t2, t2, 1        # 1 - result_exp
    srl   t3, t3, t2
    andi  t3, t3, 0x7F
    slli  t0, s4, 15
    or    t0, t0, t3
    mv    a0, t0
    j     mul_done

mul_ret_inf:
    slli  t0, s4, 15
    li t1, 0x7F80
    or  t0, t0, t1
    mv    a0, t0
    j     mul_done

mul_a_inf_nan:
    andi  t1, s0, 0x7F
    bnez  t1, mul_ret_a      # NaN -> a
    # a=Inf
    # if b==0 -> NaN; else Inf with sign
    beqz  s6, mul_b0_chk_m
    j     mul_ret_sign_inf
mul_b0_chk_m:
    beqz  s8, mul_ret_nan
    j     mul_ret_sign_inf

mul_b_inf_nan:
    andi  t1, s1, 0x7F
    bnez  t1, mul_ret_b
    beqz  s5, mul_a0_chk_m
    j     mul_ret_sign_inf
mul_a0_chk_m:
    beqz  s7, mul_ret_nan
    j     mul_ret_sign_inf

mul_ret_a:
    mv    a0, s0
    j     mul_done
mul_ret_b:
    mv    a0, s1
    j     mul_done
mul_ret_sign_inf:
    slli  t0, s4, 15
    li t1, 0x7F80
    or  t0, t0, t1
    mv    a0, t0
    j     mul_done
mul_ret_nan:
    li    a0, 0x7FC0

mul_done:
    lw    s9, 4(sp)
    lw    s8, 8(sp)
    lw    s7, 12(sp)
    lw    s6, 16(sp)
    lw    s5, 20(sp)
    lw    s4, 24(sp)
    lw    s3, 28(sp)
    lw    s2, 32(sp)
    lw    s1, 36(sp)
    lw    s0, 40(sp)
    lw    ra, 44(sp)
    addi  sp, sp, 48
    ret

############################################################################################
# bf16_div(a0=a, a1=b) -> a0=result   (integer emulate, mirrors your C)
############################################################################################
bf16_div:
    addi  sp, sp, -56
    sw    ra, 52(sp)
    sw    s0, 48(sp)
    sw    s1, 44(sp)
    sw    s2, 40(sp)
    sw    s3, 36(sp)
    sw    s4, 32(sp)
    sw    s5, 28(sp)
    sw    s6, 24(sp)
    sw    s7, 20(sp)
    sw    s8, 16(sp)
    sw    s9, 12(sp)
    sw    s10,8(sp)
    sw    s11,4(sp)

    mv    s0, a0       # a
    mv    s1, a1       # b

    # fields
    srli  s2, s0, 15   # sign_a
    andi  s2, s2, 1
    srli  s3, s1, 15   # sign_b
    andi  s3, s3, 1
    xor   s4, s2, s3   # result_sign

    srli  s5, s0, 7    # exp_a
    andi  s5, s5, 0xFF
    srli  s6, s1, 7    # exp_b
    andi  s6, s6, 0xFF
    andi  s7, s0, 0x7F # mant_a
    andi  s8, s1, 0x7F # mant_b

    # specials (follow your C)
    li    t0, 0xFF
    beq   s6, t0, div_b_inf_nan
    beqz  s6, div_b_zero_chk
    j     div_chk_a
div_b_zero_chk:
    beqz  s8, div_div_by_zero
    j     div_chk_a

div_b_inf_nan:
    bnez  s8, div_ret_b        # NaN
    # b=Inf
    beq   s5, t0, div_inf_inf_nan
    slli  t1, s4, 15            # result is signed zero
    mv    a0, t1
    j     div_done
div_inf_inf_nan:
    # a Inf and b Inf => NaN
    andi  t1, s0, 0x7F
    bnez  t1, div_ret_a
    li    a0, 0x7FC0
    j     div_done

div_div_by_zero:
    # a/0 -> Inf (unless a==0 -> NaN handled below)
    beqz  s5, div_a_zero_chk_m
    slli  t1, s4, 15
    li t2, 0x7F80
    or  t1, t1, t2
    mv    a0, t1
    j     div_done
div_a_zero_chk_m:
    beqz  s7, div_ret_nan
    slli  t1, s4, 15
    li t2, 0x7F80
    or  t1, t1, t2
    mv    a0, t1
    j     div_done

div_chk_a:
    beq   s5, t0, div_a_inf_nan
    beqz  s5, div_a_zero_sub_chk
    j     div_prep
div_a_zero_sub_chk:
    beqz  s7, div_ret_zero

div_a_inf_nan:
    bnez  s7, div_ret_a        # NaN
    # a=Inf
    slli  t1, s4, 15
    li t2, 0x7F80
    or  t1, t1, t2
    mv    a0, t1
    j     div_done

div_ret_zero:
    slli  t1, s4, 15
    mv    a0, t1
    j     div_done

div_ret_a:
    mv    a0, s0
    j     div_done
div_ret_b:
    mv    a0, s1
    j     div_done
div_ret_nan:
    li    a0, 0x7FC0
    j     div_done

div_prep:
    # add hidden 1 if normalized
    beqz  s5, div_nohid_a
    ori   s7, s7, 0x80
div_nohid_a:
    beqz  s6, div_nohid_b
    ori   s8, s8, 0x80
div_nohid_b:

    # long division to 16-bit quotient
    slli  t2, s7, 15      # dividend
    mv    t3, s8          # divisor
    li    t4, 0           # quotient
    li    t5, 0
    li    t6, 16             # 會跑 16 次：shift = 15..0
div_loop:
    addi  t6, t6, -1         # 先減，t6 = 15..0
    slli  t4, t4, 1          # quotient <<= 1

    mv    t5, t3             # t5 = divisor
    addi  t1, t6, 0          # t1 = 當前位移量 (15..0)
    sll   t5, t5, t1         # t5 = divisor << shift

    bgeu  t2, t5, div_sub_ok
    j     div_next
div_sub_ok:
    sub   t2, t2, t5         # dividend -= (divisor << shift)
    ori   t4, t4, 1          # quotient|=1
div_next:
    bnez  t6, div_loop

    # result_exp = exp_a - exp_b + 127; adjust for subnormals
    la    t0, BF16_EXP_BIAS
    lw    t0, 0(t0)
    sub   t1, s5, s6
    add   t1, t1, t0

    beqz  s5, div_adj_a
    j     div_adj_b
div_adj_a:
    addi  t1, t1, -1
div_adj_b:
    beqz  s6, div_adj_b2
    j     div_norm
div_adj_b2:
    addi  t1, t1, 1

div_norm:
    # normalize quotient to have bit15 set then >>8 to 7-bit mant
    li    t0, 0x8000
    and   t2, t4, t0
    bnez  t2, div_hi
    # shift left until bit15 set, dec exp
    li    t2, 0x8000
div_norm2:
    and   t5, t4, t2
    bnez  t5, div_shift_done
    slli  t4, t4, 1
    addi  t1, t1, -1
    j     div_norm2
div_shift_done:
    srli  t4, t4, 8
    j     div_pack
div_hi:
    srli  t4, t4, 8

div_pack:
    andi  t4, t4, 0x7F
    li    t2, 0xFF
    bge   t1, t2, div_ret_inf
    blez  t1, div_underflow

    slli  t0, s4, 15
    slli  t2, t1, 7
    or    t0, t0, t2
    or    t0, t0, t4
    mv    a0, t0
    j     div_done

div_ret_inf:
    slli  t0, s4, 15
    li t1, 0x7F80
    or  t0, t0, t1
    mv    a0, t0
    j     div_done

div_underflow:
    slli  t0, s4, 15
    mv    a0, t0

div_done:
    lw    s11,4(sp)
    lw    s10,8(sp)
    lw    s9, 12(sp)
    lw    s8, 16(sp)
    lw    s7, 20(sp)
    lw    s6, 24(sp)
    lw    s5, 28(sp)
    lw    s4, 32(sp)
    lw    s3, 36(sp)
    lw    s2, 40(sp)
    lw    s1, 44(sp)
    lw    s0, 48(sp)
    lw    ra, 52(sp)
    addi  sp, sp, 56
    ret
############################################################################################
# bf16_sqrt(a0=a) -> a0=result
############################################################################################
bf16_sqrt:
    addi  sp, sp, -40
    sw    ra, 36(sp)
    sw    s0, 32(sp)
    sw    s1, 28(sp)
    sw    s2, 24(sp)
    sw    s3, 20(sp)
    sw    s4, 16(sp)
    sw    s5, 12(sp)
    sw    s6, 8(sp)
    sw    s7, 4(sp)

    mv    s0, a0
    srli  s1, s0, 15
    andi  s1, s1, 1       # sign
    srli  s2, s0, 7
    andi  s2, s2, 0xFF    # exp
    andi  s3, s0, 0x7F    # mant

    # if exp==0xFF
    li    t0, 0xFF
    bne   s2, t0, sqrt_check_zero
    bnez  s3, sqrt_ret_a       # NaN propagate
    bnez  s1, sqrt_ret_nan     # sqrt(-Inf) = NaN
    mv    a0, s0               # +Inf
    j     sqrt_done

sqrt_check_zero:
    beqz  s2, sqrt_chk_mant
    j     sqrt_check_sign
sqrt_chk_mant:
    beqz  s3, sqrt_ret_zero
sqrt_check_sign:
    bnez  s1, sqrt_ret_nan     # negative -> NaN
    beqz  s2, sqrt_ret_zero    # denorm -> 0

    # e = exp - 127
    la    t1, BF16_EXP_BIAS
    lw    t1, 0(t1)
    sub   s4, s2, t1           # s4 = e

    # m = 0x80 | mant
    ori   s5, s3, 0x80

    # odd exponent?
    andi  t2, s4, 1
    beqz  t2, sqrt_even_exp
    slli  s5, s5, 1
    addi  s4, s4, -1
sqrt_even_exp:
    srai  s4, s4, 1
    add   s4, s4, t1           # new_exp = (e>>1)+bias

    # binary search for sqrt(m)
    li    t3, 90
    li    t4, 256
    li    s6, 128
sqrt_loop:
    bgt   t3, t4, sqrt_loop_end
    add   t5, t3, t4
    srli  t5, t5, 1
    mul   t6, t5, t5
    srli  t6, t6, 7
    ble   t6, s5, sqrt_set
    j     sqrt_high
sqrt_set:
    mv    s6, t5
    addi  t3, t5, 1
    j     sqrt_loop
sqrt_high:
    addi  t4, t5, -1
    j     sqrt_loop
sqrt_loop_end:

    mv    s5, s6

    # normalize to [128,256]
    li    t0, 256
    bge   s5, t0, sqrt_shift_r
    li    t0, 128
    blt   s5, t0, sqrt_shift_l
    j     sqrt_pack
sqrt_shift_r:
    srli  s5, s5, 1
    addi  s4, s4, 1
    j     sqrt_pack
sqrt_shift_l:
    li    t0, 128
sqrt_l_loop:
    bge   s5, t0, sqrt_pack
    slli  s5, s5, 1
    addi  s4, s4, -1
    j     sqrt_l_loop

sqrt_pack:
    andi  s5, s5, 0x7F
    li    t0, 0xFF
    bge   s4, t0, sqrt_ret_inf
    blez  s4, sqrt_ret_zero

    slli  t1, s4, 7
    or    a0, t1, s5
    j     sqrt_done

sqrt_ret_a:
    mv    a0, s0
    j     sqrt_done
sqrt_ret_inf:
    li    a0, 0x7F80
    j     sqrt_done
sqrt_ret_nan:
    li    a0, 0x7FC0
    j     sqrt_done
sqrt_ret_zero:
    li    a0, 0x0000

sqrt_done:
    lw    s7, 4(sp)
    lw    s6, 8(sp)
    lw    s5, 12(sp)
    lw    s4, 16(sp)
    lw    s3, 20(sp)
    lw    s2, 24(sp)
    lw    s1, 28(sp)
    lw    s0, 32(sp)
    lw    ra, 36(sp)
    addi  sp, sp, 40
    ret
############################################################################################
# Printing helpers
############################################################################################
# print_hex16bits(a0 = 0xHHHH)
print_hex16bits:
    addi  sp, sp, -16
    sw    ra, 12(sp)
    sw    t0, 8(sp)
    sw    t1, 4(sp)
    sw    t2, 0(sp)

    mv    t1, a0
    li    t2, 12
hex16_loop:
    srl   t0, t1, t2
    andi  t0, t0, 0xF
    la    a0, hexchars
    add   a0, a0, t0
    lbu   a0, 0(a0)
    li    a7, 11
    ecall
    addi  t2, t2, -4
    bgez  t2, hex16_loop

    lw    t2, 0(sp)
    lw    t1, 4(sp)
    lw    t0, 8(sp)
    lw    ra, 12(sp)
    addi  sp, sp, 16
    ret

# print_hex32bits(a0 = 0xHHHHHHHH)
print_hex32bits:
    addi  sp, sp, -16
    sw    ra, 12(sp)
    sw    t0, 8(sp)
    sw    t1, 4(sp)
    sw    t2, 0(sp)

    mv    t1, a0
    li    t2, 28
hex32_loop:
    srl   t0, t1, t2
    andi  t0, t0, 0xF
    la    a0, hexchars
    add   a0, a0, t0
    lbu   a0, 0(a0)
    li    a7, 11
    ecall
    addi  t2, t2, -4
    bgez  t2, hex32_loop

    lw    t2, 0(sp)
    lw    t1, 4(sp)
    lw    t0, 8(sp)
    lw    ra, 12(sp)
    addi  sp, sp, 16
    ret
