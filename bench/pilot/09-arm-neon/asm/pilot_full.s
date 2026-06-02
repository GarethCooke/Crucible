
/home/gcooke/Development/Crucible/bench/pilot/09-arm-neon/build/pilot_blackscholes:     file format elf64-littleaarch64


Disassembly of section .init:

0000000000000e28 <_init>:
 e28:	paciasp
 e2c:	stp	x29, x30, [sp, #-16]!
 e30:	mov	x29, sp
 e34:	bl	1b74 <call_weak_fn>
 e38:	ldp	x29, x30, [sp], #16
 e3c:	autiasp
 e40:	ret

Disassembly of section .plt:

0000000000000e50 <.plt>:
     e50:	stp	x16, x30, [sp, #-16]!
     e54:	adrp	x16, 1f000 <__abi_tag+0x199f8>
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
    10a0:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    10a4:	stp	x21, x22, [sp, #32]
    10a8:	mov	x21, x1
    10ac:	add	x1, x0, #0xc90
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
    10d8:	bl	4a20 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>
    10dc:	cmp	w20, #0x1
    10e0:	b.le	1ae0 <main+0xa60>
    10e4:	add	x0, sp, #0xc8
    10e8:	adrp	x22, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    10ec:	adrp	x24, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    10f0:	add	x22, x22, #0xc98
    10f4:	add	x24, x24, #0xca8
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
    1134:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1138:	add	x1, x0, #0xc90
    113c:	mov	x0, x20
    1140:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1144:	tbnz	w0, #0, 115c <main+0xdc>
    1148:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    114c:	mov	x0, x20
    1150:	add	x1, x1, #0xcb8
    1154:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1158:	tbz	w0, #0, 16d4 <main+0x654>
    115c:	mrs	x0, fpcr
    1160:	orr	x0, x0, #0x1000000
    1164:	msr	fpcr, x0
    1168:	mrs	x2, fpcr
    116c:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1170:	tst	x2, #0x1000000
    1174:	adrp	x3, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1178:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    117c:	add	x3, x3, #0xc88
    1180:	add	x0, x0, #0xd38
    1184:	add	x1, x1, #0xc80
    1188:	csel	x1, x3, x1, eq	// eq = none
    118c:	bl	1040 <printf@plt>
    1190:	mov	x0, x25
    1194:	bl	2040 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    1198:	mov	x24, x0
    119c:	mov	x0, x25
    11a0:	bl	2040 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11a4:	mov	x23, x0
    11a8:	mov	x0, x25
    11ac:	bl	2040 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11b0:	mov	x22, x0
    11b4:	mov	x0, x25
    11b8:	bl	2040 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11bc:	mov	x21, x0
    11c0:	mov	x0, x25
    11c4:	bl	2040 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
    11c8:	mov	x20, x0
    11cc:	mov	x0, x25
    11d0:	bl	2040 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>
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
    127c:	b.ge	16b0 <main+0x630>  // b.tcont
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
    12d8:	b.ge	16a4 <main+0x624>  // b.tcont
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
    1334:	b.ge	16cc <main+0x64c>  // b.tcont
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
    1398:	b.ge	16bc <main+0x63c>  // b.tcont
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
    1424:	str	x2, [sp, #160]
    1428:	bl	4b80 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
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
    1460:	bl	4a20 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>
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
    1494:	b.eq	1b08 <main+0xa88>  // b.none
    1498:	ldr	w0, [x23]
    149c:	cmp	w0, #0x22
    14a0:	b.eq	1afc <main+0xa7c>  // b.none
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
    14cc:	bl	4b80 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    14d0:	ldr	x2, [sp, #160]
    14d4:	ldr	x5, [sp, #5272]
    14d8:	b	13b8 <main+0x338>
    14dc:	mov	x0, x19
    14e0:	str	x2, [sp, #160]
    14e4:	bl	4b80 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    14e8:	ldr	x2, [sp, #160]
    14ec:	ldr	x1, [sp, #5272]
    14f0:	b	1360 <main+0x2e0>
    14f4:	mov	x0, x19
    14f8:	str	x2, [sp, #160]
    14fc:	bl	4b80 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
    1500:	ldr	x2, [sp, #160]
    1504:	ldr	x5, [sp, #5272]
    1508:	b	12fc <main+0x27c>
    150c:	mov	x0, x19
    1510:	str	x2, [sp, #160]
    1514:	bl	4b80 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>
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
    1620:	str	s15, [x19, x27, lsl #2]
    1624:	add	x27, x27, #0x1
    1628:	cmp	x27, #0x100
    162c:	b.ne	1588 <main+0x508>  // b.any
    1630:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1634:	add	x1, x0, #0xc90
    1638:	ldr	x0, [sp, #168]
    163c:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1640:	tbnz	w0, #0, 1a4c <main+0x9cc>
    1644:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1648:	ldr	x0, [sp, #168]
    164c:	add	x1, x1, #0xcc0
    1650:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1654:	tbnz	w0, #0, 1734 <main+0x6b4>
    1658:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    165c:	ldr	x0, [sp, #168]
    1660:	add	x1, x1, #0xcc8
    1664:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1668:	tbnz	w0, #0, 1abc <main+0xa3c>
    166c:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1670:	ldr	x0, [sp, #168]
    1674:	add	x1, x1, #0xcd8
    1678:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    167c:	mov	x6, x27
    1680:	mov	x5, x26
    1684:	mov	x4, x20
    1688:	mov	x3, x21
    168c:	mov	x2, x22
    1690:	mov	x1, x23
    1694:	tbz	w0, #0, 1ab0 <main+0xa30>
    1698:	mov	x0, x24
    169c:	bl	37e0 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    16a0:	b	1754 <main+0x6d4>
    16a4:	mov	w0, #0x43160000            	// #1125515264
    16a8:	fmov	s31, w0
    16ac:	b	12f0 <main+0x270>
    16b0:	mov	w0, #0x43160000            	// #1125515264
    16b4:	fmov	s31, w0
    16b8:	b	1294 <main+0x214>
    16bc:	mov	w0, #0xd709                	// #55049
    16c0:	movk	w0, #0x3da3, lsl #16
    16c4:	fmov	s31, w0
    16c8:	b	13ac <main+0x32c>
    16cc:	mvni	v31.2s, #0xc0, lsl #24
    16d0:	b	1354 <main+0x2d4>
    16d4:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    16d8:	mov	x0, x20
    16dc:	add	x1, x1, #0xcc0
    16e0:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    16e4:	tbnz	w0, #0, 115c <main+0xdc>
    16e8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    16ec:	mov	x0, x20
    16f0:	add	x1, x1, #0xcc8
    16f4:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    16f8:	tbnz	w0, #0, 115c <main+0xdc>
    16fc:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1700:	mov	x0, x20
    1704:	add	x1, x1, #0xcd8
    1708:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    170c:	tbnz	w0, #0, 115c <main+0xdc>
    1710:	adrp	x0, 1f000 <__abi_tag+0x199f8>
    1714:	ldr	x0, [x0, #4056]
    1718:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    171c:	add	x1, x1, #0xce8
    1720:	ldr	x2, [x21]
    1724:	ldr	x0, [x0]
    1728:	bl	e90 <fprintf@plt>
    172c:	mov	w19, #0x1                   	// #1
    1730:	b	196c <main+0x8ec>
    1734:	mov	x6, x27
    1738:	mov	x5, x26
    173c:	mov	x4, x20
    1740:	mov	x3, x21
    1744:	mov	x2, x22
    1748:	mov	x1, x23
    174c:	mov	x0, x24
    1750:	bl	2860 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1754:	movi	v30.2s, #0x0
    1758:	mov	x0, #0x1                   	// #1
    175c:	sub	x2, x26, #0x4
    1760:	add	x1, x19, x0, lsl #2
    1764:	ldr	s31, [x2, x0, lsl #2]
    1768:	add	x0, x0, #0x1
    176c:	ldur	s29, [x1, #-4]
    1770:	fabd	s31, s31, s29
    1774:	fcmpe	s31, s30
    1778:	fcsel	s30, s31, s30, gt
    177c:	cmp	x0, #0x101
    1780:	b.ne	1760 <main+0x6e0>  // b.any
    1784:	mov	w0, #0xb717                	// #46871
    1788:	fcvt	d0, s30
    178c:	movk	w0, #0x38d1, lsl #16
    1790:	fmov	s31, w0
    1794:	fcmpe	s30, s31
    1798:	b.ge	1a28 <main+0x9a8>  // b.tcont
    179c:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    17a0:	add	x0, x0, #0xd98
    17a4:	bl	1040 <printf@plt>
    17a8:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    17ac:	ldr	x1, [sp, #208]
    17b0:	mov	x2, x25
    17b4:	add	x0, x0, #0xdd0
    17b8:	bl	1040 <printf@plt>
    17bc:	adrp	x0, 5000 <_IO_stdin_used+0x3a0>
    17c0:	scvtf	d15, x25
    17c4:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    17c8:	add	x1, x1, #0xcc8
    17cc:	mov	x27, #0x1                   	// #1
    17d0:	ldr	d14, [x0, #16]
    17d4:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    17d8:	add	x0, x0, #0xcd8
    17dc:	stp	x1, x0, [sp, #176]
    17e0:	add	x0, sp, #0xf0
    17e4:	str	x0, [sp, #160]
    17e8:	bl	f70 <std::chrono::_V2::steady_clock::now()@plt>
    17ec:	ldr	x1, [sp, #216]
    17f0:	mov	x28, x0
    17f4:	cmp	x1, #0x6
    17f8:	b.eq	19ac <main+0x92c>  // b.none
    17fc:	cmp	x1, #0x7
    1800:	b.ne	1820 <main+0x7a0>  // b.any
    1804:	ldr	x0, [sp, #208]
    1808:	mov	w1, #0x7561                	// #30049
    180c:	movk	w1, #0x6f74, lsl #16
    1810:	ldr	w2, [x0]
    1814:	cmp	w2, w1
    1818:	b.eq	1a70 <main+0x9f0>  // b.none
    181c:	nop
    1820:	ldp	x0, x1, [sp, #168]
    1824:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1828:	tbnz	w0, #0, 1a04 <main+0x984>
    182c:	ldr	x1, [sp, #184]
    1830:	ldr	x0, [sp, #168]
    1834:	bl	4b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>
    1838:	mov	x6, x25
    183c:	mov	x5, x26
    1840:	mov	x4, x20
    1844:	mov	x3, x21
    1848:	mov	x2, x22
    184c:	mov	x1, x23
    1850:	tbz	w0, #0, 19f8 <main+0x978>
    1854:	mov	x0, x24
    1858:	bl	37e0 <price_scalar_fullpoly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    185c:	bl	f70 <std::chrono::_V2::steady_clock::now()@plt>
    1860:	lsr	x2, x25, #4
    1864:	str	wzr, [sp, #200]
    1868:	mov	x1, #0x0                   	// #0
    186c:	add	x2, x2, #0x1
    1870:	cbz	x25, 189c <main+0x81c>
    1874:	nop
    1878:	nop
    187c:	nop
    1880:	ldr	s30, [x26, x1, lsl #2]
    1884:	add	x1, x1, x2
    1888:	ldr	s31, [sp, #200]
    188c:	fadd	s31, s31, s30
    1890:	str	s31, [sp, #200]
    1894:	cmp	x1, x25
    1898:	b.cc	1880 <main+0x800>  // b.lo, b.ul, b.last
    189c:	sub	x2, x0, x28
    18a0:	ldr	x0, [sp, #160]
    18a4:	mov	w1, w27
    18a8:	scvtf	d1, x2
    18ac:	ldr	s31, [sp, #200]
    18b0:	add	x3, x0, x27, lsl #3
    18b4:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    18b8:	add	x0, x0, #0xde8
    18bc:	fdiv	d0, d1, d15
    18c0:	fmul	d1, d1, d14
    18c4:	fdiv	d1, d15, d1
    18c8:	stur	d0, [x3, #-8]
    18cc:	bl	1040 <printf@plt>
    18d0:	add	x27, x27, #0x1
    18d4:	cmp	x27, #0x6
    18d8:	b.ne	17e8 <main+0x768>  // b.any
    18dc:	ldp	q30, q31, [sp, #240]
    18e0:	add	x4, sp, #0x200
    18e4:	add	x11, x19, #0x28
    18e8:	mov	x1, x11
    18ec:	mov	x2, #0x4                   	// #4
    18f0:	ldr	x3, [sp, #272]
    18f4:	mov	x0, x19
    18f8:	stur	q30, [x4, #-232]
    18fc:	add	x4, sp, #0x220
    1900:	stur	q31, [x4, #-248]
    1904:	str	x3, [sp, #312]
    1908:	bl	1e80 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    190c:	mov	x1, x11
    1910:	mov	x0, x19
    1914:	bl	1da4 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1918:	mov	x1, #0xcd6500000000        	// #225833675390976
    191c:	ldr	d0, [sp, #296]
    1920:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1924:	movk	x1, #0x41cd, lsl #48
    1928:	add	x0, x0, #0xe10
    192c:	fmov	d1, x1
    1930:	fdiv	d1, d1, d0
    1934:	bl	1040 <printf@plt>
    1938:	mov	x0, x24
    193c:	mov	w19, #0x0                   	// #0
    1940:	bl	eb0 <free@plt>
    1944:	mov	x0, x23
    1948:	bl	eb0 <free@plt>
    194c:	mov	x0, x22
    1950:	bl	eb0 <free@plt>
    1954:	mov	x0, x21
    1958:	bl	eb0 <free@plt>
    195c:	mov	x0, x20
    1960:	bl	eb0 <free@plt>
    1964:	mov	x0, x26
    1968:	bl	eb0 <free@plt>
    196c:	ldr	x0, [sp, #168]
    1970:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1974:	mov	x12, #0x14a0                	// #5280
    1978:	ldp	d8, d9, [sp, #96]
    197c:	ldp	x29, x30, [sp]
    1980:	mov	w0, w19
    1984:	ldp	x19, x20, [sp, #16]
    1988:	ldp	x21, x22, [sp, #32]
    198c:	ldp	x23, x24, [sp, #48]
    1990:	ldp	x25, x26, [sp, #64]
    1994:	ldp	x27, x28, [sp, #80]
    1998:	ldp	d10, d11, [sp, #112]
    199c:	ldp	d12, d13, [sp, #128]
    19a0:	ldp	d14, d15, [sp, #144]
    19a4:	add	sp, sp, x12
    19a8:	ret
    19ac:	ldr	x0, [sp, #208]
    19b0:	mov	w1, #0x6373                	// #25459
    19b4:	movk	w1, #0x6c61, lsl #16
    19b8:	ldr	w2, [x0]
    19bc:	cmp	w2, w1
    19c0:	b.ne	1820 <main+0x7a0>  // b.any
    19c4:	ldrh	w1, [x0, #4]
    19c8:	mov	w0, #0x7261                	// #29281
    19cc:	cmp	w1, w0
    19d0:	b.ne	1820 <main+0x7a0>  // b.any
    19d4:	mov	x6, x25
    19d8:	mov	x5, x26
    19dc:	mov	x4, x20
    19e0:	mov	x3, x21
    19e4:	mov	x2, x22
    19e8:	mov	x1, x23
    19ec:	mov	x0, x24
    19f0:	bl	20a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    19f4:	b	185c <main+0x7dc>
    19f8:	mov	x0, x24
    19fc:	bl	3ee0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1a00:	b	185c <main+0x7dc>
    1a04:	mov	x6, x25
    1a08:	mov	x5, x26
    1a0c:	mov	x4, x20
    1a10:	mov	x3, x21
    1a14:	mov	x2, x22
    1a18:	mov	x1, x23
    1a1c:	mov	x0, x24
    1a20:	bl	3020 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1a24:	b	185c <main+0x7dc>
    1a28:	adrp	x0, 1f000 <__abi_tag+0x199f8>
    1a2c:	ldr	x0, [x0, #4056]
    1a30:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1a34:	add	x1, x1, #0xd60
    1a38:	ldr	x2, [sp, #208]
    1a3c:	ldr	x0, [x0]
    1a40:	bl	e90 <fprintf@plt>
    1a44:	mov	w19, #0x1                   	// #1
    1a48:	b	196c <main+0x8ec>
    1a4c:	mov	x6, x27
    1a50:	mov	x5, x26
    1a54:	mov	x4, x20
    1a58:	mov	x3, x21
    1a5c:	mov	x2, x22
    1a60:	mov	x1, x23
    1a64:	mov	x0, x24
    1a68:	bl	20a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1a6c:	b	1754 <main+0x6d4>
    1a70:	ldrh	w2, [x0, #4]
    1a74:	mov	w1, #0x6576                	// #25974
    1a78:	cmp	w2, w1
    1a7c:	b.ne	1820 <main+0x7a0>  // b.any
    1a80:	ldrb	w0, [x0, #6]
    1a84:	cmp	w0, #0x63
    1a88:	b.ne	1820 <main+0x7a0>  // b.any
    1a8c:	mov	x6, x25
    1a90:	mov	x5, x26
    1a94:	mov	x4, x20
    1a98:	mov	x3, x21
    1a9c:	mov	x2, x22
    1aa0:	mov	x1, x23
    1aa4:	mov	x0, x24
    1aa8:	bl	2860 <price_autovec(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1aac:	b	185c <main+0x7dc>
    1ab0:	mov	x0, x24
    1ab4:	bl	3ee0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1ab8:	b	1754 <main+0x6d4>
    1abc:	mov	x6, x27
    1ac0:	mov	x5, x26
    1ac4:	mov	x4, x20
    1ac8:	mov	x3, x21
    1acc:	mov	x2, x22
    1ad0:	mov	x1, x23
    1ad4:	mov	x0, x24
    1ad8:	bl	3020 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>
    1adc:	b	1754 <main+0x6d4>
    1ae0:	mov	x25, #0x100000              	// #1048576
    1ae4:	b	1130 <main+0xb0>
    1ae8:	mov	x20, x0
    1aec:	ldr	x0, [sp, #168]
    1af0:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1af4:	mov	x0, x20
    1af8:	bl	1000 <_Unwind_Resume@plt>
    1afc:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1b00:	add	x0, x0, #0xcb0
    1b04:	bl	f80 <std::__throw_out_of_range(char const*)@plt>
    1b08:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    1b0c:	add	x0, x0, #0xcb0
    1b10:	bl	ee0 <std::__throw_invalid_argument(char const*)@plt>
    1b14:	ldr	w1, [x23]
    1b18:	mov	x20, x0
    1b1c:	cbnz	w1, 1b24 <main+0xaa4>
    1b20:	str	w28, [x23]
    1b24:	mov	x0, x19
    1b28:	bl	f30 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_dispose()@plt>
    1b2c:	b	1aec <main+0xa6c>
    1b30:	nop
    1b34:	nop
    1b38:	nop
    1b3c:	nop

0000000000001b40 <_start>:
    1b40:	bti	c
    1b44:	mov	x29, #0x0                   	// #0
    1b48:	mov	x30, #0x0                   	// #0
    1b4c:	mov	x5, x0
    1b50:	ldr	x1, [sp]
    1b54:	add	x2, sp, #0x8
    1b58:	mov	x6, sp
    1b5c:	adrp	x0, 1f000 <__abi_tag+0x199f8>
    1b60:	ldr	x0, [x0, #4024]
    1b64:	mov	x3, #0x0                   	// #0
    1b68:	mov	x4, #0x0                   	// #0
    1b6c:	bl	f10 <__libc_start_main@plt>
    1b70:	bl	fb0 <abort@plt>

0000000000001b74 <call_weak_fn>:
    1b74:	adrp	x0, 1f000 <__abi_tag+0x199f8>
    1b78:	ldr	x0, [x0, #4048]
    1b7c:	cbz	x0, 1b84 <call_weak_fn+0x10>
    1b80:	b	1030 <__gmon_start__@plt>
    1b84:	ret
    1b88:	nop
    1b8c:	nop
    1b90:	nop
    1b94:	nop
    1b98:	nop
    1b9c:	nop

0000000000001ba0 <deregister_tm_clones>:
    1ba0:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1ba4:	add	x0, x0, #0x108
    1ba8:	adrp	x1, 20000 <memcpy@GLIBC_2.17>
    1bac:	add	x1, x1, #0x108
    1bb0:	cmp	x1, x0
    1bb4:	b.eq	1bcc <deregister_tm_clones+0x2c>  // b.none
    1bb8:	adrp	x1, 1f000 <__abi_tag+0x199f8>
    1bbc:	ldr	x1, [x1, #4040]
    1bc0:	cbz	x1, 1bcc <deregister_tm_clones+0x2c>
    1bc4:	mov	x16, x1
    1bc8:	br	x16
    1bcc:	ret

0000000000001bd0 <register_tm_clones>:
    1bd0:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1bd4:	add	x0, x0, #0x108
    1bd8:	adrp	x1, 20000 <memcpy@GLIBC_2.17>
    1bdc:	add	x1, x1, #0x108
    1be0:	sub	x1, x1, x0
    1be4:	lsr	x2, x1, #63
    1be8:	add	x1, x2, x1, asr #3
    1bec:	asr	x1, x1, #1
    1bf0:	cbz	x1, 1c08 <register_tm_clones+0x38>
    1bf4:	adrp	x2, 1f000 <__abi_tag+0x199f8>
    1bf8:	ldr	x2, [x2, #4064]
    1bfc:	cbz	x2, 1c08 <register_tm_clones+0x38>
    1c00:	mov	x16, x2
    1c04:	br	x16
    1c08:	ret

0000000000001c0c <__do_global_dtors_aux>:
    1c0c:	paciasp
    1c10:	stp	x29, x30, [sp, #-32]!
    1c14:	mov	x29, sp
    1c18:	str	x19, [sp, #16]
    1c1c:	adrp	x19, 20000 <memcpy@GLIBC_2.17>
    1c20:	ldrb	w0, [x19, #264]
    1c24:	tbnz	w0, #0, 1c4c <__do_global_dtors_aux+0x40>
    1c28:	adrp	x0, 1f000 <__abi_tag+0x199f8>
    1c2c:	ldr	x0, [x0, #4032]
    1c30:	cbz	x0, 1c40 <__do_global_dtors_aux+0x34>
    1c34:	adrp	x0, 20000 <memcpy@GLIBC_2.17>
    1c38:	ldr	x0, [x0, #248]
    1c3c:	bl	ed0 <__cxa_finalize@plt>
    1c40:	bl	1ba0 <deregister_tm_clones>
    1c44:	mov	w0, #0x1                   	// #1
    1c48:	strb	w0, [x19, #264]
    1c4c:	ldr	x19, [sp, #16]
    1c50:	ldp	x29, x30, [sp], #32
    1c54:	autiasp
    1c58:	ret
    1c5c:	nop

0000000000001c60 <frame_dummy>:
    1c60:	bti	c
    1c64:	b	1bd0 <register_tm_clones>
    1c68:	nop
    1c6c:	nop
    1c70:	nop
    1c74:	nop
    1c78:	nop
    1c7c:	nop

0000000000001c80 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1c80:	sub	x7, x2, #0x1
    1c84:	and	x8, x2, #0x1
    1c88:	add	x7, x7, x7, lsr #63
    1c8c:	asr	x7, x7, #1
    1c90:	cmp	x1, x7
    1c94:	b.ge	1d84 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x104>  // b.tcont
    1c98:	mov	x4, x1
    1c9c:	nop
    1ca0:	add	x3, x4, #0x1
    1ca4:	add	x5, x0, x3, lsl #4
    1ca8:	lsl	x6, x3, #4
    1cac:	lsl	x3, x3, #1
    1cb0:	ldr	d31, [x0, x6]
    1cb4:	ldur	d1, [x5, #-8]
    1cb8:	fcmpe	d31, d1
    1cbc:	b.mi	1cd4 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x54>  // b.first
    1cc0:	str	d31, [x0, x4, lsl #3]
    1cc4:	cmp	x3, x7
    1cc8:	b.ge	1cec <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x6c>  // b.tcont
    1ccc:	mov	x4, x3
    1cd0:	b	1ca0 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x20>
    1cd4:	sub	x3, x3, #0x1
    1cd8:	add	x5, x0, x3, lsl #3
    1cdc:	ldr	d31, [x0, x3, lsl #3]
    1ce0:	str	d31, [x0, x4, lsl #3]
    1ce4:	cmp	x3, x7
    1ce8:	b.lt	1ccc <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x4c>  // b.tstop
    1cec:	cbz	x8, 1d48 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>
    1cf0:	sub	x4, x3, #0x1
    1cf4:	add	x4, x4, x4, lsr #63
    1cf8:	asr	x4, x4, #1
    1cfc:	cmp	x3, x1
    1d00:	b.le	1d2c <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>
    1d04:	ldr	d30, [x0, x4, lsl #3]
    1d08:	sub	x2, x4, #0x1
    1d0c:	add	x5, x0, x3, lsl #3
    1d10:	add	x2, x2, x2, lsr #63
    1d14:	lsl	x6, x3, #3
    1d18:	mov	x3, x4
    1d1c:	add	x7, x0, x4, lsl #3
    1d20:	asr	x2, x2, #1
    1d24:	fcmpe	d30, d0
    1d28:	b.mi	1d34 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xb4>  // b.first
    1d2c:	str	d0, [x5]
    1d30:	ret
    1d34:	str	d30, [x0, x6]
    1d38:	cmp	x1, x4
    1d3c:	b.ge	1d78 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xf8>  // b.tcont
    1d40:	mov	x4, x2
    1d44:	b	1d04 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>
    1d48:	sub	x2, x2, #0x2
    1d4c:	add	x2, x2, x2, lsr #63
    1d50:	cmp	x3, x2, asr #1
    1d54:	b.ne	1cf0 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>  // b.any
    1d58:	add	x3, x3, #0x1
    1d5c:	add	x2, x0, x3, lsl #4
    1d60:	lsl	x3, x3, #1
    1d64:	sub	x3, x3, #0x1
    1d68:	ldur	d31, [x2, #-8]
    1d6c:	str	d31, [x5]
    1d70:	add	x5, x0, x3, lsl #3
    1d74:	b	1cf0 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>
    1d78:	mov	x5, x7
    1d7c:	str	d0, [x5]
    1d80:	ret
    1d84:	add	x5, x0, x1, lsl #3
    1d88:	cbnz	x8, 1d2c <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>
    1d8c:	sub	x2, x2, #0x2
    1d90:	add	x2, x2, x2, lsr #63
    1d94:	cmp	x1, x2, asr #1
    1d98:	b.ne	1d2c <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xac>  // b.any
    1d9c:	mov	x3, x1
    1da0:	b	1d58 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xd8>

0000000000001da4 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1da4:	cmp	x0, x1
    1da8:	b.eq	1e74 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xd0>  // b.none
    1dac:	stp	x29, x30, [sp, #-64]!
    1db0:	mov	x29, sp
    1db4:	stp	x19, x20, [sp, #16]
    1db8:	add	x19, x0, #0x8
    1dbc:	mov	x20, x0
    1dc0:	stp	x21, x22, [sp, #32]
    1dc4:	mov	x21, x1
    1dc8:	cmp	x1, x19
    1dcc:	b.eq	1e18 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x74>  // b.none
    1dd0:	mov	x22, #0x8                   	// #8
    1dd4:	stp	d14, d15, [sp, #48]
    1dd8:	nop
    1ddc:	nop
    1de0:	ldr	d15, [x19]
    1de4:	ldr	d14, [x20]
    1de8:	fcmpe	d15, d14
    1dec:	b.mi	1e40 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x9c>  // b.first
    1df0:	ldur	d31, [x19, #-8]
    1df4:	sub	x2, x19, #0x8
    1df8:	fcmpe	d15, d31
    1dfc:	b.mi	1e28 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>  // b.first
    1e00:	mov	x3, x19
    1e04:	str	d15, [x3]
    1e08:	add	x19, x19, #0x8
    1e0c:	cmp	x21, x19
    1e10:	b.ne	1de0 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x3c>  // b.any
    1e14:	ldp	d14, d15, [sp, #48]
    1e18:	ldp	x19, x20, [sp, #16]
    1e1c:	ldp	x21, x22, [sp, #32]
    1e20:	ldp	x29, x30, [sp], #64
    1e24:	ret
    1e28:	mov	x3, x2
    1e2c:	str	d31, [x2, #8]
    1e30:	ldr	d31, [x2, #-8]!
    1e34:	fcmpe	d15, d31
    1e38:	b.mi	1e28 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x84>  // b.first
    1e3c:	b	1e04 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x60>
    1e40:	sub	x2, x19, x20
    1e44:	cmp	x2, #0x8
    1e48:	b.le	1e64 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc0>
    1e4c:	sub	x0, x22, x2
    1e50:	mov	x1, x20
    1e54:	add	x0, x19, x0
    1e58:	bl	f40 <memmove@plt>
    1e5c:	str	d15, [x20]
    1e60:	b	1e08 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>
    1e64:	b.ne	1e5c <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xb8>  // b.any
    1e68:	str	d14, [x19]
    1e6c:	str	d15, [x20]
    1e70:	b	1e08 <void std::__insertion_sort<double*, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>
    1e74:	ret
    1e78:	nop
    1e7c:	nop

0000000000001e80 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>:
    1e80:	stp	x29, x30, [sp, #-48]!
    1e84:	mov	x29, sp
    1e88:	stp	x19, x20, [sp, #16]
    1e8c:	mov	x20, x0
    1e90:	sub	x0, x1, x0
    1e94:	cmp	x0, #0x80
    1e98:	b.le	200c <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x18c>
    1e9c:	asr	x10, x0, #3
    1ea0:	mov	x9, x1
    1ea4:	str	x21, [sp, #32]
    1ea8:	mov	x21, x2
    1eac:	asr	x0, x0, #4
    1eb0:	cbz	x21, 1fa8 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x128>
    1eb4:	lsl	x0, x0, #3
    1eb8:	ldp	d28, d31, [x20]
    1ebc:	sub	x21, x21, #0x1
    1ec0:	add	x19, x20, #0x8
    1ec4:	ldr	d30, [x20, x0]
    1ec8:	ldur	d0, [x9, #-8]
    1ecc:	fcmpe	d31, d30
    1ed0:	b.mi	2028 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x1a8>  // b.first
    1ed4:	fcmpe	d31, d0
    1ed8:	b.mi	2038 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x1b8>  // b.first
    1edc:	fcmpe	d30, d0
    1ee0:	b.mi	2018 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x198>  // b.first
    1ee4:	str	d30, [x20]
    1ee8:	str	d28, [x20, x0]
    1eec:	ldp	d31, d28, [x20]
    1ef0:	mov	x3, x9
    1ef4:	nop
    1ef8:	nop
    1efc:	nop
    1f00:	fcmpe	d31, d28
    1f04:	b.gt	1f48 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>
    1f08:	ldur	d29, [x3, #-8]
    1f0c:	sub	x0, x3, #0x8
    1f10:	fcmpe	d29, d31
    1f14:	b.gt	1f68 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1f18:	nop
    1f1c:	nop
    1f20:	cmp	x19, x0
    1f24:	b.cs	1f7c <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xfc>  // b.hs, b.nlast
    1f28:	mov	x1, x19
    1f2c:	mov	x3, x0
    1f30:	str	d29, [x1], #8
    1f34:	str	d28, [x0]
    1f38:	ldr	d31, [x20]
    1f3c:	ldr	d28, [x19, #8]
    1f40:	mov	x19, x1
    1f44:	b	1f00 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x80>
    1f48:	ldr	d28, [x19, #8]!
    1f4c:	fcmpe	d28, d31
    1f50:	b.mi	1f48 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xc8>  // b.first
    1f54:	ldur	d29, [x3, #-8]
    1f58:	sub	x0, x3, #0x8
    1f5c:	fcmpe	d29, d31
    1f60:	b.gt	1f68 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1f64:	b	1f20 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xa0>
    1f68:	ldr	d29, [x0, #-8]!
    1f6c:	fcmpe	d29, d31
    1f70:	b.gt	1f68 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xe8>
    1f74:	cmp	x19, x0
    1f78:	b.cc	1f28 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0xa8>  // b.lo, b.ul, b.last
    1f7c:	mov	x0, x19
    1f80:	mov	x1, x9
    1f84:	mov	x2, x21
    1f88:	bl	1e80 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1f8c:	sub	x0, x19, x20
    1f90:	cmp	x0, #0x80
    1f94:	b.le	2008 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x188>
    1f98:	asr	x10, x0, #3
    1f9c:	mov	x9, x19
    1fa0:	asr	x0, x0, #4
    1fa4:	cbnz	x21, 1eb4 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x34>
    1fa8:	sub	x1, x0, #0x1
    1fac:	b	1fb4 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x134>
    1fb0:	sub	x1, x1, #0x1
    1fb4:	ldr	d0, [x20, x1, lsl #3]
    1fb8:	mov	x2, x10
    1fbc:	mov	x0, x20
    1fc0:	bl	1c80 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    1fc4:	cbnz	x1, 1fb0 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x130>
    1fc8:	sub	x0, x9, x20
    1fcc:	cmp	x0, #0x8
    1fd0:	b.le	2008 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x188>
    1fd4:	nop
    1fd8:	nop
    1fdc:	nop
    1fe0:	ldr	d0, [x9, #-8]!
    1fe4:	mov	x1, #0x0                   	// #0
    1fe8:	mov	x0, x20
    1fec:	ldr	d31, [x20]
    1ff0:	sub	x10, x9, x20
    1ff4:	asr	x2, x10, #3
    1ff8:	str	d31, [x9]
    1ffc:	bl	1c80 <void std::__adjust_heap<double*, long, double, __gnu_cxx::__ops::_Iter_less_iter>(double*, long, long, double, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]>
    2000:	cmp	x10, #0x8
    2004:	b.gt	1fe0 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x160>
    2008:	ldr	x21, [sp, #32]
    200c:	ldp	x19, x20, [sp, #16]
    2010:	ldp	x29, x30, [sp], #48
    2014:	ret
    2018:	str	d0, [x20]
    201c:	stur	d28, [x9, #-8]
    2020:	ldp	d31, d28, [x20]
    2024:	b	1ef0 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>
    2028:	fcmpe	d30, d0
    202c:	b.mi	1ee4 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x64>  // b.first
    2030:	fcmpe	d31, d0
    2034:	b.mi	2018 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x198>  // b.first
    2038:	stp	d31, d28, [x20]
    203c:	b	1ef0 <void std::__introsort_loop<double*, long, __gnu_cxx::__ops::_Iter_less_iter>(double*, double*, long, __gnu_cxx::__ops::_Iter_less_iter) [clone .isra.0]+0x70>

0000000000002040 <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]>:
    2040:	stp	x29, x30, [sp, #-32]!
    2044:	lsl	x2, x0, #2
    2048:	mov	x29, sp
    204c:	mov	x1, #0x10                  	// #16
    2050:	add	x0, sp, #0x18
    2054:	str	xzr, [sp, #24]
    2058:	bl	f20 <posix_memalign@plt>
    205c:	cbnz	w0, 206c <main::{lambda(unsigned long)#1}::operator()(unsigned long) const [clone .isra.0]+0x2c>
    2060:	ldr	x0, [sp, #24]
    2064:	ldp	x29, x30, [sp], #32
    2068:	ret
    206c:	adrp	x3, 1f000 <__abi_tag+0x199f8>
    2070:	ldr	x3, [x3, #4056]
    2074:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    2078:	mov	x2, #0x16                  	// #22
    207c:	add	x0, x0, #0xc68
    2080:	mov	x1, #0x1                   	// #1
    2084:	ldr	x3, [x3]
    2088:	bl	ff0 <fwrite@plt>
    208c:	mov	w0, #0x1                   	// #1
    2090:	bl	fe0 <exit@plt>
    2094:	nop
    2098:	nop
    209c:	nop

00000000000020a0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    20a0:	cbz	x6, 285c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    20a4:	stp	x29, x30, [sp, #-160]!
    20a8:	mov	x29, sp
    20ac:	stp	x23, x24, [sp, #48]
    20b0:	mov	x24, x4
    20b4:	mov	w4, #0xaa3b                	// #43579
    20b8:	movk	w4, #0x3fb8, lsl #16
    20bc:	mov	x23, x3
    20c0:	mov	w3, #0x7218                	// #29208
    20c4:	stp	x19, x20, [sp, #16]
    20c8:	mov	x20, x0
    20cc:	mov	w0, #0xc2b00000            	// #-1028653056
    20d0:	movk	w3, #0x3f31, lsl #16
    20d4:	mov	x19, x6
    20d8:	stp	d8, d9, [sp, #80]
    20dc:	fmov	s9, w0
    20e0:	stp	d14, d15, [sp, #128]
    20e4:	fmov	s14, w4
    20e8:	stp	x21, x22, [sp, #32]
    20ec:	mov	x21, x1
    20f0:	mov	x22, x2
    20f4:	mov	w1, #0x8889                	// #34953
    20f8:	mov	w2, #0xb61                 	// #2913
    20fc:	movk	w2, #0x3ab6, lsl #16
    2100:	movk	w1, #0x3c08, lsl #16
    2104:	stp	x25, x26, [sp, #64]
    2108:	mov	x26, #0x0                   	// #0
    210c:	mov	x25, x5
    2110:	stp	d10, d11, [sp, #96]
    2114:	stp	d12, d13, [sp, #112]
    2118:	stp	w3, w2, [sp, #148]
    211c:	str	w1, [sp, #156]
    2120:	ldr	s12, [x22, x26, lsl #2]
    2124:	ldr	s15, [x24, x26, lsl #2]
    2128:	ldr	s13, [x20, x26, lsl #2]
    212c:	fcmp	s12, #0.0
    2130:	ldr	s8, [x21, x26, lsl #2]
    2134:	ldr	s11, [x23, x26, lsl #2]
    2138:	fmul	s10, s15, s15
    213c:	b.pl	21f4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    2140:	fmov	s0, s12
    2144:	bl	ec0 <sqrtf@plt>
    2148:	fmov	s31, s0
    214c:	fdiv	s0, s13, s8
    2150:	fmul	s15, s15, s31
    2154:	bl	1020 <logf@plt>
    2158:	fmov	s31, #5.000000000000000000e-01
    215c:	mov	w0, #0x3389                	// #13193
    2160:	fmov	s25, #1.000000000000000000e+00
    2164:	movk	w0, #0x3e6d, lsl #16
    2168:	mov	w1, #0x466f                	// #18031
    216c:	fmov	s19, #-5.000000000000000000e-01
    2170:	mov	w4, #0x1eea                	// #7914
    2174:	movk	w1, #0x3faa, lsl #16
    2178:	fmov	s29, w0
    217c:	movk	w4, #0xbfe9, lsl #16
    2180:	mov	w3, #0x778                 	// #1912
    2184:	fmadd	s10, s10, s31, s11
    2188:	movk	w3, #0x3fe4, lsl #16
    218c:	mov	w2, #0x8f89                	// #36745
    2190:	fmov	s20, w1
    2194:	movk	w2, #0xbeb6, lsl #16
    2198:	mov	w1, #0x85fa                	// #34298
    219c:	movk	w1, #0x3ea3, lsl #16
    21a0:	mov	w0, #0xaa3b                	// #43579
    21a4:	fmov	s22, w4
    21a8:	movk	w0, #0x3fb8, lsl #16
    21ac:	fmov	s23, w3
    21b0:	fmadd	s0, s12, s10, s0
    21b4:	fmov	s24, w2
    21b8:	fmov	s31, w1
    21bc:	fmov	s28, w0
    21c0:	fdiv	s0, s0, s15
    21c4:	fmadd	s21, s0, s29, s25
    21c8:	fmul	s29, s0, s19
    21cc:	fsub	s15, s0, s15
    21d0:	fmul	s29, s29, s0
    21d4:	fdiv	s25, s25, s21
    21d8:	fmul	s28, s29, s28
    21dc:	fmadd	s22, s25, s20, s22
    21e0:	fmadd	s23, s22, s25, s23
    21e4:	fmadd	s24, s23, s25, s24
    21e8:	fmadd	s31, s24, s25, s31
    21ec:	fmul	s31, s31, s25
    21f0:	b	22b8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    21f4:	fsqrt	s31, s12
    21f8:	fdiv	s0, s13, s8
    21fc:	fmul	s15, s15, s31
    2200:	bl	1020 <logf@plt>
    2204:	fmov	s29, #5.000000000000000000e-01
    2208:	fmadd	s10, s10, s29, s11
    220c:	fmadd	s0, s12, s10, s0
    2210:	fdiv	s0, s0, s15
    2214:	fcmpe	s0, #0.0
    2218:	fsub	s15, s0, s15
    221c:	b.mi	25fc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    2220:	mov	w0, #0x3389                	// #13193
    2224:	fmov	s31, #1.000000000000000000e+00
    2228:	mov	w4, #0x466f                	// #18031
    222c:	movk	w0, #0x3e6d, lsl #16
    2230:	mov	w3, #0x1eea                	// #7914
    2234:	fmov	s29, #-5.000000000000000000e-01
    2238:	movk	w4, #0x3faa, lsl #16
    223c:	movk	w3, #0xbfe9, lsl #16
    2240:	fmov	s22, w0
    2244:	mov	w2, #0x778                 	// #1912
    2248:	mov	w1, #0x8f89                	// #36745
    224c:	fmov	s21, w4
    2250:	movk	w2, #0x3fe4, lsl #16
    2254:	movk	w1, #0xbeb6, lsl #16
    2258:	fmov	s23, w3
    225c:	mov	w0, #0x85fa                	// #34298
    2260:	fmov	s24, w2
    2264:	movk	w0, #0x3ea3, lsl #16
    2268:	fmov	s25, w1
    226c:	fmov	s28, w0
    2270:	fmul	s29, s0, s29
    2274:	fmadd	s22, s0, s22, s31
    2278:	fmul	s29, s29, s0
    227c:	fcmpe	s29, s9
    2280:	fdiv	s31, s31, s22
    2284:	fmadd	s23, s31, s21, s23
    2288:	fmadd	s24, s31, s23, s24
    228c:	fmadd	s25, s31, s24, s25
    2290:	fmadd	s28, s31, s25, s28
    2294:	fmul	s31, s31, s28
    2298:	b.mi	270c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    229c:	mov	w0, #0x42b00000            	// #1118830592
    22a0:	fmov	s28, w0
    22a4:	fcmpe	s29, s28
    22a8:	b.gt	2358 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    22ac:	fmul	s28, s29, s14
    22b0:	fcmpe	s28, #0.0
    22b4:	b.ge	276c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    22b8:	fmov	s23, #5.000000000000000000e-01
    22bc:	mov	w0, #0x7218                	// #29208
    22c0:	mov	w3, #0xb61                 	// #2913
    22c4:	movk	w0, #0x3f31, lsl #16
    22c8:	mov	w2, #0x8889                	// #34953
    22cc:	fmov	s24, #1.000000000000000000e+00
    22d0:	movk	w3, #0x3ab6, lsl #16
    22d4:	movk	w2, #0x3c08, lsl #16
    22d8:	fmov	s25, w0
    22dc:	mov	w1, #0xaaab                	// #43691
    22e0:	mov	w0, #0xaaab                	// #43691
    22e4:	fsub	s28, s28, s23
    22e8:	movk	w1, #0x3d2a, lsl #16
    22ec:	movk	w0, #0x3e2a, lsl #16
    22f0:	fmov	s18, w3
    22f4:	mov	w4, #0x422a                	// #16938
    22f8:	fmov	s20, w2
    22fc:	movk	w4, #0x3ecc, lsl #16
    2300:	fmov	s21, w1
    2304:	fmov	s22, w0
    2308:	fmov	s19, w4
    230c:	fcvtzs	s28, s28
    2310:	scvtf	s28, s28
    2314:	fmsub	s25, s28, s25, s29
    2318:	fcvtzs	w0, s28
    231c:	fmadd	s28, s25, s18, s20
    2320:	add	w0, w0, #0x7f
    2324:	fmov	s30, w0
    2328:	fmadd	s28, s25, s28, s21
    232c:	fmadd	s28, s25, s28, s22
    2330:	shl	v29.2s, v30.2s, #23
    2334:	fmadd	s23, s25, s28, s23
    2338:	fmadd	s23, s25, s23, s24
    233c:	fmadd	s24, s25, s23, s24
    2340:	fmul	s29, s24, s29
    2344:	fmul	s29, s29, s19
    2348:	fcmpe	s0, #0.0
    234c:	fmul	s31, s31, s29
    2350:	b.mi	2370 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    2354:	b	2368 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2358:	mov	w0, #0x484f                	// #18511
    235c:	movk	w0, #0x7e46, lsl #16
    2360:	fmov	s29, w0
    2364:	fmul	s31, s31, s29
    2368:	fmov	s29, #1.000000000000000000e+00
    236c:	fsub	s31, s29, s31
    2370:	fnmul	s30, s11, s12
    2374:	fmul	s31, s13, s31
    2378:	movi	v29.2s, #0x0
    237c:	fcmpe	s30, s9
    2380:	b.mi	2420 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    2384:	mov	w0, #0x42b00000            	// #1118830592
    2388:	fmov	s29, w0
    238c:	fcmpe	s30, s29
    2390:	b.gt	2718 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    2394:	fmul	s28, s30, s14
    2398:	fcmpe	s28, #0.0
    239c:	b.ge	2728 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    23a0:	fmov	s27, #5.000000000000000000e-01
    23a4:	mov	w0, #0x7218                	// #29208
    23a8:	mov	w3, #0xb61                 	// #2913
    23ac:	movk	w0, #0x3f31, lsl #16
    23b0:	mov	w2, #0x8889                	// #34953
    23b4:	fmov	s29, #1.000000000000000000e+00
    23b8:	movk	w3, #0x3ab6, lsl #16
    23bc:	movk	w2, #0x3c08, lsl #16
    23c0:	fmov	s22, w0
    23c4:	mov	w1, #0xaaab                	// #43691
    23c8:	mov	w0, #0xaaab                	// #43691
    23cc:	fsub	s28, s28, s27
    23d0:	movk	w1, #0x3d2a, lsl #16
    23d4:	movk	w0, #0x3e2a, lsl #16
    23d8:	fmov	s23, w3
    23dc:	fmov	s24, w2
    23e0:	fmov	s25, w1
    23e4:	fmov	s26, w0
    23e8:	fcvtzs	s28, s28
    23ec:	scvtf	s28, s28
    23f0:	fmsub	s30, s28, s22, s30
    23f4:	fcvtzs	w0, s28
    23f8:	fmadd	s24, s30, s23, s24
    23fc:	fmadd	s25, s30, s24, s25
    2400:	add	w0, w0, #0x7f
    2404:	fmov	s28, w0
    2408:	fmadd	s26, s30, s25, s26
    240c:	fmadd	s27, s30, s26, s27
    2410:	shl	v28.2s, v28.2s, #23
    2414:	fmadd	s27, s30, s27, s29
    2418:	fmadd	s29, s30, s27, s29
    241c:	fmul	s29, s29, s28
    2420:	fcmpe	s15, #0.0
    2424:	fmul	s29, s8, s29
    2428:	b.mi	2684 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    242c:	mov	w0, #0x3389                	// #13193
    2430:	fmov	s30, #1.000000000000000000e+00
    2434:	mov	w4, #0x466f                	// #18031
    2438:	movk	w0, #0x3e6d, lsl #16
    243c:	mov	w3, #0x1eea                	// #7914
    2440:	fmov	s27, #-5.000000000000000000e-01
    2444:	movk	w4, #0x3faa, lsl #16
    2448:	movk	w3, #0xbfe9, lsl #16
    244c:	fmov	s23, w0
    2450:	mov	w2, #0x778                 	// #1912
    2454:	mov	w1, #0x8f89                	// #36745
    2458:	fmov	s22, w4
    245c:	movk	w2, #0x3fe4, lsl #16
    2460:	movk	w1, #0xbeb6, lsl #16
    2464:	fmov	s24, w3
    2468:	mov	w0, #0x85fa                	// #34298
    246c:	fmov	s25, w2
    2470:	movk	w0, #0x3ea3, lsl #16
    2474:	fmov	s26, w1
    2478:	fmov	s28, w0
    247c:	fmul	s27, s15, s27
    2480:	fmadd	s23, s15, s23, s30
    2484:	fmul	s27, s27, s15
    2488:	fcmpe	s27, s9
    248c:	fdiv	s30, s30, s23
    2490:	fmadd	s24, s30, s22, s24
    2494:	fmadd	s25, s30, s24, s25
    2498:	fmadd	s26, s30, s25, s26
    249c:	fmadd	s28, s30, s26, s28
    24a0:	fmul	s30, s30, s28
    24a4:	b.mi	2704 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    24a8:	mov	w0, #0x42b00000            	// #1118830592
    24ac:	fmov	s28, w0
    24b0:	fcmpe	s27, s28
    24b4:	b.gt	25ac <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    24b8:	nop
    24bc:	nop
    24c0:	fmul	s28, s27, s14
    24c4:	fcmpe	s28, #0.0
    24c8:	b.ge	27e4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    24cc:	fmov	s25, #5.000000000000000000e-01
    24d0:	mov	w0, #0x7218                	// #29208
    24d4:	mov	w4, #0xb61                 	// #2913
    24d8:	movk	w0, #0x3f31, lsl #16
    24dc:	mov	w2, #0x8889                	// #34953
    24e0:	fmov	s26, #1.000000000000000000e+00
    24e4:	movk	w4, #0x3ab6, lsl #16
    24e8:	movk	w2, #0x3c08, lsl #16
    24ec:	fmov	s19, w0
    24f0:	mov	w1, #0xaaab                	// #43691
    24f4:	mov	w0, #0xaaab                	// #43691
    24f8:	fsub	s28, s28, s25
    24fc:	movk	w1, #0x3d2a, lsl #16
    2500:	movk	w0, #0x3e2a, lsl #16
    2504:	fmov	s20, w4
    2508:	mov	w3, #0x422a                	// #16938
    250c:	fmov	s22, w2
    2510:	movk	w3, #0x3ecc, lsl #16
    2514:	fmov	s23, w1
    2518:	fmov	s24, w0
    251c:	fmov	s21, w3
    2520:	fcvtzs	s28, s28
    2524:	scvtf	s28, s28
    2528:	fmsub	s27, s28, s19, s27
    252c:	fcvtzs	w0, s28
    2530:	fmadd	s22, s27, s20, s22
    2534:	add	w0, w0, #0x7f
    2538:	fmov	s28, w0
    253c:	fmadd	s23, s27, s22, s23
    2540:	fmadd	s24, s27, s23, s24
    2544:	shl	v28.2s, v28.2s, #23
    2548:	fmadd	s25, s27, s24, s25
    254c:	fmadd	s25, s27, s25, s26
    2550:	fmadd	s26, s27, s25, s26
    2554:	fmul	s28, s26, s28
    2558:	fmul	s28, s28, s21
    255c:	fcmpe	s15, #0.0
    2560:	fmul	s30, s30, s28
    2564:	b.mi	25e4 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    2568:	fmov	s28, #1.000000000000000000e+00
    256c:	fsub	s30, s28, s30
    2570:	fmsub	s31, s29, s30, s31
    2574:	str	s31, [x25, x26, lsl #2]
    2578:	add	x26, x26, #0x1
    257c:	cmp	x26, x19
    2580:	b.ne	2120 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    2584:	ldp	d8, d9, [sp, #80]
    2588:	ldp	x19, x20, [sp, #16]
    258c:	ldp	x21, x22, [sp, #32]
    2590:	ldp	x23, x24, [sp, #48]
    2594:	ldp	x25, x26, [sp, #64]
    2598:	ldp	d10, d11, [sp, #96]
    259c:	ldp	d12, d13, [sp, #112]
    25a0:	ldp	d14, d15, [sp, #128]
    25a4:	ldp	x29, x30, [sp], #160
    25a8:	ret
    25ac:	mov	w0, #0x484f                	// #18511
    25b0:	movk	w0, #0x7e46, lsl #16
    25b4:	fmov	s28, w0
    25b8:	fmul	s30, s30, s28
    25bc:	fmov	s28, #1.000000000000000000e+00
    25c0:	fsub	s30, s28, s30
    25c4:	fmsub	s31, s29, s30, s31
    25c8:	str	s31, [x25, x26, lsl #2]
    25cc:	add	x26, x26, #0x1
    25d0:	cmp	x26, x19
    25d4:	b.ne	2120 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    25d8:	b	2584 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    25dc:	movi	v28.2s, #0x0
    25e0:	fmul	s30, s30, s28
    25e4:	fmsub	s30, s29, s30, s31
    25e8:	str	s30, [x25, x26, lsl #2]
    25ec:	add	x26, x26, #0x1
    25f0:	cmp	x19, x26
    25f4:	b.ne	2120 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    25f8:	b	2584 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    25fc:	mov	w0, #0x3389                	// #13193
    2600:	fmov	s31, #1.000000000000000000e+00
    2604:	mov	w4, #0x466f                	// #18031
    2608:	movk	w0, #0x3e6d, lsl #16
    260c:	mov	w3, #0x1eea                	// #7914
    2610:	fmul	s29, s0, s29
    2614:	movk	w4, #0x3faa, lsl #16
    2618:	movk	w3, #0xbfe9, lsl #16
    261c:	fmov	s22, w0
    2620:	mov	w2, #0x778                 	// #1912
    2624:	mov	w1, #0x8f89                	// #36745
    2628:	fmov	s21, w4
    262c:	movk	w2, #0x3fe4, lsl #16
    2630:	movk	w1, #0xbeb6, lsl #16
    2634:	fmov	s23, w3
    2638:	mov	w0, #0x85fa                	// #34298
    263c:	fmov	s24, w2
    2640:	movk	w0, #0x3ea3, lsl #16
    2644:	fmov	s25, w1
    2648:	fmov	s28, w0
    264c:	fnmul	s29, s0, s29
    2650:	fmsub	s22, s0, s22, s31
    2654:	fcmpe	s29, s9
    2658:	fdiv	s31, s31, s22
    265c:	fmadd	s23, s31, s21, s23
    2660:	fmadd	s24, s31, s23, s24
    2664:	fmadd	s25, s31, s24, s25
    2668:	fmadd	s28, s31, s25, s28
    266c:	fmul	s31, s31, s28
    2670:	b.mi	2678 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    2674:	b	22ac <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    2678:	movi	v29.2s, #0x0
    267c:	fmul	s31, s31, s29
    2680:	b	2370 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    2684:	mov	w0, #0x3389                	// #13193
    2688:	fmov	s30, #1.000000000000000000e+00
    268c:	mov	w4, #0x466f                	// #18031
    2690:	movk	w0, #0x3e6d, lsl #16
    2694:	mov	w3, #0x1eea                	// #7914
    2698:	fmov	s27, #5.000000000000000000e-01
    269c:	movk	w4, #0x3faa, lsl #16
    26a0:	movk	w3, #0xbfe9, lsl #16
    26a4:	fmov	s23, w0
    26a8:	mov	w2, #0x778                 	// #1912
    26ac:	mov	w1, #0x8f89                	// #36745
    26b0:	fmov	s22, w4
    26b4:	movk	w2, #0x3fe4, lsl #16
    26b8:	movk	w1, #0xbeb6, lsl #16
    26bc:	fmov	s24, w3
    26c0:	mov	w0, #0x85fa                	// #34298
    26c4:	fmov	s25, w2
    26c8:	movk	w0, #0x3ea3, lsl #16
    26cc:	fmov	s26, w1
    26d0:	fmov	s28, w0
    26d4:	fmul	s27, s15, s27
    26d8:	fmsub	s23, s15, s23, s30
    26dc:	fnmul	s27, s15, s27
    26e0:	fcmpe	s27, s9
    26e4:	fdiv	s30, s30, s23
    26e8:	fmadd	s24, s30, s22, s24
    26ec:	fmadd	s25, s24, s30, s25
    26f0:	fmadd	s26, s25, s30, s26
    26f4:	fmadd	s28, s30, s26, s28
    26f8:	fmul	s30, s30, s28
    26fc:	b.mi	25dc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    2700:	b	24c0 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    2704:	movi	v28.2s, #0x0
    2708:	b	25b8 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    270c:	movi	v29.2s, #0x0
    2710:	fmul	s31, s31, s29
    2714:	b	2368 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    2718:	mov	w7, #0x829c                	// #33436
    271c:	movk	w7, #0x7ef8, lsl #16
    2720:	fmov	s29, w7
    2724:	b	2420 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    2728:	fmov	s27, #5.000000000000000000e-01
    272c:	ldr	s24, [sp, #148]
    2730:	mov	w0, #0xaaab                	// #43691
    2734:	movk	w0, #0x3e2a, lsl #16
    2738:	mov	w1, #0xaaab                	// #43691
    273c:	fmov	s29, #1.000000000000000000e+00
    2740:	movk	w1, #0x3d2a, lsl #16
    2744:	fmov	s26, w0
    2748:	fadd	s28, s28, s27
    274c:	fmov	s25, w1
    2750:	fcvtzs	s28, s28
    2754:	scvtf	s28, s28
    2758:	fmsub	s30, s28, s24, s30
    275c:	fcvtzs	w0, s28
    2760:	ldp	s24, s28, [sp, #152]
    2764:	fmadd	s24, s30, s24, s28
    2768:	b	23fc <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    276c:	fmov	s24, #5.000000000000000000e-01
    2770:	ldr	s30, [sp, #148]
    2774:	mov	w1, #0xaaab                	// #43691
    2778:	movk	w1, #0x3d2a, lsl #16
    277c:	mov	w0, #0xaaab                	// #43691
    2780:	fmov	s25, #1.000000000000000000e+00
    2784:	movk	w0, #0x3e2a, lsl #16
    2788:	mov	w2, #0x422a                	// #16938
    278c:	fmov	s22, w1
    2790:	movk	w2, #0x3ecc, lsl #16
    2794:	fadd	s28, s28, s24
    2798:	fmov	s23, w0
    279c:	fmov	s21, w2
    27a0:	fcvtzs	s28, s28
    27a4:	scvtf	s28, s28
    27a8:	fmsub	s29, s28, s30, s29
    27ac:	fcvtzs	w7, s28
    27b0:	ldp	s28, s30, [sp, #152]
    27b4:	fmadd	s20, s29, s28, s30
    27b8:	add	w7, w7, #0x7f
    27bc:	fmov	s30, w7
    27c0:	fmadd	s22, s29, s20, s22
    27c4:	fmadd	s23, s29, s22, s23
    27c8:	shl	v28.2s, v30.2s, #23
    27cc:	fmadd	s24, s29, s23, s24
    27d0:	fmadd	s24, s29, s24, s25
    27d4:	fmadd	s29, s29, s24, s25
    27d8:	fmul	s29, s29, s28
    27dc:	fmul	s29, s29, s21
    27e0:	b	2348 <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    27e4:	fmov	s25, #5.000000000000000000e-01
    27e8:	ldr	s21, [sp, #148]
    27ec:	mov	w0, #0xaaab                	// #43691
    27f0:	movk	w0, #0x3e2a, lsl #16
    27f4:	mov	w1, #0xaaab                	// #43691
    27f8:	fmov	s26, #1.000000000000000000e+00
    27fc:	movk	w1, #0x3d2a, lsl #16
    2800:	mov	w2, #0x422a                	// #16938
    2804:	fmov	s24, w0
    2808:	movk	w2, #0x3ecc, lsl #16
    280c:	fadd	s28, s28, s25
    2810:	fmov	s23, w1
    2814:	fmov	s22, w2
    2818:	fcvtzs	s28, s28
    281c:	scvtf	s28, s28
    2820:	fmsub	s27, s28, s21, s27
    2824:	fcvtzs	w0, s28
    2828:	ldp	s21, s28, [sp, #152]
    282c:	fmadd	s21, s27, s21, s28
    2830:	add	w0, w0, #0x7f
    2834:	fmov	s28, w0
    2838:	fmadd	s23, s27, s21, s23
    283c:	fmadd	s24, s27, s23, s24
    2840:	shl	v28.2s, v28.2s, #23
    2844:	fmadd	s25, s27, s24, s25
    2848:	fmadd	s25, s27, s25, s26
    284c:	fmadd	s26, s27, s25, s26
    2850:	fmul	s28, s26, s28
    2854:	fmul	s28, s28, s22
    2858:	b	255c <price_scalar(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    285c:	ret

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

0000000000003020 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    3020:	cbz	x6, 37dc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7bc>
    3024:	stp	x29, x30, [sp, #-160]!
    3028:	mov	x29, sp
    302c:	stp	x23, x24, [sp, #48]
    3030:	mov	x24, x4
    3034:	mov	w4, #0xaa3b                	// #43579
    3038:	movk	w4, #0x3fb8, lsl #16
    303c:	mov	x23, x3
    3040:	mov	w3, #0x7218                	// #29208
    3044:	stp	x19, x20, [sp, #16]
    3048:	mov	x20, x0
    304c:	mov	w0, #0xc2b00000            	// #-1028653056
    3050:	movk	w3, #0x3f31, lsl #16
    3054:	mov	x19, x6
    3058:	stp	d8, d9, [sp, #80]
    305c:	fmov	s9, w0
    3060:	stp	d14, d15, [sp, #128]
    3064:	fmov	s14, w4
    3068:	stp	x21, x22, [sp, #32]
    306c:	mov	x21, x1
    3070:	mov	x22, x2
    3074:	mov	w1, #0x8889                	// #34953
    3078:	mov	w2, #0xb61                 	// #2913
    307c:	movk	w2, #0x3ab6, lsl #16
    3080:	movk	w1, #0x3c08, lsl #16
    3084:	stp	x25, x26, [sp, #64]
    3088:	mov	x26, #0x0                   	// #0
    308c:	mov	x25, x5
    3090:	stp	d10, d11, [sp, #96]
    3094:	stp	d12, d13, [sp, #112]
    3098:	stp	w3, w2, [sp, #148]
    309c:	str	w1, [sp, #156]
    30a0:	ldr	s12, [x22, x26, lsl #2]
    30a4:	ldr	s15, [x24, x26, lsl #2]
    30a8:	ldr	s13, [x20, x26, lsl #2]
    30ac:	fcmp	s12, #0.0
    30b0:	ldr	s8, [x21, x26, lsl #2]
    30b4:	ldr	s11, [x23, x26, lsl #2]
    30b8:	fmul	s10, s15, s15
    30bc:	b.pl	3174 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x154>  // b.nfrst
    30c0:	fmov	s0, s12
    30c4:	bl	ec0 <sqrtf@plt>
    30c8:	fmov	s31, s0
    30cc:	fdiv	s0, s13, s8
    30d0:	fmul	s15, s15, s31
    30d4:	bl	1020 <logf@plt>
    30d8:	fmov	s31, #5.000000000000000000e-01
    30dc:	mov	w0, #0x3389                	// #13193
    30e0:	fmov	s25, #1.000000000000000000e+00
    30e4:	movk	w0, #0x3e6d, lsl #16
    30e8:	mov	w1, #0x466f                	// #18031
    30ec:	fmov	s19, #-5.000000000000000000e-01
    30f0:	mov	w4, #0x1eea                	// #7914
    30f4:	movk	w1, #0x3faa, lsl #16
    30f8:	fmov	s29, w0
    30fc:	movk	w4, #0xbfe9, lsl #16
    3100:	mov	w3, #0x778                 	// #1912
    3104:	fmadd	s10, s10, s31, s11
    3108:	movk	w3, #0x3fe4, lsl #16
    310c:	mov	w2, #0x8f89                	// #36745
    3110:	fmov	s20, w1
    3114:	movk	w2, #0xbeb6, lsl #16
    3118:	mov	w1, #0x85fa                	// #34298
    311c:	movk	w1, #0x3ea3, lsl #16
    3120:	mov	w0, #0xaa3b                	// #43579
    3124:	fmov	s22, w4
    3128:	movk	w0, #0x3fb8, lsl #16
    312c:	fmov	s23, w3
    3130:	fmadd	s0, s12, s10, s0
    3134:	fmov	s24, w2
    3138:	fmov	s31, w1
    313c:	fmov	s28, w0
    3140:	fdiv	s0, s0, s15
    3144:	fmadd	s21, s0, s29, s25
    3148:	fmul	s29, s0, s19
    314c:	fsub	s15, s0, s15
    3150:	fmul	s29, s29, s0
    3154:	fdiv	s25, s25, s21
    3158:	fmul	s28, s29, s28
    315c:	fmadd	s22, s25, s20, s22
    3160:	fmadd	s23, s22, s25, s23
    3164:	fmadd	s24, s23, s25, s24
    3168:	fmadd	s31, s24, s25, s31
    316c:	fmul	s31, s31, s25
    3170:	b	3238 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x218>
    3174:	fsqrt	s31, s12
    3178:	fdiv	s0, s13, s8
    317c:	fmul	s15, s15, s31
    3180:	bl	1020 <logf@plt>
    3184:	fmov	s29, #5.000000000000000000e-01
    3188:	fmadd	s10, s10, s29, s11
    318c:	fmadd	s0, s12, s10, s0
    3190:	fdiv	s0, s0, s15
    3194:	fcmpe	s0, #0.0
    3198:	fsub	s15, s0, s15
    319c:	b.mi	357c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.first
    31a0:	mov	w0, #0x3389                	// #13193
    31a4:	fmov	s31, #1.000000000000000000e+00
    31a8:	mov	w4, #0x466f                	// #18031
    31ac:	movk	w0, #0x3e6d, lsl #16
    31b0:	mov	w3, #0x1eea                	// #7914
    31b4:	fmov	s29, #-5.000000000000000000e-01
    31b8:	movk	w4, #0x3faa, lsl #16
    31bc:	movk	w3, #0xbfe9, lsl #16
    31c0:	fmov	s22, w0
    31c4:	mov	w2, #0x778                 	// #1912
    31c8:	mov	w1, #0x8f89                	// #36745
    31cc:	fmov	s21, w4
    31d0:	movk	w2, #0x3fe4, lsl #16
    31d4:	movk	w1, #0xbeb6, lsl #16
    31d8:	fmov	s23, w3
    31dc:	mov	w0, #0x85fa                	// #34298
    31e0:	fmov	s24, w2
    31e4:	movk	w0, #0x3ea3, lsl #16
    31e8:	fmov	s25, w1
    31ec:	fmov	s28, w0
    31f0:	fmul	s29, s0, s29
    31f4:	fmadd	s22, s0, s22, s31
    31f8:	fmul	s29, s29, s0
    31fc:	fcmpe	s29, s9
    3200:	fdiv	s31, s31, s22
    3204:	fmadd	s23, s31, s21, s23
    3208:	fmadd	s24, s31, s23, s24
    320c:	fmadd	s25, s31, s24, s25
    3210:	fmadd	s28, s31, s25, s28
    3214:	fmul	s31, s31, s28
    3218:	b.mi	368c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x66c>  // b.first
    321c:	mov	w0, #0x42b00000            	// #1118830592
    3220:	fmov	s28, w0
    3224:	fcmpe	s29, s28
    3228:	b.gt	32d8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2b8>
    322c:	fmul	s28, s29, s14
    3230:	fcmpe	s28, #0.0
    3234:	b.ge	36ec <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6cc>  // b.tcont
    3238:	fmov	s23, #5.000000000000000000e-01
    323c:	mov	w0, #0x7218                	// #29208
    3240:	mov	w3, #0xb61                 	// #2913
    3244:	movk	w0, #0x3f31, lsl #16
    3248:	mov	w2, #0x8889                	// #34953
    324c:	fmov	s24, #1.000000000000000000e+00
    3250:	movk	w3, #0x3ab6, lsl #16
    3254:	movk	w2, #0x3c08, lsl #16
    3258:	fmov	s25, w0
    325c:	mov	w1, #0xaaab                	// #43691
    3260:	mov	w0, #0xaaab                	// #43691
    3264:	fsub	s28, s28, s23
    3268:	movk	w1, #0x3d2a, lsl #16
    326c:	movk	w0, #0x3e2a, lsl #16
    3270:	fmov	s18, w3
    3274:	mov	w4, #0x422a                	// #16938
    3278:	fmov	s20, w2
    327c:	movk	w4, #0x3ecc, lsl #16
    3280:	fmov	s21, w1
    3284:	fmov	s22, w0
    3288:	fmov	s19, w4
    328c:	fcvtzs	s28, s28
    3290:	scvtf	s28, s28
    3294:	fmsub	s25, s28, s25, s29
    3298:	fcvtzs	w0, s28
    329c:	fmadd	s28, s25, s18, s20
    32a0:	add	w0, w0, #0x7f
    32a4:	fmov	s30, w0
    32a8:	fmadd	s28, s25, s28, s21
    32ac:	fmadd	s28, s25, s28, s22
    32b0:	shl	v29.2s, v30.2s, #23
    32b4:	fmadd	s23, s25, s28, s23
    32b8:	fmadd	s23, s25, s23, s24
    32bc:	fmadd	s24, s25, s23, s24
    32c0:	fmul	s29, s24, s29
    32c4:	fmul	s29, s29, s19
    32c8:	fcmpe	s0, #0.0
    32cc:	fmul	s31, s31, s29
    32d0:	b.mi	32f0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>  // b.first
    32d4:	b	32e8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    32d8:	mov	w0, #0x484f                	// #18511
    32dc:	movk	w0, #0x7e46, lsl #16
    32e0:	fmov	s29, w0
    32e4:	fmul	s31, s31, s29
    32e8:	fmov	s29, #1.000000000000000000e+00
    32ec:	fsub	s31, s29, s31
    32f0:	fnmul	s30, s11, s12
    32f4:	fmul	s31, s13, s31
    32f8:	movi	v29.2s, #0x0
    32fc:	fcmpe	s30, s9
    3300:	b.mi	33a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>  // b.first
    3304:	mov	w0, #0x42b00000            	// #1118830592
    3308:	fmov	s29, w0
    330c:	fcmpe	s30, s29
    3310:	b.gt	3698 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x678>
    3314:	fmul	s28, s30, s14
    3318:	fcmpe	s28, #0.0
    331c:	b.ge	36a8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x688>  // b.tcont
    3320:	fmov	s27, #5.000000000000000000e-01
    3324:	mov	w0, #0x7218                	// #29208
    3328:	mov	w3, #0xb61                 	// #2913
    332c:	movk	w0, #0x3f31, lsl #16
    3330:	mov	w2, #0x8889                	// #34953
    3334:	fmov	s29, #1.000000000000000000e+00
    3338:	movk	w3, #0x3ab6, lsl #16
    333c:	movk	w2, #0x3c08, lsl #16
    3340:	fmov	s22, w0
    3344:	mov	w1, #0xaaab                	// #43691
    3348:	mov	w0, #0xaaab                	// #43691
    334c:	fsub	s28, s28, s27
    3350:	movk	w1, #0x3d2a, lsl #16
    3354:	movk	w0, #0x3e2a, lsl #16
    3358:	fmov	s23, w3
    335c:	fmov	s24, w2
    3360:	fmov	s25, w1
    3364:	fmov	s26, w0
    3368:	fcvtzs	s28, s28
    336c:	scvtf	s28, s28
    3370:	fmsub	s30, s28, s22, s30
    3374:	fcvtzs	w0, s28
    3378:	fmadd	s24, s30, s23, s24
    337c:	fmadd	s25, s30, s24, s25
    3380:	add	w0, w0, #0x7f
    3384:	fmov	s28, w0
    3388:	fmadd	s26, s30, s25, s26
    338c:	fmadd	s27, s30, s26, s27
    3390:	shl	v28.2s, v28.2s, #23
    3394:	fmadd	s27, s30, s27, s29
    3398:	fmadd	s29, s30, s27, s29
    339c:	fmul	s29, s29, s28
    33a0:	fcmpe	s15, #0.0
    33a4:	fmul	s29, s8, s29
    33a8:	b.mi	3604 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5e4>  // b.first
    33ac:	mov	w0, #0x3389                	// #13193
    33b0:	fmov	s30, #1.000000000000000000e+00
    33b4:	mov	w4, #0x466f                	// #18031
    33b8:	movk	w0, #0x3e6d, lsl #16
    33bc:	mov	w3, #0x1eea                	// #7914
    33c0:	fmov	s27, #-5.000000000000000000e-01
    33c4:	movk	w4, #0x3faa, lsl #16
    33c8:	movk	w3, #0xbfe9, lsl #16
    33cc:	fmov	s23, w0
    33d0:	mov	w2, #0x778                 	// #1912
    33d4:	mov	w1, #0x8f89                	// #36745
    33d8:	fmov	s22, w4
    33dc:	movk	w2, #0x3fe4, lsl #16
    33e0:	movk	w1, #0xbeb6, lsl #16
    33e4:	fmov	s24, w3
    33e8:	mov	w0, #0x85fa                	// #34298
    33ec:	fmov	s25, w2
    33f0:	movk	w0, #0x3ea3, lsl #16
    33f4:	fmov	s26, w1
    33f8:	fmov	s28, w0
    33fc:	fmul	s27, s15, s27
    3400:	fmadd	s23, s15, s23, s30
    3404:	fmul	s27, s27, s15
    3408:	fcmpe	s27, s9
    340c:	fdiv	s30, s30, s23
    3410:	fmadd	s24, s30, s22, s24
    3414:	fmadd	s25, s30, s24, s25
    3418:	fmadd	s26, s30, s25, s26
    341c:	fmadd	s28, s30, s26, s28
    3420:	fmul	s30, s30, s28
    3424:	b.mi	3684 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x664>  // b.first
    3428:	mov	w0, #0x42b00000            	// #1118830592
    342c:	fmov	s28, w0
    3430:	fcmpe	s27, s28
    3434:	b.gt	352c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x50c>
    3438:	nop
    343c:	nop
    3440:	fmul	s28, s27, s14
    3444:	fcmpe	s28, #0.0
    3448:	b.ge	3764 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x744>  // b.tcont
    344c:	fmov	s25, #5.000000000000000000e-01
    3450:	mov	w0, #0x7218                	// #29208
    3454:	mov	w4, #0xb61                 	// #2913
    3458:	movk	w0, #0x3f31, lsl #16
    345c:	mov	w2, #0x8889                	// #34953
    3460:	fmov	s26, #1.000000000000000000e+00
    3464:	movk	w4, #0x3ab6, lsl #16
    3468:	movk	w2, #0x3c08, lsl #16
    346c:	fmov	s19, w0
    3470:	mov	w1, #0xaaab                	// #43691
    3474:	mov	w0, #0xaaab                	// #43691
    3478:	fsub	s28, s28, s25
    347c:	movk	w1, #0x3d2a, lsl #16
    3480:	movk	w0, #0x3e2a, lsl #16
    3484:	fmov	s20, w4
    3488:	mov	w3, #0x422a                	// #16938
    348c:	fmov	s22, w2
    3490:	movk	w3, #0x3ecc, lsl #16
    3494:	fmov	s23, w1
    3498:	fmov	s24, w0
    349c:	fmov	s21, w3
    34a0:	fcvtzs	s28, s28
    34a4:	scvtf	s28, s28
    34a8:	fmsub	s27, s28, s19, s27
    34ac:	fcvtzs	w0, s28
    34b0:	fmadd	s22, s27, s20, s22
    34b4:	add	w0, w0, #0x7f
    34b8:	fmov	s28, w0
    34bc:	fmadd	s23, s27, s22, s23
    34c0:	fmadd	s24, s27, s23, s24
    34c4:	shl	v28.2s, v28.2s, #23
    34c8:	fmadd	s25, s27, s24, s25
    34cc:	fmadd	s25, s27, s25, s26
    34d0:	fmadd	s26, s27, s25, s26
    34d4:	fmul	s28, s26, s28
    34d8:	fmul	s28, s28, s21
    34dc:	fcmpe	s15, #0.0
    34e0:	fmul	s30, s30, s28
    34e4:	b.mi	3564 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x544>  // b.first
    34e8:	fmov	s28, #1.000000000000000000e+00
    34ec:	fsub	s30, s28, s30
    34f0:	fmsub	s31, s29, s30, s31
    34f4:	str	s31, [x25, x26, lsl #2]
    34f8:	add	x26, x26, #0x1
    34fc:	cmp	x26, x19
    3500:	b.ne	30a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    3504:	ldp	d8, d9, [sp, #80]
    3508:	ldp	x19, x20, [sp, #16]
    350c:	ldp	x21, x22, [sp, #32]
    3510:	ldp	x23, x24, [sp, #48]
    3514:	ldp	x25, x26, [sp, #64]
    3518:	ldp	d10, d11, [sp, #96]
    351c:	ldp	d12, d13, [sp, #112]
    3520:	ldp	d14, d15, [sp, #128]
    3524:	ldp	x29, x30, [sp], #160
    3528:	ret
    352c:	mov	w0, #0x484f                	// #18511
    3530:	movk	w0, #0x7e46, lsl #16
    3534:	fmov	s28, w0
    3538:	fmul	s30, s30, s28
    353c:	fmov	s28, #1.000000000000000000e+00
    3540:	fsub	s30, s28, s30
    3544:	fmsub	s31, s29, s30, s31
    3548:	str	s31, [x25, x26, lsl #2]
    354c:	add	x26, x26, #0x1
    3550:	cmp	x26, x19
    3554:	b.ne	30a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    3558:	b	3504 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    355c:	movi	v28.2s, #0x0
    3560:	fmul	s30, s30, s28
    3564:	fmsub	s30, s29, s30, s31
    3568:	str	s30, [x25, x26, lsl #2]
    356c:	add	x26, x26, #0x1
    3570:	cmp	x19, x26
    3574:	b.ne	30a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x80>  // b.any
    3578:	b	3504 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4e4>
    357c:	mov	w0, #0x3389                	// #13193
    3580:	fmov	s31, #1.000000000000000000e+00
    3584:	mov	w4, #0x466f                	// #18031
    3588:	movk	w0, #0x3e6d, lsl #16
    358c:	mov	w3, #0x1eea                	// #7914
    3590:	fmul	s29, s0, s29
    3594:	movk	w4, #0x3faa, lsl #16
    3598:	movk	w3, #0xbfe9, lsl #16
    359c:	fmov	s22, w0
    35a0:	mov	w2, #0x778                 	// #1912
    35a4:	mov	w1, #0x8f89                	// #36745
    35a8:	fmov	s21, w4
    35ac:	movk	w2, #0x3fe4, lsl #16
    35b0:	movk	w1, #0xbeb6, lsl #16
    35b4:	fmov	s23, w3
    35b8:	mov	w0, #0x85fa                	// #34298
    35bc:	fmov	s24, w2
    35c0:	movk	w0, #0x3ea3, lsl #16
    35c4:	fmov	s25, w1
    35c8:	fmov	s28, w0
    35cc:	fnmul	s29, s0, s29
    35d0:	fmsub	s22, s0, s22, s31
    35d4:	fcmpe	s29, s9
    35d8:	fdiv	s31, s31, s22
    35dc:	fmadd	s23, s31, s21, s23
    35e0:	fmadd	s24, s31, s23, s24
    35e4:	fmadd	s25, s31, s24, s25
    35e8:	fmadd	s28, s31, s25, s28
    35ec:	fmul	s31, s31, s28
    35f0:	b.mi	35f8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x5d8>  // b.first
    35f4:	b	322c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x20c>
    35f8:	movi	v29.2s, #0x0
    35fc:	fmul	s31, s31, s29
    3600:	b	32f0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2d0>
    3604:	mov	w0, #0x3389                	// #13193
    3608:	fmov	s30, #1.000000000000000000e+00
    360c:	mov	w4, #0x466f                	// #18031
    3610:	movk	w0, #0x3e6d, lsl #16
    3614:	mov	w3, #0x1eea                	// #7914
    3618:	fmov	s27, #5.000000000000000000e-01
    361c:	movk	w4, #0x3faa, lsl #16
    3620:	movk	w3, #0xbfe9, lsl #16
    3624:	fmov	s23, w0
    3628:	mov	w2, #0x778                 	// #1912
    362c:	mov	w1, #0x8f89                	// #36745
    3630:	fmov	s22, w4
    3634:	movk	w2, #0x3fe4, lsl #16
    3638:	movk	w1, #0xbeb6, lsl #16
    363c:	fmov	s24, w3
    3640:	mov	w0, #0x85fa                	// #34298
    3644:	fmov	s25, w2
    3648:	movk	w0, #0x3ea3, lsl #16
    364c:	fmov	s26, w1
    3650:	fmov	s28, w0
    3654:	fmul	s27, s15, s27
    3658:	fmsub	s23, s15, s23, s30
    365c:	fnmul	s27, s15, s27
    3660:	fcmpe	s27, s9
    3664:	fdiv	s30, s30, s23
    3668:	fmadd	s24, s30, s22, s24
    366c:	fmadd	s25, s24, s30, s25
    3670:	fmadd	s26, s25, s30, s26
    3674:	fmadd	s28, s30, s26, s28
    3678:	fmul	s30, s30, s28
    367c:	b.mi	355c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x53c>  // b.first
    3680:	b	3440 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x420>
    3684:	movi	v28.2s, #0x0
    3688:	b	3538 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x518>
    368c:	movi	v29.2s, #0x0
    3690:	fmul	s31, s31, s29
    3694:	b	32e8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2c8>
    3698:	mov	w7, #0x829c                	// #33436
    369c:	movk	w7, #0x7ef8, lsl #16
    36a0:	fmov	s29, w7
    36a4:	b	33a0 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x380>
    36a8:	fmov	s27, #5.000000000000000000e-01
    36ac:	ldr	s24, [sp, #148]
    36b0:	mov	w0, #0xaaab                	// #43691
    36b4:	movk	w0, #0x3e2a, lsl #16
    36b8:	mov	w1, #0xaaab                	// #43691
    36bc:	fmov	s29, #1.000000000000000000e+00
    36c0:	movk	w1, #0x3d2a, lsl #16
    36c4:	fmov	s26, w0
    36c8:	fadd	s28, s28, s27
    36cc:	fmov	s25, w1
    36d0:	fcvtzs	s28, s28
    36d4:	scvtf	s28, s28
    36d8:	fmsub	s30, s28, s24, s30
    36dc:	fcvtzs	w0, s28
    36e0:	ldp	s24, s28, [sp, #152]
    36e4:	fmadd	s24, s30, s24, s28
    36e8:	b	337c <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x35c>
    36ec:	fmov	s24, #5.000000000000000000e-01
    36f0:	ldr	s30, [sp, #148]
    36f4:	mov	w1, #0xaaab                	// #43691
    36f8:	movk	w1, #0x3d2a, lsl #16
    36fc:	mov	w0, #0xaaab                	// #43691
    3700:	fmov	s25, #1.000000000000000000e+00
    3704:	movk	w0, #0x3e2a, lsl #16
    3708:	mov	w2, #0x422a                	// #16938
    370c:	fmov	s22, w1
    3710:	movk	w2, #0x3ecc, lsl #16
    3714:	fadd	s28, s28, s24
    3718:	fmov	s23, w0
    371c:	fmov	s21, w2
    3720:	fcvtzs	s28, s28
    3724:	scvtf	s28, s28
    3728:	fmsub	s29, s28, s30, s29
    372c:	fcvtzs	w7, s28
    3730:	ldp	s28, s30, [sp, #152]
    3734:	fmadd	s20, s29, s28, s30
    3738:	add	w7, w7, #0x7f
    373c:	fmov	s30, w7
    3740:	fmadd	s22, s29, s20, s22
    3744:	fmadd	s23, s29, s22, s23
    3748:	shl	v28.2s, v30.2s, #23
    374c:	fmadd	s24, s29, s23, s24
    3750:	fmadd	s24, s29, s24, s25
    3754:	fmadd	s29, s29, s24, s25
    3758:	fmul	s29, s29, s28
    375c:	fmul	s29, s29, s21
    3760:	b	32c8 <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x2a8>
    3764:	fmov	s25, #5.000000000000000000e-01
    3768:	ldr	s21, [sp, #148]
    376c:	mov	w0, #0xaaab                	// #43691
    3770:	movk	w0, #0x3e2a, lsl #16
    3774:	mov	w1, #0xaaab                	// #43691
    3778:	fmov	s26, #1.000000000000000000e+00
    377c:	movk	w1, #0x3d2a, lsl #16
    3780:	mov	w2, #0x422a                	// #16938
    3784:	fmov	s24, w0
    3788:	movk	w2, #0x3ecc, lsl #16
    378c:	fadd	s28, s28, s25
    3790:	fmov	s23, w1
    3794:	fmov	s22, w2
    3798:	fcvtzs	s28, s28
    379c:	scvtf	s28, s28
    37a0:	fmsub	s27, s28, s21, s27
    37a4:	fcvtzs	w0, s28
    37a8:	ldp	s21, s28, [sp, #152]
    37ac:	fmadd	s21, s27, s21, s28
    37b0:	add	w0, w0, #0x7f
    37b4:	fmov	s28, w0
    37b8:	fmadd	s23, s27, s21, s23
    37bc:	fmadd	s24, s27, s23, s24
    37c0:	shl	v28.2s, v28.2s, #23
    37c4:	fmadd	s25, s27, s24, s25
    37c8:	fmadd	s25, s27, s25, s26
    37cc:	fmadd	s26, s27, s25, s26
    37d0:	fmul	s28, s26, s28
    37d4:	fmul	s28, s28, s22
    37d8:	b	34dc <price_scalar_poly(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4bc>
    37dc:	ret

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

0000000000003ee0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)>:
    3ee0:	stp	x29, x30, [sp, #-160]!
    3ee4:	mov	x29, sp
    3ee8:	stp	x19, x20, [sp, #16]
    3eec:	mov	x20, x0
    3ef0:	stp	x21, x22, [sp, #32]
    3ef4:	mov	x21, x1
    3ef8:	mov	x22, x2
    3efc:	stp	x23, x24, [sp, #48]
    3f00:	mov	x24, x6
    3f04:	mov	x23, x3
    3f08:	stp	x25, x26, [sp, #64]
    3f0c:	mov	x25, x4
    3f10:	mov	x26, x5
    3f14:	stp	d8, d9, [sp, #80]
    3f18:	stp	d10, d11, [sp, #96]
    3f1c:	stp	d12, d13, [sp, #112]
    3f20:	stp	d14, d15, [sp, #128]
    3f24:	cmp	x6, #0x3
    3f28:	b.ls	4a0c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xb2c>  // b.plast
    3f2c:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f30:	sub	x19, x6, #0x4
    3f34:	and	x0, x19, #0xfffffffffffffffc
    3f38:	mov	x7, #0x0                   	// #0
    3f3c:	ldr	q20, [x1, #3696]
    3f40:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f44:	mov	x8, #0x0                   	// #0
    3f48:	add	x0, x0, #0x4
    3f4c:	ldr	q1, [x1, #3712]
    3f50:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f54:	ldr	q11, [x1, #3728]
    3f58:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f5c:	ldr	q12, [x1, #3744]
    3f60:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f64:	ldr	q13, [x1, #3760]
    3f68:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f6c:	ldr	q14, [x1, #3776]
    3f70:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f74:	ldr	q15, [x1, #3792]
    3f78:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f7c:	ldr	q4, [x1, #3808]
    3f80:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f84:	ldr	q5, [x1, #3824]
    3f88:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f8c:	ldr	q6, [x1, #3840]
    3f90:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f94:	ldr	q7, [x1, #3856]
    3f98:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3f9c:	ldr	q16, [x1, #3872]
    3fa0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3fa4:	ldr	q17, [x1, #3888]
    3fa8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3fac:	ldr	q18, [x1, #3904]
    3fb0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3fb4:	movi	v26.4s, #0x7f, msl #16
    3fb8:	fmov	v25.4s, #5.000000000000000000e-01
    3fbc:	ldr	q9, [x21, x7]
    3fc0:	movi	v23.4s, #0x7f
    3fc4:	fmov	v31.4s, #-1.000000000000000000e+00
    3fc8:	fmov	v29.4s, #1.000000000000000000e+00
    3fcc:	fmov	v10.4s, #-5.000000000000000000e-01
    3fd0:	add	x8, x8, #0x4
    3fd4:	ldr	q30, [x20, x7]
    3fd8:	mov	v0.16b, v25.16b
    3fdc:	ldr	q19, [x1, #3920]
    3fe0:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3fe4:	ldr	q24, [x1, #3936]
    3fe8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    3fec:	fdiv	v27.4s, v30.4s, v9.4s
    3ff0:	ldr	q21, [x22, x7]
    3ff4:	ldr	q22, [x23, x7]
    3ff8:	and	v26.16b, v26.16b, v27.16b
    3ffc:	sshr	v27.4s, v27.4s, #23
    4000:	ldr	q30, [x25, x7]
    4004:	orr	v26.16b, v26.16b, v24.16b
    4008:	ldr	q24, [x1, #3952]
    400c:	sub	v27.4s, v27.4s, v23.4s
    4010:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4014:	fmul	v28.4s, v21.4s, v22.4s
    4018:	fmul	v3.4s, v30.4s, v30.4s
    401c:	fcmge	v8.4s, v26.4s, v24.4s
    4020:	fmul	v24.4s, v25.4s, v26.4s
    4024:	fneg	v28.4s, v28.4s
    4028:	fmla	v22.4s, v25.4s, v3.4s
    402c:	bit	v26.16b, v24.16b, v8.16b
    4030:	sub	v27.4s, v27.4s, v8.4s
    4034:	ldr	q8, [x1, #3968]
    4038:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    403c:	fmax	v28.4s, v28.4s, v4.4s
    4040:	ldr	q24, [x1, #3984]
    4044:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4048:	fadd	v31.4s, v31.4s, v26.4s
    404c:	fsqrt	v26.4s, v21.4s
    4050:	scvtf	v27.4s, v27.4s
    4054:	fmin	v28.4s, v28.4s, v5.4s
    4058:	fmul	v30.4s, v30.4s, v26.4s
    405c:	fmla	v8.4s, v24.4s, v31.4s
    4060:	ldr	q24, [x1, #4000]
    4064:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4068:	fmul	v26.4s, v28.4s, v6.4s
    406c:	fmla	v24.4s, v8.4s, v31.4s
    4070:	ldr	q8, [x1, #4016]
    4074:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4078:	frintn	v26.4s, v26.4s
    407c:	fmla	v8.4s, v24.4s, v31.4s
    4080:	ldr	q24, [x1, #4032]
    4084:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4088:	ldr	q3, [x1, #4048]
    408c:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4090:	fmls	v28.4s, v26.4s, v20.4s
    4094:	fmla	v24.4s, v8.4s, v31.4s
    4098:	mov	v8.16b, v16.16b
    409c:	fcvtzs	v26.4s, v26.4s
    40a0:	fmla	v3.4s, v24.4s, v31.4s
    40a4:	ldr	q24, [x1, #4064]
    40a8:	adrp	x1, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    40ac:	fmla	v8.4s, v7.4s, v28.4s
    40b0:	add	v26.4s, v26.4s, v23.4s
    40b4:	fmla	v24.4s, v3.4s, v31.4s
    40b8:	mov	v3.16b, v17.16b
    40bc:	shl	v26.4s, v26.4s, #23
    40c0:	fmla	v3.4s, v8.4s, v28.4s
    40c4:	ldr	q8, [x1, #4080]
    40c8:	adrp	x1, 5000 <_IO_stdin_used+0x3a0>
    40cc:	ldr	q2, [x1]
    40d0:	fmla	v8.4s, v24.4s, v31.4s
    40d4:	mov	v24.16b, v18.16b
    40d8:	fmla	v2.4s, v8.4s, v31.4s
    40dc:	fmla	v24.4s, v3.4s, v28.4s
    40e0:	mov	v3.16b, v29.16b
    40e4:	fmul	v8.4s, v31.4s, v31.4s
    40e8:	fmla	v0.4s, v24.4s, v28.4s
    40ec:	fmul	v24.4s, v31.4s, v8.4s
    40f0:	fmla	v3.4s, v0.4s, v28.4s
    40f4:	fmul	v24.4s, v24.4s, v2.4s
    40f8:	mov	v2.16b, v29.16b
    40fc:	fmls	v24.4s, v8.4s, v25.4s
    4100:	mov	v8.16b, v12.16b
    4104:	fmla	v2.4s, v3.4s, v28.4s
    4108:	mov	v3.16b, v16.16b
    410c:	fadd	v31.4s, v31.4s, v24.4s
    4110:	fmul	v26.4s, v2.4s, v26.4s
    4114:	mov	v2.16b, v18.16b
    4118:	fmla	v31.4s, v27.4s, v20.4s
    411c:	fmul	v26.4s, v26.4s, v9.4s
    4120:	mov	v9.16b, v13.16b
    4124:	fmla	v31.4s, v22.4s, v21.4s
    4128:	mov	v21.16b, v29.16b
    412c:	fdiv	v31.4s, v31.4s, v30.4s
    4130:	fsub	v30.4s, v31.4s, v30.4s
    4134:	fmul	v27.4s, v31.4s, v31.4s
    4138:	fabs	v24.4s, v31.4s
    413c:	fcmlt	v31.4s, v31.4s, #0.0
    4140:	fmul	v28.4s, v30.4s, v30.4s
    4144:	fmul	v27.4s, v27.4s, v10.4s
    4148:	fmla	v21.4s, v1.4s, v24.4s
    414c:	fabs	v22.4s, v30.4s
    4150:	mov	v24.16b, v29.16b
    4154:	fmul	v28.4s, v28.4s, v10.4s
    4158:	fmax	v27.4s, v27.4s, v4.4s
    415c:	fcmlt	v30.4s, v30.4s, #0.0
    4160:	fmla	v24.4s, v1.4s, v22.4s
    4164:	fmax	v28.4s, v28.4s, v4.4s
    4168:	fmin	v27.4s, v27.4s, v5.4s
    416c:	fdiv	v21.4s, v29.4s, v21.4s
    4170:	fmin	v28.4s, v28.4s, v5.4s
    4174:	fmul	v22.4s, v27.4s, v6.4s
    4178:	fmla	v8.4s, v11.4s, v21.4s
    417c:	fdiv	v24.4s, v29.4s, v24.4s
    4180:	fmul	v10.4s, v28.4s, v6.4s
    4184:	frintn	v22.4s, v22.4s
    4188:	fmla	v9.4s, v8.4s, v21.4s
    418c:	mov	v8.16b, v14.16b
    4190:	frintn	v10.4s, v10.4s
    4194:	fmls	v27.4s, v22.4s, v20.4s
    4198:	fmla	v8.4s, v9.4s, v21.4s
    419c:	mov	v9.16b, v15.16b
    41a0:	fmls	v28.4s, v10.4s, v20.4s
    41a4:	fcvtzs	v22.4s, v22.4s
    41a8:	fcvtzs	v10.4s, v10.4s
    41ac:	fmla	v3.4s, v7.4s, v27.4s
    41b0:	fmla	v9.4s, v8.4s, v21.4s
    41b4:	mov	v8.16b, v17.16b
    41b8:	add	v22.4s, v22.4s, v23.4s
    41bc:	add	v10.4s, v10.4s, v23.4s
    41c0:	mov	v23.16b, v16.16b
    41c4:	fmla	v8.4s, v3.4s, v27.4s
    41c8:	mov	v3.16b, v18.16b
    41cc:	fmla	v23.4s, v7.4s, v28.4s
    41d0:	shl	v22.4s, v22.4s, #23
    41d4:	fmla	v3.4s, v8.4s, v27.4s
    41d8:	mov	v8.16b, v17.16b
    41dc:	shl	v10.4s, v10.4s, #23
    41e0:	fmul	v21.4s, v21.4s, v9.4s
    41e4:	fmla	v8.4s, v23.4s, v28.4s
    41e8:	mov	v23.16b, v25.16b
    41ec:	fmla	v23.4s, v3.4s, v27.4s
    41f0:	mov	v3.16b, v29.16b
    41f4:	fmla	v2.4s, v8.4s, v28.4s
    41f8:	mov	v8.16b, v12.16b
    41fc:	fmla	v3.4s, v23.4s, v27.4s
    4200:	mov	v23.16b, v29.16b
    4204:	fmla	v25.4s, v2.4s, v28.4s
    4208:	fmla	v23.4s, v3.4s, v27.4s
    420c:	mov	v3.16b, v29.16b
    4210:	mov	v27.16b, v29.16b
    4214:	fmla	v8.4s, v11.4s, v24.4s
    4218:	fmla	v3.4s, v25.4s, v28.4s
    421c:	mov	v25.16b, v13.16b
    4220:	fmla	v25.4s, v8.4s, v24.4s
    4224:	fmla	v27.4s, v3.4s, v28.4s
    4228:	mov	v28.16b, v14.16b
    422c:	fmla	v28.4s, v25.4s, v24.4s
    4230:	fmul	v25.4s, v23.4s, v22.4s
    4234:	mov	v23.16b, v15.16b
    4238:	fmla	v23.4s, v28.4s, v24.4s
    423c:	fmul	v25.4s, v25.4s, v19.4s
    4240:	fmul	v28.4s, v27.4s, v10.4s
    4244:	fmul	v27.4s, v25.4s, v21.4s
    4248:	fmul	v28.4s, v28.4s, v19.4s
    424c:	fmul	v24.4s, v24.4s, v23.4s
    4250:	fsub	v25.4s, v29.4s, v27.4s
    4254:	fmul	v24.4s, v28.4s, v24.4s
    4258:	ldr	q28, [x20, x7]
    425c:	bsl	v31.16b, v27.16b, v25.16b
    4260:	fsub	v29.4s, v29.4s, v24.4s
    4264:	fmul	v31.4s, v28.4s, v31.4s
    4268:	bsl	v30.16b, v24.16b, v29.16b
    426c:	fmls	v31.4s, v26.4s, v30.4s
    4270:	str	q31, [x26, x7]
    4274:	add	x7, x7, #0x10
    4278:	cmp	x8, x0
    427c:	b.ne	3fb0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xd0>  // b.any
    4280:	and	x19, x19, #0xfffffffffffffffc
    4284:	add	x19, x19, #0x4
    4288:	cmp	x24, x19
    428c:	b.ls	4704 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>  // b.plast
    4290:	mov	w4, #0x3389                	// #13193
    4294:	mov	w3, #0x466f                	// #18031
    4298:	mov	w2, #0x1eea                	// #7914
    429c:	mov	w1, #0x778                 	// #1912
    42a0:	movk	w4, #0x3e6d, lsl #16
    42a4:	movk	w3, #0x3faa, lsl #16
    42a8:	movk	w2, #0xbfe9, lsl #16
    42ac:	movk	w1, #0x3fe4, lsl #16
    42b0:	mov	w0, #0xc2b00000            	// #-1028653056
    42b4:	fmov	s10, w4
    42b8:	fmov	s11, w3
    42bc:	fmov	s12, w2
    42c0:	fmov	s13, w1
    42c4:	fmov	s14, w0
    42c8:	ldr	s28, [x22, x19, lsl #2]
    42cc:	ldr	s15, [x25, x19, lsl #2]
    42d0:	ldr	s26, [x20, x19, lsl #2]
    42d4:	fcmp	s28, #0.0
    42d8:	ldr	s8, [x21, x19, lsl #2]
    42dc:	ldr	s25, [x23, x19, lsl #2]
    42e0:	fmul	s9, s15, s15
    42e4:	b.pl	443c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x55c>  // b.nfrst
    42e8:	fmov	s0, s28
    42ec:	stp	s26, s28, [sp, #148]
    42f0:	str	s25, [sp, #156]
    42f4:	bl	ec0 <sqrtf@plt>
    42f8:	ldr	s26, [sp, #148]
    42fc:	fmul	s15, s15, s0
    4300:	fdiv	s0, s26, s8
    4304:	bl	1020 <logf@plt>
    4308:	ldr	s25, [sp, #156]
    430c:	fmov	s31, #5.000000000000000000e-01
    4310:	mov	w0, #0x3389                	// #13193
    4314:	movk	w0, #0x3e6d, lsl #16
    4318:	fmov	s27, #1.000000000000000000e+00
    431c:	mov	w1, #0x466f                	// #18031
    4320:	ldp	s26, s28, [sp, #148]
    4324:	mov	w3, #0x1eea                	// #7914
    4328:	movk	w1, #0x3faa, lsl #16
    432c:	fmov	s30, w0
    4330:	movk	w3, #0xbfe9, lsl #16
    4334:	mov	w2, #0x778                 	// #1912
    4338:	fmov	s20, w1
    433c:	movk	w2, #0x3fe4, lsl #16
    4340:	mov	w1, #0x8f89                	// #36745
    4344:	fmov	s22, w3
    4348:	movk	w1, #0xbeb6, lsl #16
    434c:	mov	w0, #0x85fa                	// #34298
    4350:	fmadd	s9, s9, s31, s25
    4354:	movk	w0, #0x3ea3, lsl #16
    4358:	mov	w7, #0xaa3b                	// #43579
    435c:	fmov	s23, w2
    4360:	fmov	s19, #-5.000000000000000000e-01
    4364:	movk	w7, #0x3fb8, lsl #16
    4368:	fmov	s24, w1
    436c:	fmov	s31, w0
    4370:	fmadd	s0, s28, s9, s0
    4374:	fmov	s29, w7
    4378:	fdiv	s0, s0, s15
    437c:	fmadd	s21, s0, s30, s27
    4380:	fmul	s30, s0, s19
    4384:	fsub	s15, s0, s15
    4388:	fmul	s30, s30, s0
    438c:	fdiv	s27, s27, s21
    4390:	fmul	s29, s30, s29
    4394:	fmadd	s22, s27, s20, s22
    4398:	fmadd	s23, s22, s27, s23
    439c:	fmadd	s24, s23, s27, s24
    43a0:	fmadd	s31, s24, s27, s31
    43a4:	fmul	s31, s31, s27
    43a8:	fmov	s24, #5.000000000000000000e-01
    43ac:	mov	w0, #0x7218                	// #29208
    43b0:	mov	w3, #0xb61                 	// #2913
    43b4:	movk	w0, #0x3f31, lsl #16
    43b8:	mov	w2, #0x8889                	// #34953
    43bc:	fmov	s27, #1.000000000000000000e+00
    43c0:	movk	w3, #0x3ab6, lsl #16
    43c4:	movk	w2, #0x3c08, lsl #16
    43c8:	fmov	s18, w0
    43cc:	mov	w1, #0xaaab                	// #43691
    43d0:	mov	w0, #0xaaab                	// #43691
    43d4:	fsub	s29, s29, s24
    43d8:	movk	w1, #0x3d2a, lsl #16
    43dc:	movk	w0, #0x3e2a, lsl #16
    43e0:	fmov	s21, w2
    43e4:	mov	w4, #0x422a                	// #16938
    43e8:	fmov	s19, w3
    43ec:	movk	w4, #0x3ecc, lsl #16
    43f0:	fmov	s22, w1
    43f4:	fmov	s23, w0
    43f8:	fmov	s20, w4
    43fc:	fcvtzs	s29, s29
    4400:	scvtf	s29, s29
    4404:	fmsub	s30, s29, s18, s30
    4408:	fcvtzs	w7, s29
    440c:	fmadd	s29, s30, s19, s21
    4410:	add	w7, w7, #0x7f
    4414:	fmov	s21, w7
    4418:	fmadd	s29, s30, s29, s22
    441c:	fmadd	s29, s30, s29, s23
    4420:	shl	v21.2s, v21.2s, #23
    4424:	fmadd	s24, s30, s29, s24
    4428:	fmadd	s24, s30, s24, s27
    442c:	fmadd	s30, s30, s24, s27
    4430:	fmul	s30, s30, s21
    4434:	fmul	s30, s30, s20
    4438:	b	4978 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa98>
    443c:	fsqrt	s29, s28
    4440:	stp	s26, s28, [sp, #148]
    4444:	str	s25, [sp, #156]
    4448:	fdiv	s0, s26, s8
    444c:	fmul	s15, s15, s29
    4450:	bl	1020 <logf@plt>
    4454:	ldr	s25, [sp, #156]
    4458:	fmov	s30, #5.000000000000000000e-01
    445c:	ldp	s26, s28, [sp, #148]
    4460:	fmadd	s9, s9, s30, s25
    4464:	fmadd	s0, s28, s9, s0
    4468:	fdiv	s0, s0, s15
    446c:	fcmpe	s0, #0.0
    4470:	fsub	s15, s0, s15
    4474:	b.mi	47b4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8d4>  // b.first
    4478:	fmov	s31, #1.000000000000000000e+00
    447c:	mov	w1, #0x8f89                	// #36745
    4480:	mov	w0, #0x85fa                	// #34298
    4484:	movk	w1, #0xbeb6, lsl #16
    4488:	movk	w0, #0x3ea3, lsl #16
    448c:	fmov	s30, #-5.000000000000000000e-01
    4490:	fmov	s27, w1
    4494:	fmadd	s24, s0, s10, s31
    4498:	fmov	s29, w0
    449c:	fmul	s30, s0, s30
    44a0:	fmul	s30, s30, s0
    44a4:	fdiv	s31, s31, s24
    44a8:	fcmpe	s30, s14
    44ac:	fmadd	s24, s31, s11, s12
    44b0:	fmadd	s24, s31, s24, s13
    44b4:	fmadd	s27, s31, s24, s27
    44b8:	fmadd	s29, s31, s27, s29
    44bc:	fmul	s31, s31, s29
    44c0:	b.mi	4824 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x944>  // b.first
    44c4:	mov	w0, #0x42b00000            	// #1118830592
    44c8:	fmov	s29, w0
    44cc:	fcmpe	s30, s29
    44d0:	b.gt	44f0 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x610>
    44d4:	mov	w7, #0xaa3b                	// #43579
    44d8:	movk	w7, #0x3fb8, lsl #16
    44dc:	fmov	s29, w7
    44e0:	fmul	s29, s30, s29
    44e4:	fcmpe	s29, #0.0
    44e8:	b.ge	48e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    44ec:	b	43a8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    44f0:	mov	w0, #0x484f                	// #18511
    44f4:	movk	w0, #0x7e46, lsl #16
    44f8:	fmov	s30, w0
    44fc:	fmul	s31, s31, s30
    4500:	fmov	s30, #1.000000000000000000e+00
    4504:	fsub	s31, s30, s31
    4508:	fnmul	s29, s25, s28
    450c:	fmul	s31, s26, s31
    4510:	movi	v30.2s, #0x0
    4514:	fcmpe	s29, s14
    4518:	b.mi	45c4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>  // b.first
    451c:	mov	w0, #0x42b00000            	// #1118830592
    4520:	fmov	s30, w0
    4524:	fcmpe	s29, s30
    4528:	b.gt	4838 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x958>
    452c:	mov	w7, #0xaa3b                	// #43579
    4530:	movk	w7, #0x3fb8, lsl #16
    4534:	fmov	s28, w7
    4538:	fmul	s28, s29, s28
    453c:	fcmpe	s28, #0.0
    4540:	b.ge	4988 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xaa8>  // b.tcont
    4544:	fmov	s27, #5.000000000000000000e-01
    4548:	mov	w0, #0x7218                	// #29208
    454c:	mov	w3, #0xb61                 	// #2913
    4550:	movk	w0, #0x3f31, lsl #16
    4554:	mov	w2, #0x8889                	// #34953
    4558:	fmov	s30, #1.000000000000000000e+00
    455c:	movk	w3, #0x3ab6, lsl #16
    4560:	movk	w2, #0x3c08, lsl #16
    4564:	fmov	s22, w0
    4568:	mov	w1, #0xaaab                	// #43691
    456c:	mov	w0, #0xaaab                	// #43691
    4570:	fsub	s28, s28, s27
    4574:	movk	w1, #0x3d2a, lsl #16
    4578:	movk	w0, #0x3e2a, lsl #16
    457c:	fmov	s24, w2
    4580:	fmov	s23, w3
    4584:	fmov	s25, w1
    4588:	fmov	s26, w0
    458c:	fcvtzs	s28, s28
    4590:	scvtf	s28, s28
    4594:	fmsub	s29, s28, s22, s29
    4598:	fcvtzs	w7, s28
    459c:	fmadd	s28, s29, s23, s24
    45a0:	add	w7, w7, #0x7f
    45a4:	fmov	s24, w7
    45a8:	fmadd	s28, s29, s28, s25
    45ac:	fmadd	s28, s29, s28, s26
    45b0:	shl	v24.2s, v24.2s, #23
    45b4:	fmadd	s27, s29, s28, s27
    45b8:	fmadd	s27, s29, s27, s30
    45bc:	fmadd	s30, s29, s27, s30
    45c0:	fmul	s30, s30, s24
    45c4:	fcmpe	s15, #0.0
    45c8:	fmul	s26, s8, s30
    45cc:	b.mi	472c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x84c>  // b.first
    45d0:	fmov	s30, #1.000000000000000000e+00
    45d4:	mov	w1, #0x8f89                	// #36745
    45d8:	mov	w0, #0x85fa                	// #34298
    45dc:	movk	w1, #0xbeb6, lsl #16
    45e0:	movk	w0, #0x3ea3, lsl #16
    45e4:	fmov	s28, #-5.000000000000000000e-01
    45e8:	fmov	s27, w1
    45ec:	fmadd	s25, s15, s10, s30
    45f0:	fmov	s29, w0
    45f4:	fmul	s28, s15, s28
    45f8:	fmul	s28, s28, s15
    45fc:	fdiv	s30, s30, s25
    4600:	fcmpe	s28, s14
    4604:	fmadd	s25, s30, s11, s12
    4608:	fmadd	s25, s30, s25, s13
    460c:	fmadd	s27, s30, s25, s27
    4610:	fmadd	s29, s30, s27, s29
    4614:	fmul	s30, s30, s29
    4618:	b.mi	4830 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x950>  // b.first
    461c:	mov	w0, #0x42b00000            	// #1118830592
    4620:	fmov	s29, w0
    4624:	fcmpe	s28, s29
    4628:	b.gt	46d8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x7f8>
    462c:	mov	w7, #0xaa3b                	// #43579
    4630:	movk	w7, #0x3fb8, lsl #16
    4634:	fmov	s29, w7
    4638:	fmul	s29, s28, s29
    463c:	fcmpe	s29, #0.0
    4640:	b.ge	4848 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    4644:	fmov	s25, #5.000000000000000000e-01
    4648:	mov	w0, #0x7218                	// #29208
    464c:	mov	w4, #0xb61                 	// #2913
    4650:	movk	w0, #0x3f31, lsl #16
    4654:	mov	w2, #0x8889                	// #34953
    4658:	fmov	s27, #1.000000000000000000e+00
    465c:	movk	w4, #0x3ab6, lsl #16
    4660:	movk	w2, #0x3c08, lsl #16
    4664:	fmov	s19, w0
    4668:	mov	w1, #0xaaab                	// #43691
    466c:	mov	w0, #0xaaab                	// #43691
    4670:	fsub	s29, s29, s25
    4674:	movk	w1, #0x3d2a, lsl #16
    4678:	movk	w0, #0x3e2a, lsl #16
    467c:	fmov	s22, w2
    4680:	mov	w3, #0x422a                	// #16938
    4684:	fmov	s20, w4
    4688:	movk	w3, #0x3ecc, lsl #16
    468c:	fmov	s23, w1
    4690:	fmov	s24, w0
    4694:	fmov	s21, w3
    4698:	fcvtzs	s29, s29
    469c:	scvtf	s29, s29
    46a0:	fmsub	s28, s29, s19, s28
    46a4:	fcvtzs	w7, s29
    46a8:	fmadd	s29, s28, s20, s22
    46ac:	add	w7, w7, #0x7f
    46b0:	fmov	s22, w7
    46b4:	fmadd	s29, s28, s29, s23
    46b8:	fmadd	s29, s28, s29, s24
    46bc:	shl	v22.2s, v22.2s, #23
    46c0:	fmadd	s25, s28, s29, s25
    46c4:	fmadd	s25, s28, s25, s27
    46c8:	fmadd	s29, s28, s25, s27
    46cc:	fmul	s29, s29, s22
    46d0:	fmul	s29, s29, s21
    46d4:	b	48d8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x9f8>
    46d8:	mov	w0, #0x484f                	// #18511
    46dc:	movk	w0, #0x7e46, lsl #16
    46e0:	fmov	s29, w0
    46e4:	fmul	s30, s30, s29
    46e8:	fmov	s29, #1.000000000000000000e+00
    46ec:	fsub	s29, s29, s30
    46f0:	fmsub	s31, s26, s29, s31
    46f4:	str	s31, [x26, x19, lsl #2]
    46f8:	add	x19, x19, #0x1
    46fc:	cmp	x19, x24
    4700:	b.ne	42c8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    4704:	ldp	d8, d9, [sp, #80]
    4708:	ldp	x19, x20, [sp, #16]
    470c:	ldp	x21, x22, [sp, #32]
    4710:	ldp	x23, x24, [sp, #48]
    4714:	ldp	x25, x26, [sp, #64]
    4718:	ldp	d10, d11, [sp, #96]
    471c:	ldp	d12, d13, [sp, #112]
    4720:	ldp	d14, d15, [sp, #128]
    4724:	ldp	x29, x30, [sp], #160
    4728:	ret
    472c:	fmov	s29, #1.000000000000000000e+00
    4730:	mov	w1, #0x8f89                	// #36745
    4734:	mov	w0, #0x85fa                	// #34298
    4738:	movk	w1, #0xbeb6, lsl #16
    473c:	movk	w0, #0x3ea3, lsl #16
    4740:	fmov	s28, #5.000000000000000000e-01
    4744:	fmov	s27, w1
    4748:	fmsub	s25, s15, s10, s29
    474c:	fmov	s30, w0
    4750:	fmul	s28, s15, s28
    4754:	fnmul	s28, s15, s28
    4758:	fdiv	s29, s29, s25
    475c:	fcmpe	s28, s14
    4760:	fmadd	s25, s29, s11, s12
    4764:	fmadd	s25, s29, s25, s13
    4768:	fmadd	s27, s29, s25, s27
    476c:	fmadd	s30, s29, s27, s30
    4770:	fmul	s30, s29, s30
    4774:	b.mi	4794 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8b4>  // b.first
    4778:	mov	w7, #0xaa3b                	// #43579
    477c:	movk	w7, #0x3fb8, lsl #16
    4780:	fmov	s29, w7
    4784:	fmul	s29, s28, s29
    4788:	fcmpe	s29, #0.0
    478c:	b.ge	4848 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x968>  // b.tcont
    4790:	b	4644 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x764>
    4794:	movi	v29.2s, #0x0
    4798:	fmul	s30, s30, s29
    479c:	fmsub	s30, s26, s30, s31
    47a0:	str	s30, [x26, x19, lsl #2]
    47a4:	add	x19, x19, #0x1
    47a8:	cmp	x24, x19
    47ac:	b.ne	42c8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3e8>  // b.any
    47b0:	b	4704 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x824>
    47b4:	fmov	s31, #1.000000000000000000e+00
    47b8:	mov	w1, #0x8f89                	// #36745
    47bc:	mov	w0, #0x85fa                	// #34298
    47c0:	movk	w1, #0xbeb6, lsl #16
    47c4:	movk	w0, #0x3ea3, lsl #16
    47c8:	fmul	s30, s0, s30
    47cc:	fmov	s27, w1
    47d0:	fmsub	s24, s0, s10, s31
    47d4:	fmov	s29, w0
    47d8:	fnmul	s30, s0, s30
    47dc:	fcmpe	s30, s14
    47e0:	fdiv	s31, s31, s24
    47e4:	fmadd	s24, s31, s11, s12
    47e8:	fmadd	s24, s31, s24, s13
    47ec:	fmadd	s27, s31, s24, s27
    47f0:	fmadd	s29, s31, s27, s29
    47f4:	fmul	s31, s31, s29
    47f8:	b.mi	4818 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x938>  // b.first
    47fc:	mov	w7, #0xaa3b                	// #43579
    4800:	movk	w7, #0x3fb8, lsl #16
    4804:	fmov	s29, w7
    4808:	fmul	s29, s30, s29
    480c:	fcmpe	s29, #0.0
    4810:	b.ge	48e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0xa08>  // b.tcont
    4814:	b	43a8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x4c8>
    4818:	movi	v30.2s, #0x0
    481c:	fmul	s31, s31, s30
    4820:	b	4508 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>
    4824:	movi	v30.2s, #0x0
    4828:	fmul	s31, s31, s30
    482c:	b	4500 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    4830:	movi	v29.2s, #0x0
    4834:	b	46e4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x804>
    4838:	mov	w7, #0x829c                	// #33436
    483c:	movk	w7, #0x7ef8, lsl #16
    4840:	fmov	s30, w7
    4844:	b	45c4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    4848:	fmov	s24, #5.000000000000000000e-01
    484c:	mov	w0, #0x7218                	// #29208
    4850:	mov	w4, #0xb61                 	// #2913
    4854:	movk	w0, #0x3f31, lsl #16
    4858:	mov	w2, #0x8889                	// #34953
    485c:	fmov	s27, #1.000000000000000000e+00
    4860:	movk	w4, #0x3ab6, lsl #16
    4864:	movk	w2, #0x3c08, lsl #16
    4868:	fmov	s25, w0
    486c:	mov	w1, #0xaaab                	// #43691
    4870:	mov	w0, #0xaaab                	// #43691
    4874:	fadd	s29, s29, s24
    4878:	movk	w1, #0x3d2a, lsl #16
    487c:	movk	w0, #0x3e2a, lsl #16
    4880:	fmov	s19, w4
    4884:	mov	w3, #0x422a                	// #16938
    4888:	fmov	s21, w2
    488c:	movk	w3, #0x3ecc, lsl #16
    4890:	fmov	s22, w1
    4894:	fmov	s23, w0
    4898:	fmov	s20, w3
    489c:	fcvtzs	s29, s29
    48a0:	scvtf	s29, s29
    48a4:	fmsub	s28, s29, s25, s28
    48a8:	fcvtzs	w7, s29
    48ac:	fmadd	s29, s28, s19, s21
    48b0:	add	w7, w7, #0x7f
    48b4:	fmov	s25, w7
    48b8:	fmadd	s29, s28, s29, s22
    48bc:	fmadd	s29, s28, s29, s23
    48c0:	shl	v25.2s, v25.2s, #23
    48c4:	fmadd	s24, s28, s29, s24
    48c8:	fmadd	s24, s28, s24, s27
    48cc:	fmadd	s29, s28, s24, s27
    48d0:	fmul	s29, s29, s25
    48d4:	fmul	s29, s29, s20
    48d8:	fcmpe	s15, #0.0
    48dc:	fmul	s30, s30, s29
    48e0:	b.mi	479c <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x8bc>  // b.first
    48e4:	b	46e8 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x808>
    48e8:	fmov	s23, #5.000000000000000000e-01
    48ec:	mov	w0, #0x7218                	// #29208
    48f0:	mov	w3, #0xb61                 	// #2913
    48f4:	movk	w0, #0x3f31, lsl #16
    48f8:	mov	w2, #0x8889                	// #34953
    48fc:	fmov	s27, #1.000000000000000000e+00
    4900:	movk	w3, #0x3ab6, lsl #16
    4904:	movk	w2, #0x3c08, lsl #16
    4908:	fmov	s24, w0
    490c:	mov	w1, #0xaaab                	// #43691
    4910:	mov	w0, #0xaaab                	// #43691
    4914:	fadd	s29, s29, s23
    4918:	movk	w1, #0x3d2a, lsl #16
    491c:	movk	w0, #0x3e2a, lsl #16
    4920:	fmov	s18, w3
    4924:	mov	w4, #0x422a                	// #16938
    4928:	fmov	s20, w2
    492c:	movk	w4, #0x3ecc, lsl #16
    4930:	fmov	s21, w1
    4934:	fmov	s22, w0
    4938:	fmov	s19, w4
    493c:	fcvtzs	s29, s29
    4940:	scvtf	s29, s29
    4944:	fmsub	s30, s29, s24, s30
    4948:	fcvtzs	w7, s29
    494c:	fmadd	s29, s30, s18, s20
    4950:	add	w7, w7, #0x7f
    4954:	fmov	s24, w7
    4958:	fmadd	s29, s30, s29, s21
    495c:	fmadd	s29, s30, s29, s22
    4960:	shl	v24.2s, v24.2s, #23
    4964:	fmadd	s23, s30, s29, s23
    4968:	fmadd	s23, s30, s23, s27
    496c:	fmadd	s30, s30, s23, s27
    4970:	fmul	s30, s30, s24
    4974:	fmul	s30, s30, s19
    4978:	fcmpe	s0, #0.0
    497c:	fmul	s31, s31, s30
    4980:	b.mi	4508 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x628>  // b.first
    4984:	b	4500 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x620>
    4988:	fmov	s26, #5.000000000000000000e-01
    498c:	mov	w0, #0x7218                	// #29208
    4990:	mov	w3, #0xb61                 	// #2913
    4994:	movk	w0, #0x3f31, lsl #16
    4998:	mov	w2, #0x8889                	// #34953
    499c:	fmov	s30, #1.000000000000000000e+00
    49a0:	movk	w3, #0x3ab6, lsl #16
    49a4:	movk	w2, #0x3c08, lsl #16
    49a8:	fmov	s27, w0
    49ac:	mov	w1, #0xaaab                	// #43691
    49b0:	mov	w0, #0xaaab                	// #43691
    49b4:	fadd	s28, s28, s26
    49b8:	movk	w1, #0x3d2a, lsl #16
    49bc:	movk	w0, #0x3e2a, lsl #16
    49c0:	fmov	s22, w3
    49c4:	fmov	s23, w2
    49c8:	fmov	s24, w1
    49cc:	fmov	s25, w0
    49d0:	fcvtzs	s28, s28
    49d4:	scvtf	s28, s28
    49d8:	fmsub	s29, s28, s27, s29
    49dc:	fcvtzs	w7, s28
    49e0:	fmadd	s28, s29, s22, s23
    49e4:	add	w7, w7, #0x7f
    49e8:	fmov	s27, w7
    49ec:	fmadd	s28, s29, s28, s24
    49f0:	fmadd	s28, s29, s28, s25
    49f4:	shl	v27.2s, v27.2s, #23
    49f8:	fmadd	s26, s29, s28, s26
    49fc:	fmadd	s26, s29, s26, s30
    4a00:	fmadd	s30, s29, s26, s30
    4a04:	fmul	s30, s30, s27
    4a08:	b	45c4 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x6e4>
    4a0c:	mov	x19, #0x0                   	// #0
    4a10:	b	4288 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x3a8>
    4a14:	nop
    4a18:	nop
    4a1c:	nop

0000000000004a20 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)>:
    4a20:	stp	x29, x30, [sp, #-64]!
    4a24:	mov	x29, sp
    4a28:	stp	x21, x22, [sp, #32]
    4a2c:	add	x22, x0, #0x10
    4a30:	stp	x19, x20, [sp, #16]
    4a34:	str	x22, [x0]
    4a38:	cbz	x1, 4af0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0xd0>
    4a3c:	mov	x20, x0
    4a40:	mov	x0, x1
    4a44:	mov	x21, x1
    4a48:	bl	e80 <strlen@plt>
    4a4c:	str	x0, [sp, #56]
    4a50:	mov	x19, x0
    4a54:	cmp	x0, #0xf
    4a58:	b.hi	4aa0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0x80>  // b.pmore
    4a5c:	cmp	x0, #0x1
    4a60:	b.ne	4a84 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0x64>  // b.any
    4a64:	ldrb	w0, [x21]
    4a68:	str	x19, [x20, #8]
    4a6c:	strb	w0, [x20, #16]
    4a70:	strb	wzr, [x22, x19]
    4a74:	ldp	x19, x20, [sp, #16]
    4a78:	ldp	x21, x22, [sp, #32]
    4a7c:	ldp	x29, x30, [sp], #64
    4a80:	ret
    4a84:	cbnz	x0, 4ac0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::basic_string<std::allocator<char> >(char const*, std::allocator<char> const&)+0xa0>
    4a88:	str	x19, [x20, #8]
    4a8c:	strb	wzr, [x22, x19]
    4a90:	ldp	x19, x20, [sp, #16]
    4a94:	ldp	x21, x22, [sp, #32]
    4a98:	ldp	x29, x30, [sp], #64
    4a9c:	ret
    4aa0:	add	x1, sp, #0x38
    4aa4:	mov	x2, #0x0                   	// #0
    4aa8:	mov	x0, x20
    4aac:	bl	1010 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long)@plt>
    4ab0:	ldr	x1, [sp, #56]
    4ab4:	mov	x22, x0
    4ab8:	str	x0, [x20]
    4abc:	str	x1, [x20, #16]
    4ac0:	mov	x2, x19
    4ac4:	mov	x1, x21
    4ac8:	mov	x0, x22
    4acc:	bl	e70 <memcpy@plt>
    4ad0:	ldr	x19, [sp, #56]
    4ad4:	ldr	x22, [x20]
    4ad8:	str	x19, [x20, #8]
    4adc:	strb	wzr, [x22, x19]
    4ae0:	ldp	x19, x20, [sp, #16]
    4ae4:	ldp	x21, x22, [sp, #32]
    4ae8:	ldp	x29, x30, [sp], #64
    4aec:	ret
    4af0:	adrp	x0, 4000 <price_neon(float const*, float const*, float const*, float const*, float const*, float*, unsigned long)+0x120>
    4af4:	add	x0, x0, #0xe38
    4af8:	bl	f00 <std::__throw_logic_error(char const*)@plt>
    4afc:	nop

0000000000004b00 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)>:
    4b00:	stp	x29, x30, [sp, #-48]!
    4b04:	mov	x29, sp
    4b08:	stp	x19, x20, [sp, #16]
    4b0c:	mov	x20, x0
    4b10:	mov	x0, x1
    4b14:	mov	x19, x1
    4b18:	str	x21, [sp, #32]
    4b1c:	ldr	x21, [x20, #8]
    4b20:	bl	e80 <strlen@plt>
    4b24:	cmp	x21, x0
    4b28:	b.eq	4b40 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)+0x40>  // b.none
    4b2c:	mov	w0, #0x0                   	// #0
    4b30:	ldr	x21, [sp, #32]
    4b34:	ldp	x19, x20, [sp, #16]
    4b38:	ldp	x29, x30, [sp], #48
    4b3c:	ret
    4b40:	mov	w0, #0x1                   	// #1
    4b44:	cbz	x21, 4b30 <bool std::operator==<char, std::char_traits<char>, std::allocator<char> >(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, char const*)+0x30>
    4b48:	ldr	x0, [x20]
    4b4c:	mov	x2, x21
    4b50:	mov	x1, x19
    4b54:	bl	ea0 <memcmp@plt>
    4b58:	ldr	x21, [sp, #32]
    4b5c:	cmp	w0, #0x0
    4b60:	cset	w0, eq	// eq = none
    4b64:	ldp	x19, x20, [sp, #16]
    4b68:	ldp	x29, x30, [sp], #48
    4b6c:	ret
    4b70:	nop
    4b74:	nop
    4b78:	nop
    4b7c:	nop

0000000000004b80 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()>:
    4b80:	ldr	x5, [x0]
    4b84:	mov	w8, #0xb0df                	// #45279
    4b88:	mov	x2, x0
    4b8c:	movk	w8, #0x9908, lsl #16
    4b90:	add	x7, x0, #0x718
    4b94:	mov	x3, x0
    4b98:	nop
    4b9c:	nop
    4ba0:	and	x4, x5, #0xffffffff80000000
    4ba4:	ldr	x5, [x3, #8]
    4ba8:	ldr	x6, [x3, #3176]
    4bac:	and	x1, x5, #0x7fffffff
    4bb0:	orr	x1, x1, x4
    4bb4:	and	x4, x1, #0x1
    4bb8:	eor	x1, x6, x1, lsr #1
    4bbc:	umull	x4, w4, w8
    4bc0:	eor	x1, x1, x4
    4bc4:	str	x1, [x3], #8
    4bc8:	cmp	x3, x7
    4bcc:	b.ne	4ba0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()+0x20>  // b.any
    4bd0:	ldr	x4, [x0, #1816]
    4bd4:	mov	w6, #0xb0df                	// #45279
    4bd8:	add	x7, x0, #0xc60
    4bdc:	movk	w6, #0x9908, lsl #16
    4be0:	and	x3, x4, #0xffffffff80000000
    4be4:	ldr	x4, [x2, #1824]
    4be8:	add	x2, x2, #0x8
    4bec:	ldur	x5, [x2, #-8]
    4bf0:	and	x1, x4, #0x7fffffff
    4bf4:	orr	x1, x1, x3
    4bf8:	and	x3, x1, #0x1
    4bfc:	eor	x1, x5, x1, lsr #1
    4c00:	umull	x3, w3, w6
    4c04:	eor	x1, x1, x3
    4c08:	str	x1, [x2, #1808]
    4c0c:	cmp	x2, x7
    4c10:	b.ne	4be0 <std::mersenne_twister_engine<unsigned long, 32ul, 624ul, 397ul, 31ul, 2567483615ul, 11ul, 4294967295ul, 7ul, 2636928640ul, 15ul, 4022730752ul, 18ul, 1812433253ul>::_M_gen_rand()+0x60>  // b.any
    4c14:	ldr	x2, [x0]
    4c18:	str	xzr, [x0, #4992]
    4c1c:	ldr	x1, [x0, #4984]
    4c20:	ldr	x3, [x0, #3168]
    4c24:	bfxil	x1, x2, #0, #31
    4c28:	and	x2, x1, #0x1
    4c2c:	eor	x1, x3, x1, lsr #1
    4c30:	umull	x2, w2, w6
    4c34:	eor	x1, x1, x2
    4c38:	str	x1, [x0, #4984]
    4c3c:	ret

Disassembly of section .fini:

0000000000004c40 <_fini>:
    4c40:	paciasp
    4c44:	stp	x29, x30, [sp, #-16]!
    4c48:	mov	x29, sp
    4c4c:	ldp	x29, x30, [sp], #16
    4c50:	autiasp
    4c54:	ret
