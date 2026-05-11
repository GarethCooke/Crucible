
/home/gcooke/Development/Projects/Crucible/bench/build/demos/03-simd-blackscholes/CMakeFiles/bs_scalar_libm.dir/scalar_libm.cpp.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)>:
   0:	endbr64
   4:	push   rbp
   5:	mov    rbp,rsp
   8:	push   r15
   a:	push   r14
   c:	push   r13
   e:	push   r12
  10:	push   rbx
  11:	sub    rsp,0x38
  15:	cmp    QWORD PTR [rbp+0x10],0x0
  1a:	mov    QWORD PTR [rbp-0x58],rdi
  1e:	mov    QWORD PTR [rbp-0x60],rsi
  22:	jle    18b <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x18b>
  28:	mov    r14,r8
  2b:	mov    r15,r9
  2e:	xor    ebx,ebx
  30:	mov    r13,rdx
  33:	mov    r12,rcx
  36:	cs nop WORD PTR [rax+rax*1+0x0]
  40:	movss  xmm6,DWORD PTR [r12+rbx*4]
  46:	mov    rax,QWORD PTR [rbp-0x58]
  4a:	movss  xmm3,DWORD PTR [r13+rbx*4+0x0]
  51:	movss  xmm5,DWORD PTR [r14+rbx*4]
  57:	movss  xmm4,DWORD PTR [rax+rbx*4]
  5c:	mov    rax,QWORD PTR [rbp-0x60]
  60:	movss  DWORD PTR [rbp-0x34],xmm6
  65:	pxor   xmm6,xmm6
  69:	movss  xmm2,DWORD PTR [rax+rbx*4]
  6e:	ucomiss xmm6,xmm3
  71:	ja     19a <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x19a>
  77:	movaps xmm0,xmm3
  7a:	sqrtss xmm0,xmm0
  7e:	movaps xmm7,xmm4
  81:	mulss  xmm0,xmm5
  85:	movss  DWORD PTR [rbp-0x4c],xmm4
  8a:	movss  DWORD PTR [rbp-0x48],xmm2
  8f:	divss  xmm7,xmm2
  93:	movss  DWORD PTR [rbp-0x40],xmm3
  98:	movss  DWORD PTR [rbp-0x3c],xmm5
  9d:	movss  DWORD PTR [rbp-0x38],xmm0
  a2:	movaps xmm0,xmm7
  a5:	call   aa <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0xaa>
  aa:	movss  xmm5,DWORD PTR [rbp-0x3c]
  af:	movss  xmm1,DWORD PTR [rip+0x0]        # b7 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0xb7>
  b7:	movss  xmm3,DWORD PTR [rbp-0x40]
  bc:	mulss  xmm1,xmm5
  c0:	movss  DWORD PTR [rbp-0x44],xmm3
  c5:	mulss  xmm5,xmm1
  c9:	addss  xmm5,DWORD PTR [rbp-0x34]
  ce:	mulss  xmm5,xmm3
  d2:	addss  xmm5,xmm0
  d6:	divss  xmm5,DWORD PTR [rbp-0x38]
  db:	movss  xmm0,DWORD PTR [rip+0x0]        # e3 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0xe3>
  e3:	movaps xmm7,xmm5
  e6:	xorps  xmm7,XMMWORD PTR [rip+0x0]        # ed <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0xed>
  ed:	movss  DWORD PTR [rbp-0x40],xmm5
  f2:	mulss  xmm0,xmm7
  f6:	call   fb <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0xfb>
  fb:	movss  xmm5,DWORD PTR [rbp-0x40]
 100:	subss  xmm5,DWORD PTR [rbp-0x38]
 105:	movss  DWORD PTR [rbp-0x3c],xmm0
 10a:	movss  xmm0,DWORD PTR [rip+0x0]        # 112 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x112>
 112:	xorps  xmm5,XMMWORD PTR [rip+0x0]        # 119 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x119>
 119:	mulss  xmm0,xmm5
 11d:	call   122 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x122>
 122:	movss  xmm3,DWORD PTR [rbp-0x44]
 127:	movss  DWORD PTR [rbp-0x38],xmm0
 12c:	movss  xmm0,DWORD PTR [rbp-0x34]
 131:	xorps  xmm0,XMMWORD PTR [rip+0x0]        # 138 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x138>
 138:	mulss  xmm0,xmm3
 13c:	call   141 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x141>
 141:	movss  xmm2,DWORD PTR [rbp-0x48]
 146:	movaps xmm1,xmm0
 149:	movss  xmm0,DWORD PTR [rip+0x0]        # 151 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x151>
 151:	movss  xmm4,DWORD PTR [rbp-0x4c]
 156:	mulss  xmm0,DWORD PTR [rbp-0x3c]
 15b:	mulss  xmm2,xmm1
 15f:	movss  xmm1,DWORD PTR [rip+0x0]        # 167 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x167>
 167:	mulss  xmm1,DWORD PTR [rbp-0x38]
 16c:	mulss  xmm0,xmm4
 170:	mulss  xmm2,xmm1
 174:	subss  xmm0,xmm2
 178:	movss  DWORD PTR [r15+rbx*4],xmm0
 17e:	inc    rbx
 181:	cmp    QWORD PTR [rbp+0x10],rbx
 185:	jne    40 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x40>
 18b:	add    rsp,0x38
 18f:	pop    rbx
 190:	pop    r12
 192:	pop    r13
 194:	pop    r14
 196:	pop    r15
 198:	pop    rbp
 199:	ret
 19a:	movaps xmm0,xmm3
 19d:	movss  DWORD PTR [rbp-0x44],xmm5
 1a2:	movss  DWORD PTR [rbp-0x40],xmm2
 1a7:	movss  DWORD PTR [rbp-0x3c],xmm4
 1ac:	movss  DWORD PTR [rbp-0x38],xmm3
 1b1:	call   1b6 <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1b6>
 1b6:	movss  xmm5,DWORD PTR [rbp-0x44]
 1bb:	movss  xmm2,DWORD PTR [rbp-0x40]
 1c0:	movss  xmm4,DWORD PTR [rbp-0x3c]
 1c5:	movss  xmm3,DWORD PTR [rbp-0x38]
 1ca:	jmp    7e <price_options_scalar_libm(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7e>
