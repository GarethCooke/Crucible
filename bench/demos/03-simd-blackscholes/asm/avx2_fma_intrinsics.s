
/home/gcooke/Development/Projects/Crucible/bench/build/demos/03-simd-blackscholes/CMakeFiles/bs_avx2_fma.dir/avx2_fma_intrinsics.cpp.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)>:
   0:	endbr64
   4:	lea    r10,[rsp+0x8]
   9:	and    rsp,0xffffffffffffffe0
   d:	push   QWORD PTR [r10-0x8]
  11:	push   rbp
  12:	mov    rbp,rsp
  15:	push   r15
  17:	push   r14
  19:	push   r13
  1b:	push   r12
  1d:	push   r10
  1f:	push   rbx
  20:	mov    r15,rdi
  23:	sub    rsp,0xa0
  2a:	mov    rax,QWORD PTR [r10]
  2d:	mov    rbx,rsi
  30:	mov    r13,rdx
  33:	mov    r12,r9
  36:	mov    QWORD PTR [rbp-0xc0],rax
  3d:	cmp    rax,0x7
  41:	jle    960 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x960>
  47:	movabs r10,0x7fffff007fffff
  51:	vbroadcastss ymm5,DWORD PTR [rip+0x0]        # 5a <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5a>
  5a:	lea    r9,[rax-0x8]
  5e:	xor    eax,eax
  60:	vmovq  xmm7,r10
  65:	movabs r10,0x3f8000003f800000
  6f:	vbroadcastss ymm6,DWORD PTR [rip+0x0]        # 78 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x78>
  78:	vbroadcastss ymm12,DWORD PTR [rip+0x0]        # 81 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x81>
  81:	vpbroadcastq ymm7,xmm7
  86:	vbroadcastss ymm4,DWORD PTR [rip+0x0]        # 8f <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8f>
  8f:	vbroadcastss ymm11,DWORD PTR [rip+0x0]        # 98 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x98>
  98:	mov    rdi,r9
  9b:	vmovdqa YMMWORD PTR [rbp-0x50],ymm7
  a0:	vbroadcastss ymm10,DWORD PTR [rip+0x0]        # a9 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa9>
  a9:	vmovq  xmm7,r10
  ae:	vbroadcastss ymm9,DWORD PTR [rip+0x0]        # b7 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0xb7>
  b7:	vbroadcastss ymm8,DWORD PTR [rip+0x0]        # c0 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0xc0>
  c0:	vpbroadcastq ymm7,xmm7
  c5:	mov    r10d,0xffffff81
  cb:	and    rdi,0xfffffffffffffff8
  cf:	vmovdqa YMMWORD PTR [rbp-0x70],ymm7
  d4:	vmovd  xmm7,r10d
  d9:	movabs r10,0x100000001
  e3:	add    rdi,0x8
  e7:	vpbroadcastd ymm7,xmm7
  ec:	vmovdqa YMMWORD PTR [rbp-0x90],ymm7
  f4:	vmovq  xmm7,r10
  f9:	mov    r10d,0x7f
  ff:	vpbroadcastq ymm7,xmm7
 104:	vmovdqa YMMWORD PTR [rbp-0xb0],ymm7
 10c:	vmovd  xmm7,r10d
 111:	vpbroadcastd ymm7,xmm7
 116:	cs nop WORD PTR [rax+rax*1+0x0]
 120:	vmovaps ymm3,YMMWORD PTR [r8+rax*4]
 126:	vsqrtps ymm0,YMMWORD PTR [r13+rax*4+0x0]
 12d:	vmulps ymm1,ymm3,ymm3
 131:	vmulps ymm0,ymm0,ymm3
 135:	vmovaps ymm3,YMMWORD PTR [r15+rax*4]
 13b:	vfmadd213ps ymm1,ymm5,YMMWORD PTR [rcx+rax*4]
 141:	vdivps ymm2,ymm3,YMMWORD PTR [rbx+rax*4]
 146:	vpsrld ymm13,ymm2,0x17
 14b:	vpand  ymm2,ymm2,YMMWORD PTR [rbp-0x50]
 150:	vpaddd ymm13,ymm13,YMMWORD PTR [rbp-0x90]
 158:	vpor   ymm2,ymm2,YMMWORD PTR [rbp-0x70]
 15d:	vmulps ymm3,ymm5,ymm2
 161:	vcmpge_oqps ymm14,ymm2,YMMWORD PTR [rip+0x0]        # 16a <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x16a>
 16a:	vblendvps ymm2,ymm2,ymm3,ymm14
 170:	vaddps ymm2,ymm2,YMMWORD PTR [rip+0x0]        # 178 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x178>
 178:	vbroadcastss ymm3,DWORD PTR [rip+0x0]        # 181 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x181>
 181:	vpand  ymm14,ymm14,YMMWORD PTR [rbp-0xb0]
 189:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 192 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x192>
 192:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 19b <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x19b>
 19b:	vpaddd ymm13,ymm13,ymm14
 1a0:	vmulps ymm15,ymm2,ymm2
 1a4:	vcvtdq2ps ymm13,ymm13
 1a9:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 1b2 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1b2>
 1b2:	vmulps ymm14,ymm2,ymm15
 1b7:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 1c0 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1c0>
 1c0:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 1c9 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1c9>
 1c9:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 1d2 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1d2>
 1d2:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 1db <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1db>
 1db:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 1e4 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x1e4>
 1e4:	vmulps ymm3,ymm14,ymm3
 1e8:	vfnmadd132ps ymm15,ymm3,ymm5
 1ed:	vxorps xmm3,xmm3,xmm3
 1f1:	vaddps ymm2,ymm2,ymm15
 1f6:	vfmadd132ps ymm13,ymm2,ymm6
 1fb:	vfmadd132ps ymm1,ymm13,YMMWORD PTR [r13+rax*4+0x0]
 202:	vdivps ymm1,ymm1,ymm0
 206:	vcmplt_oqps ymm13,ymm1,ymm3
 20b:	vsubps ymm0,ymm1,ymm0
 20f:	vandnps ymm1,ymm12,ymm1
 213:	vbroadcastss ymm3,DWORD PTR [rip+0x0]        # 21c <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x21c>
 21c:	vmovaps ymm2,ymm1
 220:	vfmadd132ps ymm2,ymm4,YMMWORD PTR [rip+0x0]        # 229 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x229>
 229:	vmulps ymm1,ymm1,ymm1
 22d:	vmulps ymm1,ymm1,YMMWORD PTR [rip+0x0]        # 235 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x235>
 235:	vmaxps ymm1,ymm1,YMMWORD PTR [rip+0x0]        # 23d <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x23d>
 23d:	vdivps ymm2,ymm4,ymm2
 241:	vminps ymm1,ymm1,ymm11
 246:	vmulps ymm14,ymm1,YMMWORD PTR [rip+0x0]        # 24e <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x24e>
 24e:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 257 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x257>
 257:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 260 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x260>
 260:	vroundps ymm14,ymm14,0x8
 266:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 26f <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x26f>
 26f:	vfnmadd231ps ymm1,ymm14,ymm6
 274:	vcvtps2dq ymm14,ymm14
 279:	vfmadd213ps ymm3,ymm2,YMMWORD PTR [rip+0x0]        # 282 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x282>
 282:	vpaddd ymm14,ymm14,ymm7
 286:	vpslld ymm14,ymm14,0x17
 28c:	vmovaps ymm15,ymm1
 290:	vfmadd132ps ymm15,ymm10,YMMWORD PTR [rip+0x0]        # 299 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x299>
 299:	vmulps ymm2,ymm2,ymm3
 29d:	vfmadd132ps ymm15,ymm9,ymm1
 2a2:	vfmadd132ps ymm15,ymm8,ymm1
 2a7:	vfmadd132ps ymm15,ymm5,ymm1
 2ac:	vfmadd132ps ymm15,ymm4,ymm1
 2b1:	vfmadd132ps ymm15,ymm4,ymm1
 2b6:	vxorps xmm1,xmm1,xmm1
 2ba:	vmulps ymm15,ymm15,ymm14
 2bf:	vmulps ymm15,ymm15,YMMWORD PTR [rip+0x0]        # 2c7 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2c7>
 2c7:	vmulps ymm2,ymm15,ymm2
 2cb:	vsubps ymm3,ymm4,ymm2
 2cf:	vblendvps ymm3,ymm3,ymm2,ymm13
 2d5:	vcmplt_oqps ymm13,ymm0,ymm1
 2da:	vandnps ymm0,ymm12,ymm0
 2de:	vmovaps ymm1,ymm0
 2e2:	vmulps ymm0,ymm0,ymm0
 2e6:	vfmadd132ps ymm1,ymm4,YMMWORD PTR [rip+0x0]        # 2ef <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2ef>
 2ef:	vmulps ymm0,ymm0,YMMWORD PTR [rip+0x0]        # 2f7 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2f7>
 2f7:	vbroadcastss ymm2,DWORD PTR [rip+0x0]        # 300 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x300>
 300:	vmaxps ymm0,ymm0,YMMWORD PTR [rip+0x0]        # 308 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x308>
 308:	vdivps ymm1,ymm4,ymm1
 30c:	vminps ymm0,ymm0,ymm11
 311:	vmulps ymm14,ymm0,YMMWORD PTR [rip+0x0]        # 319 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x319>
 319:	vfmadd213ps ymm2,ymm1,YMMWORD PTR [rip+0x0]        # 322 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x322>
 322:	vfmadd213ps ymm2,ymm1,YMMWORD PTR [rip+0x0]        # 32b <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x32b>
 32b:	vroundps ymm14,ymm14,0x8
 331:	vfmadd213ps ymm2,ymm1,YMMWORD PTR [rip+0x0]        # 33a <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x33a>
 33a:	vfnmadd231ps ymm0,ymm14,ymm6
 33f:	vcvtps2dq ymm14,ymm14
 344:	vpaddd ymm14,ymm14,ymm7
 348:	vfmadd213ps ymm2,ymm1,YMMWORD PTR [rip+0x0]        # 351 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x351>
 351:	vpslld ymm14,ymm14,0x17
 357:	vmovaps ymm15,ymm0
 35b:	vfmadd132ps ymm15,ymm10,YMMWORD PTR [rip+0x0]        # 364 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x364>
 364:	vmulps ymm1,ymm1,ymm2
 368:	vfmadd132ps ymm15,ymm9,ymm0
 36d:	vfmadd132ps ymm15,ymm8,ymm0
 372:	vfmadd132ps ymm15,ymm5,ymm0
 377:	vfmadd132ps ymm15,ymm4,ymm0
 37c:	vfmadd132ps ymm15,ymm4,ymm0
 381:	vmovaps ymm0,YMMWORD PTR [r13+rax*4+0x0]
 388:	vmulps ymm0,ymm0,YMMWORD PTR [rcx+rax*4]
 38d:	vmulps ymm15,ymm15,ymm14
 392:	vmulps ymm15,ymm15,YMMWORD PTR [rip+0x0]        # 39a <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x39a>
 39a:	vxorps ymm0,ymm0,ymm12
 39f:	vmaxps ymm0,ymm0,YMMWORD PTR [rip+0x0]        # 3a7 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3a7>
 3a7:	vmulps ymm1,ymm15,ymm1
 3ab:	vsubps ymm2,ymm4,ymm1
 3af:	vminps ymm0,ymm0,ymm11
 3b4:	vblendvps ymm2,ymm2,ymm1,ymm13
 3ba:	vmulps ymm13,ymm0,YMMWORD PTR [rip+0x0]        # 3c2 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3c2>
 3c2:	vroundps ymm13,ymm13,0x8
 3c8:	vfnmadd231ps ymm0,ymm13,ymm6
 3cd:	vcvtps2dq ymm13,ymm13
 3d2:	vpaddd ymm13,ymm13,ymm7
 3d6:	vpslld ymm13,ymm13,0x17
 3dc:	vmovaps ymm1,ymm0
 3e0:	vfmadd132ps ymm1,ymm10,YMMWORD PTR [rip+0x0]        # 3e9 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3e9>
 3e9:	vfmadd132ps ymm1,ymm9,ymm0
 3ee:	vfmadd132ps ymm1,ymm8,ymm0
 3f3:	vfmadd132ps ymm1,ymm5,ymm0
 3f8:	vfmadd132ps ymm1,ymm4,ymm0
 3fd:	vfmadd132ps ymm0,ymm4,ymm1
 402:	vmulps ymm1,ymm3,YMMWORD PTR [r15+rax*4]
 408:	vmulps ymm0,ymm0,ymm13
 40d:	vmulps ymm0,ymm0,YMMWORD PTR [rbx+rax*4]
 412:	vfnmadd132ps ymm0,ymm1,ymm2
 417:	vmovaps YMMWORD PTR [r12+rax*4],ymm0
 41d:	add    rax,0x8
 421:	cmp    rax,rdi
 424:	jne    120 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x120>
 42a:	shr    r9,0x3
 42e:	lea    r14,[r9*8+0x8]
 436:	vzeroupper
 439:	cmp    QWORD PTR [rbp-0xc0],r14
 440:	jle    6f7 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6f7>
 446:	mov    QWORD PTR [rbp-0xc8],rbx
 44d:	mov    QWORD PTR [rbp-0xd0],r12
 454:	vxorps xmm5,xmm5,xmm5
 458:	mov    rbx,r8
 45b:	mov    r12,rcx
 45e:	xchg   ax,ax
 460:	vmovss xmm1,DWORD PTR [rbx+r14*4]
 466:	vmovss xmm9,DWORD PTR [r13+r14*4+0x0]
 46d:	mov    rax,QWORD PTR [rbp-0xc8]
 474:	vmovss xmm3,DWORD PTR [r12+r14*4]
 47a:	vmovss xmm11,DWORD PTR [r15+r14*4]
 480:	vmovss xmm10,DWORD PTR [rax+r14*4]
 486:	vmulss xmm0,xmm1,xmm1
 48a:	vucomiss xmm5,xmm9
 48f:	vmovss DWORD PTR [rbp-0x50],xmm0
 494:	ja     968 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x968>
 49a:	vsqrtss xmm0,xmm9,xmm9
 49f:	vmulss xmm1,xmm1,xmm0
 4a3:	vdivss xmm0,xmm11,xmm10
 4a8:	vmovss DWORD PTR [rbp-0xb8],xmm9
 4b0:	vmovss DWORD PTR [rbp-0xb4],xmm3
 4b8:	vmovss DWORD PTR [rbp-0x90],xmm10
 4c0:	vmovss DWORD PTR [rbp-0x70],xmm11
 4c5:	vmovss DWORD PTR [rbp-0xb0],xmm1
 4cd:	call   4d2 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4d2>
 4d2:	vmovss xmm2,DWORD PTR [rbp-0x50]
 4d7:	vxorps xmm5,xmm5,xmm5
 4db:	vmovss xmm3,DWORD PTR [rbp-0xb4]
 4e3:	vmovss xmm6,DWORD PTR [rip+0x0]        # 4eb <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4eb>
 4eb:	vmovss xmm9,DWORD PTR [rbp-0xb8]
 4f3:	vmovss xmm1,DWORD PTR [rbp-0xb0]
 4fb:	vmovss xmm11,DWORD PTR [rbp-0x70]
 500:	vmovss xmm10,DWORD PTR [rbp-0x90]
 508:	vmovss xmm4,DWORD PTR [rip+0x0]        # 510 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x510>
 510:	vmovss xmm7,DWORD PTR [rip+0x0]        # 518 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x518>
 518:	vfmadd132ss xmm2,xmm3,xmm6
 51d:	vfmadd132ss xmm2,xmm0,xmm9
 522:	vmovss xmm0,DWORD PTR [rip+0x0]        # 52a <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x52a>
 52a:	vdivss xmm2,xmm2,xmm1
 52e:	vsubss xmm1,xmm2,xmm1
 532:	vcomiss xmm5,xmm2
 536:	ja     790 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x790>
 53c:	vfmadd132ss xmm0,xmm4,xmm2
 541:	vmovss xmm8,DWORD PTR [rip+0x0]        # 549 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x549>
 549:	vdivss xmm0,xmm4,xmm0
 54d:	vfmadd213ss xmm8,xmm0,DWORD PTR [rip+0x0]        # 556 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x556>
 556:	vfmadd213ss xmm8,xmm0,DWORD PTR [rip+0x0]        # 55f <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x55f>
 55f:	vfmadd213ss xmm8,xmm0,DWORD PTR [rip+0x0]        # 568 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x568>
 568:	vfmadd213ss xmm8,xmm0,DWORD PTR [rip+0x0]        # 571 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x571>
 571:	vmulss xmm0,xmm0,xmm8
 576:	vmulss xmm8,xmm2,DWORD PTR [rip+0x0]        # 57e <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x57e>
 57e:	vmulss xmm8,xmm8,xmm2
 582:	vcomiss xmm7,xmm8
 587:	ja     800 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x800>
 58d:	vcomiss xmm8,DWORD PTR [rip+0x0]        # 595 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x595>
 595:	vmovss xmm12,DWORD PTR [rip+0x0]        # 59d <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x59d>
 59d:	jbe    8a0 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8a0>
 5a3:	vmulss xmm0,xmm0,xmm12
 5a8:	vsubss xmm0,xmm4,xmm0
 5ac:	vxorps xmm3,xmm3,XMMWORD PTR [rip+0x0]        # 5b4 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5b4>
 5b4:	vmulss xmm0,xmm11,xmm0
 5b8:	vxorps xmm2,xmm2,xmm2
 5bc:	vmulss xmm3,xmm3,xmm9
 5c1:	vcomiss xmm7,xmm3
 5c5:	ja     64d <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x64d>
 5cb:	vcomiss xmm3,DWORD PTR [rip+0x0]        # 5d3 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5d3>
 5d3:	vmovss xmm2,DWORD PTR [rip+0x0]        # 5db <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5db>
 5db:	ja     64d <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x64d>
 5dd:	vmulss xmm2,xmm3,DWORD PTR [rip+0x0]        # 5e5 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5e5>
 5e5:	vcomiss xmm2,xmm5
 5e9:	jb     940 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x940>
 5ef:	vaddss xmm2,xmm2,xmm6
 5f3:	vcvttss2si eax,xmm2
 5f7:	vxorps xmm2,xmm2,xmm2
 5fb:	vcvtsi2ss xmm8,xmm2,eax
 5ff:	vfnmadd231ss xmm3,xmm8,DWORD PTR [rip+0x0]        # 608 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x608>
 608:	vmovss xmm2,DWORD PTR [rip+0x0]        # 610 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x610>
 610:	vcvttss2si eax,xmm8
 615:	add    eax,0x7f
 618:	shl    eax,0x17
 61b:	vfmadd213ss xmm2,xmm3,DWORD PTR [rip+0x0]        # 624 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x624>
 624:	vfmadd213ss xmm2,xmm3,DWORD PTR [rip+0x0]        # 62d <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x62d>
 62d:	vfmadd213ss xmm2,xmm3,DWORD PTR [rip+0x0]        # 636 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x636>
 636:	vfmadd132ss xmm2,xmm6,xmm3
 63b:	vfmadd132ss xmm2,xmm4,xmm3
 640:	vfmadd132ss xmm2,xmm4,xmm3
 645:	vmovd  xmm3,eax
 649:	vmulss xmm2,xmm2,xmm3
 64d:	vmulss xmm3,xmm10,xmm2
 651:	vcomiss xmm5,xmm1
 655:	vmovss xmm2,DWORD PTR [rip+0x0]        # 65d <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x65d>
 65d:	ja     710 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x710>
 663:	vfmadd132ss xmm2,xmm4,xmm1
 668:	vmovss xmm8,DWORD PTR [rip+0x0]        # 670 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x670>
 670:	vdivss xmm2,xmm4,xmm2
 674:	vfmadd213ss xmm8,xmm2,DWORD PTR [rip+0x0]        # 67d <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x67d>
 67d:	vfmadd213ss xmm8,xmm2,DWORD PTR [rip+0x0]        # 686 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x686>
 686:	vfmadd213ss xmm8,xmm2,DWORD PTR [rip+0x0]        # 68f <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x68f>
 68f:	vfmadd213ss xmm8,xmm2,DWORD PTR [rip+0x0]        # 698 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x698>
 698:	vmulss xmm8,xmm2,xmm8
 69d:	vmulss xmm2,xmm1,DWORD PTR [rip+0x0]        # 6a5 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6a5>
 6a5:	vmulss xmm2,xmm2,xmm1
 6a9:	vcomiss xmm7,xmm2
 6ad:	ja     7f0 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7f0>
 6b3:	vcomiss xmm2,DWORD PTR [rip+0x0]        # 6bb <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6bb>
 6bb:	vmovss xmm9,DWORD PTR [rip+0x0]        # 6c3 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6c3>
 6c3:	jbe    810 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x810>
 6c9:	vmulss xmm2,xmm8,xmm9
 6ce:	vsubss xmm2,xmm4,xmm2
 6d2:	mov    rax,QWORD PTR [rbp-0xd0]
 6d9:	vfnmadd132ss xmm2,xmm0,xmm3
 6de:	vmovss DWORD PTR [rax+r14*4],xmm2
 6e4:	mov    rax,QWORD PTR [rbp-0xc0]
 6eb:	inc    r14
 6ee:	cmp    r14,rax
 6f1:	jne    460 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x460>
 6f7:	add    rsp,0xa0
 6fe:	pop    rbx
 6ff:	pop    r10
 701:	pop    r12
 703:	pop    r13
 705:	pop    r14
 707:	pop    r15
 709:	pop    rbp
 70a:	lea    rsp,[r10-0x8]
 70e:	ret
 70f:	nop
 710:	vfnmadd132ss xmm2,xmm4,xmm1
 715:	vmovss xmm8,DWORD PTR [rip+0x0]        # 71d <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x71d>
 71d:	vmulss xmm9,xmm1,xmm6
 721:	vdivss xmm2,xmm4,xmm2
 725:	vfmadd213ss xmm8,xmm2,DWORD PTR [rip+0x0]        # 72e <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x72e>
 72e:	vfmadd213ss xmm8,xmm2,DWORD PTR [rip+0x0]        # 737 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x737>
 737:	vfmadd213ss xmm8,xmm2,DWORD PTR [rip+0x0]        # 740 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x740>
 740:	vfmadd213ss xmm8,xmm2,DWORD PTR [rip+0x0]        # 749 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x749>
 749:	vmulss xmm8,xmm2,xmm8
 74e:	vxorps xmm2,xmm1,XMMWORD PTR [rip+0x0]        # 756 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x756>
 756:	vmulss xmm2,xmm2,xmm9
 75b:	vcomiss xmm7,xmm2
 75f:	jbe    810 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x810>
 765:	vmulss xmm2,xmm8,xmm5
 769:	vfnmadd132ss xmm2,xmm0,xmm3
 76e:	mov    rax,QWORD PTR [rbp-0xd0]
 775:	vmovss DWORD PTR [rax+r14*4],xmm2
 77b:	inc    r14
 77e:	cmp    QWORD PTR [rbp-0xc0],r14
 785:	jne    460 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x460>
 78b:	jmp    6f7 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6f7>
 790:	vfnmadd132ss xmm0,xmm4,xmm2
 795:	vmovss xmm8,DWORD PTR [rip+0x0]        # 79d <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x79d>
 79d:	vmulss xmm12,xmm2,xmm6
 7a1:	vdivss xmm0,xmm4,xmm0
 7a5:	vfmadd213ss xmm8,xmm0,DWORD PTR [rip+0x0]        # 7ae <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7ae>
 7ae:	vfmadd213ss xmm8,xmm0,DWORD PTR [rip+0x0]        # 7b7 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7b7>
 7b7:	vfmadd213ss xmm8,xmm0,DWORD PTR [rip+0x0]        # 7c0 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7c0>
 7c0:	vfmadd213ss xmm8,xmm0,DWORD PTR [rip+0x0]        # 7c9 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7c9>
 7c9:	vmulss xmm0,xmm0,xmm8
 7ce:	vxorps xmm8,xmm2,XMMWORD PTR [rip+0x0]        # 7d6 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7d6>
 7d6:	vmulss xmm8,xmm8,xmm12
 7db:	vcomiss xmm7,xmm8
 7e0:	jbe    8a0 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8a0>
 7e6:	vmulss xmm0,xmm0,xmm5
 7ea:	jmp    5ac <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5ac>
 7ef:	nop
 7f0:	vxorps xmm9,xmm9,xmm9
 7f5:	jmp    6c9 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6c9>
 7fa:	nop    WORD PTR [rax+rax*1+0x0]
 800:	vxorps xmm12,xmm12,xmm12
 805:	jmp    5a3 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5a3>
 80a:	nop    WORD PTR [rax+rax*1+0x0]
 810:	vmulss xmm9,xmm2,DWORD PTR [rip+0x0]        # 818 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x818>
 818:	vcomiss xmm9,xmm5
 81c:	jb     950 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x950>
 822:	vaddss xmm9,xmm9,xmm6
 826:	vxorps xmm11,xmm11,xmm11
 82b:	vcvttss2si eax,xmm9
 830:	vmovss xmm9,DWORD PTR [rip+0x0]        # 838 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x838>
 838:	vcvtsi2ss xmm10,xmm11,eax
 83c:	vfnmadd231ss xmm2,xmm10,DWORD PTR [rip+0x0]        # 845 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x845>
 845:	vcvttss2si eax,xmm10
 84a:	add    eax,0x7f
 84d:	shl    eax,0x17
 850:	vcomiss xmm5,xmm1
 854:	vmovd  xmm11,eax
 858:	vfmadd213ss xmm9,xmm2,DWORD PTR [rip+0x0]        # 861 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x861>
 861:	vfmadd213ss xmm9,xmm2,DWORD PTR [rip+0x0]        # 86a <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x86a>
 86a:	vfmadd213ss xmm9,xmm2,DWORD PTR [rip+0x0]        # 873 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x873>
 873:	vfmadd132ss xmm9,xmm6,xmm2
 878:	vfmadd132ss xmm9,xmm4,xmm2
 87d:	vfmadd132ss xmm2,xmm4,xmm9
 882:	vmulss xmm2,xmm2,xmm11
 887:	vmulss xmm2,xmm2,DWORD PTR [rip+0x0]        # 88f <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x88f>
 88f:	vmulss xmm2,xmm8,xmm2
 893:	ja     769 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x769>
 899:	jmp    6ce <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6ce>
 89e:	xchg   ax,ax
 8a0:	vmulss xmm12,xmm8,DWORD PTR [rip+0x0]        # 8a8 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8a8>
 8a8:	vcomiss xmm12,xmm5
 8ac:	jb     930 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x930>
 8b2:	vaddss xmm12,xmm12,xmm6
 8b6:	vcvttss2si eax,xmm12
 8bb:	vxorps xmm12,xmm12,xmm12
 8c0:	vcvtsi2ss xmm13,xmm12,eax
 8c4:	vfnmadd231ss xmm8,xmm13,DWORD PTR [rip+0x0]        # 8cd <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8cd>
 8cd:	vmovss xmm12,DWORD PTR [rip+0x0]        # 8d5 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8d5>
 8d5:	vcvttss2si eax,xmm13
 8da:	add    eax,0x7f
 8dd:	shl    eax,0x17
 8e0:	vcomiss xmm5,xmm2
 8e4:	vfmadd213ss xmm12,xmm8,DWORD PTR [rip+0x0]        # 8ed <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8ed>
 8ed:	vfmadd213ss xmm12,xmm8,DWORD PTR [rip+0x0]        # 8f6 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8f6>
 8f6:	vfmadd213ss xmm12,xmm8,DWORD PTR [rip+0x0]        # 8ff <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8ff>
 8ff:	vfmadd132ss xmm12,xmm6,xmm8
 904:	vfmadd132ss xmm12,xmm4,xmm8
 909:	vfmadd132ss xmm8,xmm4,xmm12
 90e:	vmovd  xmm12,eax
 912:	vmulss xmm8,xmm8,xmm12
 917:	vmulss xmm8,xmm8,DWORD PTR [rip+0x0]        # 91f <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x91f>
 91f:	vmulss xmm0,xmm0,xmm8
 924:	ja     5ac <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5ac>
 92a:	jmp    5a8 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5a8>
 92f:	nop
 930:	vsubss xmm12,xmm12,xmm6
 934:	jmp    8b6 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8b6>
 939:	nop    DWORD PTR [rax+0x0]
 940:	vsubss xmm2,xmm2,xmm6
 944:	jmp    5f3 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5f3>
 949:	nop    DWORD PTR [rax+0x0]
 950:	vsubss xmm9,xmm9,xmm6
 954:	jmp    826 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x826>
 959:	nop    DWORD PTR [rax+0x0]
 960:	xor    r14d,r14d
 963:	jmp    439 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x439>
 968:	vmovaps xmm0,xmm9
 96c:	vmovss DWORD PTR [rbp-0xb8],xmm11
 974:	vmovss DWORD PTR [rbp-0xb4],xmm10
 97c:	vmovss DWORD PTR [rbp-0xb0],xmm3
 984:	vmovss DWORD PTR [rbp-0x90],xmm1
 98c:	vmovss DWORD PTR [rbp-0x70],xmm9
 991:	call   996 <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x996>
 996:	vmovss xmm11,DWORD PTR [rbp-0xb8]
 99e:	vmovss xmm10,DWORD PTR [rbp-0xb4]
 9a6:	vmovss xmm3,DWORD PTR [rbp-0xb0]
 9ae:	vmovss xmm1,DWORD PTR [rbp-0x90]
 9b6:	vmovss xmm9,DWORD PTR [rbp-0x70]
 9bb:	jmp    49f <price_options_avx2_fma(float const*, float const*, float const*, float const*, float const*, float*, long)+0x49f>
