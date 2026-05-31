
/home/gcooke/Development/Crucible/bench/pilot/09-arm-neon/build/pilot_blackscholes:     file format elf64-littleaarch64


Disassembly of section .init:

0000000000000e28 <_init>:
 e28:	paciasp
 e2c:	stp	x29, x30, [sp, #-16]!
 e30:	mov	x29, sp
 e34:	bl	19f4 <call_weak_fn>
 e38:	ldp	x29, x30, [sp], #16
 e3c:	autiasp
 e40:	ret

Disassembly of section .plt:

0000000000000e50 <.plt>:
     e50:	stp	x16, x30, [sp, #-16]!
     e54:	adrp	x16, 1f000 <__abi_tag+0x1b404>
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
    10a0:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    10a4:	stp	x21, x22, [sp, #32]
    10a8:	mov	x21, x1
    10ac:	add	x1, x0, #0x490
    10b0:	mov	x0, x2
    10b4:	str	x2, [sp, #168]
    10b8:	mov	x2, x19
    10bc:	stp	x23, x24, [sp, #48]
    10c0:	stp	x25, x26, [sp, #64]
    10c4:	stp	x27, x28, [sp, #80]
    10c8:	stp	d8, d9, [sp, #96]
    10cc:	stp	d10, d11, [sp, #112]
    10d0:	stp	d12, d13, [sp, #128]
    10d4:	stp	d14, d15, [sp, #144]
    10d8:	bl	3220 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>
    10dc:	cmp	w20, #0x1
    10e0:	b.le	193c <main+0x8bc>
    10e4:	add	x0, sp, #0xc8
    10e8:	adrp	x22, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    10ec:	adrp	x24, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    10f0:	add	x22, x22, #0x498
    10f4:	add	x24, x24, #0x4a8
    10f8:	mov	w27, #0x1                   	// #1
    10fc:	str	x0, [sp, #160]
    1100:	mov	x25, #0x100000              	// #1048576
    1104:	add	x0, sp, #0xf0
    1108:	str	x0, [sp, #176]
    110c:	sbfiz	x23, x27, #3, #32
    1110:	mov	x1, x22
    1114:	ldr	x26, [x21, x23]
    1118:	add	w28, w27, #0x1
    111c:	mov	x0, x26
    1120:	bl	f90 <strcmp@plt>
    1124:	cbnz	w0, 1438 <main+0x3b8>
    1128:	cmp	w20, w28
    112c:	b.gt	152c <main+0x4ac>
    1130:	ldr	x20, [sp, #168]
    1134:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    1138:	add	x1, x0, #0x490
    113c:	mov	x0, x20
    1140:	bl	3300 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1144:	tbnz	w0, #0, 115c <main+0xdc>
    1148:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    114c:	mov	x0, x20
    1150:	add	x1, x1, #0x4b8
    1154:	bl	3300 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1158:	tbz	w0, #0, 1918 <main+0x898>
    115c:	mrs	x0, fpcr
    1160:	orr	x0, x0, #0x1000000
    1164:	msr	fpcr, x0
    1168:	mrs	x2, fpcr
    116c:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    1170:	tst	x2, #0x1000000
    1174:	adrp	x3, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    1178:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    117c:	add	x3, x3, #0x488
    1180:	add	x0, x0, #0x4f0
    1184:	add	x1, x1, #0x480
    1188:	csel	x1, x3, x1, eq	// eq = none
    118c:	bl	1040 <printf@plt>
    1190:	mov	x0, x25
    1194:	bl	1ec0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    1198:	mov	x24, x0
    119c:	mov	x0, x25
    11a0:	bl	1ec0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11a4:	mov	x23, x0
    11a8:	mov	x0, x25
    11ac:	bl	1ec0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11b0:	mov	x22, x0
    11b4:	mov	x0, x25
    11b8:	bl	1ec0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11bc:	mov	x21, x0
    11c0:	mov	x0, x25
    11c4:	bl	1ec0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11c8:	mov	x20, x0
    11cc:	mov	x0, x25
    11d0:	bl	1ec0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
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
    1228:	mov	x27, #0x5680                	// #22144
    122c:	movi	v15.2s, #0x0
    1230:	fmov	s13, #1.000000000000000000e+00
    1234:	movk	x27, #0x9d2c, lsl #16
    1238:	mov	x28, #0xefc60000            	// #4022730752
    123c:	fmov	s14, w0
    1240:	b	1418 <main+0x398>
    1244:	ldr	x0, [x19, x1, lsl #3]
    1248:	add	x6, x1, #0x1
    124c:	str	x6, [sp, #5272]
    1250:	ubfx	x1, x0, #11, #32
    1254:	eor	x0, x0, x1
    1258:	and	x1, x27, x0, lsl #7
    125c:	eor	x0, x0, x1
    1260:	and	x1, x28, x0, lsl #15
    1264:	eor	x0, x0, x1
    1268:	eor	x0, x0, x0, lsr #18
    126c:	ucvtf	s31, x0
    1270:	fadd	s31, s31, s15
    1274:	fmul	s31, s31, s14
    1278:	fcmpe	s31, s13
    127c:	b.ge	1878 <main+0x7f8>  // b.tcont
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
    12b4:	and	x1, x27, x0, lsl #7
    12b8:	eor	x0, x0, x1
    12bc:	and	x1, x28, x0, lsl #15
    12c0:	eor	x0, x0, x1
    12c4:	eor	x0, x0, x0, lsr #18
    12c8:	ucvtf	s31, x0
    12cc:	fadd	s31, s31, s15
    12d0:	fmul	s31, s31, s14
    12d4:	fcmpe	s31, s13
    12d8:	b.ge	186c <main+0x7ec>  // b.tcont
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
    1310:	and	x5, x27, x0, lsl #7
    1314:	eor	x0, x0, x5
    1318:	and	x5, x28, x0, lsl #15
    131c:	eor	x0, x0, x5
    1320:	eor	x0, x0, x0, lsr #18
    1324:	ucvtf	s31, x0
    1328:	fadd	s31, s31, s15
    132c:	fmul	s31, s31, s14
    1330:	fcmpe	s31, s13
    1334:	b.ge	1894 <main+0x814>  // b.tcont
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
    1374:	and	x1, x27, x0, lsl #7
    1378:	eor	x0, x0, x1
    137c:	and	x1, x28, x0, lsl #15
    1380:	eor	x0, x0, x1
    1384:	eor	x0, x0, x0, lsr #18
    1388:	ucvtf	s31, x0
    138c:	fadd	s31, s31, s15
    1390:	fmul	s31, s31, s14
    1394:	fcmpe	s31, s13
    1398:	b.ge	1884 <main+0x804>  // b.tcont
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
    13cc:	and	x5, x27, x0, lsl #7
    13d0:	eor	x0, x0, x5
    13d4:	and	x5, x28, x0, lsl #15
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
    1424:	str	x2, [sp, #160]
    1428:	bl	3380 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    142c:	ldr	x2, [sp, #160]
    1430:	ldr	x1, [sp, #5272]
    1434:	b	1244 <main+0x1c4>
    1438:	mov	x0, x26
    143c:	mov	x1, x24
    1440:	bl	f90 <strcmp@plt>
    1444:	cbnz	w0, 1524 <main+0x4a4>
    1448:	cmp	w20, w28
    144c:	b.le	1130 <main+0xb0>
    1450:	add	x23, x21, x23
    1454:	ldr	x2, [sp, #160]
    1458:	mov	x0, x19
    145c:	ldr	x1, [x23, #8]
    1460:	bl	3220 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>
    1464:	bl	f60 <__errno_location@plt>
    1468:	ldr	x26, [sp, #280]
    146c:	mov	x23, x0
    1470:	mov	w2, #0xa                   	// #10
    1474:	ldr	x1, [sp, #176]
    1478:	ldr	w28, [x0]
    147c:	mov	x0, x26
    1480:	str	wzr, [x23]
    1484:	bl	f50 <__isoc23_strtoul@plt>
    1488:	ldr	x1, [sp, #240]
    148c:	mov	x25, x0
    1490:	cmp	x26, x1
    1494:	b.eq	1950 <main+0x8d0>  // b.none
    1498:	ldr	w0, [x23]
    149c:	cmp	w0, #0x22
    14a0:	b.eq	1944 <main+0x8c4>  // b.none
    14a4:	cbnz	w0, 14ac <main+0x42c>
    14a8:	str	w28, [x23]
    14ac:	mov	x0, x19
    14b0:	add	w27, w27, #0x2
    14b4:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    14b8:	cmp	w20, w27
    14bc:	b.gt	110c <main+0x8c>
    14c0:	b	1130 <main+0xb0>
    14c4:	mov	x0, x19
    14c8:	str	x2, [sp, #160]
    14cc:	bl	3380 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    14d0:	ldr	x2, [sp, #160]
    14d4:	ldr	x5, [sp, #5272]
    14d8:	b	13b8 <main+0x338>
    14dc:	mov	x0, x19
    14e0:	str	x2, [sp, #160]
    14e4:	bl	3380 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    14e8:	ldr	x2, [sp, #160]
    14ec:	ldr	x1, [sp, #5272]
    14f0:	b	1360 <main+0x2e0>
    14f4:	mov	x0, x19
    14f8:	str	x2, [sp, #160]
    14fc:	bl	3380 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    1500:	ldr	x2, [sp, #160]
    1504:	ldr	x5, [sp, #5272]
    1508:	b	12fc <main+0x27c>
    150c:	mov	x0, x19
    1510:	str	x2, [sp, #160]
    1514:	bl	3380 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    1518:	ldr	x2, [sp, #160]
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
    154c:	ldr	x0, [sp, #168]
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
    157c:	mov	x28, #0x0                   	// #0
    1580:	movk	w0, #0x3f35, lsl #16
    1584:	fmov	s13, w0
    1588:	ldr	s9, [x22, x28, lsl #2]
    158c:	ldr	s12, [x20, x28, lsl #2]
    1590:	ldr	s30, [x24, x28, lsl #2]
    1594:	fcmp	s9, #0.0
    1598:	ldr	s15, [x23, x28, lsl #2]
    159c:	ldr	s10, [x21, x28, lsl #2]
    15a0:	fmul	s14, s12, s12
    15a4:	b.pl	15c0 <main+0x540>  // b.nfrst
    15a8:	fmov	s0, s9
    15ac:	str	s30, [sp, #160]
    15b0:	bl	ec0 <sqrtf@plt>
    15b4:	ldr	s30, [sp, #160]
    15b8:	fmov	s31, s0
    15bc:	b	15c4 <main+0x544>
    15c0:	fsqrt	s31, s9
    15c4:	fmul	s12, s12, s31
    15c8:	str	s30, [sp, #160]
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
    1610:	ldr	s30, [sp, #160]
    1614:	fmul	s11, s11, s8
    1618:	fmul	s15, s15, s0
    161c:	fnmsub	s15, s30, s11, s15
    1620:	str	s15, [x19, x28, lsl #2]
    1624:	add	x28, x28, #0x1
    1628:	cmp	x28, #0x100
    162c:	b.ne	1588 <main+0x508>  // b.any
    1630:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    1634:	add	x1, x0, #0x490
    1638:	ldr	x0, [sp, #168]
    163c:	bl	3300 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1640:	mov	x6, x28
    1644:	mov	x5, x26
    1648:	mov	x4, x20
    164c:	mov	x3, x21
    1650:	mov	x2, x22
    1654:	mov	x1, x23
    1658:	tbnz	w0, #0, 189c <main+0x81c>
    165c:	mov	x0, x24
    1660:	bl	26e0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1664:	movi	v30.2s, #0x0
    1668:	mov	x0, #0x1                   	// #1
    166c:	sub	x2, x26, #0x4
    1670:	add	x1, x19, x0, lsl #2
    1674:	ldr	s31, [x2, x0, lsl #2]
    1678:	add	x0, x0, #0x1
    167c:	ldur	s29, [x1, #-4]
    1680:	fabd	s31, s31, s29
    1684:	fcmpe	s31, s30
    1688:	fcsel	s30, s31, s30, gt
    168c:	cmp	x0, #0x101
    1690:	b.ne	1670 <main+0x5f0>  // b.any
    1694:	mov	w0, #0xb717                	// #46871
    1698:	fcvt	d0, s30
    169c:	movk	w0, #0x38d1, lsl #16
    16a0:	fmov	s31, w0
    16a4:	fcmpe	s30, s31
    16a8:	b.ge	18f4 <main+0x874>  // b.tcont
    16ac:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    16b0:	add	x0, x0, #0x550
    16b4:	bl	1040 <printf@plt>
    16b8:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    16bc:	ldr	x1, [sp, #208]
    16c0:	mov	x2, x25
    16c4:	add	x0, x0, #0x588
    16c8:	bl	1040 <printf@plt>
    16cc:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    16d0:	scvtf	d15, x25
    16d4:	movi	v13.2s, #0x0
    16d8:	lsr	x7, x25, #4
    16dc:	mov	x27, #0x1                   	// #1
    16e0:	ldr	d14, [x0, #2000]
    16e4:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    16e8:	add	x28, x7, #0x1
    16ec:	add	x0, x0, #0x5a0
    16f0:	str	x0, [sp, #176]
    16f4:	add	x0, sp, #0xf0
    16f8:	str	x0, [sp, #184]
    16fc:	bl	f70 <std::chrono::_V2::steady_clock::now()@plt>
    1700:	ldr	x1, [sp, #216]
    1704:	str	x0, [sp, #160]
    1708:	cmp	x1, #0x6
    170c:	b.eq	18a8 <main+0x828>  // b.none
    1710:	mov	x6, x25
    1714:	mov	x5, x26
    1718:	mov	x4, x20
    171c:	mov	x3, x21
    1720:	mov	x2, x22
    1724:	mov	x1, x23
    1728:	mov	x0, x24
    172c:	bl	26e0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1730:	bl	f70 <std::chrono::_V2::steady_clock::now()@plt>
    1734:	str	s13, [sp, #200]
    1738:	mov	x1, #0x0                   	// #0
    173c:	cbz	x25, 175c <main+0x6dc>
    1740:	ldr	s30, [x26, x1, lsl #2]
    1744:	add	x1, x1, x28
    1748:	ldr	s31, [sp, #200]
    174c:	fadd	s31, s31, s30
    1750:	str	s31, [sp, #200]
    1754:	cmp	x1, x25
    1758:	b.cc	1740 <main+0x6c0>  // b.lo, b.ul, b.last
    175c:	ldr	x1, [sp, #160]
    1760:	ldr	s31, [sp, #200]
    1764:	sub	x2, x0, x1
    1768:	ldr	x0, [sp, #184]
    176c:	mov	w1, w27
    1770:	scvtf	d1, x2
    1774:	add	x3, x0, x27, lsl #3
    1778:	ldr	x0, [sp, #176]
    177c:	fdiv	d0, d1, d15
    1780:	fmul	d1, d1, d14
    1784:	fdiv	d1, d15, d1
    1788:	stur	d0, [x3, #-8]
    178c:	bl	1040 <printf@plt>
    1790:	add	x27, x27, #0x1
    1794:	cmp	x27, #0x6
    1798:	b.ne	16fc <main+0x67c>  // b.any
    179c:	ldp	q30, q31, [sp, #240]
    17a0:	add	x4, sp, #0x200
    17a4:	add	x11, x19, #0x28
    17a8:	mov	x1, x11
    17ac:	mov	x2, #0x4                   	// #4
    17b0:	ldr	x3, [sp, #272]
    17b4:	mov	x0, x19
    17b8:	stur	q30, [x4, #-232]
    17bc:	add	x4, sp, #0x220
    17c0:	stur	q31, [x4, #-248]
    17c4:	str	x3, [sp, #312]
    17c8:	bl	1d00 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    17cc:	mov	x1, x11
    17d0:	mov	x0, x19
    17d4:	bl	1c24 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    17d8:	mov	x1, #0xcd6500000000        	// #225833675390976
    17dc:	ldr	d0, [sp, #296]
    17e0:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    17e4:	movk	x1, #0x41cd, lsl #48
    17e8:	add	x0, x0, #0x5c8
    17ec:	fmov	d1, x1
    17f0:	fdiv	d1, d1, d0
    17f4:	bl	1040 <printf@plt>
    17f8:	mov	x0, x24
    17fc:	mov	w19, #0x0                   	// #0
    1800:	bl	eb0 <free@plt>
    1804:	mov	x0, x23
    1808:	bl	eb0 <free@plt>
    180c:	mov	x0, x22
    1810:	bl	eb0 <free@plt>
    1814:	mov	x0, x21
    1818:	bl	eb0 <free@plt>
    181c:	mov	x0, x20
    1820:	bl	eb0 <free@plt>
    1824:	mov	x0, x26
    1828:	bl	eb0 <free@plt>
    182c:	ldr	x0, [sp, #168]
    1830:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1834:	mov	x12, #0x14a0                	// #5280
    1838:	ldp	d8, d9, [sp, #96]
    183c:	ldp	x29, x30, [sp]
    1840:	mov	w0, w19
    1844:	ldp	x19, x20, [sp, #16]
    1848:	ldp	x21, x22, [sp, #32]
    184c:	ldp	x23, x24, [sp, #48]
    1850:	ldp	x25, x26, [sp, #64]
    1854:	ldp	x27, x28, [sp, #80]
    1858:	ldp	d10, d11, [sp, #112]
    185c:	ldp	d12, d13, [sp, #128]
    1860:	ldp	d14, d15, [sp, #144]
    1864:	add	sp, sp, x12
    1868:	ret
    186c:	mov	w0, #0x43160000            	// #1125515264
    1870:	fmov	s31, w0
    1874:	b	12f0 <main+0x270>
    1878:	mov	w0, #0x43160000            	// #1125515264
    187c:	fmov	s31, w0
    1880:	b	1294 <main+0x214>
    1884:	mov	w0, #0xd709                	// #55049
    1888:	movk	w0, #0x3da3, lsl #16
    188c:	fmov	s31, w0
    1890:	b	13ac <main+0x32c>
    1894:	mvni	v31.2s, #0xc0, lsl #24
    1898:	b	1354 <main+0x2d4>
    189c:	mov	x0, x24
    18a0:	bl	1f20 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    18a4:	b	1664 <main+0x5e4>
    18a8:	ldr	x0, [sp, #208]
    18ac:	mov	w2, #0x6373                	// #25459
    18b0:	movk	w2, #0x6c61, lsl #16
    18b4:	ldr	w1, [x0]
    18b8:	cmp	w1, w2
    18bc:	b.ne	1710 <main+0x690>  // b.any
    18c0:	ldrh	w1, [x0, #4]
    18c4:	mov	w0, #0x7261                	// #29281
    18c8:	cmp	w1, w0
    18cc:	b.ne	1710 <main+0x690>  // b.any
    18d0:	mov	x6, x25
    18d4:	mov	x5, x26
    18d8:	mov	x4, x20
    18dc:	mov	x3, x21
    18e0:	mov	x2, x22
    18e4:	mov	x1, x23
    18e8:	mov	x0, x24
    18ec:	bl	1f20 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    18f0:	b	1730 <main+0x6b0>
    18f4:	adrp	x0, 1f000 <__abi_tag+0x1b404>
    18f8:	ldr	x0, [x0, #4056]
    18fc:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    1900:	add	x1, x1, #0x518
    1904:	ldr	x2, [sp, #208]
    1908:	ldr	x0, [x0]
    190c:	bl	e90 <fprintf@plt>
    1910:	mov	w19, #0x1                   	// #1
    1914:	b	182c <main+0x7ac>
    1918:	adrp	x0, 1f000 <__abi_tag+0x1b404>
    191c:	ldr	x0, [x0, #4056]
    1920:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    1924:	add	x1, x1, #0x4c0
    1928:	ldr	x2, [x21]
    192c:	ldr	x0, [x0]
    1930:	bl	e90 <fprintf@plt>
    1934:	mov	w19, #0x1                   	// #1
    1938:	b	182c <main+0x7ac>
    193c:	mov	x25, #0x100000              	// #1048576
    1940:	b	1130 <main+0xb0>
    1944:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    1948:	add	x0, x0, #0x4b0
    194c:	bl	f80 <std::__throw_out_of_range(char const*)@plt>
    1950:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    1954:	add	x0, x0, #0x4b0
    1958:	bl	ee0 <std::__throw_invalid_argument(char const*)@plt>
    195c:	mov	x20, x0
    1960:	ldr	x0, [sp, #168]
    1964:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1968:	mov	x0, x20
    196c:	bl	1000 <_Unwind_Resume@plt>
    1970:	ldr	w1, [x23]
    1974:	mov	x20, x0
    1978:	cbnz	w1, 1980 <main+0x900>
    197c:	str	w28, [x23]
    1980:	mov	x0, x19
    1984:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1988:	b	1960 <main+0x8e0>
    198c:	nop
    1990:	nop
    1994:	nop
    1998:	nop
    199c:	nop
    19a0:	nop
    19a4:	nop
    19a8:	nop
    19ac:	nop
    19b0:	nop
    19b4:	nop
    19b8:	nop
    19bc:	nop

00000000000019c0 <_start>:
    19c0:	bti	c
    19c4:	mov	x29, #0x0                   	// #0
    19c8:	mov	x30, #0x0                   	// #0
    19cc:	mov	x5, x0
    19d0:	ldr	x1, [sp]
    19d4:	add	x2, sp, #0x8
    19d8:	mov	x6, sp
    19dc:	adrp	x0, 1f000 <__abi_tag+0x1b404>
    19e0:	ldr	x0, [x0, #4024]
    19e4:	mov	x3, #0x0                   	// #0
    19e8:	mov	x4, #0x0                   	// #0
    19ec:	bl	f10 <__libc_start_main@plt>
    19f0:	bl	fb0 <abort@plt>

00000000000019f4 <call_weak_fn>:
    19f4:	adrp	x0, 1f000 <__abi_tag+0x1b404>
    19f8:	ldr	x0, [x0, #4048]
    19fc:	cbz	x0, 1a04 <call_weak_fn+0x10>
    1a00:	b	1030 <__gmon_start__@plt>
    1a04:	ret
    1a08:	nop
    1a0c:	nop
    1a10:	nop
    1a14:	nop
    1a18:	nop
    1a1c:	nop

0000000000001a20 <deregister_tm_clones>:
    1a20:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1a24:	add	x0, x0, #0x108
    1a28:	adrp	x1, 20000 <memcpy@GLIBC_2.17>
    1a2c:	add	x1, x1, #0x108
    1a30:	cmp	x1, x0
    1a34:	b.eq	1a4c <deregister_tm_clones+0x2c>  // b.none
    1a38:	adrp	x1, 1f000 <__abi_tag+0x1b404>
    1a3c:	ldr	x1, [x1, #4040]
    1a40:	cbz	x1, 1a4c <deregister_tm_clones+0x2c>
    1a44:	mov	x16, x1
    1a48:	br	x16
    1a4c:	ret

0000000000001a50 <register_tm_clones>:
    1a50:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1a54:	add	x0, x0, #0x108
    1a58:	adrp	x1, 20000 <memcpy@GLIBC_2.17>
    1a5c:	add	x1, x1, #0x108
    1a60:	sub	x1, x1, x0
    1a64:	lsr	x2, x1, #63
    1a68:	add	x1, x2, x1, asr #3
    1a6c:	asr	x1, x1, #1
    1a70:	cbz	x1, 1a88 <register_tm_clones+0x38>
    1a74:	adrp	x2, 1f000 <__abi_tag+0x1b404>
    1a78:	ldr	x2, [x2, #4064]
    1a7c:	cbz	x2, 1a88 <register_tm_clones+0x38>
    1a80:	mov	x16, x2
    1a84:	br	x16
    1a88:	ret

0000000000001a8c <__do_global_dtors_aux>:
    1a8c:	paciasp
    1a90:	stp	x29, x30, [sp, #-32]!
    1a94:	mov	x29, sp
    1a98:	str	x19, [sp, #16]
    1a9c:	adrp	x19, 20000 <memcpy@GLIBC_2.17>
    1aa0:	ldrb	w0, [x19, #264]
    1aa4:	tbnz	w0, #0, 1acc <__do_global_dtors_aux+0x40>
    1aa8:	adrp	x0, 1f000 <__abi_tag+0x1b404>
    1aac:	ldr	x0, [x0, #4032]
    1ab0:	cbz	x0, 1ac0 <__do_global_dtors_aux+0x34>
    1ab4:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1ab8:	ldr	x0, [x0, #248]
    1abc:	bl	ed0 <__cxa_finalize@plt>
    1ac0:	bl	1a20 <deregister_tm_clones>
    1ac4:	mov	w0, #0x1                   	// #1
    1ac8:	strb	w0, [x19, #264]
    1acc:	ldr	x19, [sp, #16]
    1ad0:	ldp	x29, x30, [sp], #32
    1ad4:	autiasp
    1ad8:	ret
    1adc:	nop

0000000000001ae0 <frame_dummy>:
    1ae0:	bti	c
    1ae4:	b	1a50 <register_tm_clones>
    1ae8:	nop
    1aec:	nop
    1af0:	nop
    1af4:	nop
    1af8:	nop
    1afc:	nop

0000000000001b00 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1b00:	sub	x7, x2, #0x1
    1b04:	and	x8, x2, #0x1
    1b08:	add	x7, x7, x7, lsr #63
    1b0c:	asr	x7, x7, #1
    1b10:	cmp	x1, x7
    1b14:	b.ge	1c04 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x104>  // b.tcont
    1b18:	mov	x4, x1
    1b1c:	nop
    1b20:	add	x3, x4, #0x1
    1b24:	add	x5, x0, x3, lsl #4
    1b28:	lsl	x6, x3, #4
    1b2c:	lsl	x3, x3, #1
    1b30:	ldr	d31, [x0, x6]
    1b34:	ldur	d1, [x5, #-8]
    1b38:	fcmpe	d31, d1
    1b3c:	b.mi	1b54 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x54>  // b.first
    1b40:	str	d31, [x0, x4, lsl #3]
    1b44:	cmp	x3, x7
    1b48:	b.ge	1b6c <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x6c>  // b.tcont
    1b4c:	mov	x4, x3
    1b50:	b	1b20 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x20>
    1b54:	sub	x3, x3, #0x1
    1b58:	add	x5, x0, x3, lsl #3
    1b5c:	ldr	d31, [x0, x3, lsl #3]
    1b60:	str	d31, [x0, x4, lsl #3]
    1b64:	cmp	x3, x7
    1b68:	b.lt	1b4c <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x4c>  // b.tstop
    1b6c:	cbz	x8, 1bc8 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>
    1b70:	sub	x4, x3, #0x1
    1b74:	add	x4, x4, x4, lsr #63
    1b78:	asr	x4, x4, #1
    1b7c:	cmp	x3, x1
    1b80:	b.le	1bac <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>
    1b84:	ldr	d30, [x0, x4, lsl #3]
    1b88:	sub	x2, x4, #0x1
    1b8c:	add	x5, x0, x3, lsl #3
    1b90:	add	x2, x2, x2, lsr #63
    1b94:	lsl	x6, x3, #3
    1b98:	mov	x3, x4
    1b9c:	add	x7, x0, x4, lsl #3
    1ba0:	asr	x2, x2, #1
    1ba4:	fcmpe	d30, d0
    1ba8:	b.mi	1bb4 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xb4>  // b.first
    1bac:	str	d0, [x5]
    1bb0:	ret
    1bb4:	str	d30, [x0, x6]
    1bb8:	cmp	x1, x4
    1bbc:	b.ge	1bf8 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xf8>  // b.tcont
    1bc0:	mov	x4, x2
    1bc4:	b	1b84 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>
    1bc8:	sub	x2, x2, #0x2
    1bcc:	add	x2, x2, x2, lsr #63
    1bd0:	cmp	x3, x2, asr #1
    1bd4:	b.ne	1b70 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>  // b.any
    1bd8:	add	x3, x3, #0x1
    1bdc:	add	x2, x0, x3, lsl #4
    1be0:	lsl	x3, x3, #1
    1be4:	sub	x3, x3, #0x1
    1be8:	ldur	d31, [x2, #-8]
    1bec:	str	d31, [x5]
    1bf0:	add	x5, x0, x3, lsl #3
    1bf4:	b	1b70 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>
    1bf8:	mov	x5, x7
    1bfc:	str	d0, [x5]
    1c00:	ret
    1c04:	add	x5, x0, x1, lsl #3
    1c08:	cbnz	x8, 1bac <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>
    1c0c:	sub	x2, x2, #0x2
    1c10:	add	x2, x2, x2, lsr #63
    1c14:	cmp	x1, x2, asr #1
    1c18:	b.ne	1bac <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>  // b.any
    1c1c:	mov	x3, x1
    1c20:	b	1bd8 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xd8>

0000000000001c24 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1c24:	cmp	x0, x1
    1c28:	b.eq	1cf4 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xd0>  // b.none
    1c2c:	stp	x29, x30, [sp, #-64]!
    1c30:	mov	x29, sp
    1c34:	stp	x19, x20, [sp, #16]
    1c38:	add	x19, x0, #0x8
    1c3c:	mov	x20, x0
    1c40:	stp	x21, x22, [sp, #32]
    1c44:	mov	x21, x1
    1c48:	cmp	x1, x19
    1c4c:	b.eq	1c98 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x74>  // b.none
    1c50:	mov	x22, #0x8                   	// #8
    1c54:	stp	d14, d15, [sp, #48]
    1c58:	nop
    1c5c:	nop
    1c60:	ldr	d15, [x19]
    1c64:	ldr	d14, [x20]
    1c68:	fcmpe	d15, d14
    1c6c:	b.mi	1cc0 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x9c>  // b.first
    1c70:	ldur	d31, [x19, #-8]
    1c74:	sub	x2, x19, #0x8
    1c78:	fcmpe	d15, d31
    1c7c:	b.mi	1ca8 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>  // b.first
    1c80:	mov	x3, x19
    1c84:	str	d15, [x3]
    1c88:	add	x19, x19, #0x8
    1c8c:	cmp	x21, x19
    1c90:	b.ne	1c60 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x3c>  // b.any
    1c94:	ldp	d14, d15, [sp, #48]
    1c98:	ldp	x19, x20, [sp, #16]
    1c9c:	ldp	x21, x22, [sp, #32]
    1ca0:	ldp	x29, x30, [sp], #64
    1ca4:	ret
    1ca8:	mov	x3, x2
    1cac:	str	d31, [x2, #8]
    1cb0:	ldr	d31, [x2, #-8]!
    1cb4:	fcmpe	d15, d31
    1cb8:	b.mi	1ca8 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>  // b.first
    1cbc:	b	1c84 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x60>
    1cc0:	sub	x2, x19, x20
    1cc4:	cmp	x2, #0x8
    1cc8:	b.le	1ce4 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc0>
    1ccc:	sub	x0, x22, x2
    1cd0:	mov	x1, x20
    1cd4:	add	x0, x19, x0
    1cd8:	bl	f40 <memmove@plt>
    1cdc:	str	d15, [x20]
    1ce0:	b	1c88 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>
    1ce4:	b.ne	1cdc <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xb8>  // b.any
    1ce8:	str	d14, [x19]
    1cec:	str	d15, [x20]
    1cf0:	b	1c88 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>
    1cf4:	ret
    1cf8:	nop
    1cfc:	nop

0000000000001d00 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1d00:	stp	x29, x30, [sp, #-48]!
    1d04:	mov	x29, sp
    1d08:	stp	x19, x20, [sp, #16]
    1d0c:	mov	x20, x0
    1d10:	sub	x0, x1, x0
    1d14:	cmp	x0, #0x80
    1d18:	b.le	1e8c <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x18c>
    1d1c:	asr	x10, x0, #3
    1d20:	mov	x9, x1
    1d24:	str	x21, [sp, #32]
    1d28:	mov	x21, x2
    1d2c:	asr	x0, x0, #4
    1d30:	cbz	x21, 1e28 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x128>
    1d34:	lsl	x0, x0, #3
    1d38:	ldp	d28, d31, [x20]
    1d3c:	sub	x21, x21, #0x1
    1d40:	add	x19, x20, #0x8
    1d44:	ldr	d30, [x20, x0]
    1d48:	ldur	d0, [x9, #-8]
    1d4c:	fcmpe	d31, d30
    1d50:	b.mi	1ea8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x1a8>  // b.first
    1d54:	fcmpe	d31, d0
    1d58:	b.mi	1eb8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x1b8>  // b.first
    1d5c:	fcmpe	d30, d0
    1d60:	b.mi	1e98 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x198>  // b.first
    1d64:	str	d30, [x20]
    1d68:	str	d28, [x20, x0]
    1d6c:	ldp	d31, d28, [x20]
    1d70:	mov	x3, x9
    1d74:	nop
    1d78:	nop
    1d7c:	nop
    1d80:	fcmpe	d31, d28
    1d84:	b.gt	1dc8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>
    1d88:	ldur	d29, [x3, #-8]
    1d8c:	sub	x0, x3, #0x8
    1d90:	fcmpe	d29, d31
    1d94:	b.gt	1de8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1d98:	nop
    1d9c:	nop
    1da0:	cmp	x19, x0
    1da4:	b.cs	1dfc <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xfc>  // b.hs, b.nlast
    1da8:	mov	x1, x19
    1dac:	mov	x3, x0
    1db0:	str	d29, [x1], #8
    1db4:	str	d28, [x0]
    1db8:	ldr	d31, [x20]
    1dbc:	ldr	d28, [x19, #8]
    1dc0:	mov	x19, x1
    1dc4:	b	1d80 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x80>
    1dc8:	ldr	d28, [x19, #8]!
    1dcc:	fcmpe	d28, d31
    1dd0:	b.mi	1dc8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>  // b.first
    1dd4:	ldur	d29, [x3, #-8]
    1dd8:	sub	x0, x3, #0x8
    1ddc:	fcmpe	d29, d31
    1de0:	b.gt	1de8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1de4:	b	1da0 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xa0>
    1de8:	ldr	d29, [x0, #-8]!
    1dec:	fcmpe	d29, d31
    1df0:	b.gt	1de8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1df4:	cmp	x19, x0
    1df8:	b.cc	1da8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xa8>  // b.lo, b.ul, b.last
    1dfc:	mov	x0, x19
    1e00:	mov	x1, x9
    1e04:	mov	x2, x21
    1e08:	bl	1d00 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1e0c:	sub	x0, x19, x20
    1e10:	cmp	x0, #0x80
    1e14:	b.le	1e88 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x188>
    1e18:	asr	x10, x0, #3
    1e1c:	mov	x9, x19
    1e20:	asr	x0, x0, #4
    1e24:	cbnz	x21, 1d34 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x34>
    1e28:	sub	x1, x0, #0x1
    1e2c:	b	1e34 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x134>
    1e30:	sub	x1, x1, #0x1
    1e34:	ldr	d0, [x20, x1, lsl #3]
    1e38:	mov	x2, x10
    1e3c:	mov	x0, x20
    1e40:	bl	1b00 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1e44:	cbnz	x1, 1e30 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x130>
    1e48:	sub	x0, x9, x20
    1e4c:	cmp	x0, #0x8
    1e50:	b.le	1e88 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x188>
    1e54:	nop
    1e58:	nop
    1e5c:	nop
    1e60:	ldr	d0, [x9, #-8]!
    1e64:	mov	x1, #0x0                   	// #0
    1e68:	mov	x0, x20
    1e6c:	ldr	d31, [x20]
    1e70:	sub	x10, x9, x20
    1e74:	asr	x2, x10, #3
    1e78:	str	d31, [x9]
    1e7c:	bl	1b00 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1e80:	cmp	x10, #0x8
    1e84:	b.gt	1e60 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x160>
    1e88:	ldr	x21, [sp, #32]
    1e8c:	ldp	x19, x20, [sp, #16]
    1e90:	ldp	x29, x30, [sp], #48
    1e94:	ret
    1e98:	str	d0, [x20]
    1e9c:	stur	d28, [x9, #-8]
    1ea0:	ldp	d31, d28, [x20]
    1ea4:	b	1d70 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>
    1ea8:	fcmpe	d30, d0
    1eac:	b.mi	1d64 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>  // b.first
    1eb0:	fcmpe	d31, d0
    1eb4:	b.mi	1e98 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x198>  // b.first
    1eb8:	stp	d31, d28, [x20]
    1ebc:	b	1d70 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>

0000000000001ec0 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>:
    1ec0:	stp	x29, x30, [sp, #-32]!
    1ec4:	lsl	x2, x0, #2
    1ec8:	mov	x29, sp
    1ecc:	mov	x1, #0x10                  	// #16
    1ed0:	add	x0, sp, #0x18
    1ed4:	str	xzr, [sp, #24]
    1ed8:	bl	f20 <posix_memalign@plt>
    1edc:	cbnz	w0, 1eec <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]+0x2c>
    1ee0:	ldr	x0, [sp, #24]
    1ee4:	ldp	x29, x30, [sp], #32
    1ee8:	ret
    1eec:	adrp	x3, 1f000 <__abi_tag+0x1b404>
    1ef0:	ldr	x3, [x3, #4056]
    1ef4:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    1ef8:	mov	x2, #0x16                  	// #22
    1efc:	add	x0, x0, #0x468
    1f00:	mov	x1, #0x1                   	// #1
    1f04:	ldr	x3, [x3]
    1f08:	bl	ff0 <fwrite@plt>
    1f0c:	mov	w0, #0x1                   	// #1
    1f10:	bl	fe0 <exit@plt>
    1f14:	nop
    1f18:	nop
    1f1c:	nop

0000000000001f20 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    1f20:	cbz	x6, 26dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    1f24:	stp	x29, x30, [sp, #-160]!
    1f28:	mov	x29, sp
    1f2c:	stp	x23, x24, [sp, #48]
    1f30:	mov	x24, x4
    1f34:	mov	w4, #0xaa3b                	// #43579
    1f38:	movk	w4, #0x3fb8, lsl #16
    1f3c:	mov	x23, x3
    1f40:	mov	w3, #0x7218                	// #29208
    1f44:	stp	x19, x20, [sp, #16]
    1f48:	mov	x20, x0
    1f4c:	mov	w0, #0xc2b00000            	// #-1028653056
    1f50:	movk	w3, #0x3f31, lsl #16
    1f54:	mov	x19, x6
    1f58:	stp	d8, d9, [sp, #80]
    1f5c:	fmov	s9, w0
    1f60:	stp	d14, d15, [sp, #128]
    1f64:	fmov	s14, w4
    1f68:	stp	x21, x22, [sp, #32]
    1f6c:	mov	x21, x1
    1f70:	mov	x22, x2
    1f74:	mov	w1, #0x8889                	// #34953
    1f78:	mov	w2, #0xb61                 	// #2913
    1f7c:	movk	w2, #0x3ab6, lsl #16
    1f80:	movk	w1, #0x3c08, lsl #16
    1f84:	stp	x25, x26, [sp, #64]
    1f88:	mov	x26, #0x0                   	// #0
    1f8c:	mov	x25, x5
    1f90:	stp	d10, d11, [sp, #96]
    1f94:	stp	d12, d13, [sp, #112]
    1f98:	stp	w3, w2, [sp, #148]
    1f9c:	str	w1, [sp, #156]
    1fa0:	ldr	s12, [x22, x26, lsl #2]
    1fa4:	ldr	s15, [x24, x26, lsl #2]
    1fa8:	ldr	s13, [x20, x26, lsl #2]
    1fac:	fcmp	s12, #0.0
    1fb0:	ldr	s8, [x21, x26, lsl #2]
    1fb4:	ldr	s11, [x23, x26, lsl #2]
    1fb8:	fmul	s10, s15, s15
    1fbc:	b.pl	2074 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    1fc0:	fmov	s0, s12
    1fc4:	bl	ec0 <sqrtf@plt>
    1fc8:	fmov	s31, s0
    1fcc:	fdiv	s0, s13, s8
    1fd0:	fmul	s15, s15, s31
    1fd4:	bl	1020 <logf@plt>
    1fd8:	fmov	s31, #5.000000000000000000e-01
    1fdc:	mov	w0, #0x3389                	// #13193
    1fe0:	fmov	s25, #1.000000000000000000e+00
    1fe4:	movk	w0, #0x3e6d, lsl #16
    1fe8:	mov	w1, #0x466f                	// #18031
    1fec:	fmov	s19, #-5.000000000000000000e-01
    1ff0:	mov	w4, #0x1eea                	// #7914
    1ff4:	movk	w1, #0x3faa, lsl #16
    1ff8:	fmov	s29, w0
    1ffc:	movk	w4, #0xbfe9, lsl #16
    2000:	mov	w3, #0x778                 	// #1912
    2004:	fmadd	s10, s10, s31, s11
    2008:	movk	w3, #0x3fe4, lsl #16
    200c:	mov	w2, #0x8f89                	// #36745
    2010:	fmov	s20, w1
    2014:	movk	w2, #0xbeb6, lsl #16
    2018:	mov	w1, #0x85fa                	// #34298
    201c:	movk	w1, #0x3ea3, lsl #16
    2020:	mov	w0, #0xaa3b                	// #43579
    2024:	fmov	s22, w4
    2028:	movk	w0, #0x3fb8, lsl #16
    202c:	fmov	s23, w3
    2030:	fmadd	s0, s12, s10, s0
    2034:	fmov	s24, w2
    2038:	fmov	s31, w1
    203c:	fmov	s28, w0
    2040:	fdiv	s0, s0, s15
    2044:	fmadd	s21, s0, s29, s25
    2048:	fmul	s29, s0, s19
    204c:	fsub	s15, s0, s15
    2050:	fmul	s29, s29, s0
    2054:	fdiv	s25, s25, s21
    2058:	fmul	s28, s29, s28
    205c:	fmadd	s22, s25, s20, s22
    2060:	fmadd	s23, s22, s25, s23
    2064:	fmadd	s24, s23, s25, s24
    2068:	fmadd	s31, s24, s25, s31
    206c:	fmul	s31, s31, s25
    2070:	b	2138 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    2074:	fsqrt	s31, s12
    2078:	fdiv	s0, s13, s8
    207c:	fmul	s15, s15, s31
    2080:	bl	1020 <logf@plt>
    2084:	fmov	s29, #5.000000000000000000e-01
    2088:	fmadd	s10, s10, s29, s11
    208c:	fmadd	s0, s12, s10, s0
    2090:	fdiv	s0, s0, s15
    2094:	fcmpe	s0, #0.0
    2098:	fsub	s15, s0, s15
    209c:	b.mi	247c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    20a0:	mov	w0, #0x3389                	// #13193
    20a4:	fmov	s31, #1.000000000000000000e+00
    20a8:	mov	w4, #0x466f                	// #18031
    20ac:	movk	w0, #0x3e6d, lsl #16
    20b0:	mov	w3, #0x1eea                	// #7914
    20b4:	fmov	s29, #-5.000000000000000000e-01
    20b8:	movk	w4, #0x3faa, lsl #16
    20bc:	movk	w3, #0xbfe9, lsl #16
    20c0:	fmov	s22, w0
    20c4:	mov	w2, #0x778                 	// #1912
    20c8:	mov	w1, #0x8f89                	// #36745
    20cc:	fmov	s21, w4
    20d0:	movk	w2, #0x3fe4, lsl #16
    20d4:	movk	w1, #0xbeb6, lsl #16
    20d8:	fmov	s23, w3
    20dc:	mov	w0, #0x85fa                	// #34298
    20e0:	fmov	s24, w2
    20e4:	movk	w0, #0x3ea3, lsl #16
    20e8:	fmov	s25, w1
    20ec:	fmov	s28, w0
    20f0:	fmul	s29, s0, s29
    20f4:	fmadd	s22, s0, s22, s31
    20f8:	fmul	s29, s29, s0
    20fc:	fcmpe	s29, s9
    2100:	fdiv	s31, s31, s22
    2104:	fmadd	s23, s31, s21, s23
    2108:	fmadd	s24, s31, s23, s24
    210c:	fmadd	s25, s31, s24, s25
    2110:	fmadd	s28, s31, s25, s28
    2114:	fmul	s31, s31, s28
    2118:	b.mi	258c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    211c:	mov	w0, #0x42b00000            	// #1118830592
    2120:	fmov	s28, w0
    2124:	fcmpe	s29, s28
    2128:	b.gt	21d8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    212c:	fmul	s28, s29, s14
    2130:	fcmpe	s28, #0.0
    2134:	b.ge	25ec <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    2138:	fmov	s23, #5.000000000000000000e-01
    213c:	mov	w0, #0x7218                	// #29208
    2140:	mov	w3, #0xb61                 	// #2913
    2144:	movk	w0, #0x3f31, lsl #16
    2148:	mov	w2, #0x8889                	// #34953
    214c:	fmov	s24, #1.000000000000000000e+00
    2150:	movk	w3, #0x3ab6, lsl #16
    2154:	movk	w2, #0x3c08, lsl #16
    2158:	fmov	s25, w0
    215c:	mov	w1, #0xaaab                	// #43691
    2160:	mov	w0, #0xaaab                	// #43691
    2164:	fsub	s28, s28, s23
    2168:	movk	w1, #0x3d2a, lsl #16
    216c:	movk	w0, #0x3e2a, lsl #16
    2170:	fmov	s18, w3
    2174:	mov	w4, #0x422a                	// #16938
    2178:	fmov	s20, w2
    217c:	movk	w4, #0x3ecc, lsl #16
    2180:	fmov	s21, w1
    2184:	fmov	s22, w0
    2188:	fmov	s19, w4
    218c:	fcvtzs	s28, s28
    2190:	scvtf	s28, s28
    2194:	fmsub	s25, s28, s25, s29
    2198:	fcvtzs	w0, s28
    219c:	fmadd	s28, s25, s18, s20
    21a0:	add	w0, w0, #0x7f
    21a4:	fmov	s30, w0
    21a8:	fmadd	s28, s25, s28, s21
    21ac:	fmadd	s28, s25, s28, s22
    21b0:	shl	v29.2s, v30.2s, #23
    21b4:	fmadd	s23, s25, s28, s23
    21b8:	fmadd	s23, s25, s23, s24
    21bc:	fmadd	s24, s25, s23, s24
    21c0:	fmul	s29, s24, s29
    21c4:	fmul	s29, s29, s19
    21c8:	fcmpe	s0, #0.0
    21cc:	fmul	s31, s31, s29
    21d0:	b.mi	21f0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    21d4:	b	21e8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    21d8:	mov	w0, #0x484f                	// #18511
    21dc:	movk	w0, #0x7e46, lsl #16
    21e0:	fmov	s29, w0
    21e4:	fmul	s31, s31, s29
    21e8:	fmov	s29, #1.000000000000000000e+00
    21ec:	fsub	s31, s29, s31
    21f0:	fnmul	s30, s11, s12
    21f4:	fmul	s31, s13, s31
    21f8:	movi	v29.2s, #0x0
    21fc:	fcmpe	s30, s9
    2200:	b.mi	22a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2204:	mov	w0, #0x42b00000            	// #1118830592
    2208:	fmov	s29, w0
    220c:	fcmpe	s30, s29
    2210:	b.gt	2598 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2214:	fmul	s28, s30, s14
    2218:	fcmpe	s28, #0.0
    221c:	b.ge	25a8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    2220:	fmov	s27, #5.000000000000000000e-01
    2224:	mov	w0, #0x7218                	// #29208
    2228:	mov	w3, #0xb61                 	// #2913
    222c:	movk	w0, #0x3f31, lsl #16
    2230:	mov	w2, #0x8889                	// #34953
    2234:	fmov	s29, #1.000000000000000000e+00
    2238:	movk	w3, #0x3ab6, lsl #16
    223c:	movk	w2, #0x3c08, lsl #16
    2240:	fmov	s22, w0
    2244:	mov	w1, #0xaaab                	// #43691
    2248:	mov	w0, #0xaaab                	// #43691
    224c:	fsub	s28, s28, s27
    2250:	movk	w1, #0x3d2a, lsl #16
    2254:	movk	w0, #0x3e2a, lsl #16
    2258:	fmov	s23, w3
    225c:	fmov	s24, w2
    2260:	fmov	s25, w1
    2264:	fmov	s26, w0
    2268:	fcvtzs	s28, s28
    226c:	scvtf	s28, s28
    2270:	fmsub	s30, s28, s22, s30
    2274:	fcvtzs	w0, s28
    2278:	fmadd	s24, s30, s23, s24
    227c:	fmadd	s25, s30, s24, s25
    2280:	add	w0, w0, #0x7f
    2284:	fmov	s28, w0
    2288:	fmadd	s26, s30, s25, s26
    228c:	fmadd	s27, s30, s26, s27
    2290:	shl	v28.2s, v28.2s, #23
    2294:	fmadd	s27, s30, s27, s29
    2298:	fmadd	s29, s30, s27, s29
    229c:	fmul	s29, s29, s28
    22a0:	fcmpe	s15, #0.0
    22a4:	fmul	s29, s8, s29
    22a8:	b.mi	2504 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    22ac:	mov	w0, #0x3389                	// #13193
    22b0:	fmov	s30, #1.000000000000000000e+00
    22b4:	mov	w4, #0x466f                	// #18031
    22b8:	movk	w0, #0x3e6d, lsl #16
    22bc:	mov	w3, #0x1eea                	// #7914
    22c0:	fmov	s27, #-5.000000000000000000e-01
    22c4:	movk	w4, #0x3faa, lsl #16
    22c8:	movk	w3, #0xbfe9, lsl #16
    22cc:	fmov	s23, w0
    22d0:	mov	w2, #0x778                 	// #1912
    22d4:	mov	w1, #0x8f89                	// #36745
    22d8:	fmov	s22, w4
    22dc:	movk	w2, #0x3fe4, lsl #16
    22e0:	movk	w1, #0xbeb6, lsl #16
    22e4:	fmov	s24, w3
    22e8:	mov	w0, #0x85fa                	// #34298
    22ec:	fmov	s25, w2
    22f0:	movk	w0, #0x3ea3, lsl #16
    22f4:	fmov	s26, w1
    22f8:	fmov	s28, w0
    22fc:	fmul	s27, s15, s27
    2300:	fmadd	s23, s15, s23, s30
    2304:	fmul	s27, s27, s15
    2308:	fcmpe	s27, s9
    230c:	fdiv	s30, s30, s23
    2310:	fmadd	s24, s30, s22, s24
    2314:	fmadd	s25, s30, s24, s25
    2318:	fmadd	s26, s30, s25, s26
    231c:	fmadd	s28, s30, s26, s28
    2320:	fmul	s30, s30, s28
    2324:	b.mi	2584 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    2328:	mov	w0, #0x42b00000            	// #1118830592
    232c:	fmov	s28, w0
    2330:	fcmpe	s27, s28
    2334:	b.gt	242c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    2338:	nop
    233c:	nop
    2340:	fmul	s28, s27, s14
    2344:	fcmpe	s28, #0.0
    2348:	b.ge	2664 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    234c:	fmov	s25, #5.000000000000000000e-01
    2350:	mov	w0, #0x7218                	// #29208
    2354:	mov	w4, #0xb61                 	// #2913
    2358:	movk	w0, #0x3f31, lsl #16
    235c:	mov	w2, #0x8889                	// #34953
    2360:	fmov	s26, #1.000000000000000000e+00
    2364:	movk	w4, #0x3ab6, lsl #16
    2368:	movk	w2, #0x3c08, lsl #16
    236c:	fmov	s19, w0
    2370:	mov	w1, #0xaaab                	// #43691
    2374:	mov	w0, #0xaaab                	// #43691
    2378:	fsub	s28, s28, s25
    237c:	movk	w1, #0x3d2a, lsl #16
    2380:	movk	w0, #0x3e2a, lsl #16
    2384:	fmov	s20, w4
    2388:	mov	w3, #0x422a                	// #16938
    238c:	fmov	s22, w2
    2390:	movk	w3, #0x3ecc, lsl #16
    2394:	fmov	s23, w1
    2398:	fmov	s24, w0
    239c:	fmov	s21, w3
    23a0:	fcvtzs	s28, s28
    23a4:	scvtf	s28, s28
    23a8:	fmsub	s27, s28, s19, s27
    23ac:	fcvtzs	w0, s28
    23b0:	fmadd	s22, s27, s20, s22
    23b4:	add	w0, w0, #0x7f
    23b8:	fmov	s28, w0
    23bc:	fmadd	s23, s27, s22, s23
    23c0:	fmadd	s24, s27, s23, s24
    23c4:	shl	v28.2s, v28.2s, #23
    23c8:	fmadd	s25, s27, s24, s25
    23cc:	fmadd	s25, s27, s25, s26
    23d0:	fmadd	s26, s27, s25, s26
    23d4:	fmul	s28, s26, s28
    23d8:	fmul	s28, s28, s21
    23dc:	fcmpe	s15, #0.0
    23e0:	fmul	s30, s30, s28
    23e4:	b.mi	2464 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    23e8:	fmov	s28, #1.000000000000000000e+00
    23ec:	fsub	s30, s28, s30
    23f0:	fmsub	s31, s29, s30, s31
    23f4:	str	s31, [x25, x26, lsl #2]
    23f8:	add	x26, x26, #0x1
    23fc:	cmp	x26, x19
    2400:	b.ne	1fa0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2404:	ldp	d8, d9, [sp, #80]
    2408:	ldp	x19, x20, [sp, #16]
    240c:	ldp	x21, x22, [sp, #32]
    2410:	ldp	x23, x24, [sp, #48]
    2414:	ldp	x25, x26, [sp, #64]
    2418:	ldp	d10, d11, [sp, #96]
    241c:	ldp	d12, d13, [sp, #112]
    2420:	ldp	d14, d15, [sp, #128]
    2424:	ldp	x29, x30, [sp], #160
    2428:	ret
    242c:	mov	w0, #0x484f                	// #18511
    2430:	movk	w0, #0x7e46, lsl #16
    2434:	fmov	s28, w0
    2438:	fmul	s30, s30, s28
    243c:	fmov	s28, #1.000000000000000000e+00
    2440:	fsub	s30, s28, s30
    2444:	fmsub	s31, s29, s30, s31
    2448:	str	s31, [x25, x26, lsl #2]
    244c:	add	x26, x26, #0x1
    2450:	cmp	x26, x19
    2454:	b.ne	1fa0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2458:	b	2404 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    245c:	movi	v28.2s, #0x0
    2460:	fmul	s30, s30, s28
    2464:	fmsub	s30, s29, s30, s31
    2468:	str	s30, [x25, x26, lsl #2]
    246c:	add	x26, x26, #0x1
    2470:	cmp	x19, x26
    2474:	b.ne	1fa0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2478:	b	2404 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    247c:	mov	w0, #0x3389                	// #13193
    2480:	fmov	s31, #1.000000000000000000e+00
    2484:	mov	w4, #0x466f                	// #18031
    2488:	movk	w0, #0x3e6d, lsl #16
    248c:	mov	w3, #0x1eea                	// #7914
    2490:	fmul	s29, s0, s29
    2494:	movk	w4, #0x3faa, lsl #16
    2498:	movk	w3, #0xbfe9, lsl #16
    249c:	fmov	s22, w0
    24a0:	mov	w2, #0x778                 	// #1912
    24a4:	mov	w1, #0x8f89                	// #36745
    24a8:	fmov	s21, w4
    24ac:	movk	w2, #0x3fe4, lsl #16
    24b0:	movk	w1, #0xbeb6, lsl #16
    24b4:	fmov	s23, w3
    24b8:	mov	w0, #0x85fa                	// #34298
    24bc:	fmov	s24, w2
    24c0:	movk	w0, #0x3ea3, lsl #16
    24c4:	fmov	s25, w1
    24c8:	fmov	s28, w0
    24cc:	fnmul	s29, s0, s29
    24d0:	fmsub	s22, s0, s22, s31
    24d4:	fcmpe	s29, s9
    24d8:	fdiv	s31, s31, s22
    24dc:	fmadd	s23, s31, s21, s23
    24e0:	fmadd	s24, s31, s23, s24
    24e4:	fmadd	s25, s31, s24, s25
    24e8:	fmadd	s28, s31, s25, s28
    24ec:	fmul	s31, s31, s28
    24f0:	b.mi	24f8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    24f4:	b	212c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    24f8:	movi	v29.2s, #0x0
    24fc:	fmul	s31, s31, s29
    2500:	b	21f0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2504:	mov	w0, #0x3389                	// #13193
    2508:	fmov	s30, #1.000000000000000000e+00
    250c:	mov	w4, #0x466f                	// #18031
    2510:	movk	w0, #0x3e6d, lsl #16
    2514:	mov	w3, #0x1eea                	// #7914
    2518:	fmov	s27, #5.000000000000000000e-01
    251c:	movk	w4, #0x3faa, lsl #16
    2520:	movk	w3, #0xbfe9, lsl #16
    2524:	fmov	s23, w0
    2528:	mov	w2, #0x778                 	// #1912
    252c:	mov	w1, #0x8f89                	// #36745
    2530:	fmov	s22, w4
    2534:	movk	w2, #0x3fe4, lsl #16
    2538:	movk	w1, #0xbeb6, lsl #16
    253c:	fmov	s24, w3
    2540:	mov	w0, #0x85fa                	// #34298
    2544:	fmov	s25, w2
    2548:	movk	w0, #0x3ea3, lsl #16
    254c:	fmov	s26, w1
    2550:	fmov	s28, w0
    2554:	fmul	s27, s15, s27
    2558:	fmsub	s23, s15, s23, s30
    255c:	fnmul	s27, s15, s27
    2560:	fcmpe	s27, s9
    2564:	fdiv	s30, s30, s23
    2568:	fmadd	s24, s30, s22, s24
    256c:	fmadd	s25, s24, s30, s25
    2570:	fmadd	s26, s25, s30, s26
    2574:	fmadd	s28, s30, s26, s28
    2578:	fmul	s30, s30, s28
    257c:	b.mi	245c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2580:	b	2340 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2584:	movi	v28.2s, #0x0
    2588:	b	2438 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    258c:	movi	v29.2s, #0x0
    2590:	fmul	s31, s31, s29
    2594:	b	21e8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2598:	mov	w7, #0x829c                	// #33436
    259c:	movk	w7, #0x7ef8, lsl #16
    25a0:	fmov	s29, w7
    25a4:	b	22a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    25a8:	fmov	s27, #5.000000000000000000e-01
    25ac:	ldr	s24, [sp, #148]
    25b0:	mov	w0, #0xaaab                	// #43691
    25b4:	movk	w0, #0x3e2a, lsl #16
    25b8:	mov	w1, #0xaaab                	// #43691
    25bc:	fmov	s29, #1.000000000000000000e+00
    25c0:	movk	w1, #0x3d2a, lsl #16
    25c4:	fmov	s26, w0
    25c8:	fadd	s28, s28, s27
    25cc:	fmov	s25, w1
    25d0:	fcvtzs	s28, s28
    25d4:	scvtf	s28, s28
    25d8:	fmsub	s30, s28, s24, s30
    25dc:	fcvtzs	w0, s28
    25e0:	ldp	s24, s28, [sp, #152]
    25e4:	fmadd	s24, s30, s24, s28
    25e8:	b	227c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    25ec:	fmov	s24, #5.000000000000000000e-01
    25f0:	ldr	s30, [sp, #148]
    25f4:	mov	w1, #0xaaab                	// #43691
    25f8:	movk	w1, #0x3d2a, lsl #16
    25fc:	mov	w0, #0xaaab                	// #43691
    2600:	fmov	s25, #1.000000000000000000e+00
    2604:	movk	w0, #0x3e2a, lsl #16
    2608:	mov	w2, #0x422a                	// #16938
    260c:	fmov	s22, w1
    2610:	movk	w2, #0x3ecc, lsl #16
    2614:	fadd	s28, s28, s24
    2618:	fmov	s23, w0
    261c:	fmov	s21, w2
    2620:	fcvtzs	s28, s28
    2624:	scvtf	s28, s28
    2628:	fmsub	s29, s28, s30, s29
    262c:	fcvtzs	w7, s28
    2630:	ldp	s28, s30, [sp, #152]
    2634:	fmadd	s20, s29, s28, s30
    2638:	add	w7, w7, #0x7f
    263c:	fmov	s30, w7
    2640:	fmadd	s22, s29, s20, s22
    2644:	fmadd	s23, s29, s22, s23
    2648:	shl	v28.2s, v30.2s, #23
    264c:	fmadd	s24, s29, s23, s24
    2650:	fmadd	s24, s29, s24, s25
    2654:	fmadd	s29, s29, s24, s25
    2658:	fmul	s29, s29, s28
    265c:	fmul	s29, s29, s21
    2660:	b	21c8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    2664:	fmov	s25, #5.000000000000000000e-01
    2668:	ldr	s21, [sp, #148]
    266c:	mov	w0, #0xaaab                	// #43691
    2670:	movk	w0, #0x3e2a, lsl #16
    2674:	mov	w1, #0xaaab                	// #43691
    2678:	fmov	s26, #1.000000000000000000e+00
    267c:	movk	w1, #0x3d2a, lsl #16
    2680:	mov	w2, #0x422a                	// #16938
    2684:	fmov	s24, w0
    2688:	movk	w2, #0x3ecc, lsl #16
    268c:	fadd	s28, s28, s25
    2690:	fmov	s23, w1
    2694:	fmov	s22, w2
    2698:	fcvtzs	s28, s28
    269c:	scvtf	s28, s28
    26a0:	fmsub	s27, s28, s21, s27
    26a4:	fcvtzs	w0, s28
    26a8:	ldp	s21, s28, [sp, #152]
    26ac:	fmadd	s21, s27, s21, s28
    26b0:	add	w0, w0, #0x7f
    26b4:	fmov	s28, w0
    26b8:	fmadd	s23, s27, s21, s23
    26bc:	fmadd	s24, s27, s23, s24
    26c0:	shl	v28.2s, v28.2s, #23
    26c4:	fmadd	s25, s27, s24, s25
    26c8:	fmadd	s25, s27, s25, s26
    26cc:	fmadd	s26, s27, s25, s26
    26d0:	fmul	s28, s26, s28
    26d4:	fmul	s28, s28, s22
    26d8:	b	23dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    26dc:	ret

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

0000000000003220 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>:
    3220:	stp	x29, x30, [sp, #-64]!
    3224:	mov	x29, sp
    3228:	stp	x21, x22, [sp, #32]
    322c:	add	x22, x0, #0x10
    3230:	stp	x19, x20, [sp, #16]
    3234:	str	x22, [x0]
    3238:	cbz	x1, 32f0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0xd0>
    323c:	mov	x20, x0
    3240:	mov	x0, x1
    3244:	mov	x21, x1
    3248:	bl	e80 <strlen@plt>
    324c:	str	x0, [sp, #56]
    3250:	mov	x19, x0
    3254:	cmp	x0, #0xf
    3258:	b.hi	32a0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0x80>  // b.pmore
    325c:	cmp	x0, #0x1
    3260:	b.ne	3284 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0x64>  // b.any
    3264:	ldrb	w0, [x21]
    3268:	str	x19, [x20, #8]
    326c:	strb	w0, [x20, #16]
    3270:	strb	wzr, [x22, x19]
    3274:	ldp	x19, x20, [sp, #16]
    3278:	ldp	x21, x22, [sp, #32]
    327c:	ldp	x29, x30, [sp], #64
    3280:	ret
    3284:	cbnz	x0, 32c0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0xa0>
    3288:	str	x19, [x20, #8]
    328c:	strb	wzr, [x22, x19]
    3290:	ldp	x19, x20, [sp, #16]
    3294:	ldp	x21, x22, [sp, #32]
    3298:	ldp	x29, x30, [sp], #64
    329c:	ret
    32a0:	add	x1, sp, #0x38
    32a4:	mov	x2, #0x0                   	// #0
    32a8:	mov	x0, x20
    32ac:	bl	1010 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long)@plt>
    32b0:	ldr	x1, [sp, #56]
    32b4:	mov	x22, x0
    32b8:	str	x0, [x20]
    32bc:	str	x1, [x20, #16]
    32c0:	mov	x2, x19
    32c4:	mov	x1, x21
    32c8:	mov	x0, x22
    32cc:	bl	e70 <memcpy@plt>
    32d0:	ldr	x19, [sp, #56]
    32d4:	ldr	x22, [x20]
    32d8:	str	x19, [x20, #8]
    32dc:	strb	wzr, [x22, x19]
    32e0:	ldp	x19, x20, [sp, #16]
    32e4:	ldp	x21, x22, [sp, #32]
    32e8:	ldp	x29, x30, [sp], #64
    32ec:	ret
    32f0:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x920>
    32f4:	add	x0, x0, #0x5f0
    32f8:	bl	f00 <std::__throw_logic_error(char const*)@plt>
    32fc:	nop

0000000000003300 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>:
    3300:	stp	x29, x30, [sp, #-48]!
    3304:	mov	x29, sp
    3308:	stp	x19, x20, [sp, #16]
    330c:	mov	x20, x0
    3310:	mov	x0, x1
    3314:	mov	x19, x1
    3318:	str	x21, [sp, #32]
    331c:	ldr	x21, [x20, #8]
    3320:	bl	e80 <strlen@plt>
    3324:	cmp	x21, x0
    3328:	b.eq	3340 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)+0x40>  // b.none
    332c:	mov	w0, #0x0                   	// #0
    3330:	ldr	x21, [sp, #32]
    3334:	ldp	x19, x20, [sp, #16]
    3338:	ldp	x29, x30, [sp], #48
    333c:	ret
    3340:	mov	w0, #0x1                   	// #1
    3344:	cbz	x21, 3330 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)+0x30>
    3348:	ldr	x0, [x20]
    334c:	mov	x2, x21
    3350:	mov	x1, x19
    3354:	bl	ea0 <memcmp@plt>
    3358:	ldr	x21, [sp, #32]
    335c:	cmp	w0, #0x0
    3360:	cset	w0, eq	// eq = none
    3364:	ldp	x19, x20, [sp, #16]
    3368:	ldp	x29, x30, [sp], #48
    336c:	ret
    3370:	nop
    3374:	nop
    3378:	nop
    337c:	nop

0000000000003380 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>:
    3380:	ldr	x5, [x0]
    3384:	mov	w8, #0xb0df                	// #45279
    3388:	mov	x2, x0
    338c:	movk	w8, #0x9908, lsl #16
    3390:	add	x7, x0, #0x718
    3394:	mov	x3, x0
    3398:	nop
    339c:	nop
    33a0:	and	x4, x5, #0xffffffff80000000
    33a4:	ldr	x5, [x3, #8]
    33a8:	ldr	x6, [x3, #3176]
    33ac:	and	x1, x5, #0x7fffffff
    33b0:	orr	x1, x1, x4
    33b4:	and	x4, x1, #0x1
    33b8:	eor	x1, x6, x1, lsr #1
    33bc:	umull	x4, w4, w8
    33c0:	eor	x1, x1, x4
    33c4:	str	x1, [x3], #8
    33c8:	cmp	x3, x7
    33cc:	b.ne	33a0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()+0x20>  // b.any
    33d0:	ldr	x4, [x0, #1816]
    33d4:	mov	w6, #0xb0df                	// #45279
    33d8:	add	x7, x0, #0xc60
    33dc:	movk	w6, #0x9908, lsl #16
    33e0:	and	x3, x4, #0xffffffff80000000
    33e4:	ldr	x4, [x2, #1824]
    33e8:	add	x2, x2, #0x8
    33ec:	ldur	x5, [x2, #-8]
    33f0:	and	x1, x4, #0x7fffffff
    33f4:	orr	x1, x1, x3
    33f8:	and	x3, x1, #0x1
    33fc:	eor	x1, x5, x1, lsr #1
    3400:	umull	x3, w3, w6
    3404:	eor	x1, x1, x3
    3408:	str	x1, [x2, #1808]
    340c:	cmp	x2, x7
    3410:	b.ne	33e0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()+0x60>  // b.any
    3414:	ldr	x2, [x0]
    3418:	str	xzr, [x0, #4992]
    341c:	ldr	x1, [x0, #4984]
    3420:	ldr	x3, [x0, #3168]
    3424:	bfxil	x1, x2, #0, #31
    3428:	and	x2, x1, #0x1
    342c:	eor	x1, x3, x1, lsr #1
    3430:	umull	x2, w2, w6
    3434:	eor	x1, x1, x2
    3438:	str	x1, [x0, #4984]
    343c:	ret

Disassembly of section .fini:

0000000000003440 <_fini>:
    3440:	paciasp
    3444:	stp	x29, x30, [sp, #-16]!
    3448:	mov	x29, sp
    344c:	ldp	x29, x30, [sp], #16
    3450:	autiasp
    3454:	ret
