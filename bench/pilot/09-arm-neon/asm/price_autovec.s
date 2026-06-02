0000000000002860 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    2860:	cbz	x6, 301c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    2864:	stp	x29, x30, [sp, #-160]!
    2868:	mov	x29, sp
    286c:	stp	x23, x24, [sp, #48]
    2870:	mov	x24, x4
    2874:	mov	w4, #0xaa3b                	// #43579
    2878:	movk	w4, #0x3fb8, lsl #16
    287c:	mov	x23, x3
    2880:	mov	w3, #0x7218                	// #29208
    2884:	stp	x19, x20, [sp, #16]
    2888:	mov	x20, x0
    288c:	mov	w0, #0xc2b00000            	// #-1028653056
    2890:	movk	w3, #0x3f31, lsl #16
    2894:	mov	x19, x6
    2898:	stp	d8, d9, [sp, #80]
    289c:	fmov	s9, w0
    28a0:	stp	d14, d15, [sp, #128]
    28a4:	fmov	s14, w4
    28a8:	stp	x21, x22, [sp, #32]
    28ac:	mov	x21, x1
    28b0:	mov	x22, x2
    28b4:	mov	w1, #0x8889                	// #34953
    28b8:	mov	w2, #0xb61                 	// #2913
    28bc:	movk	w2, #0x3ab6, lsl #16
    28c0:	movk	w1, #0x3c08, lsl #16
    28c4:	stp	x25, x26, [sp, #64]
    28c8:	mov	x26, #0x0                   	// #0
    28cc:	mov	x25, x5
    28d0:	stp	d10, d11, [sp, #96]
    28d4:	stp	d12, d13, [sp, #112]
    28d8:	stp	w3, w2, [sp, #148]
    28dc:	str	w1, [sp, #156]
    28e0:	ldr	s12, [x22, x26, lsl #2]
    28e4:	ldr	s15, [x24, x26, lsl #2]
    28e8:	ldr	s13, [x20, x26, lsl #2]
    28ec:	fcmp	s12, #0.0
    28f0:	ldr	s8, [x21, x26, lsl #2]
    28f4:	ldr	s11, [x23, x26, lsl #2]
    28f8:	fmul	s10, s15, s15
    28fc:	b.pl	29b4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    2900:	fmov	s0, s12
    2904:	bl	ec0 <sqrtf@plt>
    2908:	fmov	s31, s0
    290c:	fdiv	s0, s13, s8
    2910:	fmul	s15, s15, s31
    2914:	bl	1020 <logf@plt>
    2918:	fmov	s31, #5.000000000000000000e-01
    291c:	mov	w0, #0x3389                	// #13193
    2920:	fmov	s25, #1.000000000000000000e+00
    2924:	movk	w0, #0x3e6d, lsl #16
    2928:	mov	w1, #0x466f                	// #18031
    292c:	fmov	s19, #-5.000000000000000000e-01
    2930:	mov	w4, #0x1eea                	// #7914
    2934:	movk	w1, #0x3faa, lsl #16
    2938:	fmov	s29, w0
    293c:	movk	w4, #0xbfe9, lsl #16
    2940:	mov	w3, #0x778                 	// #1912
    2944:	fmadd	s10, s10, s31, s11
    2948:	movk	w3, #0x3fe4, lsl #16
    294c:	mov	w2, #0x8f89                	// #36745
    2950:	fmov	s20, w1
    2954:	movk	w2, #0xbeb6, lsl #16
    2958:	mov	w1, #0x85fa                	// #34298
    295c:	movk	w1, #0x3ea3, lsl #16
    2960:	mov	w0, #0xaa3b                	// #43579
    2964:	fmov	s22, w4
    2968:	movk	w0, #0x3fb8, lsl #16
    296c:	fmov	s23, w3
    2970:	fmadd	s0, s12, s10, s0
    2974:	fmov	s24, w2
    2978:	fmov	s31, w1
    297c:	fmov	s28, w0
    2980:	fdiv	s0, s0, s15
    2984:	fmadd	s21, s0, s29, s25
    2988:	fmul	s29, s0, s19
    298c:	fsub	s15, s0, s15
    2990:	fmul	s29, s29, s0
    2994:	fdiv	s25, s25, s21
    2998:	fmul	s28, s29, s28
    299c:	fmadd	s22, s25, s20, s22
    29a0:	fmadd	s23, s22, s25, s23
    29a4:	fmadd	s24, s23, s25, s24
    29a8:	fmadd	s31, s24, s25, s31
    29ac:	fmul	s31, s31, s25
    29b0:	b	2a78 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    29b4:	fsqrt	s31, s12
    29b8:	fdiv	s0, s13, s8
    29bc:	fmul	s15, s15, s31
    29c0:	bl	1020 <logf@plt>
    29c4:	fmov	s29, #5.000000000000000000e-01
    29c8:	fmadd	s10, s10, s29, s11
    29cc:	fmadd	s0, s12, s10, s0
    29d0:	fdiv	s0, s0, s15
    29d4:	fcmpe	s0, #0.0
    29d8:	fsub	s15, s0, s15
    29dc:	b.mi	2dbc <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    29e0:	mov	w0, #0x3389                	// #13193
    29e4:	fmov	s31, #1.000000000000000000e+00
    29e8:	mov	w4, #0x466f                	// #18031
    29ec:	movk	w0, #0x3e6d, lsl #16
    29f0:	mov	w3, #0x1eea                	// #7914
    29f4:	fmov	s29, #-5.000000000000000000e-01
    29f8:	movk	w4, #0x3faa, lsl #16
    29fc:	movk	w3, #0xbfe9, lsl #16
    2a00:	fmov	s22, w0
    2a04:	mov	w2, #0x778                 	// #1912
    2a08:	mov	w1, #0x8f89                	// #36745
    2a0c:	fmov	s21, w4
    2a10:	movk	w2, #0x3fe4, lsl #16
    2a14:	movk	w1, #0xbeb6, lsl #16
    2a18:	fmov	s23, w3
    2a1c:	mov	w0, #0x85fa                	// #34298
    2a20:	fmov	s24, w2
    2a24:	movk	w0, #0x3ea3, lsl #16
    2a28:	fmov	s25, w1
    2a2c:	fmov	s28, w0
    2a30:	fmul	s29, s0, s29
    2a34:	fmadd	s22, s0, s22, s31
    2a38:	fmul	s29, s29, s0
    2a3c:	fcmpe	s29, s9
    2a40:	fdiv	s31, s31, s22
    2a44:	fmadd	s23, s31, s21, s23
    2a48:	fmadd	s24, s31, s23, s24
    2a4c:	fmadd	s25, s31, s24, s25
    2a50:	fmadd	s28, s31, s25, s28
    2a54:	fmul	s31, s31, s28
    2a58:	b.mi	2ecc <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    2a5c:	mov	w0, #0x42b00000            	// #1118830592
    2a60:	fmov	s28, w0
    2a64:	fcmpe	s29, s28
    2a68:	b.gt	2b18 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    2a6c:	fmul	s28, s29, s14
    2a70:	fcmpe	s28, #0.0
    2a74:	b.ge	2f2c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    2a78:	fmov	s23, #5.000000000000000000e-01
    2a7c:	mov	w0, #0x7218                	// #29208
    2a80:	mov	w3, #0xb61                 	// #2913
    2a84:	movk	w0, #0x3f31, lsl #16
    2a88:	mov	w2, #0x8889                	// #34953
    2a8c:	fmov	s24, #1.000000000000000000e+00
    2a90:	movk	w3, #0x3ab6, lsl #16
    2a94:	movk	w2, #0x3c08, lsl #16
    2a98:	fmov	s25, w0
    2a9c:	mov	w1, #0xaaab                	// #43691
    2aa0:	mov	w0, #0xaaab                	// #43691
    2aa4:	fsub	s28, s28, s23
    2aa8:	movk	w1, #0x3d2a, lsl #16
    2aac:	movk	w0, #0x3e2a, lsl #16
    2ab0:	fmov	s18, w3
    2ab4:	mov	w4, #0x422a                	// #16938
    2ab8:	fmov	s20, w2
    2abc:	movk	w4, #0x3ecc, lsl #16
    2ac0:	fmov	s21, w1
    2ac4:	fmov	s22, w0
    2ac8:	fmov	s19, w4
    2acc:	fcvtzs	s28, s28
    2ad0:	scvtf	s28, s28
    2ad4:	fmsub	s25, s28, s25, s29
    2ad8:	fcvtzs	w0, s28
    2adc:	fmadd	s28, s25, s18, s20
    2ae0:	add	w0, w0, #0x7f
    2ae4:	fmov	s30, w0
    2ae8:	fmadd	s28, s25, s28, s21
    2aec:	fmadd	s28, s25, s28, s22
    2af0:	shl	v29.2s, v30.2s, #23
    2af4:	fmadd	s23, s25, s28, s23
    2af8:	fmadd	s23, s25, s23, s24
    2afc:	fmadd	s24, s25, s23, s24
    2b00:	fmul	s29, s24, s29
    2b04:	fmul	s29, s29, s19
    2b08:	fcmpe	s0, #0.0
    2b0c:	fmul	s31, s31, s29
    2b10:	b.mi	2b30 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    2b14:	b	2b28 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2b18:	mov	w0, #0x484f                	// #18511
    2b1c:	movk	w0, #0x7e46, lsl #16
    2b20:	fmov	s29, w0
    2b24:	fmul	s31, s31, s29
    2b28:	fmov	s29, #1.000000000000000000e+00
    2b2c:	fsub	s31, s29, s31
    2b30:	fnmul	s30, s11, s12
    2b34:	fmul	s31, s13, s31
    2b38:	movi	v29.2s, #0x0
    2b3c:	fcmpe	s30, s9
    2b40:	b.mi	2be0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2b44:	mov	w0, #0x42b00000            	// #1118830592
    2b48:	fmov	s29, w0
    2b4c:	fcmpe	s30, s29
    2b50:	b.gt	2ed8 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2b54:	fmul	s28, s30, s14
    2b58:	fcmpe	s28, #0.0
    2b5c:	b.ge	2ee8 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    2b60:	fmov	s27, #5.000000000000000000e-01
    2b64:	mov	w0, #0x7218                	// #29208
    2b68:	mov	w3, #0xb61                 	// #2913
    2b6c:	movk	w0, #0x3f31, lsl #16
    2b70:	mov	w2, #0x8889                	// #34953
    2b74:	fmov	s29, #1.000000000000000000e+00
    2b78:	movk	w3, #0x3ab6, lsl #16
    2b7c:	movk	w2, #0x3c08, lsl #16
    2b80:	fmov	s22, w0
    2b84:	mov	w1, #0xaaab                	// #43691
    2b88:	mov	w0, #0xaaab                	// #43691
    2b8c:	fsub	s28, s28, s27
    2b90:	movk	w1, #0x3d2a, lsl #16
    2b94:	movk	w0, #0x3e2a, lsl #16
    2b98:	fmov	s23, w3
    2b9c:	fmov	s24, w2
    2ba0:	fmov	s25, w1
    2ba4:	fmov	s26, w0
    2ba8:	fcvtzs	s28, s28
    2bac:	scvtf	s28, s28
    2bb0:	fmsub	s30, s28, s22, s30
    2bb4:	fcvtzs	w0, s28
    2bb8:	fmadd	s24, s30, s23, s24
    2bbc:	fmadd	s25, s30, s24, s25
    2bc0:	add	w0, w0, #0x7f
    2bc4:	fmov	s28, w0
    2bc8:	fmadd	s26, s30, s25, s26
    2bcc:	fmadd	s27, s30, s26, s27
    2bd0:	shl	v28.2s, v28.2s, #23
    2bd4:	fmadd	s27, s30, s27, s29
    2bd8:	fmadd	s29, s30, s27, s29
    2bdc:	fmul	s29, s29, s28
    2be0:	fcmpe	s15, #0.0
    2be4:	fmul	s29, s8, s29
    2be8:	b.mi	2e44 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    2bec:	mov	w0, #0x3389                	// #13193
    2bf0:	fmov	s30, #1.000000000000000000e+00
    2bf4:	mov	w4, #0x466f                	// #18031
    2bf8:	movk	w0, #0x3e6d, lsl #16
    2bfc:	mov	w3, #0x1eea                	// #7914
    2c00:	fmov	s27, #-5.000000000000000000e-01
    2c04:	movk	w4, #0x3faa, lsl #16
    2c08:	movk	w3, #0xbfe9, lsl #16
    2c0c:	fmov	s23, w0
    2c10:	mov	w2, #0x778                 	// #1912
    2c14:	mov	w1, #0x8f89                	// #36745
    2c18:	fmov	s22, w4
    2c1c:	movk	w2, #0x3fe4, lsl #16
    2c20:	movk	w1, #0xbeb6, lsl #16
    2c24:	fmov	s24, w3
    2c28:	mov	w0, #0x85fa                	// #34298
    2c2c:	fmov	s25, w2
    2c30:	movk	w0, #0x3ea3, lsl #16
    2c34:	fmov	s26, w1
    2c38:	fmov	s28, w0
    2c3c:	fmul	s27, s15, s27
    2c40:	fmadd	s23, s15, s23, s30
    2c44:	fmul	s27, s27, s15
    2c48:	fcmpe	s27, s9
    2c4c:	fdiv	s30, s30, s23
    2c50:	fmadd	s24, s30, s22, s24
    2c54:	fmadd	s25, s30, s24, s25
    2c58:	fmadd	s26, s30, s25, s26
    2c5c:	fmadd	s28, s30, s26, s28
    2c60:	fmul	s30, s30, s28
    2c64:	b.mi	2ec4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    2c68:	mov	w0, #0x42b00000            	// #1118830592
    2c6c:	fmov	s28, w0
    2c70:	fcmpe	s27, s28
    2c74:	b.gt	2d6c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    2c78:	nop
    2c7c:	nop
    2c80:	fmul	s28, s27, s14
    2c84:	fcmpe	s28, #0.0
    2c88:	b.ge	2fa4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    2c8c:	fmov	s25, #5.000000000000000000e-01
    2c90:	mov	w0, #0x7218                	// #29208
    2c94:	mov	w4, #0xb61                 	// #2913
    2c98:	movk	w0, #0x3f31, lsl #16
    2c9c:	mov	w2, #0x8889                	// #34953
    2ca0:	fmov	s26, #1.000000000000000000e+00
    2ca4:	movk	w4, #0x3ab6, lsl #16
    2ca8:	movk	w2, #0x3c08, lsl #16
    2cac:	fmov	s19, w0
    2cb0:	mov	w1, #0xaaab                	// #43691
    2cb4:	mov	w0, #0xaaab                	// #43691
    2cb8:	fsub	s28, s28, s25
    2cbc:	movk	w1, #0x3d2a, lsl #16
    2cc0:	movk	w0, #0x3e2a, lsl #16
    2cc4:	fmov	s20, w4
    2cc8:	mov	w3, #0x422a                	// #16938
    2ccc:	fmov	s22, w2
    2cd0:	movk	w3, #0x3ecc, lsl #16
    2cd4:	fmov	s23, w1
    2cd8:	fmov	s24, w0
    2cdc:	fmov	s21, w3
    2ce0:	fcvtzs	s28, s28
    2ce4:	scvtf	s28, s28
    2ce8:	fmsub	s27, s28, s19, s27
    2cec:	fcvtzs	w0, s28
    2cf0:	fmadd	s22, s27, s20, s22
    2cf4:	add	w0, w0, #0x7f
    2cf8:	fmov	s28, w0
    2cfc:	fmadd	s23, s27, s22, s23
    2d00:	fmadd	s24, s27, s23, s24
    2d04:	shl	v28.2s, v28.2s, #23
    2d08:	fmadd	s25, s27, s24, s25
    2d0c:	fmadd	s25, s27, s25, s26
    2d10:	fmadd	s26, s27, s25, s26
    2d14:	fmul	s28, s26, s28
    2d18:	fmul	s28, s28, s21
    2d1c:	fcmpe	s15, #0.0
    2d20:	fmul	s30, s30, s28
    2d24:	b.mi	2da4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    2d28:	fmov	s28, #1.000000000000000000e+00
    2d2c:	fsub	s30, s28, s30
    2d30:	fmsub	s31, s29, s30, s31
    2d34:	str	s31, [x25, x26, lsl #2]
    2d38:	add	x26, x26, #0x1
    2d3c:	cmp	x26, x19
    2d40:	b.ne	28e0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2d44:	ldp	d8, d9, [sp, #80]
    2d48:	ldp	x19, x20, [sp, #16]
    2d4c:	ldp	x21, x22, [sp, #32]
    2d50:	ldp	x23, x24, [sp, #48]
    2d54:	ldp	x25, x26, [sp, #64]
    2d58:	ldp	d10, d11, [sp, #96]
    2d5c:	ldp	d12, d13, [sp, #112]
    2d60:	ldp	d14, d15, [sp, #128]
    2d64:	ldp	x29, x30, [sp], #160
    2d68:	ret
    2d6c:	mov	w0, #0x484f                	// #18511
    2d70:	movk	w0, #0x7e46, lsl #16
    2d74:	fmov	s28, w0
    2d78:	fmul	s30, s30, s28
    2d7c:	fmov	s28, #1.000000000000000000e+00
    2d80:	fsub	s30, s28, s30
    2d84:	fmsub	s31, s29, s30, s31
    2d88:	str	s31, [x25, x26, lsl #2]
    2d8c:	add	x26, x26, #0x1
    2d90:	cmp	x26, x19
    2d94:	b.ne	28e0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2d98:	b	2d44 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    2d9c:	movi	v28.2s, #0x0
    2da0:	fmul	s30, s30, s28
    2da4:	fmsub	s30, s29, s30, s31
    2da8:	str	s30, [x25, x26, lsl #2]
    2dac:	add	x26, x26, #0x1
    2db0:	cmp	x19, x26
    2db4:	b.ne	28e0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2db8:	b	2d44 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    2dbc:	mov	w0, #0x3389                	// #13193
    2dc0:	fmov	s31, #1.000000000000000000e+00
    2dc4:	mov	w4, #0x466f                	// #18031
    2dc8:	movk	w0, #0x3e6d, lsl #16
    2dcc:	mov	w3, #0x1eea                	// #7914
    2dd0:	fmul	s29, s0, s29
    2dd4:	movk	w4, #0x3faa, lsl #16
    2dd8:	movk	w3, #0xbfe9, lsl #16
    2ddc:	fmov	s22, w0
    2de0:	mov	w2, #0x778                 	// #1912
    2de4:	mov	w1, #0x8f89                	// #36745
    2de8:	fmov	s21, w4
    2dec:	movk	w2, #0x3fe4, lsl #16
    2df0:	movk	w1, #0xbeb6, lsl #16
    2df4:	fmov	s23, w3
    2df8:	mov	w0, #0x85fa                	// #34298
    2dfc:	fmov	s24, w2
    2e00:	movk	w0, #0x3ea3, lsl #16
    2e04:	fmov	s25, w1
    2e08:	fmov	s28, w0
    2e0c:	fnmul	s29, s0, s29
    2e10:	fmsub	s22, s0, s22, s31
    2e14:	fcmpe	s29, s9
    2e18:	fdiv	s31, s31, s22
    2e1c:	fmadd	s23, s31, s21, s23
    2e20:	fmadd	s24, s31, s23, s24
    2e24:	fmadd	s25, s31, s24, s25
    2e28:	fmadd	s28, s31, s25, s28
    2e2c:	fmul	s31, s31, s28
    2e30:	b.mi	2e38 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    2e34:	b	2a6c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    2e38:	movi	v29.2s, #0x0
    2e3c:	fmul	s31, s31, s29
    2e40:	b	2b30 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2e44:	mov	w0, #0x3389                	// #13193
    2e48:	fmov	s30, #1.000000000000000000e+00
    2e4c:	mov	w4, #0x466f                	// #18031
    2e50:	movk	w0, #0x3e6d, lsl #16
    2e54:	mov	w3, #0x1eea                	// #7914
    2e58:	fmov	s27, #5.000000000000000000e-01
    2e5c:	movk	w4, #0x3faa, lsl #16
    2e60:	movk	w3, #0xbfe9, lsl #16
    2e64:	fmov	s23, w0
    2e68:	mov	w2, #0x778                 	// #1912
    2e6c:	mov	w1, #0x8f89                	// #36745
    2e70:	fmov	s22, w4
    2e74:	movk	w2, #0x3fe4, lsl #16
    2e78:	movk	w1, #0xbeb6, lsl #16
    2e7c:	fmov	s24, w3
    2e80:	mov	w0, #0x85fa                	// #34298
    2e84:	fmov	s25, w2
    2e88:	movk	w0, #0x3ea3, lsl #16
    2e8c:	fmov	s26, w1
    2e90:	fmov	s28, w0
    2e94:	fmul	s27, s15, s27
    2e98:	fmsub	s23, s15, s23, s30
    2e9c:	fnmul	s27, s15, s27
    2ea0:	fcmpe	s27, s9
    2ea4:	fdiv	s30, s30, s23
    2ea8:	fmadd	s24, s30, s22, s24
    2eac:	fmadd	s25, s24, s30, s25
    2eb0:	fmadd	s26, s25, s30, s26
    2eb4:	fmadd	s28, s30, s26, s28
    2eb8:	fmul	s30, s30, s28
    2ebc:	b.mi	2d9c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2ec0:	b	2c80 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2ec4:	movi	v28.2s, #0x0
    2ec8:	b	2d78 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    2ecc:	movi	v29.2s, #0x0
    2ed0:	fmul	s31, s31, s29
    2ed4:	b	2b28 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2ed8:	mov	w7, #0x829c                	// #33436
    2edc:	movk	w7, #0x7ef8, lsl #16
    2ee0:	fmov	s29, w7
    2ee4:	b	2be0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    2ee8:	fmov	s27, #5.000000000000000000e-01
    2eec:	ldr	s24, [sp, #148]
    2ef0:	mov	w0, #0xaaab                	// #43691
    2ef4:	movk	w0, #0x3e2a, lsl #16
    2ef8:	mov	w1, #0xaaab                	// #43691
    2efc:	fmov	s29, #1.000000000000000000e+00
    2f00:	movk	w1, #0x3d2a, lsl #16
    2f04:	fmov	s26, w0
    2f08:	fadd	s28, s28, s27
    2f0c:	fmov	s25, w1
    2f10:	fcvtzs	s28, s28
    2f14:	scvtf	s28, s28
    2f18:	fmsub	s30, s28, s24, s30
    2f1c:	fcvtzs	w0, s28
    2f20:	ldp	s24, s28, [sp, #152]
    2f24:	fmadd	s24, s30, s24, s28
    2f28:	b	2bbc <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    2f2c:	fmov	s24, #5.000000000000000000e-01
    2f30:	ldr	s30, [sp, #148]
    2f34:	mov	w1, #0xaaab                	// #43691
    2f38:	movk	w1, #0x3d2a, lsl #16
    2f3c:	mov	w0, #0xaaab                	// #43691
    2f40:	fmov	s25, #1.000000000000000000e+00
    2f44:	movk	w0, #0x3e2a, lsl #16
    2f48:	mov	w2, #0x422a                	// #16938
    2f4c:	fmov	s22, w1
    2f50:	movk	w2, #0x3ecc, lsl #16
    2f54:	fadd	s28, s28, s24
    2f58:	fmov	s23, w0
    2f5c:	fmov	s21, w2
    2f60:	fcvtzs	s28, s28
    2f64:	scvtf	s28, s28
    2f68:	fmsub	s29, s28, s30, s29
    2f6c:	fcvtzs	w7, s28
    2f70:	ldp	s28, s30, [sp, #152]
    2f74:	fmadd	s20, s29, s28, s30
    2f78:	add	w7, w7, #0x7f
    2f7c:	fmov	s30, w7
    2f80:	fmadd	s22, s29, s20, s22
    2f84:	fmadd	s23, s29, s22, s23
    2f88:	shl	v28.2s, v30.2s, #23
    2f8c:	fmadd	s24, s29, s23, s24
    2f90:	fmadd	s24, s29, s24, s25
    2f94:	fmadd	s29, s29, s24, s25
    2f98:	fmul	s29, s29, s28
    2f9c:	fmul	s29, s29, s21
    2fa0:	b	2b08 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    2fa4:	fmov	s25, #5.000000000000000000e-01
    2fa8:	ldr	s21, [sp, #148]
    2fac:	mov	w0, #0xaaab                	// #43691
    2fb0:	movk	w0, #0x3e2a, lsl #16
    2fb4:	mov	w1, #0xaaab                	// #43691
    2fb8:	fmov	s26, #1.000000000000000000e+00
    2fbc:	movk	w1, #0x3d2a, lsl #16
    2fc0:	mov	w2, #0x422a                	// #16938
    2fc4:	fmov	s24, w0
    2fc8:	movk	w2, #0x3ecc, lsl #16
    2fcc:	fadd	s28, s28, s25
    2fd0:	fmov	s23, w1
    2fd4:	fmov	s22, w2
    2fd8:	fcvtzs	s28, s28
    2fdc:	scvtf	s28, s28
    2fe0:	fmsub	s27, s28, s21, s27
    2fe4:	fcvtzs	w0, s28
    2fe8:	ldp	s21, s28, [sp, #152]
    2fec:	fmadd	s21, s27, s21, s28
    2ff0:	add	w0, w0, #0x7f
    2ff4:	fmov	s28, w0
    2ff8:	fmadd	s23, s27, s21, s23
    2ffc:	fmadd	s24, s27, s23, s24
    3000:	shl	v28.2s, v28.2s, #23
    3004:	fmadd	s25, s27, s24, s25
    3008:	fmadd	s25, s27, s25, s26
    300c:	fmadd	s26, s27, s25, s26
    3010:	fmul	s28, s26, s28
    3014:	fmul	s28, s28, s22
    3018:	b	2d1c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    301c:	ret
