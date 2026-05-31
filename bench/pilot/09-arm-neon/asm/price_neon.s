0000000000002f20 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    2f20:	stp	x29, x30, [sp, #-160]!
    2f24:	mov	x29, sp
    2f28:	stp	x19, x20, [sp, #16]
    2f2c:	mov	x20, x0
    2f30:	stp	x21, x22, [sp, #32]
    2f34:	mov	x21, x1
    2f38:	mov	x22, x2
    2f3c:	stp	x23, x24, [sp, #48]
    2f40:	mov	x24, x6
    2f44:	mov	x23, x3
    2f48:	stp	x25, x26, [sp, #64]
    2f4c:	mov	x25, x4
    2f50:	mov	x26, x5
    2f54:	stp	d8, d9, [sp, #80]
    2f58:	stp	d10, d11, [sp, #96]
    2f5c:	stp	d12, d13, [sp, #112]
    2f60:	stp	d14, d15, [sp, #128]
    2f64:	cmp	x6, #0x3
    2f68:	b.ls	3a4c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xb2c>  // b.plast
    2f6c:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2f70:	sub	x19, x6, #0x4
    2f74:	and	x0, x19, #0xfffffffffffffffc
    2f78:	mov	x7, #0x0                   	// #0
    2f7c:	ldr	q20, [x1, #3712]
    2f80:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2f84:	mov	x8, #0x0                   	// #0
    2f88:	add	x0, x0, #0x4
    2f8c:	ldr	q1, [x1, #3728]
    2f90:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2f94:	ldr	q11, [x1, #3744]
    2f98:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2f9c:	ldr	q12, [x1, #3760]
    2fa0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fa4:	ldr	q13, [x1, #3776]
    2fa8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fac:	ldr	q14, [x1, #3792]
    2fb0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fb4:	ldr	q15, [x1, #3808]
    2fb8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fbc:	ldr	q4, [x1, #3824]
    2fc0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fc4:	ldr	q5, [x1, #3840]
    2fc8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fcc:	ldr	q6, [x1, #3856]
    2fd0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fd4:	ldr	q7, [x1, #3872]
    2fd8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fdc:	ldr	q16, [x1, #3888]
    2fe0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fe4:	ldr	q17, [x1, #3904]
    2fe8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fec:	ldr	q18, [x1, #3920]
    2ff0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2ff4:	movi	v26.4s, #0x7f, msl #16
    2ff8:	fmov	v25.4s, #5.000000000000000000e-01
    2ffc:	ldr	q9, [x21, x7]
    3000:	movi	v23.4s, #0x7f
    3004:	fmov	v31.4s, #-1.000000000000000000e+00
    3008:	fmov	v29.4s, #1.000000000000000000e+00
    300c:	fmov	v10.4s, #-5.000000000000000000e-01
    3010:	add	x8, x8, #0x4
    3014:	ldr	q30, [x20, x7]
    3018:	mov	v0.16b, v25.16b
    301c:	ldr	q19, [x1, #3936]
    3020:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    3024:	ldr	q24, [x1, #3952]
    3028:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    302c:	fdiv	v27.4s, v30.4s, v9.4s
    3030:	ldr	q21, [x22, x7]
    3034:	ldr	q22, [x23, x7]
    3038:	and	v26.16b, v26.16b, v27.16b
    303c:	sshr	v27.4s, v27.4s, #23
    3040:	ldr	q30, [x25, x7]
    3044:	orr	v26.16b, v26.16b, v24.16b
    3048:	ldr	q24, [x1, #3968]
    304c:	sub	v27.4s, v27.4s, v23.4s
    3050:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    3054:	fmul	v28.4s, v21.4s, v22.4s
    3058:	fmul	v3.4s, v30.4s, v30.4s
    305c:	fcmge	v8.4s, v26.4s, v24.4s
    3060:	fmul	v24.4s, v25.4s, v26.4s
    3064:	fneg	v28.4s, v28.4s
    3068:	fmla	v22.4s, v25.4s, v3.4s
    306c:	bit	v26.16b, v24.16b, v8.16b
    3070:	sub	v27.4s, v27.4s, v8.4s
    3074:	ldr	q8, [x1, #3984]
    3078:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    307c:	fmax	v28.4s, v28.4s, v4.4s
    3080:	ldr	q24, [x1, #4000]
    3084:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    3088:	fadd	v31.4s, v31.4s, v26.4s
    308c:	fsqrt	v26.4s, v21.4s
    3090:	scvtf	v27.4s, v27.4s
    3094:	fmin	v28.4s, v28.4s, v5.4s
    3098:	fmul	v30.4s, v30.4s, v26.4s
    309c:	fmla	v8.4s, v24.4s, v31.4s
    30a0:	ldr	q24, [x1, #4016]
    30a4:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    30a8:	fmul	v26.4s, v28.4s, v6.4s
    30ac:	fmla	v24.4s, v8.4s, v31.4s
    30b0:	ldr	q8, [x1, #4032]
    30b4:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    30b8:	frintn	v26.4s, v26.4s
    30bc:	fmla	v8.4s, v24.4s, v31.4s
    30c0:	ldr	q24, [x1, #4048]
    30c4:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    30c8:	ldr	q3, [x1, #4064]
    30cc:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    30d0:	fmls	v28.4s, v26.4s, v20.4s
    30d4:	fmla	v24.4s, v8.4s, v31.4s
    30d8:	mov	v8.16b, v16.16b
    30dc:	fcvtzs	v26.4s, v26.4s
    30e0:	fmla	v3.4s, v24.4s, v31.4s
    30e4:	ldr	q24, [x1, #4080]
    30e8:	adrp	x1, 4000 <_IO_stdin_used+0x360>
    30ec:	fmla	v8.4s, v7.4s, v28.4s
    30f0:	add	v26.4s, v26.4s, v23.4s
    30f4:	fmla	v24.4s, v3.4s, v31.4s
    30f8:	mov	v3.16b, v17.16b
    30fc:	shl	v26.4s, v26.4s, #23
    3100:	fmla	v3.4s, v8.4s, v28.4s
    3104:	ldr	q8, [x1]
    3108:	adrp	x1, 4000 <_IO_stdin_used+0x360>
    310c:	ldr	q2, [x1, #16]
    3110:	fmla	v8.4s, v24.4s, v31.4s
    3114:	mov	v24.16b, v18.16b
    3118:	fmla	v2.4s, v8.4s, v31.4s
    311c:	fmla	v24.4s, v3.4s, v28.4s
    3120:	mov	v3.16b, v29.16b
    3124:	fmul	v8.4s, v31.4s, v31.4s
    3128:	fmla	v0.4s, v24.4s, v28.4s
    312c:	fmul	v24.4s, v31.4s, v8.4s
    3130:	fmla	v3.4s, v0.4s, v28.4s
    3134:	fmul	v24.4s, v24.4s, v2.4s
    3138:	mov	v2.16b, v29.16b
    313c:	fmls	v24.4s, v8.4s, v25.4s
    3140:	mov	v8.16b, v12.16b
    3144:	fmla	v2.4s, v3.4s, v28.4s
    3148:	mov	v3.16b, v16.16b
    314c:	fadd	v31.4s, v31.4s, v24.4s
    3150:	fmul	v26.4s, v2.4s, v26.4s
    3154:	mov	v2.16b, v18.16b
    3158:	fmla	v31.4s, v27.4s, v20.4s
    315c:	fmul	v26.4s, v26.4s, v9.4s
    3160:	mov	v9.16b, v13.16b
    3164:	fmla	v31.4s, v22.4s, v21.4s
    3168:	mov	v21.16b, v29.16b
    316c:	fdiv	v31.4s, v31.4s, v30.4s
    3170:	fsub	v30.4s, v31.4s, v30.4s
    3174:	fmul	v27.4s, v31.4s, v31.4s
    3178:	fabs	v24.4s, v31.4s
    317c:	fcmlt	v31.4s, v31.4s, #0.0
    3180:	fmul	v28.4s, v30.4s, v30.4s
    3184:	fmul	v27.4s, v27.4s, v10.4s
    3188:	fmla	v21.4s, v1.4s, v24.4s
    318c:	fabs	v22.4s, v30.4s
    3190:	mov	v24.16b, v29.16b
    3194:	fmul	v28.4s, v28.4s, v10.4s
    3198:	fmax	v27.4s, v27.4s, v4.4s
    319c:	fcmlt	v30.4s, v30.4s, #0.0
    31a0:	fmla	v24.4s, v1.4s, v22.4s
    31a4:	fmax	v28.4s, v28.4s, v4.4s
    31a8:	fmin	v27.4s, v27.4s, v5.4s
    31ac:	fdiv	v21.4s, v29.4s, v21.4s
    31b0:	fmin	v28.4s, v28.4s, v5.4s
    31b4:	fmul	v22.4s, v27.4s, v6.4s
    31b8:	fmla	v8.4s, v11.4s, v21.4s
    31bc:	fdiv	v24.4s, v29.4s, v24.4s
    31c0:	fmul	v10.4s, v28.4s, v6.4s
    31c4:	frintn	v22.4s, v22.4s
    31c8:	fmla	v9.4s, v8.4s, v21.4s
    31cc:	mov	v8.16b, v14.16b
    31d0:	frintn	v10.4s, v10.4s
    31d4:	fmls	v27.4s, v22.4s, v20.4s
    31d8:	fmla	v8.4s, v9.4s, v21.4s
    31dc:	mov	v9.16b, v15.16b
    31e0:	fmls	v28.4s, v10.4s, v20.4s
    31e4:	fcvtzs	v22.4s, v22.4s
    31e8:	fcvtzs	v10.4s, v10.4s
    31ec:	fmla	v3.4s, v7.4s, v27.4s
    31f0:	fmla	v9.4s, v8.4s, v21.4s
    31f4:	mov	v8.16b, v17.16b
    31f8:	add	v22.4s, v22.4s, v23.4s
    31fc:	add	v10.4s, v10.4s, v23.4s
    3200:	mov	v23.16b, v16.16b
    3204:	fmla	v8.4s, v3.4s, v27.4s
    3208:	mov	v3.16b, v18.16b
    320c:	fmla	v23.4s, v7.4s, v28.4s
    3210:	shl	v22.4s, v22.4s, #23
    3214:	fmla	v3.4s, v8.4s, v27.4s
    3218:	mov	v8.16b, v17.16b
    321c:	shl	v10.4s, v10.4s, #23
    3220:	fmul	v21.4s, v21.4s, v9.4s
    3224:	fmla	v8.4s, v23.4s, v28.4s
    3228:	mov	v23.16b, v25.16b
    322c:	fmla	v23.4s, v3.4s, v27.4s
    3230:	mov	v3.16b, v29.16b
    3234:	fmla	v2.4s, v8.4s, v28.4s
    3238:	mov	v8.16b, v12.16b
    323c:	fmla	v3.4s, v23.4s, v27.4s
    3240:	mov	v23.16b, v29.16b
    3244:	fmla	v25.4s, v2.4s, v28.4s
    3248:	fmla	v23.4s, v3.4s, v27.4s
    324c:	mov	v3.16b, v29.16b
    3250:	mov	v27.16b, v29.16b
    3254:	fmla	v8.4s, v11.4s, v24.4s
    3258:	fmla	v3.4s, v25.4s, v28.4s
    325c:	mov	v25.16b, v13.16b
    3260:	fmla	v25.4s, v8.4s, v24.4s
    3264:	fmla	v27.4s, v3.4s, v28.4s
    3268:	mov	v28.16b, v14.16b
    326c:	fmla	v28.4s, v25.4s, v24.4s
    3270:	fmul	v25.4s, v23.4s, v22.4s
    3274:	mov	v23.16b, v15.16b
    3278:	fmla	v23.4s, v28.4s, v24.4s
    327c:	fmul	v25.4s, v25.4s, v19.4s
    3280:	fmul	v28.4s, v27.4s, v10.4s
    3284:	fmul	v27.4s, v25.4s, v21.4s
    3288:	fmul	v28.4s, v28.4s, v19.4s
    328c:	fmul	v24.4s, v24.4s, v23.4s
    3290:	fsub	v25.4s, v29.4s, v27.4s
    3294:	fmul	v24.4s, v28.4s, v24.4s
    3298:	ldr	q28, [x20, x7]
    329c:	bsl	v31.16b, v27.16b, v25.16b
    32a0:	fsub	v29.4s, v29.4s, v24.4s
    32a4:	fmul	v31.4s, v28.4s, v31.4s
    32a8:	bsl	v30.16b, v24.16b, v29.16b
    32ac:	fmls	v31.4s, v26.4s, v30.4s
    32b0:	str	q31, [x26, x7]
    32b4:	add	x7, x7, #0x10
    32b8:	cmp	x8, x0
    32bc:	b.ne	2ff0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xd0>  // b.any
    32c0:	and	x19, x19, #0xfffffffffffffffc
    32c4:	add	x19, x19, #0x4
    32c8:	cmp	x24, x19
    32cc:	b.ls	3744 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>  // b.plast
    32d0:	mov	w4, #0x3389                	// #13193
    32d4:	mov	w3, #0x466f                	// #18031
    32d8:	mov	w2, #0x1eea                	// #7914
    32dc:	mov	w1, #0x778                 	// #1912
    32e0:	movk	w4, #0x3e6d, lsl #16
    32e4:	movk	w3, #0x3faa, lsl #16
    32e8:	movk	w2, #0xbfe9, lsl #16
    32ec:	movk	w1, #0x3fe4, lsl #16
    32f0:	mov	w0, #0xc2b00000            	// #-1028653056
    32f4:	fmov	s10, w4
    32f8:	fmov	s11, w3
    32fc:	fmov	s12, w2
    3300:	fmov	s13, w1
    3304:	fmov	s14, w0
    3308:	ldr	s28, [x22, x19, lsl #2]
    330c:	ldr	s15, [x25, x19, lsl #2]
    3310:	ldr	s26, [x20, x19, lsl #2]
    3314:	fcmp	s28, #0.0
    3318:	ldr	s8, [x21, x19, lsl #2]
    331c:	ldr	s25, [x23, x19, lsl #2]
    3320:	fmul	s9, s15, s15
    3324:	b.pl	347c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.nfrst
    3328:	fmov	s0, s28
    332c:	stp	s26, s28, [sp, #148]
    3330:	str	s25, [sp, #156]
    3334:	bl	ec0 <sqrtf@plt>
    3338:	ldr	s26, [sp, #148]
    333c:	fmul	s15, s15, s0
    3340:	fdiv	s0, s26, s8
    3344:	bl	1020 <logf@plt>
    3348:	ldr	s25, [sp, #156]
    334c:	fmov	s31, #5.000000000000000000e-01
    3350:	mov	w0, #0x3389                	// #13193
    3354:	movk	w0, #0x3e6d, lsl #16
    3358:	fmov	s27, #1.000000000000000000e+00
    335c:	mov	w1, #0x466f                	// #18031
    3360:	ldp	s26, s28, [sp, #148]
    3364:	mov	w3, #0x1eea                	// #7914
    3368:	movk	w1, #0x3faa, lsl #16
    336c:	fmov	s30, w0
    3370:	movk	w3, #0xbfe9, lsl #16
    3374:	mov	w2, #0x778                 	// #1912
    3378:	fmov	s20, w1
    337c:	movk	w2, #0x3fe4, lsl #16
    3380:	mov	w1, #0x8f89                	// #36745
    3384:	fmov	s22, w3
    3388:	movk	w1, #0xbeb6, lsl #16
    338c:	mov	w0, #0x85fa                	// #34298
    3390:	fmadd	s9, s9, s31, s25
    3394:	movk	w0, #0x3ea3, lsl #16
    3398:	mov	w7, #0xaa3b                	// #43579
    339c:	fmov	s23, w2
    33a0:	fmov	s19, #-5.000000000000000000e-01
    33a4:	movk	w7, #0x3fb8, lsl #16
    33a8:	fmov	s24, w1
    33ac:	fmov	s31, w0
    33b0:	fmadd	s0, s28, s9, s0
    33b4:	fmov	s29, w7
    33b8:	fdiv	s0, s0, s15
    33bc:	fmadd	s21, s0, s30, s27
    33c0:	fmul	s30, s0, s19
    33c4:	fsub	s15, s0, s15
    33c8:	fmul	s30, s30, s0
    33cc:	fdiv	s27, s27, s21
    33d0:	fmul	s29, s30, s29
    33d4:	fmadd	s22, s27, s20, s22
    33d8:	fmadd	s23, s22, s27, s23
    33dc:	fmadd	s24, s23, s27, s24
    33e0:	fmadd	s31, s24, s27, s31
    33e4:	fmul	s31, s31, s27
    33e8:	fmov	s24, #5.000000000000000000e-01
    33ec:	mov	w0, #0x7218                	// #29208
    33f0:	mov	w3, #0xb61                 	// #2913
    33f4:	movk	w0, #0x3f31, lsl #16
    33f8:	mov	w2, #0x8889                	// #34953
    33fc:	fmov	s27, #1.000000000000000000e+00
    3400:	movk	w3, #0x3ab6, lsl #16
    3404:	movk	w2, #0x3c08, lsl #16
    3408:	fmov	s18, w0
    340c:	mov	w1, #0xaaab                	// #43691
    3410:	mov	w0, #0xaaab                	// #43691
    3414:	fsub	s29, s29, s24
    3418:	movk	w1, #0x3d2a, lsl #16
    341c:	movk	w0, #0x3e2a, lsl #16
    3420:	fmov	s21, w2
    3424:	mov	w4, #0x422a                	// #16938
    3428:	fmov	s19, w3
    342c:	movk	w4, #0x3ecc, lsl #16
    3430:	fmov	s22, w1
    3434:	fmov	s23, w0
    3438:	fmov	s20, w4
    343c:	fcvtzs	s29, s29
    3440:	scvtf	s29, s29
    3444:	fmsub	s30, s29, s18, s30
    3448:	fcvtzs	w7, s29
    344c:	fmadd	s29, s30, s19, s21
    3450:	add	w7, w7, #0x7f
    3454:	fmov	s21, w7
    3458:	fmadd	s29, s30, s29, s22
    345c:	fmadd	s29, s30, s29, s23
    3460:	shl	v21.2s, v21.2s, #23
    3464:	fmadd	s24, s30, s29, s24
    3468:	fmadd	s24, s30, s24, s27
    346c:	fmadd	s30, s30, s24, s27
    3470:	fmul	s30, s30, s21
    3474:	fmul	s30, s30, s20
    3478:	b	39b8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa98>
    347c:	fsqrt	s29, s28
    3480:	stp	s26, s28, [sp, #148]
    3484:	str	s25, [sp, #156]
    3488:	fdiv	s0, s26, s8
    348c:	fmul	s15, s15, s29
    3490:	bl	1020 <logf@plt>
    3494:	ldr	s25, [sp, #156]
    3498:	fmov	s30, #5.000000000000000000e-01
    349c:	ldp	s26, s28, [sp, #148]
    34a0:	fmadd	s9, s9, s30, s25
    34a4:	fmadd	s0, s28, s9, s0
    34a8:	fdiv	s0, s0, s15
    34ac:	fcmpe	s0, #0.0
    34b0:	fsub	s15, s0, s15
    34b4:	b.mi	37f4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8d4>  // b.first
    34b8:	fmov	s31, #1.000000000000000000e+00
    34bc:	mov	w1, #0x8f89                	// #36745
    34c0:	mov	w0, #0x85fa                	// #34298
    34c4:	movk	w1, #0xbeb6, lsl #16
    34c8:	movk	w0, #0x3ea3, lsl #16
    34cc:	fmov	s30, #-5.000000000000000000e-01
    34d0:	fmov	s27, w1
    34d4:	fmadd	s24, s0, s10, s31
    34d8:	fmov	s29, w0
    34dc:	fmul	s30, s0, s30
    34e0:	fmul	s30, s30, s0
    34e4:	fdiv	s31, s31, s24
    34e8:	fcmpe	s30, s14
    34ec:	fmadd	s24, s31, s11, s12
    34f0:	fmadd	s24, s31, s24, s13
    34f4:	fmadd	s27, s31, s24, s27
    34f8:	fmadd	s29, s31, s27, s29
    34fc:	fmul	s31, s31, s29
    3500:	b.mi	3864 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x944>  // b.first
    3504:	mov	w0, #0x42b00000            	// #1118830592
    3508:	fmov	s29, w0
    350c:	fcmpe	s30, s29
    3510:	b.gt	3530 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x610>
    3514:	mov	w7, #0xaa3b                	// #43579
    3518:	movk	w7, #0x3fb8, lsl #16
    351c:	fmov	s29, w7
    3520:	fmul	s29, s30, s29
    3524:	fcmpe	s29, #0.0
    3528:	b.ge	3928 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    352c:	b	33e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    3530:	mov	w0, #0x484f                	// #18511
    3534:	movk	w0, #0x7e46, lsl #16
    3538:	fmov	s30, w0
    353c:	fmul	s31, s31, s30
    3540:	fmov	s30, #1.000000000000000000e+00
    3544:	fsub	s31, s30, s31
    3548:	fnmul	s29, s25, s28
    354c:	fmul	s31, s26, s31
    3550:	movi	v30.2s, #0x0
    3554:	fcmpe	s29, s14
    3558:	b.mi	3604 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>  // b.first
    355c:	mov	w0, #0x42b00000            	// #1118830592
    3560:	fmov	s30, w0
    3564:	fcmpe	s29, s30
    3568:	b.gt	3878 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x958>
    356c:	mov	w7, #0xaa3b                	// #43579
    3570:	movk	w7, #0x3fb8, lsl #16
    3574:	fmov	s28, w7
    3578:	fmul	s28, s29, s28
    357c:	fcmpe	s28, #0.0
    3580:	b.ge	39c8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xaa8>  // b.tcont
    3584:	fmov	s27, #5.000000000000000000e-01
    3588:	mov	w0, #0x7218                	// #29208
    358c:	mov	w3, #0xb61                 	// #2913
    3590:	movk	w0, #0x3f31, lsl #16
    3594:	mov	w2, #0x8889                	// #34953
    3598:	fmov	s30, #1.000000000000000000e+00
    359c:	movk	w3, #0x3ab6, lsl #16
    35a0:	movk	w2, #0x3c08, lsl #16
    35a4:	fmov	s22, w0
    35a8:	mov	w1, #0xaaab                	// #43691
    35ac:	mov	w0, #0xaaab                	// #43691
    35b0:	fsub	s28, s28, s27
    35b4:	movk	w1, #0x3d2a, lsl #16
    35b8:	movk	w0, #0x3e2a, lsl #16
    35bc:	fmov	s24, w2
    35c0:	fmov	s23, w3
    35c4:	fmov	s25, w1
    35c8:	fmov	s26, w0
    35cc:	fcvtzs	s28, s28
    35d0:	scvtf	s28, s28
    35d4:	fmsub	s29, s28, s22, s29
    35d8:	fcvtzs	w7, s28
    35dc:	fmadd	s28, s29, s23, s24
    35e0:	add	w7, w7, #0x7f
    35e4:	fmov	s24, w7
    35e8:	fmadd	s28, s29, s28, s25
    35ec:	fmadd	s28, s29, s28, s26
    35f0:	shl	v24.2s, v24.2s, #23
    35f4:	fmadd	s27, s29, s28, s27
    35f8:	fmadd	s27, s29, s27, s30
    35fc:	fmadd	s30, s29, s27, s30
    3600:	fmul	s30, s30, s24
    3604:	fcmpe	s15, #0.0
    3608:	fmul	s26, s8, s30
    360c:	b.mi	376c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x84c>  // b.first
    3610:	fmov	s30, #1.000000000000000000e+00
    3614:	mov	w1, #0x8f89                	// #36745
    3618:	mov	w0, #0x85fa                	// #34298
    361c:	movk	w1, #0xbeb6, lsl #16
    3620:	movk	w0, #0x3ea3, lsl #16
    3624:	fmov	s28, #-5.000000000000000000e-01
    3628:	fmov	s27, w1
    362c:	fmadd	s25, s15, s10, s30
    3630:	fmov	s29, w0
    3634:	fmul	s28, s15, s28
    3638:	fmul	s28, s28, s15
    363c:	fdiv	s30, s30, s25
    3640:	fcmpe	s28, s14
    3644:	fmadd	s25, s30, s11, s12
    3648:	fmadd	s25, s30, s25, s13
    364c:	fmadd	s27, s30, s25, s27
    3650:	fmadd	s29, s30, s27, s29
    3654:	fmul	s30, s30, s29
    3658:	b.mi	3870 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x950>  // b.first
    365c:	mov	w0, #0x42b00000            	// #1118830592
    3660:	fmov	s29, w0
    3664:	fcmpe	s28, s29
    3668:	b.gt	3718 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7f8>
    366c:	mov	w7, #0xaa3b                	// #43579
    3670:	movk	w7, #0x3fb8, lsl #16
    3674:	fmov	s29, w7
    3678:	fmul	s29, s28, s29
    367c:	fcmpe	s29, #0.0
    3680:	b.ge	3888 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    3684:	fmov	s25, #5.000000000000000000e-01
    3688:	mov	w0, #0x7218                	// #29208
    368c:	mov	w4, #0xb61                 	// #2913
    3690:	movk	w0, #0x3f31, lsl #16
    3694:	mov	w2, #0x8889                	// #34953
    3698:	fmov	s27, #1.000000000000000000e+00
    369c:	movk	w4, #0x3ab6, lsl #16
    36a0:	movk	w2, #0x3c08, lsl #16
    36a4:	fmov	s19, w0
    36a8:	mov	w1, #0xaaab                	// #43691
    36ac:	mov	w0, #0xaaab                	// #43691
    36b0:	fsub	s29, s29, s25
    36b4:	movk	w1, #0x3d2a, lsl #16
    36b8:	movk	w0, #0x3e2a, lsl #16
    36bc:	fmov	s22, w2
    36c0:	mov	w3, #0x422a                	// #16938
    36c4:	fmov	s20, w4
    36c8:	movk	w3, #0x3ecc, lsl #16
    36cc:	fmov	s23, w1
    36d0:	fmov	s24, w0
    36d4:	fmov	s21, w3
    36d8:	fcvtzs	s29, s29
    36dc:	scvtf	s29, s29
    36e0:	fmsub	s28, s29, s19, s28
    36e4:	fcvtzs	w7, s29
    36e8:	fmadd	s29, s28, s20, s22
    36ec:	add	w7, w7, #0x7f
    36f0:	fmov	s22, w7
    36f4:	fmadd	s29, s28, s29, s23
    36f8:	fmadd	s29, s28, s29, s24
    36fc:	shl	v22.2s, v22.2s, #23
    3700:	fmadd	s25, s28, s29, s25
    3704:	fmadd	s25, s28, s25, s27
    3708:	fmadd	s29, s28, s25, s27
    370c:	fmul	s29, s29, s22
    3710:	fmul	s29, s29, s21
    3714:	b	3918 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x9f8>
    3718:	mov	w0, #0x484f                	// #18511
    371c:	movk	w0, #0x7e46, lsl #16
    3720:	fmov	s29, w0
    3724:	fmul	s30, s30, s29
    3728:	fmov	s29, #1.000000000000000000e+00
    372c:	fsub	s29, s29, s30
    3730:	fmsub	s31, s26, s29, s31
    3734:	str	s31, [x26, x19, lsl #2]
    3738:	add	x19, x19, #0x1
    373c:	cmp	x19, x24
    3740:	b.ne	3308 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    3744:	ldp	d8, d9, [sp, #80]
    3748:	ldp	x19, x20, [sp, #16]
    374c:	ldp	x21, x22, [sp, #32]
    3750:	ldp	x23, x24, [sp, #48]
    3754:	ldp	x25, x26, [sp, #64]
    3758:	ldp	d10, d11, [sp, #96]
    375c:	ldp	d12, d13, [sp, #112]
    3760:	ldp	d14, d15, [sp, #128]
    3764:	ldp	x29, x30, [sp], #160
    3768:	ret
    376c:	fmov	s29, #1.000000000000000000e+00
    3770:	mov	w1, #0x8f89                	// #36745
    3774:	mov	w0, #0x85fa                	// #34298
    3778:	movk	w1, #0xbeb6, lsl #16
    377c:	movk	w0, #0x3ea3, lsl #16
    3780:	fmov	s28, #5.000000000000000000e-01
    3784:	fmov	s27, w1
    3788:	fmsub	s25, s15, s10, s29
    378c:	fmov	s30, w0
    3790:	fmul	s28, s15, s28
    3794:	fnmul	s28, s15, s28
    3798:	fdiv	s29, s29, s25
    379c:	fcmpe	s28, s14
    37a0:	fmadd	s25, s29, s11, s12
    37a4:	fmadd	s25, s29, s25, s13
    37a8:	fmadd	s27, s29, s25, s27
    37ac:	fmadd	s30, s29, s27, s30
    37b0:	fmul	s30, s29, s30
    37b4:	b.mi	37d4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8b4>  // b.first
    37b8:	mov	w7, #0xaa3b                	// #43579
    37bc:	movk	w7, #0x3fb8, lsl #16
    37c0:	fmov	s29, w7
    37c4:	fmul	s29, s28, s29
    37c8:	fcmpe	s29, #0.0
    37cc:	b.ge	3888 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    37d0:	b	3684 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x764>
    37d4:	movi	v29.2s, #0x0
    37d8:	fmul	s30, s30, s29
    37dc:	fmsub	s30, s26, s30, s31
    37e0:	str	s30, [x26, x19, lsl #2]
    37e4:	add	x19, x19, #0x1
    37e8:	cmp	x24, x19
    37ec:	b.ne	3308 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    37f0:	b	3744 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>
    37f4:	fmov	s31, #1.000000000000000000e+00
    37f8:	mov	w1, #0x8f89                	// #36745
    37fc:	mov	w0, #0x85fa                	// #34298
    3800:	movk	w1, #0xbeb6, lsl #16
    3804:	movk	w0, #0x3ea3, lsl #16
    3808:	fmul	s30, s0, s30
    380c:	fmov	s27, w1
    3810:	fmsub	s24, s0, s10, s31
    3814:	fmov	s29, w0
    3818:	fnmul	s30, s0, s30
    381c:	fcmpe	s30, s14
    3820:	fdiv	s31, s31, s24
    3824:	fmadd	s24, s31, s11, s12
    3828:	fmadd	s24, s31, s24, s13
    382c:	fmadd	s27, s31, s24, s27
    3830:	fmadd	s29, s31, s27, s29
    3834:	fmul	s31, s31, s29
    3838:	b.mi	3858 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x938>  // b.first
    383c:	mov	w7, #0xaa3b                	// #43579
    3840:	movk	w7, #0x3fb8, lsl #16
    3844:	fmov	s29, w7
    3848:	fmul	s29, s30, s29
    384c:	fcmpe	s29, #0.0
    3850:	b.ge	3928 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    3854:	b	33e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    3858:	movi	v30.2s, #0x0
    385c:	fmul	s31, s31, s30
    3860:	b	3548 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>
    3864:	movi	v30.2s, #0x0
    3868:	fmul	s31, s31, s30
    386c:	b	3540 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    3870:	movi	v29.2s, #0x0
    3874:	b	3724 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x804>
    3878:	mov	w7, #0x829c                	// #33436
    387c:	movk	w7, #0x7ef8, lsl #16
    3880:	fmov	s30, w7
    3884:	b	3604 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    3888:	fmov	s24, #5.000000000000000000e-01
    388c:	mov	w0, #0x7218                	// #29208
    3890:	mov	w4, #0xb61                 	// #2913
    3894:	movk	w0, #0x3f31, lsl #16
    3898:	mov	w2, #0x8889                	// #34953
    389c:	fmov	s27, #1.000000000000000000e+00
    38a0:	movk	w4, #0x3ab6, lsl #16
    38a4:	movk	w2, #0x3c08, lsl #16
    38a8:	fmov	s25, w0
    38ac:	mov	w1, #0xaaab                	// #43691
    38b0:	mov	w0, #0xaaab                	// #43691
    38b4:	fadd	s29, s29, s24
    38b8:	movk	w1, #0x3d2a, lsl #16
    38bc:	movk	w0, #0x3e2a, lsl #16
    38c0:	fmov	s19, w4
    38c4:	mov	w3, #0x422a                	// #16938
    38c8:	fmov	s21, w2
    38cc:	movk	w3, #0x3ecc, lsl #16
    38d0:	fmov	s22, w1
    38d4:	fmov	s23, w0
    38d8:	fmov	s20, w3
    38dc:	fcvtzs	s29, s29
    38e0:	scvtf	s29, s29
    38e4:	fmsub	s28, s29, s25, s28
    38e8:	fcvtzs	w7, s29
    38ec:	fmadd	s29, s28, s19, s21
    38f0:	add	w7, w7, #0x7f
    38f4:	fmov	s25, w7
    38f8:	fmadd	s29, s28, s29, s22
    38fc:	fmadd	s29, s28, s29, s23
    3900:	shl	v25.2s, v25.2s, #23
    3904:	fmadd	s24, s28, s29, s24
    3908:	fmadd	s24, s28, s24, s27
    390c:	fmadd	s29, s28, s24, s27
    3910:	fmul	s29, s29, s25
    3914:	fmul	s29, s29, s20
    3918:	fcmpe	s15, #0.0
    391c:	fmul	s30, s30, s29
    3920:	b.mi	37dc <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8bc>  // b.first
    3924:	b	3728 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x808>
    3928:	fmov	s23, #5.000000000000000000e-01
    392c:	mov	w0, #0x7218                	// #29208
    3930:	mov	w3, #0xb61                 	// #2913
    3934:	movk	w0, #0x3f31, lsl #16
    3938:	mov	w2, #0x8889                	// #34953
    393c:	fmov	s27, #1.000000000000000000e+00
    3940:	movk	w3, #0x3ab6, lsl #16
    3944:	movk	w2, #0x3c08, lsl #16
    3948:	fmov	s24, w0
    394c:	mov	w1, #0xaaab                	// #43691
    3950:	mov	w0, #0xaaab                	// #43691
    3954:	fadd	s29, s29, s23
    3958:	movk	w1, #0x3d2a, lsl #16
    395c:	movk	w0, #0x3e2a, lsl #16
    3960:	fmov	s18, w3
    3964:	mov	w4, #0x422a                	// #16938
    3968:	fmov	s20, w2
    396c:	movk	w4, #0x3ecc, lsl #16
    3970:	fmov	s21, w1
    3974:	fmov	s22, w0
    3978:	fmov	s19, w4
    397c:	fcvtzs	s29, s29
    3980:	scvtf	s29, s29
    3984:	fmsub	s30, s29, s24, s30
    3988:	fcvtzs	w7, s29
    398c:	fmadd	s29, s30, s18, s20
    3990:	add	w7, w7, #0x7f
    3994:	fmov	s24, w7
    3998:	fmadd	s29, s30, s29, s21
    399c:	fmadd	s29, s30, s29, s22
    39a0:	shl	v24.2s, v24.2s, #23
    39a4:	fmadd	s23, s30, s29, s23
    39a8:	fmadd	s23, s30, s23, s27
    39ac:	fmadd	s30, s30, s23, s27
    39b0:	fmul	s30, s30, s24
    39b4:	fmul	s30, s30, s19
    39b8:	fcmpe	s0, #0.0
    39bc:	fmul	s31, s31, s30
    39c0:	b.mi	3548 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>  // b.first
    39c4:	b	3540 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    39c8:	fmov	s26, #5.000000000000000000e-01
    39cc:	mov	w0, #0x7218                	// #29208
    39d0:	mov	w3, #0xb61                 	// #2913
    39d4:	movk	w0, #0x3f31, lsl #16
    39d8:	mov	w2, #0x8889                	// #34953
    39dc:	fmov	s30, #1.000000000000000000e+00
    39e0:	movk	w3, #0x3ab6, lsl #16
    39e4:	movk	w2, #0x3c08, lsl #16
    39e8:	fmov	s27, w0
    39ec:	mov	w1, #0xaaab                	// #43691
    39f0:	mov	w0, #0xaaab                	// #43691
    39f4:	fadd	s28, s28, s26
    39f8:	movk	w1, #0x3d2a, lsl #16
    39fc:	movk	w0, #0x3e2a, lsl #16
    3a00:	fmov	s22, w3
    3a04:	fmov	s23, w2
    3a08:	fmov	s24, w1
    3a0c:	fmov	s25, w0
    3a10:	fcvtzs	s28, s28
    3a14:	scvtf	s28, s28
    3a18:	fmsub	s29, s28, s27, s29
    3a1c:	fcvtzs	w7, s28
    3a20:	fmadd	s28, s29, s22, s23
    3a24:	add	w7, w7, #0x7f
    3a28:	fmov	s27, w7
    3a2c:	fmadd	s28, s29, s28, s24
    3a30:	fmadd	s28, s29, s28, s25
    3a34:	shl	v27.2s, v27.2s, #23
    3a38:	fmadd	s26, s29, s28, s26
    3a3c:	fmadd	s26, s29, s26, s30
    3a40:	fmadd	s30, s29, s26, s30
    3a44:	fmul	s30, s30, s27
    3a48:	b	3604 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    3a4c:	mov	x19, #0x0                   	// #0
    3a50:	b	32c8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a8>
    3a54:	nop
    3a58:	nop
    3a5c:	nop
