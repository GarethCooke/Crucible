
/home/gcooke/Development/Projects/Crucible/bench/build/demos/03-simd-blackscholes/CMakeFiles/bs_sse2.dir/sse2_intrinsics.cpp.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)>:
   0:	endbr64
   4:	push   rbp
   5:	mov    rbp,rsp
   8:	push   r15
   a:	push   r14
   c:	push   r13
   e:	push   r12
  10:	push   rbx
  11:	mov    r13,rdi
  14:	mov    r14,rsi
  17:	sub    rsp,0x38
  1b:	cmp    QWORD PTR [rbp+0x10],0x3
  20:	mov    r15,rdx
  23:	mov    r12,rcx
  26:	jle    a60 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa60>
  2c:	movss  xmm6,DWORD PTR [rip+0x0]        # 34 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x34>
  34:	movss  xmm7,DWORD PTR [rip+0x0]        # 3c <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3c>
  3c:	movss  xmm13,DWORD PTR [rip+0x0]        # 45 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x45>
  45:	movss  xmm3,DWORD PTR [rip+0x0]        # 4d <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4d>
  4d:	movss  xmm12,DWORD PTR [rip+0x0]        # 56 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x56>
  56:	movss  xmm8,DWORD PTR [rip+0x0]        # 5f <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5f>
  5f:	movss  xmm11,DWORD PTR [rip+0x0]        # 68 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x68>
  68:	movss  xmm10,DWORD PTR [rip+0x0]        # 71 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x71>
  71:	movss  xmm9,DWORD PTR [rip+0x0]        # 7a <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7a>
  7a:	mov    rax,QWORD PTR [rbp+0x10]
  7e:	lea    rsi,[rax-0x4]
  82:	shufps xmm6,xmm6,0x0
  86:	xor    eax,eax
  88:	shufps xmm7,xmm7,0x0
  8c:	mov    rcx,rsi
  8f:	shufps xmm13,xmm13,0x0
  94:	shufps xmm3,xmm3,0x0
  98:	and    rcx,0xfffffffffffffffc
  9c:	shufps xmm12,xmm12,0x0
  a1:	shufps xmm8,xmm8,0x0
  a6:	add    rcx,0x4
  aa:	shufps xmm11,xmm11,0x0
  af:	shufps xmm10,xmm10,0x0
  b4:	shufps xmm9,xmm9,0x0
  b9:	nop    DWORD PTR [rax+0x0]
  c0:	movaps xmm2,XMMWORD PTR [r13+rax*4+0x0]
  c6:	movaps xmm14,XMMWORD PTR [r8+rax*4]
  cb:	sqrtps xmm0,XMMWORD PTR [r15+rax*4]
  d0:	movaps xmm4,xmm6
  d3:	divps  xmm2,XMMWORD PTR [r14+rax*4]
  d8:	movaps xmm5,xmm14
  dc:	mulps  xmm5,xmm14
  e0:	mulps  xmm14,xmm0
  e4:	movss  xmm0,DWORD PTR [rip+0x0]        # ec <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0xec>
  ec:	mulps  xmm5,xmm6
  ef:	addps  xmm5,XMMWORD PTR [r12+rax*4]
  f4:	mulps  xmm5,XMMWORD PTR [r15+rax*4]
  f9:	shufps xmm0,xmm0,0x0
  fd:	movdqa xmm1,xmm2
 101:	pand   xmm2,XMMWORD PTR [rip+0x0]        # 109 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x109>
 109:	por    xmm2,XMMWORD PTR [rip+0x0]        # 111 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x111>
 111:	psrld  xmm1,0x17
 116:	paddd  xmm1,XMMWORD PTR [rip+0x0]        # 11e <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x11e>
 11e:	mulps  xmm4,xmm2
 121:	cmpleps xmm0,xmm2
 125:	blendvps xmm2,xmm4,xmm0
 12a:	pand   xmm0,XMMWORD PTR [rip+0x0]        # 132 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x132>
 132:	addps  xmm2,XMMWORD PTR [rip+0x0]        # 139 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x139>
 139:	paddd  xmm1,xmm0
 13d:	cvtdq2ps xmm0,xmm1
 140:	movaps xmm1,XMMWORD PTR [rip+0x0]        # 147 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x147>
 147:	movaps xmm15,xmm2
 14b:	movaps xmm4,xmm2
 14e:	mulps  xmm15,xmm2
 152:	mulps  xmm0,xmm7
 155:	mulps  xmm4,xmm15
 159:	mulps  xmm15,xmm6
 15d:	mulps  xmm1,xmm2
 160:	addps  xmm1,XMMWORD PTR [rip+0x0]        # 167 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x167>
 167:	mulps  xmm1,xmm2
 16a:	addps  xmm1,XMMWORD PTR [rip+0x0]        # 171 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x171>
 171:	mulps  xmm1,xmm2
 174:	addps  xmm1,XMMWORD PTR [rip+0x0]        # 17b <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x17b>
 17b:	mulps  xmm1,xmm2
 17e:	addps  xmm1,XMMWORD PTR [rip+0x0]        # 185 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x185>
 185:	mulps  xmm1,xmm2
 188:	addps  xmm1,XMMWORD PTR [rip+0x0]        # 18f <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x18f>
 18f:	mulps  xmm1,xmm2
 192:	addps  xmm1,XMMWORD PTR [rip+0x0]        # 199 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x199>
 199:	mulps  xmm1,xmm2
 19c:	addps  xmm1,XMMWORD PTR [rip+0x0]        # 1a3 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1a3>
 1a3:	mulps  xmm1,xmm2
 1a6:	addps  xmm1,XMMWORD PTR [rip+0x0]        # 1ad <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1ad>
 1ad:	mulps  xmm4,xmm1
 1b0:	movaps xmm1,XMMWORD PTR [rip+0x0]        # 1b7 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1b7>
 1b7:	subps  xmm4,xmm15
 1bb:	pxor   xmm15,xmm15
 1c0:	addps  xmm4,xmm2
 1c3:	addps  xmm4,xmm0
 1c6:	addps  xmm4,xmm5
 1c9:	divps  xmm4,xmm14
 1cd:	movaps xmm2,xmm4
 1d0:	movaps xmm0,xmm4
 1d3:	subps  xmm2,xmm14
 1d7:	movaps xmm14,xmm13
 1db:	cmpltps xmm0,xmm15
 1e0:	andnps xmm14,xmm4
 1e4:	movaps xmm4,xmm3
 1e7:	mulps  xmm1,xmm14
 1eb:	mulps  xmm14,xmm14
 1ef:	mulps  xmm14,XMMWORD PTR [rip+0x0]        # 1f7 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1f7>
 1f7:	maxps  xmm14,XMMWORD PTR [rip+0x0]        # 1ff <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1ff>
 1ff:	addps  xmm1,xmm3
 202:	minps  xmm14,XMMWORD PTR [rip+0x0]        # 20a <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x20a>
 20a:	divps  xmm4,xmm1
 20d:	movaps xmm5,xmm14
 211:	mulps  xmm5,xmm12
 215:	roundps xmm5,xmm5,0x8
 21b:	movaps xmm1,xmm5
 21e:	cvtps2dq xmm5,xmm5
 222:	paddd  xmm5,XMMWORD PTR [rip+0x0]        # 22a <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x22a>
 22a:	mulps  xmm1,xmm7
 22d:	subps  xmm14,xmm1
 231:	movaps xmm1,xmm14
 235:	mulps  xmm1,xmm8
 239:	pslld  xmm5,0x17
 23e:	addps  xmm1,xmm11
 242:	mulps  xmm1,xmm14
 246:	addps  xmm1,xmm10
 24a:	mulps  xmm1,xmm14
 24e:	addps  xmm1,xmm9
 252:	mulps  xmm1,xmm14
 256:	addps  xmm1,xmm6
 259:	mulps  xmm1,xmm14
 25d:	addps  xmm1,xmm3
 260:	mulps  xmm1,xmm14
 264:	movaps xmm14,xmm3
 268:	addps  xmm1,xmm3
 26b:	mulps  xmm1,xmm5
 26e:	movaps xmm5,XMMWORD PTR [rip+0x0]        # 275 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x275>
 275:	mulps  xmm1,XMMWORD PTR [rip+0x0]        # 27c <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x27c>
 27c:	mulps  xmm5,xmm4
 27f:	addps  xmm5,XMMWORD PTR [rip+0x0]        # 286 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x286>
 286:	mulps  xmm5,xmm4
 289:	addps  xmm5,XMMWORD PTR [rip+0x0]        # 290 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x290>
 290:	mulps  xmm5,xmm4
 293:	addps  xmm5,XMMWORD PTR [rip+0x0]        # 29a <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x29a>
 29a:	mulps  xmm5,xmm4
 29d:	addps  xmm5,XMMWORD PTR [rip+0x0]        # 2a4 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2a4>
 2a4:	mulps  xmm4,xmm5
 2a7:	movaps xmm5,xmm13
 2ab:	andnps xmm5,xmm2
 2ae:	mulps  xmm1,xmm4
 2b1:	subps  xmm14,xmm1
 2b5:	blendvps xmm14,xmm1,xmm0
 2bb:	movaps xmm1,XMMWORD PTR [rip+0x0]        # 2c2 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2c2>
 2c2:	movaps xmm0,xmm2
 2c5:	movaps xmm2,xmm3
 2c8:	cmpltps xmm0,xmm15
 2cd:	mulps  xmm1,xmm5
 2d0:	mulps  xmm5,xmm5
 2d3:	mulps  xmm5,XMMWORD PTR [rip+0x0]        # 2da <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2da>
 2da:	maxps  xmm5,XMMWORD PTR [rip+0x0]        # 2e1 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2e1>
 2e1:	addps  xmm1,xmm3
 2e4:	minps  xmm5,XMMWORD PTR [rip+0x0]        # 2eb <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2eb>
 2eb:	divps  xmm2,xmm1
 2ee:	movaps xmm4,xmm5
 2f1:	mulps  xmm4,xmm12
 2f5:	roundps xmm4,xmm4,0x8
 2fb:	movaps xmm1,xmm4
 2fe:	cvtps2dq xmm4,xmm4
 302:	paddd  xmm4,XMMWORD PTR [rip+0x0]        # 30a <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x30a>
 30a:	mulps  xmm1,xmm7
 30d:	subps  xmm5,xmm1
 310:	movaps xmm1,xmm5
 313:	mulps  xmm1,xmm8
 317:	pslld  xmm4,0x17
 31c:	addps  xmm1,xmm11
 320:	mulps  xmm1,xmm5
 323:	addps  xmm1,xmm10
 327:	mulps  xmm1,xmm5
 32a:	addps  xmm1,xmm9
 32e:	mulps  xmm1,xmm5
 331:	addps  xmm1,xmm6
 334:	mulps  xmm1,xmm5
 337:	addps  xmm1,xmm3
 33a:	mulps  xmm1,xmm5
 33d:	movaps xmm5,XMMWORD PTR [r15+rax*4]
 342:	mulps  xmm5,XMMWORD PTR [r12+rax*4]
 347:	addps  xmm1,xmm3
 34a:	mulps  xmm1,xmm4
 34d:	movaps xmm4,XMMWORD PTR [rip+0x0]        # 354 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x354>
 354:	mulps  xmm1,XMMWORD PTR [rip+0x0]        # 35b <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x35b>
 35b:	xorps  xmm5,xmm13
 35f:	maxps  xmm5,XMMWORD PTR [rip+0x0]        # 366 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x366>
 366:	mulps  xmm4,xmm2
 369:	addps  xmm4,XMMWORD PTR [rip+0x0]        # 370 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x370>
 370:	minps  xmm5,XMMWORD PTR [rip+0x0]        # 377 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x377>
 377:	mulps  xmm4,xmm2
 37a:	addps  xmm4,XMMWORD PTR [rip+0x0]        # 381 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x381>
 381:	mulps  xmm4,xmm2
 384:	addps  xmm4,XMMWORD PTR [rip+0x0]        # 38b <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x38b>
 38b:	mulps  xmm4,xmm2
 38e:	addps  xmm4,XMMWORD PTR [rip+0x0]        # 395 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x395>
 395:	mulps  xmm2,xmm4
 398:	movaps xmm4,xmm5
 39b:	mulps  xmm4,xmm12
 39f:	mulps  xmm1,xmm2
 3a2:	movaps xmm2,xmm3
 3a5:	roundps xmm4,xmm4,0x8
 3ab:	subps  xmm2,xmm1
 3ae:	blendvps xmm2,xmm1,xmm0
 3b3:	movaps xmm0,xmm4
 3b6:	cvtps2dq xmm4,xmm4
 3ba:	paddd  xmm4,XMMWORD PTR [rip+0x0]        # 3c2 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3c2>
 3c2:	mulps  xmm0,xmm7
 3c5:	movaps xmm1,XMMWORD PTR [r13+rax*4+0x0]
 3cb:	subps  xmm5,xmm0
 3ce:	movaps xmm0,xmm5
 3d1:	mulps  xmm0,xmm8
 3d5:	pslld  xmm4,0x17
 3da:	mulps  xmm1,xmm14
 3de:	addps  xmm0,xmm11
 3e2:	mulps  xmm0,xmm5
 3e5:	addps  xmm0,xmm10
 3e9:	mulps  xmm0,xmm5
 3ec:	addps  xmm0,xmm9
 3f0:	mulps  xmm0,xmm5
 3f3:	addps  xmm0,xmm6
 3f6:	mulps  xmm0,xmm5
 3f9:	addps  xmm0,xmm3
 3fc:	mulps  xmm0,xmm5
 3ff:	addps  xmm0,xmm3
 402:	mulps  xmm0,xmm4
 405:	mulps  xmm0,XMMWORD PTR [r14+rax*4]
 40a:	mulps  xmm0,xmm2
 40d:	subps  xmm1,xmm0
 410:	movaps XMMWORD PTR [r9+rax*4],xmm1
 415:	add    rax,0x4
 419:	cmp    rax,rcx
 41c:	jne    c0 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0xc0>
 422:	shr    rsi,0x2
 426:	lea    rbx,[rsi*4+0x4]
 42e:	cmp    QWORD PTR [rbp+0x10],rbx
 432:	jle    73b <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x73b>
 438:	mov    QWORD PTR [rbp-0x58],r9
 43c:	pxor   xmm3,xmm3
 440:	mov    r9,rbx
 443:	mov    rbx,r8
 446:	movss  xmm1,DWORD PTR [rbx+r9*4]
 44c:	movss  xmm8,DWORD PTR [r15+r9*4]
 452:	movss  xmm7,DWORD PTR [r12+r9*4]
 458:	movss  xmm9,DWORD PTR [r14+r9*4]
 45e:	movss  xmm10,DWORD PTR [r13+r9*4+0x0]
 465:	movaps xmm6,xmm1
 468:	mulss  xmm6,xmm1
 46c:	ucomiss xmm3,xmm8
 470:	movss  DWORD PTR [rbp-0x34],xmm6
 475:	ja     a67 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa67>
 47b:	movaps xmm0,xmm8
 47f:	sqrtss xmm0,xmm0
 483:	mulss  xmm1,xmm0
 487:	movaps xmm0,xmm10
 48b:	mov    QWORD PTR [rbp-0x50],r9
 48f:	movss  DWORD PTR [rbp-0x48],xmm8
 495:	divss  xmm0,xmm9
 49a:	movss  DWORD PTR [rbp-0x44],xmm7
 49f:	movss  DWORD PTR [rbp-0x3c],xmm10
 4a5:	movss  DWORD PTR [rbp-0x38],xmm9
 4ab:	movss  DWORD PTR [rbp-0x40],xmm1
 4b0:	call   4b5 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4b5>
 4b5:	movss  xmm4,DWORD PTR [rip+0x0]        # 4bd <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4bd>
 4bd:	pxor   xmm3,xmm3
 4c1:	movaps xmm6,xmm0
 4c4:	movss  xmm0,DWORD PTR [rbp-0x34]
 4c9:	movss  xmm7,DWORD PTR [rbp-0x44]
 4ce:	movss  xmm8,DWORD PTR [rbp-0x48]
 4d4:	movss  xmm1,DWORD PTR [rbp-0x40]
 4d9:	movss  xmm9,DWORD PTR [rbp-0x38]
 4df:	movss  xmm10,DWORD PTR [rbp-0x3c]
 4e5:	movss  xmm5,DWORD PTR [rip+0x0]        # 4ed <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4ed>
 4ed:	movss  xmm2,DWORD PTR [rip+0x0]        # 4f5 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4f5>
 4f5:	mov    r9,QWORD PTR [rbp-0x50]
 4f9:	mulss  xmm0,xmm4
 4fd:	addss  xmm0,xmm7
 501:	mulss  xmm0,xmm8
 506:	addss  xmm0,xmm6
 50a:	divss  xmm0,xmm1
 50e:	movaps xmm6,xmm0
 511:	movaps xmm11,xmm0
 515:	comiss xmm3,xmm0
 518:	subss  xmm6,xmm1
 51c:	ja     800 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x800>
 522:	movss  xmm1,DWORD PTR [rip+0x0]        # 52a <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x52a>
 52a:	movss  xmm12,DWORD PTR [rip+0x0]        # 533 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x533>
 533:	mulss  xmm1,xmm0
 537:	mulss  xmm12,xmm11
 53c:	movaps xmm0,xmm2
 53f:	addss  xmm1,xmm2
 543:	mulss  xmm12,xmm11
 548:	divss  xmm0,xmm1
 54c:	movss  xmm1,DWORD PTR [rip+0x0]        # 554 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x554>
 554:	comiss xmm5,xmm12
 558:	mulss  xmm1,xmm0
 55c:	subss  xmm1,DWORD PTR [rip+0x0]        # 564 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x564>
 564:	mulss  xmm1,xmm0
 568:	addss  xmm1,DWORD PTR [rip+0x0]        # 570 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x570>
 570:	mulss  xmm1,xmm0
 574:	subss  xmm1,DWORD PTR [rip+0x0]        # 57c <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x57c>
 57c:	mulss  xmm1,xmm0
 580:	addss  xmm1,DWORD PTR [rip+0x0]        # 588 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x588>
 588:	mulss  xmm0,xmm1
 58c:	ja     8a0 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8a0>
 592:	comiss xmm12,DWORD PTR [rip+0x0]        # 59a <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x59a>
 59a:	movss  xmm1,DWORD PTR [rip+0x0]        # 5a2 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5a2>
 5a2:	jbe    970 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x970>
 5a8:	mulss  xmm0,xmm1
 5ac:	movaps xmm1,xmm2
 5af:	subss  xmm1,xmm0
 5b3:	movaps xmm0,xmm1
 5b6:	xorps  xmm7,XMMWORD PTR [rip+0x0]        # 5bd <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5bd>
 5bd:	mulss  xmm0,xmm10
 5c2:	mulss  xmm7,xmm8
 5c7:	pxor   xmm8,xmm8
 5cc:	comiss xmm5,xmm7
 5cf:	ja     67c <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x67c>
 5d5:	comiss xmm7,DWORD PTR [rip+0x0]        # 5dc <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5dc>
 5dc:	movss  xmm8,DWORD PTR [rip+0x0]        # 5e5 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5e5>
 5e5:	ja     67c <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x67c>
 5eb:	movss  xmm1,DWORD PTR [rip+0x0]        # 5f3 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5f3>
 5f3:	mulss  xmm1,xmm7
 5f7:	comiss xmm1,xmm3
 5fa:	jb     a50 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa50>
 600:	addss  xmm1,xmm4
 604:	cvttss2si edx,xmm1
 608:	movss  xmm1,DWORD PTR [rip+0x0]        # 610 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x610>
 610:	pxor   xmm8,xmm8
 615:	cvtsi2ss xmm8,edx
 61a:	cvttss2si edx,xmm8
 61f:	add    edx,0x7f
 622:	shl    edx,0x17
 625:	mulss  xmm1,xmm8
 62a:	movd   xmm8,edx
 62f:	subss  xmm7,xmm1
 633:	movss  xmm1,DWORD PTR [rip+0x0]        # 63b <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x63b>
 63b:	mulss  xmm1,xmm7
 63f:	addss  xmm1,DWORD PTR [rip+0x0]        # 647 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x647>
 647:	mulss  xmm1,xmm7
 64b:	addss  xmm1,DWORD PTR [rip+0x0]        # 653 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x653>
 653:	mulss  xmm1,xmm7
 657:	addss  xmm1,DWORD PTR [rip+0x0]        # 65f <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x65f>
 65f:	mulss  xmm1,xmm7
 663:	addss  xmm1,xmm4
 667:	mulss  xmm1,xmm7
 66b:	addss  xmm1,xmm2
 66f:	mulss  xmm1,xmm7
 673:	addss  xmm1,xmm2
 677:	mulss  xmm8,xmm1
 67c:	mulss  xmm8,xmm9
 681:	comiss xmm3,xmm6
 684:	ja     750 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x750>
 68a:	movss  xmm1,DWORD PTR [rip+0x0]        # 692 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x692>
 692:	movaps xmm7,xmm2
 695:	movss  xmm9,DWORD PTR [rip+0x0]        # 69e <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x69e>
 69e:	mulss  xmm1,xmm6
 6a2:	mulss  xmm9,xmm6
 6a7:	addss  xmm1,xmm2
 6ab:	mulss  xmm9,xmm6
 6b0:	divss  xmm7,xmm1
 6b4:	movss  xmm1,DWORD PTR [rip+0x0]        # 6bc <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6bc>
 6bc:	comiss xmm5,xmm9
 6c0:	mulss  xmm1,xmm7
 6c4:	subss  xmm1,DWORD PTR [rip+0x0]        # 6cc <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6cc>
 6cc:	mulss  xmm1,xmm7
 6d0:	addss  xmm1,DWORD PTR [rip+0x0]        # 6d8 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6d8>
 6d8:	mulss  xmm1,xmm7
 6dc:	subss  xmm1,DWORD PTR [rip+0x0]        # 6e4 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6e4>
 6e4:	mulss  xmm1,xmm7
 6e8:	addss  xmm1,DWORD PTR [rip+0x0]        # 6f0 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6f0>
 6f0:	mulss  xmm7,xmm1
 6f4:	ja     890 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x890>
 6fa:	comiss xmm9,DWORD PTR [rip+0x0]        # 702 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x702>
 702:	movss  xmm1,DWORD PTR [rip+0x0]        # 70a <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x70a>
 70a:	jbe    8b0 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8b0>
 710:	mulss  xmm7,xmm1
 714:	movaps xmm1,xmm2
 717:	mov    rax,QWORD PTR [rbp-0x58]
 71b:	subss  xmm1,xmm7
 71f:	mulss  xmm1,xmm8
 724:	subss  xmm0,xmm1
 728:	movss  DWORD PTR [rax+r9*4],xmm0
 72e:	inc    r9
 731:	cmp    r9,QWORD PTR [rbp+0x10]
 735:	jne    446 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x446>
 73b:	add    rsp,0x38
 73f:	pop    rbx
 740:	pop    r12
 742:	pop    r13
 744:	pop    r14
 746:	pop    r15
 748:	pop    rbp
 749:	ret
 74a:	nop    WORD PTR [rax+rax*1+0x0]
 750:	movss  xmm1,DWORD PTR [rip+0x0]        # 758 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x758>
 758:	movaps xmm10,xmm6
 75c:	xorps  xmm10,XMMWORD PTR [rip+0x0]        # 764 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x764>
 764:	movaps xmm7,xmm2
 767:	movaps xmm9,xmm6
 76b:	mulss  xmm9,xmm4
 770:	mulss  xmm1,xmm10
 775:	mulss  xmm9,xmm10
 77a:	addss  xmm1,xmm2
 77e:	comiss xmm5,xmm9
 782:	divss  xmm7,xmm1
 786:	movss  xmm1,DWORD PTR [rip+0x0]        # 78e <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x78e>
 78e:	mulss  xmm1,xmm7
 792:	subss  xmm1,DWORD PTR [rip+0x0]        # 79a <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x79a>
 79a:	mulss  xmm1,xmm7
 79e:	addss  xmm1,DWORD PTR [rip+0x0]        # 7a6 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7a6>
 7a6:	mulss  xmm1,xmm7
 7aa:	subss  xmm1,DWORD PTR [rip+0x0]        # 7b2 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7b2>
 7b2:	mulss  xmm1,xmm7
 7b6:	addss  xmm1,DWORD PTR [rip+0x0]        # 7be <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7be>
 7be:	mulss  xmm7,xmm1
 7c2:	jbe    8b0 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8b0>
 7c8:	mulss  xmm7,xmm3
 7cc:	mulss  xmm7,xmm8
 7d1:	mov    rax,QWORD PTR [rbp-0x58]
 7d5:	subss  xmm0,xmm7
 7d9:	movss  DWORD PTR [rax+r9*4],xmm0
 7df:	inc    r9
 7e2:	cmp    QWORD PTR [rbp+0x10],r9
 7e6:	jne    446 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x446>
 7ec:	add    rsp,0x38
 7f0:	pop    rbx
 7f1:	pop    r12
 7f3:	pop    r13
 7f5:	pop    r14
 7f7:	pop    r15
 7f9:	pop    rbp
 7fa:	ret
 7fb:	nop    DWORD PTR [rax+rax*1+0x0]
 800:	movaps xmm14,xmm0
 804:	movss  xmm1,DWORD PTR [rip+0x0]        # 80c <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x80c>
 80c:	xorps  xmm14,XMMWORD PTR [rip+0x0]        # 814 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x814>
 814:	movaps xmm0,xmm2
 817:	movss  xmm13,DWORD PTR [rip+0x0]        # 820 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x820>
 820:	movaps xmm12,xmm11
 824:	mulss  xmm12,xmm4
 829:	mulss  xmm1,xmm14
 82e:	mulss  xmm12,xmm14
 833:	addss  xmm1,xmm2
 837:	comiss xmm5,xmm12
 83b:	divss  xmm0,xmm1
 83f:	mulss  xmm13,xmm0
 844:	subss  xmm13,DWORD PTR [rip+0x0]        # 84d <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x84d>
 84d:	mulss  xmm13,xmm0
 852:	addss  xmm13,DWORD PTR [rip+0x0]        # 85b <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x85b>
 85b:	mulss  xmm13,xmm0
 860:	subss  xmm13,DWORD PTR [rip+0x0]        # 869 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x869>
 869:	mulss  xmm13,xmm0
 86e:	addss  xmm13,DWORD PTR [rip+0x0]        # 877 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x877>
 877:	mulss  xmm0,xmm13
 87c:	jbe    970 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x970>
 882:	mulss  xmm0,xmm3
 886:	jmp    5b6 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5b6>
 88b:	nop    DWORD PTR [rax+rax*1+0x0]
 890:	pxor   xmm1,xmm1
 894:	jmp    710 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x710>
 899:	nop    DWORD PTR [rax+0x0]
 8a0:	pxor   xmm1,xmm1
 8a4:	jmp    5a8 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5a8>
 8a9:	nop    DWORD PTR [rax+0x0]
 8b0:	movss  xmm1,DWORD PTR [rip+0x0]        # 8b8 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8b8>
 8b8:	mulss  xmm1,xmm9
 8bd:	comiss xmm1,xmm3
 8c0:	jb     a40 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa40>
 8c6:	addss  xmm1,xmm4
 8ca:	cvttss2si edx,xmm1
 8ce:	movss  xmm1,DWORD PTR [rip+0x0]        # 8d6 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8d6>
 8d6:	pxor   xmm10,xmm10
 8db:	cvtsi2ss xmm10,edx
 8e0:	cvttss2si edx,xmm10
 8e5:	add    edx,0x7f
 8e8:	shl    edx,0x17
 8eb:	movd   xmm11,edx
 8f0:	mulss  xmm1,xmm10
 8f5:	subss  xmm9,xmm1
 8fa:	movss  xmm1,DWORD PTR [rip+0x0]        # 902 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x902>
 902:	mulss  xmm1,xmm9
 907:	addss  xmm1,DWORD PTR [rip+0x0]        # 90f <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x90f>
 90f:	mulss  xmm1,xmm9
 914:	addss  xmm1,DWORD PTR [rip+0x0]        # 91c <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x91c>
 91c:	mulss  xmm1,xmm9
 921:	addss  xmm1,DWORD PTR [rip+0x0]        # 929 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x929>
 929:	mulss  xmm1,xmm9
 92e:	addss  xmm1,xmm4
 932:	mulss  xmm1,xmm9
 937:	addss  xmm1,xmm2
 93b:	mulss  xmm1,xmm9
 940:	addss  xmm1,xmm2
 944:	mulss  xmm1,xmm11
 949:	mulss  xmm1,DWORD PTR [rip+0x0]        # 951 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x951>
 951:	mulss  xmm7,xmm1
 955:	pxor   xmm1,xmm1
 959:	comiss xmm1,xmm6
 95c:	ja     7cc <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7cc>
 962:	jmp    714 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x714>
 967:	nop    WORD PTR [rax+rax*1+0x0]
 970:	movss  xmm1,DWORD PTR [rip+0x0]        # 978 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x978>
 978:	mulss  xmm1,xmm12
 97d:	comiss xmm1,xmm3
 980:	jb     a30 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa30>
 986:	addss  xmm1,xmm4
 98a:	cvttss2si edx,xmm1
 98e:	movss  xmm1,DWORD PTR [rip+0x0]        # 996 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x996>
 996:	pxor   xmm13,xmm13
 99b:	cvtsi2ss xmm13,edx
 9a0:	cvttss2si edx,xmm13
 9a5:	add    edx,0x7f
 9a8:	shl    edx,0x17
 9ab:	mulss  xmm1,xmm13
 9b0:	movd   xmm13,edx
 9b5:	subss  xmm12,xmm1
 9ba:	movss  xmm1,DWORD PTR [rip+0x0]        # 9c2 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x9c2>
 9c2:	mulss  xmm1,xmm12
 9c7:	addss  xmm1,DWORD PTR [rip+0x0]        # 9cf <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x9cf>
 9cf:	mulss  xmm1,xmm12
 9d4:	addss  xmm1,DWORD PTR [rip+0x0]        # 9dc <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x9dc>
 9dc:	mulss  xmm1,xmm12
 9e1:	addss  xmm1,DWORD PTR [rip+0x0]        # 9e9 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x9e9>
 9e9:	mulss  xmm1,xmm12
 9ee:	addss  xmm1,xmm4
 9f2:	mulss  xmm1,xmm12
 9f7:	addss  xmm1,xmm2
 9fb:	mulss  xmm1,xmm12
 a00:	addss  xmm1,xmm2
 a04:	mulss  xmm1,xmm13
 a09:	mulss  xmm1,DWORD PTR [rip+0x0]        # a11 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa11>
 a11:	mulss  xmm0,xmm1
 a15:	pxor   xmm1,xmm1
 a19:	comiss xmm1,xmm11
 a1d:	ja     5b6 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5b6>
 a23:	jmp    5ac <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5ac>
 a28:	nop    DWORD PTR [rax+rax*1+0x0]
 a30:	subss  xmm1,xmm4
 a34:	jmp    98a <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x98a>
 a39:	nop    DWORD PTR [rax+0x0]
 a40:	subss  xmm1,xmm4
 a44:	jmp    8ca <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8ca>
 a49:	nop    DWORD PTR [rax+0x0]
 a50:	subss  xmm1,xmm4
 a54:	jmp    604 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x604>
 a59:	nop    DWORD PTR [rax+0x0]
 a60:	xor    ebx,ebx
 a62:	jmp    42e <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x42e>
 a67:	movaps xmm0,xmm8
 a6b:	mov    QWORD PTR [rbp-0x50],r9
 a6f:	movss  DWORD PTR [rbp-0x48],xmm10
 a75:	movss  DWORD PTR [rbp-0x44],xmm9
 a7b:	movss  DWORD PTR [rbp-0x40],xmm7
 a80:	movss  DWORD PTR [rbp-0x3c],xmm1
 a85:	movss  DWORD PTR [rbp-0x38],xmm8
 a8b:	call   a90 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa90>
 a90:	movss  xmm10,DWORD PTR [rbp-0x48]
 a96:	movss  xmm9,DWORD PTR [rbp-0x44]
 a9c:	movss  xmm7,DWORD PTR [rbp-0x40]
 aa1:	movss  xmm1,DWORD PTR [rbp-0x3c]
 aa6:	movss  xmm8,DWORD PTR [rbp-0x38]
 aac:	mov    r9,QWORD PTR [rbp-0x50]
 ab0:	jmp    483 <price_options_sse2(float const*, float const*, float const*, float const*, float const*, float*, long)+0x483>
