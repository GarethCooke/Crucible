
/home/gcooke/Development/Projects/Crucible/bench/build/demos/03-simd-blackscholes/CMakeFiles/bs_scalar_poly.dir/scalar_poly.cpp.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)>:
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
  1a:	mov    QWORD PTR [rbp-0x50],rdi
  1e:	mov    QWORD PTR [rbp-0x58],r9
  22:	jle    330 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x330>
  28:	mov    r12,rsi
  2b:	mov    r13,rdx
  2e:	mov    r14,rcx
  31:	mov    r15,r8
  34:	xor    ebx,ebx
  36:	pxor   xmm3,xmm3
  3a:	nop    WORD PTR [rax+rax*1+0x0]
  40:	movss  xmm1,DWORD PTR [r15+rbx*4]
  46:	movss  xmm8,DWORD PTR [r13+rbx*4+0x0]
  4d:	mov    rax,QWORD PTR [rbp-0x50]
  51:	movss  xmm7,DWORD PTR [r14+rbx*4]
  57:	movss  xmm9,DWORD PTR [r12+rbx*4]
  5d:	movss  xmm10,DWORD PTR [rax+rbx*4]
  63:	movaps xmm6,xmm1
  66:	ucomiss xmm3,xmm8
  6a:	mulss  xmm6,xmm1
  6e:	movss  DWORD PTR [rbp-0x34],xmm6
  73:	ja     679 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x679>
  79:	movaps xmm0,xmm8
  7d:	sqrtss xmm0,xmm0
  81:	mulss  xmm1,xmm0
  85:	movaps xmm0,xmm10
  89:	movss  DWORD PTR [rbp-0x48],xmm8
  8f:	movss  DWORD PTR [rbp-0x44],xmm7
  94:	divss  xmm0,xmm9
  99:	movss  DWORD PTR [rbp-0x3c],xmm10
  9f:	movss  DWORD PTR [rbp-0x38],xmm9
  a5:	movss  DWORD PTR [rbp-0x40],xmm1
  aa:	call   af <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0xaf>
  af:	movss  xmm4,DWORD PTR [rip+0x0]        # b7 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0xb7>
  b7:	pxor   xmm3,xmm3
  bb:	movaps xmm6,xmm0
  be:	movss  xmm0,DWORD PTR [rbp-0x34]
  c3:	movss  xmm7,DWORD PTR [rbp-0x44]
  c8:	movss  xmm8,DWORD PTR [rbp-0x48]
  ce:	movss  xmm1,DWORD PTR [rbp-0x40]
  d3:	movss  xmm9,DWORD PTR [rbp-0x38]
  d9:	movss  xmm10,DWORD PTR [rbp-0x3c]
  df:	movss  xmm5,DWORD PTR [rip+0x0]        # e7 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0xe7>
  e7:	movss  xmm2,DWORD PTR [rip+0x0]        # ef <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0xef>
  ef:	mulss  xmm0,xmm4
  f3:	addss  xmm0,xmm7
  f7:	mulss  xmm0,xmm8
  fc:	addss  xmm0,xmm6
 100:	divss  xmm0,xmm1
 104:	movaps xmm6,xmm0
 107:	movaps xmm11,xmm0
 10b:	comiss xmm3,xmm0
 10e:	subss  xmm6,xmm1
 112:	ja     3f0 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3f0>
 118:	movss  xmm1,DWORD PTR [rip+0x0]        # 120 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x120>
 120:	movss  xmm12,DWORD PTR [rip+0x0]        # 129 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x129>
 129:	mulss  xmm1,xmm0
 12d:	mulss  xmm12,xmm11
 132:	movaps xmm0,xmm2
 135:	addss  xmm1,xmm2
 139:	mulss  xmm12,xmm11
 13e:	divss  xmm0,xmm1
 142:	movss  xmm1,DWORD PTR [rip+0x0]        # 14a <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x14a>
 14a:	comiss xmm5,xmm12
 14e:	mulss  xmm1,xmm0
 152:	subss  xmm1,DWORD PTR [rip+0x0]        # 15a <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x15a>
 15a:	mulss  xmm1,xmm0
 15e:	addss  xmm1,DWORD PTR [rip+0x0]        # 166 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x166>
 166:	mulss  xmm1,xmm0
 16a:	subss  xmm1,DWORD PTR [rip+0x0]        # 172 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x172>
 172:	mulss  xmm1,xmm0
 176:	addss  xmm1,DWORD PTR [rip+0x0]        # 17e <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x17e>
 17e:	mulss  xmm0,xmm1
 182:	ja     480 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x480>
 188:	comiss xmm12,DWORD PTR [rip+0x0]        # 190 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x190>
 190:	movss  xmm1,DWORD PTR [rip+0x0]        # 198 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x198>
 198:	jbe    560 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x560>
 19e:	mulss  xmm0,xmm1
 1a2:	movaps xmm1,xmm2
 1a5:	subss  xmm1,xmm0
 1a9:	movaps xmm0,xmm1
 1ac:	xorps  xmm7,XMMWORD PTR [rip+0x0]        # 1b3 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1b3>
 1b3:	mulss  xmm0,xmm10
 1b8:	mulss  xmm7,xmm8
 1bd:	pxor   xmm8,xmm8
 1c2:	comiss xmm5,xmm7
 1c5:	ja     272 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x272>
 1cb:	comiss xmm7,DWORD PTR [rip+0x0]        # 1d2 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1d2>
 1d2:	movss  xmm8,DWORD PTR [rip+0x0]        # 1db <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1db>
 1db:	ja     272 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x272>
 1e1:	movss  xmm1,DWORD PTR [rip+0x0]        # 1e9 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1e9>
 1e9:	mulss  xmm1,xmm7
 1ed:	comiss xmm1,xmm3
 1f0:	jb     660 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x660>
 1f6:	addss  xmm1,xmm4
 1fa:	cvttss2si eax,xmm1
 1fe:	movss  xmm1,DWORD PTR [rip+0x0]        # 206 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x206>
 206:	pxor   xmm8,xmm8
 20b:	cvtsi2ss xmm8,eax
 210:	cvttss2si eax,xmm8
 215:	add    eax,0x7f
 218:	shl    eax,0x17
 21b:	mulss  xmm1,xmm8
 220:	movd   xmm8,eax
 225:	subss  xmm7,xmm1
 229:	movss  xmm1,DWORD PTR [rip+0x0]        # 231 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x231>
 231:	mulss  xmm1,xmm7
 235:	addss  xmm1,DWORD PTR [rip+0x0]        # 23d <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x23d>
 23d:	mulss  xmm1,xmm7
 241:	addss  xmm1,DWORD PTR [rip+0x0]        # 249 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x249>
 249:	mulss  xmm1,xmm7
 24d:	addss  xmm1,DWORD PTR [rip+0x0]        # 255 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x255>
 255:	mulss  xmm1,xmm7
 259:	addss  xmm1,xmm4
 25d:	mulss  xmm1,xmm7
 261:	addss  xmm1,xmm2
 265:	mulss  xmm1,xmm7
 269:	addss  xmm1,xmm2
 26d:	mulss  xmm8,xmm1
 272:	mulss  xmm8,xmm9
 277:	comiss xmm3,xmm6
 27a:	ja     340 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x340>
 280:	movss  xmm1,DWORD PTR [rip+0x0]        # 288 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x288>
 288:	movaps xmm7,xmm2
 28b:	movss  xmm9,DWORD PTR [rip+0x0]        # 294 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x294>
 294:	mulss  xmm1,xmm6
 298:	mulss  xmm9,xmm6
 29d:	addss  xmm1,xmm2
 2a1:	mulss  xmm9,xmm6
 2a6:	divss  xmm7,xmm1
 2aa:	movss  xmm1,DWORD PTR [rip+0x0]        # 2b2 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2b2>
 2b2:	comiss xmm5,xmm9
 2b6:	mulss  xmm1,xmm7
 2ba:	subss  xmm1,DWORD PTR [rip+0x0]        # 2c2 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2c2>
 2c2:	mulss  xmm1,xmm7
 2c6:	addss  xmm1,DWORD PTR [rip+0x0]        # 2ce <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2ce>
 2ce:	mulss  xmm1,xmm7
 2d2:	subss  xmm1,DWORD PTR [rip+0x0]        # 2da <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2da>
 2da:	mulss  xmm1,xmm7
 2de:	addss  xmm1,DWORD PTR [rip+0x0]        # 2e6 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2e6>
 2e6:	mulss  xmm7,xmm1
 2ea:	ja     490 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x490>
 2f0:	comiss xmm9,DWORD PTR [rip+0x0]        # 2f8 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2f8>
 2f8:	movss  xmm1,DWORD PTR [rip+0x0]        # 300 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x300>
 300:	jbe    4a0 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4a0>
 306:	mulss  xmm7,xmm1
 30a:	movaps xmm1,xmm2
 30d:	mov    rax,QWORD PTR [rbp-0x58]
 311:	subss  xmm1,xmm7
 315:	mulss  xmm1,xmm8
 31a:	subss  xmm0,xmm1
 31e:	movss  DWORD PTR [rax+rbx*4],xmm0
 323:	inc    rbx
 326:	cmp    rbx,QWORD PTR [rbp+0x10]
 32a:	jne    40 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x40>
 330:	add    rsp,0x38
 334:	pop    rbx
 335:	pop    r12
 337:	pop    r13
 339:	pop    r14
 33b:	pop    r15
 33d:	pop    rbp
 33e:	ret
 33f:	nop
 340:	movss  xmm7,DWORD PTR [rip+0x0]        # 348 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x348>
 348:	movaps xmm10,xmm6
 34c:	xorps  xmm10,XMMWORD PTR [rip+0x0]        # 354 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x354>
 354:	movaps xmm1,xmm2
 357:	movaps xmm9,xmm6
 35b:	mulss  xmm9,xmm4
 360:	mulss  xmm7,xmm10
 365:	mulss  xmm9,xmm10
 36a:	addss  xmm7,xmm2
 36e:	comiss xmm5,xmm9
 372:	divss  xmm1,xmm7
 376:	movss  xmm7,DWORD PTR [rip+0x0]        # 37e <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x37e>
 37e:	mulss  xmm7,xmm1
 382:	subss  xmm7,DWORD PTR [rip+0x0]        # 38a <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x38a>
 38a:	mulss  xmm7,xmm1
 38e:	addss  xmm7,DWORD PTR [rip+0x0]        # 396 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x396>
 396:	mulss  xmm7,xmm1
 39a:	subss  xmm7,DWORD PTR [rip+0x0]        # 3a2 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3a2>
 3a2:	mulss  xmm7,xmm1
 3a6:	addss  xmm7,DWORD PTR [rip+0x0]        # 3ae <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3ae>
 3ae:	mulss  xmm7,xmm1
 3b2:	jbe    4a0 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4a0>
 3b8:	mulss  xmm7,xmm3
 3bc:	mulss  xmm7,xmm8
 3c1:	mov    rax,QWORD PTR [rbp-0x58]
 3c5:	subss  xmm0,xmm7
 3c9:	movss  DWORD PTR [rax+rbx*4],xmm0
 3ce:	inc    rbx
 3d1:	cmp    QWORD PTR [rbp+0x10],rbx
 3d5:	jne    40 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x40>
 3db:	add    rsp,0x38
 3df:	pop    rbx
 3e0:	pop    r12
 3e2:	pop    r13
 3e4:	pop    r14
 3e6:	pop    r15
 3e8:	pop    rbp
 3e9:	ret
 3ea:	nop    WORD PTR [rax+rax*1+0x0]
 3f0:	movaps xmm14,xmm0
 3f4:	movss  xmm1,DWORD PTR [rip+0x0]        # 3fc <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3fc>
 3fc:	xorps  xmm14,XMMWORD PTR [rip+0x0]        # 404 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x404>
 404:	movaps xmm0,xmm2
 407:	movss  xmm13,DWORD PTR [rip+0x0]        # 410 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x410>
 410:	movaps xmm12,xmm11
 414:	mulss  xmm12,xmm4
 419:	mulss  xmm1,xmm14
 41e:	mulss  xmm12,xmm14
 423:	addss  xmm1,xmm2
 427:	comiss xmm5,xmm12
 42b:	divss  xmm0,xmm1
 42f:	mulss  xmm13,xmm0
 434:	subss  xmm13,DWORD PTR [rip+0x0]        # 43d <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x43d>
 43d:	mulss  xmm13,xmm0
 442:	addss  xmm13,DWORD PTR [rip+0x0]        # 44b <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x44b>
 44b:	mulss  xmm13,xmm0
 450:	subss  xmm13,DWORD PTR [rip+0x0]        # 459 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x459>
 459:	mulss  xmm13,xmm0
 45e:	addss  xmm13,DWORD PTR [rip+0x0]        # 467 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x467>
 467:	mulss  xmm0,xmm13
 46c:	jbe    560 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x560>
 472:	mulss  xmm0,xmm3
 476:	jmp    1ac <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1ac>
 47b:	nop    DWORD PTR [rax+rax*1+0x0]
 480:	pxor   xmm1,xmm1
 484:	jmp    19e <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x19e>
 489:	nop    DWORD PTR [rax+0x0]
 490:	pxor   xmm1,xmm1
 494:	jmp    306 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x306>
 499:	nop    DWORD PTR [rax+0x0]
 4a0:	movss  xmm1,DWORD PTR [rip+0x0]        # 4a8 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4a8>
 4a8:	mulss  xmm1,xmm9
 4ad:	comiss xmm1,xmm3
 4b0:	jb     670 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x670>
 4b6:	addss  xmm1,xmm4
 4ba:	cvttss2si eax,xmm1
 4be:	movss  xmm1,DWORD PTR [rip+0x0]        # 4c6 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4c6>
 4c6:	pxor   xmm10,xmm10
 4cb:	cvtsi2ss xmm10,eax
 4d0:	cvttss2si eax,xmm10
 4d5:	add    eax,0x7f
 4d8:	shl    eax,0x17
 4db:	comiss xmm3,xmm6
 4de:	movd   xmm15,eax
 4e3:	mulss  xmm1,xmm10
 4e8:	subss  xmm9,xmm1
 4ed:	movss  xmm1,DWORD PTR [rip+0x0]        # 4f5 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4f5>
 4f5:	mulss  xmm1,xmm9
 4fa:	addss  xmm1,DWORD PTR [rip+0x0]        # 502 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x502>
 502:	mulss  xmm1,xmm9
 507:	addss  xmm1,DWORD PTR [rip+0x0]        # 50f <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x50f>
 50f:	mulss  xmm1,xmm9
 514:	addss  xmm1,DWORD PTR [rip+0x0]        # 51c <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x51c>
 51c:	mulss  xmm1,xmm9
 521:	addss  xmm1,xmm4
 525:	mulss  xmm1,xmm9
 52a:	addss  xmm1,xmm2
 52e:	mulss  xmm1,xmm9
 533:	addss  xmm1,xmm2
 537:	mulss  xmm1,xmm15
 53c:	mulss  xmm1,DWORD PTR [rip+0x0]        # 544 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x544>
 544:	mulss  xmm7,xmm1
 548:	ja     3bc <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3bc>
 54e:	jmp    30a <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x30a>
 553:	data16 cs nop WORD PTR [rax+rax*1+0x0]
 55e:	xchg   ax,ax
 560:	movss  xmm1,DWORD PTR [rip+0x0]        # 568 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x568>
 568:	mulss  xmm1,xmm12
 56d:	comiss xmm1,xmm3
 570:	jb     620 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x620>
 576:	addss  xmm1,xmm4
 57a:	pxor   xmm13,xmm13
 57f:	cvttss2si eax,xmm1
 583:	movss  xmm1,DWORD PTR [rip+0x0]        # 58b <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x58b>
 58b:	cvtsi2ss xmm13,eax
 590:	mulss  xmm1,xmm13
 595:	subss  xmm12,xmm1
 59a:	movss  xmm1,DWORD PTR [rip+0x0]        # 5a2 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5a2>
 5a2:	mulss  xmm1,xmm12
 5a7:	addss  xmm1,DWORD PTR [rip+0x0]        # 5af <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5af>
 5af:	cvttss2si eax,xmm13
 5b4:	add    eax,0x7f
 5b7:	shl    eax,0x17
 5ba:	comiss xmm3,xmm11
 5be:	movd   xmm15,eax
 5c3:	mulss  xmm1,xmm12
 5c8:	addss  xmm1,DWORD PTR [rip+0x0]        # 5d0 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5d0>
 5d0:	mulss  xmm1,xmm12
 5d5:	addss  xmm1,DWORD PTR [rip+0x0]        # 5dd <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5dd>
 5dd:	mulss  xmm1,xmm12
 5e2:	addss  xmm1,xmm4
 5e6:	mulss  xmm1,xmm12
 5eb:	addss  xmm1,xmm2
 5ef:	mulss  xmm1,xmm12
 5f4:	addss  xmm1,xmm2
 5f8:	mulss  xmm1,xmm15
 5fd:	mulss  xmm1,DWORD PTR [rip+0x0]        # 605 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x605>
 605:	mulss  xmm0,xmm1
 609:	ja     1ac <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1ac>
 60f:	jmp    1a2 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1a2>
 614:	data16 cs nop WORD PTR [rax+rax*1+0x0]
 61f:	nop
 620:	subss  xmm1,xmm4
 624:	pxor   xmm13,xmm13
 629:	cvttss2si eax,xmm1
 62d:	movss  xmm1,DWORD PTR [rip+0x0]        # 635 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x635>
 635:	cvtsi2ss xmm13,eax
 63a:	mulss  xmm1,xmm13
 63f:	subss  xmm12,xmm1
 644:	movss  xmm1,DWORD PTR [rip+0x0]        # 64c <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x64c>
 64c:	mulss  xmm1,xmm12
 651:	jmp    5a7 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5a7>
 656:	cs nop WORD PTR [rax+rax*1+0x0]
 660:	subss  xmm1,xmm4
 664:	jmp    1fa <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1fa>
 669:	nop    DWORD PTR [rax+0x0]
 670:	subss  xmm1,xmm4
 674:	jmp    4ba <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4ba>
 679:	movaps xmm0,xmm8
 67d:	movss  DWORD PTR [rbp-0x48],xmm10
 683:	movss  DWORD PTR [rbp-0x44],xmm9
 689:	movss  DWORD PTR [rbp-0x40],xmm7
 68e:	movss  DWORD PTR [rbp-0x3c],xmm1
 693:	movss  DWORD PTR [rbp-0x38],xmm8
 699:	call   69e <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x69e>
 69e:	movss  xmm10,DWORD PTR [rbp-0x48]
 6a4:	movss  xmm9,DWORD PTR [rbp-0x44]
 6aa:	movss  xmm7,DWORD PTR [rbp-0x40]
 6af:	movss  xmm1,DWORD PTR [rbp-0x3c]
 6b4:	movss  xmm8,DWORD PTR [rbp-0x38]
 6ba:	jmp    81 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x81>
