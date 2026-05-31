0000000000002760 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    2760:	cbz	x6, 2f1c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    2764:	stp	x29, x30, [sp, #-160]!
    2768:	mov	x29, sp
    276c:	stp	x23, x24, [sp, #48]
    2770:	mov	x24, x4
    2774:	mov	w4, #0xaa3b                	// #43579
    2778:	movk	w4, #0x3fb8, lsl #16
    277c:	mov	x23, x3
    2780:	mov	w3, #0x7218                	// #29208
    2784:	stp	x19, x20, [sp, #16]
    2788:	mov	x20, x0
    278c:	mov	w0, #0xc2b00000            	// #-1028653056
    2790:	movk	w3, #0x3f31, lsl #16
    2794:	mov	x19, x6
    2798:	stp	d8, d9, [sp, #80]
    279c:	fmov	s9, w0
    27a0:	stp	d14, d15, [sp, #128]
    27a4:	fmov	s14, w4
    27a8:	stp	x21, x22, [sp, #32]
    27ac:	mov	x21, x1
    27b0:	mov	x22, x2
    27b4:	mov	w1, #0x8889                	// #34953
    27b8:	mov	w2, #0xb61                 	// #2913
    27bc:	movk	w2, #0x3ab6, lsl #16
    27c0:	movk	w1, #0x3c08, lsl #16
    27c4:	stp	x25, x26, [sp, #64]
    27c8:	mov	x26, #0x0                   	// #0
    27cc:	mov	x25, x5
    27d0:	stp	d10, d11, [sp, #96]
    27d4:	stp	d12, d13, [sp, #112]
    27d8:	stp	w3, w2, [sp, #148]
    27dc:	str	w1, [sp, #156]
    27e0:	ldr	s12, [x22, x26, lsl #2]
    27e4:	ldr	s15, [x24, x26, lsl #2]
    27e8:	ldr	s13, [x20, x26, lsl #2]
    27ec:	fcmp	s12, #0.0
    27f0:	ldr	s8, [x21, x26, lsl #2]
    27f4:	ldr	s11, [x23, x26, lsl #2]
    27f8:	fmul	s10, s15, s15
    27fc:	b.pl	28b4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    2800:	fmov	s0, s12
    2804:	bl	ec0 <sqrtf@plt>
    2808:	fmov	s31, s0
    280c:	fdiv	s0, s13, s8
    2810:	fmul	s15, s15, s31
    2814:	bl	1020 <logf@plt>
    2818:	fmov	s31, #5.000000000000000000e-01
    281c:	mov	w0, #0x3389                	// #13193
    2820:	fmov	s25, #1.000000000000000000e+00
    2824:	movk	w0, #0x3e6d, lsl #16
    2828:	mov	w1, #0x466f                	// #18031
    282c:	fmov	s19, #-5.000000000000000000e-01
    2830:	mov	w4, #0x1eea                	// #7914
    2834:	movk	w1, #0x3faa, lsl #16
    2838:	fmov	s29, w0
    283c:	movk	w4, #0xbfe9, lsl #16
    2840:	mov	w3, #0x778                 	// #1912
    2844:	fmadd	s10, s10, s31, s11
    2848:	movk	w3, #0x3fe4, lsl #16
    284c:	mov	w2, #0x8f89                	// #36745
    2850:	fmov	s20, w1
    2854:	movk	w2, #0xbeb6, lsl #16
    2858:	mov	w1, #0x85fa                	// #34298
    285c:	movk	w1, #0x3ea3, lsl #16
    2860:	mov	w0, #0xaa3b                	// #43579
    2864:	fmov	s22, w4
    2868:	movk	w0, #0x3fb8, lsl #16
    286c:	fmov	s23, w3
    2870:	fmadd	s0, s12, s10, s0
    2874:	fmov	s24, w2
    2878:	fmov	s31, w1
    287c:	fmov	s28, w0
    2880:	fdiv	s0, s0, s15
    2884:	fmadd	s21, s0, s29, s25
    2888:	fmul	s29, s0, s19
    288c:	fsub	s15, s0, s15
    2890:	fmul	s29, s29, s0
    2894:	fdiv	s25, s25, s21
    2898:	fmul	s28, s29, s28
    289c:	fmadd	s22, s25, s20, s22
    28a0:	fmadd	s23, s22, s25, s23
    28a4:	fmadd	s24, s23, s25, s24
    28a8:	fmadd	s31, s24, s25, s31
    28ac:	fmul	s31, s31, s25
    28b0:	b	2978 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    28b4:	fsqrt	s31, s12
    28b8:	fdiv	s0, s13, s8
    28bc:	fmul	s15, s15, s31
    28c0:	bl	1020 <logf@plt>
    28c4:	fmov	s29, #5.000000000000000000e-01
    28c8:	fmadd	s10, s10, s29, s11
    28cc:	fmadd	s0, s12, s10, s0
    28d0:	fdiv	s0, s0, s15
    28d4:	fcmpe	s0, #0.0
    28d8:	fsub	s15, s0, s15
    28dc:	b.mi	2cbc <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    28e0:	mov	w0, #0x3389                	// #13193
    28e4:	fmov	s31, #1.000000000000000000e+00
    28e8:	mov	w4, #0x466f                	// #18031
    28ec:	movk	w0, #0x3e6d, lsl #16
    28f0:	mov	w3, #0x1eea                	// #7914
    28f4:	fmov	s29, #-5.000000000000000000e-01
    28f8:	movk	w4, #0x3faa, lsl #16
    28fc:	movk	w3, #0xbfe9, lsl #16
    2900:	fmov	s22, w0
    2904:	mov	w2, #0x778                 	// #1912
    2908:	mov	w1, #0x8f89                	// #36745
    290c:	fmov	s21, w4
    2910:	movk	w2, #0x3fe4, lsl #16
    2914:	movk	w1, #0xbeb6, lsl #16
    2918:	fmov	s23, w3
    291c:	mov	w0, #0x85fa                	// #34298
    2920:	fmov	s24, w2
    2924:	movk	w0, #0x3ea3, lsl #16
    2928:	fmov	s25, w1
    292c:	fmov	s28, w0
    2930:	fmul	s29, s0, s29
    2934:	fmadd	s22, s0, s22, s31
    2938:	fmul	s29, s29, s0
    293c:	fcmpe	s29, s9
    2940:	fdiv	s31, s31, s22
    2944:	fmadd	s23, s31, s21, s23
    2948:	fmadd	s24, s31, s23, s24
    294c:	fmadd	s25, s31, s24, s25
    2950:	fmadd	s28, s31, s25, s28
    2954:	fmul	s31, s31, s28
    2958:	b.mi	2dcc <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    295c:	mov	w0, #0x42b00000            	// #1118830592
    2960:	fmov	s28, w0
    2964:	fcmpe	s29, s28
    2968:	b.gt	2a18 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    296c:	fmul	s28, s29, s14
    2970:	fcmpe	s28, #0.0
    2974:	b.ge	2e2c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    2978:	fmov	s23, #5.000000000000000000e-01
    297c:	mov	w0, #0x7218                	// #29208
    2980:	mov	w3, #0xb61                 	// #2913
    2984:	movk	w0, #0x3f31, lsl #16
    2988:	mov	w2, #0x8889                	// #34953
    298c:	fmov	s24, #1.000000000000000000e+00
    2990:	movk	w3, #0x3ab6, lsl #16
    2994:	movk	w2, #0x3c08, lsl #16
    2998:	fmov	s25, w0
    299c:	mov	w1, #0xaaab                	// #43691
    29a0:	mov	w0, #0xaaab                	// #43691
    29a4:	fsub	s28, s28, s23
    29a8:	movk	w1, #0x3d2a, lsl #16
    29ac:	movk	w0, #0x3e2a, lsl #16
    29b0:	fmov	s18, w3
    29b4:	mov	w4, #0x422a                	// #16938
    29b8:	fmov	s20, w2
    29bc:	movk	w4, #0x3ecc, lsl #16
    29c0:	fmov	s21, w1
    29c4:	fmov	s22, w0
    29c8:	fmov	s19, w4
    29cc:	fcvtzs	s28, s28
    29d0:	scvtf	s28, s28
    29d4:	fmsub	s25, s28, s25, s29
    29d8:	fcvtzs	w0, s28
    29dc:	fmadd	s28, s25, s18, s20
    29e0:	add	w0, w0, #0x7f
    29e4:	fmov	s30, w0
    29e8:	fmadd	s28, s25, s28, s21
    29ec:	fmadd	s28, s25, s28, s22
    29f0:	shl	v29.2s, v30.2s, #23
    29f4:	fmadd	s23, s25, s28, s23
    29f8:	fmadd	s23, s25, s23, s24
    29fc:	fmadd	s24, s25, s23, s24
    2a00:	fmul	s29, s24, s29
    2a04:	fmul	s29, s29, s19
    2a08:	fcmpe	s0, #0.0
    2a0c:	fmul	s31, s31, s29
    2a10:	b.mi	2a30 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    2a14:	b	2a28 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2a18:	mov	w0, #0x484f                	// #18511
    2a1c:	movk	w0, #0x7e46, lsl #16
    2a20:	fmov	s29, w0
    2a24:	fmul	s31, s31, s29
    2a28:	fmov	s29, #1.000000000000000000e+00
    2a2c:	fsub	s31, s29, s31
    2a30:	fnmul	s30, s11, s12
    2a34:	fmul	s31, s13, s31
    2a38:	movi	v29.2s, #0x0
    2a3c:	fcmpe	s30, s9
    2a40:	b.mi	2ae0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2a44:	mov	w0, #0x42b00000            	// #1118830592
    2a48:	fmov	s29, w0
    2a4c:	fcmpe	s30, s29
    2a50:	b.gt	2dd8 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2a54:	fmul	s28, s30, s14
    2a58:	fcmpe	s28, #0.0
    2a5c:	b.ge	2de8 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    2a60:	fmov	s27, #5.000000000000000000e-01
    2a64:	mov	w0, #0x7218                	// #29208
    2a68:	mov	w3, #0xb61                 	// #2913
    2a6c:	movk	w0, #0x3f31, lsl #16
    2a70:	mov	w2, #0x8889                	// #34953
    2a74:	fmov	s29, #1.000000000000000000e+00
    2a78:	movk	w3, #0x3ab6, lsl #16
    2a7c:	movk	w2, #0x3c08, lsl #16
    2a80:	fmov	s22, w0
    2a84:	mov	w1, #0xaaab                	// #43691
    2a88:	mov	w0, #0xaaab                	// #43691
    2a8c:	fsub	s28, s28, s27
    2a90:	movk	w1, #0x3d2a, lsl #16
    2a94:	movk	w0, #0x3e2a, lsl #16
    2a98:	fmov	s23, w3
    2a9c:	fmov	s24, w2
    2aa0:	fmov	s25, w1
    2aa4:	fmov	s26, w0
    2aa8:	fcvtzs	s28, s28
    2aac:	scvtf	s28, s28
    2ab0:	fmsub	s30, s28, s22, s30
    2ab4:	fcvtzs	w0, s28
    2ab8:	fmadd	s24, s30, s23, s24
    2abc:	fmadd	s25, s30, s24, s25
    2ac0:	add	w0, w0, #0x7f
    2ac4:	fmov	s28, w0
    2ac8:	fmadd	s26, s30, s25, s26
    2acc:	fmadd	s27, s30, s26, s27
    2ad0:	shl	v28.2s, v28.2s, #23
    2ad4:	fmadd	s27, s30, s27, s29
    2ad8:	fmadd	s29, s30, s27, s29
    2adc:	fmul	s29, s29, s28
    2ae0:	fcmpe	s15, #0.0
    2ae4:	fmul	s29, s8, s29
    2ae8:	b.mi	2d44 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    2aec:	mov	w0, #0x3389                	// #13193
    2af0:	fmov	s30, #1.000000000000000000e+00
    2af4:	mov	w4, #0x466f                	// #18031
    2af8:	movk	w0, #0x3e6d, lsl #16
    2afc:	mov	w3, #0x1eea                	// #7914
    2b00:	fmov	s27, #-5.000000000000000000e-01
    2b04:	movk	w4, #0x3faa, lsl #16
    2b08:	movk	w3, #0xbfe9, lsl #16
    2b0c:	fmov	s23, w0
    2b10:	mov	w2, #0x778                 	// #1912
    2b14:	mov	w1, #0x8f89                	// #36745
    2b18:	fmov	s22, w4
    2b1c:	movk	w2, #0x3fe4, lsl #16
    2b20:	movk	w1, #0xbeb6, lsl #16
    2b24:	fmov	s24, w3
    2b28:	mov	w0, #0x85fa                	// #34298
    2b2c:	fmov	s25, w2
    2b30:	movk	w0, #0x3ea3, lsl #16
    2b34:	fmov	s26, w1
    2b38:	fmov	s28, w0
    2b3c:	fmul	s27, s15, s27
    2b40:	fmadd	s23, s15, s23, s30
    2b44:	fmul	s27, s27, s15
    2b48:	fcmpe	s27, s9
    2b4c:	fdiv	s30, s30, s23
    2b50:	fmadd	s24, s30, s22, s24
    2b54:	fmadd	s25, s30, s24, s25
    2b58:	fmadd	s26, s30, s25, s26
    2b5c:	fmadd	s28, s30, s26, s28
    2b60:	fmul	s30, s30, s28
    2b64:	b.mi	2dc4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    2b68:	mov	w0, #0x42b00000            	// #1118830592
    2b6c:	fmov	s28, w0
    2b70:	fcmpe	s27, s28
    2b74:	b.gt	2c6c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    2b78:	nop
    2b7c:	nop
    2b80:	fmul	s28, s27, s14
    2b84:	fcmpe	s28, #0.0
    2b88:	b.ge	2ea4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    2b8c:	fmov	s25, #5.000000000000000000e-01
    2b90:	mov	w0, #0x7218                	// #29208
    2b94:	mov	w4, #0xb61                 	// #2913
    2b98:	movk	w0, #0x3f31, lsl #16
    2b9c:	mov	w2, #0x8889                	// #34953
    2ba0:	fmov	s26, #1.000000000000000000e+00
    2ba4:	movk	w4, #0x3ab6, lsl #16
    2ba8:	movk	w2, #0x3c08, lsl #16
    2bac:	fmov	s19, w0
    2bb0:	mov	w1, #0xaaab                	// #43691
    2bb4:	mov	w0, #0xaaab                	// #43691
    2bb8:	fsub	s28, s28, s25
    2bbc:	movk	w1, #0x3d2a, lsl #16
    2bc0:	movk	w0, #0x3e2a, lsl #16
    2bc4:	fmov	s20, w4
    2bc8:	mov	w3, #0x422a                	// #16938
    2bcc:	fmov	s22, w2
    2bd0:	movk	w3, #0x3ecc, lsl #16
    2bd4:	fmov	s23, w1
    2bd8:	fmov	s24, w0
    2bdc:	fmov	s21, w3
    2be0:	fcvtzs	s28, s28
    2be4:	scvtf	s28, s28
    2be8:	fmsub	s27, s28, s19, s27
    2bec:	fcvtzs	w0, s28
    2bf0:	fmadd	s22, s27, s20, s22
    2bf4:	add	w0, w0, #0x7f
    2bf8:	fmov	s28, w0
    2bfc:	fmadd	s23, s27, s22, s23
    2c00:	fmadd	s24, s27, s23, s24
    2c04:	shl	v28.2s, v28.2s, #23
    2c08:	fmadd	s25, s27, s24, s25
    2c0c:	fmadd	s25, s27, s25, s26
    2c10:	fmadd	s26, s27, s25, s26
    2c14:	fmul	s28, s26, s28
    2c18:	fmul	s28, s28, s21
    2c1c:	fcmpe	s15, #0.0
    2c20:	fmul	s30, s30, s28
    2c24:	b.mi	2ca4 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    2c28:	fmov	s28, #1.000000000000000000e+00
    2c2c:	fsub	s30, s28, s30
    2c30:	fmsub	s31, s29, s30, s31
    2c34:	str	s31, [x25, x26, lsl #2]
    2c38:	add	x26, x26, #0x1
    2c3c:	cmp	x26, x19
    2c40:	b.ne	27e0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2c44:	ldp	d8, d9, [sp, #80]
    2c48:	ldp	x19, x20, [sp, #16]
    2c4c:	ldp	x21, x22, [sp, #32]
    2c50:	ldp	x23, x24, [sp, #48]
    2c54:	ldp	x25, x26, [sp, #64]
    2c58:	ldp	d10, d11, [sp, #96]
    2c5c:	ldp	d12, d13, [sp, #112]
    2c60:	ldp	d14, d15, [sp, #128]
    2c64:	ldp	x29, x30, [sp], #160
    2c68:	ret
    2c6c:	mov	w0, #0x484f                	// #18511
    2c70:	movk	w0, #0x7e46, lsl #16
    2c74:	fmov	s28, w0
    2c78:	fmul	s30, s30, s28
    2c7c:	fmov	s28, #1.000000000000000000e+00
    2c80:	fsub	s30, s28, s30
    2c84:	fmsub	s31, s29, s30, s31
    2c88:	str	s31, [x25, x26, lsl #2]
    2c8c:	add	x26, x26, #0x1
    2c90:	cmp	x26, x19
    2c94:	b.ne	27e0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2c98:	b	2c44 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    2c9c:	movi	v28.2s, #0x0
    2ca0:	fmul	s30, s30, s28
    2ca4:	fmsub	s30, s29, s30, s31
    2ca8:	str	s30, [x25, x26, lsl #2]
    2cac:	add	x26, x26, #0x1
    2cb0:	cmp	x19, x26
    2cb4:	b.ne	27e0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2cb8:	b	2c44 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    2cbc:	mov	w0, #0x3389                	// #13193
    2cc0:	fmov	s31, #1.000000000000000000e+00
    2cc4:	mov	w4, #0x466f                	// #18031
    2cc8:	movk	w0, #0x3e6d, lsl #16
    2ccc:	mov	w3, #0x1eea                	// #7914
    2cd0:	fmul	s29, s0, s29
    2cd4:	movk	w4, #0x3faa, lsl #16
    2cd8:	movk	w3, #0xbfe9, lsl #16
    2cdc:	fmov	s22, w0
    2ce0:	mov	w2, #0x778                 	// #1912
    2ce4:	mov	w1, #0x8f89                	// #36745
    2ce8:	fmov	s21, w4
    2cec:	movk	w2, #0x3fe4, lsl #16
    2cf0:	movk	w1, #0xbeb6, lsl #16
    2cf4:	fmov	s23, w3
    2cf8:	mov	w0, #0x85fa                	// #34298
    2cfc:	fmov	s24, w2
    2d00:	movk	w0, #0x3ea3, lsl #16
    2d04:	fmov	s25, w1
    2d08:	fmov	s28, w0
    2d0c:	fnmul	s29, s0, s29
    2d10:	fmsub	s22, s0, s22, s31
    2d14:	fcmpe	s29, s9
    2d18:	fdiv	s31, s31, s22
    2d1c:	fmadd	s23, s31, s21, s23
    2d20:	fmadd	s24, s31, s23, s24
    2d24:	fmadd	s25, s31, s24, s25
    2d28:	fmadd	s28, s31, s25, s28
    2d2c:	fmul	s31, s31, s28
    2d30:	b.mi	2d38 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    2d34:	b	296c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    2d38:	movi	v29.2s, #0x0
    2d3c:	fmul	s31, s31, s29
    2d40:	b	2a30 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2d44:	mov	w0, #0x3389                	// #13193
    2d48:	fmov	s30, #1.000000000000000000e+00
    2d4c:	mov	w4, #0x466f                	// #18031
    2d50:	movk	w0, #0x3e6d, lsl #16
    2d54:	mov	w3, #0x1eea                	// #7914
    2d58:	fmov	s27, #5.000000000000000000e-01
    2d5c:	movk	w4, #0x3faa, lsl #16
    2d60:	movk	w3, #0xbfe9, lsl #16
    2d64:	fmov	s23, w0
    2d68:	mov	w2, #0x778                 	// #1912
    2d6c:	mov	w1, #0x8f89                	// #36745
    2d70:	fmov	s22, w4
    2d74:	movk	w2, #0x3fe4, lsl #16
    2d78:	movk	w1, #0xbeb6, lsl #16
    2d7c:	fmov	s24, w3
    2d80:	mov	w0, #0x85fa                	// #34298
    2d84:	fmov	s25, w2
    2d88:	movk	w0, #0x3ea3, lsl #16
    2d8c:	fmov	s26, w1
    2d90:	fmov	s28, w0
    2d94:	fmul	s27, s15, s27
    2d98:	fmsub	s23, s15, s23, s30
    2d9c:	fnmul	s27, s15, s27
    2da0:	fcmpe	s27, s9
    2da4:	fdiv	s30, s30, s23
    2da8:	fmadd	s24, s30, s22, s24
    2dac:	fmadd	s25, s24, s30, s25
    2db0:	fmadd	s26, s25, s30, s26
    2db4:	fmadd	s28, s30, s26, s28
    2db8:	fmul	s30, s30, s28
    2dbc:	b.mi	2c9c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2dc0:	b	2b80 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2dc4:	movi	v28.2s, #0x0
    2dc8:	b	2c78 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    2dcc:	movi	v29.2s, #0x0
    2dd0:	fmul	s31, s31, s29
    2dd4:	b	2a28 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2dd8:	mov	w7, #0x829c                	// #33436
    2ddc:	movk	w7, #0x7ef8, lsl #16
    2de0:	fmov	s29, w7
    2de4:	b	2ae0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    2de8:	fmov	s27, #5.000000000000000000e-01
    2dec:	ldr	s24, [sp, #148]
    2df0:	mov	w0, #0xaaab                	// #43691
    2df4:	movk	w0, #0x3e2a, lsl #16
    2df8:	mov	w1, #0xaaab                	// #43691
    2dfc:	fmov	s29, #1.000000000000000000e+00
    2e00:	movk	w1, #0x3d2a, lsl #16
    2e04:	fmov	s26, w0
    2e08:	fadd	s28, s28, s27
    2e0c:	fmov	s25, w1
    2e10:	fcvtzs	s28, s28
    2e14:	scvtf	s28, s28
    2e18:	fmsub	s30, s28, s24, s30
    2e1c:	fcvtzs	w0, s28
    2e20:	ldp	s24, s28, [sp, #152]
    2e24:	fmadd	s24, s30, s24, s28
    2e28:	b	2abc <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    2e2c:	fmov	s24, #5.000000000000000000e-01
    2e30:	ldr	s30, [sp, #148]
    2e34:	mov	w1, #0xaaab                	// #43691
    2e38:	movk	w1, #0x3d2a, lsl #16
    2e3c:	mov	w0, #0xaaab                	// #43691
    2e40:	fmov	s25, #1.000000000000000000e+00
    2e44:	movk	w0, #0x3e2a, lsl #16
    2e48:	mov	w2, #0x422a                	// #16938
    2e4c:	fmov	s22, w1
    2e50:	movk	w2, #0x3ecc, lsl #16
    2e54:	fadd	s28, s28, s24
    2e58:	fmov	s23, w0
    2e5c:	fmov	s21, w2
    2e60:	fcvtzs	s28, s28
    2e64:	scvtf	s28, s28
    2e68:	fmsub	s29, s28, s30, s29
    2e6c:	fcvtzs	w7, s28
    2e70:	ldp	s28, s30, [sp, #152]
    2e74:	fmadd	s20, s29, s28, s30
    2e78:	add	w7, w7, #0x7f
    2e7c:	fmov	s30, w7
    2e80:	fmadd	s22, s29, s20, s22
    2e84:	fmadd	s23, s29, s22, s23
    2e88:	shl	v28.2s, v30.2s, #23
    2e8c:	fmadd	s24, s29, s23, s24
    2e90:	fmadd	s24, s29, s24, s25
    2e94:	fmadd	s29, s29, s24, s25
    2e98:	fmul	s29, s29, s28
    2e9c:	fmul	s29, s29, s21
    2ea0:	b	2a08 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    2ea4:	fmov	s25, #5.000000000000000000e-01
    2ea8:	ldr	s21, [sp, #148]
    2eac:	mov	w0, #0xaaab                	// #43691
    2eb0:	movk	w0, #0x3e2a, lsl #16
    2eb4:	mov	w1, #0xaaab                	// #43691
    2eb8:	fmov	s26, #1.000000000000000000e+00
    2ebc:	movk	w1, #0x3d2a, lsl #16
    2ec0:	mov	w2, #0x422a                	// #16938
    2ec4:	fmov	s24, w0
    2ec8:	movk	w2, #0x3ecc, lsl #16
    2ecc:	fadd	s28, s28, s25
    2ed0:	fmov	s23, w1
    2ed4:	fmov	s22, w2
    2ed8:	fcvtzs	s28, s28
    2edc:	scvtf	s28, s28
    2ee0:	fmsub	s27, s28, s21, s27
    2ee4:	fcvtzs	w0, s28
    2ee8:	ldp	s21, s28, [sp, #152]
    2eec:	fmadd	s21, s27, s21, s28
    2ef0:	add	w0, w0, #0x7f
    2ef4:	fmov	s28, w0
    2ef8:	fmadd	s23, s27, s21, s23
    2efc:	fmadd	s24, s27, s23, s24
    2f00:	shl	v28.2s, v28.2s, #23
    2f04:	fmadd	s25, s27, s24, s25
    2f08:	fmadd	s25, s27, s25, s26
    2f0c:	fmadd	s26, s27, s25, s26
    2f10:	fmul	s28, s26, s28
    2f14:	fmul	s28, s28, s22
    2f18:	b	2c1c <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    2f1c:	ret
