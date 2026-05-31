0000000000001f20 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    1f20:	cbz	x6, 26dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    1f24:	stp	x29, x30, [sp, #-160]!
    1f28:	mov	x29, sp
    1f2c:	stp	x23, x24, [sp, #48]
    1f30:	mov	x24, x4
    1f34:	mov	w4, #0xaa3b                	// #43579
    1f38:	movk	w4, #0x3fb8, lsl #16
    1f3c:	mov	x23, x3
    1f40:	mov	w3, #0x7218                	// #29208
    1f44:	stp	x19, x20, [sp, #16]
    1f48:	mov	x20, x0
    1f4c:	mov	w0, #0xc2b00000            	// #-1028653056
    1f50:	movk	w3, #0x3f31, lsl #16
    1f54:	mov	x19, x6
    1f58:	stp	d8, d9, [sp, #80]
    1f5c:	fmov	s9, w0
    1f60:	stp	d14, d15, [sp, #128]
    1f64:	fmov	s14, w4
    1f68:	stp	x21, x22, [sp, #32]
    1f6c:	mov	x21, x1
    1f70:	mov	x22, x2
    1f74:	mov	w1, #0x8889                	// #34953
    1f78:	mov	w2, #0xb61                 	// #2913
    1f7c:	movk	w2, #0x3ab6, lsl #16
    1f80:	movk	w1, #0x3c08, lsl #16
    1f84:	stp	x25, x26, [sp, #64]
    1f88:	mov	x26, #0x0                   	// #0
    1f8c:	mov	x25, x5
    1f90:	stp	d10, d11, [sp, #96]
    1f94:	stp	d12, d13, [sp, #112]
    1f98:	stp	w3, w2, [sp, #148]
    1f9c:	str	w1, [sp, #156]
    1fa0:	ldr	s12, [x22, x26, lsl #2]
    1fa4:	ldr	s15, [x24, x26, lsl #2]
    1fa8:	ldr	s13, [x20, x26, lsl #2]
    1fac:	fcmp	s12, #0.0
    1fb0:	ldr	s8, [x21, x26, lsl #2]
    1fb4:	ldr	s11, [x23, x26, lsl #2]
    1fb8:	fmul	s10, s15, s15
    1fbc:	b.pl	2074 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    1fc0:	fmov	s0, s12
    1fc4:	bl	ec0 <sqrtf@plt>
    1fc8:	fmov	s31, s0
    1fcc:	fdiv	s0, s13, s8
    1fd0:	fmul	s15, s15, s31
    1fd4:	bl	1020 <logf@plt>
    1fd8:	fmov	s31, #5.000000000000000000e-01
    1fdc:	mov	w0, #0x3389                	// #13193
    1fe0:	fmov	s25, #1.000000000000000000e+00
    1fe4:	movk	w0, #0x3e6d, lsl #16
    1fe8:	mov	w1, #0x466f                	// #18031
    1fec:	fmov	s19, #-5.000000000000000000e-01
    1ff0:	mov	w4, #0x1eea                	// #7914
    1ff4:	movk	w1, #0x3faa, lsl #16
    1ff8:	fmov	s29, w0
    1ffc:	movk	w4, #0xbfe9, lsl #16
    2000:	mov	w3, #0x778                 	// #1912
    2004:	fmadd	s10, s10, s31, s11
    2008:	movk	w3, #0x3fe4, lsl #16
    200c:	mov	w2, #0x8f89                	// #36745
    2010:	fmov	s20, w1
    2014:	movk	w2, #0xbeb6, lsl #16
    2018:	mov	w1, #0x85fa                	// #34298
    201c:	movk	w1, #0x3ea3, lsl #16
    2020:	mov	w0, #0xaa3b                	// #43579
    2024:	fmov	s22, w4
    2028:	movk	w0, #0x3fb8, lsl #16
    202c:	fmov	s23, w3
    2030:	fmadd	s0, s12, s10, s0
    2034:	fmov	s24, w2
    2038:	fmov	s31, w1
    203c:	fmov	s28, w0
    2040:	fdiv	s0, s0, s15
    2044:	fmadd	s21, s0, s29, s25
    2048:	fmul	s29, s0, s19
    204c:	fsub	s15, s0, s15
    2050:	fmul	s29, s29, s0
    2054:	fdiv	s25, s25, s21
    2058:	fmul	s28, s29, s28
    205c:	fmadd	s22, s25, s20, s22
    2060:	fmadd	s23, s22, s25, s23
    2064:	fmadd	s24, s23, s25, s24
    2068:	fmadd	s31, s24, s25, s31
    206c:	fmul	s31, s31, s25
    2070:	b	2138 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    2074:	fsqrt	s31, s12
    2078:	fdiv	s0, s13, s8
    207c:	fmul	s15, s15, s31
    2080:	bl	1020 <logf@plt>
    2084:	fmov	s29, #5.000000000000000000e-01
    2088:	fmadd	s10, s10, s29, s11
    208c:	fmadd	s0, s12, s10, s0
    2090:	fdiv	s0, s0, s15
    2094:	fcmpe	s0, #0.0
    2098:	fsub	s15, s0, s15
    209c:	b.mi	247c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    20a0:	mov	w0, #0x3389                	// #13193
    20a4:	fmov	s31, #1.000000000000000000e+00
    20a8:	mov	w4, #0x466f                	// #18031
    20ac:	movk	w0, #0x3e6d, lsl #16
    20b0:	mov	w3, #0x1eea                	// #7914
    20b4:	fmov	s29, #-5.000000000000000000e-01
    20b8:	movk	w4, #0x3faa, lsl #16
    20bc:	movk	w3, #0xbfe9, lsl #16
    20c0:	fmov	s22, w0
    20c4:	mov	w2, #0x778                 	// #1912
    20c8:	mov	w1, #0x8f89                	// #36745
    20cc:	fmov	s21, w4
    20d0:	movk	w2, #0x3fe4, lsl #16
    20d4:	movk	w1, #0xbeb6, lsl #16
    20d8:	fmov	s23, w3
    20dc:	mov	w0, #0x85fa                	// #34298
    20e0:	fmov	s24, w2
    20e4:	movk	w0, #0x3ea3, lsl #16
    20e8:	fmov	s25, w1
    20ec:	fmov	s28, w0
    20f0:	fmul	s29, s0, s29
    20f4:	fmadd	s22, s0, s22, s31
    20f8:	fmul	s29, s29, s0
    20fc:	fcmpe	s29, s9
    2100:	fdiv	s31, s31, s22
    2104:	fmadd	s23, s31, s21, s23
    2108:	fmadd	s24, s31, s23, s24
    210c:	fmadd	s25, s31, s24, s25
    2110:	fmadd	s28, s31, s25, s28
    2114:	fmul	s31, s31, s28
    2118:	b.mi	258c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    211c:	mov	w0, #0x42b00000            	// #1118830592
    2120:	fmov	s28, w0
    2124:	fcmpe	s29, s28
    2128:	b.gt	21d8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    212c:	fmul	s28, s29, s14
    2130:	fcmpe	s28, #0.0
    2134:	b.ge	25ec <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    2138:	fmov	s23, #5.000000000000000000e-01
    213c:	mov	w0, #0x7218                	// #29208
    2140:	mov	w3, #0xb61                 	// #2913
    2144:	movk	w0, #0x3f31, lsl #16
    2148:	mov	w2, #0x8889                	// #34953
    214c:	fmov	s24, #1.000000000000000000e+00
    2150:	movk	w3, #0x3ab6, lsl #16
    2154:	movk	w2, #0x3c08, lsl #16
    2158:	fmov	s25, w0
    215c:	mov	w1, #0xaaab                	// #43691
    2160:	mov	w0, #0xaaab                	// #43691
    2164:	fsub	s28, s28, s23
    2168:	movk	w1, #0x3d2a, lsl #16
    216c:	movk	w0, #0x3e2a, lsl #16
    2170:	fmov	s18, w3
    2174:	mov	w4, #0x422a                	// #16938
    2178:	fmov	s20, w2
    217c:	movk	w4, #0x3ecc, lsl #16
    2180:	fmov	s21, w1
    2184:	fmov	s22, w0
    2188:	fmov	s19, w4
    218c:	fcvtzs	s28, s28
    2190:	scvtf	s28, s28
    2194:	fmsub	s25, s28, s25, s29
    2198:	fcvtzs	w0, s28
    219c:	fmadd	s28, s25, s18, s20
    21a0:	add	w0, w0, #0x7f
    21a4:	fmov	s30, w0
    21a8:	fmadd	s28, s25, s28, s21
    21ac:	fmadd	s28, s25, s28, s22
    21b0:	shl	v29.2s, v30.2s, #23
    21b4:	fmadd	s23, s25, s28, s23
    21b8:	fmadd	s23, s25, s23, s24
    21bc:	fmadd	s24, s25, s23, s24
    21c0:	fmul	s29, s24, s29
    21c4:	fmul	s29, s29, s19
    21c8:	fcmpe	s0, #0.0
    21cc:	fmul	s31, s31, s29
    21d0:	b.mi	21f0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    21d4:	b	21e8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    21d8:	mov	w0, #0x484f                	// #18511
    21dc:	movk	w0, #0x7e46, lsl #16
    21e0:	fmov	s29, w0
    21e4:	fmul	s31, s31, s29
    21e8:	fmov	s29, #1.000000000000000000e+00
    21ec:	fsub	s31, s29, s31
    21f0:	fnmul	s30, s11, s12
    21f4:	fmul	s31, s13, s31
    21f8:	movi	v29.2s, #0x0
    21fc:	fcmpe	s30, s9
    2200:	b.mi	22a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2204:	mov	w0, #0x42b00000            	// #1118830592
    2208:	fmov	s29, w0
    220c:	fcmpe	s30, s29
    2210:	b.gt	2598 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2214:	fmul	s28, s30, s14
    2218:	fcmpe	s28, #0.0
    221c:	b.ge	25a8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    2220:	fmov	s27, #5.000000000000000000e-01
    2224:	mov	w0, #0x7218                	// #29208
    2228:	mov	w3, #0xb61                 	// #2913
    222c:	movk	w0, #0x3f31, lsl #16
    2230:	mov	w2, #0x8889                	// #34953
    2234:	fmov	s29, #1.000000000000000000e+00
    2238:	movk	w3, #0x3ab6, lsl #16
    223c:	movk	w2, #0x3c08, lsl #16
    2240:	fmov	s22, w0
    2244:	mov	w1, #0xaaab                	// #43691
    2248:	mov	w0, #0xaaab                	// #43691
    224c:	fsub	s28, s28, s27
    2250:	movk	w1, #0x3d2a, lsl #16
    2254:	movk	w0, #0x3e2a, lsl #16
    2258:	fmov	s23, w3
    225c:	fmov	s24, w2
    2260:	fmov	s25, w1
    2264:	fmov	s26, w0
    2268:	fcvtzs	s28, s28
    226c:	scvtf	s28, s28
    2270:	fmsub	s30, s28, s22, s30
    2274:	fcvtzs	w0, s28
    2278:	fmadd	s24, s30, s23, s24
    227c:	fmadd	s25, s30, s24, s25
    2280:	add	w0, w0, #0x7f
    2284:	fmov	s28, w0
    2288:	fmadd	s26, s30, s25, s26
    228c:	fmadd	s27, s30, s26, s27
    2290:	shl	v28.2s, v28.2s, #23
    2294:	fmadd	s27, s30, s27, s29
    2298:	fmadd	s29, s30, s27, s29
    229c:	fmul	s29, s29, s28
    22a0:	fcmpe	s15, #0.0
    22a4:	fmul	s29, s8, s29
    22a8:	b.mi	2504 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    22ac:	mov	w0, #0x3389                	// #13193
    22b0:	fmov	s30, #1.000000000000000000e+00
    22b4:	mov	w4, #0x466f                	// #18031
    22b8:	movk	w0, #0x3e6d, lsl #16
    22bc:	mov	w3, #0x1eea                	// #7914
    22c0:	fmov	s27, #-5.000000000000000000e-01
    22c4:	movk	w4, #0x3faa, lsl #16
    22c8:	movk	w3, #0xbfe9, lsl #16
    22cc:	fmov	s23, w0
    22d0:	mov	w2, #0x778                 	// #1912
    22d4:	mov	w1, #0x8f89                	// #36745
    22d8:	fmov	s22, w4
    22dc:	movk	w2, #0x3fe4, lsl #16
    22e0:	movk	w1, #0xbeb6, lsl #16
    22e4:	fmov	s24, w3
    22e8:	mov	w0, #0x85fa                	// #34298
    22ec:	fmov	s25, w2
    22f0:	movk	w0, #0x3ea3, lsl #16
    22f4:	fmov	s26, w1
    22f8:	fmov	s28, w0
    22fc:	fmul	s27, s15, s27
    2300:	fmadd	s23, s15, s23, s30
    2304:	fmul	s27, s27, s15
    2308:	fcmpe	s27, s9
    230c:	fdiv	s30, s30, s23
    2310:	fmadd	s24, s30, s22, s24
    2314:	fmadd	s25, s30, s24, s25
    2318:	fmadd	s26, s30, s25, s26
    231c:	fmadd	s28, s30, s26, s28
    2320:	fmul	s30, s30, s28
    2324:	b.mi	2584 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    2328:	mov	w0, #0x42b00000            	// #1118830592
    232c:	fmov	s28, w0
    2330:	fcmpe	s27, s28
    2334:	b.gt	242c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    2338:	nop
    233c:	nop
    2340:	fmul	s28, s27, s14
    2344:	fcmpe	s28, #0.0
    2348:	b.ge	2664 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    234c:	fmov	s25, #5.000000000000000000e-01
    2350:	mov	w0, #0x7218                	// #29208
    2354:	mov	w4, #0xb61                 	// #2913
    2358:	movk	w0, #0x3f31, lsl #16
    235c:	mov	w2, #0x8889                	// #34953
    2360:	fmov	s26, #1.000000000000000000e+00
    2364:	movk	w4, #0x3ab6, lsl #16
    2368:	movk	w2, #0x3c08, lsl #16
    236c:	fmov	s19, w0
    2370:	mov	w1, #0xaaab                	// #43691
    2374:	mov	w0, #0xaaab                	// #43691
    2378:	fsub	s28, s28, s25
    237c:	movk	w1, #0x3d2a, lsl #16
    2380:	movk	w0, #0x3e2a, lsl #16
    2384:	fmov	s20, w4
    2388:	mov	w3, #0x422a                	// #16938
    238c:	fmov	s22, w2
    2390:	movk	w3, #0x3ecc, lsl #16
    2394:	fmov	s23, w1
    2398:	fmov	s24, w0
    239c:	fmov	s21, w3
    23a0:	fcvtzs	s28, s28
    23a4:	scvtf	s28, s28
    23a8:	fmsub	s27, s28, s19, s27
    23ac:	fcvtzs	w0, s28
    23b0:	fmadd	s22, s27, s20, s22
    23b4:	add	w0, w0, #0x7f
    23b8:	fmov	s28, w0
    23bc:	fmadd	s23, s27, s22, s23
    23c0:	fmadd	s24, s27, s23, s24
    23c4:	shl	v28.2s, v28.2s, #23
    23c8:	fmadd	s25, s27, s24, s25
    23cc:	fmadd	s25, s27, s25, s26
    23d0:	fmadd	s26, s27, s25, s26
    23d4:	fmul	s28, s26, s28
    23d8:	fmul	s28, s28, s21
    23dc:	fcmpe	s15, #0.0
    23e0:	fmul	s30, s30, s28
    23e4:	b.mi	2464 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    23e8:	fmov	s28, #1.000000000000000000e+00
    23ec:	fsub	s30, s28, s30
    23f0:	fmsub	s31, s29, s30, s31
    23f4:	str	s31, [x25, x26, lsl #2]
    23f8:	add	x26, x26, #0x1
    23fc:	cmp	x26, x19
    2400:	b.ne	1fa0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2404:	ldp	d8, d9, [sp, #80]
    2408:	ldp	x19, x20, [sp, #16]
    240c:	ldp	x21, x22, [sp, #32]
    2410:	ldp	x23, x24, [sp, #48]
    2414:	ldp	x25, x26, [sp, #64]
    2418:	ldp	d10, d11, [sp, #96]
    241c:	ldp	d12, d13, [sp, #112]
    2420:	ldp	d14, d15, [sp, #128]
    2424:	ldp	x29, x30, [sp], #160
    2428:	ret
    242c:	mov	w0, #0x484f                	// #18511
    2430:	movk	w0, #0x7e46, lsl #16
    2434:	fmov	s28, w0
    2438:	fmul	s30, s30, s28
    243c:	fmov	s28, #1.000000000000000000e+00
    2440:	fsub	s30, s28, s30
    2444:	fmsub	s31, s29, s30, s31
    2448:	str	s31, [x25, x26, lsl #2]
    244c:	add	x26, x26, #0x1
    2450:	cmp	x26, x19
    2454:	b.ne	1fa0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2458:	b	2404 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    245c:	movi	v28.2s, #0x0
    2460:	fmul	s30, s30, s28
    2464:	fmsub	s30, s29, s30, s31
    2468:	str	s30, [x25, x26, lsl #2]
    246c:	add	x26, x26, #0x1
    2470:	cmp	x19, x26
    2474:	b.ne	1fa0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2478:	b	2404 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    247c:	mov	w0, #0x3389                	// #13193
    2480:	fmov	s31, #1.000000000000000000e+00
    2484:	mov	w4, #0x466f                	// #18031
    2488:	movk	w0, #0x3e6d, lsl #16
    248c:	mov	w3, #0x1eea                	// #7914
    2490:	fmul	s29, s0, s29
    2494:	movk	w4, #0x3faa, lsl #16
    2498:	movk	w3, #0xbfe9, lsl #16
    249c:	fmov	s22, w0
    24a0:	mov	w2, #0x778                 	// #1912
    24a4:	mov	w1, #0x8f89                	// #36745
    24a8:	fmov	s21, w4
    24ac:	movk	w2, #0x3fe4, lsl #16
    24b0:	movk	w1, #0xbeb6, lsl #16
    24b4:	fmov	s23, w3
    24b8:	mov	w0, #0x85fa                	// #34298
    24bc:	fmov	s24, w2
    24c0:	movk	w0, #0x3ea3, lsl #16
    24c4:	fmov	s25, w1
    24c8:	fmov	s28, w0
    24cc:	fnmul	s29, s0, s29
    24d0:	fmsub	s22, s0, s22, s31
    24d4:	fcmpe	s29, s9
    24d8:	fdiv	s31, s31, s22
    24dc:	fmadd	s23, s31, s21, s23
    24e0:	fmadd	s24, s31, s23, s24
    24e4:	fmadd	s25, s31, s24, s25
    24e8:	fmadd	s28, s31, s25, s28
    24ec:	fmul	s31, s31, s28
    24f0:	b.mi	24f8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    24f4:	b	212c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    24f8:	movi	v29.2s, #0x0
    24fc:	fmul	s31, s31, s29
    2500:	b	21f0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2504:	mov	w0, #0x3389                	// #13193
    2508:	fmov	s30, #1.000000000000000000e+00
    250c:	mov	w4, #0x466f                	// #18031
    2510:	movk	w0, #0x3e6d, lsl #16
    2514:	mov	w3, #0x1eea                	// #7914
    2518:	fmov	s27, #5.000000000000000000e-01
    251c:	movk	w4, #0x3faa, lsl #16
    2520:	movk	w3, #0xbfe9, lsl #16
    2524:	fmov	s23, w0
    2528:	mov	w2, #0x778                 	// #1912
    252c:	mov	w1, #0x8f89                	// #36745
    2530:	fmov	s22, w4
    2534:	movk	w2, #0x3fe4, lsl #16
    2538:	movk	w1, #0xbeb6, lsl #16
    253c:	fmov	s24, w3
    2540:	mov	w0, #0x85fa                	// #34298
    2544:	fmov	s25, w2
    2548:	movk	w0, #0x3ea3, lsl #16
    254c:	fmov	s26, w1
    2550:	fmov	s28, w0
    2554:	fmul	s27, s15, s27
    2558:	fmsub	s23, s15, s23, s30
    255c:	fnmul	s27, s15, s27
    2560:	fcmpe	s27, s9
    2564:	fdiv	s30, s30, s23
    2568:	fmadd	s24, s30, s22, s24
    256c:	fmadd	s25, s24, s30, s25
    2570:	fmadd	s26, s25, s30, s26
    2574:	fmadd	s28, s30, s26, s28
    2578:	fmul	s30, s30, s28
    257c:	b.mi	245c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2580:	b	2340 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2584:	movi	v28.2s, #0x0
    2588:	b	2438 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    258c:	movi	v29.2s, #0x0
    2590:	fmul	s31, s31, s29
    2594:	b	21e8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2598:	mov	w7, #0x829c                	// #33436
    259c:	movk	w7, #0x7ef8, lsl #16
    25a0:	fmov	s29, w7
    25a4:	b	22a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    25a8:	fmov	s27, #5.000000000000000000e-01
    25ac:	ldr	s24, [sp, #148]
    25b0:	mov	w0, #0xaaab                	// #43691
    25b4:	movk	w0, #0x3e2a, lsl #16
    25b8:	mov	w1, #0xaaab                	// #43691
    25bc:	fmov	s29, #1.000000000000000000e+00
    25c0:	movk	w1, #0x3d2a, lsl #16
    25c4:	fmov	s26, w0
    25c8:	fadd	s28, s28, s27
    25cc:	fmov	s25, w1
    25d0:	fcvtzs	s28, s28
    25d4:	scvtf	s28, s28
    25d8:	fmsub	s30, s28, s24, s30
    25dc:	fcvtzs	w0, s28
    25e0:	ldp	s24, s28, [sp, #152]
    25e4:	fmadd	s24, s30, s24, s28
    25e8:	b	227c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    25ec:	fmov	s24, #5.000000000000000000e-01
    25f0:	ldr	s30, [sp, #148]
    25f4:	mov	w1, #0xaaab                	// #43691
    25f8:	movk	w1, #0x3d2a, lsl #16
    25fc:	mov	w0, #0xaaab                	// #43691
    2600:	fmov	s25, #1.000000000000000000e+00
    2604:	movk	w0, #0x3e2a, lsl #16
    2608:	mov	w2, #0x422a                	// #16938
    260c:	fmov	s22, w1
    2610:	movk	w2, #0x3ecc, lsl #16
    2614:	fadd	s28, s28, s24
    2618:	fmov	s23, w0
    261c:	fmov	s21, w2
    2620:	fcvtzs	s28, s28
    2624:	scvtf	s28, s28
    2628:	fmsub	s29, s28, s30, s29
    262c:	fcvtzs	w7, s28
    2630:	ldp	s28, s30, [sp, #152]
    2634:	fmadd	s20, s29, s28, s30
    2638:	add	w7, w7, #0x7f
    263c:	fmov	s30, w7
    2640:	fmadd	s22, s29, s20, s22
    2644:	fmadd	s23, s29, s22, s23
    2648:	shl	v28.2s, v30.2s, #23
    264c:	fmadd	s24, s29, s23, s24
    2650:	fmadd	s24, s29, s24, s25
    2654:	fmadd	s29, s29, s24, s25
    2658:	fmul	s29, s29, s28
    265c:	fmul	s29, s29, s21
    2660:	b	21c8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    2664:	fmov	s25, #5.000000000000000000e-01
    2668:	ldr	s21, [sp, #148]
    266c:	mov	w0, #0xaaab                	// #43691
    2670:	movk	w0, #0x3e2a, lsl #16
    2674:	mov	w1, #0xaaab                	// #43691
    2678:	fmov	s26, #1.000000000000000000e+00
    267c:	movk	w1, #0x3d2a, lsl #16
    2680:	mov	w2, #0x422a                	// #16938
    2684:	fmov	s24, w0
    2688:	movk	w2, #0x3ecc, lsl #16
    268c:	fadd	s28, s28, s25
    2690:	fmov	s23, w1
    2694:	fmov	s22, w2
    2698:	fcvtzs	s28, s28
    269c:	scvtf	s28, s28
    26a0:	fmsub	s27, s28, s21, s27
    26a4:	fcvtzs	w0, s28
    26a8:	ldp	s21, s28, [sp, #152]
    26ac:	fmadd	s21, s27, s21, s28
    26b0:	add	w0, w0, #0x7f
    26b4:	fmov	s28, w0
    26b8:	fmadd	s23, s27, s21, s23
    26bc:	fmadd	s24, s27, s23, s24
    26c0:	shl	v28.2s, v28.2s, #23
    26c4:	fmadd	s25, s27, s24, s25
    26c8:	fmadd	s25, s27, s25, s26
    26cc:	fmadd	s26, s27, s25, s26
    26d0:	fmul	s28, s26, s28
    26d4:	fmul	s28, s28, s22
    26d8:	b	23dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    26dc:	ret
