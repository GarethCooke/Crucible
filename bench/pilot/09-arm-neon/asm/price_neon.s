00000000000026e0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    26e0:	stp	x29, x30, [sp, #-160]!
    26e4:	mov	x29, sp
    26e8:	stp	x19, x20, [sp, #16]
    26ec:	mov	x20, x0
    26f0:	stp	x21, x22, [sp, #32]
    26f4:	mov	x21, x1
    26f8:	mov	x22, x2
    26fc:	stp	x23, x24, [sp, #48]
    2700:	mov	x24, x6
    2704:	mov	x23, x3
    2708:	stp	x25, x26, [sp, #64]
    270c:	mov	x25, x4
    2710:	mov	x26, x5
    2714:	stp	d8, d9, [sp, #80]
    2718:	stp	d10, d11, [sp, #96]
    271c:	stp	d12, d13, [sp, #112]
    2720:	stp	d14, d15, [sp, #128]
    2724:	cmp	x6, #0x3
    2728:	b.ls	320c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xb2c>  // b.plast
    272c:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2730:	sub	x19, x6, #0x4
    2734:	and	x0, x19, #0xfffffffffffffffc
    2738:	mov	x7, #0x0                   	// #0
    273c:	ldr	q20, [x1, #1584]
    2740:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2744:	mov	x8, #0x0                   	// #0
    2748:	add	x0, x0, #0x4
    274c:	ldr	q1, [x1, #1600]
    2750:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2754:	ldr	q11, [x1, #1616]
    2758:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    275c:	ldr	q12, [x1, #1632]
    2760:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2764:	ldr	q13, [x1, #1648]
    2768:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    276c:	ldr	q14, [x1, #1664]
    2770:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2774:	ldr	q15, [x1, #1680]
    2778:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    277c:	ldr	q4, [x1, #1696]
    2780:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2784:	ldr	q5, [x1, #1712]
    2788:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    278c:	ldr	q6, [x1, #1728]
    2790:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2794:	ldr	q7, [x1, #1744]
    2798:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    279c:	ldr	q16, [x1, #1760]
    27a0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    27a4:	ldr	q17, [x1, #1776]
    27a8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    27ac:	ldr	q18, [x1, #1792]
    27b0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    27b4:	movi	v26.4s, #0x7f, msl #16
    27b8:	fmov	v25.4s, #5.000000000000000000e-01
    27bc:	ldr	q9, [x21, x7]
    27c0:	movi	v23.4s, #0x7f
    27c4:	fmov	v31.4s, #-1.000000000000000000e+00
    27c8:	fmov	v29.4s, #1.000000000000000000e+00
    27cc:	fmov	v10.4s, #-5.000000000000000000e-01
    27d0:	add	x8, x8, #0x4
    27d4:	ldr	q30, [x20, x7]
    27d8:	mov	v0.16b, v25.16b
    27dc:	ldr	q19, [x1, #1808]
    27e0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    27e4:	ldr	q24, [x1, #1824]
    27e8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    27ec:	fdiv	v27.4s, v30.4s, v9.4s
    27f0:	ldr	q21, [x22, x7]
    27f4:	ldr	q22, [x23, x7]
    27f8:	and	v26.16b, v26.16b, v27.16b
    27fc:	sshr	v27.4s, v27.4s, #23
    2800:	ldr	q30, [x25, x7]
    2804:	orr	v26.16b, v26.16b, v24.16b
    2808:	ldr	q24, [x1, #1840]
    280c:	sub	v27.4s, v27.4s, v23.4s
    2810:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2814:	fmul	v28.4s, v21.4s, v22.4s
    2818:	fmul	v3.4s, v30.4s, v30.4s
    281c:	fcmge	v8.4s, v26.4s, v24.4s
    2820:	fmul	v24.4s, v25.4s, v26.4s
    2824:	fneg	v28.4s, v28.4s
    2828:	fmla	v22.4s, v25.4s, v3.4s
    282c:	bit	v26.16b, v24.16b, v8.16b
    2830:	sub	v27.4s, v27.4s, v8.4s
    2834:	ldr	q8, [x1, #1856]
    2838:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    283c:	fmax	v28.4s, v28.4s, v4.4s
    2840:	ldr	q24, [x1, #1872]
    2844:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2848:	fadd	v31.4s, v31.4s, v26.4s
    284c:	fsqrt	v26.4s, v21.4s
    2850:	scvtf	v27.4s, v27.4s
    2854:	fmin	v28.4s, v28.4s, v5.4s
    2858:	fmul	v30.4s, v30.4s, v26.4s
    285c:	fmla	v8.4s, v24.4s, v31.4s
    2860:	ldr	q24, [x1, #1888]
    2864:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2868:	fmul	v26.4s, v28.4s, v6.4s
    286c:	fmla	v24.4s, v8.4s, v31.4s
    2870:	ldr	q8, [x1, #1904]
    2874:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2878:	frintn	v26.4s, v26.4s
    287c:	fmla	v8.4s, v24.4s, v31.4s
    2880:	ldr	q24, [x1, #1920]
    2884:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2888:	ldr	q3, [x1, #1936]
    288c:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    2890:	fmls	v28.4s, v26.4s, v20.4s
    2894:	fmla	v24.4s, v8.4s, v31.4s
    2898:	mov	v8.16b, v16.16b
    289c:	fcvtzs	v26.4s, v26.4s
    28a0:	fmla	v3.4s, v24.4s, v31.4s
    28a4:	ldr	q24, [x1, #1952]
    28a8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    28ac:	fmla	v8.4s, v7.4s, v28.4s
    28b0:	add	v26.4s, v26.4s, v23.4s
    28b4:	fmla	v24.4s, v3.4s, v31.4s
    28b8:	mov	v3.16b, v17.16b
    28bc:	shl	v26.4s, v26.4s, #23
    28c0:	fmla	v3.4s, v8.4s, v28.4s
    28c4:	ldr	q8, [x1, #1968]
    28c8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    28cc:	ldr	q2, [x1, #1984]
    28d0:	fmla	v8.4s, v24.4s, v31.4s
    28d4:	mov	v24.16b, v18.16b
    28d8:	fmla	v2.4s, v8.4s, v31.4s
    28dc:	fmla	v24.4s, v3.4s, v28.4s
    28e0:	mov	v3.16b, v29.16b
    28e4:	fmul	v8.4s, v31.4s, v31.4s
    28e8:	fmla	v0.4s, v24.4s, v28.4s
    28ec:	fmul	v24.4s, v31.4s, v8.4s
    28f0:	fmla	v3.4s, v0.4s, v28.4s
    28f4:	fmul	v24.4s, v24.4s, v2.4s
    28f8:	mov	v2.16b, v29.16b
    28fc:	fmls	v24.4s, v8.4s, v25.4s
    2900:	mov	v8.16b, v12.16b
    2904:	fmla	v2.4s, v3.4s, v28.4s
    2908:	mov	v3.16b, v16.16b
    290c:	fadd	v31.4s, v31.4s, v24.4s
    2910:	fmul	v26.4s, v2.4s, v26.4s
    2914:	mov	v2.16b, v18.16b
    2918:	fmla	v31.4s, v27.4s, v20.4s
    291c:	fmul	v26.4s, v26.4s, v9.4s
    2920:	mov	v9.16b, v13.16b
    2924:	fmla	v31.4s, v22.4s, v21.4s
    2928:	mov	v21.16b, v29.16b
    292c:	fdiv	v31.4s, v31.4s, v30.4s
    2930:	fsub	v30.4s, v31.4s, v30.4s
    2934:	fmul	v27.4s, v31.4s, v31.4s
    2938:	fabs	v24.4s, v31.4s
    293c:	fcmlt	v31.4s, v31.4s, #0.0
    2940:	fmul	v28.4s, v30.4s, v30.4s
    2944:	fmul	v27.4s, v27.4s, v10.4s
    2948:	fmla	v21.4s, v1.4s, v24.4s
    294c:	fabs	v22.4s, v30.4s
    2950:	mov	v24.16b, v29.16b
    2954:	fmul	v28.4s, v28.4s, v10.4s
    2958:	fmax	v27.4s, v27.4s, v4.4s
    295c:	fcmlt	v30.4s, v30.4s, #0.0
    2960:	fmla	v24.4s, v1.4s, v22.4s
    2964:	fmax	v28.4s, v28.4s, v4.4s
    2968:	fmin	v27.4s, v27.4s, v5.4s
    296c:	fdiv	v21.4s, v29.4s, v21.4s
    2970:	fmin	v28.4s, v28.4s, v5.4s
    2974:	fmul	v22.4s, v27.4s, v6.4s
    2978:	fmla	v8.4s, v11.4s, v21.4s
    297c:	fdiv	v24.4s, v29.4s, v24.4s
    2980:	fmul	v10.4s, v28.4s, v6.4s
    2984:	frintn	v22.4s, v22.4s
    2988:	fmla	v9.4s, v8.4s, v21.4s
    298c:	mov	v8.16b, v14.16b
    2990:	frintn	v10.4s, v10.4s
    2994:	fmls	v27.4s, v22.4s, v20.4s
    2998:	fmla	v8.4s, v9.4s, v21.4s
    299c:	mov	v9.16b, v15.16b
    29a0:	fmls	v28.4s, v10.4s, v20.4s
    29a4:	fcvtzs	v22.4s, v22.4s
    29a8:	fcvtzs	v10.4s, v10.4s
    29ac:	fmla	v3.4s, v7.4s, v27.4s
    29b0:	fmla	v9.4s, v8.4s, v21.4s
    29b4:	mov	v8.16b, v17.16b
    29b8:	add	v22.4s, v22.4s, v23.4s
    29bc:	add	v10.4s, v10.4s, v23.4s
    29c0:	mov	v23.16b, v16.16b
    29c4:	fmla	v8.4s, v3.4s, v27.4s
    29c8:	mov	v3.16b, v18.16b
    29cc:	fmla	v23.4s, v7.4s, v28.4s
    29d0:	shl	v22.4s, v22.4s, #23
    29d4:	fmla	v3.4s, v8.4s, v27.4s
    29d8:	mov	v8.16b, v17.16b
    29dc:	shl	v10.4s, v10.4s, #23
    29e0:	fmul	v21.4s, v21.4s, v9.4s
    29e4:	fmla	v8.4s, v23.4s, v28.4s
    29e8:	mov	v23.16b, v25.16b
    29ec:	fmla	v23.4s, v3.4s, v27.4s
    29f0:	mov	v3.16b, v29.16b
    29f4:	fmla	v2.4s, v8.4s, v28.4s
    29f8:	mov	v8.16b, v12.16b
    29fc:	fmla	v3.4s, v23.4s, v27.4s
    2a00:	mov	v23.16b, v29.16b
    2a04:	fmla	v25.4s, v2.4s, v28.4s
    2a08:	fmla	v23.4s, v3.4s, v27.4s
    2a0c:	mov	v3.16b, v29.16b
    2a10:	mov	v27.16b, v29.16b
    2a14:	fmla	v8.4s, v11.4s, v24.4s
    2a18:	fmla	v3.4s, v25.4s, v28.4s
    2a1c:	mov	v25.16b, v13.16b
    2a20:	fmla	v25.4s, v8.4s, v24.4s
    2a24:	fmla	v27.4s, v3.4s, v28.4s
    2a28:	mov	v28.16b, v14.16b
    2a2c:	fmla	v28.4s, v25.4s, v24.4s
    2a30:	fmul	v25.4s, v23.4s, v22.4s
    2a34:	mov	v23.16b, v15.16b
    2a38:	fmla	v23.4s, v28.4s, v24.4s
    2a3c:	fmul	v25.4s, v25.4s, v19.4s
    2a40:	fmul	v28.4s, v27.4s, v10.4s
    2a44:	fmul	v27.4s, v25.4s, v21.4s
    2a48:	fmul	v28.4s, v28.4s, v19.4s
    2a4c:	fmul	v24.4s, v24.4s, v23.4s
    2a50:	fsub	v25.4s, v29.4s, v27.4s
    2a54:	fmul	v24.4s, v28.4s, v24.4s
    2a58:	ldr	q28, [x20, x7]
    2a5c:	bsl	v31.16b, v27.16b, v25.16b
    2a60:	fsub	v29.4s, v29.4s, v24.4s
    2a64:	fmul	v31.4s, v28.4s, v31.4s
    2a68:	bsl	v30.16b, v24.16b, v29.16b
    2a6c:	fmls	v31.4s, v26.4s, v30.4s
    2a70:	str	q31, [x26, x7]
    2a74:	add	x7, x7, #0x10
    2a78:	cmp	x8, x0
    2a7c:	b.ne	27b0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xd0>  // b.any
    2a80:	and	x19, x19, #0xfffffffffffffffc
    2a84:	add	x19, x19, #0x4
    2a88:	cmp	x24, x19
    2a8c:	b.ls	2f04 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>  // b.plast
    2a90:	mov	w4, #0x3389                	// #13193
    2a94:	mov	w3, #0x466f                	// #18031
    2a98:	mov	w2, #0x1eea                	// #7914
    2a9c:	mov	w1, #0x778                 	// #1912
    2aa0:	movk	w4, #0x3e6d, lsl #16
    2aa4:	movk	w3, #0x3faa, lsl #16
    2aa8:	movk	w2, #0xbfe9, lsl #16
    2aac:	movk	w1, #0x3fe4, lsl #16
    2ab0:	mov	w0, #0xc2b00000            	// #-1028653056
    2ab4:	fmov	s10, w4
    2ab8:	fmov	s11, w3
    2abc:	fmov	s12, w2
    2ac0:	fmov	s13, w1
    2ac4:	fmov	s14, w0
    2ac8:	ldr	s28, [x22, x19, lsl #2]
    2acc:	ldr	s15, [x25, x19, lsl #2]
    2ad0:	ldr	s26, [x20, x19, lsl #2]
    2ad4:	fcmp	s28, #0.0
    2ad8:	ldr	s8, [x21, x19, lsl #2]
    2adc:	ldr	s25, [x23, x19, lsl #2]
    2ae0:	fmul	s9, s15, s15
    2ae4:	b.pl	2c3c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.nfrst
    2ae8:	fmov	s0, s28
    2aec:	stp	s26, s28, [sp, #148]
    2af0:	str	s25, [sp, #156]
    2af4:	bl	ec0 <sqrtf@plt>
    2af8:	ldr	s26, [sp, #148]
    2afc:	fmul	s15, s15, s0
    2b00:	fdiv	s0, s26, s8
    2b04:	bl	1020 <logf@plt>
    2b08:	ldr	s25, [sp, #156]
    2b0c:	fmov	s31, #5.000000000000000000e-01
    2b10:	mov	w0, #0x3389                	// #13193
    2b14:	movk	w0, #0x3e6d, lsl #16
    2b18:	fmov	s27, #1.000000000000000000e+00
    2b1c:	mov	w1, #0x466f                	// #18031
    2b20:	ldp	s26, s28, [sp, #148]
    2b24:	mov	w3, #0x1eea                	// #7914
    2b28:	movk	w1, #0x3faa, lsl #16
    2b2c:	fmov	s30, w0
    2b30:	movk	w3, #0xbfe9, lsl #16
    2b34:	mov	w2, #0x778                 	// #1912
    2b38:	fmov	s20, w1
    2b3c:	movk	w2, #0x3fe4, lsl #16
    2b40:	mov	w1, #0x8f89                	// #36745
    2b44:	fmov	s22, w3
    2b48:	movk	w1, #0xbeb6, lsl #16
    2b4c:	mov	w0, #0x85fa                	// #34298
    2b50:	fmadd	s9, s9, s31, s25
    2b54:	movk	w0, #0x3ea3, lsl #16
    2b58:	mov	w7, #0xaa3b                	// #43579
    2b5c:	fmov	s23, w2
    2b60:	fmov	s19, #-5.000000000000000000e-01
    2b64:	movk	w7, #0x3fb8, lsl #16
    2b68:	fmov	s24, w1
    2b6c:	fmov	s31, w0
    2b70:	fmadd	s0, s28, s9, s0
    2b74:	fmov	s29, w7
    2b78:	fdiv	s0, s0, s15
    2b7c:	fmadd	s21, s0, s30, s27
    2b80:	fmul	s30, s0, s19
    2b84:	fsub	s15, s0, s15
    2b88:	fmul	s30, s30, s0
    2b8c:	fdiv	s27, s27, s21
    2b90:	fmul	s29, s30, s29
    2b94:	fmadd	s22, s27, s20, s22
    2b98:	fmadd	s23, s22, s27, s23
    2b9c:	fmadd	s24, s23, s27, s24
    2ba0:	fmadd	s31, s24, s27, s31
    2ba4:	fmul	s31, s31, s27
    2ba8:	fmov	s24, #5.000000000000000000e-01
    2bac:	mov	w0, #0x7218                	// #29208
    2bb0:	mov	w3, #0xb61                 	// #2913
    2bb4:	movk	w0, #0x3f31, lsl #16
    2bb8:	mov	w2, #0x8889                	// #34953
    2bbc:	fmov	s27, #1.000000000000000000e+00
    2bc0:	movk	w3, #0x3ab6, lsl #16
    2bc4:	movk	w2, #0x3c08, lsl #16
    2bc8:	fmov	s18, w0
    2bcc:	mov	w1, #0xaaab                	// #43691
    2bd0:	mov	w0, #0xaaab                	// #43691
    2bd4:	fsub	s29, s29, s24
    2bd8:	movk	w1, #0x3d2a, lsl #16
    2bdc:	movk	w0, #0x3e2a, lsl #16
    2be0:	fmov	s21, w2
    2be4:	mov	w4, #0x422a                	// #16938
    2be8:	fmov	s19, w3
    2bec:	movk	w4, #0x3ecc, lsl #16
    2bf0:	fmov	s22, w1
    2bf4:	fmov	s23, w0
    2bf8:	fmov	s20, w4
    2bfc:	fcvtzs	s29, s29
    2c00:	scvtf	s29, s29
    2c04:	fmsub	s30, s29, s18, s30
    2c08:	fcvtzs	w7, s29
    2c0c:	fmadd	s29, s30, s19, s21
    2c10:	add	w7, w7, #0x7f
    2c14:	fmov	s21, w7
    2c18:	fmadd	s29, s30, s29, s22
    2c1c:	fmadd	s29, s30, s29, s23
    2c20:	shl	v21.2s, v21.2s, #23
    2c24:	fmadd	s24, s30, s29, s24
    2c28:	fmadd	s24, s30, s24, s27
    2c2c:	fmadd	s30, s30, s24, s27
    2c30:	fmul	s30, s30, s21
    2c34:	fmul	s30, s30, s20
    2c38:	b	3178 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa98>
    2c3c:	fsqrt	s29, s28
    2c40:	stp	s26, s28, [sp, #148]
    2c44:	str	s25, [sp, #156]
    2c48:	fdiv	s0, s26, s8
    2c4c:	fmul	s15, s15, s29
    2c50:	bl	1020 <logf@plt>
    2c54:	ldr	s25, [sp, #156]
    2c58:	fmov	s30, #5.000000000000000000e-01
    2c5c:	ldp	s26, s28, [sp, #148]
    2c60:	fmadd	s9, s9, s30, s25
    2c64:	fmadd	s0, s28, s9, s0
    2c68:	fdiv	s0, s0, s15
    2c6c:	fcmpe	s0, #0.0
    2c70:	fsub	s15, s0, s15
    2c74:	b.mi	2fb4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8d4>  // b.first
    2c78:	fmov	s31, #1.000000000000000000e+00
    2c7c:	mov	w1, #0x8f89                	// #36745
    2c80:	mov	w0, #0x85fa                	// #34298
    2c84:	movk	w1, #0xbeb6, lsl #16
    2c88:	movk	w0, #0x3ea3, lsl #16
    2c8c:	fmov	s30, #-5.000000000000000000e-01
    2c90:	fmov	s27, w1
    2c94:	fmadd	s24, s0, s10, s31
    2c98:	fmov	s29, w0
    2c9c:	fmul	s30, s0, s30
    2ca0:	fmul	s30, s30, s0
    2ca4:	fdiv	s31, s31, s24
    2ca8:	fcmpe	s30, s14
    2cac:	fmadd	s24, s31, s11, s12
    2cb0:	fmadd	s24, s31, s24, s13
    2cb4:	fmadd	s27, s31, s24, s27
    2cb8:	fmadd	s29, s31, s27, s29
    2cbc:	fmul	s31, s31, s29
    2cc0:	b.mi	3024 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x944>  // b.first
    2cc4:	mov	w0, #0x42b00000            	// #1118830592
    2cc8:	fmov	s29, w0
    2ccc:	fcmpe	s30, s29
    2cd0:	b.gt	2cf0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x610>
    2cd4:	mov	w7, #0xaa3b                	// #43579
    2cd8:	movk	w7, #0x3fb8, lsl #16
    2cdc:	fmov	s29, w7
    2ce0:	fmul	s29, s30, s29
    2ce4:	fcmpe	s29, #0.0
    2ce8:	b.ge	30e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    2cec:	b	2ba8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    2cf0:	mov	w0, #0x484f                	// #18511
    2cf4:	movk	w0, #0x7e46, lsl #16
    2cf8:	fmov	s30, w0
    2cfc:	fmul	s31, s31, s30
    2d00:	fmov	s30, #1.000000000000000000e+00
    2d04:	fsub	s31, s30, s31
    2d08:	fnmul	s29, s25, s28
    2d0c:	fmul	s31, s26, s31
    2d10:	movi	v30.2s, #0x0
    2d14:	fcmpe	s29, s14
    2d18:	b.mi	2dc4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>  // b.first
    2d1c:	mov	w0, #0x42b00000            	// #1118830592
    2d20:	fmov	s30, w0
    2d24:	fcmpe	s29, s30
    2d28:	b.gt	3038 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x958>
    2d2c:	mov	w7, #0xaa3b                	// #43579
    2d30:	movk	w7, #0x3fb8, lsl #16
    2d34:	fmov	s28, w7
    2d38:	fmul	s28, s29, s28
    2d3c:	fcmpe	s28, #0.0
    2d40:	b.ge	3188 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xaa8>  // b.tcont
    2d44:	fmov	s27, #5.000000000000000000e-01
    2d48:	mov	w0, #0x7218                	// #29208
    2d4c:	mov	w3, #0xb61                 	// #2913
    2d50:	movk	w0, #0x3f31, lsl #16
    2d54:	mov	w2, #0x8889                	// #34953
    2d58:	fmov	s30, #1.000000000000000000e+00
    2d5c:	movk	w3, #0x3ab6, lsl #16
    2d60:	movk	w2, #0x3c08, lsl #16
    2d64:	fmov	s22, w0
    2d68:	mov	w1, #0xaaab                	// #43691
    2d6c:	mov	w0, #0xaaab                	// #43691
    2d70:	fsub	s28, s28, s27
    2d74:	movk	w1, #0x3d2a, lsl #16
    2d78:	movk	w0, #0x3e2a, lsl #16
    2d7c:	fmov	s24, w2
    2d80:	fmov	s23, w3
    2d84:	fmov	s25, w1
    2d88:	fmov	s26, w0
    2d8c:	fcvtzs	s28, s28
    2d90:	scvtf	s28, s28
    2d94:	fmsub	s29, s28, s22, s29
    2d98:	fcvtzs	w7, s28
    2d9c:	fmadd	s28, s29, s23, s24
    2da0:	add	w7, w7, #0x7f
    2da4:	fmov	s24, w7
    2da8:	fmadd	s28, s29, s28, s25
    2dac:	fmadd	s28, s29, s28, s26
    2db0:	shl	v24.2s, v24.2s, #23
    2db4:	fmadd	s27, s29, s28, s27
    2db8:	fmadd	s27, s29, s27, s30
    2dbc:	fmadd	s30, s29, s27, s30
    2dc0:	fmul	s30, s30, s24
    2dc4:	fcmpe	s15, #0.0
    2dc8:	fmul	s26, s8, s30
    2dcc:	b.mi	2f2c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x84c>  // b.first
    2dd0:	fmov	s30, #1.000000000000000000e+00
    2dd4:	mov	w1, #0x8f89                	// #36745
    2dd8:	mov	w0, #0x85fa                	// #34298
    2ddc:	movk	w1, #0xbeb6, lsl #16
    2de0:	movk	w0, #0x3ea3, lsl #16
    2de4:	fmov	s28, #-5.000000000000000000e-01
    2de8:	fmov	s27, w1
    2dec:	fmadd	s25, s15, s10, s30
    2df0:	fmov	s29, w0
    2df4:	fmul	s28, s15, s28
    2df8:	fmul	s28, s28, s15
    2dfc:	fdiv	s30, s30, s25
    2e00:	fcmpe	s28, s14
    2e04:	fmadd	s25, s30, s11, s12
    2e08:	fmadd	s25, s30, s25, s13
    2e0c:	fmadd	s27, s30, s25, s27
    2e10:	fmadd	s29, s30, s27, s29
    2e14:	fmul	s30, s30, s29
    2e18:	b.mi	3030 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x950>  // b.first
    2e1c:	mov	w0, #0x42b00000            	// #1118830592
    2e20:	fmov	s29, w0
    2e24:	fcmpe	s28, s29
    2e28:	b.gt	2ed8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7f8>
    2e2c:	mov	w7, #0xaa3b                	// #43579
    2e30:	movk	w7, #0x3fb8, lsl #16
    2e34:	fmov	s29, w7
    2e38:	fmul	s29, s28, s29
    2e3c:	fcmpe	s29, #0.0
    2e40:	b.ge	3048 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    2e44:	fmov	s25, #5.000000000000000000e-01
    2e48:	mov	w0, #0x7218                	// #29208
    2e4c:	mov	w4, #0xb61                 	// #2913
    2e50:	movk	w0, #0x3f31, lsl #16
    2e54:	mov	w2, #0x8889                	// #34953
    2e58:	fmov	s27, #1.000000000000000000e+00
    2e5c:	movk	w4, #0x3ab6, lsl #16
    2e60:	movk	w2, #0x3c08, lsl #16
    2e64:	fmov	s19, w0
    2e68:	mov	w1, #0xaaab                	// #43691
    2e6c:	mov	w0, #0xaaab                	// #43691
    2e70:	fsub	s29, s29, s25
    2e74:	movk	w1, #0x3d2a, lsl #16
    2e78:	movk	w0, #0x3e2a, lsl #16
    2e7c:	fmov	s22, w2
    2e80:	mov	w3, #0x422a                	// #16938
    2e84:	fmov	s20, w4
    2e88:	movk	w3, #0x3ecc, lsl #16
    2e8c:	fmov	s23, w1
    2e90:	fmov	s24, w0
    2e94:	fmov	s21, w3
    2e98:	fcvtzs	s29, s29
    2e9c:	scvtf	s29, s29
    2ea0:	fmsub	s28, s29, s19, s28
    2ea4:	fcvtzs	w7, s29
    2ea8:	fmadd	s29, s28, s20, s22
    2eac:	add	w7, w7, #0x7f
    2eb0:	fmov	s22, w7
    2eb4:	fmadd	s29, s28, s29, s23
    2eb8:	fmadd	s29, s28, s29, s24
    2ebc:	shl	v22.2s, v22.2s, #23
    2ec0:	fmadd	s25, s28, s29, s25
    2ec4:	fmadd	s25, s28, s25, s27
    2ec8:	fmadd	s29, s28, s25, s27
    2ecc:	fmul	s29, s29, s22
    2ed0:	fmul	s29, s29, s21
    2ed4:	b	30d8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x9f8>
    2ed8:	mov	w0, #0x484f                	// #18511
    2edc:	movk	w0, #0x7e46, lsl #16
    2ee0:	fmov	s29, w0
    2ee4:	fmul	s30, s30, s29
    2ee8:	fmov	s29, #1.000000000000000000e+00
    2eec:	fsub	s29, s29, s30
    2ef0:	fmsub	s31, s26, s29, s31
    2ef4:	str	s31, [x26, x19, lsl #2]
    2ef8:	add	x19, x19, #0x1
    2efc:	cmp	x19, x24
    2f00:	b.ne	2ac8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    2f04:	ldp	d8, d9, [sp, #80]
    2f08:	ldp	x19, x20, [sp, #16]
    2f0c:	ldp	x21, x22, [sp, #32]
    2f10:	ldp	x23, x24, [sp, #48]
    2f14:	ldp	x25, x26, [sp, #64]
    2f18:	ldp	d10, d11, [sp, #96]
    2f1c:	ldp	d12, d13, [sp, #112]
    2f20:	ldp	d14, d15, [sp, #128]
    2f24:	ldp	x29, x30, [sp], #160
    2f28:	ret
    2f2c:	fmov	s29, #1.000000000000000000e+00
    2f30:	mov	w1, #0x8f89                	// #36745
    2f34:	mov	w0, #0x85fa                	// #34298
    2f38:	movk	w1, #0xbeb6, lsl #16
    2f3c:	movk	w0, #0x3ea3, lsl #16
    2f40:	fmov	s28, #5.000000000000000000e-01
    2f44:	fmov	s27, w1
    2f48:	fmsub	s25, s15, s10, s29
    2f4c:	fmov	s30, w0
    2f50:	fmul	s28, s15, s28
    2f54:	fnmul	s28, s15, s28
    2f58:	fdiv	s29, s29, s25
    2f5c:	fcmpe	s28, s14
    2f60:	fmadd	s25, s29, s11, s12
    2f64:	fmadd	s25, s29, s25, s13
    2f68:	fmadd	s27, s29, s25, s27
    2f6c:	fmadd	s30, s29, s27, s30
    2f70:	fmul	s30, s29, s30
    2f74:	b.mi	2f94 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8b4>  // b.first
    2f78:	mov	w7, #0xaa3b                	// #43579
    2f7c:	movk	w7, #0x3fb8, lsl #16
    2f80:	fmov	s29, w7
    2f84:	fmul	s29, s28, s29
    2f88:	fcmpe	s29, #0.0
    2f8c:	b.ge	3048 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    2f90:	b	2e44 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x764>
    2f94:	movi	v29.2s, #0x0
    2f98:	fmul	s30, s30, s29
    2f9c:	fmsub	s30, s26, s30, s31
    2fa0:	str	s30, [x26, x19, lsl #2]
    2fa4:	add	x19, x19, #0x1
    2fa8:	cmp	x24, x19
    2fac:	b.ne	2ac8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    2fb0:	b	2f04 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>
    2fb4:	fmov	s31, #1.000000000000000000e+00
    2fb8:	mov	w1, #0x8f89                	// #36745
    2fbc:	mov	w0, #0x85fa                	// #34298
    2fc0:	movk	w1, #0xbeb6, lsl #16
    2fc4:	movk	w0, #0x3ea3, lsl #16
    2fc8:	fmul	s30, s0, s30
    2fcc:	fmov	s27, w1
    2fd0:	fmsub	s24, s0, s10, s31
    2fd4:	fmov	s29, w0
    2fd8:	fnmul	s30, s0, s30
    2fdc:	fcmpe	s30, s14
    2fe0:	fdiv	s31, s31, s24
    2fe4:	fmadd	s24, s31, s11, s12
    2fe8:	fmadd	s24, s31, s24, s13
    2fec:	fmadd	s27, s31, s24, s27
    2ff0:	fmadd	s29, s31, s27, s29
    2ff4:	fmul	s31, s31, s29
    2ff8:	b.mi	3018 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x938>  // b.first
    2ffc:	mov	w7, #0xaa3b                	// #43579
    3000:	movk	w7, #0x3fb8, lsl #16
    3004:	fmov	s29, w7
    3008:	fmul	s29, s30, s29
    300c:	fcmpe	s29, #0.0
    3010:	b.ge	30e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    3014:	b	2ba8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    3018:	movi	v30.2s, #0x0
    301c:	fmul	s31, s31, s30
    3020:	b	2d08 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>
    3024:	movi	v30.2s, #0x0
    3028:	fmul	s31, s31, s30
    302c:	b	2d00 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    3030:	movi	v29.2s, #0x0
    3034:	b	2ee4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x804>
    3038:	mov	w7, #0x829c                	// #33436
    303c:	movk	w7, #0x7ef8, lsl #16
    3040:	fmov	s30, w7
    3044:	b	2dc4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    3048:	fmov	s24, #5.000000000000000000e-01
    304c:	mov	w0, #0x7218                	// #29208
    3050:	mov	w4, #0xb61                 	// #2913
    3054:	movk	w0, #0x3f31, lsl #16
    3058:	mov	w2, #0x8889                	// #34953
    305c:	fmov	s27, #1.000000000000000000e+00
    3060:	movk	w4, #0x3ab6, lsl #16
    3064:	movk	w2, #0x3c08, lsl #16
    3068:	fmov	s25, w0
    306c:	mov	w1, #0xaaab                	// #43691
    3070:	mov	w0, #0xaaab                	// #43691
    3074:	fadd	s29, s29, s24
    3078:	movk	w1, #0x3d2a, lsl #16
    307c:	movk	w0, #0x3e2a, lsl #16
    3080:	fmov	s19, w4
    3084:	mov	w3, #0x422a                	// #16938
    3088:	fmov	s21, w2
    308c:	movk	w3, #0x3ecc, lsl #16
    3090:	fmov	s22, w1
    3094:	fmov	s23, w0
    3098:	fmov	s20, w3
    309c:	fcvtzs	s29, s29
    30a0:	scvtf	s29, s29
    30a4:	fmsub	s28, s29, s25, s28
    30a8:	fcvtzs	w7, s29
    30ac:	fmadd	s29, s28, s19, s21
    30b0:	add	w7, w7, #0x7f
    30b4:	fmov	s25, w7
    30b8:	fmadd	s29, s28, s29, s22
    30bc:	fmadd	s29, s28, s29, s23
    30c0:	shl	v25.2s, v25.2s, #23
    30c4:	fmadd	s24, s28, s29, s24
    30c8:	fmadd	s24, s28, s24, s27
    30cc:	fmadd	s29, s28, s24, s27
    30d0:	fmul	s29, s29, s25
    30d4:	fmul	s29, s29, s20
    30d8:	fcmpe	s15, #0.0
    30dc:	fmul	s30, s30, s29
    30e0:	b.mi	2f9c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8bc>  // b.first
    30e4:	b	2ee8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x808>
    30e8:	fmov	s23, #5.000000000000000000e-01
    30ec:	mov	w0, #0x7218                	// #29208
    30f0:	mov	w3, #0xb61                 	// #2913
    30f4:	movk	w0, #0x3f31, lsl #16
    30f8:	mov	w2, #0x8889                	// #34953
    30fc:	fmov	s27, #1.000000000000000000e+00
    3100:	movk	w3, #0x3ab6, lsl #16
    3104:	movk	w2, #0x3c08, lsl #16
    3108:	fmov	s24, w0
    310c:	mov	w1, #0xaaab                	// #43691
    3110:	mov	w0, #0xaaab                	// #43691
    3114:	fadd	s29, s29, s23
    3118:	movk	w1, #0x3d2a, lsl #16
    311c:	movk	w0, #0x3e2a, lsl #16
    3120:	fmov	s18, w3
    3124:	mov	w4, #0x422a                	// #16938
    3128:	fmov	s20, w2
    312c:	movk	w4, #0x3ecc, lsl #16
    3130:	fmov	s21, w1
    3134:	fmov	s22, w0
    3138:	fmov	s19, w4
    313c:	fcvtzs	s29, s29
    3140:	scvtf	s29, s29
    3144:	fmsub	s30, s29, s24, s30
    3148:	fcvtzs	w7, s29
    314c:	fmadd	s29, s30, s18, s20
    3150:	add	w7, w7, #0x7f
    3154:	fmov	s24, w7
    3158:	fmadd	s29, s30, s29, s21
    315c:	fmadd	s29, s30, s29, s22
    3160:	shl	v24.2s, v24.2s, #23
    3164:	fmadd	s23, s30, s29, s23
    3168:	fmadd	s23, s30, s23, s27
    316c:	fmadd	s30, s30, s23, s27
    3170:	fmul	s30, s30, s24
    3174:	fmul	s30, s30, s19
    3178:	fcmpe	s0, #0.0
    317c:	fmul	s31, s31, s30
    3180:	b.mi	2d08 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>  // b.first
    3184:	b	2d00 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    3188:	fmov	s26, #5.000000000000000000e-01
    318c:	mov	w0, #0x7218                	// #29208
    3190:	mov	w3, #0xb61                 	// #2913
    3194:	movk	w0, #0x3f31, lsl #16
    3198:	mov	w2, #0x8889                	// #34953
    319c:	fmov	s30, #1.000000000000000000e+00
    31a0:	movk	w3, #0x3ab6, lsl #16
    31a4:	movk	w2, #0x3c08, lsl #16
    31a8:	fmov	s27, w0
    31ac:	mov	w1, #0xaaab                	// #43691
    31b0:	mov	w0, #0xaaab                	// #43691
    31b4:	fadd	s28, s28, s26
    31b8:	movk	w1, #0x3d2a, lsl #16
    31bc:	movk	w0, #0x3e2a, lsl #16
    31c0:	fmov	s22, w3
    31c4:	fmov	s23, w2
    31c8:	fmov	s24, w1
    31cc:	fmov	s25, w0
    31d0:	fcvtzs	s28, s28
    31d4:	scvtf	s28, s28
    31d8:	fmsub	s29, s28, s27, s29
    31dc:	fcvtzs	w7, s28
    31e0:	fmadd	s28, s29, s22, s23
    31e4:	add	w7, w7, #0x7f
    31e8:	fmov	s27, w7
    31ec:	fmadd	s28, s29, s28, s24
    31f0:	fmadd	s28, s29, s28, s25
    31f4:	shl	v27.2s, v27.2s, #23
    31f8:	fmadd	s26, s29, s28, s26
    31fc:	fmadd	s26, s29, s26, s30
    3200:	fmadd	s30, s29, s26, s30
    3204:	fmul	s30, s30, s27
    3208:	b	2dc4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    320c:	mov	x19, #0x0                   	// #0
    3210:	b	2a88 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a8>
    3214:	nop
    3218:	nop
    321c:	nop
