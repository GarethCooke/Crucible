0000000000003ee0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    3ee0:	stp	x29, x30, [sp, #-160]!
    3ee4:	mov	x29, sp
    3ee8:	stp	x19, x20, [sp, #16]
    3eec:	mov	x20, x0
    3ef0:	stp	x21, x22, [sp, #32]
    3ef4:	mov	x21, x1
    3ef8:	mov	x22, x2
    3efc:	stp	x23, x24, [sp, #48]
    3f00:	mov	x24, x6
    3f04:	mov	x23, x3
    3f08:	stp	x25, x26, [sp, #64]
    3f0c:	mov	x25, x4
    3f10:	mov	x26, x5
    3f14:	stp	d8, d9, [sp, #80]
    3f18:	stp	d10, d11, [sp, #96]
    3f1c:	stp	d12, d13, [sp, #112]
    3f20:	stp	d14, d15, [sp, #128]
    3f24:	cmp	x6, #0x3
    3f28:	b.ls	4a0c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xb2c>  // b.plast
    3f2c:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f30:	sub	x19, x6, #0x4
    3f34:	and	x0, x19, #0xfffffffffffffffc
    3f38:	mov	x7, #0x0                   	// #0
    3f3c:	ldr	q20, [x1, #3696]
    3f40:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f44:	mov	x8, #0x0                   	// #0
    3f48:	add	x0, x0, #0x4
    3f4c:	ldr	q1, [x1, #3712]
    3f50:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f54:	ldr	q11, [x1, #3728]
    3f58:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f5c:	ldr	q12, [x1, #3744]
    3f60:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f64:	ldr	q13, [x1, #3760]
    3f68:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f6c:	ldr	q14, [x1, #3776]
    3f70:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f74:	ldr	q15, [x1, #3792]
    3f78:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f7c:	ldr	q4, [x1, #3808]
    3f80:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f84:	ldr	q5, [x1, #3824]
    3f88:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f8c:	ldr	q6, [x1, #3840]
    3f90:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f94:	ldr	q7, [x1, #3856]
    3f98:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f9c:	ldr	q16, [x1, #3872]
    3fa0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3fa4:	ldr	q17, [x1, #3888]
    3fa8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3fac:	ldr	q18, [x1, #3904]
    3fb0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3fb4:	movi	v26.4s, #0x7f, msl #16
    3fb8:	fmov	v25.4s, #5.000000000000000000e-01
    3fbc:	ldr	q9, [x21, x7]
    3fc0:	movi	v23.4s, #0x7f
    3fc4:	fmov	v31.4s, #-1.000000000000000000e+00
    3fc8:	fmov	v29.4s, #1.000000000000000000e+00
    3fcc:	fmov	v10.4s, #-5.000000000000000000e-01
    3fd0:	add	x8, x8, #0x4
    3fd4:	ldr	q30, [x20, x7]
    3fd8:	mov	v0.16b, v25.16b
    3fdc:	ldr	q19, [x1, #3920]
    3fe0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3fe4:	ldr	q24, [x1, #3936]
    3fe8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3fec:	fdiv	v27.4s, v30.4s, v9.4s
    3ff0:	ldr	q21, [x22, x7]
    3ff4:	ldr	q22, [x23, x7]
    3ff8:	and	v26.16b, v26.16b, v27.16b
    3ffc:	sshr	v27.4s, v27.4s, #23
    4000:	ldr	q30, [x25, x7]
    4004:	orr	v26.16b, v26.16b, v24.16b
    4008:	ldr	q24, [x1, #3952]
    400c:	sub	v27.4s, v27.4s, v23.4s
    4010:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4014:	fmul	v28.4s, v21.4s, v22.4s
    4018:	fmul	v3.4s, v30.4s, v30.4s
    401c:	fcmge	v8.4s, v26.4s, v24.4s
    4020:	fmul	v24.4s, v25.4s, v26.4s
    4024:	fneg	v28.4s, v28.4s
    4028:	fmla	v22.4s, v25.4s, v3.4s
    402c:	bit	v26.16b, v24.16b, v8.16b
    4030:	sub	v27.4s, v27.4s, v8.4s
    4034:	ldr	q8, [x1, #3968]
    4038:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    403c:	fmax	v28.4s, v28.4s, v4.4s
    4040:	ldr	q24, [x1, #3984]
    4044:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4048:	fadd	v31.4s, v31.4s, v26.4s
    404c:	fsqrt	v26.4s, v21.4s
    4050:	scvtf	v27.4s, v27.4s
    4054:	fmin	v28.4s, v28.4s, v5.4s
    4058:	fmul	v30.4s, v30.4s, v26.4s
    405c:	fmla	v8.4s, v24.4s, v31.4s
    4060:	ldr	q24, [x1, #4000]
    4064:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4068:	fmul	v26.4s, v28.4s, v6.4s
    406c:	fmla	v24.4s, v8.4s, v31.4s
    4070:	ldr	q8, [x1, #4016]
    4074:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4078:	frintn	v26.4s, v26.4s
    407c:	fmla	v8.4s, v24.4s, v31.4s
    4080:	ldr	q24, [x1, #4032]
    4084:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4088:	ldr	q3, [x1, #4048]
    408c:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4090:	fmls	v28.4s, v26.4s, v20.4s
    4094:	fmla	v24.4s, v8.4s, v31.4s
    4098:	mov	v8.16b, v16.16b
    409c:	fcvtzs	v26.4s, v26.4s
    40a0:	fmla	v3.4s, v24.4s, v31.4s
    40a4:	ldr	q24, [x1, #4064]
    40a8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    40ac:	fmla	v8.4s, v7.4s, v28.4s
    40b0:	add	v26.4s, v26.4s, v23.4s
    40b4:	fmla	v24.4s, v3.4s, v31.4s
    40b8:	mov	v3.16b, v17.16b
    40bc:	shl	v26.4s, v26.4s, #23
    40c0:	fmla	v3.4s, v8.4s, v28.4s
    40c4:	ldr	q8, [x1, #4080]
    40c8:	adrp	x1, 5000 <_IO_stdin_used+0x3a0>
    40cc:	ldr	q2, [x1]
    40d0:	fmla	v8.4s, v24.4s, v31.4s
    40d4:	mov	v24.16b, v18.16b
    40d8:	fmla	v2.4s, v8.4s, v31.4s
    40dc:	fmla	v24.4s, v3.4s, v28.4s
    40e0:	mov	v3.16b, v29.16b
    40e4:	fmul	v8.4s, v31.4s, v31.4s
    40e8:	fmla	v0.4s, v24.4s, v28.4s
    40ec:	fmul	v24.4s, v31.4s, v8.4s
    40f0:	fmla	v3.4s, v0.4s, v28.4s
    40f4:	fmul	v24.4s, v24.4s, v2.4s
    40f8:	mov	v2.16b, v29.16b
    40fc:	fmls	v24.4s, v8.4s, v25.4s
    4100:	mov	v8.16b, v12.16b
    4104:	fmla	v2.4s, v3.4s, v28.4s
    4108:	mov	v3.16b, v16.16b
    410c:	fadd	v31.4s, v31.4s, v24.4s
    4110:	fmul	v26.4s, v2.4s, v26.4s
    4114:	mov	v2.16b, v18.16b
    4118:	fmla	v31.4s, v27.4s, v20.4s
    411c:	fmul	v26.4s, v26.4s, v9.4s
    4120:	mov	v9.16b, v13.16b
    4124:	fmla	v31.4s, v22.4s, v21.4s
    4128:	mov	v21.16b, v29.16b
    412c:	fdiv	v31.4s, v31.4s, v30.4s
    4130:	fsub	v30.4s, v31.4s, v30.4s
    4134:	fmul	v27.4s, v31.4s, v31.4s
    4138:	fabs	v24.4s, v31.4s
    413c:	fcmlt	v31.4s, v31.4s, #0.0
    4140:	fmul	v28.4s, v30.4s, v30.4s
    4144:	fmul	v27.4s, v27.4s, v10.4s
    4148:	fmla	v21.4s, v1.4s, v24.4s
    414c:	fabs	v22.4s, v30.4s
    4150:	mov	v24.16b, v29.16b
    4154:	fmul	v28.4s, v28.4s, v10.4s
    4158:	fmax	v27.4s, v27.4s, v4.4s
    415c:	fcmlt	v30.4s, v30.4s, #0.0
    4160:	fmla	v24.4s, v1.4s, v22.4s
    4164:	fmax	v28.4s, v28.4s, v4.4s
    4168:	fmin	v27.4s, v27.4s, v5.4s
    416c:	fdiv	v21.4s, v29.4s, v21.4s
    4170:	fmin	v28.4s, v28.4s, v5.4s
    4174:	fmul	v22.4s, v27.4s, v6.4s
    4178:	fmla	v8.4s, v11.4s, v21.4s
    417c:	fdiv	v24.4s, v29.4s, v24.4s
    4180:	fmul	v10.4s, v28.4s, v6.4s
    4184:	frintn	v22.4s, v22.4s
    4188:	fmla	v9.4s, v8.4s, v21.4s
    418c:	mov	v8.16b, v14.16b
    4190:	frintn	v10.4s, v10.4s
    4194:	fmls	v27.4s, v22.4s, v20.4s
    4198:	fmla	v8.4s, v9.4s, v21.4s
    419c:	mov	v9.16b, v15.16b
    41a0:	fmls	v28.4s, v10.4s, v20.4s
    41a4:	fcvtzs	v22.4s, v22.4s
    41a8:	fcvtzs	v10.4s, v10.4s
    41ac:	fmla	v3.4s, v7.4s, v27.4s
    41b0:	fmla	v9.4s, v8.4s, v21.4s
    41b4:	mov	v8.16b, v17.16b
    41b8:	add	v22.4s, v22.4s, v23.4s
    41bc:	add	v10.4s, v10.4s, v23.4s
    41c0:	mov	v23.16b, v16.16b
    41c4:	fmla	v8.4s, v3.4s, v27.4s
    41c8:	mov	v3.16b, v18.16b
    41cc:	fmla	v23.4s, v7.4s, v28.4s
    41d0:	shl	v22.4s, v22.4s, #23
    41d4:	fmla	v3.4s, v8.4s, v27.4s
    41d8:	mov	v8.16b, v17.16b
    41dc:	shl	v10.4s, v10.4s, #23
    41e0:	fmul	v21.4s, v21.4s, v9.4s
    41e4:	fmla	v8.4s, v23.4s, v28.4s
    41e8:	mov	v23.16b, v25.16b
    41ec:	fmla	v23.4s, v3.4s, v27.4s
    41f0:	mov	v3.16b, v29.16b
    41f4:	fmla	v2.4s, v8.4s, v28.4s
    41f8:	mov	v8.16b, v12.16b
    41fc:	fmla	v3.4s, v23.4s, v27.4s
    4200:	mov	v23.16b, v29.16b
    4204:	fmla	v25.4s, v2.4s, v28.4s
    4208:	fmla	v23.4s, v3.4s, v27.4s
    420c:	mov	v3.16b, v29.16b
    4210:	mov	v27.16b, v29.16b
    4214:	fmla	v8.4s, v11.4s, v24.4s
    4218:	fmla	v3.4s, v25.4s, v28.4s
    421c:	mov	v25.16b, v13.16b
    4220:	fmla	v25.4s, v8.4s, v24.4s
    4224:	fmla	v27.4s, v3.4s, v28.4s
    4228:	mov	v28.16b, v14.16b
    422c:	fmla	v28.4s, v25.4s, v24.4s
    4230:	fmul	v25.4s, v23.4s, v22.4s
    4234:	mov	v23.16b, v15.16b
    4238:	fmla	v23.4s, v28.4s, v24.4s
    423c:	fmul	v25.4s, v25.4s, v19.4s
    4240:	fmul	v28.4s, v27.4s, v10.4s
    4244:	fmul	v27.4s, v25.4s, v21.4s
    4248:	fmul	v28.4s, v28.4s, v19.4s
    424c:	fmul	v24.4s, v24.4s, v23.4s
    4250:	fsub	v25.4s, v29.4s, v27.4s
    4254:	fmul	v24.4s, v28.4s, v24.4s
    4258:	ldr	q28, [x20, x7]
    425c:	bsl	v31.16b, v27.16b, v25.16b
    4260:	fsub	v29.4s, v29.4s, v24.4s
    4264:	fmul	v31.4s, v28.4s, v31.4s
    4268:	bsl	v30.16b, v24.16b, v29.16b
    426c:	fmls	v31.4s, v26.4s, v30.4s
    4270:	str	q31, [x26, x7]
    4274:	add	x7, x7, #0x10
    4278:	cmp	x8, x0
    427c:	b.ne	3fb0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xd0>  // b.any
    4280:	and	x19, x19, #0xfffffffffffffffc
    4284:	add	x19, x19, #0x4
    4288:	cmp	x24, x19
    428c:	b.ls	4704 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>  // b.plast
    4290:	mov	w4, #0x3389                	// #13193
    4294:	mov	w3, #0x466f                	// #18031
    4298:	mov	w2, #0x1eea                	// #7914
    429c:	mov	w1, #0x778                 	// #1912
    42a0:	movk	w4, #0x3e6d, lsl #16
    42a4:	movk	w3, #0x3faa, lsl #16
    42a8:	movk	w2, #0xbfe9, lsl #16
    42ac:	movk	w1, #0x3fe4, lsl #16
    42b0:	mov	w0, #0xc2b00000            	// #-1028653056
    42b4:	fmov	s10, w4
    42b8:	fmov	s11, w3
    42bc:	fmov	s12, w2
    42c0:	fmov	s13, w1
    42c4:	fmov	s14, w0
    42c8:	ldr	s28, [x22, x19, lsl #2]
    42cc:	ldr	s15, [x25, x19, lsl #2]
    42d0:	ldr	s26, [x20, x19, lsl #2]
    42d4:	fcmp	s28, #0.0
    42d8:	ldr	s8, [x21, x19, lsl #2]
    42dc:	ldr	s25, [x23, x19, lsl #2]
    42e0:	fmul	s9, s15, s15
    42e4:	b.pl	443c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.nfrst
    42e8:	fmov	s0, s28
    42ec:	stp	s26, s28, [sp, #148]
    42f0:	str	s25, [sp, #156]
    42f4:	bl	ec0 <sqrtf@plt>
    42f8:	ldr	s26, [sp, #148]
    42fc:	fmul	s15, s15, s0
    4300:	fdiv	s0, s26, s8
    4304:	bl	1020 <logf@plt>
    4308:	ldr	s25, [sp, #156]
    430c:	fmov	s31, #5.000000000000000000e-01
    4310:	mov	w0, #0x3389                	// #13193
    4314:	movk	w0, #0x3e6d, lsl #16
    4318:	fmov	s27, #1.000000000000000000e+00
    431c:	mov	w1, #0x466f                	// #18031
    4320:	ldp	s26, s28, [sp, #148]
    4324:	mov	w3, #0x1eea                	// #7914
    4328:	movk	w1, #0x3faa, lsl #16
    432c:	fmov	s30, w0
    4330:	movk	w3, #0xbfe9, lsl #16
    4334:	mov	w2, #0x778                 	// #1912
    4338:	fmov	s20, w1
    433c:	movk	w2, #0x3fe4, lsl #16
    4340:	mov	w1, #0x8f89                	// #36745
    4344:	fmov	s22, w3
    4348:	movk	w1, #0xbeb6, lsl #16
    434c:	mov	w0, #0x85fa                	// #34298
    4350:	fmadd	s9, s9, s31, s25
    4354:	movk	w0, #0x3ea3, lsl #16
    4358:	mov	w7, #0xaa3b                	// #43579
    435c:	fmov	s23, w2
    4360:	fmov	s19, #-5.000000000000000000e-01
    4364:	movk	w7, #0x3fb8, lsl #16
    4368:	fmov	s24, w1
    436c:	fmov	s31, w0
    4370:	fmadd	s0, s28, s9, s0
    4374:	fmov	s29, w7
    4378:	fdiv	s0, s0, s15
    437c:	fmadd	s21, s0, s30, s27
    4380:	fmul	s30, s0, s19
    4384:	fsub	s15, s0, s15
    4388:	fmul	s30, s30, s0
    438c:	fdiv	s27, s27, s21
    4390:	fmul	s29, s30, s29
    4394:	fmadd	s22, s27, s20, s22
    4398:	fmadd	s23, s22, s27, s23
    439c:	fmadd	s24, s23, s27, s24
    43a0:	fmadd	s31, s24, s27, s31
    43a4:	fmul	s31, s31, s27
    43a8:	fmov	s24, #5.000000000000000000e-01
    43ac:	mov	w0, #0x7218                	// #29208
    43b0:	mov	w3, #0xb61                 	// #2913
    43b4:	movk	w0, #0x3f31, lsl #16
    43b8:	mov	w2, #0x8889                	// #34953
    43bc:	fmov	s27, #1.000000000000000000e+00
    43c0:	movk	w3, #0x3ab6, lsl #16
    43c4:	movk	w2, #0x3c08, lsl #16
    43c8:	fmov	s18, w0
    43cc:	mov	w1, #0xaaab                	// #43691
    43d0:	mov	w0, #0xaaab                	// #43691
    43d4:	fsub	s29, s29, s24
    43d8:	movk	w1, #0x3d2a, lsl #16
    43dc:	movk	w0, #0x3e2a, lsl #16
    43e0:	fmov	s21, w2
    43e4:	mov	w4, #0x422a                	// #16938
    43e8:	fmov	s19, w3
    43ec:	movk	w4, #0x3ecc, lsl #16
    43f0:	fmov	s22, w1
    43f4:	fmov	s23, w0
    43f8:	fmov	s20, w4
    43fc:	fcvtzs	s29, s29
    4400:	scvtf	s29, s29
    4404:	fmsub	s30, s29, s18, s30
    4408:	fcvtzs	w7, s29
    440c:	fmadd	s29, s30, s19, s21
    4410:	add	w7, w7, #0x7f
    4414:	fmov	s21, w7
    4418:	fmadd	s29, s30, s29, s22
    441c:	fmadd	s29, s30, s29, s23
    4420:	shl	v21.2s, v21.2s, #23
    4424:	fmadd	s24, s30, s29, s24
    4428:	fmadd	s24, s30, s24, s27
    442c:	fmadd	s30, s30, s24, s27
    4430:	fmul	s30, s30, s21
    4434:	fmul	s30, s30, s20
    4438:	b	4978 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa98>
    443c:	fsqrt	s29, s28
    4440:	stp	s26, s28, [sp, #148]
    4444:	str	s25, [sp, #156]
    4448:	fdiv	s0, s26, s8
    444c:	fmul	s15, s15, s29
    4450:	bl	1020 <logf@plt>
    4454:	ldr	s25, [sp, #156]
    4458:	fmov	s30, #5.000000000000000000e-01
    445c:	ldp	s26, s28, [sp, #148]
    4460:	fmadd	s9, s9, s30, s25
    4464:	fmadd	s0, s28, s9, s0
    4468:	fdiv	s0, s0, s15
    446c:	fcmpe	s0, #0.0
    4470:	fsub	s15, s0, s15
    4474:	b.mi	47b4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8d4>  // b.first
    4478:	fmov	s31, #1.000000000000000000e+00
    447c:	mov	w1, #0x8f89                	// #36745
    4480:	mov	w0, #0x85fa                	// #34298
    4484:	movk	w1, #0xbeb6, lsl #16
    4488:	movk	w0, #0x3ea3, lsl #16
    448c:	fmov	s30, #-5.000000000000000000e-01
    4490:	fmov	s27, w1
    4494:	fmadd	s24, s0, s10, s31
    4498:	fmov	s29, w0
    449c:	fmul	s30, s0, s30
    44a0:	fmul	s30, s30, s0
    44a4:	fdiv	s31, s31, s24
    44a8:	fcmpe	s30, s14
    44ac:	fmadd	s24, s31, s11, s12
    44b0:	fmadd	s24, s31, s24, s13
    44b4:	fmadd	s27, s31, s24, s27
    44b8:	fmadd	s29, s31, s27, s29
    44bc:	fmul	s31, s31, s29
    44c0:	b.mi	4824 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x944>  // b.first
    44c4:	mov	w0, #0x42b00000            	// #1118830592
    44c8:	fmov	s29, w0
    44cc:	fcmpe	s30, s29
    44d0:	b.gt	44f0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x610>
    44d4:	mov	w7, #0xaa3b                	// #43579
    44d8:	movk	w7, #0x3fb8, lsl #16
    44dc:	fmov	s29, w7
    44e0:	fmul	s29, s30, s29
    44e4:	fcmpe	s29, #0.0
    44e8:	b.ge	48e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    44ec:	b	43a8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    44f0:	mov	w0, #0x484f                	// #18511
    44f4:	movk	w0, #0x7e46, lsl #16
    44f8:	fmov	s30, w0
    44fc:	fmul	s31, s31, s30
    4500:	fmov	s30, #1.000000000000000000e+00
    4504:	fsub	s31, s30, s31
    4508:	fnmul	s29, s25, s28
    450c:	fmul	s31, s26, s31
    4510:	movi	v30.2s, #0x0
    4514:	fcmpe	s29, s14
    4518:	b.mi	45c4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>  // b.first
    451c:	mov	w0, #0x42b00000            	// #1118830592
    4520:	fmov	s30, w0
    4524:	fcmpe	s29, s30
    4528:	b.gt	4838 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x958>
    452c:	mov	w7, #0xaa3b                	// #43579
    4530:	movk	w7, #0x3fb8, lsl #16
    4534:	fmov	s28, w7
    4538:	fmul	s28, s29, s28
    453c:	fcmpe	s28, #0.0
    4540:	b.ge	4988 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xaa8>  // b.tcont
    4544:	fmov	s27, #5.000000000000000000e-01
    4548:	mov	w0, #0x7218                	// #29208
    454c:	mov	w3, #0xb61                 	// #2913
    4550:	movk	w0, #0x3f31, lsl #16
    4554:	mov	w2, #0x8889                	// #34953
    4558:	fmov	s30, #1.000000000000000000e+00
    455c:	movk	w3, #0x3ab6, lsl #16
    4560:	movk	w2, #0x3c08, lsl #16
    4564:	fmov	s22, w0
    4568:	mov	w1, #0xaaab                	// #43691
    456c:	mov	w0, #0xaaab                	// #43691
    4570:	fsub	s28, s28, s27
    4574:	movk	w1, #0x3d2a, lsl #16
    4578:	movk	w0, #0x3e2a, lsl #16
    457c:	fmov	s24, w2
    4580:	fmov	s23, w3
    4584:	fmov	s25, w1
    4588:	fmov	s26, w0
    458c:	fcvtzs	s28, s28
    4590:	scvtf	s28, s28
    4594:	fmsub	s29, s28, s22, s29
    4598:	fcvtzs	w7, s28
    459c:	fmadd	s28, s29, s23, s24
    45a0:	add	w7, w7, #0x7f
    45a4:	fmov	s24, w7
    45a8:	fmadd	s28, s29, s28, s25
    45ac:	fmadd	s28, s29, s28, s26
    45b0:	shl	v24.2s, v24.2s, #23
    45b4:	fmadd	s27, s29, s28, s27
    45b8:	fmadd	s27, s29, s27, s30
    45bc:	fmadd	s30, s29, s27, s30
    45c0:	fmul	s30, s30, s24
    45c4:	fcmpe	s15, #0.0
    45c8:	fmul	s26, s8, s30
    45cc:	b.mi	472c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x84c>  // b.first
    45d0:	fmov	s30, #1.000000000000000000e+00
    45d4:	mov	w1, #0x8f89                	// #36745
    45d8:	mov	w0, #0x85fa                	// #34298
    45dc:	movk	w1, #0xbeb6, lsl #16
    45e0:	movk	w0, #0x3ea3, lsl #16
    45e4:	fmov	s28, #-5.000000000000000000e-01
    45e8:	fmov	s27, w1
    45ec:	fmadd	s25, s15, s10, s30
    45f0:	fmov	s29, w0
    45f4:	fmul	s28, s15, s28
    45f8:	fmul	s28, s28, s15
    45fc:	fdiv	s30, s30, s25
    4600:	fcmpe	s28, s14
    4604:	fmadd	s25, s30, s11, s12
    4608:	fmadd	s25, s30, s25, s13
    460c:	fmadd	s27, s30, s25, s27
    4610:	fmadd	s29, s30, s27, s29
    4614:	fmul	s30, s30, s29
    4618:	b.mi	4830 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x950>  // b.first
    461c:	mov	w0, #0x42b00000            	// #1118830592
    4620:	fmov	s29, w0
    4624:	fcmpe	s28, s29
    4628:	b.gt	46d8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7f8>
    462c:	mov	w7, #0xaa3b                	// #43579
    4630:	movk	w7, #0x3fb8, lsl #16
    4634:	fmov	s29, w7
    4638:	fmul	s29, s28, s29
    463c:	fcmpe	s29, #0.0
    4640:	b.ge	4848 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    4644:	fmov	s25, #5.000000000000000000e-01
    4648:	mov	w0, #0x7218                	// #29208
    464c:	mov	w4, #0xb61                 	// #2913
    4650:	movk	w0, #0x3f31, lsl #16
    4654:	mov	w2, #0x8889                	// #34953
    4658:	fmov	s27, #1.000000000000000000e+00
    465c:	movk	w4, #0x3ab6, lsl #16
    4660:	movk	w2, #0x3c08, lsl #16
    4664:	fmov	s19, w0
    4668:	mov	w1, #0xaaab                	// #43691
    466c:	mov	w0, #0xaaab                	// #43691
    4670:	fsub	s29, s29, s25
    4674:	movk	w1, #0x3d2a, lsl #16
    4678:	movk	w0, #0x3e2a, lsl #16
    467c:	fmov	s22, w2
    4680:	mov	w3, #0x422a                	// #16938
    4684:	fmov	s20, w4
    4688:	movk	w3, #0x3ecc, lsl #16
    468c:	fmov	s23, w1
    4690:	fmov	s24, w0
    4694:	fmov	s21, w3
    4698:	fcvtzs	s29, s29
    469c:	scvtf	s29, s29
    46a0:	fmsub	s28, s29, s19, s28
    46a4:	fcvtzs	w7, s29
    46a8:	fmadd	s29, s28, s20, s22
    46ac:	add	w7, w7, #0x7f
    46b0:	fmov	s22, w7
    46b4:	fmadd	s29, s28, s29, s23
    46b8:	fmadd	s29, s28, s29, s24
    46bc:	shl	v22.2s, v22.2s, #23
    46c0:	fmadd	s25, s28, s29, s25
    46c4:	fmadd	s25, s28, s25, s27
    46c8:	fmadd	s29, s28, s25, s27
    46cc:	fmul	s29, s29, s22
    46d0:	fmul	s29, s29, s21
    46d4:	b	48d8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x9f8>
    46d8:	mov	w0, #0x484f                	// #18511
    46dc:	movk	w0, #0x7e46, lsl #16
    46e0:	fmov	s29, w0
    46e4:	fmul	s30, s30, s29
    46e8:	fmov	s29, #1.000000000000000000e+00
    46ec:	fsub	s29, s29, s30
    46f0:	fmsub	s31, s26, s29, s31
    46f4:	str	s31, [x26, x19, lsl #2]
    46f8:	add	x19, x19, #0x1
    46fc:	cmp	x19, x24
    4700:	b.ne	42c8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    4704:	ldp	d8, d9, [sp, #80]
    4708:	ldp	x19, x20, [sp, #16]
    470c:	ldp	x21, x22, [sp, #32]
    4710:	ldp	x23, x24, [sp, #48]
    4714:	ldp	x25, x26, [sp, #64]
    4718:	ldp	d10, d11, [sp, #96]
    471c:	ldp	d12, d13, [sp, #112]
    4720:	ldp	d14, d15, [sp, #128]
    4724:	ldp	x29, x30, [sp], #160
    4728:	ret
    472c:	fmov	s29, #1.000000000000000000e+00
    4730:	mov	w1, #0x8f89                	// #36745
    4734:	mov	w0, #0x85fa                	// #34298
    4738:	movk	w1, #0xbeb6, lsl #16
    473c:	movk	w0, #0x3ea3, lsl #16
    4740:	fmov	s28, #5.000000000000000000e-01
    4744:	fmov	s27, w1
    4748:	fmsub	s25, s15, s10, s29
    474c:	fmov	s30, w0
    4750:	fmul	s28, s15, s28
    4754:	fnmul	s28, s15, s28
    4758:	fdiv	s29, s29, s25
    475c:	fcmpe	s28, s14
    4760:	fmadd	s25, s29, s11, s12
    4764:	fmadd	s25, s29, s25, s13
    4768:	fmadd	s27, s29, s25, s27
    476c:	fmadd	s30, s29, s27, s30
    4770:	fmul	s30, s29, s30
    4774:	b.mi	4794 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8b4>  // b.first
    4778:	mov	w7, #0xaa3b                	// #43579
    477c:	movk	w7, #0x3fb8, lsl #16
    4780:	fmov	s29, w7
    4784:	fmul	s29, s28, s29
    4788:	fcmpe	s29, #0.0
    478c:	b.ge	4848 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    4790:	b	4644 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x764>
    4794:	movi	v29.2s, #0x0
    4798:	fmul	s30, s30, s29
    479c:	fmsub	s30, s26, s30, s31
    47a0:	str	s30, [x26, x19, lsl #2]
    47a4:	add	x19, x19, #0x1
    47a8:	cmp	x24, x19
    47ac:	b.ne	42c8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    47b0:	b	4704 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>
    47b4:	fmov	s31, #1.000000000000000000e+00
    47b8:	mov	w1, #0x8f89                	// #36745
    47bc:	mov	w0, #0x85fa                	// #34298
    47c0:	movk	w1, #0xbeb6, lsl #16
    47c4:	movk	w0, #0x3ea3, lsl #16
    47c8:	fmul	s30, s0, s30
    47cc:	fmov	s27, w1
    47d0:	fmsub	s24, s0, s10, s31
    47d4:	fmov	s29, w0
    47d8:	fnmul	s30, s0, s30
    47dc:	fcmpe	s30, s14
    47e0:	fdiv	s31, s31, s24
    47e4:	fmadd	s24, s31, s11, s12
    47e8:	fmadd	s24, s31, s24, s13
    47ec:	fmadd	s27, s31, s24, s27
    47f0:	fmadd	s29, s31, s27, s29
    47f4:	fmul	s31, s31, s29
    47f8:	b.mi	4818 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x938>  // b.first
    47fc:	mov	w7, #0xaa3b                	// #43579
    4800:	movk	w7, #0x3fb8, lsl #16
    4804:	fmov	s29, w7
    4808:	fmul	s29, s30, s29
    480c:	fcmpe	s29, #0.0
    4810:	b.ge	48e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    4814:	b	43a8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    4818:	movi	v30.2s, #0x0
    481c:	fmul	s31, s31, s30
    4820:	b	4508 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>
    4824:	movi	v30.2s, #0x0
    4828:	fmul	s31, s31, s30
    482c:	b	4500 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    4830:	movi	v29.2s, #0x0
    4834:	b	46e4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x804>
    4838:	mov	w7, #0x829c                	// #33436
    483c:	movk	w7, #0x7ef8, lsl #16
    4840:	fmov	s30, w7
    4844:	b	45c4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    4848:	fmov	s24, #5.000000000000000000e-01
    484c:	mov	w0, #0x7218                	// #29208
    4850:	mov	w4, #0xb61                 	// #2913
    4854:	movk	w0, #0x3f31, lsl #16
    4858:	mov	w2, #0x8889                	// #34953
    485c:	fmov	s27, #1.000000000000000000e+00
    4860:	movk	w4, #0x3ab6, lsl #16
    4864:	movk	w2, #0x3c08, lsl #16
    4868:	fmov	s25, w0
    486c:	mov	w1, #0xaaab                	// #43691
    4870:	mov	w0, #0xaaab                	// #43691
    4874:	fadd	s29, s29, s24
    4878:	movk	w1, #0x3d2a, lsl #16
    487c:	movk	w0, #0x3e2a, lsl #16
    4880:	fmov	s19, w4
    4884:	mov	w3, #0x422a                	// #16938
    4888:	fmov	s21, w2
    488c:	movk	w3, #0x3ecc, lsl #16
    4890:	fmov	s22, w1
    4894:	fmov	s23, w0
    4898:	fmov	s20, w3
    489c:	fcvtzs	s29, s29
    48a0:	scvtf	s29, s29
    48a4:	fmsub	s28, s29, s25, s28
    48a8:	fcvtzs	w7, s29
    48ac:	fmadd	s29, s28, s19, s21
    48b0:	add	w7, w7, #0x7f
    48b4:	fmov	s25, w7
    48b8:	fmadd	s29, s28, s29, s22
    48bc:	fmadd	s29, s28, s29, s23
    48c0:	shl	v25.2s, v25.2s, #23
    48c4:	fmadd	s24, s28, s29, s24
    48c8:	fmadd	s24, s28, s24, s27
    48cc:	fmadd	s29, s28, s24, s27
    48d0:	fmul	s29, s29, s25
    48d4:	fmul	s29, s29, s20
    48d8:	fcmpe	s15, #0.0
    48dc:	fmul	s30, s30, s29
    48e0:	b.mi	479c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8bc>  // b.first
    48e4:	b	46e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x808>
    48e8:	fmov	s23, #5.000000000000000000e-01
    48ec:	mov	w0, #0x7218                	// #29208
    48f0:	mov	w3, #0xb61                 	// #2913
    48f4:	movk	w0, #0x3f31, lsl #16
    48f8:	mov	w2, #0x8889                	// #34953
    48fc:	fmov	s27, #1.000000000000000000e+00
    4900:	movk	w3, #0x3ab6, lsl #16
    4904:	movk	w2, #0x3c08, lsl #16
    4908:	fmov	s24, w0
    490c:	mov	w1, #0xaaab                	// #43691
    4910:	mov	w0, #0xaaab                	// #43691
    4914:	fadd	s29, s29, s23
    4918:	movk	w1, #0x3d2a, lsl #16
    491c:	movk	w0, #0x3e2a, lsl #16
    4920:	fmov	s18, w3
    4924:	mov	w4, #0x422a                	// #16938
    4928:	fmov	s20, w2
    492c:	movk	w4, #0x3ecc, lsl #16
    4930:	fmov	s21, w1
    4934:	fmov	s22, w0
    4938:	fmov	s19, w4
    493c:	fcvtzs	s29, s29
    4940:	scvtf	s29, s29
    4944:	fmsub	s30, s29, s24, s30
    4948:	fcvtzs	w7, s29
    494c:	fmadd	s29, s30, s18, s20
    4950:	add	w7, w7, #0x7f
    4954:	fmov	s24, w7
    4958:	fmadd	s29, s30, s29, s21
    495c:	fmadd	s29, s30, s29, s22
    4960:	shl	v24.2s, v24.2s, #23
    4964:	fmadd	s23, s30, s29, s23
    4968:	fmadd	s23, s30, s23, s27
    496c:	fmadd	s30, s30, s23, s27
    4970:	fmul	s30, s30, s24
    4974:	fmul	s30, s30, s19
    4978:	fcmpe	s0, #0.0
    497c:	fmul	s31, s31, s30
    4980:	b.mi	4508 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>  // b.first
    4984:	b	4500 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    4988:	fmov	s26, #5.000000000000000000e-01
    498c:	mov	w0, #0x7218                	// #29208
    4990:	mov	w3, #0xb61                 	// #2913
    4994:	movk	w0, #0x3f31, lsl #16
    4998:	mov	w2, #0x8889                	// #34953
    499c:	fmov	s30, #1.000000000000000000e+00
    49a0:	movk	w3, #0x3ab6, lsl #16
    49a4:	movk	w2, #0x3c08, lsl #16
    49a8:	fmov	s27, w0
    49ac:	mov	w1, #0xaaab                	// #43691
    49b0:	mov	w0, #0xaaab                	// #43691
    49b4:	fadd	s28, s28, s26
    49b8:	movk	w1, #0x3d2a, lsl #16
    49bc:	movk	w0, #0x3e2a, lsl #16
    49c0:	fmov	s22, w3
    49c4:	fmov	s23, w2
    49c8:	fmov	s24, w1
    49cc:	fmov	s25, w0
    49d0:	fcvtzs	s28, s28
    49d4:	scvtf	s28, s28
    49d8:	fmsub	s29, s28, s27, s29
    49dc:	fcvtzs	w7, s28
    49e0:	fmadd	s28, s29, s22, s23
    49e4:	add	w7, w7, #0x7f
    49e8:	fmov	s27, w7
    49ec:	fmadd	s28, s29, s28, s24
    49f0:	fmadd	s28, s29, s28, s25
    49f4:	shl	v27.2s, v27.2s, #23
    49f8:	fmadd	s26, s29, s28, s26
    49fc:	fmadd	s26, s29, s26, s30
    4a00:	fmadd	s30, s29, s26, s30
    4a04:	fmul	s30, s30, s27
    4a08:	b	45c4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    4a0c:	mov	x19, #0x0                   	// #0
    4a10:	b	4288 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a8>
    4a14:	nop
    4a18:	nop
    4a1c:	nop
