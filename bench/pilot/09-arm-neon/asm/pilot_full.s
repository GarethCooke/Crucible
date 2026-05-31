
/home/gcooke/Development/Crucible/bench/pilot/09-arm-neon/build/pilot_blackscholes:     file format elf64-littleaarch64


Disassembly of section .init:

0000000000000e28 <_init>:
 e28:	paciasp
 e2c:	stp	x29, x30, [sp, #-16]!
 e30:	mov	x29, sp
 e34:	bl	1af4 <call_weak_fn>
 e38:	ldp	x29, x30, [sp], #16
 e3c:	autiasp
 e40:	ret

Disassembly of section .plt:

0000000000000e50 <.plt>:
     e50:	stp	x16, x30, [sp, #-16]!
     e54:	adrp	x16, 1f000 <__abi_tag+0x1a2e8>
     e58:	ldr	x17, [x16, #4088]
     e5c:	add	x16, x16, #0xff8
     e60:	br	x17
     e64:	nop
     e68:	nop
     e6c:	nop

0000000000000e70 <memcpy@plt>:
     e70:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     e74:	ldr	x17, [x16]
     e78:	add	x16, x16, #0x0
     e7c:	br	x17

0000000000000e80 <strlen@plt>:
     e80:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     e84:	ldr	x17, [x16, #8]
     e88:	add	x16, x16, #0x8
     e8c:	br	x17

0000000000000e90 <fprintf@plt>:
     e90:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     e94:	ldr	x17, [x16, #16]
     e98:	add	x16, x16, #0x10
     e9c:	br	x17

0000000000000ea0 <memcmp@plt>:
     ea0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     ea4:	ldr	x17, [x16, #24]
     ea8:	add	x16, x16, #0x18
     eac:	br	x17

0000000000000eb0 <free@plt>:
     eb0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     eb4:	ldr	x17, [x16, #32]
     eb8:	add	x16, x16, #0x20
     ebc:	br	x17

0000000000000ec0 <sqrtf@plt>:
     ec0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     ec4:	ldr	x17, [x16, #40]
     ec8:	add	x16, x16, #0x28
     ecc:	br	x17

0000000000000ed0 <__cxa_finalize@plt>:
     ed0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     ed4:	ldr	x17, [x16, #48]
     ed8:	add	x16, x16, #0x30
     edc:	br	x17

0000000000000ee0 <std::__throw_invalid_argument(char const*)@plt>:
     ee0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     ee4:	ldr	x17, [x16, #56]
     ee8:	add	x16, x16, #0x38
     eec:	br	x17

0000000000000ef0 <erfcf@plt>:
     ef0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     ef4:	ldr	x17, [x16, #64]
     ef8:	add	x16, x16, #0x40
     efc:	br	x17

0000000000000f00 <std::__throw_logic_error(char const*)@plt>:
     f00:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     f04:	ldr	x17, [x16, #72]
     f08:	add	x16, x16, #0x48
     f0c:	br	x17

0000000000000f10 <__libc_start_main@plt>:
     f10:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     f14:	ldr	x17, [x16, #80]
     f18:	add	x16, x16, #0x50
     f1c:	br	x17

0000000000000f20 <posix_memalign@plt>:
     f20:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     f24:	ldr	x17, [x16, #88]
     f28:	add	x16, x16, #0x58
     f2c:	br	x17

0000000000000f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>:
     f30:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     f34:	ldr	x17, [x16, #96]
     f38:	add	x16, x16, #0x60
     f3c:	br	x17

0000000000000f40 <memmove@plt>:
     f40:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     f44:	ldr	x17, [x16, #104]
     f48:	add	x16, x16, #0x68
     f4c:	br	x17

0000000000000f50 <__isoc23_strtoul@plt>:
     f50:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     f54:	ldr	x17, [x16, #112]
     f58:	add	x16, x16, #0x70
     f5c:	br	x17

0000000000000f60 <__errno_location@plt>:
     f60:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     f64:	ldr	x17, [x16, #120]
     f68:	add	x16, x16, #0x78
     f6c:	br	x17

0000000000000f70 <std::chrono::_V2::steady_clock::now()@plt>:
     f70:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     f74:	ldr	x17, [x16, #128]
     f78:	add	x16, x16, #0x80
     f7c:	br	x17

0000000000000f80 <std::__throw_out_of_range(char const*)@plt>:
     f80:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     f84:	ldr	x17, [x16, #136]
     f88:	add	x16, x16, #0x88
     f8c:	br	x17

0000000000000f90 <strcmp@plt>:
     f90:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     f94:	ldr	x17, [x16, #144]
     f98:	add	x16, x16, #0x90
     f9c:	br	x17

0000000000000fa0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_replace(unsigned long, unsigned long, char const*, unsigned long)@plt>:
     fa0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     fa4:	ldr	x17, [x16, #152]
     fa8:	add	x16, x16, #0x98
     fac:	br	x17

0000000000000fb0 <abort@plt>:
     fb0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     fb4:	ldr	x17, [x16, #160]
     fb8:	add	x16, x16, #0xa0
     fbc:	br	x17

0000000000000fc0 <__gxx_personality_v0@plt>:
     fc0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     fc4:	ldr	x17, [x16, #168]
     fc8:	add	x16, x16, #0xa8
     fcc:	br	x17

0000000000000fd0 <expf@plt>:
     fd0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     fd4:	ldr	x17, [x16, #176]
     fd8:	add	x16, x16, #0xb0
     fdc:	br	x17

0000000000000fe0 <exit@plt>:
     fe0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     fe4:	ldr	x17, [x16, #184]
     fe8:	add	x16, x16, #0xb8
     fec:	br	x17

0000000000000ff0 <fwrite@plt>:
     ff0:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
     ff4:	ldr	x17, [x16, #192]
     ff8:	add	x16, x16, #0xc0
     ffc:	br	x17

0000000000001000 <_Unwind_Resume@plt>:
    1000:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
    1004:	ldr	x17, [x16, #200]
    1008:	add	x16, x16, #0xc8
    100c:	br	x17

0000000000001010 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long)@plt>:
    1010:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
    1014:	ldr	x17, [x16, #208]
    1018:	add	x16, x16, #0xd0
    101c:	br	x17

0000000000001020 <logf@plt>:
    1020:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
    1024:	ldr	x17, [x16, #216]
    1028:	add	x16, x16, #0xd8
    102c:	br	x17

0000000000001030 <__gmon_start__@plt>:
    1030:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
    1034:	ldr	x17, [x16, #224]
    1038:	add	x16, x16, #0xe0
    103c:	br	x17

0000000000001040 <printf@plt>:
    1040:	adrp	x16, 20000 <memcpy@GLIBC_2.17>
    1044:	ldr	x17, [x16, #232]
    1048:	add	x16, x16, #0xe8
    104c:	br	x17

Disassembly of section .text:

0000000000001080 <main>:
    1080:	mov	x12, #0x14a0                	// #5280
    1084:	sub	sp, sp, x12
    1088:	add	x2, sp, #0xd0
    108c:	stp	x29, x30, [sp]
    1090:	mov	x29, sp
    1094:	stp	x19, x20, [sp, #16]
    1098:	mov	w20, w0
    109c:	add	x19, sp, #0x118
    10a0:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    10a4:	stp	x21, x22, [sp, #32]
    10a8:	mov	x21, x1
    10ac:	add	x1, x0, #0x450
    10b0:	mov	x0, x2
    10b4:	str	x2, [sp, #176]
    10b8:	mov	x2, x19
    10bc:	stp	x23, x24, [sp, #48]
    10c0:	stp	x25, x26, [sp, #64]
    10c4:	stp	x27, x28, [sp, #80]
    10c8:	stp	d8, d9, [sp, #96]
    10cc:	stp	d10, d11, [sp, #112]
    10d0:	stp	d12, d13, [sp, #128]
    10d4:	stp	d14, d15, [sp, #144]
    10d8:	bl	41e0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>
    10dc:	cmp	w20, #0x1
    10e0:	b.le	1a5c <main+0x9dc>
    10e4:	add	x0, sp, #0xc8
    10e8:	adrp	x22, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    10ec:	adrp	x24, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    10f0:	add	x22, x22, #0x458
    10f4:	add	x24, x24, #0x468
    10f8:	mov	w27, #0x1                   	// #1
    10fc:	str	x0, [sp, #168]
    1100:	mov	x25, #0x100000              	// #1048576
    1104:	add	x0, sp, #0xf0
    1108:	str	x0, [sp, #184]
    110c:	sbfiz	x23, x27, #3, #32
    1110:	mov	x1, x22
    1114:	ldr	x26, [x21, x23]
    1118:	add	w28, w27, #0x1
    111c:	mov	x0, x26
    1120:	bl	f90 <strcmp@plt>
    1124:	cbnz	w0, 1438 <main+0x3b8>
    1128:	cmp	w20, w28
    112c:	b.gt	152c <main+0x4ac>
    1130:	ldr	x20, [sp, #176]
    1134:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1138:	add	x1, x0, #0x450
    113c:	mov	x0, x20
    1140:	bl	42c0 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1144:	tbnz	w0, #0, 115c <main+0xdc>
    1148:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    114c:	mov	x0, x20
    1150:	add	x1, x1, #0x478
    1154:	bl	42c0 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1158:	tbz	w0, #0, 1900 <main+0x880>
    115c:	mrs	x0, fpcr
    1160:	orr	x0, x0, #0x1000000
    1164:	msr	fpcr, x0
    1168:	mrs	x2, fpcr
    116c:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1170:	tst	x2, #0x1000000
    1174:	adrp	x3, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1178:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    117c:	add	x3, x3, #0x448
    1180:	add	x0, x0, #0x4d8
    1184:	add	x1, x1, #0x440
    1188:	csel	x1, x3, x1, eq	// eq = none
    118c:	bl	1040 <printf@plt>
    1190:	mov	x0, x25
    1194:	bl	1fc0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    1198:	mov	x24, x0
    119c:	mov	x0, x25
    11a0:	bl	1fc0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11a4:	mov	x23, x0
    11a8:	mov	x0, x25
    11ac:	bl	1fc0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11b0:	mov	x22, x0
    11b4:	mov	x0, x25
    11b8:	bl	1fc0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11bc:	mov	x21, x0
    11c0:	mov	x0, x25
    11c4:	bl	1fc0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11c8:	mov	x20, x0
    11cc:	mov	x0, x25
    11d0:	bl	1fc0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11d4:	mov	x3, #0xbabe                	// #47806
    11d8:	mov	x26, x0
    11dc:	movk	x3, #0xcafe, lsl #16
    11e0:	add	x2, x19, #0x8
    11e4:	mov	x0, x3
    11e8:	mov	x1, #0x1                   	// #1
    11ec:	str	x3, [sp, #280]
    11f0:	mov	w3, #0x8965                	// #35173
    11f4:	movk	w3, #0x6c07, lsl #16
    11f8:	nop
    11fc:	nop
    1200:	eor	x0, x0, x0, lsr #30
    1204:	madd	w0, w3, w0, w1
    1208:	add	x1, x1, #0x1
    120c:	str	x0, [x2], #8
    1210:	cmp	x1, #0x270
    1214:	b.ne	1200 <main+0x180>  // b.any
    1218:	str	x1, [sp, #5272]
    121c:	mov	x2, #0x0                   	// #0
    1220:	cbz	x25, 1574 <main+0x4f4>
    1224:	mov	w0, #0x2f800000            	// #796917760
    1228:	mov	x28, #0x5680                	// #22144
    122c:	movi	v15.2s, #0x0
    1230:	fmov	s13, #1.000000000000000000e+00
    1234:	movk	x28, #0x9d2c, lsl #16
    1238:	mov	x27, #0xefc60000            	// #4022730752
    123c:	fmov	s14, w0
    1240:	b	1418 <main+0x398>
    1244:	ldr	x0, [x19, x1, lsl #3]
    1248:	add	x6, x1, #0x1
    124c:	str	x6, [sp, #5272]
    1250:	ubfx	x1, x0, #11, #32
    1254:	eor	x0, x0, x1
    1258:	and	x1, x28, x0, lsl #7
    125c:	eor	x0, x0, x1
    1260:	and	x1, x27, x0, lsl #15
    1264:	eor	x0, x0, x1
    1268:	eor	x0, x0, x0, lsr #18
    126c:	ucvtf	s31, x0
    1270:	fadd	s31, s31, s15
    1274:	fmul	s31, s31, s14
    1278:	fcmpe	s31, s13
    127c:	b.ge	18dc <main+0x85c>  // b.tcont
    1280:	mov	w1, #0x42c80000            	// #1120403456
    1284:	mov	w0, #0x42480000            	// #1112014848
    1288:	fmov	s29, w1
    128c:	fmov	s30, w0
    1290:	fmadd	s31, s31, s29, s30
    1294:	str	s31, [x24, x2, lsl #2]
    1298:	cmp	x6, #0x26f
    129c:	b.hi	150c <main+0x48c>  // b.pmore
    12a0:	ldr	x0, [x19, x6, lsl #3]
    12a4:	add	x5, x6, #0x1
    12a8:	str	x5, [sp, #5272]
    12ac:	ubfx	x1, x0, #11, #32
    12b0:	eor	x0, x0, x1
    12b4:	and	x1, x28, x0, lsl #7
    12b8:	eor	x0, x0, x1
    12bc:	and	x1, x27, x0, lsl #15
    12c0:	eor	x0, x0, x1
    12c4:	eor	x0, x0, x0, lsr #18
    12c8:	ucvtf	s31, x0
    12cc:	fadd	s31, s31, s15
    12d0:	fmul	s31, s31, s14
    12d4:	fcmpe	s31, s13
    12d8:	b.ge	18d0 <main+0x850>  // b.tcont
    12dc:	mov	w1, #0x42c80000            	// #1120403456
    12e0:	mov	w0, #0x42480000            	// #1112014848
    12e4:	fmov	s29, w1
    12e8:	fmov	s30, w0
    12ec:	fmadd	s31, s31, s29, s30
    12f0:	str	s31, [x23, x2, lsl #2]
    12f4:	cmp	x5, #0x26f
    12f8:	b.hi	14f4 <main+0x474>  // b.pmore
    12fc:	ldr	x0, [x19, x5, lsl #3]
    1300:	add	x1, x5, #0x1
    1304:	str	x1, [sp, #5272]
    1308:	ubfx	x5, x0, #11, #32
    130c:	eor	x0, x0, x5
    1310:	and	x5, x28, x0, lsl #7
    1314:	eor	x0, x0, x5
    1318:	and	x5, x27, x0, lsl #15
    131c:	eor	x0, x0, x5
    1320:	eor	x0, x0, x0, lsr #18
    1324:	ucvtf	s31, x0
    1328:	fadd	s31, s31, s15
    132c:	fmul	s31, s31, s14
    1330:	fcmpe	s31, s13
    1334:	b.ge	18f8 <main+0x878>  // b.tcont
    1338:	mov	w5, #0x999a                	// #39322
    133c:	mov	w0, #0xcccd                	// #52429
    1340:	movk	w5, #0x3ff9, lsl #16
    1344:	movk	w0, #0x3d4c, lsl #16
    1348:	fmov	s29, w5
    134c:	fmov	s30, w0
    1350:	fmadd	s31, s31, s29, s30
    1354:	str	s31, [x22, x2, lsl #2]
    1358:	cmp	x1, #0x26f
    135c:	b.hi	14dc <main+0x45c>  // b.pmore
    1360:	ldr	x0, [x19, x1, lsl #3]
    1364:	add	x5, x1, #0x1
    1368:	str	x5, [sp, #5272]
    136c:	ubfx	x1, x0, #11, #32
    1370:	eor	x0, x0, x1
    1374:	and	x1, x28, x0, lsl #7
    1378:	eor	x0, x0, x1
    137c:	and	x1, x27, x0, lsl #15
    1380:	eor	x0, x0, x1
    1384:	eor	x0, x0, x0, lsr #18
    1388:	ucvtf	s31, x0
    138c:	fadd	s31, s31, s15
    1390:	fmul	s31, s31, s14
    1394:	fcmpe	s31, s13
    1398:	b.ge	18e8 <main+0x868>  // b.tcont
    139c:	mov	w0, #0xd70a                	// #55050
    13a0:	movk	w0, #0x3da3, lsl #16
    13a4:	fmov	s30, w0
    13a8:	fmadd	s31, s31, s30, s15
    13ac:	str	s31, [x21, x2, lsl #2]
    13b0:	cmp	x5, #0x26f
    13b4:	b.hi	14c4 <main+0x444>  // b.pmore
    13b8:	ldr	x0, [x19, x5, lsl #3]
    13bc:	add	x1, x5, #0x1
    13c0:	str	x1, [sp, #5272]
    13c4:	ubfx	x5, x0, #11, #32
    13c8:	eor	x0, x0, x5
    13cc:	and	x5, x28, x0, lsl #7
    13d0:	eor	x0, x0, x5
    13d4:	and	x5, x27, x0, lsl #15
    13d8:	eor	x0, x0, x5
    13dc:	eor	x0, x0, x0, lsr #18
    13e0:	ucvtf	s31, x0
    13e4:	fadd	s31, s31, s15
    13e8:	fmul	s31, s31, s14
    13ec:	fcmpe	s31, s13
    13f0:	b.ge	155c <main+0x4dc>  // b.tcont
    13f4:	mov	w0, #0xcccd                	// #52429
    13f8:	fmov	s29, #5.000000000000000000e-01
    13fc:	movk	w0, #0x3dcc, lsl #16
    1400:	fmov	s30, w0
    1404:	fmadd	s31, s31, s29, s30
    1408:	str	s31, [x20, x2, lsl #2]
    140c:	add	x2, x2, #0x1
    1410:	cmp	x2, x25
    1414:	b.eq	1574 <main+0x4f4>  // b.none
    1418:	cmp	x1, #0x26f
    141c:	b.ls	1244 <main+0x1c4>  // b.plast
    1420:	mov	x0, x19
    1424:	str	x2, [sp, #168]
    1428:	bl	4340 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    142c:	ldr	x2, [sp, #168]
    1430:	ldr	x1, [sp, #5272]
    1434:	b	1244 <main+0x1c4>
    1438:	mov	x0, x26
    143c:	mov	x1, x24
    1440:	bl	f90 <strcmp@plt>
    1444:	cbnz	w0, 1524 <main+0x4a4>
    1448:	cmp	w20, w28
    144c:	b.le	1130 <main+0xb0>
    1450:	add	x23, x21, x23
    1454:	ldr	x2, [sp, #168]
    1458:	mov	x0, x19
    145c:	ldr	x1, [x23, #8]
    1460:	bl	41e0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>
    1464:	bl	f60 <__errno_location@plt>
    1468:	ldr	x26, [sp, #280]
    146c:	mov	x23, x0
    1470:	mov	w2, #0xa                   	// #10
    1474:	ldr	x1, [sp, #184]
    1478:	ldr	w28, [x0]
    147c:	mov	x0, x26
    1480:	str	wzr, [x23]
    1484:	bl	f50 <__isoc23_strtoul@plt>
    1488:	ldr	x1, [sp, #240]
    148c:	mov	x25, x0
    1490:	cmp	x26, x1
    1494:	b.eq	1a84 <main+0xa04>  // b.none
    1498:	ldr	w0, [x23]
    149c:	cmp	w0, #0x22
    14a0:	b.eq	1a78 <main+0x9f8>  // b.none
    14a4:	cbnz	w0, 14ac <main+0x42c>
    14a8:	str	w28, [x23]
    14ac:	mov	x0, x19
    14b0:	add	w27, w27, #0x2
    14b4:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    14b8:	cmp	w20, w27
    14bc:	b.gt	110c <main+0x8c>
    14c0:	b	1130 <main+0xb0>
    14c4:	mov	x0, x19
    14c8:	str	x2, [sp, #168]
    14cc:	bl	4340 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    14d0:	ldr	x2, [sp, #168]
    14d4:	ldr	x5, [sp, #5272]
    14d8:	b	13b8 <main+0x338>
    14dc:	mov	x0, x19
    14e0:	str	x2, [sp, #168]
    14e4:	bl	4340 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    14e8:	ldr	x2, [sp, #168]
    14ec:	ldr	x1, [sp, #5272]
    14f0:	b	1360 <main+0x2e0>
    14f4:	mov	x0, x19
    14f8:	str	x2, [sp, #168]
    14fc:	bl	4340 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    1500:	ldr	x2, [sp, #168]
    1504:	ldr	x5, [sp, #5272]
    1508:	b	12fc <main+0x27c>
    150c:	mov	x0, x19
    1510:	str	x2, [sp, #168]
    1514:	bl	4340 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    1518:	ldr	x2, [sp, #168]
    151c:	ldr	x6, [sp, #5272]
    1520:	b	12a0 <main+0x220>
    1524:	mov	w27, w28
    1528:	b	14b8 <main+0x438>
    152c:	add	x23, x21, x23
    1530:	ldr	x23, [x23, #8]
    1534:	mov	x0, x23
    1538:	bl	e80 <strlen@plt>
    153c:	ldr	x2, [sp, #216]
    1540:	mov	x4, x0
    1544:	mov	x3, x23
    1548:	mov	x1, #0x0                   	// #0
    154c:	ldr	x0, [sp, #176]
    1550:	bl	fa0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_replace(unsigned long, unsigned long, char const*, unsigned long)@plt>
    1554:	add	w27, w27, #0x2
    1558:	b	14b8 <main+0x438>
    155c:	mov	w0, #0x9999                	// #39321
    1560:	movk	w0, #0x3f19, lsl #16
    1564:	str	w0, [x20, x2, lsl #2]
    1568:	add	x2, x2, #0x1
    156c:	cmp	x2, x25
    1570:	b.ne	1418 <main+0x398>  // b.any
    1574:	mov	w0, #0x4f3                 	// #1267
    1578:	fmov	s8, #5.000000000000000000e-01
    157c:	mov	x27, #0x0                   	// #0
    1580:	movk	w0, #0x3f35, lsl #16
    1584:	fmov	s13, w0
    1588:	ldr	s9, [x22, x27, lsl #2]
    158c:	ldr	s12, [x20, x27, lsl #2]
    1590:	ldr	s30, [x24, x27, lsl #2]
    1594:	fcmp	s9, #0.0
    1598:	ldr	s15, [x23, x27, lsl #2]
    159c:	ldr	s10, [x21, x27, lsl #2]
    15a0:	fmul	s14, s12, s12
    15a4:	b.pl	15c0 <main+0x540>  // b.nfrst
    15a8:	fmov	s0, s9
    15ac:	str	s30, [sp, #168]
    15b0:	bl	ec0 <sqrtf@plt>
    15b4:	ldr	s30, [sp, #168]
    15b8:	fmov	s31, s0
    15bc:	b	15c4 <main+0x544>
    15c0:	fsqrt	s31, s9
    15c4:	fmul	s12, s12, s31
    15c8:	str	s30, [sp, #168]
    15cc:	fdiv	s0, s30, s15
    15d0:	bl	1020 <logf@plt>
    15d4:	fmadd	s14, s14, s8, s10
    15d8:	fmadd	s14, s9, s14, s0
    15dc:	fdiv	s14, s14, s12
    15e0:	fnmul	s0, s14, s13
    15e4:	bl	ef0 <erfcf@plt>
    15e8:	fmov	s11, s0
    15ec:	fnmul	s0, s10, s9
    15f0:	bl	fd0 <expf@plt>
    15f4:	fsub	s14, s14, s12
    15f8:	fmov	s31, s0
    15fc:	fnmul	s0, s14, s13
    1600:	fmov	s14, s31
    1604:	bl	ef0 <erfcf@plt>
    1608:	fmul	s15, s15, s14
    160c:	fmul	s0, s0, s8
    1610:	ldr	s30, [sp, #168]
    1614:	fmul	s11, s11, s8
    1618:	fmul	s15, s15, s0
    161c:	fnmsub	s15, s30, s11, s15
    1620:	str	s15, [x19, x27, lsl #2]
    1624:	add	x27, x27, #0x1
    1628:	cmp	x27, #0x100
    162c:	b.ne	1588 <main+0x508>  // b.any
    1630:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1634:	add	x1, x0, #0x450
    1638:	ldr	x0, [sp, #176]
    163c:	bl	42c0 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1640:	tbnz	w0, #0, 19ec <main+0x96c>
    1644:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1648:	ldr	x0, [sp, #176]
    164c:	add	x1, x1, #0x480
    1650:	bl	42c0 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1654:	tbnz	w0, #0, 194c <main+0x8cc>
    1658:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    165c:	ldr	x0, [sp, #176]
    1660:	add	x1, x1, #0x488
    1664:	bl	42c0 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1668:	mov	x6, x27
    166c:	mov	x5, x26
    1670:	mov	x4, x20
    1674:	mov	x3, x21
    1678:	mov	x2, x22
    167c:	mov	x1, x23
    1680:	tbz	w0, #0, 1a50 <main+0x9d0>
    1684:	mov	x0, x24
    1688:	bl	2fa0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    168c:	movi	v30.2s, #0x0
    1690:	mov	x0, #0x1                   	// #1
    1694:	sub	x2, x26, #0x4
    1698:	nop
    169c:	nop
    16a0:	add	x1, x19, x0, lsl #2
    16a4:	ldr	s31, [x2, x0, lsl #2]
    16a8:	add	x0, x0, #0x1
    16ac:	ldur	s29, [x1, #-4]
    16b0:	fabd	s31, s31, s29
    16b4:	fcmpe	s31, s30
    16b8:	fcsel	s30, s31, s30, gt
    16bc:	cmp	x0, #0x101
    16c0:	b.ne	16a0 <main+0x620>  // b.any
    16c4:	mov	w0, #0xb717                	// #46871
    16c8:	fcvt	d0, s30
    16cc:	movk	w0, #0x38d1, lsl #16
    16d0:	fmov	s31, w0
    16d4:	fcmpe	s30, s31
    16d8:	b.ge	19c8 <main+0x948>  // b.tcont
    16dc:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    16e0:	add	x0, x0, #0x538
    16e4:	bl	1040 <printf@plt>
    16e8:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    16ec:	ldr	x1, [sp, #208]
    16f0:	mov	x2, x25
    16f4:	add	x0, x0, #0x570
    16f8:	bl	1040 <printf@plt>
    16fc:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1700:	scvtf	d15, x25
    1704:	mov	x27, #0x1                   	// #1
    1708:	ldr	d14, [x0, #1968]
    170c:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1710:	add	x0, x0, #0x488
    1714:	str	x0, [sp, #184]
    1718:	add	x0, sp, #0xf0
    171c:	str	x0, [sp, #168]
    1720:	bl	f70 <std::chrono::_V2::steady_clock::now()@plt>
    1724:	ldr	x1, [sp, #216]
    1728:	mov	x28, x0
    172c:	cmp	x1, #0x6
    1730:	b.eq	1970 <main+0x8f0>  // b.none
    1734:	cmp	x1, #0x7
    1738:	b.ne	1760 <main+0x6e0>  // b.any
    173c:	ldr	x0, [sp, #208]
    1740:	mov	w2, #0x7561                	// #30049
    1744:	movk	w2, #0x6f74, lsl #16
    1748:	ldr	w1, [x0]
    174c:	cmp	w1, w2
    1750:	b.eq	1a10 <main+0x990>  // b.none
    1754:	nop
    1758:	nop
    175c:	nop
    1760:	ldp	x0, x1, [sp, #176]
    1764:	bl	42c0 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1768:	mov	x6, x25
    176c:	mov	x5, x26
    1770:	mov	x4, x20
    1774:	mov	x3, x21
    1778:	mov	x2, x22
    177c:	mov	x1, x23
    1780:	tbz	w0, #0, 19bc <main+0x93c>
    1784:	mov	x0, x24
    1788:	bl	2fa0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    178c:	bl	f70 <std::chrono::_V2::steady_clock::now()@plt>
    1790:	lsr	x2, x25, #4
    1794:	str	wzr, [sp, #200]
    1798:	mov	x1, #0x0                   	// #0
    179c:	add	x2, x2, #0x1
    17a0:	cbz	x25, 17c0 <main+0x740>
    17a4:	ldr	s30, [x26, x1, lsl #2]
    17a8:	add	x1, x1, x2
    17ac:	ldr	s31, [sp, #200]
    17b0:	fadd	s31, s31, s30
    17b4:	str	s31, [sp, #200]
    17b8:	cmp	x1, x25
    17bc:	b.cc	17a4 <main+0x724>  // b.lo, b.ul, b.last
    17c0:	sub	x2, x0, x28
    17c4:	ldr	x0, [sp, #168]
    17c8:	mov	w1, w27
    17cc:	scvtf	d1, x2
    17d0:	ldr	s31, [sp, #200]
    17d4:	add	x3, x0, x27, lsl #3
    17d8:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    17dc:	add	x0, x0, #0x588
    17e0:	fdiv	d0, d1, d15
    17e4:	fmul	d1, d1, d14
    17e8:	fdiv	d1, d15, d1
    17ec:	stur	d0, [x3, #-8]
    17f0:	bl	1040 <printf@plt>
    17f4:	add	x27, x27, #0x1
    17f8:	cmp	x27, #0x6
    17fc:	b.ne	1720 <main+0x6a0>  // b.any
    1800:	ldp	q30, q31, [sp, #240]
    1804:	add	x4, sp, #0x200
    1808:	add	x11, x19, #0x28
    180c:	mov	x1, x11
    1810:	mov	x2, #0x4                   	// #4
    1814:	ldr	x3, [sp, #272]
    1818:	mov	x0, x19
    181c:	stur	q30, [x4, #-232]
    1820:	add	x4, sp, #0x220
    1824:	stur	q31, [x4, #-248]
    1828:	str	x3, [sp, #312]
    182c:	bl	1e00 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1830:	mov	x1, x11
    1834:	mov	x0, x19
    1838:	bl	1d24 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    183c:	mov	x1, #0xcd6500000000        	// #225833675390976
    1840:	ldr	d0, [sp, #296]
    1844:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1848:	movk	x1, #0x41cd, lsl #48
    184c:	add	x0, x0, #0x5b0
    1850:	fmov	d1, x1
    1854:	fdiv	d1, d1, d0
    1858:	bl	1040 <printf@plt>
    185c:	mov	x0, x24
    1860:	mov	w19, #0x0                   	// #0
    1864:	bl	eb0 <free@plt>
    1868:	mov	x0, x23
    186c:	bl	eb0 <free@plt>
    1870:	mov	x0, x22
    1874:	bl	eb0 <free@plt>
    1878:	mov	x0, x21
    187c:	bl	eb0 <free@plt>
    1880:	mov	x0, x20
    1884:	bl	eb0 <free@plt>
    1888:	mov	x0, x26
    188c:	bl	eb0 <free@plt>
    1890:	ldr	x0, [sp, #176]
    1894:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1898:	mov	x12, #0x14a0                	// #5280
    189c:	ldp	d8, d9, [sp, #96]
    18a0:	ldp	x29, x30, [sp]
    18a4:	mov	w0, w19
    18a8:	ldp	x19, x20, [sp, #16]
    18ac:	ldp	x21, x22, [sp, #32]
    18b0:	ldp	x23, x24, [sp, #48]
    18b4:	ldp	x25, x26, [sp, #64]
    18b8:	ldp	x27, x28, [sp, #80]
    18bc:	ldp	d10, d11, [sp, #112]
    18c0:	ldp	d12, d13, [sp, #128]
    18c4:	ldp	d14, d15, [sp, #144]
    18c8:	add	sp, sp, x12
    18cc:	ret
    18d0:	mov	w0, #0x43160000            	// #1125515264
    18d4:	fmov	s31, w0
    18d8:	b	12f0 <main+0x270>
    18dc:	mov	w0, #0x43160000            	// #1125515264
    18e0:	fmov	s31, w0
    18e4:	b	1294 <main+0x214>
    18e8:	mov	w0, #0xd709                	// #55049
    18ec:	movk	w0, #0x3da3, lsl #16
    18f0:	fmov	s31, w0
    18f4:	b	13ac <main+0x32c>
    18f8:	mvni	v31.2s, #0xc0, lsl #24
    18fc:	b	1354 <main+0x2d4>
    1900:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1904:	mov	x0, x20
    1908:	add	x1, x1, #0x480
    190c:	bl	42c0 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1910:	tbnz	w0, #0, 115c <main+0xdc>
    1914:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1918:	mov	x0, x20
    191c:	add	x1, x1, #0x488
    1920:	bl	42c0 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1924:	tbnz	w0, #0, 115c <main+0xdc>
    1928:	adrp	x0, 1f000 <__abi_tag+0x1a2e8>
    192c:	ldr	x0, [x0, #4056]
    1930:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1934:	add	x1, x1, #0x498
    1938:	ldr	x2, [x21]
    193c:	ldr	x0, [x0]
    1940:	bl	e90 <fprintf@plt>
    1944:	mov	w19, #0x1                   	// #1
    1948:	b	1890 <main+0x810>
    194c:	mov	x6, x27
    1950:	mov	x5, x26
    1954:	mov	x4, x20
    1958:	mov	x3, x21
    195c:	mov	x2, x22
    1960:	mov	x1, x23
    1964:	mov	x0, x24
    1968:	bl	27e0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    196c:	b	168c <main+0x60c>
    1970:	ldr	x0, [sp, #208]
    1974:	mov	w2, #0x6373                	// #25459
    1978:	movk	w2, #0x6c61, lsl #16
    197c:	ldr	w1, [x0]
    1980:	cmp	w1, w2
    1984:	b.ne	1760 <main+0x6e0>  // b.any
    1988:	ldrh	w1, [x0, #4]
    198c:	mov	w0, #0x7261                	// #29281
    1990:	cmp	w1, w0
    1994:	b.ne	1760 <main+0x6e0>  // b.any
    1998:	mov	x6, x25
    199c:	mov	x5, x26
    19a0:	mov	x4, x20
    19a4:	mov	x3, x21
    19a8:	mov	x2, x22
    19ac:	mov	x1, x23
    19b0:	mov	x0, x24
    19b4:	bl	2020 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    19b8:	b	178c <main+0x70c>
    19bc:	mov	x0, x24
    19c0:	bl	36a0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    19c4:	b	178c <main+0x70c>
    19c8:	adrp	x0, 1f000 <__abi_tag+0x1a2e8>
    19cc:	ldr	x0, [x0, #4056]
    19d0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    19d4:	add	x1, x1, #0x500
    19d8:	ldr	x2, [sp, #208]
    19dc:	ldr	x0, [x0]
    19e0:	bl	e90 <fprintf@plt>
    19e4:	mov	w19, #0x1                   	// #1
    19e8:	b	1890 <main+0x810>
    19ec:	mov	x6, x27
    19f0:	mov	x5, x26
    19f4:	mov	x4, x20
    19f8:	mov	x3, x21
    19fc:	mov	x2, x22
    1a00:	mov	x1, x23
    1a04:	mov	x0, x24
    1a08:	bl	2020 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1a0c:	b	168c <main+0x60c>
    1a10:	ldrh	w2, [x0, #4]
    1a14:	mov	w1, #0x6576                	// #25974
    1a18:	cmp	w2, w1
    1a1c:	b.ne	1760 <main+0x6e0>  // b.any
    1a20:	ldrb	w0, [x0, #6]
    1a24:	cmp	w0, #0x63
    1a28:	b.ne	1760 <main+0x6e0>  // b.any
    1a2c:	mov	x6, x25
    1a30:	mov	x5, x26
    1a34:	mov	x4, x20
    1a38:	mov	x3, x21
    1a3c:	mov	x2, x22
    1a40:	mov	x1, x23
    1a44:	mov	x0, x24
    1a48:	bl	27e0 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1a4c:	b	178c <main+0x70c>
    1a50:	mov	x0, x24
    1a54:	bl	36a0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1a58:	b	168c <main+0x60c>
    1a5c:	mov	x25, #0x100000              	// #1048576
    1a60:	b	1130 <main+0xb0>
    1a64:	mov	x20, x0
    1a68:	ldr	x0, [sp, #176]
    1a6c:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1a70:	mov	x0, x20
    1a74:	bl	1000 <_Unwind_Resume@plt>
    1a78:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1a7c:	add	x0, x0, #0x470
    1a80:	bl	f80 <std::__throw_out_of_range(char const*)@plt>
    1a84:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1a88:	add	x0, x0, #0x470
    1a8c:	bl	ee0 <std::__throw_invalid_argument(char const*)@plt>
    1a90:	ldr	w1, [x23]
    1a94:	mov	x20, x0
    1a98:	cbnz	w1, 1aa0 <main+0xa20>
    1a9c:	str	w28, [x23]
    1aa0:	mov	x0, x19
    1aa4:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1aa8:	b	1a68 <main+0x9e8>
    1aac:	nop
    1ab0:	nop
    1ab4:	nop
    1ab8:	nop
    1abc:	nop

0000000000001ac0 <_start>:
    1ac0:	bti	c
    1ac4:	mov	x29, #0x0                   	// #0
    1ac8:	mov	x30, #0x0                   	// #0
    1acc:	mov	x5, x0
    1ad0:	ldr	x1, [sp]
    1ad4:	add	x2, sp, #0x8
    1ad8:	mov	x6, sp
    1adc:	adrp	x0, 1f000 <__abi_tag+0x1a2e8>
    1ae0:	ldr	x0, [x0, #4024]
    1ae4:	mov	x3, #0x0                   	// #0
    1ae8:	mov	x4, #0x0                   	// #0
    1aec:	bl	f10 <__libc_start_main@plt>
    1af0:	bl	fb0 <abort@plt>

0000000000001af4 <call_weak_fn>:
    1af4:	adrp	x0, 1f000 <__abi_tag+0x1a2e8>
    1af8:	ldr	x0, [x0, #4048]
    1afc:	cbz	x0, 1b04 <call_weak_fn+0x10>
    1b00:	b	1030 <__gmon_start__@plt>
    1b04:	ret
    1b08:	nop
    1b0c:	nop
    1b10:	nop
    1b14:	nop
    1b18:	nop
    1b1c:	nop

0000000000001b20 <deregister_tm_clones>:
    1b20:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1b24:	add	x0, x0, #0x108
    1b28:	adrp	x1, 20000 <memcpy@GLIBC_2.17>
    1b2c:	add	x1, x1, #0x108
    1b30:	cmp	x1, x0
    1b34:	b.eq	1b4c <deregister_tm_clones+0x2c>  // b.none
    1b38:	adrp	x1, 1f000 <__abi_tag+0x1a2e8>
    1b3c:	ldr	x1, [x1, #4040]
    1b40:	cbz	x1, 1b4c <deregister_tm_clones+0x2c>
    1b44:	mov	x16, x1
    1b48:	br	x16
    1b4c:	ret

0000000000001b50 <register_tm_clones>:
    1b50:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1b54:	add	x0, x0, #0x108
    1b58:	adrp	x1, 20000 <memcpy@GLIBC_2.17>
    1b5c:	add	x1, x1, #0x108
    1b60:	sub	x1, x1, x0
    1b64:	lsr	x2, x1, #63
    1b68:	add	x1, x2, x1, asr #3
    1b6c:	asr	x1, x1, #1
    1b70:	cbz	x1, 1b88 <register_tm_clones+0x38>
    1b74:	adrp	x2, 1f000 <__abi_tag+0x1a2e8>
    1b78:	ldr	x2, [x2, #4064]
    1b7c:	cbz	x2, 1b88 <register_tm_clones+0x38>
    1b80:	mov	x16, x2
    1b84:	br	x16
    1b88:	ret

0000000000001b8c <__do_global_dtors_aux>:
    1b8c:	paciasp
    1b90:	stp	x29, x30, [sp, #-32]!
    1b94:	mov	x29, sp
    1b98:	str	x19, [sp, #16]
    1b9c:	adrp	x19, 20000 <memcpy@GLIBC_2.17>
    1ba0:	ldrb	w0, [x19, #264]
    1ba4:	tbnz	w0, #0, 1bcc <__do_global_dtors_aux+0x40>
    1ba8:	adrp	x0, 1f000 <__abi_tag+0x1a2e8>
    1bac:	ldr	x0, [x0, #4032]
    1bb0:	cbz	x0, 1bc0 <__do_global_dtors_aux+0x34>
    1bb4:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1bb8:	ldr	x0, [x0, #248]
    1bbc:	bl	ed0 <__cxa_finalize@plt>
    1bc0:	bl	1b20 <deregister_tm_clones>
    1bc4:	mov	w0, #0x1                   	// #1
    1bc8:	strb	w0, [x19, #264]
    1bcc:	ldr	x19, [sp, #16]
    1bd0:	ldp	x29, x30, [sp], #32
    1bd4:	autiasp
    1bd8:	ret
    1bdc:	nop

0000000000001be0 <frame_dummy>:
    1be0:	bti	c
    1be4:	b	1b50 <register_tm_clones>
    1be8:	nop
    1bec:	nop
    1bf0:	nop
    1bf4:	nop
    1bf8:	nop
    1bfc:	nop

0000000000001c00 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1c00:	sub	x7, x2, #0x1
    1c04:	and	x8, x2, #0x1
    1c08:	add	x7, x7, x7, lsr #63
    1c0c:	asr	x7, x7, #1
    1c10:	cmp	x1, x7
    1c14:	b.ge	1d04 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x104>  // b.tcont
    1c18:	mov	x4, x1
    1c1c:	nop
    1c20:	add	x3, x4, #0x1
    1c24:	add	x5, x0, x3, lsl #4
    1c28:	lsl	x6, x3, #4
    1c2c:	lsl	x3, x3, #1
    1c30:	ldr	d31, [x0, x6]
    1c34:	ldur	d1, [x5, #-8]
    1c38:	fcmpe	d31, d1
    1c3c:	b.mi	1c54 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x54>  // b.first
    1c40:	str	d31, [x0, x4, lsl #3]
    1c44:	cmp	x3, x7
    1c48:	b.ge	1c6c <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x6c>  // b.tcont
    1c4c:	mov	x4, x3
    1c50:	b	1c20 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x20>
    1c54:	sub	x3, x3, #0x1
    1c58:	add	x5, x0, x3, lsl #3
    1c5c:	ldr	d31, [x0, x3, lsl #3]
    1c60:	str	d31, [x0, x4, lsl #3]
    1c64:	cmp	x3, x7
    1c68:	b.lt	1c4c <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x4c>  // b.tstop
    1c6c:	cbz	x8, 1cc8 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>
    1c70:	sub	x4, x3, #0x1
    1c74:	add	x4, x4, x4, lsr #63
    1c78:	asr	x4, x4, #1
    1c7c:	cmp	x3, x1
    1c80:	b.le	1cac <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>
    1c84:	ldr	d30, [x0, x4, lsl #3]
    1c88:	sub	x2, x4, #0x1
    1c8c:	add	x5, x0, x3, lsl #3
    1c90:	add	x2, x2, x2, lsr #63
    1c94:	lsl	x6, x3, #3
    1c98:	mov	x3, x4
    1c9c:	add	x7, x0, x4, lsl #3
    1ca0:	asr	x2, x2, #1
    1ca4:	fcmpe	d30, d0
    1ca8:	b.mi	1cb4 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xb4>  // b.first
    1cac:	str	d0, [x5]
    1cb0:	ret
    1cb4:	str	d30, [x0, x6]
    1cb8:	cmp	x1, x4
    1cbc:	b.ge	1cf8 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xf8>  // b.tcont
    1cc0:	mov	x4, x2
    1cc4:	b	1c84 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>
    1cc8:	sub	x2, x2, #0x2
    1ccc:	add	x2, x2, x2, lsr #63
    1cd0:	cmp	x3, x2, asr #1
    1cd4:	b.ne	1c70 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>  // b.any
    1cd8:	add	x3, x3, #0x1
    1cdc:	add	x2, x0, x3, lsl #4
    1ce0:	lsl	x3, x3, #1
    1ce4:	sub	x3, x3, #0x1
    1ce8:	ldur	d31, [x2, #-8]
    1cec:	str	d31, [x5]
    1cf0:	add	x5, x0, x3, lsl #3
    1cf4:	b	1c70 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>
    1cf8:	mov	x5, x7
    1cfc:	str	d0, [x5]
    1d00:	ret
    1d04:	add	x5, x0, x1, lsl #3
    1d08:	cbnz	x8, 1cac <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>
    1d0c:	sub	x2, x2, #0x2
    1d10:	add	x2, x2, x2, lsr #63
    1d14:	cmp	x1, x2, asr #1
    1d18:	b.ne	1cac <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>  // b.any
    1d1c:	mov	x3, x1
    1d20:	b	1cd8 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xd8>

0000000000001d24 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1d24:	cmp	x0, x1
    1d28:	b.eq	1df4 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xd0>  // b.none
    1d2c:	stp	x29, x30, [sp, #-64]!
    1d30:	mov	x29, sp
    1d34:	stp	x19, x20, [sp, #16]
    1d38:	add	x19, x0, #0x8
    1d3c:	mov	x20, x0
    1d40:	stp	x21, x22, [sp, #32]
    1d44:	mov	x21, x1
    1d48:	cmp	x1, x19
    1d4c:	b.eq	1d98 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x74>  // b.none
    1d50:	mov	x22, #0x8                   	// #8
    1d54:	stp	d14, d15, [sp, #48]
    1d58:	nop
    1d5c:	nop
    1d60:	ldr	d15, [x19]
    1d64:	ldr	d14, [x20]
    1d68:	fcmpe	d15, d14
    1d6c:	b.mi	1dc0 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x9c>  // b.first
    1d70:	ldur	d31, [x19, #-8]
    1d74:	sub	x2, x19, #0x8
    1d78:	fcmpe	d15, d31
    1d7c:	b.mi	1da8 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>  // b.first
    1d80:	mov	x3, x19
    1d84:	str	d15, [x3]
    1d88:	add	x19, x19, #0x8
    1d8c:	cmp	x21, x19
    1d90:	b.ne	1d60 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x3c>  // b.any
    1d94:	ldp	d14, d15, [sp, #48]
    1d98:	ldp	x19, x20, [sp, #16]
    1d9c:	ldp	x21, x22, [sp, #32]
    1da0:	ldp	x29, x30, [sp], #64
    1da4:	ret
    1da8:	mov	x3, x2
    1dac:	str	d31, [x2, #8]
    1db0:	ldr	d31, [x2, #-8]!
    1db4:	fcmpe	d15, d31
    1db8:	b.mi	1da8 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>  // b.first
    1dbc:	b	1d84 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x60>
    1dc0:	sub	x2, x19, x20
    1dc4:	cmp	x2, #0x8
    1dc8:	b.le	1de4 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc0>
    1dcc:	sub	x0, x22, x2
    1dd0:	mov	x1, x20
    1dd4:	add	x0, x19, x0
    1dd8:	bl	f40 <memmove@plt>
    1ddc:	str	d15, [x20]
    1de0:	b	1d88 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>
    1de4:	b.ne	1ddc <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xb8>  // b.any
    1de8:	str	d14, [x19]
    1dec:	str	d15, [x20]
    1df0:	b	1d88 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>
    1df4:	ret
    1df8:	nop
    1dfc:	nop

0000000000001e00 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1e00:	stp	x29, x30, [sp, #-48]!
    1e04:	mov	x29, sp
    1e08:	stp	x19, x20, [sp, #16]
    1e0c:	mov	x20, x0
    1e10:	sub	x0, x1, x0
    1e14:	cmp	x0, #0x80
    1e18:	b.le	1f8c <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x18c>
    1e1c:	asr	x10, x0, #3
    1e20:	mov	x9, x1
    1e24:	str	x21, [sp, #32]
    1e28:	mov	x21, x2
    1e2c:	asr	x0, x0, #4
    1e30:	cbz	x21, 1f28 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x128>
    1e34:	lsl	x0, x0, #3
    1e38:	ldp	d28, d31, [x20]
    1e3c:	sub	x21, x21, #0x1
    1e40:	add	x19, x20, #0x8
    1e44:	ldr	d30, [x20, x0]
    1e48:	ldur	d0, [x9, #-8]
    1e4c:	fcmpe	d31, d30
    1e50:	b.mi	1fa8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x1a8>  // b.first
    1e54:	fcmpe	d31, d0
    1e58:	b.mi	1fb8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x1b8>  // b.first
    1e5c:	fcmpe	d30, d0
    1e60:	b.mi	1f98 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x198>  // b.first
    1e64:	str	d30, [x20]
    1e68:	str	d28, [x20, x0]
    1e6c:	ldp	d31, d28, [x20]
    1e70:	mov	x3, x9
    1e74:	nop
    1e78:	nop
    1e7c:	nop
    1e80:	fcmpe	d31, d28
    1e84:	b.gt	1ec8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>
    1e88:	ldur	d29, [x3, #-8]
    1e8c:	sub	x0, x3, #0x8
    1e90:	fcmpe	d29, d31
    1e94:	b.gt	1ee8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1e98:	nop
    1e9c:	nop
    1ea0:	cmp	x19, x0
    1ea4:	b.cs	1efc <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xfc>  // b.hs, b.nlast
    1ea8:	mov	x1, x19
    1eac:	mov	x3, x0
    1eb0:	str	d29, [x1], #8
    1eb4:	str	d28, [x0]
    1eb8:	ldr	d31, [x20]
    1ebc:	ldr	d28, [x19, #8]
    1ec0:	mov	x19, x1
    1ec4:	b	1e80 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x80>
    1ec8:	ldr	d28, [x19, #8]!
    1ecc:	fcmpe	d28, d31
    1ed0:	b.mi	1ec8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>  // b.first
    1ed4:	ldur	d29, [x3, #-8]
    1ed8:	sub	x0, x3, #0x8
    1edc:	fcmpe	d29, d31
    1ee0:	b.gt	1ee8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1ee4:	b	1ea0 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xa0>
    1ee8:	ldr	d29, [x0, #-8]!
    1eec:	fcmpe	d29, d31
    1ef0:	b.gt	1ee8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1ef4:	cmp	x19, x0
    1ef8:	b.cc	1ea8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xa8>  // b.lo, b.ul, b.last
    1efc:	mov	x0, x19
    1f00:	mov	x1, x9
    1f04:	mov	x2, x21
    1f08:	bl	1e00 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1f0c:	sub	x0, x19, x20
    1f10:	cmp	x0, #0x80
    1f14:	b.le	1f88 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x188>
    1f18:	asr	x10, x0, #3
    1f1c:	mov	x9, x19
    1f20:	asr	x0, x0, #4
    1f24:	cbnz	x21, 1e34 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x34>
    1f28:	sub	x1, x0, #0x1
    1f2c:	b	1f34 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x134>
    1f30:	sub	x1, x1, #0x1
    1f34:	ldr	d0, [x20, x1, lsl #3]
    1f38:	mov	x2, x10
    1f3c:	mov	x0, x20
    1f40:	bl	1c00 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1f44:	cbnz	x1, 1f30 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x130>
    1f48:	sub	x0, x9, x20
    1f4c:	cmp	x0, #0x8
    1f50:	b.le	1f88 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x188>
    1f54:	nop
    1f58:	nop
    1f5c:	nop
    1f60:	ldr	d0, [x9, #-8]!
    1f64:	mov	x1, #0x0                   	// #0
    1f68:	mov	x0, x20
    1f6c:	ldr	d31, [x20]
    1f70:	sub	x10, x9, x20
    1f74:	asr	x2, x10, #3
    1f78:	str	d31, [x9]
    1f7c:	bl	1c00 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1f80:	cmp	x10, #0x8
    1f84:	b.gt	1f60 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x160>
    1f88:	ldr	x21, [sp, #32]
    1f8c:	ldp	x19, x20, [sp, #16]
    1f90:	ldp	x29, x30, [sp], #48
    1f94:	ret
    1f98:	str	d0, [x20]
    1f9c:	stur	d28, [x9, #-8]
    1fa0:	ldp	d31, d28, [x20]
    1fa4:	b	1e70 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>
    1fa8:	fcmpe	d30, d0
    1fac:	b.mi	1e64 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>  // b.first
    1fb0:	fcmpe	d31, d0
    1fb4:	b.mi	1f98 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x198>  // b.first
    1fb8:	stp	d31, d28, [x20]
    1fbc:	b	1e70 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>

0000000000001fc0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>:
    1fc0:	stp	x29, x30, [sp, #-32]!
    1fc4:	lsl	x2, x0, #2
    1fc8:	mov	x29, sp
    1fcc:	mov	x1, #0x10                  	// #16
    1fd0:	add	x0, sp, #0x18
    1fd4:	str	xzr, [sp, #24]
    1fd8:	bl	f20 <posix_memalign@plt>
    1fdc:	cbnz	w0, 1fec <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]+0x2c>
    1fe0:	ldr	x0, [sp, #24]
    1fe4:	ldp	x29, x30, [sp], #32
    1fe8:	ret
    1fec:	adrp	x3, 1f000 <__abi_tag+0x1a2e8>
    1ff0:	ldr	x3, [x3, #4056]
    1ff4:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    1ff8:	mov	x2, #0x16                  	// #22
    1ffc:	add	x0, x0, #0x428
    2000:	mov	x1, #0x1                   	// #1
    2004:	ldr	x3, [x3]
    2008:	bl	ff0 <fwrite@plt>
    200c:	mov	w0, #0x1                   	// #1
    2010:	bl	fe0 <exit@plt>
    2014:	nop
    2018:	nop
    201c:	nop

0000000000002020 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    2020:	cbz	x6, 27dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    2024:	stp	x29, x30, [sp, #-160]!
    2028:	mov	x29, sp
    202c:	stp	x23, x24, [sp, #48]
    2030:	mov	x24, x4
    2034:	mov	w4, #0xaa3b                	// #43579
    2038:	movk	w4, #0x3fb8, lsl #16
    203c:	mov	x23, x3
    2040:	mov	w3, #0x7218                	// #29208
    2044:	stp	x19, x20, [sp, #16]
    2048:	mov	x20, x0
    204c:	mov	w0, #0xc2b00000            	// #-1028653056
    2050:	movk	w3, #0x3f31, lsl #16
    2054:	mov	x19, x6
    2058:	stp	d8, d9, [sp, #80]
    205c:	fmov	s9, w0
    2060:	stp	d14, d15, [sp, #128]
    2064:	fmov	s14, w4
    2068:	stp	x21, x22, [sp, #32]
    206c:	mov	x21, x1
    2070:	mov	x22, x2
    2074:	mov	w1, #0x8889                	// #34953
    2078:	mov	w2, #0xb61                 	// #2913
    207c:	movk	w2, #0x3ab6, lsl #16
    2080:	movk	w1, #0x3c08, lsl #16
    2084:	stp	x25, x26, [sp, #64]
    2088:	mov	x26, #0x0                   	// #0
    208c:	mov	x25, x5
    2090:	stp	d10, d11, [sp, #96]
    2094:	stp	d12, d13, [sp, #112]
    2098:	stp	w3, w2, [sp, #148]
    209c:	str	w1, [sp, #156]
    20a0:	ldr	s12, [x22, x26, lsl #2]
    20a4:	ldr	s15, [x24, x26, lsl #2]
    20a8:	ldr	s13, [x20, x26, lsl #2]
    20ac:	fcmp	s12, #0.0
    20b0:	ldr	s8, [x21, x26, lsl #2]
    20b4:	ldr	s11, [x23, x26, lsl #2]
    20b8:	fmul	s10, s15, s15
    20bc:	b.pl	2174 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    20c0:	fmov	s0, s12
    20c4:	bl	ec0 <sqrtf@plt>
    20c8:	fmov	s31, s0
    20cc:	fdiv	s0, s13, s8
    20d0:	fmul	s15, s15, s31
    20d4:	bl	1020 <logf@plt>
    20d8:	fmov	s31, #5.000000000000000000e-01
    20dc:	mov	w0, #0x3389                	// #13193
    20e0:	fmov	s25, #1.000000000000000000e+00
    20e4:	movk	w0, #0x3e6d, lsl #16
    20e8:	mov	w1, #0x466f                	// #18031
    20ec:	fmov	s19, #-5.000000000000000000e-01
    20f0:	mov	w4, #0x1eea                	// #7914
    20f4:	movk	w1, #0x3faa, lsl #16
    20f8:	fmov	s29, w0
    20fc:	movk	w4, #0xbfe9, lsl #16
    2100:	mov	w3, #0x778                 	// #1912
    2104:	fmadd	s10, s10, s31, s11
    2108:	movk	w3, #0x3fe4, lsl #16
    210c:	mov	w2, #0x8f89                	// #36745
    2110:	fmov	s20, w1
    2114:	movk	w2, #0xbeb6, lsl #16
    2118:	mov	w1, #0x85fa                	// #34298
    211c:	movk	w1, #0x3ea3, lsl #16
    2120:	mov	w0, #0xaa3b                	// #43579
    2124:	fmov	s22, w4
    2128:	movk	w0, #0x3fb8, lsl #16
    212c:	fmov	s23, w3
    2130:	fmadd	s0, s12, s10, s0
    2134:	fmov	s24, w2
    2138:	fmov	s31, w1
    213c:	fmov	s28, w0
    2140:	fdiv	s0, s0, s15
    2144:	fmadd	s21, s0, s29, s25
    2148:	fmul	s29, s0, s19
    214c:	fsub	s15, s0, s15
    2150:	fmul	s29, s29, s0
    2154:	fdiv	s25, s25, s21
    2158:	fmul	s28, s29, s28
    215c:	fmadd	s22, s25, s20, s22
    2160:	fmadd	s23, s22, s25, s23
    2164:	fmadd	s24, s23, s25, s24
    2168:	fmadd	s31, s24, s25, s31
    216c:	fmul	s31, s31, s25
    2170:	b	2238 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    2174:	fsqrt	s31, s12
    2178:	fdiv	s0, s13, s8
    217c:	fmul	s15, s15, s31
    2180:	bl	1020 <logf@plt>
    2184:	fmov	s29, #5.000000000000000000e-01
    2188:	fmadd	s10, s10, s29, s11
    218c:	fmadd	s0, s12, s10, s0
    2190:	fdiv	s0, s0, s15
    2194:	fcmpe	s0, #0.0
    2198:	fsub	s15, s0, s15
    219c:	b.mi	257c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    21a0:	mov	w0, #0x3389                	// #13193
    21a4:	fmov	s31, #1.000000000000000000e+00
    21a8:	mov	w4, #0x466f                	// #18031
    21ac:	movk	w0, #0x3e6d, lsl #16
    21b0:	mov	w3, #0x1eea                	// #7914
    21b4:	fmov	s29, #-5.000000000000000000e-01
    21b8:	movk	w4, #0x3faa, lsl #16
    21bc:	movk	w3, #0xbfe9, lsl #16
    21c0:	fmov	s22, w0
    21c4:	mov	w2, #0x778                 	// #1912
    21c8:	mov	w1, #0x8f89                	// #36745
    21cc:	fmov	s21, w4
    21d0:	movk	w2, #0x3fe4, lsl #16
    21d4:	movk	w1, #0xbeb6, lsl #16
    21d8:	fmov	s23, w3
    21dc:	mov	w0, #0x85fa                	// #34298
    21e0:	fmov	s24, w2
    21e4:	movk	w0, #0x3ea3, lsl #16
    21e8:	fmov	s25, w1
    21ec:	fmov	s28, w0
    21f0:	fmul	s29, s0, s29
    21f4:	fmadd	s22, s0, s22, s31
    21f8:	fmul	s29, s29, s0
    21fc:	fcmpe	s29, s9
    2200:	fdiv	s31, s31, s22
    2204:	fmadd	s23, s31, s21, s23
    2208:	fmadd	s24, s31, s23, s24
    220c:	fmadd	s25, s31, s24, s25
    2210:	fmadd	s28, s31, s25, s28
    2214:	fmul	s31, s31, s28
    2218:	b.mi	268c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    221c:	mov	w0, #0x42b00000            	// #1118830592
    2220:	fmov	s28, w0
    2224:	fcmpe	s29, s28
    2228:	b.gt	22d8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    222c:	fmul	s28, s29, s14
    2230:	fcmpe	s28, #0.0
    2234:	b.ge	26ec <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    2238:	fmov	s23, #5.000000000000000000e-01
    223c:	mov	w0, #0x7218                	// #29208
    2240:	mov	w3, #0xb61                 	// #2913
    2244:	movk	w0, #0x3f31, lsl #16
    2248:	mov	w2, #0x8889                	// #34953
    224c:	fmov	s24, #1.000000000000000000e+00
    2250:	movk	w3, #0x3ab6, lsl #16
    2254:	movk	w2, #0x3c08, lsl #16
    2258:	fmov	s25, w0
    225c:	mov	w1, #0xaaab                	// #43691
    2260:	mov	w0, #0xaaab                	// #43691
    2264:	fsub	s28, s28, s23
    2268:	movk	w1, #0x3d2a, lsl #16
    226c:	movk	w0, #0x3e2a, lsl #16
    2270:	fmov	s18, w3
    2274:	mov	w4, #0x422a                	// #16938
    2278:	fmov	s20, w2
    227c:	movk	w4, #0x3ecc, lsl #16
    2280:	fmov	s21, w1
    2284:	fmov	s22, w0
    2288:	fmov	s19, w4
    228c:	fcvtzs	s28, s28
    2290:	scvtf	s28, s28
    2294:	fmsub	s25, s28, s25, s29
    2298:	fcvtzs	w0, s28
    229c:	fmadd	s28, s25, s18, s20
    22a0:	add	w0, w0, #0x7f
    22a4:	fmov	s30, w0
    22a8:	fmadd	s28, s25, s28, s21
    22ac:	fmadd	s28, s25, s28, s22
    22b0:	shl	v29.2s, v30.2s, #23
    22b4:	fmadd	s23, s25, s28, s23
    22b8:	fmadd	s23, s25, s23, s24
    22bc:	fmadd	s24, s25, s23, s24
    22c0:	fmul	s29, s24, s29
    22c4:	fmul	s29, s29, s19
    22c8:	fcmpe	s0, #0.0
    22cc:	fmul	s31, s31, s29
    22d0:	b.mi	22f0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    22d4:	b	22e8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    22d8:	mov	w0, #0x484f                	// #18511
    22dc:	movk	w0, #0x7e46, lsl #16
    22e0:	fmov	s29, w0
    22e4:	fmul	s31, s31, s29
    22e8:	fmov	s29, #1.000000000000000000e+00
    22ec:	fsub	s31, s29, s31
    22f0:	fnmul	s30, s11, s12
    22f4:	fmul	s31, s13, s31
    22f8:	movi	v29.2s, #0x0
    22fc:	fcmpe	s30, s9
    2300:	b.mi	23a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2304:	mov	w0, #0x42b00000            	// #1118830592
    2308:	fmov	s29, w0
    230c:	fcmpe	s30, s29
    2310:	b.gt	2698 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2314:	fmul	s28, s30, s14
    2318:	fcmpe	s28, #0.0
    231c:	b.ge	26a8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    2320:	fmov	s27, #5.000000000000000000e-01
    2324:	mov	w0, #0x7218                	// #29208
    2328:	mov	w3, #0xb61                 	// #2913
    232c:	movk	w0, #0x3f31, lsl #16
    2330:	mov	w2, #0x8889                	// #34953
    2334:	fmov	s29, #1.000000000000000000e+00
    2338:	movk	w3, #0x3ab6, lsl #16
    233c:	movk	w2, #0x3c08, lsl #16
    2340:	fmov	s22, w0
    2344:	mov	w1, #0xaaab                	// #43691
    2348:	mov	w0, #0xaaab                	// #43691
    234c:	fsub	s28, s28, s27
    2350:	movk	w1, #0x3d2a, lsl #16
    2354:	movk	w0, #0x3e2a, lsl #16
    2358:	fmov	s23, w3
    235c:	fmov	s24, w2
    2360:	fmov	s25, w1
    2364:	fmov	s26, w0
    2368:	fcvtzs	s28, s28
    236c:	scvtf	s28, s28
    2370:	fmsub	s30, s28, s22, s30
    2374:	fcvtzs	w0, s28
    2378:	fmadd	s24, s30, s23, s24
    237c:	fmadd	s25, s30, s24, s25
    2380:	add	w0, w0, #0x7f
    2384:	fmov	s28, w0
    2388:	fmadd	s26, s30, s25, s26
    238c:	fmadd	s27, s30, s26, s27
    2390:	shl	v28.2s, v28.2s, #23
    2394:	fmadd	s27, s30, s27, s29
    2398:	fmadd	s29, s30, s27, s29
    239c:	fmul	s29, s29, s28
    23a0:	fcmpe	s15, #0.0
    23a4:	fmul	s29, s8, s29
    23a8:	b.mi	2604 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    23ac:	mov	w0, #0x3389                	// #13193
    23b0:	fmov	s30, #1.000000000000000000e+00
    23b4:	mov	w4, #0x466f                	// #18031
    23b8:	movk	w0, #0x3e6d, lsl #16
    23bc:	mov	w3, #0x1eea                	// #7914
    23c0:	fmov	s27, #-5.000000000000000000e-01
    23c4:	movk	w4, #0x3faa, lsl #16
    23c8:	movk	w3, #0xbfe9, lsl #16
    23cc:	fmov	s23, w0
    23d0:	mov	w2, #0x778                 	// #1912
    23d4:	mov	w1, #0x8f89                	// #36745
    23d8:	fmov	s22, w4
    23dc:	movk	w2, #0x3fe4, lsl #16
    23e0:	movk	w1, #0xbeb6, lsl #16
    23e4:	fmov	s24, w3
    23e8:	mov	w0, #0x85fa                	// #34298
    23ec:	fmov	s25, w2
    23f0:	movk	w0, #0x3ea3, lsl #16
    23f4:	fmov	s26, w1
    23f8:	fmov	s28, w0
    23fc:	fmul	s27, s15, s27
    2400:	fmadd	s23, s15, s23, s30
    2404:	fmul	s27, s27, s15
    2408:	fcmpe	s27, s9
    240c:	fdiv	s30, s30, s23
    2410:	fmadd	s24, s30, s22, s24
    2414:	fmadd	s25, s30, s24, s25
    2418:	fmadd	s26, s30, s25, s26
    241c:	fmadd	s28, s30, s26, s28
    2420:	fmul	s30, s30, s28
    2424:	b.mi	2684 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    2428:	mov	w0, #0x42b00000            	// #1118830592
    242c:	fmov	s28, w0
    2430:	fcmpe	s27, s28
    2434:	b.gt	252c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    2438:	nop
    243c:	nop
    2440:	fmul	s28, s27, s14
    2444:	fcmpe	s28, #0.0
    2448:	b.ge	2764 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    244c:	fmov	s25, #5.000000000000000000e-01
    2450:	mov	w0, #0x7218                	// #29208
    2454:	mov	w4, #0xb61                 	// #2913
    2458:	movk	w0, #0x3f31, lsl #16
    245c:	mov	w2, #0x8889                	// #34953
    2460:	fmov	s26, #1.000000000000000000e+00
    2464:	movk	w4, #0x3ab6, lsl #16
    2468:	movk	w2, #0x3c08, lsl #16
    246c:	fmov	s19, w0
    2470:	mov	w1, #0xaaab                	// #43691
    2474:	mov	w0, #0xaaab                	// #43691
    2478:	fsub	s28, s28, s25
    247c:	movk	w1, #0x3d2a, lsl #16
    2480:	movk	w0, #0x3e2a, lsl #16
    2484:	fmov	s20, w4
    2488:	mov	w3, #0x422a                	// #16938
    248c:	fmov	s22, w2
    2490:	movk	w3, #0x3ecc, lsl #16
    2494:	fmov	s23, w1
    2498:	fmov	s24, w0
    249c:	fmov	s21, w3
    24a0:	fcvtzs	s28, s28
    24a4:	scvtf	s28, s28
    24a8:	fmsub	s27, s28, s19, s27
    24ac:	fcvtzs	w0, s28
    24b0:	fmadd	s22, s27, s20, s22
    24b4:	add	w0, w0, #0x7f
    24b8:	fmov	s28, w0
    24bc:	fmadd	s23, s27, s22, s23
    24c0:	fmadd	s24, s27, s23, s24
    24c4:	shl	v28.2s, v28.2s, #23
    24c8:	fmadd	s25, s27, s24, s25
    24cc:	fmadd	s25, s27, s25, s26
    24d0:	fmadd	s26, s27, s25, s26
    24d4:	fmul	s28, s26, s28
    24d8:	fmul	s28, s28, s21
    24dc:	fcmpe	s15, #0.0
    24e0:	fmul	s30, s30, s28
    24e4:	b.mi	2564 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    24e8:	fmov	s28, #1.000000000000000000e+00
    24ec:	fsub	s30, s28, s30
    24f0:	fmsub	s31, s29, s30, s31
    24f4:	str	s31, [x25, x26, lsl #2]
    24f8:	add	x26, x26, #0x1
    24fc:	cmp	x26, x19
    2500:	b.ne	20a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2504:	ldp	d8, d9, [sp, #80]
    2508:	ldp	x19, x20, [sp, #16]
    250c:	ldp	x21, x22, [sp, #32]
    2510:	ldp	x23, x24, [sp, #48]
    2514:	ldp	x25, x26, [sp, #64]
    2518:	ldp	d10, d11, [sp, #96]
    251c:	ldp	d12, d13, [sp, #112]
    2520:	ldp	d14, d15, [sp, #128]
    2524:	ldp	x29, x30, [sp], #160
    2528:	ret
    252c:	mov	w0, #0x484f                	// #18511
    2530:	movk	w0, #0x7e46, lsl #16
    2534:	fmov	s28, w0
    2538:	fmul	s30, s30, s28
    253c:	fmov	s28, #1.000000000000000000e+00
    2540:	fsub	s30, s28, s30
    2544:	fmsub	s31, s29, s30, s31
    2548:	str	s31, [x25, x26, lsl #2]
    254c:	add	x26, x26, #0x1
    2550:	cmp	x26, x19
    2554:	b.ne	20a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2558:	b	2504 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    255c:	movi	v28.2s, #0x0
    2560:	fmul	s30, s30, s28
    2564:	fmsub	s30, s29, s30, s31
    2568:	str	s30, [x25, x26, lsl #2]
    256c:	add	x26, x26, #0x1
    2570:	cmp	x19, x26
    2574:	b.ne	20a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2578:	b	2504 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    257c:	mov	w0, #0x3389                	// #13193
    2580:	fmov	s31, #1.000000000000000000e+00
    2584:	mov	w4, #0x466f                	// #18031
    2588:	movk	w0, #0x3e6d, lsl #16
    258c:	mov	w3, #0x1eea                	// #7914
    2590:	fmul	s29, s0, s29
    2594:	movk	w4, #0x3faa, lsl #16
    2598:	movk	w3, #0xbfe9, lsl #16
    259c:	fmov	s22, w0
    25a0:	mov	w2, #0x778                 	// #1912
    25a4:	mov	w1, #0x8f89                	// #36745
    25a8:	fmov	s21, w4
    25ac:	movk	w2, #0x3fe4, lsl #16
    25b0:	movk	w1, #0xbeb6, lsl #16
    25b4:	fmov	s23, w3
    25b8:	mov	w0, #0x85fa                	// #34298
    25bc:	fmov	s24, w2
    25c0:	movk	w0, #0x3ea3, lsl #16
    25c4:	fmov	s25, w1
    25c8:	fmov	s28, w0
    25cc:	fnmul	s29, s0, s29
    25d0:	fmsub	s22, s0, s22, s31
    25d4:	fcmpe	s29, s9
    25d8:	fdiv	s31, s31, s22
    25dc:	fmadd	s23, s31, s21, s23
    25e0:	fmadd	s24, s31, s23, s24
    25e4:	fmadd	s25, s31, s24, s25
    25e8:	fmadd	s28, s31, s25, s28
    25ec:	fmul	s31, s31, s28
    25f0:	b.mi	25f8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    25f4:	b	222c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    25f8:	movi	v29.2s, #0x0
    25fc:	fmul	s31, s31, s29
    2600:	b	22f0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2604:	mov	w0, #0x3389                	// #13193
    2608:	fmov	s30, #1.000000000000000000e+00
    260c:	mov	w4, #0x466f                	// #18031
    2610:	movk	w0, #0x3e6d, lsl #16
    2614:	mov	w3, #0x1eea                	// #7914
    2618:	fmov	s27, #5.000000000000000000e-01
    261c:	movk	w4, #0x3faa, lsl #16
    2620:	movk	w3, #0xbfe9, lsl #16
    2624:	fmov	s23, w0
    2628:	mov	w2, #0x778                 	// #1912
    262c:	mov	w1, #0x8f89                	// #36745
    2630:	fmov	s22, w4
    2634:	movk	w2, #0x3fe4, lsl #16
    2638:	movk	w1, #0xbeb6, lsl #16
    263c:	fmov	s24, w3
    2640:	mov	w0, #0x85fa                	// #34298
    2644:	fmov	s25, w2
    2648:	movk	w0, #0x3ea3, lsl #16
    264c:	fmov	s26, w1
    2650:	fmov	s28, w0
    2654:	fmul	s27, s15, s27
    2658:	fmsub	s23, s15, s23, s30
    265c:	fnmul	s27, s15, s27
    2660:	fcmpe	s27, s9
    2664:	fdiv	s30, s30, s23
    2668:	fmadd	s24, s30, s22, s24
    266c:	fmadd	s25, s24, s30, s25
    2670:	fmadd	s26, s25, s30, s26
    2674:	fmadd	s28, s30, s26, s28
    2678:	fmul	s30, s30, s28
    267c:	b.mi	255c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2680:	b	2440 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2684:	movi	v28.2s, #0x0
    2688:	b	2538 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    268c:	movi	v29.2s, #0x0
    2690:	fmul	s31, s31, s29
    2694:	b	22e8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2698:	mov	w7, #0x829c                	// #33436
    269c:	movk	w7, #0x7ef8, lsl #16
    26a0:	fmov	s29, w7
    26a4:	b	23a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    26a8:	fmov	s27, #5.000000000000000000e-01
    26ac:	ldr	s24, [sp, #148]
    26b0:	mov	w0, #0xaaab                	// #43691
    26b4:	movk	w0, #0x3e2a, lsl #16
    26b8:	mov	w1, #0xaaab                	// #43691
    26bc:	fmov	s29, #1.000000000000000000e+00
    26c0:	movk	w1, #0x3d2a, lsl #16
    26c4:	fmov	s26, w0
    26c8:	fadd	s28, s28, s27
    26cc:	fmov	s25, w1
    26d0:	fcvtzs	s28, s28
    26d4:	scvtf	s28, s28
    26d8:	fmsub	s30, s28, s24, s30
    26dc:	fcvtzs	w0, s28
    26e0:	ldp	s24, s28, [sp, #152]
    26e4:	fmadd	s24, s30, s24, s28
    26e8:	b	237c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    26ec:	fmov	s24, #5.000000000000000000e-01
    26f0:	ldr	s30, [sp, #148]
    26f4:	mov	w1, #0xaaab                	// #43691
    26f8:	movk	w1, #0x3d2a, lsl #16
    26fc:	mov	w0, #0xaaab                	// #43691
    2700:	fmov	s25, #1.000000000000000000e+00
    2704:	movk	w0, #0x3e2a, lsl #16
    2708:	mov	w2, #0x422a                	// #16938
    270c:	fmov	s22, w1
    2710:	movk	w2, #0x3ecc, lsl #16
    2714:	fadd	s28, s28, s24
    2718:	fmov	s23, w0
    271c:	fmov	s21, w2
    2720:	fcvtzs	s28, s28
    2724:	scvtf	s28, s28
    2728:	fmsub	s29, s28, s30, s29
    272c:	fcvtzs	w7, s28
    2730:	ldp	s28, s30, [sp, #152]
    2734:	fmadd	s20, s29, s28, s30
    2738:	add	w7, w7, #0x7f
    273c:	fmov	s30, w7
    2740:	fmadd	s22, s29, s20, s22
    2744:	fmadd	s23, s29, s22, s23
    2748:	shl	v28.2s, v30.2s, #23
    274c:	fmadd	s24, s29, s23, s24
    2750:	fmadd	s24, s29, s24, s25
    2754:	fmadd	s29, s29, s24, s25
    2758:	fmul	s29, s29, s28
    275c:	fmul	s29, s29, s21
    2760:	b	22c8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    2764:	fmov	s25, #5.000000000000000000e-01
    2768:	ldr	s21, [sp, #148]
    276c:	mov	w0, #0xaaab                	// #43691
    2770:	movk	w0, #0x3e2a, lsl #16
    2774:	mov	w1, #0xaaab                	// #43691
    2778:	fmov	s26, #1.000000000000000000e+00
    277c:	movk	w1, #0x3d2a, lsl #16
    2780:	mov	w2, #0x422a                	// #16938
    2784:	fmov	s24, w0
    2788:	movk	w2, #0x3ecc, lsl #16
    278c:	fadd	s28, s28, s25
    2790:	fmov	s23, w1
    2794:	fmov	s22, w2
    2798:	fcvtzs	s28, s28
    279c:	scvtf	s28, s28
    27a0:	fmsub	s27, s28, s21, s27
    27a4:	fcvtzs	w0, s28
    27a8:	ldp	s21, s28, [sp, #152]
    27ac:	fmadd	s21, s27, s21, s28
    27b0:	add	w0, w0, #0x7f
    27b4:	fmov	s28, w0
    27b8:	fmadd	s23, s27, s21, s23
    27bc:	fmadd	s24, s27, s23, s24
    27c0:	shl	v28.2s, v28.2s, #23
    27c4:	fmadd	s25, s27, s24, s25
    27c8:	fmadd	s25, s27, s25, s26
    27cc:	fmadd	s26, s27, s25, s26
    27d0:	fmul	s28, s26, s28
    27d4:	fmul	s28, s28, s22
    27d8:	b	24dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    27dc:	ret

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

0000000000002fa0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    2fa0:	cbz	x6, 369c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6fc>
    2fa4:	mov	w10, #0x4f3                 	// #1267
    2fa8:	mov	w9, #0x21bb                	// #8635
    2fac:	stp	x29, x30, [sp, #-144]!
    2fb0:	movk	w10, #0x3fb5, lsl #16
    2fb4:	movk	w9, #0x3d90, lsl #16
    2fb8:	mov	x29, sp
    2fbc:	mov	w15, #0x251a                	// #9498
    2fc0:	mov	w14, #0x5d4f                	// #23887
    2fc4:	mov	w13, #0xe9bf                	// #59839
    2fc8:	stp	d14, d15, [sp, #80]
    2fcc:	mov	w12, #0xae50                	// #44624
    2fd0:	fmov	s15, w10
    2fd4:	mov	w11, #0xceac                	// #52908
    2fd8:	mov	w10, #0xfffc                	// #65532
    2fdc:	movk	w15, #0x3def, lsl #16
    2fe0:	fmov	s0, w9
    2fe4:	movk	w14, #0xbdfe, lsl #16
    2fe8:	movk	w13, #0x3e11, lsl #16
    2fec:	stp	x19, x20, [sp, #16]
    2ff0:	movk	w12, #0xbe2a, lsl #16
    2ff4:	movk	w11, #0x3e4c, lsl #16
    2ff8:	movk	w10, #0xbe7f, lsl #16
    2ffc:	mov	w9, #0xaaaa                	// #43690
    3000:	movk	w9, #0x3eaa, lsl #16
    3004:	fmov	s2, w15
    3008:	mov	w20, #0xaa3b                	// #43579
    300c:	fmov	s3, w14
    3010:	mov	w15, #0x3389                	// #13193
    3014:	mov	w14, #0x466f                	// #18031
    3018:	fmov	s4, w13
    301c:	mov	w13, #0x1eea                	// #7914
    3020:	movk	w20, #0x3fb8, lsl #16
    3024:	fmov	s5, w12
    3028:	mov	w12, #0x778                 	// #1912
    302c:	movk	w15, #0x3e6d, lsl #16
    3030:	stp	d8, d9, [sp, #32]
    3034:	movk	w14, #0x3faa, lsl #16
    3038:	movk	w13, #0xbfe9, lsl #16
    303c:	fmov	s8, w11
    3040:	mov	w11, #0x8f89                	// #36745
    3044:	movk	w12, #0x3fe4, lsl #16
    3048:	fmov	s9, w10
    304c:	mov	w10, #0x85fa                	// #34298
    3050:	movk	w11, #0xbeb6, lsl #16
    3054:	movk	w10, #0x3ea3, lsl #16
    3058:	stp	d10, d11, [sp, #48]
    305c:	mov	w8, #0xd1b8                	// #53688
    3060:	fmov	s10, w9
    3064:	mov	w9, #0xc2b00000            	// #-1028653056
    3068:	movk	w8, #0xbdeb, lsl #16
    306c:	fmov	s11, w20
    3070:	mov	w19, #0xb61                 	// #2913
    3074:	mov	w30, #0x8889                	// #34953
    3078:	fmov	s7, w15
    307c:	mov	w18, #0xaaab                	// #43691
    3080:	mov	w17, #0xaaab                	// #43691
    3084:	fmov	s16, w14
    3088:	mov	w16, #0x422a                	// #16938
    308c:	movk	w19, #0x3ab6, lsl #16
    3090:	fmov	s17, w13
    3094:	movk	w30, #0x3c08, lsl #16
    3098:	movk	w18, #0x3d2a, lsl #16
    309c:	fmov	s18, w12
    30a0:	movk	w17, #0x3e2a, lsl #16
    30a4:	movk	w16, #0x3ecc, lsl #16
    30a8:	fmov	s19, w11
    30ac:	mov	x7, #0x0                   	// #0
    30b0:	fmov	s20, w10
    30b4:	fmov	s24, w9
    30b8:	fmov	s1, w8
    30bc:	mov	w8, #0x7218                	// #29208
    30c0:	movk	w8, #0x3f31, lsl #16
    30c4:	stp	d12, d13, [sp, #64]
    30c8:	stp	w30, w18, [sp, #116]
    30cc:	fmov	s6, w8
    30d0:	mov	w8, #0x484f                	// #18511
    30d4:	movk	w8, #0x7e46, lsl #16
    30d8:	stp	w17, w16, [sp, #124]
    30dc:	stp	w8, w19, [sp, #108]
    30e0:	ldr	s26, [x0, x7, lsl #2]
    30e4:	ldr	s25, [x1, x7, lsl #2]
    30e8:	ldr	s27, [x2, x7, lsl #2]
    30ec:	ldr	s29, [x4, x7, lsl #2]
    30f0:	fdiv	s31, s26, s25
    30f4:	ldr	s23, [x3, x7, lsl #2]
    30f8:	fmul	s21, s29, s29
    30fc:	fmov	w8, s31
    3100:	dup	v31.2s, v27.s[0]
    3104:	fsqrt	v31.2s, v31.2s
    3108:	and	w9, w8, #0x7fffff
    310c:	ubfx	x8, x8, #23, #8
    3110:	orr	w9, w9, #0x3f800000
    3114:	fmul	s29, s29, s31
    3118:	fmov	s31, w9
    311c:	fcmpe	s31, s15
    3120:	b.ge	34fc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.tcont
    3124:	sub	w8, w8, #0x7f
    3128:	fmov	s30, #1.000000000000000000e+00
    312c:	fmov	s28, #5.000000000000000000e-01
    3130:	scvtf	s14, w8
    3134:	fsub	s31, s31, s30
    3138:	fmadd	s21, s21, s28, s23
    313c:	fmadd	s22, s31, s0, s1
    3140:	fmul	s12, s31, s31
    3144:	fmadd	s22, s31, s22, s2
    3148:	fmul	s13, s12, s28
    314c:	fmadd	s22, s31, s22, s3
    3150:	fmadd	s22, s31, s22, s4
    3154:	fmadd	s22, s31, s22, s5
    3158:	fmadd	s22, s31, s22, s8
    315c:	fmadd	s22, s31, s22, s9
    3160:	fmadd	s22, s31, s22, s10
    3164:	fmul	s22, s22, s12
    3168:	fnmsub	s13, s31, s22, s13
    316c:	fadd	s31, s31, s13
    3170:	fmadd	s31, s14, s6, s31
    3174:	fmadd	s31, s27, s21, s31
    3178:	fdiv	s31, s31, s29
    317c:	fcmpe	s31, #0.0
    3180:	fsub	s29, s31, s29
    3184:	b.mi	3544 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5a4>  // b.first
    3188:	fmadd	s22, s31, s7, s30
    318c:	fmov	s28, #-5.000000000000000000e-01
    3190:	fmul	s28, s31, s28
    3194:	fdiv	s30, s30, s22
    3198:	fmul	s28, s28, s31
    319c:	fcmpe	s28, s24
    31a0:	fmadd	s22, s30, s16, s17
    31a4:	fmadd	s22, s30, s22, s18
    31a8:	fmadd	s22, s30, s22, s19
    31ac:	fmadd	s22, s30, s22, s20
    31b0:	fmul	s30, s30, s22
    31b4:	b.mi	3284 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2e4>  // b.first
    31b8:	mov	w8, #0x42b00000            	// #1118830592
    31bc:	ldr	s21, [sp, #108]
    31c0:	fmov	s22, w8
    31c4:	fcmpe	s28, s22
    31c8:	b.gt	3288 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2e8>
    31cc:	fmul	s22, s28, s11
    31d0:	fcmpe	s22, #0.0
    31d4:	b.ge	3640 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6a0>  // b.tcont
    31d8:	fmov	s21, #5.000000000000000000e-01
    31dc:	mov	w8, #0x7218                	// #29208
    31e0:	mov	w12, #0xb61                 	// #2913
    31e4:	movk	w8, #0x3f31, lsl #16
    31e8:	mov	w11, #0x8889                	// #34953
    31ec:	fmov	s12, #1.000000000000000000e+00
    31f0:	movk	w12, #0x3ab6, lsl #16
    31f4:	movk	w11, #0x3c08, lsl #16
    31f8:	fmov	s13, w8
    31fc:	mov	w8, #0x422a                	// #16938
    3200:	mov	w10, #0xaaab                	// #43691
    3204:	fsub	s22, s22, s21
    3208:	movk	w8, #0x3ecc, lsl #16
    320c:	movk	w10, #0x3d2a, lsl #16
    3210:	mov	w9, #0xaaab                	// #43691
    3214:	stp	w12, w11, [sp, #132]
    3218:	str	w8, [sp, #140]
    321c:	movk	w9, #0x3e2a, lsl #16
    3220:	fmov	s14, w10
    3224:	fmov	s21, w9
    3228:	fcvtzs	s22, s22
    322c:	scvtf	s22, s22
    3230:	fmsub	s28, s22, s13, s28
    3234:	fcvtzs	w8, s22
    3238:	fmov	s13, w11
    323c:	fmov	s22, w12
    3240:	add	w8, w8, #0x7f
    3244:	fmadd	s13, s28, s22, s13
    3248:	fmov	s22, w8
    324c:	fmadd	s14, s28, s13, s14
    3250:	shl	v22.2s, v22.2s, #23
    3254:	fmadd	s21, s28, s14, s21
    3258:	fmov	s14, #5.000000000000000000e-01
    325c:	fmadd	s21, s28, s21, s14
    3260:	fmadd	s21, s28, s21, s12
    3264:	fmadd	s28, s28, s21, s12
    3268:	fmul	s28, s28, s22
    326c:	ldr	s22, [sp, #140]
    3270:	fmul	s28, s28, s22
    3274:	fcmpe	s31, #0.0
    3278:	fmul	s30, s30, s28
    327c:	b.mi	3294 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2f4>  // b.first
    3280:	b	328c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2ec>
    3284:	movi	v21.2s, #0x0
    3288:	fmul	s30, s30, s21
    328c:	fmov	s31, #1.000000000000000000e+00
    3290:	fsub	s30, s31, s30
    3294:	fnmul	s27, s23, s27
    3298:	fmul	s30, s26, s30
    329c:	movi	v31.2s, #0x0
    32a0:	fcmpe	s27, s24
    32a4:	b.mi	3344 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a4>  // b.first
    32a8:	mov	w8, #0x42b00000            	// #1118830592
    32ac:	fmov	s31, w8
    32b0:	fcmpe	s27, s31
    32b4:	b.gt	3580 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e0>
    32b8:	fmul	s28, s27, s11
    32bc:	fcmpe	s28, #0.0
    32c0:	b.ge	3590 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5f0>  // b.tcont
    32c4:	fmov	s23, #5.000000000000000000e-01
    32c8:	mov	w8, #0x7218                	// #29208
    32cc:	mov	w11, #0xb61                 	// #2913
    32d0:	movk	w8, #0x3f31, lsl #16
    32d4:	mov	w10, #0x8889                	// #34953
    32d8:	fmov	s31, #1.000000000000000000e+00
    32dc:	movk	w11, #0x3ab6, lsl #16
    32e0:	movk	w10, #0x3c08, lsl #16
    32e4:	fmov	s26, w8
    32e8:	mov	w9, #0xaaab                	// #43691
    32ec:	mov	w8, #0xaaab                	// #43691
    32f0:	fsub	s28, s28, s23
    32f4:	movk	w9, #0x3d2a, lsl #16
    32f8:	movk	w8, #0x3e2a, lsl #16
    32fc:	fmov	s21, w11
    3300:	fmov	s14, w10
    3304:	fmov	s22, w9
    3308:	fmov	s13, w8
    330c:	fcvtzs	s28, s28
    3310:	scvtf	s28, s28
    3314:	fmsub	s26, s28, s26, s27
    3318:	fcvtzs	w8, s28
    331c:	fmadd	s14, s26, s21, s14
    3320:	add	w8, w8, #0x7f
    3324:	fmov	s28, w8
    3328:	fmadd	s22, s26, s14, s22
    332c:	fmadd	s13, s26, s22, s13
    3330:	shl	v28.2s, v28.2s, #23
    3334:	fmadd	s23, s26, s13, s23
    3338:	fmadd	s23, s26, s23, s31
    333c:	fmadd	s31, s26, s23, s31
    3340:	fmul	s31, s31, s28
    3344:	fcmpe	s29, #0.0
    3348:	fmul	s27, s25, s31
    334c:	b.mi	350c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x56c>  // b.first
    3350:	fmov	s31, #1.000000000000000000e+00
    3354:	fmov	s28, #-5.000000000000000000e-01
    3358:	fmadd	s26, s29, s7, s31
    335c:	fmul	s28, s29, s28
    3360:	fmul	s28, s28, s29
    3364:	fdiv	s31, s31, s26
    3368:	fcmpe	s28, s24
    336c:	fmadd	s26, s31, s16, s17
    3370:	fmadd	s26, s31, s26, s18
    3374:	fmadd	s26, s31, s26, s19
    3378:	fmadd	s26, s31, s26, s20
    337c:	fmul	s31, s31, s26
    3380:	b.mi	3484 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>  // b.first
    3384:	mov	w8, #0x42b00000            	// #1118830592
    3388:	ldr	s25, [sp, #108]
    338c:	fmov	s26, w8
    3390:	fcmpe	s28, s26
    3394:	b.gt	3488 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e8>
    3398:	nop
    339c:	nop
    33a0:	fmul	s26, s28, s11
    33a4:	fcmpe	s26, #0.0
    33a8:	b.ge	35e4 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x644>  // b.tcont
    33ac:	fmov	s23, #5.000000000000000000e-01
    33b0:	mov	w8, #0x7218                	// #29208
    33b4:	mov	w12, #0xb61                 	// #2913
    33b8:	movk	w8, #0x3f31, lsl #16
    33bc:	mov	w11, #0x8889                	// #34953
    33c0:	fmov	s13, #1.000000000000000000e+00
    33c4:	movk	w12, #0x3ab6, lsl #16
    33c8:	movk	w11, #0x3c08, lsl #16
    33cc:	fmov	s25, w8
    33d0:	mov	w10, #0xaaab                	// #43691
    33d4:	mov	w9, #0xaaab                	// #43691
    33d8:	fsub	s26, s26, s23
    33dc:	movk	w10, #0x3d2a, lsl #16
    33e0:	movk	w9, #0x3e2a, lsl #16
    33e4:	fmov	s12, w12
    33e8:	mov	w8, #0x422a                	// #16938
    33ec:	fmov	s14, w11
    33f0:	movk	w8, #0x3ecc, lsl #16
    33f4:	fmov	s21, w10
    33f8:	fmov	s22, w9
    33fc:	str	w8, [sp, #132]
    3400:	fcvtzs	s26, s26
    3404:	scvtf	s26, s26
    3408:	fmsub	s25, s26, s25, s28
    340c:	fcvtzs	w8, s26
    3410:	fmadd	s14, s25, s12, s14
    3414:	add	w8, w8, #0x7f
    3418:	fmov	s28, w8
    341c:	fmadd	s21, s25, s14, s21
    3420:	fmadd	s22, s25, s21, s22
    3424:	shl	v26.2s, v28.2s, #23
    3428:	fmadd	s23, s25, s22, s23
    342c:	fmadd	s23, s25, s23, s13
    3430:	fmadd	s28, s25, s23, s13
    3434:	fmul	s28, s28, s26
    3438:	ldr	s26, [sp, #132]
    343c:	fmul	s28, s28, s26
    3440:	fcmpe	s29, #0.0
    3444:	fmul	s31, s31, s28
    3448:	b.mi	34cc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x52c>  // b.first
    344c:	fmov	s29, #1.000000000000000000e+00
    3450:	fsub	s31, s29, s31
    3454:	fmsub	s31, s27, s31, s30
    3458:	str	s31, [x5, x7, lsl #2]
    345c:	add	x7, x7, #0x1
    3460:	cmp	x7, x6
    3464:	b.ne	30e0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x140>  // b.any
    3468:	ldp	d8, d9, [sp, #32]
    346c:	ldp	x19, x20, [sp, #16]
    3470:	ldp	d10, d11, [sp, #48]
    3474:	ldp	d12, d13, [sp, #64]
    3478:	ldp	d14, d15, [sp, #80]
    347c:	ldp	x29, x30, [sp], #144
    3480:	ret
    3484:	movi	v25.2s, #0x0
    3488:	fmul	s31, s31, s25
    348c:	fmov	s29, #1.000000000000000000e+00
    3490:	fsub	s31, s29, s31
    3494:	fmsub	s31, s27, s31, s30
    3498:	str	s31, [x5, x7, lsl #2]
    349c:	add	x7, x7, #0x1
    34a0:	cmp	x7, x6
    34a4:	b.ne	30e0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x140>  // b.any
    34a8:	ldp	d8, d9, [sp, #32]
    34ac:	ldp	x19, x20, [sp, #16]
    34b0:	ldp	d10, d11, [sp, #48]
    34b4:	ldp	d12, d13, [sp, #64]
    34b8:	ldp	d14, d15, [sp, #80]
    34bc:	ldp	x29, x30, [sp], #144
    34c0:	ret
    34c4:	movi	v29.2s, #0x0
    34c8:	fmul	s31, s31, s29
    34cc:	fmsub	s31, s27, s31, s30
    34d0:	str	s31, [x5, x7, lsl #2]
    34d4:	add	x7, x7, #0x1
    34d8:	cmp	x6, x7
    34dc:	b.ne	30e0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x140>  // b.any
    34e0:	ldp	d8, d9, [sp, #32]
    34e4:	ldp	x19, x20, [sp, #16]
    34e8:	ldp	d10, d11, [sp, #48]
    34ec:	ldp	d12, d13, [sp, #64]
    34f0:	ldp	d14, d15, [sp, #80]
    34f4:	ldp	x29, x30, [sp], #144
    34f8:	ret
    34fc:	fmov	s30, #5.000000000000000000e-01
    3500:	sub	w8, w8, #0x7e
    3504:	fmul	s31, s31, s30
    3508:	b	3128 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x188>
    350c:	fmov	s26, #1.000000000000000000e+00
    3510:	fmov	s28, #5.000000000000000000e-01
    3514:	fmsub	s31, s29, s7, s26
    3518:	fmul	s28, s29, s28
    351c:	fnmul	s28, s29, s28
    3520:	fdiv	s26, s26, s31
    3524:	fcmpe	s28, s24
    3528:	fmadd	s31, s26, s16, s17
    352c:	fmadd	s31, s31, s26, s18
    3530:	fmadd	s31, s31, s26, s19
    3534:	fmadd	s31, s31, s26, s20
    3538:	fmul	s31, s31, s26
    353c:	b.mi	34c4 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x524>  // b.first
    3540:	b	33a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x400>
    3544:	fmsub	s22, s31, s7, s30
    3548:	fmul	s28, s31, s28
    354c:	fnmul	s28, s31, s28
    3550:	fdiv	s22, s30, s22
    3554:	fcmpe	s28, s24
    3558:	fmadd	s30, s22, s16, s17
    355c:	fmadd	s30, s22, s30, s18
    3560:	fmadd	s30, s22, s30, s19
    3564:	fmadd	s30, s22, s30, s20
    3568:	fmul	s30, s22, s30
    356c:	b.mi	3574 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d4>  // b.first
    3570:	b	31cc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x22c>
    3574:	movi	v31.2s, #0x0
    3578:	fmul	s30, s30, s31
    357c:	b	3294 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2f4>
    3580:	mov	w8, #0x829c                	// #33436
    3584:	movk	w8, #0x7ef8, lsl #16
    3588:	fmov	s31, w8
    358c:	b	3344 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a4>
    3590:	fmov	s26, #5.000000000000000000e-01
    3594:	ldr	s22, [sp, #120]
    3598:	fmov	s31, #1.000000000000000000e+00
    359c:	fadd	s28, s28, s26
    35a0:	fcvtzs	s28, s28
    35a4:	scvtf	s28, s28
    35a8:	fmsub	s27, s28, s6, s27
    35ac:	fcvtzs	w8, s28
    35b0:	ldp	s23, s28, [sp, #112]
    35b4:	fmadd	s28, s27, s23, s28
    35b8:	add	w8, w8, #0x7f
    35bc:	fmov	s23, w8
    35c0:	fmadd	s28, s27, s28, s22
    35c4:	ldr	s22, [sp, #124]
    35c8:	fmadd	s28, s27, s28, s22
    35cc:	shl	v23.2s, v23.2s, #23
    35d0:	fmadd	s26, s27, s28, s26
    35d4:	fmadd	s26, s27, s26, s31
    35d8:	fmadd	s31, s27, s26, s31
    35dc:	fmul	s31, s31, s23
    35e0:	b	3344 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a4>
    35e4:	fmov	s23, #5.000000000000000000e-01
    35e8:	ldr	s21, [sp, #120]
    35ec:	fmov	s25, #1.000000000000000000e+00
    35f0:	fadd	s26, s26, s23
    35f4:	fcvtzs	s26, s26
    35f8:	scvtf	s26, s26
    35fc:	fmsub	s28, s26, s6, s28
    3600:	fcvtzs	w8, s26
    3604:	ldp	s22, s26, [sp, #112]
    3608:	fmadd	s26, s28, s22, s26
    360c:	add	w8, w8, #0x7f
    3610:	fmov	s22, w8
    3614:	fmadd	s26, s28, s26, s21
    3618:	ldr	s21, [sp, #124]
    361c:	fmadd	s26, s28, s26, s21
    3620:	shl	v22.2s, v22.2s, #23
    3624:	fmadd	s23, s28, s26, s23
    3628:	ldr	s26, [sp, #128]
    362c:	fmadd	s23, s28, s23, s25
    3630:	fmadd	s28, s28, s23, s25
    3634:	fmul	s28, s28, s22
    3638:	fmul	s28, s28, s26
    363c:	b	3440 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4a0>
    3640:	fmov	s14, #5.000000000000000000e-01
    3644:	ldr	s12, [sp, #120]
    3648:	fmov	s21, #1.000000000000000000e+00
    364c:	fadd	s22, s22, s14
    3650:	fcvtzs	s22, s22
    3654:	scvtf	s22, s22
    3658:	fmsub	s28, s22, s6, s28
    365c:	fcvtzs	w8, s22
    3660:	ldp	s13, s22, [sp, #112]
    3664:	fmadd	s13, s28, s13, s22
    3668:	add	w8, w8, #0x7f
    366c:	fmov	s22, w8
    3670:	fmadd	s13, s28, s13, s12
    3674:	ldr	s12, [sp, #124]
    3678:	fmadd	s13, s28, s13, s12
    367c:	shl	v22.2s, v22.2s, #23
    3680:	fmadd	s14, s28, s13, s14
    3684:	fmadd	s14, s28, s14, s21
    3688:	fmadd	s28, s28, s14, s21
    368c:	fmul	s28, s28, s22
    3690:	ldr	s22, [sp, #128]
    3694:	fmul	s28, s28, s22
    3698:	b	3274 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d4>
    369c:	ret

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

00000000000041e0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>:
    41e0:	stp	x29, x30, [sp, #-64]!
    41e4:	mov	x29, sp
    41e8:	stp	x21, x22, [sp, #32]
    41ec:	add	x22, x0, #0x10
    41f0:	stp	x19, x20, [sp, #16]
    41f4:	str	x22, [x0]
    41f8:	cbz	x1, 42b0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0xd0>
    41fc:	mov	x20, x0
    4200:	mov	x0, x1
    4204:	mov	x21, x1
    4208:	bl	e80 <strlen@plt>
    420c:	str	x0, [sp, #56]
    4210:	mov	x19, x0
    4214:	cmp	x0, #0xf
    4218:	b.hi	4260 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0x80>  // b.pmore
    421c:	cmp	x0, #0x1
    4220:	b.ne	4244 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0x64>  // b.any
    4224:	ldrb	w0, [x21]
    4228:	str	x19, [x20, #8]
    422c:	strb	w0, [x20, #16]
    4230:	strb	wzr, [x22, x19]
    4234:	ldp	x19, x20, [sp, #16]
    4238:	ldp	x21, x22, [sp, #32]
    423c:	ldp	x29, x30, [sp], #64
    4240:	ret
    4244:	cbnz	x0, 4280 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0xa0>
    4248:	str	x19, [x20, #8]
    424c:	strb	wzr, [x22, x19]
    4250:	ldp	x19, x20, [sp, #16]
    4254:	ldp	x21, x22, [sp, #32]
    4258:	ldp	x29, x30, [sp], #64
    425c:	ret
    4260:	add	x1, sp, #0x38
    4264:	mov	x2, #0x0                   	// #0
    4268:	mov	x0, x20
    426c:	bl	1010 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long)@plt>
    4270:	ldr	x1, [sp, #56]
    4274:	mov	x22, x0
    4278:	str	x0, [x20]
    427c:	str	x1, [x20, #16]
    4280:	mov	x2, x19
    4284:	mov	x1, x21
    4288:	mov	x0, x22
    428c:	bl	e70 <memcpy@plt>
    4290:	ldr	x19, [sp, #56]
    4294:	ldr	x22, [x20]
    4298:	str	x19, [x20, #8]
    429c:	strb	wzr, [x22, x19]
    42a0:	ldp	x19, x20, [sp, #16]
    42a4:	ldp	x21, x22, [sp, #32]
    42a8:	ldp	x29, x30, [sp], #64
    42ac:	ret
    42b0:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x960>
    42b4:	add	x0, x0, #0x5d8
    42b8:	bl	f00 <std::__throw_logic_error(char const*)@plt>
    42bc:	nop

00000000000042c0 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>:
    42c0:	stp	x29, x30, [sp, #-48]!
    42c4:	mov	x29, sp
    42c8:	stp	x19, x20, [sp, #16]
    42cc:	mov	x20, x0
    42d0:	mov	x0, x1
    42d4:	mov	x19, x1
    42d8:	str	x21, [sp, #32]
    42dc:	ldr	x21, [x20, #8]
    42e0:	bl	e80 <strlen@plt>
    42e4:	cmp	x21, x0
    42e8:	b.eq	4300 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)+0x40>  // b.none
    42ec:	mov	w0, #0x0                   	// #0
    42f0:	ldr	x21, [sp, #32]
    42f4:	ldp	x19, x20, [sp, #16]
    42f8:	ldp	x29, x30, [sp], #48
    42fc:	ret
    4300:	mov	w0, #0x1                   	// #1
    4304:	cbz	x21, 42f0 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)+0x30>
    4308:	ldr	x0, [x20]
    430c:	mov	x2, x21
    4310:	mov	x1, x19
    4314:	bl	ea0 <memcmp@plt>
    4318:	ldr	x21, [sp, #32]
    431c:	cmp	w0, #0x0
    4320:	cset	w0, eq	// eq = none
    4324:	ldp	x19, x20, [sp, #16]
    4328:	ldp	x29, x30, [sp], #48
    432c:	ret
    4330:	nop
    4334:	nop
    4338:	nop
    433c:	nop

0000000000004340 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>:
    4340:	ldr	x5, [x0]
    4344:	mov	w8, #0xb0df                	// #45279
    4348:	mov	x2, x0
    434c:	movk	w8, #0x9908, lsl #16
    4350:	add	x7, x0, #0x718
    4354:	mov	x3, x0
    4358:	nop
    435c:	nop
    4360:	and	x4, x5, #0xffffffff80000000
    4364:	ldr	x5, [x3, #8]
    4368:	ldr	x6, [x3, #3176]
    436c:	and	x1, x5, #0x7fffffff
    4370:	orr	x1, x1, x4
    4374:	and	x4, x1, #0x1
    4378:	eor	x1, x6, x1, lsr #1
    437c:	umull	x4, w4, w8
    4380:	eor	x1, x1, x4
    4384:	str	x1, [x3], #8
    4388:	cmp	x3, x7
    438c:	b.ne	4360 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()+0x20>  // b.any
    4390:	ldr	x4, [x0, #1816]
    4394:	mov	w6, #0xb0df                	// #45279
    4398:	add	x7, x0, #0xc60
    439c:	movk	w6, #0x9908, lsl #16
    43a0:	and	x3, x4, #0xffffffff80000000
    43a4:	ldr	x4, [x2, #1824]
    43a8:	add	x2, x2, #0x8
    43ac:	ldur	x5, [x2, #-8]
    43b0:	and	x1, x4, #0x7fffffff
    43b4:	orr	x1, x1, x3
    43b8:	and	x3, x1, #0x1
    43bc:	eor	x1, x5, x1, lsr #1
    43c0:	umull	x3, w3, w6
    43c4:	eor	x1, x1, x3
    43c8:	str	x1, [x2, #1808]
    43cc:	cmp	x2, x7
    43d0:	b.ne	43a0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()+0x60>  // b.any
    43d4:	ldr	x2, [x0]
    43d8:	str	xzr, [x0, #4992]
    43dc:	ldr	x1, [x0, #4984]
    43e0:	ldr	x3, [x0, #3168]
    43e4:	bfxil	x1, x2, #0, #31
    43e8:	and	x2, x1, #0x1
    43ec:	eor	x1, x3, x1, lsr #1
    43f0:	umull	x2, w2, w6
    43f4:	eor	x1, x1, x2
    43f8:	str	x1, [x0, #4984]
    43fc:	ret

Disassembly of section .fini:

0000000000004400 <_fini>:
    4400:	paciasp
    4404:	stp	x29, x30, [sp, #-16]!
    4408:	mov	x29, sp
    440c:	ldp	x29, x30, [sp], #16
    4410:	autiasp
    4414:	ret
