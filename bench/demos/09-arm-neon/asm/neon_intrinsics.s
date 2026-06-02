
/home/gcooke/Development/Crucible/bench/build/demos/09-arm-neon/CMakeFiles/bs09_neon.dir/neon_intrinsics.cpp.o:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>:
   0:	stp	x29, x30, [sp, #-160]!
   4:	mov	x29, sp
   8:	stp	x19, x20, [sp, #16]
   c:	mov	x20, x0
  10:	stp	x21, x22, [sp, #32]
  14:	mov	x21, x1
  18:	mov	x22, x2
  1c:	stp	x23, x24, [sp, #48]
  20:	mov	x24, x6
  24:	mov	x23, x3
  28:	stp	x25, x26, [sp, #64]
  2c:	mov	x25, x4
  30:	mov	x26, x5
  34:	stp	d8, d9, [sp, #80]
  38:	stp	d10, d11, [sp, #96]
  3c:	stp	d12, d13, [sp, #112]
  40:	stp	d14, d15, [sp, #128]
  44:	cmp	x6, #0x3
  48:	b.le	b28 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0xb28>
  4c:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  50:	sub	x19, x6, #0x4
  54:	and	x19, x19, #0xfffffffffffffffc
  58:	mov	x7, #0x0                   	// #0
  5c:	ldr	q20, [x0]
  60:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  64:	mov	x8, #0x0                   	// #0
  68:	add	x19, x19, #0x4
  6c:	ldr	q1, [x0]
  70:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  74:	ldr	q11, [x0]
  78:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  7c:	ldr	q12, [x0]
  80:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  84:	ldr	q13, [x0]
  88:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  8c:	ldr	q14, [x0]
  90:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  94:	ldr	q15, [x0]
  98:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  9c:	ldr	q4, [x0]
  a0:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  a4:	ldr	q5, [x0]
  a8:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  ac:	ldr	q6, [x0]
  b0:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  b4:	ldr	q7, [x0]
  b8:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  bc:	ldr	q16, [x0]
  c0:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  c4:	ldr	q17, [x0]
  c8:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  cc:	ldr	q18, [x0]
  d0:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
  d4:	movi	v26.4s, #0x7f, msl #16
  d8:	fmov	v25.4s, #5.000000000000000000e-01
  dc:	ldr	q9, [x21, x7]
  e0:	movi	v23.4s, #0x7f
  e4:	fmov	v31.4s, #-1.000000000000000000e+00
  e8:	fmov	v29.4s, #1.000000000000000000e+00
  ec:	fmov	v10.4s, #-5.000000000000000000e-01
  f0:	add	x8, x8, #0x4
  f4:	ldr	q30, [x20, x7]
  f8:	mov	v0.16b, v25.16b
  fc:	ldr	q19, [x0]
 100:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 104:	ldr	q24, [x0]
 108:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 10c:	fdiv	v27.4s, v30.4s, v9.4s
 110:	ldr	q21, [x22, x7]
 114:	ldr	q22, [x23, x7]
 118:	and	v26.16b, v26.16b, v27.16b
 11c:	sshr	v27.4s, v27.4s, #23
 120:	ldr	q30, [x25, x7]
 124:	orr	v26.16b, v26.16b, v24.16b
 128:	ldr	q24, [x0]
 12c:	sub	v27.4s, v27.4s, v23.4s
 130:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 134:	fmul	v28.4s, v21.4s, v22.4s
 138:	fmul	v3.4s, v30.4s, v30.4s
 13c:	fcmge	v8.4s, v26.4s, v24.4s
 140:	fmul	v24.4s, v25.4s, v26.4s
 144:	fneg	v28.4s, v28.4s
 148:	fmla	v22.4s, v25.4s, v3.4s
 14c:	bit	v26.16b, v24.16b, v8.16b
 150:	sub	v27.4s, v27.4s, v8.4s
 154:	ldr	q8, [x0]
 158:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 15c:	fmax	v28.4s, v28.4s, v4.4s
 160:	ldr	q24, [x0]
 164:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 168:	fadd	v31.4s, v31.4s, v26.4s
 16c:	fsqrt	v26.4s, v21.4s
 170:	scvtf	v27.4s, v27.4s
 174:	fmin	v28.4s, v28.4s, v5.4s
 178:	fmul	v30.4s, v30.4s, v26.4s
 17c:	fmla	v8.4s, v24.4s, v31.4s
 180:	ldr	q24, [x0]
 184:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 188:	fmul	v26.4s, v28.4s, v6.4s
 18c:	fmla	v24.4s, v8.4s, v31.4s
 190:	ldr	q8, [x0]
 194:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 198:	frintn	v26.4s, v26.4s
 19c:	fmla	v8.4s, v24.4s, v31.4s
 1a0:	ldr	q24, [x0]
 1a4:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 1a8:	ldr	q3, [x0]
 1ac:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 1b0:	fmls	v28.4s, v26.4s, v20.4s
 1b4:	fmla	v24.4s, v8.4s, v31.4s
 1b8:	mov	v8.16b, v16.16b
 1bc:	fcvtzs	v26.4s, v26.4s
 1c0:	fmla	v3.4s, v24.4s, v31.4s
 1c4:	ldr	q24, [x0]
 1c8:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 1cc:	fmla	v8.4s, v7.4s, v28.4s
 1d0:	add	v26.4s, v26.4s, v23.4s
 1d4:	fmla	v24.4s, v3.4s, v31.4s
 1d8:	mov	v3.16b, v17.16b
 1dc:	shl	v26.4s, v26.4s, #23
 1e0:	fmla	v3.4s, v8.4s, v28.4s
 1e4:	ldr	q8, [x0]
 1e8:	adrp	x0, 0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)>
 1ec:	ldr	q2, [x0]
 1f0:	fmla	v8.4s, v24.4s, v31.4s
 1f4:	mov	v24.16b, v18.16b
 1f8:	fmla	v2.4s, v8.4s, v31.4s
 1fc:	fmla	v24.4s, v3.4s, v28.4s
 200:	mov	v3.16b, v29.16b
 204:	fmul	v8.4s, v31.4s, v31.4s
 208:	fmla	v0.4s, v24.4s, v28.4s
 20c:	fmul	v24.4s, v31.4s, v8.4s
 210:	fmla	v3.4s, v0.4s, v28.4s
 214:	fmul	v24.4s, v24.4s, v2.4s
 218:	mov	v2.16b, v29.16b
 21c:	fmls	v24.4s, v8.4s, v25.4s
 220:	mov	v8.16b, v12.16b
 224:	fmla	v2.4s, v3.4s, v28.4s
 228:	mov	v3.16b, v16.16b
 22c:	fadd	v31.4s, v31.4s, v24.4s
 230:	fmul	v26.4s, v2.4s, v26.4s
 234:	mov	v2.16b, v18.16b
 238:	fmla	v31.4s, v27.4s, v20.4s
 23c:	fmul	v26.4s, v26.4s, v9.4s
 240:	mov	v9.16b, v13.16b
 244:	fmla	v31.4s, v22.4s, v21.4s
 248:	mov	v21.16b, v29.16b
 24c:	fdiv	v31.4s, v31.4s, v30.4s
 250:	fsub	v30.4s, v31.4s, v30.4s
 254:	fmul	v27.4s, v31.4s, v31.4s
 258:	fabs	v24.4s, v31.4s
 25c:	fcmlt	v31.4s, v31.4s, #0.0
 260:	fmul	v28.4s, v30.4s, v30.4s
 264:	fmul	v27.4s, v27.4s, v10.4s
 268:	fmla	v21.4s, v1.4s, v24.4s
 26c:	fabs	v22.4s, v30.4s
 270:	mov	v24.16b, v29.16b
 274:	fmul	v28.4s, v28.4s, v10.4s
 278:	fmax	v27.4s, v27.4s, v4.4s
 27c:	fcmlt	v30.4s, v30.4s, #0.0
 280:	fmla	v24.4s, v1.4s, v22.4s
 284:	fmax	v28.4s, v28.4s, v4.4s
 288:	fmin	v27.4s, v27.4s, v5.4s
 28c:	fdiv	v21.4s, v29.4s, v21.4s
 290:	fmin	v28.4s, v28.4s, v5.4s
 294:	fmul	v22.4s, v27.4s, v6.4s
 298:	fmla	v8.4s, v11.4s, v21.4s
 29c:	fdiv	v24.4s, v29.4s, v24.4s
 2a0:	fmul	v10.4s, v28.4s, v6.4s
 2a4:	frintn	v22.4s, v22.4s
 2a8:	fmla	v9.4s, v8.4s, v21.4s
 2ac:	mov	v8.16b, v14.16b
 2b0:	frintn	v10.4s, v10.4s
 2b4:	fmls	v27.4s, v22.4s, v20.4s
 2b8:	fmla	v8.4s, v9.4s, v21.4s
 2bc:	mov	v9.16b, v15.16b
 2c0:	fmls	v28.4s, v10.4s, v20.4s
 2c4:	fcvtzs	v22.4s, v22.4s
 2c8:	fcvtzs	v10.4s, v10.4s
 2cc:	fmla	v3.4s, v7.4s, v27.4s
 2d0:	fmla	v9.4s, v8.4s, v21.4s
 2d4:	mov	v8.16b, v17.16b
 2d8:	add	v22.4s, v22.4s, v23.4s
 2dc:	add	v10.4s, v10.4s, v23.4s
 2e0:	mov	v23.16b, v16.16b
 2e4:	fmla	v8.4s, v3.4s, v27.4s
 2e8:	mov	v3.16b, v18.16b
 2ec:	fmla	v23.4s, v7.4s, v28.4s
 2f0:	shl	v22.4s, v22.4s, #23
 2f4:	fmla	v3.4s, v8.4s, v27.4s
 2f8:	mov	v8.16b, v17.16b
 2fc:	shl	v10.4s, v10.4s, #23
 300:	fmul	v21.4s, v21.4s, v9.4s
 304:	fmla	v8.4s, v23.4s, v28.4s
 308:	mov	v23.16b, v25.16b
 30c:	fmla	v23.4s, v3.4s, v27.4s
 310:	mov	v3.16b, v29.16b
 314:	fmla	v2.4s, v8.4s, v28.4s
 318:	mov	v8.16b, v12.16b
 31c:	fmla	v3.4s, v23.4s, v27.4s
 320:	mov	v23.16b, v29.16b
 324:	fmla	v25.4s, v2.4s, v28.4s
 328:	fmla	v23.4s, v3.4s, v27.4s
 32c:	mov	v3.16b, v29.16b
 330:	mov	v27.16b, v29.16b
 334:	fmla	v8.4s, v11.4s, v24.4s
 338:	fmla	v3.4s, v25.4s, v28.4s
 33c:	mov	v25.16b, v13.16b
 340:	fmla	v25.4s, v8.4s, v24.4s
 344:	fmla	v27.4s, v3.4s, v28.4s
 348:	mov	v28.16b, v14.16b
 34c:	fmla	v28.4s, v25.4s, v24.4s
 350:	fmul	v25.4s, v23.4s, v22.4s
 354:	mov	v23.16b, v15.16b
 358:	fmla	v23.4s, v28.4s, v24.4s
 35c:	fmul	v25.4s, v25.4s, v19.4s
 360:	fmul	v28.4s, v27.4s, v10.4s
 364:	fmul	v27.4s, v25.4s, v21.4s
 368:	fmul	v28.4s, v28.4s, v19.4s
 36c:	fmul	v24.4s, v24.4s, v23.4s
 370:	fsub	v25.4s, v29.4s, v27.4s
 374:	fmul	v24.4s, v28.4s, v24.4s
 378:	ldr	q28, [x20, x7]
 37c:	bsl	v31.16b, v27.16b, v25.16b
 380:	fsub	v29.4s, v29.4s, v24.4s
 384:	fmul	v31.4s, v28.4s, v31.4s
 388:	bsl	v30.16b, v24.16b, v29.16b
 38c:	fmls	v31.4s, v26.4s, v30.4s
 390:	str	q31, [x26, x7]
 394:	add	x7, x7, #0x10
 398:	cmp	x8, x19
 39c:	b.ne	d0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0xd0>  // b.any
 3a0:	cmp	x24, x19
 3a4:	b.le	820 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x820>
 3a8:	mov	w4, #0x3389                	// #13193
 3ac:	mov	w3, #0x466f                	// #18031
 3b0:	mov	w2, #0x1eea                	// #7914
 3b4:	mov	w1, #0x778                 	// #1912
 3b8:	movk	w4, #0x3e6d, lsl #16
 3bc:	movk	w3, #0x3faa, lsl #16
 3c0:	movk	w2, #0xbfe9, lsl #16
 3c4:	movk	w1, #0x3fe4, lsl #16
 3c8:	mov	w0, #0xc2b00000            	// #-1028653056
 3cc:	fmov	s10, w4
 3d0:	fmov	s11, w3
 3d4:	fmov	s12, w2
 3d8:	fmov	s13, w1
 3dc:	fmov	s14, w0
 3e0:	ldr	s28, [x22, x19, lsl #2]
 3e4:	ldr	s15, [x25, x19, lsl #2]
 3e8:	ldr	s26, [x20, x19, lsl #2]
 3ec:	fcmp	s28, #0.0
 3f0:	ldr	s8, [x21, x19, lsl #2]
 3f4:	ldr	s25, [x23, x19, lsl #2]
 3f8:	fmul	s9, s15, s15
 3fc:	b.pl	554 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x554>  // b.nfrst
 400:	fmov	s0, s28
 404:	stp	s26, s28, [sp, #148]
 408:	str	s25, [sp, #156]
 40c:	bl	0 <sqrtf>
 410:	ldr	s26, [sp, #148]
 414:	fmul	s15, s15, s0
 418:	fdiv	s0, s26, s8
 41c:	bl	0 <logf>
 420:	ldr	s25, [sp, #156]
 424:	fmov	s31, #5.000000000000000000e-01
 428:	mov	w0, #0x3389                	// #13193
 42c:	movk	w0, #0x3e6d, lsl #16
 430:	fmov	s27, #1.000000000000000000e+00
 434:	mov	w1, #0x466f                	// #18031
 438:	ldp	s26, s28, [sp, #148]
 43c:	mov	w3, #0x1eea                	// #7914
 440:	movk	w1, #0x3faa, lsl #16
 444:	fmov	s30, w0
 448:	movk	w3, #0xbfe9, lsl #16
 44c:	mov	w2, #0x778                 	// #1912
 450:	fmov	s20, w1
 454:	movk	w2, #0x3fe4, lsl #16
 458:	mov	w1, #0x8f89                	// #36745
 45c:	fmov	s22, w3
 460:	movk	w1, #0xbeb6, lsl #16
 464:	mov	w0, #0x85fa                	// #34298
 468:	fmadd	s9, s9, s31, s25
 46c:	movk	w0, #0x3ea3, lsl #16
 470:	mov	w7, #0xaa3b                	// #43579
 474:	fmov	s23, w2
 478:	fmov	s19, #-5.000000000000000000e-01
 47c:	movk	w7, #0x3fb8, lsl #16
 480:	fmov	s24, w1
 484:	fmov	s31, w0
 488:	fmadd	s0, s28, s9, s0
 48c:	fmov	s29, w7
 490:	fdiv	s0, s0, s15
 494:	fmadd	s21, s0, s30, s27
 498:	fmul	s30, s0, s19
 49c:	fsub	s15, s0, s15
 4a0:	fmul	s30, s30, s0
 4a4:	fdiv	s27, s27, s21
 4a8:	fmul	s29, s30, s29
 4ac:	fmadd	s22, s27, s20, s22
 4b0:	fmadd	s23, s22, s27, s23
 4b4:	fmadd	s24, s23, s27, s24
 4b8:	fmadd	s31, s24, s27, s31
 4bc:	fmul	s31, s31, s27
 4c0:	fmov	s24, #5.000000000000000000e-01
 4c4:	mov	w0, #0x7218                	// #29208
 4c8:	mov	w3, #0xb61                 	// #2913
 4cc:	movk	w0, #0x3f31, lsl #16
 4d0:	mov	w2, #0x8889                	// #34953
 4d4:	fmov	s27, #1.000000000000000000e+00
 4d8:	movk	w3, #0x3ab6, lsl #16
 4dc:	movk	w2, #0x3c08, lsl #16
 4e0:	fmov	s18, w0
 4e4:	mov	w1, #0xaaab                	// #43691
 4e8:	mov	w0, #0xaaab                	// #43691
 4ec:	fsub	s29, s29, s24
 4f0:	movk	w1, #0x3d2a, lsl #16
 4f4:	movk	w0, #0x3e2a, lsl #16
 4f8:	fmov	s21, w2
 4fc:	mov	w4, #0x422a                	// #16938
 500:	fmov	s19, w3
 504:	movk	w4, #0x3ecc, lsl #16
 508:	fmov	s22, w1
 50c:	fmov	s23, w0
 510:	fmov	s20, w4
 514:	fcvtzs	s29, s29
 518:	scvtf	s29, s29
 51c:	fmsub	s30, s29, s18, s30
 520:	fcvtzs	w7, s29
 524:	fmadd	s29, s30, s19, s21
 528:	add	w7, w7, #0x7f
 52c:	fmov	s21, w7
 530:	fmadd	s29, s30, s29, s22
 534:	fmadd	s29, s30, s29, s23
 538:	shl	v21.2s, v21.2s, #23
 53c:	fmadd	s24, s30, s29, s24
 540:	fmadd	s24, s30, s24, s27
 544:	fmadd	s30, s30, s24, s27
 548:	fmul	s30, s30, s21
 54c:	fmul	s30, s30, s20
 550:	b	a94 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa94>
 554:	fsqrt	s29, s28
 558:	stp	s26, s28, [sp, #148]
 55c:	str	s25, [sp, #156]
 560:	fdiv	s0, s26, s8
 564:	fmul	s15, s15, s29
 568:	bl	0 <logf>
 56c:	ldr	s25, [sp, #156]
 570:	fmov	s30, #5.000000000000000000e-01
 574:	ldp	s26, s28, [sp, #148]
 578:	fmadd	s9, s9, s30, s25
 57c:	fmadd	s0, s28, s9, s0
 580:	fdiv	s0, s0, s15
 584:	fcmpe	s0, #0.0
 588:	fsub	s15, s0, s15
 58c:	b.mi	8d0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8d0>  // b.first
 590:	fmov	s31, #1.000000000000000000e+00
 594:	mov	w1, #0x8f89                	// #36745
 598:	mov	w0, #0x85fa                	// #34298
 59c:	movk	w1, #0xbeb6, lsl #16
 5a0:	movk	w0, #0x3ea3, lsl #16
 5a4:	fmov	s30, #-5.000000000000000000e-01
 5a8:	fmov	s27, w1
 5ac:	fmadd	s24, s0, s10, s31
 5b0:	fmov	s29, w0
 5b4:	fmul	s30, s0, s30
 5b8:	fmul	s30, s30, s0
 5bc:	fdiv	s31, s31, s24
 5c0:	fcmpe	s30, s14
 5c4:	fmadd	s24, s31, s11, s12
 5c8:	fmadd	s24, s31, s24, s13
 5cc:	fmadd	s27, s31, s24, s27
 5d0:	fmadd	s29, s31, s27, s29
 5d4:	fmul	s31, s31, s29
 5d8:	b.mi	940 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x940>  // b.first
 5dc:	mov	w0, #0x42b00000            	// #1118830592
 5e0:	fmov	s29, w0
 5e4:	fcmpe	s30, s29
 5e8:	b.gt	608 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x608>
 5ec:	mov	w7, #0xaa3b                	// #43579
 5f0:	movk	w7, #0x3fb8, lsl #16
 5f4:	fmov	s29, w7
 5f8:	fmul	s29, s30, s29
 5fc:	fcmpe	s29, #0.0
 600:	b.ge	a04 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa04>  // b.tcont
 604:	b	4c0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4c0>
 608:	mov	w0, #0x484f                	// #18511
 60c:	movk	w0, #0x7e46, lsl #16
 610:	fmov	s30, w0
 614:	fmul	s31, s31, s30
 618:	fmov	s30, #1.000000000000000000e+00
 61c:	fsub	s31, s30, s31
 620:	fnmul	s29, s25, s28
 624:	fmul	s31, s26, s31
 628:	movi	v30.2s, #0x0
 62c:	fcmpe	s29, s14
 630:	b.mi	6e0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6e0>  // b.first
 634:	mov	w0, #0x42b00000            	// #1118830592
 638:	fmov	s30, w0
 63c:	fcmpe	s29, s30
 640:	b.gt	954 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x954>
 644:	mov	w7, #0xaa3b                	// #43579
 648:	movk	w7, #0x3fb8, lsl #16
 64c:	fmov	s28, w7
 650:	fmul	s28, s29, s28
 654:	fcmpe	s28, #0.0
 658:	b.ge	aa4 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0xaa4>  // b.tcont
 65c:	fmov	s27, #5.000000000000000000e-01
 660:	mov	w0, #0x7218                	// #29208
 664:	mov	w3, #0xb61                 	// #2913
 668:	movk	w0, #0x3f31, lsl #16
 66c:	mov	w2, #0x8889                	// #34953
 670:	fmov	s30, #1.000000000000000000e+00
 674:	movk	w3, #0x3ab6, lsl #16
 678:	movk	w2, #0x3c08, lsl #16
 67c:	fmov	s22, w0
 680:	mov	w1, #0xaaab                	// #43691
 684:	mov	w0, #0xaaab                	// #43691
 688:	fsub	s28, s28, s27
 68c:	movk	w1, #0x3d2a, lsl #16
 690:	movk	w0, #0x3e2a, lsl #16
 694:	fmov	s24, w2
 698:	fmov	s23, w3
 69c:	fmov	s25, w1
 6a0:	fmov	s26, w0
 6a4:	fcvtzs	s28, s28
 6a8:	scvtf	s28, s28
 6ac:	fmsub	s29, s28, s22, s29
 6b0:	fcvtzs	w7, s28
 6b4:	fmadd	s28, s29, s23, s24
 6b8:	add	w7, w7, #0x7f
 6bc:	fmov	s24, w7
 6c0:	fmadd	s28, s29, s28, s25
 6c4:	fmadd	s28, s29, s28, s26
 6c8:	shl	v24.2s, v24.2s, #23
 6cc:	fmadd	s27, s29, s28, s27
 6d0:	fmadd	s27, s29, s27, s30
 6d4:	fmadd	s30, s29, s27, s30
 6d8:	fmul	s30, s30, s24
 6dc:	nop
 6e0:	fcmpe	s15, #0.0
 6e4:	fmul	s26, s8, s30
 6e8:	b.mi	848 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x848>  // b.first
 6ec:	fmov	s30, #1.000000000000000000e+00
 6f0:	mov	w1, #0x8f89                	// #36745
 6f4:	mov	w0, #0x85fa                	// #34298
 6f8:	movk	w1, #0xbeb6, lsl #16
 6fc:	movk	w0, #0x3ea3, lsl #16
 700:	fmov	s28, #-5.000000000000000000e-01
 704:	fmov	s27, w1
 708:	fmadd	s25, s15, s10, s30
 70c:	fmov	s29, w0
 710:	fmul	s28, s15, s28
 714:	fmul	s28, s28, s15
 718:	fdiv	s30, s30, s25
 71c:	fcmpe	s28, s14
 720:	fmadd	s25, s30, s11, s12
 724:	fmadd	s25, s30, s25, s13
 728:	fmadd	s27, s30, s25, s27
 72c:	fmadd	s29, s30, s27, s29
 730:	fmul	s30, s30, s29
 734:	b.mi	94c <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x94c>  // b.first
 738:	mov	w0, #0x42b00000            	// #1118830592
 73c:	fmov	s29, w0
 740:	fcmpe	s28, s29
 744:	b.gt	7f4 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7f4>
 748:	mov	w7, #0xaa3b                	// #43579
 74c:	movk	w7, #0x3fb8, lsl #16
 750:	fmov	s29, w7
 754:	fmul	s29, s28, s29
 758:	fcmpe	s29, #0.0
 75c:	b.ge	964 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x964>  // b.tcont
 760:	fmov	s25, #5.000000000000000000e-01
 764:	mov	w0, #0x7218                	// #29208
 768:	mov	w4, #0xb61                 	// #2913
 76c:	movk	w0, #0x3f31, lsl #16
 770:	mov	w2, #0x8889                	// #34953
 774:	fmov	s27, #1.000000000000000000e+00
 778:	movk	w4, #0x3ab6, lsl #16
 77c:	movk	w2, #0x3c08, lsl #16
 780:	fmov	s19, w0
 784:	mov	w1, #0xaaab                	// #43691
 788:	mov	w0, #0xaaab                	// #43691
 78c:	fsub	s29, s29, s25
 790:	movk	w1, #0x3d2a, lsl #16
 794:	movk	w0, #0x3e2a, lsl #16
 798:	fmov	s22, w2
 79c:	mov	w3, #0x422a                	// #16938
 7a0:	fmov	s20, w4
 7a4:	movk	w3, #0x3ecc, lsl #16
 7a8:	fmov	s23, w1
 7ac:	fmov	s24, w0
 7b0:	fmov	s21, w3
 7b4:	fcvtzs	s29, s29
 7b8:	scvtf	s29, s29
 7bc:	fmsub	s28, s29, s19, s28
 7c0:	fcvtzs	w7, s29
 7c4:	fmadd	s29, s28, s20, s22
 7c8:	add	w7, w7, #0x7f
 7cc:	fmov	s22, w7
 7d0:	fmadd	s29, s28, s29, s23
 7d4:	fmadd	s29, s28, s29, s24
 7d8:	shl	v22.2s, v22.2s, #23
 7dc:	fmadd	s25, s28, s29, s25
 7e0:	fmadd	s25, s28, s25, s27
 7e4:	fmadd	s29, s28, s25, s27
 7e8:	fmul	s29, s29, s22
 7ec:	fmul	s29, s29, s21
 7f0:	b	9f4 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x9f4>
 7f4:	mov	w0, #0x484f                	// #18511
 7f8:	movk	w0, #0x7e46, lsl #16
 7fc:	fmov	s29, w0
 800:	fmul	s30, s29, s30
 804:	fmov	s29, #1.000000000000000000e+00
 808:	fsub	s29, s29, s30
 80c:	fmsub	s31, s26, s29, s31
 810:	str	s31, [x26, x19, lsl #2]
 814:	add	x19, x19, #0x1
 818:	cmp	x19, x24
 81c:	b.ne	3e0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3e0>  // b.any
 820:	ldp	d8, d9, [sp, #80]
 824:	ldp	x19, x20, [sp, #16]
 828:	ldp	x21, x22, [sp, #32]
 82c:	ldp	x23, x24, [sp, #48]
 830:	ldp	x25, x26, [sp, #64]
 834:	ldp	d10, d11, [sp, #96]
 838:	ldp	d12, d13, [sp, #112]
 83c:	ldp	d14, d15, [sp, #128]
 840:	ldp	x29, x30, [sp], #160
 844:	ret
 848:	fmov	s29, #1.000000000000000000e+00
 84c:	mov	w1, #0x8f89                	// #36745
 850:	mov	w0, #0x85fa                	// #34298
 854:	movk	w1, #0xbeb6, lsl #16
 858:	movk	w0, #0x3ea3, lsl #16
 85c:	fmov	s28, #5.000000000000000000e-01
 860:	fmov	s27, w1
 864:	fmsub	s25, s15, s10, s29
 868:	fmov	s30, w0
 86c:	fmul	s28, s15, s28
 870:	fnmul	s28, s15, s28
 874:	fdiv	s29, s29, s25
 878:	fcmpe	s28, s14
 87c:	fmadd	s25, s29, s11, s12
 880:	fmadd	s25, s29, s25, s13
 884:	fmadd	s27, s29, s25, s27
 888:	fmadd	s30, s29, s27, s30
 88c:	fmul	s30, s29, s30
 890:	b.mi	8b0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8b0>  // b.first
 894:	mov	w7, #0xaa3b                	// #43579
 898:	movk	w7, #0x3fb8, lsl #16
 89c:	fmov	s29, w7
 8a0:	fmul	s29, s28, s29
 8a4:	fcmpe	s29, #0.0
 8a8:	b.ge	964 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x964>  // b.tcont
 8ac:	b	760 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x760>
 8b0:	movi	v29.2s, #0x0
 8b4:	fmul	s30, s30, s29
 8b8:	fmsub	s30, s30, s26, s31
 8bc:	str	s30, [x26, x19, lsl #2]
 8c0:	add	x19, x19, #0x1
 8c4:	cmp	x24, x19
 8c8:	b.ne	3e0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3e0>  // b.any
 8cc:	b	820 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x820>
 8d0:	fmov	s31, #1.000000000000000000e+00
 8d4:	mov	w1, #0x8f89                	// #36745
 8d8:	mov	w0, #0x85fa                	// #34298
 8dc:	movk	w1, #0xbeb6, lsl #16
 8e0:	movk	w0, #0x3ea3, lsl #16
 8e4:	fmul	s30, s0, s30
 8e8:	fmov	s27, w1
 8ec:	fmsub	s24, s0, s10, s31
 8f0:	fmov	s29, w0
 8f4:	fnmul	s30, s0, s30
 8f8:	fcmpe	s30, s14
 8fc:	fdiv	s31, s31, s24
 900:	fmadd	s24, s31, s11, s12
 904:	fmadd	s24, s31, s24, s13
 908:	fmadd	s27, s31, s24, s27
 90c:	fmadd	s29, s31, s27, s29
 910:	fmul	s31, s31, s29
 914:	b.mi	934 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x934>  // b.first
 918:	mov	w7, #0xaa3b                	// #43579
 91c:	movk	w7, #0x3fb8, lsl #16
 920:	fmov	s29, w7
 924:	fmul	s29, s30, s29
 928:	fcmpe	s29, #0.0
 92c:	b.ge	a04 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0xa04>  // b.tcont
 930:	b	4c0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4c0>
 934:	movi	v30.2s, #0x0
 938:	fmul	s31, s31, s30
 93c:	b	620 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x620>
 940:	movi	v30.2s, #0x0
 944:	fmul	s31, s31, s30
 948:	b	618 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x618>
 94c:	movi	v29.2s, #0x0
 950:	b	800 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x800>
 954:	mov	w7, #0x829c                	// #33436
 958:	movk	w7, #0x7ef8, lsl #16
 95c:	fmov	s30, w7
 960:	b	6e0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6e0>
 964:	fmov	s24, #5.000000000000000000e-01
 968:	mov	w0, #0x7218                	// #29208
 96c:	mov	w4, #0xb61                 	// #2913
 970:	movk	w0, #0x3f31, lsl #16
 974:	mov	w2, #0x8889                	// #34953
 978:	fmov	s27, #1.000000000000000000e+00
 97c:	movk	w4, #0x3ab6, lsl #16
 980:	movk	w2, #0x3c08, lsl #16
 984:	fmov	s25, w0
 988:	mov	w1, #0xaaab                	// #43691
 98c:	mov	w0, #0xaaab                	// #43691
 990:	fadd	s29, s29, s24
 994:	movk	w1, #0x3d2a, lsl #16
 998:	movk	w0, #0x3e2a, lsl #16
 99c:	fmov	s19, w4
 9a0:	mov	w3, #0x422a                	// #16938
 9a4:	fmov	s21, w2
 9a8:	movk	w3, #0x3ecc, lsl #16
 9ac:	fmov	s22, w1
 9b0:	fmov	s23, w0
 9b4:	fmov	s20, w3
 9b8:	fcvtzs	s29, s29
 9bc:	scvtf	s29, s29
 9c0:	fmsub	s28, s29, s25, s28
 9c4:	fcvtzs	w7, s29
 9c8:	fmadd	s29, s28, s19, s21
 9cc:	add	w7, w7, #0x7f
 9d0:	fmov	s25, w7
 9d4:	fmadd	s29, s28, s29, s22
 9d8:	fmadd	s29, s28, s29, s23
 9dc:	shl	v25.2s, v25.2s, #23
 9e0:	fmadd	s24, s28, s29, s24
 9e4:	fmadd	s24, s28, s24, s27
 9e8:	fmadd	s29, s28, s24, s27
 9ec:	fmul	s29, s29, s25
 9f0:	fmul	s29, s29, s20
 9f4:	fcmpe	s15, #0.0
 9f8:	fmul	s30, s30, s29
 9fc:	b.mi	8b8 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8b8>  // b.first
 a00:	b	804 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x804>
 a04:	fmov	s23, #5.000000000000000000e-01
 a08:	mov	w0, #0x7218                	// #29208
 a0c:	mov	w3, #0xb61                 	// #2913
 a10:	movk	w0, #0x3f31, lsl #16
 a14:	mov	w2, #0x8889                	// #34953
 a18:	fmov	s27, #1.000000000000000000e+00
 a1c:	movk	w3, #0x3ab6, lsl #16
 a20:	movk	w2, #0x3c08, lsl #16
 a24:	fmov	s24, w0
 a28:	mov	w1, #0xaaab                	// #43691
 a2c:	mov	w0, #0xaaab                	// #43691
 a30:	fadd	s29, s29, s23
 a34:	movk	w1, #0x3d2a, lsl #16
 a38:	movk	w0, #0x3e2a, lsl #16
 a3c:	fmov	s18, w3
 a40:	mov	w4, #0x422a                	// #16938
 a44:	fmov	s20, w2
 a48:	movk	w4, #0x3ecc, lsl #16
 a4c:	fmov	s21, w1
 a50:	fmov	s22, w0
 a54:	fmov	s19, w4
 a58:	fcvtzs	s29, s29
 a5c:	scvtf	s29, s29
 a60:	fmsub	s30, s29, s24, s30
 a64:	fcvtzs	w7, s29
 a68:	fmadd	s29, s30, s18, s20
 a6c:	add	w7, w7, #0x7f
 a70:	fmov	s24, w7
 a74:	fmadd	s29, s30, s29, s21
 a78:	fmadd	s29, s30, s29, s22
 a7c:	shl	v24.2s, v24.2s, #23
 a80:	fmadd	s23, s30, s29, s23
 a84:	fmadd	s23, s30, s23, s27
 a88:	fmadd	s30, s30, s23, s27
 a8c:	fmul	s30, s30, s24
 a90:	fmul	s30, s30, s19
 a94:	fcmpe	s0, #0.0
 a98:	fmul	s31, s31, s30
 a9c:	b.mi	620 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x620>  // b.first
 aa0:	b	618 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x618>
 aa4:	fmov	s26, #5.000000000000000000e-01
 aa8:	mov	w0, #0x7218                	// #29208
 aac:	mov	w3, #0xb61                 	// #2913
 ab0:	movk	w0, #0x3f31, lsl #16
 ab4:	mov	w2, #0x8889                	// #34953
 ab8:	fmov	s30, #1.000000000000000000e+00
 abc:	movk	w3, #0x3ab6, lsl #16
 ac0:	movk	w2, #0x3c08, lsl #16
 ac4:	fmov	s27, w0
 ac8:	mov	w1, #0xaaab                	// #43691
 acc:	mov	w0, #0xaaab                	// #43691
 ad0:	fadd	s28, s28, s26
 ad4:	movk	w1, #0x3d2a, lsl #16
 ad8:	movk	w0, #0x3e2a, lsl #16
 adc:	fmov	s22, w3
 ae0:	fmov	s23, w2
 ae4:	fmov	s24, w1
 ae8:	fmov	s25, w0
 aec:	fcvtzs	s28, s28
 af0:	scvtf	s28, s28
 af4:	fmsub	s29, s28, s27, s29
 af8:	fcvtzs	w7, s28
 afc:	fmadd	s28, s29, s22, s23
 b00:	add	w7, w7, #0x7f
 b04:	fmov	s27, w7
 b08:	fmadd	s28, s29, s28, s24
 b0c:	fmadd	s28, s29, s28, s25
 b10:	shl	v27.2s, v27.2s, #23
 b14:	fmadd	s26, s29, s28, s26
 b18:	fmadd	s26, s29, s26, s30
 b1c:	fmadd	s30, s29, s26, s30
 b20:	fmul	s30, s30, s27
 b24:	b	6e0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6e0>
 b28:	mov	x19, #0x0                   	// #0
 b2c:	b	3a0 <price_options_neon(float const*, float const*, float const*, float const*, float const*, float*, long)+0x3a0>
