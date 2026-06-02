00000000000020a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    20a0:	cbz	x6, 285c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    20a4:	stp	x29, x30, [sp, #-160]!
    20a8:	mov	x29, sp
    20ac:	stp	x23, x24, [sp, #48]
    20b0:	mov	x24, x4
    20b4:	mov	w4, #0xaa3b                	// #43579
    20b8:	movk	w4, #0x3fb8, lsl #16
    20bc:	mov	x23, x3
    20c0:	mov	w3, #0x7218                	// #29208
    20c4:	stp	x19, x20, [sp, #16]
    20c8:	mov	x20, x0
    20cc:	mov	w0, #0xc2b00000            	// #-1028653056
    20d0:	movk	w3, #0x3f31, lsl #16
    20d4:	mov	x19, x6
    20d8:	stp	d8, d9, [sp, #80]
    20dc:	fmov	s9, w0
    20e0:	stp	d14, d15, [sp, #128]
    20e4:	fmov	s14, w4
    20e8:	stp	x21, x22, [sp, #32]
    20ec:	mov	x21, x1
    20f0:	mov	x22, x2
    20f4:	mov	w1, #0x8889                	// #34953
    20f8:	mov	w2, #0xb61                 	// #2913
    20fc:	movk	w2, #0x3ab6, lsl #16
    2100:	movk	w1, #0x3c08, lsl #16
    2104:	stp	x25, x26, [sp, #64]
    2108:	mov	x26, #0x0                   	// #0
    210c:	mov	x25, x5
    2110:	stp	d10, d11, [sp, #96]
    2114:	stp	d12, d13, [sp, #112]
    2118:	stp	w3, w2, [sp, #148]
    211c:	str	w1, [sp, #156]
    2120:	ldr	s12, [x22, x26, lsl #2]
    2124:	ldr	s15, [x24, x26, lsl #2]
    2128:	ldr	s13, [x20, x26, lsl #2]
    212c:	fcmp	s12, #0.0
    2130:	ldr	s8, [x21, x26, lsl #2]
    2134:	ldr	s11, [x23, x26, lsl #2]
    2138:	fmul	s10, s15, s15
    213c:	b.pl	21f4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    2140:	fmov	s0, s12
    2144:	bl	ec0 <sqrtf@plt>
    2148:	fmov	s31, s0
    214c:	fdiv	s0, s13, s8
    2150:	fmul	s15, s15, s31
    2154:	bl	1020 <logf@plt>
    2158:	fmov	s31, #5.000000000000000000e-01
    215c:	mov	w0, #0x3389                	// #13193
    2160:	fmov	s25, #1.000000000000000000e+00
    2164:	movk	w0, #0x3e6d, lsl #16
    2168:	mov	w1, #0x466f                	// #18031
    216c:	fmov	s19, #-5.000000000000000000e-01
    2170:	mov	w4, #0x1eea                	// #7914
    2174:	movk	w1, #0x3faa, lsl #16
    2178:	fmov	s29, w0
    217c:	movk	w4, #0xbfe9, lsl #16
    2180:	mov	w3, #0x778                 	// #1912
    2184:	fmadd	s10, s10, s31, s11
    2188:	movk	w3, #0x3fe4, lsl #16
    218c:	mov	w2, #0x8f89                	// #36745
    2190:	fmov	s20, w1
    2194:	movk	w2, #0xbeb6, lsl #16
    2198:	mov	w1, #0x85fa                	// #34298
    219c:	movk	w1, #0x3ea3, lsl #16
    21a0:	mov	w0, #0xaa3b                	// #43579
    21a4:	fmov	s22, w4
    21a8:	movk	w0, #0x3fb8, lsl #16
    21ac:	fmov	s23, w3
    21b0:	fmadd	s0, s12, s10, s0
    21b4:	fmov	s24, w2
    21b8:	fmov	s31, w1
    21bc:	fmov	s28, w0
    21c0:	fdiv	s0, s0, s15
    21c4:	fmadd	s21, s0, s29, s25
    21c8:	fmul	s29, s0, s19
    21cc:	fsub	s15, s0, s15
    21d0:	fmul	s29, s29, s0
    21d4:	fdiv	s25, s25, s21
    21d8:	fmul	s28, s29, s28
    21dc:	fmadd	s22, s25, s20, s22
    21e0:	fmadd	s23, s22, s25, s23
    21e4:	fmadd	s24, s23, s25, s24
    21e8:	fmadd	s31, s24, s25, s31
    21ec:	fmul	s31, s31, s25
    21f0:	b	22b8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    21f4:	fsqrt	s31, s12
    21f8:	fdiv	s0, s13, s8
    21fc:	fmul	s15, s15, s31
    2200:	bl	1020 <logf@plt>
    2204:	fmov	s29, #5.000000000000000000e-01
    2208:	fmadd	s10, s10, s29, s11
    220c:	fmadd	s0, s12, s10, s0
    2210:	fdiv	s0, s0, s15
    2214:	fcmpe	s0, #0.0
    2218:	fsub	s15, s0, s15
    221c:	b.mi	25fc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    2220:	mov	w0, #0x3389                	// #13193
    2224:	fmov	s31, #1.000000000000000000e+00
    2228:	mov	w4, #0x466f                	// #18031
    222c:	movk	w0, #0x3e6d, lsl #16
    2230:	mov	w3, #0x1eea                	// #7914
    2234:	fmov	s29, #-5.000000000000000000e-01
    2238:	movk	w4, #0x3faa, lsl #16
    223c:	movk	w3, #0xbfe9, lsl #16
    2240:	fmov	s22, w0
    2244:	mov	w2, #0x778                 	// #1912
    2248:	mov	w1, #0x8f89                	// #36745
    224c:	fmov	s21, w4
    2250:	movk	w2, #0x3fe4, lsl #16
    2254:	movk	w1, #0xbeb6, lsl #16
    2258:	fmov	s23, w3
    225c:	mov	w0, #0x85fa                	// #34298
    2260:	fmov	s24, w2
    2264:	movk	w0, #0x3ea3, lsl #16
    2268:	fmov	s25, w1
    226c:	fmov	s28, w0
    2270:	fmul	s29, s0, s29
    2274:	fmadd	s22, s0, s22, s31
    2278:	fmul	s29, s29, s0
    227c:	fcmpe	s29, s9
    2280:	fdiv	s31, s31, s22
    2284:	fmadd	s23, s31, s21, s23
    2288:	fmadd	s24, s31, s23, s24
    228c:	fmadd	s25, s31, s24, s25
    2290:	fmadd	s28, s31, s25, s28
    2294:	fmul	s31, s31, s28
    2298:	b.mi	270c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    229c:	mov	w0, #0x42b00000            	// #1118830592
    22a0:	fmov	s28, w0
    22a4:	fcmpe	s29, s28
    22a8:	b.gt	2358 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    22ac:	fmul	s28, s29, s14
    22b0:	fcmpe	s28, #0.0
    22b4:	b.ge	276c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    22b8:	fmov	s23, #5.000000000000000000e-01
    22bc:	mov	w0, #0x7218                	// #29208
    22c0:	mov	w3, #0xb61                 	// #2913
    22c4:	movk	w0, #0x3f31, lsl #16
    22c8:	mov	w2, #0x8889                	// #34953
    22cc:	fmov	s24, #1.000000000000000000e+00
    22d0:	movk	w3, #0x3ab6, lsl #16
    22d4:	movk	w2, #0x3c08, lsl #16
    22d8:	fmov	s25, w0
    22dc:	mov	w1, #0xaaab                	// #43691
    22e0:	mov	w0, #0xaaab                	// #43691
    22e4:	fsub	s28, s28, s23
    22e8:	movk	w1, #0x3d2a, lsl #16
    22ec:	movk	w0, #0x3e2a, lsl #16
    22f0:	fmov	s18, w3
    22f4:	mov	w4, #0x422a                	// #16938
    22f8:	fmov	s20, w2
    22fc:	movk	w4, #0x3ecc, lsl #16
    2300:	fmov	s21, w1
    2304:	fmov	s22, w0
    2308:	fmov	s19, w4
    230c:	fcvtzs	s28, s28
    2310:	scvtf	s28, s28
    2314:	fmsub	s25, s28, s25, s29
    2318:	fcvtzs	w0, s28
    231c:	fmadd	s28, s25, s18, s20
    2320:	add	w0, w0, #0x7f
    2324:	fmov	s30, w0
    2328:	fmadd	s28, s25, s28, s21
    232c:	fmadd	s28, s25, s28, s22
    2330:	shl	v29.2s, v30.2s, #23
    2334:	fmadd	s23, s25, s28, s23
    2338:	fmadd	s23, s25, s23, s24
    233c:	fmadd	s24, s25, s23, s24
    2340:	fmul	s29, s24, s29
    2344:	fmul	s29, s29, s19
    2348:	fcmpe	s0, #0.0
    234c:	fmul	s31, s31, s29
    2350:	b.mi	2370 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    2354:	b	2368 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2358:	mov	w0, #0x484f                	// #18511
    235c:	movk	w0, #0x7e46, lsl #16
    2360:	fmov	s29, w0
    2364:	fmul	s31, s31, s29
    2368:	fmov	s29, #1.000000000000000000e+00
    236c:	fsub	s31, s29, s31
    2370:	fnmul	s30, s11, s12
    2374:	fmul	s31, s13, s31
    2378:	movi	v29.2s, #0x0
    237c:	fcmpe	s30, s9
    2380:	b.mi	2420 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2384:	mov	w0, #0x42b00000            	// #1118830592
    2388:	fmov	s29, w0
    238c:	fcmpe	s30, s29
    2390:	b.gt	2718 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2394:	fmul	s28, s30, s14
    2398:	fcmpe	s28, #0.0
    239c:	b.ge	2728 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    23a0:	fmov	s27, #5.000000000000000000e-01
    23a4:	mov	w0, #0x7218                	// #29208
    23a8:	mov	w3, #0xb61                 	// #2913
    23ac:	movk	w0, #0x3f31, lsl #16
    23b0:	mov	w2, #0x8889                	// #34953
    23b4:	fmov	s29, #1.000000000000000000e+00
    23b8:	movk	w3, #0x3ab6, lsl #16
    23bc:	movk	w2, #0x3c08, lsl #16
    23c0:	fmov	s22, w0
    23c4:	mov	w1, #0xaaab                	// #43691
    23c8:	mov	w0, #0xaaab                	// #43691
    23cc:	fsub	s28, s28, s27
    23d0:	movk	w1, #0x3d2a, lsl #16
    23d4:	movk	w0, #0x3e2a, lsl #16
    23d8:	fmov	s23, w3
    23dc:	fmov	s24, w2
    23e0:	fmov	s25, w1
    23e4:	fmov	s26, w0
    23e8:	fcvtzs	s28, s28
    23ec:	scvtf	s28, s28
    23f0:	fmsub	s30, s28, s22, s30
    23f4:	fcvtzs	w0, s28
    23f8:	fmadd	s24, s30, s23, s24
    23fc:	fmadd	s25, s30, s24, s25
    2400:	add	w0, w0, #0x7f
    2404:	fmov	s28, w0
    2408:	fmadd	s26, s30, s25, s26
    240c:	fmadd	s27, s30, s26, s27
    2410:	shl	v28.2s, v28.2s, #23
    2414:	fmadd	s27, s30, s27, s29
    2418:	fmadd	s29, s30, s27, s29
    241c:	fmul	s29, s29, s28
    2420:	fcmpe	s15, #0.0
    2424:	fmul	s29, s8, s29
    2428:	b.mi	2684 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    242c:	mov	w0, #0x3389                	// #13193
    2430:	fmov	s30, #1.000000000000000000e+00
    2434:	mov	w4, #0x466f                	// #18031
    2438:	movk	w0, #0x3e6d, lsl #16
    243c:	mov	w3, #0x1eea                	// #7914
    2440:	fmov	s27, #-5.000000000000000000e-01
    2444:	movk	w4, #0x3faa, lsl #16
    2448:	movk	w3, #0xbfe9, lsl #16
    244c:	fmov	s23, w0
    2450:	mov	w2, #0x778                 	// #1912
    2454:	mov	w1, #0x8f89                	// #36745
    2458:	fmov	s22, w4
    245c:	movk	w2, #0x3fe4, lsl #16
    2460:	movk	w1, #0xbeb6, lsl #16
    2464:	fmov	s24, w3
    2468:	mov	w0, #0x85fa                	// #34298
    246c:	fmov	s25, w2
    2470:	movk	w0, #0x3ea3, lsl #16
    2474:	fmov	s26, w1
    2478:	fmov	s28, w0
    247c:	fmul	s27, s15, s27
    2480:	fmadd	s23, s15, s23, s30
    2484:	fmul	s27, s27, s15
    2488:	fcmpe	s27, s9
    248c:	fdiv	s30, s30, s23
    2490:	fmadd	s24, s30, s22, s24
    2494:	fmadd	s25, s30, s24, s25
    2498:	fmadd	s26, s30, s25, s26
    249c:	fmadd	s28, s30, s26, s28
    24a0:	fmul	s30, s30, s28
    24a4:	b.mi	2704 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    24a8:	mov	w0, #0x42b00000            	// #1118830592
    24ac:	fmov	s28, w0
    24b0:	fcmpe	s27, s28
    24b4:	b.gt	25ac <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    24b8:	nop
    24bc:	nop
    24c0:	fmul	s28, s27, s14
    24c4:	fcmpe	s28, #0.0
    24c8:	b.ge	27e4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    24cc:	fmov	s25, #5.000000000000000000e-01
    24d0:	mov	w0, #0x7218                	// #29208
    24d4:	mov	w4, #0xb61                 	// #2913
    24d8:	movk	w0, #0x3f31, lsl #16
    24dc:	mov	w2, #0x8889                	// #34953
    24e0:	fmov	s26, #1.000000000000000000e+00
    24e4:	movk	w4, #0x3ab6, lsl #16
    24e8:	movk	w2, #0x3c08, lsl #16
    24ec:	fmov	s19, w0
    24f0:	mov	w1, #0xaaab                	// #43691
    24f4:	mov	w0, #0xaaab                	// #43691
    24f8:	fsub	s28, s28, s25
    24fc:	movk	w1, #0x3d2a, lsl #16
    2500:	movk	w0, #0x3e2a, lsl #16
    2504:	fmov	s20, w4
    2508:	mov	w3, #0x422a                	// #16938
    250c:	fmov	s22, w2
    2510:	movk	w3, #0x3ecc, lsl #16
    2514:	fmov	s23, w1
    2518:	fmov	s24, w0
    251c:	fmov	s21, w3
    2520:	fcvtzs	s28, s28
    2524:	scvtf	s28, s28
    2528:	fmsub	s27, s28, s19, s27
    252c:	fcvtzs	w0, s28
    2530:	fmadd	s22, s27, s20, s22
    2534:	add	w0, w0, #0x7f
    2538:	fmov	s28, w0
    253c:	fmadd	s23, s27, s22, s23
    2540:	fmadd	s24, s27, s23, s24
    2544:	shl	v28.2s, v28.2s, #23
    2548:	fmadd	s25, s27, s24, s25
    254c:	fmadd	s25, s27, s25, s26
    2550:	fmadd	s26, s27, s25, s26
    2554:	fmul	s28, s26, s28
    2558:	fmul	s28, s28, s21
    255c:	fcmpe	s15, #0.0
    2560:	fmul	s30, s30, s28
    2564:	b.mi	25e4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    2568:	fmov	s28, #1.000000000000000000e+00
    256c:	fsub	s30, s28, s30
    2570:	fmsub	s31, s29, s30, s31
    2574:	str	s31, [x25, x26, lsl #2]
    2578:	add	x26, x26, #0x1
    257c:	cmp	x26, x19
    2580:	b.ne	2120 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2584:	ldp	d8, d9, [sp, #80]
    2588:	ldp	x19, x20, [sp, #16]
    258c:	ldp	x21, x22, [sp, #32]
    2590:	ldp	x23, x24, [sp, #48]
    2594:	ldp	x25, x26, [sp, #64]
    2598:	ldp	d10, d11, [sp, #96]
    259c:	ldp	d12, d13, [sp, #112]
    25a0:	ldp	d14, d15, [sp, #128]
    25a4:	ldp	x29, x30, [sp], #160
    25a8:	ret
    25ac:	mov	w0, #0x484f                	// #18511
    25b0:	movk	w0, #0x7e46, lsl #16
    25b4:	fmov	s28, w0
    25b8:	fmul	s30, s30, s28
    25bc:	fmov	s28, #1.000000000000000000e+00
    25c0:	fsub	s30, s28, s30
    25c4:	fmsub	s31, s29, s30, s31
    25c8:	str	s31, [x25, x26, lsl #2]
    25cc:	add	x26, x26, #0x1
    25d0:	cmp	x26, x19
    25d4:	b.ne	2120 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    25d8:	b	2584 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    25dc:	movi	v28.2s, #0x0
    25e0:	fmul	s30, s30, s28
    25e4:	fmsub	s30, s29, s30, s31
    25e8:	str	s30, [x25, x26, lsl #2]
    25ec:	add	x26, x26, #0x1
    25f0:	cmp	x19, x26
    25f4:	b.ne	2120 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    25f8:	b	2584 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    25fc:	mov	w0, #0x3389                	// #13193
    2600:	fmov	s31, #1.000000000000000000e+00
    2604:	mov	w4, #0x466f                	// #18031
    2608:	movk	w0, #0x3e6d, lsl #16
    260c:	mov	w3, #0x1eea                	// #7914
    2610:	fmul	s29, s0, s29
    2614:	movk	w4, #0x3faa, lsl #16
    2618:	movk	w3, #0xbfe9, lsl #16
    261c:	fmov	s22, w0
    2620:	mov	w2, #0x778                 	// #1912
    2624:	mov	w1, #0x8f89                	// #36745
    2628:	fmov	s21, w4
    262c:	movk	w2, #0x3fe4, lsl #16
    2630:	movk	w1, #0xbeb6, lsl #16
    2634:	fmov	s23, w3
    2638:	mov	w0, #0x85fa                	// #34298
    263c:	fmov	s24, w2
    2640:	movk	w0, #0x3ea3, lsl #16
    2644:	fmov	s25, w1
    2648:	fmov	s28, w0
    264c:	fnmul	s29, s0, s29
    2650:	fmsub	s22, s0, s22, s31
    2654:	fcmpe	s29, s9
    2658:	fdiv	s31, s31, s22
    265c:	fmadd	s23, s31, s21, s23
    2660:	fmadd	s24, s31, s23, s24
    2664:	fmadd	s25, s31, s24, s25
    2668:	fmadd	s28, s31, s25, s28
    266c:	fmul	s31, s31, s28
    2670:	b.mi	2678 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    2674:	b	22ac <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    2678:	movi	v29.2s, #0x0
    267c:	fmul	s31, s31, s29
    2680:	b	2370 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2684:	mov	w0, #0x3389                	// #13193
    2688:	fmov	s30, #1.000000000000000000e+00
    268c:	mov	w4, #0x466f                	// #18031
    2690:	movk	w0, #0x3e6d, lsl #16
    2694:	mov	w3, #0x1eea                	// #7914
    2698:	fmov	s27, #5.000000000000000000e-01
    269c:	movk	w4, #0x3faa, lsl #16
    26a0:	movk	w3, #0xbfe9, lsl #16
    26a4:	fmov	s23, w0
    26a8:	mov	w2, #0x778                 	// #1912
    26ac:	mov	w1, #0x8f89                	// #36745
    26b0:	fmov	s22, w4
    26b4:	movk	w2, #0x3fe4, lsl #16
    26b8:	movk	w1, #0xbeb6, lsl #16
    26bc:	fmov	s24, w3
    26c0:	mov	w0, #0x85fa                	// #34298
    26c4:	fmov	s25, w2
    26c8:	movk	w0, #0x3ea3, lsl #16
    26cc:	fmov	s26, w1
    26d0:	fmov	s28, w0
    26d4:	fmul	s27, s15, s27
    26d8:	fmsub	s23, s15, s23, s30
    26dc:	fnmul	s27, s15, s27
    26e0:	fcmpe	s27, s9
    26e4:	fdiv	s30, s30, s23
    26e8:	fmadd	s24, s30, s22, s24
    26ec:	fmadd	s25, s24, s30, s25
    26f0:	fmadd	s26, s25, s30, s26
    26f4:	fmadd	s28, s30, s26, s28
    26f8:	fmul	s30, s30, s28
    26fc:	b.mi	25dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2700:	b	24c0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2704:	movi	v28.2s, #0x0
    2708:	b	25b8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    270c:	movi	v29.2s, #0x0
    2710:	fmul	s31, s31, s29
    2714:	b	2368 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2718:	mov	w7, #0x829c                	// #33436
    271c:	movk	w7, #0x7ef8, lsl #16
    2720:	fmov	s29, w7
    2724:	b	2420 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    2728:	fmov	s27, #5.000000000000000000e-01
    272c:	ldr	s24, [sp, #148]
    2730:	mov	w0, #0xaaab                	// #43691
    2734:	movk	w0, #0x3e2a, lsl #16
    2738:	mov	w1, #0xaaab                	// #43691
    273c:	fmov	s29, #1.000000000000000000e+00
    2740:	movk	w1, #0x3d2a, lsl #16
    2744:	fmov	s26, w0
    2748:	fadd	s28, s28, s27
    274c:	fmov	s25, w1
    2750:	fcvtzs	s28, s28
    2754:	scvtf	s28, s28
    2758:	fmsub	s30, s28, s24, s30
    275c:	fcvtzs	w0, s28
    2760:	ldp	s24, s28, [sp, #152]
    2764:	fmadd	s24, s30, s24, s28
    2768:	b	23fc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    276c:	fmov	s24, #5.000000000000000000e-01
    2770:	ldr	s30, [sp, #148]
    2774:	mov	w1, #0xaaab                	// #43691
    2778:	movk	w1, #0x3d2a, lsl #16
    277c:	mov	w0, #0xaaab                	// #43691
    2780:	fmov	s25, #1.000000000000000000e+00
    2784:	movk	w0, #0x3e2a, lsl #16
    2788:	mov	w2, #0x422a                	// #16938
    278c:	fmov	s22, w1
    2790:	movk	w2, #0x3ecc, lsl #16
    2794:	fadd	s28, s28, s24
    2798:	fmov	s23, w0
    279c:	fmov	s21, w2
    27a0:	fcvtzs	s28, s28
    27a4:	scvtf	s28, s28
    27a8:	fmsub	s29, s28, s30, s29
    27ac:	fcvtzs	w7, s28
    27b0:	ldp	s28, s30, [sp, #152]
    27b4:	fmadd	s20, s29, s28, s30
    27b8:	add	w7, w7, #0x7f
    27bc:	fmov	s30, w7
    27c0:	fmadd	s22, s29, s20, s22
    27c4:	fmadd	s23, s29, s22, s23
    27c8:	shl	v28.2s, v30.2s, #23
    27cc:	fmadd	s24, s29, s23, s24
    27d0:	fmadd	s24, s29, s24, s25
    27d4:	fmadd	s29, s29, s24, s25
    27d8:	fmul	s29, s29, s28
    27dc:	fmul	s29, s29, s21
    27e0:	b	2348 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    27e4:	fmov	s25, #5.000000000000000000e-01
    27e8:	ldr	s21, [sp, #148]
    27ec:	mov	w0, #0xaaab                	// #43691
    27f0:	movk	w0, #0x3e2a, lsl #16
    27f4:	mov	w1, #0xaaab                	// #43691
    27f8:	fmov	s26, #1.000000000000000000e+00
    27fc:	movk	w1, #0x3d2a, lsl #16
    2800:	mov	w2, #0x422a                	// #16938
    2804:	fmov	s24, w0
    2808:	movk	w2, #0x3ecc, lsl #16
    280c:	fadd	s28, s28, s25
    2810:	fmov	s23, w1
    2814:	fmov	s22, w2
    2818:	fcvtzs	s28, s28
    281c:	scvtf	s28, s28
    2820:	fmsub	s27, s28, s21, s27
    2824:	fcvtzs	w0, s28
    2828:	ldp	s21, s28, [sp, #152]
    282c:	fmadd	s21, s27, s21, s28
    2830:	add	w0, w0, #0x7f
    2834:	fmov	s28, w0
    2838:	fmadd	s23, s27, s21, s23
    283c:	fmadd	s24, s27, s23, s24
    2840:	shl	v28.2s, v28.2s, #23
    2844:	fmadd	s25, s27, s24, s25
    2848:	fmadd	s25, s27, s25, s26
    284c:	fmadd	s26, s27, s25, s26
    2850:	fmul	s28, s26, s28
    2854:	fmul	s28, s28, s22
    2858:	b	255c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    285c:	ret
