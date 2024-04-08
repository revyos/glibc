/* ldconfig default paths and libraries.  Linux/RISC-V version.
   Copyright (C) 2001-2022 Free Software Foundation, Inc.
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
   <https://www.gnu.org/licenses/>.  */

#include <sysdeps/generic/ldconfig.h>

#define LD_SO_PREFIX "/lib/ld-linux-"
#define LD_SO_SUFFIX ".so.1"

#if __riscv_xlen == 64
#if defined(__riscv_xthead) && defined(__riscv_v)
#if __riscv_v >= 1000000
# define LD_SO_ABI "riscv64v_xthead-lp64"
#else
# define LD_SO_ABI "riscv64v0p7_xthead-lp64"
#endif
#elif defined(__riscv_xthead)
# define LD_SO_ABI "riscv64xthead-lp64"
#else
# define LD_SO_ABI "riscv64-lp64"
#endif
#else
#if defined(__riscv_xthead) && defined(__riscv_v)
# define LD_SO_ABI "riscv32v_xthead-ilp32"
#elif defined(__riscv_xthead)
# define LD_SO_ABI "riscv32xthead-ilp32"
#else
# define LD_SO_ABI "riscv32-ilp32"
#endif
#endif

#define SYSDEP_KNOWN_INTERPRETER_NAMES				\
  { LD_SO_PREFIX LD_SO_ABI "v" LD_SO_SUFFIX, FLAG_ELF_LIBC6 },  \
  { LD_SO_PREFIX LD_SO_ABI "d" LD_SO_SUFFIX, FLAG_ELF_LIBC6 },	\
  { LD_SO_PREFIX LD_SO_ABI "dv" LD_SO_SUFFIX, FLAG_ELF_LIBC6 }, \
  { LD_SO_PREFIX LD_SO_ABI     LD_SO_SUFFIX, FLAG_ELF_LIBC6 },

#define SYSDEP_KNOWN_LIBRARY_NAMES	\
  { "libc.so.6", FLAG_ELF_LIBC6 },	\
  { "libm.so.6", FLAG_ELF_LIBC6 },
