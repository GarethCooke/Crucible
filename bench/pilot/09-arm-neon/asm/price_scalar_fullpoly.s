00000000000037e0 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    37e0:	cbz	x6, 3edc <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6fc>
    37e4:	mov	w10, #0x4f3                 	// #1267
    37e8:	mov	w9, #0x21bb                	// #8635
    37ec:	stp	x29, x30, [sp, #-144]!
    37f0:	movk	w10, #0x3fb5, lsl #16
    37f4:	movk	w9, #0x3d90, lsl #16
    37f8:	mov	x29, sp
    37fc:	mov	w15, #0x251a                	// #9498
    3800:	mov	w14, #0x5d4f                	// #23887
    3804:	mov	w13, #0xe9bf                	// #59839
    3808:	stp	d14, d15, [sp, #80]
    380c:	mov	w12, #0xae50                	// #44624
    3810:	fmov	s15, w10
    3814:	mov	w11, #0xceac                	// #52908
    3818:	mov	w10, #0xfffc                	// #65532
    381c:	movk	w15, #0x3def, lsl #16
    3820:	fmov	s0, w9
    3824:	movk	w14, #0xbdfe, lsl #16
    3828:	movk	w13, #0x3e11, lsl #16
    382c:	stp	x19, x20, [sp, #16]
    3830:	movk	w12, #0xbe2a, lsl #16
    3834:	movk	w11, #0x3e4c, lsl #16
    3838:	movk	w10, #0xbe7f, lsl #16
    383c:	mov	w9, #0xaaaa                	// #43690
    3840:	movk	w9, #0x3eaa, lsl #16
    3844:	fmov	s2, w15
    3848:	mov	w20, #0xaa3b                	// #43579
    384c:	fmov	s3, w14
    3850:	mov	w15, #0x3389                	// #13193
    3854:	mov	w14, #0x466f                	// #18031
    3858:	fmov	s4, w13
    385c:	mov	w13, #0x1eea                	// #7914
    3860:	movk	w20, #0x3fb8, lsl #16
    3864:	fmov	s5, w12
    3868:	mov	w12, #0x778                 	// #1912
    386c:	movk	w15, #0x3e6d, lsl #16
    3870:	stp	d8, d9, [sp, #32]
    3874:	movk	w14, #0x3faa, lsl #16
    3878:	movk	w13, #0xbfe9, lsl #16
    387c:	fmov	s8, w11
    3880:	mov	w11, #0x8f89                	// #36745
    3884:	movk	w12, #0x3fe4, lsl #16
    3888:	fmov	s9, w10
    388c:	mov	w10, #0x85fa                	// #34298
    3890:	movk	w11, #0xbeb6, lsl #16
    3894:	movk	w10, #0x3ea3, lsl #16
    3898:	stp	d10, d11, [sp, #48]
    389c:	mov	w8, #0xd1b8                	// #53688
    38a0:	fmov	s10, w9
    38a4:	mov	w9, #0xc2b00000            	// #-1028653056
    38a8:	movk	w8, #0xbdeb, lsl #16
    38ac:	fmov	s11, w20
    38b0:	mov	w19, #0xb61                 	// #2913
    38b4:	mov	w30, #0x8889                	// #34953
    38b8:	fmov	s7, w15
    38bc:	mov	w18, #0xaaab                	// #43691
    38c0:	mov	w17, #0xaaab                	// #43691
    38c4:	fmov	s16, w14
    38c8:	mov	w16, #0x422a                	// #16938
    38cc:	movk	w19, #0x3ab6, lsl #16
    38d0:	fmov	s17, w13
    38d4:	movk	w30, #0x3c08, lsl #16
    38d8:	movk	w18, #0x3d2a, lsl #16
    38dc:	fmov	s18, w12
    38e0:	movk	w17, #0x3e2a, lsl #16
    38e4:	movk	w16, #0x3ecc, lsl #16
    38e8:	fmov	s19, w11
    38ec:	mov	x7, #0x0                   	// #0
    38f0:	fmov	s20, w10
    38f4:	fmov	s24, w9
    38f8:	fmov	s1, w8
    38fc:	mov	w8, #0x7218                	// #29208
    3900:	movk	w8, #0x3f31, lsl #16
    3904:	stp	d12, d13, [sp, #64]
    3908:	stp	w30, w18, [sp, #116]
    390c:	fmov	s6, w8
    3910:	mov	w8, #0x484f                	// #18511
    3914:	movk	w8, #0x7e46, lsl #16
    3918:	stp	w17, w16, [sp, #124]
    391c:	stp	w8, w19, [sp, #108]
    3920:	ldr	s26, [x0, x7, lsl #2]
    3924:	ldr	s25, [x1, x7, lsl #2]
    3928:	ldr	s27, [x2, x7, lsl #2]
    392c:	ldr	s29, [x4, x7, lsl #2]
    3930:	fdiv	s31, s26, s25
    3934:	ldr	s23, [x3, x7, lsl #2]
    3938:	fmul	s21, s29, s29
    393c:	fmov	w8, s31
    3940:	dup	v31.2s, v27.s[0]
    3944:	fsqrt	v31.2s, v31.2s
    3948:	and	w9, w8, #0x7fffff
    394c:	ubfx	x8, x8, #23, #8
    3950:	orr	w9, w9, #0x3f800000
    3954:	fmul	s29, s29, s31
    3958:	fmov	s31, w9
    395c:	fcmpe	s31, s15
    3960:	b.ge	3d3c <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.tcont
    3964:	sub	w8, w8, #0x7f
    3968:	fmov	s30, #1.000000000000000000e+00
    396c:	fmov	s28, #5.000000000000000000e-01
    3970:	scvtf	s14, w8
    3974:	fsub	s31, s31, s30
    3978:	fmadd	s21, s21, s28, s23
    397c:	fmadd	s22, s31, s0, s1
    3980:	fmul	s12, s31, s31
    3984:	fmadd	s22, s31, s22, s2
    3988:	fmul	s13, s12, s28
    398c:	fmadd	s22, s31, s22, s3
    3990:	fmadd	s22, s31, s22, s4
    3994:	fmadd	s22, s31, s22, s5
    3998:	fmadd	s22, s31, s22, s8
    399c:	fmadd	s22, s31, s22, s9
    39a0:	fmadd	s22, s31, s22, s10
    39a4:	fmul	s22, s22, s12
    39a8:	fnmsub	s13, s31, s22, s13
    39ac:	fadd	s31, s31, s13
    39b0:	fmadd	s31, s14, s6, s31
    39b4:	fmadd	s31, s27, s21, s31
    39b8:	fdiv	s31, s31, s29
    39bc:	fcmpe	s31, #0.0
    39c0:	fsub	s29, s31, s29
    39c4:	b.mi	3d84 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5a4>  // b.first
    39c8:	fmadd	s22, s31, s7, s30
    39cc:	fmov	s28, #-5.000000000000000000e-01
    39d0:	fmul	s28, s31, s28
    39d4:	fdiv	s30, s30, s22
    39d8:	fmul	s28, s28, s31
    39dc:	fcmpe	s28, s24
    39e0:	fmadd	s22, s30, s16, s17
    39e4:	fmadd	s22, s30, s22, s18
    39e8:	fmadd	s22, s30, s22, s19
    39ec:	fmadd	s22, s30, s22, s20
    39f0:	fmul	s30, s30, s22
    39f4:	b.mi	3ac4 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2e4>  // b.first
    39f8:	mov	w8, #0x42b00000            	// #1118830592
    39fc:	ldr	s21, [sp, #108]
    3a00:	fmov	s22, w8
    3a04:	fcmpe	s28, s22
    3a08:	b.gt	3ac8 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2e8>
    3a0c:	fmul	s22, s28, s11
    3a10:	fcmpe	s22, #0.0
    3a14:	b.ge	3e80 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6a0>  // b.tcont
    3a18:	fmov	s21, #5.000000000000000000e-01
    3a1c:	mov	w8, #0x7218                	// #29208
    3a20:	mov	w12, #0xb61                 	// #2913
    3a24:	movk	w8, #0x3f31, lsl #16
    3a28:	mov	w11, #0x8889                	// #34953
    3a2c:	fmov	s12, #1.000000000000000000e+00
    3a30:	movk	w12, #0x3ab6, lsl #16
    3a34:	movk	w11, #0x3c08, lsl #16
    3a38:	fmov	s13, w8
    3a3c:	mov	w8, #0x422a                	// #16938
    3a40:	mov	w10, #0xaaab                	// #43691
    3a44:	fsub	s22, s22, s21
    3a48:	movk	w8, #0x3ecc, lsl #16
    3a4c:	movk	w10, #0x3d2a, lsl #16
    3a50:	mov	w9, #0xaaab                	// #43691
    3a54:	stp	w12, w11, [sp, #132]
    3a58:	str	w8, [sp, #140]
    3a5c:	movk	w9, #0x3e2a, lsl #16
    3a60:	fmov	s14, w10
    3a64:	fmov	s21, w9
    3a68:	fcvtzs	s22, s22
    3a6c:	scvtf	s22, s22
    3a70:	fmsub	s28, s22, s13, s28
    3a74:	fcvtzs	w8, s22
    3a78:	fmov	s13, w11
    3a7c:	fmov	s22, w12
    3a80:	add	w8, w8, #0x7f
    3a84:	fmadd	s13, s28, s22, s13
    3a88:	fmov	s22, w8
    3a8c:	fmadd	s14, s28, s13, s14
    3a90:	shl	v22.2s, v22.2s, #23
    3a94:	fmadd	s21, s28, s14, s21
    3a98:	fmov	s14, #5.000000000000000000e-01
    3a9c:	fmadd	s21, s28, s21, s14
    3aa0:	fmadd	s21, s28, s21, s12
    3aa4:	fmadd	s28, s28, s21, s12
    3aa8:	fmul	s28, s28, s22
    3aac:	ldr	s22, [sp, #140]
    3ab0:	fmul	s28, s28, s22
    3ab4:	fcmpe	s31, #0.0
    3ab8:	fmul	s30, s30, s28
    3abc:	b.mi	3ad4 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2f4>  // b.first
    3ac0:	b	3acc <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2ec>
    3ac4:	movi	v21.2s, #0x0
    3ac8:	fmul	s30, s30, s21
    3acc:	fmov	s31, #1.000000000000000000e+00
    3ad0:	fsub	s30, s31, s30
    3ad4:	fnmul	s27, s23, s27
    3ad8:	fmul	s30, s26, s30
    3adc:	movi	v31.2s, #0x0
    3ae0:	fcmpe	s27, s24
    3ae4:	b.mi	3b84 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a4>  // b.first
    3ae8:	mov	w8, #0x42b00000            	// #1118830592
    3aec:	fmov	s31, w8
    3af0:	fcmpe	s27, s31
    3af4:	b.gt	3dc0 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e0>
    3af8:	fmul	s28, s27, s11
    3afc:	fcmpe	s28, #0.0
    3b00:	b.ge	3dd0 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5f0>  // b.tcont
    3b04:	fmov	s23, #5.000000000000000000e-01
    3b08:	mov	w8, #0x7218                	// #29208
    3b0c:	mov	w11, #0xb61                 	// #2913
    3b10:	movk	w8, #0x3f31, lsl #16
    3b14:	mov	w10, #0x8889                	// #34953
    3b18:	fmov	s31, #1.000000000000000000e+00
    3b1c:	movk	w11, #0x3ab6, lsl #16
    3b20:	movk	w10, #0x3c08, lsl #16
    3b24:	fmov	s26, w8
    3b28:	mov	w9, #0xaaab                	// #43691
    3b2c:	mov	w8, #0xaaab                	// #43691
    3b30:	fsub	s28, s28, s23
    3b34:	movk	w9, #0x3d2a, lsl #16
    3b38:	movk	w8, #0x3e2a, lsl #16
    3b3c:	fmov	s21, w11
    3b40:	fmov	s14, w10
    3b44:	fmov	s22, w9
    3b48:	fmov	s13, w8
    3b4c:	fcvtzs	s28, s28
    3b50:	scvtf	s28, s28
    3b54:	fmsub	s26, s28, s26, s27
    3b58:	fcvtzs	w8, s28
    3b5c:	fmadd	s14, s26, s21, s14
    3b60:	add	w8, w8, #0x7f
    3b64:	fmov	s28, w8
    3b68:	fmadd	s22, s26, s14, s22
    3b6c:	fmadd	s13, s26, s22, s13
    3b70:	shl	v28.2s, v28.2s, #23
    3b74:	fmadd	s23, s26, s13, s23
    3b78:	fmadd	s23, s26, s23, s31
    3b7c:	fmadd	s31, s26, s23, s31
    3b80:	fmul	s31, s31, s28
    3b84:	fcmpe	s29, #0.0
    3b88:	fmul	s27, s25, s31
    3b8c:	b.mi	3d4c <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x56c>  // b.first
    3b90:	fmov	s31, #1.000000000000000000e+00
    3b94:	fmov	s28, #-5.000000000000000000e-01
    3b98:	fmadd	s26, s29, s7, s31
    3b9c:	fmul	s28, s29, s28
    3ba0:	fmul	s28, s28, s29
    3ba4:	fdiv	s31, s31, s26
    3ba8:	fcmpe	s28, s24
    3bac:	fmadd	s26, s31, s16, s17
    3bb0:	fmadd	s26, s31, s26, s18
    3bb4:	fmadd	s26, s31, s26, s19
    3bb8:	fmadd	s26, s31, s26, s20
    3bbc:	fmul	s31, s31, s26
    3bc0:	b.mi	3cc4 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>  // b.first
    3bc4:	mov	w8, #0x42b00000            	// #1118830592
    3bc8:	ldr	s25, [sp, #108]
    3bcc:	fmov	s26, w8
    3bd0:	fcmpe	s28, s26
    3bd4:	b.gt	3cc8 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e8>
    3bd8:	nop
    3bdc:	nop
    3be0:	fmul	s26, s28, s11
    3be4:	fcmpe	s26, #0.0
    3be8:	b.ge	3e24 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x644>  // b.tcont
    3bec:	fmov	s23, #5.000000000000000000e-01
    3bf0:	mov	w8, #0x7218                	// #29208
    3bf4:	mov	w12, #0xb61                 	// #2913
    3bf8:	movk	w8, #0x3f31, lsl #16
    3bfc:	mov	w11, #0x8889                	// #34953
    3c00:	fmov	s13, #1.000000000000000000e+00
    3c04:	movk	w12, #0x3ab6, lsl #16
    3c08:	movk	w11, #0x3c08, lsl #16
    3c0c:	fmov	s25, w8
    3c10:	mov	w10, #0xaaab                	// #43691
    3c14:	mov	w9, #0xaaab                	// #43691
    3c18:	fsub	s26, s26, s23
    3c1c:	movk	w10, #0x3d2a, lsl #16
    3c20:	movk	w9, #0x3e2a, lsl #16
    3c24:	fmov	s12, w12
    3c28:	mov	w8, #0x422a                	// #16938
    3c2c:	fmov	s14, w11
    3c30:	movk	w8, #0x3ecc, lsl #16
    3c34:	fmov	s21, w10
    3c38:	fmov	s22, w9
    3c3c:	str	w8, [sp, #132]
    3c40:	fcvtzs	s26, s26
    3c44:	scvtf	s26, s26
    3c48:	fmsub	s25, s26, s25, s28
    3c4c:	fcvtzs	w8, s26
    3c50:	fmadd	s14, s25, s12, s14
    3c54:	add	w8, w8, #0x7f
    3c58:	fmov	s28, w8
    3c5c:	fmadd	s21, s25, s14, s21
    3c60:	fmadd	s22, s25, s21, s22
    3c64:	shl	v26.2s, v28.2s, #23
    3c68:	fmadd	s23, s25, s22, s23
    3c6c:	fmadd	s23, s25, s23, s13
    3c70:	fmadd	s28, s25, s23, s13
    3c74:	fmul	s28, s28, s26
    3c78:	ldr	s26, [sp, #132]
    3c7c:	fmul	s28, s28, s26
    3c80:	fcmpe	s29, #0.0
    3c84:	fmul	s31, s31, s28
    3c88:	b.mi	3d0c <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x52c>  // b.first
    3c8c:	fmov	s29, #1.000000000000000000e+00
    3c90:	fsub	s31, s29, s31
    3c94:	fmsub	s31, s27, s31, s30
    3c98:	str	s31, [x5, x7, lsl #2]
    3c9c:	add	x7, x7, #0x1
    3ca0:	cmp	x7, x6
    3ca4:	b.ne	3920 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x140>  // b.any
    3ca8:	ldp	d8, d9, [sp, #32]
    3cac:	ldp	x19, x20, [sp, #16]
    3cb0:	ldp	d10, d11, [sp, #48]
    3cb4:	ldp	d12, d13, [sp, #64]
    3cb8:	ldp	d14, d15, [sp, #80]
    3cbc:	ldp	x29, x30, [sp], #144
    3cc0:	ret
    3cc4:	movi	v25.2s, #0x0
    3cc8:	fmul	s31, s31, s25
    3ccc:	fmov	s29, #1.000000000000000000e+00
    3cd0:	fsub	s31, s29, s31
    3cd4:	fmsub	s31, s27, s31, s30
    3cd8:	str	s31, [x5, x7, lsl #2]
    3cdc:	add	x7, x7, #0x1
    3ce0:	cmp	x7, x6
    3ce4:	b.ne	3920 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x140>  // b.any
    3ce8:	ldp	d8, d9, [sp, #32]
    3cec:	ldp	x19, x20, [sp, #16]
    3cf0:	ldp	d10, d11, [sp, #48]
    3cf4:	ldp	d12, d13, [sp, #64]
    3cf8:	ldp	d14, d15, [sp, #80]
    3cfc:	ldp	x29, x30, [sp], #144
    3d00:	ret
    3d04:	movi	v29.2s, #0x0
    3d08:	fmul	s31, s31, s29
    3d0c:	fmsub	s31, s27, s31, s30
    3d10:	str	s31, [x5, x7, lsl #2]
    3d14:	add	x7, x7, #0x1
    3d18:	cmp	x6, x7
    3d1c:	b.ne	3920 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x140>  // b.any
    3d20:	ldp	d8, d9, [sp, #32]
    3d24:	ldp	x19, x20, [sp, #16]
    3d28:	ldp	d10, d11, [sp, #48]
    3d2c:	ldp	d12, d13, [sp, #64]
    3d30:	ldp	d14, d15, [sp, #80]
    3d34:	ldp	x29, x30, [sp], #144
    3d38:	ret
    3d3c:	fmov	s30, #5.000000000000000000e-01
    3d40:	sub	w8, w8, #0x7e
    3d44:	fmul	s31, s31, s30
    3d48:	b	3968 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x188>
    3d4c:	fmov	s26, #1.000000000000000000e+00
    3d50:	fmov	s28, #5.000000000000000000e-01
    3d54:	fmsub	s31, s29, s7, s26
    3d58:	fmul	s28, s29, s28
    3d5c:	fnmul	s28, s29, s28
    3d60:	fdiv	s26, s26, s31
    3d64:	fcmpe	s28, s24
    3d68:	fmadd	s31, s26, s16, s17
    3d6c:	fmadd	s31, s31, s26, s18
    3d70:	fmadd	s31, s31, s26, s19
    3d74:	fmadd	s31, s31, s26, s20
    3d78:	fmul	s31, s31, s26
    3d7c:	b.mi	3d04 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x524>  // b.first
    3d80:	b	3be0 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x400>
    3d84:	fmsub	s22, s31, s7, s30
    3d88:	fmul	s28, s31, s28
    3d8c:	fnmul	s28, s31, s28
    3d90:	fdiv	s22, s30, s22
    3d94:	fcmpe	s28, s24
    3d98:	fmadd	s30, s22, s16, s17
    3d9c:	fmadd	s30, s22, s30, s18
    3da0:	fmadd	s30, s22, s30, s19
    3da4:	fmadd	s30, s22, s30, s20
    3da8:	fmul	s30, s22, s30
    3dac:	b.mi	3db4 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d4>  // b.first
    3db0:	b	3a0c <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x22c>
    3db4:	movi	v31.2s, #0x0
    3db8:	fmul	s30, s30, s31
    3dbc:	b	3ad4 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2f4>
    3dc0:	mov	w8, #0x829c                	// #33436
    3dc4:	movk	w8, #0x7ef8, lsl #16
    3dc8:	fmov	s31, w8
    3dcc:	b	3b84 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a4>
    3dd0:	fmov	s26, #5.000000000000000000e-01
    3dd4:	ldr	s22, [sp, #120]
    3dd8:	fmov	s31, #1.000000000000000000e+00
    3ddc:	fadd	s28, s28, s26
    3de0:	fcvtzs	s28, s28
    3de4:	scvtf	s28, s28
    3de8:	fmsub	s27, s28, s6, s27
    3dec:	fcvtzs	w8, s28
    3df0:	ldp	s23, s28, [sp, #112]
    3df4:	fmadd	s28, s27, s23, s28
    3df8:	add	w8, w8, #0x7f
    3dfc:	fmov	s23, w8
    3e00:	fmadd	s28, s27, s28, s22
    3e04:	ldr	s22, [sp, #124]
    3e08:	fmadd	s28, s27, s28, s22
    3e0c:	shl	v23.2s, v23.2s, #23
    3e10:	fmadd	s26, s27, s28, s26
    3e14:	fmadd	s26, s27, s26, s31
    3e18:	fmadd	s31, s27, s26, s31
    3e1c:	fmul	s31, s31, s23
    3e20:	b	3b84 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a4>
    3e24:	fmov	s23, #5.000000000000000000e-01
    3e28:	ldr	s21, [sp, #120]
    3e2c:	fmov	s25, #1.000000000000000000e+00
    3e30:	fadd	s26, s26, s23
    3e34:	fcvtzs	s26, s26
    3e38:	scvtf	s26, s26
    3e3c:	fmsub	s28, s26, s6, s28
    3e40:	fcvtzs	w8, s26
    3e44:	ldp	s22, s26, [sp, #112]
    3e48:	fmadd	s26, s28, s22, s26
    3e4c:	add	w8, w8, #0x7f
    3e50:	fmov	s22, w8
    3e54:	fmadd	s26, s28, s26, s21
    3e58:	ldr	s21, [sp, #124]
    3e5c:	fmadd	s26, s28, s26, s21
    3e60:	shl	v22.2s, v22.2s, #23
    3e64:	fmadd	s23, s28, s26, s23
    3e68:	ldr	s26, [sp, #128]
    3e6c:	fmadd	s23, s28, s23, s25
    3e70:	fmadd	s28, s28, s23, s25
    3e74:	fmul	s28, s28, s22
    3e78:	fmul	s28, s28, s26
    3e7c:	b	3c80 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4a0>
    3e80:	fmov	s14, #5.000000000000000000e-01
    3e84:	ldr	s12, [sp, #120]
    3e88:	fmov	s21, #1.000000000000000000e+00
    3e8c:	fadd	s22, s22, s14
    3e90:	fcvtzs	s22, s22
    3e94:	scvtf	s22, s22
    3e98:	fmsub	s28, s22, s6, s28
    3e9c:	fcvtzs	w8, s22
    3ea0:	ldp	s13, s22, [sp, #112]
    3ea4:	fmadd	s13, s28, s13, s22
    3ea8:	add	w8, w8, #0x7f
    3eac:	fmov	s22, w8
    3eb0:	fmadd	s13, s28, s13, s12
    3eb4:	ldr	s12, [sp, #124]
    3eb8:	fmadd	s13, s28, s13, s12
    3ebc:	shl	v22.2s, v22.2s, #23
    3ec0:	fmadd	s14, s28, s13, s14
    3ec4:	fmadd	s14, s28, s14, s21
    3ec8:	fmadd	s28, s28, s14, s21
    3ecc:	fmul	s28, s28, s22
    3ed0:	ldr	s22, [sp, #128]
    3ed4:	fmul	s28, s28, s22
    3ed8:	b	3ab4 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d4>
    3edc:	ret
