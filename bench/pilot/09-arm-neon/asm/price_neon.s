00000000000036a0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    36a0:	stp	x29, x30, [sp, #-160]!
    36a4:	mov	x29, sp
    36a8:	stp	x19, x20, [sp, #16]
    36ac:	mov	x20, x0
    36b0:	stp	x21, x22, [sp, #32]
    36b4:	mov	x21, x1
    36b8:	mov	x22, x2
    36bc:	stp	x23, x24, [sp, #48]
    36c0:	mov	x24, x6
    36c4:	mov	x23, x3
    36c8:	stp	x25, x26, [sp, #64]
    36cc:	mov	x25, x4
    36d0:	mov	x26, x5
    36d4:	stp	d8, d9, [sp, #80]
    36d8:	stp	d10, d11, [sp, #96]
    36dc:	stp	d12, d13, [sp, #112]
    36e0:	stp	d14, d15, [sp, #128]
    36e4:	cmp	x6, #0x3
    36e8:	b.ls	41cc <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xb2c>  // b.plast
    36ec:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    36f0:	sub	x19, x6, #0x4
    36f4:	and	x0, x19, #0xfffffffffffffffc
    36f8:	mov	x7, #0x0                   	// #0
    36fc:	ldr	q20, [x1, #1552]
    3700:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3704:	mov	x8, #0x0                   	// #0
    3708:	add	x0, x0, #0x4
    370c:	ldr	q1, [x1, #1568]
    3710:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3714:	ldr	q11, [x1, #1584]
    3718:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    371c:	ldr	q12, [x1, #1600]
    3720:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3724:	ldr	q13, [x1, #1616]
    3728:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    372c:	ldr	q14, [x1, #1632]
    3730:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3734:	ldr	q15, [x1, #1648]
    3738:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    373c:	ldr	q4, [x1, #1664]
    3740:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3744:	ldr	q5, [x1, #1680]
    3748:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    374c:	ldr	q6, [x1, #1696]
    3750:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3754:	ldr	q7, [x1, #1712]
    3758:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    375c:	ldr	q16, [x1, #1728]
    3760:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3764:	ldr	q17, [x1, #1744]
    3768:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    376c:	ldr	q18, [x1, #1760]
    3770:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3774:	movi	v26.4s, #0x7f, msl #16
    3778:	fmov	v25.4s, #5.000000000000000000e-01
    377c:	ldr	q9, [x21, x7]
    3780:	movi	v23.4s, #0x7f
    3784:	fmov	v31.4s, #-1.000000000000000000e+00
    3788:	fmov	v29.4s, #1.000000000000000000e+00
    378c:	fmov	v10.4s, #-5.000000000000000000e-01
    3790:	add	x8, x8, #0x4
    3794:	ldr	q30, [x20, x7]
    3798:	mov	v0.16b, v25.16b
    379c:	ldr	q19, [x1, #1776]
    37a0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    37a4:	ldr	q24, [x1, #1792]
    37a8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    37ac:	fdiv	v27.4s, v30.4s, v9.4s
    37b0:	ldr	q21, [x22, x7]
    37b4:	ldr	q22, [x23, x7]
    37b8:	and	v26.16b, v26.16b, v27.16b
    37bc:	sshr	v27.4s, v27.4s, #23
    37c0:	ldr	q30, [x25, x7]
    37c4:	orr	v26.16b, v26.16b, v24.16b
    37c8:	ldr	q24, [x1, #1808]
    37cc:	sub	v27.4s, v27.4s, v23.4s
    37d0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    37d4:	fmul	v28.4s, v21.4s, v22.4s
    37d8:	fmul	v3.4s, v30.4s, v30.4s
    37dc:	fcmge	v8.4s, v26.4s, v24.4s
    37e0:	fmul	v24.4s, v25.4s, v26.4s
    37e4:	fneg	v28.4s, v28.4s
    37e8:	fmla	v22.4s, v25.4s, v3.4s
    37ec:	bit	v26.16b, v24.16b, v8.16b
    37f0:	sub	v27.4s, v27.4s, v8.4s
    37f4:	ldr	q8, [x1, #1824]
    37f8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    37fc:	fmax	v28.4s, v28.4s, v4.4s
    3800:	ldr	q24, [x1, #1840]
    3804:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3808:	fadd	v31.4s, v31.4s, v26.4s
    380c:	fsqrt	v26.4s, v21.4s
    3810:	scvtf	v27.4s, v27.4s
    3814:	fmin	v28.4s, v28.4s, v5.4s
    3818:	fmul	v30.4s, v30.4s, v26.4s
    381c:	fmla	v8.4s, v24.4s, v31.4s
    3820:	ldr	q24, [x1, #1856]
    3824:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3828:	fmul	v26.4s, v28.4s, v6.4s
    382c:	fmla	v24.4s, v8.4s, v31.4s
    3830:	ldr	q8, [x1, #1872]
    3834:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3838:	frintn	v26.4s, v26.4s
    383c:	fmla	v8.4s, v24.4s, v31.4s
    3840:	ldr	q24, [x1, #1888]
    3844:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3848:	ldr	q3, [x1, #1904]
    384c:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    3850:	fmls	v28.4s, v26.4s, v20.4s
    3854:	fmla	v24.4s, v8.4s, v31.4s
    3858:	mov	v8.16b, v16.16b
    385c:	fcvtzs	v26.4s, v26.4s
    3860:	fmla	v3.4s, v24.4s, v31.4s
    3864:	ldr	q24, [x1, #1920]
    3868:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    386c:	fmla	v8.4s, v7.4s, v28.4s
    3870:	add	v26.4s, v26.4s, v23.4s
    3874:	fmla	v24.4s, v3.4s, v31.4s
    3878:	mov	v3.16b, v17.16b
    387c:	shl	v26.4s, v26.4s, #23
    3880:	fmla	v3.4s, v8.4s, v28.4s
    3884:	ldr	q8, [x1, #1936]
    3888:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    388c:	ldr	q2, [x1, #1952]
    3890:	fmla	v8.4s, v24.4s, v31.4s
    3894:	mov	v24.16b, v18.16b
    3898:	fmla	v2.4s, v8.4s, v31.4s
    389c:	fmla	v24.4s, v3.4s, v28.4s
    38a0:	mov	v3.16b, v29.16b
    38a4:	fmul	v8.4s, v31.4s, v31.4s
    38a8:	fmla	v0.4s, v24.4s, v28.4s
    38ac:	fmul	v24.4s, v31.4s, v8.4s
    38b0:	fmla	v3.4s, v0.4s, v28.4s
    38b4:	fmul	v24.4s, v24.4s, v2.4s
    38b8:	mov	v2.16b, v29.16b
    38bc:	fmls	v24.4s, v8.4s, v25.4s
    38c0:	mov	v8.16b, v12.16b
    38c4:	fmla	v2.4s, v3.4s, v28.4s
    38c8:	mov	v3.16b, v16.16b
    38cc:	fadd	v31.4s, v31.4s, v24.4s
    38d0:	fmul	v26.4s, v2.4s, v26.4s
    38d4:	mov	v2.16b, v18.16b
    38d8:	fmla	v31.4s, v27.4s, v20.4s
    38dc:	fmul	v26.4s, v26.4s, v9.4s
    38e0:	mov	v9.16b, v13.16b
    38e4:	fmla	v31.4s, v22.4s, v21.4s
    38e8:	mov	v21.16b, v29.16b
    38ec:	fdiv	v31.4s, v31.4s, v30.4s
    38f0:	fsub	v30.4s, v31.4s, v30.4s
    38f4:	fmul	v27.4s, v31.4s, v31.4s
    38f8:	fabs	v24.4s, v31.4s
    38fc:	fcmlt	v31.4s, v31.4s, #0.0
    3900:	fmul	v28.4s, v30.4s, v30.4s
    3904:	fmul	v27.4s, v27.4s, v10.4s
    3908:	fmla	v21.4s, v1.4s, v24.4s
    390c:	fabs	v22.4s, v30.4s
    3910:	mov	v24.16b, v29.16b
    3914:	fmul	v28.4s, v28.4s, v10.4s
    3918:	fmax	v27.4s, v27.4s, v4.4s
    391c:	fcmlt	v30.4s, v30.4s, #0.0
    3920:	fmla	v24.4s, v1.4s, v22.4s
    3924:	fmax	v28.4s, v28.4s, v4.4s
    3928:	fmin	v27.4s, v27.4s, v5.4s
    392c:	fdiv	v21.4s, v29.4s, v21.4s
    3930:	fmin	v28.4s, v28.4s, v5.4s
    3934:	fmul	v22.4s, v27.4s, v6.4s
    3938:	fmla	v8.4s, v11.4s, v21.4s
    393c:	fdiv	v24.4s, v29.4s, v24.4s
    3940:	fmul	v10.4s, v28.4s, v6.4s
    3944:	frintn	v22.4s, v22.4s
    3948:	fmla	v9.4s, v8.4s, v21.4s
    394c:	mov	v8.16b, v14.16b
    3950:	frintn	v10.4s, v10.4s
    3954:	fmls	v27.4s, v22.4s, v20.4s
    3958:	fmla	v8.4s, v9.4s, v21.4s
    395c:	mov	v9.16b, v15.16b
    3960:	fmls	v28.4s, v10.4s, v20.4s
    3964:	fcvtzs	v22.4s, v22.4s
    3968:	fcvtzs	v10.4s, v10.4s
    396c:	fmla	v3.4s, v7.4s, v27.4s
    3970:	fmla	v9.4s, v8.4s, v21.4s
    3974:	mov	v8.16b, v17.16b
    3978:	add	v22.4s, v22.4s, v23.4s
    397c:	add	v10.4s, v10.4s, v23.4s
    3980:	mov	v23.16b, v16.16b
    3984:	fmla	v8.4s, v3.4s, v27.4s
    3988:	mov	v3.16b, v18.16b
    398c:	fmla	v23.4s, v7.4s, v28.4s
    3990:	shl	v22.4s, v22.4s, #23
    3994:	fmla	v3.4s, v8.4s, v27.4s
    3998:	mov	v8.16b, v17.16b
    399c:	shl	v10.4s, v10.4s, #23
    39a0:	fmul	v21.4s, v21.4s, v9.4s
    39a4:	fmla	v8.4s, v23.4s, v28.4s
    39a8:	mov	v23.16b, v25.16b
    39ac:	fmla	v23.4s, v3.4s, v27.4s
    39b0:	mov	v3.16b, v29.16b
    39b4:	fmla	v2.4s, v8.4s, v28.4s
    39b8:	mov	v8.16b, v12.16b
    39bc:	fmla	v3.4s, v23.4s, v27.4s
    39c0:	mov	v23.16b, v29.16b
    39c4:	fmla	v25.4s, v2.4s, v28.4s
    39c8:	fmla	v23.4s, v3.4s, v27.4s
    39cc:	mov	v3.16b, v29.16b
    39d0:	mov	v27.16b, v29.16b
    39d4:	fmla	v8.4s, v11.4s, v24.4s
    39d8:	fmla	v3.4s, v25.4s, v28.4s
    39dc:	mov	v25.16b, v13.16b
    39e0:	fmla	v25.4s, v8.4s, v24.4s
    39e4:	fmla	v27.4s, v3.4s, v28.4s
    39e8:	mov	v28.16b, v14.16b
    39ec:	fmla	v28.4s, v25.4s, v24.4s
    39f0:	fmul	v25.4s, v23.4s, v22.4s
    39f4:	mov	v23.16b, v15.16b
    39f8:	fmla	v23.4s, v28.4s, v24.4s
    39fc:	fmul	v25.4s, v25.4s, v19.4s
    3a00:	fmul	v28.4s, v27.4s, v10.4s
    3a04:	fmul	v27.4s, v25.4s, v21.4s
    3a08:	fmul	v28.4s, v28.4s, v19.4s
    3a0c:	fmul	v24.4s, v24.4s, v23.4s
    3a10:	fsub	v25.4s, v29.4s, v27.4s
    3a14:	fmul	v24.4s, v28.4s, v24.4s
    3a18:	ldr	q28, [x20, x7]
    3a1c:	bsl	v31.16b, v27.16b, v25.16b
    3a20:	fsub	v29.4s, v29.4s, v24.4s
    3a24:	fmul	v31.4s, v28.4s, v31.4s
    3a28:	bsl	v30.16b, v24.16b, v29.16b
    3a2c:	fmls	v31.4s, v26.4s, v30.4s
    3a30:	str	q31, [x26, x7]
    3a34:	add	x7, x7, #0x10
    3a38:	cmp	x8, x0
    3a3c:	b.ne	3770 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xd0>  // b.any
    3a40:	and	x19, x19, #0xfffffffffffffffc
    3a44:	add	x19, x19, #0x4
    3a48:	cmp	x24, x19
    3a4c:	b.ls	3ec4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>  // b.plast
    3a50:	mov	w4, #0x3389                	// #13193
    3a54:	mov	w3, #0x466f                	// #18031
    3a58:	mov	w2, #0x1eea                	// #7914
    3a5c:	mov	w1, #0x778                 	// #1912
    3a60:	movk	w4, #0x3e6d, lsl #16
    3a64:	movk	w3, #0x3faa, lsl #16
    3a68:	movk	w2, #0xbfe9, lsl #16
    3a6c:	movk	w1, #0x3fe4, lsl #16
    3a70:	mov	w0, #0xc2b00000            	// #-1028653056
    3a74:	fmov	s10, w4
    3a78:	fmov	s11, w3
    3a7c:	fmov	s12, w2
    3a80:	fmov	s13, w1
    3a84:	fmov	s14, w0
    3a88:	ldr	s28, [x22, x19, lsl #2]
    3a8c:	ldr	s15, [x25, x19, lsl #2]
    3a90:	ldr	s26, [x20, x19, lsl #2]
    3a94:	fcmp	s28, #0.0
    3a98:	ldr	s8, [x21, x19, lsl #2]
    3a9c:	ldr	s25, [x23, x19, lsl #2]
    3aa0:	fmul	s9, s15, s15
    3aa4:	b.pl	3bfc <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.nfrst
    3aa8:	fmov	s0, s28
    3aac:	stp	s26, s28, [sp, #148]
    3ab0:	str	s25, [sp, #156]
    3ab4:	bl	ec0 <sqrtf@plt>
    3ab8:	ldr	s26, [sp, #148]
    3abc:	fmul	s15, s15, s0
    3ac0:	fdiv	s0, s26, s8
    3ac4:	bl	1020 <logf@plt>
    3ac8:	ldr	s25, [sp, #156]
    3acc:	fmov	s31, #5.000000000000000000e-01
    3ad0:	mov	w0, #0x3389                	// #13193
    3ad4:	movk	w0, #0x3e6d, lsl #16
    3ad8:	fmov	s27, #1.000000000000000000e+00
    3adc:	mov	w1, #0x466f                	// #18031
    3ae0:	ldp	s26, s28, [sp, #148]
    3ae4:	mov	w3, #0x1eea                	// #7914
    3ae8:	movk	w1, #0x3faa, lsl #16
    3aec:	fmov	s30, w0
    3af0:	movk	w3, #0xbfe9, lsl #16
    3af4:	mov	w2, #0x778                 	// #1912
    3af8:	fmov	s20, w1
    3afc:	movk	w2, #0x3fe4, lsl #16
    3b00:	mov	w1, #0x8f89                	// #36745
    3b04:	fmov	s22, w3
    3b08:	movk	w1, #0xbeb6, lsl #16
    3b0c:	mov	w0, #0x85fa                	// #34298
    3b10:	fmadd	s9, s9, s31, s25
    3b14:	movk	w0, #0x3ea3, lsl #16
    3b18:	mov	w7, #0xaa3b                	// #43579
    3b1c:	fmov	s23, w2
    3b20:	fmov	s19, #-5.000000000000000000e-01
    3b24:	movk	w7, #0x3fb8, lsl #16
    3b28:	fmov	s24, w1
    3b2c:	fmov	s31, w0
    3b30:	fmadd	s0, s28, s9, s0
    3b34:	fmov	s29, w7
    3b38:	fdiv	s0, s0, s15
    3b3c:	fmadd	s21, s0, s30, s27
    3b40:	fmul	s30, s0, s19
    3b44:	fsub	s15, s0, s15
    3b48:	fmul	s30, s30, s0
    3b4c:	fdiv	s27, s27, s21
    3b50:	fmul	s29, s30, s29
    3b54:	fmadd	s22, s27, s20, s22
    3b58:	fmadd	s23, s22, s27, s23
    3b5c:	fmadd	s24, s23, s27, s24
    3b60:	fmadd	s31, s24, s27, s31
    3b64:	fmul	s31, s31, s27
    3b68:	fmov	s24, #5.000000000000000000e-01
    3b6c:	mov	w0, #0x7218                	// #29208
    3b70:	mov	w3, #0xb61                 	// #2913
    3b74:	movk	w0, #0x3f31, lsl #16
    3b78:	mov	w2, #0x8889                	// #34953
    3b7c:	fmov	s27, #1.000000000000000000e+00
    3b80:	movk	w3, #0x3ab6, lsl #16
    3b84:	movk	w2, #0x3c08, lsl #16
    3b88:	fmov	s18, w0
    3b8c:	mov	w1, #0xaaab                	// #43691
    3b90:	mov	w0, #0xaaab                	// #43691
    3b94:	fsub	s29, s29, s24
    3b98:	movk	w1, #0x3d2a, lsl #16
    3b9c:	movk	w0, #0x3e2a, lsl #16
    3ba0:	fmov	s21, w2
    3ba4:	mov	w4, #0x422a                	// #16938
    3ba8:	fmov	s19, w3
    3bac:	movk	w4, #0x3ecc, lsl #16
    3bb0:	fmov	s22, w1
    3bb4:	fmov	s23, w0
    3bb8:	fmov	s20, w4
    3bbc:	fcvtzs	s29, s29
    3bc0:	scvtf	s29, s29
    3bc4:	fmsub	s30, s29, s18, s30
    3bc8:	fcvtzs	w7, s29
    3bcc:	fmadd	s29, s30, s19, s21
    3bd0:	add	w7, w7, #0x7f
    3bd4:	fmov	s21, w7
    3bd8:	fmadd	s29, s30, s29, s22
    3bdc:	fmadd	s29, s30, s29, s23
    3be0:	shl	v21.2s, v21.2s, #23
    3be4:	fmadd	s24, s30, s29, s24
    3be8:	fmadd	s24, s30, s24, s27
    3bec:	fmadd	s30, s30, s24, s27
    3bf0:	fmul	s30, s30, s21
    3bf4:	fmul	s30, s30, s20
    3bf8:	b	4138 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa98>
    3bfc:	fsqrt	s29, s28
    3c00:	stp	s26, s28, [sp, #148]
    3c04:	str	s25, [sp, #156]
    3c08:	fdiv	s0, s26, s8
    3c0c:	fmul	s15, s15, s29
    3c10:	bl	1020 <logf@plt>
    3c14:	ldr	s25, [sp, #156]
    3c18:	fmov	s30, #5.000000000000000000e-01
    3c1c:	ldp	s26, s28, [sp, #148]
    3c20:	fmadd	s9, s9, s30, s25
    3c24:	fmadd	s0, s28, s9, s0
    3c28:	fdiv	s0, s0, s15
    3c2c:	fcmpe	s0, #0.0
    3c30:	fsub	s15, s0, s15
    3c34:	b.mi	3f74 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8d4>  // b.first
    3c38:	fmov	s31, #1.000000000000000000e+00
    3c3c:	mov	w1, #0x8f89                	// #36745
    3c40:	mov	w0, #0x85fa                	// #34298
    3c44:	movk	w1, #0xbeb6, lsl #16
    3c48:	movk	w0, #0x3ea3, lsl #16
    3c4c:	fmov	s30, #-5.000000000000000000e-01
    3c50:	fmov	s27, w1
    3c54:	fmadd	s24, s0, s10, s31
    3c58:	fmov	s29, w0
    3c5c:	fmul	s30, s0, s30
    3c60:	fmul	s30, s30, s0
    3c64:	fdiv	s31, s31, s24
    3c68:	fcmpe	s30, s14
    3c6c:	fmadd	s24, s31, s11, s12
    3c70:	fmadd	s24, s31, s24, s13
    3c74:	fmadd	s27, s31, s24, s27
    3c78:	fmadd	s29, s31, s27, s29
    3c7c:	fmul	s31, s31, s29
    3c80:	b.mi	3fe4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x944>  // b.first
    3c84:	mov	w0, #0x42b00000            	// #1118830592
    3c88:	fmov	s29, w0
    3c8c:	fcmpe	s30, s29
    3c90:	b.gt	3cb0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x610>
    3c94:	mov	w7, #0xaa3b                	// #43579
    3c98:	movk	w7, #0x3fb8, lsl #16
    3c9c:	fmov	s29, w7
    3ca0:	fmul	s29, s30, s29
    3ca4:	fcmpe	s29, #0.0
    3ca8:	b.ge	40a8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    3cac:	b	3b68 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    3cb0:	mov	w0, #0x484f                	// #18511
    3cb4:	movk	w0, #0x7e46, lsl #16
    3cb8:	fmov	s30, w0
    3cbc:	fmul	s31, s31, s30
    3cc0:	fmov	s30, #1.000000000000000000e+00
    3cc4:	fsub	s31, s30, s31
    3cc8:	fnmul	s29, s25, s28
    3ccc:	fmul	s31, s26, s31
    3cd0:	movi	v30.2s, #0x0
    3cd4:	fcmpe	s29, s14
    3cd8:	b.mi	3d84 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>  // b.first
    3cdc:	mov	w0, #0x42b00000            	// #1118830592
    3ce0:	fmov	s30, w0
    3ce4:	fcmpe	s29, s30
    3ce8:	b.gt	3ff8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x958>
    3cec:	mov	w7, #0xaa3b                	// #43579
    3cf0:	movk	w7, #0x3fb8, lsl #16
    3cf4:	fmov	s28, w7
    3cf8:	fmul	s28, s29, s28
    3cfc:	fcmpe	s28, #0.0
    3d00:	b.ge	4148 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xaa8>  // b.tcont
    3d04:	fmov	s27, #5.000000000000000000e-01
    3d08:	mov	w0, #0x7218                	// #29208
    3d0c:	mov	w3, #0xb61                 	// #2913
    3d10:	movk	w0, #0x3f31, lsl #16
    3d14:	mov	w2, #0x8889                	// #34953
    3d18:	fmov	s30, #1.000000000000000000e+00
    3d1c:	movk	w3, #0x3ab6, lsl #16
    3d20:	movk	w2, #0x3c08, lsl #16
    3d24:	fmov	s22, w0
    3d28:	mov	w1, #0xaaab                	// #43691
    3d2c:	mov	w0, #0xaaab                	// #43691
    3d30:	fsub	s28, s28, s27
    3d34:	movk	w1, #0x3d2a, lsl #16
    3d38:	movk	w0, #0x3e2a, lsl #16
    3d3c:	fmov	s24, w2
    3d40:	fmov	s23, w3
    3d44:	fmov	s25, w1
    3d48:	fmov	s26, w0
    3d4c:	fcvtzs	s28, s28
    3d50:	scvtf	s28, s28
    3d54:	fmsub	s29, s28, s22, s29
    3d58:	fcvtzs	w7, s28
    3d5c:	fmadd	s28, s29, s23, s24
    3d60:	add	w7, w7, #0x7f
    3d64:	fmov	s24, w7
    3d68:	fmadd	s28, s29, s28, s25
    3d6c:	fmadd	s28, s29, s28, s26
    3d70:	shl	v24.2s, v24.2s, #23
    3d74:	fmadd	s27, s29, s28, s27
    3d78:	fmadd	s27, s29, s27, s30
    3d7c:	fmadd	s30, s29, s27, s30
    3d80:	fmul	s30, s30, s24
    3d84:	fcmpe	s15, #0.0
    3d88:	fmul	s26, s8, s30
    3d8c:	b.mi	3eec <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x84c>  // b.first
    3d90:	fmov	s30, #1.000000000000000000e+00
    3d94:	mov	w1, #0x8f89                	// #36745
    3d98:	mov	w0, #0x85fa                	// #34298
    3d9c:	movk	w1, #0xbeb6, lsl #16
    3da0:	movk	w0, #0x3ea3, lsl #16
    3da4:	fmov	s28, #-5.000000000000000000e-01
    3da8:	fmov	s27, w1
    3dac:	fmadd	s25, s15, s10, s30
    3db0:	fmov	s29, w0
    3db4:	fmul	s28, s15, s28
    3db8:	fmul	s28, s28, s15
    3dbc:	fdiv	s30, s30, s25
    3dc0:	fcmpe	s28, s14
    3dc4:	fmadd	s25, s30, s11, s12
    3dc8:	fmadd	s25, s30, s25, s13
    3dcc:	fmadd	s27, s30, s25, s27
    3dd0:	fmadd	s29, s30, s27, s29
    3dd4:	fmul	s30, s30, s29
    3dd8:	b.mi	3ff0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x950>  // b.first
    3ddc:	mov	w0, #0x42b00000            	// #1118830592
    3de0:	fmov	s29, w0
    3de4:	fcmpe	s28, s29
    3de8:	b.gt	3e98 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7f8>
    3dec:	mov	w7, #0xaa3b                	// #43579
    3df0:	movk	w7, #0x3fb8, lsl #16
    3df4:	fmov	s29, w7
    3df8:	fmul	s29, s28, s29
    3dfc:	fcmpe	s29, #0.0
    3e00:	b.ge	4008 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    3e04:	fmov	s25, #5.000000000000000000e-01
    3e08:	mov	w0, #0x7218                	// #29208
    3e0c:	mov	w4, #0xb61                 	// #2913
    3e10:	movk	w0, #0x3f31, lsl #16
    3e14:	mov	w2, #0x8889                	// #34953
    3e18:	fmov	s27, #1.000000000000000000e+00
    3e1c:	movk	w4, #0x3ab6, lsl #16
    3e20:	movk	w2, #0x3c08, lsl #16
    3e24:	fmov	s19, w0
    3e28:	mov	w1, #0xaaab                	// #43691
    3e2c:	mov	w0, #0xaaab                	// #43691
    3e30:	fsub	s29, s29, s25
    3e34:	movk	w1, #0x3d2a, lsl #16
    3e38:	movk	w0, #0x3e2a, lsl #16
    3e3c:	fmov	s22, w2
    3e40:	mov	w3, #0x422a                	// #16938
    3e44:	fmov	s20, w4
    3e48:	movk	w3, #0x3ecc, lsl #16
    3e4c:	fmov	s23, w1
    3e50:	fmov	s24, w0
    3e54:	fmov	s21, w3
    3e58:	fcvtzs	s29, s29
    3e5c:	scvtf	s29, s29
    3e60:	fmsub	s28, s29, s19, s28
    3e64:	fcvtzs	w7, s29
    3e68:	fmadd	s29, s28, s20, s22
    3e6c:	add	w7, w7, #0x7f
    3e70:	fmov	s22, w7
    3e74:	fmadd	s29, s28, s29, s23
    3e78:	fmadd	s29, s28, s29, s24
    3e7c:	shl	v22.2s, v22.2s, #23
    3e80:	fmadd	s25, s28, s29, s25
    3e84:	fmadd	s25, s28, s25, s27
    3e88:	fmadd	s29, s28, s25, s27
    3e8c:	fmul	s29, s29, s22
    3e90:	fmul	s29, s29, s21
    3e94:	b	4098 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x9f8>
    3e98:	mov	w0, #0x484f                	// #18511
    3e9c:	movk	w0, #0x7e46, lsl #16
    3ea0:	fmov	s29, w0
    3ea4:	fmul	s30, s30, s29
    3ea8:	fmov	s29, #1.000000000000000000e+00
    3eac:	fsub	s29, s29, s30
    3eb0:	fmsub	s31, s26, s29, s31
    3eb4:	str	s31, [x26, x19, lsl #2]
    3eb8:	add	x19, x19, #0x1
    3ebc:	cmp	x19, x24
    3ec0:	b.ne	3a88 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    3ec4:	ldp	d8, d9, [sp, #80]
    3ec8:	ldp	x19, x20, [sp, #16]
    3ecc:	ldp	x21, x22, [sp, #32]
    3ed0:	ldp	x23, x24, [sp, #48]
    3ed4:	ldp	x25, x26, [sp, #64]
    3ed8:	ldp	d10, d11, [sp, #96]
    3edc:	ldp	d12, d13, [sp, #112]
    3ee0:	ldp	d14, d15, [sp, #128]
    3ee4:	ldp	x29, x30, [sp], #160
    3ee8:	ret
    3eec:	fmov	s29, #1.000000000000000000e+00
    3ef0:	mov	w1, #0x8f89                	// #36745
    3ef4:	mov	w0, #0x85fa                	// #34298
    3ef8:	movk	w1, #0xbeb6, lsl #16
    3efc:	movk	w0, #0x3ea3, lsl #16
    3f00:	fmov	s28, #5.000000000000000000e-01
    3f04:	fmov	s27, w1
    3f08:	fmsub	s25, s15, s10, s29
    3f0c:	fmov	s30, w0
    3f10:	fmul	s28, s15, s28
    3f14:	fnmul	s28, s15, s28
    3f18:	fdiv	s29, s29, s25
    3f1c:	fcmpe	s28, s14
    3f20:	fmadd	s25, s29, s11, s12
    3f24:	fmadd	s25, s29, s25, s13
    3f28:	fmadd	s27, s29, s25, s27
    3f2c:	fmadd	s30, s29, s27, s30
    3f30:	fmul	s30, s29, s30
    3f34:	b.mi	3f54 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8b4>  // b.first
    3f38:	mov	w7, #0xaa3b                	// #43579
    3f3c:	movk	w7, #0x3fb8, lsl #16
    3f40:	fmov	s29, w7
    3f44:	fmul	s29, s28, s29
    3f48:	fcmpe	s29, #0.0
    3f4c:	b.ge	4008 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    3f50:	b	3e04 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x764>
    3f54:	movi	v29.2s, #0x0
    3f58:	fmul	s30, s30, s29
    3f5c:	fmsub	s30, s26, s30, s31
    3f60:	str	s30, [x26, x19, lsl #2]
    3f64:	add	x19, x19, #0x1
    3f68:	cmp	x24, x19
    3f6c:	b.ne	3a88 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    3f70:	b	3ec4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>
    3f74:	fmov	s31, #1.000000000000000000e+00
    3f78:	mov	w1, #0x8f89                	// #36745
    3f7c:	mov	w0, #0x85fa                	// #34298
    3f80:	movk	w1, #0xbeb6, lsl #16
    3f84:	movk	w0, #0x3ea3, lsl #16
    3f88:	fmul	s30, s0, s30
    3f8c:	fmov	s27, w1
    3f90:	fmsub	s24, s0, s10, s31
    3f94:	fmov	s29, w0
    3f98:	fnmul	s30, s0, s30
    3f9c:	fcmpe	s30, s14
    3fa0:	fdiv	s31, s31, s24
    3fa4:	fmadd	s24, s31, s11, s12
    3fa8:	fmadd	s24, s31, s24, s13
    3fac:	fmadd	s27, s31, s24, s27
    3fb0:	fmadd	s29, s31, s27, s29
    3fb4:	fmul	s31, s31, s29
    3fb8:	b.mi	3fd8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x938>  // b.first
    3fbc:	mov	w7, #0xaa3b                	// #43579
    3fc0:	movk	w7, #0x3fb8, lsl #16
    3fc4:	fmov	s29, w7
    3fc8:	fmul	s29, s30, s29
    3fcc:	fcmpe	s29, #0.0
    3fd0:	b.ge	40a8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    3fd4:	b	3b68 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    3fd8:	movi	v30.2s, #0x0
    3fdc:	fmul	s31, s31, s30
    3fe0:	b	3cc8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>
    3fe4:	movi	v30.2s, #0x0
    3fe8:	fmul	s31, s31, s30
    3fec:	b	3cc0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    3ff0:	movi	v29.2s, #0x0
    3ff4:	b	3ea4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x804>
    3ff8:	mov	w7, #0x829c                	// #33436
    3ffc:	movk	w7, #0x7ef8, lsl #16
    4000:	fmov	s30, w7
    4004:	b	3d84 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    4008:	fmov	s24, #5.000000000000000000e-01
    400c:	mov	w0, #0x7218                	// #29208
    4010:	mov	w4, #0xb61                 	// #2913
    4014:	movk	w0, #0x3f31, lsl #16
    4018:	mov	w2, #0x8889                	// #34953
    401c:	fmov	s27, #1.000000000000000000e+00
    4020:	movk	w4, #0x3ab6, lsl #16
    4024:	movk	w2, #0x3c08, lsl #16
    4028:	fmov	s25, w0
    402c:	mov	w1, #0xaaab                	// #43691
    4030:	mov	w0, #0xaaab                	// #43691
    4034:	fadd	s29, s29, s24
    4038:	movk	w1, #0x3d2a, lsl #16
    403c:	movk	w0, #0x3e2a, lsl #16
    4040:	fmov	s19, w4
    4044:	mov	w3, #0x422a                	// #16938
    4048:	fmov	s21, w2
    404c:	movk	w3, #0x3ecc, lsl #16
    4050:	fmov	s22, w1
    4054:	fmov	s23, w0
    4058:	fmov	s20, w3
    405c:	fcvtzs	s29, s29
    4060:	scvtf	s29, s29
    4064:	fmsub	s28, s29, s25, s28
    4068:	fcvtzs	w7, s29
    406c:	fmadd	s29, s28, s19, s21
    4070:	add	w7, w7, #0x7f
    4074:	fmov	s25, w7
    4078:	fmadd	s29, s28, s29, s22
    407c:	fmadd	s29, s28, s29, s23
    4080:	shl	v25.2s, v25.2s, #23
    4084:	fmadd	s24, s28, s29, s24
    4088:	fmadd	s24, s28, s24, s27
    408c:	fmadd	s29, s28, s24, s27
    4090:	fmul	s29, s29, s25
    4094:	fmul	s29, s29, s20
    4098:	fcmpe	s15, #0.0
    409c:	fmul	s30, s30, s29
    40a0:	b.mi	3f5c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8bc>  // b.first
    40a4:	b	3ea8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x808>
    40a8:	fmov	s23, #5.000000000000000000e-01
    40ac:	mov	w0, #0x7218                	// #29208
    40b0:	mov	w3, #0xb61                 	// #2913
    40b4:	movk	w0, #0x3f31, lsl #16
    40b8:	mov	w2, #0x8889                	// #34953
    40bc:	fmov	s27, #1.000000000000000000e+00
    40c0:	movk	w3, #0x3ab6, lsl #16
    40c4:	movk	w2, #0x3c08, lsl #16
    40c8:	fmov	s24, w0
    40cc:	mov	w1, #0xaaab                	// #43691
    40d0:	mov	w0, #0xaaab                	// #43691
    40d4:	fadd	s29, s29, s23
    40d8:	movk	w1, #0x3d2a, lsl #16
    40dc:	movk	w0, #0x3e2a, lsl #16
    40e0:	fmov	s18, w3
    40e4:	mov	w4, #0x422a                	// #16938
    40e8:	fmov	s20, w2
    40ec:	movk	w4, #0x3ecc, lsl #16
    40f0:	fmov	s21, w1
    40f4:	fmov	s22, w0
    40f8:	fmov	s19, w4
    40fc:	fcvtzs	s29, s29
    4100:	scvtf	s29, s29
    4104:	fmsub	s30, s29, s24, s30
    4108:	fcvtzs	w7, s29
    410c:	fmadd	s29, s30, s18, s20
    4110:	add	w7, w7, #0x7f
    4114:	fmov	s24, w7
    4118:	fmadd	s29, s30, s29, s21
    411c:	fmadd	s29, s30, s29, s22
    4120:	shl	v24.2s, v24.2s, #23
    4124:	fmadd	s23, s30, s29, s23
    4128:	fmadd	s23, s30, s23, s27
    412c:	fmadd	s30, s30, s23, s27
    4130:	fmul	s30, s30, s24
    4134:	fmul	s30, s30, s19
    4138:	fcmpe	s0, #0.0
    413c:	fmul	s31, s31, s30
    4140:	b.mi	3cc8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>  // b.first
    4144:	b	3cc0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    4148:	fmov	s26, #5.000000000000000000e-01
    414c:	mov	w0, #0x7218                	// #29208
    4150:	mov	w3, #0xb61                 	// #2913
    4154:	movk	w0, #0x3f31, lsl #16
    4158:	mov	w2, #0x8889                	// #34953
    415c:	fmov	s30, #1.000000000000000000e+00
    4160:	movk	w3, #0x3ab6, lsl #16
    4164:	movk	w2, #0x3c08, lsl #16
    4168:	fmov	s27, w0
    416c:	mov	w1, #0xaaab                	// #43691
    4170:	mov	w0, #0xaaab                	// #43691
    4174:	fadd	s28, s28, s26
    4178:	movk	w1, #0x3d2a, lsl #16
    417c:	movk	w0, #0x3e2a, lsl #16
    4180:	fmov	s22, w3
    4184:	fmov	s23, w2
    4188:	fmov	s24, w1
    418c:	fmov	s25, w0
    4190:	fcvtzs	s28, s28
    4194:	scvtf	s28, s28
    4198:	fmsub	s29, s28, s27, s29
    419c:	fcvtzs	w7, s28
    41a0:	fmadd	s28, s29, s22, s23
    41a4:	add	w7, w7, #0x7f
    41a8:	fmov	s27, w7
    41ac:	fmadd	s28, s29, s28, s24
    41b0:	fmadd	s28, s29, s28, s25
    41b4:	shl	v27.2s, v27.2s, #23
    41b8:	fmadd	s26, s29, s28, s26
    41bc:	fmadd	s26, s29, s26, s30
    41c0:	fmadd	s30, s29, s26, s30
    41c4:	fmul	s30, s30, s27
    41c8:	b	3d84 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    41cc:	mov	x19, #0x0                   	// #0
    41d0:	b	3a48 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a8>
    41d4:	nop
    41d8:	nop
    41dc:	nop
