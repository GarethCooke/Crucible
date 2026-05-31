0000000000001fa0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    1fa0:	cbz	x6, 275c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    1fa4:	stp	x29, x30, [sp, #-160]!
    1fa8:	mov	x29, sp
    1fac:	stp	x23, x24, [sp, #48]
    1fb0:	mov	x24, x4
    1fb4:	mov	w4, #0xaa3b                	// #43579
    1fb8:	movk	w4, #0x3fb8, lsl #16
    1fbc:	mov	x23, x3
    1fc0:	mov	w3, #0x7218                	// #29208
    1fc4:	stp	x19, x20, [sp, #16]
    1fc8:	mov	x20, x0
    1fcc:	mov	w0, #0xc2b00000            	// #-1028653056
    1fd0:	movk	w3, #0x3f31, lsl #16
    1fd4:	mov	x19, x6
    1fd8:	stp	d8, d9, [sp, #80]
    1fdc:	fmov	s9, w0
    1fe0:	stp	d14, d15, [sp, #128]
    1fe4:	fmov	s14, w4
    1fe8:	stp	x21, x22, [sp, #32]
    1fec:	mov	x21, x1
    1ff0:	mov	x22, x2
    1ff4:	mov	w1, #0x8889                	// #34953
    1ff8:	mov	w2, #0xb61                 	// #2913
    1ffc:	movk	w2, #0x3ab6, lsl #16
    2000:	movk	w1, #0x3c08, lsl #16
    2004:	stp	x25, x26, [sp, #64]
    2008:	mov	x26, #0x0                   	// #0
    200c:	mov	x25, x5
    2010:	stp	d10, d11, [sp, #96]
    2014:	stp	d12, d13, [sp, #112]
    2018:	stp	w3, w2, [sp, #148]
    201c:	str	w1, [sp, #156]
    2020:	ldr	s12, [x22, x26, lsl #2]
    2024:	ldr	s15, [x24, x26, lsl #2]
    2028:	ldr	s13, [x20, x26, lsl #2]
    202c:	fcmp	s12, #0.0
    2030:	ldr	s8, [x21, x26, lsl #2]
    2034:	ldr	s11, [x23, x26, lsl #2]
    2038:	fmul	s10, s15, s15
    203c:	b.pl	20f4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    2040:	fmov	s0, s12
    2044:	bl	ec0 <sqrtf@plt>
    2048:	fmov	s31, s0
    204c:	fdiv	s0, s13, s8
    2050:	fmul	s15, s15, s31
    2054:	bl	1020 <logf@plt>
    2058:	fmov	s31, #5.000000000000000000e-01
    205c:	mov	w0, #0x3389                	// #13193
    2060:	fmov	s25, #1.000000000000000000e+00
    2064:	movk	w0, #0x3e6d, lsl #16
    2068:	mov	w1, #0x466f                	// #18031
    206c:	fmov	s19, #-5.000000000000000000e-01
    2070:	mov	w4, #0x1eea                	// #7914
    2074:	movk	w1, #0x3faa, lsl #16
    2078:	fmov	s29, w0
    207c:	movk	w4, #0xbfe9, lsl #16
    2080:	mov	w3, #0x778                 	// #1912
    2084:	fmadd	s10, s10, s31, s11
    2088:	movk	w3, #0x3fe4, lsl #16
    208c:	mov	w2, #0x8f89                	// #36745
    2090:	fmov	s20, w1
    2094:	movk	w2, #0xbeb6, lsl #16
    2098:	mov	w1, #0x85fa                	// #34298
    209c:	movk	w1, #0x3ea3, lsl #16
    20a0:	mov	w0, #0xaa3b                	// #43579
    20a4:	fmov	s22, w4
    20a8:	movk	w0, #0x3fb8, lsl #16
    20ac:	fmov	s23, w3
    20b0:	fmadd	s0, s12, s10, s0
    20b4:	fmov	s24, w2
    20b8:	fmov	s31, w1
    20bc:	fmov	s28, w0
    20c0:	fdiv	s0, s0, s15
    20c4:	fmadd	s21, s0, s29, s25
    20c8:	fmul	s29, s0, s19
    20cc:	fsub	s15, s0, s15
    20d0:	fmul	s29, s29, s0
    20d4:	fdiv	s25, s25, s21
    20d8:	fmul	s28, s29, s28
    20dc:	fmadd	s22, s25, s20, s22
    20e0:	fmadd	s23, s22, s25, s23
    20e4:	fmadd	s24, s23, s25, s24
    20e8:	fmadd	s31, s24, s25, s31
    20ec:	fmul	s31, s31, s25
    20f0:	b	21b8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    20f4:	fsqrt	s31, s12
    20f8:	fdiv	s0, s13, s8
    20fc:	fmul	s15, s15, s31
    2100:	bl	1020 <logf@plt>
    2104:	fmov	s29, #5.000000000000000000e-01
    2108:	fmadd	s10, s10, s29, s11
    210c:	fmadd	s0, s12, s10, s0
    2110:	fdiv	s0, s0, s15
    2114:	fcmpe	s0, #0.0
    2118:	fsub	s15, s0, s15
    211c:	b.mi	24fc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    2120:	mov	w0, #0x3389                	// #13193
    2124:	fmov	s31, #1.000000000000000000e+00
    2128:	mov	w4, #0x466f                	// #18031
    212c:	movk	w0, #0x3e6d, lsl #16
    2130:	mov	w3, #0x1eea                	// #7914
    2134:	fmov	s29, #-5.000000000000000000e-01
    2138:	movk	w4, #0x3faa, lsl #16
    213c:	movk	w3, #0xbfe9, lsl #16
    2140:	fmov	s22, w0
    2144:	mov	w2, #0x778                 	// #1912
    2148:	mov	w1, #0x8f89                	// #36745
    214c:	fmov	s21, w4
    2150:	movk	w2, #0x3fe4, lsl #16
    2154:	movk	w1, #0xbeb6, lsl #16
    2158:	fmov	s23, w3
    215c:	mov	w0, #0x85fa                	// #34298
    2160:	fmov	s24, w2
    2164:	movk	w0, #0x3ea3, lsl #16
    2168:	fmov	s25, w1
    216c:	fmov	s28, w0
    2170:	fmul	s29, s0, s29
    2174:	fmadd	s22, s0, s22, s31
    2178:	fmul	s29, s29, s0
    217c:	fcmpe	s29, s9
    2180:	fdiv	s31, s31, s22
    2184:	fmadd	s23, s31, s21, s23
    2188:	fmadd	s24, s31, s23, s24
    218c:	fmadd	s25, s31, s24, s25
    2190:	fmadd	s28, s31, s25, s28
    2194:	fmul	s31, s31, s28
    2198:	b.mi	260c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    219c:	mov	w0, #0x42b00000            	// #1118830592
    21a0:	fmov	s28, w0
    21a4:	fcmpe	s29, s28
    21a8:	b.gt	2258 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    21ac:	fmul	s28, s29, s14
    21b0:	fcmpe	s28, #0.0
    21b4:	b.ge	266c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    21b8:	fmov	s23, #5.000000000000000000e-01
    21bc:	mov	w0, #0x7218                	// #29208
    21c0:	mov	w3, #0xb61                 	// #2913
    21c4:	movk	w0, #0x3f31, lsl #16
    21c8:	mov	w2, #0x8889                	// #34953
    21cc:	fmov	s24, #1.000000000000000000e+00
    21d0:	movk	w3, #0x3ab6, lsl #16
    21d4:	movk	w2, #0x3c08, lsl #16
    21d8:	fmov	s25, w0
    21dc:	mov	w1, #0xaaab                	// #43691
    21e0:	mov	w0, #0xaaab                	// #43691
    21e4:	fsub	s28, s28, s23
    21e8:	movk	w1, #0x3d2a, lsl #16
    21ec:	movk	w0, #0x3e2a, lsl #16
    21f0:	fmov	s18, w3
    21f4:	mov	w4, #0x422a                	// #16938
    21f8:	fmov	s20, w2
    21fc:	movk	w4, #0x3ecc, lsl #16
    2200:	fmov	s21, w1
    2204:	fmov	s22, w0
    2208:	fmov	s19, w4
    220c:	fcvtzs	s28, s28
    2210:	scvtf	s28, s28
    2214:	fmsub	s25, s28, s25, s29
    2218:	fcvtzs	w0, s28
    221c:	fmadd	s28, s25, s18, s20
    2220:	add	w0, w0, #0x7f
    2224:	fmov	s30, w0
    2228:	fmadd	s28, s25, s28, s21
    222c:	fmadd	s28, s25, s28, s22
    2230:	shl	v29.2s, v30.2s, #23
    2234:	fmadd	s23, s25, s28, s23
    2238:	fmadd	s23, s25, s23, s24
    223c:	fmadd	s24, s25, s23, s24
    2240:	fmul	s29, s24, s29
    2244:	fmul	s29, s29, s19
    2248:	fcmpe	s0, #0.0
    224c:	fmul	s31, s31, s29
    2250:	b.mi	2270 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    2254:	b	2268 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2258:	mov	w0, #0x484f                	// #18511
    225c:	movk	w0, #0x7e46, lsl #16
    2260:	fmov	s29, w0
    2264:	fmul	s31, s31, s29
    2268:	fmov	s29, #1.000000000000000000e+00
    226c:	fsub	s31, s29, s31
    2270:	fnmul	s30, s11, s12
    2274:	fmul	s31, s13, s31
    2278:	movi	v29.2s, #0x0
    227c:	fcmpe	s30, s9
    2280:	b.mi	2320 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2284:	mov	w0, #0x42b00000            	// #1118830592
    2288:	fmov	s29, w0
    228c:	fcmpe	s30, s29
    2290:	b.gt	2618 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2294:	fmul	s28, s30, s14
    2298:	fcmpe	s28, #0.0
    229c:	b.ge	2628 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    22a0:	fmov	s27, #5.000000000000000000e-01
    22a4:	mov	w0, #0x7218                	// #29208
    22a8:	mov	w3, #0xb61                 	// #2913
    22ac:	movk	w0, #0x3f31, lsl #16
    22b0:	mov	w2, #0x8889                	// #34953
    22b4:	fmov	s29, #1.000000000000000000e+00
    22b8:	movk	w3, #0x3ab6, lsl #16
    22bc:	movk	w2, #0x3c08, lsl #16
    22c0:	fmov	s22, w0
    22c4:	mov	w1, #0xaaab                	// #43691
    22c8:	mov	w0, #0xaaab                	// #43691
    22cc:	fsub	s28, s28, s27
    22d0:	movk	w1, #0x3d2a, lsl #16
    22d4:	movk	w0, #0x3e2a, lsl #16
    22d8:	fmov	s23, w3
    22dc:	fmov	s24, w2
    22e0:	fmov	s25, w1
    22e4:	fmov	s26, w0
    22e8:	fcvtzs	s28, s28
    22ec:	scvtf	s28, s28
    22f0:	fmsub	s30, s28, s22, s30
    22f4:	fcvtzs	w0, s28
    22f8:	fmadd	s24, s30, s23, s24
    22fc:	fmadd	s25, s30, s24, s25
    2300:	add	w0, w0, #0x7f
    2304:	fmov	s28, w0
    2308:	fmadd	s26, s30, s25, s26
    230c:	fmadd	s27, s30, s26, s27
    2310:	shl	v28.2s, v28.2s, #23
    2314:	fmadd	s27, s30, s27, s29
    2318:	fmadd	s29, s30, s27, s29
    231c:	fmul	s29, s29, s28
    2320:	fcmpe	s15, #0.0
    2324:	fmul	s29, s8, s29
    2328:	b.mi	2584 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    232c:	mov	w0, #0x3389                	// #13193
    2330:	fmov	s30, #1.000000000000000000e+00
    2334:	mov	w4, #0x466f                	// #18031
    2338:	movk	w0, #0x3e6d, lsl #16
    233c:	mov	w3, #0x1eea                	// #7914
    2340:	fmov	s27, #-5.000000000000000000e-01
    2344:	movk	w4, #0x3faa, lsl #16
    2348:	movk	w3, #0xbfe9, lsl #16
    234c:	fmov	s23, w0
    2350:	mov	w2, #0x778                 	// #1912
    2354:	mov	w1, #0x8f89                	// #36745
    2358:	fmov	s22, w4
    235c:	movk	w2, #0x3fe4, lsl #16
    2360:	movk	w1, #0xbeb6, lsl #16
    2364:	fmov	s24, w3
    2368:	mov	w0, #0x85fa                	// #34298
    236c:	fmov	s25, w2
    2370:	movk	w0, #0x3ea3, lsl #16
    2374:	fmov	s26, w1
    2378:	fmov	s28, w0
    237c:	fmul	s27, s15, s27
    2380:	fmadd	s23, s15, s23, s30
    2384:	fmul	s27, s27, s15
    2388:	fcmpe	s27, s9
    238c:	fdiv	s30, s30, s23
    2390:	fmadd	s24, s30, s22, s24
    2394:	fmadd	s25, s30, s24, s25
    2398:	fmadd	s26, s30, s25, s26
    239c:	fmadd	s28, s30, s26, s28
    23a0:	fmul	s30, s30, s28
    23a4:	b.mi	2604 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    23a8:	mov	w0, #0x42b00000            	// #1118830592
    23ac:	fmov	s28, w0
    23b0:	fcmpe	s27, s28
    23b4:	b.gt	24ac <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    23b8:	nop
    23bc:	nop
    23c0:	fmul	s28, s27, s14
    23c4:	fcmpe	s28, #0.0
    23c8:	b.ge	26e4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    23cc:	fmov	s25, #5.000000000000000000e-01
    23d0:	mov	w0, #0x7218                	// #29208
    23d4:	mov	w4, #0xb61                 	// #2913
    23d8:	movk	w0, #0x3f31, lsl #16
    23dc:	mov	w2, #0x8889                	// #34953
    23e0:	fmov	s26, #1.000000000000000000e+00
    23e4:	movk	w4, #0x3ab6, lsl #16
    23e8:	movk	w2, #0x3c08, lsl #16
    23ec:	fmov	s19, w0
    23f0:	mov	w1, #0xaaab                	// #43691
    23f4:	mov	w0, #0xaaab                	// #43691
    23f8:	fsub	s28, s28, s25
    23fc:	movk	w1, #0x3d2a, lsl #16
    2400:	movk	w0, #0x3e2a, lsl #16
    2404:	fmov	s20, w4
    2408:	mov	w3, #0x422a                	// #16938
    240c:	fmov	s22, w2
    2410:	movk	w3, #0x3ecc, lsl #16
    2414:	fmov	s23, w1
    2418:	fmov	s24, w0
    241c:	fmov	s21, w3
    2420:	fcvtzs	s28, s28
    2424:	scvtf	s28, s28
    2428:	fmsub	s27, s28, s19, s27
    242c:	fcvtzs	w0, s28
    2430:	fmadd	s22, s27, s20, s22
    2434:	add	w0, w0, #0x7f
    2438:	fmov	s28, w0
    243c:	fmadd	s23, s27, s22, s23
    2440:	fmadd	s24, s27, s23, s24
    2444:	shl	v28.2s, v28.2s, #23
    2448:	fmadd	s25, s27, s24, s25
    244c:	fmadd	s25, s27, s25, s26
    2450:	fmadd	s26, s27, s25, s26
    2454:	fmul	s28, s26, s28
    2458:	fmul	s28, s28, s21
    245c:	fcmpe	s15, #0.0
    2460:	fmul	s30, s30, s28
    2464:	b.mi	24e4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    2468:	fmov	s28, #1.000000000000000000e+00
    246c:	fsub	s30, s28, s30
    2470:	fmsub	s31, s29, s30, s31
    2474:	str	s31, [x25, x26, lsl #2]
    2478:	add	x26, x26, #0x1
    247c:	cmp	x26, x19
    2480:	b.ne	2020 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2484:	ldp	d8, d9, [sp, #80]
    2488:	ldp	x19, x20, [sp, #16]
    248c:	ldp	x21, x22, [sp, #32]
    2490:	ldp	x23, x24, [sp, #48]
    2494:	ldp	x25, x26, [sp, #64]
    2498:	ldp	d10, d11, [sp, #96]
    249c:	ldp	d12, d13, [sp, #112]
    24a0:	ldp	d14, d15, [sp, #128]
    24a4:	ldp	x29, x30, [sp], #160
    24a8:	ret
    24ac:	mov	w0, #0x484f                	// #18511
    24b0:	movk	w0, #0x7e46, lsl #16
    24b4:	fmov	s28, w0
    24b8:	fmul	s30, s30, s28
    24bc:	fmov	s28, #1.000000000000000000e+00
    24c0:	fsub	s30, s28, s30
    24c4:	fmsub	s31, s29, s30, s31
    24c8:	str	s31, [x25, x26, lsl #2]
    24cc:	add	x26, x26, #0x1
    24d0:	cmp	x26, x19
    24d4:	b.ne	2020 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    24d8:	b	2484 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    24dc:	movi	v28.2s, #0x0
    24e0:	fmul	s30, s30, s28
    24e4:	fmsub	s30, s29, s30, s31
    24e8:	str	s30, [x25, x26, lsl #2]
    24ec:	add	x26, x26, #0x1
    24f0:	cmp	x19, x26
    24f4:	b.ne	2020 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    24f8:	b	2484 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    24fc:	mov	w0, #0x3389                	// #13193
    2500:	fmov	s31, #1.000000000000000000e+00
    2504:	mov	w4, #0x466f                	// #18031
    2508:	movk	w0, #0x3e6d, lsl #16
    250c:	mov	w3, #0x1eea                	// #7914
    2510:	fmul	s29, s0, s29
    2514:	movk	w4, #0x3faa, lsl #16
    2518:	movk	w3, #0xbfe9, lsl #16
    251c:	fmov	s22, w0
    2520:	mov	w2, #0x778                 	// #1912
    2524:	mov	w1, #0x8f89                	// #36745
    2528:	fmov	s21, w4
    252c:	movk	w2, #0x3fe4, lsl #16
    2530:	movk	w1, #0xbeb6, lsl #16
    2534:	fmov	s23, w3
    2538:	mov	w0, #0x85fa                	// #34298
    253c:	fmov	s24, w2
    2540:	movk	w0, #0x3ea3, lsl #16
    2544:	fmov	s25, w1
    2548:	fmov	s28, w0
    254c:	fnmul	s29, s0, s29
    2550:	fmsub	s22, s0, s22, s31
    2554:	fcmpe	s29, s9
    2558:	fdiv	s31, s31, s22
    255c:	fmadd	s23, s31, s21, s23
    2560:	fmadd	s24, s31, s23, s24
    2564:	fmadd	s25, s31, s24, s25
    2568:	fmadd	s28, s31, s25, s28
    256c:	fmul	s31, s31, s28
    2570:	b.mi	2578 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    2574:	b	21ac <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    2578:	movi	v29.2s, #0x0
    257c:	fmul	s31, s31, s29
    2580:	b	2270 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2584:	mov	w0, #0x3389                	// #13193
    2588:	fmov	s30, #1.000000000000000000e+00
    258c:	mov	w4, #0x466f                	// #18031
    2590:	movk	w0, #0x3e6d, lsl #16
    2594:	mov	w3, #0x1eea                	// #7914
    2598:	fmov	s27, #5.000000000000000000e-01
    259c:	movk	w4, #0x3faa, lsl #16
    25a0:	movk	w3, #0xbfe9, lsl #16
    25a4:	fmov	s23, w0
    25a8:	mov	w2, #0x778                 	// #1912
    25ac:	mov	w1, #0x8f89                	// #36745
    25b0:	fmov	s22, w4
    25b4:	movk	w2, #0x3fe4, lsl #16
    25b8:	movk	w1, #0xbeb6, lsl #16
    25bc:	fmov	s24, w3
    25c0:	mov	w0, #0x85fa                	// #34298
    25c4:	fmov	s25, w2
    25c8:	movk	w0, #0x3ea3, lsl #16
    25cc:	fmov	s26, w1
    25d0:	fmov	s28, w0
    25d4:	fmul	s27, s15, s27
    25d8:	fmsub	s23, s15, s23, s30
    25dc:	fnmul	s27, s15, s27
    25e0:	fcmpe	s27, s9
    25e4:	fdiv	s30, s30, s23
    25e8:	fmadd	s24, s30, s22, s24
    25ec:	fmadd	s25, s24, s30, s25
    25f0:	fmadd	s26, s25, s30, s26
    25f4:	fmadd	s28, s30, s26, s28
    25f8:	fmul	s30, s30, s28
    25fc:	b.mi	24dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2600:	b	23c0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2604:	movi	v28.2s, #0x0
    2608:	b	24b8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    260c:	movi	v29.2s, #0x0
    2610:	fmul	s31, s31, s29
    2614:	b	2268 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2618:	mov	w7, #0x829c                	// #33436
    261c:	movk	w7, #0x7ef8, lsl #16
    2620:	fmov	s29, w7
    2624:	b	2320 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    2628:	fmov	s27, #5.000000000000000000e-01
    262c:	ldr	s24, [sp, #148]
    2630:	mov	w0, #0xaaab                	// #43691
    2634:	movk	w0, #0x3e2a, lsl #16
    2638:	mov	w1, #0xaaab                	// #43691
    263c:	fmov	s29, #1.000000000000000000e+00
    2640:	movk	w1, #0x3d2a, lsl #16
    2644:	fmov	s26, w0
    2648:	fadd	s28, s28, s27
    264c:	fmov	s25, w1
    2650:	fcvtzs	s28, s28
    2654:	scvtf	s28, s28
    2658:	fmsub	s30, s28, s24, s30
    265c:	fcvtzs	w0, s28
    2660:	ldp	s24, s28, [sp, #152]
    2664:	fmadd	s24, s30, s24, s28
    2668:	b	22fc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    266c:	fmov	s24, #5.000000000000000000e-01
    2670:	ldr	s30, [sp, #148]
    2674:	mov	w1, #0xaaab                	// #43691
    2678:	movk	w1, #0x3d2a, lsl #16
    267c:	mov	w0, #0xaaab                	// #43691
    2680:	fmov	s25, #1.000000000000000000e+00
    2684:	movk	w0, #0x3e2a, lsl #16
    2688:	mov	w2, #0x422a                	// #16938
    268c:	fmov	s22, w1
    2690:	movk	w2, #0x3ecc, lsl #16
    2694:	fadd	s28, s28, s24
    2698:	fmov	s23, w0
    269c:	fmov	s21, w2
    26a0:	fcvtzs	s28, s28
    26a4:	scvtf	s28, s28
    26a8:	fmsub	s29, s28, s30, s29
    26ac:	fcvtzs	w7, s28
    26b0:	ldp	s28, s30, [sp, #152]
    26b4:	fmadd	s20, s29, s28, s30
    26b8:	add	w7, w7, #0x7f
    26bc:	fmov	s30, w7
    26c0:	fmadd	s22, s29, s20, s22
    26c4:	fmadd	s23, s29, s22, s23
    26c8:	shl	v28.2s, v30.2s, #23
    26cc:	fmadd	s24, s29, s23, s24
    26d0:	fmadd	s24, s29, s24, s25
    26d4:	fmadd	s29, s29, s24, s25
    26d8:	fmul	s29, s29, s28
    26dc:	fmul	s29, s29, s21
    26e0:	b	2248 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    26e4:	fmov	s25, #5.000000000000000000e-01
    26e8:	ldr	s21, [sp, #148]
    26ec:	mov	w0, #0xaaab                	// #43691
    26f0:	movk	w0, #0x3e2a, lsl #16
    26f4:	mov	w1, #0xaaab                	// #43691
    26f8:	fmov	s26, #1.000000000000000000e+00
    26fc:	movk	w1, #0x3d2a, lsl #16
    2700:	mov	w2, #0x422a                	// #16938
    2704:	fmov	s24, w0
    2708:	movk	w2, #0x3ecc, lsl #16
    270c:	fadd	s28, s28, s25
    2710:	fmov	s23, w1
    2714:	fmov	s22, w2
    2718:	fcvtzs	s28, s28
    271c:	scvtf	s28, s28
    2720:	fmsub	s27, s28, s21, s27
    2724:	fcvtzs	w0, s28
    2728:	ldp	s21, s28, [sp, #152]
    272c:	fmadd	s21, s27, s21, s28
    2730:	add	w0, w0, #0x7f
    2734:	fmov	s28, w0
    2738:	fmadd	s23, s27, s21, s23
    273c:	fmadd	s24, s27, s23, s24
    2740:	shl	v28.2s, v28.2s, #23
    2744:	fmadd	s25, s27, s24, s25
    2748:	fmadd	s25, s27, s25, s26
    274c:	fmadd	s26, s27, s25, s26
    2750:	fmul	s28, s26, s28
    2754:	fmul	s28, s28, s22
    2758:	b	245c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    275c:	ret
