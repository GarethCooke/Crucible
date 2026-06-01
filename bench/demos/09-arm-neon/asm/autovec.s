
/home/gcooke/Development/Crucible/bench/build/demos/09-arm-neon/CMakeFiles/bs09_autovec.dir/autovec.cpp.o:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <price_options_autovec(float const*, float const*, float const*, float const*, float const*, float*, long)>:
   0:	cmp	x6, #0x0
   4:	b.le	124 <price_options_autovec(float const*, float const*, float const*, float const*, float const*, float*, long)+0x124>
   8:	stp	x29, x30, [sp, #-144]!
   c:	mov	x29, sp
  10:	stp	x21, x22, [sp, #32]
  14:	mov	x21, x0
  18:	mov	w0, #0x4f3                 	// #1267
  1c:	movk	w0, #0x3f35, lsl #16
  20:	mov	x22, x1
  24:	stp	d12, d13, [sp, #112]
  28:	fmov	s13, w0
  2c:	stp	d8, d9, [sp, #80]
  30:	fmov	s9, #5.000000000000000000e-01
  34:	stp	x19, x20, [sp, #16]
  38:	mov	x20, x6
  3c:	mov	x19, #0x0                   	// #0
  40:	stp	x23, x24, [sp, #48]
  44:	mov	x23, x2
  48:	mov	x24, x3
  4c:	stp	x25, x26, [sp, #64]
  50:	mov	x25, x4
  54:	mov	x26, x5
  58:	stp	d10, d11, [sp, #96]
  5c:	stp	d14, d15, [sp, #128]
  60:	ldr	s10, [x23, x19, lsl #2]
  64:	ldr	s8, [x21, x19, lsl #2]
  68:	ldr	s15, [x22, x19, lsl #2]
  6c:	fcmp	s10, #0.0
  70:	ldr	s12, [x24, x19, lsl #2]
  74:	ldr	s14, [x25, x19, lsl #2]
  78:	b.pl	8c <price_options_autovec(float const*, float const*, float const*, float const*, float const*, float*, long)+0x8c>  // b.nfrst
  7c:	fmov	s0, s10
  80:	bl	0 <sqrtf>
  84:	fmov	s11, s0
  88:	b	90 <price_options_autovec(float const*, float const*, float const*, float const*, float const*, float*, long)+0x90>
  8c:	fsqrt	s11, s10
  90:	fmul	s11, s14, s11
  94:	fdiv	s0, s8, s15
  98:	bl	0 <logf>
  9c:	fmul	s31, s14, s9
  a0:	fmadd	s31, s31, s14, s12
  a4:	fmadd	s14, s31, s10, s0
  a8:	fdiv	s14, s14, s11
  ac:	fnmul	s0, s14, s13
  b0:	bl	0 <erfcf>
  b4:	fsub	s14, s14, s11
  b8:	fmov	s31, s0
  bc:	fnmul	s0, s14, s13
  c0:	fmov	s14, s31
  c4:	bl	0 <erfcf>
  c8:	fmov	s31, s0
  cc:	fnmul	s0, s12, s10
  d0:	fmov	s12, s31
  d4:	bl	0 <expf>
  d8:	fmul	s12, s12, s9
  dc:	fmul	s0, s15, s0
  e0:	fmul	s14, s14, s9
  e4:	fmul	s0, s0, s12
  e8:	fnmsub	s0, s8, s14, s0
  ec:	str	s0, [x26, x19, lsl #2]
  f0:	add	x19, x19, #0x1
  f4:	cmp	x20, x19
  f8:	b.ne	60 <price_options_autovec(float const*, float const*, float const*, float const*, float const*, float*, long)+0x60>  // b.any
  fc:	ldp	d8, d9, [sp, #80]
 100:	ldp	x19, x20, [sp, #16]
 104:	ldp	x21, x22, [sp, #32]
 108:	ldp	x23, x24, [sp, #48]
 10c:	ldp	x25, x26, [sp, #64]
 110:	ldp	d10, d11, [sp, #96]
 114:	ldp	d12, d13, [sp, #112]
 118:	ldp	d14, d15, [sp, #128]
 11c:	ldp	x29, x30, [sp], #144
 120:	ret
 124:	ret
