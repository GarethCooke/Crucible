0000000000002fa0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    2fa0:	cbz	x6, 384c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8ac>
    2fa4:	mov	w11, #0x4f3                 	// #1267
    2fa8:	mov	w10, #0x21bb                	// #8635
    2fac:	stp	x29, x30, [sp, #-176]!
    2fb0:	mov	w9, #0xd1b8                	// #53688
    2fb4:	mov	w8, #0x251a                	// #9498
    2fb8:	movk	w11, #0x3fb5, lsl #16
    2fbc:	movk	w10, #0x3d90, lsl #16
    2fc0:	movk	w9, #0xbdeb, lsl #16
    2fc4:	movk	w8, #0x3def, lsl #16
    2fc8:	mov	w7, #0xc2b00000            	// #-1028653056
    2fcc:	mov	x29, sp
    2fd0:	stp	d8, d9, [sp, #32]
    2fd4:	fmov	s8, w11
    2fd8:	fmov	s9, w10
    2fdc:	stp	d10, d11, [sp, #48]
    2fe0:	fmov	s10, w9
    2fe4:	fmov	s11, w8
    2fe8:	stp	d14, d15, [sp, #80]
    2fec:	fmov	s14, w7
    2ff0:	str	x19, [sp, #16]
    2ff4:	mov	x19, #0x0                   	// #0
    2ff8:	stp	d12, d13, [sp, #64]
    2ffc:	nop
    3000:	ldr	s15, [x2, x19, lsl #2]
    3004:	ldr	s21, [x4, x19, lsl #2]
    3008:	ldr	s13, [x0, x19, lsl #2]
    300c:	fcmp	s15, #0.0
    3010:	ldr	s12, [x1, x19, lsl #2]
    3014:	ldr	s24, [x3, x19, lsl #2]
    3018:	fmul	s19, s21, s21
    301c:	b.pl	3060 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xc0>  // b.nfrst
    3020:	fmov	s0, s15
    3024:	stp	s24, s21, [sp, #108]
    3028:	str	s19, [sp, #116]
    302c:	stp	x0, x1, [sp, #120]
    3030:	stp	x2, x3, [sp, #136]
    3034:	stp	x4, x5, [sp, #152]
    3038:	str	x6, [sp, #168]
    303c:	bl	ec0 <sqrtf@plt>
    3040:	ldr	s19, [sp, #116]
    3044:	fmov	s31, s0
    3048:	ldp	x0, x1, [sp, #120]
    304c:	ldp	x2, x3, [sp, #136]
    3050:	ldp	x4, x5, [sp, #152]
    3054:	ldr	x6, [sp, #168]
    3058:	ldp	s24, s21, [sp, #108]
    305c:	b	3064 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xc4>
    3060:	fsqrt	s31, s15
    3064:	fmul	s21, s21, s31
    3068:	fdiv	s30, s13, s12
    306c:	fmov	w7, s30
    3070:	and	w8, w7, #0x7fffff
    3074:	ubfx	x7, x7, #23, #8
    3078:	orr	w8, w8, #0x3f800000
    307c:	fmov	s31, w8
    3080:	fcmpe	s31, s8
    3084:	b.ge	356c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5cc>  // b.tcont
    3088:	sub	w8, w7, #0x7f
    308c:	fmov	s29, #1.000000000000000000e+00
    3090:	mov	w7, #0x5d4f                	// #23887
    3094:	mov	w12, #0xe9bf                	// #59839
    3098:	movk	w7, #0xbdfe, lsl #16
    309c:	movk	w12, #0x3e11, lsl #16
    30a0:	fmov	s22, #5.000000000000000000e-01
    30a4:	mov	w11, #0xae50                	// #44624
    30a8:	mov	w10, #0xceac                	// #52908
    30ac:	scvtf	s20, w8
    30b0:	fmov	s23, w7
    30b4:	movk	w11, #0xbe2a, lsl #16
    30b8:	movk	w10, #0x3e4c, lsl #16
    30bc:	fsub	s31, s31, s29
    30c0:	mov	w9, #0xfffc                	// #65532
    30c4:	mov	w7, #0xaaaa                	// #43690
    30c8:	fmov	s25, w12
    30cc:	movk	w9, #0xbe7f, lsl #16
    30d0:	movk	w7, #0x3eaa, lsl #16
    30d4:	fmov	s26, w11
    30d8:	mov	w12, #0x7218                	// #29208
    30dc:	fmov	s27, w10
    30e0:	movk	w12, #0x3f31, lsl #16
    30e4:	fmov	s28, w9
    30e8:	fmov	s30, w7
    30ec:	fmadd	s16, s31, s9, s10
    30f0:	fmul	s7, s31, s31
    30f4:	fmov	s18, w12
    30f8:	fmadd	s19, s19, s22, s24
    30fc:	fmadd	s16, s31, s16, s11
    3100:	fmul	s17, s7, s22
    3104:	fmadd	s23, s31, s16, s23
    3108:	fmadd	s25, s31, s23, s25
    310c:	fmadd	s26, s31, s25, s26
    3110:	fmadd	s27, s31, s26, s27
    3114:	fmadd	s28, s31, s27, s28
    3118:	fmadd	s30, s31, s28, s30
    311c:	fmul	s30, s30, s7
    3120:	fnmsub	s30, s31, s30, s17
    3124:	fadd	s31, s31, s30
    3128:	fmadd	s31, s20, s18, s31
    312c:	fmadd	s31, s15, s19, s31
    3130:	fdiv	s31, s31, s21
    3134:	fcmpe	s31, #0.0
    3138:	fsub	s28, s31, s21
    313c:	b.mi	35fc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x65c>  // b.first
    3140:	mov	w7, #0x3389                	// #13193
    3144:	mov	w11, #0x466f                	// #18031
    3148:	fmov	s22, #-5.000000000000000000e-01
    314c:	movk	w7, #0x3e6d, lsl #16
    3150:	mov	w10, #0x1eea                	// #7914
    3154:	movk	w11, #0x3faa, lsl #16
    3158:	movk	w10, #0xbfe9, lsl #16
    315c:	fmov	s30, w7
    3160:	mov	w9, #0x778                 	// #1912
    3164:	mov	w8, #0x8f89                	// #36745
    3168:	fmov	s21, w11
    316c:	movk	w9, #0x3fe4, lsl #16
    3170:	movk	w8, #0xbeb6, lsl #16
    3174:	fmov	s23, w10
    3178:	mov	w7, #0x85fa                	// #34298
    317c:	fmov	s25, w9
    3180:	movk	w7, #0x3ea3, lsl #16
    3184:	fmov	s26, w8
    3188:	fmov	s27, w7
    318c:	fmul	s22, s31, s22
    3190:	fmadd	s30, s31, s30, s29
    3194:	fmul	s22, s22, s31
    3198:	fcmpe	s22, s14
    319c:	fdiv	s30, s29, s30
    31a0:	fmadd	s29, s30, s21, s23
    31a4:	fmadd	s29, s30, s29, s25
    31a8:	fmadd	s29, s30, s29, s26
    31ac:	fmadd	s29, s30, s29, s27
    31b0:	fmul	s30, s30, s29
    31b4:	b.mi	3688 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e8>  // b.first
    31b8:	mov	w7, #0x42b00000            	// #1118830592
    31bc:	fmov	s29, w7
    31c0:	fcmpe	s22, s29
    31c4:	b.gt	3280 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2e0>
    31c8:	mov	w7, #0xaa3b                	// #43579
    31cc:	movk	w7, #0x3fb8, lsl #16
    31d0:	fmov	s29, w7
    31d4:	fmul	s29, s22, s29
    31d8:	fcmpe	s29, #0.0
    31dc:	b.ge	37b8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x818>  // b.tcont
    31e0:	fmov	s26, #5.000000000000000000e-01
    31e4:	mov	w7, #0x7218                	// #29208
    31e8:	mov	w10, #0xb61                 	// #2913
    31ec:	movk	w7, #0x3f31, lsl #16
    31f0:	mov	w9, #0x8889                	// #34953
    31f4:	fmov	s27, #1.000000000000000000e+00
    31f8:	movk	w10, #0x3ab6, lsl #16
    31fc:	movk	w9, #0x3c08, lsl #16
    3200:	fmov	s18, w7
    3204:	mov	w8, #0xaaab                	// #43691
    3208:	mov	w7, #0xaaab                	// #43691
    320c:	fsub	s29, s29, s26
    3210:	movk	w8, #0x3d2a, lsl #16
    3214:	movk	w7, #0x3e2a, lsl #16
    3218:	fmov	s19, w10
    321c:	mov	w11, #0x422a                	// #16938
    3220:	fmov	s21, w9
    3224:	movk	w11, #0x3ecc, lsl #16
    3228:	fmov	s23, w8
    322c:	fmov	s25, w7
    3230:	fmov	s20, w11
    3234:	fcvtzs	s29, s29
    3238:	scvtf	s29, s29
    323c:	fmsub	s22, s29, s18, s22
    3240:	fcvtzs	w7, s29
    3244:	fmadd	s21, s22, s19, s21
    3248:	add	w7, w7, #0x7f
    324c:	fmov	s29, w7
    3250:	fmadd	s23, s22, s21, s23
    3254:	fmadd	s25, s22, s23, s25
    3258:	shl	v29.2s, v29.2s, #23
    325c:	fmadd	s26, s22, s25, s26
    3260:	fmadd	s26, s22, s26, s27
    3264:	fmadd	s27, s22, s26, s27
    3268:	fmul	s29, s27, s29
    326c:	fmul	s29, s29, s20
    3270:	fcmpe	s31, #0.0
    3274:	fmul	s30, s30, s29
    3278:	b.mi	3298 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2f8>  // b.first
    327c:	b	3290 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2f0>
    3280:	mov	w7, #0x484f                	// #18511
    3284:	movk	w7, #0x7e46, lsl #16
    3288:	fmov	s31, w7
    328c:	fmul	s30, s31, s30
    3290:	fmov	s31, #1.000000000000000000e+00
    3294:	fsub	s30, s31, s30
    3298:	fnmul	s15, s24, s15
    329c:	fmul	s30, s13, s30
    32a0:	movi	v31.2s, #0x0
    32a4:	fcmpe	s15, s14
    32a8:	b.mi	3360 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3c0>  // b.first
    32ac:	mov	w7, #0x42b00000            	// #1118830592
    32b0:	fmov	s31, w7
    32b4:	fcmpe	s15, s31
    32b8:	b.gt	3690 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6f0>
    32bc:	mov	w7, #0xaa3b                	// #43579
    32c0:	movk	w7, #0x3fb8, lsl #16
    32c4:	fmov	s31, w7
    32c8:	fmul	s31, s15, s31
    32cc:	fcmpe	s31, #0.0
    32d0:	b.ge	36a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x700>  // b.tcont
    32d4:	fmov	s27, #5.000000000000000000e-01
    32d8:	mov	w7, #0x7218                	// #29208
    32dc:	mov	w10, #0xb61                 	// #2913
    32e0:	movk	w7, #0x3f31, lsl #16
    32e4:	mov	w9, #0x8889                	// #34953
    32e8:	fmov	s29, #1.000000000000000000e+00
    32ec:	movk	w10, #0x3ab6, lsl #16
    32f0:	movk	w9, #0x3c08, lsl #16
    32f4:	fmov	s22, w7
    32f8:	mov	w8, #0xaaab                	// #43691
    32fc:	mov	w7, #0xaaab                	// #43691
    3300:	fsub	s31, s31, s27
    3304:	movk	w8, #0x3d2a, lsl #16
    3308:	movk	w7, #0x3e2a, lsl #16
    330c:	fmov	s23, w10
    3310:	fmov	s24, w9
    3314:	fmov	s25, w8
    3318:	fmov	s26, w7
    331c:	fcvtzs	s31, s31
    3320:	scvtf	s31, s31
    3324:	fmsub	s15, s31, s22, s15
    3328:	fcvtzs	w7, s31
    332c:	fmadd	s24, s15, s23, s24
    3330:	add	w7, w7, #0x7f
    3334:	fmov	s31, w7
    3338:	fmadd	s25, s15, s24, s25
    333c:	fmadd	s26, s15, s25, s26
    3340:	shl	v31.2s, v31.2s, #23
    3344:	fmadd	s27, s15, s26, s27
    3348:	fmadd	s27, s15, s27, s29
    334c:	fmadd	s29, s15, s27, s29
    3350:	fmul	s31, s29, s31
    3354:	nop
    3358:	nop
    335c:	nop
    3360:	fcmpe	s28, #0.0
    3364:	fmul	s26, s12, s31
    3368:	b.mi	357c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5dc>  // b.first
    336c:	mov	w7, #0x3389                	// #13193
    3370:	fmov	s31, #1.000000000000000000e+00
    3374:	mov	w11, #0x466f                	// #18031
    3378:	movk	w7, #0x3e6d, lsl #16
    337c:	mov	w10, #0x1eea                	// #7914
    3380:	fmov	s27, #-5.000000000000000000e-01
    3384:	movk	w11, #0x3faa, lsl #16
    3388:	movk	w10, #0xbfe9, lsl #16
    338c:	fmov	s22, w7
    3390:	mov	w9, #0x778                 	// #1912
    3394:	mov	w8, #0x8f89                	// #36745
    3398:	fmov	s21, w11
    339c:	movk	w9, #0x3fe4, lsl #16
    33a0:	movk	w8, #0xbeb6, lsl #16
    33a4:	fmov	s23, w10
    33a8:	mov	w7, #0x85fa                	// #34298
    33ac:	fmov	s24, w9
    33b0:	movk	w7, #0x3ea3, lsl #16
    33b4:	fmov	s25, w8
    33b8:	fmov	s29, w7
    33bc:	fmul	s27, s28, s27
    33c0:	fmadd	s22, s28, s22, s31
    33c4:	fmul	s27, s27, s28
    33c8:	fcmpe	s27, s14
    33cc:	fdiv	s31, s31, s22
    33d0:	fmadd	s23, s31, s21, s23
    33d4:	fmadd	s24, s31, s23, s24
    33d8:	fmadd	s25, s31, s24, s25
    33dc:	fmadd	s29, s31, s25, s29
    33e0:	fmul	s31, s31, s29
    33e4:	b.mi	3680 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e0>  // b.first
    33e8:	mov	w7, #0x42b00000            	// #1118830592
    33ec:	fmov	s29, w7
    33f0:	fcmpe	s27, s29
    33f4:	b.gt	34ec <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x54c>
    33f8:	nop
    33fc:	nop
    3400:	mov	w7, #0xaa3b                	// #43579
    3404:	movk	w7, #0x3fb8, lsl #16
    3408:	fmov	s29, w7
    340c:	fmul	s29, s27, s29
    3410:	fcmpe	s29, #0.0
    3414:	b.ge	3724 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x784>  // b.tcont
    3418:	fmov	s24, #5.000000000000000000e-01
    341c:	mov	w7, #0x7218                	// #29208
    3420:	mov	w11, #0xb61                 	// #2913
    3424:	movk	w7, #0x3f31, lsl #16
    3428:	mov	w9, #0x8889                	// #34953
    342c:	fmov	s25, #1.000000000000000000e+00
    3430:	movk	w11, #0x3ab6, lsl #16
    3434:	movk	w9, #0x3c08, lsl #16
    3438:	fmov	s18, w7
    343c:	mov	w8, #0xaaab                	// #43691
    3440:	mov	w7, #0xaaab                	// #43691
    3444:	fsub	s29, s29, s24
    3448:	movk	w8, #0x3d2a, lsl #16
    344c:	movk	w7, #0x3e2a, lsl #16
    3450:	fmov	s19, w11
    3454:	mov	w10, #0x422a                	// #16938
    3458:	fmov	s21, w9
    345c:	movk	w10, #0x3ecc, lsl #16
    3460:	fmov	s22, w8
    3464:	fmov	s23, w7
    3468:	fmov	s20, w10
    346c:	fcvtzs	s29, s29
    3470:	scvtf	s29, s29
    3474:	fmsub	s27, s29, s18, s27
    3478:	fcvtzs	w7, s29
    347c:	fmadd	s21, s27, s19, s21
    3480:	add	w7, w7, #0x7f
    3484:	fmov	s29, w7
    3488:	fmadd	s22, s27, s21, s22
    348c:	fmadd	s23, s27, s22, s23
    3490:	shl	v29.2s, v29.2s, #23
    3494:	fmadd	s24, s27, s23, s24
    3498:	fmadd	s24, s27, s24, s25
    349c:	fmadd	s25, s27, s24, s25
    34a0:	fmul	s29, s25, s29
    34a4:	fmul	s29, s29, s20
    34a8:	fcmpe	s28, #0.0
    34ac:	fmul	s31, s31, s29
    34b0:	b.mi	353c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x59c>  // b.first
    34b4:	fmov	s29, #1.000000000000000000e+00
    34b8:	fsub	s31, s29, s31
    34bc:	fmsub	s31, s26, s31, s30
    34c0:	str	s31, [x5, x19, lsl #2]
    34c4:	add	x19, x19, #0x1
    34c8:	cmp	x19, x6
    34cc:	b.ne	3000 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x60>  // b.any
    34d0:	ldr	x19, [sp, #16]
    34d4:	ldp	d8, d9, [sp, #32]
    34d8:	ldp	d10, d11, [sp, #48]
    34dc:	ldp	d12, d13, [sp, #64]
    34e0:	ldp	d14, d15, [sp, #80]
    34e4:	ldp	x29, x30, [sp], #176
    34e8:	ret
    34ec:	mov	w7, #0x484f                	// #18511
    34f0:	movk	w7, #0x7e46, lsl #16
    34f4:	fmov	s29, w7
    34f8:	fmul	s31, s31, s29
    34fc:	fmov	s29, #1.000000000000000000e+00
    3500:	fsub	s31, s29, s31
    3504:	fmsub	s31, s26, s31, s30
    3508:	str	s31, [x5, x19, lsl #2]
    350c:	add	x19, x19, #0x1
    3510:	cmp	x19, x6
    3514:	b.ne	3000 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x60>  // b.any
    3518:	ldr	x19, [sp, #16]
    351c:	ldp	d8, d9, [sp, #32]
    3520:	ldp	d10, d11, [sp, #48]
    3524:	ldp	d12, d13, [sp, #64]
    3528:	ldp	d14, d15, [sp, #80]
    352c:	ldp	x29, x30, [sp], #176
    3530:	ret
    3534:	movi	v29.2s, #0x0
    3538:	fmul	s31, s31, s29
    353c:	fmsub	s31, s26, s31, s30
    3540:	str	s31, [x5, x19, lsl #2]
    3544:	add	x19, x19, #0x1
    3548:	cmp	x6, x19
    354c:	b.ne	3000 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x60>  // b.any
    3550:	ldr	x19, [sp, #16]
    3554:	ldp	d8, d9, [sp, #32]
    3558:	ldp	d10, d11, [sp, #48]
    355c:	ldp	d12, d13, [sp, #64]
    3560:	ldp	d14, d15, [sp, #80]
    3564:	ldp	x29, x30, [sp], #176
    3568:	ret
    356c:	fmov	s30, #5.000000000000000000e-01
    3570:	sub	w8, w7, #0x7e
    3574:	fmul	s31, s31, s30
    3578:	b	308c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xec>
    357c:	mov	w7, #0x3389                	// #13193
    3580:	fmov	s29, #1.000000000000000000e+00
    3584:	mov	w11, #0x466f                	// #18031
    3588:	movk	w7, #0x3e6d, lsl #16
    358c:	mov	w10, #0x1eea                	// #7914
    3590:	fmov	s27, #5.000000000000000000e-01
    3594:	movk	w11, #0x3faa, lsl #16
    3598:	movk	w10, #0xbfe9, lsl #16
    359c:	fmov	s22, w7
    35a0:	mov	w9, #0x778                 	// #1912
    35a4:	mov	w8, #0x8f89                	// #36745
    35a8:	fmov	s21, w11
    35ac:	movk	w9, #0x3fe4, lsl #16
    35b0:	movk	w8, #0xbeb6, lsl #16
    35b4:	fmov	s23, w10
    35b8:	mov	w7, #0x85fa                	// #34298
    35bc:	fmov	s24, w9
    35c0:	movk	w7, #0x3ea3, lsl #16
    35c4:	fmov	s25, w8
    35c8:	fmov	s31, w7
    35cc:	fmul	s27, s28, s27
    35d0:	fmsub	s22, s28, s22, s29
    35d4:	fnmul	s27, s28, s27
    35d8:	fcmpe	s27, s14
    35dc:	fdiv	s29, s29, s22
    35e0:	fmadd	s23, s29, s21, s23
    35e4:	fmadd	s24, s23, s29, s24
    35e8:	fmadd	s25, s24, s29, s25
    35ec:	fmadd	s31, s25, s29, s31
    35f0:	fmul	s31, s29, s31
    35f4:	b.mi	3534 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x594>  // b.first
    35f8:	b	3400 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x460>
    35fc:	mov	w7, #0x3389                	// #13193
    3600:	mov	w11, #0x466f                	// #18031
    3604:	fmul	s22, s31, s22
    3608:	movk	w7, #0x3e6d, lsl #16
    360c:	mov	w10, #0x1eea                	// #7914
    3610:	movk	w11, #0x3faa, lsl #16
    3614:	movk	w10, #0xbfe9, lsl #16
    3618:	fmov	s30, w7
    361c:	mov	w9, #0x778                 	// #1912
    3620:	mov	w8, #0x8f89                	// #36745
    3624:	fmov	s21, w11
    3628:	movk	w9, #0x3fe4, lsl #16
    362c:	movk	w8, #0xbeb6, lsl #16
    3630:	fmov	s23, w10
    3634:	mov	w7, #0x85fa                	// #34298
    3638:	fmov	s25, w9
    363c:	movk	w7, #0x3ea3, lsl #16
    3640:	fmov	s26, w8
    3644:	fmov	s27, w7
    3648:	fnmul	s22, s31, s22
    364c:	fmsub	s30, s31, s30, s29
    3650:	fcmpe	s22, s14
    3654:	fdiv	s30, s29, s30
    3658:	fmadd	s29, s30, s21, s23
    365c:	fmadd	s29, s30, s29, s25
    3660:	fmadd	s29, s30, s29, s26
    3664:	fmadd	s29, s30, s29, s27
    3668:	fmul	s30, s30, s29
    366c:	b.mi	3674 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6d4>  // b.first
    3670:	b	31c8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x228>
    3674:	movi	v31.2s, #0x0
    3678:	fmul	s30, s30, s31
    367c:	b	3298 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2f8>
    3680:	movi	v29.2s, #0x0
    3684:	b	34f8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x558>
    3688:	movi	v31.2s, #0x0
    368c:	b	328c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2ec>
    3690:	mov	w7, #0x829c                	// #33436
    3694:	movk	w7, #0x7ef8, lsl #16
    3698:	fmov	s31, w7
    369c:	b	3360 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3c0>
    36a0:	fmov	s26, #5.000000000000000000e-01
    36a4:	mov	w7, #0x7218                	// #29208
    36a8:	mov	w10, #0xb61                 	// #2913
    36ac:	movk	w7, #0x3f31, lsl #16
    36b0:	mov	w9, #0x8889                	// #34953
    36b4:	fmov	s29, #1.000000000000000000e+00
    36b8:	movk	w10, #0x3ab6, lsl #16
    36bc:	movk	w9, #0x3c08, lsl #16
    36c0:	fmov	s27, w7
    36c4:	mov	w8, #0xaaab                	// #43691
    36c8:	mov	w7, #0xaaab                	// #43691
    36cc:	fadd	s31, s31, s26
    36d0:	movk	w8, #0x3d2a, lsl #16
    36d4:	movk	w7, #0x3e2a, lsl #16
    36d8:	fmov	s22, w10
    36dc:	fmov	s23, w9
    36e0:	fmov	s24, w8
    36e4:	fmov	s25, w7
    36e8:	fcvtzs	s31, s31
    36ec:	scvtf	s31, s31
    36f0:	fmsub	s27, s31, s27, s15
    36f4:	fcvtzs	w7, s31
    36f8:	fmadd	s23, s27, s22, s23
    36fc:	add	w7, w7, #0x7f
    3700:	fmov	s31, w7
    3704:	fmadd	s24, s27, s23, s24
    3708:	fmadd	s25, s27, s24, s25
    370c:	shl	v31.2s, v31.2s, #23
    3710:	fmadd	s26, s27, s25, s26
    3714:	fmadd	s26, s27, s26, s29
    3718:	fmadd	s29, s27, s26, s29
    371c:	fmul	s31, s29, s31
    3720:	b	3360 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3c0>
    3724:	fmov	s23, #5.000000000000000000e-01
    3728:	mov	w7, #0x7218                	// #29208
    372c:	mov	w11, #0xb61                 	// #2913
    3730:	movk	w7, #0x3f31, lsl #16
    3734:	mov	w9, #0x8889                	// #34953
    3738:	fmov	s25, #1.000000000000000000e+00
    373c:	movk	w11, #0x3ab6, lsl #16
    3740:	movk	w9, #0x3c08, lsl #16
    3744:	fmov	s24, w7
    3748:	mov	w8, #0xaaab                	// #43691
    374c:	mov	w7, #0xaaab                	// #43691
    3750:	fadd	s29, s29, s23
    3754:	movk	w8, #0x3d2a, lsl #16
    3758:	movk	w7, #0x3e2a, lsl #16
    375c:	fmov	s18, w11
    3760:	mov	w10, #0x422a                	// #16938
    3764:	fmov	s20, w9
    3768:	movk	w10, #0x3ecc, lsl #16
    376c:	fmov	s21, w8
    3770:	fmov	s22, w7
    3774:	fmov	s19, w10
    3778:	fcvtzs	s29, s29
    377c:	scvtf	s29, s29
    3780:	fmsub	s27, s29, s24, s27
    3784:	fcvtzs	w7, s29
    3788:	fmadd	s24, s27, s18, s20
    378c:	add	w7, w7, #0x7f
    3790:	fmov	s29, w7
    3794:	fmadd	s24, s27, s24, s21
    3798:	fmadd	s24, s27, s24, s22
    379c:	shl	v29.2s, v29.2s, #23
    37a0:	fmadd	s23, s27, s24, s23
    37a4:	fmadd	s23, s27, s23, s25
    37a8:	fmadd	s25, s27, s23, s25
    37ac:	fmul	s29, s25, s29
    37b0:	fmul	s29, s29, s19
    37b4:	b	34a8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x508>
    37b8:	fmov	s25, #5.000000000000000000e-01
    37bc:	mov	w7, #0x7218                	// #29208
    37c0:	mov	w10, #0xb61                 	// #2913
    37c4:	movk	w7, #0x3f31, lsl #16
    37c8:	mov	w9, #0x8889                	// #34953
    37cc:	fmov	s27, #1.000000000000000000e+00
    37d0:	movk	w10, #0x3ab6, lsl #16
    37d4:	movk	w9, #0x3c08, lsl #16
    37d8:	fmov	s26, w7
    37dc:	mov	w8, #0xaaab                	// #43691
    37e0:	mov	w7, #0xaaab                	// #43691
    37e4:	fadd	s29, s29, s25
    37e8:	movk	w8, #0x3d2a, lsl #16
    37ec:	movk	w7, #0x3e2a, lsl #16
    37f0:	fmov	s18, w10
    37f4:	mov	w11, #0x422a                	// #16938
    37f8:	fmov	s20, w9
    37fc:	movk	w11, #0x3ecc, lsl #16
    3800:	fmov	s21, w8
    3804:	fmov	s23, w7
    3808:	fmov	s19, w11
    380c:	fcvtzs	s29, s29
    3810:	scvtf	s29, s29
    3814:	fmsub	s26, s29, s26, s22
    3818:	fcvtzs	w7, s29
    381c:	fmadd	s22, s26, s18, s20
    3820:	add	w7, w7, #0x7f
    3824:	fmov	s29, w7
    3828:	fmadd	s22, s26, s22, s21
    382c:	fmadd	s23, s26, s22, s23
    3830:	shl	v29.2s, v29.2s, #23
    3834:	fmadd	s25, s26, s23, s25
    3838:	fmadd	s25, s26, s25, s27
    383c:	fmadd	s27, s26, s25, s27
    3840:	fmul	s29, s27, s29
    3844:	fmul	s29, s29, s19
    3848:	b	3270 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    384c:	ret
