0000000000002fa0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    2fa0:	cbz	x6, 369c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6fc>
    2fa4:	mov	w10, #0x4f3                 	// #1267
    2fa8:	mov	w9, #0x21bb                	// #8635
    2fac:	stp	x29, x30, [sp, #-144]!
    2fb0:	movk	w10, #0x3fb5, lsl #16
    2fb4:	movk	w9, #0x3d90, lsl #16
    2fb8:	mov	x29, sp
    2fbc:	mov	w15, #0x251a                	// #9498
    2fc0:	mov	w14, #0x5d4f                	// #23887
    2fc4:	mov	w13, #0xe9bf                	// #59839
    2fc8:	stp	d14, d15, [sp, #80]
    2fcc:	mov	w12, #0xae50                	// #44624
    2fd0:	fmov	s15, w10
    2fd4:	mov	w11, #0xceac                	// #52908
    2fd8:	mov	w10, #0xfffc                	// #65532
    2fdc:	movk	w15, #0x3def, lsl #16
    2fe0:	fmov	s0, w9
    2fe4:	movk	w14, #0xbdfe, lsl #16
    2fe8:	movk	w13, #0x3e11, lsl #16
    2fec:	stp	x19, x20, [sp, #16]
    2ff0:	movk	w12, #0xbe2a, lsl #16
    2ff4:	movk	w11, #0x3e4c, lsl #16
    2ff8:	movk	w10, #0xbe7f, lsl #16
    2ffc:	mov	w9, #0xaaaa                	// #43690
    3000:	movk	w9, #0x3eaa, lsl #16
    3004:	fmov	s2, w15
    3008:	mov	w20, #0xaa3b                	// #43579
    300c:	fmov	s3, w14
    3010:	mov	w15, #0x3389                	// #13193
    3014:	mov	w14, #0x466f                	// #18031
    3018:	fmov	s4, w13
    301c:	mov	w13, #0x1eea                	// #7914
    3020:	movk	w20, #0x3fb8, lsl #16
    3024:	fmov	s5, w12
    3028:	mov	w12, #0x778                 	// #1912
    302c:	movk	w15, #0x3e6d, lsl #16
    3030:	stp	d8, d9, [sp, #32]
    3034:	movk	w14, #0x3faa, lsl #16
    3038:	movk	w13, #0xbfe9, lsl #16
    303c:	fmov	s8, w11
    3040:	mov	w11, #0x8f89                	// #36745
    3044:	movk	w12, #0x3fe4, lsl #16
    3048:	fmov	s9, w10
    304c:	mov	w10, #0x85fa                	// #34298
    3050:	movk	w11, #0xbeb6, lsl #16
    3054:	movk	w10, #0x3ea3, lsl #16
    3058:	stp	d10, d11, [sp, #48]
    305c:	mov	w8, #0xd1b8                	// #53688
    3060:	fmov	s10, w9
    3064:	mov	w9, #0xc2b00000            	// #-1028653056
    3068:	movk	w8, #0xbdeb, lsl #16
    306c:	fmov	s11, w20
    3070:	mov	w19, #0xb61                 	// #2913
    3074:	mov	w30, #0x8889                	// #34953
    3078:	fmov	s7, w15
    307c:	mov	w18, #0xaaab                	// #43691
    3080:	mov	w17, #0xaaab                	// #43691
    3084:	fmov	s16, w14
    3088:	mov	w16, #0x422a                	// #16938
    308c:	movk	w19, #0x3ab6, lsl #16
    3090:	fmov	s17, w13
    3094:	movk	w30, #0x3c08, lsl #16
    3098:	movk	w18, #0x3d2a, lsl #16
    309c:	fmov	s18, w12
    30a0:	movk	w17, #0x3e2a, lsl #16
    30a4:	movk	w16, #0x3ecc, lsl #16
    30a8:	fmov	s19, w11
    30ac:	mov	x7, #0x0                   	// #0
    30b0:	fmov	s20, w10
    30b4:	fmov	s24, w9
    30b8:	fmov	s1, w8
    30bc:	mov	w8, #0x7218                	// #29208
    30c0:	movk	w8, #0x3f31, lsl #16
    30c4:	stp	d12, d13, [sp, #64]
    30c8:	stp	w30, w18, [sp, #116]
    30cc:	fmov	s6, w8
    30d0:	mov	w8, #0x484f                	// #18511
    30d4:	movk	w8, #0x7e46, lsl #16
    30d8:	stp	w17, w16, [sp, #124]
    30dc:	stp	w8, w19, [sp, #108]
    30e0:	ldr	s26, [x0, x7, lsl #2]
    30e4:	ldr	s25, [x1, x7, lsl #2]
    30e8:	ldr	s27, [x2, x7, lsl #2]
    30ec:	ldr	s29, [x4, x7, lsl #2]
    30f0:	fdiv	s31, s26, s25
    30f4:	ldr	s23, [x3, x7, lsl #2]
    30f8:	fmul	s21, s29, s29
    30fc:	fmov	w8, s31
    3100:	dup	v31.2s, v27.s[0]
    3104:	fsqrt	v31.2s, v31.2s
    3108:	and	w9, w8, #0x7fffff
    310c:	ubfx	x8, x8, #23, #8
    3110:	orr	w9, w9, #0x3f800000
    3114:	fmul	s29, s29, s31
    3118:	fmov	s31, w9
    311c:	fcmpe	s31, s15
    3120:	b.ge	34fc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.tcont
    3124:	sub	w8, w8, #0x7f
    3128:	fmov	s30, #1.000000000000000000e+00
    312c:	fmov	s28, #5.000000000000000000e-01
    3130:	scvtf	s14, w8
    3134:	fsub	s31, s31, s30
    3138:	fmadd	s21, s21, s28, s23
    313c:	fmadd	s22, s31, s0, s1
    3140:	fmul	s12, s31, s31
    3144:	fmadd	s22, s31, s22, s2
    3148:	fmul	s13, s12, s28
    314c:	fmadd	s22, s31, s22, s3
    3150:	fmadd	s22, s31, s22, s4
    3154:	fmadd	s22, s31, s22, s5
    3158:	fmadd	s22, s31, s22, s8
    315c:	fmadd	s22, s31, s22, s9
    3160:	fmadd	s22, s31, s22, s10
    3164:	fmul	s22, s22, s12
    3168:	fnmsub	s13, s31, s22, s13
    316c:	fadd	s31, s31, s13
    3170:	fmadd	s31, s14, s6, s31
    3174:	fmadd	s31, s27, s21, s31
    3178:	fdiv	s31, s31, s29
    317c:	fcmpe	s31, #0.0
    3180:	fsub	s29, s31, s29
    3184:	b.mi	3544 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5a4>  // b.first
    3188:	fmadd	s22, s31, s7, s30
    318c:	fmov	s28, #-5.000000000000000000e-01
    3190:	fmul	s28, s31, s28
    3194:	fdiv	s30, s30, s22
    3198:	fmul	s28, s28, s31
    319c:	fcmpe	s28, s24
    31a0:	fmadd	s22, s30, s16, s17
    31a4:	fmadd	s22, s30, s22, s18
    31a8:	fmadd	s22, s30, s22, s19
    31ac:	fmadd	s22, s30, s22, s20
    31b0:	fmul	s30, s30, s22
    31b4:	b.mi	3284 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2e4>  // b.first
    31b8:	mov	w8, #0x42b00000            	// #1118830592
    31bc:	ldr	s21, [sp, #108]
    31c0:	fmov	s22, w8
    31c4:	fcmpe	s28, s22
    31c8:	b.gt	3288 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2e8>
    31cc:	fmul	s22, s28, s11
    31d0:	fcmpe	s22, #0.0
    31d4:	b.ge	3640 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6a0>  // b.tcont
    31d8:	fmov	s21, #5.000000000000000000e-01
    31dc:	mov	w8, #0x7218                	// #29208
    31e0:	mov	w12, #0xb61                 	// #2913
    31e4:	movk	w8, #0x3f31, lsl #16
    31e8:	mov	w11, #0x8889                	// #34953
    31ec:	fmov	s12, #1.000000000000000000e+00
    31f0:	movk	w12, #0x3ab6, lsl #16
    31f4:	movk	w11, #0x3c08, lsl #16
    31f8:	fmov	s13, w8
    31fc:	mov	w8, #0x422a                	// #16938
    3200:	mov	w10, #0xaaab                	// #43691
    3204:	fsub	s22, s22, s21
    3208:	movk	w8, #0x3ecc, lsl #16
    320c:	movk	w10, #0x3d2a, lsl #16
    3210:	mov	w9, #0xaaab                	// #43691
    3214:	stp	w12, w11, [sp, #132]
    3218:	str	w8, [sp, #140]
    321c:	movk	w9, #0x3e2a, lsl #16
    3220:	fmov	s14, w10
    3224:	fmov	s21, w9
    3228:	fcvtzs	s22, s22
    322c:	scvtf	s22, s22
    3230:	fmsub	s28, s22, s13, s28
    3234:	fcvtzs	w8, s22
    3238:	fmov	s13, w11
    323c:	fmov	s22, w12
    3240:	add	w8, w8, #0x7f
    3244:	fmadd	s13, s28, s22, s13
    3248:	fmov	s22, w8
    324c:	fmadd	s14, s28, s13, s14
    3250:	shl	v22.2s, v22.2s, #23
    3254:	fmadd	s21, s28, s14, s21
    3258:	fmov	s14, #5.000000000000000000e-01
    325c:	fmadd	s21, s28, s21, s14
    3260:	fmadd	s21, s28, s21, s12
    3264:	fmadd	s28, s28, s21, s12
    3268:	fmul	s28, s28, s22
    326c:	ldr	s22, [sp, #140]
    3270:	fmul	s28, s28, s22
    3274:	fcmpe	s31, #0.0
    3278:	fmul	s30, s30, s28
    327c:	b.mi	3294 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2f4>  // b.first
    3280:	b	328c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2ec>
    3284:	movi	v21.2s, #0x0
    3288:	fmul	s30, s30, s21
    328c:	fmov	s31, #1.000000000000000000e+00
    3290:	fsub	s30, s31, s30
    3294:	fnmul	s27, s23, s27
    3298:	fmul	s30, s26, s30
    329c:	movi	v31.2s, #0x0
    32a0:	fcmpe	s27, s24
    32a4:	b.mi	3344 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a4>  // b.first
    32a8:	mov	w8, #0x42b00000            	// #1118830592
    32ac:	fmov	s31, w8
    32b0:	fcmpe	s27, s31
    32b4:	b.gt	3580 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e0>
    32b8:	fmul	s28, s27, s11
    32bc:	fcmpe	s28, #0.0
    32c0:	b.ge	3590 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5f0>  // b.tcont
    32c4:	fmov	s23, #5.000000000000000000e-01
    32c8:	mov	w8, #0x7218                	// #29208
    32cc:	mov	w11, #0xb61                 	// #2913
    32d0:	movk	w8, #0x3f31, lsl #16
    32d4:	mov	w10, #0x8889                	// #34953
    32d8:	fmov	s31, #1.000000000000000000e+00
    32dc:	movk	w11, #0x3ab6, lsl #16
    32e0:	movk	w10, #0x3c08, lsl #16
    32e4:	fmov	s26, w8
    32e8:	mov	w9, #0xaaab                	// #43691
    32ec:	mov	w8, #0xaaab                	// #43691
    32f0:	fsub	s28, s28, s23
    32f4:	movk	w9, #0x3d2a, lsl #16
    32f8:	movk	w8, #0x3e2a, lsl #16
    32fc:	fmov	s21, w11
    3300:	fmov	s14, w10
    3304:	fmov	s22, w9
    3308:	fmov	s13, w8
    330c:	fcvtzs	s28, s28
    3310:	scvtf	s28, s28
    3314:	fmsub	s26, s28, s26, s27
    3318:	fcvtzs	w8, s28
    331c:	fmadd	s14, s26, s21, s14
    3320:	add	w8, w8, #0x7f
    3324:	fmov	s28, w8
    3328:	fmadd	s22, s26, s14, s22
    332c:	fmadd	s13, s26, s22, s13
    3330:	shl	v28.2s, v28.2s, #23
    3334:	fmadd	s23, s26, s13, s23
    3338:	fmadd	s23, s26, s23, s31
    333c:	fmadd	s31, s26, s23, s31
    3340:	fmul	s31, s31, s28
    3344:	fcmpe	s29, #0.0
    3348:	fmul	s27, s25, s31
    334c:	b.mi	350c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x56c>  // b.first
    3350:	fmov	s31, #1.000000000000000000e+00
    3354:	fmov	s28, #-5.000000000000000000e-01
    3358:	fmadd	s26, s29, s7, s31
    335c:	fmul	s28, s29, s28
    3360:	fmul	s28, s28, s29
    3364:	fdiv	s31, s31, s26
    3368:	fcmpe	s28, s24
    336c:	fmadd	s26, s31, s16, s17
    3370:	fmadd	s26, s31, s26, s18
    3374:	fmadd	s26, s31, s26, s19
    3378:	fmadd	s26, s31, s26, s20
    337c:	fmul	s31, s31, s26
    3380:	b.mi	3484 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>  // b.first
    3384:	mov	w8, #0x42b00000            	// #1118830592
    3388:	ldr	s25, [sp, #108]
    338c:	fmov	s26, w8
    3390:	fcmpe	s28, s26
    3394:	b.gt	3488 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e8>
    3398:	nop
    339c:	nop
    33a0:	fmul	s26, s28, s11
    33a4:	fcmpe	s26, #0.0
    33a8:	b.ge	35e4 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x644>  // b.tcont
    33ac:	fmov	s23, #5.000000000000000000e-01
    33b0:	mov	w8, #0x7218                	// #29208
    33b4:	mov	w12, #0xb61                 	// #2913
    33b8:	movk	w8, #0x3f31, lsl #16
    33bc:	mov	w11, #0x8889                	// #34953
    33c0:	fmov	s13, #1.000000000000000000e+00
    33c4:	movk	w12, #0x3ab6, lsl #16
    33c8:	movk	w11, #0x3c08, lsl #16
    33cc:	fmov	s25, w8
    33d0:	mov	w10, #0xaaab                	// #43691
    33d4:	mov	w9, #0xaaab                	// #43691
    33d8:	fsub	s26, s26, s23
    33dc:	movk	w10, #0x3d2a, lsl #16
    33e0:	movk	w9, #0x3e2a, lsl #16
    33e4:	fmov	s12, w12
    33e8:	mov	w8, #0x422a                	// #16938
    33ec:	fmov	s14, w11
    33f0:	movk	w8, #0x3ecc, lsl #16
    33f4:	fmov	s21, w10
    33f8:	fmov	s22, w9
    33fc:	str	w8, [sp, #132]
    3400:	fcvtzs	s26, s26
    3404:	scvtf	s26, s26
    3408:	fmsub	s25, s26, s25, s28
    340c:	fcvtzs	w8, s26
    3410:	fmadd	s14, s25, s12, s14
    3414:	add	w8, w8, #0x7f
    3418:	fmov	s28, w8
    341c:	fmadd	s21, s25, s14, s21
    3420:	fmadd	s22, s25, s21, s22
    3424:	shl	v26.2s, v28.2s, #23
    3428:	fmadd	s23, s25, s22, s23
    342c:	fmadd	s23, s25, s23, s13
    3430:	fmadd	s28, s25, s23, s13
    3434:	fmul	s28, s28, s26
    3438:	ldr	s26, [sp, #132]
    343c:	fmul	s28, s28, s26
    3440:	fcmpe	s29, #0.0
    3444:	fmul	s31, s31, s28
    3448:	b.mi	34cc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x52c>  // b.first
    344c:	fmov	s29, #1.000000000000000000e+00
    3450:	fsub	s31, s29, s31
    3454:	fmsub	s31, s27, s31, s30
    3458:	str	s31, [x5, x7, lsl #2]
    345c:	add	x7, x7, #0x1
    3460:	cmp	x7, x6
    3464:	b.ne	30e0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x140>  // b.any
    3468:	ldp	d8, d9, [sp, #32]
    346c:	ldp	x19, x20, [sp, #16]
    3470:	ldp	d10, d11, [sp, #48]
    3474:	ldp	d12, d13, [sp, #64]
    3478:	ldp	d14, d15, [sp, #80]
    347c:	ldp	x29, x30, [sp], #144
    3480:	ret
    3484:	movi	v25.2s, #0x0
    3488:	fmul	s31, s31, s25
    348c:	fmov	s29, #1.000000000000000000e+00
    3490:	fsub	s31, s29, s31
    3494:	fmsub	s31, s27, s31, s30
    3498:	str	s31, [x5, x7, lsl #2]
    349c:	add	x7, x7, #0x1
    34a0:	cmp	x7, x6
    34a4:	b.ne	30e0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x140>  // b.any
    34a8:	ldp	d8, d9, [sp, #32]
    34ac:	ldp	x19, x20, [sp, #16]
    34b0:	ldp	d10, d11, [sp, #48]
    34b4:	ldp	d12, d13, [sp, #64]
    34b8:	ldp	d14, d15, [sp, #80]
    34bc:	ldp	x29, x30, [sp], #144
    34c0:	ret
    34c4:	movi	v29.2s, #0x0
    34c8:	fmul	s31, s31, s29
    34cc:	fmsub	s31, s27, s31, s30
    34d0:	str	s31, [x5, x7, lsl #2]
    34d4:	add	x7, x7, #0x1
    34d8:	cmp	x6, x7
    34dc:	b.ne	30e0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x140>  // b.any
    34e0:	ldp	d8, d9, [sp, #32]
    34e4:	ldp	x19, x20, [sp, #16]
    34e8:	ldp	d10, d11, [sp, #48]
    34ec:	ldp	d12, d13, [sp, #64]
    34f0:	ldp	d14, d15, [sp, #80]
    34f4:	ldp	x29, x30, [sp], #144
    34f8:	ret
    34fc:	fmov	s30, #5.000000000000000000e-01
    3500:	sub	w8, w8, #0x7e
    3504:	fmul	s31, s31, s30
    3508:	b	3128 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x188>
    350c:	fmov	s26, #1.000000000000000000e+00
    3510:	fmov	s28, #5.000000000000000000e-01
    3514:	fmsub	s31, s29, s7, s26
    3518:	fmul	s28, s29, s28
    351c:	fnmul	s28, s29, s28
    3520:	fdiv	s26, s26, s31
    3524:	fcmpe	s28, s24
    3528:	fmadd	s31, s26, s16, s17
    352c:	fmadd	s31, s31, s26, s18
    3530:	fmadd	s31, s31, s26, s19
    3534:	fmadd	s31, s31, s26, s20
    3538:	fmul	s31, s31, s26
    353c:	b.mi	34c4 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x524>  // b.first
    3540:	b	33a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x400>
    3544:	fmsub	s22, s31, s7, s30
    3548:	fmul	s28, s31, s28
    354c:	fnmul	s28, s31, s28
    3550:	fdiv	s22, s30, s22
    3554:	fcmpe	s28, s24
    3558:	fmadd	s30, s22, s16, s17
    355c:	fmadd	s30, s22, s30, s18
    3560:	fmadd	s30, s22, s30, s19
    3564:	fmadd	s30, s22, s30, s20
    3568:	fmul	s30, s22, s30
    356c:	b.mi	3574 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d4>  // b.first
    3570:	b	31cc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x22c>
    3574:	movi	v31.2s, #0x0
    3578:	fmul	s30, s30, s31
    357c:	b	3294 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2f4>
    3580:	mov	w8, #0x829c                	// #33436
    3584:	movk	w8, #0x7ef8, lsl #16
    3588:	fmov	s31, w8
    358c:	b	3344 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a4>
    3590:	fmov	s26, #5.000000000000000000e-01
    3594:	ldr	s22, [sp, #120]
    3598:	fmov	s31, #1.000000000000000000e+00
    359c:	fadd	s28, s28, s26
    35a0:	fcvtzs	s28, s28
    35a4:	scvtf	s28, s28
    35a8:	fmsub	s27, s28, s6, s27
    35ac:	fcvtzs	w8, s28
    35b0:	ldp	s23, s28, [sp, #112]
    35b4:	fmadd	s28, s27, s23, s28
    35b8:	add	w8, w8, #0x7f
    35bc:	fmov	s23, w8
    35c0:	fmadd	s28, s27, s28, s22
    35c4:	ldr	s22, [sp, #124]
    35c8:	fmadd	s28, s27, s28, s22
    35cc:	shl	v23.2s, v23.2s, #23
    35d0:	fmadd	s26, s27, s28, s26
    35d4:	fmadd	s26, s27, s26, s31
    35d8:	fmadd	s31, s27, s26, s31
    35dc:	fmul	s31, s31, s23
    35e0:	b	3344 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a4>
    35e4:	fmov	s23, #5.000000000000000000e-01
    35e8:	ldr	s21, [sp, #120]
    35ec:	fmov	s25, #1.000000000000000000e+00
    35f0:	fadd	s26, s26, s23
    35f4:	fcvtzs	s26, s26
    35f8:	scvtf	s26, s26
    35fc:	fmsub	s28, s26, s6, s28
    3600:	fcvtzs	w8, s26
    3604:	ldp	s22, s26, [sp, #112]
    3608:	fmadd	s26, s28, s22, s26
    360c:	add	w8, w8, #0x7f
    3610:	fmov	s22, w8
    3614:	fmadd	s26, s28, s26, s21
    3618:	ldr	s21, [sp, #124]
    361c:	fmadd	s26, s28, s26, s21
    3620:	shl	v22.2s, v22.2s, #23
    3624:	fmadd	s23, s28, s26, s23
    3628:	ldr	s26, [sp, #128]
    362c:	fmadd	s23, s28, s23, s25
    3630:	fmadd	s28, s28, s23, s25
    3634:	fmul	s28, s28, s22
    3638:	fmul	s28, s28, s26
    363c:	b	3440 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4a0>
    3640:	fmov	s14, #5.000000000000000000e-01
    3644:	ldr	s12, [sp, #120]
    3648:	fmov	s21, #1.000000000000000000e+00
    364c:	fadd	s22, s22, s14
    3650:	fcvtzs	s22, s22
    3654:	scvtf	s22, s22
    3658:	fmsub	s28, s22, s6, s28
    365c:	fcvtzs	w8, s22
    3660:	ldp	s13, s22, [sp, #112]
    3664:	fmadd	s13, s28, s13, s22
    3668:	add	w8, w8, #0x7f
    366c:	fmov	s22, w8
    3670:	fmadd	s13, s28, s13, s12
    3674:	ldr	s12, [sp, #124]
    3678:	fmadd	s13, s28, s13, s12
    367c:	shl	v22.2s, v22.2s, #23
    3680:	fmadd	s14, s28, s13, s14
    3684:	fmadd	s14, s28, s14, s21
    3688:	fmadd	s28, s28, s14, s21
    368c:	fmul	s28, s28, s22
    3690:	ldr	s22, [sp, #128]
    3694:	fmul	s28, s28, s22
    3698:	b	3274 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d4>
    369c:	ret
