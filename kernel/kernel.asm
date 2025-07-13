
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	98010113          	addi	sp,sp,-1664 # 80007980 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb94f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	6ed010ef          	jal	80001fe6 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00010517          	auipc	a0,0x10
    80000158:	82c50513          	addi	a0,a0,-2004 # 8000f980 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00010497          	auipc	s1,0x10
    80000164:	82048493          	addi	s1,s1,-2016 # 8000f980 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	8b090913          	addi	s2,s2,-1872 # 8000fa18 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	758010ef          	jal	800018d8 <myproc>
    80000184:	5ef010ef          	jal	80001f72 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	3ad010ef          	jal	80001d3a <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0000f717          	auipc	a4,0xf
    800001a4:	7e070713          	addi	a4,a4,2016 # 8000f980 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	5cb010ef          	jal	80001f9c <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	0000f517          	auipc	a0,0xf
    800001ee:	79650513          	addi	a0,a0,1942 # 8000f980 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00010717          	auipc	a4,0x10
    80000218:	80f72223          	sw	a5,-2044(a4) # 8000fa18 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	0000f517          	auipc	a0,0xf
    8000022e:	75650513          	addi	a0,a0,1878 # 8000f980 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	0000f517          	auipc	a0,0xf
    80000282:	70250513          	addi	a0,a0,1794 # 8000f980 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	591010ef          	jal	80002030 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	6dc50513          	addi	a0,a0,1756 # 8000f980 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	0000f717          	auipc	a4,0xf
    800002c6:	6be70713          	addi	a4,a4,1726 # 8000f980 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	0000f797          	auipc	a5,0xf
    800002ec:	69878793          	addi	a5,a5,1688 # 8000f980 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	0000f797          	auipc	a5,0xf
    8000031a:	7027a783          	lw	a5,1794(a5) # 8000fa18 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	65470713          	addi	a4,a4,1620 # 8000f980 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	64448493          	addi	s1,s1,1604 # 8000f980 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	60270713          	addi	a4,a4,1538 # 8000f980 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	68f72623          	sw	a5,1676(a4) # 8000fa20 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	5ce78793          	addi	a5,a5,1486 # 8000f980 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	64c7a323          	sw	a2,1606(a5) # 8000fa1c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	63a50513          	addi	a0,a0,1594 # 8000fa18 <cons+0x98>
    800003e6:	1a1010ef          	jal	80001d86 <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	58450513          	addi	a0,a0,1412 # 8000f980 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00022797          	auipc	a5,0x22
    80000410:	90c78793          	addi	a5,a5,-1780 # 80021d18 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7139                	addi	sp,sp,-64
    80000432:	fc06                	sd	ra,56(sp)
    80000434:	f822                	sd	s0,48(sp)
    80000436:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fc840693          	addi	a3,s0,-56

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	38a60613          	addi	a2,a2,906 # 800077d0 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78423          	sb	a4,-24(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	f426                	sd	s1,40(sp)
    80000486:	f04a                	sd	s2,32(sp)
    80000488:	fc840713          	addi	a4,s0,-56
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	74a2                	ld	s1,40(sp)
    800004b0:	7902                	ld	s2,32(sp)
}
    800004b2:	70e2                	ld	ra,56(sp)
    800004b4:	7442                	ld	s0,48(sp)
    800004b6:	6121                	addi	sp,sp,64
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	0000f797          	auipc	a5,0xf
    800004e4:	5607a783          	lw	a5,1376(a5) # 8000fa40 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	0000f517          	auipc	a0,0xf
    80000530:	4fc50513          	addi	a0,a0,1276 # 8000fa28 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	0e4b8b93          	addi	s7,s7,228 # 800077d0 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	0000f517          	auipc	a0,0xf
    8000078a:	2a250513          	addi	a0,a0,674 # 8000fa28 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	0000f797          	auipc	a5,0xf
    800007a4:	2a07a023          	sw	zero,672(a5) # 8000fa40 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	00007717          	auipc	a4,0x7
    800007c8:	16f72e23          	sw	a5,380(a4) # 80007940 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	0000f497          	auipc	s1,0xf
    800007dc:	25048493          	addi	s1,s1,592 # 8000fa28 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	0000f517          	auipc	a0,0xf
    80000844:	20850513          	addi	a0,a0,520 # 8000fa48 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	00007797          	auipc	a5,0x7
    80000868:	0dc7a783          	lw	a5,220(a5) # 80007940 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	00007797          	auipc	a5,0x7
    8000089e:	0ae7b783          	ld	a5,174(a5) # 80007948 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	0ae73703          	ld	a4,174(a4) # 80007950 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	0000fa97          	auipc	s5,0xf
    800008cc:	180a8a93          	addi	s5,s5,384 # 8000fa48 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	07848493          	addi	s1,s1,120 # 80007948 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	07498993          	addi	s3,s3,116 # 80007950 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	488010ef          	jal	80001d86 <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	0000f517          	auipc	a0,0xf
    80000950:	0fc50513          	addi	a0,a0,252 # 8000fa48 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	fe87a783          	lw	a5,-24(a5) # 80007940 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	fee73703          	ld	a4,-18(a4) # 80007950 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	fde7b783          	ld	a5,-34(a5) # 80007948 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	0d298993          	addi	s3,s3,210 # 8000fa48 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	fca48493          	addi	s1,s1,-54 # 80007948 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	fca90913          	addi	s2,s2,-54 # 80007950 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	3a4010ef          	jal	80001d3a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	0a048493          	addi	s1,s1,160 # 8000fa48 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	f8e7ba23          	sd	a4,-108(a5) # 80007950 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	0000f497          	auipc	s1,0xf
    80000a24:	02848493          	addi	s1,s1,40 # 8000fa48 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00022797          	auipc	a5,0x22
    80000a5a:	45a78793          	addi	a5,a5,1114 # 80022eb0 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	0000f917          	auipc	s2,0xf
    80000a76:	00e90913          	addi	s2,s2,14 # 8000fa80 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	0000f517          	auipc	a0,0xf
    80000b04:	f8050513          	addi	a0,a0,-128 # 8000fa80 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00022517          	auipc	a0,0x22
    80000b14:	3a050513          	addi	a0,a0,928 # 80022eb0 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	0000f497          	auipc	s1,0xf
    80000b32:	f5248493          	addi	s1,s1,-174 # 8000fa80 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	f3e50513          	addi	a0,a0,-194 # 8000fa80 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	0000f517          	auipc	a0,0xf
    80000b6a:	f1a50513          	addi	a0,a0,-230 # 8000fa80 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	51f000ef          	jal	800018bc <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4f1000ef          	jal	800018bc <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4e9000ef          	jal	800018bc <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4d5000ef          	jal	800018bc <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1c:	4a1000ef          	jal	800018bc <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	47d000ef          	jal	800018bc <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca6:	0f50000f          	fence	iorw,ow
    80000caa:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    80000cda:	00b78023          	sb	a1,0(a5)
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
    80000d16:	40e7853b          	subw	a0,a5,a4
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
    80000d38:	872a                	mv	a4,a0
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc151>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    80000d5e:	96aa                	add	a3,a3,a0
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    80000e2e:	00078023          	sb	zero,0(a5)
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	243000ef          	jal	800018ac <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00007717          	auipc	a4,0x7
    80000e72:	aea70713          	addi	a4,a4,-1302 # 80007958 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e82:	22b000ef          	jal	800018ac <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	0dd010ef          	jal	80002774 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	06d040ef          	jal	80005708 <plicinithart>
  }

  scheduler();        
    80000ea0:	4f9000ef          	jal	80001b98 <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	11d000ef          	jal	800017f8 <procinit>
    trapinit();      // trap vectors
    80000ee0:	071010ef          	jal	80002750 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	091010ef          	jal	80002774 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	007040ef          	jal	800056ee <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	01d040ef          	jal	80005708 <plicinithart>
    binit();         // buffer cache
    80000ef0:	7cb010ef          	jal	80002eba <binit>
    iinit();         // inode table
    80000ef4:	5bc020ef          	jal	800034b0 <iinit>
    fileinit();      // file table
    80000ef8:	368030ef          	jal	80004260 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	0fd040ef          	jal	800057f8 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	31c010ef          	jal	8000221c <userinit>
    __sync_synchronize();
    80000f04:	0ff0000f          	fence
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00007717          	auipc	a4,0x7
    80000f0e:	a4f72723          	sw	a5,-1458(a4) # 80007958 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00007797          	auipc	a5,0x7
    80000f22:	a427b783          	ld	a5,-1470(a5) # 80007960 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc147>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00006797          	auipc	a5,0x6
    800011ae:	7aa7bb23          	sd	a0,1974(a5) # 80007960 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	0000e497          	auipc	s1,0xe
    80001780:	75448493          	addi	s1,s1,1876 # 8000fed0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	bdef8937          	lui	s2,0xbdef8
    8000178a:	bdf90913          	addi	s2,s2,-1057 # ffffffffbdef7bdf <end+0xffffffff3ded4d2f>
    8000178e:	093e                	slli	s2,s2,0xf
    80001790:	bdf90913          	addi	s2,s2,-1057
    80001794:	093e                	slli	s2,s2,0xf
    80001796:	bdf90913          	addi	s2,s2,-1057
    8000179a:	040009b7          	lui	s3,0x4000
    8000179e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a0:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a2:	00016a97          	auipc	s5,0x16
    800017a6:	32ea8a93          	addi	s5,s5,814 # 80017ad0 <tickslock>
    char *pa = kalloc();
    800017aa:	b7aff0ef          	jal	80000b24 <kalloc>
    800017ae:	862a                	mv	a2,a0
    if(pa == 0)
    800017b0:	cd15                	beqz	a0,800017ec <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800017b2:	416485b3          	sub	a1,s1,s6
    800017b6:	8591                	srai	a1,a1,0x4
    800017b8:	032585b3          	mul	a1,a1,s2
    800017bc:	2585                	addiw	a1,a1,1
    800017be:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c2:	4719                	li	a4,6
    800017c4:	6685                	lui	a3,0x1
    800017c6:	40b985b3          	sub	a1,s3,a1
    800017ca:	8552                	mv	a0,s4
    800017cc:	8f9ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d0:	1f048493          	addi	s1,s1,496
    800017d4:	fd549be3          	bne	s1,s5,800017aa <proc_mapstacks+0x44>
  }
}
    800017d8:	70e2                	ld	ra,56(sp)
    800017da:	7442                	ld	s0,48(sp)
    800017dc:	74a2                	ld	s1,40(sp)
    800017de:	7902                	ld	s2,32(sp)
    800017e0:	69e2                	ld	s3,24(sp)
    800017e2:	6a42                	ld	s4,16(sp)
    800017e4:	6aa2                	ld	s5,8(sp)
    800017e6:	6b02                	ld	s6,0(sp)
    800017e8:	6121                	addi	sp,sp,64
    800017ea:	8082                	ret
      panic("kalloc");
    800017ec:	00006517          	auipc	a0,0x6
    800017f0:	a0c50513          	addi	a0,a0,-1524 # 800071f8 <etext+0x1f8>
    800017f4:	fa1fe0ef          	jal	80000794 <panic>

00000000800017f8 <procinit>:
////////////////////////////////////////////////

// initialize the proc table.
void 
procinit(void)
{
    800017f8:	7139                	addi	sp,sp,-64
    800017fa:	fc06                	sd	ra,56(sp)
    800017fc:	f822                	sd	s0,48(sp)
    800017fe:	f426                	sd	s1,40(sp)
    80001800:	f04a                	sd	s2,32(sp)
    80001802:	ec4e                	sd	s3,24(sp)
    80001804:	e852                	sd	s4,16(sp)
    80001806:	e456                	sd	s5,8(sp)
    80001808:	e05a                	sd	s6,0(sp)
    8000180a:	0080                	addi	s0,sp,64
  struct proc *p;
  initlock(&pid_lock, "nextpid");
    8000180c:	00006597          	auipc	a1,0x6
    80001810:	9f458593          	addi	a1,a1,-1548 # 80007200 <etext+0x200>
    80001814:	0000e517          	auipc	a0,0xe
    80001818:	28c50513          	addi	a0,a0,652 # 8000faa0 <pid_lock>
    8000181c:	b58ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001820:	00006597          	auipc	a1,0x6
    80001824:	9e858593          	addi	a1,a1,-1560 # 80007208 <etext+0x208>
    80001828:	0000e517          	auipc	a0,0xe
    8000182c:	29050513          	addi	a0,a0,656 # 8000fab8 <wait_lock>
    80001830:	b44ff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001834:	0000e497          	auipc	s1,0xe
    80001838:	69c48493          	addi	s1,s1,1692 # 8000fed0 <proc>
    initlock(&p->lock, "proc");
    8000183c:	00006b17          	auipc	s6,0x6
    80001840:	9dcb0b13          	addi	s6,s6,-1572 # 80007218 <etext+0x218>
    p->state = UNUSED;
    p->kstack = KSTACK((int) (p - proc));
    80001844:	8aa6                	mv	s5,s1
    80001846:	bdef8937          	lui	s2,0xbdef8
    8000184a:	bdf90913          	addi	s2,s2,-1057 # ffffffffbdef7bdf <end+0xffffffff3ded4d2f>
    8000184e:	093e                	slli	s2,s2,0xf
    80001850:	bdf90913          	addi	s2,s2,-1057
    80001854:	093e                	slli	s2,s2,0xf
    80001856:	bdf90913          	addi	s2,s2,-1057
    8000185a:	040009b7          	lui	s3,0x4000
    8000185e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001860:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001862:	00016a17          	auipc	s4,0x16
    80001866:	26ea0a13          	addi	s4,s4,622 # 80017ad0 <tickslock>
    initlock(&p->lock, "proc");
    8000186a:	85da                	mv	a1,s6
    8000186c:	8526                	mv	a0,s1
    8000186e:	b06ff0ef          	jal	80000b74 <initlock>
    p->state = UNUSED;
    80001872:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int) (p - proc));
    80001876:	415487b3          	sub	a5,s1,s5
    8000187a:	8791                	srai	a5,a5,0x4
    8000187c:	032787b3          	mul	a5,a5,s2
    80001880:	2785                	addiw	a5,a5,1
    80001882:	00d7979b          	slliw	a5,a5,0xd
    80001886:	40f987b3          	sub	a5,s3,a5
    8000188a:	e0bc                	sd	a5,64(s1)
    p->current_thread = 0; 
    8000188c:	1e04b423          	sd	zero,488(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001890:	1f048493          	addi	s1,s1,496
    80001894:	fd449be3          	bne	s1,s4,8000186a <procinit+0x72>
  }
}
    80001898:	70e2                	ld	ra,56(sp)
    8000189a:	7442                	ld	s0,48(sp)
    8000189c:	74a2                	ld	s1,40(sp)
    8000189e:	7902                	ld	s2,32(sp)
    800018a0:	69e2                	ld	s3,24(sp)
    800018a2:	6a42                	ld	s4,16(sp)
    800018a4:	6aa2                	ld	s5,8(sp)
    800018a6:	6b02                	ld	s6,0(sp)
    800018a8:	6121                	addi	sp,sp,64
    800018aa:	8082                	ret

00000000800018ac <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018ac:	1141                	addi	sp,sp,-16
    800018ae:	e422                	sd	s0,8(sp)
    800018b0:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018b2:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018b4:	2501                	sext.w	a0,a0
    800018b6:	6422                	ld	s0,8(sp)
    800018b8:	0141                	addi	sp,sp,16
    800018ba:	8082                	ret

00000000800018bc <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018bc:	1141                	addi	sp,sp,-16
    800018be:	e422                	sd	s0,8(sp)
    800018c0:	0800                	addi	s0,sp,16
    800018c2:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018c4:	2781                	sext.w	a5,a5
    800018c6:	079e                	slli	a5,a5,0x7
  return c;
}
    800018c8:	0000e517          	auipc	a0,0xe
    800018cc:	20850513          	addi	a0,a0,520 # 8000fad0 <cpus>
    800018d0:	953e                	add	a0,a0,a5
    800018d2:	6422                	ld	s0,8(sp)
    800018d4:	0141                	addi	sp,sp,16
    800018d6:	8082                	ret

00000000800018d8 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018d8:	1101                	addi	sp,sp,-32
    800018da:	ec06                	sd	ra,24(sp)
    800018dc:	e822                	sd	s0,16(sp)
    800018de:	e426                	sd	s1,8(sp)
    800018e0:	1000                	addi	s0,sp,32
  push_off();
    800018e2:	ad2ff0ef          	jal	80000bb4 <push_off>
    800018e6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018e8:	2781                	sext.w	a5,a5
    800018ea:	079e                	slli	a5,a5,0x7
    800018ec:	0000e717          	auipc	a4,0xe
    800018f0:	1b470713          	addi	a4,a4,436 # 8000faa0 <pid_lock>
    800018f4:	97ba                	add	a5,a5,a4
    800018f6:	7b84                	ld	s1,48(a5)
  pop_off();
    800018f8:	b40ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    800018fc:	8526                	mv	a0,s1
    800018fe:	60e2                	ld	ra,24(sp)
    80001900:	6442                	ld	s0,16(sp)
    80001902:	64a2                	ld	s1,8(sp)
    80001904:	6105                	addi	sp,sp,32
    80001906:	8082                	ret

0000000080001908 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001908:	1141                	addi	sp,sp,-16
    8000190a:	e406                	sd	ra,8(sp)
    8000190c:	e022                	sd	s0,0(sp)
    8000190e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001910:	fc9ff0ef          	jal	800018d8 <myproc>
    80001914:	b78ff0ef          	jal	80000c8c <release>

  if (first) {
    80001918:	00006797          	auipc	a5,0x6
    8000191c:	fd87a783          	lw	a5,-40(a5) # 800078f0 <first.1>
    80001920:	e799                	bnez	a5,8000192e <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001922:	66b000ef          	jal	8000278c <usertrapret>
}
    80001926:	60a2                	ld	ra,8(sp)
    80001928:	6402                	ld	s0,0(sp)
    8000192a:	0141                	addi	sp,sp,16
    8000192c:	8082                	ret
    fsinit(ROOTDEV);
    8000192e:	4505                	li	a0,1
    80001930:	315010ef          	jal	80003444 <fsinit>
    first = 0;
    80001934:	00006797          	auipc	a5,0x6
    80001938:	fa07ae23          	sw	zero,-68(a5) # 800078f0 <first.1>
    __sync_synchronize();
    8000193c:	0ff0000f          	fence
    80001940:	b7cd                	j	80001922 <forkret+0x1a>

0000000080001942 <allocpid>:
{
    80001942:	1101                	addi	sp,sp,-32
    80001944:	ec06                	sd	ra,24(sp)
    80001946:	e822                	sd	s0,16(sp)
    80001948:	e426                	sd	s1,8(sp)
    8000194a:	e04a                	sd	s2,0(sp)
    8000194c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    8000194e:	0000e917          	auipc	s2,0xe
    80001952:	15290913          	addi	s2,s2,338 # 8000faa0 <pid_lock>
    80001956:	854a                	mv	a0,s2
    80001958:	a9cff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    8000195c:	00006797          	auipc	a5,0x6
    80001960:	f9878793          	addi	a5,a5,-104 # 800078f4 <nextpid>
    80001964:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001966:	0014871b          	addiw	a4,s1,1
    8000196a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    8000196c:	854a                	mv	a0,s2
    8000196e:	b1eff0ef          	jal	80000c8c <release>
}
    80001972:	8526                	mv	a0,s1
    80001974:	60e2                	ld	ra,24(sp)
    80001976:	6442                	ld	s0,16(sp)
    80001978:	64a2                	ld	s1,8(sp)
    8000197a:	6902                	ld	s2,0(sp)
    8000197c:	6105                	addi	sp,sp,32
    8000197e:	8082                	ret

0000000080001980 <proc_pagetable>:
{
    80001980:	1101                	addi	sp,sp,-32
    80001982:	ec06                	sd	ra,24(sp)
    80001984:	e822                	sd	s0,16(sp)
    80001986:	e426                	sd	s1,8(sp)
    80001988:	e04a                	sd	s2,0(sp)
    8000198a:	1000                	addi	s0,sp,32
    8000198c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000198e:	8e9ff0ef          	jal	80001276 <uvmcreate>
    80001992:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001994:	cd05                	beqz	a0,800019cc <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001996:	4729                	li	a4,10
    80001998:	00004697          	auipc	a3,0x4
    8000199c:	66868693          	addi	a3,a3,1640 # 80006000 <_trampoline>
    800019a0:	6605                	lui	a2,0x1
    800019a2:	040005b7          	lui	a1,0x4000
    800019a6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019a8:	05b2                	slli	a1,a1,0xc
    800019aa:	e6aff0ef          	jal	80001014 <mappages>
    800019ae:	02054663          	bltz	a0,800019da <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019b2:	4719                	li	a4,6
    800019b4:	05893683          	ld	a3,88(s2)
    800019b8:	6605                	lui	a2,0x1
    800019ba:	020005b7          	lui	a1,0x2000
    800019be:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c0:	05b6                	slli	a1,a1,0xd
    800019c2:	8526                	mv	a0,s1
    800019c4:	e50ff0ef          	jal	80001014 <mappages>
    800019c8:	00054f63          	bltz	a0,800019e6 <proc_pagetable+0x66>
}
    800019cc:	8526                	mv	a0,s1
    800019ce:	60e2                	ld	ra,24(sp)
    800019d0:	6442                	ld	s0,16(sp)
    800019d2:	64a2                	ld	s1,8(sp)
    800019d4:	6902                	ld	s2,0(sp)
    800019d6:	6105                	addi	sp,sp,32
    800019d8:	8082                	ret
    uvmfree(pagetable, 0);
    800019da:	4581                	li	a1,0
    800019dc:	8526                	mv	a0,s1
    800019de:	a67ff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019e2:	4481                	li	s1,0
    800019e4:	b7e5                	j	800019cc <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019e6:	4681                	li	a3,0
    800019e8:	4605                	li	a2,1
    800019ea:	040005b7          	lui	a1,0x4000
    800019ee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f0:	05b2                	slli	a1,a1,0xc
    800019f2:	8526                	mv	a0,s1
    800019f4:	fc6ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    800019f8:	4581                	li	a1,0
    800019fa:	8526                	mv	a0,s1
    800019fc:	a49ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a00:	4481                	li	s1,0
    80001a02:	b7e9                	j	800019cc <proc_pagetable+0x4c>

0000000080001a04 <proc_freepagetable>:
{
    80001a04:	1101                	addi	sp,sp,-32
    80001a06:	ec06                	sd	ra,24(sp)
    80001a08:	e822                	sd	s0,16(sp)
    80001a0a:	e426                	sd	s1,8(sp)
    80001a0c:	e04a                	sd	s2,0(sp)
    80001a0e:	1000                	addi	s0,sp,32
    80001a10:	84aa                	mv	s1,a0
    80001a12:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a14:	4681                	li	a3,0
    80001a16:	4605                	li	a2,1
    80001a18:	040005b7          	lui	a1,0x4000
    80001a1c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a1e:	05b2                	slli	a1,a1,0xc
    80001a20:	f9aff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a24:	4681                	li	a3,0
    80001a26:	4605                	li	a2,1
    80001a28:	020005b7          	lui	a1,0x2000
    80001a2c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a2e:	05b6                	slli	a1,a1,0xd
    80001a30:	8526                	mv	a0,s1
    80001a32:	f88ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a36:	85ca                	mv	a1,s2
    80001a38:	8526                	mv	a0,s1
    80001a3a:	a0bff0ef          	jal	80001444 <uvmfree>
}
    80001a3e:	60e2                	ld	ra,24(sp)
    80001a40:	6442                	ld	s0,16(sp)
    80001a42:	64a2                	ld	s1,8(sp)
    80001a44:	6902                	ld	s2,0(sp)
    80001a46:	6105                	addi	sp,sp,32
    80001a48:	8082                	ret

0000000080001a4a <growproc>:
{
    80001a4a:	1101                	addi	sp,sp,-32
    80001a4c:	ec06                	sd	ra,24(sp)
    80001a4e:	e822                	sd	s0,16(sp)
    80001a50:	e426                	sd	s1,8(sp)
    80001a52:	e04a                	sd	s2,0(sp)
    80001a54:	1000                	addi	s0,sp,32
    80001a56:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001a58:	e81ff0ef          	jal	800018d8 <myproc>
    80001a5c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001a5e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001a60:	01204c63          	bgtz	s2,80001a78 <growproc+0x2e>
  } else if(n < 0){
    80001a64:	02094463          	bltz	s2,80001a8c <growproc+0x42>
  p->sz = sz;
    80001a68:	e4ac                	sd	a1,72(s1)
  return 0;
    80001a6a:	4501                	li	a0,0
}
    80001a6c:	60e2                	ld	ra,24(sp)
    80001a6e:	6442                	ld	s0,16(sp)
    80001a70:	64a2                	ld	s1,8(sp)
    80001a72:	6902                	ld	s2,0(sp)
    80001a74:	6105                	addi	sp,sp,32
    80001a76:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001a78:	4691                	li	a3,4
    80001a7a:	00b90633          	add	a2,s2,a1
    80001a7e:	6928                	ld	a0,80(a0)
    80001a80:	8bfff0ef          	jal	8000133e <uvmalloc>
    80001a84:	85aa                	mv	a1,a0
    80001a86:	f16d                	bnez	a0,80001a68 <growproc+0x1e>
      return -1;
    80001a88:	557d                	li	a0,-1
    80001a8a:	b7cd                	j	80001a6c <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001a8c:	00b90633          	add	a2,s2,a1
    80001a90:	6928                	ld	a0,80(a0)
    80001a92:	869ff0ef          	jal	800012fa <uvmdealloc>
    80001a96:	85aa                	mv	a1,a0
    80001a98:	bfc1                	j	80001a68 <growproc+0x1e>

0000000080001a9a <thread_schd>:
  if (!p->current_thread) {
    80001a9a:	1e853783          	ld	a5,488(a0)
    80001a9e:	cbed                	beqz	a5,80001b90 <thread_schd+0xf6>
thread_schd(struct proc *p) {
    80001aa0:	1101                	addi	sp,sp,-32
    80001aa2:	ec06                	sd	ra,24(sp)
    80001aa4:	e822                	sd	s0,16(sp)
    80001aa6:	e426                	sd	s1,8(sp)
    80001aa8:	e04a                	sd	s2,0(sp)
    80001aaa:	1000                	addi	s0,sp,32
    80001aac:	84aa                	mv	s1,a0
  if (p->current_thread->state == THREAD_RUNNING) {
    80001aae:	4394                	lw	a3,0(a5)
    80001ab0:	4709                	li	a4,2
    80001ab2:	02e68c63          	beq	a3,a4,80001aea <thread_schd+0x50>
  acquire(&tickslock);
    80001ab6:	00016517          	auipc	a0,0x16
    80001aba:	01a50513          	addi	a0,a0,26 # 80017ad0 <tickslock>
    80001abe:	936ff0ef          	jal	80000bf4 <acquire>
  uint ticks0 = ticks;
    80001ac2:	00006917          	auipc	s2,0x6
    80001ac6:	eae92903          	lw	s2,-338(s2) # 80007970 <ticks>
  release(&tickslock);
    80001aca:	00016517          	auipc	a0,0x16
    80001ace:	00650513          	addi	a0,a0,6 # 80017ad0 <tickslock>
    80001ad2:	9baff0ef          	jal	80000c8c <release>
  struct thread *t = p->current_thread + 1;
    80001ad6:	1e84b803          	ld	a6,488(s1)
    80001ada:	02080793          	addi	a5,a6,32
    80001ade:	4711                	li	a4,4
    if (t >= p->threads + NTHREAD) {
    80001ae0:	1e848593          	addi	a1,s1,488
    if (t->state == THREAD_RUNNABLE) {
    80001ae4:	4605                	li	a2,1
    else if (t->state == THREAD_SLEEPING && ticks0 - t -> sleep_tick0 >= t->sleep_n) {
    80001ae6:	4511                	li	a0,4
    80001ae8:	a829                	j	80001b02 <thread_schd+0x68>
    p->current_thread->state = THREAD_RUNNABLE;
    80001aea:	4705                	li	a4,1
    80001aec:	c398                	sw	a4,0(a5)
    80001aee:	b7e1                	j	80001ab6 <thread_schd+0x1c>
    if (t->state == THREAD_RUNNABLE) {
    80001af0:	4394                	lw	a3,0(a5)
    80001af2:	02c68463          	beq	a3,a2,80001b1a <thread_schd+0x80>
    else if (t->state == THREAD_SLEEPING && ticks0 - t -> sleep_tick0 >= t->sleep_n) {
    80001af6:	00a68b63          	beq	a3,a0,80001b0c <thread_schd+0x72>
  for (int i = 0; i < NTHREAD; i++, t++) {
    80001afa:	02078793          	addi	a5,a5,32
    80001afe:	377d                	addiw	a4,a4,-1
    80001b00:	c349                	beqz	a4,80001b82 <thread_schd+0xe8>
    if (t >= p->threads + NTHREAD) {
    80001b02:	feb7e7e3          	bltu	a5,a1,80001af0 <thread_schd+0x56>
      t = p->threads;
    80001b06:	16848793          	addi	a5,s1,360
    80001b0a:	b7dd                	j	80001af0 <thread_schd+0x56>
    else if (t->state == THREAD_SLEEPING && ticks0 - t -> sleep_tick0 >= t->sleep_n) {
    80001b0c:	4fd4                	lw	a3,28(a5)
    80001b0e:	40d906bb          	subw	a3,s2,a3
    80001b12:	0187a883          	lw	a7,24(a5)
    80001b16:	ff16e2e3          	bltu	a3,a7,80001afa <thread_schd+0x60>
  else if (p->current_thread != next) {
    80001b1a:	06f80d63          	beq	a6,a5,80001b94 <thread_schd+0xfa>
    next->state = THREAD_RUNNING;
    80001b1e:	4709                	li	a4,2
    80001b20:	c398                	sw	a4,0(a5)
    struct thread *t = p->current_thread;
    80001b22:	1e84b703          	ld	a4,488(s1)
    p->current_thread = next;
    80001b26:	1ef4b423          	sd	a5,488(s1)
    if (t->trapframe) {
    80001b2a:	6714                	ld	a3,8(a4)
    80001b2c:	c685                	beqz	a3,80001b54 <thread_schd+0xba>
      *t->trapframe = *p->trapframe;
    80001b2e:	6cb8                	ld	a4,88(s1)
    80001b30:	12070893          	addi	a7,a4,288
    80001b34:	00073803          	ld	a6,0(a4)
    80001b38:	6708                	ld	a0,8(a4)
    80001b3a:	6b0c                	ld	a1,16(a4)
    80001b3c:	6f10                	ld	a2,24(a4)
    80001b3e:	0106b023          	sd	a6,0(a3)
    80001b42:	e688                	sd	a0,8(a3)
    80001b44:	ea8c                	sd	a1,16(a3)
    80001b46:	ee90                	sd	a2,24(a3)
    80001b48:	02070713          	addi	a4,a4,32
    80001b4c:	02068693          	addi	a3,a3,32
    80001b50:	ff1712e3          	bne	a4,a7,80001b34 <thread_schd+0x9a>
    *p->trapframe = *next->trapframe;
    80001b54:	6794                	ld	a3,8(a5)
    80001b56:	87b6                	mv	a5,a3
    80001b58:	6cb8                	ld	a4,88(s1)
    80001b5a:	12068693          	addi	a3,a3,288
    80001b5e:	0007b803          	ld	a6,0(a5)
    80001b62:	6788                	ld	a0,8(a5)
    80001b64:	6b8c                	ld	a1,16(a5)
    80001b66:	6f90                	ld	a2,24(a5)
    80001b68:	01073023          	sd	a6,0(a4)
    80001b6c:	e708                	sd	a0,8(a4)
    80001b6e:	eb0c                	sd	a1,16(a4)
    80001b70:	ef10                	sd	a2,24(a4)
    80001b72:	02078793          	addi	a5,a5,32
    80001b76:	02070713          	addi	a4,a4,32
    80001b7a:	fed792e3          	bne	a5,a3,80001b5e <thread_schd+0xc4>
  return 1;
    80001b7e:	4505                	li	a0,1
    80001b80:	a011                	j	80001b84 <thread_schd+0xea>
    return 0;
    80001b82:	4501                	li	a0,0
}
    80001b84:	60e2                	ld	ra,24(sp)
    80001b86:	6442                	ld	s0,16(sp)
    80001b88:	64a2                	ld	s1,8(sp)
    80001b8a:	6902                	ld	s2,0(sp)
    80001b8c:	6105                	addi	sp,sp,32
    80001b8e:	8082                	ret
    return 1;
    80001b90:	4505                	li	a0,1
}
    80001b92:	8082                	ret
  return 1;
    80001b94:	4505                	li	a0,1
    80001b96:	b7fd                	j	80001b84 <thread_schd+0xea>

0000000080001b98 <scheduler>:
{
    80001b98:	715d                	addi	sp,sp,-80
    80001b9a:	e486                	sd	ra,72(sp)
    80001b9c:	e0a2                	sd	s0,64(sp)
    80001b9e:	fc26                	sd	s1,56(sp)
    80001ba0:	f84a                	sd	s2,48(sp)
    80001ba2:	f44e                	sd	s3,40(sp)
    80001ba4:	f052                	sd	s4,32(sp)
    80001ba6:	ec56                	sd	s5,24(sp)
    80001ba8:	e85a                	sd	s6,16(sp)
    80001baa:	e45e                	sd	s7,8(sp)
    80001bac:	e062                	sd	s8,0(sp)
    80001bae:	0880                	addi	s0,sp,80
    80001bb0:	8792                	mv	a5,tp
  int id = r_tp();
    80001bb2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001bb4:	00779b13          	slli	s6,a5,0x7
    80001bb8:	0000e717          	auipc	a4,0xe
    80001bbc:	ee870713          	addi	a4,a4,-280 # 8000faa0 <pid_lock>
    80001bc0:	975a                	add	a4,a4,s6
    80001bc2:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001bc6:	0000e717          	auipc	a4,0xe
    80001bca:	f1270713          	addi	a4,a4,-238 # 8000fad8 <cpus+0x8>
    80001bce:	9b3a                	add	s6,s6,a4
          p->state = RUNNING;
    80001bd0:	4c11                	li	s8,4
          c->proc = p;
    80001bd2:	079e                	slli	a5,a5,0x7
    80001bd4:	0000ea17          	auipc	s4,0xe
    80001bd8:	ecca0a13          	addi	s4,s4,-308 # 8000faa0 <pid_lock>
    80001bdc:	9a3e                	add	s4,s4,a5
          found = 1;
    80001bde:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001be0:	00016997          	auipc	s3,0x16
    80001be4:	ef098993          	addi	s3,s3,-272 # 80017ad0 <tickslock>
    80001be8:	a889                	j	80001c3a <scheduler+0xa2>
      release(&p->lock);
    80001bea:	8526                	mv	a0,s1
    80001bec:	8a0ff0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001bf0:	1f048493          	addi	s1,s1,496
    80001bf4:	03348963          	beq	s1,s3,80001c26 <scheduler+0x8e>
      acquire(&p->lock);
    80001bf8:	8526                	mv	a0,s1
    80001bfa:	ffbfe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001bfe:	4c9c                	lw	a5,24(s1)
    80001c00:	ff2795e3          	bne	a5,s2,80001bea <scheduler+0x52>
        if (thread_schd(p)) {
    80001c04:	8526                	mv	a0,s1
    80001c06:	e95ff0ef          	jal	80001a9a <thread_schd>
    80001c0a:	d165                	beqz	a0,80001bea <scheduler+0x52>
          p->state = RUNNING;
    80001c0c:	0184ac23          	sw	s8,24(s1)
          c->proc = p;
    80001c10:	029a3823          	sd	s1,48(s4)
          swtch(&c->context, &p->context);
    80001c14:	06048593          	addi	a1,s1,96
    80001c18:	855a                	mv	a0,s6
    80001c1a:	2cd000ef          	jal	800026e6 <swtch>
          c->proc = 0;
    80001c1e:	020a3823          	sd	zero,48(s4)
          found = 1;
    80001c22:	8ade                	mv	s5,s7
    80001c24:	b7d9                	j	80001bea <scheduler+0x52>
    if(found == 0) {
    80001c26:	000a9a63          	bnez	s5,80001c3a <scheduler+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c2a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001c2e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c32:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001c36:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c42:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001c46:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001c48:	0000e497          	auipc	s1,0xe
    80001c4c:	28848493          	addi	s1,s1,648 # 8000fed0 <proc>
      if(p->state == RUNNABLE) {
    80001c50:	490d                	li	s2,3
    80001c52:	b75d                	j	80001bf8 <scheduler+0x60>

0000000080001c54 <sched>:
{
    80001c54:	7179                	addi	sp,sp,-48
    80001c56:	f406                	sd	ra,40(sp)
    80001c58:	f022                	sd	s0,32(sp)
    80001c5a:	ec26                	sd	s1,24(sp)
    80001c5c:	e84a                	sd	s2,16(sp)
    80001c5e:	e44e                	sd	s3,8(sp)
    80001c60:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001c62:	c77ff0ef          	jal	800018d8 <myproc>
    80001c66:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001c68:	f23fe0ef          	jal	80000b8a <holding>
    80001c6c:	c92d                	beqz	a0,80001cde <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c6e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001c70:	2781                	sext.w	a5,a5
    80001c72:	079e                	slli	a5,a5,0x7
    80001c74:	0000e717          	auipc	a4,0xe
    80001c78:	e2c70713          	addi	a4,a4,-468 # 8000faa0 <pid_lock>
    80001c7c:	97ba                	add	a5,a5,a4
    80001c7e:	0a87a703          	lw	a4,168(a5)
    80001c82:	4785                	li	a5,1
    80001c84:	06f71363          	bne	a4,a5,80001cea <sched+0x96>
  if(p->state == RUNNING)
    80001c88:	4c98                	lw	a4,24(s1)
    80001c8a:	4791                	li	a5,4
    80001c8c:	06f70563          	beq	a4,a5,80001cf6 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c90:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001c94:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001c96:	e7b5                	bnez	a5,80001d02 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c98:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001c9a:	0000e917          	auipc	s2,0xe
    80001c9e:	e0690913          	addi	s2,s2,-506 # 8000faa0 <pid_lock>
    80001ca2:	2781                	sext.w	a5,a5
    80001ca4:	079e                	slli	a5,a5,0x7
    80001ca6:	97ca                	add	a5,a5,s2
    80001ca8:	0ac7a983          	lw	s3,172(a5)
    80001cac:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001cae:	2781                	sext.w	a5,a5
    80001cb0:	079e                	slli	a5,a5,0x7
    80001cb2:	0000e597          	auipc	a1,0xe
    80001cb6:	e2658593          	addi	a1,a1,-474 # 8000fad8 <cpus+0x8>
    80001cba:	95be                	add	a1,a1,a5
    80001cbc:	06048513          	addi	a0,s1,96
    80001cc0:	227000ef          	jal	800026e6 <swtch>
    80001cc4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001cc6:	2781                	sext.w	a5,a5
    80001cc8:	079e                	slli	a5,a5,0x7
    80001cca:	993e                	add	s2,s2,a5
    80001ccc:	0b392623          	sw	s3,172(s2)
}
    80001cd0:	70a2                	ld	ra,40(sp)
    80001cd2:	7402                	ld	s0,32(sp)
    80001cd4:	64e2                	ld	s1,24(sp)
    80001cd6:	6942                	ld	s2,16(sp)
    80001cd8:	69a2                	ld	s3,8(sp)
    80001cda:	6145                	addi	sp,sp,48
    80001cdc:	8082                	ret
    panic("sched p->lock");
    80001cde:	00005517          	auipc	a0,0x5
    80001ce2:	54250513          	addi	a0,a0,1346 # 80007220 <etext+0x220>
    80001ce6:	aaffe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001cea:	00005517          	auipc	a0,0x5
    80001cee:	54650513          	addi	a0,a0,1350 # 80007230 <etext+0x230>
    80001cf2:	aa3fe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001cf6:	00005517          	auipc	a0,0x5
    80001cfa:	54a50513          	addi	a0,a0,1354 # 80007240 <etext+0x240>
    80001cfe:	a97fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001d02:	00005517          	auipc	a0,0x5
    80001d06:	54e50513          	addi	a0,a0,1358 # 80007250 <etext+0x250>
    80001d0a:	a8bfe0ef          	jal	80000794 <panic>

0000000080001d0e <yield>:
{
    80001d0e:	1101                	addi	sp,sp,-32
    80001d10:	ec06                	sd	ra,24(sp)
    80001d12:	e822                	sd	s0,16(sp)
    80001d14:	e426                	sd	s1,8(sp)
    80001d16:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001d18:	bc1ff0ef          	jal	800018d8 <myproc>
    80001d1c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001d1e:	ed7fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001d22:	478d                	li	a5,3
    80001d24:	cc9c                	sw	a5,24(s1)
  sched();
    80001d26:	f2fff0ef          	jal	80001c54 <sched>
  release(&p->lock);
    80001d2a:	8526                	mv	a0,s1
    80001d2c:	f61fe0ef          	jal	80000c8c <release>
}
    80001d30:	60e2                	ld	ra,24(sp)
    80001d32:	6442                	ld	s0,16(sp)
    80001d34:	64a2                	ld	s1,8(sp)
    80001d36:	6105                	addi	sp,sp,32
    80001d38:	8082                	ret

0000000080001d3a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001d3a:	7179                	addi	sp,sp,-48
    80001d3c:	f406                	sd	ra,40(sp)
    80001d3e:	f022                	sd	s0,32(sp)
    80001d40:	ec26                	sd	s1,24(sp)
    80001d42:	e84a                	sd	s2,16(sp)
    80001d44:	e44e                	sd	s3,8(sp)
    80001d46:	1800                	addi	s0,sp,48
    80001d48:	89aa                	mv	s3,a0
    80001d4a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001d4c:	b8dff0ef          	jal	800018d8 <myproc>
    80001d50:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001d52:	ea3fe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001d56:	854a                	mv	a0,s2
    80001d58:	f35fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001d5c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001d60:	4789                	li	a5,2
    80001d62:	cc9c                	sw	a5,24(s1)

  sched();
    80001d64:	ef1ff0ef          	jal	80001c54 <sched>

  // Tidy up.
  p->chan = 0;
    80001d68:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001d6c:	8526                	mv	a0,s1
    80001d6e:	f1ffe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001d72:	854a                	mv	a0,s2
    80001d74:	e81fe0ef          	jal	80000bf4 <acquire>
}
    80001d78:	70a2                	ld	ra,40(sp)
    80001d7a:	7402                	ld	s0,32(sp)
    80001d7c:	64e2                	ld	s1,24(sp)
    80001d7e:	6942                	ld	s2,16(sp)
    80001d80:	69a2                	ld	s3,8(sp)
    80001d82:	6145                	addi	sp,sp,48
    80001d84:	8082                	ret

0000000080001d86 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001d86:	7139                	addi	sp,sp,-64
    80001d88:	fc06                	sd	ra,56(sp)
    80001d8a:	f822                	sd	s0,48(sp)
    80001d8c:	f426                	sd	s1,40(sp)
    80001d8e:	f04a                	sd	s2,32(sp)
    80001d90:	ec4e                	sd	s3,24(sp)
    80001d92:	e852                	sd	s4,16(sp)
    80001d94:	e456                	sd	s5,8(sp)
    80001d96:	0080                	addi	s0,sp,64
    80001d98:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001d9a:	0000e497          	auipc	s1,0xe
    80001d9e:	13648493          	addi	s1,s1,310 # 8000fed0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001da2:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001da4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001da6:	00016917          	auipc	s2,0x16
    80001daa:	d2a90913          	addi	s2,s2,-726 # 80017ad0 <tickslock>
    80001dae:	a801                	j	80001dbe <wakeup+0x38>
      }
      release(&p->lock);
    80001db0:	8526                	mv	a0,s1
    80001db2:	edbfe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001db6:	1f048493          	addi	s1,s1,496
    80001dba:	03248263          	beq	s1,s2,80001dde <wakeup+0x58>
    if(p != myproc()){
    80001dbe:	b1bff0ef          	jal	800018d8 <myproc>
    80001dc2:	fea48ae3          	beq	s1,a0,80001db6 <wakeup+0x30>
      acquire(&p->lock);
    80001dc6:	8526                	mv	a0,s1
    80001dc8:	e2dfe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001dcc:	4c9c                	lw	a5,24(s1)
    80001dce:	ff3791e3          	bne	a5,s3,80001db0 <wakeup+0x2a>
    80001dd2:	709c                	ld	a5,32(s1)
    80001dd4:	fd479ee3          	bne	a5,s4,80001db0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001dd8:	0154ac23          	sw	s5,24(s1)
    80001ddc:	bfd1                	j	80001db0 <wakeup+0x2a>
    }
  }
}
    80001dde:	70e2                	ld	ra,56(sp)
    80001de0:	7442                	ld	s0,48(sp)
    80001de2:	74a2                	ld	s1,40(sp)
    80001de4:	7902                	ld	s2,32(sp)
    80001de6:	69e2                	ld	s3,24(sp)
    80001de8:	6a42                	ld	s4,16(sp)
    80001dea:	6aa2                	ld	s5,8(sp)
    80001dec:	6121                	addi	sp,sp,64
    80001dee:	8082                	ret

0000000080001df0 <reparent>:
{
    80001df0:	7179                	addi	sp,sp,-48
    80001df2:	f406                	sd	ra,40(sp)
    80001df4:	f022                	sd	s0,32(sp)
    80001df6:	ec26                	sd	s1,24(sp)
    80001df8:	e84a                	sd	s2,16(sp)
    80001dfa:	e44e                	sd	s3,8(sp)
    80001dfc:	e052                	sd	s4,0(sp)
    80001dfe:	1800                	addi	s0,sp,48
    80001e00:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001e02:	0000e497          	auipc	s1,0xe
    80001e06:	0ce48493          	addi	s1,s1,206 # 8000fed0 <proc>
      pp->parent = initproc;
    80001e0a:	00006a17          	auipc	s4,0x6
    80001e0e:	b5ea0a13          	addi	s4,s4,-1186 # 80007968 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001e12:	00016997          	auipc	s3,0x16
    80001e16:	cbe98993          	addi	s3,s3,-834 # 80017ad0 <tickslock>
    80001e1a:	a029                	j	80001e24 <reparent+0x34>
    80001e1c:	1f048493          	addi	s1,s1,496
    80001e20:	01348b63          	beq	s1,s3,80001e36 <reparent+0x46>
    if(pp->parent == p){
    80001e24:	7c9c                	ld	a5,56(s1)
    80001e26:	ff279be3          	bne	a5,s2,80001e1c <reparent+0x2c>
      pp->parent = initproc;
    80001e2a:	000a3503          	ld	a0,0(s4)
    80001e2e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001e30:	f57ff0ef          	jal	80001d86 <wakeup>
    80001e34:	b7e5                	j	80001e1c <reparent+0x2c>
}
    80001e36:	70a2                	ld	ra,40(sp)
    80001e38:	7402                	ld	s0,32(sp)
    80001e3a:	64e2                	ld	s1,24(sp)
    80001e3c:	6942                	ld	s2,16(sp)
    80001e3e:	69a2                	ld	s3,8(sp)
    80001e40:	6a02                	ld	s4,0(sp)
    80001e42:	6145                	addi	sp,sp,48
    80001e44:	8082                	ret

0000000080001e46 <exit>:
{
    80001e46:	7179                	addi	sp,sp,-48
    80001e48:	f406                	sd	ra,40(sp)
    80001e4a:	f022                	sd	s0,32(sp)
    80001e4c:	ec26                	sd	s1,24(sp)
    80001e4e:	e84a                	sd	s2,16(sp)
    80001e50:	e44e                	sd	s3,8(sp)
    80001e52:	e052                	sd	s4,0(sp)
    80001e54:	1800                	addi	s0,sp,48
    80001e56:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001e58:	a81ff0ef          	jal	800018d8 <myproc>
    80001e5c:	89aa                	mv	s3,a0
  if(p == initproc)
    80001e5e:	00006797          	auipc	a5,0x6
    80001e62:	b0a7b783          	ld	a5,-1270(a5) # 80007968 <initproc>
    80001e66:	0d050493          	addi	s1,a0,208
    80001e6a:	15050913          	addi	s2,a0,336
    80001e6e:	00a79f63          	bne	a5,a0,80001e8c <exit+0x46>
    panic("init exiting");
    80001e72:	00005517          	auipc	a0,0x5
    80001e76:	3f650513          	addi	a0,a0,1014 # 80007268 <etext+0x268>
    80001e7a:	91bfe0ef          	jal	80000794 <panic>
      fileclose(f);
    80001e7e:	4aa020ef          	jal	80004328 <fileclose>
      p->ofile[fd] = 0;
    80001e82:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001e86:	04a1                	addi	s1,s1,8
    80001e88:	01248563          	beq	s1,s2,80001e92 <exit+0x4c>
    if(p->ofile[fd]){
    80001e8c:	6088                	ld	a0,0(s1)
    80001e8e:	f965                	bnez	a0,80001e7e <exit+0x38>
    80001e90:	bfdd                	j	80001e86 <exit+0x40>
  begin_op();
    80001e92:	07c020ef          	jal	80003f0e <begin_op>
  iput(p->cwd);
    80001e96:	1509b503          	ld	a0,336(s3)
    80001e9a:	161010ef          	jal	800037fa <iput>
  end_op();
    80001e9e:	0da020ef          	jal	80003f78 <end_op>
  p->cwd = 0;
    80001ea2:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001ea6:	0000e497          	auipc	s1,0xe
    80001eaa:	c1248493          	addi	s1,s1,-1006 # 8000fab8 <wait_lock>
    80001eae:	8526                	mv	a0,s1
    80001eb0:	d45fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80001eb4:	854e                	mv	a0,s3
    80001eb6:	f3bff0ef          	jal	80001df0 <reparent>
  wakeup(p->parent);
    80001eba:	0389b503          	ld	a0,56(s3)
    80001ebe:	ec9ff0ef          	jal	80001d86 <wakeup>
  acquire(&p->lock);
    80001ec2:	854e                	mv	a0,s3
    80001ec4:	d31fe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    80001ec8:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001ecc:	4795                	li	a5,5
    80001ece:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	db9fe0ef          	jal	80000c8c <release>
  sched();
    80001ed8:	d7dff0ef          	jal	80001c54 <sched>
  panic("zombie exit");
    80001edc:	00005517          	auipc	a0,0x5
    80001ee0:	39c50513          	addi	a0,a0,924 # 80007278 <etext+0x278>
    80001ee4:	8b1fe0ef          	jal	80000794 <panic>

0000000080001ee8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001ee8:	7179                	addi	sp,sp,-48
    80001eea:	f406                	sd	ra,40(sp)
    80001eec:	f022                	sd	s0,32(sp)
    80001eee:	ec26                	sd	s1,24(sp)
    80001ef0:	e84a                	sd	s2,16(sp)
    80001ef2:	e44e                	sd	s3,8(sp)
    80001ef4:	1800                	addi	s0,sp,48
    80001ef6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001ef8:	0000e497          	auipc	s1,0xe
    80001efc:	fd848493          	addi	s1,s1,-40 # 8000fed0 <proc>
    80001f00:	00016997          	auipc	s3,0x16
    80001f04:	bd098993          	addi	s3,s3,-1072 # 80017ad0 <tickslock>
    acquire(&p->lock);
    80001f08:	8526                	mv	a0,s1
    80001f0a:	cebfe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80001f0e:	589c                	lw	a5,48(s1)
    80001f10:	01278b63          	beq	a5,s2,80001f26 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001f14:	8526                	mv	a0,s1
    80001f16:	d77fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001f1a:	1f048493          	addi	s1,s1,496
    80001f1e:	ff3495e3          	bne	s1,s3,80001f08 <kill+0x20>
  }
  return -1;
    80001f22:	557d                	li	a0,-1
    80001f24:	a819                	j	80001f3a <kill+0x52>
      p->killed = 1;
    80001f26:	4785                	li	a5,1
    80001f28:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001f2a:	4c98                	lw	a4,24(s1)
    80001f2c:	4789                	li	a5,2
    80001f2e:	00f70d63          	beq	a4,a5,80001f48 <kill+0x60>
      release(&p->lock);
    80001f32:	8526                	mv	a0,s1
    80001f34:	d59fe0ef          	jal	80000c8c <release>
      return 0;
    80001f38:	4501                	li	a0,0
}
    80001f3a:	70a2                	ld	ra,40(sp)
    80001f3c:	7402                	ld	s0,32(sp)
    80001f3e:	64e2                	ld	s1,24(sp)
    80001f40:	6942                	ld	s2,16(sp)
    80001f42:	69a2                	ld	s3,8(sp)
    80001f44:	6145                	addi	sp,sp,48
    80001f46:	8082                	ret
        p->state = RUNNABLE;
    80001f48:	478d                	li	a5,3
    80001f4a:	cc9c                	sw	a5,24(s1)
    80001f4c:	b7dd                	j	80001f32 <kill+0x4a>

0000000080001f4e <setkilled>:

void
setkilled(struct proc *p)
{
    80001f4e:	1101                	addi	sp,sp,-32
    80001f50:	ec06                	sd	ra,24(sp)
    80001f52:	e822                	sd	s0,16(sp)
    80001f54:	e426                	sd	s1,8(sp)
    80001f56:	1000                	addi	s0,sp,32
    80001f58:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f5a:	c9bfe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    80001f5e:	4785                	li	a5,1
    80001f60:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001f62:	8526                	mv	a0,s1
    80001f64:	d29fe0ef          	jal	80000c8c <release>
}
    80001f68:	60e2                	ld	ra,24(sp)
    80001f6a:	6442                	ld	s0,16(sp)
    80001f6c:	64a2                	ld	s1,8(sp)
    80001f6e:	6105                	addi	sp,sp,32
    80001f70:	8082                	ret

0000000080001f72 <killed>:

int
killed(struct proc *p)
{
    80001f72:	1101                	addi	sp,sp,-32
    80001f74:	ec06                	sd	ra,24(sp)
    80001f76:	e822                	sd	s0,16(sp)
    80001f78:	e426                	sd	s1,8(sp)
    80001f7a:	e04a                	sd	s2,0(sp)
    80001f7c:	1000                	addi	s0,sp,32
    80001f7e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001f80:	c75fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80001f84:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001f88:	8526                	mv	a0,s1
    80001f8a:	d03fe0ef          	jal	80000c8c <release>
  return k;
}
    80001f8e:	854a                	mv	a0,s2
    80001f90:	60e2                	ld	ra,24(sp)
    80001f92:	6442                	ld	s0,16(sp)
    80001f94:	64a2                	ld	s1,8(sp)
    80001f96:	6902                	ld	s2,0(sp)
    80001f98:	6105                	addi	sp,sp,32
    80001f9a:	8082                	ret

0000000080001f9c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001f9c:	7179                	addi	sp,sp,-48
    80001f9e:	f406                	sd	ra,40(sp)
    80001fa0:	f022                	sd	s0,32(sp)
    80001fa2:	ec26                	sd	s1,24(sp)
    80001fa4:	e84a                	sd	s2,16(sp)
    80001fa6:	e44e                	sd	s3,8(sp)
    80001fa8:	e052                	sd	s4,0(sp)
    80001faa:	1800                	addi	s0,sp,48
    80001fac:	84aa                	mv	s1,a0
    80001fae:	892e                	mv	s2,a1
    80001fb0:	89b2                	mv	s3,a2
    80001fb2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001fb4:	925ff0ef          	jal	800018d8 <myproc>
  if(user_dst){
    80001fb8:	cc99                	beqz	s1,80001fd6 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80001fba:	86d2                	mv	a3,s4
    80001fbc:	864e                	mv	a2,s3
    80001fbe:	85ca                	mv	a1,s2
    80001fc0:	6928                	ld	a0,80(a0)
    80001fc2:	d90ff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001fc6:	70a2                	ld	ra,40(sp)
    80001fc8:	7402                	ld	s0,32(sp)
    80001fca:	64e2                	ld	s1,24(sp)
    80001fcc:	6942                	ld	s2,16(sp)
    80001fce:	69a2                	ld	s3,8(sp)
    80001fd0:	6a02                	ld	s4,0(sp)
    80001fd2:	6145                	addi	sp,sp,48
    80001fd4:	8082                	ret
    memmove((char *)dst, src, len);
    80001fd6:	000a061b          	sext.w	a2,s4
    80001fda:	85ce                	mv	a1,s3
    80001fdc:	854a                	mv	a0,s2
    80001fde:	d47fe0ef          	jal	80000d24 <memmove>
    return 0;
    80001fe2:	8526                	mv	a0,s1
    80001fe4:	b7cd                	j	80001fc6 <either_copyout+0x2a>

0000000080001fe6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001fe6:	7179                	addi	sp,sp,-48
    80001fe8:	f406                	sd	ra,40(sp)
    80001fea:	f022                	sd	s0,32(sp)
    80001fec:	ec26                	sd	s1,24(sp)
    80001fee:	e84a                	sd	s2,16(sp)
    80001ff0:	e44e                	sd	s3,8(sp)
    80001ff2:	e052                	sd	s4,0(sp)
    80001ff4:	1800                	addi	s0,sp,48
    80001ff6:	892a                	mv	s2,a0
    80001ff8:	84ae                	mv	s1,a1
    80001ffa:	89b2                	mv	s3,a2
    80001ffc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001ffe:	8dbff0ef          	jal	800018d8 <myproc>
  if(user_src){
    80002002:	cc99                	beqz	s1,80002020 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002004:	86d2                	mv	a3,s4
    80002006:	864e                	mv	a2,s3
    80002008:	85ca                	mv	a1,s2
    8000200a:	6928                	ld	a0,80(a0)
    8000200c:	e1cff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002010:	70a2                	ld	ra,40(sp)
    80002012:	7402                	ld	s0,32(sp)
    80002014:	64e2                	ld	s1,24(sp)
    80002016:	6942                	ld	s2,16(sp)
    80002018:	69a2                	ld	s3,8(sp)
    8000201a:	6a02                	ld	s4,0(sp)
    8000201c:	6145                	addi	sp,sp,48
    8000201e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002020:	000a061b          	sext.w	a2,s4
    80002024:	85ce                	mv	a1,s3
    80002026:	854a                	mv	a0,s2
    80002028:	cfdfe0ef          	jal	80000d24 <memmove>
    return 0;
    8000202c:	8526                	mv	a0,s1
    8000202e:	b7cd                	j	80002010 <either_copyin+0x2a>

0000000080002030 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002030:	715d                	addi	sp,sp,-80
    80002032:	e486                	sd	ra,72(sp)
    80002034:	e0a2                	sd	s0,64(sp)
    80002036:	fc26                	sd	s1,56(sp)
    80002038:	f84a                	sd	s2,48(sp)
    8000203a:	f44e                	sd	s3,40(sp)
    8000203c:	f052                	sd	s4,32(sp)
    8000203e:	ec56                	sd	s5,24(sp)
    80002040:	e85a                	sd	s6,16(sp)
    80002042:	e45e                	sd	s7,8(sp)
    80002044:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002046:	00005517          	auipc	a0,0x5
    8000204a:	03250513          	addi	a0,a0,50 # 80007078 <etext+0x78>
    8000204e:	c74fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002052:	0000e497          	auipc	s1,0xe
    80002056:	fd648493          	addi	s1,s1,-42 # 80010028 <proc+0x158>
    8000205a:	00016917          	auipc	s2,0x16
    8000205e:	bce90913          	addi	s2,s2,-1074 # 80017c28 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002062:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002064:	00005997          	auipc	s3,0x5
    80002068:	22498993          	addi	s3,s3,548 # 80007288 <etext+0x288>
    printf("%d %s %s", p->pid, state, p->name);
    8000206c:	00005a97          	auipc	s5,0x5
    80002070:	224a8a93          	addi	s5,s5,548 # 80007290 <etext+0x290>
    printf("\n");
    80002074:	00005a17          	auipc	s4,0x5
    80002078:	004a0a13          	addi	s4,s4,4 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000207c:	00005b97          	auipc	s7,0x5
    80002080:	76cb8b93          	addi	s7,s7,1900 # 800077e8 <states.0>
    80002084:	a829                	j	8000209e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002086:	ed86a583          	lw	a1,-296(a3)
    8000208a:	8556                	mv	a0,s5
    8000208c:	c36fe0ef          	jal	800004c2 <printf>
    printf("\n");
    80002090:	8552                	mv	a0,s4
    80002092:	c30fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002096:	1f048493          	addi	s1,s1,496
    8000209a:	03248263          	beq	s1,s2,800020be <procdump+0x8e>
    if(p->state == UNUSED)
    8000209e:	86a6                	mv	a3,s1
    800020a0:	ec04a783          	lw	a5,-320(s1)
    800020a4:	dbed                	beqz	a5,80002096 <procdump+0x66>
      state = "???";
    800020a6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800020a8:	fcfb6fe3          	bltu	s6,a5,80002086 <procdump+0x56>
    800020ac:	02079713          	slli	a4,a5,0x20
    800020b0:	01d75793          	srli	a5,a4,0x1d
    800020b4:	97de                	add	a5,a5,s7
    800020b6:	6390                	ld	a2,0(a5)
    800020b8:	f679                	bnez	a2,80002086 <procdump+0x56>
      state = "???";
    800020ba:	864e                	mv	a2,s3
    800020bc:	b7e9                	j	80002086 <procdump+0x56>
  }
}
    800020be:	60a6                	ld	ra,72(sp)
    800020c0:	6406                	ld	s0,64(sp)
    800020c2:	74e2                	ld	s1,56(sp)
    800020c4:	7942                	ld	s2,48(sp)
    800020c6:	79a2                	ld	s3,40(sp)
    800020c8:	7a02                	ld	s4,32(sp)
    800020ca:	6ae2                	ld	s5,24(sp)
    800020cc:	6b42                	ld	s6,16(sp)
    800020ce:	6ba2                	ld	s7,8(sp)
    800020d0:	6161                	addi	sp,sp,80
    800020d2:	8082                	ret

00000000800020d4 <freethread>:
  return 0;
}

void
freethread(struct thread *t)
{
    800020d4:	1101                	addi	sp,sp,-32
    800020d6:	ec06                	sd	ra,24(sp)
    800020d8:	e822                	sd	s0,16(sp)
    800020da:	e426                	sd	s1,8(sp)
    800020dc:	1000                	addi	s0,sp,32
    800020de:	84aa                	mv	s1,a0
  t->state = THREAD_UNUSED;
    800020e0:	00052023          	sw	zero,0(a0)
  if (t->trapframe)
    800020e4:	6508                	ld	a0,8(a0)
    800020e6:	c119                	beqz	a0,800020ec <freethread+0x18>
    kfree((void*)t->trapframe);
    800020e8:	95bfe0ef          	jal	80000a42 <kfree>
  t->trapframe = 0;
    800020ec:	0004b423          	sd	zero,8(s1)
  t->id = 0;
    800020f0:	0004a823          	sw	zero,16(s1)
  t->join = 0;
    800020f4:	0004aa23          	sw	zero,20(s1)
}
    800020f8:	60e2                	ld	ra,24(sp)
    800020fa:	6442                	ld	s0,16(sp)
    800020fc:	64a2                	ld	s1,8(sp)
    800020fe:	6105                	addi	sp,sp,32
    80002100:	8082                	ret

0000000080002102 <freeproc>:
{
    80002102:	1101                	addi	sp,sp,-32
    80002104:	ec06                	sd	ra,24(sp)
    80002106:	e822                	sd	s0,16(sp)
    80002108:	e426                	sd	s1,8(sp)
    8000210a:	1000                	addi	s0,sp,32
    8000210c:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000210e:	6d28                	ld	a0,88(a0)
    80002110:	c119                	beqz	a0,80002116 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80002112:	931fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80002116:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000211a:	68a8                	ld	a0,80(s1)
    8000211c:	c501                	beqz	a0,80002124 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    8000211e:	64ac                	ld	a1,72(s1)
    80002120:	8e5ff0ef          	jal	80001a04 <proc_freepagetable>
  p->pagetable = 0;
    80002124:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80002128:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    8000212c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80002130:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80002134:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80002138:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    8000213c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80002140:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80002144:	0004ac23          	sw	zero,24(s1)
  p->current_thread = 0; // Reset current_thread to null
    80002148:	1e04b423          	sd	zero,488(s1)
    freethread(&p->threads[i]); 
    8000214c:	16848513          	addi	a0,s1,360
    80002150:	f85ff0ef          	jal	800020d4 <freethread>
    80002154:	18848513          	addi	a0,s1,392
    80002158:	f7dff0ef          	jal	800020d4 <freethread>
    8000215c:	1a848513          	addi	a0,s1,424
    80002160:	f75ff0ef          	jal	800020d4 <freethread>
    80002164:	1c848513          	addi	a0,s1,456
    80002168:	f6dff0ef          	jal	800020d4 <freethread>
}
    8000216c:	60e2                	ld	ra,24(sp)
    8000216e:	6442                	ld	s0,16(sp)
    80002170:	64a2                	ld	s1,8(sp)
    80002172:	6105                	addi	sp,sp,32
    80002174:	8082                	ret

0000000080002176 <allocproc>:
{
    80002176:	1101                	addi	sp,sp,-32
    80002178:	ec06                	sd	ra,24(sp)
    8000217a:	e822                	sd	s0,16(sp)
    8000217c:	e426                	sd	s1,8(sp)
    8000217e:	e04a                	sd	s2,0(sp)
    80002180:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80002182:	0000e497          	auipc	s1,0xe
    80002186:	d4e48493          	addi	s1,s1,-690 # 8000fed0 <proc>
    8000218a:	00016917          	auipc	s2,0x16
    8000218e:	94690913          	addi	s2,s2,-1722 # 80017ad0 <tickslock>
    acquire(&p->lock);
    80002192:	8526                	mv	a0,s1
    80002194:	a61fe0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80002198:	4c9c                	lw	a5,24(s1)
    8000219a:	cb91                	beqz	a5,800021ae <allocproc+0x38>
      release(&p->lock);
    8000219c:	8526                	mv	a0,s1
    8000219e:	aeffe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021a2:	1f048493          	addi	s1,s1,496
    800021a6:	ff2496e3          	bne	s1,s2,80002192 <allocproc+0x1c>
  return 0;
    800021aa:	4481                	li	s1,0
    800021ac:	a089                	j	800021ee <allocproc+0x78>
  p->pid = allocpid();
    800021ae:	f94ff0ef          	jal	80001942 <allocpid>
    800021b2:	d888                	sw	a0,48(s1)
  p->state = USED;
    800021b4:	4785                	li	a5,1
    800021b6:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800021b8:	96dfe0ef          	jal	80000b24 <kalloc>
    800021bc:	892a                	mv	s2,a0
    800021be:	eca8                	sd	a0,88(s1)
    800021c0:	cd15                	beqz	a0,800021fc <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    800021c2:	8526                	mv	a0,s1
    800021c4:	fbcff0ef          	jal	80001980 <proc_pagetable>
    800021c8:	892a                	mv	s2,a0
    800021ca:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800021cc:	c121                	beqz	a0,8000220c <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    800021ce:	07000613          	li	a2,112
    800021d2:	4581                	li	a1,0
    800021d4:	06048513          	addi	a0,s1,96
    800021d8:	af1fe0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    800021dc:	fffff797          	auipc	a5,0xfffff
    800021e0:	72c78793          	addi	a5,a5,1836 # 80001908 <forkret>
    800021e4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800021e6:	60bc                	ld	a5,64(s1)
    800021e8:	6705                	lui	a4,0x1
    800021ea:	97ba                	add	a5,a5,a4
    800021ec:	f4bc                	sd	a5,104(s1)
}
    800021ee:	8526                	mv	a0,s1
    800021f0:	60e2                	ld	ra,24(sp)
    800021f2:	6442                	ld	s0,16(sp)
    800021f4:	64a2                	ld	s1,8(sp)
    800021f6:	6902                	ld	s2,0(sp)
    800021f8:	6105                	addi	sp,sp,32
    800021fa:	8082                	ret
    freeproc(p);
    800021fc:	8526                	mv	a0,s1
    800021fe:	f05ff0ef          	jal	80002102 <freeproc>
    release(&p->lock);
    80002202:	8526                	mv	a0,s1
    80002204:	a89fe0ef          	jal	80000c8c <release>
    return 0;
    80002208:	84ca                	mv	s1,s2
    8000220a:	b7d5                	j	800021ee <allocproc+0x78>
    freeproc(p);
    8000220c:	8526                	mv	a0,s1
    8000220e:	ef5ff0ef          	jal	80002102 <freeproc>
    release(&p->lock);
    80002212:	8526                	mv	a0,s1
    80002214:	a79fe0ef          	jal	80000c8c <release>
    return 0;
    80002218:	84ca                	mv	s1,s2
    8000221a:	bfd1                	j	800021ee <allocproc+0x78>

000000008000221c <userinit>:
{
    8000221c:	1101                	addi	sp,sp,-32
    8000221e:	ec06                	sd	ra,24(sp)
    80002220:	e822                	sd	s0,16(sp)
    80002222:	e426                	sd	s1,8(sp)
    80002224:	1000                	addi	s0,sp,32
  p = allocproc();
    80002226:	f51ff0ef          	jal	80002176 <allocproc>
    8000222a:	84aa                	mv	s1,a0
  initproc = p;
    8000222c:	00005797          	auipc	a5,0x5
    80002230:	72a7be23          	sd	a0,1852(a5) # 80007968 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80002234:	03400613          	li	a2,52
    80002238:	00005597          	auipc	a1,0x5
    8000223c:	6c858593          	addi	a1,a1,1736 # 80007900 <initcode>
    80002240:	6928                	ld	a0,80(a0)
    80002242:	85aff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80002246:	6785                	lui	a5,0x1
    80002248:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    8000224a:	6cb8                	ld	a4,88(s1)
    8000224c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80002250:	6cb8                	ld	a4,88(s1)
    80002252:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002254:	4641                	li	a2,16
    80002256:	00005597          	auipc	a1,0x5
    8000225a:	04a58593          	addi	a1,a1,74 # 800072a0 <etext+0x2a0>
    8000225e:	15848513          	addi	a0,s1,344
    80002262:	ba5fe0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80002266:	00005517          	auipc	a0,0x5
    8000226a:	04a50513          	addi	a0,a0,74 # 800072b0 <etext+0x2b0>
    8000226e:	2e5010ef          	jal	80003d52 <namei>
    80002272:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80002276:	478d                	li	a5,3
    80002278:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000227a:	8526                	mv	a0,s1
    8000227c:	a11fe0ef          	jal	80000c8c <release>
}
    80002280:	60e2                	ld	ra,24(sp)
    80002282:	6442                	ld	s0,16(sp)
    80002284:	64a2                	ld	s1,8(sp)
    80002286:	6105                	addi	sp,sp,32
    80002288:	8082                	ret

000000008000228a <fork>:
{
    8000228a:	7139                	addi	sp,sp,-64
    8000228c:	fc06                	sd	ra,56(sp)
    8000228e:	f822                	sd	s0,48(sp)
    80002290:	f04a                	sd	s2,32(sp)
    80002292:	e456                	sd	s5,8(sp)
    80002294:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002296:	e42ff0ef          	jal	800018d8 <myproc>
    8000229a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000229c:	edbff0ef          	jal	80002176 <allocproc>
    800022a0:	0e050a63          	beqz	a0,80002394 <fork+0x10a>
    800022a4:	e852                	sd	s4,16(sp)
    800022a6:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800022a8:	048ab603          	ld	a2,72(s5)
    800022ac:	692c                	ld	a1,80(a0)
    800022ae:	050ab503          	ld	a0,80(s5)
    800022b2:	9c4ff0ef          	jal	80001476 <uvmcopy>
    800022b6:	04054a63          	bltz	a0,8000230a <fork+0x80>
    800022ba:	f426                	sd	s1,40(sp)
    800022bc:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    800022be:	048ab783          	ld	a5,72(s5)
    800022c2:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    800022c6:	058ab683          	ld	a3,88(s5)
    800022ca:	87b6                	mv	a5,a3
    800022cc:	058a3703          	ld	a4,88(s4)
    800022d0:	12068693          	addi	a3,a3,288
    800022d4:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800022d8:	6788                	ld	a0,8(a5)
    800022da:	6b8c                	ld	a1,16(a5)
    800022dc:	6f90                	ld	a2,24(a5)
    800022de:	01073023          	sd	a6,0(a4)
    800022e2:	e708                	sd	a0,8(a4)
    800022e4:	eb0c                	sd	a1,16(a4)
    800022e6:	ef10                	sd	a2,24(a4)
    800022e8:	02078793          	addi	a5,a5,32
    800022ec:	02070713          	addi	a4,a4,32
    800022f0:	fed792e3          	bne	a5,a3,800022d4 <fork+0x4a>
  np->trapframe->a0 = 0;
    800022f4:	058a3783          	ld	a5,88(s4)
    800022f8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800022fc:	0d0a8493          	addi	s1,s5,208
    80002300:	0d0a0913          	addi	s2,s4,208
    80002304:	150a8993          	addi	s3,s5,336
    80002308:	a831                	j	80002324 <fork+0x9a>
    freeproc(np);
    8000230a:	8552                	mv	a0,s4
    8000230c:	df7ff0ef          	jal	80002102 <freeproc>
    release(&np->lock);
    80002310:	8552                	mv	a0,s4
    80002312:	97bfe0ef          	jal	80000c8c <release>
    return -1;
    80002316:	597d                	li	s2,-1
    80002318:	6a42                	ld	s4,16(sp)
    8000231a:	a0b5                	j	80002386 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    8000231c:	04a1                	addi	s1,s1,8
    8000231e:	0921                	addi	s2,s2,8
    80002320:	01348963          	beq	s1,s3,80002332 <fork+0xa8>
    if(p->ofile[i])
    80002324:	6088                	ld	a0,0(s1)
    80002326:	d97d                	beqz	a0,8000231c <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80002328:	7bb010ef          	jal	800042e2 <filedup>
    8000232c:	00a93023          	sd	a0,0(s2)
    80002330:	b7f5                	j	8000231c <fork+0x92>
  np->cwd = idup(p->cwd);
    80002332:	150ab503          	ld	a0,336(s5)
    80002336:	30c010ef          	jal	80003642 <idup>
    8000233a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000233e:	4641                	li	a2,16
    80002340:	158a8593          	addi	a1,s5,344
    80002344:	158a0513          	addi	a0,s4,344
    80002348:	abffe0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    8000234c:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80002350:	8552                	mv	a0,s4
    80002352:	93bfe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80002356:	0000d497          	auipc	s1,0xd
    8000235a:	76248493          	addi	s1,s1,1890 # 8000fab8 <wait_lock>
    8000235e:	8526                	mv	a0,s1
    80002360:	895fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80002364:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	923fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    8000236e:	8552                	mv	a0,s4
    80002370:	885fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80002374:	478d                	li	a5,3
    80002376:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000237a:	8552                	mv	a0,s4
    8000237c:	911fe0ef          	jal	80000c8c <release>
  return pid;
    80002380:	74a2                	ld	s1,40(sp)
    80002382:	69e2                	ld	s3,24(sp)
    80002384:	6a42                	ld	s4,16(sp)
}
    80002386:	854a                	mv	a0,s2
    80002388:	70e2                	ld	ra,56(sp)
    8000238a:	7442                	ld	s0,48(sp)
    8000238c:	7902                	ld	s2,32(sp)
    8000238e:	6aa2                	ld	s5,8(sp)
    80002390:	6121                	addi	sp,sp,64
    80002392:	8082                	ret
    return -1;
    80002394:	597d                	li	s2,-1
    80002396:	bfc5                	j	80002386 <fork+0xfc>

0000000080002398 <wait>:
{
    80002398:	715d                	addi	sp,sp,-80
    8000239a:	e486                	sd	ra,72(sp)
    8000239c:	e0a2                	sd	s0,64(sp)
    8000239e:	fc26                	sd	s1,56(sp)
    800023a0:	f84a                	sd	s2,48(sp)
    800023a2:	f44e                	sd	s3,40(sp)
    800023a4:	f052                	sd	s4,32(sp)
    800023a6:	ec56                	sd	s5,24(sp)
    800023a8:	e85a                	sd	s6,16(sp)
    800023aa:	e45e                	sd	s7,8(sp)
    800023ac:	e062                	sd	s8,0(sp)
    800023ae:	0880                	addi	s0,sp,80
    800023b0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023b2:	d26ff0ef          	jal	800018d8 <myproc>
    800023b6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023b8:	0000d517          	auipc	a0,0xd
    800023bc:	70050513          	addi	a0,a0,1792 # 8000fab8 <wait_lock>
    800023c0:	835fe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    800023c4:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023c6:	4a15                	li	s4,5
        havekids = 1;
    800023c8:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ca:	00015997          	auipc	s3,0x15
    800023ce:	70698993          	addi	s3,s3,1798 # 80017ad0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023d2:	0000dc17          	auipc	s8,0xd
    800023d6:	6e6c0c13          	addi	s8,s8,1766 # 8000fab8 <wait_lock>
    800023da:	a871                	j	80002476 <wait+0xde>
          pid = pp->pid;
    800023dc:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023e0:	000b0c63          	beqz	s6,800023f8 <wait+0x60>
    800023e4:	4691                	li	a3,4
    800023e6:	02c48613          	addi	a2,s1,44
    800023ea:	85da                	mv	a1,s6
    800023ec:	05093503          	ld	a0,80(s2)
    800023f0:	962ff0ef          	jal	80001552 <copyout>
    800023f4:	02054b63          	bltz	a0,8000242a <wait+0x92>
          freeproc(pp);
    800023f8:	8526                	mv	a0,s1
    800023fa:	d09ff0ef          	jal	80002102 <freeproc>
          release(&pp->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	88dfe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    80002404:	0000d517          	auipc	a0,0xd
    80002408:	6b450513          	addi	a0,a0,1716 # 8000fab8 <wait_lock>
    8000240c:	881fe0ef          	jal	80000c8c <release>
}
    80002410:	854e                	mv	a0,s3
    80002412:	60a6                	ld	ra,72(sp)
    80002414:	6406                	ld	s0,64(sp)
    80002416:	74e2                	ld	s1,56(sp)
    80002418:	7942                	ld	s2,48(sp)
    8000241a:	79a2                	ld	s3,40(sp)
    8000241c:	7a02                	ld	s4,32(sp)
    8000241e:	6ae2                	ld	s5,24(sp)
    80002420:	6b42                	ld	s6,16(sp)
    80002422:	6ba2                	ld	s7,8(sp)
    80002424:	6c02                	ld	s8,0(sp)
    80002426:	6161                	addi	sp,sp,80
    80002428:	8082                	ret
            release(&pp->lock);
    8000242a:	8526                	mv	a0,s1
    8000242c:	861fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    80002430:	0000d517          	auipc	a0,0xd
    80002434:	68850513          	addi	a0,a0,1672 # 8000fab8 <wait_lock>
    80002438:	855fe0ef          	jal	80000c8c <release>
            return -1;
    8000243c:	59fd                	li	s3,-1
    8000243e:	bfc9                	j	80002410 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002440:	1f048493          	addi	s1,s1,496
    80002444:	03348063          	beq	s1,s3,80002464 <wait+0xcc>
      if(pp->parent == p){
    80002448:	7c9c                	ld	a5,56(s1)
    8000244a:	ff279be3          	bne	a5,s2,80002440 <wait+0xa8>
        acquire(&pp->lock);
    8000244e:	8526                	mv	a0,s1
    80002450:	fa4fe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    80002454:	4c9c                	lw	a5,24(s1)
    80002456:	f94783e3          	beq	a5,s4,800023dc <wait+0x44>
        release(&pp->lock);
    8000245a:	8526                	mv	a0,s1
    8000245c:	831fe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002460:	8756                	mv	a4,s5
    80002462:	bff9                	j	80002440 <wait+0xa8>
    if(!havekids || killed(p)){
    80002464:	cf19                	beqz	a4,80002482 <wait+0xea>
    80002466:	854a                	mv	a0,s2
    80002468:	b0bff0ef          	jal	80001f72 <killed>
    8000246c:	e919                	bnez	a0,80002482 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000246e:	85e2                	mv	a1,s8
    80002470:	854a                	mv	a0,s2
    80002472:	8c9ff0ef          	jal	80001d3a <sleep>
    havekids = 0;
    80002476:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002478:	0000e497          	auipc	s1,0xe
    8000247c:	a5848493          	addi	s1,s1,-1448 # 8000fed0 <proc>
    80002480:	b7e1                	j	80002448 <wait+0xb0>
      release(&wait_lock);
    80002482:	0000d517          	auipc	a0,0xd
    80002486:	63650513          	addi	a0,a0,1590 # 8000fab8 <wait_lock>
    8000248a:	803fe0ef          	jal	80000c8c <release>
      return -1;
    8000248e:	59fd                	li	s3,-1
    80002490:	b741                	j	80002410 <wait+0x78>

0000000080002492 <initthread>:
{
    80002492:	7179                	addi	sp,sp,-48
    80002494:	f406                	sd	ra,40(sp)
    80002496:	f022                	sd	s0,32(sp)
    80002498:	ec26                	sd	s1,24(sp)
    8000249a:	e84a                	sd	s2,16(sp)
    8000249c:	1800                	addi	s0,sp,48
    8000249e:	84aa                	mv	s1,a0
  if (!p->current_thread) {
    800024a0:	1e853783          	ld	a5,488(a0)
    800024a4:	cb91                	beqz	a5,800024b8 <initthread+0x26>
  return p->current_thread;
    800024a6:	1e84b903          	ld	s2,488(s1)
}
    800024aa:	854a                	mv	a0,s2
    800024ac:	70a2                	ld	ra,40(sp)
    800024ae:	7402                	ld	s0,32(sp)
    800024b0:	64e2                	ld	s1,24(sp)
    800024b2:	6942                	ld	s2,16(sp)
    800024b4:	6145                	addi	sp,sp,48
    800024b6:	8082                	ret
    800024b8:	e44e                	sd	s3,8(sp)
      p->threads[i].trapframe = 0;
    800024ba:	16053823          	sd	zero,368(a0)
      freethread(&p->threads[i]);
    800024be:	16850993          	addi	s3,a0,360
    800024c2:	854e                	mv	a0,s3
    800024c4:	c11ff0ef          	jal	800020d4 <freethread>
      p->threads[i].trapframe = 0;
    800024c8:	1804b823          	sd	zero,400(s1)
      freethread(&p->threads[i]);
    800024cc:	18848513          	addi	a0,s1,392
    800024d0:	c05ff0ef          	jal	800020d4 <freethread>
      p->threads[i].trapframe = 0;
    800024d4:	1a04b823          	sd	zero,432(s1)
      freethread(&p->threads[i]);
    800024d8:	1a848513          	addi	a0,s1,424
    800024dc:	bf9ff0ef          	jal	800020d4 <freethread>
      p->threads[i].trapframe = 0;
    800024e0:	1c04b823          	sd	zero,464(s1)
      freethread(&p->threads[i]);
    800024e4:	1c848513          	addi	a0,s1,456
    800024e8:	bedff0ef          	jal	800020d4 <freethread>
    t->id = p->pid;
    800024ec:	589c                	lw	a5,48(s1)
    800024ee:	16f4ac23          	sw	a5,376(s1)
    if ((t->trapframe = (struct trapframe *)kalloc()) == 0) {
    800024f2:	e32fe0ef          	jal	80000b24 <kalloc>
    800024f6:	892a                	mv	s2,a0
    800024f8:	16a4b823          	sd	a0,368(s1)
    800024fc:	c901                	beqz	a0,8000250c <initthread+0x7a>
    t->state = THREAD_RUNNING;
    800024fe:	4789                	li	a5,2
    80002500:	16f4a423          	sw	a5,360(s1)
    p->current_thread = t;
    80002504:	1f34b423          	sd	s3,488(s1)
    80002508:	69a2                	ld	s3,8(sp)
    8000250a:	bf71                	j	800024a6 <initthread+0x14>
      freethread(t);
    8000250c:	854e                	mv	a0,s3
    8000250e:	bc7ff0ef          	jal	800020d4 <freethread>
      return 0;
    80002512:	69a2                	ld	s3,8(sp)
    80002514:	bf59                	j	800024aa <initthread+0x18>

0000000080002516 <allocthread>:
struct thread *allocthread(uint64 start_thread, uint64 stack_address, uint64 arg) {
    80002516:	7139                	addi	sp,sp,-64
    80002518:	fc06                	sd	ra,56(sp)
    8000251a:	f822                	sd	s0,48(sp)
    8000251c:	f426                	sd	s1,40(sp)
    8000251e:	f04a                	sd	s2,32(sp)
    80002520:	e852                	sd	s4,16(sp)
    80002522:	e456                	sd	s5,8(sp)
    80002524:	e05a                	sd	s6,0(sp)
    80002526:	0080                	addi	s0,sp,64
    80002528:	8a2a                	mv	s4,a0
    8000252a:	8b2e                	mv	s6,a1
    8000252c:	8ab2                	mv	s5,a2
  struct proc *p = myproc();
    8000252e:	baaff0ef          	jal	800018d8 <myproc>
    80002532:	892a                	mv	s2,a0
  if (!initthread(p))
    80002534:	f5fff0ef          	jal	80002492 <initthread>
    80002538:	84aa                	mv	s1,a0
    8000253a:	cd11                	beqz	a0,80002556 <allocthread+0x40>
  for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {
    8000253c:	16890493          	addi	s1,s2,360
    80002540:	1e890713          	addi	a4,s2,488
    80002544:	08e4f563          	bgeu	s1,a4,800025ce <allocthread+0xb8>
    if (t->state == THREAD_UNUSED) {
    80002548:	409c                	lw	a5,0(s1)
    8000254a:	c385                	beqz	a5,8000256a <allocthread+0x54>
  for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {
    8000254c:	02048493          	addi	s1,s1,32
    80002550:	fee49ce3          	bne	s1,a4,80002548 <allocthread+0x32>
  return 0;
    80002554:	4481                	li	s1,0
}
    80002556:	8526                	mv	a0,s1
    80002558:	70e2                	ld	ra,56(sp)
    8000255a:	7442                	ld	s0,48(sp)
    8000255c:	74a2                	ld	s1,40(sp)
    8000255e:	7902                	ld	s2,32(sp)
    80002560:	6a42                	ld	s4,16(sp)
    80002562:	6aa2                	ld	s5,8(sp)
    80002564:	6b02                	ld	s6,0(sp)
    80002566:	6121                	addi	sp,sp,64
    80002568:	8082                	ret
    8000256a:	ec4e                	sd	s3,24(sp)
      t->id = allocpid();
    8000256c:	bd6ff0ef          	jal	80001942 <allocpid>
    80002570:	c888                	sw	a0,16(s1)
      if ((t->trapframe = (struct trapframe *)kalloc()) == 0) {
    80002572:	db2fe0ef          	jal	80000b24 <kalloc>
    80002576:	89aa                	mv	s3,a0
    80002578:	e488                	sd	a0,8(s1)
    8000257a:	c521                	beqz	a0,800025c2 <allocthread+0xac>
      t->state = THREAD_RUNNABLE;
    8000257c:	4785                	li	a5,1
    8000257e:	c09c                	sw	a5,0(s1)
      *t->trapframe = *p->trapframe;
    80002580:	05893703          	ld	a4,88(s2)
    80002584:	87aa                	mv	a5,a0
    80002586:	12070813          	addi	a6,a4,288
    8000258a:	6308                	ld	a0,0(a4)
    8000258c:	670c                	ld	a1,8(a4)
    8000258e:	6b10                	ld	a2,16(a4)
    80002590:	6f14                	ld	a3,24(a4)
    80002592:	e388                	sd	a0,0(a5)
    80002594:	e78c                	sd	a1,8(a5)
    80002596:	eb90                	sd	a2,16(a5)
    80002598:	ef94                	sd	a3,24(a5)
    8000259a:	02070713          	addi	a4,a4,32
    8000259e:	02078793          	addi	a5,a5,32
    800025a2:	ff0714e3          	bne	a4,a6,8000258a <allocthread+0x74>
      t->trapframe->sp = stack_address;
    800025a6:	649c                	ld	a5,8(s1)
    800025a8:	0367b823          	sd	s6,48(a5)
      t->trapframe->a0 = arg;
    800025ac:	649c                	ld	a5,8(s1)
    800025ae:	0757b823          	sd	s5,112(a5)
      t->trapframe->ra = -1;
    800025b2:	649c                	ld	a5,8(s1)
    800025b4:	577d                	li	a4,-1
    800025b6:	f798                	sd	a4,40(a5)
      t->trapframe->epc = (uint64) start_thread;
    800025b8:	649c                	ld	a5,8(s1)
    800025ba:	0147bc23          	sd	s4,24(a5)
      return t;
    800025be:	69e2                	ld	s3,24(sp)
    800025c0:	bf59                	j	80002556 <allocthread+0x40>
        freethread(t);
    800025c2:	8526                	mv	a0,s1
    800025c4:	b11ff0ef          	jal	800020d4 <freethread>
  return 0;
    800025c8:	84ce                	mv	s1,s3
        break;
    800025ca:	69e2                	ld	s3,24(sp)
    800025cc:	b769                	j	80002556 <allocthread+0x40>
  return 0;
    800025ce:	4481                	li	s1,0
    800025d0:	b759                	j	80002556 <allocthread+0x40>

00000000800025d2 <exitthread>:

void exitthread() {
    800025d2:	1101                	addi	sp,sp,-32
    800025d4:	ec06                	sd	ra,24(sp)
    800025d6:	e822                	sd	s0,16(sp)
    800025d8:	e426                	sd	s1,8(sp)
    800025da:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800025dc:	afcff0ef          	jal	800018d8 <myproc>
    800025e0:	84aa                	mv	s1,a0
  uint id = p->current_thread->id;
  for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {
    800025e2:	16850793          	addi	a5,a0,360
    800025e6:	1e850693          	addi	a3,a0,488
    800025ea:	02d7f663          	bgeu	a5,a3,80002616 <exitthread+0x44>
  uint id = p->current_thread->id;
    800025ee:	1e853703          	ld	a4,488(a0)
    800025f2:	4b0c                	lw	a1,16(a4)
    if (t->state == THREAD_JOINED && t->join == id) {
    800025f4:	460d                	li	a2,3
    800025f6:	a029                	j	80002600 <exitthread+0x2e>
  for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {
    800025f8:	02078793          	addi	a5,a5,32
    800025fc:	00d78d63          	beq	a5,a3,80002616 <exitthread+0x44>
    if (t->state == THREAD_JOINED && t->join == id) {
    80002600:	4398                	lw	a4,0(a5)
    80002602:	fec71be3          	bne	a4,a2,800025f8 <exitthread+0x26>
    80002606:	4bd8                	lw	a4,20(a5)
    80002608:	feb718e3          	bne	a4,a1,800025f8 <exitthread+0x26>
      t->join = 0;
    8000260c:	0007aa23          	sw	zero,20(a5)
      t->state = THREAD_RUNNABLE;
    80002610:	4705                	li	a4,1
    80002612:	c398                	sw	a4,0(a5)
    80002614:	b7d5                	j	800025f8 <exitthread+0x26>
    }
  }
  freethread(p->current_thread);
    80002616:	1e84b503          	ld	a0,488(s1)
    8000261a:	abbff0ef          	jal	800020d4 <freethread>
  if (!thread_schd(p))
    8000261e:	8526                	mv	a0,s1
    80002620:	c7aff0ef          	jal	80001a9a <thread_schd>
    80002624:	c511                	beqz	a0,80002630 <exitthread+0x5e>
    setkilled(p);
}
    80002626:	60e2                	ld	ra,24(sp)
    80002628:	6442                	ld	s0,16(sp)
    8000262a:	64a2                	ld	s1,8(sp)
    8000262c:	6105                	addi	sp,sp,32
    8000262e:	8082                	ret
    setkilled(p);
    80002630:	8526                	mv	a0,s1
    80002632:	91dff0ef          	jal	80001f4e <setkilled>
}
    80002636:	bfc5                	j	80002626 <exitthread+0x54>

0000000080002638 <jointhread>:

int jointhread(uint join_id) {
    80002638:	1101                	addi	sp,sp,-32
    8000263a:	ec06                	sd	ra,24(sp)
    8000263c:	e822                	sd	s0,16(sp)
    8000263e:	e426                	sd	s1,8(sp)
    80002640:	1000                	addi	s0,sp,32
    80002642:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002644:	a94ff0ef          	jal	800018d8 <myproc>
  struct thread *t = p->current_thread;
    80002648:	1e853803          	ld	a6,488(a0)
  if (!t)
    8000264c:	04080c63          	beqz	a6,800026a4 <jointhread+0x6c>
    return -3;
  int found = 0;
  uint current_id = join_id;
    80002650:	8626                	mv	a2,s1
  int found = 0;
    80002652:	4301                	li	t1,0
  while (current_id != 0) {
    if (current_id == t->id)
      return -1; // deadlock
    uint target_id = current_id;
    current_id = 0;
    for (int i = 0; i < NTHREAD; i++) {
    80002654:	4881                	li	a7,0
    80002656:	4591                	li	a1,4
      if (p->threads[i].id == target_id) {
        current_id = p->threads[i].join;
        found = 1;
    80002658:	4e05                	li	t3,1
    8000265a:	a031                	j	80002666 <jointhread+0x2e>
        current_id = p->threads[i].join;
    8000265c:	0796                	slli	a5,a5,0x5
    8000265e:	97aa                	add	a5,a5,a0
    80002660:	17c7a603          	lw	a2,380(a5)
        found = 1;
    80002664:	8372                	mv	t1,t3
  while (current_id != 0) {
    80002666:	c205                	beqz	a2,80002686 <jointhread+0x4e>
    if (current_id == t->id)
    80002668:	01082783          	lw	a5,16(a6)
    8000266c:	02c78e63          	beq	a5,a2,800026a8 <jointhread+0x70>
    80002670:	17850713          	addi	a4,a0,376
    for (int i = 0; i < NTHREAD; i++) {
    80002674:	87c6                	mv	a5,a7
      if (p->threads[i].id == target_id) {
    80002676:	4314                	lw	a3,0(a4)
    80002678:	fec682e3          	beq	a3,a2,8000265c <jointhread+0x24>
    for (int i = 0; i < NTHREAD; i++) {
    8000267c:	2785                	addiw	a5,a5,1
    8000267e:	02070713          	addi	a4,a4,32
    80002682:	feb79ae3          	bne	a5,a1,80002676 <jointhread+0x3e>
        break;
      }
    }
  }
  if (!found)
    80002686:	02030363          	beqz	t1,800026ac <jointhread+0x74>
    return -2;

  t->join = join_id;
    8000268a:	00982a23          	sw	s1,20(a6)
  t->state = THREAD_JOINED;
    8000268e:	478d                	li	a5,3
    80002690:	00f82023          	sw	a5,0(a6)
  yield();
    80002694:	e7aff0ef          	jal	80001d0e <yield>
  return 0;
    80002698:	4501                	li	a0,0
}
    8000269a:	60e2                	ld	ra,24(sp)
    8000269c:	6442                	ld	s0,16(sp)
    8000269e:	64a2                	ld	s1,8(sp)
    800026a0:	6105                	addi	sp,sp,32
    800026a2:	8082                	ret
    return -3;
    800026a4:	5575                	li	a0,-3
    800026a6:	bfd5                	j	8000269a <jointhread+0x62>
      return -1; // deadlock
    800026a8:	557d                	li	a0,-1
    800026aa:	bfc5                	j	8000269a <jointhread+0x62>
    return -2;
    800026ac:	5579                	li	a0,-2
    800026ae:	b7f5                	j	8000269a <jointhread+0x62>

00000000800026b0 <sleepthread>:

void sleepthread(int n, uint ticks0) {
    800026b0:	1101                	addi	sp,sp,-32
    800026b2:	ec06                	sd	ra,24(sp)
    800026b4:	e822                	sd	s0,16(sp)
    800026b6:	e426                	sd	s1,8(sp)
    800026b8:	e04a                	sd	s2,0(sp)
    800026ba:	1000                	addi	s0,sp,32
    800026bc:	892a                	mv	s2,a0
    800026be:	84ae                	mv	s1,a1
  struct thread *t = myproc()->current_thread;
    800026c0:	a18ff0ef          	jal	800018d8 <myproc>
    800026c4:	1e853783          	ld	a5,488(a0)
  t->sleep_n = n;
    800026c8:	0127ac23          	sw	s2,24(a5)
  t->sleep_tick0 = ticks0;
    800026cc:	cfc4                	sw	s1,28(a5)
  t->state = THREAD_SLEEPING;
    800026ce:	4711                	li	a4,4
    800026d0:	c398                	sw	a4,0(a5)
  thread_schd(myproc());
    800026d2:	a06ff0ef          	jal	800018d8 <myproc>
    800026d6:	bc4ff0ef          	jal	80001a9a <thread_schd>
}
    800026da:	60e2                	ld	ra,24(sp)
    800026dc:	6442                	ld	s0,16(sp)
    800026de:	64a2                	ld	s1,8(sp)
    800026e0:	6902                	ld	s2,0(sp)
    800026e2:	6105                	addi	sp,sp,32
    800026e4:	8082                	ret

00000000800026e6 <swtch>:
    800026e6:	00153023          	sd	ra,0(a0)
    800026ea:	00253423          	sd	sp,8(a0)
    800026ee:	e900                	sd	s0,16(a0)
    800026f0:	ed04                	sd	s1,24(a0)
    800026f2:	03253023          	sd	s2,32(a0)
    800026f6:	03353423          	sd	s3,40(a0)
    800026fa:	03453823          	sd	s4,48(a0)
    800026fe:	03553c23          	sd	s5,56(a0)
    80002702:	05653023          	sd	s6,64(a0)
    80002706:	05753423          	sd	s7,72(a0)
    8000270a:	05853823          	sd	s8,80(a0)
    8000270e:	05953c23          	sd	s9,88(a0)
    80002712:	07a53023          	sd	s10,96(a0)
    80002716:	07b53423          	sd	s11,104(a0)
    8000271a:	0005b083          	ld	ra,0(a1)
    8000271e:	0085b103          	ld	sp,8(a1)
    80002722:	6980                	ld	s0,16(a1)
    80002724:	6d84                	ld	s1,24(a1)
    80002726:	0205b903          	ld	s2,32(a1)
    8000272a:	0285b983          	ld	s3,40(a1)
    8000272e:	0305ba03          	ld	s4,48(a1)
    80002732:	0385ba83          	ld	s5,56(a1)
    80002736:	0405bb03          	ld	s6,64(a1)
    8000273a:	0485bb83          	ld	s7,72(a1)
    8000273e:	0505bc03          	ld	s8,80(a1)
    80002742:	0585bc83          	ld	s9,88(a1)
    80002746:	0605bd03          	ld	s10,96(a1)
    8000274a:	0685bd83          	ld	s11,104(a1)
    8000274e:	8082                	ret

0000000080002750 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002750:	1141                	addi	sp,sp,-16
    80002752:	e406                	sd	ra,8(sp)
    80002754:	e022                	sd	s0,0(sp)
    80002756:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002758:	00005597          	auipc	a1,0x5
    8000275c:	b9058593          	addi	a1,a1,-1136 # 800072e8 <etext+0x2e8>
    80002760:	00015517          	auipc	a0,0x15
    80002764:	37050513          	addi	a0,a0,880 # 80017ad0 <tickslock>
    80002768:	c0cfe0ef          	jal	80000b74 <initlock>
}
    8000276c:	60a2                	ld	ra,8(sp)
    8000276e:	6402                	ld	s0,0(sp)
    80002770:	0141                	addi	sp,sp,16
    80002772:	8082                	ret

0000000080002774 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002774:	1141                	addi	sp,sp,-16
    80002776:	e422                	sd	s0,8(sp)
    80002778:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000277a:	00003797          	auipc	a5,0x3
    8000277e:	f1678793          	addi	a5,a5,-234 # 80005690 <kernelvec>
    80002782:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002786:	6422                	ld	s0,8(sp)
    80002788:	0141                	addi	sp,sp,16
    8000278a:	8082                	ret

000000008000278c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000278c:	1141                	addi	sp,sp,-16
    8000278e:	e406                	sd	ra,8(sp)
    80002790:	e022                	sd	s0,0(sp)
    80002792:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002794:	944ff0ef          	jal	800018d8 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002798:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000279c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000279e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800027a2:	00004697          	auipc	a3,0x4
    800027a6:	85e68693          	addi	a3,a3,-1954 # 80006000 <_trampoline>
    800027aa:	00004717          	auipc	a4,0x4
    800027ae:	85670713          	addi	a4,a4,-1962 # 80006000 <_trampoline>
    800027b2:	8f15                	sub	a4,a4,a3
    800027b4:	040007b7          	lui	a5,0x4000
    800027b8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800027ba:	07b2                	slli	a5,a5,0xc
    800027bc:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027be:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027c2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027c4:	18002673          	csrr	a2,satp
    800027c8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027ca:	6d30                	ld	a2,88(a0)
    800027cc:	6138                	ld	a4,64(a0)
    800027ce:	6585                	lui	a1,0x1
    800027d0:	972e                	add	a4,a4,a1
    800027d2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027d4:	6d38                	ld	a4,88(a0)
    800027d6:	00000617          	auipc	a2,0x0
    800027da:	11060613          	addi	a2,a2,272 # 800028e6 <usertrap>
    800027de:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027e0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027e2:	8612                	mv	a2,tp
    800027e4:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027e6:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027ea:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027ee:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027f2:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027f6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027f8:	6f18                	ld	a4,24(a4)
    800027fa:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027fe:	6928                	ld	a0,80(a0)
    80002800:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002802:	00004717          	auipc	a4,0x4
    80002806:	89a70713          	addi	a4,a4,-1894 # 8000609c <userret>
    8000280a:	8f15                	sub	a4,a4,a3
    8000280c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000280e:	577d                	li	a4,-1
    80002810:	177e                	slli	a4,a4,0x3f
    80002812:	8d59                	or	a0,a0,a4
    80002814:	9782                	jalr	a5
}
    80002816:	60a2                	ld	ra,8(sp)
    80002818:	6402                	ld	s0,0(sp)
    8000281a:	0141                	addi	sp,sp,16
    8000281c:	8082                	ret

000000008000281e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000281e:	1101                	addi	sp,sp,-32
    80002820:	ec06                	sd	ra,24(sp)
    80002822:	e822                	sd	s0,16(sp)
    80002824:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002826:	886ff0ef          	jal	800018ac <cpuid>
    8000282a:	cd11                	beqz	a0,80002846 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000282c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002830:	000f4737          	lui	a4,0xf4
    80002834:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002838:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000283a:	14d79073          	csrw	stimecmp,a5
}
    8000283e:	60e2                	ld	ra,24(sp)
    80002840:	6442                	ld	s0,16(sp)
    80002842:	6105                	addi	sp,sp,32
    80002844:	8082                	ret
    80002846:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002848:	00015497          	auipc	s1,0x15
    8000284c:	28848493          	addi	s1,s1,648 # 80017ad0 <tickslock>
    80002850:	8526                	mv	a0,s1
    80002852:	ba2fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002856:	00005517          	auipc	a0,0x5
    8000285a:	11a50513          	addi	a0,a0,282 # 80007970 <ticks>
    8000285e:	411c                	lw	a5,0(a0)
    80002860:	2785                	addiw	a5,a5,1
    80002862:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002864:	d22ff0ef          	jal	80001d86 <wakeup>
    release(&tickslock);
    80002868:	8526                	mv	a0,s1
    8000286a:	c22fe0ef          	jal	80000c8c <release>
    8000286e:	64a2                	ld	s1,8(sp)
    80002870:	bf75                	j	8000282c <clockintr+0xe>

0000000080002872 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002872:	1101                	addi	sp,sp,-32
    80002874:	ec06                	sd	ra,24(sp)
    80002876:	e822                	sd	s0,16(sp)
    80002878:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000287a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000287e:	57fd                	li	a5,-1
    80002880:	17fe                	slli	a5,a5,0x3f
    80002882:	07a5                	addi	a5,a5,9
    80002884:	00f70c63          	beq	a4,a5,8000289c <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002888:	57fd                	li	a5,-1
    8000288a:	17fe                	slli	a5,a5,0x3f
    8000288c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000288e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002890:	04f70763          	beq	a4,a5,800028de <devintr+0x6c>
  }
}
    80002894:	60e2                	ld	ra,24(sp)
    80002896:	6442                	ld	s0,16(sp)
    80002898:	6105                	addi	sp,sp,32
    8000289a:	8082                	ret
    8000289c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000289e:	69f020ef          	jal	8000573c <plic_claim>
    800028a2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028a4:	47a9                	li	a5,10
    800028a6:	00f50963          	beq	a0,a5,800028b8 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800028aa:	4785                	li	a5,1
    800028ac:	00f50963          	beq	a0,a5,800028be <devintr+0x4c>
    return 1;
    800028b0:	4505                	li	a0,1
    } else if(irq){
    800028b2:	e889                	bnez	s1,800028c4 <devintr+0x52>
    800028b4:	64a2                	ld	s1,8(sp)
    800028b6:	bff9                	j	80002894 <devintr+0x22>
      uartintr();
    800028b8:	94efe0ef          	jal	80000a06 <uartintr>
    if(irq)
    800028bc:	a819                	j	800028d2 <devintr+0x60>
      virtio_disk_intr();
    800028be:	344030ef          	jal	80005c02 <virtio_disk_intr>
    if(irq)
    800028c2:	a801                	j	800028d2 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800028c4:	85a6                	mv	a1,s1
    800028c6:	00005517          	auipc	a0,0x5
    800028ca:	a2a50513          	addi	a0,a0,-1494 # 800072f0 <etext+0x2f0>
    800028ce:	bf5fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800028d2:	8526                	mv	a0,s1
    800028d4:	689020ef          	jal	8000575c <plic_complete>
    return 1;
    800028d8:	4505                	li	a0,1
    800028da:	64a2                	ld	s1,8(sp)
    800028dc:	bf65                	j	80002894 <devintr+0x22>
    clockintr();
    800028de:	f41ff0ef          	jal	8000281e <clockintr>
    return 2;
    800028e2:	4509                	li	a0,2
    800028e4:	bf45                	j	80002894 <devintr+0x22>

00000000800028e6 <usertrap>:
{
    800028e6:	1101                	addi	sp,sp,-32
    800028e8:	ec06                	sd	ra,24(sp)
    800028ea:	e822                	sd	s0,16(sp)
    800028ec:	e426                	sd	s1,8(sp)
    800028ee:	e04a                	sd	s2,0(sp)
    800028f0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028f2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028f6:	1007f793          	andi	a5,a5,256
    800028fa:	e3c1                	bnez	a5,8000297a <usertrap+0x94>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028fc:	00003797          	auipc	a5,0x3
    80002900:	d9478793          	addi	a5,a5,-620 # 80005690 <kernelvec>
    80002904:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002908:	fd1fe0ef          	jal	800018d8 <myproc>
    8000290c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000290e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002910:	14102773          	csrr	a4,sepc
    80002914:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002916:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000291a:	47a1                	li	a5,8
    8000291c:	06f70563          	beq	a4,a5,80002986 <usertrap+0xa0>
  } else if((which_dev = devintr()) != 0){
    80002920:	f53ff0ef          	jal	80002872 <devintr>
    80002924:	892a                	mv	s2,a0
    80002926:	e571                	bnez	a0,800029f2 <usertrap+0x10c>
  } else if (p->current_thread && p->current_thread->id != p->pid) {
    80002928:	1e84b783          	ld	a5,488(s1)
    8000292c:	cfc1                	beqz	a5,800029c4 <usertrap+0xde>
    8000292e:	4b94                	lw	a3,16(a5)
    80002930:	5890                	lw	a2,48(s1)
    80002932:	0006079b          	sext.w	a5,a2
    80002936:	08f68763          	beq	a3,a5,800029c4 <usertrap+0xde>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000293a:	141027f3          	csrr	a5,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000293e:	14302773          	csrr	a4,stval
    if (r_sepc() != r_stval() || r_scause() != 0xc) {
    80002942:	00f71763          	bne	a4,a5,80002950 <usertrap+0x6a>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002946:	14202773          	csrr	a4,scause
    8000294a:	47b1                	li	a5,12
    8000294c:	02f70463          	beq	a4,a5,80002974 <usertrap+0x8e>
    80002950:	142025f3          	csrr	a1,scause
      printf("usertrap(): thread unexpected scause 0x%lx pid=%d tid=%d\n", r_scause(), p->pid, p->current_thread->id);
    80002954:	00005517          	auipc	a0,0x5
    80002958:	9dc50513          	addi	a0,a0,-1572 # 80007330 <etext+0x330>
    8000295c:	b67fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002960:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002964:	14302673          	csrr	a2,stval
      printf(" sepc=0x%lx stval=0x%lx\n", r_sepc(),r_stval());
    80002968:	00005517          	auipc	a0,0x5
    8000296c:	a0850513          	addi	a0,a0,-1528 # 80007370 <etext+0x370>
    80002970:	b53fd0ef          	jal	800004c2 <printf>
    exitthread();
    80002974:	c5fff0ef          	jal	800025d2 <exitthread>
    80002978:	a035                	j	800029a4 <usertrap+0xbe>
    panic("usertrap: not from user mode");
    8000297a:	00005517          	auipc	a0,0x5
    8000297e:	99650513          	addi	a0,a0,-1642 # 80007310 <etext+0x310>
    80002982:	e13fd0ef          	jal	80000794 <panic>
    if(killed(p))
    80002986:	decff0ef          	jal	80001f72 <killed>
    8000298a:	e90d                	bnez	a0,800029bc <usertrap+0xd6>
    p->trapframe->epc += 4;
    8000298c:	6cb8                	ld	a4,88(s1)
    8000298e:	6f1c                	ld	a5,24(a4)
    80002990:	0791                	addi	a5,a5,4
    80002992:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002994:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002998:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000299c:	10079073          	csrw	sstatus,a5
    syscall();
    800029a0:	29a000ef          	jal	80002c3a <syscall>
  if(killed(p))
    800029a4:	8526                	mv	a0,s1
    800029a6:	dccff0ef          	jal	80001f72 <killed>
    800029aa:	e929                	bnez	a0,800029fc <usertrap+0x116>
  usertrapret();
    800029ac:	de1ff0ef          	jal	8000278c <usertrapret>
}
    800029b0:	60e2                	ld	ra,24(sp)
    800029b2:	6442                	ld	s0,16(sp)
    800029b4:	64a2                	ld	s1,8(sp)
    800029b6:	6902                	ld	s2,0(sp)
    800029b8:	6105                	addi	sp,sp,32
    800029ba:	8082                	ret
      exit(-1);
    800029bc:	557d                	li	a0,-1
    800029be:	c88ff0ef          	jal	80001e46 <exit>
    800029c2:	b7e9                	j	8000298c <usertrap+0xa6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029c4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800029c8:	5890                	lw	a2,48(s1)
    800029ca:	00005517          	auipc	a0,0x5
    800029ce:	9c650513          	addi	a0,a0,-1594 # 80007390 <etext+0x390>
    800029d2:	af1fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029d6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029da:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800029de:	00005517          	auipc	a0,0x5
    800029e2:	9e250513          	addi	a0,a0,-1566 # 800073c0 <etext+0x3c0>
    800029e6:	addfd0ef          	jal	800004c2 <printf>
    setkilled(p);
    800029ea:	8526                	mv	a0,s1
    800029ec:	d62ff0ef          	jal	80001f4e <setkilled>
    800029f0:	bf55                	j	800029a4 <usertrap+0xbe>
  if(killed(p))
    800029f2:	8526                	mv	a0,s1
    800029f4:	d7eff0ef          	jal	80001f72 <killed>
    800029f8:	c511                	beqz	a0,80002a04 <usertrap+0x11e>
    800029fa:	a011                	j	800029fe <usertrap+0x118>
    800029fc:	4901                	li	s2,0
    exit(-1);
    800029fe:	557d                	li	a0,-1
    80002a00:	c46ff0ef          	jal	80001e46 <exit>
  if(which_dev == 2)
    80002a04:	4789                	li	a5,2
    80002a06:	faf913e3          	bne	s2,a5,800029ac <usertrap+0xc6>
    yield();
    80002a0a:	b04ff0ef          	jal	80001d0e <yield>
    80002a0e:	bf79                	j	800029ac <usertrap+0xc6>

0000000080002a10 <kerneltrap>:
{
    80002a10:	7179                	addi	sp,sp,-48
    80002a12:	f406                	sd	ra,40(sp)
    80002a14:	f022                	sd	s0,32(sp)
    80002a16:	ec26                	sd	s1,24(sp)
    80002a18:	e84a                	sd	s2,16(sp)
    80002a1a:	e44e                	sd	s3,8(sp)
    80002a1c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a1e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a22:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a26:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a2a:	1004f793          	andi	a5,s1,256
    80002a2e:	c795                	beqz	a5,80002a5a <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a30:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a34:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a36:	eb85                	bnez	a5,80002a66 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002a38:	e3bff0ef          	jal	80002872 <devintr>
    80002a3c:	c91d                	beqz	a0,80002a72 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002a3e:	4789                	li	a5,2
    80002a40:	04f50a63          	beq	a0,a5,80002a94 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a44:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a48:	10049073          	csrw	sstatus,s1
}
    80002a4c:	70a2                	ld	ra,40(sp)
    80002a4e:	7402                	ld	s0,32(sp)
    80002a50:	64e2                	ld	s1,24(sp)
    80002a52:	6942                	ld	s2,16(sp)
    80002a54:	69a2                	ld	s3,8(sp)
    80002a56:	6145                	addi	sp,sp,48
    80002a58:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a5a:	00005517          	auipc	a0,0x5
    80002a5e:	98e50513          	addi	a0,a0,-1650 # 800073e8 <etext+0x3e8>
    80002a62:	d33fd0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a66:	00005517          	auipc	a0,0x5
    80002a6a:	9aa50513          	addi	a0,a0,-1622 # 80007410 <etext+0x410>
    80002a6e:	d27fd0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a72:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a76:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002a7a:	85ce                	mv	a1,s3
    80002a7c:	00005517          	auipc	a0,0x5
    80002a80:	9b450513          	addi	a0,a0,-1612 # 80007430 <etext+0x430>
    80002a84:	a3ffd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002a88:	00005517          	auipc	a0,0x5
    80002a8c:	9d050513          	addi	a0,a0,-1584 # 80007458 <etext+0x458>
    80002a90:	d05fd0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002a94:	e45fe0ef          	jal	800018d8 <myproc>
    80002a98:	d555                	beqz	a0,80002a44 <kerneltrap+0x34>
    yield();
    80002a9a:	a74ff0ef          	jal	80001d0e <yield>
    80002a9e:	b75d                	j	80002a44 <kerneltrap+0x34>

0000000080002aa0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002aa0:	1101                	addi	sp,sp,-32
    80002aa2:	ec06                	sd	ra,24(sp)
    80002aa4:	e822                	sd	s0,16(sp)
    80002aa6:	e426                	sd	s1,8(sp)
    80002aa8:	1000                	addi	s0,sp,32
    80002aaa:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002aac:	e2dfe0ef          	jal	800018d8 <myproc>
  switch (n) {
    80002ab0:	4795                	li	a5,5
    80002ab2:	0497e163          	bltu	a5,s1,80002af4 <argraw+0x54>
    80002ab6:	048a                	slli	s1,s1,0x2
    80002ab8:	00005717          	auipc	a4,0x5
    80002abc:	d6070713          	addi	a4,a4,-672 # 80007818 <states.0+0x30>
    80002ac0:	94ba                	add	s1,s1,a4
    80002ac2:	409c                	lw	a5,0(s1)
    80002ac4:	97ba                	add	a5,a5,a4
    80002ac6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ac8:	6d3c                	ld	a5,88(a0)
    80002aca:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002acc:	60e2                	ld	ra,24(sp)
    80002ace:	6442                	ld	s0,16(sp)
    80002ad0:	64a2                	ld	s1,8(sp)
    80002ad2:	6105                	addi	sp,sp,32
    80002ad4:	8082                	ret
    return p->trapframe->a1;
    80002ad6:	6d3c                	ld	a5,88(a0)
    80002ad8:	7fa8                	ld	a0,120(a5)
    80002ada:	bfcd                	j	80002acc <argraw+0x2c>
    return p->trapframe->a2;
    80002adc:	6d3c                	ld	a5,88(a0)
    80002ade:	63c8                	ld	a0,128(a5)
    80002ae0:	b7f5                	j	80002acc <argraw+0x2c>
    return p->trapframe->a3;
    80002ae2:	6d3c                	ld	a5,88(a0)
    80002ae4:	67c8                	ld	a0,136(a5)
    80002ae6:	b7dd                	j	80002acc <argraw+0x2c>
    return p->trapframe->a4;
    80002ae8:	6d3c                	ld	a5,88(a0)
    80002aea:	6bc8                	ld	a0,144(a5)
    80002aec:	b7c5                	j	80002acc <argraw+0x2c>
    return p->trapframe->a5;
    80002aee:	6d3c                	ld	a5,88(a0)
    80002af0:	6fc8                	ld	a0,152(a5)
    80002af2:	bfe9                	j	80002acc <argraw+0x2c>
  panic("argraw");
    80002af4:	00005517          	auipc	a0,0x5
    80002af8:	97450513          	addi	a0,a0,-1676 # 80007468 <etext+0x468>
    80002afc:	c99fd0ef          	jal	80000794 <panic>

0000000080002b00 <fetchaddr>:
{
    80002b00:	1101                	addi	sp,sp,-32
    80002b02:	ec06                	sd	ra,24(sp)
    80002b04:	e822                	sd	s0,16(sp)
    80002b06:	e426                	sd	s1,8(sp)
    80002b08:	e04a                	sd	s2,0(sp)
    80002b0a:	1000                	addi	s0,sp,32
    80002b0c:	84aa                	mv	s1,a0
    80002b0e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b10:	dc9fe0ef          	jal	800018d8 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b14:	653c                	ld	a5,72(a0)
    80002b16:	02f4f663          	bgeu	s1,a5,80002b42 <fetchaddr+0x42>
    80002b1a:	00848713          	addi	a4,s1,8
    80002b1e:	02e7e463          	bltu	a5,a4,80002b46 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b22:	46a1                	li	a3,8
    80002b24:	8626                	mv	a2,s1
    80002b26:	85ca                	mv	a1,s2
    80002b28:	6928                	ld	a0,80(a0)
    80002b2a:	afffe0ef          	jal	80001628 <copyin>
    80002b2e:	00a03533          	snez	a0,a0
    80002b32:	40a00533          	neg	a0,a0
}
    80002b36:	60e2                	ld	ra,24(sp)
    80002b38:	6442                	ld	s0,16(sp)
    80002b3a:	64a2                	ld	s1,8(sp)
    80002b3c:	6902                	ld	s2,0(sp)
    80002b3e:	6105                	addi	sp,sp,32
    80002b40:	8082                	ret
    return -1;
    80002b42:	557d                	li	a0,-1
    80002b44:	bfcd                	j	80002b36 <fetchaddr+0x36>
    80002b46:	557d                	li	a0,-1
    80002b48:	b7fd                	j	80002b36 <fetchaddr+0x36>

0000000080002b4a <fetchstr>:
{
    80002b4a:	7179                	addi	sp,sp,-48
    80002b4c:	f406                	sd	ra,40(sp)
    80002b4e:	f022                	sd	s0,32(sp)
    80002b50:	ec26                	sd	s1,24(sp)
    80002b52:	e84a                	sd	s2,16(sp)
    80002b54:	e44e                	sd	s3,8(sp)
    80002b56:	1800                	addi	s0,sp,48
    80002b58:	892a                	mv	s2,a0
    80002b5a:	84ae                	mv	s1,a1
    80002b5c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b5e:	d7bfe0ef          	jal	800018d8 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b62:	86ce                	mv	a3,s3
    80002b64:	864a                	mv	a2,s2
    80002b66:	85a6                	mv	a1,s1
    80002b68:	6928                	ld	a0,80(a0)
    80002b6a:	b45fe0ef          	jal	800016ae <copyinstr>
    80002b6e:	00054c63          	bltz	a0,80002b86 <fetchstr+0x3c>
  return strlen(buf);
    80002b72:	8526                	mv	a0,s1
    80002b74:	ac4fe0ef          	jal	80000e38 <strlen>
}
    80002b78:	70a2                	ld	ra,40(sp)
    80002b7a:	7402                	ld	s0,32(sp)
    80002b7c:	64e2                	ld	s1,24(sp)
    80002b7e:	6942                	ld	s2,16(sp)
    80002b80:	69a2                	ld	s3,8(sp)
    80002b82:	6145                	addi	sp,sp,48
    80002b84:	8082                	ret
    return -1;
    80002b86:	557d                	li	a0,-1
    80002b88:	bfc5                	j	80002b78 <fetchstr+0x2e>

0000000080002b8a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b8a:	1101                	addi	sp,sp,-32
    80002b8c:	ec06                	sd	ra,24(sp)
    80002b8e:	e822                	sd	s0,16(sp)
    80002b90:	e426                	sd	s1,8(sp)
    80002b92:	1000                	addi	s0,sp,32
    80002b94:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b96:	f0bff0ef          	jal	80002aa0 <argraw>
    80002b9a:	c088                	sw	a0,0(s1)
}
    80002b9c:	60e2                	ld	ra,24(sp)
    80002b9e:	6442                	ld	s0,16(sp)
    80002ba0:	64a2                	ld	s1,8(sp)
    80002ba2:	6105                	addi	sp,sp,32
    80002ba4:	8082                	ret

0000000080002ba6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ba6:	1101                	addi	sp,sp,-32
    80002ba8:	ec06                	sd	ra,24(sp)
    80002baa:	e822                	sd	s0,16(sp)
    80002bac:	e426                	sd	s1,8(sp)
    80002bae:	1000                	addi	s0,sp,32
    80002bb0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bb2:	eefff0ef          	jal	80002aa0 <argraw>
    80002bb6:	e088                	sd	a0,0(s1)
}
    80002bb8:	60e2                	ld	ra,24(sp)
    80002bba:	6442                	ld	s0,16(sp)
    80002bbc:	64a2                	ld	s1,8(sp)
    80002bbe:	6105                	addi	sp,sp,32
    80002bc0:	8082                	ret

0000000080002bc2 <sys_thread>:
  if (oldt == newt || p->current_thread == oldt) {
    p->trapframe->a0 = ret;
  }
}

uint64 sys_thread(void) {
    80002bc2:	7179                	addi	sp,sp,-48
    80002bc4:	f406                	sd	ra,40(sp)
    80002bc6:	f022                	sd	s0,32(sp)
    80002bc8:	1800                	addi	s0,sp,48
  uint64 start_thread, stack_address, arg;
  argaddr(0, &start_thread);
    80002bca:	fe840593          	addi	a1,s0,-24
    80002bce:	4501                	li	a0,0
    80002bd0:	fd7ff0ef          	jal	80002ba6 <argaddr>
  argaddr(1, &stack_address);
    80002bd4:	fe040593          	addi	a1,s0,-32
    80002bd8:	4505                	li	a0,1
    80002bda:	fcdff0ef          	jal	80002ba6 <argaddr>
  argaddr(2, &arg);
    80002bde:	fd840593          	addi	a1,s0,-40
    80002be2:	4509                	li	a0,2
    80002be4:	fc3ff0ef          	jal	80002ba6 <argaddr>
  struct thread *t = allocthread(start_thread, stack_address, arg);
    80002be8:	fd843603          	ld	a2,-40(s0)
    80002bec:	fe043583          	ld	a1,-32(s0)
    80002bf0:	fe843503          	ld	a0,-24(s0)
    80002bf4:	923ff0ef          	jal	80002516 <allocthread>
    80002bf8:	87aa                	mv	a5,a0
  return t ? t->id : 0;
    80002bfa:	4501                	li	a0,0
    80002bfc:	c399                	beqz	a5,80002c02 <sys_thread+0x40>
    80002bfe:	0107e503          	lwu	a0,16(a5)
}
    80002c02:	70a2                	ld	ra,40(sp)
    80002c04:	7402                	ld	s0,32(sp)
    80002c06:	6145                	addi	sp,sp,48
    80002c08:	8082                	ret

0000000080002c0a <argstr>:
{
    80002c0a:	7179                	addi	sp,sp,-48
    80002c0c:	f406                	sd	ra,40(sp)
    80002c0e:	f022                	sd	s0,32(sp)
    80002c10:	ec26                	sd	s1,24(sp)
    80002c12:	e84a                	sd	s2,16(sp)
    80002c14:	1800                	addi	s0,sp,48
    80002c16:	84ae                	mv	s1,a1
    80002c18:	8932                	mv	s2,a2
  argaddr(n, &addr);
    80002c1a:	fd840593          	addi	a1,s0,-40
    80002c1e:	f89ff0ef          	jal	80002ba6 <argaddr>
  return fetchstr(addr, buf, max);
    80002c22:	864a                	mv	a2,s2
    80002c24:	85a6                	mv	a1,s1
    80002c26:	fd843503          	ld	a0,-40(s0)
    80002c2a:	f21ff0ef          	jal	80002b4a <fetchstr>
}
    80002c2e:	70a2                	ld	ra,40(sp)
    80002c30:	7402                	ld	s0,32(sp)
    80002c32:	64e2                	ld	s1,24(sp)
    80002c34:	6942                	ld	s2,16(sp)
    80002c36:	6145                	addi	sp,sp,48
    80002c38:	8082                	ret

0000000080002c3a <syscall>:
{
    80002c3a:	1101                	addi	sp,sp,-32
    80002c3c:	ec06                	sd	ra,24(sp)
    80002c3e:	e822                	sd	s0,16(sp)
    80002c40:	e426                	sd	s1,8(sp)
    80002c42:	e04a                	sd	s2,0(sp)
    80002c44:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002c46:	c93fe0ef          	jal	800018d8 <myproc>
    80002c4a:	84aa                	mv	s1,a0
  struct thread *oldt = p->current_thread;
    80002c4c:	1e853903          	ld	s2,488(a0)
  num = p->trapframe->a7;
    80002c50:	6d3c                	ld	a5,88(a0)
    80002c52:	77dc                	ld	a5,168(a5)
    80002c54:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c58:	37fd                	addiw	a5,a5,-1
    80002c5a:	4759                	li	a4,22
    80002c5c:	00f76d63          	bltu	a4,a5,80002c76 <syscall+0x3c>
    80002c60:	00369713          	slli	a4,a3,0x3
    80002c64:	00005797          	auipc	a5,0x5
    80002c68:	bcc78793          	addi	a5,a5,-1076 # 80007830 <syscalls>
    80002c6c:	97ba                	add	a5,a5,a4
    80002c6e:	639c                	ld	a5,0(a5)
    80002c70:	c399                	beqz	a5,80002c76 <syscall+0x3c>
    ret = syscalls[num]();
    80002c72:	9782                	jalr	a5
    80002c74:	a819                	j	80002c8a <syscall+0x50>
    printf("%d %s: unknown sys call %d\n",
    80002c76:	15848613          	addi	a2,s1,344
    80002c7a:	588c                	lw	a1,48(s1)
    80002c7c:	00004517          	auipc	a0,0x4
    80002c80:	7f450513          	addi	a0,a0,2036 # 80007470 <etext+0x470>
    80002c84:	83ffd0ef          	jal	800004c2 <printf>
    ret = -1;
    80002c88:	557d                	li	a0,-1
  struct thread *newt = p->current_thread;
    80002c8a:	1e84b783          	ld	a5,488(s1)
  if (oldt != newt) {
    80002c8e:	00f90b63          	beq	s2,a5,80002ca4 <syscall+0x6a>
    if (!oldt)
    80002c92:	02090163          	beqz	s2,80002cb4 <syscall+0x7a>
    oldt->trapframe->a0 = ret;
    80002c96:	00893783          	ld	a5,8(s2)
    80002c9a:	fba8                	sd	a0,112(a5)
  if (oldt == newt || p->current_thread == oldt) {
    80002c9c:	1e84b783          	ld	a5,488(s1)
    80002ca0:	01279463          	bne	a5,s2,80002ca8 <syscall+0x6e>
    p->trapframe->a0 = ret;
    80002ca4:	6cbc                	ld	a5,88(s1)
    80002ca6:	fba8                	sd	a0,112(a5)
}
    80002ca8:	60e2                	ld	ra,24(sp)
    80002caa:	6442                	ld	s0,16(sp)
    80002cac:	64a2                	ld	s1,8(sp)
    80002cae:	6902                	ld	s2,0(sp)
    80002cb0:	6105                	addi	sp,sp,32
    80002cb2:	8082                	ret
      oldt = &p->threads[0];
    80002cb4:	16848913          	addi	s2,s1,360
    oldt->trapframe->a0 = ret;
    80002cb8:	1704b703          	ld	a4,368(s1)
    80002cbc:	fb28                	sd	a0,112(a4)
  if (oldt == newt || p->current_thread == oldt) {
    80002cbe:	fd279fe3          	bne	a5,s2,80002c9c <syscall+0x62>
    80002cc2:	b7cd                	j	80002ca4 <syscall+0x6a>

0000000080002cc4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cc4:	1101                	addi	sp,sp,-32
    80002cc6:	ec06                	sd	ra,24(sp)
    80002cc8:	e822                	sd	s0,16(sp)
    80002cca:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ccc:	fec40593          	addi	a1,s0,-20
    80002cd0:	4501                	li	a0,0
    80002cd2:	eb9ff0ef          	jal	80002b8a <argint>
  exit(n);
    80002cd6:	fec42503          	lw	a0,-20(s0)
    80002cda:	96cff0ef          	jal	80001e46 <exit>
  return 0;  // not reached
}
    80002cde:	4501                	li	a0,0
    80002ce0:	60e2                	ld	ra,24(sp)
    80002ce2:	6442                	ld	s0,16(sp)
    80002ce4:	6105                	addi	sp,sp,32
    80002ce6:	8082                	ret

0000000080002ce8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ce8:	1141                	addi	sp,sp,-16
    80002cea:	e406                	sd	ra,8(sp)
    80002cec:	e022                	sd	s0,0(sp)
    80002cee:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cf0:	be9fe0ef          	jal	800018d8 <myproc>
}
    80002cf4:	5908                	lw	a0,48(a0)
    80002cf6:	60a2                	ld	ra,8(sp)
    80002cf8:	6402                	ld	s0,0(sp)
    80002cfa:	0141                	addi	sp,sp,16
    80002cfc:	8082                	ret

0000000080002cfe <sys_fork>:

uint64
sys_fork(void)
{
    80002cfe:	1141                	addi	sp,sp,-16
    80002d00:	e406                	sd	ra,8(sp)
    80002d02:	e022                	sd	s0,0(sp)
    80002d04:	0800                	addi	s0,sp,16
  return fork();
    80002d06:	d84ff0ef          	jal	8000228a <fork>
}
    80002d0a:	60a2                	ld	ra,8(sp)
    80002d0c:	6402                	ld	s0,0(sp)
    80002d0e:	0141                	addi	sp,sp,16
    80002d10:	8082                	ret

0000000080002d12 <sys_wait>:

uint64
sys_wait(void)
{
    80002d12:	1101                	addi	sp,sp,-32
    80002d14:	ec06                	sd	ra,24(sp)
    80002d16:	e822                	sd	s0,16(sp)
    80002d18:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d1a:	fe840593          	addi	a1,s0,-24
    80002d1e:	4501                	li	a0,0
    80002d20:	e87ff0ef          	jal	80002ba6 <argaddr>
  return wait(p);
    80002d24:	fe843503          	ld	a0,-24(s0)
    80002d28:	e70ff0ef          	jal	80002398 <wait>
}
    80002d2c:	60e2                	ld	ra,24(sp)
    80002d2e:	6442                	ld	s0,16(sp)
    80002d30:	6105                	addi	sp,sp,32
    80002d32:	8082                	ret

0000000080002d34 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d34:	7179                	addi	sp,sp,-48
    80002d36:	f406                	sd	ra,40(sp)
    80002d38:	f022                	sd	s0,32(sp)
    80002d3a:	ec26                	sd	s1,24(sp)
    80002d3c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d3e:	fdc40593          	addi	a1,s0,-36
    80002d42:	4501                	li	a0,0
    80002d44:	e47ff0ef          	jal	80002b8a <argint>
  addr = myproc()->sz;
    80002d48:	b91fe0ef          	jal	800018d8 <myproc>
    80002d4c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002d4e:	fdc42503          	lw	a0,-36(s0)
    80002d52:	cf9fe0ef          	jal	80001a4a <growproc>
    80002d56:	00054863          	bltz	a0,80002d66 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002d5a:	8526                	mv	a0,s1
    80002d5c:	70a2                	ld	ra,40(sp)
    80002d5e:	7402                	ld	s0,32(sp)
    80002d60:	64e2                	ld	s1,24(sp)
    80002d62:	6145                	addi	sp,sp,48
    80002d64:	8082                	ret
    return -1;
    80002d66:	54fd                	li	s1,-1
    80002d68:	bfcd                	j	80002d5a <sys_sbrk+0x26>

0000000080002d6a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d6a:	7139                	addi	sp,sp,-64
    80002d6c:	fc06                	sd	ra,56(sp)
    80002d6e:	f822                	sd	s0,48(sp)
    80002d70:	f04a                	sd	s2,32(sp)
    80002d72:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;
  argint(0, &n);
    80002d74:	fcc40593          	addi	a1,s0,-52
    80002d78:	4501                	li	a0,0
    80002d7a:	e11ff0ef          	jal	80002b8a <argint>
  if(n < 0)
    80002d7e:	fcc42783          	lw	a5,-52(s0)
    80002d82:	0607cf63          	bltz	a5,80002e00 <sys_sleep+0x96>
    n = 0;
  acquire(&tickslock);
    80002d86:	00015517          	auipc	a0,0x15
    80002d8a:	d4a50513          	addi	a0,a0,-694 # 80017ad0 <tickslock>
    80002d8e:	e67fd0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002d92:	00005917          	auipc	s2,0x5
    80002d96:	bde92903          	lw	s2,-1058(s2) # 80007970 <ticks>
  if (myproc()->current_thread) {
    80002d9a:	b3ffe0ef          	jal	800018d8 <myproc>
    80002d9e:	1e853783          	ld	a5,488(a0)
    80002da2:	e3b5                	bnez	a5,80002e06 <sys_sleep+0x9c>
    80002da4:	f426                	sd	s1,40(sp)
    80002da6:	ec4e                	sd	s3,24(sp)
    release(&tickslock);
    sleepthread(n, ticks0);
    return 0;
  }
  while(ticks - ticks0 < n){
    80002da8:	00005797          	auipc	a5,0x5
    80002dac:	bc87a783          	lw	a5,-1080(a5) # 80007970 <ticks>
    80002db0:	412787bb          	subw	a5,a5,s2
    80002db4:	fcc42703          	lw	a4,-52(s0)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002db8:	00015997          	auipc	s3,0x15
    80002dbc:	d1898993          	addi	s3,s3,-744 # 80017ad0 <tickslock>
    80002dc0:	00005497          	auipc	s1,0x5
    80002dc4:	bb048493          	addi	s1,s1,-1104 # 80007970 <ticks>
  while(ticks - ticks0 < n){
    80002dc8:	02e7f263          	bgeu	a5,a4,80002dec <sys_sleep+0x82>
    if(killed(myproc())){
    80002dcc:	b0dfe0ef          	jal	800018d8 <myproc>
    80002dd0:	9a2ff0ef          	jal	80001f72 <killed>
    80002dd4:	e931                	bnez	a0,80002e28 <sys_sleep+0xbe>
    sleep(&ticks, &tickslock);
    80002dd6:	85ce                	mv	a1,s3
    80002dd8:	8526                	mv	a0,s1
    80002dda:	f61fe0ef          	jal	80001d3a <sleep>
  while(ticks - ticks0 < n){
    80002dde:	409c                	lw	a5,0(s1)
    80002de0:	412787bb          	subw	a5,a5,s2
    80002de4:	fcc42703          	lw	a4,-52(s0)
    80002de8:	fee7e2e3          	bltu	a5,a4,80002dcc <sys_sleep+0x62>
  }
  release(&tickslock);
    80002dec:	00015517          	auipc	a0,0x15
    80002df0:	ce450513          	addi	a0,a0,-796 # 80017ad0 <tickslock>
    80002df4:	e99fd0ef          	jal	80000c8c <release>
  return 0;
    80002df8:	4501                	li	a0,0
    80002dfa:	74a2                	ld	s1,40(sp)
    80002dfc:	69e2                	ld	s3,24(sp)
    80002dfe:	a005                	j	80002e1e <sys_sleep+0xb4>
    n = 0;
    80002e00:	fc042623          	sw	zero,-52(s0)
    80002e04:	b749                	j	80002d86 <sys_sleep+0x1c>
    release(&tickslock);
    80002e06:	00015517          	auipc	a0,0x15
    80002e0a:	cca50513          	addi	a0,a0,-822 # 80017ad0 <tickslock>
    80002e0e:	e7ffd0ef          	jal	80000c8c <release>
    sleepthread(n, ticks0);
    80002e12:	85ca                	mv	a1,s2
    80002e14:	fcc42503          	lw	a0,-52(s0)
    80002e18:	899ff0ef          	jal	800026b0 <sleepthread>
    return 0;
    80002e1c:	4501                	li	a0,0
}
    80002e1e:	70e2                	ld	ra,56(sp)
    80002e20:	7442                	ld	s0,48(sp)
    80002e22:	7902                	ld	s2,32(sp)
    80002e24:	6121                	addi	sp,sp,64
    80002e26:	8082                	ret
      release(&tickslock);
    80002e28:	00015517          	auipc	a0,0x15
    80002e2c:	ca850513          	addi	a0,a0,-856 # 80017ad0 <tickslock>
    80002e30:	e5dfd0ef          	jal	80000c8c <release>
      return -1;
    80002e34:	557d                	li	a0,-1
    80002e36:	74a2                	ld	s1,40(sp)
    80002e38:	69e2                	ld	s3,24(sp)
    80002e3a:	b7d5                	j	80002e1e <sys_sleep+0xb4>

0000000080002e3c <sys_kill>:

uint64
sys_kill(void)
{
    80002e3c:	1101                	addi	sp,sp,-32
    80002e3e:	ec06                	sd	ra,24(sp)
    80002e40:	e822                	sd	s0,16(sp)
    80002e42:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e44:	fec40593          	addi	a1,s0,-20
    80002e48:	4501                	li	a0,0
    80002e4a:	d41ff0ef          	jal	80002b8a <argint>
  return kill(pid);
    80002e4e:	fec42503          	lw	a0,-20(s0)
    80002e52:	896ff0ef          	jal	80001ee8 <kill>
}
    80002e56:	60e2                	ld	ra,24(sp)
    80002e58:	6442                	ld	s0,16(sp)
    80002e5a:	6105                	addi	sp,sp,32
    80002e5c:	8082                	ret

0000000080002e5e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e5e:	1101                	addi	sp,sp,-32
    80002e60:	ec06                	sd	ra,24(sp)
    80002e62:	e822                	sd	s0,16(sp)
    80002e64:	e426                	sd	s1,8(sp)
    80002e66:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e68:	00015517          	auipc	a0,0x15
    80002e6c:	c6850513          	addi	a0,a0,-920 # 80017ad0 <tickslock>
    80002e70:	d85fd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002e74:	00005497          	auipc	s1,0x5
    80002e78:	afc4a483          	lw	s1,-1284(s1) # 80007970 <ticks>
  release(&tickslock);
    80002e7c:	00015517          	auipc	a0,0x15
    80002e80:	c5450513          	addi	a0,a0,-940 # 80017ad0 <tickslock>
    80002e84:	e09fd0ef          	jal	80000c8c <release>
  return xticks;
}
    80002e88:	02049513          	slli	a0,s1,0x20
    80002e8c:	9101                	srli	a0,a0,0x20
    80002e8e:	60e2                	ld	ra,24(sp)
    80002e90:	6442                	ld	s0,16(sp)
    80002e92:	64a2                	ld	s1,8(sp)
    80002e94:	6105                	addi	sp,sp,32
    80002e96:	8082                	ret

0000000080002e98 <sys_jointhread>:

uint64 
sys_jointhread(void) 
{
    80002e98:	1101                	addi	sp,sp,-32
    80002e9a:	ec06                	sd	ra,24(sp)
    80002e9c:	e822                	sd	s0,16(sp)
    80002e9e:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002ea0:	fec40593          	addi	a1,s0,-20
    80002ea4:	4501                	li	a0,0
    80002ea6:	ce5ff0ef          	jal	80002b8a <argint>
  return jointhread(id);
    80002eaa:	fec42503          	lw	a0,-20(s0)
    80002eae:	f8aff0ef          	jal	80002638 <jointhread>
}
    80002eb2:	60e2                	ld	ra,24(sp)
    80002eb4:	6442                	ld	s0,16(sp)
    80002eb6:	6105                	addi	sp,sp,32
    80002eb8:	8082                	ret

0000000080002eba <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002eba:	7179                	addi	sp,sp,-48
    80002ebc:	f406                	sd	ra,40(sp)
    80002ebe:	f022                	sd	s0,32(sp)
    80002ec0:	ec26                	sd	s1,24(sp)
    80002ec2:	e84a                	sd	s2,16(sp)
    80002ec4:	e44e                	sd	s3,8(sp)
    80002ec6:	e052                	sd	s4,0(sp)
    80002ec8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002eca:	00004597          	auipc	a1,0x4
    80002ece:	5c658593          	addi	a1,a1,1478 # 80007490 <etext+0x490>
    80002ed2:	00015517          	auipc	a0,0x15
    80002ed6:	c1650513          	addi	a0,a0,-1002 # 80017ae8 <bcache>
    80002eda:	c9bfd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ede:	0001d797          	auipc	a5,0x1d
    80002ee2:	c0a78793          	addi	a5,a5,-1014 # 8001fae8 <bcache+0x8000>
    80002ee6:	0001d717          	auipc	a4,0x1d
    80002eea:	e6a70713          	addi	a4,a4,-406 # 8001fd50 <bcache+0x8268>
    80002eee:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ef2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ef6:	00015497          	auipc	s1,0x15
    80002efa:	c0a48493          	addi	s1,s1,-1014 # 80017b00 <bcache+0x18>
    b->next = bcache.head.next;
    80002efe:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f00:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f02:	00004a17          	auipc	s4,0x4
    80002f06:	596a0a13          	addi	s4,s4,1430 # 80007498 <etext+0x498>
    b->next = bcache.head.next;
    80002f0a:	2b893783          	ld	a5,696(s2)
    80002f0e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f10:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f14:	85d2                	mv	a1,s4
    80002f16:	01048513          	addi	a0,s1,16
    80002f1a:	248010ef          	jal	80004162 <initsleeplock>
    bcache.head.next->prev = b;
    80002f1e:	2b893783          	ld	a5,696(s2)
    80002f22:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f24:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f28:	45848493          	addi	s1,s1,1112
    80002f2c:	fd349fe3          	bne	s1,s3,80002f0a <binit+0x50>
  }
}
    80002f30:	70a2                	ld	ra,40(sp)
    80002f32:	7402                	ld	s0,32(sp)
    80002f34:	64e2                	ld	s1,24(sp)
    80002f36:	6942                	ld	s2,16(sp)
    80002f38:	69a2                	ld	s3,8(sp)
    80002f3a:	6a02                	ld	s4,0(sp)
    80002f3c:	6145                	addi	sp,sp,48
    80002f3e:	8082                	ret

0000000080002f40 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f40:	7179                	addi	sp,sp,-48
    80002f42:	f406                	sd	ra,40(sp)
    80002f44:	f022                	sd	s0,32(sp)
    80002f46:	ec26                	sd	s1,24(sp)
    80002f48:	e84a                	sd	s2,16(sp)
    80002f4a:	e44e                	sd	s3,8(sp)
    80002f4c:	1800                	addi	s0,sp,48
    80002f4e:	892a                	mv	s2,a0
    80002f50:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f52:	00015517          	auipc	a0,0x15
    80002f56:	b9650513          	addi	a0,a0,-1130 # 80017ae8 <bcache>
    80002f5a:	c9bfd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f5e:	0001d497          	auipc	s1,0x1d
    80002f62:	e424b483          	ld	s1,-446(s1) # 8001fda0 <bcache+0x82b8>
    80002f66:	0001d797          	auipc	a5,0x1d
    80002f6a:	dea78793          	addi	a5,a5,-534 # 8001fd50 <bcache+0x8268>
    80002f6e:	02f48b63          	beq	s1,a5,80002fa4 <bread+0x64>
    80002f72:	873e                	mv	a4,a5
    80002f74:	a021                	j	80002f7c <bread+0x3c>
    80002f76:	68a4                	ld	s1,80(s1)
    80002f78:	02e48663          	beq	s1,a4,80002fa4 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002f7c:	449c                	lw	a5,8(s1)
    80002f7e:	ff279ce3          	bne	a5,s2,80002f76 <bread+0x36>
    80002f82:	44dc                	lw	a5,12(s1)
    80002f84:	ff3799e3          	bne	a5,s3,80002f76 <bread+0x36>
      b->refcnt++;
    80002f88:	40bc                	lw	a5,64(s1)
    80002f8a:	2785                	addiw	a5,a5,1
    80002f8c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f8e:	00015517          	auipc	a0,0x15
    80002f92:	b5a50513          	addi	a0,a0,-1190 # 80017ae8 <bcache>
    80002f96:	cf7fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002f9a:	01048513          	addi	a0,s1,16
    80002f9e:	1fa010ef          	jal	80004198 <acquiresleep>
      return b;
    80002fa2:	a889                	j	80002ff4 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fa4:	0001d497          	auipc	s1,0x1d
    80002fa8:	df44b483          	ld	s1,-524(s1) # 8001fd98 <bcache+0x82b0>
    80002fac:	0001d797          	auipc	a5,0x1d
    80002fb0:	da478793          	addi	a5,a5,-604 # 8001fd50 <bcache+0x8268>
    80002fb4:	00f48863          	beq	s1,a5,80002fc4 <bread+0x84>
    80002fb8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fba:	40bc                	lw	a5,64(s1)
    80002fbc:	cb91                	beqz	a5,80002fd0 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fbe:	64a4                	ld	s1,72(s1)
    80002fc0:	fee49de3          	bne	s1,a4,80002fba <bread+0x7a>
  panic("bget: no buffers");
    80002fc4:	00004517          	auipc	a0,0x4
    80002fc8:	4dc50513          	addi	a0,a0,1244 # 800074a0 <etext+0x4a0>
    80002fcc:	fc8fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002fd0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fd4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fd8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fdc:	4785                	li	a5,1
    80002fde:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fe0:	00015517          	auipc	a0,0x15
    80002fe4:	b0850513          	addi	a0,a0,-1272 # 80017ae8 <bcache>
    80002fe8:	ca5fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002fec:	01048513          	addi	a0,s1,16
    80002ff0:	1a8010ef          	jal	80004198 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ff4:	409c                	lw	a5,0(s1)
    80002ff6:	cb89                	beqz	a5,80003008 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ff8:	8526                	mv	a0,s1
    80002ffa:	70a2                	ld	ra,40(sp)
    80002ffc:	7402                	ld	s0,32(sp)
    80002ffe:	64e2                	ld	s1,24(sp)
    80003000:	6942                	ld	s2,16(sp)
    80003002:	69a2                	ld	s3,8(sp)
    80003004:	6145                	addi	sp,sp,48
    80003006:	8082                	ret
    virtio_disk_rw(b, 0);
    80003008:	4581                	li	a1,0
    8000300a:	8526                	mv	a0,s1
    8000300c:	1e5020ef          	jal	800059f0 <virtio_disk_rw>
    b->valid = 1;
    80003010:	4785                	li	a5,1
    80003012:	c09c                	sw	a5,0(s1)
  return b;
    80003014:	b7d5                	j	80002ff8 <bread+0xb8>

0000000080003016 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003016:	1101                	addi	sp,sp,-32
    80003018:	ec06                	sd	ra,24(sp)
    8000301a:	e822                	sd	s0,16(sp)
    8000301c:	e426                	sd	s1,8(sp)
    8000301e:	1000                	addi	s0,sp,32
    80003020:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003022:	0541                	addi	a0,a0,16
    80003024:	1f2010ef          	jal	80004216 <holdingsleep>
    80003028:	c911                	beqz	a0,8000303c <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000302a:	4585                	li	a1,1
    8000302c:	8526                	mv	a0,s1
    8000302e:	1c3020ef          	jal	800059f0 <virtio_disk_rw>
}
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	64a2                	ld	s1,8(sp)
    80003038:	6105                	addi	sp,sp,32
    8000303a:	8082                	ret
    panic("bwrite");
    8000303c:	00004517          	auipc	a0,0x4
    80003040:	47c50513          	addi	a0,a0,1148 # 800074b8 <etext+0x4b8>
    80003044:	f50fd0ef          	jal	80000794 <panic>

0000000080003048 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003048:	1101                	addi	sp,sp,-32
    8000304a:	ec06                	sd	ra,24(sp)
    8000304c:	e822                	sd	s0,16(sp)
    8000304e:	e426                	sd	s1,8(sp)
    80003050:	e04a                	sd	s2,0(sp)
    80003052:	1000                	addi	s0,sp,32
    80003054:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003056:	01050913          	addi	s2,a0,16
    8000305a:	854a                	mv	a0,s2
    8000305c:	1ba010ef          	jal	80004216 <holdingsleep>
    80003060:	c135                	beqz	a0,800030c4 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80003062:	854a                	mv	a0,s2
    80003064:	17a010ef          	jal	800041de <releasesleep>

  acquire(&bcache.lock);
    80003068:	00015517          	auipc	a0,0x15
    8000306c:	a8050513          	addi	a0,a0,-1408 # 80017ae8 <bcache>
    80003070:	b85fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80003074:	40bc                	lw	a5,64(s1)
    80003076:	37fd                	addiw	a5,a5,-1
    80003078:	0007871b          	sext.w	a4,a5
    8000307c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000307e:	e71d                	bnez	a4,800030ac <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003080:	68b8                	ld	a4,80(s1)
    80003082:	64bc                	ld	a5,72(s1)
    80003084:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003086:	68b8                	ld	a4,80(s1)
    80003088:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000308a:	0001d797          	auipc	a5,0x1d
    8000308e:	a5e78793          	addi	a5,a5,-1442 # 8001fae8 <bcache+0x8000>
    80003092:	2b87b703          	ld	a4,696(a5)
    80003096:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003098:	0001d717          	auipc	a4,0x1d
    8000309c:	cb870713          	addi	a4,a4,-840 # 8001fd50 <bcache+0x8268>
    800030a0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030a2:	2b87b703          	ld	a4,696(a5)
    800030a6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030a8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030ac:	00015517          	auipc	a0,0x15
    800030b0:	a3c50513          	addi	a0,a0,-1476 # 80017ae8 <bcache>
    800030b4:	bd9fd0ef          	jal	80000c8c <release>
}
    800030b8:	60e2                	ld	ra,24(sp)
    800030ba:	6442                	ld	s0,16(sp)
    800030bc:	64a2                	ld	s1,8(sp)
    800030be:	6902                	ld	s2,0(sp)
    800030c0:	6105                	addi	sp,sp,32
    800030c2:	8082                	ret
    panic("brelse");
    800030c4:	00004517          	auipc	a0,0x4
    800030c8:	3fc50513          	addi	a0,a0,1020 # 800074c0 <etext+0x4c0>
    800030cc:	ec8fd0ef          	jal	80000794 <panic>

00000000800030d0 <bpin>:

void
bpin(struct buf *b) {
    800030d0:	1101                	addi	sp,sp,-32
    800030d2:	ec06                	sd	ra,24(sp)
    800030d4:	e822                	sd	s0,16(sp)
    800030d6:	e426                	sd	s1,8(sp)
    800030d8:	1000                	addi	s0,sp,32
    800030da:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030dc:	00015517          	auipc	a0,0x15
    800030e0:	a0c50513          	addi	a0,a0,-1524 # 80017ae8 <bcache>
    800030e4:	b11fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    800030e8:	40bc                	lw	a5,64(s1)
    800030ea:	2785                	addiw	a5,a5,1
    800030ec:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030ee:	00015517          	auipc	a0,0x15
    800030f2:	9fa50513          	addi	a0,a0,-1542 # 80017ae8 <bcache>
    800030f6:	b97fd0ef          	jal	80000c8c <release>
}
    800030fa:	60e2                	ld	ra,24(sp)
    800030fc:	6442                	ld	s0,16(sp)
    800030fe:	64a2                	ld	s1,8(sp)
    80003100:	6105                	addi	sp,sp,32
    80003102:	8082                	ret

0000000080003104 <bunpin>:

void
bunpin(struct buf *b) {
    80003104:	1101                	addi	sp,sp,-32
    80003106:	ec06                	sd	ra,24(sp)
    80003108:	e822                	sd	s0,16(sp)
    8000310a:	e426                	sd	s1,8(sp)
    8000310c:	1000                	addi	s0,sp,32
    8000310e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003110:	00015517          	auipc	a0,0x15
    80003114:	9d850513          	addi	a0,a0,-1576 # 80017ae8 <bcache>
    80003118:	addfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    8000311c:	40bc                	lw	a5,64(s1)
    8000311e:	37fd                	addiw	a5,a5,-1
    80003120:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003122:	00015517          	auipc	a0,0x15
    80003126:	9c650513          	addi	a0,a0,-1594 # 80017ae8 <bcache>
    8000312a:	b63fd0ef          	jal	80000c8c <release>
}
    8000312e:	60e2                	ld	ra,24(sp)
    80003130:	6442                	ld	s0,16(sp)
    80003132:	64a2                	ld	s1,8(sp)
    80003134:	6105                	addi	sp,sp,32
    80003136:	8082                	ret

0000000080003138 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003138:	1101                	addi	sp,sp,-32
    8000313a:	ec06                	sd	ra,24(sp)
    8000313c:	e822                	sd	s0,16(sp)
    8000313e:	e426                	sd	s1,8(sp)
    80003140:	e04a                	sd	s2,0(sp)
    80003142:	1000                	addi	s0,sp,32
    80003144:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003146:	00d5d59b          	srliw	a1,a1,0xd
    8000314a:	0001d797          	auipc	a5,0x1d
    8000314e:	07a7a783          	lw	a5,122(a5) # 800201c4 <sb+0x1c>
    80003152:	9dbd                	addw	a1,a1,a5
    80003154:	dedff0ef          	jal	80002f40 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003158:	0074f713          	andi	a4,s1,7
    8000315c:	4785                	li	a5,1
    8000315e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003162:	14ce                	slli	s1,s1,0x33
    80003164:	90d9                	srli	s1,s1,0x36
    80003166:	00950733          	add	a4,a0,s1
    8000316a:	05874703          	lbu	a4,88(a4)
    8000316e:	00e7f6b3          	and	a3,a5,a4
    80003172:	c29d                	beqz	a3,80003198 <bfree+0x60>
    80003174:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003176:	94aa                	add	s1,s1,a0
    80003178:	fff7c793          	not	a5,a5
    8000317c:	8f7d                	and	a4,a4,a5
    8000317e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003182:	711000ef          	jal	80004092 <log_write>
  brelse(bp);
    80003186:	854a                	mv	a0,s2
    80003188:	ec1ff0ef          	jal	80003048 <brelse>
}
    8000318c:	60e2                	ld	ra,24(sp)
    8000318e:	6442                	ld	s0,16(sp)
    80003190:	64a2                	ld	s1,8(sp)
    80003192:	6902                	ld	s2,0(sp)
    80003194:	6105                	addi	sp,sp,32
    80003196:	8082                	ret
    panic("freeing free block");
    80003198:	00004517          	auipc	a0,0x4
    8000319c:	33050513          	addi	a0,a0,816 # 800074c8 <etext+0x4c8>
    800031a0:	df4fd0ef          	jal	80000794 <panic>

00000000800031a4 <balloc>:
{
    800031a4:	711d                	addi	sp,sp,-96
    800031a6:	ec86                	sd	ra,88(sp)
    800031a8:	e8a2                	sd	s0,80(sp)
    800031aa:	e4a6                	sd	s1,72(sp)
    800031ac:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031ae:	0001d797          	auipc	a5,0x1d
    800031b2:	ffe7a783          	lw	a5,-2(a5) # 800201ac <sb+0x4>
    800031b6:	0e078f63          	beqz	a5,800032b4 <balloc+0x110>
    800031ba:	e0ca                	sd	s2,64(sp)
    800031bc:	fc4e                	sd	s3,56(sp)
    800031be:	f852                	sd	s4,48(sp)
    800031c0:	f456                	sd	s5,40(sp)
    800031c2:	f05a                	sd	s6,32(sp)
    800031c4:	ec5e                	sd	s7,24(sp)
    800031c6:	e862                	sd	s8,16(sp)
    800031c8:	e466                	sd	s9,8(sp)
    800031ca:	8baa                	mv	s7,a0
    800031cc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031ce:	0001db17          	auipc	s6,0x1d
    800031d2:	fdab0b13          	addi	s6,s6,-38 # 800201a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031d8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031da:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031dc:	6c89                	lui	s9,0x2
    800031de:	a0b5                	j	8000324a <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031e0:	97ca                	add	a5,a5,s2
    800031e2:	8e55                	or	a2,a2,a3
    800031e4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031e8:	854a                	mv	a0,s2
    800031ea:	6a9000ef          	jal	80004092 <log_write>
        brelse(bp);
    800031ee:	854a                	mv	a0,s2
    800031f0:	e59ff0ef          	jal	80003048 <brelse>
  bp = bread(dev, bno);
    800031f4:	85a6                	mv	a1,s1
    800031f6:	855e                	mv	a0,s7
    800031f8:	d49ff0ef          	jal	80002f40 <bread>
    800031fc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031fe:	40000613          	li	a2,1024
    80003202:	4581                	li	a1,0
    80003204:	05850513          	addi	a0,a0,88
    80003208:	ac1fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    8000320c:	854a                	mv	a0,s2
    8000320e:	685000ef          	jal	80004092 <log_write>
  brelse(bp);
    80003212:	854a                	mv	a0,s2
    80003214:	e35ff0ef          	jal	80003048 <brelse>
}
    80003218:	6906                	ld	s2,64(sp)
    8000321a:	79e2                	ld	s3,56(sp)
    8000321c:	7a42                	ld	s4,48(sp)
    8000321e:	7aa2                	ld	s5,40(sp)
    80003220:	7b02                	ld	s6,32(sp)
    80003222:	6be2                	ld	s7,24(sp)
    80003224:	6c42                	ld	s8,16(sp)
    80003226:	6ca2                	ld	s9,8(sp)
}
    80003228:	8526                	mv	a0,s1
    8000322a:	60e6                	ld	ra,88(sp)
    8000322c:	6446                	ld	s0,80(sp)
    8000322e:	64a6                	ld	s1,72(sp)
    80003230:	6125                	addi	sp,sp,96
    80003232:	8082                	ret
    brelse(bp);
    80003234:	854a                	mv	a0,s2
    80003236:	e13ff0ef          	jal	80003048 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000323a:	015c87bb          	addw	a5,s9,s5
    8000323e:	00078a9b          	sext.w	s5,a5
    80003242:	004b2703          	lw	a4,4(s6)
    80003246:	04eaff63          	bgeu	s5,a4,800032a4 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    8000324a:	41fad79b          	sraiw	a5,s5,0x1f
    8000324e:	0137d79b          	srliw	a5,a5,0x13
    80003252:	015787bb          	addw	a5,a5,s5
    80003256:	40d7d79b          	sraiw	a5,a5,0xd
    8000325a:	01cb2583          	lw	a1,28(s6)
    8000325e:	9dbd                	addw	a1,a1,a5
    80003260:	855e                	mv	a0,s7
    80003262:	cdfff0ef          	jal	80002f40 <bread>
    80003266:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003268:	004b2503          	lw	a0,4(s6)
    8000326c:	000a849b          	sext.w	s1,s5
    80003270:	8762                	mv	a4,s8
    80003272:	fca4f1e3          	bgeu	s1,a0,80003234 <balloc+0x90>
      m = 1 << (bi % 8);
    80003276:	00777693          	andi	a3,a4,7
    8000327a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000327e:	41f7579b          	sraiw	a5,a4,0x1f
    80003282:	01d7d79b          	srliw	a5,a5,0x1d
    80003286:	9fb9                	addw	a5,a5,a4
    80003288:	4037d79b          	sraiw	a5,a5,0x3
    8000328c:	00f90633          	add	a2,s2,a5
    80003290:	05864603          	lbu	a2,88(a2)
    80003294:	00c6f5b3          	and	a1,a3,a2
    80003298:	d5a1                	beqz	a1,800031e0 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000329a:	2705                	addiw	a4,a4,1
    8000329c:	2485                	addiw	s1,s1,1
    8000329e:	fd471ae3          	bne	a4,s4,80003272 <balloc+0xce>
    800032a2:	bf49                	j	80003234 <balloc+0x90>
    800032a4:	6906                	ld	s2,64(sp)
    800032a6:	79e2                	ld	s3,56(sp)
    800032a8:	7a42                	ld	s4,48(sp)
    800032aa:	7aa2                	ld	s5,40(sp)
    800032ac:	7b02                	ld	s6,32(sp)
    800032ae:	6be2                	ld	s7,24(sp)
    800032b0:	6c42                	ld	s8,16(sp)
    800032b2:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800032b4:	00004517          	auipc	a0,0x4
    800032b8:	22c50513          	addi	a0,a0,556 # 800074e0 <etext+0x4e0>
    800032bc:	a06fd0ef          	jal	800004c2 <printf>
  return 0;
    800032c0:	4481                	li	s1,0
    800032c2:	b79d                	j	80003228 <balloc+0x84>

00000000800032c4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032c4:	7179                	addi	sp,sp,-48
    800032c6:	f406                	sd	ra,40(sp)
    800032c8:	f022                	sd	s0,32(sp)
    800032ca:	ec26                	sd	s1,24(sp)
    800032cc:	e84a                	sd	s2,16(sp)
    800032ce:	e44e                	sd	s3,8(sp)
    800032d0:	1800                	addi	s0,sp,48
    800032d2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032d4:	47ad                	li	a5,11
    800032d6:	02b7e663          	bltu	a5,a1,80003302 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800032da:	02059793          	slli	a5,a1,0x20
    800032de:	01e7d593          	srli	a1,a5,0x1e
    800032e2:	00b504b3          	add	s1,a0,a1
    800032e6:	0504a903          	lw	s2,80(s1)
    800032ea:	06091a63          	bnez	s2,8000335e <bmap+0x9a>
      addr = balloc(ip->dev);
    800032ee:	4108                	lw	a0,0(a0)
    800032f0:	eb5ff0ef          	jal	800031a4 <balloc>
    800032f4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032f8:	06090363          	beqz	s2,8000335e <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800032fc:	0524a823          	sw	s2,80(s1)
    80003300:	a8b9                	j	8000335e <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003302:	ff45849b          	addiw	s1,a1,-12
    80003306:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000330a:	0ff00793          	li	a5,255
    8000330e:	06e7ee63          	bltu	a5,a4,8000338a <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003312:	08052903          	lw	s2,128(a0)
    80003316:	00091d63          	bnez	s2,80003330 <bmap+0x6c>
      addr = balloc(ip->dev);
    8000331a:	4108                	lw	a0,0(a0)
    8000331c:	e89ff0ef          	jal	800031a4 <balloc>
    80003320:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003324:	02090d63          	beqz	s2,8000335e <bmap+0x9a>
    80003328:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000332a:	0929a023          	sw	s2,128(s3)
    8000332e:	a011                	j	80003332 <bmap+0x6e>
    80003330:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003332:	85ca                	mv	a1,s2
    80003334:	0009a503          	lw	a0,0(s3)
    80003338:	c09ff0ef          	jal	80002f40 <bread>
    8000333c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000333e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003342:	02049713          	slli	a4,s1,0x20
    80003346:	01e75593          	srli	a1,a4,0x1e
    8000334a:	00b784b3          	add	s1,a5,a1
    8000334e:	0004a903          	lw	s2,0(s1)
    80003352:	00090e63          	beqz	s2,8000336e <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003356:	8552                	mv	a0,s4
    80003358:	cf1ff0ef          	jal	80003048 <brelse>
    return addr;
    8000335c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000335e:	854a                	mv	a0,s2
    80003360:	70a2                	ld	ra,40(sp)
    80003362:	7402                	ld	s0,32(sp)
    80003364:	64e2                	ld	s1,24(sp)
    80003366:	6942                	ld	s2,16(sp)
    80003368:	69a2                	ld	s3,8(sp)
    8000336a:	6145                	addi	sp,sp,48
    8000336c:	8082                	ret
      addr = balloc(ip->dev);
    8000336e:	0009a503          	lw	a0,0(s3)
    80003372:	e33ff0ef          	jal	800031a4 <balloc>
    80003376:	0005091b          	sext.w	s2,a0
      if(addr){
    8000337a:	fc090ee3          	beqz	s2,80003356 <bmap+0x92>
        a[bn] = addr;
    8000337e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003382:	8552                	mv	a0,s4
    80003384:	50f000ef          	jal	80004092 <log_write>
    80003388:	b7f9                	j	80003356 <bmap+0x92>
    8000338a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000338c:	00004517          	auipc	a0,0x4
    80003390:	16c50513          	addi	a0,a0,364 # 800074f8 <etext+0x4f8>
    80003394:	c00fd0ef          	jal	80000794 <panic>

0000000080003398 <iget>:
{
    80003398:	7179                	addi	sp,sp,-48
    8000339a:	f406                	sd	ra,40(sp)
    8000339c:	f022                	sd	s0,32(sp)
    8000339e:	ec26                	sd	s1,24(sp)
    800033a0:	e84a                	sd	s2,16(sp)
    800033a2:	e44e                	sd	s3,8(sp)
    800033a4:	e052                	sd	s4,0(sp)
    800033a6:	1800                	addi	s0,sp,48
    800033a8:	89aa                	mv	s3,a0
    800033aa:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033ac:	0001d517          	auipc	a0,0x1d
    800033b0:	e1c50513          	addi	a0,a0,-484 # 800201c8 <itable>
    800033b4:	841fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    800033b8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033ba:	0001d497          	auipc	s1,0x1d
    800033be:	e2648493          	addi	s1,s1,-474 # 800201e0 <itable+0x18>
    800033c2:	0001f697          	auipc	a3,0x1f
    800033c6:	8ae68693          	addi	a3,a3,-1874 # 80021c70 <log>
    800033ca:	a039                	j	800033d8 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033cc:	02090963          	beqz	s2,800033fe <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033d0:	08848493          	addi	s1,s1,136
    800033d4:	02d48863          	beq	s1,a3,80003404 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033d8:	449c                	lw	a5,8(s1)
    800033da:	fef059e3          	blez	a5,800033cc <iget+0x34>
    800033de:	4098                	lw	a4,0(s1)
    800033e0:	ff3716e3          	bne	a4,s3,800033cc <iget+0x34>
    800033e4:	40d8                	lw	a4,4(s1)
    800033e6:	ff4713e3          	bne	a4,s4,800033cc <iget+0x34>
      ip->ref++;
    800033ea:	2785                	addiw	a5,a5,1
    800033ec:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033ee:	0001d517          	auipc	a0,0x1d
    800033f2:	dda50513          	addi	a0,a0,-550 # 800201c8 <itable>
    800033f6:	897fd0ef          	jal	80000c8c <release>
      return ip;
    800033fa:	8926                	mv	s2,s1
    800033fc:	a02d                	j	80003426 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033fe:	fbe9                	bnez	a5,800033d0 <iget+0x38>
      empty = ip;
    80003400:	8926                	mv	s2,s1
    80003402:	b7f9                	j	800033d0 <iget+0x38>
  if(empty == 0)
    80003404:	02090a63          	beqz	s2,80003438 <iget+0xa0>
  ip->dev = dev;
    80003408:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000340c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003410:	4785                	li	a5,1
    80003412:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003416:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000341a:	0001d517          	auipc	a0,0x1d
    8000341e:	dae50513          	addi	a0,a0,-594 # 800201c8 <itable>
    80003422:	86bfd0ef          	jal	80000c8c <release>
}
    80003426:	854a                	mv	a0,s2
    80003428:	70a2                	ld	ra,40(sp)
    8000342a:	7402                	ld	s0,32(sp)
    8000342c:	64e2                	ld	s1,24(sp)
    8000342e:	6942                	ld	s2,16(sp)
    80003430:	69a2                	ld	s3,8(sp)
    80003432:	6a02                	ld	s4,0(sp)
    80003434:	6145                	addi	sp,sp,48
    80003436:	8082                	ret
    panic("iget: no inodes");
    80003438:	00004517          	auipc	a0,0x4
    8000343c:	0d850513          	addi	a0,a0,216 # 80007510 <etext+0x510>
    80003440:	b54fd0ef          	jal	80000794 <panic>

0000000080003444 <fsinit>:
fsinit(int dev) {
    80003444:	7179                	addi	sp,sp,-48
    80003446:	f406                	sd	ra,40(sp)
    80003448:	f022                	sd	s0,32(sp)
    8000344a:	ec26                	sd	s1,24(sp)
    8000344c:	e84a                	sd	s2,16(sp)
    8000344e:	e44e                	sd	s3,8(sp)
    80003450:	1800                	addi	s0,sp,48
    80003452:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003454:	4585                	li	a1,1
    80003456:	aebff0ef          	jal	80002f40 <bread>
    8000345a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000345c:	0001d997          	auipc	s3,0x1d
    80003460:	d4c98993          	addi	s3,s3,-692 # 800201a8 <sb>
    80003464:	02000613          	li	a2,32
    80003468:	05850593          	addi	a1,a0,88
    8000346c:	854e                	mv	a0,s3
    8000346e:	8b7fd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80003472:	8526                	mv	a0,s1
    80003474:	bd5ff0ef          	jal	80003048 <brelse>
  if(sb.magic != FSMAGIC)
    80003478:	0009a703          	lw	a4,0(s3)
    8000347c:	102037b7          	lui	a5,0x10203
    80003480:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003484:	02f71063          	bne	a4,a5,800034a4 <fsinit+0x60>
  initlog(dev, &sb);
    80003488:	0001d597          	auipc	a1,0x1d
    8000348c:	d2058593          	addi	a1,a1,-736 # 800201a8 <sb>
    80003490:	854a                	mv	a0,s2
    80003492:	1f9000ef          	jal	80003e8a <initlog>
}
    80003496:	70a2                	ld	ra,40(sp)
    80003498:	7402                	ld	s0,32(sp)
    8000349a:	64e2                	ld	s1,24(sp)
    8000349c:	6942                	ld	s2,16(sp)
    8000349e:	69a2                	ld	s3,8(sp)
    800034a0:	6145                	addi	sp,sp,48
    800034a2:	8082                	ret
    panic("invalid file system");
    800034a4:	00004517          	auipc	a0,0x4
    800034a8:	07c50513          	addi	a0,a0,124 # 80007520 <etext+0x520>
    800034ac:	ae8fd0ef          	jal	80000794 <panic>

00000000800034b0 <iinit>:
{
    800034b0:	7179                	addi	sp,sp,-48
    800034b2:	f406                	sd	ra,40(sp)
    800034b4:	f022                	sd	s0,32(sp)
    800034b6:	ec26                	sd	s1,24(sp)
    800034b8:	e84a                	sd	s2,16(sp)
    800034ba:	e44e                	sd	s3,8(sp)
    800034bc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034be:	00004597          	auipc	a1,0x4
    800034c2:	07a58593          	addi	a1,a1,122 # 80007538 <etext+0x538>
    800034c6:	0001d517          	auipc	a0,0x1d
    800034ca:	d0250513          	addi	a0,a0,-766 # 800201c8 <itable>
    800034ce:	ea6fd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034d2:	0001d497          	auipc	s1,0x1d
    800034d6:	d1e48493          	addi	s1,s1,-738 # 800201f0 <itable+0x28>
    800034da:	0001e997          	auipc	s3,0x1e
    800034de:	7a698993          	addi	s3,s3,1958 # 80021c80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034e2:	00004917          	auipc	s2,0x4
    800034e6:	05e90913          	addi	s2,s2,94 # 80007540 <etext+0x540>
    800034ea:	85ca                	mv	a1,s2
    800034ec:	8526                	mv	a0,s1
    800034ee:	475000ef          	jal	80004162 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034f2:	08848493          	addi	s1,s1,136
    800034f6:	ff349ae3          	bne	s1,s3,800034ea <iinit+0x3a>
}
    800034fa:	70a2                	ld	ra,40(sp)
    800034fc:	7402                	ld	s0,32(sp)
    800034fe:	64e2                	ld	s1,24(sp)
    80003500:	6942                	ld	s2,16(sp)
    80003502:	69a2                	ld	s3,8(sp)
    80003504:	6145                	addi	sp,sp,48
    80003506:	8082                	ret

0000000080003508 <ialloc>:
{
    80003508:	7139                	addi	sp,sp,-64
    8000350a:	fc06                	sd	ra,56(sp)
    8000350c:	f822                	sd	s0,48(sp)
    8000350e:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003510:	0001d717          	auipc	a4,0x1d
    80003514:	ca472703          	lw	a4,-860(a4) # 800201b4 <sb+0xc>
    80003518:	4785                	li	a5,1
    8000351a:	06e7f063          	bgeu	a5,a4,8000357a <ialloc+0x72>
    8000351e:	f426                	sd	s1,40(sp)
    80003520:	f04a                	sd	s2,32(sp)
    80003522:	ec4e                	sd	s3,24(sp)
    80003524:	e852                	sd	s4,16(sp)
    80003526:	e456                	sd	s5,8(sp)
    80003528:	e05a                	sd	s6,0(sp)
    8000352a:	8aaa                	mv	s5,a0
    8000352c:	8b2e                	mv	s6,a1
    8000352e:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003530:	0001da17          	auipc	s4,0x1d
    80003534:	c78a0a13          	addi	s4,s4,-904 # 800201a8 <sb>
    80003538:	00495593          	srli	a1,s2,0x4
    8000353c:	018a2783          	lw	a5,24(s4)
    80003540:	9dbd                	addw	a1,a1,a5
    80003542:	8556                	mv	a0,s5
    80003544:	9fdff0ef          	jal	80002f40 <bread>
    80003548:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000354a:	05850993          	addi	s3,a0,88
    8000354e:	00f97793          	andi	a5,s2,15
    80003552:	079a                	slli	a5,a5,0x6
    80003554:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003556:	00099783          	lh	a5,0(s3)
    8000355a:	cb9d                	beqz	a5,80003590 <ialloc+0x88>
    brelse(bp);
    8000355c:	aedff0ef          	jal	80003048 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003560:	0905                	addi	s2,s2,1
    80003562:	00ca2703          	lw	a4,12(s4)
    80003566:	0009079b          	sext.w	a5,s2
    8000356a:	fce7e7e3          	bltu	a5,a4,80003538 <ialloc+0x30>
    8000356e:	74a2                	ld	s1,40(sp)
    80003570:	7902                	ld	s2,32(sp)
    80003572:	69e2                	ld	s3,24(sp)
    80003574:	6a42                	ld	s4,16(sp)
    80003576:	6aa2                	ld	s5,8(sp)
    80003578:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000357a:	00004517          	auipc	a0,0x4
    8000357e:	fce50513          	addi	a0,a0,-50 # 80007548 <etext+0x548>
    80003582:	f41fc0ef          	jal	800004c2 <printf>
  return 0;
    80003586:	4501                	li	a0,0
}
    80003588:	70e2                	ld	ra,56(sp)
    8000358a:	7442                	ld	s0,48(sp)
    8000358c:	6121                	addi	sp,sp,64
    8000358e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003590:	04000613          	li	a2,64
    80003594:	4581                	li	a1,0
    80003596:	854e                	mv	a0,s3
    80003598:	f30fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    8000359c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035a0:	8526                	mv	a0,s1
    800035a2:	2f1000ef          	jal	80004092 <log_write>
      brelse(bp);
    800035a6:	8526                	mv	a0,s1
    800035a8:	aa1ff0ef          	jal	80003048 <brelse>
      return iget(dev, inum);
    800035ac:	0009059b          	sext.w	a1,s2
    800035b0:	8556                	mv	a0,s5
    800035b2:	de7ff0ef          	jal	80003398 <iget>
    800035b6:	74a2                	ld	s1,40(sp)
    800035b8:	7902                	ld	s2,32(sp)
    800035ba:	69e2                	ld	s3,24(sp)
    800035bc:	6a42                	ld	s4,16(sp)
    800035be:	6aa2                	ld	s5,8(sp)
    800035c0:	6b02                	ld	s6,0(sp)
    800035c2:	b7d9                	j	80003588 <ialloc+0x80>

00000000800035c4 <iupdate>:
{
    800035c4:	1101                	addi	sp,sp,-32
    800035c6:	ec06                	sd	ra,24(sp)
    800035c8:	e822                	sd	s0,16(sp)
    800035ca:	e426                	sd	s1,8(sp)
    800035cc:	e04a                	sd	s2,0(sp)
    800035ce:	1000                	addi	s0,sp,32
    800035d0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035d2:	415c                	lw	a5,4(a0)
    800035d4:	0047d79b          	srliw	a5,a5,0x4
    800035d8:	0001d597          	auipc	a1,0x1d
    800035dc:	be85a583          	lw	a1,-1048(a1) # 800201c0 <sb+0x18>
    800035e0:	9dbd                	addw	a1,a1,a5
    800035e2:	4108                	lw	a0,0(a0)
    800035e4:	95dff0ef          	jal	80002f40 <bread>
    800035e8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035ea:	05850793          	addi	a5,a0,88
    800035ee:	40d8                	lw	a4,4(s1)
    800035f0:	8b3d                	andi	a4,a4,15
    800035f2:	071a                	slli	a4,a4,0x6
    800035f4:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800035f6:	04449703          	lh	a4,68(s1)
    800035fa:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800035fe:	04649703          	lh	a4,70(s1)
    80003602:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003606:	04849703          	lh	a4,72(s1)
    8000360a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000360e:	04a49703          	lh	a4,74(s1)
    80003612:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003616:	44f8                	lw	a4,76(s1)
    80003618:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000361a:	03400613          	li	a2,52
    8000361e:	05048593          	addi	a1,s1,80
    80003622:	00c78513          	addi	a0,a5,12
    80003626:	efefd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    8000362a:	854a                	mv	a0,s2
    8000362c:	267000ef          	jal	80004092 <log_write>
  brelse(bp);
    80003630:	854a                	mv	a0,s2
    80003632:	a17ff0ef          	jal	80003048 <brelse>
}
    80003636:	60e2                	ld	ra,24(sp)
    80003638:	6442                	ld	s0,16(sp)
    8000363a:	64a2                	ld	s1,8(sp)
    8000363c:	6902                	ld	s2,0(sp)
    8000363e:	6105                	addi	sp,sp,32
    80003640:	8082                	ret

0000000080003642 <idup>:
{
    80003642:	1101                	addi	sp,sp,-32
    80003644:	ec06                	sd	ra,24(sp)
    80003646:	e822                	sd	s0,16(sp)
    80003648:	e426                	sd	s1,8(sp)
    8000364a:	1000                	addi	s0,sp,32
    8000364c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000364e:	0001d517          	auipc	a0,0x1d
    80003652:	b7a50513          	addi	a0,a0,-1158 # 800201c8 <itable>
    80003656:	d9efd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    8000365a:	449c                	lw	a5,8(s1)
    8000365c:	2785                	addiw	a5,a5,1
    8000365e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003660:	0001d517          	auipc	a0,0x1d
    80003664:	b6850513          	addi	a0,a0,-1176 # 800201c8 <itable>
    80003668:	e24fd0ef          	jal	80000c8c <release>
}
    8000366c:	8526                	mv	a0,s1
    8000366e:	60e2                	ld	ra,24(sp)
    80003670:	6442                	ld	s0,16(sp)
    80003672:	64a2                	ld	s1,8(sp)
    80003674:	6105                	addi	sp,sp,32
    80003676:	8082                	ret

0000000080003678 <ilock>:
{
    80003678:	1101                	addi	sp,sp,-32
    8000367a:	ec06                	sd	ra,24(sp)
    8000367c:	e822                	sd	s0,16(sp)
    8000367e:	e426                	sd	s1,8(sp)
    80003680:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003682:	cd19                	beqz	a0,800036a0 <ilock+0x28>
    80003684:	84aa                	mv	s1,a0
    80003686:	451c                	lw	a5,8(a0)
    80003688:	00f05c63          	blez	a5,800036a0 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000368c:	0541                	addi	a0,a0,16
    8000368e:	30b000ef          	jal	80004198 <acquiresleep>
  if(ip->valid == 0){
    80003692:	40bc                	lw	a5,64(s1)
    80003694:	cf89                	beqz	a5,800036ae <ilock+0x36>
}
    80003696:	60e2                	ld	ra,24(sp)
    80003698:	6442                	ld	s0,16(sp)
    8000369a:	64a2                	ld	s1,8(sp)
    8000369c:	6105                	addi	sp,sp,32
    8000369e:	8082                	ret
    800036a0:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800036a2:	00004517          	auipc	a0,0x4
    800036a6:	ebe50513          	addi	a0,a0,-322 # 80007560 <etext+0x560>
    800036aa:	8eafd0ef          	jal	80000794 <panic>
    800036ae:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036b0:	40dc                	lw	a5,4(s1)
    800036b2:	0047d79b          	srliw	a5,a5,0x4
    800036b6:	0001d597          	auipc	a1,0x1d
    800036ba:	b0a5a583          	lw	a1,-1270(a1) # 800201c0 <sb+0x18>
    800036be:	9dbd                	addw	a1,a1,a5
    800036c0:	4088                	lw	a0,0(s1)
    800036c2:	87fff0ef          	jal	80002f40 <bread>
    800036c6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036c8:	05850593          	addi	a1,a0,88
    800036cc:	40dc                	lw	a5,4(s1)
    800036ce:	8bbd                	andi	a5,a5,15
    800036d0:	079a                	slli	a5,a5,0x6
    800036d2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036d4:	00059783          	lh	a5,0(a1)
    800036d8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036dc:	00259783          	lh	a5,2(a1)
    800036e0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036e4:	00459783          	lh	a5,4(a1)
    800036e8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036ec:	00659783          	lh	a5,6(a1)
    800036f0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036f4:	459c                	lw	a5,8(a1)
    800036f6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036f8:	03400613          	li	a2,52
    800036fc:	05b1                	addi	a1,a1,12
    800036fe:	05048513          	addi	a0,s1,80
    80003702:	e22fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003706:	854a                	mv	a0,s2
    80003708:	941ff0ef          	jal	80003048 <brelse>
    ip->valid = 1;
    8000370c:	4785                	li	a5,1
    8000370e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003710:	04449783          	lh	a5,68(s1)
    80003714:	c399                	beqz	a5,8000371a <ilock+0xa2>
    80003716:	6902                	ld	s2,0(sp)
    80003718:	bfbd                	j	80003696 <ilock+0x1e>
      panic("ilock: no type");
    8000371a:	00004517          	auipc	a0,0x4
    8000371e:	e4e50513          	addi	a0,a0,-434 # 80007568 <etext+0x568>
    80003722:	872fd0ef          	jal	80000794 <panic>

0000000080003726 <iunlock>:
{
    80003726:	1101                	addi	sp,sp,-32
    80003728:	ec06                	sd	ra,24(sp)
    8000372a:	e822                	sd	s0,16(sp)
    8000372c:	e426                	sd	s1,8(sp)
    8000372e:	e04a                	sd	s2,0(sp)
    80003730:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003732:	c505                	beqz	a0,8000375a <iunlock+0x34>
    80003734:	84aa                	mv	s1,a0
    80003736:	01050913          	addi	s2,a0,16
    8000373a:	854a                	mv	a0,s2
    8000373c:	2db000ef          	jal	80004216 <holdingsleep>
    80003740:	cd09                	beqz	a0,8000375a <iunlock+0x34>
    80003742:	449c                	lw	a5,8(s1)
    80003744:	00f05b63          	blez	a5,8000375a <iunlock+0x34>
  releasesleep(&ip->lock);
    80003748:	854a                	mv	a0,s2
    8000374a:	295000ef          	jal	800041de <releasesleep>
}
    8000374e:	60e2                	ld	ra,24(sp)
    80003750:	6442                	ld	s0,16(sp)
    80003752:	64a2                	ld	s1,8(sp)
    80003754:	6902                	ld	s2,0(sp)
    80003756:	6105                	addi	sp,sp,32
    80003758:	8082                	ret
    panic("iunlock");
    8000375a:	00004517          	auipc	a0,0x4
    8000375e:	e1e50513          	addi	a0,a0,-482 # 80007578 <etext+0x578>
    80003762:	832fd0ef          	jal	80000794 <panic>

0000000080003766 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003766:	7179                	addi	sp,sp,-48
    80003768:	f406                	sd	ra,40(sp)
    8000376a:	f022                	sd	s0,32(sp)
    8000376c:	ec26                	sd	s1,24(sp)
    8000376e:	e84a                	sd	s2,16(sp)
    80003770:	e44e                	sd	s3,8(sp)
    80003772:	1800                	addi	s0,sp,48
    80003774:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003776:	05050493          	addi	s1,a0,80
    8000377a:	08050913          	addi	s2,a0,128
    8000377e:	a021                	j	80003786 <itrunc+0x20>
    80003780:	0491                	addi	s1,s1,4
    80003782:	01248b63          	beq	s1,s2,80003798 <itrunc+0x32>
    if(ip->addrs[i]){
    80003786:	408c                	lw	a1,0(s1)
    80003788:	dde5                	beqz	a1,80003780 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000378a:	0009a503          	lw	a0,0(s3)
    8000378e:	9abff0ef          	jal	80003138 <bfree>
      ip->addrs[i] = 0;
    80003792:	0004a023          	sw	zero,0(s1)
    80003796:	b7ed                	j	80003780 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003798:	0809a583          	lw	a1,128(s3)
    8000379c:	ed89                	bnez	a1,800037b6 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000379e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037a2:	854e                	mv	a0,s3
    800037a4:	e21ff0ef          	jal	800035c4 <iupdate>
}
    800037a8:	70a2                	ld	ra,40(sp)
    800037aa:	7402                	ld	s0,32(sp)
    800037ac:	64e2                	ld	s1,24(sp)
    800037ae:	6942                	ld	s2,16(sp)
    800037b0:	69a2                	ld	s3,8(sp)
    800037b2:	6145                	addi	sp,sp,48
    800037b4:	8082                	ret
    800037b6:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037b8:	0009a503          	lw	a0,0(s3)
    800037bc:	f84ff0ef          	jal	80002f40 <bread>
    800037c0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037c2:	05850493          	addi	s1,a0,88
    800037c6:	45850913          	addi	s2,a0,1112
    800037ca:	a021                	j	800037d2 <itrunc+0x6c>
    800037cc:	0491                	addi	s1,s1,4
    800037ce:	01248963          	beq	s1,s2,800037e0 <itrunc+0x7a>
      if(a[j])
    800037d2:	408c                	lw	a1,0(s1)
    800037d4:	dde5                	beqz	a1,800037cc <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800037d6:	0009a503          	lw	a0,0(s3)
    800037da:	95fff0ef          	jal	80003138 <bfree>
    800037de:	b7fd                	j	800037cc <itrunc+0x66>
    brelse(bp);
    800037e0:	8552                	mv	a0,s4
    800037e2:	867ff0ef          	jal	80003048 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037e6:	0809a583          	lw	a1,128(s3)
    800037ea:	0009a503          	lw	a0,0(s3)
    800037ee:	94bff0ef          	jal	80003138 <bfree>
    ip->addrs[NDIRECT] = 0;
    800037f2:	0809a023          	sw	zero,128(s3)
    800037f6:	6a02                	ld	s4,0(sp)
    800037f8:	b75d                	j	8000379e <itrunc+0x38>

00000000800037fa <iput>:
{
    800037fa:	1101                	addi	sp,sp,-32
    800037fc:	ec06                	sd	ra,24(sp)
    800037fe:	e822                	sd	s0,16(sp)
    80003800:	e426                	sd	s1,8(sp)
    80003802:	1000                	addi	s0,sp,32
    80003804:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003806:	0001d517          	auipc	a0,0x1d
    8000380a:	9c250513          	addi	a0,a0,-1598 # 800201c8 <itable>
    8000380e:	be6fd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003812:	4498                	lw	a4,8(s1)
    80003814:	4785                	li	a5,1
    80003816:	02f70063          	beq	a4,a5,80003836 <iput+0x3c>
  ip->ref--;
    8000381a:	449c                	lw	a5,8(s1)
    8000381c:	37fd                	addiw	a5,a5,-1
    8000381e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003820:	0001d517          	auipc	a0,0x1d
    80003824:	9a850513          	addi	a0,a0,-1624 # 800201c8 <itable>
    80003828:	c64fd0ef          	jal	80000c8c <release>
}
    8000382c:	60e2                	ld	ra,24(sp)
    8000382e:	6442                	ld	s0,16(sp)
    80003830:	64a2                	ld	s1,8(sp)
    80003832:	6105                	addi	sp,sp,32
    80003834:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003836:	40bc                	lw	a5,64(s1)
    80003838:	d3ed                	beqz	a5,8000381a <iput+0x20>
    8000383a:	04a49783          	lh	a5,74(s1)
    8000383e:	fff1                	bnez	a5,8000381a <iput+0x20>
    80003840:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003842:	01048913          	addi	s2,s1,16
    80003846:	854a                	mv	a0,s2
    80003848:	151000ef          	jal	80004198 <acquiresleep>
    release(&itable.lock);
    8000384c:	0001d517          	auipc	a0,0x1d
    80003850:	97c50513          	addi	a0,a0,-1668 # 800201c8 <itable>
    80003854:	c38fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    80003858:	8526                	mv	a0,s1
    8000385a:	f0dff0ef          	jal	80003766 <itrunc>
    ip->type = 0;
    8000385e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003862:	8526                	mv	a0,s1
    80003864:	d61ff0ef          	jal	800035c4 <iupdate>
    ip->valid = 0;
    80003868:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000386c:	854a                	mv	a0,s2
    8000386e:	171000ef          	jal	800041de <releasesleep>
    acquire(&itable.lock);
    80003872:	0001d517          	auipc	a0,0x1d
    80003876:	95650513          	addi	a0,a0,-1706 # 800201c8 <itable>
    8000387a:	b7afd0ef          	jal	80000bf4 <acquire>
    8000387e:	6902                	ld	s2,0(sp)
    80003880:	bf69                	j	8000381a <iput+0x20>

0000000080003882 <iunlockput>:
{
    80003882:	1101                	addi	sp,sp,-32
    80003884:	ec06                	sd	ra,24(sp)
    80003886:	e822                	sd	s0,16(sp)
    80003888:	e426                	sd	s1,8(sp)
    8000388a:	1000                	addi	s0,sp,32
    8000388c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000388e:	e99ff0ef          	jal	80003726 <iunlock>
  iput(ip);
    80003892:	8526                	mv	a0,s1
    80003894:	f67ff0ef          	jal	800037fa <iput>
}
    80003898:	60e2                	ld	ra,24(sp)
    8000389a:	6442                	ld	s0,16(sp)
    8000389c:	64a2                	ld	s1,8(sp)
    8000389e:	6105                	addi	sp,sp,32
    800038a0:	8082                	ret

00000000800038a2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038a2:	1141                	addi	sp,sp,-16
    800038a4:	e422                	sd	s0,8(sp)
    800038a6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038a8:	411c                	lw	a5,0(a0)
    800038aa:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038ac:	415c                	lw	a5,4(a0)
    800038ae:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038b0:	04451783          	lh	a5,68(a0)
    800038b4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038b8:	04a51783          	lh	a5,74(a0)
    800038bc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800038c0:	04c56783          	lwu	a5,76(a0)
    800038c4:	e99c                	sd	a5,16(a1)
}
    800038c6:	6422                	ld	s0,8(sp)
    800038c8:	0141                	addi	sp,sp,16
    800038ca:	8082                	ret

00000000800038cc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038cc:	457c                	lw	a5,76(a0)
    800038ce:	0ed7eb63          	bltu	a5,a3,800039c4 <readi+0xf8>
{
    800038d2:	7159                	addi	sp,sp,-112
    800038d4:	f486                	sd	ra,104(sp)
    800038d6:	f0a2                	sd	s0,96(sp)
    800038d8:	eca6                	sd	s1,88(sp)
    800038da:	e0d2                	sd	s4,64(sp)
    800038dc:	fc56                	sd	s5,56(sp)
    800038de:	f85a                	sd	s6,48(sp)
    800038e0:	f45e                	sd	s7,40(sp)
    800038e2:	1880                	addi	s0,sp,112
    800038e4:	8b2a                	mv	s6,a0
    800038e6:	8bae                	mv	s7,a1
    800038e8:	8a32                	mv	s4,a2
    800038ea:	84b6                	mv	s1,a3
    800038ec:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800038ee:	9f35                	addw	a4,a4,a3
    return 0;
    800038f0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800038f2:	0cd76063          	bltu	a4,a3,800039b2 <readi+0xe6>
    800038f6:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800038f8:	00e7f463          	bgeu	a5,a4,80003900 <readi+0x34>
    n = ip->size - off;
    800038fc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003900:	080a8f63          	beqz	s5,8000399e <readi+0xd2>
    80003904:	e8ca                	sd	s2,80(sp)
    80003906:	f062                	sd	s8,32(sp)
    80003908:	ec66                	sd	s9,24(sp)
    8000390a:	e86a                	sd	s10,16(sp)
    8000390c:	e46e                	sd	s11,8(sp)
    8000390e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003910:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003914:	5c7d                	li	s8,-1
    80003916:	a80d                	j	80003948 <readi+0x7c>
    80003918:	020d1d93          	slli	s11,s10,0x20
    8000391c:	020ddd93          	srli	s11,s11,0x20
    80003920:	05890613          	addi	a2,s2,88
    80003924:	86ee                	mv	a3,s11
    80003926:	963a                	add	a2,a2,a4
    80003928:	85d2                	mv	a1,s4
    8000392a:	855e                	mv	a0,s7
    8000392c:	e70fe0ef          	jal	80001f9c <either_copyout>
    80003930:	05850763          	beq	a0,s8,8000397e <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003934:	854a                	mv	a0,s2
    80003936:	f12ff0ef          	jal	80003048 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000393a:	013d09bb          	addw	s3,s10,s3
    8000393e:	009d04bb          	addw	s1,s10,s1
    80003942:	9a6e                	add	s4,s4,s11
    80003944:	0559f763          	bgeu	s3,s5,80003992 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003948:	00a4d59b          	srliw	a1,s1,0xa
    8000394c:	855a                	mv	a0,s6
    8000394e:	977ff0ef          	jal	800032c4 <bmap>
    80003952:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003956:	c5b1                	beqz	a1,800039a2 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003958:	000b2503          	lw	a0,0(s6)
    8000395c:	de4ff0ef          	jal	80002f40 <bread>
    80003960:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003962:	3ff4f713          	andi	a4,s1,1023
    80003966:	40ec87bb          	subw	a5,s9,a4
    8000396a:	413a86bb          	subw	a3,s5,s3
    8000396e:	8d3e                	mv	s10,a5
    80003970:	2781                	sext.w	a5,a5
    80003972:	0006861b          	sext.w	a2,a3
    80003976:	faf671e3          	bgeu	a2,a5,80003918 <readi+0x4c>
    8000397a:	8d36                	mv	s10,a3
    8000397c:	bf71                	j	80003918 <readi+0x4c>
      brelse(bp);
    8000397e:	854a                	mv	a0,s2
    80003980:	ec8ff0ef          	jal	80003048 <brelse>
      tot = -1;
    80003984:	59fd                	li	s3,-1
      break;
    80003986:	6946                	ld	s2,80(sp)
    80003988:	7c02                	ld	s8,32(sp)
    8000398a:	6ce2                	ld	s9,24(sp)
    8000398c:	6d42                	ld	s10,16(sp)
    8000398e:	6da2                	ld	s11,8(sp)
    80003990:	a831                	j	800039ac <readi+0xe0>
    80003992:	6946                	ld	s2,80(sp)
    80003994:	7c02                	ld	s8,32(sp)
    80003996:	6ce2                	ld	s9,24(sp)
    80003998:	6d42                	ld	s10,16(sp)
    8000399a:	6da2                	ld	s11,8(sp)
    8000399c:	a801                	j	800039ac <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000399e:	89d6                	mv	s3,s5
    800039a0:	a031                	j	800039ac <readi+0xe0>
    800039a2:	6946                	ld	s2,80(sp)
    800039a4:	7c02                	ld	s8,32(sp)
    800039a6:	6ce2                	ld	s9,24(sp)
    800039a8:	6d42                	ld	s10,16(sp)
    800039aa:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800039ac:	0009851b          	sext.w	a0,s3
    800039b0:	69a6                	ld	s3,72(sp)
}
    800039b2:	70a6                	ld	ra,104(sp)
    800039b4:	7406                	ld	s0,96(sp)
    800039b6:	64e6                	ld	s1,88(sp)
    800039b8:	6a06                	ld	s4,64(sp)
    800039ba:	7ae2                	ld	s5,56(sp)
    800039bc:	7b42                	ld	s6,48(sp)
    800039be:	7ba2                	ld	s7,40(sp)
    800039c0:	6165                	addi	sp,sp,112
    800039c2:	8082                	ret
    return 0;
    800039c4:	4501                	li	a0,0
}
    800039c6:	8082                	ret

00000000800039c8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039c8:	457c                	lw	a5,76(a0)
    800039ca:	10d7e063          	bltu	a5,a3,80003aca <writei+0x102>
{
    800039ce:	7159                	addi	sp,sp,-112
    800039d0:	f486                	sd	ra,104(sp)
    800039d2:	f0a2                	sd	s0,96(sp)
    800039d4:	e8ca                	sd	s2,80(sp)
    800039d6:	e0d2                	sd	s4,64(sp)
    800039d8:	fc56                	sd	s5,56(sp)
    800039da:	f85a                	sd	s6,48(sp)
    800039dc:	f45e                	sd	s7,40(sp)
    800039de:	1880                	addi	s0,sp,112
    800039e0:	8aaa                	mv	s5,a0
    800039e2:	8bae                	mv	s7,a1
    800039e4:	8a32                	mv	s4,a2
    800039e6:	8936                	mv	s2,a3
    800039e8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039ea:	00e687bb          	addw	a5,a3,a4
    800039ee:	0ed7e063          	bltu	a5,a3,80003ace <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800039f2:	00043737          	lui	a4,0x43
    800039f6:	0cf76e63          	bltu	a4,a5,80003ad2 <writei+0x10a>
    800039fa:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039fc:	0a0b0f63          	beqz	s6,80003aba <writei+0xf2>
    80003a00:	eca6                	sd	s1,88(sp)
    80003a02:	f062                	sd	s8,32(sp)
    80003a04:	ec66                	sd	s9,24(sp)
    80003a06:	e86a                	sd	s10,16(sp)
    80003a08:	e46e                	sd	s11,8(sp)
    80003a0a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a0c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a10:	5c7d                	li	s8,-1
    80003a12:	a825                	j	80003a4a <writei+0x82>
    80003a14:	020d1d93          	slli	s11,s10,0x20
    80003a18:	020ddd93          	srli	s11,s11,0x20
    80003a1c:	05848513          	addi	a0,s1,88
    80003a20:	86ee                	mv	a3,s11
    80003a22:	8652                	mv	a2,s4
    80003a24:	85de                	mv	a1,s7
    80003a26:	953a                	add	a0,a0,a4
    80003a28:	dbefe0ef          	jal	80001fe6 <either_copyin>
    80003a2c:	05850a63          	beq	a0,s8,80003a80 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a30:	8526                	mv	a0,s1
    80003a32:	660000ef          	jal	80004092 <log_write>
    brelse(bp);
    80003a36:	8526                	mv	a0,s1
    80003a38:	e10ff0ef          	jal	80003048 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a3c:	013d09bb          	addw	s3,s10,s3
    80003a40:	012d093b          	addw	s2,s10,s2
    80003a44:	9a6e                	add	s4,s4,s11
    80003a46:	0569f063          	bgeu	s3,s6,80003a86 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003a4a:	00a9559b          	srliw	a1,s2,0xa
    80003a4e:	8556                	mv	a0,s5
    80003a50:	875ff0ef          	jal	800032c4 <bmap>
    80003a54:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a58:	c59d                	beqz	a1,80003a86 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003a5a:	000aa503          	lw	a0,0(s5)
    80003a5e:	ce2ff0ef          	jal	80002f40 <bread>
    80003a62:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a64:	3ff97713          	andi	a4,s2,1023
    80003a68:	40ec87bb          	subw	a5,s9,a4
    80003a6c:	413b06bb          	subw	a3,s6,s3
    80003a70:	8d3e                	mv	s10,a5
    80003a72:	2781                	sext.w	a5,a5
    80003a74:	0006861b          	sext.w	a2,a3
    80003a78:	f8f67ee3          	bgeu	a2,a5,80003a14 <writei+0x4c>
    80003a7c:	8d36                	mv	s10,a3
    80003a7e:	bf59                	j	80003a14 <writei+0x4c>
      brelse(bp);
    80003a80:	8526                	mv	a0,s1
    80003a82:	dc6ff0ef          	jal	80003048 <brelse>
  }

  if(off > ip->size)
    80003a86:	04caa783          	lw	a5,76(s5)
    80003a8a:	0327fa63          	bgeu	a5,s2,80003abe <writei+0xf6>
    ip->size = off;
    80003a8e:	052aa623          	sw	s2,76(s5)
    80003a92:	64e6                	ld	s1,88(sp)
    80003a94:	7c02                	ld	s8,32(sp)
    80003a96:	6ce2                	ld	s9,24(sp)
    80003a98:	6d42                	ld	s10,16(sp)
    80003a9a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a9c:	8556                	mv	a0,s5
    80003a9e:	b27ff0ef          	jal	800035c4 <iupdate>

  return tot;
    80003aa2:	0009851b          	sext.w	a0,s3
    80003aa6:	69a6                	ld	s3,72(sp)
}
    80003aa8:	70a6                	ld	ra,104(sp)
    80003aaa:	7406                	ld	s0,96(sp)
    80003aac:	6946                	ld	s2,80(sp)
    80003aae:	6a06                	ld	s4,64(sp)
    80003ab0:	7ae2                	ld	s5,56(sp)
    80003ab2:	7b42                	ld	s6,48(sp)
    80003ab4:	7ba2                	ld	s7,40(sp)
    80003ab6:	6165                	addi	sp,sp,112
    80003ab8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aba:	89da                	mv	s3,s6
    80003abc:	b7c5                	j	80003a9c <writei+0xd4>
    80003abe:	64e6                	ld	s1,88(sp)
    80003ac0:	7c02                	ld	s8,32(sp)
    80003ac2:	6ce2                	ld	s9,24(sp)
    80003ac4:	6d42                	ld	s10,16(sp)
    80003ac6:	6da2                	ld	s11,8(sp)
    80003ac8:	bfd1                	j	80003a9c <writei+0xd4>
    return -1;
    80003aca:	557d                	li	a0,-1
}
    80003acc:	8082                	ret
    return -1;
    80003ace:	557d                	li	a0,-1
    80003ad0:	bfe1                	j	80003aa8 <writei+0xe0>
    return -1;
    80003ad2:	557d                	li	a0,-1
    80003ad4:	bfd1                	j	80003aa8 <writei+0xe0>

0000000080003ad6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ad6:	1141                	addi	sp,sp,-16
    80003ad8:	e406                	sd	ra,8(sp)
    80003ada:	e022                	sd	s0,0(sp)
    80003adc:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ade:	4639                	li	a2,14
    80003ae0:	ab4fd0ef          	jal	80000d94 <strncmp>
}
    80003ae4:	60a2                	ld	ra,8(sp)
    80003ae6:	6402                	ld	s0,0(sp)
    80003ae8:	0141                	addi	sp,sp,16
    80003aea:	8082                	ret

0000000080003aec <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003aec:	7139                	addi	sp,sp,-64
    80003aee:	fc06                	sd	ra,56(sp)
    80003af0:	f822                	sd	s0,48(sp)
    80003af2:	f426                	sd	s1,40(sp)
    80003af4:	f04a                	sd	s2,32(sp)
    80003af6:	ec4e                	sd	s3,24(sp)
    80003af8:	e852                	sd	s4,16(sp)
    80003afa:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003afc:	04451703          	lh	a4,68(a0)
    80003b00:	4785                	li	a5,1
    80003b02:	00f71a63          	bne	a4,a5,80003b16 <dirlookup+0x2a>
    80003b06:	892a                	mv	s2,a0
    80003b08:	89ae                	mv	s3,a1
    80003b0a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b0c:	457c                	lw	a5,76(a0)
    80003b0e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b10:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b12:	e39d                	bnez	a5,80003b38 <dirlookup+0x4c>
    80003b14:	a095                	j	80003b78 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003b16:	00004517          	auipc	a0,0x4
    80003b1a:	a6a50513          	addi	a0,a0,-1430 # 80007580 <etext+0x580>
    80003b1e:	c77fc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    80003b22:	00004517          	auipc	a0,0x4
    80003b26:	a7650513          	addi	a0,a0,-1418 # 80007598 <etext+0x598>
    80003b2a:	c6bfc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b2e:	24c1                	addiw	s1,s1,16
    80003b30:	04c92783          	lw	a5,76(s2)
    80003b34:	04f4f163          	bgeu	s1,a5,80003b76 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b38:	4741                	li	a4,16
    80003b3a:	86a6                	mv	a3,s1
    80003b3c:	fc040613          	addi	a2,s0,-64
    80003b40:	4581                	li	a1,0
    80003b42:	854a                	mv	a0,s2
    80003b44:	d89ff0ef          	jal	800038cc <readi>
    80003b48:	47c1                	li	a5,16
    80003b4a:	fcf51ce3          	bne	a0,a5,80003b22 <dirlookup+0x36>
    if(de.inum == 0)
    80003b4e:	fc045783          	lhu	a5,-64(s0)
    80003b52:	dff1                	beqz	a5,80003b2e <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003b54:	fc240593          	addi	a1,s0,-62
    80003b58:	854e                	mv	a0,s3
    80003b5a:	f7dff0ef          	jal	80003ad6 <namecmp>
    80003b5e:	f961                	bnez	a0,80003b2e <dirlookup+0x42>
      if(poff)
    80003b60:	000a0463          	beqz	s4,80003b68 <dirlookup+0x7c>
        *poff = off;
    80003b64:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003b68:	fc045583          	lhu	a1,-64(s0)
    80003b6c:	00092503          	lw	a0,0(s2)
    80003b70:	829ff0ef          	jal	80003398 <iget>
    80003b74:	a011                	j	80003b78 <dirlookup+0x8c>
  return 0;
    80003b76:	4501                	li	a0,0
}
    80003b78:	70e2                	ld	ra,56(sp)
    80003b7a:	7442                	ld	s0,48(sp)
    80003b7c:	74a2                	ld	s1,40(sp)
    80003b7e:	7902                	ld	s2,32(sp)
    80003b80:	69e2                	ld	s3,24(sp)
    80003b82:	6a42                	ld	s4,16(sp)
    80003b84:	6121                	addi	sp,sp,64
    80003b86:	8082                	ret

0000000080003b88 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b88:	711d                	addi	sp,sp,-96
    80003b8a:	ec86                	sd	ra,88(sp)
    80003b8c:	e8a2                	sd	s0,80(sp)
    80003b8e:	e4a6                	sd	s1,72(sp)
    80003b90:	e0ca                	sd	s2,64(sp)
    80003b92:	fc4e                	sd	s3,56(sp)
    80003b94:	f852                	sd	s4,48(sp)
    80003b96:	f456                	sd	s5,40(sp)
    80003b98:	f05a                	sd	s6,32(sp)
    80003b9a:	ec5e                	sd	s7,24(sp)
    80003b9c:	e862                	sd	s8,16(sp)
    80003b9e:	e466                	sd	s9,8(sp)
    80003ba0:	1080                	addi	s0,sp,96
    80003ba2:	84aa                	mv	s1,a0
    80003ba4:	8b2e                	mv	s6,a1
    80003ba6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ba8:	00054703          	lbu	a4,0(a0)
    80003bac:	02f00793          	li	a5,47
    80003bb0:	00f70e63          	beq	a4,a5,80003bcc <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003bb4:	d25fd0ef          	jal	800018d8 <myproc>
    80003bb8:	15053503          	ld	a0,336(a0)
    80003bbc:	a87ff0ef          	jal	80003642 <idup>
    80003bc0:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003bc2:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003bc6:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003bc8:	4b85                	li	s7,1
    80003bca:	a871                	j	80003c66 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003bcc:	4585                	li	a1,1
    80003bce:	4505                	li	a0,1
    80003bd0:	fc8ff0ef          	jal	80003398 <iget>
    80003bd4:	8a2a                	mv	s4,a0
    80003bd6:	b7f5                	j	80003bc2 <namex+0x3a>
      iunlockput(ip);
    80003bd8:	8552                	mv	a0,s4
    80003bda:	ca9ff0ef          	jal	80003882 <iunlockput>
      return 0;
    80003bde:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003be0:	8552                	mv	a0,s4
    80003be2:	60e6                	ld	ra,88(sp)
    80003be4:	6446                	ld	s0,80(sp)
    80003be6:	64a6                	ld	s1,72(sp)
    80003be8:	6906                	ld	s2,64(sp)
    80003bea:	79e2                	ld	s3,56(sp)
    80003bec:	7a42                	ld	s4,48(sp)
    80003bee:	7aa2                	ld	s5,40(sp)
    80003bf0:	7b02                	ld	s6,32(sp)
    80003bf2:	6be2                	ld	s7,24(sp)
    80003bf4:	6c42                	ld	s8,16(sp)
    80003bf6:	6ca2                	ld	s9,8(sp)
    80003bf8:	6125                	addi	sp,sp,96
    80003bfa:	8082                	ret
      iunlock(ip);
    80003bfc:	8552                	mv	a0,s4
    80003bfe:	b29ff0ef          	jal	80003726 <iunlock>
      return ip;
    80003c02:	bff9                	j	80003be0 <namex+0x58>
      iunlockput(ip);
    80003c04:	8552                	mv	a0,s4
    80003c06:	c7dff0ef          	jal	80003882 <iunlockput>
      return 0;
    80003c0a:	8a4e                	mv	s4,s3
    80003c0c:	bfd1                	j	80003be0 <namex+0x58>
  len = path - s;
    80003c0e:	40998633          	sub	a2,s3,s1
    80003c12:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c16:	099c5063          	bge	s8,s9,80003c96 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003c1a:	4639                	li	a2,14
    80003c1c:	85a6                	mv	a1,s1
    80003c1e:	8556                	mv	a0,s5
    80003c20:	904fd0ef          	jal	80000d24 <memmove>
    80003c24:	84ce                	mv	s1,s3
  while(*path == '/')
    80003c26:	0004c783          	lbu	a5,0(s1)
    80003c2a:	01279763          	bne	a5,s2,80003c38 <namex+0xb0>
    path++;
    80003c2e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c30:	0004c783          	lbu	a5,0(s1)
    80003c34:	ff278de3          	beq	a5,s2,80003c2e <namex+0xa6>
    ilock(ip);
    80003c38:	8552                	mv	a0,s4
    80003c3a:	a3fff0ef          	jal	80003678 <ilock>
    if(ip->type != T_DIR){
    80003c3e:	044a1783          	lh	a5,68(s4)
    80003c42:	f9779be3          	bne	a5,s7,80003bd8 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003c46:	000b0563          	beqz	s6,80003c50 <namex+0xc8>
    80003c4a:	0004c783          	lbu	a5,0(s1)
    80003c4e:	d7dd                	beqz	a5,80003bfc <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c50:	4601                	li	a2,0
    80003c52:	85d6                	mv	a1,s5
    80003c54:	8552                	mv	a0,s4
    80003c56:	e97ff0ef          	jal	80003aec <dirlookup>
    80003c5a:	89aa                	mv	s3,a0
    80003c5c:	d545                	beqz	a0,80003c04 <namex+0x7c>
    iunlockput(ip);
    80003c5e:	8552                	mv	a0,s4
    80003c60:	c23ff0ef          	jal	80003882 <iunlockput>
    ip = next;
    80003c64:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003c66:	0004c783          	lbu	a5,0(s1)
    80003c6a:	01279763          	bne	a5,s2,80003c78 <namex+0xf0>
    path++;
    80003c6e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c70:	0004c783          	lbu	a5,0(s1)
    80003c74:	ff278de3          	beq	a5,s2,80003c6e <namex+0xe6>
  if(*path == 0)
    80003c78:	cb8d                	beqz	a5,80003caa <namex+0x122>
  while(*path != '/' && *path != 0)
    80003c7a:	0004c783          	lbu	a5,0(s1)
    80003c7e:	89a6                	mv	s3,s1
  len = path - s;
    80003c80:	4c81                	li	s9,0
    80003c82:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003c84:	01278963          	beq	a5,s2,80003c96 <namex+0x10e>
    80003c88:	d3d9                	beqz	a5,80003c0e <namex+0x86>
    path++;
    80003c8a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003c8c:	0009c783          	lbu	a5,0(s3)
    80003c90:	ff279ce3          	bne	a5,s2,80003c88 <namex+0x100>
    80003c94:	bfad                	j	80003c0e <namex+0x86>
    memmove(name, s, len);
    80003c96:	2601                	sext.w	a2,a2
    80003c98:	85a6                	mv	a1,s1
    80003c9a:	8556                	mv	a0,s5
    80003c9c:	888fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003ca0:	9cd6                	add	s9,s9,s5
    80003ca2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003ca6:	84ce                	mv	s1,s3
    80003ca8:	bfbd                	j	80003c26 <namex+0x9e>
  if(nameiparent){
    80003caa:	f20b0be3          	beqz	s6,80003be0 <namex+0x58>
    iput(ip);
    80003cae:	8552                	mv	a0,s4
    80003cb0:	b4bff0ef          	jal	800037fa <iput>
    return 0;
    80003cb4:	4a01                	li	s4,0
    80003cb6:	b72d                	j	80003be0 <namex+0x58>

0000000080003cb8 <dirlink>:
{
    80003cb8:	7139                	addi	sp,sp,-64
    80003cba:	fc06                	sd	ra,56(sp)
    80003cbc:	f822                	sd	s0,48(sp)
    80003cbe:	f04a                	sd	s2,32(sp)
    80003cc0:	ec4e                	sd	s3,24(sp)
    80003cc2:	e852                	sd	s4,16(sp)
    80003cc4:	0080                	addi	s0,sp,64
    80003cc6:	892a                	mv	s2,a0
    80003cc8:	8a2e                	mv	s4,a1
    80003cca:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ccc:	4601                	li	a2,0
    80003cce:	e1fff0ef          	jal	80003aec <dirlookup>
    80003cd2:	e535                	bnez	a0,80003d3e <dirlink+0x86>
    80003cd4:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cd6:	04c92483          	lw	s1,76(s2)
    80003cda:	c48d                	beqz	s1,80003d04 <dirlink+0x4c>
    80003cdc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cde:	4741                	li	a4,16
    80003ce0:	86a6                	mv	a3,s1
    80003ce2:	fc040613          	addi	a2,s0,-64
    80003ce6:	4581                	li	a1,0
    80003ce8:	854a                	mv	a0,s2
    80003cea:	be3ff0ef          	jal	800038cc <readi>
    80003cee:	47c1                	li	a5,16
    80003cf0:	04f51b63          	bne	a0,a5,80003d46 <dirlink+0x8e>
    if(de.inum == 0)
    80003cf4:	fc045783          	lhu	a5,-64(s0)
    80003cf8:	c791                	beqz	a5,80003d04 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cfa:	24c1                	addiw	s1,s1,16
    80003cfc:	04c92783          	lw	a5,76(s2)
    80003d00:	fcf4efe3          	bltu	s1,a5,80003cde <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003d04:	4639                	li	a2,14
    80003d06:	85d2                	mv	a1,s4
    80003d08:	fc240513          	addi	a0,s0,-62
    80003d0c:	8befd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003d10:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d14:	4741                	li	a4,16
    80003d16:	86a6                	mv	a3,s1
    80003d18:	fc040613          	addi	a2,s0,-64
    80003d1c:	4581                	li	a1,0
    80003d1e:	854a                	mv	a0,s2
    80003d20:	ca9ff0ef          	jal	800039c8 <writei>
    80003d24:	1541                	addi	a0,a0,-16
    80003d26:	00a03533          	snez	a0,a0
    80003d2a:	40a00533          	neg	a0,a0
    80003d2e:	74a2                	ld	s1,40(sp)
}
    80003d30:	70e2                	ld	ra,56(sp)
    80003d32:	7442                	ld	s0,48(sp)
    80003d34:	7902                	ld	s2,32(sp)
    80003d36:	69e2                	ld	s3,24(sp)
    80003d38:	6a42                	ld	s4,16(sp)
    80003d3a:	6121                	addi	sp,sp,64
    80003d3c:	8082                	ret
    iput(ip);
    80003d3e:	abdff0ef          	jal	800037fa <iput>
    return -1;
    80003d42:	557d                	li	a0,-1
    80003d44:	b7f5                	j	80003d30 <dirlink+0x78>
      panic("dirlink read");
    80003d46:	00004517          	auipc	a0,0x4
    80003d4a:	86250513          	addi	a0,a0,-1950 # 800075a8 <etext+0x5a8>
    80003d4e:	a47fc0ef          	jal	80000794 <panic>

0000000080003d52 <namei>:

struct inode*
namei(char *path)
{
    80003d52:	1101                	addi	sp,sp,-32
    80003d54:	ec06                	sd	ra,24(sp)
    80003d56:	e822                	sd	s0,16(sp)
    80003d58:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003d5a:	fe040613          	addi	a2,s0,-32
    80003d5e:	4581                	li	a1,0
    80003d60:	e29ff0ef          	jal	80003b88 <namex>
}
    80003d64:	60e2                	ld	ra,24(sp)
    80003d66:	6442                	ld	s0,16(sp)
    80003d68:	6105                	addi	sp,sp,32
    80003d6a:	8082                	ret

0000000080003d6c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003d6c:	1141                	addi	sp,sp,-16
    80003d6e:	e406                	sd	ra,8(sp)
    80003d70:	e022                	sd	s0,0(sp)
    80003d72:	0800                	addi	s0,sp,16
    80003d74:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003d76:	4585                	li	a1,1
    80003d78:	e11ff0ef          	jal	80003b88 <namex>
}
    80003d7c:	60a2                	ld	ra,8(sp)
    80003d7e:	6402                	ld	s0,0(sp)
    80003d80:	0141                	addi	sp,sp,16
    80003d82:	8082                	ret

0000000080003d84 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d84:	1101                	addi	sp,sp,-32
    80003d86:	ec06                	sd	ra,24(sp)
    80003d88:	e822                	sd	s0,16(sp)
    80003d8a:	e426                	sd	s1,8(sp)
    80003d8c:	e04a                	sd	s2,0(sp)
    80003d8e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d90:	0001e917          	auipc	s2,0x1e
    80003d94:	ee090913          	addi	s2,s2,-288 # 80021c70 <log>
    80003d98:	01892583          	lw	a1,24(s2)
    80003d9c:	02892503          	lw	a0,40(s2)
    80003da0:	9a0ff0ef          	jal	80002f40 <bread>
    80003da4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003da6:	02c92603          	lw	a2,44(s2)
    80003daa:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003dac:	00c05f63          	blez	a2,80003dca <write_head+0x46>
    80003db0:	0001e717          	auipc	a4,0x1e
    80003db4:	ef070713          	addi	a4,a4,-272 # 80021ca0 <log+0x30>
    80003db8:	87aa                	mv	a5,a0
    80003dba:	060a                	slli	a2,a2,0x2
    80003dbc:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003dbe:	4314                	lw	a3,0(a4)
    80003dc0:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003dc2:	0711                	addi	a4,a4,4
    80003dc4:	0791                	addi	a5,a5,4
    80003dc6:	fec79ce3          	bne	a5,a2,80003dbe <write_head+0x3a>
  }
  bwrite(buf);
    80003dca:	8526                	mv	a0,s1
    80003dcc:	a4aff0ef          	jal	80003016 <bwrite>
  brelse(buf);
    80003dd0:	8526                	mv	a0,s1
    80003dd2:	a76ff0ef          	jal	80003048 <brelse>
}
    80003dd6:	60e2                	ld	ra,24(sp)
    80003dd8:	6442                	ld	s0,16(sp)
    80003dda:	64a2                	ld	s1,8(sp)
    80003ddc:	6902                	ld	s2,0(sp)
    80003dde:	6105                	addi	sp,sp,32
    80003de0:	8082                	ret

0000000080003de2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003de2:	0001e797          	auipc	a5,0x1e
    80003de6:	eba7a783          	lw	a5,-326(a5) # 80021c9c <log+0x2c>
    80003dea:	08f05f63          	blez	a5,80003e88 <install_trans+0xa6>
{
    80003dee:	7139                	addi	sp,sp,-64
    80003df0:	fc06                	sd	ra,56(sp)
    80003df2:	f822                	sd	s0,48(sp)
    80003df4:	f426                	sd	s1,40(sp)
    80003df6:	f04a                	sd	s2,32(sp)
    80003df8:	ec4e                	sd	s3,24(sp)
    80003dfa:	e852                	sd	s4,16(sp)
    80003dfc:	e456                	sd	s5,8(sp)
    80003dfe:	e05a                	sd	s6,0(sp)
    80003e00:	0080                	addi	s0,sp,64
    80003e02:	8b2a                	mv	s6,a0
    80003e04:	0001ea97          	auipc	s5,0x1e
    80003e08:	e9ca8a93          	addi	s5,s5,-356 # 80021ca0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e0c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e0e:	0001e997          	auipc	s3,0x1e
    80003e12:	e6298993          	addi	s3,s3,-414 # 80021c70 <log>
    80003e16:	a829                	j	80003e30 <install_trans+0x4e>
    brelse(lbuf);
    80003e18:	854a                	mv	a0,s2
    80003e1a:	a2eff0ef          	jal	80003048 <brelse>
    brelse(dbuf);
    80003e1e:	8526                	mv	a0,s1
    80003e20:	a28ff0ef          	jal	80003048 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e24:	2a05                	addiw	s4,s4,1
    80003e26:	0a91                	addi	s5,s5,4
    80003e28:	02c9a783          	lw	a5,44(s3)
    80003e2c:	04fa5463          	bge	s4,a5,80003e74 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e30:	0189a583          	lw	a1,24(s3)
    80003e34:	014585bb          	addw	a1,a1,s4
    80003e38:	2585                	addiw	a1,a1,1
    80003e3a:	0289a503          	lw	a0,40(s3)
    80003e3e:	902ff0ef          	jal	80002f40 <bread>
    80003e42:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003e44:	000aa583          	lw	a1,0(s5)
    80003e48:	0289a503          	lw	a0,40(s3)
    80003e4c:	8f4ff0ef          	jal	80002f40 <bread>
    80003e50:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003e52:	40000613          	li	a2,1024
    80003e56:	05890593          	addi	a1,s2,88
    80003e5a:	05850513          	addi	a0,a0,88
    80003e5e:	ec7fc0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003e62:	8526                	mv	a0,s1
    80003e64:	9b2ff0ef          	jal	80003016 <bwrite>
    if(recovering == 0)
    80003e68:	fa0b18e3          	bnez	s6,80003e18 <install_trans+0x36>
      bunpin(dbuf);
    80003e6c:	8526                	mv	a0,s1
    80003e6e:	a96ff0ef          	jal	80003104 <bunpin>
    80003e72:	b75d                	j	80003e18 <install_trans+0x36>
}
    80003e74:	70e2                	ld	ra,56(sp)
    80003e76:	7442                	ld	s0,48(sp)
    80003e78:	74a2                	ld	s1,40(sp)
    80003e7a:	7902                	ld	s2,32(sp)
    80003e7c:	69e2                	ld	s3,24(sp)
    80003e7e:	6a42                	ld	s4,16(sp)
    80003e80:	6aa2                	ld	s5,8(sp)
    80003e82:	6b02                	ld	s6,0(sp)
    80003e84:	6121                	addi	sp,sp,64
    80003e86:	8082                	ret
    80003e88:	8082                	ret

0000000080003e8a <initlog>:
{
    80003e8a:	7179                	addi	sp,sp,-48
    80003e8c:	f406                	sd	ra,40(sp)
    80003e8e:	f022                	sd	s0,32(sp)
    80003e90:	ec26                	sd	s1,24(sp)
    80003e92:	e84a                	sd	s2,16(sp)
    80003e94:	e44e                	sd	s3,8(sp)
    80003e96:	1800                	addi	s0,sp,48
    80003e98:	892a                	mv	s2,a0
    80003e9a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e9c:	0001e497          	auipc	s1,0x1e
    80003ea0:	dd448493          	addi	s1,s1,-556 # 80021c70 <log>
    80003ea4:	00003597          	auipc	a1,0x3
    80003ea8:	71458593          	addi	a1,a1,1812 # 800075b8 <etext+0x5b8>
    80003eac:	8526                	mv	a0,s1
    80003eae:	cc7fc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003eb2:	0149a583          	lw	a1,20(s3)
    80003eb6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003eb8:	0109a783          	lw	a5,16(s3)
    80003ebc:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003ebe:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ec2:	854a                	mv	a0,s2
    80003ec4:	87cff0ef          	jal	80002f40 <bread>
  log.lh.n = lh->n;
    80003ec8:	4d30                	lw	a2,88(a0)
    80003eca:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003ecc:	00c05f63          	blez	a2,80003eea <initlog+0x60>
    80003ed0:	87aa                	mv	a5,a0
    80003ed2:	0001e717          	auipc	a4,0x1e
    80003ed6:	dce70713          	addi	a4,a4,-562 # 80021ca0 <log+0x30>
    80003eda:	060a                	slli	a2,a2,0x2
    80003edc:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003ede:	4ff4                	lw	a3,92(a5)
    80003ee0:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ee2:	0791                	addi	a5,a5,4
    80003ee4:	0711                	addi	a4,a4,4
    80003ee6:	fec79ce3          	bne	a5,a2,80003ede <initlog+0x54>
  brelse(buf);
    80003eea:	95eff0ef          	jal	80003048 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003eee:	4505                	li	a0,1
    80003ef0:	ef3ff0ef          	jal	80003de2 <install_trans>
  log.lh.n = 0;
    80003ef4:	0001e797          	auipc	a5,0x1e
    80003ef8:	da07a423          	sw	zero,-600(a5) # 80021c9c <log+0x2c>
  write_head(); // clear the log
    80003efc:	e89ff0ef          	jal	80003d84 <write_head>
}
    80003f00:	70a2                	ld	ra,40(sp)
    80003f02:	7402                	ld	s0,32(sp)
    80003f04:	64e2                	ld	s1,24(sp)
    80003f06:	6942                	ld	s2,16(sp)
    80003f08:	69a2                	ld	s3,8(sp)
    80003f0a:	6145                	addi	sp,sp,48
    80003f0c:	8082                	ret

0000000080003f0e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003f0e:	1101                	addi	sp,sp,-32
    80003f10:	ec06                	sd	ra,24(sp)
    80003f12:	e822                	sd	s0,16(sp)
    80003f14:	e426                	sd	s1,8(sp)
    80003f16:	e04a                	sd	s2,0(sp)
    80003f18:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f1a:	0001e517          	auipc	a0,0x1e
    80003f1e:	d5650513          	addi	a0,a0,-682 # 80021c70 <log>
    80003f22:	cd3fc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003f26:	0001e497          	auipc	s1,0x1e
    80003f2a:	d4a48493          	addi	s1,s1,-694 # 80021c70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f2e:	4979                	li	s2,30
    80003f30:	a029                	j	80003f3a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003f32:	85a6                	mv	a1,s1
    80003f34:	8526                	mv	a0,s1
    80003f36:	e05fd0ef          	jal	80001d3a <sleep>
    if(log.committing){
    80003f3a:	50dc                	lw	a5,36(s1)
    80003f3c:	fbfd                	bnez	a5,80003f32 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f3e:	5098                	lw	a4,32(s1)
    80003f40:	2705                	addiw	a4,a4,1
    80003f42:	0027179b          	slliw	a5,a4,0x2
    80003f46:	9fb9                	addw	a5,a5,a4
    80003f48:	0017979b          	slliw	a5,a5,0x1
    80003f4c:	54d4                	lw	a3,44(s1)
    80003f4e:	9fb5                	addw	a5,a5,a3
    80003f50:	00f95763          	bge	s2,a5,80003f5e <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003f54:	85a6                	mv	a1,s1
    80003f56:	8526                	mv	a0,s1
    80003f58:	de3fd0ef          	jal	80001d3a <sleep>
    80003f5c:	bff9                	j	80003f3a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003f5e:	0001e517          	auipc	a0,0x1e
    80003f62:	d1250513          	addi	a0,a0,-750 # 80021c70 <log>
    80003f66:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003f68:	d25fc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003f6c:	60e2                	ld	ra,24(sp)
    80003f6e:	6442                	ld	s0,16(sp)
    80003f70:	64a2                	ld	s1,8(sp)
    80003f72:	6902                	ld	s2,0(sp)
    80003f74:	6105                	addi	sp,sp,32
    80003f76:	8082                	ret

0000000080003f78 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f78:	7139                	addi	sp,sp,-64
    80003f7a:	fc06                	sd	ra,56(sp)
    80003f7c:	f822                	sd	s0,48(sp)
    80003f7e:	f426                	sd	s1,40(sp)
    80003f80:	f04a                	sd	s2,32(sp)
    80003f82:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f84:	0001e497          	auipc	s1,0x1e
    80003f88:	cec48493          	addi	s1,s1,-788 # 80021c70 <log>
    80003f8c:	8526                	mv	a0,s1
    80003f8e:	c67fc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003f92:	509c                	lw	a5,32(s1)
    80003f94:	37fd                	addiw	a5,a5,-1
    80003f96:	0007891b          	sext.w	s2,a5
    80003f9a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003f9c:	50dc                	lw	a5,36(s1)
    80003f9e:	ef9d                	bnez	a5,80003fdc <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003fa0:	04091763          	bnez	s2,80003fee <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003fa4:	0001e497          	auipc	s1,0x1e
    80003fa8:	ccc48493          	addi	s1,s1,-820 # 80021c70 <log>
    80003fac:	4785                	li	a5,1
    80003fae:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	cdbfc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003fb6:	54dc                	lw	a5,44(s1)
    80003fb8:	04f04b63          	bgtz	a5,8000400e <end_op+0x96>
    acquire(&log.lock);
    80003fbc:	0001e497          	auipc	s1,0x1e
    80003fc0:	cb448493          	addi	s1,s1,-844 # 80021c70 <log>
    80003fc4:	8526                	mv	a0,s1
    80003fc6:	c2ffc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003fca:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003fce:	8526                	mv	a0,s1
    80003fd0:	db7fd0ef          	jal	80001d86 <wakeup>
    release(&log.lock);
    80003fd4:	8526                	mv	a0,s1
    80003fd6:	cb7fc0ef          	jal	80000c8c <release>
}
    80003fda:	a025                	j	80004002 <end_op+0x8a>
    80003fdc:	ec4e                	sd	s3,24(sp)
    80003fde:	e852                	sd	s4,16(sp)
    80003fe0:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003fe2:	00003517          	auipc	a0,0x3
    80003fe6:	5de50513          	addi	a0,a0,1502 # 800075c0 <etext+0x5c0>
    80003fea:	faafc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003fee:	0001e497          	auipc	s1,0x1e
    80003ff2:	c8248493          	addi	s1,s1,-894 # 80021c70 <log>
    80003ff6:	8526                	mv	a0,s1
    80003ff8:	d8ffd0ef          	jal	80001d86 <wakeup>
  release(&log.lock);
    80003ffc:	8526                	mv	a0,s1
    80003ffe:	c8ffc0ef          	jal	80000c8c <release>
}
    80004002:	70e2                	ld	ra,56(sp)
    80004004:	7442                	ld	s0,48(sp)
    80004006:	74a2                	ld	s1,40(sp)
    80004008:	7902                	ld	s2,32(sp)
    8000400a:	6121                	addi	sp,sp,64
    8000400c:	8082                	ret
    8000400e:	ec4e                	sd	s3,24(sp)
    80004010:	e852                	sd	s4,16(sp)
    80004012:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004014:	0001ea97          	auipc	s5,0x1e
    80004018:	c8ca8a93          	addi	s5,s5,-884 # 80021ca0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000401c:	0001ea17          	auipc	s4,0x1e
    80004020:	c54a0a13          	addi	s4,s4,-940 # 80021c70 <log>
    80004024:	018a2583          	lw	a1,24(s4)
    80004028:	012585bb          	addw	a1,a1,s2
    8000402c:	2585                	addiw	a1,a1,1
    8000402e:	028a2503          	lw	a0,40(s4)
    80004032:	f0ffe0ef          	jal	80002f40 <bread>
    80004036:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004038:	000aa583          	lw	a1,0(s5)
    8000403c:	028a2503          	lw	a0,40(s4)
    80004040:	f01fe0ef          	jal	80002f40 <bread>
    80004044:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004046:	40000613          	li	a2,1024
    8000404a:	05850593          	addi	a1,a0,88
    8000404e:	05848513          	addi	a0,s1,88
    80004052:	cd3fc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80004056:	8526                	mv	a0,s1
    80004058:	fbffe0ef          	jal	80003016 <bwrite>
    brelse(from);
    8000405c:	854e                	mv	a0,s3
    8000405e:	febfe0ef          	jal	80003048 <brelse>
    brelse(to);
    80004062:	8526                	mv	a0,s1
    80004064:	fe5fe0ef          	jal	80003048 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004068:	2905                	addiw	s2,s2,1
    8000406a:	0a91                	addi	s5,s5,4
    8000406c:	02ca2783          	lw	a5,44(s4)
    80004070:	faf94ae3          	blt	s2,a5,80004024 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004074:	d11ff0ef          	jal	80003d84 <write_head>
    install_trans(0); // Now install writes to home locations
    80004078:	4501                	li	a0,0
    8000407a:	d69ff0ef          	jal	80003de2 <install_trans>
    log.lh.n = 0;
    8000407e:	0001e797          	auipc	a5,0x1e
    80004082:	c007af23          	sw	zero,-994(a5) # 80021c9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004086:	cffff0ef          	jal	80003d84 <write_head>
    8000408a:	69e2                	ld	s3,24(sp)
    8000408c:	6a42                	ld	s4,16(sp)
    8000408e:	6aa2                	ld	s5,8(sp)
    80004090:	b735                	j	80003fbc <end_op+0x44>

0000000080004092 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004092:	1101                	addi	sp,sp,-32
    80004094:	ec06                	sd	ra,24(sp)
    80004096:	e822                	sd	s0,16(sp)
    80004098:	e426                	sd	s1,8(sp)
    8000409a:	e04a                	sd	s2,0(sp)
    8000409c:	1000                	addi	s0,sp,32
    8000409e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800040a0:	0001e917          	auipc	s2,0x1e
    800040a4:	bd090913          	addi	s2,s2,-1072 # 80021c70 <log>
    800040a8:	854a                	mv	a0,s2
    800040aa:	b4bfc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800040ae:	02c92603          	lw	a2,44(s2)
    800040b2:	47f5                	li	a5,29
    800040b4:	06c7c363          	blt	a5,a2,8000411a <log_write+0x88>
    800040b8:	0001e797          	auipc	a5,0x1e
    800040bc:	bd47a783          	lw	a5,-1068(a5) # 80021c8c <log+0x1c>
    800040c0:	37fd                	addiw	a5,a5,-1
    800040c2:	04f65c63          	bge	a2,a5,8000411a <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800040c6:	0001e797          	auipc	a5,0x1e
    800040ca:	bca7a783          	lw	a5,-1078(a5) # 80021c90 <log+0x20>
    800040ce:	04f05c63          	blez	a5,80004126 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800040d2:	4781                	li	a5,0
    800040d4:	04c05f63          	blez	a2,80004132 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800040d8:	44cc                	lw	a1,12(s1)
    800040da:	0001e717          	auipc	a4,0x1e
    800040de:	bc670713          	addi	a4,a4,-1082 # 80021ca0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800040e2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800040e4:	4314                	lw	a3,0(a4)
    800040e6:	04b68663          	beq	a3,a1,80004132 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    800040ea:	2785                	addiw	a5,a5,1
    800040ec:	0711                	addi	a4,a4,4
    800040ee:	fef61be3          	bne	a2,a5,800040e4 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    800040f2:	0621                	addi	a2,a2,8
    800040f4:	060a                	slli	a2,a2,0x2
    800040f6:	0001e797          	auipc	a5,0x1e
    800040fa:	b7a78793          	addi	a5,a5,-1158 # 80021c70 <log>
    800040fe:	97b2                	add	a5,a5,a2
    80004100:	44d8                	lw	a4,12(s1)
    80004102:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004104:	8526                	mv	a0,s1
    80004106:	fcbfe0ef          	jal	800030d0 <bpin>
    log.lh.n++;
    8000410a:	0001e717          	auipc	a4,0x1e
    8000410e:	b6670713          	addi	a4,a4,-1178 # 80021c70 <log>
    80004112:	575c                	lw	a5,44(a4)
    80004114:	2785                	addiw	a5,a5,1
    80004116:	d75c                	sw	a5,44(a4)
    80004118:	a80d                	j	8000414a <log_write+0xb8>
    panic("too big a transaction");
    8000411a:	00003517          	auipc	a0,0x3
    8000411e:	4b650513          	addi	a0,a0,1206 # 800075d0 <etext+0x5d0>
    80004122:	e72fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80004126:	00003517          	auipc	a0,0x3
    8000412a:	4c250513          	addi	a0,a0,1218 # 800075e8 <etext+0x5e8>
    8000412e:	e66fc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80004132:	00878693          	addi	a3,a5,8
    80004136:	068a                	slli	a3,a3,0x2
    80004138:	0001e717          	auipc	a4,0x1e
    8000413c:	b3870713          	addi	a4,a4,-1224 # 80021c70 <log>
    80004140:	9736                	add	a4,a4,a3
    80004142:	44d4                	lw	a3,12(s1)
    80004144:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004146:	faf60fe3          	beq	a2,a5,80004104 <log_write+0x72>
  }
  release(&log.lock);
    8000414a:	0001e517          	auipc	a0,0x1e
    8000414e:	b2650513          	addi	a0,a0,-1242 # 80021c70 <log>
    80004152:	b3bfc0ef          	jal	80000c8c <release>
}
    80004156:	60e2                	ld	ra,24(sp)
    80004158:	6442                	ld	s0,16(sp)
    8000415a:	64a2                	ld	s1,8(sp)
    8000415c:	6902                	ld	s2,0(sp)
    8000415e:	6105                	addi	sp,sp,32
    80004160:	8082                	ret

0000000080004162 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004162:	1101                	addi	sp,sp,-32
    80004164:	ec06                	sd	ra,24(sp)
    80004166:	e822                	sd	s0,16(sp)
    80004168:	e426                	sd	s1,8(sp)
    8000416a:	e04a                	sd	s2,0(sp)
    8000416c:	1000                	addi	s0,sp,32
    8000416e:	84aa                	mv	s1,a0
    80004170:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004172:	00003597          	auipc	a1,0x3
    80004176:	49658593          	addi	a1,a1,1174 # 80007608 <etext+0x608>
    8000417a:	0521                	addi	a0,a0,8
    8000417c:	9f9fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80004180:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004184:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004188:	0204a423          	sw	zero,40(s1)
}
    8000418c:	60e2                	ld	ra,24(sp)
    8000418e:	6442                	ld	s0,16(sp)
    80004190:	64a2                	ld	s1,8(sp)
    80004192:	6902                	ld	s2,0(sp)
    80004194:	6105                	addi	sp,sp,32
    80004196:	8082                	ret

0000000080004198 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004198:	1101                	addi	sp,sp,-32
    8000419a:	ec06                	sd	ra,24(sp)
    8000419c:	e822                	sd	s0,16(sp)
    8000419e:	e426                	sd	s1,8(sp)
    800041a0:	e04a                	sd	s2,0(sp)
    800041a2:	1000                	addi	s0,sp,32
    800041a4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041a6:	00850913          	addi	s2,a0,8
    800041aa:	854a                	mv	a0,s2
    800041ac:	a49fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    800041b0:	409c                	lw	a5,0(s1)
    800041b2:	c799                	beqz	a5,800041c0 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800041b4:	85ca                	mv	a1,s2
    800041b6:	8526                	mv	a0,s1
    800041b8:	b83fd0ef          	jal	80001d3a <sleep>
  while (lk->locked) {
    800041bc:	409c                	lw	a5,0(s1)
    800041be:	fbfd                	bnez	a5,800041b4 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800041c0:	4785                	li	a5,1
    800041c2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800041c4:	f14fd0ef          	jal	800018d8 <myproc>
    800041c8:	591c                	lw	a5,48(a0)
    800041ca:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800041cc:	854a                	mv	a0,s2
    800041ce:	abffc0ef          	jal	80000c8c <release>
}
    800041d2:	60e2                	ld	ra,24(sp)
    800041d4:	6442                	ld	s0,16(sp)
    800041d6:	64a2                	ld	s1,8(sp)
    800041d8:	6902                	ld	s2,0(sp)
    800041da:	6105                	addi	sp,sp,32
    800041dc:	8082                	ret

00000000800041de <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800041de:	1101                	addi	sp,sp,-32
    800041e0:	ec06                	sd	ra,24(sp)
    800041e2:	e822                	sd	s0,16(sp)
    800041e4:	e426                	sd	s1,8(sp)
    800041e6:	e04a                	sd	s2,0(sp)
    800041e8:	1000                	addi	s0,sp,32
    800041ea:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041ec:	00850913          	addi	s2,a0,8
    800041f0:	854a                	mv	a0,s2
    800041f2:	a03fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    800041f6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800041fa:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800041fe:	8526                	mv	a0,s1
    80004200:	b87fd0ef          	jal	80001d86 <wakeup>
  release(&lk->lk);
    80004204:	854a                	mv	a0,s2
    80004206:	a87fc0ef          	jal	80000c8c <release>
}
    8000420a:	60e2                	ld	ra,24(sp)
    8000420c:	6442                	ld	s0,16(sp)
    8000420e:	64a2                	ld	s1,8(sp)
    80004210:	6902                	ld	s2,0(sp)
    80004212:	6105                	addi	sp,sp,32
    80004214:	8082                	ret

0000000080004216 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004216:	7179                	addi	sp,sp,-48
    80004218:	f406                	sd	ra,40(sp)
    8000421a:	f022                	sd	s0,32(sp)
    8000421c:	ec26                	sd	s1,24(sp)
    8000421e:	e84a                	sd	s2,16(sp)
    80004220:	1800                	addi	s0,sp,48
    80004222:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004224:	00850913          	addi	s2,a0,8
    80004228:	854a                	mv	a0,s2
    8000422a:	9cbfc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000422e:	409c                	lw	a5,0(s1)
    80004230:	ef81                	bnez	a5,80004248 <holdingsleep+0x32>
    80004232:	4481                	li	s1,0
  release(&lk->lk);
    80004234:	854a                	mv	a0,s2
    80004236:	a57fc0ef          	jal	80000c8c <release>
  return r;
}
    8000423a:	8526                	mv	a0,s1
    8000423c:	70a2                	ld	ra,40(sp)
    8000423e:	7402                	ld	s0,32(sp)
    80004240:	64e2                	ld	s1,24(sp)
    80004242:	6942                	ld	s2,16(sp)
    80004244:	6145                	addi	sp,sp,48
    80004246:	8082                	ret
    80004248:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000424a:	0284a983          	lw	s3,40(s1)
    8000424e:	e8afd0ef          	jal	800018d8 <myproc>
    80004252:	5904                	lw	s1,48(a0)
    80004254:	413484b3          	sub	s1,s1,s3
    80004258:	0014b493          	seqz	s1,s1
    8000425c:	69a2                	ld	s3,8(sp)
    8000425e:	bfd9                	j	80004234 <holdingsleep+0x1e>

0000000080004260 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004260:	1141                	addi	sp,sp,-16
    80004262:	e406                	sd	ra,8(sp)
    80004264:	e022                	sd	s0,0(sp)
    80004266:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004268:	00003597          	auipc	a1,0x3
    8000426c:	3b058593          	addi	a1,a1,944 # 80007618 <etext+0x618>
    80004270:	0001e517          	auipc	a0,0x1e
    80004274:	b4850513          	addi	a0,a0,-1208 # 80021db8 <ftable>
    80004278:	8fdfc0ef          	jal	80000b74 <initlock>
}
    8000427c:	60a2                	ld	ra,8(sp)
    8000427e:	6402                	ld	s0,0(sp)
    80004280:	0141                	addi	sp,sp,16
    80004282:	8082                	ret

0000000080004284 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004284:	1101                	addi	sp,sp,-32
    80004286:	ec06                	sd	ra,24(sp)
    80004288:	e822                	sd	s0,16(sp)
    8000428a:	e426                	sd	s1,8(sp)
    8000428c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000428e:	0001e517          	auipc	a0,0x1e
    80004292:	b2a50513          	addi	a0,a0,-1238 # 80021db8 <ftable>
    80004296:	95ffc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000429a:	0001e497          	auipc	s1,0x1e
    8000429e:	b3648493          	addi	s1,s1,-1226 # 80021dd0 <ftable+0x18>
    800042a2:	0001f717          	auipc	a4,0x1f
    800042a6:	ace70713          	addi	a4,a4,-1330 # 80022d70 <disk>
    if(f->ref == 0){
    800042aa:	40dc                	lw	a5,4(s1)
    800042ac:	cf89                	beqz	a5,800042c6 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800042ae:	02848493          	addi	s1,s1,40
    800042b2:	fee49ce3          	bne	s1,a4,800042aa <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042b6:	0001e517          	auipc	a0,0x1e
    800042ba:	b0250513          	addi	a0,a0,-1278 # 80021db8 <ftable>
    800042be:	9cffc0ef          	jal	80000c8c <release>
  return 0;
    800042c2:	4481                	li	s1,0
    800042c4:	a809                	j	800042d6 <filealloc+0x52>
      f->ref = 1;
    800042c6:	4785                	li	a5,1
    800042c8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800042ca:	0001e517          	auipc	a0,0x1e
    800042ce:	aee50513          	addi	a0,a0,-1298 # 80021db8 <ftable>
    800042d2:	9bbfc0ef          	jal	80000c8c <release>
}
    800042d6:	8526                	mv	a0,s1
    800042d8:	60e2                	ld	ra,24(sp)
    800042da:	6442                	ld	s0,16(sp)
    800042dc:	64a2                	ld	s1,8(sp)
    800042de:	6105                	addi	sp,sp,32
    800042e0:	8082                	ret

00000000800042e2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800042e2:	1101                	addi	sp,sp,-32
    800042e4:	ec06                	sd	ra,24(sp)
    800042e6:	e822                	sd	s0,16(sp)
    800042e8:	e426                	sd	s1,8(sp)
    800042ea:	1000                	addi	s0,sp,32
    800042ec:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800042ee:	0001e517          	auipc	a0,0x1e
    800042f2:	aca50513          	addi	a0,a0,-1334 # 80021db8 <ftable>
    800042f6:	8fffc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    800042fa:	40dc                	lw	a5,4(s1)
    800042fc:	02f05063          	blez	a5,8000431c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004300:	2785                	addiw	a5,a5,1
    80004302:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004304:	0001e517          	auipc	a0,0x1e
    80004308:	ab450513          	addi	a0,a0,-1356 # 80021db8 <ftable>
    8000430c:	981fc0ef          	jal	80000c8c <release>
  return f;
}
    80004310:	8526                	mv	a0,s1
    80004312:	60e2                	ld	ra,24(sp)
    80004314:	6442                	ld	s0,16(sp)
    80004316:	64a2                	ld	s1,8(sp)
    80004318:	6105                	addi	sp,sp,32
    8000431a:	8082                	ret
    panic("filedup");
    8000431c:	00003517          	auipc	a0,0x3
    80004320:	30450513          	addi	a0,a0,772 # 80007620 <etext+0x620>
    80004324:	c70fc0ef          	jal	80000794 <panic>

0000000080004328 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004328:	7139                	addi	sp,sp,-64
    8000432a:	fc06                	sd	ra,56(sp)
    8000432c:	f822                	sd	s0,48(sp)
    8000432e:	f426                	sd	s1,40(sp)
    80004330:	0080                	addi	s0,sp,64
    80004332:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004334:	0001e517          	auipc	a0,0x1e
    80004338:	a8450513          	addi	a0,a0,-1404 # 80021db8 <ftable>
    8000433c:	8b9fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004340:	40dc                	lw	a5,4(s1)
    80004342:	04f05a63          	blez	a5,80004396 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004346:	37fd                	addiw	a5,a5,-1
    80004348:	0007871b          	sext.w	a4,a5
    8000434c:	c0dc                	sw	a5,4(s1)
    8000434e:	04e04e63          	bgtz	a4,800043aa <fileclose+0x82>
    80004352:	f04a                	sd	s2,32(sp)
    80004354:	ec4e                	sd	s3,24(sp)
    80004356:	e852                	sd	s4,16(sp)
    80004358:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000435a:	0004a903          	lw	s2,0(s1)
    8000435e:	0094ca83          	lbu	s5,9(s1)
    80004362:	0104ba03          	ld	s4,16(s1)
    80004366:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000436a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000436e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004372:	0001e517          	auipc	a0,0x1e
    80004376:	a4650513          	addi	a0,a0,-1466 # 80021db8 <ftable>
    8000437a:	913fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    8000437e:	4785                	li	a5,1
    80004380:	04f90063          	beq	s2,a5,800043c0 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004384:	3979                	addiw	s2,s2,-2
    80004386:	4785                	li	a5,1
    80004388:	0527f563          	bgeu	a5,s2,800043d2 <fileclose+0xaa>
    8000438c:	7902                	ld	s2,32(sp)
    8000438e:	69e2                	ld	s3,24(sp)
    80004390:	6a42                	ld	s4,16(sp)
    80004392:	6aa2                	ld	s5,8(sp)
    80004394:	a00d                	j	800043b6 <fileclose+0x8e>
    80004396:	f04a                	sd	s2,32(sp)
    80004398:	ec4e                	sd	s3,24(sp)
    8000439a:	e852                	sd	s4,16(sp)
    8000439c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000439e:	00003517          	auipc	a0,0x3
    800043a2:	28a50513          	addi	a0,a0,650 # 80007628 <etext+0x628>
    800043a6:	beefc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    800043aa:	0001e517          	auipc	a0,0x1e
    800043ae:	a0e50513          	addi	a0,a0,-1522 # 80021db8 <ftable>
    800043b2:	8dbfc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043b6:	70e2                	ld	ra,56(sp)
    800043b8:	7442                	ld	s0,48(sp)
    800043ba:	74a2                	ld	s1,40(sp)
    800043bc:	6121                	addi	sp,sp,64
    800043be:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800043c0:	85d6                	mv	a1,s5
    800043c2:	8552                	mv	a0,s4
    800043c4:	336000ef          	jal	800046fa <pipeclose>
    800043c8:	7902                	ld	s2,32(sp)
    800043ca:	69e2                	ld	s3,24(sp)
    800043cc:	6a42                	ld	s4,16(sp)
    800043ce:	6aa2                	ld	s5,8(sp)
    800043d0:	b7dd                	j	800043b6 <fileclose+0x8e>
    begin_op();
    800043d2:	b3dff0ef          	jal	80003f0e <begin_op>
    iput(ff.ip);
    800043d6:	854e                	mv	a0,s3
    800043d8:	c22ff0ef          	jal	800037fa <iput>
    end_op();
    800043dc:	b9dff0ef          	jal	80003f78 <end_op>
    800043e0:	7902                	ld	s2,32(sp)
    800043e2:	69e2                	ld	s3,24(sp)
    800043e4:	6a42                	ld	s4,16(sp)
    800043e6:	6aa2                	ld	s5,8(sp)
    800043e8:	b7f9                	j	800043b6 <fileclose+0x8e>

00000000800043ea <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800043ea:	715d                	addi	sp,sp,-80
    800043ec:	e486                	sd	ra,72(sp)
    800043ee:	e0a2                	sd	s0,64(sp)
    800043f0:	fc26                	sd	s1,56(sp)
    800043f2:	f44e                	sd	s3,40(sp)
    800043f4:	0880                	addi	s0,sp,80
    800043f6:	84aa                	mv	s1,a0
    800043f8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800043fa:	cdefd0ef          	jal	800018d8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800043fe:	409c                	lw	a5,0(s1)
    80004400:	37f9                	addiw	a5,a5,-2
    80004402:	4705                	li	a4,1
    80004404:	04f76063          	bltu	a4,a5,80004444 <filestat+0x5a>
    80004408:	f84a                	sd	s2,48(sp)
    8000440a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000440c:	6c88                	ld	a0,24(s1)
    8000440e:	a6aff0ef          	jal	80003678 <ilock>
    stati(f->ip, &st);
    80004412:	fb840593          	addi	a1,s0,-72
    80004416:	6c88                	ld	a0,24(s1)
    80004418:	c8aff0ef          	jal	800038a2 <stati>
    iunlock(f->ip);
    8000441c:	6c88                	ld	a0,24(s1)
    8000441e:	b08ff0ef          	jal	80003726 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004422:	46e1                	li	a3,24
    80004424:	fb840613          	addi	a2,s0,-72
    80004428:	85ce                	mv	a1,s3
    8000442a:	05093503          	ld	a0,80(s2)
    8000442e:	924fd0ef          	jal	80001552 <copyout>
    80004432:	41f5551b          	sraiw	a0,a0,0x1f
    80004436:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004438:	60a6                	ld	ra,72(sp)
    8000443a:	6406                	ld	s0,64(sp)
    8000443c:	74e2                	ld	s1,56(sp)
    8000443e:	79a2                	ld	s3,40(sp)
    80004440:	6161                	addi	sp,sp,80
    80004442:	8082                	ret
  return -1;
    80004444:	557d                	li	a0,-1
    80004446:	bfcd                	j	80004438 <filestat+0x4e>

0000000080004448 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004448:	7179                	addi	sp,sp,-48
    8000444a:	f406                	sd	ra,40(sp)
    8000444c:	f022                	sd	s0,32(sp)
    8000444e:	e84a                	sd	s2,16(sp)
    80004450:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004452:	00854783          	lbu	a5,8(a0)
    80004456:	cfd1                	beqz	a5,800044f2 <fileread+0xaa>
    80004458:	ec26                	sd	s1,24(sp)
    8000445a:	e44e                	sd	s3,8(sp)
    8000445c:	84aa                	mv	s1,a0
    8000445e:	89ae                	mv	s3,a1
    80004460:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004462:	411c                	lw	a5,0(a0)
    80004464:	4705                	li	a4,1
    80004466:	04e78363          	beq	a5,a4,800044ac <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000446a:	470d                	li	a4,3
    8000446c:	04e78763          	beq	a5,a4,800044ba <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004470:	4709                	li	a4,2
    80004472:	06e79a63          	bne	a5,a4,800044e6 <fileread+0x9e>
    ilock(f->ip);
    80004476:	6d08                	ld	a0,24(a0)
    80004478:	a00ff0ef          	jal	80003678 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000447c:	874a                	mv	a4,s2
    8000447e:	5094                	lw	a3,32(s1)
    80004480:	864e                	mv	a2,s3
    80004482:	4585                	li	a1,1
    80004484:	6c88                	ld	a0,24(s1)
    80004486:	c46ff0ef          	jal	800038cc <readi>
    8000448a:	892a                	mv	s2,a0
    8000448c:	00a05563          	blez	a0,80004496 <fileread+0x4e>
      f->off += r;
    80004490:	509c                	lw	a5,32(s1)
    80004492:	9fa9                	addw	a5,a5,a0
    80004494:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004496:	6c88                	ld	a0,24(s1)
    80004498:	a8eff0ef          	jal	80003726 <iunlock>
    8000449c:	64e2                	ld	s1,24(sp)
    8000449e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800044a0:	854a                	mv	a0,s2
    800044a2:	70a2                	ld	ra,40(sp)
    800044a4:	7402                	ld	s0,32(sp)
    800044a6:	6942                	ld	s2,16(sp)
    800044a8:	6145                	addi	sp,sp,48
    800044aa:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800044ac:	6908                	ld	a0,16(a0)
    800044ae:	388000ef          	jal	80004836 <piperead>
    800044b2:	892a                	mv	s2,a0
    800044b4:	64e2                	ld	s1,24(sp)
    800044b6:	69a2                	ld	s3,8(sp)
    800044b8:	b7e5                	j	800044a0 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800044ba:	02451783          	lh	a5,36(a0)
    800044be:	03079693          	slli	a3,a5,0x30
    800044c2:	92c1                	srli	a3,a3,0x30
    800044c4:	4725                	li	a4,9
    800044c6:	02d76863          	bltu	a4,a3,800044f6 <fileread+0xae>
    800044ca:	0792                	slli	a5,a5,0x4
    800044cc:	0001e717          	auipc	a4,0x1e
    800044d0:	84c70713          	addi	a4,a4,-1972 # 80021d18 <devsw>
    800044d4:	97ba                	add	a5,a5,a4
    800044d6:	639c                	ld	a5,0(a5)
    800044d8:	c39d                	beqz	a5,800044fe <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800044da:	4505                	li	a0,1
    800044dc:	9782                	jalr	a5
    800044de:	892a                	mv	s2,a0
    800044e0:	64e2                	ld	s1,24(sp)
    800044e2:	69a2                	ld	s3,8(sp)
    800044e4:	bf75                	j	800044a0 <fileread+0x58>
    panic("fileread");
    800044e6:	00003517          	auipc	a0,0x3
    800044ea:	15250513          	addi	a0,a0,338 # 80007638 <etext+0x638>
    800044ee:	aa6fc0ef          	jal	80000794 <panic>
    return -1;
    800044f2:	597d                	li	s2,-1
    800044f4:	b775                	j	800044a0 <fileread+0x58>
      return -1;
    800044f6:	597d                	li	s2,-1
    800044f8:	64e2                	ld	s1,24(sp)
    800044fa:	69a2                	ld	s3,8(sp)
    800044fc:	b755                	j	800044a0 <fileread+0x58>
    800044fe:	597d                	li	s2,-1
    80004500:	64e2                	ld	s1,24(sp)
    80004502:	69a2                	ld	s3,8(sp)
    80004504:	bf71                	j	800044a0 <fileread+0x58>

0000000080004506 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004506:	00954783          	lbu	a5,9(a0)
    8000450a:	10078b63          	beqz	a5,80004620 <filewrite+0x11a>
{
    8000450e:	715d                	addi	sp,sp,-80
    80004510:	e486                	sd	ra,72(sp)
    80004512:	e0a2                	sd	s0,64(sp)
    80004514:	f84a                	sd	s2,48(sp)
    80004516:	f052                	sd	s4,32(sp)
    80004518:	e85a                	sd	s6,16(sp)
    8000451a:	0880                	addi	s0,sp,80
    8000451c:	892a                	mv	s2,a0
    8000451e:	8b2e                	mv	s6,a1
    80004520:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004522:	411c                	lw	a5,0(a0)
    80004524:	4705                	li	a4,1
    80004526:	02e78763          	beq	a5,a4,80004554 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000452a:	470d                	li	a4,3
    8000452c:	02e78863          	beq	a5,a4,8000455c <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004530:	4709                	li	a4,2
    80004532:	0ce79c63          	bne	a5,a4,8000460a <filewrite+0x104>
    80004536:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004538:	0ac05863          	blez	a2,800045e8 <filewrite+0xe2>
    8000453c:	fc26                	sd	s1,56(sp)
    8000453e:	ec56                	sd	s5,24(sp)
    80004540:	e45e                	sd	s7,8(sp)
    80004542:	e062                	sd	s8,0(sp)
    int i = 0;
    80004544:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004546:	6b85                	lui	s7,0x1
    80004548:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000454c:	6c05                	lui	s8,0x1
    8000454e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004552:	a8b5                	j	800045ce <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004554:	6908                	ld	a0,16(a0)
    80004556:	1fc000ef          	jal	80004752 <pipewrite>
    8000455a:	a04d                	j	800045fc <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000455c:	02451783          	lh	a5,36(a0)
    80004560:	03079693          	slli	a3,a5,0x30
    80004564:	92c1                	srli	a3,a3,0x30
    80004566:	4725                	li	a4,9
    80004568:	0ad76e63          	bltu	a4,a3,80004624 <filewrite+0x11e>
    8000456c:	0792                	slli	a5,a5,0x4
    8000456e:	0001d717          	auipc	a4,0x1d
    80004572:	7aa70713          	addi	a4,a4,1962 # 80021d18 <devsw>
    80004576:	97ba                	add	a5,a5,a4
    80004578:	679c                	ld	a5,8(a5)
    8000457a:	c7dd                	beqz	a5,80004628 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000457c:	4505                	li	a0,1
    8000457e:	9782                	jalr	a5
    80004580:	a8b5                	j	800045fc <filewrite+0xf6>
      if(n1 > max)
    80004582:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004586:	989ff0ef          	jal	80003f0e <begin_op>
      ilock(f->ip);
    8000458a:	01893503          	ld	a0,24(s2)
    8000458e:	8eaff0ef          	jal	80003678 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004592:	8756                	mv	a4,s5
    80004594:	02092683          	lw	a3,32(s2)
    80004598:	01698633          	add	a2,s3,s6
    8000459c:	4585                	li	a1,1
    8000459e:	01893503          	ld	a0,24(s2)
    800045a2:	c26ff0ef          	jal	800039c8 <writei>
    800045a6:	84aa                	mv	s1,a0
    800045a8:	00a05763          	blez	a0,800045b6 <filewrite+0xb0>
        f->off += r;
    800045ac:	02092783          	lw	a5,32(s2)
    800045b0:	9fa9                	addw	a5,a5,a0
    800045b2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800045b6:	01893503          	ld	a0,24(s2)
    800045ba:	96cff0ef          	jal	80003726 <iunlock>
      end_op();
    800045be:	9bbff0ef          	jal	80003f78 <end_op>

      if(r != n1){
    800045c2:	029a9563          	bne	s5,s1,800045ec <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800045c6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800045ca:	0149da63          	bge	s3,s4,800045de <filewrite+0xd8>
      int n1 = n - i;
    800045ce:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800045d2:	0004879b          	sext.w	a5,s1
    800045d6:	fafbd6e3          	bge	s7,a5,80004582 <filewrite+0x7c>
    800045da:	84e2                	mv	s1,s8
    800045dc:	b75d                	j	80004582 <filewrite+0x7c>
    800045de:	74e2                	ld	s1,56(sp)
    800045e0:	6ae2                	ld	s5,24(sp)
    800045e2:	6ba2                	ld	s7,8(sp)
    800045e4:	6c02                	ld	s8,0(sp)
    800045e6:	a039                	j	800045f4 <filewrite+0xee>
    int i = 0;
    800045e8:	4981                	li	s3,0
    800045ea:	a029                	j	800045f4 <filewrite+0xee>
    800045ec:	74e2                	ld	s1,56(sp)
    800045ee:	6ae2                	ld	s5,24(sp)
    800045f0:	6ba2                	ld	s7,8(sp)
    800045f2:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800045f4:	033a1c63          	bne	s4,s3,8000462c <filewrite+0x126>
    800045f8:	8552                	mv	a0,s4
    800045fa:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800045fc:	60a6                	ld	ra,72(sp)
    800045fe:	6406                	ld	s0,64(sp)
    80004600:	7942                	ld	s2,48(sp)
    80004602:	7a02                	ld	s4,32(sp)
    80004604:	6b42                	ld	s6,16(sp)
    80004606:	6161                	addi	sp,sp,80
    80004608:	8082                	ret
    8000460a:	fc26                	sd	s1,56(sp)
    8000460c:	f44e                	sd	s3,40(sp)
    8000460e:	ec56                	sd	s5,24(sp)
    80004610:	e45e                	sd	s7,8(sp)
    80004612:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004614:	00003517          	auipc	a0,0x3
    80004618:	03450513          	addi	a0,a0,52 # 80007648 <etext+0x648>
    8000461c:	978fc0ef          	jal	80000794 <panic>
    return -1;
    80004620:	557d                	li	a0,-1
}
    80004622:	8082                	ret
      return -1;
    80004624:	557d                	li	a0,-1
    80004626:	bfd9                	j	800045fc <filewrite+0xf6>
    80004628:	557d                	li	a0,-1
    8000462a:	bfc9                	j	800045fc <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000462c:	557d                	li	a0,-1
    8000462e:	79a2                	ld	s3,40(sp)
    80004630:	b7f1                	j	800045fc <filewrite+0xf6>

0000000080004632 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004632:	7179                	addi	sp,sp,-48
    80004634:	f406                	sd	ra,40(sp)
    80004636:	f022                	sd	s0,32(sp)
    80004638:	ec26                	sd	s1,24(sp)
    8000463a:	e052                	sd	s4,0(sp)
    8000463c:	1800                	addi	s0,sp,48
    8000463e:	84aa                	mv	s1,a0
    80004640:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004642:	0005b023          	sd	zero,0(a1)
    80004646:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000464a:	c3bff0ef          	jal	80004284 <filealloc>
    8000464e:	e088                	sd	a0,0(s1)
    80004650:	c549                	beqz	a0,800046da <pipealloc+0xa8>
    80004652:	c33ff0ef          	jal	80004284 <filealloc>
    80004656:	00aa3023          	sd	a0,0(s4)
    8000465a:	cd25                	beqz	a0,800046d2 <pipealloc+0xa0>
    8000465c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000465e:	cc6fc0ef          	jal	80000b24 <kalloc>
    80004662:	892a                	mv	s2,a0
    80004664:	c12d                	beqz	a0,800046c6 <pipealloc+0x94>
    80004666:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004668:	4985                	li	s3,1
    8000466a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000466e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004672:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004676:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000467a:	00003597          	auipc	a1,0x3
    8000467e:	fde58593          	addi	a1,a1,-34 # 80007658 <etext+0x658>
    80004682:	cf2fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    80004686:	609c                	ld	a5,0(s1)
    80004688:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000468c:	609c                	ld	a5,0(s1)
    8000468e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004692:	609c                	ld	a5,0(s1)
    80004694:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004698:	609c                	ld	a5,0(s1)
    8000469a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000469e:	000a3783          	ld	a5,0(s4)
    800046a2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800046a6:	000a3783          	ld	a5,0(s4)
    800046aa:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800046ae:	000a3783          	ld	a5,0(s4)
    800046b2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800046b6:	000a3783          	ld	a5,0(s4)
    800046ba:	0127b823          	sd	s2,16(a5)
  return 0;
    800046be:	4501                	li	a0,0
    800046c0:	6942                	ld	s2,16(sp)
    800046c2:	69a2                	ld	s3,8(sp)
    800046c4:	a01d                	j	800046ea <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800046c6:	6088                	ld	a0,0(s1)
    800046c8:	c119                	beqz	a0,800046ce <pipealloc+0x9c>
    800046ca:	6942                	ld	s2,16(sp)
    800046cc:	a029                	j	800046d6 <pipealloc+0xa4>
    800046ce:	6942                	ld	s2,16(sp)
    800046d0:	a029                	j	800046da <pipealloc+0xa8>
    800046d2:	6088                	ld	a0,0(s1)
    800046d4:	c10d                	beqz	a0,800046f6 <pipealloc+0xc4>
    fileclose(*f0);
    800046d6:	c53ff0ef          	jal	80004328 <fileclose>
  if(*f1)
    800046da:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800046de:	557d                	li	a0,-1
  if(*f1)
    800046e0:	c789                	beqz	a5,800046ea <pipealloc+0xb8>
    fileclose(*f1);
    800046e2:	853e                	mv	a0,a5
    800046e4:	c45ff0ef          	jal	80004328 <fileclose>
  return -1;
    800046e8:	557d                	li	a0,-1
}
    800046ea:	70a2                	ld	ra,40(sp)
    800046ec:	7402                	ld	s0,32(sp)
    800046ee:	64e2                	ld	s1,24(sp)
    800046f0:	6a02                	ld	s4,0(sp)
    800046f2:	6145                	addi	sp,sp,48
    800046f4:	8082                	ret
  return -1;
    800046f6:	557d                	li	a0,-1
    800046f8:	bfcd                	j	800046ea <pipealloc+0xb8>

00000000800046fa <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800046fa:	1101                	addi	sp,sp,-32
    800046fc:	ec06                	sd	ra,24(sp)
    800046fe:	e822                	sd	s0,16(sp)
    80004700:	e426                	sd	s1,8(sp)
    80004702:	e04a                	sd	s2,0(sp)
    80004704:	1000                	addi	s0,sp,32
    80004706:	84aa                	mv	s1,a0
    80004708:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000470a:	ceafc0ef          	jal	80000bf4 <acquire>
  if(writable){
    8000470e:	02090763          	beqz	s2,8000473c <pipeclose+0x42>
    pi->writeopen = 0;
    80004712:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004716:	21848513          	addi	a0,s1,536
    8000471a:	e6cfd0ef          	jal	80001d86 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000471e:	2204b783          	ld	a5,544(s1)
    80004722:	e785                	bnez	a5,8000474a <pipeclose+0x50>
    release(&pi->lock);
    80004724:	8526                	mv	a0,s1
    80004726:	d66fc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    8000472a:	8526                	mv	a0,s1
    8000472c:	b16fc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004730:	60e2                	ld	ra,24(sp)
    80004732:	6442                	ld	s0,16(sp)
    80004734:	64a2                	ld	s1,8(sp)
    80004736:	6902                	ld	s2,0(sp)
    80004738:	6105                	addi	sp,sp,32
    8000473a:	8082                	ret
    pi->readopen = 0;
    8000473c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004740:	21c48513          	addi	a0,s1,540
    80004744:	e42fd0ef          	jal	80001d86 <wakeup>
    80004748:	bfd9                	j	8000471e <pipeclose+0x24>
    release(&pi->lock);
    8000474a:	8526                	mv	a0,s1
    8000474c:	d40fc0ef          	jal	80000c8c <release>
}
    80004750:	b7c5                	j	80004730 <pipeclose+0x36>

0000000080004752 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004752:	711d                	addi	sp,sp,-96
    80004754:	ec86                	sd	ra,88(sp)
    80004756:	e8a2                	sd	s0,80(sp)
    80004758:	e4a6                	sd	s1,72(sp)
    8000475a:	e0ca                	sd	s2,64(sp)
    8000475c:	fc4e                	sd	s3,56(sp)
    8000475e:	f852                	sd	s4,48(sp)
    80004760:	f456                	sd	s5,40(sp)
    80004762:	1080                	addi	s0,sp,96
    80004764:	84aa                	mv	s1,a0
    80004766:	8aae                	mv	s5,a1
    80004768:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000476a:	96efd0ef          	jal	800018d8 <myproc>
    8000476e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004770:	8526                	mv	a0,s1
    80004772:	c82fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    80004776:	0b405a63          	blez	s4,8000482a <pipewrite+0xd8>
    8000477a:	f05a                	sd	s6,32(sp)
    8000477c:	ec5e                	sd	s7,24(sp)
    8000477e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004780:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004782:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004784:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004788:	21c48b93          	addi	s7,s1,540
    8000478c:	a81d                	j	800047c2 <pipewrite+0x70>
      release(&pi->lock);
    8000478e:	8526                	mv	a0,s1
    80004790:	cfcfc0ef          	jal	80000c8c <release>
      return -1;
    80004794:	597d                	li	s2,-1
    80004796:	7b02                	ld	s6,32(sp)
    80004798:	6be2                	ld	s7,24(sp)
    8000479a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000479c:	854a                	mv	a0,s2
    8000479e:	60e6                	ld	ra,88(sp)
    800047a0:	6446                	ld	s0,80(sp)
    800047a2:	64a6                	ld	s1,72(sp)
    800047a4:	6906                	ld	s2,64(sp)
    800047a6:	79e2                	ld	s3,56(sp)
    800047a8:	7a42                	ld	s4,48(sp)
    800047aa:	7aa2                	ld	s5,40(sp)
    800047ac:	6125                	addi	sp,sp,96
    800047ae:	8082                	ret
      wakeup(&pi->nread);
    800047b0:	8562                	mv	a0,s8
    800047b2:	dd4fd0ef          	jal	80001d86 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800047b6:	85a6                	mv	a1,s1
    800047b8:	855e                	mv	a0,s7
    800047ba:	d80fd0ef          	jal	80001d3a <sleep>
  while(i < n){
    800047be:	05495b63          	bge	s2,s4,80004814 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800047c2:	2204a783          	lw	a5,544(s1)
    800047c6:	d7e1                	beqz	a5,8000478e <pipewrite+0x3c>
    800047c8:	854e                	mv	a0,s3
    800047ca:	fa8fd0ef          	jal	80001f72 <killed>
    800047ce:	f161                	bnez	a0,8000478e <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800047d0:	2184a783          	lw	a5,536(s1)
    800047d4:	21c4a703          	lw	a4,540(s1)
    800047d8:	2007879b          	addiw	a5,a5,512
    800047dc:	fcf70ae3          	beq	a4,a5,800047b0 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800047e0:	4685                	li	a3,1
    800047e2:	01590633          	add	a2,s2,s5
    800047e6:	faf40593          	addi	a1,s0,-81
    800047ea:	0509b503          	ld	a0,80(s3)
    800047ee:	e3bfc0ef          	jal	80001628 <copyin>
    800047f2:	03650e63          	beq	a0,s6,8000482e <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800047f6:	21c4a783          	lw	a5,540(s1)
    800047fa:	0017871b          	addiw	a4,a5,1
    800047fe:	20e4ae23          	sw	a4,540(s1)
    80004802:	1ff7f793          	andi	a5,a5,511
    80004806:	97a6                	add	a5,a5,s1
    80004808:	faf44703          	lbu	a4,-81(s0)
    8000480c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004810:	2905                	addiw	s2,s2,1
    80004812:	b775                	j	800047be <pipewrite+0x6c>
    80004814:	7b02                	ld	s6,32(sp)
    80004816:	6be2                	ld	s7,24(sp)
    80004818:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000481a:	21848513          	addi	a0,s1,536
    8000481e:	d68fd0ef          	jal	80001d86 <wakeup>
  release(&pi->lock);
    80004822:	8526                	mv	a0,s1
    80004824:	c68fc0ef          	jal	80000c8c <release>
  return i;
    80004828:	bf95                	j	8000479c <pipewrite+0x4a>
  int i = 0;
    8000482a:	4901                	li	s2,0
    8000482c:	b7fd                	j	8000481a <pipewrite+0xc8>
    8000482e:	7b02                	ld	s6,32(sp)
    80004830:	6be2                	ld	s7,24(sp)
    80004832:	6c42                	ld	s8,16(sp)
    80004834:	b7dd                	j	8000481a <pipewrite+0xc8>

0000000080004836 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004836:	715d                	addi	sp,sp,-80
    80004838:	e486                	sd	ra,72(sp)
    8000483a:	e0a2                	sd	s0,64(sp)
    8000483c:	fc26                	sd	s1,56(sp)
    8000483e:	f84a                	sd	s2,48(sp)
    80004840:	f44e                	sd	s3,40(sp)
    80004842:	f052                	sd	s4,32(sp)
    80004844:	ec56                	sd	s5,24(sp)
    80004846:	0880                	addi	s0,sp,80
    80004848:	84aa                	mv	s1,a0
    8000484a:	892e                	mv	s2,a1
    8000484c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000484e:	88afd0ef          	jal	800018d8 <myproc>
    80004852:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004854:	8526                	mv	a0,s1
    80004856:	b9efc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000485a:	2184a703          	lw	a4,536(s1)
    8000485e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004862:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004866:	02f71563          	bne	a4,a5,80004890 <piperead+0x5a>
    8000486a:	2244a783          	lw	a5,548(s1)
    8000486e:	cb85                	beqz	a5,8000489e <piperead+0x68>
    if(killed(pr)){
    80004870:	8552                	mv	a0,s4
    80004872:	f00fd0ef          	jal	80001f72 <killed>
    80004876:	ed19                	bnez	a0,80004894 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004878:	85a6                	mv	a1,s1
    8000487a:	854e                	mv	a0,s3
    8000487c:	cbefd0ef          	jal	80001d3a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004880:	2184a703          	lw	a4,536(s1)
    80004884:	21c4a783          	lw	a5,540(s1)
    80004888:	fef701e3          	beq	a4,a5,8000486a <piperead+0x34>
    8000488c:	e85a                	sd	s6,16(sp)
    8000488e:	a809                	j	800048a0 <piperead+0x6a>
    80004890:	e85a                	sd	s6,16(sp)
    80004892:	a039                	j	800048a0 <piperead+0x6a>
      release(&pi->lock);
    80004894:	8526                	mv	a0,s1
    80004896:	bf6fc0ef          	jal	80000c8c <release>
      return -1;
    8000489a:	59fd                	li	s3,-1
    8000489c:	a8b1                	j	800048f8 <piperead+0xc2>
    8000489e:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048a0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800048a2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048a4:	05505263          	blez	s5,800048e8 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800048a8:	2184a783          	lw	a5,536(s1)
    800048ac:	21c4a703          	lw	a4,540(s1)
    800048b0:	02f70c63          	beq	a4,a5,800048e8 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800048b4:	0017871b          	addiw	a4,a5,1
    800048b8:	20e4ac23          	sw	a4,536(s1)
    800048bc:	1ff7f793          	andi	a5,a5,511
    800048c0:	97a6                	add	a5,a5,s1
    800048c2:	0187c783          	lbu	a5,24(a5)
    800048c6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800048ca:	4685                	li	a3,1
    800048cc:	fbf40613          	addi	a2,s0,-65
    800048d0:	85ca                	mv	a1,s2
    800048d2:	050a3503          	ld	a0,80(s4)
    800048d6:	c7dfc0ef          	jal	80001552 <copyout>
    800048da:	01650763          	beq	a0,s6,800048e8 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048de:	2985                	addiw	s3,s3,1
    800048e0:	0905                	addi	s2,s2,1
    800048e2:	fd3a93e3          	bne	s5,s3,800048a8 <piperead+0x72>
    800048e6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800048e8:	21c48513          	addi	a0,s1,540
    800048ec:	c9afd0ef          	jal	80001d86 <wakeup>
  release(&pi->lock);
    800048f0:	8526                	mv	a0,s1
    800048f2:	b9afc0ef          	jal	80000c8c <release>
    800048f6:	6b42                	ld	s6,16(sp)
  return i;
}
    800048f8:	854e                	mv	a0,s3
    800048fa:	60a6                	ld	ra,72(sp)
    800048fc:	6406                	ld	s0,64(sp)
    800048fe:	74e2                	ld	s1,56(sp)
    80004900:	7942                	ld	s2,48(sp)
    80004902:	79a2                	ld	s3,40(sp)
    80004904:	7a02                	ld	s4,32(sp)
    80004906:	6ae2                	ld	s5,24(sp)
    80004908:	6161                	addi	sp,sp,80
    8000490a:	8082                	ret

000000008000490c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000490c:	1141                	addi	sp,sp,-16
    8000490e:	e422                	sd	s0,8(sp)
    80004910:	0800                	addi	s0,sp,16
    80004912:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004914:	8905                	andi	a0,a0,1
    80004916:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004918:	8b89                	andi	a5,a5,2
    8000491a:	c399                	beqz	a5,80004920 <flags2perm+0x14>
      perm |= PTE_W;
    8000491c:	00456513          	ori	a0,a0,4
    return perm;
}
    80004920:	6422                	ld	s0,8(sp)
    80004922:	0141                	addi	sp,sp,16
    80004924:	8082                	ret

0000000080004926 <exec>:

int
exec(char *path, char **argv)
{
    80004926:	df010113          	addi	sp,sp,-528
    8000492a:	20113423          	sd	ra,520(sp)
    8000492e:	20813023          	sd	s0,512(sp)
    80004932:	ffa6                	sd	s1,504(sp)
    80004934:	fbca                	sd	s2,496(sp)
    80004936:	0c00                	addi	s0,sp,528
    80004938:	892a                	mv	s2,a0
    8000493a:	dea43c23          	sd	a0,-520(s0)
    8000493e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004942:	f97fc0ef          	jal	800018d8 <myproc>
    80004946:	84aa                	mv	s1,a0

  begin_op();
    80004948:	dc6ff0ef          	jal	80003f0e <begin_op>

  if((ip = namei(path)) == 0){
    8000494c:	854a                	mv	a0,s2
    8000494e:	c04ff0ef          	jal	80003d52 <namei>
    80004952:	c931                	beqz	a0,800049a6 <exec+0x80>
    80004954:	f3d2                	sd	s4,480(sp)
    80004956:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004958:	d21fe0ef          	jal	80003678 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000495c:	04000713          	li	a4,64
    80004960:	4681                	li	a3,0
    80004962:	e5040613          	addi	a2,s0,-432
    80004966:	4581                	li	a1,0
    80004968:	8552                	mv	a0,s4
    8000496a:	f63fe0ef          	jal	800038cc <readi>
    8000496e:	04000793          	li	a5,64
    80004972:	00f51a63          	bne	a0,a5,80004986 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004976:	e5042703          	lw	a4,-432(s0)
    8000497a:	464c47b7          	lui	a5,0x464c4
    8000497e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004982:	02f70663          	beq	a4,a5,800049ae <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004986:	8552                	mv	a0,s4
    80004988:	efbfe0ef          	jal	80003882 <iunlockput>
    end_op();
    8000498c:	decff0ef          	jal	80003f78 <end_op>
  }
  return -1;
    80004990:	557d                	li	a0,-1
    80004992:	7a1e                	ld	s4,480(sp)
}
    80004994:	20813083          	ld	ra,520(sp)
    80004998:	20013403          	ld	s0,512(sp)
    8000499c:	74fe                	ld	s1,504(sp)
    8000499e:	795e                	ld	s2,496(sp)
    800049a0:	21010113          	addi	sp,sp,528
    800049a4:	8082                	ret
    end_op();
    800049a6:	dd2ff0ef          	jal	80003f78 <end_op>
    return -1;
    800049aa:	557d                	li	a0,-1
    800049ac:	b7e5                	j	80004994 <exec+0x6e>
    800049ae:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800049b0:	8526                	mv	a0,s1
    800049b2:	fcffc0ef          	jal	80001980 <proc_pagetable>
    800049b6:	8b2a                	mv	s6,a0
    800049b8:	2c050b63          	beqz	a0,80004c8e <exec+0x368>
    800049bc:	f7ce                	sd	s3,488(sp)
    800049be:	efd6                	sd	s5,472(sp)
    800049c0:	e7de                	sd	s7,456(sp)
    800049c2:	e3e2                	sd	s8,448(sp)
    800049c4:	ff66                	sd	s9,440(sp)
    800049c6:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049c8:	e7042d03          	lw	s10,-400(s0)
    800049cc:	e8845783          	lhu	a5,-376(s0)
    800049d0:	12078963          	beqz	a5,80004b02 <exec+0x1dc>
    800049d4:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049d6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049d8:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800049da:	6c85                	lui	s9,0x1
    800049dc:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800049e0:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800049e4:	6a85                	lui	s5,0x1
    800049e6:	a085                	j	80004a46 <exec+0x120>
      panic("loadseg: address should exist");
    800049e8:	00003517          	auipc	a0,0x3
    800049ec:	c7850513          	addi	a0,a0,-904 # 80007660 <etext+0x660>
    800049f0:	da5fb0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    800049f4:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800049f6:	8726                	mv	a4,s1
    800049f8:	012c06bb          	addw	a3,s8,s2
    800049fc:	4581                	li	a1,0
    800049fe:	8552                	mv	a0,s4
    80004a00:	ecdfe0ef          	jal	800038cc <readi>
    80004a04:	2501                	sext.w	a0,a0
    80004a06:	24a49a63          	bne	s1,a0,80004c5a <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004a0a:	012a893b          	addw	s2,s5,s2
    80004a0e:	03397363          	bgeu	s2,s3,80004a34 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004a12:	02091593          	slli	a1,s2,0x20
    80004a16:	9181                	srli	a1,a1,0x20
    80004a18:	95de                	add	a1,a1,s7
    80004a1a:	855a                	mv	a0,s6
    80004a1c:	dbafc0ef          	jal	80000fd6 <walkaddr>
    80004a20:	862a                	mv	a2,a0
    if(pa == 0)
    80004a22:	d179                	beqz	a0,800049e8 <exec+0xc2>
    if(sz - i < PGSIZE)
    80004a24:	412984bb          	subw	s1,s3,s2
    80004a28:	0004879b          	sext.w	a5,s1
    80004a2c:	fcfcf4e3          	bgeu	s9,a5,800049f4 <exec+0xce>
    80004a30:	84d6                	mv	s1,s5
    80004a32:	b7c9                	j	800049f4 <exec+0xce>
    sz = sz1;
    80004a34:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a38:	2d85                	addiw	s11,s11,1
    80004a3a:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004a3e:	e8845783          	lhu	a5,-376(s0)
    80004a42:	08fdd063          	bge	s11,a5,80004ac2 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a46:	2d01                	sext.w	s10,s10
    80004a48:	03800713          	li	a4,56
    80004a4c:	86ea                	mv	a3,s10
    80004a4e:	e1840613          	addi	a2,s0,-488
    80004a52:	4581                	li	a1,0
    80004a54:	8552                	mv	a0,s4
    80004a56:	e77fe0ef          	jal	800038cc <readi>
    80004a5a:	03800793          	li	a5,56
    80004a5e:	1cf51663          	bne	a0,a5,80004c2a <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004a62:	e1842783          	lw	a5,-488(s0)
    80004a66:	4705                	li	a4,1
    80004a68:	fce798e3          	bne	a5,a4,80004a38 <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004a6c:	e4043483          	ld	s1,-448(s0)
    80004a70:	e3843783          	ld	a5,-456(s0)
    80004a74:	1af4ef63          	bltu	s1,a5,80004c32 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a78:	e2843783          	ld	a5,-472(s0)
    80004a7c:	94be                	add	s1,s1,a5
    80004a7e:	1af4ee63          	bltu	s1,a5,80004c3a <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004a82:	df043703          	ld	a4,-528(s0)
    80004a86:	8ff9                	and	a5,a5,a4
    80004a88:	1a079d63          	bnez	a5,80004c42 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a8c:	e1c42503          	lw	a0,-484(s0)
    80004a90:	e7dff0ef          	jal	8000490c <flags2perm>
    80004a94:	86aa                	mv	a3,a0
    80004a96:	8626                	mv	a2,s1
    80004a98:	85ca                	mv	a1,s2
    80004a9a:	855a                	mv	a0,s6
    80004a9c:	8a3fc0ef          	jal	8000133e <uvmalloc>
    80004aa0:	e0a43423          	sd	a0,-504(s0)
    80004aa4:	1a050363          	beqz	a0,80004c4a <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004aa8:	e2843b83          	ld	s7,-472(s0)
    80004aac:	e2042c03          	lw	s8,-480(s0)
    80004ab0:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ab4:	00098463          	beqz	s3,80004abc <exec+0x196>
    80004ab8:	4901                	li	s2,0
    80004aba:	bfa1                	j	80004a12 <exec+0xec>
    sz = sz1;
    80004abc:	e0843903          	ld	s2,-504(s0)
    80004ac0:	bfa5                	j	80004a38 <exec+0x112>
    80004ac2:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004ac4:	8552                	mv	a0,s4
    80004ac6:	dbdfe0ef          	jal	80003882 <iunlockput>
  end_op();
    80004aca:	caeff0ef          	jal	80003f78 <end_op>
  p = myproc();
    80004ace:	e0bfc0ef          	jal	800018d8 <myproc>
    80004ad2:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004ad4:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004ad8:	6985                	lui	s3,0x1
    80004ada:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004adc:	99ca                	add	s3,s3,s2
    80004ade:	77fd                	lui	a5,0xfffff
    80004ae0:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004ae4:	4691                	li	a3,4
    80004ae6:	6609                	lui	a2,0x2
    80004ae8:	964e                	add	a2,a2,s3
    80004aea:	85ce                	mv	a1,s3
    80004aec:	855a                	mv	a0,s6
    80004aee:	851fc0ef          	jal	8000133e <uvmalloc>
    80004af2:	892a                	mv	s2,a0
    80004af4:	e0a43423          	sd	a0,-504(s0)
    80004af8:	e519                	bnez	a0,80004b06 <exec+0x1e0>
  if(pagetable)
    80004afa:	e1343423          	sd	s3,-504(s0)
    80004afe:	4a01                	li	s4,0
    80004b00:	aab1                	j	80004c5c <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b02:	4901                	li	s2,0
    80004b04:	b7c1                	j	80004ac4 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004b06:	75f9                	lui	a1,0xffffe
    80004b08:	95aa                	add	a1,a1,a0
    80004b0a:	855a                	mv	a0,s6
    80004b0c:	a1dfc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004b10:	7bfd                	lui	s7,0xfffff
    80004b12:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004b14:	e0043783          	ld	a5,-512(s0)
    80004b18:	6388                	ld	a0,0(a5)
    80004b1a:	cd39                	beqz	a0,80004b78 <exec+0x252>
    80004b1c:	e9040993          	addi	s3,s0,-368
    80004b20:	f9040c13          	addi	s8,s0,-112
    80004b24:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004b26:	b12fc0ef          	jal	80000e38 <strlen>
    80004b2a:	0015079b          	addiw	a5,a0,1
    80004b2e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b32:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004b36:	11796e63          	bltu	s2,s7,80004c52 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b3a:	e0043d03          	ld	s10,-512(s0)
    80004b3e:	000d3a03          	ld	s4,0(s10)
    80004b42:	8552                	mv	a0,s4
    80004b44:	af4fc0ef          	jal	80000e38 <strlen>
    80004b48:	0015069b          	addiw	a3,a0,1
    80004b4c:	8652                	mv	a2,s4
    80004b4e:	85ca                	mv	a1,s2
    80004b50:	855a                	mv	a0,s6
    80004b52:	a01fc0ef          	jal	80001552 <copyout>
    80004b56:	10054063          	bltz	a0,80004c56 <exec+0x330>
    ustack[argc] = sp;
    80004b5a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004b5e:	0485                	addi	s1,s1,1
    80004b60:	008d0793          	addi	a5,s10,8
    80004b64:	e0f43023          	sd	a5,-512(s0)
    80004b68:	008d3503          	ld	a0,8(s10)
    80004b6c:	c909                	beqz	a0,80004b7e <exec+0x258>
    if(argc >= MAXARG)
    80004b6e:	09a1                	addi	s3,s3,8
    80004b70:	fb899be3          	bne	s3,s8,80004b26 <exec+0x200>
  ip = 0;
    80004b74:	4a01                	li	s4,0
    80004b76:	a0dd                	j	80004c5c <exec+0x336>
  sp = sz;
    80004b78:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004b7c:	4481                	li	s1,0
  ustack[argc] = 0;
    80004b7e:	00349793          	slli	a5,s1,0x3
    80004b82:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdc0e0>
    80004b86:	97a2                	add	a5,a5,s0
    80004b88:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b8c:	00148693          	addi	a3,s1,1
    80004b90:	068e                	slli	a3,a3,0x3
    80004b92:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004b96:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b9a:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004b9e:	f5796ee3          	bltu	s2,s7,80004afa <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ba2:	e9040613          	addi	a2,s0,-368
    80004ba6:	85ca                	mv	a1,s2
    80004ba8:	855a                	mv	a0,s6
    80004baa:	9a9fc0ef          	jal	80001552 <copyout>
    80004bae:	0e054263          	bltz	a0,80004c92 <exec+0x36c>
  p->trapframe->a1 = sp;
    80004bb2:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004bb6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004bba:	df843783          	ld	a5,-520(s0)
    80004bbe:	0007c703          	lbu	a4,0(a5)
    80004bc2:	cf11                	beqz	a4,80004bde <exec+0x2b8>
    80004bc4:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004bc6:	02f00693          	li	a3,47
    80004bca:	a039                	j	80004bd8 <exec+0x2b2>
      last = s+1;
    80004bcc:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004bd0:	0785                	addi	a5,a5,1
    80004bd2:	fff7c703          	lbu	a4,-1(a5)
    80004bd6:	c701                	beqz	a4,80004bde <exec+0x2b8>
    if(*s == '/')
    80004bd8:	fed71ce3          	bne	a4,a3,80004bd0 <exec+0x2aa>
    80004bdc:	bfc5                	j	80004bcc <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004bde:	4641                	li	a2,16
    80004be0:	df843583          	ld	a1,-520(s0)
    80004be4:	158a8513          	addi	a0,s5,344
    80004be8:	a1efc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004bec:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004bf0:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004bf4:	e0843783          	ld	a5,-504(s0)
    80004bf8:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004bfc:	058ab783          	ld	a5,88(s5)
    80004c00:	e6843703          	ld	a4,-408(s0)
    80004c04:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004c06:	058ab783          	ld	a5,88(s5)
    80004c0a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c0e:	85e6                	mv	a1,s9
    80004c10:	df5fc0ef          	jal	80001a04 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c14:	0004851b          	sext.w	a0,s1
    80004c18:	79be                	ld	s3,488(sp)
    80004c1a:	7a1e                	ld	s4,480(sp)
    80004c1c:	6afe                	ld	s5,472(sp)
    80004c1e:	6b5e                	ld	s6,464(sp)
    80004c20:	6bbe                	ld	s7,456(sp)
    80004c22:	6c1e                	ld	s8,448(sp)
    80004c24:	7cfa                	ld	s9,440(sp)
    80004c26:	7d5a                	ld	s10,432(sp)
    80004c28:	b3b5                	j	80004994 <exec+0x6e>
    80004c2a:	e1243423          	sd	s2,-504(s0)
    80004c2e:	7dba                	ld	s11,424(sp)
    80004c30:	a035                	j	80004c5c <exec+0x336>
    80004c32:	e1243423          	sd	s2,-504(s0)
    80004c36:	7dba                	ld	s11,424(sp)
    80004c38:	a015                	j	80004c5c <exec+0x336>
    80004c3a:	e1243423          	sd	s2,-504(s0)
    80004c3e:	7dba                	ld	s11,424(sp)
    80004c40:	a831                	j	80004c5c <exec+0x336>
    80004c42:	e1243423          	sd	s2,-504(s0)
    80004c46:	7dba                	ld	s11,424(sp)
    80004c48:	a811                	j	80004c5c <exec+0x336>
    80004c4a:	e1243423          	sd	s2,-504(s0)
    80004c4e:	7dba                	ld	s11,424(sp)
    80004c50:	a031                	j	80004c5c <exec+0x336>
  ip = 0;
    80004c52:	4a01                	li	s4,0
    80004c54:	a021                	j	80004c5c <exec+0x336>
    80004c56:	4a01                	li	s4,0
  if(pagetable)
    80004c58:	a011                	j	80004c5c <exec+0x336>
    80004c5a:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004c5c:	e0843583          	ld	a1,-504(s0)
    80004c60:	855a                	mv	a0,s6
    80004c62:	da3fc0ef          	jal	80001a04 <proc_freepagetable>
  return -1;
    80004c66:	557d                	li	a0,-1
  if(ip){
    80004c68:	000a1b63          	bnez	s4,80004c7e <exec+0x358>
    80004c6c:	79be                	ld	s3,488(sp)
    80004c6e:	7a1e                	ld	s4,480(sp)
    80004c70:	6afe                	ld	s5,472(sp)
    80004c72:	6b5e                	ld	s6,464(sp)
    80004c74:	6bbe                	ld	s7,456(sp)
    80004c76:	6c1e                	ld	s8,448(sp)
    80004c78:	7cfa                	ld	s9,440(sp)
    80004c7a:	7d5a                	ld	s10,432(sp)
    80004c7c:	bb21                	j	80004994 <exec+0x6e>
    80004c7e:	79be                	ld	s3,488(sp)
    80004c80:	6afe                	ld	s5,472(sp)
    80004c82:	6b5e                	ld	s6,464(sp)
    80004c84:	6bbe                	ld	s7,456(sp)
    80004c86:	6c1e                	ld	s8,448(sp)
    80004c88:	7cfa                	ld	s9,440(sp)
    80004c8a:	7d5a                	ld	s10,432(sp)
    80004c8c:	b9ed                	j	80004986 <exec+0x60>
    80004c8e:	6b5e                	ld	s6,464(sp)
    80004c90:	b9dd                	j	80004986 <exec+0x60>
  sz = sz1;
    80004c92:	e0843983          	ld	s3,-504(s0)
    80004c96:	b595                	j	80004afa <exec+0x1d4>

0000000080004c98 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c98:	7179                	addi	sp,sp,-48
    80004c9a:	f406                	sd	ra,40(sp)
    80004c9c:	f022                	sd	s0,32(sp)
    80004c9e:	ec26                	sd	s1,24(sp)
    80004ca0:	e84a                	sd	s2,16(sp)
    80004ca2:	1800                	addi	s0,sp,48
    80004ca4:	892e                	mv	s2,a1
    80004ca6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ca8:	fdc40593          	addi	a1,s0,-36
    80004cac:	edffd0ef          	jal	80002b8a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004cb0:	fdc42703          	lw	a4,-36(s0)
    80004cb4:	47bd                	li	a5,15
    80004cb6:	02e7e963          	bltu	a5,a4,80004ce8 <argfd+0x50>
    80004cba:	c1ffc0ef          	jal	800018d8 <myproc>
    80004cbe:	fdc42703          	lw	a4,-36(s0)
    80004cc2:	01a70793          	addi	a5,a4,26
    80004cc6:	078e                	slli	a5,a5,0x3
    80004cc8:	953e                	add	a0,a0,a5
    80004cca:	611c                	ld	a5,0(a0)
    80004ccc:	c385                	beqz	a5,80004cec <argfd+0x54>
    return -1;
  if(pfd)
    80004cce:	00090463          	beqz	s2,80004cd6 <argfd+0x3e>
    *pfd = fd;
    80004cd2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004cd6:	4501                	li	a0,0
  if(pf)
    80004cd8:	c091                	beqz	s1,80004cdc <argfd+0x44>
    *pf = f;
    80004cda:	e09c                	sd	a5,0(s1)
}
    80004cdc:	70a2                	ld	ra,40(sp)
    80004cde:	7402                	ld	s0,32(sp)
    80004ce0:	64e2                	ld	s1,24(sp)
    80004ce2:	6942                	ld	s2,16(sp)
    80004ce4:	6145                	addi	sp,sp,48
    80004ce6:	8082                	ret
    return -1;
    80004ce8:	557d                	li	a0,-1
    80004cea:	bfcd                	j	80004cdc <argfd+0x44>
    80004cec:	557d                	li	a0,-1
    80004cee:	b7fd                	j	80004cdc <argfd+0x44>

0000000080004cf0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004cf0:	1101                	addi	sp,sp,-32
    80004cf2:	ec06                	sd	ra,24(sp)
    80004cf4:	e822                	sd	s0,16(sp)
    80004cf6:	e426                	sd	s1,8(sp)
    80004cf8:	1000                	addi	s0,sp,32
    80004cfa:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004cfc:	bddfc0ef          	jal	800018d8 <myproc>
    80004d00:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004d02:	0d050793          	addi	a5,a0,208
    80004d06:	4501                	li	a0,0
    80004d08:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004d0a:	6398                	ld	a4,0(a5)
    80004d0c:	cb19                	beqz	a4,80004d22 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004d0e:	2505                	addiw	a0,a0,1
    80004d10:	07a1                	addi	a5,a5,8
    80004d12:	fed51ce3          	bne	a0,a3,80004d0a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d16:	557d                	li	a0,-1
}
    80004d18:	60e2                	ld	ra,24(sp)
    80004d1a:	6442                	ld	s0,16(sp)
    80004d1c:	64a2                	ld	s1,8(sp)
    80004d1e:	6105                	addi	sp,sp,32
    80004d20:	8082                	ret
      p->ofile[fd] = f;
    80004d22:	01a50793          	addi	a5,a0,26
    80004d26:	078e                	slli	a5,a5,0x3
    80004d28:	963e                	add	a2,a2,a5
    80004d2a:	e204                	sd	s1,0(a2)
      return fd;
    80004d2c:	b7f5                	j	80004d18 <fdalloc+0x28>

0000000080004d2e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004d2e:	715d                	addi	sp,sp,-80
    80004d30:	e486                	sd	ra,72(sp)
    80004d32:	e0a2                	sd	s0,64(sp)
    80004d34:	fc26                	sd	s1,56(sp)
    80004d36:	f84a                	sd	s2,48(sp)
    80004d38:	f44e                	sd	s3,40(sp)
    80004d3a:	ec56                	sd	s5,24(sp)
    80004d3c:	e85a                	sd	s6,16(sp)
    80004d3e:	0880                	addi	s0,sp,80
    80004d40:	8b2e                	mv	s6,a1
    80004d42:	89b2                	mv	s3,a2
    80004d44:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004d46:	fb040593          	addi	a1,s0,-80
    80004d4a:	822ff0ef          	jal	80003d6c <nameiparent>
    80004d4e:	84aa                	mv	s1,a0
    80004d50:	10050a63          	beqz	a0,80004e64 <create+0x136>
    return 0;

  ilock(dp);
    80004d54:	925fe0ef          	jal	80003678 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004d58:	4601                	li	a2,0
    80004d5a:	fb040593          	addi	a1,s0,-80
    80004d5e:	8526                	mv	a0,s1
    80004d60:	d8dfe0ef          	jal	80003aec <dirlookup>
    80004d64:	8aaa                	mv	s5,a0
    80004d66:	c129                	beqz	a0,80004da8 <create+0x7a>
    iunlockput(dp);
    80004d68:	8526                	mv	a0,s1
    80004d6a:	b19fe0ef          	jal	80003882 <iunlockput>
    ilock(ip);
    80004d6e:	8556                	mv	a0,s5
    80004d70:	909fe0ef          	jal	80003678 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d74:	4789                	li	a5,2
    80004d76:	02fb1463          	bne	s6,a5,80004d9e <create+0x70>
    80004d7a:	044ad783          	lhu	a5,68(s5)
    80004d7e:	37f9                	addiw	a5,a5,-2
    80004d80:	17c2                	slli	a5,a5,0x30
    80004d82:	93c1                	srli	a5,a5,0x30
    80004d84:	4705                	li	a4,1
    80004d86:	00f76c63          	bltu	a4,a5,80004d9e <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d8a:	8556                	mv	a0,s5
    80004d8c:	60a6                	ld	ra,72(sp)
    80004d8e:	6406                	ld	s0,64(sp)
    80004d90:	74e2                	ld	s1,56(sp)
    80004d92:	7942                	ld	s2,48(sp)
    80004d94:	79a2                	ld	s3,40(sp)
    80004d96:	6ae2                	ld	s5,24(sp)
    80004d98:	6b42                	ld	s6,16(sp)
    80004d9a:	6161                	addi	sp,sp,80
    80004d9c:	8082                	ret
    iunlockput(ip);
    80004d9e:	8556                	mv	a0,s5
    80004da0:	ae3fe0ef          	jal	80003882 <iunlockput>
    return 0;
    80004da4:	4a81                	li	s5,0
    80004da6:	b7d5                	j	80004d8a <create+0x5c>
    80004da8:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004daa:	85da                	mv	a1,s6
    80004dac:	4088                	lw	a0,0(s1)
    80004dae:	f5afe0ef          	jal	80003508 <ialloc>
    80004db2:	8a2a                	mv	s4,a0
    80004db4:	cd15                	beqz	a0,80004df0 <create+0xc2>
  ilock(ip);
    80004db6:	8c3fe0ef          	jal	80003678 <ilock>
  ip->major = major;
    80004dba:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004dbe:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004dc2:	4905                	li	s2,1
    80004dc4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004dc8:	8552                	mv	a0,s4
    80004dca:	ffafe0ef          	jal	800035c4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004dce:	032b0763          	beq	s6,s2,80004dfc <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004dd2:	004a2603          	lw	a2,4(s4)
    80004dd6:	fb040593          	addi	a1,s0,-80
    80004dda:	8526                	mv	a0,s1
    80004ddc:	eddfe0ef          	jal	80003cb8 <dirlink>
    80004de0:	06054563          	bltz	a0,80004e4a <create+0x11c>
  iunlockput(dp);
    80004de4:	8526                	mv	a0,s1
    80004de6:	a9dfe0ef          	jal	80003882 <iunlockput>
  return ip;
    80004dea:	8ad2                	mv	s5,s4
    80004dec:	7a02                	ld	s4,32(sp)
    80004dee:	bf71                	j	80004d8a <create+0x5c>
    iunlockput(dp);
    80004df0:	8526                	mv	a0,s1
    80004df2:	a91fe0ef          	jal	80003882 <iunlockput>
    return 0;
    80004df6:	8ad2                	mv	s5,s4
    80004df8:	7a02                	ld	s4,32(sp)
    80004dfa:	bf41                	j	80004d8a <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004dfc:	004a2603          	lw	a2,4(s4)
    80004e00:	00003597          	auipc	a1,0x3
    80004e04:	88058593          	addi	a1,a1,-1920 # 80007680 <etext+0x680>
    80004e08:	8552                	mv	a0,s4
    80004e0a:	eaffe0ef          	jal	80003cb8 <dirlink>
    80004e0e:	02054e63          	bltz	a0,80004e4a <create+0x11c>
    80004e12:	40d0                	lw	a2,4(s1)
    80004e14:	00003597          	auipc	a1,0x3
    80004e18:	87458593          	addi	a1,a1,-1932 # 80007688 <etext+0x688>
    80004e1c:	8552                	mv	a0,s4
    80004e1e:	e9bfe0ef          	jal	80003cb8 <dirlink>
    80004e22:	02054463          	bltz	a0,80004e4a <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e26:	004a2603          	lw	a2,4(s4)
    80004e2a:	fb040593          	addi	a1,s0,-80
    80004e2e:	8526                	mv	a0,s1
    80004e30:	e89fe0ef          	jal	80003cb8 <dirlink>
    80004e34:	00054b63          	bltz	a0,80004e4a <create+0x11c>
    dp->nlink++;  // for ".."
    80004e38:	04a4d783          	lhu	a5,74(s1)
    80004e3c:	2785                	addiw	a5,a5,1
    80004e3e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e42:	8526                	mv	a0,s1
    80004e44:	f80fe0ef          	jal	800035c4 <iupdate>
    80004e48:	bf71                	j	80004de4 <create+0xb6>
  ip->nlink = 0;
    80004e4a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004e4e:	8552                	mv	a0,s4
    80004e50:	f74fe0ef          	jal	800035c4 <iupdate>
  iunlockput(ip);
    80004e54:	8552                	mv	a0,s4
    80004e56:	a2dfe0ef          	jal	80003882 <iunlockput>
  iunlockput(dp);
    80004e5a:	8526                	mv	a0,s1
    80004e5c:	a27fe0ef          	jal	80003882 <iunlockput>
  return 0;
    80004e60:	7a02                	ld	s4,32(sp)
    80004e62:	b725                	j	80004d8a <create+0x5c>
    return 0;
    80004e64:	8aaa                	mv	s5,a0
    80004e66:	b715                	j	80004d8a <create+0x5c>

0000000080004e68 <sys_dup>:
{
    80004e68:	7179                	addi	sp,sp,-48
    80004e6a:	f406                	sd	ra,40(sp)
    80004e6c:	f022                	sd	s0,32(sp)
    80004e6e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004e70:	fd840613          	addi	a2,s0,-40
    80004e74:	4581                	li	a1,0
    80004e76:	4501                	li	a0,0
    80004e78:	e21ff0ef          	jal	80004c98 <argfd>
    return -1;
    80004e7c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004e7e:	02054363          	bltz	a0,80004ea4 <sys_dup+0x3c>
    80004e82:	ec26                	sd	s1,24(sp)
    80004e84:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004e86:	fd843903          	ld	s2,-40(s0)
    80004e8a:	854a                	mv	a0,s2
    80004e8c:	e65ff0ef          	jal	80004cf0 <fdalloc>
    80004e90:	84aa                	mv	s1,a0
    return -1;
    80004e92:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004e94:	00054d63          	bltz	a0,80004eae <sys_dup+0x46>
  filedup(f);
    80004e98:	854a                	mv	a0,s2
    80004e9a:	c48ff0ef          	jal	800042e2 <filedup>
  return fd;
    80004e9e:	87a6                	mv	a5,s1
    80004ea0:	64e2                	ld	s1,24(sp)
    80004ea2:	6942                	ld	s2,16(sp)
}
    80004ea4:	853e                	mv	a0,a5
    80004ea6:	70a2                	ld	ra,40(sp)
    80004ea8:	7402                	ld	s0,32(sp)
    80004eaa:	6145                	addi	sp,sp,48
    80004eac:	8082                	ret
    80004eae:	64e2                	ld	s1,24(sp)
    80004eb0:	6942                	ld	s2,16(sp)
    80004eb2:	bfcd                	j	80004ea4 <sys_dup+0x3c>

0000000080004eb4 <sys_read>:
{
    80004eb4:	7179                	addi	sp,sp,-48
    80004eb6:	f406                	sd	ra,40(sp)
    80004eb8:	f022                	sd	s0,32(sp)
    80004eba:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ebc:	fd840593          	addi	a1,s0,-40
    80004ec0:	4505                	li	a0,1
    80004ec2:	ce5fd0ef          	jal	80002ba6 <argaddr>
  argint(2, &n);
    80004ec6:	fe440593          	addi	a1,s0,-28
    80004eca:	4509                	li	a0,2
    80004ecc:	cbffd0ef          	jal	80002b8a <argint>
  if(argfd(0, 0, &f) < 0)
    80004ed0:	fe840613          	addi	a2,s0,-24
    80004ed4:	4581                	li	a1,0
    80004ed6:	4501                	li	a0,0
    80004ed8:	dc1ff0ef          	jal	80004c98 <argfd>
    80004edc:	87aa                	mv	a5,a0
    return -1;
    80004ede:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ee0:	0007ca63          	bltz	a5,80004ef4 <sys_read+0x40>
  return fileread(f, p, n);
    80004ee4:	fe442603          	lw	a2,-28(s0)
    80004ee8:	fd843583          	ld	a1,-40(s0)
    80004eec:	fe843503          	ld	a0,-24(s0)
    80004ef0:	d58ff0ef          	jal	80004448 <fileread>
}
    80004ef4:	70a2                	ld	ra,40(sp)
    80004ef6:	7402                	ld	s0,32(sp)
    80004ef8:	6145                	addi	sp,sp,48
    80004efa:	8082                	ret

0000000080004efc <sys_write>:
{
    80004efc:	7179                	addi	sp,sp,-48
    80004efe:	f406                	sd	ra,40(sp)
    80004f00:	f022                	sd	s0,32(sp)
    80004f02:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f04:	fd840593          	addi	a1,s0,-40
    80004f08:	4505                	li	a0,1
    80004f0a:	c9dfd0ef          	jal	80002ba6 <argaddr>
  argint(2, &n);
    80004f0e:	fe440593          	addi	a1,s0,-28
    80004f12:	4509                	li	a0,2
    80004f14:	c77fd0ef          	jal	80002b8a <argint>
  if(argfd(0, 0, &f) < 0)
    80004f18:	fe840613          	addi	a2,s0,-24
    80004f1c:	4581                	li	a1,0
    80004f1e:	4501                	li	a0,0
    80004f20:	d79ff0ef          	jal	80004c98 <argfd>
    80004f24:	87aa                	mv	a5,a0
    return -1;
    80004f26:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f28:	0007ca63          	bltz	a5,80004f3c <sys_write+0x40>
  return filewrite(f, p, n);
    80004f2c:	fe442603          	lw	a2,-28(s0)
    80004f30:	fd843583          	ld	a1,-40(s0)
    80004f34:	fe843503          	ld	a0,-24(s0)
    80004f38:	dceff0ef          	jal	80004506 <filewrite>
}
    80004f3c:	70a2                	ld	ra,40(sp)
    80004f3e:	7402                	ld	s0,32(sp)
    80004f40:	6145                	addi	sp,sp,48
    80004f42:	8082                	ret

0000000080004f44 <sys_close>:
{
    80004f44:	1101                	addi	sp,sp,-32
    80004f46:	ec06                	sd	ra,24(sp)
    80004f48:	e822                	sd	s0,16(sp)
    80004f4a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004f4c:	fe040613          	addi	a2,s0,-32
    80004f50:	fec40593          	addi	a1,s0,-20
    80004f54:	4501                	li	a0,0
    80004f56:	d43ff0ef          	jal	80004c98 <argfd>
    return -1;
    80004f5a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004f5c:	02054063          	bltz	a0,80004f7c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004f60:	979fc0ef          	jal	800018d8 <myproc>
    80004f64:	fec42783          	lw	a5,-20(s0)
    80004f68:	07e9                	addi	a5,a5,26
    80004f6a:	078e                	slli	a5,a5,0x3
    80004f6c:	953e                	add	a0,a0,a5
    80004f6e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f72:	fe043503          	ld	a0,-32(s0)
    80004f76:	bb2ff0ef          	jal	80004328 <fileclose>
  return 0;
    80004f7a:	4781                	li	a5,0
}
    80004f7c:	853e                	mv	a0,a5
    80004f7e:	60e2                	ld	ra,24(sp)
    80004f80:	6442                	ld	s0,16(sp)
    80004f82:	6105                	addi	sp,sp,32
    80004f84:	8082                	ret

0000000080004f86 <sys_fstat>:
{
    80004f86:	1101                	addi	sp,sp,-32
    80004f88:	ec06                	sd	ra,24(sp)
    80004f8a:	e822                	sd	s0,16(sp)
    80004f8c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f8e:	fe040593          	addi	a1,s0,-32
    80004f92:	4505                	li	a0,1
    80004f94:	c13fd0ef          	jal	80002ba6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004f98:	fe840613          	addi	a2,s0,-24
    80004f9c:	4581                	li	a1,0
    80004f9e:	4501                	li	a0,0
    80004fa0:	cf9ff0ef          	jal	80004c98 <argfd>
    80004fa4:	87aa                	mv	a5,a0
    return -1;
    80004fa6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fa8:	0007c863          	bltz	a5,80004fb8 <sys_fstat+0x32>
  return filestat(f, st);
    80004fac:	fe043583          	ld	a1,-32(s0)
    80004fb0:	fe843503          	ld	a0,-24(s0)
    80004fb4:	c36ff0ef          	jal	800043ea <filestat>
}
    80004fb8:	60e2                	ld	ra,24(sp)
    80004fba:	6442                	ld	s0,16(sp)
    80004fbc:	6105                	addi	sp,sp,32
    80004fbe:	8082                	ret

0000000080004fc0 <sys_link>:
{
    80004fc0:	7169                	addi	sp,sp,-304
    80004fc2:	f606                	sd	ra,296(sp)
    80004fc4:	f222                	sd	s0,288(sp)
    80004fc6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fc8:	08000613          	li	a2,128
    80004fcc:	ed040593          	addi	a1,s0,-304
    80004fd0:	4501                	li	a0,0
    80004fd2:	c39fd0ef          	jal	80002c0a <argstr>
    return -1;
    80004fd6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fd8:	0c054e63          	bltz	a0,800050b4 <sys_link+0xf4>
    80004fdc:	08000613          	li	a2,128
    80004fe0:	f5040593          	addi	a1,s0,-176
    80004fe4:	4505                	li	a0,1
    80004fe6:	c25fd0ef          	jal	80002c0a <argstr>
    return -1;
    80004fea:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fec:	0c054463          	bltz	a0,800050b4 <sys_link+0xf4>
    80004ff0:	ee26                	sd	s1,280(sp)
  begin_op();
    80004ff2:	f1dfe0ef          	jal	80003f0e <begin_op>
  if((ip = namei(old)) == 0){
    80004ff6:	ed040513          	addi	a0,s0,-304
    80004ffa:	d59fe0ef          	jal	80003d52 <namei>
    80004ffe:	84aa                	mv	s1,a0
    80005000:	c53d                	beqz	a0,8000506e <sys_link+0xae>
  ilock(ip);
    80005002:	e76fe0ef          	jal	80003678 <ilock>
  if(ip->type == T_DIR){
    80005006:	04449703          	lh	a4,68(s1)
    8000500a:	4785                	li	a5,1
    8000500c:	06f70663          	beq	a4,a5,80005078 <sys_link+0xb8>
    80005010:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005012:	04a4d783          	lhu	a5,74(s1)
    80005016:	2785                	addiw	a5,a5,1
    80005018:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000501c:	8526                	mv	a0,s1
    8000501e:	da6fe0ef          	jal	800035c4 <iupdate>
  iunlock(ip);
    80005022:	8526                	mv	a0,s1
    80005024:	f02fe0ef          	jal	80003726 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005028:	fd040593          	addi	a1,s0,-48
    8000502c:	f5040513          	addi	a0,s0,-176
    80005030:	d3dfe0ef          	jal	80003d6c <nameiparent>
    80005034:	892a                	mv	s2,a0
    80005036:	cd21                	beqz	a0,8000508e <sys_link+0xce>
  ilock(dp);
    80005038:	e40fe0ef          	jal	80003678 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000503c:	00092703          	lw	a4,0(s2)
    80005040:	409c                	lw	a5,0(s1)
    80005042:	04f71363          	bne	a4,a5,80005088 <sys_link+0xc8>
    80005046:	40d0                	lw	a2,4(s1)
    80005048:	fd040593          	addi	a1,s0,-48
    8000504c:	854a                	mv	a0,s2
    8000504e:	c6bfe0ef          	jal	80003cb8 <dirlink>
    80005052:	02054b63          	bltz	a0,80005088 <sys_link+0xc8>
  iunlockput(dp);
    80005056:	854a                	mv	a0,s2
    80005058:	82bfe0ef          	jal	80003882 <iunlockput>
  iput(ip);
    8000505c:	8526                	mv	a0,s1
    8000505e:	f9cfe0ef          	jal	800037fa <iput>
  end_op();
    80005062:	f17fe0ef          	jal	80003f78 <end_op>
  return 0;
    80005066:	4781                	li	a5,0
    80005068:	64f2                	ld	s1,280(sp)
    8000506a:	6952                	ld	s2,272(sp)
    8000506c:	a0a1                	j	800050b4 <sys_link+0xf4>
    end_op();
    8000506e:	f0bfe0ef          	jal	80003f78 <end_op>
    return -1;
    80005072:	57fd                	li	a5,-1
    80005074:	64f2                	ld	s1,280(sp)
    80005076:	a83d                	j	800050b4 <sys_link+0xf4>
    iunlockput(ip);
    80005078:	8526                	mv	a0,s1
    8000507a:	809fe0ef          	jal	80003882 <iunlockput>
    end_op();
    8000507e:	efbfe0ef          	jal	80003f78 <end_op>
    return -1;
    80005082:	57fd                	li	a5,-1
    80005084:	64f2                	ld	s1,280(sp)
    80005086:	a03d                	j	800050b4 <sys_link+0xf4>
    iunlockput(dp);
    80005088:	854a                	mv	a0,s2
    8000508a:	ff8fe0ef          	jal	80003882 <iunlockput>
  ilock(ip);
    8000508e:	8526                	mv	a0,s1
    80005090:	de8fe0ef          	jal	80003678 <ilock>
  ip->nlink--;
    80005094:	04a4d783          	lhu	a5,74(s1)
    80005098:	37fd                	addiw	a5,a5,-1
    8000509a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000509e:	8526                	mv	a0,s1
    800050a0:	d24fe0ef          	jal	800035c4 <iupdate>
  iunlockput(ip);
    800050a4:	8526                	mv	a0,s1
    800050a6:	fdcfe0ef          	jal	80003882 <iunlockput>
  end_op();
    800050aa:	ecffe0ef          	jal	80003f78 <end_op>
  return -1;
    800050ae:	57fd                	li	a5,-1
    800050b0:	64f2                	ld	s1,280(sp)
    800050b2:	6952                	ld	s2,272(sp)
}
    800050b4:	853e                	mv	a0,a5
    800050b6:	70b2                	ld	ra,296(sp)
    800050b8:	7412                	ld	s0,288(sp)
    800050ba:	6155                	addi	sp,sp,304
    800050bc:	8082                	ret

00000000800050be <sys_unlink>:
{
    800050be:	7151                	addi	sp,sp,-240
    800050c0:	f586                	sd	ra,232(sp)
    800050c2:	f1a2                	sd	s0,224(sp)
    800050c4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800050c6:	08000613          	li	a2,128
    800050ca:	f3040593          	addi	a1,s0,-208
    800050ce:	4501                	li	a0,0
    800050d0:	b3bfd0ef          	jal	80002c0a <argstr>
    800050d4:	16054063          	bltz	a0,80005234 <sys_unlink+0x176>
    800050d8:	eda6                	sd	s1,216(sp)
  begin_op();
    800050da:	e35fe0ef          	jal	80003f0e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800050de:	fb040593          	addi	a1,s0,-80
    800050e2:	f3040513          	addi	a0,s0,-208
    800050e6:	c87fe0ef          	jal	80003d6c <nameiparent>
    800050ea:	84aa                	mv	s1,a0
    800050ec:	c945                	beqz	a0,8000519c <sys_unlink+0xde>
  ilock(dp);
    800050ee:	d8afe0ef          	jal	80003678 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800050f2:	00002597          	auipc	a1,0x2
    800050f6:	58e58593          	addi	a1,a1,1422 # 80007680 <etext+0x680>
    800050fa:	fb040513          	addi	a0,s0,-80
    800050fe:	9d9fe0ef          	jal	80003ad6 <namecmp>
    80005102:	10050e63          	beqz	a0,8000521e <sys_unlink+0x160>
    80005106:	00002597          	auipc	a1,0x2
    8000510a:	58258593          	addi	a1,a1,1410 # 80007688 <etext+0x688>
    8000510e:	fb040513          	addi	a0,s0,-80
    80005112:	9c5fe0ef          	jal	80003ad6 <namecmp>
    80005116:	10050463          	beqz	a0,8000521e <sys_unlink+0x160>
    8000511a:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000511c:	f2c40613          	addi	a2,s0,-212
    80005120:	fb040593          	addi	a1,s0,-80
    80005124:	8526                	mv	a0,s1
    80005126:	9c7fe0ef          	jal	80003aec <dirlookup>
    8000512a:	892a                	mv	s2,a0
    8000512c:	0e050863          	beqz	a0,8000521c <sys_unlink+0x15e>
  ilock(ip);
    80005130:	d48fe0ef          	jal	80003678 <ilock>
  if(ip->nlink < 1)
    80005134:	04a91783          	lh	a5,74(s2)
    80005138:	06f05763          	blez	a5,800051a6 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000513c:	04491703          	lh	a4,68(s2)
    80005140:	4785                	li	a5,1
    80005142:	06f70963          	beq	a4,a5,800051b4 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005146:	4641                	li	a2,16
    80005148:	4581                	li	a1,0
    8000514a:	fc040513          	addi	a0,s0,-64
    8000514e:	b7bfb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005152:	4741                	li	a4,16
    80005154:	f2c42683          	lw	a3,-212(s0)
    80005158:	fc040613          	addi	a2,s0,-64
    8000515c:	4581                	li	a1,0
    8000515e:	8526                	mv	a0,s1
    80005160:	869fe0ef          	jal	800039c8 <writei>
    80005164:	47c1                	li	a5,16
    80005166:	08f51b63          	bne	a0,a5,800051fc <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000516a:	04491703          	lh	a4,68(s2)
    8000516e:	4785                	li	a5,1
    80005170:	08f70d63          	beq	a4,a5,8000520a <sys_unlink+0x14c>
  iunlockput(dp);
    80005174:	8526                	mv	a0,s1
    80005176:	f0cfe0ef          	jal	80003882 <iunlockput>
  ip->nlink--;
    8000517a:	04a95783          	lhu	a5,74(s2)
    8000517e:	37fd                	addiw	a5,a5,-1
    80005180:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005184:	854a                	mv	a0,s2
    80005186:	c3efe0ef          	jal	800035c4 <iupdate>
  iunlockput(ip);
    8000518a:	854a                	mv	a0,s2
    8000518c:	ef6fe0ef          	jal	80003882 <iunlockput>
  end_op();
    80005190:	de9fe0ef          	jal	80003f78 <end_op>
  return 0;
    80005194:	4501                	li	a0,0
    80005196:	64ee                	ld	s1,216(sp)
    80005198:	694e                	ld	s2,208(sp)
    8000519a:	a849                	j	8000522c <sys_unlink+0x16e>
    end_op();
    8000519c:	dddfe0ef          	jal	80003f78 <end_op>
    return -1;
    800051a0:	557d                	li	a0,-1
    800051a2:	64ee                	ld	s1,216(sp)
    800051a4:	a061                	j	8000522c <sys_unlink+0x16e>
    800051a6:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800051a8:	00002517          	auipc	a0,0x2
    800051ac:	4e850513          	addi	a0,a0,1256 # 80007690 <etext+0x690>
    800051b0:	de4fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051b4:	04c92703          	lw	a4,76(s2)
    800051b8:	02000793          	li	a5,32
    800051bc:	f8e7f5e3          	bgeu	a5,a4,80005146 <sys_unlink+0x88>
    800051c0:	e5ce                	sd	s3,200(sp)
    800051c2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051c6:	4741                	li	a4,16
    800051c8:	86ce                	mv	a3,s3
    800051ca:	f1840613          	addi	a2,s0,-232
    800051ce:	4581                	li	a1,0
    800051d0:	854a                	mv	a0,s2
    800051d2:	efafe0ef          	jal	800038cc <readi>
    800051d6:	47c1                	li	a5,16
    800051d8:	00f51c63          	bne	a0,a5,800051f0 <sys_unlink+0x132>
    if(de.inum != 0)
    800051dc:	f1845783          	lhu	a5,-232(s0)
    800051e0:	efa1                	bnez	a5,80005238 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051e2:	29c1                	addiw	s3,s3,16
    800051e4:	04c92783          	lw	a5,76(s2)
    800051e8:	fcf9efe3          	bltu	s3,a5,800051c6 <sys_unlink+0x108>
    800051ec:	69ae                	ld	s3,200(sp)
    800051ee:	bfa1                	j	80005146 <sys_unlink+0x88>
      panic("isdirempty: readi");
    800051f0:	00002517          	auipc	a0,0x2
    800051f4:	4b850513          	addi	a0,a0,1208 # 800076a8 <etext+0x6a8>
    800051f8:	d9cfb0ef          	jal	80000794 <panic>
    800051fc:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800051fe:	00002517          	auipc	a0,0x2
    80005202:	4c250513          	addi	a0,a0,1218 # 800076c0 <etext+0x6c0>
    80005206:	d8efb0ef          	jal	80000794 <panic>
    dp->nlink--;
    8000520a:	04a4d783          	lhu	a5,74(s1)
    8000520e:	37fd                	addiw	a5,a5,-1
    80005210:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005214:	8526                	mv	a0,s1
    80005216:	baefe0ef          	jal	800035c4 <iupdate>
    8000521a:	bfa9                	j	80005174 <sys_unlink+0xb6>
    8000521c:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000521e:	8526                	mv	a0,s1
    80005220:	e62fe0ef          	jal	80003882 <iunlockput>
  end_op();
    80005224:	d55fe0ef          	jal	80003f78 <end_op>
  return -1;
    80005228:	557d                	li	a0,-1
    8000522a:	64ee                	ld	s1,216(sp)
}
    8000522c:	70ae                	ld	ra,232(sp)
    8000522e:	740e                	ld	s0,224(sp)
    80005230:	616d                	addi	sp,sp,240
    80005232:	8082                	ret
    return -1;
    80005234:	557d                	li	a0,-1
    80005236:	bfdd                	j	8000522c <sys_unlink+0x16e>
    iunlockput(ip);
    80005238:	854a                	mv	a0,s2
    8000523a:	e48fe0ef          	jal	80003882 <iunlockput>
    goto bad;
    8000523e:	694e                	ld	s2,208(sp)
    80005240:	69ae                	ld	s3,200(sp)
    80005242:	bff1                	j	8000521e <sys_unlink+0x160>

0000000080005244 <sys_open>:

uint64
sys_open(void)
{
    80005244:	7131                	addi	sp,sp,-192
    80005246:	fd06                	sd	ra,184(sp)
    80005248:	f922                	sd	s0,176(sp)
    8000524a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000524c:	f4c40593          	addi	a1,s0,-180
    80005250:	4505                	li	a0,1
    80005252:	939fd0ef          	jal	80002b8a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005256:	08000613          	li	a2,128
    8000525a:	f5040593          	addi	a1,s0,-176
    8000525e:	4501                	li	a0,0
    80005260:	9abfd0ef          	jal	80002c0a <argstr>
    80005264:	87aa                	mv	a5,a0
    return -1;
    80005266:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005268:	0a07c263          	bltz	a5,8000530c <sys_open+0xc8>
    8000526c:	f526                	sd	s1,168(sp)

  begin_op();
    8000526e:	ca1fe0ef          	jal	80003f0e <begin_op>

  if(omode & O_CREATE){
    80005272:	f4c42783          	lw	a5,-180(s0)
    80005276:	2007f793          	andi	a5,a5,512
    8000527a:	c3d5                	beqz	a5,8000531e <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000527c:	4681                	li	a3,0
    8000527e:	4601                	li	a2,0
    80005280:	4589                	li	a1,2
    80005282:	f5040513          	addi	a0,s0,-176
    80005286:	aa9ff0ef          	jal	80004d2e <create>
    8000528a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000528c:	c541                	beqz	a0,80005314 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000528e:	04449703          	lh	a4,68(s1)
    80005292:	478d                	li	a5,3
    80005294:	00f71763          	bne	a4,a5,800052a2 <sys_open+0x5e>
    80005298:	0464d703          	lhu	a4,70(s1)
    8000529c:	47a5                	li	a5,9
    8000529e:	0ae7ed63          	bltu	a5,a4,80005358 <sys_open+0x114>
    800052a2:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800052a4:	fe1fe0ef          	jal	80004284 <filealloc>
    800052a8:	892a                	mv	s2,a0
    800052aa:	c179                	beqz	a0,80005370 <sys_open+0x12c>
    800052ac:	ed4e                	sd	s3,152(sp)
    800052ae:	a43ff0ef          	jal	80004cf0 <fdalloc>
    800052b2:	89aa                	mv	s3,a0
    800052b4:	0a054a63          	bltz	a0,80005368 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800052b8:	04449703          	lh	a4,68(s1)
    800052bc:	478d                	li	a5,3
    800052be:	0cf70263          	beq	a4,a5,80005382 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800052c2:	4789                	li	a5,2
    800052c4:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800052c8:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800052cc:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800052d0:	f4c42783          	lw	a5,-180(s0)
    800052d4:	0017c713          	xori	a4,a5,1
    800052d8:	8b05                	andi	a4,a4,1
    800052da:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800052de:	0037f713          	andi	a4,a5,3
    800052e2:	00e03733          	snez	a4,a4
    800052e6:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800052ea:	4007f793          	andi	a5,a5,1024
    800052ee:	c791                	beqz	a5,800052fa <sys_open+0xb6>
    800052f0:	04449703          	lh	a4,68(s1)
    800052f4:	4789                	li	a5,2
    800052f6:	08f70d63          	beq	a4,a5,80005390 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800052fa:	8526                	mv	a0,s1
    800052fc:	c2afe0ef          	jal	80003726 <iunlock>
  end_op();
    80005300:	c79fe0ef          	jal	80003f78 <end_op>

  return fd;
    80005304:	854e                	mv	a0,s3
    80005306:	74aa                	ld	s1,168(sp)
    80005308:	790a                	ld	s2,160(sp)
    8000530a:	69ea                	ld	s3,152(sp)
}
    8000530c:	70ea                	ld	ra,184(sp)
    8000530e:	744a                	ld	s0,176(sp)
    80005310:	6129                	addi	sp,sp,192
    80005312:	8082                	ret
      end_op();
    80005314:	c65fe0ef          	jal	80003f78 <end_op>
      return -1;
    80005318:	557d                	li	a0,-1
    8000531a:	74aa                	ld	s1,168(sp)
    8000531c:	bfc5                	j	8000530c <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000531e:	f5040513          	addi	a0,s0,-176
    80005322:	a31fe0ef          	jal	80003d52 <namei>
    80005326:	84aa                	mv	s1,a0
    80005328:	c11d                	beqz	a0,8000534e <sys_open+0x10a>
    ilock(ip);
    8000532a:	b4efe0ef          	jal	80003678 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000532e:	04449703          	lh	a4,68(s1)
    80005332:	4785                	li	a5,1
    80005334:	f4f71de3          	bne	a4,a5,8000528e <sys_open+0x4a>
    80005338:	f4c42783          	lw	a5,-180(s0)
    8000533c:	d3bd                	beqz	a5,800052a2 <sys_open+0x5e>
      iunlockput(ip);
    8000533e:	8526                	mv	a0,s1
    80005340:	d42fe0ef          	jal	80003882 <iunlockput>
      end_op();
    80005344:	c35fe0ef          	jal	80003f78 <end_op>
      return -1;
    80005348:	557d                	li	a0,-1
    8000534a:	74aa                	ld	s1,168(sp)
    8000534c:	b7c1                	j	8000530c <sys_open+0xc8>
      end_op();
    8000534e:	c2bfe0ef          	jal	80003f78 <end_op>
      return -1;
    80005352:	557d                	li	a0,-1
    80005354:	74aa                	ld	s1,168(sp)
    80005356:	bf5d                	j	8000530c <sys_open+0xc8>
    iunlockput(ip);
    80005358:	8526                	mv	a0,s1
    8000535a:	d28fe0ef          	jal	80003882 <iunlockput>
    end_op();
    8000535e:	c1bfe0ef          	jal	80003f78 <end_op>
    return -1;
    80005362:	557d                	li	a0,-1
    80005364:	74aa                	ld	s1,168(sp)
    80005366:	b75d                	j	8000530c <sys_open+0xc8>
      fileclose(f);
    80005368:	854a                	mv	a0,s2
    8000536a:	fbffe0ef          	jal	80004328 <fileclose>
    8000536e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005370:	8526                	mv	a0,s1
    80005372:	d10fe0ef          	jal	80003882 <iunlockput>
    end_op();
    80005376:	c03fe0ef          	jal	80003f78 <end_op>
    return -1;
    8000537a:	557d                	li	a0,-1
    8000537c:	74aa                	ld	s1,168(sp)
    8000537e:	790a                	ld	s2,160(sp)
    80005380:	b771                	j	8000530c <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005382:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005386:	04649783          	lh	a5,70(s1)
    8000538a:	02f91223          	sh	a5,36(s2)
    8000538e:	bf3d                	j	800052cc <sys_open+0x88>
    itrunc(ip);
    80005390:	8526                	mv	a0,s1
    80005392:	bd4fe0ef          	jal	80003766 <itrunc>
    80005396:	b795                	j	800052fa <sys_open+0xb6>

0000000080005398 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005398:	7175                	addi	sp,sp,-144
    8000539a:	e506                	sd	ra,136(sp)
    8000539c:	e122                	sd	s0,128(sp)
    8000539e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800053a0:	b6ffe0ef          	jal	80003f0e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800053a4:	08000613          	li	a2,128
    800053a8:	f7040593          	addi	a1,s0,-144
    800053ac:	4501                	li	a0,0
    800053ae:	85dfd0ef          	jal	80002c0a <argstr>
    800053b2:	02054363          	bltz	a0,800053d8 <sys_mkdir+0x40>
    800053b6:	4681                	li	a3,0
    800053b8:	4601                	li	a2,0
    800053ba:	4585                	li	a1,1
    800053bc:	f7040513          	addi	a0,s0,-144
    800053c0:	96fff0ef          	jal	80004d2e <create>
    800053c4:	c911                	beqz	a0,800053d8 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053c6:	cbcfe0ef          	jal	80003882 <iunlockput>
  end_op();
    800053ca:	baffe0ef          	jal	80003f78 <end_op>
  return 0;
    800053ce:	4501                	li	a0,0
}
    800053d0:	60aa                	ld	ra,136(sp)
    800053d2:	640a                	ld	s0,128(sp)
    800053d4:	6149                	addi	sp,sp,144
    800053d6:	8082                	ret
    end_op();
    800053d8:	ba1fe0ef          	jal	80003f78 <end_op>
    return -1;
    800053dc:	557d                	li	a0,-1
    800053de:	bfcd                	j	800053d0 <sys_mkdir+0x38>

00000000800053e0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800053e0:	7135                	addi	sp,sp,-160
    800053e2:	ed06                	sd	ra,152(sp)
    800053e4:	e922                	sd	s0,144(sp)
    800053e6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800053e8:	b27fe0ef          	jal	80003f0e <begin_op>
  argint(1, &major);
    800053ec:	f6c40593          	addi	a1,s0,-148
    800053f0:	4505                	li	a0,1
    800053f2:	f98fd0ef          	jal	80002b8a <argint>
  argint(2, &minor);
    800053f6:	f6840593          	addi	a1,s0,-152
    800053fa:	4509                	li	a0,2
    800053fc:	f8efd0ef          	jal	80002b8a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005400:	08000613          	li	a2,128
    80005404:	f7040593          	addi	a1,s0,-144
    80005408:	4501                	li	a0,0
    8000540a:	801fd0ef          	jal	80002c0a <argstr>
    8000540e:	02054563          	bltz	a0,80005438 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005412:	f6841683          	lh	a3,-152(s0)
    80005416:	f6c41603          	lh	a2,-148(s0)
    8000541a:	458d                	li	a1,3
    8000541c:	f7040513          	addi	a0,s0,-144
    80005420:	90fff0ef          	jal	80004d2e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005424:	c911                	beqz	a0,80005438 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005426:	c5cfe0ef          	jal	80003882 <iunlockput>
  end_op();
    8000542a:	b4ffe0ef          	jal	80003f78 <end_op>
  return 0;
    8000542e:	4501                	li	a0,0
}
    80005430:	60ea                	ld	ra,152(sp)
    80005432:	644a                	ld	s0,144(sp)
    80005434:	610d                	addi	sp,sp,160
    80005436:	8082                	ret
    end_op();
    80005438:	b41fe0ef          	jal	80003f78 <end_op>
    return -1;
    8000543c:	557d                	li	a0,-1
    8000543e:	bfcd                	j	80005430 <sys_mknod+0x50>

0000000080005440 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005440:	7135                	addi	sp,sp,-160
    80005442:	ed06                	sd	ra,152(sp)
    80005444:	e922                	sd	s0,144(sp)
    80005446:	e14a                	sd	s2,128(sp)
    80005448:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000544a:	c8efc0ef          	jal	800018d8 <myproc>
    8000544e:	892a                	mv	s2,a0
  
  begin_op();
    80005450:	abffe0ef          	jal	80003f0e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005454:	08000613          	li	a2,128
    80005458:	f6040593          	addi	a1,s0,-160
    8000545c:	4501                	li	a0,0
    8000545e:	facfd0ef          	jal	80002c0a <argstr>
    80005462:	04054363          	bltz	a0,800054a8 <sys_chdir+0x68>
    80005466:	e526                	sd	s1,136(sp)
    80005468:	f6040513          	addi	a0,s0,-160
    8000546c:	8e7fe0ef          	jal	80003d52 <namei>
    80005470:	84aa                	mv	s1,a0
    80005472:	c915                	beqz	a0,800054a6 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005474:	a04fe0ef          	jal	80003678 <ilock>
  if(ip->type != T_DIR){
    80005478:	04449703          	lh	a4,68(s1)
    8000547c:	4785                	li	a5,1
    8000547e:	02f71963          	bne	a4,a5,800054b0 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005482:	8526                	mv	a0,s1
    80005484:	aa2fe0ef          	jal	80003726 <iunlock>
  iput(p->cwd);
    80005488:	15093503          	ld	a0,336(s2)
    8000548c:	b6efe0ef          	jal	800037fa <iput>
  end_op();
    80005490:	ae9fe0ef          	jal	80003f78 <end_op>
  p->cwd = ip;
    80005494:	14993823          	sd	s1,336(s2)
  return 0;
    80005498:	4501                	li	a0,0
    8000549a:	64aa                	ld	s1,136(sp)
}
    8000549c:	60ea                	ld	ra,152(sp)
    8000549e:	644a                	ld	s0,144(sp)
    800054a0:	690a                	ld	s2,128(sp)
    800054a2:	610d                	addi	sp,sp,160
    800054a4:	8082                	ret
    800054a6:	64aa                	ld	s1,136(sp)
    end_op();
    800054a8:	ad1fe0ef          	jal	80003f78 <end_op>
    return -1;
    800054ac:	557d                	li	a0,-1
    800054ae:	b7fd                	j	8000549c <sys_chdir+0x5c>
    iunlockput(ip);
    800054b0:	8526                	mv	a0,s1
    800054b2:	bd0fe0ef          	jal	80003882 <iunlockput>
    end_op();
    800054b6:	ac3fe0ef          	jal	80003f78 <end_op>
    return -1;
    800054ba:	557d                	li	a0,-1
    800054bc:	64aa                	ld	s1,136(sp)
    800054be:	bff9                	j	8000549c <sys_chdir+0x5c>

00000000800054c0 <sys_exec>:

uint64
sys_exec(void)
{
    800054c0:	7121                	addi	sp,sp,-448
    800054c2:	ff06                	sd	ra,440(sp)
    800054c4:	fb22                	sd	s0,432(sp)
    800054c6:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800054c8:	e4840593          	addi	a1,s0,-440
    800054cc:	4505                	li	a0,1
    800054ce:	ed8fd0ef          	jal	80002ba6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800054d2:	08000613          	li	a2,128
    800054d6:	f5040593          	addi	a1,s0,-176
    800054da:	4501                	li	a0,0
    800054dc:	f2efd0ef          	jal	80002c0a <argstr>
    800054e0:	87aa                	mv	a5,a0
    return -1;
    800054e2:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800054e4:	0c07c463          	bltz	a5,800055ac <sys_exec+0xec>
    800054e8:	f726                	sd	s1,424(sp)
    800054ea:	f34a                	sd	s2,416(sp)
    800054ec:	ef4e                	sd	s3,408(sp)
    800054ee:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800054f0:	10000613          	li	a2,256
    800054f4:	4581                	li	a1,0
    800054f6:	e5040513          	addi	a0,s0,-432
    800054fa:	fcefb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800054fe:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005502:	89a6                	mv	s3,s1
    80005504:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005506:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000550a:	00391513          	slli	a0,s2,0x3
    8000550e:	e4040593          	addi	a1,s0,-448
    80005512:	e4843783          	ld	a5,-440(s0)
    80005516:	953e                	add	a0,a0,a5
    80005518:	de8fd0ef          	jal	80002b00 <fetchaddr>
    8000551c:	02054663          	bltz	a0,80005548 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005520:	e4043783          	ld	a5,-448(s0)
    80005524:	c3a9                	beqz	a5,80005566 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005526:	dfefb0ef          	jal	80000b24 <kalloc>
    8000552a:	85aa                	mv	a1,a0
    8000552c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005530:	cd01                	beqz	a0,80005548 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005532:	6605                	lui	a2,0x1
    80005534:	e4043503          	ld	a0,-448(s0)
    80005538:	e12fd0ef          	jal	80002b4a <fetchstr>
    8000553c:	00054663          	bltz	a0,80005548 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005540:	0905                	addi	s2,s2,1
    80005542:	09a1                	addi	s3,s3,8
    80005544:	fd4913e3          	bne	s2,s4,8000550a <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005548:	f5040913          	addi	s2,s0,-176
    8000554c:	6088                	ld	a0,0(s1)
    8000554e:	c931                	beqz	a0,800055a2 <sys_exec+0xe2>
    kfree(argv[i]);
    80005550:	cf2fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005554:	04a1                	addi	s1,s1,8
    80005556:	ff249be3          	bne	s1,s2,8000554c <sys_exec+0x8c>
  return -1;
    8000555a:	557d                	li	a0,-1
    8000555c:	74ba                	ld	s1,424(sp)
    8000555e:	791a                	ld	s2,416(sp)
    80005560:	69fa                	ld	s3,408(sp)
    80005562:	6a5a                	ld	s4,400(sp)
    80005564:	a0a1                	j	800055ac <sys_exec+0xec>
      argv[i] = 0;
    80005566:	0009079b          	sext.w	a5,s2
    8000556a:	078e                	slli	a5,a5,0x3
    8000556c:	fd078793          	addi	a5,a5,-48
    80005570:	97a2                	add	a5,a5,s0
    80005572:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005576:	e5040593          	addi	a1,s0,-432
    8000557a:	f5040513          	addi	a0,s0,-176
    8000557e:	ba8ff0ef          	jal	80004926 <exec>
    80005582:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005584:	f5040993          	addi	s3,s0,-176
    80005588:	6088                	ld	a0,0(s1)
    8000558a:	c511                	beqz	a0,80005596 <sys_exec+0xd6>
    kfree(argv[i]);
    8000558c:	cb6fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005590:	04a1                	addi	s1,s1,8
    80005592:	ff349be3          	bne	s1,s3,80005588 <sys_exec+0xc8>
  return ret;
    80005596:	854a                	mv	a0,s2
    80005598:	74ba                	ld	s1,424(sp)
    8000559a:	791a                	ld	s2,416(sp)
    8000559c:	69fa                	ld	s3,408(sp)
    8000559e:	6a5a                	ld	s4,400(sp)
    800055a0:	a031                	j	800055ac <sys_exec+0xec>
  return -1;
    800055a2:	557d                	li	a0,-1
    800055a4:	74ba                	ld	s1,424(sp)
    800055a6:	791a                	ld	s2,416(sp)
    800055a8:	69fa                	ld	s3,408(sp)
    800055aa:	6a5a                	ld	s4,400(sp)
}
    800055ac:	70fa                	ld	ra,440(sp)
    800055ae:	745a                	ld	s0,432(sp)
    800055b0:	6139                	addi	sp,sp,448
    800055b2:	8082                	ret

00000000800055b4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800055b4:	7139                	addi	sp,sp,-64
    800055b6:	fc06                	sd	ra,56(sp)
    800055b8:	f822                	sd	s0,48(sp)
    800055ba:	f426                	sd	s1,40(sp)
    800055bc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800055be:	b1afc0ef          	jal	800018d8 <myproc>
    800055c2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800055c4:	fd840593          	addi	a1,s0,-40
    800055c8:	4501                	li	a0,0
    800055ca:	ddcfd0ef          	jal	80002ba6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800055ce:	fc840593          	addi	a1,s0,-56
    800055d2:	fd040513          	addi	a0,s0,-48
    800055d6:	85cff0ef          	jal	80004632 <pipealloc>
    return -1;
    800055da:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800055dc:	0a054463          	bltz	a0,80005684 <sys_pipe+0xd0>
  fd0 = -1;
    800055e0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800055e4:	fd043503          	ld	a0,-48(s0)
    800055e8:	f08ff0ef          	jal	80004cf0 <fdalloc>
    800055ec:	fca42223          	sw	a0,-60(s0)
    800055f0:	08054163          	bltz	a0,80005672 <sys_pipe+0xbe>
    800055f4:	fc843503          	ld	a0,-56(s0)
    800055f8:	ef8ff0ef          	jal	80004cf0 <fdalloc>
    800055fc:	fca42023          	sw	a0,-64(s0)
    80005600:	06054063          	bltz	a0,80005660 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005604:	4691                	li	a3,4
    80005606:	fc440613          	addi	a2,s0,-60
    8000560a:	fd843583          	ld	a1,-40(s0)
    8000560e:	68a8                	ld	a0,80(s1)
    80005610:	f43fb0ef          	jal	80001552 <copyout>
    80005614:	00054e63          	bltz	a0,80005630 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005618:	4691                	li	a3,4
    8000561a:	fc040613          	addi	a2,s0,-64
    8000561e:	fd843583          	ld	a1,-40(s0)
    80005622:	0591                	addi	a1,a1,4
    80005624:	68a8                	ld	a0,80(s1)
    80005626:	f2dfb0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000562a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000562c:	04055c63          	bgez	a0,80005684 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005630:	fc442783          	lw	a5,-60(s0)
    80005634:	07e9                	addi	a5,a5,26
    80005636:	078e                	slli	a5,a5,0x3
    80005638:	97a6                	add	a5,a5,s1
    8000563a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000563e:	fc042783          	lw	a5,-64(s0)
    80005642:	07e9                	addi	a5,a5,26
    80005644:	078e                	slli	a5,a5,0x3
    80005646:	94be                	add	s1,s1,a5
    80005648:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000564c:	fd043503          	ld	a0,-48(s0)
    80005650:	cd9fe0ef          	jal	80004328 <fileclose>
    fileclose(wf);
    80005654:	fc843503          	ld	a0,-56(s0)
    80005658:	cd1fe0ef          	jal	80004328 <fileclose>
    return -1;
    8000565c:	57fd                	li	a5,-1
    8000565e:	a01d                	j	80005684 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005660:	fc442783          	lw	a5,-60(s0)
    80005664:	0007c763          	bltz	a5,80005672 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005668:	07e9                	addi	a5,a5,26
    8000566a:	078e                	slli	a5,a5,0x3
    8000566c:	97a6                	add	a5,a5,s1
    8000566e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005672:	fd043503          	ld	a0,-48(s0)
    80005676:	cb3fe0ef          	jal	80004328 <fileclose>
    fileclose(wf);
    8000567a:	fc843503          	ld	a0,-56(s0)
    8000567e:	cabfe0ef          	jal	80004328 <fileclose>
    return -1;
    80005682:	57fd                	li	a5,-1
}
    80005684:	853e                	mv	a0,a5
    80005686:	70e2                	ld	ra,56(sp)
    80005688:	7442                	ld	s0,48(sp)
    8000568a:	74a2                	ld	s1,40(sp)
    8000568c:	6121                	addi	sp,sp,64
    8000568e:	8082                	ret

0000000080005690 <kernelvec>:
    80005690:	7111                	addi	sp,sp,-256
    80005692:	e006                	sd	ra,0(sp)
    80005694:	e40a                	sd	sp,8(sp)
    80005696:	e80e                	sd	gp,16(sp)
    80005698:	ec12                	sd	tp,24(sp)
    8000569a:	f016                	sd	t0,32(sp)
    8000569c:	f41a                	sd	t1,40(sp)
    8000569e:	f81e                	sd	t2,48(sp)
    800056a0:	e4aa                	sd	a0,72(sp)
    800056a2:	e8ae                	sd	a1,80(sp)
    800056a4:	ecb2                	sd	a2,88(sp)
    800056a6:	f0b6                	sd	a3,96(sp)
    800056a8:	f4ba                	sd	a4,104(sp)
    800056aa:	f8be                	sd	a5,112(sp)
    800056ac:	fcc2                	sd	a6,120(sp)
    800056ae:	e146                	sd	a7,128(sp)
    800056b0:	edf2                	sd	t3,216(sp)
    800056b2:	f1f6                	sd	t4,224(sp)
    800056b4:	f5fa                	sd	t5,232(sp)
    800056b6:	f9fe                	sd	t6,240(sp)
    800056b8:	b58fd0ef          	jal	80002a10 <kerneltrap>
    800056bc:	6082                	ld	ra,0(sp)
    800056be:	6122                	ld	sp,8(sp)
    800056c0:	61c2                	ld	gp,16(sp)
    800056c2:	7282                	ld	t0,32(sp)
    800056c4:	7322                	ld	t1,40(sp)
    800056c6:	73c2                	ld	t2,48(sp)
    800056c8:	6526                	ld	a0,72(sp)
    800056ca:	65c6                	ld	a1,80(sp)
    800056cc:	6666                	ld	a2,88(sp)
    800056ce:	7686                	ld	a3,96(sp)
    800056d0:	7726                	ld	a4,104(sp)
    800056d2:	77c6                	ld	a5,112(sp)
    800056d4:	7866                	ld	a6,120(sp)
    800056d6:	688a                	ld	a7,128(sp)
    800056d8:	6e6e                	ld	t3,216(sp)
    800056da:	7e8e                	ld	t4,224(sp)
    800056dc:	7f2e                	ld	t5,232(sp)
    800056de:	7fce                	ld	t6,240(sp)
    800056e0:	6111                	addi	sp,sp,256
    800056e2:	10200073          	sret
	...

00000000800056ee <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800056ee:	1141                	addi	sp,sp,-16
    800056f0:	e422                	sd	s0,8(sp)
    800056f2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800056f4:	0c0007b7          	lui	a5,0xc000
    800056f8:	4705                	li	a4,1
    800056fa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800056fc:	0c0007b7          	lui	a5,0xc000
    80005700:	c3d8                	sw	a4,4(a5)
}
    80005702:	6422                	ld	s0,8(sp)
    80005704:	0141                	addi	sp,sp,16
    80005706:	8082                	ret

0000000080005708 <plicinithart>:

void
plicinithart(void)
{
    80005708:	1141                	addi	sp,sp,-16
    8000570a:	e406                	sd	ra,8(sp)
    8000570c:	e022                	sd	s0,0(sp)
    8000570e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005710:	99cfc0ef          	jal	800018ac <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005714:	0085171b          	slliw	a4,a0,0x8
    80005718:	0c0027b7          	lui	a5,0xc002
    8000571c:	97ba                	add	a5,a5,a4
    8000571e:	40200713          	li	a4,1026
    80005722:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005726:	00d5151b          	slliw	a0,a0,0xd
    8000572a:	0c2017b7          	lui	a5,0xc201
    8000572e:	97aa                	add	a5,a5,a0
    80005730:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005734:	60a2                	ld	ra,8(sp)
    80005736:	6402                	ld	s0,0(sp)
    80005738:	0141                	addi	sp,sp,16
    8000573a:	8082                	ret

000000008000573c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000573c:	1141                	addi	sp,sp,-16
    8000573e:	e406                	sd	ra,8(sp)
    80005740:	e022                	sd	s0,0(sp)
    80005742:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005744:	968fc0ef          	jal	800018ac <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005748:	00d5151b          	slliw	a0,a0,0xd
    8000574c:	0c2017b7          	lui	a5,0xc201
    80005750:	97aa                	add	a5,a5,a0
  return irq;
}
    80005752:	43c8                	lw	a0,4(a5)
    80005754:	60a2                	ld	ra,8(sp)
    80005756:	6402                	ld	s0,0(sp)
    80005758:	0141                	addi	sp,sp,16
    8000575a:	8082                	ret

000000008000575c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000575c:	1101                	addi	sp,sp,-32
    8000575e:	ec06                	sd	ra,24(sp)
    80005760:	e822                	sd	s0,16(sp)
    80005762:	e426                	sd	s1,8(sp)
    80005764:	1000                	addi	s0,sp,32
    80005766:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005768:	944fc0ef          	jal	800018ac <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000576c:	00d5151b          	slliw	a0,a0,0xd
    80005770:	0c2017b7          	lui	a5,0xc201
    80005774:	97aa                	add	a5,a5,a0
    80005776:	c3c4                	sw	s1,4(a5)
}
    80005778:	60e2                	ld	ra,24(sp)
    8000577a:	6442                	ld	s0,16(sp)
    8000577c:	64a2                	ld	s1,8(sp)
    8000577e:	6105                	addi	sp,sp,32
    80005780:	8082                	ret

0000000080005782 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005782:	1141                	addi	sp,sp,-16
    80005784:	e406                	sd	ra,8(sp)
    80005786:	e022                	sd	s0,0(sp)
    80005788:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000578a:	479d                	li	a5,7
    8000578c:	04a7ca63          	blt	a5,a0,800057e0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005790:	0001d797          	auipc	a5,0x1d
    80005794:	5e078793          	addi	a5,a5,1504 # 80022d70 <disk>
    80005798:	97aa                	add	a5,a5,a0
    8000579a:	0187c783          	lbu	a5,24(a5)
    8000579e:	e7b9                	bnez	a5,800057ec <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800057a0:	00451693          	slli	a3,a0,0x4
    800057a4:	0001d797          	auipc	a5,0x1d
    800057a8:	5cc78793          	addi	a5,a5,1484 # 80022d70 <disk>
    800057ac:	6398                	ld	a4,0(a5)
    800057ae:	9736                	add	a4,a4,a3
    800057b0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800057b4:	6398                	ld	a4,0(a5)
    800057b6:	9736                	add	a4,a4,a3
    800057b8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800057bc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800057c0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800057c4:	97aa                	add	a5,a5,a0
    800057c6:	4705                	li	a4,1
    800057c8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800057cc:	0001d517          	auipc	a0,0x1d
    800057d0:	5bc50513          	addi	a0,a0,1468 # 80022d88 <disk+0x18>
    800057d4:	db2fc0ef          	jal	80001d86 <wakeup>
}
    800057d8:	60a2                	ld	ra,8(sp)
    800057da:	6402                	ld	s0,0(sp)
    800057dc:	0141                	addi	sp,sp,16
    800057de:	8082                	ret
    panic("free_desc 1");
    800057e0:	00002517          	auipc	a0,0x2
    800057e4:	ef050513          	addi	a0,a0,-272 # 800076d0 <etext+0x6d0>
    800057e8:	fadfa0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    800057ec:	00002517          	auipc	a0,0x2
    800057f0:	ef450513          	addi	a0,a0,-268 # 800076e0 <etext+0x6e0>
    800057f4:	fa1fa0ef          	jal	80000794 <panic>

00000000800057f8 <virtio_disk_init>:
{
    800057f8:	1101                	addi	sp,sp,-32
    800057fa:	ec06                	sd	ra,24(sp)
    800057fc:	e822                	sd	s0,16(sp)
    800057fe:	e426                	sd	s1,8(sp)
    80005800:	e04a                	sd	s2,0(sp)
    80005802:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005804:	00002597          	auipc	a1,0x2
    80005808:	eec58593          	addi	a1,a1,-276 # 800076f0 <etext+0x6f0>
    8000580c:	0001d517          	auipc	a0,0x1d
    80005810:	68c50513          	addi	a0,a0,1676 # 80022e98 <disk+0x128>
    80005814:	b60fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005818:	100017b7          	lui	a5,0x10001
    8000581c:	4398                	lw	a4,0(a5)
    8000581e:	2701                	sext.w	a4,a4
    80005820:	747277b7          	lui	a5,0x74727
    80005824:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005828:	18f71063          	bne	a4,a5,800059a8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000582c:	100017b7          	lui	a5,0x10001
    80005830:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005832:	439c                	lw	a5,0(a5)
    80005834:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005836:	4709                	li	a4,2
    80005838:	16e79863          	bne	a5,a4,800059a8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000583c:	100017b7          	lui	a5,0x10001
    80005840:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005842:	439c                	lw	a5,0(a5)
    80005844:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005846:	16e79163          	bne	a5,a4,800059a8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000584a:	100017b7          	lui	a5,0x10001
    8000584e:	47d8                	lw	a4,12(a5)
    80005850:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005852:	554d47b7          	lui	a5,0x554d4
    80005856:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000585a:	14f71763          	bne	a4,a5,800059a8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000585e:	100017b7          	lui	a5,0x10001
    80005862:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005866:	4705                	li	a4,1
    80005868:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000586a:	470d                	li	a4,3
    8000586c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000586e:	10001737          	lui	a4,0x10001
    80005872:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005874:	c7ffe737          	lui	a4,0xc7ffe
    80005878:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb8af>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000587c:	8ef9                	and	a3,a3,a4
    8000587e:	10001737          	lui	a4,0x10001
    80005882:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005884:	472d                	li	a4,11
    80005886:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005888:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000588c:	439c                	lw	a5,0(a5)
    8000588e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005892:	8ba1                	andi	a5,a5,8
    80005894:	12078063          	beqz	a5,800059b4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005898:	100017b7          	lui	a5,0x10001
    8000589c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800058a0:	100017b7          	lui	a5,0x10001
    800058a4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800058a8:	439c                	lw	a5,0(a5)
    800058aa:	2781                	sext.w	a5,a5
    800058ac:	10079a63          	bnez	a5,800059c0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800058b0:	100017b7          	lui	a5,0x10001
    800058b4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800058b8:	439c                	lw	a5,0(a5)
    800058ba:	2781                	sext.w	a5,a5
  if(max == 0)
    800058bc:	10078863          	beqz	a5,800059cc <virtio_disk_init+0x1d4>
  if(max < NUM)
    800058c0:	471d                	li	a4,7
    800058c2:	10f77b63          	bgeu	a4,a5,800059d8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800058c6:	a5efb0ef          	jal	80000b24 <kalloc>
    800058ca:	0001d497          	auipc	s1,0x1d
    800058ce:	4a648493          	addi	s1,s1,1190 # 80022d70 <disk>
    800058d2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800058d4:	a50fb0ef          	jal	80000b24 <kalloc>
    800058d8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800058da:	a4afb0ef          	jal	80000b24 <kalloc>
    800058de:	87aa                	mv	a5,a0
    800058e0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800058e2:	6088                	ld	a0,0(s1)
    800058e4:	10050063          	beqz	a0,800059e4 <virtio_disk_init+0x1ec>
    800058e8:	0001d717          	auipc	a4,0x1d
    800058ec:	49073703          	ld	a4,1168(a4) # 80022d78 <disk+0x8>
    800058f0:	0e070a63          	beqz	a4,800059e4 <virtio_disk_init+0x1ec>
    800058f4:	0e078863          	beqz	a5,800059e4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800058f8:	6605                	lui	a2,0x1
    800058fa:	4581                	li	a1,0
    800058fc:	bccfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005900:	0001d497          	auipc	s1,0x1d
    80005904:	47048493          	addi	s1,s1,1136 # 80022d70 <disk>
    80005908:	6605                	lui	a2,0x1
    8000590a:	4581                	li	a1,0
    8000590c:	6488                	ld	a0,8(s1)
    8000590e:	bbafb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005912:	6605                	lui	a2,0x1
    80005914:	4581                	li	a1,0
    80005916:	6888                	ld	a0,16(s1)
    80005918:	bb0fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000591c:	100017b7          	lui	a5,0x10001
    80005920:	4721                	li	a4,8
    80005922:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005924:	4098                	lw	a4,0(s1)
    80005926:	100017b7          	lui	a5,0x10001
    8000592a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000592e:	40d8                	lw	a4,4(s1)
    80005930:	100017b7          	lui	a5,0x10001
    80005934:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005938:	649c                	ld	a5,8(s1)
    8000593a:	0007869b          	sext.w	a3,a5
    8000593e:	10001737          	lui	a4,0x10001
    80005942:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005946:	9781                	srai	a5,a5,0x20
    80005948:	10001737          	lui	a4,0x10001
    8000594c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005950:	689c                	ld	a5,16(s1)
    80005952:	0007869b          	sext.w	a3,a5
    80005956:	10001737          	lui	a4,0x10001
    8000595a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000595e:	9781                	srai	a5,a5,0x20
    80005960:	10001737          	lui	a4,0x10001
    80005964:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005968:	10001737          	lui	a4,0x10001
    8000596c:	4785                	li	a5,1
    8000596e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005970:	00f48c23          	sb	a5,24(s1)
    80005974:	00f48ca3          	sb	a5,25(s1)
    80005978:	00f48d23          	sb	a5,26(s1)
    8000597c:	00f48da3          	sb	a5,27(s1)
    80005980:	00f48e23          	sb	a5,28(s1)
    80005984:	00f48ea3          	sb	a5,29(s1)
    80005988:	00f48f23          	sb	a5,30(s1)
    8000598c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005990:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005994:	100017b7          	lui	a5,0x10001
    80005998:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000599c:	60e2                	ld	ra,24(sp)
    8000599e:	6442                	ld	s0,16(sp)
    800059a0:	64a2                	ld	s1,8(sp)
    800059a2:	6902                	ld	s2,0(sp)
    800059a4:	6105                	addi	sp,sp,32
    800059a6:	8082                	ret
    panic("could not find virtio disk");
    800059a8:	00002517          	auipc	a0,0x2
    800059ac:	d5850513          	addi	a0,a0,-680 # 80007700 <etext+0x700>
    800059b0:	de5fa0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    800059b4:	00002517          	auipc	a0,0x2
    800059b8:	d6c50513          	addi	a0,a0,-660 # 80007720 <etext+0x720>
    800059bc:	dd9fa0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    800059c0:	00002517          	auipc	a0,0x2
    800059c4:	d8050513          	addi	a0,a0,-640 # 80007740 <etext+0x740>
    800059c8:	dcdfa0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    800059cc:	00002517          	auipc	a0,0x2
    800059d0:	d9450513          	addi	a0,a0,-620 # 80007760 <etext+0x760>
    800059d4:	dc1fa0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    800059d8:	00002517          	auipc	a0,0x2
    800059dc:	da850513          	addi	a0,a0,-600 # 80007780 <etext+0x780>
    800059e0:	db5fa0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    800059e4:	00002517          	auipc	a0,0x2
    800059e8:	dbc50513          	addi	a0,a0,-580 # 800077a0 <etext+0x7a0>
    800059ec:	da9fa0ef          	jal	80000794 <panic>

00000000800059f0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800059f0:	7159                	addi	sp,sp,-112
    800059f2:	f486                	sd	ra,104(sp)
    800059f4:	f0a2                	sd	s0,96(sp)
    800059f6:	eca6                	sd	s1,88(sp)
    800059f8:	e8ca                	sd	s2,80(sp)
    800059fa:	e4ce                	sd	s3,72(sp)
    800059fc:	e0d2                	sd	s4,64(sp)
    800059fe:	fc56                	sd	s5,56(sp)
    80005a00:	f85a                	sd	s6,48(sp)
    80005a02:	f45e                	sd	s7,40(sp)
    80005a04:	f062                	sd	s8,32(sp)
    80005a06:	ec66                	sd	s9,24(sp)
    80005a08:	1880                	addi	s0,sp,112
    80005a0a:	8a2a                	mv	s4,a0
    80005a0c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a0e:	00c52c83          	lw	s9,12(a0)
    80005a12:	001c9c9b          	slliw	s9,s9,0x1
    80005a16:	1c82                	slli	s9,s9,0x20
    80005a18:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005a1c:	0001d517          	auipc	a0,0x1d
    80005a20:	47c50513          	addi	a0,a0,1148 # 80022e98 <disk+0x128>
    80005a24:	9d0fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005a28:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005a2a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a2c:	0001db17          	auipc	s6,0x1d
    80005a30:	344b0b13          	addi	s6,s6,836 # 80022d70 <disk>
  for(int i = 0; i < 3; i++){
    80005a34:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a36:	0001dc17          	auipc	s8,0x1d
    80005a3a:	462c0c13          	addi	s8,s8,1122 # 80022e98 <disk+0x128>
    80005a3e:	a8b9                	j	80005a9c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005a40:	00fb0733          	add	a4,s6,a5
    80005a44:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005a48:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005a4a:	0207c563          	bltz	a5,80005a74 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005a4e:	2905                	addiw	s2,s2,1
    80005a50:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a52:	05590963          	beq	s2,s5,80005aa4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005a56:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005a58:	0001d717          	auipc	a4,0x1d
    80005a5c:	31870713          	addi	a4,a4,792 # 80022d70 <disk>
    80005a60:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005a62:	01874683          	lbu	a3,24(a4)
    80005a66:	fee9                	bnez	a3,80005a40 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005a68:	2785                	addiw	a5,a5,1
    80005a6a:	0705                	addi	a4,a4,1
    80005a6c:	fe979be3          	bne	a5,s1,80005a62 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005a70:	57fd                	li	a5,-1
    80005a72:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005a74:	01205d63          	blez	s2,80005a8e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005a78:	f9042503          	lw	a0,-112(s0)
    80005a7c:	d07ff0ef          	jal	80005782 <free_desc>
      for(int j = 0; j < i; j++)
    80005a80:	4785                	li	a5,1
    80005a82:	0127d663          	bge	a5,s2,80005a8e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005a86:	f9442503          	lw	a0,-108(s0)
    80005a8a:	cf9ff0ef          	jal	80005782 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a8e:	85e2                	mv	a1,s8
    80005a90:	0001d517          	auipc	a0,0x1d
    80005a94:	2f850513          	addi	a0,a0,760 # 80022d88 <disk+0x18>
    80005a98:	aa2fc0ef          	jal	80001d3a <sleep>
  for(int i = 0; i < 3; i++){
    80005a9c:	f9040613          	addi	a2,s0,-112
    80005aa0:	894e                	mv	s2,s3
    80005aa2:	bf55                	j	80005a56 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005aa4:	f9042503          	lw	a0,-112(s0)
    80005aa8:	00451693          	slli	a3,a0,0x4

  if(write)
    80005aac:	0001d797          	auipc	a5,0x1d
    80005ab0:	2c478793          	addi	a5,a5,708 # 80022d70 <disk>
    80005ab4:	00a50713          	addi	a4,a0,10
    80005ab8:	0712                	slli	a4,a4,0x4
    80005aba:	973e                	add	a4,a4,a5
    80005abc:	01703633          	snez	a2,s7
    80005ac0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005ac2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005ac6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005aca:	6398                	ld	a4,0(a5)
    80005acc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005ace:	0a868613          	addi	a2,a3,168
    80005ad2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ad4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005ad6:	6390                	ld	a2,0(a5)
    80005ad8:	00d605b3          	add	a1,a2,a3
    80005adc:	4741                	li	a4,16
    80005ade:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005ae0:	4805                	li	a6,1
    80005ae2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005ae6:	f9442703          	lw	a4,-108(s0)
    80005aea:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005aee:	0712                	slli	a4,a4,0x4
    80005af0:	963a                	add	a2,a2,a4
    80005af2:	058a0593          	addi	a1,s4,88
    80005af6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005af8:	0007b883          	ld	a7,0(a5)
    80005afc:	9746                	add	a4,a4,a7
    80005afe:	40000613          	li	a2,1024
    80005b02:	c710                	sw	a2,8(a4)
  if(write)
    80005b04:	001bb613          	seqz	a2,s7
    80005b08:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b0c:	00166613          	ori	a2,a2,1
    80005b10:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b14:	f9842583          	lw	a1,-104(s0)
    80005b18:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b1c:	00250613          	addi	a2,a0,2
    80005b20:	0612                	slli	a2,a2,0x4
    80005b22:	963e                	add	a2,a2,a5
    80005b24:	577d                	li	a4,-1
    80005b26:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005b2a:	0592                	slli	a1,a1,0x4
    80005b2c:	98ae                	add	a7,a7,a1
    80005b2e:	03068713          	addi	a4,a3,48
    80005b32:	973e                	add	a4,a4,a5
    80005b34:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b38:	6398                	ld	a4,0(a5)
    80005b3a:	972e                	add	a4,a4,a1
    80005b3c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b40:	4689                	li	a3,2
    80005b42:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b46:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b4a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005b4e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b52:	6794                	ld	a3,8(a5)
    80005b54:	0026d703          	lhu	a4,2(a3)
    80005b58:	8b1d                	andi	a4,a4,7
    80005b5a:	0706                	slli	a4,a4,0x1
    80005b5c:	96ba                	add	a3,a3,a4
    80005b5e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005b62:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005b66:	6798                	ld	a4,8(a5)
    80005b68:	00275783          	lhu	a5,2(a4)
    80005b6c:	2785                	addiw	a5,a5,1
    80005b6e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005b72:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005b76:	100017b7          	lui	a5,0x10001
    80005b7a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005b7e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005b82:	0001d917          	auipc	s2,0x1d
    80005b86:	31690913          	addi	s2,s2,790 # 80022e98 <disk+0x128>
  while(b->disk == 1) {
    80005b8a:	4485                	li	s1,1
    80005b8c:	01079a63          	bne	a5,a6,80005ba0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005b90:	85ca                	mv	a1,s2
    80005b92:	8552                	mv	a0,s4
    80005b94:	9a6fc0ef          	jal	80001d3a <sleep>
  while(b->disk == 1) {
    80005b98:	004a2783          	lw	a5,4(s4)
    80005b9c:	fe978ae3          	beq	a5,s1,80005b90 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005ba0:	f9042903          	lw	s2,-112(s0)
    80005ba4:	00290713          	addi	a4,s2,2
    80005ba8:	0712                	slli	a4,a4,0x4
    80005baa:	0001d797          	auipc	a5,0x1d
    80005bae:	1c678793          	addi	a5,a5,454 # 80022d70 <disk>
    80005bb2:	97ba                	add	a5,a5,a4
    80005bb4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005bb8:	0001d997          	auipc	s3,0x1d
    80005bbc:	1b898993          	addi	s3,s3,440 # 80022d70 <disk>
    80005bc0:	00491713          	slli	a4,s2,0x4
    80005bc4:	0009b783          	ld	a5,0(s3)
    80005bc8:	97ba                	add	a5,a5,a4
    80005bca:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005bce:	854a                	mv	a0,s2
    80005bd0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005bd4:	bafff0ef          	jal	80005782 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005bd8:	8885                	andi	s1,s1,1
    80005bda:	f0fd                	bnez	s1,80005bc0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005bdc:	0001d517          	auipc	a0,0x1d
    80005be0:	2bc50513          	addi	a0,a0,700 # 80022e98 <disk+0x128>
    80005be4:	8a8fb0ef          	jal	80000c8c <release>
}
    80005be8:	70a6                	ld	ra,104(sp)
    80005bea:	7406                	ld	s0,96(sp)
    80005bec:	64e6                	ld	s1,88(sp)
    80005bee:	6946                	ld	s2,80(sp)
    80005bf0:	69a6                	ld	s3,72(sp)
    80005bf2:	6a06                	ld	s4,64(sp)
    80005bf4:	7ae2                	ld	s5,56(sp)
    80005bf6:	7b42                	ld	s6,48(sp)
    80005bf8:	7ba2                	ld	s7,40(sp)
    80005bfa:	7c02                	ld	s8,32(sp)
    80005bfc:	6ce2                	ld	s9,24(sp)
    80005bfe:	6165                	addi	sp,sp,112
    80005c00:	8082                	ret

0000000080005c02 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005c02:	1101                	addi	sp,sp,-32
    80005c04:	ec06                	sd	ra,24(sp)
    80005c06:	e822                	sd	s0,16(sp)
    80005c08:	e426                	sd	s1,8(sp)
    80005c0a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005c0c:	0001d497          	auipc	s1,0x1d
    80005c10:	16448493          	addi	s1,s1,356 # 80022d70 <disk>
    80005c14:	0001d517          	auipc	a0,0x1d
    80005c18:	28450513          	addi	a0,a0,644 # 80022e98 <disk+0x128>
    80005c1c:	fd9fa0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c20:	100017b7          	lui	a5,0x10001
    80005c24:	53b8                	lw	a4,96(a5)
    80005c26:	8b0d                	andi	a4,a4,3
    80005c28:	100017b7          	lui	a5,0x10001
    80005c2c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005c2e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005c32:	689c                	ld	a5,16(s1)
    80005c34:	0204d703          	lhu	a4,32(s1)
    80005c38:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c3c:	04f70663          	beq	a4,a5,80005c88 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005c40:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c44:	6898                	ld	a4,16(s1)
    80005c46:	0204d783          	lhu	a5,32(s1)
    80005c4a:	8b9d                	andi	a5,a5,7
    80005c4c:	078e                	slli	a5,a5,0x3
    80005c4e:	97ba                	add	a5,a5,a4
    80005c50:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005c52:	00278713          	addi	a4,a5,2
    80005c56:	0712                	slli	a4,a4,0x4
    80005c58:	9726                	add	a4,a4,s1
    80005c5a:	01074703          	lbu	a4,16(a4)
    80005c5e:	e321                	bnez	a4,80005c9e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005c60:	0789                	addi	a5,a5,2
    80005c62:	0792                	slli	a5,a5,0x4
    80005c64:	97a6                	add	a5,a5,s1
    80005c66:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005c68:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c6c:	91afc0ef          	jal	80001d86 <wakeup>

    disk.used_idx += 1;
    80005c70:	0204d783          	lhu	a5,32(s1)
    80005c74:	2785                	addiw	a5,a5,1
    80005c76:	17c2                	slli	a5,a5,0x30
    80005c78:	93c1                	srli	a5,a5,0x30
    80005c7a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005c7e:	6898                	ld	a4,16(s1)
    80005c80:	00275703          	lhu	a4,2(a4)
    80005c84:	faf71ee3          	bne	a4,a5,80005c40 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c88:	0001d517          	auipc	a0,0x1d
    80005c8c:	21050513          	addi	a0,a0,528 # 80022e98 <disk+0x128>
    80005c90:	ffdfa0ef          	jal	80000c8c <release>
}
    80005c94:	60e2                	ld	ra,24(sp)
    80005c96:	6442                	ld	s0,16(sp)
    80005c98:	64a2                	ld	s1,8(sp)
    80005c9a:	6105                	addi	sp,sp,32
    80005c9c:	8082                	ret
      panic("virtio_disk_intr status");
    80005c9e:	00002517          	auipc	a0,0x2
    80005ca2:	b1a50513          	addi	a0,a0,-1254 # 800077b8 <etext+0x7b8>
    80005ca6:	aeffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
