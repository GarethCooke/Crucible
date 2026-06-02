
/home/gcooke/Development/Crucible/bench/build/demos/09-arm-neon/CMakeFiles/bs09_scalar_poly.dir/scalar_poly.cpp.o:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)>:
   0:	cmp	x6, #0x0
   4:	b.le	7bc <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x7bc>
   8:	stp	x29, x30, [sp, #-160]!
   c:	mov	x29, sp
  10:	stp	x23, x24, [sp, #48]
  14:	mov	x24, x4
  18:	mov	w4, #0xaa3b                	// #43579
  1c:	movk	w4, #0x3fb8, lsl #16
  20:	mov	x23, x3
  24:	mov	w3, #0x7218                	// #29208
  28:	stp	x19, x20, [sp, #16]
  2c:	mov	x20, x0
  30:	mov	w0, #0xc2b00000            	// #-1028653056
  34:	movk	w3, #0x3f31, lsl #16
  38:	mov	x19, x6
  3c:	stp	d8, d9, [sp, #80]
  40:	fmov	s9, w0
  44:	stp	d14, d15, [sp, #128]
  48:	fmov	s14, w4
  4c:	stp	x21, x22, [sp, #32]
  50:	mov	x21, x1
  54:	mov	x22, x2
  58:	mov	w1, #0x8889                	// #34953
  5c:	mov	w2, #0xb61                 	// #2913
  60:	movk	w2, #0x3ab6, lsl #16
  64:	movk	w1, #0x3c08, lsl #16
  68:	stp	x25, x26, [sp, #64]
  6c:	mov	x26, #0x0                   	// #0
  70:	mov	x25, x5
  74:	stp	d10, d11, [sp, #96]
  78:	stp	d12, d13, [sp, #112]
  7c:	stp	w3, w2, [sp, #148]
  80:	str	w1, [sp, #156]
  84:	ldr	s12, [x22, x26, lsl #2]
  88:	ldr	s15, [x24, x26, lsl #2]
  8c:	ldr	s13, [x20, x26, lsl #2]
  90:	fcmp	s12, #0.0
  94:	ldr	s8, [x21, x26, lsl #2]
  98:	ldr	s11, [x23, x26, lsl #2]
  9c:	fmul	s10, s15, s15
  a0:	b.pl	158 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x158>  // b.nfrst
  a4:	fmov	s0, s12
  a8:	bl	0 <sqrtf>
  ac:	fmov	s31, s0
  b0:	fdiv	s0, s13, s8
  b4:	fmul	s15, s15, s31
  b8:	bl	0 <logf>
  bc:	fmov	s31, #5.000000000000000000e-01
  c0:	mov	w0, #0x3389                	// #13193
  c4:	fmov	s25, #1.000000000000000000e+00
  c8:	movk	w0, #0x3e6d, lsl #16
  cc:	mov	w1, #0x466f                	// #18031
  d0:	fmov	s19, #-5.000000000000000000e-01
  d4:	mov	w4, #0x1eea                	// #7914
  d8:	movk	w1, #0x3faa, lsl #16
  dc:	fmov	s29, w0
  e0:	movk	w4, #0xbfe9, lsl #16
  e4:	mov	w3, #0x778                 	// #1912
  e8:	fmadd	s10, s10, s31, s11
  ec:	movk	w3, #0x3fe4, lsl #16
  f0:	mov	w2, #0x8f89                	// #36745
  f4:	fmov	s20, w1
  f8:	movk	w2, #0xbeb6, lsl #16
  fc:	mov	w1, #0x85fa                	// #34298
 100:	movk	w1, #0x3ea3, lsl #16
 104:	mov	w0, #0xaa3b                	// #43579
 108:	fmov	s22, w4
 10c:	movk	w0, #0x3fb8, lsl #16
 110:	fmov	s23, w3
 114:	fmadd	s0, s12, s10, s0
 118:	fmov	s24, w2
 11c:	fmov	s31, w1
 120:	fmov	s28, w0
 124:	fdiv	s0, s0, s15
 128:	fmadd	s21, s0, s29, s25
 12c:	fmul	s29, s0, s19
 130:	fsub	s15, s0, s15
 134:	fmul	s29, s29, s0
 138:	fdiv	s25, s25, s21
 13c:	fmul	s28, s29, s28
 140:	fmadd	s22, s25, s20, s22
 144:	fmadd	s23, s22, s25, s23
 148:	fmadd	s24, s23, s25, s24
 14c:	fmadd	s31, s24, s25, s31
 150:	fmul	s31, s31, s25
 154:	b	21c <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x21c>
 158:	fsqrt	s31, s12
 15c:	fdiv	s0, s13, s8
 160:	fmul	s15, s15, s31
 164:	bl	0 <logf>
 168:	fmov	s29, #5.000000000000000000e-01
 16c:	fmadd	s10, s10, s29, s11
 170:	fmadd	s0, s12, s10, s0
 174:	fdiv	s0, s0, s15
 178:	fcmpe	s0, #0.0
 17c:	fsub	s15, s0, s15
 180:	b.mi	55c <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x55c>  // b.first
 184:	mov	w0, #0x3389                	// #13193
 188:	fmov	s31, #1.000000000000000000e+00
 18c:	mov	w4, #0x466f                	// #18031
 190:	movk	w0, #0x3e6d, lsl #16
 194:	mov	w3, #0x1eea                	// #7914
 198:	fmov	s29, #-5.000000000000000000e-01
 19c:	movk	w4, #0x3faa, lsl #16
 1a0:	movk	w3, #0xbfe9, lsl #16
 1a4:	fmov	s22, w0
 1a8:	mov	w2, #0x778                 	// #1912
 1ac:	mov	w1, #0x8f89                	// #36745
 1b0:	fmov	s21, w4
 1b4:	movk	w2, #0x3fe4, lsl #16
 1b8:	movk	w1, #0xbeb6, lsl #16
 1bc:	fmov	s23, w3
 1c0:	mov	w0, #0x85fa                	// #34298
 1c4:	fmov	s24, w2
 1c8:	movk	w0, #0x3ea3, lsl #16
 1cc:	fmov	s25, w1
 1d0:	fmov	s28, w0
 1d4:	fmul	s29, s0, s29
 1d8:	fmadd	s22, s0, s22, s31
 1dc:	fmul	s29, s29, s0
 1e0:	fcmpe	s29, s9
 1e4:	fdiv	s31, s31, s22
 1e8:	fmadd	s23, s31, s21, s23
 1ec:	fmadd	s24, s31, s23, s24
 1f0:	fmadd	s25, s31, s24, s25
 1f4:	fmadd	s28, s31, s25, s28
 1f8:	fmul	s31, s31, s28
 1fc:	b.mi	66c <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x66c>  // b.first
 200:	mov	w0, #0x42b00000            	// #1118830592
 204:	fmov	s28, w0
 208:	fcmpe	s29, s28
 20c:	b.gt	2bc <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2bc>
 210:	fmul	s28, s29, s14
 214:	fcmpe	s28, #0.0
 218:	b.ge	6cc <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x6cc>  // b.tcont
 21c:	fmov	s23, #5.000000000000000000e-01
 220:	mov	w0, #0x7218                	// #29208
 224:	mov	w3, #0xb61                 	// #2913
 228:	movk	w0, #0x3f31, lsl #16
 22c:	mov	w2, #0x8889                	// #34953
 230:	fmov	s24, #1.000000000000000000e+00
 234:	movk	w3, #0x3ab6, lsl #16
 238:	movk	w2, #0x3c08, lsl #16
 23c:	fmov	s25, w0
 240:	mov	w1, #0xaaab                	// #43691
 244:	mov	w0, #0xaaab                	// #43691
 248:	fsub	s28, s28, s23
 24c:	movk	w1, #0x3d2a, lsl #16
 250:	movk	w0, #0x3e2a, lsl #16
 254:	fmov	s18, w3
 258:	mov	w4, #0x422a                	// #16938
 25c:	fmov	s20, w2
 260:	movk	w4, #0x3ecc, lsl #16
 264:	fmov	s21, w1
 268:	fmov	s22, w0
 26c:	fmov	s19, w4
 270:	fcvtzs	s28, s28
 274:	scvtf	s28, s28
 278:	fmsub	s25, s28, s25, s29
 27c:	fcvtzs	w0, s28
 280:	fmadd	s28, s25, s18, s20
 284:	add	w0, w0, #0x7f
 288:	fmov	s30, w0
 28c:	fmadd	s28, s25, s28, s21
 290:	fmadd	s28, s25, s28, s22
 294:	shl	v29.2s, v30.2s, #23
 298:	fmadd	s23, s25, s28, s23
 29c:	fmadd	s23, s25, s23, s24
 2a0:	fmadd	s24, s25, s23, s24
 2a4:	fmul	s29, s24, s29
 2a8:	fmul	s29, s29, s19
 2ac:	fcmpe	s0, #0.0
 2b0:	fmul	s31, s31, s29
 2b4:	b.mi	2d4 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2d4>  // b.first
 2b8:	b	2cc <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2cc>
 2bc:	mov	w0, #0x484f                	// #18511
 2c0:	movk	w0, #0x7e46, lsl #16
 2c4:	fmov	s29, w0
 2c8:	fmul	s31, s31, s29
 2cc:	fmov	s29, #1.000000000000000000e+00
 2d0:	fsub	s31, s29, s31
 2d4:	fnmul	s30, s11, s12
 2d8:	fmul	s31, s13, s31
 2dc:	movi	v29.2s, #0x0
 2e0:	fcmpe	s30, s9
 2e4:	b.mi	384 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x384>  // b.first
 2e8:	mov	w0, #0x42b00000            	// #1118830592
 2ec:	fmov	s29, w0
 2f0:	fcmpe	s30, s29
 2f4:	b.gt	678 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x678>
 2f8:	fmul	s28, s30, s14
 2fc:	fcmpe	s28, #0.0
 300:	b.ge	688 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x688>  // b.tcont
 304:	fmov	s27, #5.000000000000000000e-01
 308:	mov	w0, #0x7218                	// #29208
 30c:	mov	w3, #0xb61                 	// #2913
 310:	movk	w0, #0x3f31, lsl #16
 314:	mov	w2, #0x8889                	// #34953
 318:	fmov	s29, #1.000000000000000000e+00
 31c:	movk	w3, #0x3ab6, lsl #16
 320:	movk	w2, #0x3c08, lsl #16
 324:	fmov	s22, w0
 328:	mov	w1, #0xaaab                	// #43691
 32c:	mov	w0, #0xaaab                	// #43691
 330:	fsub	s28, s28, s27
 334:	movk	w1, #0x3d2a, lsl #16
 338:	movk	w0, #0x3e2a, lsl #16
 33c:	fmov	s23, w3
 340:	fmov	s24, w2
 344:	fmov	s25, w1
 348:	fmov	s26, w0
 34c:	fcvtzs	s28, s28
 350:	scvtf	s28, s28
 354:	fmsub	s30, s28, s22, s30
 358:	fcvtzs	w0, s28
 35c:	fmadd	s24, s30, s23, s24
 360:	fmadd	s25, s30, s24, s25
 364:	add	w0, w0, #0x7f
 368:	fmov	s28, w0
 36c:	fmadd	s26, s30, s25, s26
 370:	fmadd	s27, s30, s26, s27
 374:	shl	v28.2s, v28.2s, #23
 378:	fmadd	s27, s30, s27, s29
 37c:	fmadd	s29, s30, s27, s29
 380:	fmul	s29, s29, s28
 384:	fcmpe	s15, #0.0
 388:	fmul	s29, s8, s29
 38c:	b.mi	5e4 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5e4>  // b.first
 390:	mov	w0, #0x3389                	// #13193
 394:	fmov	s30, #1.000000000000000000e+00
 398:	mov	w4, #0x466f                	// #18031
 39c:	movk	w0, #0x3e6d, lsl #16
 3a0:	mov	w3, #0x1eea                	// #7914
 3a4:	fmov	s27, #-5.000000000000000000e-01
 3a8:	movk	w4, #0x3faa, lsl #16
 3ac:	movk	w3, #0xbfe9, lsl #16
 3b0:	fmov	s23, w0
 3b4:	mov	w2, #0x778                 	// #1912
 3b8:	mov	w1, #0x8f89                	// #36745
 3bc:	fmov	s22, w4
 3c0:	movk	w2, #0x3fe4, lsl #16
 3c4:	movk	w1, #0xbeb6, lsl #16
 3c8:	fmov	s24, w3
 3cc:	mov	w0, #0x85fa                	// #34298
 3d0:	fmov	s25, w2
 3d4:	movk	w0, #0x3ea3, lsl #16
 3d8:	fmov	s26, w1
 3dc:	fmov	s28, w0
 3e0:	fmul	s27, s15, s27
 3e4:	fmadd	s23, s15, s23, s30
 3e8:	fmul	s27, s27, s15
 3ec:	fcmpe	s27, s9
 3f0:	fdiv	s30, s30, s23
 3f4:	fmadd	s24, s30, s22, s24
 3f8:	fmadd	s25, s30, s24, s25
 3fc:	fmadd	s26, s30, s25, s26
 400:	fmadd	s28, s30, s26, s28
 404:	fmul	s30, s30, s28
 408:	b.mi	664 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x664>  // b.first
 40c:	mov	w0, #0x42b00000            	// #1118830592
 410:	fmov	s28, w0
 414:	fcmpe	s27, s28
 418:	b.gt	50c <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x50c>
 41c:	nop
 420:	fmul	s28, s27, s14
 424:	fcmpe	s28, #0.0
 428:	b.ge	744 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x744>  // b.tcont
 42c:	fmov	s25, #5.000000000000000000e-01
 430:	mov	w0, #0x7218                	// #29208
 434:	mov	w4, #0xb61                 	// #2913
 438:	movk	w0, #0x3f31, lsl #16
 43c:	mov	w2, #0x8889                	// #34953
 440:	fmov	s26, #1.000000000000000000e+00
 444:	movk	w4, #0x3ab6, lsl #16
 448:	movk	w2, #0x3c08, lsl #16
 44c:	fmov	s19, w0
 450:	mov	w1, #0xaaab                	// #43691
 454:	mov	w0, #0xaaab                	// #43691
 458:	fsub	s28, s28, s25
 45c:	movk	w1, #0x3d2a, lsl #16
 460:	movk	w0, #0x3e2a, lsl #16
 464:	fmov	s20, w4
 468:	mov	w3, #0x422a                	// #16938
 46c:	fmov	s22, w2
 470:	movk	w3, #0x3ecc, lsl #16
 474:	fmov	s23, w1
 478:	fmov	s24, w0
 47c:	fmov	s21, w3
 480:	fcvtzs	s28, s28
 484:	scvtf	s28, s28
 488:	fmsub	s27, s28, s19, s27
 48c:	fcvtzs	w0, s28
 490:	fmadd	s22, s27, s20, s22
 494:	add	w0, w0, #0x7f
 498:	fmov	s28, w0
 49c:	fmadd	s23, s27, s22, s23
 4a0:	fmadd	s24, s27, s23, s24
 4a4:	shl	v28.2s, v28.2s, #23
 4a8:	fmadd	s25, s27, s24, s25
 4ac:	fmadd	s25, s27, s25, s26
 4b0:	fmadd	s26, s27, s25, s26
 4b4:	fmul	s28, s26, s28
 4b8:	fmul	s28, s28, s21
 4bc:	fcmpe	s15, #0.0
 4c0:	fmul	s30, s30, s28
 4c4:	b.mi	544 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x544>  // b.first
 4c8:	fmov	s28, #1.000000000000000000e+00
 4cc:	fsub	s30, s28, s30
 4d0:	fmsub	s31, s29, s30, s31
 4d4:	str	s31, [x25, x26, lsl #2]
 4d8:	add	x26, x26, #0x1
 4dc:	cmp	x26, x19
 4e0:	b.ne	84 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x84>  // b.any
 4e4:	ldp	d8, d9, [sp, #80]
 4e8:	ldp	x19, x20, [sp, #16]
 4ec:	ldp	x21, x22, [sp, #32]
 4f0:	ldp	x23, x24, [sp, #48]
 4f4:	ldp	x25, x26, [sp, #64]
 4f8:	ldp	d10, d11, [sp, #96]
 4fc:	ldp	d12, d13, [sp, #112]
 500:	ldp	d14, d15, [sp, #128]
 504:	ldp	x29, x30, [sp], #160
 508:	ret
 50c:	mov	w0, #0x484f                	// #18511
 510:	movk	w0, #0x7e46, lsl #16
 514:	fmov	s28, w0
 518:	fmul	s30, s30, s28
 51c:	fmov	s28, #1.000000000000000000e+00
 520:	fsub	s30, s28, s30
 524:	fmsub	s31, s29, s30, s31
 528:	str	s31, [x25, x26, lsl #2]
 52c:	add	x26, x26, #0x1
 530:	cmp	x26, x19
 534:	b.ne	84 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x84>  // b.any
 538:	b	4e4 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4e4>
 53c:	movi	v28.2s, #0x0
 540:	fmul	s30, s30, s28
 544:	fmsub	s30, s29, s30, s31
 548:	str	s30, [x25, x26, lsl #2]
 54c:	add	x26, x26, #0x1
 550:	cmp	x19, x26
 554:	b.ne	84 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x84>  // b.any
 558:	b	4e4 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4e4>
 55c:	mov	w0, #0x3389                	// #13193
 560:	fmov	s31, #1.000000000000000000e+00
 564:	mov	w4, #0x466f                	// #18031
 568:	movk	w0, #0x3e6d, lsl #16
 56c:	mov	w3, #0x1eea                	// #7914
 570:	fmul	s29, s0, s29
 574:	movk	w4, #0x3faa, lsl #16
 578:	movk	w3, #0xbfe9, lsl #16
 57c:	fmov	s22, w0
 580:	mov	w2, #0x778                 	// #1912
 584:	mov	w1, #0x8f89                	// #36745
 588:	fmov	s21, w4
 58c:	movk	w2, #0x3fe4, lsl #16
 590:	movk	w1, #0xbeb6, lsl #16
 594:	fmov	s23, w3
 598:	mov	w0, #0x85fa                	// #34298
 59c:	fmov	s24, w2
 5a0:	movk	w0, #0x3ea3, lsl #16
 5a4:	fmov	s25, w1
 5a8:	fmov	s28, w0
 5ac:	fnmul	s29, s0, s29
 5b0:	fmsub	s22, s0, s22, s31
 5b4:	fcmpe	s29, s9
 5b8:	fdiv	s31, s31, s22
 5bc:	fmadd	s23, s31, s21, s23
 5c0:	fmadd	s24, s31, s23, s24
 5c4:	fmadd	s25, s31, s24, s25
 5c8:	fmadd	s28, s31, s25, s28
 5cc:	fmul	s31, s31, s28
 5d0:	b.mi	5d8 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x5d8>  // b.first
 5d4:	b	210 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x210>
 5d8:	movi	v29.2s, #0x0
 5dc:	fmul	s31, s31, s29
 5e0:	b	2d4 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2d4>
 5e4:	mov	w0, #0x3389                	// #13193
 5e8:	fmov	s30, #1.000000000000000000e+00
 5ec:	mov	w4, #0x466f                	// #18031
 5f0:	movk	w0, #0x3e6d, lsl #16
 5f4:	mov	w3, #0x1eea                	// #7914
 5f8:	fmov	s27, #5.000000000000000000e-01
 5fc:	movk	w4, #0x3faa, lsl #16
 600:	movk	w3, #0xbfe9, lsl #16
 604:	fmov	s23, w0
 608:	mov	w2, #0x778                 	// #1912
 60c:	mov	w1, #0x8f89                	// #36745
 610:	fmov	s22, w4
 614:	movk	w2, #0x3fe4, lsl #16
 618:	movk	w1, #0xbeb6, lsl #16
 61c:	fmov	s24, w3
 620:	mov	w0, #0x85fa                	// #34298
 624:	fmov	s25, w2
 628:	movk	w0, #0x3ea3, lsl #16
 62c:	fmov	s26, w1
 630:	fmov	s28, w0
 634:	fmul	s27, s15, s27
 638:	fmsub	s23, s15, s23, s30
 63c:	fnmul	s27, s15, s27
 640:	fcmpe	s27, s9
 644:	fdiv	s30, s30, s23
 648:	fmadd	s24, s30, s22, s24
 64c:	fmadd	s25, s24, s30, s25
 650:	fmadd	s26, s25, s30, s26
 654:	fmadd	s28, s30, s26, s28
 658:	fmul	s30, s30, s28
 65c:	b.mi	53c <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x53c>  // b.first
 660:	b	420 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x420>
 664:	movi	v28.2s, #0x0
 668:	b	518 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x518>
 66c:	movi	v29.2s, #0x0
 670:	fmul	s31, s31, s29
 674:	b	2cc <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2cc>
 678:	mov	w7, #0x829c                	// #33436
 67c:	movk	w7, #0x7ef8, lsl #16
 680:	fmov	s29, w7
 684:	b	384 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x384>
 688:	fmov	s27, #5.000000000000000000e-01
 68c:	ldr	s24, [sp, #148]
 690:	mov	w0, #0xaaab                	// #43691
 694:	movk	w0, #0x3e2a, lsl #16
 698:	mov	w1, #0xaaab                	// #43691
 69c:	fmov	s29, #1.000000000000000000e+00
 6a0:	movk	w1, #0x3d2a, lsl #16
 6a4:	fmov	s26, w0
 6a8:	fadd	s28, s28, s27
 6ac:	fmov	s25, w1
 6b0:	fcvtzs	s28, s28
 6b4:	scvtf	s28, s28
 6b8:	fmsub	s30, s28, s24, s30
 6bc:	fcvtzs	w0, s28
 6c0:	ldp	s24, s28, [sp, #152]
 6c4:	fmadd	s24, s30, s24, s28
 6c8:	b	360 <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x360>
 6cc:	fmov	s24, #5.000000000000000000e-01
 6d0:	ldr	s30, [sp, #148]
 6d4:	mov	w1, #0xaaab                	// #43691
 6d8:	movk	w1, #0x3d2a, lsl #16
 6dc:	mov	w0, #0xaaab                	// #43691
 6e0:	fmov	s25, #1.000000000000000000e+00
 6e4:	movk	w0, #0x3e2a, lsl #16
 6e8:	mov	w2, #0x422a                	// #16938
 6ec:	fmov	s22, w1
 6f0:	movk	w2, #0x3ecc, lsl #16
 6f4:	fadd	s28, s28, s24
 6f8:	fmov	s23, w0
 6fc:	fmov	s21, w2
 700:	fcvtzs	s28, s28
 704:	scvtf	s28, s28
 708:	fmsub	s29, s28, s30, s29
 70c:	fcvtzs	w7, s28
 710:	ldp	s28, s30, [sp, #152]
 714:	fmadd	s20, s29, s28, s30
 718:	add	w7, w7, #0x7f
 71c:	fmov	s30, w7
 720:	fmadd	s22, s29, s20, s22
 724:	fmadd	s23, s29, s22, s23
 728:	shl	v28.2s, v30.2s, #23
 72c:	fmadd	s24, s29, s23, s24
 730:	fmadd	s24, s29, s24, s25
 734:	fmadd	s29, s29, s24, s25
 738:	fmul	s29, s29, s28
 73c:	fmul	s29, s29, s21
 740:	b	2ac <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x2ac>
 744:	fmov	s25, #5.000000000000000000e-01
 748:	ldr	s21, [sp, #148]
 74c:	mov	w0, #0xaaab                	// #43691
 750:	movk	w0, #0x3e2a, lsl #16
 754:	mov	w1, #0xaaab                	// #43691
 758:	fmov	s26, #1.000000000000000000e+00
 75c:	movk	w1, #0x3d2a, lsl #16
 760:	mov	w2, #0x422a                	// #16938
 764:	fmov	s24, w0
 768:	movk	w2, #0x3ecc, lsl #16
 76c:	fadd	s28, s28, s25
 770:	fmov	s23, w1
 774:	fmov	s22, w2
 778:	fcvtzs	s28, s28
 77c:	scvtf	s28, s28
 780:	fmsub	s27, s28, s21, s27
 784:	fcvtzs	w0, s28
 788:	ldp	s21, s28, [sp, #152]
 78c:	fmadd	s21, s27, s21, s28
 790:	add	w0, w0, #0x7f
 794:	fmov	s28, w0
 798:	fmadd	s23, s27, s21, s23
 79c:	fmadd	s24, s27, s23, s24
 7a0:	shl	v28.2s, v28.2s, #23
 7a4:	fmadd	s25, s27, s24, s25
 7a8:	fmadd	s25, s27, s25, s26
 7ac:	fmadd	s26, s27, s25, s26
 7b0:	fmul	s28, s26, s28
 7b4:	fmul	s28, s28, s22
 7b8:	b	4bc <price_options_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, long)+0x4bc>
 7bc:	ret
