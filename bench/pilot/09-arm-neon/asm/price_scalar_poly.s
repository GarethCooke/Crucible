0000000000003020 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    3020:	cbz	x6, 37dc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    3024:	stp	x29, x30, [sp, #-160]!
    3028:	mov	x29, sp
    302c:	stp	x23, x24, [sp, #48]
    3030:	mov	x24, x4
    3034:	mov	w4, #0xaa3b                	// #43579
    3038:	movk	w4, #0x3fb8, lsl #16
    303c:	mov	x23, x3
    3040:	mov	w3, #0x7218                	// #29208
    3044:	stp	x19, x20, [sp, #16]
    3048:	mov	x20, x0
    304c:	mov	w0, #0xc2b00000            	// #-1028653056
    3050:	movk	w3, #0x3f31, lsl #16
    3054:	mov	x19, x6
    3058:	stp	d8, d9, [sp, #80]
    305c:	fmov	s9, w0
    3060:	stp	d14, d15, [sp, #128]
    3064:	fmov	s14, w4
    3068:	stp	x21, x22, [sp, #32]
    306c:	mov	x21, x1
    3070:	mov	x22, x2
    3074:	mov	w1, #0x8889                	// #34953
    3078:	mov	w2, #0xb61                 	// #2913
    307c:	movk	w2, #0x3ab6, lsl #16
    3080:	movk	w1, #0x3c08, lsl #16
    3084:	stp	x25, x26, [sp, #64]
    3088:	mov	x26, #0x0                   	// #0
    308c:	mov	x25, x5
    3090:	stp	d10, d11, [sp, #96]
    3094:	stp	d12, d13, [sp, #112]
    3098:	stp	w3, w2, [sp, #148]
    309c:	str	w1, [sp, #156]
    30a0:	ldr	s12, [x22, x26, lsl #2]
    30a4:	ldr	s15, [x24, x26, lsl #2]
    30a8:	ldr	s13, [x20, x26, lsl #2]
    30ac:	fcmp	s12, #0.0
    30b0:	ldr	s8, [x21, x26, lsl #2]
    30b4:	ldr	s11, [x23, x26, lsl #2]
    30b8:	fmul	s10, s15, s15
    30bc:	b.pl	3174 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    30c0:	fmov	s0, s12
    30c4:	bl	ec0 <sqrtf@plt>
    30c8:	fmov	s31, s0
    30cc:	fdiv	s0, s13, s8
    30d0:	fmul	s15, s15, s31
    30d4:	bl	1020 <logf@plt>
    30d8:	fmov	s31, #5.000000000000000000e-01
    30dc:	mov	w0, #0x3389                	// #13193
    30e0:	fmov	s25, #1.000000000000000000e+00
    30e4:	movk	w0, #0x3e6d, lsl #16
    30e8:	mov	w1, #0x466f                	// #18031
    30ec:	fmov	s19, #-5.000000000000000000e-01
    30f0:	mov	w4, #0x1eea                	// #7914
    30f4:	movk	w1, #0x3faa, lsl #16
    30f8:	fmov	s29, w0
    30fc:	movk	w4, #0xbfe9, lsl #16
    3100:	mov	w3, #0x778                 	// #1912
    3104:	fmadd	s10, s10, s31, s11
    3108:	movk	w3, #0x3fe4, lsl #16
    310c:	mov	w2, #0x8f89                	// #36745
    3110:	fmov	s20, w1
    3114:	movk	w2, #0xbeb6, lsl #16
    3118:	mov	w1, #0x85fa                	// #34298
    311c:	movk	w1, #0x3ea3, lsl #16
    3120:	mov	w0, #0xaa3b                	// #43579
    3124:	fmov	s22, w4
    3128:	movk	w0, #0x3fb8, lsl #16
    312c:	fmov	s23, w3
    3130:	fmadd	s0, s12, s10, s0
    3134:	fmov	s24, w2
    3138:	fmov	s31, w1
    313c:	fmov	s28, w0
    3140:	fdiv	s0, s0, s15
    3144:	fmadd	s21, s0, s29, s25
    3148:	fmul	s29, s0, s19
    314c:	fsub	s15, s0, s15
    3150:	fmul	s29, s29, s0
    3154:	fdiv	s25, s25, s21
    3158:	fmul	s28, s29, s28
    315c:	fmadd	s22, s25, s20, s22
    3160:	fmadd	s23, s22, s25, s23
    3164:	fmadd	s24, s23, s25, s24
    3168:	fmadd	s31, s24, s25, s31
    316c:	fmul	s31, s31, s25
    3170:	b	3238 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    3174:	fsqrt	s31, s12
    3178:	fdiv	s0, s13, s8
    317c:	fmul	s15, s15, s31
    3180:	bl	1020 <logf@plt>
    3184:	fmov	s29, #5.000000000000000000e-01
    3188:	fmadd	s10, s10, s29, s11
    318c:	fmadd	s0, s12, s10, s0
    3190:	fdiv	s0, s0, s15
    3194:	fcmpe	s0, #0.0
    3198:	fsub	s15, s0, s15
    319c:	b.mi	357c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    31a0:	mov	w0, #0x3389                	// #13193
    31a4:	fmov	s31, #1.000000000000000000e+00
    31a8:	mov	w4, #0x466f                	// #18031
    31ac:	movk	w0, #0x3e6d, lsl #16
    31b0:	mov	w3, #0x1eea                	// #7914
    31b4:	fmov	s29, #-5.000000000000000000e-01
    31b8:	movk	w4, #0x3faa, lsl #16
    31bc:	movk	w3, #0xbfe9, lsl #16
    31c0:	fmov	s22, w0
    31c4:	mov	w2, #0x778                 	// #1912
    31c8:	mov	w1, #0x8f89                	// #36745
    31cc:	fmov	s21, w4
    31d0:	movk	w2, #0x3fe4, lsl #16
    31d4:	movk	w1, #0xbeb6, lsl #16
    31d8:	fmov	s23, w3
    31dc:	mov	w0, #0x85fa                	// #34298
    31e0:	fmov	s24, w2
    31e4:	movk	w0, #0x3ea3, lsl #16
    31e8:	fmov	s25, w1
    31ec:	fmov	s28, w0
    31f0:	fmul	s29, s0, s29
    31f4:	fmadd	s22, s0, s22, s31
    31f8:	fmul	s29, s29, s0
    31fc:	fcmpe	s29, s9
    3200:	fdiv	s31, s31, s22
    3204:	fmadd	s23, s31, s21, s23
    3208:	fmadd	s24, s31, s23, s24
    320c:	fmadd	s25, s31, s24, s25
    3210:	fmadd	s28, s31, s25, s28
    3214:	fmul	s31, s31, s28
    3218:	b.mi	368c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    321c:	mov	w0, #0x42b00000            	// #1118830592
    3220:	fmov	s28, w0
    3224:	fcmpe	s29, s28
    3228:	b.gt	32d8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    322c:	fmul	s28, s29, s14
    3230:	fcmpe	s28, #0.0
    3234:	b.ge	36ec <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    3238:	fmov	s23, #5.000000000000000000e-01
    323c:	mov	w0, #0x7218                	// #29208
    3240:	mov	w3, #0xb61                 	// #2913
    3244:	movk	w0, #0x3f31, lsl #16
    3248:	mov	w2, #0x8889                	// #34953
    324c:	fmov	s24, #1.000000000000000000e+00
    3250:	movk	w3, #0x3ab6, lsl #16
    3254:	movk	w2, #0x3c08, lsl #16
    3258:	fmov	s25, w0
    325c:	mov	w1, #0xaaab                	// #43691
    3260:	mov	w0, #0xaaab                	// #43691
    3264:	fsub	s28, s28, s23
    3268:	movk	w1, #0x3d2a, lsl #16
    326c:	movk	w0, #0x3e2a, lsl #16
    3270:	fmov	s18, w3
    3274:	mov	w4, #0x422a                	// #16938
    3278:	fmov	s20, w2
    327c:	movk	w4, #0x3ecc, lsl #16
    3280:	fmov	s21, w1
    3284:	fmov	s22, w0
    3288:	fmov	s19, w4
    328c:	fcvtzs	s28, s28
    3290:	scvtf	s28, s28
    3294:	fmsub	s25, s28, s25, s29
    3298:	fcvtzs	w0, s28
    329c:	fmadd	s28, s25, s18, s20
    32a0:	add	w0, w0, #0x7f
    32a4:	fmov	s30, w0
    32a8:	fmadd	s28, s25, s28, s21
    32ac:	fmadd	s28, s25, s28, s22
    32b0:	shl	v29.2s, v30.2s, #23
    32b4:	fmadd	s23, s25, s28, s23
    32b8:	fmadd	s23, s25, s23, s24
    32bc:	fmadd	s24, s25, s23, s24
    32c0:	fmul	s29, s24, s29
    32c4:	fmul	s29, s29, s19
    32c8:	fcmpe	s0, #0.0
    32cc:	fmul	s31, s31, s29
    32d0:	b.mi	32f0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    32d4:	b	32e8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    32d8:	mov	w0, #0x484f                	// #18511
    32dc:	movk	w0, #0x7e46, lsl #16
    32e0:	fmov	s29, w0
    32e4:	fmul	s31, s31, s29
    32e8:	fmov	s29, #1.000000000000000000e+00
    32ec:	fsub	s31, s29, s31
    32f0:	fnmul	s30, s11, s12
    32f4:	fmul	s31, s13, s31
    32f8:	movi	v29.2s, #0x0
    32fc:	fcmpe	s30, s9
    3300:	b.mi	33a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    3304:	mov	w0, #0x42b00000            	// #1118830592
    3308:	fmov	s29, w0
    330c:	fcmpe	s30, s29
    3310:	b.gt	3698 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    3314:	fmul	s28, s30, s14
    3318:	fcmpe	s28, #0.0
    331c:	b.ge	36a8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    3320:	fmov	s27, #5.000000000000000000e-01
    3324:	mov	w0, #0x7218                	// #29208
    3328:	mov	w3, #0xb61                 	// #2913
    332c:	movk	w0, #0x3f31, lsl #16
    3330:	mov	w2, #0x8889                	// #34953
    3334:	fmov	s29, #1.000000000000000000e+00
    3338:	movk	w3, #0x3ab6, lsl #16
    333c:	movk	w2, #0x3c08, lsl #16
    3340:	fmov	s22, w0
    3344:	mov	w1, #0xaaab                	// #43691
    3348:	mov	w0, #0xaaab                	// #43691
    334c:	fsub	s28, s28, s27
    3350:	movk	w1, #0x3d2a, lsl #16
    3354:	movk	w0, #0x3e2a, lsl #16
    3358:	fmov	s23, w3
    335c:	fmov	s24, w2
    3360:	fmov	s25, w1
    3364:	fmov	s26, w0
    3368:	fcvtzs	s28, s28
    336c:	scvtf	s28, s28
    3370:	fmsub	s30, s28, s22, s30
    3374:	fcvtzs	w0, s28
    3378:	fmadd	s24, s30, s23, s24
    337c:	fmadd	s25, s30, s24, s25
    3380:	add	w0, w0, #0x7f
    3384:	fmov	s28, w0
    3388:	fmadd	s26, s30, s25, s26
    338c:	fmadd	s27, s30, s26, s27
    3390:	shl	v28.2s, v28.2s, #23
    3394:	fmadd	s27, s30, s27, s29
    3398:	fmadd	s29, s30, s27, s29
    339c:	fmul	s29, s29, s28
    33a0:	fcmpe	s15, #0.0
    33a4:	fmul	s29, s8, s29
    33a8:	b.mi	3604 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    33ac:	mov	w0, #0x3389                	// #13193
    33b0:	fmov	s30, #1.000000000000000000e+00
    33b4:	mov	w4, #0x466f                	// #18031
    33b8:	movk	w0, #0x3e6d, lsl #16
    33bc:	mov	w3, #0x1eea                	// #7914
    33c0:	fmov	s27, #-5.000000000000000000e-01
    33c4:	movk	w4, #0x3faa, lsl #16
    33c8:	movk	w3, #0xbfe9, lsl #16
    33cc:	fmov	s23, w0
    33d0:	mov	w2, #0x778                 	// #1912
    33d4:	mov	w1, #0x8f89                	// #36745
    33d8:	fmov	s22, w4
    33dc:	movk	w2, #0x3fe4, lsl #16
    33e0:	movk	w1, #0xbeb6, lsl #16
    33e4:	fmov	s24, w3
    33e8:	mov	w0, #0x85fa                	// #34298
    33ec:	fmov	s25, w2
    33f0:	movk	w0, #0x3ea3, lsl #16
    33f4:	fmov	s26, w1
    33f8:	fmov	s28, w0
    33fc:	fmul	s27, s15, s27
    3400:	fmadd	s23, s15, s23, s30
    3404:	fmul	s27, s27, s15
    3408:	fcmpe	s27, s9
    340c:	fdiv	s30, s30, s23
    3410:	fmadd	s24, s30, s22, s24
    3414:	fmadd	s25, s30, s24, s25
    3418:	fmadd	s26, s30, s25, s26
    341c:	fmadd	s28, s30, s26, s28
    3420:	fmul	s30, s30, s28
    3424:	b.mi	3684 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    3428:	mov	w0, #0x42b00000            	// #1118830592
    342c:	fmov	s28, w0
    3430:	fcmpe	s27, s28
    3434:	b.gt	352c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    3438:	nop
    343c:	nop
    3440:	fmul	s28, s27, s14
    3444:	fcmpe	s28, #0.0
    3448:	b.ge	3764 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    344c:	fmov	s25, #5.000000000000000000e-01
    3450:	mov	w0, #0x7218                	// #29208
    3454:	mov	w4, #0xb61                 	// #2913
    3458:	movk	w0, #0x3f31, lsl #16
    345c:	mov	w2, #0x8889                	// #34953
    3460:	fmov	s26, #1.000000000000000000e+00
    3464:	movk	w4, #0x3ab6, lsl #16
    3468:	movk	w2, #0x3c08, lsl #16
    346c:	fmov	s19, w0
    3470:	mov	w1, #0xaaab                	// #43691
    3474:	mov	w0, #0xaaab                	// #43691
    3478:	fsub	s28, s28, s25
    347c:	movk	w1, #0x3d2a, lsl #16
    3480:	movk	w0, #0x3e2a, lsl #16
    3484:	fmov	s20, w4
    3488:	mov	w3, #0x422a                	// #16938
    348c:	fmov	s22, w2
    3490:	movk	w3, #0x3ecc, lsl #16
    3494:	fmov	s23, w1
    3498:	fmov	s24, w0
    349c:	fmov	s21, w3
    34a0:	fcvtzs	s28, s28
    34a4:	scvtf	s28, s28
    34a8:	fmsub	s27, s28, s19, s27
    34ac:	fcvtzs	w0, s28
    34b0:	fmadd	s22, s27, s20, s22
    34b4:	add	w0, w0, #0x7f
    34b8:	fmov	s28, w0
    34bc:	fmadd	s23, s27, s22, s23
    34c0:	fmadd	s24, s27, s23, s24
    34c4:	shl	v28.2s, v28.2s, #23
    34c8:	fmadd	s25, s27, s24, s25
    34cc:	fmadd	s25, s27, s25, s26
    34d0:	fmadd	s26, s27, s25, s26
    34d4:	fmul	s28, s26, s28
    34d8:	fmul	s28, s28, s21
    34dc:	fcmpe	s15, #0.0
    34e0:	fmul	s30, s30, s28
    34e4:	b.mi	3564 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    34e8:	fmov	s28, #1.000000000000000000e+00
    34ec:	fsub	s30, s28, s30
    34f0:	fmsub	s31, s29, s30, s31
    34f4:	str	s31, [x25, x26, lsl #2]
    34f8:	add	x26, x26, #0x1
    34fc:	cmp	x26, x19
    3500:	b.ne	30a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    3504:	ldp	d8, d9, [sp, #80]
    3508:	ldp	x19, x20, [sp, #16]
    350c:	ldp	x21, x22, [sp, #32]
    3510:	ldp	x23, x24, [sp, #48]
    3514:	ldp	x25, x26, [sp, #64]
    3518:	ldp	d10, d11, [sp, #96]
    351c:	ldp	d12, d13, [sp, #112]
    3520:	ldp	d14, d15, [sp, #128]
    3524:	ldp	x29, x30, [sp], #160
    3528:	ret
    352c:	mov	w0, #0x484f                	// #18511
    3530:	movk	w0, #0x7e46, lsl #16
    3534:	fmov	s28, w0
    3538:	fmul	s30, s30, s28
    353c:	fmov	s28, #1.000000000000000000e+00
    3540:	fsub	s30, s28, s30
    3544:	fmsub	s31, s29, s30, s31
    3548:	str	s31, [x25, x26, lsl #2]
    354c:	add	x26, x26, #0x1
    3550:	cmp	x26, x19
    3554:	b.ne	30a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    3558:	b	3504 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    355c:	movi	v28.2s, #0x0
    3560:	fmul	s30, s30, s28
    3564:	fmsub	s30, s29, s30, s31
    3568:	str	s30, [x25, x26, lsl #2]
    356c:	add	x26, x26, #0x1
    3570:	cmp	x19, x26
    3574:	b.ne	30a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    3578:	b	3504 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    357c:	mov	w0, #0x3389                	// #13193
    3580:	fmov	s31, #1.000000000000000000e+00
    3584:	mov	w4, #0x466f                	// #18031
    3588:	movk	w0, #0x3e6d, lsl #16
    358c:	mov	w3, #0x1eea                	// #7914
    3590:	fmul	s29, s0, s29
    3594:	movk	w4, #0x3faa, lsl #16
    3598:	movk	w3, #0xbfe9, lsl #16
    359c:	fmov	s22, w0
    35a0:	mov	w2, #0x778                 	// #1912
    35a4:	mov	w1, #0x8f89                	// #36745
    35a8:	fmov	s21, w4
    35ac:	movk	w2, #0x3fe4, lsl #16
    35b0:	movk	w1, #0xbeb6, lsl #16
    35b4:	fmov	s23, w3
    35b8:	mov	w0, #0x85fa                	// #34298
    35bc:	fmov	s24, w2
    35c0:	movk	w0, #0x3ea3, lsl #16
    35c4:	fmov	s25, w1
    35c8:	fmov	s28, w0
    35cc:	fnmul	s29, s0, s29
    35d0:	fmsub	s22, s0, s22, s31
    35d4:	fcmpe	s29, s9
    35d8:	fdiv	s31, s31, s22
    35dc:	fmadd	s23, s31, s21, s23
    35e0:	fmadd	s24, s31, s23, s24
    35e4:	fmadd	s25, s31, s24, s25
    35e8:	fmadd	s28, s31, s25, s28
    35ec:	fmul	s31, s31, s28
    35f0:	b.mi	35f8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    35f4:	b	322c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    35f8:	movi	v29.2s, #0x0
    35fc:	fmul	s31, s31, s29
    3600:	b	32f0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    3604:	mov	w0, #0x3389                	// #13193
    3608:	fmov	s30, #1.000000000000000000e+00
    360c:	mov	w4, #0x466f                	// #18031
    3610:	movk	w0, #0x3e6d, lsl #16
    3614:	mov	w3, #0x1eea                	// #7914
    3618:	fmov	s27, #5.000000000000000000e-01
    361c:	movk	w4, #0x3faa, lsl #16
    3620:	movk	w3, #0xbfe9, lsl #16
    3624:	fmov	s23, w0
    3628:	mov	w2, #0x778                 	// #1912
    362c:	mov	w1, #0x8f89                	// #36745
    3630:	fmov	s22, w4
    3634:	movk	w2, #0x3fe4, lsl #16
    3638:	movk	w1, #0xbeb6, lsl #16
    363c:	fmov	s24, w3
    3640:	mov	w0, #0x85fa                	// #34298
    3644:	fmov	s25, w2
    3648:	movk	w0, #0x3ea3, lsl #16
    364c:	fmov	s26, w1
    3650:	fmov	s28, w0
    3654:	fmul	s27, s15, s27
    3658:	fmsub	s23, s15, s23, s30
    365c:	fnmul	s27, s15, s27
    3660:	fcmpe	s27, s9
    3664:	fdiv	s30, s30, s23
    3668:	fmadd	s24, s30, s22, s24
    366c:	fmadd	s25, s24, s30, s25
    3670:	fmadd	s26, s25, s30, s26
    3674:	fmadd	s28, s30, s26, s28
    3678:	fmul	s30, s30, s28
    367c:	b.mi	355c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    3680:	b	3440 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    3684:	movi	v28.2s, #0x0
    3688:	b	3538 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    368c:	movi	v29.2s, #0x0
    3690:	fmul	s31, s31, s29
    3694:	b	32e8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    3698:	mov	w7, #0x829c                	// #33436
    369c:	movk	w7, #0x7ef8, lsl #16
    36a0:	fmov	s29, w7
    36a4:	b	33a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    36a8:	fmov	s27, #5.000000000000000000e-01
    36ac:	ldr	s24, [sp, #148]
    36b0:	mov	w0, #0xaaab                	// #43691
    36b4:	movk	w0, #0x3e2a, lsl #16
    36b8:	mov	w1, #0xaaab                	// #43691
    36bc:	fmov	s29, #1.000000000000000000e+00
    36c0:	movk	w1, #0x3d2a, lsl #16
    36c4:	fmov	s26, w0
    36c8:	fadd	s28, s28, s27
    36cc:	fmov	s25, w1
    36d0:	fcvtzs	s28, s28
    36d4:	scvtf	s28, s28
    36d8:	fmsub	s30, s28, s24, s30
    36dc:	fcvtzs	w0, s28
    36e0:	ldp	s24, s28, [sp, #152]
    36e4:	fmadd	s24, s30, s24, s28
    36e8:	b	337c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    36ec:	fmov	s24, #5.000000000000000000e-01
    36f0:	ldr	s30, [sp, #148]
    36f4:	mov	w1, #0xaaab                	// #43691
    36f8:	movk	w1, #0x3d2a, lsl #16
    36fc:	mov	w0, #0xaaab                	// #43691
    3700:	fmov	s25, #1.000000000000000000e+00
    3704:	movk	w0, #0x3e2a, lsl #16
    3708:	mov	w2, #0x422a                	// #16938
    370c:	fmov	s22, w1
    3710:	movk	w2, #0x3ecc, lsl #16
    3714:	fadd	s28, s28, s24
    3718:	fmov	s23, w0
    371c:	fmov	s21, w2
    3720:	fcvtzs	s28, s28
    3724:	scvtf	s28, s28
    3728:	fmsub	s29, s28, s30, s29
    372c:	fcvtzs	w7, s28
    3730:	ldp	s28, s30, [sp, #152]
    3734:	fmadd	s20, s29, s28, s30
    3738:	add	w7, w7, #0x7f
    373c:	fmov	s30, w7
    3740:	fmadd	s22, s29, s20, s22
    3744:	fmadd	s23, s29, s22, s23
    3748:	shl	v28.2s, v30.2s, #23
    374c:	fmadd	s24, s29, s23, s24
    3750:	fmadd	s24, s29, s24, s25
    3754:	fmadd	s29, s29, s24, s25
    3758:	fmul	s29, s29, s28
    375c:	fmul	s29, s29, s21
    3760:	b	32c8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    3764:	fmov	s25, #5.000000000000000000e-01
    3768:	ldr	s21, [sp, #148]
    376c:	mov	w0, #0xaaab                	// #43691
    3770:	movk	w0, #0x3e2a, lsl #16
    3774:	mov	w1, #0xaaab                	// #43691
    3778:	fmov	s26, #1.000000000000000000e+00
    377c:	movk	w1, #0x3d2a, lsl #16
    3780:	mov	w2, #0x422a                	// #16938
    3784:	fmov	s24, w0
    3788:	movk	w2, #0x3ecc, lsl #16
    378c:	fadd	s28, s28, s25
    3790:	fmov	s23, w1
    3794:	fmov	s22, w2
    3798:	fcvtzs	s28, s28
    379c:	scvtf	s28, s28
    37a0:	fmsub	s27, s28, s21, s27
    37a4:	fcvtzs	w0, s28
    37a8:	ldp	s21, s28, [sp, #152]
    37ac:	fmadd	s21, s27, s21, s28
    37b0:	add	w0, w0, #0x7f
    37b4:	fmov	s28, w0
    37b8:	fmadd	s23, s27, s21, s23
    37bc:	fmadd	s24, s27, s23, s24
    37c0:	shl	v28.2s, v28.2s, #23
    37c4:	fmadd	s25, s27, s24, s25
    37c8:	fmadd	s25, s27, s25, s26
    37cc:	fmadd	s26, s27, s25, s26
    37d0:	fmul	s28, s26, s28
    37d4:	fmul	s28, s28, s22
    37d8:	b	34dc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    37dc:	ret
