0000000000002020 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    2020:	cbz	x6, 27dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    2024:	stp	x29, x30, [sp, #-160]!
    2028:	mov	x29, sp
    202c:	stp	x23, x24, [sp, #48]
    2030:	mov	x24, x4
    2034:	mov	w4, #0xaa3b                	// #43579
    2038:	movk	w4, #0x3fb8, lsl #16
    203c:	mov	x23, x3
    2040:	mov	w3, #0x7218                	// #29208
    2044:	stp	x19, x20, [sp, #16]
    2048:	mov	x20, x0
    204c:	mov	w0, #0xc2b00000            	// #-1028653056
    2050:	movk	w3, #0x3f31, lsl #16
    2054:	mov	x19, x6
    2058:	stp	d8, d9, [sp, #80]
    205c:	fmov	s9, w0
    2060:	stp	d14, d15, [sp, #128]
    2064:	fmov	s14, w4
    2068:	stp	x21, x22, [sp, #32]
    206c:	mov	x21, x1
    2070:	mov	x22, x2
    2074:	mov	w1, #0x8889                	// #34953
    2078:	mov	w2, #0xb61                 	// #2913
    207c:	movk	w2, #0x3ab6, lsl #16
    2080:	movk	w1, #0x3c08, lsl #16
    2084:	stp	x25, x26, [sp, #64]
    2088:	mov	x26, #0x0                   	// #0
    208c:	mov	x25, x5
    2090:	stp	d10, d11, [sp, #96]
    2094:	stp	d12, d13, [sp, #112]
    2098:	stp	w3, w2, [sp, #148]
    209c:	str	w1, [sp, #156]
    20a0:	ldr	s12, [x22, x26, lsl #2]
    20a4:	ldr	s15, [x24, x26, lsl #2]
    20a8:	ldr	s13, [x20, x26, lsl #2]
    20ac:	fcmp	s12, #0.0
    20b0:	ldr	s8, [x21, x26, lsl #2]
    20b4:	ldr	s11, [x23, x26, lsl #2]
    20b8:	fmul	s10, s15, s15
    20bc:	b.pl	2174 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    20c0:	fmov	s0, s12
    20c4:	bl	ec0 <sqrtf@plt>
    20c8:	fmov	s31, s0
    20cc:	fdiv	s0, s13, s8
    20d0:	fmul	s15, s15, s31
    20d4:	bl	1020 <logf@plt>
    20d8:	fmov	s31, #5.000000000000000000e-01
    20dc:	mov	w0, #0x3389                	// #13193
    20e0:	fmov	s25, #1.000000000000000000e+00
    20e4:	movk	w0, #0x3e6d, lsl #16
    20e8:	mov	w1, #0x466f                	// #18031
    20ec:	fmov	s19, #-5.000000000000000000e-01
    20f0:	mov	w4, #0x1eea                	// #7914
    20f4:	movk	w1, #0x3faa, lsl #16
    20f8:	fmov	s29, w0
    20fc:	movk	w4, #0xbfe9, lsl #16
    2100:	mov	w3, #0x778                 	// #1912
    2104:	fmadd	s10, s10, s31, s11
    2108:	movk	w3, #0x3fe4, lsl #16
    210c:	mov	w2, #0x8f89                	// #36745
    2110:	fmov	s20, w1
    2114:	movk	w2, #0xbeb6, lsl #16
    2118:	mov	w1, #0x85fa                	// #34298
    211c:	movk	w1, #0x3ea3, lsl #16
    2120:	mov	w0, #0xaa3b                	// #43579
    2124:	fmov	s22, w4
    2128:	movk	w0, #0x3fb8, lsl #16
    212c:	fmov	s23, w3
    2130:	fmadd	s0, s12, s10, s0
    2134:	fmov	s24, w2
    2138:	fmov	s31, w1
    213c:	fmov	s28, w0
    2140:	fdiv	s0, s0, s15
    2144:	fmadd	s21, s0, s29, s25
    2148:	fmul	s29, s0, s19
    214c:	fsub	s15, s0, s15
    2150:	fmul	s29, s29, s0
    2154:	fdiv	s25, s25, s21
    2158:	fmul	s28, s29, s28
    215c:	fmadd	s22, s25, s20, s22
    2160:	fmadd	s23, s22, s25, s23
    2164:	fmadd	s24, s23, s25, s24
    2168:	fmadd	s31, s24, s25, s31
    216c:	fmul	s31, s31, s25
    2170:	b	2238 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    2174:	fsqrt	s31, s12
    2178:	fdiv	s0, s13, s8
    217c:	fmul	s15, s15, s31
    2180:	bl	1020 <logf@plt>
    2184:	fmov	s29, #5.000000000000000000e-01
    2188:	fmadd	s10, s10, s29, s11
    218c:	fmadd	s0, s12, s10, s0
    2190:	fdiv	s0, s0, s15
    2194:	fcmpe	s0, #0.0
    2198:	fsub	s15, s0, s15
    219c:	b.mi	257c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    21a0:	mov	w0, #0x3389                	// #13193
    21a4:	fmov	s31, #1.000000000000000000e+00
    21a8:	mov	w4, #0x466f                	// #18031
    21ac:	movk	w0, #0x3e6d, lsl #16
    21b0:	mov	w3, #0x1eea                	// #7914
    21b4:	fmov	s29, #-5.000000000000000000e-01
    21b8:	movk	w4, #0x3faa, lsl #16
    21bc:	movk	w3, #0xbfe9, lsl #16
    21c0:	fmov	s22, w0
    21c4:	mov	w2, #0x778                 	// #1912
    21c8:	mov	w1, #0x8f89                	// #36745
    21cc:	fmov	s21, w4
    21d0:	movk	w2, #0x3fe4, lsl #16
    21d4:	movk	w1, #0xbeb6, lsl #16
    21d8:	fmov	s23, w3
    21dc:	mov	w0, #0x85fa                	// #34298
    21e0:	fmov	s24, w2
    21e4:	movk	w0, #0x3ea3, lsl #16
    21e8:	fmov	s25, w1
    21ec:	fmov	s28, w0
    21f0:	fmul	s29, s0, s29
    21f4:	fmadd	s22, s0, s22, s31
    21f8:	fmul	s29, s29, s0
    21fc:	fcmpe	s29, s9
    2200:	fdiv	s31, s31, s22
    2204:	fmadd	s23, s31, s21, s23
    2208:	fmadd	s24, s31, s23, s24
    220c:	fmadd	s25, s31, s24, s25
    2210:	fmadd	s28, s31, s25, s28
    2214:	fmul	s31, s31, s28
    2218:	b.mi	268c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    221c:	mov	w0, #0x42b00000            	// #1118830592
    2220:	fmov	s28, w0
    2224:	fcmpe	s29, s28
    2228:	b.gt	22d8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    222c:	fmul	s28, s29, s14
    2230:	fcmpe	s28, #0.0
    2234:	b.ge	26ec <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    2238:	fmov	s23, #5.000000000000000000e-01
    223c:	mov	w0, #0x7218                	// #29208
    2240:	mov	w3, #0xb61                 	// #2913
    2244:	movk	w0, #0x3f31, lsl #16
    2248:	mov	w2, #0x8889                	// #34953
    224c:	fmov	s24, #1.000000000000000000e+00
    2250:	movk	w3, #0x3ab6, lsl #16
    2254:	movk	w2, #0x3c08, lsl #16
    2258:	fmov	s25, w0
    225c:	mov	w1, #0xaaab                	// #43691
    2260:	mov	w0, #0xaaab                	// #43691
    2264:	fsub	s28, s28, s23
    2268:	movk	w1, #0x3d2a, lsl #16
    226c:	movk	w0, #0x3e2a, lsl #16
    2270:	fmov	s18, w3
    2274:	mov	w4, #0x422a                	// #16938
    2278:	fmov	s20, w2
    227c:	movk	w4, #0x3ecc, lsl #16
    2280:	fmov	s21, w1
    2284:	fmov	s22, w0
    2288:	fmov	s19, w4
    228c:	fcvtzs	s28, s28
    2290:	scvtf	s28, s28
    2294:	fmsub	s25, s28, s25, s29
    2298:	fcvtzs	w0, s28
    229c:	fmadd	s28, s25, s18, s20
    22a0:	add	w0, w0, #0x7f
    22a4:	fmov	s30, w0
    22a8:	fmadd	s28, s25, s28, s21
    22ac:	fmadd	s28, s25, s28, s22
    22b0:	shl	v29.2s, v30.2s, #23
    22b4:	fmadd	s23, s25, s28, s23
    22b8:	fmadd	s23, s25, s23, s24
    22bc:	fmadd	s24, s25, s23, s24
    22c0:	fmul	s29, s24, s29
    22c4:	fmul	s29, s29, s19
    22c8:	fcmpe	s0, #0.0
    22cc:	fmul	s31, s31, s29
    22d0:	b.mi	22f0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    22d4:	b	22e8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    22d8:	mov	w0, #0x484f                	// #18511
    22dc:	movk	w0, #0x7e46, lsl #16
    22e0:	fmov	s29, w0
    22e4:	fmul	s31, s31, s29
    22e8:	fmov	s29, #1.000000000000000000e+00
    22ec:	fsub	s31, s29, s31
    22f0:	fnmul	s30, s11, s12
    22f4:	fmul	s31, s13, s31
    22f8:	movi	v29.2s, #0x0
    22fc:	fcmpe	s30, s9
    2300:	b.mi	23a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2304:	mov	w0, #0x42b00000            	// #1118830592
    2308:	fmov	s29, w0
    230c:	fcmpe	s30, s29
    2310:	b.gt	2698 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2314:	fmul	s28, s30, s14
    2318:	fcmpe	s28, #0.0
    231c:	b.ge	26a8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    2320:	fmov	s27, #5.000000000000000000e-01
    2324:	mov	w0, #0x7218                	// #29208
    2328:	mov	w3, #0xb61                 	// #2913
    232c:	movk	w0, #0x3f31, lsl #16
    2330:	mov	w2, #0x8889                	// #34953
    2334:	fmov	s29, #1.000000000000000000e+00
    2338:	movk	w3, #0x3ab6, lsl #16
    233c:	movk	w2, #0x3c08, lsl #16
    2340:	fmov	s22, w0
    2344:	mov	w1, #0xaaab                	// #43691
    2348:	mov	w0, #0xaaab                	// #43691
    234c:	fsub	s28, s28, s27
    2350:	movk	w1, #0x3d2a, lsl #16
    2354:	movk	w0, #0x3e2a, lsl #16
    2358:	fmov	s23, w3
    235c:	fmov	s24, w2
    2360:	fmov	s25, w1
    2364:	fmov	s26, w0
    2368:	fcvtzs	s28, s28
    236c:	scvtf	s28, s28
    2370:	fmsub	s30, s28, s22, s30
    2374:	fcvtzs	w0, s28
    2378:	fmadd	s24, s30, s23, s24
    237c:	fmadd	s25, s30, s24, s25
    2380:	add	w0, w0, #0x7f
    2384:	fmov	s28, w0
    2388:	fmadd	s26, s30, s25, s26
    238c:	fmadd	s27, s30, s26, s27
    2390:	shl	v28.2s, v28.2s, #23
    2394:	fmadd	s27, s30, s27, s29
    2398:	fmadd	s29, s30, s27, s29
    239c:	fmul	s29, s29, s28
    23a0:	fcmpe	s15, #0.0
    23a4:	fmul	s29, s8, s29
    23a8:	b.mi	2604 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    23ac:	mov	w0, #0x3389                	// #13193
    23b0:	fmov	s30, #1.000000000000000000e+00
    23b4:	mov	w4, #0x466f                	// #18031
    23b8:	movk	w0, #0x3e6d, lsl #16
    23bc:	mov	w3, #0x1eea                	// #7914
    23c0:	fmov	s27, #-5.000000000000000000e-01
    23c4:	movk	w4, #0x3faa, lsl #16
    23c8:	movk	w3, #0xbfe9, lsl #16
    23cc:	fmov	s23, w0
    23d0:	mov	w2, #0x778                 	// #1912
    23d4:	mov	w1, #0x8f89                	// #36745
    23d8:	fmov	s22, w4
    23dc:	movk	w2, #0x3fe4, lsl #16
    23e0:	movk	w1, #0xbeb6, lsl #16
    23e4:	fmov	s24, w3
    23e8:	mov	w0, #0x85fa                	// #34298
    23ec:	fmov	s25, w2
    23f0:	movk	w0, #0x3ea3, lsl #16
    23f4:	fmov	s26, w1
    23f8:	fmov	s28, w0
    23fc:	fmul	s27, s15, s27
    2400:	fmadd	s23, s15, s23, s30
    2404:	fmul	s27, s27, s15
    2408:	fcmpe	s27, s9
    240c:	fdiv	s30, s30, s23
    2410:	fmadd	s24, s30, s22, s24
    2414:	fmadd	s25, s30, s24, s25
    2418:	fmadd	s26, s30, s25, s26
    241c:	fmadd	s28, s30, s26, s28
    2420:	fmul	s30, s30, s28
    2424:	b.mi	2684 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    2428:	mov	w0, #0x42b00000            	// #1118830592
    242c:	fmov	s28, w0
    2430:	fcmpe	s27, s28
    2434:	b.gt	252c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    2438:	nop
    243c:	nop
    2440:	fmul	s28, s27, s14
    2444:	fcmpe	s28, #0.0
    2448:	b.ge	2764 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    244c:	fmov	s25, #5.000000000000000000e-01
    2450:	mov	w0, #0x7218                	// #29208
    2454:	mov	w4, #0xb61                 	// #2913
    2458:	movk	w0, #0x3f31, lsl #16
    245c:	mov	w2, #0x8889                	// #34953
    2460:	fmov	s26, #1.000000000000000000e+00
    2464:	movk	w4, #0x3ab6, lsl #16
    2468:	movk	w2, #0x3c08, lsl #16
    246c:	fmov	s19, w0
    2470:	mov	w1, #0xaaab                	// #43691
    2474:	mov	w0, #0xaaab                	// #43691
    2478:	fsub	s28, s28, s25
    247c:	movk	w1, #0x3d2a, lsl #16
    2480:	movk	w0, #0x3e2a, lsl #16
    2484:	fmov	s20, w4
    2488:	mov	w3, #0x422a                	// #16938
    248c:	fmov	s22, w2
    2490:	movk	w3, #0x3ecc, lsl #16
    2494:	fmov	s23, w1
    2498:	fmov	s24, w0
    249c:	fmov	s21, w3
    24a0:	fcvtzs	s28, s28
    24a4:	scvtf	s28, s28
    24a8:	fmsub	s27, s28, s19, s27
    24ac:	fcvtzs	w0, s28
    24b0:	fmadd	s22, s27, s20, s22
    24b4:	add	w0, w0, #0x7f
    24b8:	fmov	s28, w0
    24bc:	fmadd	s23, s27, s22, s23
    24c0:	fmadd	s24, s27, s23, s24
    24c4:	shl	v28.2s, v28.2s, #23
    24c8:	fmadd	s25, s27, s24, s25
    24cc:	fmadd	s25, s27, s25, s26
    24d0:	fmadd	s26, s27, s25, s26
    24d4:	fmul	s28, s26, s28
    24d8:	fmul	s28, s28, s21
    24dc:	fcmpe	s15, #0.0
    24e0:	fmul	s30, s30, s28
    24e4:	b.mi	2564 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    24e8:	fmov	s28, #1.000000000000000000e+00
    24ec:	fsub	s30, s28, s30
    24f0:	fmsub	s31, s29, s30, s31
    24f4:	str	s31, [x25, x26, lsl #2]
    24f8:	add	x26, x26, #0x1
    24fc:	cmp	x26, x19
    2500:	b.ne	20a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2504:	ldp	d8, d9, [sp, #80]
    2508:	ldp	x19, x20, [sp, #16]
    250c:	ldp	x21, x22, [sp, #32]
    2510:	ldp	x23, x24, [sp, #48]
    2514:	ldp	x25, x26, [sp, #64]
    2518:	ldp	d10, d11, [sp, #96]
    251c:	ldp	d12, d13, [sp, #112]
    2520:	ldp	d14, d15, [sp, #128]
    2524:	ldp	x29, x30, [sp], #160
    2528:	ret
    252c:	mov	w0, #0x484f                	// #18511
    2530:	movk	w0, #0x7e46, lsl #16
    2534:	fmov	s28, w0
    2538:	fmul	s30, s30, s28
    253c:	fmov	s28, #1.000000000000000000e+00
    2540:	fsub	s30, s28, s30
    2544:	fmsub	s31, s29, s30, s31
    2548:	str	s31, [x25, x26, lsl #2]
    254c:	add	x26, x26, #0x1
    2550:	cmp	x26, x19
    2554:	b.ne	20a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2558:	b	2504 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    255c:	movi	v28.2s, #0x0
    2560:	fmul	s30, s30, s28
    2564:	fmsub	s30, s29, s30, s31
    2568:	str	s30, [x25, x26, lsl #2]
    256c:	add	x26, x26, #0x1
    2570:	cmp	x19, x26
    2574:	b.ne	20a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2578:	b	2504 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    257c:	mov	w0, #0x3389                	// #13193
    2580:	fmov	s31, #1.000000000000000000e+00
    2584:	mov	w4, #0x466f                	// #18031
    2588:	movk	w0, #0x3e6d, lsl #16
    258c:	mov	w3, #0x1eea                	// #7914
    2590:	fmul	s29, s0, s29
    2594:	movk	w4, #0x3faa, lsl #16
    2598:	movk	w3, #0xbfe9, lsl #16
    259c:	fmov	s22, w0
    25a0:	mov	w2, #0x778                 	// #1912
    25a4:	mov	w1, #0x8f89                	// #36745
    25a8:	fmov	s21, w4
    25ac:	movk	w2, #0x3fe4, lsl #16
    25b0:	movk	w1, #0xbeb6, lsl #16
    25b4:	fmov	s23, w3
    25b8:	mov	w0, #0x85fa                	// #34298
    25bc:	fmov	s24, w2
    25c0:	movk	w0, #0x3ea3, lsl #16
    25c4:	fmov	s25, w1
    25c8:	fmov	s28, w0
    25cc:	fnmul	s29, s0, s29
    25d0:	fmsub	s22, s0, s22, s31
    25d4:	fcmpe	s29, s9
    25d8:	fdiv	s31, s31, s22
    25dc:	fmadd	s23, s31, s21, s23
    25e0:	fmadd	s24, s31, s23, s24
    25e4:	fmadd	s25, s31, s24, s25
    25e8:	fmadd	s28, s31, s25, s28
    25ec:	fmul	s31, s31, s28
    25f0:	b.mi	25f8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    25f4:	b	222c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    25f8:	movi	v29.2s, #0x0
    25fc:	fmul	s31, s31, s29
    2600:	b	22f0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2604:	mov	w0, #0x3389                	// #13193
    2608:	fmov	s30, #1.000000000000000000e+00
    260c:	mov	w4, #0x466f                	// #18031
    2610:	movk	w0, #0x3e6d, lsl #16
    2614:	mov	w3, #0x1eea                	// #7914
    2618:	fmov	s27, #5.000000000000000000e-01
    261c:	movk	w4, #0x3faa, lsl #16
    2620:	movk	w3, #0xbfe9, lsl #16
    2624:	fmov	s23, w0
    2628:	mov	w2, #0x778                 	// #1912
    262c:	mov	w1, #0x8f89                	// #36745
    2630:	fmov	s22, w4
    2634:	movk	w2, #0x3fe4, lsl #16
    2638:	movk	w1, #0xbeb6, lsl #16
    263c:	fmov	s24, w3
    2640:	mov	w0, #0x85fa                	// #34298
    2644:	fmov	s25, w2
    2648:	movk	w0, #0x3ea3, lsl #16
    264c:	fmov	s26, w1
    2650:	fmov	s28, w0
    2654:	fmul	s27, s15, s27
    2658:	fmsub	s23, s15, s23, s30
    265c:	fnmul	s27, s15, s27
    2660:	fcmpe	s27, s9
    2664:	fdiv	s30, s30, s23
    2668:	fmadd	s24, s30, s22, s24
    266c:	fmadd	s25, s24, s30, s25
    2670:	fmadd	s26, s25, s30, s26
    2674:	fmadd	s28, s30, s26, s28
    2678:	fmul	s30, s30, s28
    267c:	b.mi	255c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2680:	b	2440 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2684:	movi	v28.2s, #0x0
    2688:	b	2538 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    268c:	movi	v29.2s, #0x0
    2690:	fmul	s31, s31, s29
    2694:	b	22e8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2698:	mov	w7, #0x829c                	// #33436
    269c:	movk	w7, #0x7ef8, lsl #16
    26a0:	fmov	s29, w7
    26a4:	b	23a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    26a8:	fmov	s27, #5.000000000000000000e-01
    26ac:	ldr	s24, [sp, #148]
    26b0:	mov	w0, #0xaaab                	// #43691
    26b4:	movk	w0, #0x3e2a, lsl #16
    26b8:	mov	w1, #0xaaab                	// #43691
    26bc:	fmov	s29, #1.000000000000000000e+00
    26c0:	movk	w1, #0x3d2a, lsl #16
    26c4:	fmov	s26, w0
    26c8:	fadd	s28, s28, s27
    26cc:	fmov	s25, w1
    26d0:	fcvtzs	s28, s28
    26d4:	scvtf	s28, s28
    26d8:	fmsub	s30, s28, s24, s30
    26dc:	fcvtzs	w0, s28
    26e0:	ldp	s24, s28, [sp, #152]
    26e4:	fmadd	s24, s30, s24, s28
    26e8:	b	237c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    26ec:	fmov	s24, #5.000000000000000000e-01
    26f0:	ldr	s30, [sp, #148]
    26f4:	mov	w1, #0xaaab                	// #43691
    26f8:	movk	w1, #0x3d2a, lsl #16
    26fc:	mov	w0, #0xaaab                	// #43691
    2700:	fmov	s25, #1.000000000000000000e+00
    2704:	movk	w0, #0x3e2a, lsl #16
    2708:	mov	w2, #0x422a                	// #16938
    270c:	fmov	s22, w1
    2710:	movk	w2, #0x3ecc, lsl #16
    2714:	fadd	s28, s28, s24
    2718:	fmov	s23, w0
    271c:	fmov	s21, w2
    2720:	fcvtzs	s28, s28
    2724:	scvtf	s28, s28
    2728:	fmsub	s29, s28, s30, s29
    272c:	fcvtzs	w7, s28
    2730:	ldp	s28, s30, [sp, #152]
    2734:	fmadd	s20, s29, s28, s30
    2738:	add	w7, w7, #0x7f
    273c:	fmov	s30, w7
    2740:	fmadd	s22, s29, s20, s22
    2744:	fmadd	s23, s29, s22, s23
    2748:	shl	v28.2s, v30.2s, #23
    274c:	fmadd	s24, s29, s23, s24
    2750:	fmadd	s24, s29, s24, s25
    2754:	fmadd	s29, s29, s24, s25
    2758:	fmul	s29, s29, s28
    275c:	fmul	s29, s29, s21
    2760:	b	22c8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    2764:	fmov	s25, #5.000000000000000000e-01
    2768:	ldr	s21, [sp, #148]
    276c:	mov	w0, #0xaaab                	// #43691
    2770:	movk	w0, #0x3e2a, lsl #16
    2774:	mov	w1, #0xaaab                	// #43691
    2778:	fmov	s26, #1.000000000000000000e+00
    277c:	movk	w1, #0x3d2a, lsl #16
    2780:	mov	w2, #0x422a                	// #16938
    2784:	fmov	s24, w0
    2788:	movk	w2, #0x3ecc, lsl #16
    278c:	fadd	s28, s28, s25
    2790:	fmov	s23, w1
    2794:	fmov	s22, w2
    2798:	fcvtzs	s28, s28
    279c:	scvtf	s28, s28
    27a0:	fmsub	s27, s28, s21, s27
    27a4:	fcvtzs	w0, s28
    27a8:	ldp	s21, s28, [sp, #152]
    27ac:	fmadd	s21, s27, s21, s28
    27b0:	add	w0, w0, #0x7f
    27b4:	fmov	s28, w0
    27b8:	fmadd	s23, s27, s21, s23
    27bc:	fmadd	s24, s27, s23, s24
    27c0:	shl	v28.2s, v28.2s, #23
    27c4:	fmadd	s25, s27, s24, s25
    27c8:	fmadd	s25, s27, s25, s26
    27cc:	fmadd	s26, s27, s25, s26
    27d0:	fmul	s28, s26, s28
    27d4:	fmul	s28, s28, s22
    27d8:	b	24dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    27dc:	ret
