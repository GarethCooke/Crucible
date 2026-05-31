
/home/gcooke/Development/Crucible/bench/pilot/09-arm-neon/build/pilot_blackscholes:     file format elf64-littleaarch64


Disassembly of section .init:

0000000000000e28 <_init>:
 e28:	paciasp
 e2c:	stp	x29, x30, [sp, #-16]!
 e30:	mov	x29, sp
 e34:	bl	1a74 <call_weak_fn>
 e38:	ldp	x29, x30, [sp], #16
 e3c:	autiasp
 e40:	ret

Disassembly of section .plt:

0000000000000e50 <.plt>:
     e50:	stp	x16, x30, [sp, #-16]!
     e54:	adrp	x16, 1f000 <__abi_tag+0x1ab24>
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
    10a0:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    10a4:	stp	x21, x22, [sp, #32]
    10a8:	mov	x21, x1
    10ac:	add	x1, x0, #0xcd0
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
    10d8:	bl	3a60 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>
    10dc:	cmp	w20, #0x1
    10e0:	b.le	19e8 <main+0x968>
    10e4:	add	x0, sp, #0xc8
    10e8:	adrp	x22, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    10ec:	adrp	x24, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    10f0:	add	x22, x22, #0xcd8
    10f4:	add	x24, x24, #0xce8
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
    1134:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    1138:	add	x1, x0, #0xcd0
    113c:	mov	x0, x20
    1140:	bl	3b40 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1144:	tbnz	w0, #0, 115c <main+0xdc>
    1148:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    114c:	mov	x0, x20
    1150:	add	x1, x1, #0xcf8
    1154:	bl	3b40 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1158:	tbz	w0, #0, 18d0 <main+0x850>
    115c:	mrs	x0, fpcr
    1160:	orr	x0, x0, #0x1000000
    1164:	msr	fpcr, x0
    1168:	mrs	x2, fpcr
    116c:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    1170:	tst	x2, #0x1000000
    1174:	adrp	x3, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    1178:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    117c:	add	x3, x3, #0xcc8
    1180:	add	x0, x0, #0xd40
    1184:	add	x1, x1, #0xcc0
    1188:	csel	x1, x3, x1, eq	// eq = none
    118c:	bl	1040 <printf@plt>
    1190:	mov	x0, x25
    1194:	bl	1f40 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    1198:	mov	x24, x0
    119c:	mov	x0, x25
    11a0:	bl	1f40 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11a4:	mov	x23, x0
    11a8:	mov	x0, x25
    11ac:	bl	1f40 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11b0:	mov	x22, x0
    11b4:	mov	x0, x25
    11b8:	bl	1f40 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11bc:	mov	x21, x0
    11c0:	mov	x0, x25
    11c4:	bl	1f40 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11c8:	mov	x20, x0
    11cc:	mov	x0, x25
    11d0:	bl	1f40 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
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
    127c:	b.ge	18ac <main+0x82c>  // b.tcont
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
    12d8:	b.ge	18a0 <main+0x820>  // b.tcont
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
    1334:	b.ge	18c8 <main+0x848>  // b.tcont
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
    1398:	b.ge	18b8 <main+0x838>  // b.tcont
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
    1424:	str	x2, [sp, #168]
    1428:	bl	3bc0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
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
    1460:	bl	3a60 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>
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
    1494:	b.eq	19fc <main+0x97c>  // b.none
    1498:	ldr	w0, [x23]
    149c:	cmp	w0, #0x22
    14a0:	b.eq	19f0 <main+0x970>  // b.none
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
    14cc:	bl	3bc0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    14d0:	ldr	x2, [sp, #168]
    14d4:	ldr	x5, [sp, #5272]
    14d8:	b	13b8 <main+0x338>
    14dc:	mov	x0, x19
    14e0:	str	x2, [sp, #168]
    14e4:	bl	3bc0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    14e8:	ldr	x2, [sp, #168]
    14ec:	ldr	x1, [sp, #5272]
    14f0:	b	1360 <main+0x2e0>
    14f4:	mov	x0, x19
    14f8:	str	x2, [sp, #168]
    14fc:	bl	3bc0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    1500:	ldr	x2, [sp, #168]
    1504:	ldr	x5, [sp, #5272]
    1508:	b	12fc <main+0x27c>
    150c:	mov	x0, x19
    1510:	str	x2, [sp, #168]
    1514:	bl	3bc0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
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
    1620:	str	s15, [x19, x28, lsl #2]
    1624:	add	x28, x28, #0x1
    1628:	cmp	x28, #0x100
    162c:	b.ne	1588 <main+0x508>  // b.any
    1630:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    1634:	add	x1, x0, #0xcd0
    1638:	ldr	x0, [sp, #176]
    163c:	bl	3b40 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1640:	tbnz	w0, #0, 1984 <main+0x904>
    1644:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    1648:	ldr	x0, [sp, #176]
    164c:	add	x1, x1, #0xd00
    1650:	bl	3b40 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1654:	mov	x6, x28
    1658:	mov	x5, x26
    165c:	mov	x4, x20
    1660:	mov	x3, x21
    1664:	mov	x2, x22
    1668:	mov	x1, x23
    166c:	tbnz	w0, #0, 1908 <main+0x888>
    1670:	mov	x0, x24
    1674:	bl	2f20 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1678:	movi	v30.2s, #0x0
    167c:	mov	x0, #0x1                   	// #1
    1680:	sub	x2, x26, #0x4
    1684:	add	x1, x19, x0, lsl #2
    1688:	ldr	s31, [x2, x0, lsl #2]
    168c:	add	x0, x0, #0x1
    1690:	ldur	s29, [x1, #-4]
    1694:	fabd	s31, s31, s29
    1698:	fcmpe	s31, s30
    169c:	fcsel	s30, s31, s30, gt
    16a0:	cmp	x0, #0x101
    16a4:	b.ne	1684 <main+0x604>  // b.any
    16a8:	mov	w0, #0xb717                	// #46871
    16ac:	fcvt	d0, s30
    16b0:	movk	w0, #0x38d1, lsl #16
    16b4:	fmov	s31, w0
    16b8:	fcmpe	s30, s31
    16bc:	b.ge	1960 <main+0x8e0>  // b.tcont
    16c0:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    16c4:	add	x0, x0, #0xda0
    16c8:	bl	1040 <printf@plt>
    16cc:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    16d0:	ldr	x1, [sp, #208]
    16d4:	mov	x2, x25
    16d8:	add	x0, x0, #0xdd8
    16dc:	bl	1040 <printf@plt>
    16e0:	scvtf	d15, x25
    16e4:	adrp	x0, 4000 <_IO_stdin_used+0x360>
    16e8:	movi	v13.2s, #0x0
    16ec:	lsr	x7, x25, #4
    16f0:	mov	x27, #0x1                   	// #1
    16f4:	ldr	d14, [x0, #32]
    16f8:	add	x28, x7, #0x1
    16fc:	add	x0, sp, #0xf0
    1700:	str	x0, [sp, #184]
    1704:	bl	f70 <std::chrono::_V2::steady_clock::now()@plt>
    1708:	ldr	x1, [sp, #216]
    170c:	str	x0, [sp, #168]
    1710:	cmp	x1, #0x6
    1714:	b.eq	1914 <main+0x894>  // b.none
    1718:	cmp	x1, #0x7
    171c:	b.ne	1740 <main+0x6c0>  // b.any
    1720:	ldr	x0, [sp, #208]
    1724:	mov	w2, #0x7561                	// #30049
    1728:	movk	w2, #0x6f74, lsl #16
    172c:	ldr	w1, [x0]
    1730:	cmp	w1, w2
    1734:	b.eq	19a8 <main+0x928>  // b.none
    1738:	nop
    173c:	nop
    1740:	mov	x6, x25
    1744:	mov	x5, x26
    1748:	mov	x4, x20
    174c:	mov	x3, x21
    1750:	mov	x2, x22
    1754:	mov	x1, x23
    1758:	mov	x0, x24
    175c:	bl	2f20 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1760:	bl	f70 <std::chrono::_V2::steady_clock::now()@plt>
    1764:	str	s13, [sp, #200]
    1768:	mov	x1, #0x0                   	// #0
    176c:	cbz	x25, 178c <main+0x70c>
    1770:	ldr	s30, [x26, x1, lsl #2]
    1774:	add	x1, x1, x28
    1778:	ldr	s31, [sp, #200]
    177c:	fadd	s31, s31, s30
    1780:	str	s31, [sp, #200]
    1784:	cmp	x1, x25
    1788:	b.cc	1770 <main+0x6f0>  // b.lo, b.ul, b.last
    178c:	ldr	x1, [sp, #168]
    1790:	ldr	s31, [sp, #200]
    1794:	sub	x2, x0, x1
    1798:	ldr	x0, [sp, #184]
    179c:	mov	w1, w27
    17a0:	scvtf	d1, x2
    17a4:	add	x3, x0, x27, lsl #3
    17a8:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    17ac:	add	x0, x0, #0xdf0
    17b0:	fdiv	d0, d1, d15
    17b4:	fmul	d1, d1, d14
    17b8:	fdiv	d1, d15, d1
    17bc:	stur	d0, [x3, #-8]
    17c0:	bl	1040 <printf@plt>
    17c4:	add	x27, x27, #0x1
    17c8:	cmp	x27, #0x6
    17cc:	b.ne	1704 <main+0x684>  // b.any
    17d0:	ldp	q30, q31, [sp, #240]
    17d4:	add	x4, sp, #0x200
    17d8:	add	x11, x19, #0x28
    17dc:	mov	x1, x11
    17e0:	mov	x2, #0x4                   	// #4
    17e4:	ldr	x3, [sp, #272]
    17e8:	mov	x0, x19
    17ec:	stur	q30, [x4, #-232]
    17f0:	add	x4, sp, #0x220
    17f4:	stur	q31, [x4, #-248]
    17f8:	str	x3, [sp, #312]
    17fc:	bl	1d80 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1800:	mov	x1, x11
    1804:	mov	x0, x19
    1808:	bl	1ca4 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    180c:	mov	x1, #0xcd6500000000        	// #225833675390976
    1810:	ldr	d0, [sp, #296]
    1814:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    1818:	movk	x1, #0x41cd, lsl #48
    181c:	add	x0, x0, #0xe18
    1820:	fmov	d1, x1
    1824:	fdiv	d1, d1, d0
    1828:	bl	1040 <printf@plt>
    182c:	mov	x0, x24
    1830:	mov	w19, #0x0                   	// #0
    1834:	bl	eb0 <free@plt>
    1838:	mov	x0, x23
    183c:	bl	eb0 <free@plt>
    1840:	mov	x0, x22
    1844:	bl	eb0 <free@plt>
    1848:	mov	x0, x21
    184c:	bl	eb0 <free@plt>
    1850:	mov	x0, x20
    1854:	bl	eb0 <free@plt>
    1858:	mov	x0, x26
    185c:	bl	eb0 <free@plt>
    1860:	ldr	x0, [sp, #176]
    1864:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1868:	mov	x12, #0x14a0                	// #5280
    186c:	ldp	d8, d9, [sp, #96]
    1870:	ldp	x29, x30, [sp]
    1874:	mov	w0, w19
    1878:	ldp	x19, x20, [sp, #16]
    187c:	ldp	x21, x22, [sp, #32]
    1880:	ldp	x23, x24, [sp, #48]
    1884:	ldp	x25, x26, [sp, #64]
    1888:	ldp	x27, x28, [sp, #80]
    188c:	ldp	d10, d11, [sp, #112]
    1890:	ldp	d12, d13, [sp, #128]
    1894:	ldp	d14, d15, [sp, #144]
    1898:	add	sp, sp, x12
    189c:	ret
    18a0:	mov	w0, #0x43160000            	// #1125515264
    18a4:	fmov	s31, w0
    18a8:	b	12f0 <main+0x270>
    18ac:	mov	w0, #0x43160000            	// #1125515264
    18b0:	fmov	s31, w0
    18b4:	b	1294 <main+0x214>
    18b8:	mov	w0, #0xd709                	// #55049
    18bc:	movk	w0, #0x3da3, lsl #16
    18c0:	fmov	s31, w0
    18c4:	b	13ac <main+0x32c>
    18c8:	mvni	v31.2s, #0xc0, lsl #24
    18cc:	b	1354 <main+0x2d4>
    18d0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    18d4:	mov	x0, x20
    18d8:	add	x1, x1, #0xd00
    18dc:	bl	3b40 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    18e0:	tbnz	w0, #0, 115c <main+0xdc>
    18e4:	adrp	x0, 1f000 <__abi_tag+0x1ab24>
    18e8:	ldr	x0, [x0, #4056]
    18ec:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    18f0:	add	x1, x1, #0xd08
    18f4:	ldr	x2, [x21]
    18f8:	ldr	x0, [x0]
    18fc:	bl	e90 <fprintf@plt>
    1900:	mov	w19, #0x1                   	// #1
    1904:	b	1860 <main+0x7e0>
    1908:	mov	x0, x24
    190c:	bl	2760 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1910:	b	1678 <main+0x5f8>
    1914:	ldr	x0, [sp, #208]
    1918:	mov	w2, #0x6373                	// #25459
    191c:	movk	w2, #0x6c61, lsl #16
    1920:	ldr	w1, [x0]
    1924:	cmp	w1, w2
    1928:	b.ne	1740 <main+0x6c0>  // b.any
    192c:	ldrh	w1, [x0, #4]
    1930:	mov	w0, #0x7261                	// #29281
    1934:	cmp	w1, w0
    1938:	b.ne	1740 <main+0x6c0>  // b.any
    193c:	mov	x6, x25
    1940:	mov	x5, x26
    1944:	mov	x4, x20
    1948:	mov	x3, x21
    194c:	mov	x2, x22
    1950:	mov	x1, x23
    1954:	mov	x0, x24
    1958:	bl	1fa0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    195c:	b	1760 <main+0x6e0>
    1960:	adrp	x0, 1f000 <__abi_tag+0x1ab24>
    1964:	ldr	x0, [x0, #4056]
    1968:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    196c:	add	x1, x1, #0xd68
    1970:	ldr	x2, [sp, #208]
    1974:	ldr	x0, [x0]
    1978:	bl	e90 <fprintf@plt>
    197c:	mov	w19, #0x1                   	// #1
    1980:	b	1860 <main+0x7e0>
    1984:	mov	x6, x28
    1988:	mov	x5, x26
    198c:	mov	x4, x20
    1990:	mov	x3, x21
    1994:	mov	x2, x22
    1998:	mov	x1, x23
    199c:	mov	x0, x24
    19a0:	bl	1fa0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    19a4:	b	1678 <main+0x5f8>
    19a8:	ldrh	w2, [x0, #4]
    19ac:	mov	w1, #0x6576                	// #25974
    19b0:	cmp	w2, w1
    19b4:	b.ne	1740 <main+0x6c0>  // b.any
    19b8:	ldrb	w0, [x0, #6]
    19bc:	cmp	w0, #0x63
    19c0:	b.ne	1740 <main+0x6c0>  // b.any
    19c4:	mov	x6, x25
    19c8:	mov	x5, x26
    19cc:	mov	x4, x20
    19d0:	mov	x3, x21
    19d4:	mov	x2, x22
    19d8:	mov	x1, x23
    19dc:	mov	x0, x24
    19e0:	bl	2760 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    19e4:	b	1760 <main+0x6e0>
    19e8:	mov	x25, #0x100000              	// #1048576
    19ec:	b	1130 <main+0xb0>
    19f0:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    19f4:	add	x0, x0, #0xcf0
    19f8:	bl	f80 <std::__throw_out_of_range(char const*)@plt>
    19fc:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    1a00:	add	x0, x0, #0xcf0
    1a04:	bl	ee0 <std::__throw_invalid_argument(char const*)@plt>
    1a08:	mov	x20, x0
    1a0c:	ldr	x0, [sp, #176]
    1a10:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1a14:	mov	x0, x20
    1a18:	bl	1000 <_Unwind_Resume@plt>
    1a1c:	ldr	w1, [x23]
    1a20:	mov	x20, x0
    1a24:	cbnz	w1, 1a2c <main+0x9ac>
    1a28:	str	w28, [x23]
    1a2c:	mov	x0, x19
    1a30:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1a34:	b	1a0c <main+0x98c>
    1a38:	nop
    1a3c:	nop

0000000000001a40 <_start>:
    1a40:	bti	c
    1a44:	mov	x29, #0x0                   	// #0
    1a48:	mov	x30, #0x0                   	// #0
    1a4c:	mov	x5, x0
    1a50:	ldr	x1, [sp]
    1a54:	add	x2, sp, #0x8
    1a58:	mov	x6, sp
    1a5c:	adrp	x0, 1f000 <__abi_tag+0x1ab24>
    1a60:	ldr	x0, [x0, #4024]
    1a64:	mov	x3, #0x0                   	// #0
    1a68:	mov	x4, #0x0                   	// #0
    1a6c:	bl	f10 <__libc_start_main@plt>
    1a70:	bl	fb0 <abort@plt>

0000000000001a74 <call_weak_fn>:
    1a74:	adrp	x0, 1f000 <__abi_tag+0x1ab24>
    1a78:	ldr	x0, [x0, #4048]
    1a7c:	cbz	x0, 1a84 <call_weak_fn+0x10>
    1a80:	b	1030 <__gmon_start__@plt>
    1a84:	ret
    1a88:	nop
    1a8c:	nop
    1a90:	nop
    1a94:	nop
    1a98:	nop
    1a9c:	nop

0000000000001aa0 <deregister_tm_clones>:
    1aa0:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1aa4:	add	x0, x0, #0x108
    1aa8:	adrp	x1, 20000 <memcpy@GLIBC_2.17>
    1aac:	add	x1, x1, #0x108
    1ab0:	cmp	x1, x0
    1ab4:	b.eq	1acc <deregister_tm_clones+0x2c>  // b.none
    1ab8:	adrp	x1, 1f000 <__abi_tag+0x1ab24>
    1abc:	ldr	x1, [x1, #4040]
    1ac0:	cbz	x1, 1acc <deregister_tm_clones+0x2c>
    1ac4:	mov	x16, x1
    1ac8:	br	x16
    1acc:	ret

0000000000001ad0 <register_tm_clones>:
    1ad0:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1ad4:	add	x0, x0, #0x108
    1ad8:	adrp	x1, 20000 <memcpy@GLIBC_2.17>
    1adc:	add	x1, x1, #0x108
    1ae0:	sub	x1, x1, x0
    1ae4:	lsr	x2, x1, #63
    1ae8:	add	x1, x2, x1, asr #3
    1aec:	asr	x1, x1, #1
    1af0:	cbz	x1, 1b08 <register_tm_clones+0x38>
    1af4:	adrp	x2, 1f000 <__abi_tag+0x1ab24>
    1af8:	ldr	x2, [x2, #4064]
    1afc:	cbz	x2, 1b08 <register_tm_clones+0x38>
    1b00:	mov	x16, x2
    1b04:	br	x16
    1b08:	ret

0000000000001b0c <__do_global_dtors_aux>:
    1b0c:	paciasp
    1b10:	stp	x29, x30, [sp, #-32]!
    1b14:	mov	x29, sp
    1b18:	str	x19, [sp, #16]
    1b1c:	adrp	x19, 20000 <memcpy@GLIBC_2.17>
    1b20:	ldrb	w0, [x19, #264]
    1b24:	tbnz	w0, #0, 1b4c <__do_global_dtors_aux+0x40>
    1b28:	adrp	x0, 1f000 <__abi_tag+0x1ab24>
    1b2c:	ldr	x0, [x0, #4032]
    1b30:	cbz	x0, 1b40 <__do_global_dtors_aux+0x34>
    1b34:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1b38:	ldr	x0, [x0, #248]
    1b3c:	bl	ed0 <__cxa_finalize@plt>
    1b40:	bl	1aa0 <deregister_tm_clones>
    1b44:	mov	w0, #0x1                   	// #1
    1b48:	strb	w0, [x19, #264]
    1b4c:	ldr	x19, [sp, #16]
    1b50:	ldp	x29, x30, [sp], #32
    1b54:	autiasp
    1b58:	ret
    1b5c:	nop

0000000000001b60 <frame_dummy>:
    1b60:	bti	c
    1b64:	b	1ad0 <register_tm_clones>
    1b68:	nop
    1b6c:	nop
    1b70:	nop
    1b74:	nop
    1b78:	nop
    1b7c:	nop

0000000000001b80 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1b80:	sub	x7, x2, #0x1
    1b84:	and	x8, x2, #0x1
    1b88:	add	x7, x7, x7, lsr #63
    1b8c:	asr	x7, x7, #1
    1b90:	cmp	x1, x7
    1b94:	b.ge	1c84 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x104>  // b.tcont
    1b98:	mov	x4, x1
    1b9c:	nop
    1ba0:	add	x3, x4, #0x1
    1ba4:	add	x5, x0, x3, lsl #4
    1ba8:	lsl	x6, x3, #4
    1bac:	lsl	x3, x3, #1
    1bb0:	ldr	d31, [x0, x6]
    1bb4:	ldur	d1, [x5, #-8]
    1bb8:	fcmpe	d31, d1
    1bbc:	b.mi	1bd4 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x54>  // b.first
    1bc0:	str	d31, [x0, x4, lsl #3]
    1bc4:	cmp	x3, x7
    1bc8:	b.ge	1bec <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x6c>  // b.tcont
    1bcc:	mov	x4, x3
    1bd0:	b	1ba0 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x20>
    1bd4:	sub	x3, x3, #0x1
    1bd8:	add	x5, x0, x3, lsl #3
    1bdc:	ldr	d31, [x0, x3, lsl #3]
    1be0:	str	d31, [x0, x4, lsl #3]
    1be4:	cmp	x3, x7
    1be8:	b.lt	1bcc <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x4c>  // b.tstop
    1bec:	cbz	x8, 1c48 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>
    1bf0:	sub	x4, x3, #0x1
    1bf4:	add	x4, x4, x4, lsr #63
    1bf8:	asr	x4, x4, #1
    1bfc:	cmp	x3, x1
    1c00:	b.le	1c2c <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>
    1c04:	ldr	d30, [x0, x4, lsl #3]
    1c08:	sub	x2, x4, #0x1
    1c0c:	add	x5, x0, x3, lsl #3
    1c10:	add	x2, x2, x2, lsr #63
    1c14:	lsl	x6, x3, #3
    1c18:	mov	x3, x4
    1c1c:	add	x7, x0, x4, lsl #3
    1c20:	asr	x2, x2, #1
    1c24:	fcmpe	d30, d0
    1c28:	b.mi	1c34 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xb4>  // b.first
    1c2c:	str	d0, [x5]
    1c30:	ret
    1c34:	str	d30, [x0, x6]
    1c38:	cmp	x1, x4
    1c3c:	b.ge	1c78 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xf8>  // b.tcont
    1c40:	mov	x4, x2
    1c44:	b	1c04 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>
    1c48:	sub	x2, x2, #0x2
    1c4c:	add	x2, x2, x2, lsr #63
    1c50:	cmp	x3, x2, asr #1
    1c54:	b.ne	1bf0 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>  // b.any
    1c58:	add	x3, x3, #0x1
    1c5c:	add	x2, x0, x3, lsl #4
    1c60:	lsl	x3, x3, #1
    1c64:	sub	x3, x3, #0x1
    1c68:	ldur	d31, [x2, #-8]
    1c6c:	str	d31, [x5]
    1c70:	add	x5, x0, x3, lsl #3
    1c74:	b	1bf0 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>
    1c78:	mov	x5, x7
    1c7c:	str	d0, [x5]
    1c80:	ret
    1c84:	add	x5, x0, x1, lsl #3
    1c88:	cbnz	x8, 1c2c <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>
    1c8c:	sub	x2, x2, #0x2
    1c90:	add	x2, x2, x2, lsr #63
    1c94:	cmp	x1, x2, asr #1
    1c98:	b.ne	1c2c <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>  // b.any
    1c9c:	mov	x3, x1
    1ca0:	b	1c58 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xd8>

0000000000001ca4 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1ca4:	cmp	x0, x1
    1ca8:	b.eq	1d74 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xd0>  // b.none
    1cac:	stp	x29, x30, [sp, #-64]!
    1cb0:	mov	x29, sp
    1cb4:	stp	x19, x20, [sp, #16]
    1cb8:	add	x19, x0, #0x8
    1cbc:	mov	x20, x0
    1cc0:	stp	x21, x22, [sp, #32]
    1cc4:	mov	x21, x1
    1cc8:	cmp	x1, x19
    1ccc:	b.eq	1d18 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x74>  // b.none
    1cd0:	mov	x22, #0x8                   	// #8
    1cd4:	stp	d14, d15, [sp, #48]
    1cd8:	nop
    1cdc:	nop
    1ce0:	ldr	d15, [x19]
    1ce4:	ldr	d14, [x20]
    1ce8:	fcmpe	d15, d14
    1cec:	b.mi	1d40 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x9c>  // b.first
    1cf0:	ldur	d31, [x19, #-8]
    1cf4:	sub	x2, x19, #0x8
    1cf8:	fcmpe	d15, d31
    1cfc:	b.mi	1d28 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>  // b.first
    1d00:	mov	x3, x19
    1d04:	str	d15, [x3]
    1d08:	add	x19, x19, #0x8
    1d0c:	cmp	x21, x19
    1d10:	b.ne	1ce0 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x3c>  // b.any
    1d14:	ldp	d14, d15, [sp, #48]
    1d18:	ldp	x19, x20, [sp, #16]
    1d1c:	ldp	x21, x22, [sp, #32]
    1d20:	ldp	x29, x30, [sp], #64
    1d24:	ret
    1d28:	mov	x3, x2
    1d2c:	str	d31, [x2, #8]
    1d30:	ldr	d31, [x2, #-8]!
    1d34:	fcmpe	d15, d31
    1d38:	b.mi	1d28 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>  // b.first
    1d3c:	b	1d04 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x60>
    1d40:	sub	x2, x19, x20
    1d44:	cmp	x2, #0x8
    1d48:	b.le	1d64 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc0>
    1d4c:	sub	x0, x22, x2
    1d50:	mov	x1, x20
    1d54:	add	x0, x19, x0
    1d58:	bl	f40 <memmove@plt>
    1d5c:	str	d15, [x20]
    1d60:	b	1d08 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>
    1d64:	b.ne	1d5c <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xb8>  // b.any
    1d68:	str	d14, [x19]
    1d6c:	str	d15, [x20]
    1d70:	b	1d08 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>
    1d74:	ret
    1d78:	nop
    1d7c:	nop

0000000000001d80 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1d80:	stp	x29, x30, [sp, #-48]!
    1d84:	mov	x29, sp
    1d88:	stp	x19, x20, [sp, #16]
    1d8c:	mov	x20, x0
    1d90:	sub	x0, x1, x0
    1d94:	cmp	x0, #0x80
    1d98:	b.le	1f0c <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x18c>
    1d9c:	asr	x10, x0, #3
    1da0:	mov	x9, x1
    1da4:	str	x21, [sp, #32]
    1da8:	mov	x21, x2
    1dac:	asr	x0, x0, #4
    1db0:	cbz	x21, 1ea8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x128>
    1db4:	lsl	x0, x0, #3
    1db8:	ldp	d28, d31, [x20]
    1dbc:	sub	x21, x21, #0x1
    1dc0:	add	x19, x20, #0x8
    1dc4:	ldr	d30, [x20, x0]
    1dc8:	ldur	d0, [x9, #-8]
    1dcc:	fcmpe	d31, d30
    1dd0:	b.mi	1f28 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x1a8>  // b.first
    1dd4:	fcmpe	d31, d0
    1dd8:	b.mi	1f38 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x1b8>  // b.first
    1ddc:	fcmpe	d30, d0
    1de0:	b.mi	1f18 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x198>  // b.first
    1de4:	str	d30, [x20]
    1de8:	str	d28, [x20, x0]
    1dec:	ldp	d31, d28, [x20]
    1df0:	mov	x3, x9
    1df4:	nop
    1df8:	nop
    1dfc:	nop
    1e00:	fcmpe	d31, d28
    1e04:	b.gt	1e48 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>
    1e08:	ldur	d29, [x3, #-8]
    1e0c:	sub	x0, x3, #0x8
    1e10:	fcmpe	d29, d31
    1e14:	b.gt	1e68 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1e18:	nop
    1e1c:	nop
    1e20:	cmp	x19, x0
    1e24:	b.cs	1e7c <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xfc>  // b.hs, b.nlast
    1e28:	mov	x1, x19
    1e2c:	mov	x3, x0
    1e30:	str	d29, [x1], #8
    1e34:	str	d28, [x0]
    1e38:	ldr	d31, [x20]
    1e3c:	ldr	d28, [x19, #8]
    1e40:	mov	x19, x1
    1e44:	b	1e00 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x80>
    1e48:	ldr	d28, [x19, #8]!
    1e4c:	fcmpe	d28, d31
    1e50:	b.mi	1e48 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>  // b.first
    1e54:	ldur	d29, [x3, #-8]
    1e58:	sub	x0, x3, #0x8
    1e5c:	fcmpe	d29, d31
    1e60:	b.gt	1e68 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1e64:	b	1e20 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xa0>
    1e68:	ldr	d29, [x0, #-8]!
    1e6c:	fcmpe	d29, d31
    1e70:	b.gt	1e68 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1e74:	cmp	x19, x0
    1e78:	b.cc	1e28 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xa8>  // b.lo, b.ul, b.last
    1e7c:	mov	x0, x19
    1e80:	mov	x1, x9
    1e84:	mov	x2, x21
    1e88:	bl	1d80 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1e8c:	sub	x0, x19, x20
    1e90:	cmp	x0, #0x80
    1e94:	b.le	1f08 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x188>
    1e98:	asr	x10, x0, #3
    1e9c:	mov	x9, x19
    1ea0:	asr	x0, x0, #4
    1ea4:	cbnz	x21, 1db4 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x34>
    1ea8:	sub	x1, x0, #0x1
    1eac:	b	1eb4 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x134>
    1eb0:	sub	x1, x1, #0x1
    1eb4:	ldr	d0, [x20, x1, lsl #3]
    1eb8:	mov	x2, x10
    1ebc:	mov	x0, x20
    1ec0:	bl	1b80 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1ec4:	cbnz	x1, 1eb0 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x130>
    1ec8:	sub	x0, x9, x20
    1ecc:	cmp	x0, #0x8
    1ed0:	b.le	1f08 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x188>
    1ed4:	nop
    1ed8:	nop
    1edc:	nop
    1ee0:	ldr	d0, [x9, #-8]!
    1ee4:	mov	x1, #0x0                   	// #0
    1ee8:	mov	x0, x20
    1eec:	ldr	d31, [x20]
    1ef0:	sub	x10, x9, x20
    1ef4:	asr	x2, x10, #3
    1ef8:	str	d31, [x9]
    1efc:	bl	1b80 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1f00:	cmp	x10, #0x8
    1f04:	b.gt	1ee0 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x160>
    1f08:	ldr	x21, [sp, #32]
    1f0c:	ldp	x19, x20, [sp, #16]
    1f10:	ldp	x29, x30, [sp], #48
    1f14:	ret
    1f18:	str	d0, [x20]
    1f1c:	stur	d28, [x9, #-8]
    1f20:	ldp	d31, d28, [x20]
    1f24:	b	1df0 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>
    1f28:	fcmpe	d30, d0
    1f2c:	b.mi	1de4 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>  // b.first
    1f30:	fcmpe	d31, d0
    1f34:	b.mi	1f18 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x198>  // b.first
    1f38:	stp	d31, d28, [x20]
    1f3c:	b	1df0 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>

0000000000001f40 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>:
    1f40:	stp	x29, x30, [sp, #-32]!
    1f44:	lsl	x2, x0, #2
    1f48:	mov	x29, sp
    1f4c:	mov	x1, #0x10                  	// #16
    1f50:	add	x0, sp, #0x18
    1f54:	str	xzr, [sp, #24]
    1f58:	bl	f20 <posix_memalign@plt>
    1f5c:	cbnz	w0, 1f6c <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]+0x2c>
    1f60:	ldr	x0, [sp, #24]
    1f64:	ldp	x29, x30, [sp], #32
    1f68:	ret
    1f6c:	adrp	x3, 1f000 <__abi_tag+0x1ab24>
    1f70:	ldr	x3, [x3, #4056]
    1f74:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    1f78:	mov	x2, #0x16                  	// #22
    1f7c:	add	x0, x0, #0xca8
    1f80:	mov	x1, #0x1                   	// #1
    1f84:	ldr	x3, [x3]
    1f88:	bl	ff0 <fwrite@plt>
    1f8c:	mov	w0, #0x1                   	// #1
    1f90:	bl	fe0 <exit@plt>
    1f94:	nop
    1f98:	nop
    1f9c:	nop

0000000000001fa0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    1fa0:	cbz	x6, 275c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    1fa4:	stp	x29, x30, [sp, #-160]!
    1fa8:	mov	x29, sp
    1fac:	stp	x23, x24, [sp, #48]
    1fb0:	mov	x24, x4
    1fb4:	mov	w4, #0xaa3b                	// #43579
    1fb8:	movk	w4, #0x3fb8, lsl #16
    1fbc:	mov	x23, x3
    1fc0:	mov	w3, #0x7218                	// #29208
    1fc4:	stp	x19, x20, [sp, #16]
    1fc8:	mov	x20, x0
    1fcc:	mov	w0, #0xc2b00000            	// #-1028653056
    1fd0:	movk	w3, #0x3f31, lsl #16
    1fd4:	mov	x19, x6
    1fd8:	stp	d8, d9, [sp, #80]
    1fdc:	fmov	s9, w0
    1fe0:	stp	d14, d15, [sp, #128]
    1fe4:	fmov	s14, w4
    1fe8:	stp	x21, x22, [sp, #32]
    1fec:	mov	x21, x1
    1ff0:	mov	x22, x2
    1ff4:	mov	w1, #0x8889                	// #34953
    1ff8:	mov	w2, #0xb61                 	// #2913
    1ffc:	movk	w2, #0x3ab6, lsl #16
    2000:	movk	w1, #0x3c08, lsl #16
    2004:	stp	x25, x26, [sp, #64]
    2008:	mov	x26, #0x0                   	// #0
    200c:	mov	x25, x5
    2010:	stp	d10, d11, [sp, #96]
    2014:	stp	d12, d13, [sp, #112]
    2018:	stp	w3, w2, [sp, #148]
    201c:	str	w1, [sp, #156]
    2020:	ldr	s12, [x22, x26, lsl #2]
    2024:	ldr	s15, [x24, x26, lsl #2]
    2028:	ldr	s13, [x20, x26, lsl #2]
    202c:	fcmp	s12, #0.0
    2030:	ldr	s8, [x21, x26, lsl #2]
    2034:	ldr	s11, [x23, x26, lsl #2]
    2038:	fmul	s10, s15, s15
    203c:	b.pl	20f4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    2040:	fmov	s0, s12
    2044:	bl	ec0 <sqrtf@plt>
    2048:	fmov	s31, s0
    204c:	fdiv	s0, s13, s8
    2050:	fmul	s15, s15, s31
    2054:	bl	1020 <logf@plt>
    2058:	fmov	s31, #5.000000000000000000e-01
    205c:	mov	w0, #0x3389                	// #13193
    2060:	fmov	s25, #1.000000000000000000e+00
    2064:	movk	w0, #0x3e6d, lsl #16
    2068:	mov	w1, #0x466f                	// #18031
    206c:	fmov	s19, #-5.000000000000000000e-01
    2070:	mov	w4, #0x1eea                	// #7914
    2074:	movk	w1, #0x3faa, lsl #16
    2078:	fmov	s29, w0
    207c:	movk	w4, #0xbfe9, lsl #16
    2080:	mov	w3, #0x778                 	// #1912
    2084:	fmadd	s10, s10, s31, s11
    2088:	movk	w3, #0x3fe4, lsl #16
    208c:	mov	w2, #0x8f89                	// #36745
    2090:	fmov	s20, w1
    2094:	movk	w2, #0xbeb6, lsl #16
    2098:	mov	w1, #0x85fa                	// #34298
    209c:	movk	w1, #0x3ea3, lsl #16
    20a0:	mov	w0, #0xaa3b                	// #43579
    20a4:	fmov	s22, w4
    20a8:	movk	w0, #0x3fb8, lsl #16
    20ac:	fmov	s23, w3
    20b0:	fmadd	s0, s12, s10, s0
    20b4:	fmov	s24, w2
    20b8:	fmov	s31, w1
    20bc:	fmov	s28, w0
    20c0:	fdiv	s0, s0, s15
    20c4:	fmadd	s21, s0, s29, s25
    20c8:	fmul	s29, s0, s19
    20cc:	fsub	s15, s0, s15
    20d0:	fmul	s29, s29, s0
    20d4:	fdiv	s25, s25, s21
    20d8:	fmul	s28, s29, s28
    20dc:	fmadd	s22, s25, s20, s22
    20e0:	fmadd	s23, s22, s25, s23
    20e4:	fmadd	s24, s23, s25, s24
    20e8:	fmadd	s31, s24, s25, s31
    20ec:	fmul	s31, s31, s25
    20f0:	b	21b8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    20f4:	fsqrt	s31, s12
    20f8:	fdiv	s0, s13, s8
    20fc:	fmul	s15, s15, s31
    2100:	bl	1020 <logf@plt>
    2104:	fmov	s29, #5.000000000000000000e-01
    2108:	fmadd	s10, s10, s29, s11
    210c:	fmadd	s0, s12, s10, s0
    2110:	fdiv	s0, s0, s15
    2114:	fcmpe	s0, #0.0
    2118:	fsub	s15, s0, s15
    211c:	b.mi	24fc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    2120:	mov	w0, #0x3389                	// #13193
    2124:	fmov	s31, #1.000000000000000000e+00
    2128:	mov	w4, #0x466f                	// #18031
    212c:	movk	w0, #0x3e6d, lsl #16
    2130:	mov	w3, #0x1eea                	// #7914
    2134:	fmov	s29, #-5.000000000000000000e-01
    2138:	movk	w4, #0x3faa, lsl #16
    213c:	movk	w3, #0xbfe9, lsl #16
    2140:	fmov	s22, w0
    2144:	mov	w2, #0x778                 	// #1912
    2148:	mov	w1, #0x8f89                	// #36745
    214c:	fmov	s21, w4
    2150:	movk	w2, #0x3fe4, lsl #16
    2154:	movk	w1, #0xbeb6, lsl #16
    2158:	fmov	s23, w3
    215c:	mov	w0, #0x85fa                	// #34298
    2160:	fmov	s24, w2
    2164:	movk	w0, #0x3ea3, lsl #16
    2168:	fmov	s25, w1
    216c:	fmov	s28, w0
    2170:	fmul	s29, s0, s29
    2174:	fmadd	s22, s0, s22, s31
    2178:	fmul	s29, s29, s0
    217c:	fcmpe	s29, s9
    2180:	fdiv	s31, s31, s22
    2184:	fmadd	s23, s31, s21, s23
    2188:	fmadd	s24, s31, s23, s24
    218c:	fmadd	s25, s31, s24, s25
    2190:	fmadd	s28, s31, s25, s28
    2194:	fmul	s31, s31, s28
    2198:	b.mi	260c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    219c:	mov	w0, #0x42b00000            	// #1118830592
    21a0:	fmov	s28, w0
    21a4:	fcmpe	s29, s28
    21a8:	b.gt	2258 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    21ac:	fmul	s28, s29, s14
    21b0:	fcmpe	s28, #0.0
    21b4:	b.ge	266c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    21b8:	fmov	s23, #5.000000000000000000e-01
    21bc:	mov	w0, #0x7218                	// #29208
    21c0:	mov	w3, #0xb61                 	// #2913
    21c4:	movk	w0, #0x3f31, lsl #16
    21c8:	mov	w2, #0x8889                	// #34953
    21cc:	fmov	s24, #1.000000000000000000e+00
    21d0:	movk	w3, #0x3ab6, lsl #16
    21d4:	movk	w2, #0x3c08, lsl #16
    21d8:	fmov	s25, w0
    21dc:	mov	w1, #0xaaab                	// #43691
    21e0:	mov	w0, #0xaaab                	// #43691
    21e4:	fsub	s28, s28, s23
    21e8:	movk	w1, #0x3d2a, lsl #16
    21ec:	movk	w0, #0x3e2a, lsl #16
    21f0:	fmov	s18, w3
    21f4:	mov	w4, #0x422a                	// #16938
    21f8:	fmov	s20, w2
    21fc:	movk	w4, #0x3ecc, lsl #16
    2200:	fmov	s21, w1
    2204:	fmov	s22, w0
    2208:	fmov	s19, w4
    220c:	fcvtzs	s28, s28
    2210:	scvtf	s28, s28
    2214:	fmsub	s25, s28, s25, s29
    2218:	fcvtzs	w0, s28
    221c:	fmadd	s28, s25, s18, s20
    2220:	add	w0, w0, #0x7f
    2224:	fmov	s30, w0
    2228:	fmadd	s28, s25, s28, s21
    222c:	fmadd	s28, s25, s28, s22
    2230:	shl	v29.2s, v30.2s, #23
    2234:	fmadd	s23, s25, s28, s23
    2238:	fmadd	s23, s25, s23, s24
    223c:	fmadd	s24, s25, s23, s24
    2240:	fmul	s29, s24, s29
    2244:	fmul	s29, s29, s19
    2248:	fcmpe	s0, #0.0
    224c:	fmul	s31, s31, s29
    2250:	b.mi	2270 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    2254:	b	2268 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2258:	mov	w0, #0x484f                	// #18511
    225c:	movk	w0, #0x7e46, lsl #16
    2260:	fmov	s29, w0
    2264:	fmul	s31, s31, s29
    2268:	fmov	s29, #1.000000000000000000e+00
    226c:	fsub	s31, s29, s31
    2270:	fnmul	s30, s11, s12
    2274:	fmul	s31, s13, s31
    2278:	movi	v29.2s, #0x0
    227c:	fcmpe	s30, s9
    2280:	b.mi	2320 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2284:	mov	w0, #0x42b00000            	// #1118830592
    2288:	fmov	s29, w0
    228c:	fcmpe	s30, s29
    2290:	b.gt	2618 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2294:	fmul	s28, s30, s14
    2298:	fcmpe	s28, #0.0
    229c:	b.ge	2628 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    22a0:	fmov	s27, #5.000000000000000000e-01
    22a4:	mov	w0, #0x7218                	// #29208
    22a8:	mov	w3, #0xb61                 	// #2913
    22ac:	movk	w0, #0x3f31, lsl #16
    22b0:	mov	w2, #0x8889                	// #34953
    22b4:	fmov	s29, #1.000000000000000000e+00
    22b8:	movk	w3, #0x3ab6, lsl #16
    22bc:	movk	w2, #0x3c08, lsl #16
    22c0:	fmov	s22, w0
    22c4:	mov	w1, #0xaaab                	// #43691
    22c8:	mov	w0, #0xaaab                	// #43691
    22cc:	fsub	s28, s28, s27
    22d0:	movk	w1, #0x3d2a, lsl #16
    22d4:	movk	w0, #0x3e2a, lsl #16
    22d8:	fmov	s23, w3
    22dc:	fmov	s24, w2
    22e0:	fmov	s25, w1
    22e4:	fmov	s26, w0
    22e8:	fcvtzs	s28, s28
    22ec:	scvtf	s28, s28
    22f0:	fmsub	s30, s28, s22, s30
    22f4:	fcvtzs	w0, s28
    22f8:	fmadd	s24, s30, s23, s24
    22fc:	fmadd	s25, s30, s24, s25
    2300:	add	w0, w0, #0x7f
    2304:	fmov	s28, w0
    2308:	fmadd	s26, s30, s25, s26
    230c:	fmadd	s27, s30, s26, s27
    2310:	shl	v28.2s, v28.2s, #23
    2314:	fmadd	s27, s30, s27, s29
    2318:	fmadd	s29, s30, s27, s29
    231c:	fmul	s29, s29, s28
    2320:	fcmpe	s15, #0.0
    2324:	fmul	s29, s8, s29
    2328:	b.mi	2584 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    232c:	mov	w0, #0x3389                	// #13193
    2330:	fmov	s30, #1.000000000000000000e+00
    2334:	mov	w4, #0x466f                	// #18031
    2338:	movk	w0, #0x3e6d, lsl #16
    233c:	mov	w3, #0x1eea                	// #7914
    2340:	fmov	s27, #-5.000000000000000000e-01
    2344:	movk	w4, #0x3faa, lsl #16
    2348:	movk	w3, #0xbfe9, lsl #16
    234c:	fmov	s23, w0
    2350:	mov	w2, #0x778                 	// #1912
    2354:	mov	w1, #0x8f89                	// #36745
    2358:	fmov	s22, w4
    235c:	movk	w2, #0x3fe4, lsl #16
    2360:	movk	w1, #0xbeb6, lsl #16
    2364:	fmov	s24, w3
    2368:	mov	w0, #0x85fa                	// #34298
    236c:	fmov	s25, w2
    2370:	movk	w0, #0x3ea3, lsl #16
    2374:	fmov	s26, w1
    2378:	fmov	s28, w0
    237c:	fmul	s27, s15, s27
    2380:	fmadd	s23, s15, s23, s30
    2384:	fmul	s27, s27, s15
    2388:	fcmpe	s27, s9
    238c:	fdiv	s30, s30, s23
    2390:	fmadd	s24, s30, s22, s24
    2394:	fmadd	s25, s30, s24, s25
    2398:	fmadd	s26, s30, s25, s26
    239c:	fmadd	s28, s30, s26, s28
    23a0:	fmul	s30, s30, s28
    23a4:	b.mi	2604 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    23a8:	mov	w0, #0x42b00000            	// #1118830592
    23ac:	fmov	s28, w0
    23b0:	fcmpe	s27, s28
    23b4:	b.gt	24ac <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    23b8:	nop
    23bc:	nop
    23c0:	fmul	s28, s27, s14
    23c4:	fcmpe	s28, #0.0
    23c8:	b.ge	26e4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    23cc:	fmov	s25, #5.000000000000000000e-01
    23d0:	mov	w0, #0x7218                	// #29208
    23d4:	mov	w4, #0xb61                 	// #2913
    23d8:	movk	w0, #0x3f31, lsl #16
    23dc:	mov	w2, #0x8889                	// #34953
    23e0:	fmov	s26, #1.000000000000000000e+00
    23e4:	movk	w4, #0x3ab6, lsl #16
    23e8:	movk	w2, #0x3c08, lsl #16
    23ec:	fmov	s19, w0
    23f0:	mov	w1, #0xaaab                	// #43691
    23f4:	mov	w0, #0xaaab                	// #43691
    23f8:	fsub	s28, s28, s25
    23fc:	movk	w1, #0x3d2a, lsl #16
    2400:	movk	w0, #0x3e2a, lsl #16
    2404:	fmov	s20, w4
    2408:	mov	w3, #0x422a                	// #16938
    240c:	fmov	s22, w2
    2410:	movk	w3, #0x3ecc, lsl #16
    2414:	fmov	s23, w1
    2418:	fmov	s24, w0
    241c:	fmov	s21, w3
    2420:	fcvtzs	s28, s28
    2424:	scvtf	s28, s28
    2428:	fmsub	s27, s28, s19, s27
    242c:	fcvtzs	w0, s28
    2430:	fmadd	s22, s27, s20, s22
    2434:	add	w0, w0, #0x7f
    2438:	fmov	s28, w0
    243c:	fmadd	s23, s27, s22, s23
    2440:	fmadd	s24, s27, s23, s24
    2444:	shl	v28.2s, v28.2s, #23
    2448:	fmadd	s25, s27, s24, s25
    244c:	fmadd	s25, s27, s25, s26
    2450:	fmadd	s26, s27, s25, s26
    2454:	fmul	s28, s26, s28
    2458:	fmul	s28, s28, s21
    245c:	fcmpe	s15, #0.0
    2460:	fmul	s30, s30, s28
    2464:	b.mi	24e4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    2468:	fmov	s28, #1.000000000000000000e+00
    246c:	fsub	s30, s28, s30
    2470:	fmsub	s31, s29, s30, s31
    2474:	str	s31, [x25, x26, lsl #2]
    2478:	add	x26, x26, #0x1
    247c:	cmp	x26, x19
    2480:	b.ne	2020 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2484:	ldp	d8, d9, [sp, #80]
    2488:	ldp	x19, x20, [sp, #16]
    248c:	ldp	x21, x22, [sp, #32]
    2490:	ldp	x23, x24, [sp, #48]
    2494:	ldp	x25, x26, [sp, #64]
    2498:	ldp	d10, d11, [sp, #96]
    249c:	ldp	d12, d13, [sp, #112]
    24a0:	ldp	d14, d15, [sp, #128]
    24a4:	ldp	x29, x30, [sp], #160
    24a8:	ret
    24ac:	mov	w0, #0x484f                	// #18511
    24b0:	movk	w0, #0x7e46, lsl #16
    24b4:	fmov	s28, w0
    24b8:	fmul	s30, s30, s28
    24bc:	fmov	s28, #1.000000000000000000e+00
    24c0:	fsub	s30, s28, s30
    24c4:	fmsub	s31, s29, s30, s31
    24c8:	str	s31, [x25, x26, lsl #2]
    24cc:	add	x26, x26, #0x1
    24d0:	cmp	x26, x19
    24d4:	b.ne	2020 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    24d8:	b	2484 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    24dc:	movi	v28.2s, #0x0
    24e0:	fmul	s30, s30, s28
    24e4:	fmsub	s30, s29, s30, s31
    24e8:	str	s30, [x25, x26, lsl #2]
    24ec:	add	x26, x26, #0x1
    24f0:	cmp	x19, x26
    24f4:	b.ne	2020 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    24f8:	b	2484 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    24fc:	mov	w0, #0x3389                	// #13193
    2500:	fmov	s31, #1.000000000000000000e+00
    2504:	mov	w4, #0x466f                	// #18031
    2508:	movk	w0, #0x3e6d, lsl #16
    250c:	mov	w3, #0x1eea                	// #7914
    2510:	fmul	s29, s0, s29
    2514:	movk	w4, #0x3faa, lsl #16
    2518:	movk	w3, #0xbfe9, lsl #16
    251c:	fmov	s22, w0
    2520:	mov	w2, #0x778                 	// #1912
    2524:	mov	w1, #0x8f89                	// #36745
    2528:	fmov	s21, w4
    252c:	movk	w2, #0x3fe4, lsl #16
    2530:	movk	w1, #0xbeb6, lsl #16
    2534:	fmov	s23, w3
    2538:	mov	w0, #0x85fa                	// #34298
    253c:	fmov	s24, w2
    2540:	movk	w0, #0x3ea3, lsl #16
    2544:	fmov	s25, w1
    2548:	fmov	s28, w0
    254c:	fnmul	s29, s0, s29
    2550:	fmsub	s22, s0, s22, s31
    2554:	fcmpe	s29, s9
    2558:	fdiv	s31, s31, s22
    255c:	fmadd	s23, s31, s21, s23
    2560:	fmadd	s24, s31, s23, s24
    2564:	fmadd	s25, s31, s24, s25
    2568:	fmadd	s28, s31, s25, s28
    256c:	fmul	s31, s31, s28
    2570:	b.mi	2578 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    2574:	b	21ac <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    2578:	movi	v29.2s, #0x0
    257c:	fmul	s31, s31, s29
    2580:	b	2270 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2584:	mov	w0, #0x3389                	// #13193
    2588:	fmov	s30, #1.000000000000000000e+00
    258c:	mov	w4, #0x466f                	// #18031
    2590:	movk	w0, #0x3e6d, lsl #16
    2594:	mov	w3, #0x1eea                	// #7914
    2598:	fmov	s27, #5.000000000000000000e-01
    259c:	movk	w4, #0x3faa, lsl #16
    25a0:	movk	w3, #0xbfe9, lsl #16
    25a4:	fmov	s23, w0
    25a8:	mov	w2, #0x778                 	// #1912
    25ac:	mov	w1, #0x8f89                	// #36745
    25b0:	fmov	s22, w4
    25b4:	movk	w2, #0x3fe4, lsl #16
    25b8:	movk	w1, #0xbeb6, lsl #16
    25bc:	fmov	s24, w3
    25c0:	mov	w0, #0x85fa                	// #34298
    25c4:	fmov	s25, w2
    25c8:	movk	w0, #0x3ea3, lsl #16
    25cc:	fmov	s26, w1
    25d0:	fmov	s28, w0
    25d4:	fmul	s27, s15, s27
    25d8:	fmsub	s23, s15, s23, s30
    25dc:	fnmul	s27, s15, s27
    25e0:	fcmpe	s27, s9
    25e4:	fdiv	s30, s30, s23
    25e8:	fmadd	s24, s30, s22, s24
    25ec:	fmadd	s25, s24, s30, s25
    25f0:	fmadd	s26, s25, s30, s26
    25f4:	fmadd	s28, s30, s26, s28
    25f8:	fmul	s30, s30, s28
    25fc:	b.mi	24dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2600:	b	23c0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2604:	movi	v28.2s, #0x0
    2608:	b	24b8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    260c:	movi	v29.2s, #0x0
    2610:	fmul	s31, s31, s29
    2614:	b	2268 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2618:	mov	w7, #0x829c                	// #33436
    261c:	movk	w7, #0x7ef8, lsl #16
    2620:	fmov	s29, w7
    2624:	b	2320 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    2628:	fmov	s27, #5.000000000000000000e-01
    262c:	ldr	s24, [sp, #148]
    2630:	mov	w0, #0xaaab                	// #43691
    2634:	movk	w0, #0x3e2a, lsl #16
    2638:	mov	w1, #0xaaab                	// #43691
    263c:	fmov	s29, #1.000000000000000000e+00
    2640:	movk	w1, #0x3d2a, lsl #16
    2644:	fmov	s26, w0
    2648:	fadd	s28, s28, s27
    264c:	fmov	s25, w1
    2650:	fcvtzs	s28, s28
    2654:	scvtf	s28, s28
    2658:	fmsub	s30, s28, s24, s30
    265c:	fcvtzs	w0, s28
    2660:	ldp	s24, s28, [sp, #152]
    2664:	fmadd	s24, s30, s24, s28
    2668:	b	22fc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    266c:	fmov	s24, #5.000000000000000000e-01
    2670:	ldr	s30, [sp, #148]
    2674:	mov	w1, #0xaaab                	// #43691
    2678:	movk	w1, #0x3d2a, lsl #16
    267c:	mov	w0, #0xaaab                	// #43691
    2680:	fmov	s25, #1.000000000000000000e+00
    2684:	movk	w0, #0x3e2a, lsl #16
    2688:	mov	w2, #0x422a                	// #16938
    268c:	fmov	s22, w1
    2690:	movk	w2, #0x3ecc, lsl #16
    2694:	fadd	s28, s28, s24
    2698:	fmov	s23, w0
    269c:	fmov	s21, w2
    26a0:	fcvtzs	s28, s28
    26a4:	scvtf	s28, s28
    26a8:	fmsub	s29, s28, s30, s29
    26ac:	fcvtzs	w7, s28
    26b0:	ldp	s28, s30, [sp, #152]
    26b4:	fmadd	s20, s29, s28, s30
    26b8:	add	w7, w7, #0x7f
    26bc:	fmov	s30, w7
    26c0:	fmadd	s22, s29, s20, s22
    26c4:	fmadd	s23, s29, s22, s23
    26c8:	shl	v28.2s, v30.2s, #23
    26cc:	fmadd	s24, s29, s23, s24
    26d0:	fmadd	s24, s29, s24, s25
    26d4:	fmadd	s29, s29, s24, s25
    26d8:	fmul	s29, s29, s28
    26dc:	fmul	s29, s29, s21
    26e0:	b	2248 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    26e4:	fmov	s25, #5.000000000000000000e-01
    26e8:	ldr	s21, [sp, #148]
    26ec:	mov	w0, #0xaaab                	// #43691
    26f0:	movk	w0, #0x3e2a, lsl #16
    26f4:	mov	w1, #0xaaab                	// #43691
    26f8:	fmov	s26, #1.000000000000000000e+00
    26fc:	movk	w1, #0x3d2a, lsl #16
    2700:	mov	w2, #0x422a                	// #16938
    2704:	fmov	s24, w0
    2708:	movk	w2, #0x3ecc, lsl #16
    270c:	fadd	s28, s28, s25
    2710:	fmov	s23, w1
    2714:	fmov	s22, w2
    2718:	fcvtzs	s28, s28
    271c:	scvtf	s28, s28
    2720:	fmsub	s27, s28, s21, s27
    2724:	fcvtzs	w0, s28
    2728:	ldp	s21, s28, [sp, #152]
    272c:	fmadd	s21, s27, s21, s28
    2730:	add	w0, w0, #0x7f
    2734:	fmov	s28, w0
    2738:	fmadd	s23, s27, s21, s23
    273c:	fmadd	s24, s27, s23, s24
    2740:	shl	v28.2s, v28.2s, #23
    2744:	fmadd	s25, s27, s24, s25
    2748:	fmadd	s25, s27, s25, s26
    274c:	fmadd	s26, s27, s25, s26
    2750:	fmul	s28, s26, s28
    2754:	fmul	s28, s28, s22
    2758:	b	245c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    275c:	ret

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

0000000000002f20 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    2f20:	stp	x29, x30, [sp, #-160]!
    2f24:	mov	x29, sp
    2f28:	stp	x19, x20, [sp, #16]
    2f2c:	mov	x20, x0
    2f30:	stp	x21, x22, [sp, #32]
    2f34:	mov	x21, x1
    2f38:	mov	x22, x2
    2f3c:	stp	x23, x24, [sp, #48]
    2f40:	mov	x24, x6
    2f44:	mov	x23, x3
    2f48:	stp	x25, x26, [sp, #64]
    2f4c:	mov	x25, x4
    2f50:	mov	x26, x5
    2f54:	stp	d8, d9, [sp, #80]
    2f58:	stp	d10, d11, [sp, #96]
    2f5c:	stp	d12, d13, [sp, #112]
    2f60:	stp	d14, d15, [sp, #128]
    2f64:	cmp	x6, #0x3
    2f68:	b.ls	3a4c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xb2c>  // b.plast
    2f6c:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2f70:	sub	x19, x6, #0x4
    2f74:	and	x0, x19, #0xfffffffffffffffc
    2f78:	mov	x7, #0x0                   	// #0
    2f7c:	ldr	q20, [x1, #3712]
    2f80:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2f84:	mov	x8, #0x0                   	// #0
    2f88:	add	x0, x0, #0x4
    2f8c:	ldr	q1, [x1, #3728]
    2f90:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2f94:	ldr	q11, [x1, #3744]
    2f98:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2f9c:	ldr	q12, [x1, #3760]
    2fa0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fa4:	ldr	q13, [x1, #3776]
    2fa8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fac:	ldr	q14, [x1, #3792]
    2fb0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fb4:	ldr	q15, [x1, #3808]
    2fb8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fbc:	ldr	q4, [x1, #3824]
    2fc0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fc4:	ldr	q5, [x1, #3840]
    2fc8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fcc:	ldr	q6, [x1, #3856]
    2fd0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fd4:	ldr	q7, [x1, #3872]
    2fd8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fdc:	ldr	q16, [x1, #3888]
    2fe0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fe4:	ldr	q17, [x1, #3904]
    2fe8:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2fec:	ldr	q18, [x1, #3920]
    2ff0:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    2ff4:	movi	v26.4s, #0x7f, msl #16
    2ff8:	fmov	v25.4s, #5.000000000000000000e-01
    2ffc:	ldr	q9, [x21, x7]
    3000:	movi	v23.4s, #0x7f
    3004:	fmov	v31.4s, #-1.000000000000000000e+00
    3008:	fmov	v29.4s, #1.000000000000000000e+00
    300c:	fmov	v10.4s, #-5.000000000000000000e-01
    3010:	add	x8, x8, #0x4
    3014:	ldr	q30, [x20, x7]
    3018:	mov	v0.16b, v25.16b
    301c:	ldr	q19, [x1, #3936]
    3020:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    3024:	ldr	q24, [x1, #3952]
    3028:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    302c:	fdiv	v27.4s, v30.4s, v9.4s
    3030:	ldr	q21, [x22, x7]
    3034:	ldr	q22, [x23, x7]
    3038:	and	v26.16b, v26.16b, v27.16b
    303c:	sshr	v27.4s, v27.4s, #23
    3040:	ldr	q30, [x25, x7]
    3044:	orr	v26.16b, v26.16b, v24.16b
    3048:	ldr	q24, [x1, #3968]
    304c:	sub	v27.4s, v27.4s, v23.4s
    3050:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    3054:	fmul	v28.4s, v21.4s, v22.4s
    3058:	fmul	v3.4s, v30.4s, v30.4s
    305c:	fcmge	v8.4s, v26.4s, v24.4s
    3060:	fmul	v24.4s, v25.4s, v26.4s
    3064:	fneg	v28.4s, v28.4s
    3068:	fmla	v22.4s, v25.4s, v3.4s
    306c:	bit	v26.16b, v24.16b, v8.16b
    3070:	sub	v27.4s, v27.4s, v8.4s
    3074:	ldr	q8, [x1, #3984]
    3078:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    307c:	fmax	v28.4s, v28.4s, v4.4s
    3080:	ldr	q24, [x1, #4000]
    3084:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    3088:	fadd	v31.4s, v31.4s, v26.4s
    308c:	fsqrt	v26.4s, v21.4s
    3090:	scvtf	v27.4s, v27.4s
    3094:	fmin	v28.4s, v28.4s, v5.4s
    3098:	fmul	v30.4s, v30.4s, v26.4s
    309c:	fmla	v8.4s, v24.4s, v31.4s
    30a0:	ldr	q24, [x1, #4016]
    30a4:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    30a8:	fmul	v26.4s, v28.4s, v6.4s
    30ac:	fmla	v24.4s, v8.4s, v31.4s
    30b0:	ldr	q8, [x1, #4032]
    30b4:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    30b8:	frintn	v26.4s, v26.4s
    30bc:	fmla	v8.4s, v24.4s, v31.4s
    30c0:	ldr	q24, [x1, #4048]
    30c4:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    30c8:	ldr	q3, [x1, #4064]
    30cc:	adrp	x1, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    30d0:	fmls	v28.4s, v26.4s, v20.4s
    30d4:	fmla	v24.4s, v8.4s, v31.4s
    30d8:	mov	v8.16b, v16.16b
    30dc:	fcvtzs	v26.4s, v26.4s
    30e0:	fmla	v3.4s, v24.4s, v31.4s
    30e4:	ldr	q24, [x1, #4080]
    30e8:	adrp	x1, 4000 <_IO_stdin_used+0x360>
    30ec:	fmla	v8.4s, v7.4s, v28.4s
    30f0:	add	v26.4s, v26.4s, v23.4s
    30f4:	fmla	v24.4s, v3.4s, v31.4s
    30f8:	mov	v3.16b, v17.16b
    30fc:	shl	v26.4s, v26.4s, #23
    3100:	fmla	v3.4s, v8.4s, v28.4s
    3104:	ldr	q8, [x1]
    3108:	adrp	x1, 4000 <_IO_stdin_used+0x360>
    310c:	ldr	q2, [x1, #16]
    3110:	fmla	v8.4s, v24.4s, v31.4s
    3114:	mov	v24.16b, v18.16b
    3118:	fmla	v2.4s, v8.4s, v31.4s
    311c:	fmla	v24.4s, v3.4s, v28.4s
    3120:	mov	v3.16b, v29.16b
    3124:	fmul	v8.4s, v31.4s, v31.4s
    3128:	fmla	v0.4s, v24.4s, v28.4s
    312c:	fmul	v24.4s, v31.4s, v8.4s
    3130:	fmla	v3.4s, v0.4s, v28.4s
    3134:	fmul	v24.4s, v24.4s, v2.4s
    3138:	mov	v2.16b, v29.16b
    313c:	fmls	v24.4s, v8.4s, v25.4s
    3140:	mov	v8.16b, v12.16b
    3144:	fmla	v2.4s, v3.4s, v28.4s
    3148:	mov	v3.16b, v16.16b
    314c:	fadd	v31.4s, v31.4s, v24.4s
    3150:	fmul	v26.4s, v2.4s, v26.4s
    3154:	mov	v2.16b, v18.16b
    3158:	fmla	v31.4s, v27.4s, v20.4s
    315c:	fmul	v26.4s, v26.4s, v9.4s
    3160:	mov	v9.16b, v13.16b
    3164:	fmla	v31.4s, v22.4s, v21.4s
    3168:	mov	v21.16b, v29.16b
    316c:	fdiv	v31.4s, v31.4s, v30.4s
    3170:	fsub	v30.4s, v31.4s, v30.4s
    3174:	fmul	v27.4s, v31.4s, v31.4s
    3178:	fabs	v24.4s, v31.4s
    317c:	fcmlt	v31.4s, v31.4s, #0.0
    3180:	fmul	v28.4s, v30.4s, v30.4s
    3184:	fmul	v27.4s, v27.4s, v10.4s
    3188:	fmla	v21.4s, v1.4s, v24.4s
    318c:	fabs	v22.4s, v30.4s
    3190:	mov	v24.16b, v29.16b
    3194:	fmul	v28.4s, v28.4s, v10.4s
    3198:	fmax	v27.4s, v27.4s, v4.4s
    319c:	fcmlt	v30.4s, v30.4s, #0.0
    31a0:	fmla	v24.4s, v1.4s, v22.4s
    31a4:	fmax	v28.4s, v28.4s, v4.4s
    31a8:	fmin	v27.4s, v27.4s, v5.4s
    31ac:	fdiv	v21.4s, v29.4s, v21.4s
    31b0:	fmin	v28.4s, v28.4s, v5.4s
    31b4:	fmul	v22.4s, v27.4s, v6.4s
    31b8:	fmla	v8.4s, v11.4s, v21.4s
    31bc:	fdiv	v24.4s, v29.4s, v24.4s
    31c0:	fmul	v10.4s, v28.4s, v6.4s
    31c4:	frintn	v22.4s, v22.4s
    31c8:	fmla	v9.4s, v8.4s, v21.4s
    31cc:	mov	v8.16b, v14.16b
    31d0:	frintn	v10.4s, v10.4s
    31d4:	fmls	v27.4s, v22.4s, v20.4s
    31d8:	fmla	v8.4s, v9.4s, v21.4s
    31dc:	mov	v9.16b, v15.16b
    31e0:	fmls	v28.4s, v10.4s, v20.4s
    31e4:	fcvtzs	v22.4s, v22.4s
    31e8:	fcvtzs	v10.4s, v10.4s
    31ec:	fmla	v3.4s, v7.4s, v27.4s
    31f0:	fmla	v9.4s, v8.4s, v21.4s
    31f4:	mov	v8.16b, v17.16b
    31f8:	add	v22.4s, v22.4s, v23.4s
    31fc:	add	v10.4s, v10.4s, v23.4s
    3200:	mov	v23.16b, v16.16b
    3204:	fmla	v8.4s, v3.4s, v27.4s
    3208:	mov	v3.16b, v18.16b
    320c:	fmla	v23.4s, v7.4s, v28.4s
    3210:	shl	v22.4s, v22.4s, #23
    3214:	fmla	v3.4s, v8.4s, v27.4s
    3218:	mov	v8.16b, v17.16b
    321c:	shl	v10.4s, v10.4s, #23
    3220:	fmul	v21.4s, v21.4s, v9.4s
    3224:	fmla	v8.4s, v23.4s, v28.4s
    3228:	mov	v23.16b, v25.16b
    322c:	fmla	v23.4s, v3.4s, v27.4s
    3230:	mov	v3.16b, v29.16b
    3234:	fmla	v2.4s, v8.4s, v28.4s
    3238:	mov	v8.16b, v12.16b
    323c:	fmla	v3.4s, v23.4s, v27.4s
    3240:	mov	v23.16b, v29.16b
    3244:	fmla	v25.4s, v2.4s, v28.4s
    3248:	fmla	v23.4s, v3.4s, v27.4s
    324c:	mov	v3.16b, v29.16b
    3250:	mov	v27.16b, v29.16b
    3254:	fmla	v8.4s, v11.4s, v24.4s
    3258:	fmla	v3.4s, v25.4s, v28.4s
    325c:	mov	v25.16b, v13.16b
    3260:	fmla	v25.4s, v8.4s, v24.4s
    3264:	fmla	v27.4s, v3.4s, v28.4s
    3268:	mov	v28.16b, v14.16b
    326c:	fmla	v28.4s, v25.4s, v24.4s
    3270:	fmul	v25.4s, v23.4s, v22.4s
    3274:	mov	v23.16b, v15.16b
    3278:	fmla	v23.4s, v28.4s, v24.4s
    327c:	fmul	v25.4s, v25.4s, v19.4s
    3280:	fmul	v28.4s, v27.4s, v10.4s
    3284:	fmul	v27.4s, v25.4s, v21.4s
    3288:	fmul	v28.4s, v28.4s, v19.4s
    328c:	fmul	v24.4s, v24.4s, v23.4s
    3290:	fsub	v25.4s, v29.4s, v27.4s
    3294:	fmul	v24.4s, v28.4s, v24.4s
    3298:	ldr	q28, [x20, x7]
    329c:	bsl	v31.16b, v27.16b, v25.16b
    32a0:	fsub	v29.4s, v29.4s, v24.4s
    32a4:	fmul	v31.4s, v28.4s, v31.4s
    32a8:	bsl	v30.16b, v24.16b, v29.16b
    32ac:	fmls	v31.4s, v26.4s, v30.4s
    32b0:	str	q31, [x26, x7]
    32b4:	add	x7, x7, #0x10
    32b8:	cmp	x8, x0
    32bc:	b.ne	2ff0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xd0>  // b.any
    32c0:	and	x19, x19, #0xfffffffffffffffc
    32c4:	add	x19, x19, #0x4
    32c8:	cmp	x24, x19
    32cc:	b.ls	3744 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>  // b.plast
    32d0:	mov	w4, #0x3389                	// #13193
    32d4:	mov	w3, #0x466f                	// #18031
    32d8:	mov	w2, #0x1eea                	// #7914
    32dc:	mov	w1, #0x778                 	// #1912
    32e0:	movk	w4, #0x3e6d, lsl #16
    32e4:	movk	w3, #0x3faa, lsl #16
    32e8:	movk	w2, #0xbfe9, lsl #16
    32ec:	movk	w1, #0x3fe4, lsl #16
    32f0:	mov	w0, #0xc2b00000            	// #-1028653056
    32f4:	fmov	s10, w4
    32f8:	fmov	s11, w3
    32fc:	fmov	s12, w2
    3300:	fmov	s13, w1
    3304:	fmov	s14, w0
    3308:	ldr	s28, [x22, x19, lsl #2]
    330c:	ldr	s15, [x25, x19, lsl #2]
    3310:	ldr	s26, [x20, x19, lsl #2]
    3314:	fcmp	s28, #0.0
    3318:	ldr	s8, [x21, x19, lsl #2]
    331c:	ldr	s25, [x23, x19, lsl #2]
    3320:	fmul	s9, s15, s15
    3324:	b.pl	347c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.nfrst
    3328:	fmov	s0, s28
    332c:	stp	s26, s28, [sp, #148]
    3330:	str	s25, [sp, #156]
    3334:	bl	ec0 <sqrtf@plt>
    3338:	ldr	s26, [sp, #148]
    333c:	fmul	s15, s15, s0
    3340:	fdiv	s0, s26, s8
    3344:	bl	1020 <logf@plt>
    3348:	ldr	s25, [sp, #156]
    334c:	fmov	s31, #5.000000000000000000e-01
    3350:	mov	w0, #0x3389                	// #13193
    3354:	movk	w0, #0x3e6d, lsl #16
    3358:	fmov	s27, #1.000000000000000000e+00
    335c:	mov	w1, #0x466f                	// #18031
    3360:	ldp	s26, s28, [sp, #148]
    3364:	mov	w3, #0x1eea                	// #7914
    3368:	movk	w1, #0x3faa, lsl #16
    336c:	fmov	s30, w0
    3370:	movk	w3, #0xbfe9, lsl #16
    3374:	mov	w2, #0x778                 	// #1912
    3378:	fmov	s20, w1
    337c:	movk	w2, #0x3fe4, lsl #16
    3380:	mov	w1, #0x8f89                	// #36745
    3384:	fmov	s22, w3
    3388:	movk	w1, #0xbeb6, lsl #16
    338c:	mov	w0, #0x85fa                	// #34298
    3390:	fmadd	s9, s9, s31, s25
    3394:	movk	w0, #0x3ea3, lsl #16
    3398:	mov	w7, #0xaa3b                	// #43579
    339c:	fmov	s23, w2
    33a0:	fmov	s19, #-5.000000000000000000e-01
    33a4:	movk	w7, #0x3fb8, lsl #16
    33a8:	fmov	s24, w1
    33ac:	fmov	s31, w0
    33b0:	fmadd	s0, s28, s9, s0
    33b4:	fmov	s29, w7
    33b8:	fdiv	s0, s0, s15
    33bc:	fmadd	s21, s0, s30, s27
    33c0:	fmul	s30, s0, s19
    33c4:	fsub	s15, s0, s15
    33c8:	fmul	s30, s30, s0
    33cc:	fdiv	s27, s27, s21
    33d0:	fmul	s29, s30, s29
    33d4:	fmadd	s22, s27, s20, s22
    33d8:	fmadd	s23, s22, s27, s23
    33dc:	fmadd	s24, s23, s27, s24
    33e0:	fmadd	s31, s24, s27, s31
    33e4:	fmul	s31, s31, s27
    33e8:	fmov	s24, #5.000000000000000000e-01
    33ec:	mov	w0, #0x7218                	// #29208
    33f0:	mov	w3, #0xb61                 	// #2913
    33f4:	movk	w0, #0x3f31, lsl #16
    33f8:	mov	w2, #0x8889                	// #34953
    33fc:	fmov	s27, #1.000000000000000000e+00
    3400:	movk	w3, #0x3ab6, lsl #16
    3404:	movk	w2, #0x3c08, lsl #16
    3408:	fmov	s18, w0
    340c:	mov	w1, #0xaaab                	// #43691
    3410:	mov	w0, #0xaaab                	// #43691
    3414:	fsub	s29, s29, s24
    3418:	movk	w1, #0x3d2a, lsl #16
    341c:	movk	w0, #0x3e2a, lsl #16
    3420:	fmov	s21, w2
    3424:	mov	w4, #0x422a                	// #16938
    3428:	fmov	s19, w3
    342c:	movk	w4, #0x3ecc, lsl #16
    3430:	fmov	s22, w1
    3434:	fmov	s23, w0
    3438:	fmov	s20, w4
    343c:	fcvtzs	s29, s29
    3440:	scvtf	s29, s29
    3444:	fmsub	s30, s29, s18, s30
    3448:	fcvtzs	w7, s29
    344c:	fmadd	s29, s30, s19, s21
    3450:	add	w7, w7, #0x7f
    3454:	fmov	s21, w7
    3458:	fmadd	s29, s30, s29, s22
    345c:	fmadd	s29, s30, s29, s23
    3460:	shl	v21.2s, v21.2s, #23
    3464:	fmadd	s24, s30, s29, s24
    3468:	fmadd	s24, s30, s24, s27
    346c:	fmadd	s30, s30, s24, s27
    3470:	fmul	s30, s30, s21
    3474:	fmul	s30, s30, s20
    3478:	b	39b8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa98>
    347c:	fsqrt	s29, s28
    3480:	stp	s26, s28, [sp, #148]
    3484:	str	s25, [sp, #156]
    3488:	fdiv	s0, s26, s8
    348c:	fmul	s15, s15, s29
    3490:	bl	1020 <logf@plt>
    3494:	ldr	s25, [sp, #156]
    3498:	fmov	s30, #5.000000000000000000e-01
    349c:	ldp	s26, s28, [sp, #148]
    34a0:	fmadd	s9, s9, s30, s25
    34a4:	fmadd	s0, s28, s9, s0
    34a8:	fdiv	s0, s0, s15
    34ac:	fcmpe	s0, #0.0
    34b0:	fsub	s15, s0, s15
    34b4:	b.mi	37f4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8d4>  // b.first
    34b8:	fmov	s31, #1.000000000000000000e+00
    34bc:	mov	w1, #0x8f89                	// #36745
    34c0:	mov	w0, #0x85fa                	// #34298
    34c4:	movk	w1, #0xbeb6, lsl #16
    34c8:	movk	w0, #0x3ea3, lsl #16
    34cc:	fmov	s30, #-5.000000000000000000e-01
    34d0:	fmov	s27, w1
    34d4:	fmadd	s24, s0, s10, s31
    34d8:	fmov	s29, w0
    34dc:	fmul	s30, s0, s30
    34e0:	fmul	s30, s30, s0
    34e4:	fdiv	s31, s31, s24
    34e8:	fcmpe	s30, s14
    34ec:	fmadd	s24, s31, s11, s12
    34f0:	fmadd	s24, s31, s24, s13
    34f4:	fmadd	s27, s31, s24, s27
    34f8:	fmadd	s29, s31, s27, s29
    34fc:	fmul	s31, s31, s29
    3500:	b.mi	3864 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x944>  // b.first
    3504:	mov	w0, #0x42b00000            	// #1118830592
    3508:	fmov	s29, w0
    350c:	fcmpe	s30, s29
    3510:	b.gt	3530 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x610>
    3514:	mov	w7, #0xaa3b                	// #43579
    3518:	movk	w7, #0x3fb8, lsl #16
    351c:	fmov	s29, w7
    3520:	fmul	s29, s30, s29
    3524:	fcmpe	s29, #0.0
    3528:	b.ge	3928 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    352c:	b	33e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    3530:	mov	w0, #0x484f                	// #18511
    3534:	movk	w0, #0x7e46, lsl #16
    3538:	fmov	s30, w0
    353c:	fmul	s31, s31, s30
    3540:	fmov	s30, #1.000000000000000000e+00
    3544:	fsub	s31, s30, s31
    3548:	fnmul	s29, s25, s28
    354c:	fmul	s31, s26, s31
    3550:	movi	v30.2s, #0x0
    3554:	fcmpe	s29, s14
    3558:	b.mi	3604 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>  // b.first
    355c:	mov	w0, #0x42b00000            	// #1118830592
    3560:	fmov	s30, w0
    3564:	fcmpe	s29, s30
    3568:	b.gt	3878 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x958>
    356c:	mov	w7, #0xaa3b                	// #43579
    3570:	movk	w7, #0x3fb8, lsl #16
    3574:	fmov	s28, w7
    3578:	fmul	s28, s29, s28
    357c:	fcmpe	s28, #0.0
    3580:	b.ge	39c8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xaa8>  // b.tcont
    3584:	fmov	s27, #5.000000000000000000e-01
    3588:	mov	w0, #0x7218                	// #29208
    358c:	mov	w3, #0xb61                 	// #2913
    3590:	movk	w0, #0x3f31, lsl #16
    3594:	mov	w2, #0x8889                	// #34953
    3598:	fmov	s30, #1.000000000000000000e+00
    359c:	movk	w3, #0x3ab6, lsl #16
    35a0:	movk	w2, #0x3c08, lsl #16
    35a4:	fmov	s22, w0
    35a8:	mov	w1, #0xaaab                	// #43691
    35ac:	mov	w0, #0xaaab                	// #43691
    35b0:	fsub	s28, s28, s27
    35b4:	movk	w1, #0x3d2a, lsl #16
    35b8:	movk	w0, #0x3e2a, lsl #16
    35bc:	fmov	s24, w2
    35c0:	fmov	s23, w3
    35c4:	fmov	s25, w1
    35c8:	fmov	s26, w0
    35cc:	fcvtzs	s28, s28
    35d0:	scvtf	s28, s28
    35d4:	fmsub	s29, s28, s22, s29
    35d8:	fcvtzs	w7, s28
    35dc:	fmadd	s28, s29, s23, s24
    35e0:	add	w7, w7, #0x7f
    35e4:	fmov	s24, w7
    35e8:	fmadd	s28, s29, s28, s25
    35ec:	fmadd	s28, s29, s28, s26
    35f0:	shl	v24.2s, v24.2s, #23
    35f4:	fmadd	s27, s29, s28, s27
    35f8:	fmadd	s27, s29, s27, s30
    35fc:	fmadd	s30, s29, s27, s30
    3600:	fmul	s30, s30, s24
    3604:	fcmpe	s15, #0.0
    3608:	fmul	s26, s8, s30
    360c:	b.mi	376c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x84c>  // b.first
    3610:	fmov	s30, #1.000000000000000000e+00
    3614:	mov	w1, #0x8f89                	// #36745
    3618:	mov	w0, #0x85fa                	// #34298
    361c:	movk	w1, #0xbeb6, lsl #16
    3620:	movk	w0, #0x3ea3, lsl #16
    3624:	fmov	s28, #-5.000000000000000000e-01
    3628:	fmov	s27, w1
    362c:	fmadd	s25, s15, s10, s30
    3630:	fmov	s29, w0
    3634:	fmul	s28, s15, s28
    3638:	fmul	s28, s28, s15
    363c:	fdiv	s30, s30, s25
    3640:	fcmpe	s28, s14
    3644:	fmadd	s25, s30, s11, s12
    3648:	fmadd	s25, s30, s25, s13
    364c:	fmadd	s27, s30, s25, s27
    3650:	fmadd	s29, s30, s27, s29
    3654:	fmul	s30, s30, s29
    3658:	b.mi	3870 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x950>  // b.first
    365c:	mov	w0, #0x42b00000            	// #1118830592
    3660:	fmov	s29, w0
    3664:	fcmpe	s28, s29
    3668:	b.gt	3718 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7f8>
    366c:	mov	w7, #0xaa3b                	// #43579
    3670:	movk	w7, #0x3fb8, lsl #16
    3674:	fmov	s29, w7
    3678:	fmul	s29, s28, s29
    367c:	fcmpe	s29, #0.0
    3680:	b.ge	3888 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    3684:	fmov	s25, #5.000000000000000000e-01
    3688:	mov	w0, #0x7218                	// #29208
    368c:	mov	w4, #0xb61                 	// #2913
    3690:	movk	w0, #0x3f31, lsl #16
    3694:	mov	w2, #0x8889                	// #34953
    3698:	fmov	s27, #1.000000000000000000e+00
    369c:	movk	w4, #0x3ab6, lsl #16
    36a0:	movk	w2, #0x3c08, lsl #16
    36a4:	fmov	s19, w0
    36a8:	mov	w1, #0xaaab                	// #43691
    36ac:	mov	w0, #0xaaab                	// #43691
    36b0:	fsub	s29, s29, s25
    36b4:	movk	w1, #0x3d2a, lsl #16
    36b8:	movk	w0, #0x3e2a, lsl #16
    36bc:	fmov	s22, w2
    36c0:	mov	w3, #0x422a                	// #16938
    36c4:	fmov	s20, w4
    36c8:	movk	w3, #0x3ecc, lsl #16
    36cc:	fmov	s23, w1
    36d0:	fmov	s24, w0
    36d4:	fmov	s21, w3
    36d8:	fcvtzs	s29, s29
    36dc:	scvtf	s29, s29
    36e0:	fmsub	s28, s29, s19, s28
    36e4:	fcvtzs	w7, s29
    36e8:	fmadd	s29, s28, s20, s22
    36ec:	add	w7, w7, #0x7f
    36f0:	fmov	s22, w7
    36f4:	fmadd	s29, s28, s29, s23
    36f8:	fmadd	s29, s28, s29, s24
    36fc:	shl	v22.2s, v22.2s, #23
    3700:	fmadd	s25, s28, s29, s25
    3704:	fmadd	s25, s28, s25, s27
    3708:	fmadd	s29, s28, s25, s27
    370c:	fmul	s29, s29, s22
    3710:	fmul	s29, s29, s21
    3714:	b	3918 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x9f8>
    3718:	mov	w0, #0x484f                	// #18511
    371c:	movk	w0, #0x7e46, lsl #16
    3720:	fmov	s29, w0
    3724:	fmul	s30, s30, s29
    3728:	fmov	s29, #1.000000000000000000e+00
    372c:	fsub	s29, s29, s30
    3730:	fmsub	s31, s26, s29, s31
    3734:	str	s31, [x26, x19, lsl #2]
    3738:	add	x19, x19, #0x1
    373c:	cmp	x19, x24
    3740:	b.ne	3308 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    3744:	ldp	d8, d9, [sp, #80]
    3748:	ldp	x19, x20, [sp, #16]
    374c:	ldp	x21, x22, [sp, #32]
    3750:	ldp	x23, x24, [sp, #48]
    3754:	ldp	x25, x26, [sp, #64]
    3758:	ldp	d10, d11, [sp, #96]
    375c:	ldp	d12, d13, [sp, #112]
    3760:	ldp	d14, d15, [sp, #128]
    3764:	ldp	x29, x30, [sp], #160
    3768:	ret
    376c:	fmov	s29, #1.000000000000000000e+00
    3770:	mov	w1, #0x8f89                	// #36745
    3774:	mov	w0, #0x85fa                	// #34298
    3778:	movk	w1, #0xbeb6, lsl #16
    377c:	movk	w0, #0x3ea3, lsl #16
    3780:	fmov	s28, #5.000000000000000000e-01
    3784:	fmov	s27, w1
    3788:	fmsub	s25, s15, s10, s29
    378c:	fmov	s30, w0
    3790:	fmul	s28, s15, s28
    3794:	fnmul	s28, s15, s28
    3798:	fdiv	s29, s29, s25
    379c:	fcmpe	s28, s14
    37a0:	fmadd	s25, s29, s11, s12
    37a4:	fmadd	s25, s29, s25, s13
    37a8:	fmadd	s27, s29, s25, s27
    37ac:	fmadd	s30, s29, s27, s30
    37b0:	fmul	s30, s29, s30
    37b4:	b.mi	37d4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8b4>  // b.first
    37b8:	mov	w7, #0xaa3b                	// #43579
    37bc:	movk	w7, #0x3fb8, lsl #16
    37c0:	fmov	s29, w7
    37c4:	fmul	s29, s28, s29
    37c8:	fcmpe	s29, #0.0
    37cc:	b.ge	3888 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    37d0:	b	3684 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x764>
    37d4:	movi	v29.2s, #0x0
    37d8:	fmul	s30, s30, s29
    37dc:	fmsub	s30, s26, s30, s31
    37e0:	str	s30, [x26, x19, lsl #2]
    37e4:	add	x19, x19, #0x1
    37e8:	cmp	x24, x19
    37ec:	b.ne	3308 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    37f0:	b	3744 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>
    37f4:	fmov	s31, #1.000000000000000000e+00
    37f8:	mov	w1, #0x8f89                	// #36745
    37fc:	mov	w0, #0x85fa                	// #34298
    3800:	movk	w1, #0xbeb6, lsl #16
    3804:	movk	w0, #0x3ea3, lsl #16
    3808:	fmul	s30, s0, s30
    380c:	fmov	s27, w1
    3810:	fmsub	s24, s0, s10, s31
    3814:	fmov	s29, w0
    3818:	fnmul	s30, s0, s30
    381c:	fcmpe	s30, s14
    3820:	fdiv	s31, s31, s24
    3824:	fmadd	s24, s31, s11, s12
    3828:	fmadd	s24, s31, s24, s13
    382c:	fmadd	s27, s31, s24, s27
    3830:	fmadd	s29, s31, s27, s29
    3834:	fmul	s31, s31, s29
    3838:	b.mi	3858 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x938>  // b.first
    383c:	mov	w7, #0xaa3b                	// #43579
    3840:	movk	w7, #0x3fb8, lsl #16
    3844:	fmov	s29, w7
    3848:	fmul	s29, s30, s29
    384c:	fcmpe	s29, #0.0
    3850:	b.ge	3928 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    3854:	b	33e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    3858:	movi	v30.2s, #0x0
    385c:	fmul	s31, s31, s30
    3860:	b	3548 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>
    3864:	movi	v30.2s, #0x0
    3868:	fmul	s31, s31, s30
    386c:	b	3540 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    3870:	movi	v29.2s, #0x0
    3874:	b	3724 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x804>
    3878:	mov	w7, #0x829c                	// #33436
    387c:	movk	w7, #0x7ef8, lsl #16
    3880:	fmov	s30, w7
    3884:	b	3604 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    3888:	fmov	s24, #5.000000000000000000e-01
    388c:	mov	w0, #0x7218                	// #29208
    3890:	mov	w4, #0xb61                 	// #2913
    3894:	movk	w0, #0x3f31, lsl #16
    3898:	mov	w2, #0x8889                	// #34953
    389c:	fmov	s27, #1.000000000000000000e+00
    38a0:	movk	w4, #0x3ab6, lsl #16
    38a4:	movk	w2, #0x3c08, lsl #16
    38a8:	fmov	s25, w0
    38ac:	mov	w1, #0xaaab                	// #43691
    38b0:	mov	w0, #0xaaab                	// #43691
    38b4:	fadd	s29, s29, s24
    38b8:	movk	w1, #0x3d2a, lsl #16
    38bc:	movk	w0, #0x3e2a, lsl #16
    38c0:	fmov	s19, w4
    38c4:	mov	w3, #0x422a                	// #16938
    38c8:	fmov	s21, w2
    38cc:	movk	w3, #0x3ecc, lsl #16
    38d0:	fmov	s22, w1
    38d4:	fmov	s23, w0
    38d8:	fmov	s20, w3
    38dc:	fcvtzs	s29, s29
    38e0:	scvtf	s29, s29
    38e4:	fmsub	s28, s29, s25, s28
    38e8:	fcvtzs	w7, s29
    38ec:	fmadd	s29, s28, s19, s21
    38f0:	add	w7, w7, #0x7f
    38f4:	fmov	s25, w7
    38f8:	fmadd	s29, s28, s29, s22
    38fc:	fmadd	s29, s28, s29, s23
    3900:	shl	v25.2s, v25.2s, #23
    3904:	fmadd	s24, s28, s29, s24
    3908:	fmadd	s24, s28, s24, s27
    390c:	fmadd	s29, s28, s24, s27
    3910:	fmul	s29, s29, s25
    3914:	fmul	s29, s29, s20
    3918:	fcmpe	s15, #0.0
    391c:	fmul	s30, s30, s29
    3920:	b.mi	37dc <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8bc>  // b.first
    3924:	b	3728 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x808>
    3928:	fmov	s23, #5.000000000000000000e-01
    392c:	mov	w0, #0x7218                	// #29208
    3930:	mov	w3, #0xb61                 	// #2913
    3934:	movk	w0, #0x3f31, lsl #16
    3938:	mov	w2, #0x8889                	// #34953
    393c:	fmov	s27, #1.000000000000000000e+00
    3940:	movk	w3, #0x3ab6, lsl #16
    3944:	movk	w2, #0x3c08, lsl #16
    3948:	fmov	s24, w0
    394c:	mov	w1, #0xaaab                	// #43691
    3950:	mov	w0, #0xaaab                	// #43691
    3954:	fadd	s29, s29, s23
    3958:	movk	w1, #0x3d2a, lsl #16
    395c:	movk	w0, #0x3e2a, lsl #16
    3960:	fmov	s18, w3
    3964:	mov	w4, #0x422a                	// #16938
    3968:	fmov	s20, w2
    396c:	movk	w4, #0x3ecc, lsl #16
    3970:	fmov	s21, w1
    3974:	fmov	s22, w0
    3978:	fmov	s19, w4
    397c:	fcvtzs	s29, s29
    3980:	scvtf	s29, s29
    3984:	fmsub	s30, s29, s24, s30
    3988:	fcvtzs	w7, s29
    398c:	fmadd	s29, s30, s18, s20
    3990:	add	w7, w7, #0x7f
    3994:	fmov	s24, w7
    3998:	fmadd	s29, s30, s29, s21
    399c:	fmadd	s29, s30, s29, s22
    39a0:	shl	v24.2s, v24.2s, #23
    39a4:	fmadd	s23, s30, s29, s23
    39a8:	fmadd	s23, s30, s23, s27
    39ac:	fmadd	s30, s30, s23, s27
    39b0:	fmul	s30, s30, s24
    39b4:	fmul	s30, s30, s19
    39b8:	fcmpe	s0, #0.0
    39bc:	fmul	s31, s31, s30
    39c0:	b.mi	3548 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>  // b.first
    39c4:	b	3540 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    39c8:	fmov	s26, #5.000000000000000000e-01
    39cc:	mov	w0, #0x7218                	// #29208
    39d0:	mov	w3, #0xb61                 	// #2913
    39d4:	movk	w0, #0x3f31, lsl #16
    39d8:	mov	w2, #0x8889                	// #34953
    39dc:	fmov	s30, #1.000000000000000000e+00
    39e0:	movk	w3, #0x3ab6, lsl #16
    39e4:	movk	w2, #0x3c08, lsl #16
    39e8:	fmov	s27, w0
    39ec:	mov	w1, #0xaaab                	// #43691
    39f0:	mov	w0, #0xaaab                	// #43691
    39f4:	fadd	s28, s28, s26
    39f8:	movk	w1, #0x3d2a, lsl #16
    39fc:	movk	w0, #0x3e2a, lsl #16
    3a00:	fmov	s22, w3
    3a04:	fmov	s23, w2
    3a08:	fmov	s24, w1
    3a0c:	fmov	s25, w0
    3a10:	fcvtzs	s28, s28
    3a14:	scvtf	s28, s28
    3a18:	fmsub	s29, s28, s27, s29
    3a1c:	fcvtzs	w7, s28
    3a20:	fmadd	s28, s29, s22, s23
    3a24:	add	w7, w7, #0x7f
    3a28:	fmov	s27, w7
    3a2c:	fmadd	s28, s29, s28, s24
    3a30:	fmadd	s28, s29, s28, s25
    3a34:	shl	v27.2s, v27.2s, #23
    3a38:	fmadd	s26, s29, s28, s26
    3a3c:	fmadd	s26, s29, s26, s30
    3a40:	fmadd	s30, s29, s26, s30
    3a44:	fmul	s30, s30, s27
    3a48:	b	3604 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    3a4c:	mov	x19, #0x0                   	// #0
    3a50:	b	32c8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a8>
    3a54:	nop
    3a58:	nop
    3a5c:	nop

0000000000003a60 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>:
    3a60:	stp	x29, x30, [sp, #-64]!
    3a64:	mov	x29, sp
    3a68:	stp	x21, x22, [sp, #32]
    3a6c:	add	x22, x0, #0x10
    3a70:	stp	x19, x20, [sp, #16]
    3a74:	str	x22, [x0]
    3a78:	cbz	x1, 3b30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0xd0>
    3a7c:	mov	x20, x0
    3a80:	mov	x0, x1
    3a84:	mov	x21, x1
    3a88:	bl	e80 <strlen@plt>
    3a8c:	str	x0, [sp, #56]
    3a90:	mov	x19, x0
    3a94:	cmp	x0, #0xf
    3a98:	b.hi	3ae0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0x80>  // b.pmore
    3a9c:	cmp	x0, #0x1
    3aa0:	b.ne	3ac4 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0x64>  // b.any
    3aa4:	ldrb	w0, [x21]
    3aa8:	str	x19, [x20, #8]
    3aac:	strb	w0, [x20, #16]
    3ab0:	strb	wzr, [x22, x19]
    3ab4:	ldp	x19, x20, [sp, #16]
    3ab8:	ldp	x21, x22, [sp, #32]
    3abc:	ldp	x29, x30, [sp], #64
    3ac0:	ret
    3ac4:	cbnz	x0, 3b00 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0xa0>
    3ac8:	str	x19, [x20, #8]
    3acc:	strb	wzr, [x22, x19]
    3ad0:	ldp	x19, x20, [sp, #16]
    3ad4:	ldp	x21, x22, [sp, #32]
    3ad8:	ldp	x29, x30, [sp], #64
    3adc:	ret
    3ae0:	add	x1, sp, #0x38
    3ae4:	mov	x2, #0x0                   	// #0
    3ae8:	mov	x0, x20
    3aec:	bl	1010 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long)@plt>
    3af0:	ldr	x1, [sp, #56]
    3af4:	mov	x22, x0
    3af8:	str	x0, [x20]
    3afc:	str	x1, [x20, #16]
    3b00:	mov	x2, x19
    3b04:	mov	x1, x21
    3b08:	mov	x0, x22
    3b0c:	bl	e70 <memcpy@plt>
    3b10:	ldr	x19, [sp, #56]
    3b14:	ldr	x22, [x20]
    3b18:	str	x19, [x20, #8]
    3b1c:	strb	wzr, [x22, x19]
    3b20:	ldp	x19, x20, [sp, #16]
    3b24:	ldp	x21, x22, [sp, #32]
    3b28:	ldp	x29, x30, [sp], #64
    3b2c:	ret
    3b30:	adrp	x0, 3000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xe0>
    3b34:	add	x0, x0, #0xe40
    3b38:	bl	f00 <std::__throw_logic_error(char const*)@plt>
    3b3c:	nop

0000000000003b40 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>:
    3b40:	stp	x29, x30, [sp, #-48]!
    3b44:	mov	x29, sp
    3b48:	stp	x19, x20, [sp, #16]
    3b4c:	mov	x20, x0
    3b50:	mov	x0, x1
    3b54:	mov	x19, x1
    3b58:	str	x21, [sp, #32]
    3b5c:	ldr	x21, [x20, #8]
    3b60:	bl	e80 <strlen@plt>
    3b64:	cmp	x21, x0
    3b68:	b.eq	3b80 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)+0x40>  // b.none
    3b6c:	mov	w0, #0x0                   	// #0
    3b70:	ldr	x21, [sp, #32]
    3b74:	ldp	x19, x20, [sp, #16]
    3b78:	ldp	x29, x30, [sp], #48
    3b7c:	ret
    3b80:	mov	w0, #0x1                   	// #1
    3b84:	cbz	x21, 3b70 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)+0x30>
    3b88:	ldr	x0, [x20]
    3b8c:	mov	x2, x21
    3b90:	mov	x1, x19
    3b94:	bl	ea0 <memcmp@plt>
    3b98:	ldr	x21, [sp, #32]
    3b9c:	cmp	w0, #0x0
    3ba0:	cset	w0, eq	// eq = none
    3ba4:	ldp	x19, x20, [sp, #16]
    3ba8:	ldp	x29, x30, [sp], #48
    3bac:	ret
    3bb0:	nop
    3bb4:	nop
    3bb8:	nop
    3bbc:	nop

0000000000003bc0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>:
    3bc0:	ldr	x5, [x0]
    3bc4:	mov	w8, #0xb0df                	// #45279
    3bc8:	mov	x2, x0
    3bcc:	movk	w8, #0x9908, lsl #16
    3bd0:	add	x7, x0, #0x718
    3bd4:	mov	x3, x0
    3bd8:	nop
    3bdc:	nop
    3be0:	and	x4, x5, #0xffffffff80000000
    3be4:	ldr	x5, [x3, #8]
    3be8:	ldr	x6, [x3, #3176]
    3bec:	and	x1, x5, #0x7fffffff
    3bf0:	orr	x1, x1, x4
    3bf4:	and	x4, x1, #0x1
    3bf8:	eor	x1, x6, x1, lsr #1
    3bfc:	umull	x4, w4, w8
    3c00:	eor	x1, x1, x4
    3c04:	str	x1, [x3], #8
    3c08:	cmp	x3, x7
    3c0c:	b.ne	3be0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()+0x20>  // b.any
    3c10:	ldr	x4, [x0, #1816]
    3c14:	mov	w6, #0xb0df                	// #45279
    3c18:	add	x7, x0, #0xc60
    3c1c:	movk	w6, #0x9908, lsl #16
    3c20:	and	x3, x4, #0xffffffff80000000
    3c24:	ldr	x4, [x2, #1824]
    3c28:	add	x2, x2, #0x8
    3c2c:	ldur	x5, [x2, #-8]
    3c30:	and	x1, x4, #0x7fffffff
    3c34:	orr	x1, x1, x3
    3c38:	and	x3, x1, #0x1
    3c3c:	eor	x1, x5, x1, lsr #1
    3c40:	umull	x3, w3, w6
    3c44:	eor	x1, x1, x3
    3c48:	str	x1, [x2, #1808]
    3c4c:	cmp	x2, x7
    3c50:	b.ne	3c20 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()+0x60>  // b.any
    3c54:	ldr	x2, [x0]
    3c58:	str	xzr, [x0, #4992]
    3c5c:	ldr	x1, [x0, #4984]
    3c60:	ldr	x3, [x0, #3168]
    3c64:	bfxil	x1, x2, #0, #31
    3c68:	and	x2, x1, #0x1
    3c6c:	eor	x1, x3, x1, lsr #1
    3c70:	umull	x2, w2, w6
    3c74:	eor	x1, x1, x2
    3c78:	str	x1, [x0, #4984]
    3c7c:	ret

Disassembly of section .fini:

0000000000003c80 <_fini>:
    3c80:	paciasp
    3c84:	stp	x29, x30, [sp, #-16]!
    3c88:	mov	x29, sp
    3c8c:	ldp	x29, x30, [sp], #16
    3c90:	autiasp
    3c94:	ret
