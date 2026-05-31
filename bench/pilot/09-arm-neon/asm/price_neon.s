0000000000003850 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    3850:	stp	x29, x30, [sp, #-160]!
    3854:	mov	x29, sp
    3858:	stp	x19, x20, [sp, #16]
    385c:	mov	x20, x0
    3860:	stp	x21, x22, [sp, #32]
    3864:	mov	x21, x1
    3868:	mov	x22, x2
    386c:	stp	x23, x24, [sp, #48]
    3870:	mov	x24, x6
    3874:	mov	x23, x3
    3878:	stp	x25, x26, [sp, #64]
    387c:	mov	x25, x4
    3880:	mov	x26, x5
    3884:	stp	d8, d9, [sp, #80]
    3888:	stp	d10, d11, [sp, #96]
    388c:	stp	d12, d13, [sp, #112]
    3890:	stp	d14, d15, [sp, #128]
    3894:	cmp	x6, #0x3
    3898:	b.ls	4388 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xb38>  // b.plast
    389c:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    38a0:	sub	x19, x6, #0x4
    38a4:	and	x0, x19, #0xfffffffffffffffc
    38a8:	mov	x7, #0x0                   	// #0
    38ac:	ldr	q20, [x1, #2000]
    38b0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    38b4:	mov	x8, #0x0                   	// #0
    38b8:	add	x0, x0, #0x4
    38bc:	ldr	q1, [x1, #2016]
    38c0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    38c4:	ldr	q11, [x1, #2032]
    38c8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    38cc:	ldr	q12, [x1, #2048]
    38d0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    38d4:	ldr	q13, [x1, #2064]
    38d8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    38dc:	ldr	q14, [x1, #2080]
    38e0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    38e4:	ldr	q15, [x1, #2096]
    38e8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    38ec:	ldr	q4, [x1, #2112]
    38f0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    38f4:	ldr	q5, [x1, #2128]
    38f8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    38fc:	ldr	q6, [x1, #2144]
    3900:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    3904:	ldr	q7, [x1, #2160]
    3908:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    390c:	ldr	q16, [x1, #2176]
    3910:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    3914:	ldr	q17, [x1, #2192]
    3918:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    391c:	ldr	q18, [x1, #2208]
    3920:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    3924:	movi	v26.4s, #0x7f, msl #16
    3928:	fmov	v25.4s, #5.000000000000000000e-01
    392c:	ldr	q9, [x21, x7]
    3930:	movi	v23.4s, #0x7f
    3934:	fmov	v31.4s, #-1.000000000000000000e+00
    3938:	fmov	v29.4s, #1.000000000000000000e+00
    393c:	fmov	v10.4s, #-5.000000000000000000e-01
    3940:	add	x8, x8, #0x4
    3944:	ldr	q30, [x20, x7]
    3948:	mov	v0.16b, v25.16b
    394c:	ldr	q19, [x1, #2224]
    3950:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    3954:	ldr	q24, [x1, #2240]
    3958:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    395c:	fdiv	v27.4s, v30.4s, v9.4s
    3960:	ldr	q21, [x22, x7]
    3964:	ldr	q22, [x23, x7]
    3968:	and	v26.16b, v26.16b, v27.16b
    396c:	sshr	v27.4s, v27.4s, #23
    3970:	ldr	q30, [x25, x7]
    3974:	orr	v26.16b, v26.16b, v24.16b
    3978:	ldr	q24, [x1, #2256]
    397c:	sub	v27.4s, v27.4s, v23.4s
    3980:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    3984:	fmul	v28.4s, v21.4s, v22.4s
    3988:	fmul	v3.4s, v30.4s, v30.4s
    398c:	fcmge	v8.4s, v26.4s, v24.4s
    3990:	fmul	v24.4s, v25.4s, v26.4s
    3994:	fneg	v28.4s, v28.4s
    3998:	fmla	v22.4s, v25.4s, v3.4s
    399c:	bit	v26.16b, v24.16b, v8.16b
    39a0:	sub	v27.4s, v27.4s, v8.4s
    39a4:	ldr	q8, [x1, #2272]
    39a8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    39ac:	fmax	v28.4s, v28.4s, v4.4s
    39b0:	ldr	q24, [x1, #2288]
    39b4:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    39b8:	fadd	v31.4s, v31.4s, v26.4s
    39bc:	fsqrt	v26.4s, v21.4s
    39c0:	scvtf	v27.4s, v27.4s
    39c4:	fmin	v28.4s, v28.4s, v5.4s
    39c8:	fmul	v30.4s, v30.4s, v26.4s
    39cc:	fmla	v8.4s, v24.4s, v31.4s
    39d0:	ldr	q24, [x1, #2304]
    39d4:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    39d8:	fmul	v26.4s, v28.4s, v6.4s
    39dc:	fmla	v24.4s, v8.4s, v31.4s
    39e0:	ldr	q8, [x1, #2320]
    39e4:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    39e8:	frintn	v26.4s, v26.4s
    39ec:	fmla	v8.4s, v24.4s, v31.4s
    39f0:	ldr	q24, [x1, #2336]
    39f4:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    39f8:	ldr	q3, [x1, #2352]
    39fc:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    3a00:	fmls	v28.4s, v26.4s, v20.4s
    3a04:	fmla	v24.4s, v8.4s, v31.4s
    3a08:	mov	v8.16b, v16.16b
    3a0c:	fcvtzs	v26.4s, v26.4s
    3a10:	fmla	v3.4s, v24.4s, v31.4s
    3a14:	ldr	q24, [x1, #2368]
    3a18:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    3a1c:	fmla	v8.4s, v7.4s, v28.4s
    3a20:	add	v26.4s, v26.4s, v23.4s
    3a24:	fmla	v24.4s, v3.4s, v31.4s
    3a28:	mov	v3.16b, v17.16b
    3a2c:	shl	v26.4s, v26.4s, #23
    3a30:	fmla	v3.4s, v8.4s, v28.4s
    3a34:	ldr	q8, [x1, #2384]
    3a38:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7b0>
    3a3c:	ldr	q2, [x1, #2400]
    3a40:	fmla	v8.4s, v24.4s, v31.4s
    3a44:	mov	v24.16b, v18.16b
    3a48:	fmla	v2.4s, v8.4s, v31.4s
    3a4c:	fmla	v24.4s, v3.4s, v28.4s
    3a50:	mov	v3.16b, v29.16b
    3a54:	fmul	v8.4s, v31.4s, v31.4s
    3a58:	fmla	v0.4s, v24.4s, v28.4s
    3a5c:	fmul	v24.4s, v31.4s, v8.4s
    3a60:	fmla	v3.4s, v0.4s, v28.4s
    3a64:	fmul	v24.4s, v24.4s, v2.4s
    3a68:	mov	v2.16b, v29.16b
    3a6c:	fmls	v24.4s, v8.4s, v25.4s
    3a70:	mov	v8.16b, v12.16b
    3a74:	fmla	v2.4s, v3.4s, v28.4s
    3a78:	mov	v3.16b, v16.16b
    3a7c:	fadd	v31.4s, v31.4s, v24.4s
    3a80:	fmul	v26.4s, v2.4s, v26.4s
    3a84:	mov	v2.16b, v18.16b
    3a88:	fmla	v31.4s, v27.4s, v20.4s
    3a8c:	fmul	v26.4s, v26.4s, v9.4s
    3a90:	mov	v9.16b, v13.16b
    3a94:	fmla	v31.4s, v22.4s, v21.4s
    3a98:	mov	v21.16b, v29.16b
    3a9c:	fdiv	v31.4s, v31.4s, v30.4s
    3aa0:	fsub	v30.4s, v31.4s, v30.4s
    3aa4:	fmul	v27.4s, v31.4s, v31.4s
    3aa8:	fabs	v24.4s, v31.4s
    3aac:	fcmlt	v31.4s, v31.4s, #0.0
    3ab0:	fmul	v28.4s, v30.4s, v30.4s
    3ab4:	fmul	v27.4s, v27.4s, v10.4s
    3ab8:	fmla	v21.4s, v1.4s, v24.4s
    3abc:	fabs	v22.4s, v30.4s
    3ac0:	mov	v24.16b, v29.16b
    3ac4:	fmul	v28.4s, v28.4s, v10.4s
    3ac8:	fmax	v27.4s, v27.4s, v4.4s
    3acc:	fcmlt	v30.4s, v30.4s, #0.0
    3ad0:	fmla	v24.4s, v1.4s, v22.4s
    3ad4:	fmax	v28.4s, v28.4s, v4.4s
    3ad8:	fmin	v27.4s, v27.4s, v5.4s
    3adc:	fdiv	v21.4s, v29.4s, v21.4s
    3ae0:	fmin	v28.4s, v28.4s, v5.4s
    3ae4:	fmul	v22.4s, v27.4s, v6.4s
    3ae8:	fmla	v8.4s, v11.4s, v21.4s
    3aec:	fdiv	v24.4s, v29.4s, v24.4s
    3af0:	fmul	v10.4s, v28.4s, v6.4s
    3af4:	frintn	v22.4s, v22.4s
    3af8:	fmla	v9.4s, v8.4s, v21.4s
    3afc:	mov	v8.16b, v14.16b
    3b00:	frintn	v10.4s, v10.4s
    3b04:	fmls	v27.4s, v22.4s, v20.4s
    3b08:	fmla	v8.4s, v9.4s, v21.4s
    3b0c:	mov	v9.16b, v15.16b
    3b10:	fmls	v28.4s, v10.4s, v20.4s
    3b14:	fcvtzs	v22.4s, v22.4s
    3b18:	fcvtzs	v10.4s, v10.4s
    3b1c:	fmla	v3.4s, v7.4s, v27.4s
    3b20:	fmla	v9.4s, v8.4s, v21.4s
    3b24:	mov	v8.16b, v17.16b
    3b28:	add	v22.4s, v22.4s, v23.4s
    3b2c:	add	v10.4s, v10.4s, v23.4s
    3b30:	mov	v23.16b, v16.16b
    3b34:	fmla	v8.4s, v3.4s, v27.4s
    3b38:	mov	v3.16b, v18.16b
    3b3c:	fmla	v23.4s, v7.4s, v28.4s
    3b40:	shl	v22.4s, v22.4s, #23
    3b44:	fmla	v3.4s, v8.4s, v27.4s
    3b48:	mov	v8.16b, v17.16b
    3b4c:	shl	v10.4s, v10.4s, #23
    3b50:	fmul	v21.4s, v21.4s, v9.4s
    3b54:	fmla	v8.4s, v23.4s, v28.4s
    3b58:	mov	v23.16b, v25.16b
    3b5c:	fmla	v23.4s, v3.4s, v27.4s
    3b60:	mov	v3.16b, v29.16b
    3b64:	fmla	v2.4s, v8.4s, v28.4s
    3b68:	mov	v8.16b, v12.16b
    3b6c:	fmla	v3.4s, v23.4s, v27.4s
    3b70:	mov	v23.16b, v29.16b
    3b74:	fmla	v25.4s, v2.4s, v28.4s
    3b78:	fmla	v23.4s, v3.4s, v27.4s
    3b7c:	mov	v3.16b, v29.16b
    3b80:	mov	v27.16b, v29.16b
    3b84:	fmla	v8.4s, v11.4s, v24.4s
    3b88:	fmla	v3.4s, v25.4s, v28.4s
    3b8c:	mov	v25.16b, v13.16b
    3b90:	fmla	v25.4s, v8.4s, v24.4s
    3b94:	fmla	v27.4s, v3.4s, v28.4s
    3b98:	mov	v28.16b, v14.16b
    3b9c:	fmla	v28.4s, v25.4s, v24.4s
    3ba0:	fmul	v25.4s, v23.4s, v22.4s
    3ba4:	mov	v23.16b, v15.16b
    3ba8:	fmla	v23.4s, v28.4s, v24.4s
    3bac:	fmul	v25.4s, v25.4s, v19.4s
    3bb0:	fmul	v28.4s, v27.4s, v10.4s
    3bb4:	fmul	v27.4s, v25.4s, v21.4s
    3bb8:	fmul	v28.4s, v28.4s, v19.4s
    3bbc:	fmul	v24.4s, v24.4s, v23.4s
    3bc0:	fsub	v25.4s, v29.4s, v27.4s
    3bc4:	fmul	v24.4s, v28.4s, v24.4s
    3bc8:	ldr	q28, [x20, x7]
    3bcc:	bsl	v31.16b, v27.16b, v25.16b
    3bd0:	fsub	v29.4s, v29.4s, v24.4s
    3bd4:	fmul	v31.4s, v28.4s, v31.4s
    3bd8:	bsl	v30.16b, v24.16b, v29.16b
    3bdc:	fmls	v31.4s, v26.4s, v30.4s
    3be0:	str	q31, [x26, x7]
    3be4:	add	x7, x7, #0x10
    3be8:	cmp	x8, x0
    3bec:	b.ne	3920 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xd0>  // b.any
    3bf0:	and	x19, x19, #0xfffffffffffffffc
    3bf4:	add	x19, x19, #0x4
    3bf8:	cmp	x24, x19
    3bfc:	b.ls	4080 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x830>  // b.plast
    3c00:	mov	w4, #0x3389                	// #13193
    3c04:	mov	w3, #0x466f                	// #18031
    3c08:	mov	w2, #0x1eea                	// #7914
    3c0c:	mov	w1, #0x778                 	// #1912
    3c10:	movk	w4, #0x3e6d, lsl #16
    3c14:	movk	w3, #0x3faa, lsl #16
    3c18:	movk	w2, #0xbfe9, lsl #16
    3c1c:	movk	w1, #0x3fe4, lsl #16
    3c20:	mov	w0, #0xc2b00000            	// #-1028653056
    3c24:	fmov	s10, w4
    3c28:	fmov	s11, w3
    3c2c:	fmov	s12, w2
    3c30:	fmov	s13, w1
    3c34:	fmov	s14, w0
    3c38:	ldr	s28, [x22, x19, lsl #2]
    3c3c:	ldr	s15, [x25, x19, lsl #2]
    3c40:	ldr	s26, [x20, x19, lsl #2]
    3c44:	fcmp	s28, #0.0
    3c48:	ldr	s8, [x21, x19, lsl #2]
    3c4c:	ldr	s25, [x23, x19, lsl #2]
    3c50:	fmul	s9, s15, s15
    3c54:	b.pl	3db4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x564>  // b.nfrst
    3c58:	fmov	s0, s28
    3c5c:	stp	s26, s28, [sp, #148]
    3c60:	str	s25, [sp, #156]
    3c64:	bl	ec0 <sqrtf@plt>
    3c68:	ldr	s26, [sp, #148]
    3c6c:	fmul	s15, s15, s0
    3c70:	fdiv	s0, s26, s8
    3c74:	bl	1020 <logf@plt>
    3c78:	ldr	s25, [sp, #156]
    3c7c:	fmov	s31, #5.000000000000000000e-01
    3c80:	mov	w0, #0x3389                	// #13193
    3c84:	movk	w0, #0x3e6d, lsl #16
    3c88:	fmov	s27, #1.000000000000000000e+00
    3c8c:	mov	w1, #0x466f                	// #18031
    3c90:	ldp	s26, s28, [sp, #148]
    3c94:	mov	w3, #0x1eea                	// #7914
    3c98:	movk	w1, #0x3faa, lsl #16
    3c9c:	fmov	s30, w0
    3ca0:	movk	w3, #0xbfe9, lsl #16
    3ca4:	mov	w2, #0x778                 	// #1912
    3ca8:	fmov	s20, w1
    3cac:	movk	w2, #0x3fe4, lsl #16
    3cb0:	mov	w1, #0x8f89                	// #36745
    3cb4:	fmov	s22, w3
    3cb8:	movk	w1, #0xbeb6, lsl #16
    3cbc:	mov	w0, #0x85fa                	// #34298
    3cc0:	fmadd	s9, s9, s31, s25
    3cc4:	movk	w0, #0x3ea3, lsl #16
    3cc8:	mov	w7, #0xaa3b                	// #43579
    3ccc:	fmov	s23, w2
    3cd0:	fmov	s19, #-5.000000000000000000e-01
    3cd4:	movk	w7, #0x3fb8, lsl #16
    3cd8:	fmov	s24, w1
    3cdc:	fmov	s31, w0
    3ce0:	fmadd	s0, s28, s9, s0
    3ce4:	fmov	s29, w7
    3ce8:	fdiv	s0, s0, s15
    3cec:	fmadd	s21, s0, s30, s27
    3cf0:	fmul	s30, s0, s19
    3cf4:	fsub	s15, s0, s15
    3cf8:	fmul	s30, s30, s0
    3cfc:	fdiv	s27, s27, s21
    3d00:	fmul	s29, s30, s29
    3d04:	fmadd	s22, s27, s20, s22
    3d08:	fmadd	s23, s22, s27, s23
    3d0c:	fmadd	s24, s23, s27, s24
    3d10:	fmadd	s31, s24, s27, s31
    3d14:	fmul	s31, s31, s27
    3d18:	nop
    3d1c:	nop
    3d20:	fmov	s24, #5.000000000000000000e-01
    3d24:	mov	w0, #0x7218                	// #29208
    3d28:	mov	w3, #0xb61                 	// #2913
    3d2c:	movk	w0, #0x3f31, lsl #16
    3d30:	mov	w2, #0x8889                	// #34953
    3d34:	fmov	s27, #1.000000000000000000e+00
    3d38:	movk	w3, #0x3ab6, lsl #16
    3d3c:	movk	w2, #0x3c08, lsl #16
    3d40:	fmov	s18, w0
    3d44:	mov	w1, #0xaaab                	// #43691
    3d48:	mov	w0, #0xaaab                	// #43691
    3d4c:	fsub	s29, s29, s24
    3d50:	movk	w1, #0x3d2a, lsl #16
    3d54:	movk	w0, #0x3e2a, lsl #16
    3d58:	fmov	s21, w2
    3d5c:	mov	w4, #0x422a                	// #16938
    3d60:	fmov	s19, w3
    3d64:	movk	w4, #0x3ecc, lsl #16
    3d68:	fmov	s22, w1
    3d6c:	fmov	s23, w0
    3d70:	fmov	s20, w4
    3d74:	fcvtzs	s29, s29
    3d78:	scvtf	s29, s29
    3d7c:	fmsub	s30, s29, s18, s30
    3d80:	fcvtzs	w7, s29
    3d84:	fmadd	s29, s30, s19, s21
    3d88:	add	w7, w7, #0x7f
    3d8c:	fmov	s21, w7
    3d90:	fmadd	s29, s30, s29, s22
    3d94:	fmadd	s29, s30, s29, s23
    3d98:	shl	v21.2s, v21.2s, #23
    3d9c:	fmadd	s24, s30, s29, s24
    3da0:	fmadd	s24, s30, s24, s27
    3da4:	fmadd	s30, s30, s24, s27
    3da8:	fmul	s30, s30, s21
    3dac:	fmul	s30, s30, s20
    3db0:	b	42f4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xaa4>
    3db4:	fsqrt	s29, s28
    3db8:	stp	s26, s28, [sp, #148]
    3dbc:	str	s25, [sp, #156]
    3dc0:	fdiv	s0, s26, s8
    3dc4:	fmul	s15, s15, s29
    3dc8:	bl	1020 <logf@plt>
    3dcc:	ldr	s25, [sp, #156]
    3dd0:	fmov	s30, #5.000000000000000000e-01
    3dd4:	ldp	s26, s28, [sp, #148]
    3dd8:	fmadd	s9, s9, s30, s25
    3ddc:	fmadd	s0, s28, s9, s0
    3de0:	fdiv	s0, s0, s15
    3de4:	fcmpe	s0, #0.0
    3de8:	fsub	s15, s0, s15
    3dec:	b.mi	4130 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8e0>  // b.first
    3df0:	fmov	s31, #1.000000000000000000e+00
    3df4:	mov	w1, #0x8f89                	// #36745
    3df8:	mov	w0, #0x85fa                	// #34298
    3dfc:	movk	w1, #0xbeb6, lsl #16
    3e00:	movk	w0, #0x3ea3, lsl #16
    3e04:	fmov	s30, #-5.000000000000000000e-01
    3e08:	fmov	s27, w1
    3e0c:	fmadd	s24, s0, s10, s31
    3e10:	fmov	s29, w0
    3e14:	fmul	s30, s0, s30
    3e18:	fmul	s30, s30, s0
    3e1c:	fdiv	s31, s31, s24
    3e20:	fcmpe	s30, s14
    3e24:	fmadd	s24, s31, s11, s12
    3e28:	fmadd	s24, s31, s24, s13
    3e2c:	fmadd	s27, s31, s24, s27
    3e30:	fmadd	s29, s31, s27, s29
    3e34:	fmul	s31, s31, s29
    3e38:	b.mi	41a0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x950>  // b.first
    3e3c:	mov	w0, #0x42b00000            	// #1118830592
    3e40:	fmov	s29, w0
    3e44:	fcmpe	s30, s29
    3e48:	b.gt	3e68 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x618>
    3e4c:	mov	w7, #0xaa3b                	// #43579
    3e50:	movk	w7, #0x3fb8, lsl #16
    3e54:	fmov	s29, w7
    3e58:	fmul	s29, s30, s29
    3e5c:	fcmpe	s29, #0.0
    3e60:	b.ge	4264 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa14>  // b.tcont
    3e64:	b	3d20 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4d0>
    3e68:	mov	w0, #0x484f                	// #18511
    3e6c:	movk	w0, #0x7e46, lsl #16
    3e70:	fmov	s30, w0
    3e74:	fmul	s31, s31, s30
    3e78:	fmov	s30, #1.000000000000000000e+00
    3e7c:	fsub	s31, s30, s31
    3e80:	fnmul	s29, s25, s28
    3e84:	fmul	s31, s26, s31
    3e88:	movi	v30.2s, #0x0
    3e8c:	fcmpe	s29, s14
    3e90:	b.mi	3f40 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6f0>  // b.first
    3e94:	mov	w0, #0x42b00000            	// #1118830592
    3e98:	fmov	s30, w0
    3e9c:	fcmpe	s29, s30
    3ea0:	b.gt	41b4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x964>
    3ea4:	mov	w7, #0xaa3b                	// #43579
    3ea8:	movk	w7, #0x3fb8, lsl #16
    3eac:	fmov	s28, w7
    3eb0:	fmul	s28, s29, s28
    3eb4:	fcmpe	s28, #0.0
    3eb8:	b.ge	4304 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xab4>  // b.tcont
    3ebc:	fmov	s27, #5.000000000000000000e-01
    3ec0:	mov	w0, #0x7218                	// #29208
    3ec4:	mov	w3, #0xb61                 	// #2913
    3ec8:	movk	w0, #0x3f31, lsl #16
    3ecc:	mov	w2, #0x8889                	// #34953
    3ed0:	fmov	s30, #1.000000000000000000e+00
    3ed4:	movk	w3, #0x3ab6, lsl #16
    3ed8:	movk	w2, #0x3c08, lsl #16
    3edc:	fmov	s22, w0
    3ee0:	mov	w1, #0xaaab                	// #43691
    3ee4:	mov	w0, #0xaaab                	// #43691
    3ee8:	fsub	s28, s28, s27
    3eec:	movk	w1, #0x3d2a, lsl #16
    3ef0:	movk	w0, #0x3e2a, lsl #16
    3ef4:	fmov	s24, w2
    3ef8:	fmov	s23, w3
    3efc:	fmov	s25, w1
    3f00:	fmov	s26, w0
    3f04:	fcvtzs	s28, s28
    3f08:	scvtf	s28, s28
    3f0c:	fmsub	s29, s28, s22, s29
    3f10:	fcvtzs	w7, s28
    3f14:	fmadd	s28, s29, s23, s24
    3f18:	add	w7, w7, #0x7f
    3f1c:	fmov	s24, w7
    3f20:	fmadd	s28, s29, s28, s25
    3f24:	fmadd	s28, s29, s28, s26
    3f28:	shl	v24.2s, v24.2s, #23
    3f2c:	fmadd	s27, s29, s28, s27
    3f30:	fmadd	s27, s29, s27, s30
    3f34:	fmadd	s30, s29, s27, s30
    3f38:	fmul	s30, s30, s24
    3f3c:	nop
    3f40:	fcmpe	s15, #0.0
    3f44:	fmul	s26, s8, s30
    3f48:	b.mi	40a8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x858>  // b.first
    3f4c:	fmov	s30, #1.000000000000000000e+00
    3f50:	mov	w1, #0x8f89                	// #36745
    3f54:	mov	w0, #0x85fa                	// #34298
    3f58:	movk	w1, #0xbeb6, lsl #16
    3f5c:	movk	w0, #0x3ea3, lsl #16
    3f60:	fmov	s28, #-5.000000000000000000e-01
    3f64:	fmov	s27, w1
    3f68:	fmadd	s25, s15, s10, s30
    3f6c:	fmov	s29, w0
    3f70:	fmul	s28, s15, s28
    3f74:	fmul	s28, s28, s15
    3f78:	fdiv	s30, s30, s25
    3f7c:	fcmpe	s28, s14
    3f80:	fmadd	s25, s30, s11, s12
    3f84:	fmadd	s25, s30, s25, s13
    3f88:	fmadd	s27, s30, s25, s27
    3f8c:	fmadd	s29, s30, s27, s29
    3f90:	fmul	s30, s30, s29
    3f94:	b.mi	41ac <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x95c>  // b.first
    3f98:	mov	w0, #0x42b00000            	// #1118830592
    3f9c:	fmov	s29, w0
    3fa0:	fcmpe	s28, s29
    3fa4:	b.gt	4054 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x804>
    3fa8:	mov	w7, #0xaa3b                	// #43579
    3fac:	movk	w7, #0x3fb8, lsl #16
    3fb0:	fmov	s29, w7
    3fb4:	fmul	s29, s28, s29
    3fb8:	fcmpe	s29, #0.0
    3fbc:	b.ge	41c4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x974>  // b.tcont
    3fc0:	fmov	s25, #5.000000000000000000e-01
    3fc4:	mov	w0, #0x7218                	// #29208
    3fc8:	mov	w4, #0xb61                 	// #2913
    3fcc:	movk	w0, #0x3f31, lsl #16
    3fd0:	mov	w2, #0x8889                	// #34953
    3fd4:	fmov	s27, #1.000000000000000000e+00
    3fd8:	movk	w4, #0x3ab6, lsl #16
    3fdc:	movk	w2, #0x3c08, lsl #16
    3fe0:	fmov	s19, w0
    3fe4:	mov	w1, #0xaaab                	// #43691
    3fe8:	mov	w0, #0xaaab                	// #43691
    3fec:	fsub	s29, s29, s25
    3ff0:	movk	w1, #0x3d2a, lsl #16
    3ff4:	movk	w0, #0x3e2a, lsl #16
    3ff8:	fmov	s22, w2
    3ffc:	mov	w3, #0x422a                	// #16938
    4000:	fmov	s20, w4
    4004:	movk	w3, #0x3ecc, lsl #16
    4008:	fmov	s23, w1
    400c:	fmov	s24, w0
    4010:	fmov	s21, w3
    4014:	fcvtzs	s29, s29
    4018:	scvtf	s29, s29
    401c:	fmsub	s28, s29, s19, s28
    4020:	fcvtzs	w7, s29
    4024:	fmadd	s29, s28, s20, s22
    4028:	add	w7, w7, #0x7f
    402c:	fmov	s22, w7
    4030:	fmadd	s29, s28, s29, s23
    4034:	fmadd	s29, s28, s29, s24
    4038:	shl	v22.2s, v22.2s, #23
    403c:	fmadd	s25, s28, s29, s25
    4040:	fmadd	s25, s28, s25, s27
    4044:	fmadd	s29, s28, s25, s27
    4048:	fmul	s29, s29, s22
    404c:	fmul	s29, s29, s21
    4050:	b	4254 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa04>
    4054:	mov	w0, #0x484f                	// #18511
    4058:	movk	w0, #0x7e46, lsl #16
    405c:	fmov	s29, w0
    4060:	fmul	s30, s30, s29
    4064:	fmov	s29, #1.000000000000000000e+00
    4068:	fsub	s29, s29, s30
    406c:	fmsub	s31, s26, s29, s31
    4070:	str	s31, [x26, x19, lsl #2]
    4074:	add	x19, x19, #0x1
    4078:	cmp	x19, x24
    407c:	b.ne	3c38 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    4080:	ldp	d8, d9, [sp, #80]
    4084:	ldp	x19, x20, [sp, #16]
    4088:	ldp	x21, x22, [sp, #32]
    408c:	ldp	x23, x24, [sp, #48]
    4090:	ldp	x25, x26, [sp, #64]
    4094:	ldp	d10, d11, [sp, #96]
    4098:	ldp	d12, d13, [sp, #112]
    409c:	ldp	d14, d15, [sp, #128]
    40a0:	ldp	x29, x30, [sp], #160
    40a4:	ret
    40a8:	fmov	s29, #1.000000000000000000e+00
    40ac:	mov	w1, #0x8f89                	// #36745
    40b0:	mov	w0, #0x85fa                	// #34298
    40b4:	movk	w1, #0xbeb6, lsl #16
    40b8:	movk	w0, #0x3ea3, lsl #16
    40bc:	fmov	s28, #5.000000000000000000e-01
    40c0:	fmov	s27, w1
    40c4:	fmsub	s25, s15, s10, s29
    40c8:	fmov	s30, w0
    40cc:	fmul	s28, s15, s28
    40d0:	fnmul	s28, s15, s28
    40d4:	fdiv	s29, s29, s25
    40d8:	fcmpe	s28, s14
    40dc:	fmadd	s25, s29, s11, s12
    40e0:	fmadd	s25, s29, s25, s13
    40e4:	fmadd	s27, s29, s25, s27
    40e8:	fmadd	s30, s29, s27, s30
    40ec:	fmul	s30, s29, s30
    40f0:	b.mi	4110 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8c0>  // b.first
    40f4:	mov	w7, #0xaa3b                	// #43579
    40f8:	movk	w7, #0x3fb8, lsl #16
    40fc:	fmov	s29, w7
    4100:	fmul	s29, s28, s29
    4104:	fcmpe	s29, #0.0
    4108:	b.ge	41c4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x974>  // b.tcont
    410c:	b	3fc0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x770>
    4110:	movi	v29.2s, #0x0
    4114:	fmul	s30, s30, s29
    4118:	fmsub	s30, s26, s30, s31
    411c:	str	s30, [x26, x19, lsl #2]
    4120:	add	x19, x19, #0x1
    4124:	cmp	x24, x19
    4128:	b.ne	3c38 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    412c:	b	4080 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x830>
    4130:	fmov	s31, #1.000000000000000000e+00
    4134:	mov	w1, #0x8f89                	// #36745
    4138:	mov	w0, #0x85fa                	// #34298
    413c:	movk	w1, #0xbeb6, lsl #16
    4140:	movk	w0, #0x3ea3, lsl #16
    4144:	fmul	s30, s0, s30
    4148:	fmov	s27, w1
    414c:	fmsub	s24, s0, s10, s31
    4150:	fmov	s29, w0
    4154:	fnmul	s30, s0, s30
    4158:	fcmpe	s30, s14
    415c:	fdiv	s31, s31, s24
    4160:	fmadd	s24, s31, s11, s12
    4164:	fmadd	s24, s31, s24, s13
    4168:	fmadd	s27, s31, s24, s27
    416c:	fmadd	s29, s31, s27, s29
    4170:	fmul	s31, s31, s29
    4174:	b.mi	4194 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x944>  // b.first
    4178:	mov	w7, #0xaa3b                	// #43579
    417c:	movk	w7, #0x3fb8, lsl #16
    4180:	fmov	s29, w7
    4184:	fmul	s29, s30, s29
    4188:	fcmpe	s29, #0.0
    418c:	b.ge	4264 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa14>  // b.tcont
    4190:	b	3d20 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4d0>
    4194:	movi	v30.2s, #0x0
    4198:	fmul	s31, s31, s30
    419c:	b	3e80 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x630>
    41a0:	movi	v30.2s, #0x0
    41a4:	fmul	s31, s31, s30
    41a8:	b	3e78 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>
    41ac:	movi	v29.2s, #0x0
    41b0:	b	4060 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x810>
    41b4:	mov	w7, #0x829c                	// #33436
    41b8:	movk	w7, #0x7ef8, lsl #16
    41bc:	fmov	s30, w7
    41c0:	b	3f40 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6f0>
    41c4:	fmov	s24, #5.000000000000000000e-01
    41c8:	mov	w0, #0x7218                	// #29208
    41cc:	mov	w4, #0xb61                 	// #2913
    41d0:	movk	w0, #0x3f31, lsl #16
    41d4:	mov	w2, #0x8889                	// #34953
    41d8:	fmov	s27, #1.000000000000000000e+00
    41dc:	movk	w4, #0x3ab6, lsl #16
    41e0:	movk	w2, #0x3c08, lsl #16
    41e4:	fmov	s25, w0
    41e8:	mov	w1, #0xaaab                	// #43691
    41ec:	mov	w0, #0xaaab                	// #43691
    41f0:	fadd	s29, s29, s24
    41f4:	movk	w1, #0x3d2a, lsl #16
    41f8:	movk	w0, #0x3e2a, lsl #16
    41fc:	fmov	s19, w4
    4200:	mov	w3, #0x422a                	// #16938
    4204:	fmov	s21, w2
    4208:	movk	w3, #0x3ecc, lsl #16
    420c:	fmov	s22, w1
    4210:	fmov	s23, w0
    4214:	fmov	s20, w3
    4218:	fcvtzs	s29, s29
    421c:	scvtf	s29, s29
    4220:	fmsub	s28, s29, s25, s28
    4224:	fcvtzs	w7, s29
    4228:	fmadd	s29, s28, s19, s21
    422c:	add	w7, w7, #0x7f
    4230:	fmov	s25, w7
    4234:	fmadd	s29, s28, s29, s22
    4238:	fmadd	s29, s28, s29, s23
    423c:	shl	v25.2s, v25.2s, #23
    4240:	fmadd	s24, s28, s29, s24
    4244:	fmadd	s24, s28, s24, s27
    4248:	fmadd	s29, s28, s24, s27
    424c:	fmul	s29, s29, s25
    4250:	fmul	s29, s29, s20
    4254:	fcmpe	s15, #0.0
    4258:	fmul	s30, s30, s29
    425c:	b.mi	4118 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8c8>  // b.first
    4260:	b	4064 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x814>
    4264:	fmov	s23, #5.000000000000000000e-01
    4268:	mov	w0, #0x7218                	// #29208
    426c:	mov	w3, #0xb61                 	// #2913
    4270:	movk	w0, #0x3f31, lsl #16
    4274:	mov	w2, #0x8889                	// #34953
    4278:	fmov	s27, #1.000000000000000000e+00
    427c:	movk	w3, #0x3ab6, lsl #16
    4280:	movk	w2, #0x3c08, lsl #16
    4284:	fmov	s24, w0
    4288:	mov	w1, #0xaaab                	// #43691
    428c:	mov	w0, #0xaaab                	// #43691
    4290:	fadd	s29, s29, s23
    4294:	movk	w1, #0x3d2a, lsl #16
    4298:	movk	w0, #0x3e2a, lsl #16
    429c:	fmov	s18, w3
    42a0:	mov	w4, #0x422a                	// #16938
    42a4:	fmov	s20, w2
    42a8:	movk	w4, #0x3ecc, lsl #16
    42ac:	fmov	s21, w1
    42b0:	fmov	s22, w0
    42b4:	fmov	s19, w4
    42b8:	fcvtzs	s29, s29
    42bc:	scvtf	s29, s29
    42c0:	fmsub	s30, s29, s24, s30
    42c4:	fcvtzs	w7, s29
    42c8:	fmadd	s29, s30, s18, s20
    42cc:	add	w7, w7, #0x7f
    42d0:	fmov	s24, w7
    42d4:	fmadd	s29, s30, s29, s21
    42d8:	fmadd	s29, s30, s29, s22
    42dc:	shl	v24.2s, v24.2s, #23
    42e0:	fmadd	s23, s30, s29, s23
    42e4:	fmadd	s23, s30, s23, s27
    42e8:	fmadd	s30, s30, s23, s27
    42ec:	fmul	s30, s30, s24
    42f0:	fmul	s30, s30, s19
    42f4:	fcmpe	s0, #0.0
    42f8:	fmul	s31, s31, s30
    42fc:	b.mi	3e80 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x630>  // b.first
    4300:	b	3e78 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>
    4304:	fmov	s26, #5.000000000000000000e-01
    4308:	mov	w0, #0x7218                	// #29208
    430c:	mov	w3, #0xb61                 	// #2913
    4310:	movk	w0, #0x3f31, lsl #16
    4314:	mov	w2, #0x8889                	// #34953
    4318:	fmov	s30, #1.000000000000000000e+00
    431c:	movk	w3, #0x3ab6, lsl #16
    4320:	movk	w2, #0x3c08, lsl #16
    4324:	fmov	s27, w0
    4328:	mov	w1, #0xaaab                	// #43691
    432c:	mov	w0, #0xaaab                	// #43691
    4330:	fadd	s28, s28, s26
    4334:	movk	w1, #0x3d2a, lsl #16
    4338:	movk	w0, #0x3e2a, lsl #16
    433c:	fmov	s22, w3
    4340:	fmov	s23, w2
    4344:	fmov	s24, w1
    4348:	fmov	s25, w0
    434c:	fcvtzs	s28, s28
    4350:	scvtf	s28, s28
    4354:	fmsub	s29, s28, s27, s29
    4358:	fcvtzs	w7, s28
    435c:	fmadd	s28, s29, s22, s23
    4360:	add	w7, w7, #0x7f
    4364:	fmov	s27, w7
    4368:	fmadd	s28, s29, s28, s24
    436c:	fmadd	s28, s29, s28, s25
    4370:	shl	v27.2s, v27.2s, #23
    4374:	fmadd	s26, s29, s28, s26
    4378:	fmadd	s26, s29, s26, s30
    437c:	fmadd	s30, s29, s26, s30
    4380:	fmul	s30, s30, s27
    4384:	b	3f40 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6f0>
    4388:	mov	x19, #0x0                   	// #0
    438c:	b	3bf8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a8>
    4390:	nop
    4394:	nop
    4398:	nop
    439c:	nop
