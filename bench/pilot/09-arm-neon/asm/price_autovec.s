00000000000027e0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    27e0:	cbz	x6, 2f9c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    27e4:	stp	x29, x30, [sp, #-160]!
    27e8:	mov	x29, sp
    27ec:	stp	x23, x24, [sp, #48]
    27f0:	mov	x24, x4
    27f4:	mov	w4, #0xaa3b                	// #43579
    27f8:	movk	w4, #0x3fb8, lsl #16
    27fc:	mov	x23, x3
    2800:	mov	w3, #0x7218                	// #29208
    2804:	stp	x19, x20, [sp, #16]
    2808:	mov	x20, x0
    280c:	mov	w0, #0xc2b00000            	// #-1028653056
    2810:	movk	w3, #0x3f31, lsl #16
    2814:	mov	x19, x6
    2818:	stp	d8, d9, [sp, #80]
    281c:	fmov	s9, w0
    2820:	stp	d14, d15, [sp, #128]
    2824:	fmov	s14, w4
    2828:	stp	x21, x22, [sp, #32]
    282c:	mov	x21, x1
    2830:	mov	x22, x2
    2834:	mov	w1, #0x8889                	// #34953
    2838:	mov	w2, #0xb61                 	// #2913
    283c:	movk	w2, #0x3ab6, lsl #16
    2840:	movk	w1, #0x3c08, lsl #16
    2844:	stp	x25, x26, [sp, #64]
    2848:	mov	x26, #0x0                   	// #0
    284c:	mov	x25, x5
    2850:	stp	d10, d11, [sp, #96]
    2854:	stp	d12, d13, [sp, #112]
    2858:	stp	w3, w2, [sp, #148]
    285c:	str	w1, [sp, #156]
    2860:	ldr	s12, [x22, x26, lsl #2]
    2864:	ldr	s15, [x24, x26, lsl #2]
    2868:	ldr	s13, [x20, x26, lsl #2]
    286c:	fcmp	s12, #0.0
    2870:	ldr	s8, [x21, x26, lsl #2]
    2874:	ldr	s11, [x23, x26, lsl #2]
    2878:	fmul	s10, s15, s15
    287c:	b.pl	2934 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    2880:	fmov	s0, s12
    2884:	bl	ec0 <sqrtf@plt>
    2888:	fmov	s31, s0
    288c:	fdiv	s0, s13, s8
    2890:	fmul	s15, s15, s31
    2894:	bl	1020 <logf@plt>
    2898:	fmov	s31, #5.000000000000000000e-01
    289c:	mov	w0, #0x3389                	// #13193
    28a0:	fmov	s25, #1.000000000000000000e+00
    28a4:	movk	w0, #0x3e6d, lsl #16
    28a8:	mov	w1, #0x466f                	// #18031
    28ac:	fmov	s19, #-5.000000000000000000e-01
    28b0:	mov	w4, #0x1eea                	// #7914
    28b4:	movk	w1, #0x3faa, lsl #16
    28b8:	fmov	s29, w0
    28bc:	movk	w4, #0xbfe9, lsl #16
    28c0:	mov	w3, #0x778                 	// #1912
    28c4:	fmadd	s10, s10, s31, s11
    28c8:	movk	w3, #0x3fe4, lsl #16
    28cc:	mov	w2, #0x8f89                	// #36745
    28d0:	fmov	s20, w1
    28d4:	movk	w2, #0xbeb6, lsl #16
    28d8:	mov	w1, #0x85fa                	// #34298
    28dc:	movk	w1, #0x3ea3, lsl #16
    28e0:	mov	w0, #0xaa3b                	// #43579
    28e4:	fmov	s22, w4
    28e8:	movk	w0, #0x3fb8, lsl #16
    28ec:	fmov	s23, w3
    28f0:	fmadd	s0, s12, s10, s0
    28f4:	fmov	s24, w2
    28f8:	fmov	s31, w1
    28fc:	fmov	s28, w0
    2900:	fdiv	s0, s0, s15
    2904:	fmadd	s21, s0, s29, s25
    2908:	fmul	s29, s0, s19
    290c:	fsub	s15, s0, s15
    2910:	fmul	s29, s29, s0
    2914:	fdiv	s25, s25, s21
    2918:	fmul	s28, s29, s28
    291c:	fmadd	s22, s25, s20, s22
    2920:	fmadd	s23, s22, s25, s23
    2924:	fmadd	s24, s23, s25, s24
    2928:	fmadd	s31, s24, s25, s31
    292c:	fmul	s31, s31, s25
    2930:	b	29f8 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    2934:	fsqrt	s31, s12
    2938:	fdiv	s0, s13, s8
    293c:	fmul	s15, s15, s31
    2940:	bl	1020 <logf@plt>
    2944:	fmov	s29, #5.000000000000000000e-01
    2948:	fmadd	s10, s10, s29, s11
    294c:	fmadd	s0, s12, s10, s0
    2950:	fdiv	s0, s0, s15
    2954:	fcmpe	s0, #0.0
    2958:	fsub	s15, s0, s15
    295c:	b.mi	2d3c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    2960:	mov	w0, #0x3389                	// #13193
    2964:	fmov	s31, #1.000000000000000000e+00
    2968:	mov	w4, #0x466f                	// #18031
    296c:	movk	w0, #0x3e6d, lsl #16
    2970:	mov	w3, #0x1eea                	// #7914
    2974:	fmov	s29, #-5.000000000000000000e-01
    2978:	movk	w4, #0x3faa, lsl #16
    297c:	movk	w3, #0xbfe9, lsl #16
    2980:	fmov	s22, w0
    2984:	mov	w2, #0x778                 	// #1912
    2988:	mov	w1, #0x8f89                	// #36745
    298c:	fmov	s21, w4
    2990:	movk	w2, #0x3fe4, lsl #16
    2994:	movk	w1, #0xbeb6, lsl #16
    2998:	fmov	s23, w3
    299c:	mov	w0, #0x85fa                	// #34298
    29a0:	fmov	s24, w2
    29a4:	movk	w0, #0x3ea3, lsl #16
    29a8:	fmov	s25, w1
    29ac:	fmov	s28, w0
    29b0:	fmul	s29, s0, s29
    29b4:	fmadd	s22, s0, s22, s31
    29b8:	fmul	s29, s29, s0
    29bc:	fcmpe	s29, s9
    29c0:	fdiv	s31, s31, s22
    29c4:	fmadd	s23, s31, s21, s23
    29c8:	fmadd	s24, s31, s23, s24
    29cc:	fmadd	s25, s31, s24, s25
    29d0:	fmadd	s28, s31, s25, s28
    29d4:	fmul	s31, s31, s28
    29d8:	b.mi	2e4c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    29dc:	mov	w0, #0x42b00000            	// #1118830592
    29e0:	fmov	s28, w0
    29e4:	fcmpe	s29, s28
    29e8:	b.gt	2a98 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    29ec:	fmul	s28, s29, s14
    29f0:	fcmpe	s28, #0.0
    29f4:	b.ge	2eac <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    29f8:	fmov	s23, #5.000000000000000000e-01
    29fc:	mov	w0, #0x7218                	// #29208
    2a00:	mov	w3, #0xb61                 	// #2913
    2a04:	movk	w0, #0x3f31, lsl #16
    2a08:	mov	w2, #0x8889                	// #34953
    2a0c:	fmov	s24, #1.000000000000000000e+00
    2a10:	movk	w3, #0x3ab6, lsl #16
    2a14:	movk	w2, #0x3c08, lsl #16
    2a18:	fmov	s25, w0
    2a1c:	mov	w1, #0xaaab                	// #43691
    2a20:	mov	w0, #0xaaab                	// #43691
    2a24:	fsub	s28, s28, s23
    2a28:	movk	w1, #0x3d2a, lsl #16
    2a2c:	movk	w0, #0x3e2a, lsl #16
    2a30:	fmov	s18, w3
    2a34:	mov	w4, #0x422a                	// #16938
    2a38:	fmov	s20, w2
    2a3c:	movk	w4, #0x3ecc, lsl #16
    2a40:	fmov	s21, w1
    2a44:	fmov	s22, w0
    2a48:	fmov	s19, w4
    2a4c:	fcvtzs	s28, s28
    2a50:	scvtf	s28, s28
    2a54:	fmsub	s25, s28, s25, s29
    2a58:	fcvtzs	w0, s28
    2a5c:	fmadd	s28, s25, s18, s20
    2a60:	add	w0, w0, #0x7f
    2a64:	fmov	s30, w0
    2a68:	fmadd	s28, s25, s28, s21
    2a6c:	fmadd	s28, s25, s28, s22
    2a70:	shl	v29.2s, v30.2s, #23
    2a74:	fmadd	s23, s25, s28, s23
    2a78:	fmadd	s23, s25, s23, s24
    2a7c:	fmadd	s24, s25, s23, s24
    2a80:	fmul	s29, s24, s29
    2a84:	fmul	s29, s29, s19
    2a88:	fcmpe	s0, #0.0
    2a8c:	fmul	s31, s31, s29
    2a90:	b.mi	2ab0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    2a94:	b	2aa8 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2a98:	mov	w0, #0x484f                	// #18511
    2a9c:	movk	w0, #0x7e46, lsl #16
    2aa0:	fmov	s29, w0
    2aa4:	fmul	s31, s31, s29
    2aa8:	fmov	s29, #1.000000000000000000e+00
    2aac:	fsub	s31, s29, s31
    2ab0:	fnmul	s30, s11, s12
    2ab4:	fmul	s31, s13, s31
    2ab8:	movi	v29.2s, #0x0
    2abc:	fcmpe	s30, s9
    2ac0:	b.mi	2b60 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2ac4:	mov	w0, #0x42b00000            	// #1118830592
    2ac8:	fmov	s29, w0
    2acc:	fcmpe	s30, s29
    2ad0:	b.gt	2e58 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2ad4:	fmul	s28, s30, s14
    2ad8:	fcmpe	s28, #0.0
    2adc:	b.ge	2e68 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    2ae0:	fmov	s27, #5.000000000000000000e-01
    2ae4:	mov	w0, #0x7218                	// #29208
    2ae8:	mov	w3, #0xb61                 	// #2913
    2aec:	movk	w0, #0x3f31, lsl #16
    2af0:	mov	w2, #0x8889                	// #34953
    2af4:	fmov	s29, #1.000000000000000000e+00
    2af8:	movk	w3, #0x3ab6, lsl #16
    2afc:	movk	w2, #0x3c08, lsl #16
    2b00:	fmov	s22, w0
    2b04:	mov	w1, #0xaaab                	// #43691
    2b08:	mov	w0, #0xaaab                	// #43691
    2b0c:	fsub	s28, s28, s27
    2b10:	movk	w1, #0x3d2a, lsl #16
    2b14:	movk	w0, #0x3e2a, lsl #16
    2b18:	fmov	s23, w3
    2b1c:	fmov	s24, w2
    2b20:	fmov	s25, w1
    2b24:	fmov	s26, w0
    2b28:	fcvtzs	s28, s28
    2b2c:	scvtf	s28, s28
    2b30:	fmsub	s30, s28, s22, s30
    2b34:	fcvtzs	w0, s28
    2b38:	fmadd	s24, s30, s23, s24
    2b3c:	fmadd	s25, s30, s24, s25
    2b40:	add	w0, w0, #0x7f
    2b44:	fmov	s28, w0
    2b48:	fmadd	s26, s30, s25, s26
    2b4c:	fmadd	s27, s30, s26, s27
    2b50:	shl	v28.2s, v28.2s, #23
    2b54:	fmadd	s27, s30, s27, s29
    2b58:	fmadd	s29, s30, s27, s29
    2b5c:	fmul	s29, s29, s28
    2b60:	fcmpe	s15, #0.0
    2b64:	fmul	s29, s8, s29
    2b68:	b.mi	2dc4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    2b6c:	mov	w0, #0x3389                	// #13193
    2b70:	fmov	s30, #1.000000000000000000e+00
    2b74:	mov	w4, #0x466f                	// #18031
    2b78:	movk	w0, #0x3e6d, lsl #16
    2b7c:	mov	w3, #0x1eea                	// #7914
    2b80:	fmov	s27, #-5.000000000000000000e-01
    2b84:	movk	w4, #0x3faa, lsl #16
    2b88:	movk	w3, #0xbfe9, lsl #16
    2b8c:	fmov	s23, w0
    2b90:	mov	w2, #0x778                 	// #1912
    2b94:	mov	w1, #0x8f89                	// #36745
    2b98:	fmov	s22, w4
    2b9c:	movk	w2, #0x3fe4, lsl #16
    2ba0:	movk	w1, #0xbeb6, lsl #16
    2ba4:	fmov	s24, w3
    2ba8:	mov	w0, #0x85fa                	// #34298
    2bac:	fmov	s25, w2
    2bb0:	movk	w0, #0x3ea3, lsl #16
    2bb4:	fmov	s26, w1
    2bb8:	fmov	s28, w0
    2bbc:	fmul	s27, s15, s27
    2bc0:	fmadd	s23, s15, s23, s30
    2bc4:	fmul	s27, s27, s15
    2bc8:	fcmpe	s27, s9
    2bcc:	fdiv	s30, s30, s23
    2bd0:	fmadd	s24, s30, s22, s24
    2bd4:	fmadd	s25, s30, s24, s25
    2bd8:	fmadd	s26, s30, s25, s26
    2bdc:	fmadd	s28, s30, s26, s28
    2be0:	fmul	s30, s30, s28
    2be4:	b.mi	2e44 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    2be8:	mov	w0, #0x42b00000            	// #1118830592
    2bec:	fmov	s28, w0
    2bf0:	fcmpe	s27, s28
    2bf4:	b.gt	2cec <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    2bf8:	nop
    2bfc:	nop
    2c00:	fmul	s28, s27, s14
    2c04:	fcmpe	s28, #0.0
    2c08:	b.ge	2f24 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    2c0c:	fmov	s25, #5.000000000000000000e-01
    2c10:	mov	w0, #0x7218                	// #29208
    2c14:	mov	w4, #0xb61                 	// #2913
    2c18:	movk	w0, #0x3f31, lsl #16
    2c1c:	mov	w2, #0x8889                	// #34953
    2c20:	fmov	s26, #1.000000000000000000e+00
    2c24:	movk	w4, #0x3ab6, lsl #16
    2c28:	movk	w2, #0x3c08, lsl #16
    2c2c:	fmov	s19, w0
    2c30:	mov	w1, #0xaaab                	// #43691
    2c34:	mov	w0, #0xaaab                	// #43691
    2c38:	fsub	s28, s28, s25
    2c3c:	movk	w1, #0x3d2a, lsl #16
    2c40:	movk	w0, #0x3e2a, lsl #16
    2c44:	fmov	s20, w4
    2c48:	mov	w3, #0x422a                	// #16938
    2c4c:	fmov	s22, w2
    2c50:	movk	w3, #0x3ecc, lsl #16
    2c54:	fmov	s23, w1
    2c58:	fmov	s24, w0
    2c5c:	fmov	s21, w3
    2c60:	fcvtzs	s28, s28
    2c64:	scvtf	s28, s28
    2c68:	fmsub	s27, s28, s19, s27
    2c6c:	fcvtzs	w0, s28
    2c70:	fmadd	s22, s27, s20, s22
    2c74:	add	w0, w0, #0x7f
    2c78:	fmov	s28, w0
    2c7c:	fmadd	s23, s27, s22, s23
    2c80:	fmadd	s24, s27, s23, s24
    2c84:	shl	v28.2s, v28.2s, #23
    2c88:	fmadd	s25, s27, s24, s25
    2c8c:	fmadd	s25, s27, s25, s26
    2c90:	fmadd	s26, s27, s25, s26
    2c94:	fmul	s28, s26, s28
    2c98:	fmul	s28, s28, s21
    2c9c:	fcmpe	s15, #0.0
    2ca0:	fmul	s30, s30, s28
    2ca4:	b.mi	2d24 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    2ca8:	fmov	s28, #1.000000000000000000e+00
    2cac:	fsub	s30, s28, s30
    2cb0:	fmsub	s31, s29, s30, s31
    2cb4:	str	s31, [x25, x26, lsl #2]
    2cb8:	add	x26, x26, #0x1
    2cbc:	cmp	x26, x19
    2cc0:	b.ne	2860 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2cc4:	ldp	d8, d9, [sp, #80]
    2cc8:	ldp	x19, x20, [sp, #16]
    2ccc:	ldp	x21, x22, [sp, #32]
    2cd0:	ldp	x23, x24, [sp, #48]
    2cd4:	ldp	x25, x26, [sp, #64]
    2cd8:	ldp	d10, d11, [sp, #96]
    2cdc:	ldp	d12, d13, [sp, #112]
    2ce0:	ldp	d14, d15, [sp, #128]
    2ce4:	ldp	x29, x30, [sp], #160
    2ce8:	ret
    2cec:	mov	w0, #0x484f                	// #18511
    2cf0:	movk	w0, #0x7e46, lsl #16
    2cf4:	fmov	s28, w0
    2cf8:	fmul	s30, s30, s28
    2cfc:	fmov	s28, #1.000000000000000000e+00
    2d00:	fsub	s30, s28, s30
    2d04:	fmsub	s31, s29, s30, s31
    2d08:	str	s31, [x25, x26, lsl #2]
    2d0c:	add	x26, x26, #0x1
    2d10:	cmp	x26, x19
    2d14:	b.ne	2860 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2d18:	b	2cc4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    2d1c:	movi	v28.2s, #0x0
    2d20:	fmul	s30, s30, s28
    2d24:	fmsub	s30, s29, s30, s31
    2d28:	str	s30, [x25, x26, lsl #2]
    2d2c:	add	x26, x26, #0x1
    2d30:	cmp	x19, x26
    2d34:	b.ne	2860 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2d38:	b	2cc4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    2d3c:	mov	w0, #0x3389                	// #13193
    2d40:	fmov	s31, #1.000000000000000000e+00
    2d44:	mov	w4, #0x466f                	// #18031
    2d48:	movk	w0, #0x3e6d, lsl #16
    2d4c:	mov	w3, #0x1eea                	// #7914
    2d50:	fmul	s29, s0, s29
    2d54:	movk	w4, #0x3faa, lsl #16
    2d58:	movk	w3, #0xbfe9, lsl #16
    2d5c:	fmov	s22, w0
    2d60:	mov	w2, #0x778                 	// #1912
    2d64:	mov	w1, #0x8f89                	// #36745
    2d68:	fmov	s21, w4
    2d6c:	movk	w2, #0x3fe4, lsl #16
    2d70:	movk	w1, #0xbeb6, lsl #16
    2d74:	fmov	s23, w3
    2d78:	mov	w0, #0x85fa                	// #34298
    2d7c:	fmov	s24, w2
    2d80:	movk	w0, #0x3ea3, lsl #16
    2d84:	fmov	s25, w1
    2d88:	fmov	s28, w0
    2d8c:	fnmul	s29, s0, s29
    2d90:	fmsub	s22, s0, s22, s31
    2d94:	fcmpe	s29, s9
    2d98:	fdiv	s31, s31, s22
    2d9c:	fmadd	s23, s31, s21, s23
    2da0:	fmadd	s24, s31, s23, s24
    2da4:	fmadd	s25, s31, s24, s25
    2da8:	fmadd	s28, s31, s25, s28
    2dac:	fmul	s31, s31, s28
    2db0:	b.mi	2db8 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    2db4:	b	29ec <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    2db8:	movi	v29.2s, #0x0
    2dbc:	fmul	s31, s31, s29
    2dc0:	b	2ab0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2dc4:	mov	w0, #0x3389                	// #13193
    2dc8:	fmov	s30, #1.000000000000000000e+00
    2dcc:	mov	w4, #0x466f                	// #18031
    2dd0:	movk	w0, #0x3e6d, lsl #16
    2dd4:	mov	w3, #0x1eea                	// #7914
    2dd8:	fmov	s27, #5.000000000000000000e-01
    2ddc:	movk	w4, #0x3faa, lsl #16
    2de0:	movk	w3, #0xbfe9, lsl #16
    2de4:	fmov	s23, w0
    2de8:	mov	w2, #0x778                 	// #1912
    2dec:	mov	w1, #0x8f89                	// #36745
    2df0:	fmov	s22, w4
    2df4:	movk	w2, #0x3fe4, lsl #16
    2df8:	movk	w1, #0xbeb6, lsl #16
    2dfc:	fmov	s24, w3
    2e00:	mov	w0, #0x85fa                	// #34298
    2e04:	fmov	s25, w2
    2e08:	movk	w0, #0x3ea3, lsl #16
    2e0c:	fmov	s26, w1
    2e10:	fmov	s28, w0
    2e14:	fmul	s27, s15, s27
    2e18:	fmsub	s23, s15, s23, s30
    2e1c:	fnmul	s27, s15, s27
    2e20:	fcmpe	s27, s9
    2e24:	fdiv	s30, s30, s23
    2e28:	fmadd	s24, s30, s22, s24
    2e2c:	fmadd	s25, s24, s30, s25
    2e30:	fmadd	s26, s25, s30, s26
    2e34:	fmadd	s28, s30, s26, s28
    2e38:	fmul	s30, s30, s28
    2e3c:	b.mi	2d1c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2e40:	b	2c00 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2e44:	movi	v28.2s, #0x0
    2e48:	b	2cf8 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    2e4c:	movi	v29.2s, #0x0
    2e50:	fmul	s31, s31, s29
    2e54:	b	2aa8 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2e58:	mov	w7, #0x829c                	// #33436
    2e5c:	movk	w7, #0x7ef8, lsl #16
    2e60:	fmov	s29, w7
    2e64:	b	2b60 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    2e68:	fmov	s27, #5.000000000000000000e-01
    2e6c:	ldr	s24, [sp, #148]
    2e70:	mov	w0, #0xaaab                	// #43691
    2e74:	movk	w0, #0x3e2a, lsl #16
    2e78:	mov	w1, #0xaaab                	// #43691
    2e7c:	fmov	s29, #1.000000000000000000e+00
    2e80:	movk	w1, #0x3d2a, lsl #16
    2e84:	fmov	s26, w0
    2e88:	fadd	s28, s28, s27
    2e8c:	fmov	s25, w1
    2e90:	fcvtzs	s28, s28
    2e94:	scvtf	s28, s28
    2e98:	fmsub	s30, s28, s24, s30
    2e9c:	fcvtzs	w0, s28
    2ea0:	ldp	s24, s28, [sp, #152]
    2ea4:	fmadd	s24, s30, s24, s28
    2ea8:	b	2b3c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    2eac:	fmov	s24, #5.000000000000000000e-01
    2eb0:	ldr	s30, [sp, #148]
    2eb4:	mov	w1, #0xaaab                	// #43691
    2eb8:	movk	w1, #0x3d2a, lsl #16
    2ebc:	mov	w0, #0xaaab                	// #43691
    2ec0:	fmov	s25, #1.000000000000000000e+00
    2ec4:	movk	w0, #0x3e2a, lsl #16
    2ec8:	mov	w2, #0x422a                	// #16938
    2ecc:	fmov	s22, w1
    2ed0:	movk	w2, #0x3ecc, lsl #16
    2ed4:	fadd	s28, s28, s24
    2ed8:	fmov	s23, w0
    2edc:	fmov	s21, w2
    2ee0:	fcvtzs	s28, s28
    2ee4:	scvtf	s28, s28
    2ee8:	fmsub	s29, s28, s30, s29
    2eec:	fcvtzs	w7, s28
    2ef0:	ldp	s28, s30, [sp, #152]
    2ef4:	fmadd	s20, s29, s28, s30
    2ef8:	add	w7, w7, #0x7f
    2efc:	fmov	s30, w7
    2f00:	fmadd	s22, s29, s20, s22
    2f04:	fmadd	s23, s29, s22, s23
    2f08:	shl	v28.2s, v30.2s, #23
    2f0c:	fmadd	s24, s29, s23, s24
    2f10:	fmadd	s24, s29, s24, s25
    2f14:	fmadd	s29, s29, s24, s25
    2f18:	fmul	s29, s29, s28
    2f1c:	fmul	s29, s29, s21
    2f20:	b	2a88 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    2f24:	fmov	s25, #5.000000000000000000e-01
    2f28:	ldr	s21, [sp, #148]
    2f2c:	mov	w0, #0xaaab                	// #43691
    2f30:	movk	w0, #0x3e2a, lsl #16
    2f34:	mov	w1, #0xaaab                	// #43691
    2f38:	fmov	s26, #1.000000000000000000e+00
    2f3c:	movk	w1, #0x3d2a, lsl #16
    2f40:	mov	w2, #0x422a                	// #16938
    2f44:	fmov	s24, w0
    2f48:	movk	w2, #0x3ecc, lsl #16
    2f4c:	fadd	s28, s28, s25
    2f50:	fmov	s23, w1
    2f54:	fmov	s22, w2
    2f58:	fcvtzs	s28, s28
    2f5c:	scvtf	s28, s28
    2f60:	fmsub	s27, s28, s21, s27
    2f64:	fcvtzs	w0, s28
    2f68:	ldp	s21, s28, [sp, #152]
    2f6c:	fmadd	s21, s27, s21, s28
    2f70:	add	w0, w0, #0x7f
    2f74:	fmov	s28, w0
    2f78:	fmadd	s23, s27, s21, s23
    2f7c:	fmadd	s24, s27, s23, s24
    2f80:	shl	v28.2s, v28.2s, #23
    2f84:	fmadd	s25, s27, s24, s25
    2f88:	fmadd	s25, s27, s25, s26
    2f8c:	fmadd	s26, s27, s25, s26
    2f90:	fmul	s28, s26, s28
    2f94:	fmul	s28, s28, s22
    2f98:	b	2c9c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    2f9c:	ret
