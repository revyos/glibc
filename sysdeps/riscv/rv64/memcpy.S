/* The assembly function for memcpy.  RISC-V version.
   Copyright (C) 2018 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library.  If not, see
   <http://www.gnu.org/licenses/>.  */

#include <sysdep.h>

#  define LABLE_ALIGN   \
        .balignl 16, 0x00000013

#if defined(__riscv_v) && (__riscv_v >= 1000000)
# define VLDB vle8.v
# define VSTB vse8.v
#else
# define VLDB vlb.v
# define VSTB vsb.v
#endif

ENTRY (memcpy)
#if defined(__riscv_vector)
	mv	a3, a0
	sltiu	a4, a2, 16
	bnez	a4, .loop_cpy
	andi	a5, a0, 15
	li	a6, 16
	beqz	a5, .loop_cpy
	sub	a5, a6, a5
	vsetvli	t0, a5, e8, m4
	VLDB	v0, (a1)
	add	a1, a1, t0
	sub	a2, a2, t0
	VSTB	v0, (a3)
	add	a3, a3, t0
.loop_cpy:
	vsetvli	t0, a2, e8, m4
	VLDB	v0, (a1)
	add	a1, a1, t0
	sub	a2, a2, t0
	VSTB	v0, (a3)
	add	a3, a3, t0
	bnez	a2, .loop_cpy
	ret
#else
        /* Test if len less than 8 bytes.  */
        mv      t6, a0
        sltiu   a3, a2, 8
        li     t3, 1
        bnez    a3, .L_copy_by_byte

        andi    a3, a0, 7
        li     t5, 8
	/* Test if dest is not 8 bytes aligned.  */
        bnez    a3, .L_dest_not_aligned
.L_dest_aligned:
        /* If dest is aligned, then copy.  */
        srli    t4, a2, 6
        /* Test if len less than 32 bytes.  */
        beqz     t4, .L_len_less_16bytes
	andi    a2, a2, 63

.L_len_larger_16bytes:
#if defined(__riscv_xtheadc)
	ldd	a4, a5, 0(a1)
	sdd	a4, a5, 0(a0)
	ldd	a6, a7, 16(a1)
	sdd	a6, a7, 16(a0)
	ldd	a4, a5, 32(a1)
	sdd	a4, a5, 32(a0)
	ldd	a6, a7, 48(a1)
	sub	t4, t4, t3
        addi    a1, a1, 64
	sdd	a6, a7, 48(a0)
#else
        ld      a4, 0(a1)
        sd      a4, 0(a0)
        ld      a5, 8(a1)
        sd      a5, 8(a0)
        ld      a6, 16(a1)
        sd      a6, 16(a0)
        ld      a7, 24(a1)
        sd      a7, 24(a0)
        ld      a4, 32(a1)
        sd      a4, 32(a0)
        ld      a5, 40(a1)
        sd      a5, 40(a0)
        ld      a6, 48(a1)
        sd      a6, 48(a0)
        ld      a7, 56(a1)
        sub     t4, t4, t3
        addi    a1, a1, 64
        sd      a7, 56(a0)
#endif
        addi    a0, a0, 64
	bnez	t4, .L_len_larger_16bytes

.L_len_less_16bytes:
	srli    t4, a2, 2
        beqz     t4, .L_copy_by_byte
        andi    a2, a2, 3
.L_len_less_16bytes_loop:
        lw      a4, 0(a1)
	sub	t4, t4, t3
        addi    a1, a1, 4
        sw      a4, 0(a0)
        addi    a0, a0, 4
	bnez    t4, .L_len_less_16bytes_loop

        /* Copy tail.  */
.L_copy_by_byte:
        andi    t4, a2, 7
        beqz     t4, .L_return
.L_copy_by_byte_loop:
        lb     a4, 0(a1)
	sub	t4, t4, t3
        addi    a1, a1, 1
        sb     a4, 0(a0)
        addi    a0, a0, 1
	bnez	t4, .L_copy_by_byte_loop

.L_return:
        mv      a0, t6
        ret

        /* If dest is not aligned, just copying some bytes makes the dest
           align.  */
.L_dest_not_aligned:
        sub     a3, t5, a3
        mv      t5, a3
.L_dest_not_aligned_loop:
        /* Makes the dest align.  */
        lb     a4, 0(a1)
	sub	a3, a3, t3
        addi    a1, a1, 1
        sb     a4, 0(a0)
        addi    a0, a0, 1
	bnez	a3, .L_dest_not_aligned_loop
        sub     a2, a2, t5
	sltiu	a3, a2, 4
        bnez    a3, .L_copy_by_byte
        /* Check whether the src is aligned.  */
        j		.L_dest_aligned
#endif
END (memcpy)

libc_hidden_builtin_def (memcpy)
.weak memcpy