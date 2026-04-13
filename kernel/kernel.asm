
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000c117          	auipc	sp,0xc
    80000004:	95813103          	ld	sp,-1704(sp) # 8000b958 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd9217>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
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
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
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
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	2d3020ef          	jal	80002be4 <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00014517          	auipc	a0,0x14
    80000190:	81450513          	addi	a0,a0,-2028 # 800139a0 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00014497          	auipc	s1,0x14
    8000019c:	80848493          	addi	s1,s1,-2040 # 800139a0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00014917          	auipc	s2,0x14
    800001a4:	89890913          	addi	s2,s2,-1896 # 80013a38 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	03f010ef          	jal	800019f6 <myproc>
    800001bc:	6e0020ef          	jal	8000289c <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	40a020ef          	jal	800025d0 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00013717          	auipc	a4,0x13
    800001dc:	7c870713          	addi	a4,a4,1992 # 800139a0 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	191020ef          	jal	80002b9a <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	00013517          	auipc	a0,0x13
    80000226:	77e50513          	addi	a0,a0,1918 # 800139a0 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	00013717          	auipc	a4,0x13
    80000250:	7ef72623          	sw	a5,2028(a4) # 80013a38 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00013517          	auipc	a0,0x13
    80000266:	73e50513          	addi	a0,a0,1854 # 800139a0 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	00013517          	auipc	a0,0x13
    800002ba:	6ea50513          	addi	a0,a0,1770 # 800139a0 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	157020ef          	jal	80002c2e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00013517          	auipc	a0,0x13
    800002e0:	6c450513          	addi	a0,a0,1732 # 800139a0 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	00013717          	auipc	a4,0x13
    800002fe:	6a670713          	addi	a4,a4,1702 # 800139a0 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	00013797          	auipc	a5,0x13
    80000324:	68078793          	addi	a5,a5,1664 # 800139a0 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	00013797          	auipc	a5,0x13
    80000352:	6ea7a783          	lw	a5,1770(a5) # 80013a38 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00013717          	auipc	a4,0x13
    80000368:	63c70713          	addi	a4,a4,1596 # 800139a0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00013497          	auipc	s1,0x13
    80000378:	62c48493          	addi	s1,s1,1580 # 800139a0 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	00013717          	auipc	a4,0x13
    800003ba:	5ea70713          	addi	a4,a4,1514 # 800139a0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00013717          	auipc	a4,0x13
    800003d0:	66f72a23          	sw	a5,1652(a4) # 80013a40 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	00013797          	auipc	a5,0x13
    800003ee:	5b678793          	addi	a5,a5,1462 # 800139a0 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	00013797          	auipc	a5,0x13
    80000412:	62c7a723          	sw	a2,1582(a5) # 80013a3c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00013517          	auipc	a0,0x13
    8000041a:	62250513          	addi	a0,a0,1570 # 80013a38 <cons+0x98>
    8000041e:	1fe020ef          	jal	8000261c <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00008597          	auipc	a1,0x8
    80000430:	bd458593          	addi	a1,a1,-1068 # 80008000 <etext>
    80000434:	00013517          	auipc	a0,0x13
    80000438:	56c50513          	addi	a0,a0,1388 # 800139a0 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00024797          	auipc	a5,0x24
    80000448:	00c78793          	addi	a5,a5,12 # 80024450 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00008617          	auipc	a2,0x8
    80000482:	3da60613          	addi	a2,a2,986 # 80008858 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	0000b797          	auipc	a5,0xb
    8000051c:	45c7a783          	lw	a5,1116(a5) # 8000b974 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	00013517          	auipc	a0,0x13
    80000564:	4e850513          	addi	a0,a0,1256 # 80013a48 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00008b97          	auipc	s7,0x8
    8000072c:	130b8b93          	addi	s7,s7,304 # 80008858 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00008917          	auipc	s2,0x8
    8000078c:	88090913          	addi	s2,s2,-1920 # 80008008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	0000b797          	auipc	a5,0xb
    800007c0:	1b87a783          	lw	a5,440(a5) # 8000b974 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	00013517          	auipc	a0,0x13
    800007d6:	27650513          	addi	a0,a0,630 # 80013a48 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	0000b797          	auipc	a5,0xb
    800007f4:	1927a223          	sw	s2,388(a5) # 8000b974 <panicking>
  printf("panic: ");
    800007f8:	00008517          	auipc	a0,0x8
    800007fc:	82050513          	addi	a0,a0,-2016 # 80008018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00008517          	auipc	a0,0x8
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80008020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	0000b797          	auipc	a5,0xb
    80000816:	1527af23          	sw	s2,350(a5) # 8000b970 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00008597          	auipc	a1,0x8
    80000828:	80458593          	addi	a1,a1,-2044 # 80008028 <etext+0x28>
    8000082c:	00013517          	auipc	a0,0x13
    80000830:	21c50513          	addi	a0,a0,540 # 80013a48 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00007597          	auipc	a1,0x7
    80000880:	7b458593          	addi	a1,a1,1972 # 80008030 <etext+0x30>
    80000884:	00013517          	auipc	a0,0x13
    80000888:	1dc50513          	addi	a0,a0,476 # 80013a60 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	00013517          	auipc	a0,0x13
    800008ac:	1b850513          	addi	a0,a0,440 # 80013a60 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	0000b497          	auipc	s1,0xb
    800008ca:	0b648493          	addi	s1,s1,182 # 8000b97c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00013997          	auipc	s3,0x13
    800008d2:	19298993          	addi	s3,s3,402 # 80013a60 <tx_lock>
    800008d6:	0000b917          	auipc	s2,0xb
    800008da:	0a290913          	addi	s2,s2,162 # 8000b978 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	4e7010ef          	jal	800025d0 <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	00013517          	auipc	a0,0x13
    80000918:	14c50513          	addi	a0,a0,332 # 80013a60 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	0000b797          	auipc	a5,0xb
    8000093c:	03c7a783          	lw	a5,60(a5) # 8000b974 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	0000b797          	auipc	a5,0xb
    80000946:	02e7a783          	lw	a5,46(a5) # 8000b970 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	0000b797          	auipc	a5,0xb
    8000096c:	00c7a783          	lw	a5,12(a5) # 8000b974 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	00013517          	auipc	a0,0x13
    800009c8:	09c50513          	addi	a0,a0,156 # 80013a60 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	00013517          	auipc	a0,0x13
    800009e4:	08050513          	addi	a0,a0,128 # 80013a60 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	0000b797          	auipc	a5,0xb
    800009f4:	f807a623          	sw	zero,-116(a5) # 8000b97c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	0000b517          	auipc	a0,0xb
    800009fc:	f8050513          	addi	a0,a0,-128 # 8000b978 <tx_chan>
    80000a00:	41d010ef          	jal	8000261c <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	00025797          	auipc	a5,0x25
    80000a34:	bb878793          	addi	a5,a5,-1096 # 800255e8 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	00013917          	auipc	s2,0x13
    80000a50:	02c90913          	addi	s2,s2,44 # 80013a78 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00007517          	auipc	a0,0x7
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80008038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00007597          	auipc	a1,0x7
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80008040 <etext+0x40>
    80000ada:	00013517          	auipc	a0,0x13
    80000ade:	f9e50513          	addi	a0,a0,-98 # 80013a78 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00025517          	auipc	a0,0x25
    80000aee:	afe50513          	addi	a0,a0,-1282 # 800255e8 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	00013497          	auipc	s1,0x13
    80000b0c:	f7048493          	addi	s1,s1,-144 # 80013a78 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00013517          	auipc	a0,0x13
    80000b20:	f5c50513          	addi	a0,a0,-164 # 80013a78 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	00013517          	auipc	a0,0x13
    80000b44:	f3850513          	addi	a0,a0,-200 # 80013a78 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	663000ef          	jal	800019da <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	635000ef          	jal	800019da <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	62d000ef          	jal	800019da <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	619000ef          	jal	800019da <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000bf6:	5e5000ef          	jal	800019da <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00007517          	auipc	a0,0x7
    80000c0a:	44250513          	addi	a0,a0,1090 # 80008048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	5c1000ef          	jal	800019da <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00007517          	auipc	a0,0x7
    80000c52:	40250513          	addi	a0,a0,1026 # 80008050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00007517          	auipc	a0,0x7
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80008068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000c80:	0310000f          	fence	rw,w
    80000c84:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00007517          	auipc	a0,0x7
    80000c9a:	3da50513          	addi	a0,a0,986 # 80008070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd9a19>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	387000ef          	jal	800019ca <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	0000b717          	auipc	a4,0xb
    80000e4c:	b3870713          	addi	a4,a4,-1224 # 8000b980 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e5c:	36f000ef          	jal	800019ca <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00007517          	auipc	a0,0x7
    80000e66:	23650513          	addi	a0,a0,566 # 80008098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	6ef010ef          	jal	80002d60 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	432050ef          	jal	800062a8 <plicinithart>
  }

  scheduler();        
    80000e7a:	5a0010ef          	jal	8000241a <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00007517          	auipc	a0,0x7
    80000e8a:	1f250513          	addi	a0,a0,498 # 80008078 <etext+0x78>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00007517          	auipc	a0,0x7
    80000e96:	1ee50513          	addi	a0,a0,494 # 80008080 <etext+0x80>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    printf("\n");
    80000e9e:	00007517          	auipc	a0,0x7
    80000ea2:	1da50513          	addi	a0,a0,474 # 80008078 <etext+0x78>
    80000ea6:	e54ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eaa:	c21ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eae:	2ca000ef          	jal	80001178 <kvminit>
    kvminithart();   // turn on paging
    80000eb2:	03c000ef          	jal	80000eee <kvminithart>
    procinit();      // process table
    80000eb6:	25b000ef          	jal	80001910 <procinit>
    trapinit();      // trap vectors
    80000eba:	683010ef          	jal	80002d3c <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	6a3010ef          	jal	80002d60 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	3cc050ef          	jal	8000628e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	3e2050ef          	jal	800062a8 <plicinithart>
    binit();         // buffer cache
    80000eca:	2a9020ef          	jal	80003972 <binit>
    iinit();         // inode table
    80000ece:	02e030ef          	jal	80003efc <iinit>
    fileinit();      // file table
    80000ed2:	721030ef          	jal	80004df2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	4c2050ef          	jal	80006398 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	116010ef          	jal	80001ff0 <userinit>
    __sync_synchronize();
    80000ede:	0330000f          	fence	rw,rw
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	0000b717          	auipc	a4,0xb
    80000ee8:	a8f72e23          	sw	a5,-1380(a4) # 8000b980 <started>
    80000eec:	b779                	j	80000e7a <main+0x3e>

0000000080000eee <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e422                	sd	s0,8(sp)
    80000ef2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ef4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ef8:	0000b797          	auipc	a5,0xb
    80000efc:	a907b783          	ld	a5,-1392(a5) # 8000b988 <kernel_pagetable>
    80000f00:	83b1                	srli	a5,a5,0xc
    80000f02:	577d                	li	a4,-1
    80000f04:	177e                	slli	a4,a4,0x3f
    80000f06:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f08:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f0c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f16:	7139                	addi	sp,sp,-64
    80000f18:	fc06                	sd	ra,56(sp)
    80000f1a:	f822                	sd	s0,48(sp)
    80000f1c:	f426                	sd	s1,40(sp)
    80000f1e:	f04a                	sd	s2,32(sp)
    80000f20:	ec4e                	sd	s3,24(sp)
    80000f22:	e852                	sd	s4,16(sp)
    80000f24:	e456                	sd	s5,8(sp)
    80000f26:	e05a                	sd	s6,0(sp)
    80000f28:	0080                	addi	s0,sp,64
    80000f2a:	84aa                	mv	s1,a0
    80000f2c:	89ae                	mv	s3,a1
    80000f2e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f30:	57fd                	li	a5,-1
    80000f32:	83e9                	srli	a5,a5,0x1a
    80000f34:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f36:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f38:	02b7fc63          	bgeu	a5,a1,80000f70 <walk+0x5a>
    panic("walk");
    80000f3c:	00007517          	auipc	a0,0x7
    80000f40:	17450513          	addi	a0,a0,372 # 800080b0 <etext+0xb0>
    80000f44:	89dff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f48:	060a8263          	beqz	s5,80000fac <walk+0x96>
    80000f4c:	bb3ff0ef          	jal	80000afe <kalloc>
    80000f50:	84aa                	mv	s1,a0
    80000f52:	c139                	beqz	a0,80000f98 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f54:	6605                	lui	a2,0x1
    80000f56:	4581                	li	a1,0
    80000f58:	d4bff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f5c:	00c4d793          	srli	a5,s1,0xc
    80000f60:	07aa                	slli	a5,a5,0xa
    80000f62:	0017e793          	ori	a5,a5,1
    80000f66:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd9a0f>
    80000f6c:	036a0063          	beq	s4,s6,80000f8c <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f70:	0149d933          	srl	s2,s3,s4
    80000f74:	1ff97913          	andi	s2,s2,511
    80000f78:	090e                	slli	s2,s2,0x3
    80000f7a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f7c:	00093483          	ld	s1,0(s2)
    80000f80:	0014f793          	andi	a5,s1,1
    80000f84:	d3f1                	beqz	a5,80000f48 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f86:	80a9                	srli	s1,s1,0xa
    80000f88:	04b2                	slli	s1,s1,0xc
    80000f8a:	b7c5                	j	80000f6a <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f8c:	00c9d513          	srli	a0,s3,0xc
    80000f90:	1ff57513          	andi	a0,a0,511
    80000f94:	050e                	slli	a0,a0,0x3
    80000f96:	9526                	add	a0,a0,s1
}
    80000f98:	70e2                	ld	ra,56(sp)
    80000f9a:	7442                	ld	s0,48(sp)
    80000f9c:	74a2                	ld	s1,40(sp)
    80000f9e:	7902                	ld	s2,32(sp)
    80000fa0:	69e2                	ld	s3,24(sp)
    80000fa2:	6a42                	ld	s4,16(sp)
    80000fa4:	6aa2                	ld	s5,8(sp)
    80000fa6:	6b02                	ld	s6,0(sp)
    80000fa8:	6121                	addi	sp,sp,64
    80000faa:	8082                	ret
        return 0;
    80000fac:	4501                	li	a0,0
    80000fae:	b7ed                	j	80000f98 <walk+0x82>

0000000080000fb0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fb0:	57fd                	li	a5,-1
    80000fb2:	83e9                	srli	a5,a5,0x1a
    80000fb4:	00b7f463          	bgeu	a5,a1,80000fbc <walkaddr+0xc>
    return 0;
    80000fb8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fba:	8082                	ret
{
    80000fbc:	1141                	addi	sp,sp,-16
    80000fbe:	e406                	sd	ra,8(sp)
    80000fc0:	e022                	sd	s0,0(sp)
    80000fc2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fc4:	4601                	li	a2,0
    80000fc6:	f51ff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    80000fca:	c105                	beqz	a0,80000fea <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fcc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fce:	0117f693          	andi	a3,a5,17
    80000fd2:	4745                	li	a4,17
    return 0;
    80000fd4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fd6:	00e68663          	beq	a3,a4,80000fe2 <walkaddr+0x32>
}
    80000fda:	60a2                	ld	ra,8(sp)
    80000fdc:	6402                	ld	s0,0(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  pa = PTE2PA(*pte);
    80000fe2:	83a9                	srli	a5,a5,0xa
    80000fe4:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fe8:	bfcd                	j	80000fda <walkaddr+0x2a>
    return 0;
    80000fea:	4501                	li	a0,0
    80000fec:	b7fd                	j	80000fda <walkaddr+0x2a>

0000000080000fee <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fee:	715d                	addi	sp,sp,-80
    80000ff0:	e486                	sd	ra,72(sp)
    80000ff2:	e0a2                	sd	s0,64(sp)
    80000ff4:	fc26                	sd	s1,56(sp)
    80000ff6:	f84a                	sd	s2,48(sp)
    80000ff8:	f44e                	sd	s3,40(sp)
    80000ffa:	f052                	sd	s4,32(sp)
    80000ffc:	ec56                	sd	s5,24(sp)
    80000ffe:	e85a                	sd	s6,16(sp)
    80001000:	e45e                	sd	s7,8(sp)
    80001002:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001004:	03459793          	slli	a5,a1,0x34
    80001008:	e7a9                	bnez	a5,80001052 <mappages+0x64>
    8000100a:	8aaa                	mv	s5,a0
    8000100c:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000100e:	03461793          	slli	a5,a2,0x34
    80001012:	e7b1                	bnez	a5,8000105e <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001014:	ca39                	beqz	a2,8000106a <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001016:	77fd                	lui	a5,0xfffff
    80001018:	963e                	add	a2,a2,a5
    8000101a:	00b609b3          	add	s3,a2,a1
  a = va;
    8000101e:	892e                	mv	s2,a1
    80001020:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001024:	6b85                	lui	s7,0x1
    80001026:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000102a:	4605                	li	a2,1
    8000102c:	85ca                	mv	a1,s2
    8000102e:	8556                	mv	a0,s5
    80001030:	ee7ff0ef          	jal	80000f16 <walk>
    80001034:	c539                	beqz	a0,80001082 <mappages+0x94>
    if(*pte & PTE_V)
    80001036:	611c                	ld	a5,0(a0)
    80001038:	8b85                	andi	a5,a5,1
    8000103a:	ef95                	bnez	a5,80001076 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000103c:	80b1                	srli	s1,s1,0xc
    8000103e:	04aa                	slli	s1,s1,0xa
    80001040:	0164e4b3          	or	s1,s1,s6
    80001044:	0014e493          	ori	s1,s1,1
    80001048:	e104                	sd	s1,0(a0)
    if(a == last)
    8000104a:	05390863          	beq	s2,s3,8000109a <mappages+0xac>
    a += PGSIZE;
    8000104e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	bfd9                	j	80001026 <mappages+0x38>
    panic("mappages: va not aligned");
    80001052:	00007517          	auipc	a0,0x7
    80001056:	06650513          	addi	a0,a0,102 # 800080b8 <etext+0xb8>
    8000105a:	f86ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    8000105e:	00007517          	auipc	a0,0x7
    80001062:	07a50513          	addi	a0,a0,122 # 800080d8 <etext+0xd8>
    80001066:	f7aff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000106a:	00007517          	auipc	a0,0x7
    8000106e:	08e50513          	addi	a0,a0,142 # 800080f8 <etext+0xf8>
    80001072:	f6eff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    80001076:	00007517          	auipc	a0,0x7
    8000107a:	09250513          	addi	a0,a0,146 # 80008108 <etext+0x108>
    8000107e:	f62ff0ef          	jal	800007e0 <panic>
      return -1;
    80001082:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001084:	60a6                	ld	ra,72(sp)
    80001086:	6406                	ld	s0,64(sp)
    80001088:	74e2                	ld	s1,56(sp)
    8000108a:	7942                	ld	s2,48(sp)
    8000108c:	79a2                	ld	s3,40(sp)
    8000108e:	7a02                	ld	s4,32(sp)
    80001090:	6ae2                	ld	s5,24(sp)
    80001092:	6b42                	ld	s6,16(sp)
    80001094:	6ba2                	ld	s7,8(sp)
    80001096:	6161                	addi	sp,sp,80
    80001098:	8082                	ret
  return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7e5                	j	80001084 <mappages+0x96>

000000008000109e <kvmmap>:
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
    800010a6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010a8:	86b2                	mv	a3,a2
    800010aa:	863e                	mv	a2,a5
    800010ac:	f43ff0ef          	jal	80000fee <mappages>
    800010b0:	e509                	bnez	a0,800010ba <kvmmap+0x1c>
}
    800010b2:	60a2                	ld	ra,8(sp)
    800010b4:	6402                	ld	s0,0(sp)
    800010b6:	0141                	addi	sp,sp,16
    800010b8:	8082                	ret
    panic("kvmmap");
    800010ba:	00007517          	auipc	a0,0x7
    800010be:	05e50513          	addi	a0,a0,94 # 80008118 <etext+0x118>
    800010c2:	f1eff0ef          	jal	800007e0 <panic>

00000000800010c6 <kvmmake>:
{
    800010c6:	1101                	addi	sp,sp,-32
    800010c8:	ec06                	sd	ra,24(sp)
    800010ca:	e822                	sd	s0,16(sp)
    800010cc:	e426                	sd	s1,8(sp)
    800010ce:	e04a                	sd	s2,0(sp)
    800010d0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010d2:	a2dff0ef          	jal	80000afe <kalloc>
    800010d6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010d8:	6605                	lui	a2,0x1
    800010da:	4581                	li	a1,0
    800010dc:	bc7ff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010e0:	4719                	li	a4,6
    800010e2:	6685                	lui	a3,0x1
    800010e4:	10000637          	lui	a2,0x10000
    800010e8:	100005b7          	lui	a1,0x10000
    800010ec:	8526                	mv	a0,s1
    800010ee:	fb1ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010f2:	4719                	li	a4,6
    800010f4:	6685                	lui	a3,0x1
    800010f6:	10001637          	lui	a2,0x10001
    800010fa:	100015b7          	lui	a1,0x10001
    800010fe:	8526                	mv	a0,s1
    80001100:	f9fff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001104:	4719                	li	a4,6
    80001106:	040006b7          	lui	a3,0x4000
    8000110a:	0c000637          	lui	a2,0xc000
    8000110e:	0c0005b7          	lui	a1,0xc000
    80001112:	8526                	mv	a0,s1
    80001114:	f8bff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001118:	00007917          	auipc	s2,0x7
    8000111c:	ee890913          	addi	s2,s2,-280 # 80008000 <etext>
    80001120:	4729                	li	a4,10
    80001122:	80007697          	auipc	a3,0x80007
    80001126:	ede68693          	addi	a3,a3,-290 # 8000 <_entry-0x7fff8000>
    8000112a:	4605                	li	a2,1
    8000112c:	067e                	slli	a2,a2,0x1f
    8000112e:	85b2                	mv	a1,a2
    80001130:	8526                	mv	a0,s1
    80001132:	f6dff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001136:	46c5                	li	a3,17
    80001138:	06ee                	slli	a3,a3,0x1b
    8000113a:	4719                	li	a4,6
    8000113c:	412686b3          	sub	a3,a3,s2
    80001140:	864a                	mv	a2,s2
    80001142:	85ca                	mv	a1,s2
    80001144:	8526                	mv	a0,s1
    80001146:	f59ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000114a:	4729                	li	a4,10
    8000114c:	6685                	lui	a3,0x1
    8000114e:	00006617          	auipc	a2,0x6
    80001152:	eb260613          	addi	a2,a2,-334 # 80007000 <_trampoline>
    80001156:	040005b7          	lui	a1,0x4000
    8000115a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000115c:	05b2                	slli	a1,a1,0xc
    8000115e:	8526                	mv	a0,s1
    80001160:	f3fff0ef          	jal	8000109e <kvmmap>
  proc_mapstacks(kpgtbl);
    80001164:	8526                	mv	a0,s1
    80001166:	712000ef          	jal	80001878 <proc_mapstacks>
}
    8000116a:	8526                	mv	a0,s1
    8000116c:	60e2                	ld	ra,24(sp)
    8000116e:	6442                	ld	s0,16(sp)
    80001170:	64a2                	ld	s1,8(sp)
    80001172:	6902                	ld	s2,0(sp)
    80001174:	6105                	addi	sp,sp,32
    80001176:	8082                	ret

0000000080001178 <kvminit>:
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001180:	f47ff0ef          	jal	800010c6 <kvmmake>
    80001184:	0000b797          	auipc	a5,0xb
    80001188:	80a7b223          	sd	a0,-2044(a5) # 8000b988 <kernel_pagetable>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret

0000000080001194 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001194:	1101                	addi	sp,sp,-32
    80001196:	ec06                	sd	ra,24(sp)
    80001198:	e822                	sd	s0,16(sp)
    8000119a:	e426                	sd	s1,8(sp)
    8000119c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000119e:	961ff0ef          	jal	80000afe <kalloc>
    800011a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011a4:	c509                	beqz	a0,800011ae <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011a6:	6605                	lui	a2,0x1
    800011a8:	4581                	li	a1,0
    800011aa:	af9ff0ef          	jal	80000ca2 <memset>
  return pagetable;
}
    800011ae:	8526                	mv	a0,s1
    800011b0:	60e2                	ld	ra,24(sp)
    800011b2:	6442                	ld	s0,16(sp)
    800011b4:	64a2                	ld	s1,8(sp)
    800011b6:	6105                	addi	sp,sp,32
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	7139                	addi	sp,sp,-64
    800011bc:	fc06                	sd	ra,56(sp)
    800011be:	f822                	sd	s0,48(sp)
    800011c0:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e38d                	bnez	a5,800011e8 <uvmunmap+0x2e>
    800011c8:	f04a                	sd	s2,32(sp)
    800011ca:	ec4e                	sd	s3,24(sp)
    800011cc:	e852                	sd	s4,16(sp)
    800011ce:	e456                	sd	s5,8(sp)
    800011d0:	e05a                	sd	s6,0(sp)
    800011d2:	8a2a                	mv	s4,a0
    800011d4:	892e                	mv	s2,a1
    800011d6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011d8:	0632                	slli	a2,a2,0xc
    800011da:	00b609b3          	add	s3,a2,a1
    800011de:	6b05                	lui	s6,0x1
    800011e0:	0535f963          	bgeu	a1,s3,80001232 <uvmunmap+0x78>
    800011e4:	f426                	sd	s1,40(sp)
    800011e6:	a015                	j	8000120a <uvmunmap+0x50>
    800011e8:	f426                	sd	s1,40(sp)
    800011ea:	f04a                	sd	s2,32(sp)
    800011ec:	ec4e                	sd	s3,24(sp)
    800011ee:	e852                	sd	s4,16(sp)
    800011f0:	e456                	sd	s5,8(sp)
    800011f2:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011f4:	00007517          	auipc	a0,0x7
    800011f8:	f2c50513          	addi	a0,a0,-212 # 80008120 <etext+0x120>
    800011fc:	de4ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001200:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001204:	995a                	add	s2,s2,s6
    80001206:	03397563          	bgeu	s2,s3,80001230 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000120a:	4601                	li	a2,0
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8552                	mv	a0,s4
    80001210:	d07ff0ef          	jal	80000f16 <walk>
    80001214:	84aa                	mv	s1,a0
    80001216:	d57d                	beqz	a0,80001204 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001218:	611c                	ld	a5,0(a0)
    8000121a:	0017f713          	andi	a4,a5,1
    8000121e:	d37d                	beqz	a4,80001204 <uvmunmap+0x4a>
    if(do_free){
    80001220:	fe0a80e3          	beqz	s5,80001200 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001224:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001226:	00c79513          	slli	a0,a5,0xc
    8000122a:	ff2ff0ef          	jal	80000a1c <kfree>
    8000122e:	bfc9                	j	80001200 <uvmunmap+0x46>
    80001230:	74a2                	ld	s1,40(sp)
    80001232:	7902                	ld	s2,32(sp)
    80001234:	69e2                	ld	s3,24(sp)
    80001236:	6a42                	ld	s4,16(sp)
    80001238:	6aa2                	ld	s5,8(sp)
    8000123a:	6b02                	ld	s6,0(sp)
  }
}
    8000123c:	70e2                	ld	ra,56(sp)
    8000123e:	7442                	ld	s0,48(sp)
    80001240:	6121                	addi	sp,sp,64
    80001242:	8082                	ret

0000000080001244 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001244:	1101                	addi	sp,sp,-32
    80001246:	ec06                	sd	ra,24(sp)
    80001248:	e822                	sd	s0,16(sp)
    8000124a:	e426                	sd	s1,8(sp)
    8000124c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000124e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001250:	00b67d63          	bgeu	a2,a1,8000126a <uvmdealloc+0x26>
    80001254:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001256:	6785                	lui	a5,0x1
    80001258:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000125a:	00f60733          	add	a4,a2,a5
    8000125e:	76fd                	lui	a3,0xfffff
    80001260:	8f75                	and	a4,a4,a3
    80001262:	97ae                	add	a5,a5,a1
    80001264:	8ff5                	and	a5,a5,a3
    80001266:	00f76863          	bltu	a4,a5,80001276 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000126a:	8526                	mv	a0,s1
    8000126c:	60e2                	ld	ra,24(sp)
    8000126e:	6442                	ld	s0,16(sp)
    80001270:	64a2                	ld	s1,8(sp)
    80001272:	6105                	addi	sp,sp,32
    80001274:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001276:	8f99                	sub	a5,a5,a4
    80001278:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000127a:	4685                	li	a3,1
    8000127c:	0007861b          	sext.w	a2,a5
    80001280:	85ba                	mv	a1,a4
    80001282:	f39ff0ef          	jal	800011ba <uvmunmap>
    80001286:	b7d5                	j	8000126a <uvmdealloc+0x26>

0000000080001288 <uvmalloc>:
  if(newsz < oldsz)
    80001288:	08b66f63          	bltu	a2,a1,80001326 <uvmalloc+0x9e>
{
    8000128c:	7139                	addi	sp,sp,-64
    8000128e:	fc06                	sd	ra,56(sp)
    80001290:	f822                	sd	s0,48(sp)
    80001292:	ec4e                	sd	s3,24(sp)
    80001294:	e852                	sd	s4,16(sp)
    80001296:	e456                	sd	s5,8(sp)
    80001298:	0080                	addi	s0,sp,64
    8000129a:	8aaa                	mv	s5,a0
    8000129c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000129e:	6785                	lui	a5,0x1
    800012a0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012a2:	95be                	add	a1,a1,a5
    800012a4:	77fd                	lui	a5,0xfffff
    800012a6:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012aa:	08c9f063          	bgeu	s3,a2,8000132a <uvmalloc+0xa2>
    800012ae:	f426                	sd	s1,40(sp)
    800012b0:	f04a                	sd	s2,32(sp)
    800012b2:	e05a                	sd	s6,0(sp)
    800012b4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012b6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012ba:	845ff0ef          	jal	80000afe <kalloc>
    800012be:	84aa                	mv	s1,a0
    if(mem == 0){
    800012c0:	c515                	beqz	a0,800012ec <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012c2:	6605                	lui	a2,0x1
    800012c4:	4581                	li	a1,0
    800012c6:	9ddff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012ca:	875a                	mv	a4,s6
    800012cc:	86a6                	mv	a3,s1
    800012ce:	6605                	lui	a2,0x1
    800012d0:	85ca                	mv	a1,s2
    800012d2:	8556                	mv	a0,s5
    800012d4:	d1bff0ef          	jal	80000fee <mappages>
    800012d8:	e915                	bnez	a0,8000130c <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012da:	6785                	lui	a5,0x1
    800012dc:	993e                	add	s2,s2,a5
    800012de:	fd496ee3          	bltu	s2,s4,800012ba <uvmalloc+0x32>
  return newsz;
    800012e2:	8552                	mv	a0,s4
    800012e4:	74a2                	ld	s1,40(sp)
    800012e6:	7902                	ld	s2,32(sp)
    800012e8:	6b02                	ld	s6,0(sp)
    800012ea:	a811                	j	800012fe <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012ec:	864e                	mv	a2,s3
    800012ee:	85ca                	mv	a1,s2
    800012f0:	8556                	mv	a0,s5
    800012f2:	f53ff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    800012f6:	4501                	li	a0,0
    800012f8:	74a2                	ld	s1,40(sp)
    800012fa:	7902                	ld	s2,32(sp)
    800012fc:	6b02                	ld	s6,0(sp)
}
    800012fe:	70e2                	ld	ra,56(sp)
    80001300:	7442                	ld	s0,48(sp)
    80001302:	69e2                	ld	s3,24(sp)
    80001304:	6a42                	ld	s4,16(sp)
    80001306:	6aa2                	ld	s5,8(sp)
    80001308:	6121                	addi	sp,sp,64
    8000130a:	8082                	ret
      kfree(mem);
    8000130c:	8526                	mv	a0,s1
    8000130e:	f0eff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001312:	864e                	mv	a2,s3
    80001314:	85ca                	mv	a1,s2
    80001316:	8556                	mv	a0,s5
    80001318:	f2dff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    8000131c:	4501                	li	a0,0
    8000131e:	74a2                	ld	s1,40(sp)
    80001320:	7902                	ld	s2,32(sp)
    80001322:	6b02                	ld	s6,0(sp)
    80001324:	bfe9                	j	800012fe <uvmalloc+0x76>
    return oldsz;
    80001326:	852e                	mv	a0,a1
}
    80001328:	8082                	ret
  return newsz;
    8000132a:	8532                	mv	a0,a2
    8000132c:	bfc9                	j	800012fe <uvmalloc+0x76>

000000008000132e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000132e:	7179                	addi	sp,sp,-48
    80001330:	f406                	sd	ra,40(sp)
    80001332:	f022                	sd	s0,32(sp)
    80001334:	ec26                	sd	s1,24(sp)
    80001336:	e84a                	sd	s2,16(sp)
    80001338:	e44e                	sd	s3,8(sp)
    8000133a:	e052                	sd	s4,0(sp)
    8000133c:	1800                	addi	s0,sp,48
    8000133e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001340:	84aa                	mv	s1,a0
    80001342:	6905                	lui	s2,0x1
    80001344:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001346:	4985                	li	s3,1
    80001348:	a819                	j	8000135e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000134a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000134c:	00c79513          	slli	a0,a5,0xc
    80001350:	fdfff0ef          	jal	8000132e <freewalk>
      pagetable[i] = 0;
    80001354:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001358:	04a1                	addi	s1,s1,8
    8000135a:	01248f63          	beq	s1,s2,80001378 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000135e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001360:	00f7f713          	andi	a4,a5,15
    80001364:	ff3703e3          	beq	a4,s3,8000134a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001368:	8b85                	andi	a5,a5,1
    8000136a:	d7fd                	beqz	a5,80001358 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000136c:	00007517          	auipc	a0,0x7
    80001370:	dcc50513          	addi	a0,a0,-564 # 80008138 <etext+0x138>
    80001374:	c6cff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001378:	8552                	mv	a0,s4
    8000137a:	ea2ff0ef          	jal	80000a1c <kfree>
}
    8000137e:	70a2                	ld	ra,40(sp)
    80001380:	7402                	ld	s0,32(sp)
    80001382:	64e2                	ld	s1,24(sp)
    80001384:	6942                	ld	s2,16(sp)
    80001386:	69a2                	ld	s3,8(sp)
    80001388:	6a02                	ld	s4,0(sp)
    8000138a:	6145                	addi	sp,sp,48
    8000138c:	8082                	ret

000000008000138e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000138e:	1101                	addi	sp,sp,-32
    80001390:	ec06                	sd	ra,24(sp)
    80001392:	e822                	sd	s0,16(sp)
    80001394:	e426                	sd	s1,8(sp)
    80001396:	1000                	addi	s0,sp,32
    80001398:	84aa                	mv	s1,a0
  if(sz > 0)
    8000139a:	e989                	bnez	a1,800013ac <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000139c:	8526                	mv	a0,s1
    8000139e:	f91ff0ef          	jal	8000132e <freewalk>
}
    800013a2:	60e2                	ld	ra,24(sp)
    800013a4:	6442                	ld	s0,16(sp)
    800013a6:	64a2                	ld	s1,8(sp)
    800013a8:	6105                	addi	sp,sp,32
    800013aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013ac:	6785                	lui	a5,0x1
    800013ae:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013b0:	95be                	add	a1,a1,a5
    800013b2:	4685                	li	a3,1
    800013b4:	00c5d613          	srli	a2,a1,0xc
    800013b8:	4581                	li	a1,0
    800013ba:	e01ff0ef          	jal	800011ba <uvmunmap>
    800013be:	bff9                	j	8000139c <uvmfree+0xe>

00000000800013c0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013c0:	ce49                	beqz	a2,8000145a <uvmcopy+0x9a>
{
    800013c2:	715d                	addi	sp,sp,-80
    800013c4:	e486                	sd	ra,72(sp)
    800013c6:	e0a2                	sd	s0,64(sp)
    800013c8:	fc26                	sd	s1,56(sp)
    800013ca:	f84a                	sd	s2,48(sp)
    800013cc:	f44e                	sd	s3,40(sp)
    800013ce:	f052                	sd	s4,32(sp)
    800013d0:	ec56                	sd	s5,24(sp)
    800013d2:	e85a                	sd	s6,16(sp)
    800013d4:	e45e                	sd	s7,8(sp)
    800013d6:	0880                	addi	s0,sp,80
    800013d8:	8aaa                	mv	s5,a0
    800013da:	8b2e                	mv	s6,a1
    800013dc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800013de:	4481                	li	s1,0
    800013e0:	a029                	j	800013ea <uvmcopy+0x2a>
    800013e2:	6785                	lui	a5,0x1
    800013e4:	94be                	add	s1,s1,a5
    800013e6:	0544fe63          	bgeu	s1,s4,80001442 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800013ea:	4601                	li	a2,0
    800013ec:	85a6                	mv	a1,s1
    800013ee:	8556                	mv	a0,s5
    800013f0:	b27ff0ef          	jal	80000f16 <walk>
    800013f4:	d57d                	beqz	a0,800013e2 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800013f6:	6118                	ld	a4,0(a0)
    800013f8:	00177793          	andi	a5,a4,1
    800013fc:	d3fd                	beqz	a5,800013e2 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013fe:	00a75593          	srli	a1,a4,0xa
    80001402:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001406:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000140a:	ef4ff0ef          	jal	80000afe <kalloc>
    8000140e:	89aa                	mv	s3,a0
    80001410:	c105                	beqz	a0,80001430 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001412:	6605                	lui	a2,0x1
    80001414:	85de                	mv	a1,s7
    80001416:	8e9ff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000141a:	874a                	mv	a4,s2
    8000141c:	86ce                	mv	a3,s3
    8000141e:	6605                	lui	a2,0x1
    80001420:	85a6                	mv	a1,s1
    80001422:	855a                	mv	a0,s6
    80001424:	bcbff0ef          	jal	80000fee <mappages>
    80001428:	dd4d                	beqz	a0,800013e2 <uvmcopy+0x22>
      kfree(mem);
    8000142a:	854e                	mv	a0,s3
    8000142c:	df0ff0ef          	jal	80000a1c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001430:	4685                	li	a3,1
    80001432:	00c4d613          	srli	a2,s1,0xc
    80001436:	4581                	li	a1,0
    80001438:	855a                	mv	a0,s6
    8000143a:	d81ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000143e:	557d                	li	a0,-1
    80001440:	a011                	j	80001444 <uvmcopy+0x84>
  return 0;
    80001442:	4501                	li	a0,0
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
  return 0;
    8000145a:	4501                	li	a0,0
}
    8000145c:	8082                	ret

000000008000145e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000145e:	1141                	addi	sp,sp,-16
    80001460:	e406                	sd	ra,8(sp)
    80001462:	e022                	sd	s0,0(sp)
    80001464:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001466:	4601                	li	a2,0
    80001468:	aafff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    8000146c:	c901                	beqz	a0,8000147c <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000146e:	611c                	ld	a5,0(a0)
    80001470:	9bbd                	andi	a5,a5,-17
    80001472:	e11c                	sd	a5,0(a0)
}
    80001474:	60a2                	ld	ra,8(sp)
    80001476:	6402                	ld	s0,0(sp)
    80001478:	0141                	addi	sp,sp,16
    8000147a:	8082                	ret
    panic("uvmclear");
    8000147c:	00007517          	auipc	a0,0x7
    80001480:	ccc50513          	addi	a0,a0,-820 # 80008148 <etext+0x148>
    80001484:	b5cff0ef          	jal	800007e0 <panic>

0000000080001488 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001488:	c6dd                	beqz	a3,80001536 <copyinstr+0xae>
{
    8000148a:	715d                	addi	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	addi	s0,sp,80
    800014a0:	8a2a                	mv	s4,a0
    800014a2:	8b2e                	mv	s6,a1
    800014a4:	8bb2                	mv	s7,a2
    800014a6:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014a8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014aa:	6985                	lui	s3,0x1
    800014ac:	a825                	j	800014e4 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014ae:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014b2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014b4:	37fd                	addiw	a5,a5,-1
    800014b6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014ba:	60a6                	ld	ra,72(sp)
    800014bc:	6406                	ld	s0,64(sp)
    800014be:	74e2                	ld	s1,56(sp)
    800014c0:	7942                	ld	s2,48(sp)
    800014c2:	79a2                	ld	s3,40(sp)
    800014c4:	7a02                	ld	s4,32(sp)
    800014c6:	6ae2                	ld	s5,24(sp)
    800014c8:	6b42                	ld	s6,16(sp)
    800014ca:	6ba2                	ld	s7,8(sp)
    800014cc:	6161                	addi	sp,sp,80
    800014ce:	8082                	ret
    800014d0:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014d4:	9742                	add	a4,a4,a6
      --max;
    800014d6:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014da:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800014de:	04e58463          	beq	a1,a4,80001526 <copyinstr+0x9e>
{
    800014e2:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014e4:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014e8:	85a6                	mv	a1,s1
    800014ea:	8552                	mv	a0,s4
    800014ec:	ac5ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0)
    800014f0:	cd0d                	beqz	a0,8000152a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800014f2:	417486b3          	sub	a3,s1,s7
    800014f6:	96ce                	add	a3,a3,s3
    if(n > max)
    800014f8:	00d97363          	bgeu	s2,a3,800014fe <copyinstr+0x76>
    800014fc:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800014fe:	955e                	add	a0,a0,s7
    80001500:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001502:	c695                	beqz	a3,8000152e <copyinstr+0xa6>
    80001504:	87da                	mv	a5,s6
    80001506:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001508:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000150c:	96da                	add	a3,a3,s6
    8000150e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001510:	00f60733          	add	a4,a2,a5
    80001514:	00074703          	lbu	a4,0(a4)
    80001518:	db59                	beqz	a4,800014ae <copyinstr+0x26>
        *dst = *p;
    8000151a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000151e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001520:	fed797e3          	bne	a5,a3,8000150e <copyinstr+0x86>
    80001524:	b775                	j	800014d0 <copyinstr+0x48>
    80001526:	4781                	li	a5,0
    80001528:	b771                	j	800014b4 <copyinstr+0x2c>
      return -1;
    8000152a:	557d                	li	a0,-1
    8000152c:	b779                	j	800014ba <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000152e:	6b85                	lui	s7,0x1
    80001530:	9ba6                	add	s7,s7,s1
    80001532:	87da                	mv	a5,s6
    80001534:	b77d                	j	800014e2 <copyinstr+0x5a>
  int got_null = 0;
    80001536:	4781                	li	a5,0
  if(got_null){
    80001538:	37fd                	addiw	a5,a5,-1
    8000153a:	0007851b          	sext.w	a0,a5
}
    8000153e:	8082                	ret

0000000080001540 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001540:	1141                	addi	sp,sp,-16
    80001542:	e406                	sd	ra,8(sp)
    80001544:	e022                	sd	s0,0(sp)
    80001546:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001548:	4601                	li	a2,0
    8000154a:	9cdff0ef          	jal	80000f16 <walk>
  if (pte == 0) {
    8000154e:	c519                	beqz	a0,8000155c <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001550:	6108                	ld	a0,0(a0)
    80001552:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001554:	60a2                	ld	ra,8(sp)
    80001556:	6402                	ld	s0,0(sp)
    80001558:	0141                	addi	sp,sp,16
    8000155a:	8082                	ret
    return 0;
    8000155c:	4501                	li	a0,0
    8000155e:	bfdd                	j	80001554 <ismapped+0x14>

0000000080001560 <vmfault>:
{
    80001560:	7179                	addi	sp,sp,-48
    80001562:	f406                	sd	ra,40(sp)
    80001564:	f022                	sd	s0,32(sp)
    80001566:	ec26                	sd	s1,24(sp)
    80001568:	e44e                	sd	s3,8(sp)
    8000156a:	1800                	addi	s0,sp,48
    8000156c:	89aa                	mv	s3,a0
    8000156e:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001570:	486000ef          	jal	800019f6 <myproc>
  if (va >= p->sz)
    80001574:	693c                	ld	a5,80(a0)
    80001576:	00f4ea63          	bltu	s1,a5,8000158a <vmfault+0x2a>
    return 0;
    8000157a:	4981                	li	s3,0
}
    8000157c:	854e                	mv	a0,s3
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	69a2                	ld	s3,8(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret
    8000158a:	e84a                	sd	s2,16(sp)
    8000158c:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000158e:	77fd                	lui	a5,0xfffff
    80001590:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001592:	85a6                	mv	a1,s1
    80001594:	854e                	mv	a0,s3
    80001596:	fabff0ef          	jal	80001540 <ismapped>
    return 0;
    8000159a:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000159c:	c119                	beqz	a0,800015a2 <vmfault+0x42>
    8000159e:	6942                	ld	s2,16(sp)
    800015a0:	bff1                	j	8000157c <vmfault+0x1c>
    800015a2:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015a4:	d5aff0ef          	jal	80000afe <kalloc>
    800015a8:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015aa:	c90d                	beqz	a0,800015dc <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015ac:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	4581                	li	a1,0
    800015b2:	ef0ff0ef          	jal	80000ca2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015b6:	4759                	li	a4,22
    800015b8:	86d2                	mv	a3,s4
    800015ba:	6605                	lui	a2,0x1
    800015bc:	85a6                	mv	a1,s1
    800015be:	05893503          	ld	a0,88(s2)
    800015c2:	a2dff0ef          	jal	80000fee <mappages>
    800015c6:	e501                	bnez	a0,800015ce <vmfault+0x6e>
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	6a02                	ld	s4,0(sp)
    800015cc:	bf45                	j	8000157c <vmfault+0x1c>
    kfree((void *)mem);
    800015ce:	8552                	mv	a0,s4
    800015d0:	c4cff0ef          	jal	80000a1c <kfree>
    return 0;
    800015d4:	4981                	li	s3,0
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	6a02                	ld	s4,0(sp)
    800015da:	b74d                	j	8000157c <vmfault+0x1c>
    800015dc:	6942                	ld	s2,16(sp)
    800015de:	6a02                	ld	s4,0(sp)
    800015e0:	bf71                	j	8000157c <vmfault+0x1c>

00000000800015e2 <copyout>:
  while(len > 0){
    800015e2:	c2cd                	beqz	a3,80001684 <copyout+0xa2>
{
    800015e4:	711d                	addi	sp,sp,-96
    800015e6:	ec86                	sd	ra,88(sp)
    800015e8:	e8a2                	sd	s0,80(sp)
    800015ea:	e4a6                	sd	s1,72(sp)
    800015ec:	f852                	sd	s4,48(sp)
    800015ee:	f05a                	sd	s6,32(sp)
    800015f0:	ec5e                	sd	s7,24(sp)
    800015f2:	e862                	sd	s8,16(sp)
    800015f4:	1080                	addi	s0,sp,96
    800015f6:	8c2a                	mv	s8,a0
    800015f8:	8b2e                	mv	s6,a1
    800015fa:	8bb2                	mv	s7,a2
    800015fc:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015fe:	74fd                	lui	s1,0xfffff
    80001600:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001602:	57fd                	li	a5,-1
    80001604:	83e9                	srli	a5,a5,0x1a
    80001606:	0897e163          	bltu	a5,s1,80001688 <copyout+0xa6>
    8000160a:	e0ca                	sd	s2,64(sp)
    8000160c:	fc4e                	sd	s3,56(sp)
    8000160e:	f456                	sd	s5,40(sp)
    80001610:	e466                	sd	s9,8(sp)
    80001612:	e06a                	sd	s10,0(sp)
    80001614:	6d05                	lui	s10,0x1
    80001616:	8cbe                	mv	s9,a5
    80001618:	a015                	j	8000163c <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000161a:	409b0533          	sub	a0,s6,s1
    8000161e:	0009861b          	sext.w	a2,s3
    80001622:	85de                	mv	a1,s7
    80001624:	954a                	add	a0,a0,s2
    80001626:	ed8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000162a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000162e:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001630:	040a0363          	beqz	s4,80001676 <copyout+0x94>
    if(va0 >= MAXVA)
    80001634:	055cec63          	bltu	s9,s5,8000168c <copyout+0xaa>
    80001638:	84d6                	mv	s1,s5
    8000163a:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000163c:	85a6                	mv	a1,s1
    8000163e:	8562                	mv	a0,s8
    80001640:	971ff0ef          	jal	80000fb0 <walkaddr>
    80001644:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001646:	e901                	bnez	a0,80001656 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001648:	4601                	li	a2,0
    8000164a:	85a6                	mv	a1,s1
    8000164c:	8562                	mv	a0,s8
    8000164e:	f13ff0ef          	jal	80001560 <vmfault>
    80001652:	892a                	mv	s2,a0
    80001654:	c139                	beqz	a0,8000169a <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001656:	4601                	li	a2,0
    80001658:	85a6                	mv	a1,s1
    8000165a:	8562                	mv	a0,s8
    8000165c:	8bbff0ef          	jal	80000f16 <walk>
    if((*pte & PTE_W) == 0)
    80001660:	611c                	ld	a5,0(a0)
    80001662:	8b91                	andi	a5,a5,4
    80001664:	c3b1                	beqz	a5,800016a8 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001666:	01a48ab3          	add	s5,s1,s10
    8000166a:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000166e:	fb3a76e3          	bgeu	s4,s3,8000161a <copyout+0x38>
    80001672:	89d2                	mv	s3,s4
    80001674:	b75d                	j	8000161a <copyout+0x38>
  return 0;
    80001676:	4501                	li	a0,0
    80001678:	6906                	ld	s2,64(sp)
    8000167a:	79e2                	ld	s3,56(sp)
    8000167c:	7aa2                	ld	s5,40(sp)
    8000167e:	6ca2                	ld	s9,8(sp)
    80001680:	6d02                	ld	s10,0(sp)
    80001682:	a80d                	j	800016b4 <copyout+0xd2>
    80001684:	4501                	li	a0,0
}
    80001686:	8082                	ret
      return -1;
    80001688:	557d                	li	a0,-1
    8000168a:	a02d                	j	800016b4 <copyout+0xd2>
    8000168c:	557d                	li	a0,-1
    8000168e:	6906                	ld	s2,64(sp)
    80001690:	79e2                	ld	s3,56(sp)
    80001692:	7aa2                	ld	s5,40(sp)
    80001694:	6ca2                	ld	s9,8(sp)
    80001696:	6d02                	ld	s10,0(sp)
    80001698:	a831                	j	800016b4 <copyout+0xd2>
        return -1;
    8000169a:	557d                	li	a0,-1
    8000169c:	6906                	ld	s2,64(sp)
    8000169e:	79e2                	ld	s3,56(sp)
    800016a0:	7aa2                	ld	s5,40(sp)
    800016a2:	6ca2                	ld	s9,8(sp)
    800016a4:	6d02                	ld	s10,0(sp)
    800016a6:	a039                	j	800016b4 <copyout+0xd2>
      return -1;
    800016a8:	557d                	li	a0,-1
    800016aa:	6906                	ld	s2,64(sp)
    800016ac:	79e2                	ld	s3,56(sp)
    800016ae:	7aa2                	ld	s5,40(sp)
    800016b0:	6ca2                	ld	s9,8(sp)
    800016b2:	6d02                	ld	s10,0(sp)
}
    800016b4:	60e6                	ld	ra,88(sp)
    800016b6:	6446                	ld	s0,80(sp)
    800016b8:	64a6                	ld	s1,72(sp)
    800016ba:	7a42                	ld	s4,48(sp)
    800016bc:	7b02                	ld	s6,32(sp)
    800016be:	6be2                	ld	s7,24(sp)
    800016c0:	6c42                	ld	s8,16(sp)
    800016c2:	6125                	addi	sp,sp,96
    800016c4:	8082                	ret

00000000800016c6 <copyin>:
  while(len > 0){
    800016c6:	c6c9                	beqz	a3,80001750 <copyin+0x8a>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	e062                	sd	s8,0(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8baa                	mv	s7,a0
    800016e2:	8aae                	mv	s5,a1
    800016e4:	8932                	mv	s2,a2
    800016e6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016e8:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016ea:	6b05                	lui	s6,0x1
    800016ec:	a035                	j	80001718 <copyin+0x52>
    800016ee:	412984b3          	sub	s1,s3,s2
    800016f2:	94da                	add	s1,s1,s6
    if(n > len)
    800016f4:	009a7363          	bgeu	s4,s1,800016fa <copyin+0x34>
    800016f8:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016fa:	413905b3          	sub	a1,s2,s3
    800016fe:	0004861b          	sext.w	a2,s1
    80001702:	95aa                	add	a1,a1,a0
    80001704:	8556                	mv	a0,s5
    80001706:	df8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000170a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000170e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001710:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001714:	020a0163          	beqz	s4,80001736 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001718:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000171c:	85ce                	mv	a1,s3
    8000171e:	855e                	mv	a0,s7
    80001720:	891ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0) {
    80001724:	f569                	bnez	a0,800016ee <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001726:	4601                	li	a2,0
    80001728:	85ce                	mv	a1,s3
    8000172a:	855e                	mv	a0,s7
    8000172c:	e35ff0ef          	jal	80001560 <vmfault>
    80001730:	fd5d                	bnez	a0,800016ee <copyin+0x28>
        return -1;
    80001732:	557d                	li	a0,-1
    80001734:	a011                	j	80001738 <copyin+0x72>
  return 0;
    80001736:	4501                	li	a0,0
}
    80001738:	60a6                	ld	ra,72(sp)
    8000173a:	6406                	ld	s0,64(sp)
    8000173c:	74e2                	ld	s1,56(sp)
    8000173e:	7942                	ld	s2,48(sp)
    80001740:	79a2                	ld	s3,40(sp)
    80001742:	7a02                	ld	s4,32(sp)
    80001744:	6ae2                	ld	s5,24(sp)
    80001746:	6b42                	ld	s6,16(sp)
    80001748:	6ba2                	ld	s7,8(sp)
    8000174a:	6c02                	ld	s8,0(sp)
    8000174c:	6161                	addi	sp,sp,80
    8000174e:	8082                	ret
  return 0;
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret

0000000080001754 <uvmshare>:
  uint64 i;
  pte_t *pte;
  uint64 pa;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001754:	ca3d                	beqz	a2,800017ca <uvmshare+0x76>
{
    80001756:	7179                	addi	sp,sp,-48
    80001758:	f406                	sd	ra,40(sp)
    8000175a:	f022                	sd	s0,32(sp)
    8000175c:	ec26                	sd	s1,24(sp)
    8000175e:	e84a                	sd	s2,16(sp)
    80001760:	e44e                	sd	s3,8(sp)
    80001762:	e052                	sd	s4,0(sp)
    80001764:	1800                	addi	s0,sp,48
    80001766:	89aa                	mv	s3,a0
    80001768:	8a2e                	mv	s4,a1
    8000176a:	8932                	mv	s2,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000176c:	4481                	li	s1,0
    8000176e:	a029                	j	80001778 <uvmshare+0x24>
    80001770:	6785                	lui	a5,0x1
    80001772:	94be                	add	s1,s1,a5
    80001774:	0524f263          	bgeu	s1,s2,800017b8 <uvmshare+0x64>
    pte = walk(old, i, 0);
    80001778:	4601                	li	a2,0
    8000177a:	85a6                	mv	a1,s1
    8000177c:	854e                	mv	a0,s3
    8000177e:	f98ff0ef          	jal	80000f16 <walk>
    if(pte == 0)
    80001782:	d57d                	beqz	a0,80001770 <uvmshare+0x1c>
      continue;
    if((*pte & PTE_V) == 0)
    80001784:	6118                	ld	a4,0(a0)
    80001786:	00177793          	andi	a5,a4,1
    8000178a:	d3fd                	beqz	a5,80001770 <uvmshare+0x1c>
      continue;

    pa = PTE2PA(*pte);
    8000178c:	00a75693          	srli	a3,a4,0xa
    flags = PTE_FLAGS(*pte);

    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80001790:	3ff77713          	andi	a4,a4,1023
    80001794:	06b2                	slli	a3,a3,0xc
    80001796:	6605                	lui	a2,0x1
    80001798:	85a6                	mv	a1,s1
    8000179a:	8552                	mv	a0,s4
    8000179c:	853ff0ef          	jal	80000fee <mappages>
    800017a0:	d961                	beqz	a0,80001770 <uvmshare+0x1c>
      if(i > 0)
        uvmunmap(new, 0, i / PGSIZE, 0);
      return -1;
    800017a2:	557d                	li	a0,-1
      if(i > 0)
    800017a4:	c899                	beqz	s1,800017ba <uvmshare+0x66>
        uvmunmap(new, 0, i / PGSIZE, 0);
    800017a6:	4681                	li	a3,0
    800017a8:	00c4d613          	srli	a2,s1,0xc
    800017ac:	4581                	li	a1,0
    800017ae:	8552                	mv	a0,s4
    800017b0:	a0bff0ef          	jal	800011ba <uvmunmap>
      return -1;
    800017b4:	557d                	li	a0,-1
    800017b6:	a011                	j	800017ba <uvmshare+0x66>
    }
  }
  return 0;
    800017b8:	4501                	li	a0,0
}
    800017ba:	70a2                	ld	ra,40(sp)
    800017bc:	7402                	ld	s0,32(sp)
    800017be:	64e2                	ld	s1,24(sp)
    800017c0:	6942                	ld	s2,16(sp)
    800017c2:	69a2                	ld	s3,8(sp)
    800017c4:	6a02                	ld	s4,0(sp)
    800017c6:	6145                	addi	sp,sp,48
    800017c8:	8082                	ret
  return 0;
    800017ca:	4501                	li	a0,0
}
    800017cc:	8082                	ret

00000000800017ce <thread_freepagetable>:

void
thread_freepagetable(pagetable_t pagetable, uint64 sz)
{
    800017ce:	1101                	addi	sp,sp,-32
    800017d0:	ec06                	sd	ra,24(sp)
    800017d2:	e822                	sd	s0,16(sp)
    800017d4:	e426                	sd	s1,8(sp)
    800017d6:	e04a                	sd	s2,0(sp)
    800017d8:	1000                	addi	s0,sp,32
    800017da:	84aa                	mv	s1,a0
    800017dc:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800017de:	4681                	li	a3,0
    800017e0:	4605                	li	a2,1
    800017e2:	040005b7          	lui	a1,0x4000
    800017e6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800017e8:	05b2                	slli	a1,a1,0xc
    800017ea:	9d1ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800017ee:	4681                	li	a3,0
    800017f0:	4605                	li	a2,1
    800017f2:	020005b7          	lui	a1,0x2000
    800017f6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800017f8:	05b6                	slli	a1,a1,0xd
    800017fa:	8526                	mv	a0,s1
    800017fc:	9bfff0ef          	jal	800011ba <uvmunmap>

  if(sz > 0)
    80001800:	00091b63          	bnez	s2,80001816 <thread_freepagetable+0x48>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 0);

  freewalk(pagetable);
    80001804:	8526                	mv	a0,s1
    80001806:	b29ff0ef          	jal	8000132e <freewalk>
}
    8000180a:	60e2                	ld	ra,24(sp)
    8000180c:	6442                	ld	s0,16(sp)
    8000180e:	64a2                	ld	s1,8(sp)
    80001810:	6902                	ld	s2,0(sp)
    80001812:	6105                	addi	sp,sp,32
    80001814:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 0);
    80001816:	6785                	lui	a5,0x1
    80001818:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000181a:	00f90633          	add	a2,s2,a5
    8000181e:	4681                	li	a3,0
    80001820:	8231                	srli	a2,a2,0xc
    80001822:	4581                	li	a1,0
    80001824:	8526                	mv	a0,s1
    80001826:	995ff0ef          	jal	800011ba <uvmunmap>
    8000182a:	bfe9                	j	80001804 <thread_freepagetable+0x36>

000000008000182c <shminit>:

struct shmseg shmtable[SHM_PAGES];

void
shminit(void)
{
    8000182c:	7179                	addi	sp,sp,-48
    8000182e:	f406                	sd	ra,40(sp)
    80001830:	f022                	sd	s0,32(sp)
    80001832:	ec26                	sd	s1,24(sp)
    80001834:	e84a                	sd	s2,16(sp)
    80001836:	e44e                	sd	s3,8(sp)
    80001838:	1800                	addi	s0,sp,48
  int i;
  for(i = 0; i < SHM_PAGES; i++){
    8000183a:	00012497          	auipc	s1,0x12
    8000183e:	25e48493          	addi	s1,s1,606 # 80013a98 <shmtable>
    80001842:	00012997          	auipc	s3,0x12
    80001846:	39698993          	addi	s3,s3,918 # 80013bd8 <pid_lock>
    initlock(&shmtable[i].lock, "shm");
    8000184a:	00007917          	auipc	s2,0x7
    8000184e:	90e90913          	addi	s2,s2,-1778 # 80008158 <etext+0x158>
    80001852:	85ca                	mv	a1,s2
    80001854:	8526                	mv	a0,s1
    80001856:	af8ff0ef          	jal	80000b4e <initlock>
    shmtable[i].pa = 0;
    8000185a:	0004bc23          	sd	zero,24(s1)
    shmtable[i].refcnt = 0;
    8000185e:	0204a023          	sw	zero,32(s1)
  for(i = 0; i < SHM_PAGES; i++){
    80001862:	02848493          	addi	s1,s1,40
    80001866:	ff3496e3          	bne	s1,s3,80001852 <shminit+0x26>
  }
}
    8000186a:	70a2                	ld	ra,40(sp)
    8000186c:	7402                	ld	s0,32(sp)
    8000186e:	64e2                	ld	s1,24(sp)
    80001870:	6942                	ld	s2,16(sp)
    80001872:	69a2                	ld	s3,8(sp)
    80001874:	6145                	addi	sp,sp,48
    80001876:	8082                	ret

0000000080001878 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001878:	7139                	addi	sp,sp,-64
    8000187a:	fc06                	sd	ra,56(sp)
    8000187c:	f822                	sd	s0,48(sp)
    8000187e:	f426                	sd	s1,40(sp)
    80001880:	f04a                	sd	s2,32(sp)
    80001882:	ec4e                	sd	s3,24(sp)
    80001884:	e852                	sd	s4,16(sp)
    80001886:	e456                	sd	s5,8(sp)
    80001888:	e05a                	sd	s6,0(sp)
    8000188a:	0080                	addi	s0,sp,64
    8000188c:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188e:	00012497          	auipc	s1,0x12
    80001892:	77a48493          	addi	s1,s1,1914 # 80014008 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001896:	8b26                	mv	s6,s1
    80001898:	00a36937          	lui	s2,0xa36
    8000189c:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    800018a0:	0932                	slli	s2,s2,0xc
    800018a2:	46d90913          	addi	s2,s2,1133
    800018a6:	0936                	slli	s2,s2,0xd
    800018a8:	df590913          	addi	s2,s2,-523
    800018ac:	093a                	slli	s2,s2,0xe
    800018ae:	6cf90913          	addi	s2,s2,1743
    800018b2:	040009b7          	lui	s3,0x4000
    800018b6:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018b8:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ba:	00018a97          	auipc	s5,0x18
    800018be:	54ea8a93          	addi	s5,s5,1358 # 80019e08 <tickslock>
    char *pa = kalloc();
    800018c2:	a3cff0ef          	jal	80000afe <kalloc>
    800018c6:	862a                	mv	a2,a0
    if(pa == 0)
    800018c8:	cd15                	beqz	a0,80001904 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800018ca:	416485b3          	sub	a1,s1,s6
    800018ce:	858d                	srai	a1,a1,0x3
    800018d0:	032585b3          	mul	a1,a1,s2
    800018d4:	2585                	addiw	a1,a1,1
    800018d6:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018da:	4719                	li	a4,6
    800018dc:	6685                	lui	a3,0x1
    800018de:	40b985b3          	sub	a1,s3,a1
    800018e2:	8552                	mv	a0,s4
    800018e4:	fbaff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e8:	17848493          	addi	s1,s1,376
    800018ec:	fd549be3          	bne	s1,s5,800018c2 <proc_mapstacks+0x4a>
  }
}
    800018f0:	70e2                	ld	ra,56(sp)
    800018f2:	7442                	ld	s0,48(sp)
    800018f4:	74a2                	ld	s1,40(sp)
    800018f6:	7902                	ld	s2,32(sp)
    800018f8:	69e2                	ld	s3,24(sp)
    800018fa:	6a42                	ld	s4,16(sp)
    800018fc:	6aa2                	ld	s5,8(sp)
    800018fe:	6b02                	ld	s6,0(sp)
    80001900:	6121                	addi	sp,sp,64
    80001902:	8082                	ret
      panic("kalloc");
    80001904:	00007517          	auipc	a0,0x7
    80001908:	85c50513          	addi	a0,a0,-1956 # 80008160 <etext+0x160>
    8000190c:	ed5fe0ef          	jal	800007e0 <panic>

0000000080001910 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001910:	7139                	addi	sp,sp,-64
    80001912:	fc06                	sd	ra,56(sp)
    80001914:	f822                	sd	s0,48(sp)
    80001916:	f426                	sd	s1,40(sp)
    80001918:	f04a                	sd	s2,32(sp)
    8000191a:	ec4e                	sd	s3,24(sp)
    8000191c:	e852                	sd	s4,16(sp)
    8000191e:	e456                	sd	s5,8(sp)
    80001920:	e05a                	sd	s6,0(sp)
    80001922:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001924:	00007597          	auipc	a1,0x7
    80001928:	84458593          	addi	a1,a1,-1980 # 80008168 <etext+0x168>
    8000192c:	00012517          	auipc	a0,0x12
    80001930:	2ac50513          	addi	a0,a0,684 # 80013bd8 <pid_lock>
    80001934:	a1aff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001938:	00007597          	auipc	a1,0x7
    8000193c:	83858593          	addi	a1,a1,-1992 # 80008170 <etext+0x170>
    80001940:	00012517          	auipc	a0,0x12
    80001944:	2b050513          	addi	a0,a0,688 # 80013bf0 <wait_lock>
    80001948:	a06ff0ef          	jal	80000b4e <initlock>
  shminit();
    8000194c:	ee1ff0ef          	jal	8000182c <shminit>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001950:	00012497          	auipc	s1,0x12
    80001954:	6b848493          	addi	s1,s1,1720 # 80014008 <proc>
      initlock(&p->lock, "proc");
    80001958:	00007b17          	auipc	s6,0x7
    8000195c:	828b0b13          	addi	s6,s6,-2008 # 80008180 <etext+0x180>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001960:	8aa6                	mv	s5,s1
    80001962:	00a36937          	lui	s2,0xa36
    80001966:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    8000196a:	0932                	slli	s2,s2,0xc
    8000196c:	46d90913          	addi	s2,s2,1133
    80001970:	0936                	slli	s2,s2,0xd
    80001972:	df590913          	addi	s2,s2,-523
    80001976:	093a                	slli	s2,s2,0xe
    80001978:	6cf90913          	addi	s2,s2,1743
    8000197c:	040009b7          	lui	s3,0x4000
    80001980:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001982:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001984:	00018a17          	auipc	s4,0x18
    80001988:	484a0a13          	addi	s4,s4,1156 # 80019e08 <tickslock>
      initlock(&p->lock, "proc");
    8000198c:	85da                	mv	a1,s6
    8000198e:	8526                	mv	a0,s1
    80001990:	9beff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    80001994:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001998:	415487b3          	sub	a5,s1,s5
    8000199c:	878d                	srai	a5,a5,0x3
    8000199e:	032787b3          	mul	a5,a5,s2
    800019a2:	2785                	addiw	a5,a5,1
    800019a4:	00d7979b          	slliw	a5,a5,0xd
    800019a8:	40f987b3          	sub	a5,s3,a5
    800019ac:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ae:	17848493          	addi	s1,s1,376
    800019b2:	fd449de3          	bne	s1,s4,8000198c <procinit+0x7c>
  }
}
    800019b6:	70e2                	ld	ra,56(sp)
    800019b8:	7442                	ld	s0,48(sp)
    800019ba:	74a2                	ld	s1,40(sp)
    800019bc:	7902                	ld	s2,32(sp)
    800019be:	69e2                	ld	s3,24(sp)
    800019c0:	6a42                	ld	s4,16(sp)
    800019c2:	6aa2                	ld	s5,8(sp)
    800019c4:	6b02                	ld	s6,0(sp)
    800019c6:	6121                	addi	sp,sp,64
    800019c8:	8082                	ret

00000000800019ca <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019ca:	1141                	addi	sp,sp,-16
    800019cc:	e422                	sd	s0,8(sp)
    800019ce:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019d0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019d2:	2501                	sext.w	a0,a0
    800019d4:	6422                	ld	s0,8(sp)
    800019d6:	0141                	addi	sp,sp,16
    800019d8:	8082                	ret

00000000800019da <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019da:	1141                	addi	sp,sp,-16
    800019dc:	e422                	sd	s0,8(sp)
    800019de:	0800                	addi	s0,sp,16
    800019e0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019e2:	2781                	sext.w	a5,a5
    800019e4:	079e                	slli	a5,a5,0x7
  return c;
}
    800019e6:	00012517          	auipc	a0,0x12
    800019ea:	22250513          	addi	a0,a0,546 # 80013c08 <cpus>
    800019ee:	953e                	add	a0,a0,a5
    800019f0:	6422                	ld	s0,8(sp)
    800019f2:	0141                	addi	sp,sp,16
    800019f4:	8082                	ret

00000000800019f6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019f6:	1101                	addi	sp,sp,-32
    800019f8:	ec06                	sd	ra,24(sp)
    800019fa:	e822                	sd	s0,16(sp)
    800019fc:	e426                	sd	s1,8(sp)
    800019fe:	1000                	addi	s0,sp,32
  push_off();
    80001a00:	98eff0ef          	jal	80000b8e <push_off>
    80001a04:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a06:	2781                	sext.w	a5,a5
    80001a08:	079e                	slli	a5,a5,0x7
    80001a0a:	00012717          	auipc	a4,0x12
    80001a0e:	08e70713          	addi	a4,a4,142 # 80013a98 <shmtable>
    80001a12:	97ba                	add	a5,a5,a4
    80001a14:	1707b483          	ld	s1,368(a5)
  pop_off();
    80001a18:	9faff0ef          	jal	80000c12 <pop_off>
  return p;
}
    80001a1c:	8526                	mv	a0,s1
    80001a1e:	60e2                	ld	ra,24(sp)
    80001a20:	6442                	ld	s0,16(sp)
    80001a22:	64a2                	ld	s1,8(sp)
    80001a24:	6105                	addi	sp,sp,32
    80001a26:	8082                	ret

0000000080001a28 <kshmget>:
{
    80001a28:	7139                	addi	sp,sp,-64
    80001a2a:	fc06                	sd	ra,56(sp)
    80001a2c:	f822                	sd	s0,48(sp)
    80001a2e:	f426                	sd	s1,40(sp)
    80001a30:	ec4e                	sd	s3,24(sp)
    80001a32:	0080                	addi	s0,sp,64
    80001a34:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001a36:	fc1ff0ef          	jal	800019f6 <myproc>
  if(key < 0 || key >= SHM_PAGES)
    80001a3a:	0004871b          	sext.w	a4,s1
    80001a3e:	479d                	li	a5,7
    return 0;
    80001a40:	4981                	li	s3,0
  if(key < 0 || key >= SHM_PAGES)
    80001a42:	02e7e763          	bltu	a5,a4,80001a70 <kshmget+0x48>
    80001a46:	f04a                	sd	s2,32(sp)
    80001a48:	e852                	sd	s4,16(sp)
    80001a4a:	892a                	mv	s2,a0
  if(p->shm_mask & (1U << key))
    80001a4c:	4a05                	li	s4,1
    80001a4e:	009a1a3b          	sllw	s4,s4,s1
    80001a52:	17052783          	lw	a5,368(a0)
    80001a56:	0147f7b3          	and	a5,a5,s4
    80001a5a:	2781                	sext.w	a5,a5
    80001a5c:	c38d                	beqz	a5,80001a7e <kshmget+0x56>
    return SHMBASE + key * PGSIZE;
    80001a5e:	00c4999b          	slliw	s3,s1,0xc
    80001a62:	020007b7          	lui	a5,0x2000
    80001a66:	17ed                	addi	a5,a5,-5 # 1fffffb <_entry-0x7e000005>
    80001a68:	07b6                	slli	a5,a5,0xd
    80001a6a:	99be                	add	s3,s3,a5
    80001a6c:	7902                	ld	s2,32(sp)
    80001a6e:	6a42                	ld	s4,16(sp)
}
    80001a70:	854e                	mv	a0,s3
    80001a72:	70e2                	ld	ra,56(sp)
    80001a74:	7442                	ld	s0,48(sp)
    80001a76:	74a2                	ld	s1,40(sp)
    80001a78:	69e2                	ld	s3,24(sp)
    80001a7a:	6121                	addi	sp,sp,64
    80001a7c:	8082                	ret
    80001a7e:	e456                	sd	s5,8(sp)
  va = SHMBASE + key * PGSIZE;
    80001a80:	00c4999b          	slliw	s3,s1,0xc
    80001a84:	020007b7          	lui	a5,0x2000
    80001a88:	17ed                	addi	a5,a5,-5 # 1fffffb <_entry-0x7e000005>
    80001a8a:	07b6                	slli	a5,a5,0xd
    80001a8c:	99be                	add	s3,s3,a5
  acquire(&s->lock);
    80001a8e:	00249793          	slli	a5,s1,0x2
    80001a92:	97a6                	add	a5,a5,s1
    80001a94:	078e                	slli	a5,a5,0x3
    80001a96:	00012a97          	auipc	s5,0x12
    80001a9a:	002a8a93          	addi	s5,s5,2 # 80013a98 <shmtable>
    80001a9e:	9abe                	add	s5,s5,a5
    80001aa0:	8556                	mv	a0,s5
    80001aa2:	92cff0ef          	jal	80000bce <acquire>
  if(s->pa == 0){
    80001aa6:	018ab683          	ld	a3,24(s5)
    80001aaa:	c6a1                	beqz	a3,80001af2 <kshmget+0xca>
  if(mappages(p->pagetable, va, PGSIZE, (uint64)s->pa, PTE_R | PTE_W | PTE_U) < 0){
    80001aac:	4759                	li	a4,22
    80001aae:	6605                	lui	a2,0x1
    80001ab0:	85ce                	mv	a1,s3
    80001ab2:	05893503          	ld	a0,88(s2)
    80001ab6:	d38ff0ef          	jal	80000fee <mappages>
    80001aba:	08054a63          	bltz	a0,80001b4e <kshmget+0x126>
  s->refcnt++;
    80001abe:	00012697          	auipc	a3,0x12
    80001ac2:	fda68693          	addi	a3,a3,-38 # 80013a98 <shmtable>
    80001ac6:	00249793          	slli	a5,s1,0x2
    80001aca:	00978733          	add	a4,a5,s1
    80001ace:	070e                	slli	a4,a4,0x3
    80001ad0:	9736                	add	a4,a4,a3
    80001ad2:	531c                	lw	a5,32(a4)
    80001ad4:	2785                	addiw	a5,a5,1
    80001ad6:	d31c                	sw	a5,32(a4)
  p->shm_mask |= (1U << key);
    80001ad8:	17092783          	lw	a5,368(s2)
    80001adc:	0147e7b3          	or	a5,a5,s4
    80001ae0:	16f92823          	sw	a5,368(s2)
  release(&s->lock);
    80001ae4:	8556                	mv	a0,s5
    80001ae6:	980ff0ef          	jal	80000c66 <release>
  return va;
    80001aea:	7902                	ld	s2,32(sp)
    80001aec:	6a42                	ld	s4,16(sp)
    80001aee:	6aa2                	ld	s5,8(sp)
    80001af0:	b741                	j	80001a70 <kshmget+0x48>
    s->pa = kalloc();
    80001af2:	80cff0ef          	jal	80000afe <kalloc>
    80001af6:	00aabc23          	sd	a0,24(s5)
    if(s->pa == 0){
    80001afa:	c135                	beqz	a0,80001b5e <kshmget+0x136>
    memset(s->pa, 0, PGSIZE);
    80001afc:	6605                	lui	a2,0x1
    80001afe:	4581                	li	a1,0
    80001b00:	9a2ff0ef          	jal	80000ca2 <memset>
  if(mappages(p->pagetable, va, PGSIZE, (uint64)s->pa, PTE_R | PTE_W | PTE_U) < 0){
    80001b04:	00249793          	slli	a5,s1,0x2
    80001b08:	97a6                	add	a5,a5,s1
    80001b0a:	078e                	slli	a5,a5,0x3
    80001b0c:	00012717          	auipc	a4,0x12
    80001b10:	f8c70713          	addi	a4,a4,-116 # 80013a98 <shmtable>
    80001b14:	97ba                	add	a5,a5,a4
    80001b16:	4759                	li	a4,22
    80001b18:	6f94                	ld	a3,24(a5)
    80001b1a:	6605                	lui	a2,0x1
    80001b1c:	85ce                	mv	a1,s3
    80001b1e:	05893503          	ld	a0,88(s2)
    80001b22:	cccff0ef          	jal	80000fee <mappages>
    80001b26:	f8055ce3          	bgez	a0,80001abe <kshmget+0x96>
      kfree(s->pa);
    80001b2a:	00012997          	auipc	s3,0x12
    80001b2e:	f6e98993          	addi	s3,s3,-146 # 80013a98 <shmtable>
    80001b32:	00249913          	slli	s2,s1,0x2
    80001b36:	009907b3          	add	a5,s2,s1
    80001b3a:	078e                	slli	a5,a5,0x3
    80001b3c:	97ce                	add	a5,a5,s3
    80001b3e:	6f88                	ld	a0,24(a5)
    80001b40:	eddfe0ef          	jal	80000a1c <kfree>
      s->pa = 0;
    80001b44:	9926                	add	s2,s2,s1
    80001b46:	090e                	slli	s2,s2,0x3
    80001b48:	99ca                	add	s3,s3,s2
    80001b4a:	0009bc23          	sd	zero,24(s3)
    release(&s->lock);
    80001b4e:	8556                	mv	a0,s5
    80001b50:	916ff0ef          	jal	80000c66 <release>
    return 0;
    80001b54:	4981                	li	s3,0
    80001b56:	7902                	ld	s2,32(sp)
    80001b58:	6a42                	ld	s4,16(sp)
    80001b5a:	6aa2                	ld	s5,8(sp)
    80001b5c:	bf11                	j	80001a70 <kshmget+0x48>
      release(&s->lock);
    80001b5e:	8556                	mv	a0,s5
    80001b60:	906ff0ef          	jal	80000c66 <release>
      return 0;
    80001b64:	4981                	li	s3,0
    80001b66:	7902                	ld	s2,32(sp)
    80001b68:	6a42                	ld	s4,16(sp)
    80001b6a:	6aa2                	ld	s5,8(sp)
    80001b6c:	b711                	j	80001a70 <kshmget+0x48>

0000000080001b6e <kshmdt>:
{
    80001b6e:	7179                	addi	sp,sp,-48
    80001b70:	f406                	sd	ra,40(sp)
    80001b72:	f022                	sd	s0,32(sp)
    80001b74:	ec26                	sd	s1,24(sp)
    80001b76:	1800                	addi	s0,sp,48
    80001b78:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b7a:	e7dff0ef          	jal	800019f6 <myproc>
  if(key < 0 || key >= SHM_PAGES)
    80001b7e:	0004871b          	sext.w	a4,s1
    80001b82:	479d                	li	a5,7
    80001b84:	08e7ea63          	bltu	a5,a4,80001c18 <kshmdt+0xaa>
    80001b88:	e84a                	sd	s2,16(sp)
    80001b8a:	e44e                	sd	s3,8(sp)
    80001b8c:	892a                	mv	s2,a0
  if((p->shm_mask & (1U << key)) == 0)
    80001b8e:	4985                	li	s3,1
    80001b90:	009999bb          	sllw	s3,s3,s1
    80001b94:	17052783          	lw	a5,368(a0)
    80001b98:	0137f7b3          	and	a5,a5,s3
    80001b9c:	2781                	sext.w	a5,a5
    80001b9e:	cfbd                	beqz	a5,80001c1c <kshmdt+0xae>
  va = SHMBASE + key * PGSIZE;
    80001ba0:	00c4959b          	slliw	a1,s1,0xc
    80001ba4:	020007b7          	lui	a5,0x2000
    80001ba8:	17ed                	addi	a5,a5,-5 # 1fffffb <_entry-0x7e000005>
    80001baa:	07b6                	slli	a5,a5,0xd
  uvmunmap(p->pagetable, va, 1, 0);
    80001bac:	4681                	li	a3,0
    80001bae:	4605                	li	a2,1
    80001bb0:	95be                	add	a1,a1,a5
    80001bb2:	6d28                	ld	a0,88(a0)
    80001bb4:	e06ff0ef          	jal	800011ba <uvmunmap>
  p->shm_mask &= ~(1U << key);
    80001bb8:	fff9c993          	not	s3,s3
    80001bbc:	17092783          	lw	a5,368(s2)
    80001bc0:	0137f7b3          	and	a5,a5,s3
    80001bc4:	16f92823          	sw	a5,368(s2)
  acquire(&s->lock);
    80001bc8:	00249793          	slli	a5,s1,0x2
    80001bcc:	97a6                	add	a5,a5,s1
    80001bce:	078e                	slli	a5,a5,0x3
    80001bd0:	00012917          	auipc	s2,0x12
    80001bd4:	ec890913          	addi	s2,s2,-312 # 80013a98 <shmtable>
    80001bd8:	993e                	add	s2,s2,a5
    80001bda:	854a                	mv	a0,s2
    80001bdc:	ff3fe0ef          	jal	80000bce <acquire>
  s->refcnt--;
    80001be0:	02092783          	lw	a5,32(s2)
    80001be4:	37fd                	addiw	a5,a5,-1
    80001be6:	0007871b          	sext.w	a4,a5
    80001bea:	02f92023          	sw	a5,32(s2)
  if(s->refcnt == 0){
    80001bee:	cf01                	beqz	a4,80001c06 <kshmdt+0x98>
  release(&s->lock);
    80001bf0:	854a                	mv	a0,s2
    80001bf2:	874ff0ef          	jal	80000c66 <release>
  return 0;
    80001bf6:	4501                	li	a0,0
    80001bf8:	6942                	ld	s2,16(sp)
    80001bfa:	69a2                	ld	s3,8(sp)
}
    80001bfc:	70a2                	ld	ra,40(sp)
    80001bfe:	7402                	ld	s0,32(sp)
    80001c00:	64e2                	ld	s1,24(sp)
    80001c02:	6145                	addi	sp,sp,48
    80001c04:	8082                	ret
    80001c06:	e052                	sd	s4,0(sp)
    kfree(s->pa);
    80001c08:	01893503          	ld	a0,24(s2)
    80001c0c:	e11fe0ef          	jal	80000a1c <kfree>
    s->pa = 0;
    80001c10:	00093c23          	sd	zero,24(s2)
    80001c14:	6a02                	ld	s4,0(sp)
    80001c16:	bfe9                	j	80001bf0 <kshmdt+0x82>
    return -1;
    80001c18:	557d                	li	a0,-1
    80001c1a:	b7cd                	j	80001bfc <kshmdt+0x8e>
    return -1;
    80001c1c:	557d                	li	a0,-1
    80001c1e:	6942                	ld	s2,16(sp)
    80001c20:	69a2                	ld	s3,8(sp)
    80001c22:	bfe9                	j	80001bfc <kshmdt+0x8e>

0000000080001c24 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001c24:	7179                	addi	sp,sp,-48
    80001c26:	f406                	sd	ra,40(sp)
    80001c28:	f022                	sd	s0,32(sp)
    80001c2a:	ec26                	sd	s1,24(sp)
    80001c2c:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001c2e:	dc9ff0ef          	jal	800019f6 <myproc>
    80001c32:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001c34:	832ff0ef          	jal	80000c66 <release>

  if (first) {
    80001c38:	0000a797          	auipc	a5,0xa
    80001c3c:	d087a783          	lw	a5,-760(a5) # 8000b940 <first.1>
    80001c40:	cf8d                	beqz	a5,80001c7a <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001c42:	4505                	li	a0,1
    80001c44:	774020ef          	jal	800043b8 <fsinit>

    first = 0;
    80001c48:	0000a797          	auipc	a5,0xa
    80001c4c:	ce07ac23          	sw	zero,-776(a5) # 8000b940 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001c50:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001c54:	00006517          	auipc	a0,0x6
    80001c58:	53450513          	addi	a0,a0,1332 # 80008188 <etext+0x188>
    80001c5c:	fca43823          	sd	a0,-48(s0)
    80001c60:	fc043c23          	sd	zero,-40(s0)
    80001c64:	fd040593          	addi	a1,s0,-48
    80001c68:	05b030ef          	jal	800054c2 <kexec>
    80001c6c:	70bc                	ld	a5,96(s1)
    80001c6e:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001c70:	70bc                	ld	a5,96(s1)
    80001c72:	7bb8                	ld	a4,112(a5)
    80001c74:	57fd                	li	a5,-1
    80001c76:	02f70d63          	beq	a4,a5,80001cb0 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001c7a:	0fe010ef          	jal	80002d78 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c7e:	6ca8                	ld	a0,88(s1)
    80001c80:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001c82:	04000737          	lui	a4,0x4000
    80001c86:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001c88:	0732                	slli	a4,a4,0xc
    80001c8a:	00005797          	auipc	a5,0x5
    80001c8e:	41278793          	addi	a5,a5,1042 # 8000709c <userret>
    80001c92:	00005697          	auipc	a3,0x5
    80001c96:	36e68693          	addi	a3,a3,878 # 80007000 <_trampoline>
    80001c9a:	8f95                	sub	a5,a5,a3
    80001c9c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001c9e:	577d                	li	a4,-1
    80001ca0:	177e                	slli	a4,a4,0x3f
    80001ca2:	8d59                	or	a0,a0,a4
    80001ca4:	9782                	jalr	a5
}
    80001ca6:	70a2                	ld	ra,40(sp)
    80001ca8:	7402                	ld	s0,32(sp)
    80001caa:	64e2                	ld	s1,24(sp)
    80001cac:	6145                	addi	sp,sp,48
    80001cae:	8082                	ret
      panic("exec");
    80001cb0:	00006517          	auipc	a0,0x6
    80001cb4:	4e050513          	addi	a0,a0,1248 # 80008190 <etext+0x190>
    80001cb8:	b29fe0ef          	jal	800007e0 <panic>

0000000080001cbc <allocpid>:
{
    80001cbc:	1101                	addi	sp,sp,-32
    80001cbe:	ec06                	sd	ra,24(sp)
    80001cc0:	e822                	sd	s0,16(sp)
    80001cc2:	e426                	sd	s1,8(sp)
    80001cc4:	e04a                	sd	s2,0(sp)
    80001cc6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001cc8:	00012917          	auipc	s2,0x12
    80001ccc:	f1090913          	addi	s2,s2,-240 # 80013bd8 <pid_lock>
    80001cd0:	854a                	mv	a0,s2
    80001cd2:	efdfe0ef          	jal	80000bce <acquire>
  pid = nextpid;
    80001cd6:	0000a797          	auipc	a5,0xa
    80001cda:	c6e78793          	addi	a5,a5,-914 # 8000b944 <nextpid>
    80001cde:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ce0:	0014871b          	addiw	a4,s1,1
    80001ce4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ce6:	854a                	mv	a0,s2
    80001ce8:	f7ffe0ef          	jal	80000c66 <release>
}
    80001cec:	8526                	mv	a0,s1
    80001cee:	60e2                	ld	ra,24(sp)
    80001cf0:	6442                	ld	s0,16(sp)
    80001cf2:	64a2                	ld	s1,8(sp)
    80001cf4:	6902                	ld	s2,0(sp)
    80001cf6:	6105                	addi	sp,sp,32
    80001cf8:	8082                	ret

0000000080001cfa <setpriority>:
  if(priority < 0)
    80001cfa:	0605c463          	bltz	a1,80001d62 <setpriority+0x68>
{
    80001cfe:	7179                	addi	sp,sp,-48
    80001d00:	f406                	sd	ra,40(sp)
    80001d02:	f022                	sd	s0,32(sp)
    80001d04:	ec26                	sd	s1,24(sp)
    80001d06:	e84a                	sd	s2,16(sp)
    80001d08:	e44e                	sd	s3,8(sp)
    80001d0a:	e052                	sd	s4,0(sp)
    80001d0c:	1800                	addi	s0,sp,48
    80001d0e:	892a                	mv	s2,a0
    80001d10:	8a2e                	mv	s4,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80001d12:	00012497          	auipc	s1,0x12
    80001d16:	2f648493          	addi	s1,s1,758 # 80014008 <proc>
    80001d1a:	00018997          	auipc	s3,0x18
    80001d1e:	0ee98993          	addi	s3,s3,238 # 80019e08 <tickslock>
    80001d22:	a801                	j	80001d32 <setpriority+0x38>
    release(&p->lock);
    80001d24:	8526                	mv	a0,s1
    80001d26:	f41fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001d2a:	17848493          	addi	s1,s1,376
    80001d2e:	03348863          	beq	s1,s3,80001d5e <setpriority+0x64>
    acquire(&p->lock);
    80001d32:	8526                	mv	a0,s1
    80001d34:	e9bfe0ef          	jal	80000bce <acquire>
    if(p->pid == pid && p->state != UNUSED){
    80001d38:	589c                	lw	a5,48(s1)
    80001d3a:	ff2795e3          	bne	a5,s2,80001d24 <setpriority+0x2a>
    80001d3e:	4c9c                	lw	a5,24(s1)
    80001d40:	d3f5                	beqz	a5,80001d24 <setpriority+0x2a>
      p->priority = priority;
    80001d42:	0344aa23          	sw	s4,52(s1)
      release(&p->lock);
    80001d46:	8526                	mv	a0,s1
    80001d48:	f1ffe0ef          	jal	80000c66 <release>
      return 0;
    80001d4c:	4501                	li	a0,0
}
    80001d4e:	70a2                	ld	ra,40(sp)
    80001d50:	7402                	ld	s0,32(sp)
    80001d52:	64e2                	ld	s1,24(sp)
    80001d54:	6942                	ld	s2,16(sp)
    80001d56:	69a2                	ld	s3,8(sp)
    80001d58:	6a02                	ld	s4,0(sp)
    80001d5a:	6145                	addi	sp,sp,48
    80001d5c:	8082                	ret
  return -1;
    80001d5e:	557d                	li	a0,-1
    80001d60:	b7fd                	j	80001d4e <setpriority+0x54>
    return -1;
    80001d62:	557d                	li	a0,-1
}
    80001d64:	8082                	ret

0000000080001d66 <proc_pagetable>:
{
    80001d66:	1101                	addi	sp,sp,-32
    80001d68:	ec06                	sd	ra,24(sp)
    80001d6a:	e822                	sd	s0,16(sp)
    80001d6c:	e426                	sd	s1,8(sp)
    80001d6e:	e04a                	sd	s2,0(sp)
    80001d70:	1000                	addi	s0,sp,32
    80001d72:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d74:	c20ff0ef          	jal	80001194 <uvmcreate>
    80001d78:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001d7a:	cd05                	beqz	a0,80001db2 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d7c:	4729                	li	a4,10
    80001d7e:	00005697          	auipc	a3,0x5
    80001d82:	28268693          	addi	a3,a3,642 # 80007000 <_trampoline>
    80001d86:	6605                	lui	a2,0x1
    80001d88:	040005b7          	lui	a1,0x4000
    80001d8c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d8e:	05b2                	slli	a1,a1,0xc
    80001d90:	a5eff0ef          	jal	80000fee <mappages>
    80001d94:	02054663          	bltz	a0,80001dc0 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d98:	4719                	li	a4,6
    80001d9a:	06093683          	ld	a3,96(s2)
    80001d9e:	6605                	lui	a2,0x1
    80001da0:	020005b7          	lui	a1,0x2000
    80001da4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001da6:	05b6                	slli	a1,a1,0xd
    80001da8:	8526                	mv	a0,s1
    80001daa:	a44ff0ef          	jal	80000fee <mappages>
    80001dae:	00054f63          	bltz	a0,80001dcc <proc_pagetable+0x66>
}
    80001db2:	8526                	mv	a0,s1
    80001db4:	60e2                	ld	ra,24(sp)
    80001db6:	6442                	ld	s0,16(sp)
    80001db8:	64a2                	ld	s1,8(sp)
    80001dba:	6902                	ld	s2,0(sp)
    80001dbc:	6105                	addi	sp,sp,32
    80001dbe:	8082                	ret
    uvmfree(pagetable, 0);
    80001dc0:	4581                	li	a1,0
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	dcaff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001dc8:	4481                	li	s1,0
    80001dca:	b7e5                	j	80001db2 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dcc:	4681                	li	a3,0
    80001dce:	4605                	li	a2,1
    80001dd0:	040005b7          	lui	a1,0x4000
    80001dd4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dd6:	05b2                	slli	a1,a1,0xc
    80001dd8:	8526                	mv	a0,s1
    80001dda:	be0ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001dde:	4581                	li	a1,0
    80001de0:	8526                	mv	a0,s1
    80001de2:	dacff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001de6:	4481                	li	s1,0
    80001de8:	b7e9                	j	80001db2 <proc_pagetable+0x4c>

0000000080001dea <proc_freepagetable>:
{
    80001dea:	1101                	addi	sp,sp,-32
    80001dec:	ec06                	sd	ra,24(sp)
    80001dee:	e822                	sd	s0,16(sp)
    80001df0:	e426                	sd	s1,8(sp)
    80001df2:	e04a                	sd	s2,0(sp)
    80001df4:	1000                	addi	s0,sp,32
    80001df6:	84aa                	mv	s1,a0
    80001df8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dfa:	4681                	li	a3,0
    80001dfc:	4605                	li	a2,1
    80001dfe:	040005b7          	lui	a1,0x4000
    80001e02:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e04:	05b2                	slli	a1,a1,0xc
    80001e06:	bb4ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e0a:	4681                	li	a3,0
    80001e0c:	4605                	li	a2,1
    80001e0e:	020005b7          	lui	a1,0x2000
    80001e12:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e14:	05b6                	slli	a1,a1,0xd
    80001e16:	8526                	mv	a0,s1
    80001e18:	ba2ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001e1c:	85ca                	mv	a1,s2
    80001e1e:	8526                	mv	a0,s1
    80001e20:	d6eff0ef          	jal	8000138e <uvmfree>
}
    80001e24:	60e2                	ld	ra,24(sp)
    80001e26:	6442                	ld	s0,16(sp)
    80001e28:	64a2                	ld	s1,8(sp)
    80001e2a:	6902                	ld	s2,0(sp)
    80001e2c:	6105                	addi	sp,sp,32
    80001e2e:	8082                	ret

0000000080001e30 <freeproc>:
{
    80001e30:	715d                	addi	sp,sp,-80
    80001e32:	e486                	sd	ra,72(sp)
    80001e34:	e0a2                	sd	s0,64(sp)
    80001e36:	fc26                	sd	s1,56(sp)
    80001e38:	0880                	addi	s0,sp,80
    80001e3a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001e3c:	7128                	ld	a0,96(a0)
    80001e3e:	c119                	beqz	a0,80001e44 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001e40:	bddfe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001e44:	0604b023          	sd	zero,96(s1)
  if(p->pagetable){
    80001e48:	6cbc                	ld	a5,88(s1)
    80001e4a:	cfd9                	beqz	a5,80001ee8 <freeproc+0xb8>
    80001e4c:	f84a                	sd	s2,48(sp)
    80001e4e:	f44e                	sd	s3,40(sp)
    80001e50:	f052                	sd	s4,32(sp)
    80001e52:	ec56                	sd	s5,24(sp)
    80001e54:	e85a                	sd	s6,16(sp)
    80001e56:	e45e                	sd	s7,8(sp)
    80001e58:	e062                	sd	s8,0(sp)
    80001e5a:	00012917          	auipc	s2,0x12
    80001e5e:	c3e90913          	addi	s2,s2,-962 # 80013a98 <shmtable>
    80001e62:	02000a37          	lui	s4,0x2000
    80001e66:	1a6d                	addi	s4,s4,-5 # 1fffffb <_entry-0x7e000005>
    80001e68:	0a36                	slli	s4,s4,0xd
  for(key = 0; key < SHM_PAGES; key++){
    80001e6a:	4981                	li	s3,0
    if((p->shm_mask & (1U << key)) == 0)
    80001e6c:	4b85                	li	s7,1
  for(key = 0; key < SHM_PAGES; key++){
    80001e6e:	6b05                	lui	s6,0x1
    80001e70:	4aa1                	li	s5,8
    80001e72:	a035                	j	80001e9e <freeproc+0x6e>
    acquire(&shmtable[key].lock);
    80001e74:	8c4a                	mv	s8,s2
    80001e76:	854a                	mv	a0,s2
    80001e78:	d57fe0ef          	jal	80000bce <acquire>
    shmtable[key].refcnt--;
    80001e7c:	02092783          	lw	a5,32(s2)
    80001e80:	37fd                	addiw	a5,a5,-1
    80001e82:	0007871b          	sext.w	a4,a5
    80001e86:	02f92023          	sw	a5,32(s2)
    if(shmtable[key].refcnt == 0){
    80001e8a:	cb0d                	beqz	a4,80001ebc <freeproc+0x8c>
    release(&shmtable[key].lock);
    80001e8c:	8562                	mv	a0,s8
    80001e8e:	dd9fe0ef          	jal	80000c66 <release>
  for(key = 0; key < SHM_PAGES; key++){
    80001e92:	2985                	addiw	s3,s3,1
    80001e94:	02890913          	addi	s2,s2,40
    80001e98:	9a5a                	add	s4,s4,s6
    80001e9a:	03598863          	beq	s3,s5,80001eca <freeproc+0x9a>
    if((p->shm_mask & (1U << key)) == 0)
    80001e9e:	013b973b          	sllw	a4,s7,s3
    80001ea2:	1704a783          	lw	a5,368(s1)
    80001ea6:	8ff9                	and	a5,a5,a4
    80001ea8:	2781                	sext.w	a5,a5
    80001eaa:	d7e5                	beqz	a5,80001e92 <freeproc+0x62>
    if(p->pagetable)
    80001eac:	6ca8                	ld	a0,88(s1)
    80001eae:	d179                	beqz	a0,80001e74 <freeproc+0x44>
      uvmunmap(p->pagetable, va, 1, 0);
    80001eb0:	4681                	li	a3,0
    80001eb2:	4605                	li	a2,1
    80001eb4:	85d2                	mv	a1,s4
    80001eb6:	b04ff0ef          	jal	800011ba <uvmunmap>
    80001eba:	bf6d                	j	80001e74 <freeproc+0x44>
      kfree(shmtable[key].pa);
    80001ebc:	01893503          	ld	a0,24(s2)
    80001ec0:	b5dfe0ef          	jal	80000a1c <kfree>
      shmtable[key].pa = 0;
    80001ec4:	00093c23          	sd	zero,24(s2)
    80001ec8:	b7d1                	j	80001e8c <freeproc+0x5c>
  p->shm_mask = 0;
    80001eca:	1604a823          	sw	zero,368(s1)
  if(p->is_thread)
    80001ece:	5c9c                	lw	a5,56(s1)
    80001ed0:	cba9                	beqz	a5,80001f22 <freeproc+0xf2>
    thread_freepagetable(p->pagetable, p->sz);
    80001ed2:	68ac                	ld	a1,80(s1)
    80001ed4:	6ca8                	ld	a0,88(s1)
    80001ed6:	8f9ff0ef          	jal	800017ce <thread_freepagetable>
    80001eda:	7942                	ld	s2,48(sp)
    80001edc:	79a2                	ld	s3,40(sp)
    80001ede:	7a02                	ld	s4,32(sp)
    80001ee0:	6ae2                	ld	s5,24(sp)
    80001ee2:	6b42                	ld	s6,16(sp)
    80001ee4:	6ba2                	ld	s7,8(sp)
    80001ee6:	6c02                	ld	s8,0(sp)
  p->pagetable = 0;
    80001ee8:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001eec:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001ef0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ef4:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001ef8:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001efc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001f00:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001f04:	0204a623          	sw	zero,44(s1)
  p->priority = 0;
    80001f08:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001f0c:	0004ac23          	sw	zero,24(s1)
  p->is_thread = 0;
    80001f10:	0204ac23          	sw	zero,56(s1)
  p->tgid = 0;
    80001f14:	0204ae23          	sw	zero,60(s1)
}
    80001f18:	60a6                	ld	ra,72(sp)
    80001f1a:	6406                	ld	s0,64(sp)
    80001f1c:	74e2                	ld	s1,56(sp)
    80001f1e:	6161                	addi	sp,sp,80
    80001f20:	8082                	ret
    proc_freepagetable(p->pagetable, p->sz);
    80001f22:	68ac                	ld	a1,80(s1)
    80001f24:	6ca8                	ld	a0,88(s1)
    80001f26:	ec5ff0ef          	jal	80001dea <proc_freepagetable>
    80001f2a:	7942                	ld	s2,48(sp)
    80001f2c:	79a2                	ld	s3,40(sp)
    80001f2e:	7a02                	ld	s4,32(sp)
    80001f30:	6ae2                	ld	s5,24(sp)
    80001f32:	6b42                	ld	s6,16(sp)
    80001f34:	6ba2                	ld	s7,8(sp)
    80001f36:	6c02                	ld	s8,0(sp)
    80001f38:	bf45                	j	80001ee8 <freeproc+0xb8>

0000000080001f3a <allocproc>:
{
    80001f3a:	1101                	addi	sp,sp,-32
    80001f3c:	ec06                	sd	ra,24(sp)
    80001f3e:	e822                	sd	s0,16(sp)
    80001f40:	e426                	sd	s1,8(sp)
    80001f42:	e04a                	sd	s2,0(sp)
    80001f44:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f46:	00012497          	auipc	s1,0x12
    80001f4a:	0c248493          	addi	s1,s1,194 # 80014008 <proc>
    80001f4e:	00018917          	auipc	s2,0x18
    80001f52:	eba90913          	addi	s2,s2,-326 # 80019e08 <tickslock>
    acquire(&p->lock);
    80001f56:	8526                	mv	a0,s1
    80001f58:	c77fe0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001f5c:	4c9c                	lw	a5,24(s1)
    80001f5e:	cb91                	beqz	a5,80001f72 <allocproc+0x38>
      release(&p->lock);
    80001f60:	8526                	mv	a0,s1
    80001f62:	d05fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f66:	17848493          	addi	s1,s1,376
    80001f6a:	ff2496e3          	bne	s1,s2,80001f56 <allocproc+0x1c>
  return 0;
    80001f6e:	4481                	li	s1,0
    80001f70:	a889                	j	80001fc2 <allocproc+0x88>
  p->pid = allocpid();
    80001f72:	d4bff0ef          	jal	80001cbc <allocpid>
    80001f76:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001f78:	4785                	li	a5,1
    80001f7a:	cc9c                	sw	a5,24(s1)
  p->shm_mask = 0;
    80001f7c:	1604a823          	sw	zero,368(s1)
  p->priority = 10;
    80001f80:	47a9                	li	a5,10
    80001f82:	d8dc                	sw	a5,52(s1)
  p->is_thread = 0;
    80001f84:	0204ac23          	sw	zero,56(s1)
  p->tgid = 0;
    80001f88:	0204ae23          	sw	zero,60(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001f8c:	b73fe0ef          	jal	80000afe <kalloc>
    80001f90:	892a                	mv	s2,a0
    80001f92:	f0a8                	sd	a0,96(s1)
    80001f94:	cd15                	beqz	a0,80001fd0 <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001f96:	8526                	mv	a0,s1
    80001f98:	dcfff0ef          	jal	80001d66 <proc_pagetable>
    80001f9c:	892a                	mv	s2,a0
    80001f9e:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001fa0:	c121                	beqz	a0,80001fe0 <allocproc+0xa6>
  memset(&p->context, 0, sizeof(p->context));
    80001fa2:	07000613          	li	a2,112
    80001fa6:	4581                	li	a1,0
    80001fa8:	06848513          	addi	a0,s1,104
    80001fac:	cf7fe0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001fb0:	00000797          	auipc	a5,0x0
    80001fb4:	c7478793          	addi	a5,a5,-908 # 80001c24 <forkret>
    80001fb8:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001fba:	64bc                	ld	a5,72(s1)
    80001fbc:	6705                	lui	a4,0x1
    80001fbe:	97ba                	add	a5,a5,a4
    80001fc0:	f8bc                	sd	a5,112(s1)
}
    80001fc2:	8526                	mv	a0,s1
    80001fc4:	60e2                	ld	ra,24(sp)
    80001fc6:	6442                	ld	s0,16(sp)
    80001fc8:	64a2                	ld	s1,8(sp)
    80001fca:	6902                	ld	s2,0(sp)
    80001fcc:	6105                	addi	sp,sp,32
    80001fce:	8082                	ret
    freeproc(p);
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	e5fff0ef          	jal	80001e30 <freeproc>
    release(&p->lock);
    80001fd6:	8526                	mv	a0,s1
    80001fd8:	c8ffe0ef          	jal	80000c66 <release>
    return 0;
    80001fdc:	84ca                	mv	s1,s2
    80001fde:	b7d5                	j	80001fc2 <allocproc+0x88>
    freeproc(p);
    80001fe0:	8526                	mv	a0,s1
    80001fe2:	e4fff0ef          	jal	80001e30 <freeproc>
    release(&p->lock);
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	c7ffe0ef          	jal	80000c66 <release>
    return 0;
    80001fec:	84ca                	mv	s1,s2
    80001fee:	bfd1                	j	80001fc2 <allocproc+0x88>

0000000080001ff0 <userinit>:
{
    80001ff0:	1101                	addi	sp,sp,-32
    80001ff2:	ec06                	sd	ra,24(sp)
    80001ff4:	e822                	sd	s0,16(sp)
    80001ff6:	e426                	sd	s1,8(sp)
    80001ff8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ffa:	f41ff0ef          	jal	80001f3a <allocproc>
    80001ffe:	84aa                	mv	s1,a0
  initproc = p;
    80002000:	0000a797          	auipc	a5,0xa
    80002004:	98a7b823          	sd	a0,-1648(a5) # 8000b990 <initproc>
  p->cwd = namei("/");
    80002008:	00006517          	auipc	a0,0x6
    8000200c:	19050513          	addi	a0,a0,400 # 80008198 <etext+0x198>
    80002010:	0cb020ef          	jal	800048da <namei>
    80002014:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80002018:	478d                	li	a5,3
    8000201a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000201c:	8526                	mv	a0,s1
    8000201e:	c49fe0ef          	jal	80000c66 <release>
}
    80002022:	60e2                	ld	ra,24(sp)
    80002024:	6442                	ld	s0,16(sp)
    80002026:	64a2                	ld	s1,8(sp)
    80002028:	6105                	addi	sp,sp,32
    8000202a:	8082                	ret

000000008000202c <growproc>:
{
    8000202c:	1101                	addi	sp,sp,-32
    8000202e:	ec06                	sd	ra,24(sp)
    80002030:	e822                	sd	s0,16(sp)
    80002032:	e426                	sd	s1,8(sp)
    80002034:	e04a                	sd	s2,0(sp)
    80002036:	1000                	addi	s0,sp,32
    80002038:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000203a:	9bdff0ef          	jal	800019f6 <myproc>
    8000203e:	892a                	mv	s2,a0
  sz = p->sz;
    80002040:	692c                	ld	a1,80(a0)
  if(n > 0){
    80002042:	02905963          	blez	s1,80002074 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80002046:	00b48633          	add	a2,s1,a1
    8000204a:	020007b7          	lui	a5,0x2000
    8000204e:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002050:	07b6                	slli	a5,a5,0xd
    80002052:	02c7ea63          	bltu	a5,a2,80002086 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80002056:	4691                	li	a3,4
    80002058:	6d28                	ld	a0,88(a0)
    8000205a:	a2eff0ef          	jal	80001288 <uvmalloc>
    8000205e:	85aa                	mv	a1,a0
    80002060:	c50d                	beqz	a0,8000208a <growproc+0x5e>
  p->sz = sz;
    80002062:	04b93823          	sd	a1,80(s2)
  return 0;
    80002066:	4501                	li	a0,0
}
    80002068:	60e2                	ld	ra,24(sp)
    8000206a:	6442                	ld	s0,16(sp)
    8000206c:	64a2                	ld	s1,8(sp)
    8000206e:	6902                	ld	s2,0(sp)
    80002070:	6105                	addi	sp,sp,32
    80002072:	8082                	ret
  } else if(n < 0){
    80002074:	fe04d7e3          	bgez	s1,80002062 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002078:	00b48633          	add	a2,s1,a1
    8000207c:	6d28                	ld	a0,88(a0)
    8000207e:	9c6ff0ef          	jal	80001244 <uvmdealloc>
    80002082:	85aa                	mv	a1,a0
    80002084:	bff9                	j	80002062 <growproc+0x36>
      return -1;
    80002086:	557d                	li	a0,-1
    80002088:	b7c5                	j	80002068 <growproc+0x3c>
      return -1;
    8000208a:	557d                	li	a0,-1
    8000208c:	bff1                	j	80002068 <growproc+0x3c>

000000008000208e <kfork>:
{
    8000208e:	7139                	addi	sp,sp,-64
    80002090:	fc06                	sd	ra,56(sp)
    80002092:	f822                	sd	s0,48(sp)
    80002094:	f04a                	sd	s2,32(sp)
    80002096:	e456                	sd	s5,8(sp)
    80002098:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000209a:	95dff0ef          	jal	800019f6 <myproc>
    8000209e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800020a0:	e9bff0ef          	jal	80001f3a <allocproc>
    800020a4:	0e050a63          	beqz	a0,80002198 <kfork+0x10a>
    800020a8:	e852                	sd	s4,16(sp)
    800020aa:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020ac:	050ab603          	ld	a2,80(s5)
    800020b0:	6d2c                	ld	a1,88(a0)
    800020b2:	058ab503          	ld	a0,88(s5)
    800020b6:	b0aff0ef          	jal	800013c0 <uvmcopy>
    800020ba:	04054a63          	bltz	a0,8000210e <kfork+0x80>
    800020be:	f426                	sd	s1,40(sp)
    800020c0:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    800020c2:	050ab783          	ld	a5,80(s5)
    800020c6:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    800020ca:	060ab683          	ld	a3,96(s5)
    800020ce:	87b6                	mv	a5,a3
    800020d0:	060a3703          	ld	a4,96(s4)
    800020d4:	12068693          	addi	a3,a3,288
    800020d8:	0007b803          	ld	a6,0(a5)
    800020dc:	6788                	ld	a0,8(a5)
    800020de:	6b8c                	ld	a1,16(a5)
    800020e0:	6f90                	ld	a2,24(a5)
    800020e2:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800020e6:	e708                	sd	a0,8(a4)
    800020e8:	eb0c                	sd	a1,16(a4)
    800020ea:	ef10                	sd	a2,24(a4)
    800020ec:	02078793          	addi	a5,a5,32
    800020f0:	02070713          	addi	a4,a4,32
    800020f4:	fed792e3          	bne	a5,a3,800020d8 <kfork+0x4a>
  np->trapframe->a0 = 0;
    800020f8:	060a3783          	ld	a5,96(s4)
    800020fc:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002100:	0d8a8493          	addi	s1,s5,216
    80002104:	0d8a0913          	addi	s2,s4,216
    80002108:	158a8993          	addi	s3,s5,344
    8000210c:	a831                	j	80002128 <kfork+0x9a>
    freeproc(np);
    8000210e:	8552                	mv	a0,s4
    80002110:	d21ff0ef          	jal	80001e30 <freeproc>
    release(&np->lock);
    80002114:	8552                	mv	a0,s4
    80002116:	b51fe0ef          	jal	80000c66 <release>
    return -1;
    8000211a:	597d                	li	s2,-1
    8000211c:	6a42                	ld	s4,16(sp)
    8000211e:	a0b5                	j	8000218a <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80002120:	04a1                	addi	s1,s1,8
    80002122:	0921                	addi	s2,s2,8
    80002124:	01348963          	beq	s1,s3,80002136 <kfork+0xa8>
    if(p->ofile[i])
    80002128:	6088                	ld	a0,0(s1)
    8000212a:	d97d                	beqz	a0,80002120 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    8000212c:	549020ef          	jal	80004e74 <filedup>
    80002130:	00a93023          	sd	a0,0(s2)
    80002134:	b7f5                	j	80002120 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80002136:	158ab503          	ld	a0,344(s5)
    8000213a:	755010ef          	jal	8000408e <idup>
    8000213e:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002142:	4641                	li	a2,16
    80002144:	160a8593          	addi	a1,s5,352
    80002148:	160a0513          	addi	a0,s4,352
    8000214c:	c95fe0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80002150:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80002154:	8552                	mv	a0,s4
    80002156:	b11fe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    8000215a:	00012497          	auipc	s1,0x12
    8000215e:	a9648493          	addi	s1,s1,-1386 # 80013bf0 <wait_lock>
    80002162:	8526                	mv	a0,s1
    80002164:	a6bfe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80002168:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	af9fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80002172:	8552                	mv	a0,s4
    80002174:	a5bfe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80002178:	478d                	li	a5,3
    8000217a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000217e:	8552                	mv	a0,s4
    80002180:	ae7fe0ef          	jal	80000c66 <release>
  return pid;
    80002184:	74a2                	ld	s1,40(sp)
    80002186:	69e2                	ld	s3,24(sp)
    80002188:	6a42                	ld	s4,16(sp)
}
    8000218a:	854a                	mv	a0,s2
    8000218c:	70e2                	ld	ra,56(sp)
    8000218e:	7442                	ld	s0,48(sp)
    80002190:	7902                	ld	s2,32(sp)
    80002192:	6aa2                	ld	s5,8(sp)
    80002194:	6121                	addi	sp,sp,64
    80002196:	8082                	ret
    return -1;
    80002198:	597d                	li	s2,-1
    8000219a:	bfc5                	j	8000218a <kfork+0xfc>

000000008000219c <kthread_create>:
{
    8000219c:	7119                	addi	sp,sp,-128
    8000219e:	fc86                	sd	ra,120(sp)
    800021a0:	f8a2                	sd	s0,112(sp)
    800021a2:	f0ca                	sd	s2,96(sp)
    800021a4:	f06a                	sd	s10,32(sp)
    800021a6:	ec6e                	sd	s11,24(sp)
    800021a8:	0100                	addi	s0,sp,128
    800021aa:	8daa                	mv	s11,a0
    800021ac:	f8b43423          	sd	a1,-120(s0)
    800021b0:	8d32                	mv	s10,a2
  struct proc *p = myproc();
    800021b2:	845ff0ef          	jal	800019f6 <myproc>
  if(stack == 0){
    800021b6:	040d0763          	beqz	s10,80002204 <kthread_create+0x68>
    800021ba:	f4a6                	sd	s1,104(sp)
    800021bc:	e4d6                	sd	s5,72(sp)
    800021be:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800021c0:	d7bff0ef          	jal	80001f3a <allocproc>
    800021c4:	84aa                	mv	s1,a0
    800021c6:	c539                	beqz	a0,80002214 <kthread_create+0x78>
  if(uvmshare(p->pagetable, np->pagetable, p->sz) < 0){
    800021c8:	050ab603          	ld	a2,80(s5)
    800021cc:	6d2c                	ld	a1,88(a0)
    800021ce:	058ab503          	ld	a0,88(s5)
    800021d2:	d82ff0ef          	jal	80001754 <uvmshare>
    800021d6:	04054963          	bltz	a0,80002228 <kthread_create+0x8c>
    800021da:	ecce                	sd	s3,88(sp)
    800021dc:	e8d2                	sd	s4,80(sp)
    800021de:	e0da                	sd	s6,64(sp)
    800021e0:	fc5e                	sd	s7,56(sp)
    800021e2:	f862                	sd	s8,48(sp)
    800021e4:	f466                	sd	s9,40(sp)
  np->sz = p->sz;
    800021e6:	050ab783          	ld	a5,80(s5)
    800021ea:	e8bc                	sd	a5,80(s1)
  for(key = 0; key < SHM_PAGES; key++){
    800021ec:	00012997          	auipc	s3,0x12
    800021f0:	8ac98993          	addi	s3,s3,-1876 # 80013a98 <shmtable>
  np->sz = p->sz;
    800021f4:	02000a37          	lui	s4,0x2000
    800021f8:	1a6d                	addi	s4,s4,-5 # 1fffffb <_entry-0x7e000005>
    800021fa:	0a36                	slli	s4,s4,0xd
  for(key = 0; key < SHM_PAGES; key++){
    800021fc:	4901                	li	s2,0
    if((p->shm_mask & (1U << key)) == 0)
    800021fe:	4c05                	li	s8,1
  for(key = 0; key < SHM_PAGES; key++){
    80002200:	4ca1                	li	s9,8
    80002202:	a055                	j	800022a6 <kthread_create+0x10a>
  printf("kthread_create: null stack\n");
    80002204:	00006517          	auipc	a0,0x6
    80002208:	f9c50513          	addi	a0,a0,-100 # 800081a0 <etext+0x1a0>
    8000220c:	aeefe0ef          	jal	800004fa <printf>
  return -1;
    80002210:	597d                	li	s2,-1
    80002212:	a2cd                	j	800023f4 <kthread_create+0x258>
    printf("kthread_create: allocproc failed\n");
    80002214:	00006517          	auipc	a0,0x6
    80002218:	fac50513          	addi	a0,a0,-84 # 800081c0 <etext+0x1c0>
    8000221c:	adefe0ef          	jal	800004fa <printf>
    return -1;
    80002220:	597d                	li	s2,-1
    80002222:	74a6                	ld	s1,104(sp)
    80002224:	6aa6                	ld	s5,72(sp)
    80002226:	a2f9                	j	800023f4 <kthread_create+0x258>
    printf("kthread_create: uvmshare failed\n");
    80002228:	00006517          	auipc	a0,0x6
    8000222c:	fc050513          	addi	a0,a0,-64 # 800081e8 <etext+0x1e8>
    80002230:	acafe0ef          	jal	800004fa <printf>
    freeproc(np);
    80002234:	8526                	mv	a0,s1
    80002236:	bfbff0ef          	jal	80001e30 <freeproc>
    release(&np->lock);
    8000223a:	8526                	mv	a0,s1
    8000223c:	a2bfe0ef          	jal	80000c66 <release>
    return -1;
    80002240:	597d                	li	s2,-1
    80002242:	74a6                	ld	s1,104(sp)
    80002244:	6aa6                	ld	s5,72(sp)
    80002246:	a27d                	j	800023f4 <kthread_create+0x258>
      printf("kthread_create: shm key %d has null pa\n", key);
    80002248:	85ca                	mv	a1,s2
    8000224a:	00006517          	auipc	a0,0x6
    8000224e:	fc650513          	addi	a0,a0,-58 # 80008210 <etext+0x210>
    80002252:	aa8fe0ef          	jal	800004fa <printf>
      release(&shmtable[key].lock);
    80002256:	854e                	mv	a0,s3
    80002258:	a0ffe0ef          	jal	80000c66 <release>
      freeproc(np);
    8000225c:	8526                	mv	a0,s1
    8000225e:	bd3ff0ef          	jal	80001e30 <freeproc>
      release(&np->lock);
    80002262:	8526                	mv	a0,s1
    80002264:	a03fe0ef          	jal	80000c66 <release>
      return -1;
    80002268:	597d                	li	s2,-1
    8000226a:	74a6                	ld	s1,104(sp)
    8000226c:	69e6                	ld	s3,88(sp)
    8000226e:	6a46                	ld	s4,80(sp)
    80002270:	6aa6                	ld	s5,72(sp)
    80002272:	6b06                	ld	s6,64(sp)
    80002274:	7be2                	ld	s7,56(sp)
    80002276:	7c42                	ld	s8,48(sp)
    80002278:	7ca2                	ld	s9,40(sp)
    8000227a:	aaad                	j	800023f4 <kthread_create+0x258>
    shmtable[key].refcnt++;
    8000227c:	0209a783          	lw	a5,32(s3)
    80002280:	2785                	addiw	a5,a5,1
    80002282:	02f9a023          	sw	a5,32(s3)
    np->shm_mask |= (1U << key);
    80002286:	1704a783          	lw	a5,368(s1)
    8000228a:	0167e7b3          	or	a5,a5,s6
    8000228e:	16f4a823          	sw	a5,368(s1)
    release(&shmtable[key].lock);
    80002292:	854e                	mv	a0,s3
    80002294:	9d3fe0ef          	jal	80000c66 <release>
  for(key = 0; key < SHM_PAGES; key++){
    80002298:	2905                	addiw	s2,s2,1
    8000229a:	02898993          	addi	s3,s3,40
    8000229e:	6785                	lui	a5,0x1
    800022a0:	9a3e                	add	s4,s4,a5
    800022a2:	07990163          	beq	s2,s9,80002304 <kthread_create+0x168>
    if((p->shm_mask & (1U << key)) == 0)
    800022a6:	012c1b3b          	sllw	s6,s8,s2
    800022aa:	170aa783          	lw	a5,368(s5)
    800022ae:	0167f7b3          	and	a5,a5,s6
    800022b2:	2781                	sext.w	a5,a5
    800022b4:	d3f5                	beqz	a5,80002298 <kthread_create+0xfc>
    acquire(&shmtable[key].lock);
    800022b6:	854e                	mv	a0,s3
    800022b8:	917fe0ef          	jal	80000bce <acquire>
    if(shmtable[key].pa == 0){
    800022bc:	0189b683          	ld	a3,24(s3)
    800022c0:	d6c1                	beqz	a3,80002248 <kthread_create+0xac>
    if(mappages(np->pagetable, va, PGSIZE, (uint64)shmtable[key].pa,
    800022c2:	4759                	li	a4,22
    800022c4:	6605                	lui	a2,0x1
    800022c6:	85d2                	mv	a1,s4
    800022c8:	6ca8                	ld	a0,88(s1)
    800022ca:	d25fe0ef          	jal	80000fee <mappages>
    800022ce:	d55d                	beqz	a0,8000227c <kthread_create+0xe0>
      printf("kthread_create: shm remap failed for key %d\n", key);
    800022d0:	85ca                	mv	a1,s2
    800022d2:	00006517          	auipc	a0,0x6
    800022d6:	f6650513          	addi	a0,a0,-154 # 80008238 <etext+0x238>
    800022da:	a20fe0ef          	jal	800004fa <printf>
      release(&shmtable[key].lock);
    800022de:	854e                	mv	a0,s3
    800022e0:	987fe0ef          	jal	80000c66 <release>
      freeproc(np);
    800022e4:	8526                	mv	a0,s1
    800022e6:	b4bff0ef          	jal	80001e30 <freeproc>
      release(&np->lock);
    800022ea:	8526                	mv	a0,s1
    800022ec:	97bfe0ef          	jal	80000c66 <release>
      return -1;
    800022f0:	597d                	li	s2,-1
    800022f2:	74a6                	ld	s1,104(sp)
    800022f4:	69e6                	ld	s3,88(sp)
    800022f6:	6a46                	ld	s4,80(sp)
    800022f8:	6aa6                	ld	s5,72(sp)
    800022fa:	6b06                	ld	s6,64(sp)
    800022fc:	7be2                	ld	s7,56(sp)
    800022fe:	7c42                	ld	s8,48(sp)
    80002300:	7ca2                	ld	s9,40(sp)
    80002302:	a8cd                	j	800023f4 <kthread_create+0x258>
  *(np->trapframe) = *(p->trapframe);
    80002304:	060ab683          	ld	a3,96(s5)
    80002308:	87b6                	mv	a5,a3
    8000230a:	70b8                	ld	a4,96(s1)
    8000230c:	12068693          	addi	a3,a3,288
    80002310:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002314:	6788                	ld	a0,8(a5)
    80002316:	6b8c                	ld	a1,16(a5)
    80002318:	6f90                	ld	a2,24(a5)
    8000231a:	01073023          	sd	a6,0(a4)
    8000231e:	e708                	sd	a0,8(a4)
    80002320:	eb0c                	sd	a1,16(a4)
    80002322:	ef10                	sd	a2,24(a4)
    80002324:	02078793          	addi	a5,a5,32
    80002328:	02070713          	addi	a4,a4,32
    8000232c:	fed792e3          	bne	a5,a3,80002310 <kthread_create+0x174>
  np->trapframe->epc = fcn;
    80002330:	70bc                	ld	a5,96(s1)
    80002332:	01b7bc23          	sd	s11,24(a5)
  np->trapframe->a0 = arg;
    80002336:	70bc                	ld	a5,96(s1)
    80002338:	f8843703          	ld	a4,-120(s0)
    8000233c:	fbb8                	sd	a4,112(a5)
  np->trapframe->sp = stack + 4096;
    8000233e:	70bc                	ld	a5,96(s1)
    80002340:	6705                	lui	a4,0x1
    80002342:	9d3a                	add	s10,s10,a4
    80002344:	03a7b823          	sd	s10,48(a5)
  np->is_thread = 1;
    80002348:	4785                	li	a5,1
    8000234a:	dc9c                	sw	a5,56(s1)
  np->tgid = p->is_thread ? p->tgid : p->pid;
    8000234c:	038aa783          	lw	a5,56(s5)
    80002350:	cf91                	beqz	a5,8000236c <kthread_create+0x1d0>
    80002352:	03caa783          	lw	a5,60(s5)
    80002356:	dcdc                	sw	a5,60(s1)
  np->priority = p->priority;
    80002358:	034aa783          	lw	a5,52(s5)
    8000235c:	d8dc                	sw	a5,52(s1)
  for(i = 0; i < NOFILE; i++){
    8000235e:	0d8a8913          	addi	s2,s5,216
    80002362:	0d848993          	addi	s3,s1,216
    80002366:	158a8a13          	addi	s4,s5,344
    8000236a:	a801                	j	8000237a <kthread_create+0x1de>
  np->tgid = p->is_thread ? p->tgid : p->pid;
    8000236c:	030aa783          	lw	a5,48(s5)
    80002370:	b7dd                	j	80002356 <kthread_create+0x1ba>
  for(i = 0; i < NOFILE; i++){
    80002372:	0921                	addi	s2,s2,8
    80002374:	09a1                	addi	s3,s3,8
    80002376:	01490a63          	beq	s2,s4,8000238a <kthread_create+0x1ee>
    if(p->ofile[i])
    8000237a:	00093503          	ld	a0,0(s2)
    8000237e:	d975                	beqz	a0,80002372 <kthread_create+0x1d6>
      np->ofile[i] = filedup(p->ofile[i]);
    80002380:	2f5020ef          	jal	80004e74 <filedup>
    80002384:	00a9b023          	sd	a0,0(s3)
    80002388:	b7ed                	j	80002372 <kthread_create+0x1d6>
  np->cwd = idup(p->cwd);
    8000238a:	158ab503          	ld	a0,344(s5)
    8000238e:	501010ef          	jal	8000408e <idup>
    80002392:	14a4bc23          	sd	a0,344(s1)
  safestrcpy(np->name, p->name, sizeof(np->name));
    80002396:	4641                	li	a2,16
    80002398:	160a8593          	addi	a1,s5,352
    8000239c:	16048513          	addi	a0,s1,352
    800023a0:	a41fe0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    800023a4:	0304a903          	lw	s2,48(s1)
  release(&np->lock);
    800023a8:	8526                	mv	a0,s1
    800023aa:	8bdfe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    800023ae:	00012997          	auipc	s3,0x12
    800023b2:	84298993          	addi	s3,s3,-1982 # 80013bf0 <wait_lock>
    800023b6:	854e                	mv	a0,s3
    800023b8:	817fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    800023bc:	0554b023          	sd	s5,64(s1)
  release(&wait_lock);
    800023c0:	854e                	mv	a0,s3
    800023c2:	8a5fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    800023c6:	8526                	mv	a0,s1
    800023c8:	807fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    800023cc:	478d                	li	a5,3
    800023ce:	cc9c                	sw	a5,24(s1)
  release(&np->lock);
    800023d0:	8526                	mv	a0,s1
    800023d2:	895fe0ef          	jal	80000c66 <release>
  printf("kthread_create: success tid=%d\n", pid);
    800023d6:	85ca                	mv	a1,s2
    800023d8:	00006517          	auipc	a0,0x6
    800023dc:	e9050513          	addi	a0,a0,-368 # 80008268 <etext+0x268>
    800023e0:	91afe0ef          	jal	800004fa <printf>
    800023e4:	74a6                	ld	s1,104(sp)
    800023e6:	69e6                	ld	s3,88(sp)
    800023e8:	6a46                	ld	s4,80(sp)
    800023ea:	6aa6                	ld	s5,72(sp)
    800023ec:	6b06                	ld	s6,64(sp)
    800023ee:	7be2                	ld	s7,56(sp)
    800023f0:	7c42                	ld	s8,48(sp)
    800023f2:	7ca2                	ld	s9,40(sp)
}
    800023f4:	854a                	mv	a0,s2
    800023f6:	70e6                	ld	ra,120(sp)
    800023f8:	7446                	ld	s0,112(sp)
    800023fa:	7906                	ld	s2,96(sp)
    800023fc:	7d02                	ld	s10,32(sp)
    800023fe:	6de2                	ld	s11,24(sp)
    80002400:	6109                	addi	sp,sp,128
    80002402:	8082                	ret

0000000080002404 <kthread_id>:
{
    80002404:	1141                	addi	sp,sp,-16
    80002406:	e406                	sd	ra,8(sp)
    80002408:	e022                	sd	s0,0(sp)
    8000240a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000240c:	deaff0ef          	jal	800019f6 <myproc>
}
    80002410:	5908                	lw	a0,48(a0)
    80002412:	60a2                	ld	ra,8(sp)
    80002414:	6402                	ld	s0,0(sp)
    80002416:	0141                	addi	sp,sp,16
    80002418:	8082                	ret

000000008000241a <scheduler>:
{
    8000241a:	715d                	addi	sp,sp,-80
    8000241c:	e486                	sd	ra,72(sp)
    8000241e:	e0a2                	sd	s0,64(sp)
    80002420:	fc26                	sd	s1,56(sp)
    80002422:	f84a                	sd	s2,48(sp)
    80002424:	f44e                	sd	s3,40(sp)
    80002426:	f052                	sd	s4,32(sp)
    80002428:	ec56                	sd	s5,24(sp)
    8000242a:	e85a                	sd	s6,16(sp)
    8000242c:	e45e                	sd	s7,8(sp)
    8000242e:	e062                	sd	s8,0(sp)
    80002430:	0880                	addi	s0,sp,80
    80002432:	8792                	mv	a5,tp
  int id = r_tp();
    80002434:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002436:	00779b93          	slli	s7,a5,0x7
    8000243a:	00011717          	auipc	a4,0x11
    8000243e:	65e70713          	addi	a4,a4,1630 # 80013a98 <shmtable>
    80002442:	975e                	add	a4,a4,s7
    80002444:	16073823          	sd	zero,368(a4)
      swtch(&c->context, &best->context);
    80002448:	00011717          	auipc	a4,0x11
    8000244c:	7c870713          	addi	a4,a4,1992 # 80013c10 <cpus+0x8>
    80002450:	9bba                	add	s7,s7,a4
    best = 0;
    80002452:	4b01                	li	s6,0
      if(p->state == RUNNABLE){
    80002454:	4a0d                	li	s4,3
    for(p = proc; p < &proc[NPROC]; p++){
    80002456:	00018997          	auipc	s3,0x18
    8000245a:	9b298993          	addi	s3,s3,-1614 # 80019e08 <tickslock>
      best->state = RUNNING;
    8000245e:	4c11                	li	s8,4
      c->proc = best;
    80002460:	079e                	slli	a5,a5,0x7
    80002462:	00011a97          	auipc	s5,0x11
    80002466:	636a8a93          	addi	s5,s5,1590 # 80013a98 <shmtable>
    8000246a:	9abe                	add	s5,s5,a5
    8000246c:	a08d                	j	800024ce <scheduler+0xb4>
          release(&p->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	ff6fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80002474:	17848493          	addi	s1,s1,376
    80002478:	03348d63          	beq	s1,s3,800024b2 <scheduler+0x98>
      acquire(&p->lock);
    8000247c:	8526                	mv	a0,s1
    8000247e:	f50fe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE){
    80002482:	4c9c                	lw	a5,24(s1)
    80002484:	01479e63          	bne	a5,s4,800024a0 <scheduler+0x86>
        if(best == 0 || p->priority > best->priority){
    80002488:	04090f63          	beqz	s2,800024e6 <scheduler+0xcc>
    8000248c:	58d8                	lw	a4,52(s1)
    8000248e:	03492783          	lw	a5,52(s2)
    80002492:	fce7dee3          	bge	a5,a4,8000246e <scheduler+0x54>
            release(&best->lock);
    80002496:	854a                	mv	a0,s2
    80002498:	fcefe0ef          	jal	80000c66 <release>
          best = p;
    8000249c:	8926                	mv	s2,s1
    8000249e:	bfd9                	j	80002474 <scheduler+0x5a>
        release(&p->lock);
    800024a0:	8526                	mv	a0,s1
    800024a2:	fc4fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++){
    800024a6:	17848493          	addi	s1,s1,376
    800024aa:	fd3499e3          	bne	s1,s3,8000247c <scheduler+0x62>
    if(best != 0){
    800024ae:	02090063          	beqz	s2,800024ce <scheduler+0xb4>
      best->state = RUNNING;
    800024b2:	01892c23          	sw	s8,24(s2)
      c->proc = best;
    800024b6:	172ab823          	sd	s2,368(s5)
      swtch(&c->context, &best->context);
    800024ba:	06890593          	addi	a1,s2,104
    800024be:	855e                	mv	a0,s7
    800024c0:	013000ef          	jal	80002cd2 <swtch>
      c->proc = 0;
    800024c4:	160ab823          	sd	zero,368(s5)
      release(&best->lock);
    800024c8:	854a                	mv	a0,s2
    800024ca:	f9cfe0ef          	jal	80000c66 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024ce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024d2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024d6:	10079073          	csrw	sstatus,a5
    best = 0;
    800024da:	895a                	mv	s2,s6
    for(p = proc; p < &proc[NPROC]; p++){
    800024dc:	00012497          	auipc	s1,0x12
    800024e0:	b2c48493          	addi	s1,s1,-1236 # 80014008 <proc>
    800024e4:	bf61                	j	8000247c <scheduler+0x62>
          best = p;
    800024e6:	8926                	mv	s2,s1
    800024e8:	b771                	j	80002474 <scheduler+0x5a>

00000000800024ea <sched>:
{
    800024ea:	7179                	addi	sp,sp,-48
    800024ec:	f406                	sd	ra,40(sp)
    800024ee:	f022                	sd	s0,32(sp)
    800024f0:	ec26                	sd	s1,24(sp)
    800024f2:	e84a                	sd	s2,16(sp)
    800024f4:	e44e                	sd	s3,8(sp)
    800024f6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800024f8:	cfeff0ef          	jal	800019f6 <myproc>
    800024fc:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800024fe:	e66fe0ef          	jal	80000b64 <holding>
    80002502:	c92d                	beqz	a0,80002574 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002504:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002506:	2781                	sext.w	a5,a5
    80002508:	079e                	slli	a5,a5,0x7
    8000250a:	00011717          	auipc	a4,0x11
    8000250e:	58e70713          	addi	a4,a4,1422 # 80013a98 <shmtable>
    80002512:	97ba                	add	a5,a5,a4
    80002514:	1e87a703          	lw	a4,488(a5)
    80002518:	4785                	li	a5,1
    8000251a:	06f71363          	bne	a4,a5,80002580 <sched+0x96>
  if(p->state == RUNNING)
    8000251e:	4c98                	lw	a4,24(s1)
    80002520:	4791                	li	a5,4
    80002522:	06f70563          	beq	a4,a5,8000258c <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002526:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000252a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000252c:	e7b5                	bnez	a5,80002598 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000252e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002530:	00011917          	auipc	s2,0x11
    80002534:	56890913          	addi	s2,s2,1384 # 80013a98 <shmtable>
    80002538:	2781                	sext.w	a5,a5
    8000253a:	079e                	slli	a5,a5,0x7
    8000253c:	97ca                	add	a5,a5,s2
    8000253e:	1ec7a983          	lw	s3,492(a5)
    80002542:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002544:	2781                	sext.w	a5,a5
    80002546:	079e                	slli	a5,a5,0x7
    80002548:	00011597          	auipc	a1,0x11
    8000254c:	6c858593          	addi	a1,a1,1736 # 80013c10 <cpus+0x8>
    80002550:	95be                	add	a1,a1,a5
    80002552:	06848513          	addi	a0,s1,104
    80002556:	77c000ef          	jal	80002cd2 <swtch>
    8000255a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000255c:	2781                	sext.w	a5,a5
    8000255e:	079e                	slli	a5,a5,0x7
    80002560:	993e                	add	s2,s2,a5
    80002562:	1f392623          	sw	s3,492(s2)
}
    80002566:	70a2                	ld	ra,40(sp)
    80002568:	7402                	ld	s0,32(sp)
    8000256a:	64e2                	ld	s1,24(sp)
    8000256c:	6942                	ld	s2,16(sp)
    8000256e:	69a2                	ld	s3,8(sp)
    80002570:	6145                	addi	sp,sp,48
    80002572:	8082                	ret
    panic("sched p->lock");
    80002574:	00006517          	auipc	a0,0x6
    80002578:	d1450513          	addi	a0,a0,-748 # 80008288 <etext+0x288>
    8000257c:	a64fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80002580:	00006517          	auipc	a0,0x6
    80002584:	d1850513          	addi	a0,a0,-744 # 80008298 <etext+0x298>
    80002588:	a58fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    8000258c:	00006517          	auipc	a0,0x6
    80002590:	d1c50513          	addi	a0,a0,-740 # 800082a8 <etext+0x2a8>
    80002594:	a4cfe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80002598:	00006517          	auipc	a0,0x6
    8000259c:	d2050513          	addi	a0,a0,-736 # 800082b8 <etext+0x2b8>
    800025a0:	a40fe0ef          	jal	800007e0 <panic>

00000000800025a4 <yield>:
{
    800025a4:	1101                	addi	sp,sp,-32
    800025a6:	ec06                	sd	ra,24(sp)
    800025a8:	e822                	sd	s0,16(sp)
    800025aa:	e426                	sd	s1,8(sp)
    800025ac:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800025ae:	c48ff0ef          	jal	800019f6 <myproc>
    800025b2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800025b4:	e1afe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    800025b8:	478d                	li	a5,3
    800025ba:	cc9c                	sw	a5,24(s1)
  sched();
    800025bc:	f2fff0ef          	jal	800024ea <sched>
  release(&p->lock);
    800025c0:	8526                	mv	a0,s1
    800025c2:	ea4fe0ef          	jal	80000c66 <release>
}
    800025c6:	60e2                	ld	ra,24(sp)
    800025c8:	6442                	ld	s0,16(sp)
    800025ca:	64a2                	ld	s1,8(sp)
    800025cc:	6105                	addi	sp,sp,32
    800025ce:	8082                	ret

00000000800025d0 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800025d0:	7179                	addi	sp,sp,-48
    800025d2:	f406                	sd	ra,40(sp)
    800025d4:	f022                	sd	s0,32(sp)
    800025d6:	ec26                	sd	s1,24(sp)
    800025d8:	e84a                	sd	s2,16(sp)
    800025da:	e44e                	sd	s3,8(sp)
    800025dc:	1800                	addi	s0,sp,48
    800025de:	89aa                	mv	s3,a0
    800025e0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800025e2:	c14ff0ef          	jal	800019f6 <myproc>
    800025e6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800025e8:	de6fe0ef          	jal	80000bce <acquire>
  release(lk);
    800025ec:	854a                	mv	a0,s2
    800025ee:	e78fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    800025f2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800025f6:	4789                	li	a5,2
    800025f8:	cc9c                	sw	a5,24(s1)

  sched();
    800025fa:	ef1ff0ef          	jal	800024ea <sched>

  // Tidy up.
  p->chan = 0;
    800025fe:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002602:	8526                	mv	a0,s1
    80002604:	e62fe0ef          	jal	80000c66 <release>
  acquire(lk);
    80002608:	854a                	mv	a0,s2
    8000260a:	dc4fe0ef          	jal	80000bce <acquire>
}
    8000260e:	70a2                	ld	ra,40(sp)
    80002610:	7402                	ld	s0,32(sp)
    80002612:	64e2                	ld	s1,24(sp)
    80002614:	6942                	ld	s2,16(sp)
    80002616:	69a2                	ld	s3,8(sp)
    80002618:	6145                	addi	sp,sp,48
    8000261a:	8082                	ret

000000008000261c <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000261c:	7139                	addi	sp,sp,-64
    8000261e:	fc06                	sd	ra,56(sp)
    80002620:	f822                	sd	s0,48(sp)
    80002622:	f426                	sd	s1,40(sp)
    80002624:	f04a                	sd	s2,32(sp)
    80002626:	ec4e                	sd	s3,24(sp)
    80002628:	e852                	sd	s4,16(sp)
    8000262a:	e456                	sd	s5,8(sp)
    8000262c:	0080                	addi	s0,sp,64
    8000262e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002630:	00012497          	auipc	s1,0x12
    80002634:	9d848493          	addi	s1,s1,-1576 # 80014008 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002638:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000263a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000263c:	00017917          	auipc	s2,0x17
    80002640:	7cc90913          	addi	s2,s2,1996 # 80019e08 <tickslock>
    80002644:	a801                	j	80002654 <wakeup+0x38>
      }
      release(&p->lock);
    80002646:	8526                	mv	a0,s1
    80002648:	e1efe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000264c:	17848493          	addi	s1,s1,376
    80002650:	03248263          	beq	s1,s2,80002674 <wakeup+0x58>
    if(p != myproc()){
    80002654:	ba2ff0ef          	jal	800019f6 <myproc>
    80002658:	fea48ae3          	beq	s1,a0,8000264c <wakeup+0x30>
      acquire(&p->lock);
    8000265c:	8526                	mv	a0,s1
    8000265e:	d70fe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002662:	4c9c                	lw	a5,24(s1)
    80002664:	ff3791e3          	bne	a5,s3,80002646 <wakeup+0x2a>
    80002668:	709c                	ld	a5,32(s1)
    8000266a:	fd479ee3          	bne	a5,s4,80002646 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000266e:	0154ac23          	sw	s5,24(s1)
    80002672:	bfd1                	j	80002646 <wakeup+0x2a>
    }
  }
}
    80002674:	70e2                	ld	ra,56(sp)
    80002676:	7442                	ld	s0,48(sp)
    80002678:	74a2                	ld	s1,40(sp)
    8000267a:	7902                	ld	s2,32(sp)
    8000267c:	69e2                	ld	s3,24(sp)
    8000267e:	6a42                	ld	s4,16(sp)
    80002680:	6aa2                	ld	s5,8(sp)
    80002682:	6121                	addi	sp,sp,64
    80002684:	8082                	ret

0000000080002686 <reparent>:
{
    80002686:	7179                	addi	sp,sp,-48
    80002688:	f406                	sd	ra,40(sp)
    8000268a:	f022                	sd	s0,32(sp)
    8000268c:	ec26                	sd	s1,24(sp)
    8000268e:	e84a                	sd	s2,16(sp)
    80002690:	e44e                	sd	s3,8(sp)
    80002692:	e052                	sd	s4,0(sp)
    80002694:	1800                	addi	s0,sp,48
    80002696:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002698:	00012497          	auipc	s1,0x12
    8000269c:	97048493          	addi	s1,s1,-1680 # 80014008 <proc>
      pp->parent = initproc;
    800026a0:	00009a17          	auipc	s4,0x9
    800026a4:	2f0a0a13          	addi	s4,s4,752 # 8000b990 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800026a8:	00017997          	auipc	s3,0x17
    800026ac:	76098993          	addi	s3,s3,1888 # 80019e08 <tickslock>
    800026b0:	a029                	j	800026ba <reparent+0x34>
    800026b2:	17848493          	addi	s1,s1,376
    800026b6:	01348b63          	beq	s1,s3,800026cc <reparent+0x46>
    if(pp->parent == p){
    800026ba:	60bc                	ld	a5,64(s1)
    800026bc:	ff279be3          	bne	a5,s2,800026b2 <reparent+0x2c>
      pp->parent = initproc;
    800026c0:	000a3503          	ld	a0,0(s4)
    800026c4:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    800026c6:	f57ff0ef          	jal	8000261c <wakeup>
    800026ca:	b7e5                	j	800026b2 <reparent+0x2c>
}
    800026cc:	70a2                	ld	ra,40(sp)
    800026ce:	7402                	ld	s0,32(sp)
    800026d0:	64e2                	ld	s1,24(sp)
    800026d2:	6942                	ld	s2,16(sp)
    800026d4:	69a2                	ld	s3,8(sp)
    800026d6:	6a02                	ld	s4,0(sp)
    800026d8:	6145                	addi	sp,sp,48
    800026da:	8082                	ret

00000000800026dc <kexit>:
{
    800026dc:	7179                	addi	sp,sp,-48
    800026de:	f406                	sd	ra,40(sp)
    800026e0:	f022                	sd	s0,32(sp)
    800026e2:	ec26                	sd	s1,24(sp)
    800026e4:	e84a                	sd	s2,16(sp)
    800026e6:	e44e                	sd	s3,8(sp)
    800026e8:	e052                	sd	s4,0(sp)
    800026ea:	1800                	addi	s0,sp,48
    800026ec:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800026ee:	b08ff0ef          	jal	800019f6 <myproc>
    800026f2:	89aa                	mv	s3,a0
  if(p == initproc)
    800026f4:	00009797          	auipc	a5,0x9
    800026f8:	29c7b783          	ld	a5,668(a5) # 8000b990 <initproc>
    800026fc:	0d850493          	addi	s1,a0,216
    80002700:	15850913          	addi	s2,a0,344
    80002704:	00a79f63          	bne	a5,a0,80002722 <kexit+0x46>
    panic("init exiting");
    80002708:	00006517          	auipc	a0,0x6
    8000270c:	bc850513          	addi	a0,a0,-1080 # 800082d0 <etext+0x2d0>
    80002710:	8d0fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002714:	7a6020ef          	jal	80004eba <fileclose>
      p->ofile[fd] = 0;
    80002718:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000271c:	04a1                	addi	s1,s1,8
    8000271e:	01248563          	beq	s1,s2,80002728 <kexit+0x4c>
    if(p->ofile[fd]){
    80002722:	6088                	ld	a0,0(s1)
    80002724:	f965                	bnez	a0,80002714 <kexit+0x38>
    80002726:	bfdd                	j	8000271c <kexit+0x40>
  begin_op();
    80002728:	386020ef          	jal	80004aae <begin_op>
  iput(p->cwd);
    8000272c:	1589b503          	ld	a0,344(s3)
    80002730:	317010ef          	jal	80004246 <iput>
  end_op();
    80002734:	3e4020ef          	jal	80004b18 <end_op>
  p->cwd = 0;
    80002738:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    8000273c:	00011497          	auipc	s1,0x11
    80002740:	4b448493          	addi	s1,s1,1204 # 80013bf0 <wait_lock>
    80002744:	8526                	mv	a0,s1
    80002746:	c88fe0ef          	jal	80000bce <acquire>
  reparent(p);
    8000274a:	854e                	mv	a0,s3
    8000274c:	f3bff0ef          	jal	80002686 <reparent>
  wakeup(p->parent);
    80002750:	0409b503          	ld	a0,64(s3)
    80002754:	ec9ff0ef          	jal	8000261c <wakeup>
  acquire(&p->lock);
    80002758:	854e                	mv	a0,s3
    8000275a:	c74fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    8000275e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002762:	4795                	li	a5,5
    80002764:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002768:	8526                	mv	a0,s1
    8000276a:	cfcfe0ef          	jal	80000c66 <release>
  sched();
    8000276e:	d7dff0ef          	jal	800024ea <sched>
  panic("zombie exit");
    80002772:	00006517          	auipc	a0,0x6
    80002776:	b6e50513          	addi	a0,a0,-1170 # 800082e0 <etext+0x2e0>
    8000277a:	866fe0ef          	jal	800007e0 <panic>

000000008000277e <kthread_exit>:
{
    8000277e:	7179                	addi	sp,sp,-48
    80002780:	f406                	sd	ra,40(sp)
    80002782:	f022                	sd	s0,32(sp)
    80002784:	ec26                	sd	s1,24(sp)
    80002786:	e84a                	sd	s2,16(sp)
    80002788:	e44e                	sd	s3,8(sp)
    8000278a:	e052                	sd	s4,0(sp)
    8000278c:	1800                	addi	s0,sp,48
    8000278e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002790:	a66ff0ef          	jal	800019f6 <myproc>
    80002794:	89aa                	mv	s3,a0
  if(!p->is_thread)
    80002796:	5d1c                	lw	a5,56(a0)
    80002798:	0d850493          	addi	s1,a0,216
    8000279c:	15850913          	addi	s2,a0,344
    800027a0:	e799                	bnez	a5,800027ae <kthread_exit+0x30>
  kexit(status);
    800027a2:	8552                	mv	a0,s4
    800027a4:	f39ff0ef          	jal	800026dc <kexit>
  for(fd = 0; fd < NOFILE; fd++){
    800027a8:	04a1                	addi	s1,s1,8
    800027aa:	01248963          	beq	s1,s2,800027bc <kthread_exit+0x3e>
    if(p->ofile[fd]){
    800027ae:	6088                	ld	a0,0(s1)
    800027b0:	dd65                	beqz	a0,800027a8 <kthread_exit+0x2a>
      p->ofile[fd] = 0;
    800027b2:	0004b023          	sd	zero,0(s1)
      fileclose(f);
    800027b6:	704020ef          	jal	80004eba <fileclose>
    800027ba:	b7fd                	j	800027a8 <kthread_exit+0x2a>
  begin_op();
    800027bc:	2f2020ef          	jal	80004aae <begin_op>
  iput(p->cwd);
    800027c0:	1589b503          	ld	a0,344(s3)
    800027c4:	283010ef          	jal	80004246 <iput>
  end_op();
    800027c8:	350020ef          	jal	80004b18 <end_op>
  p->cwd = 0;
    800027cc:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    800027d0:	00011497          	auipc	s1,0x11
    800027d4:	42048493          	addi	s1,s1,1056 # 80013bf0 <wait_lock>
    800027d8:	8526                	mv	a0,s1
    800027da:	bf4fe0ef          	jal	80000bce <acquire>
  reparent(p);
    800027de:	854e                	mv	a0,s3
    800027e0:	ea7ff0ef          	jal	80002686 <reparent>
  wakeup(p->parent);
    800027e4:	0409b503          	ld	a0,64(s3)
    800027e8:	e35ff0ef          	jal	8000261c <wakeup>
  acquire(&p->lock);
    800027ec:	854e                	mv	a0,s3
    800027ee:	be0fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    800027f2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800027f6:	4795                	li	a5,5
    800027f8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800027fc:	8526                	mv	a0,s1
    800027fe:	c68fe0ef          	jal	80000c66 <release>
  sched();
    80002802:	ce9ff0ef          	jal	800024ea <sched>
  panic("zombie thread_exit");
    80002806:	00006517          	auipc	a0,0x6
    8000280a:	aea50513          	addi	a0,a0,-1302 # 800082f0 <etext+0x2f0>
    8000280e:	fd3fd0ef          	jal	800007e0 <panic>

0000000080002812 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002812:	7179                	addi	sp,sp,-48
    80002814:	f406                	sd	ra,40(sp)
    80002816:	f022                	sd	s0,32(sp)
    80002818:	ec26                	sd	s1,24(sp)
    8000281a:	e84a                	sd	s2,16(sp)
    8000281c:	e44e                	sd	s3,8(sp)
    8000281e:	1800                	addi	s0,sp,48
    80002820:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002822:	00011497          	auipc	s1,0x11
    80002826:	7e648493          	addi	s1,s1,2022 # 80014008 <proc>
    8000282a:	00017997          	auipc	s3,0x17
    8000282e:	5de98993          	addi	s3,s3,1502 # 80019e08 <tickslock>
    acquire(&p->lock);
    80002832:	8526                	mv	a0,s1
    80002834:	b9afe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    80002838:	589c                	lw	a5,48(s1)
    8000283a:	01278b63          	beq	a5,s2,80002850 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000283e:	8526                	mv	a0,s1
    80002840:	c26fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002844:	17848493          	addi	s1,s1,376
    80002848:	ff3495e3          	bne	s1,s3,80002832 <kkill+0x20>
  }
  return -1;
    8000284c:	557d                	li	a0,-1
    8000284e:	a819                	j	80002864 <kkill+0x52>
      p->killed = 1;
    80002850:	4785                	li	a5,1
    80002852:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002854:	4c98                	lw	a4,24(s1)
    80002856:	4789                	li	a5,2
    80002858:	00f70d63          	beq	a4,a5,80002872 <kkill+0x60>
      release(&p->lock);
    8000285c:	8526                	mv	a0,s1
    8000285e:	c08fe0ef          	jal	80000c66 <release>
      return 0;
    80002862:	4501                	li	a0,0
}
    80002864:	70a2                	ld	ra,40(sp)
    80002866:	7402                	ld	s0,32(sp)
    80002868:	64e2                	ld	s1,24(sp)
    8000286a:	6942                	ld	s2,16(sp)
    8000286c:	69a2                	ld	s3,8(sp)
    8000286e:	6145                	addi	sp,sp,48
    80002870:	8082                	ret
        p->state = RUNNABLE;
    80002872:	478d                	li	a5,3
    80002874:	cc9c                	sw	a5,24(s1)
    80002876:	b7dd                	j	8000285c <kkill+0x4a>

0000000080002878 <setkilled>:

void
setkilled(struct proc *p)
{
    80002878:	1101                	addi	sp,sp,-32
    8000287a:	ec06                	sd	ra,24(sp)
    8000287c:	e822                	sd	s0,16(sp)
    8000287e:	e426                	sd	s1,8(sp)
    80002880:	1000                	addi	s0,sp,32
    80002882:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002884:	b4afe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    80002888:	4785                	li	a5,1
    8000288a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000288c:	8526                	mv	a0,s1
    8000288e:	bd8fe0ef          	jal	80000c66 <release>
}
    80002892:	60e2                	ld	ra,24(sp)
    80002894:	6442                	ld	s0,16(sp)
    80002896:	64a2                	ld	s1,8(sp)
    80002898:	6105                	addi	sp,sp,32
    8000289a:	8082                	ret

000000008000289c <killed>:

int
killed(struct proc *p)
{
    8000289c:	1101                	addi	sp,sp,-32
    8000289e:	ec06                	sd	ra,24(sp)
    800028a0:	e822                	sd	s0,16(sp)
    800028a2:	e426                	sd	s1,8(sp)
    800028a4:	e04a                	sd	s2,0(sp)
    800028a6:	1000                	addi	s0,sp,32
    800028a8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800028aa:	b24fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    800028ae:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800028b2:	8526                	mv	a0,s1
    800028b4:	bb2fe0ef          	jal	80000c66 <release>
  return k;
}
    800028b8:	854a                	mv	a0,s2
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	64a2                	ld	s1,8(sp)
    800028c0:	6902                	ld	s2,0(sp)
    800028c2:	6105                	addi	sp,sp,32
    800028c4:	8082                	ret

00000000800028c6 <kwait>:
{
    800028c6:	715d                	addi	sp,sp,-80
    800028c8:	e486                	sd	ra,72(sp)
    800028ca:	e0a2                	sd	s0,64(sp)
    800028cc:	fc26                	sd	s1,56(sp)
    800028ce:	f84a                	sd	s2,48(sp)
    800028d0:	f44e                	sd	s3,40(sp)
    800028d2:	f052                	sd	s4,32(sp)
    800028d4:	ec56                	sd	s5,24(sp)
    800028d6:	e85a                	sd	s6,16(sp)
    800028d8:	e45e                	sd	s7,8(sp)
    800028da:	e062                	sd	s8,0(sp)
    800028dc:	0880                	addi	s0,sp,80
    800028de:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800028e0:	916ff0ef          	jal	800019f6 <myproc>
    800028e4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800028e6:	00011517          	auipc	a0,0x11
    800028ea:	30a50513          	addi	a0,a0,778 # 80013bf0 <wait_lock>
    800028ee:	ae0fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    800028f2:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800028f4:	4a15                	li	s4,5
        havekids = 1;
    800028f6:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800028f8:	00017997          	auipc	s3,0x17
    800028fc:	51098993          	addi	s3,s3,1296 # 80019e08 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002900:	00011c17          	auipc	s8,0x11
    80002904:	2f0c0c13          	addi	s8,s8,752 # 80013bf0 <wait_lock>
    80002908:	a871                	j	800029a4 <kwait+0xde>
          pid = pp->pid;
    8000290a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000290e:	000b0c63          	beqz	s6,80002926 <kwait+0x60>
    80002912:	4691                	li	a3,4
    80002914:	02c48613          	addi	a2,s1,44
    80002918:	85da                	mv	a1,s6
    8000291a:	05893503          	ld	a0,88(s2)
    8000291e:	cc5fe0ef          	jal	800015e2 <copyout>
    80002922:	02054b63          	bltz	a0,80002958 <kwait+0x92>
          freeproc(pp);
    80002926:	8526                	mv	a0,s1
    80002928:	d08ff0ef          	jal	80001e30 <freeproc>
          release(&pp->lock);
    8000292c:	8526                	mv	a0,s1
    8000292e:	b38fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    80002932:	00011517          	auipc	a0,0x11
    80002936:	2be50513          	addi	a0,a0,702 # 80013bf0 <wait_lock>
    8000293a:	b2cfe0ef          	jal	80000c66 <release>
}
    8000293e:	854e                	mv	a0,s3
    80002940:	60a6                	ld	ra,72(sp)
    80002942:	6406                	ld	s0,64(sp)
    80002944:	74e2                	ld	s1,56(sp)
    80002946:	7942                	ld	s2,48(sp)
    80002948:	79a2                	ld	s3,40(sp)
    8000294a:	7a02                	ld	s4,32(sp)
    8000294c:	6ae2                	ld	s5,24(sp)
    8000294e:	6b42                	ld	s6,16(sp)
    80002950:	6ba2                	ld	s7,8(sp)
    80002952:	6c02                	ld	s8,0(sp)
    80002954:	6161                	addi	sp,sp,80
    80002956:	8082                	ret
            release(&pp->lock);
    80002958:	8526                	mv	a0,s1
    8000295a:	b0cfe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    8000295e:	00011517          	auipc	a0,0x11
    80002962:	29250513          	addi	a0,a0,658 # 80013bf0 <wait_lock>
    80002966:	b00fe0ef          	jal	80000c66 <release>
            return -1;
    8000296a:	59fd                	li	s3,-1
    8000296c:	bfc9                	j	8000293e <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000296e:	17848493          	addi	s1,s1,376
    80002972:	03348063          	beq	s1,s3,80002992 <kwait+0xcc>
      if(pp->parent == p){
    80002976:	60bc                	ld	a5,64(s1)
    80002978:	ff279be3          	bne	a5,s2,8000296e <kwait+0xa8>
        acquire(&pp->lock);
    8000297c:	8526                	mv	a0,s1
    8000297e:	a50fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    80002982:	4c9c                	lw	a5,24(s1)
    80002984:	f94783e3          	beq	a5,s4,8000290a <kwait+0x44>
        release(&pp->lock);
    80002988:	8526                	mv	a0,s1
    8000298a:	adcfe0ef          	jal	80000c66 <release>
        havekids = 1;
    8000298e:	8756                	mv	a4,s5
    80002990:	bff9                	j	8000296e <kwait+0xa8>
    if(!havekids || killed(p)){
    80002992:	cf19                	beqz	a4,800029b0 <kwait+0xea>
    80002994:	854a                	mv	a0,s2
    80002996:	f07ff0ef          	jal	8000289c <killed>
    8000299a:	e919                	bnez	a0,800029b0 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000299c:	85e2                	mv	a1,s8
    8000299e:	854a                	mv	a0,s2
    800029a0:	c31ff0ef          	jal	800025d0 <sleep>
    havekids = 0;
    800029a4:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800029a6:	00011497          	auipc	s1,0x11
    800029aa:	66248493          	addi	s1,s1,1634 # 80014008 <proc>
    800029ae:	b7e1                	j	80002976 <kwait+0xb0>
      release(&wait_lock);
    800029b0:	00011517          	auipc	a0,0x11
    800029b4:	24050513          	addi	a0,a0,576 # 80013bf0 <wait_lock>
    800029b8:	aaefe0ef          	jal	80000c66 <release>
      return -1;
    800029bc:	59fd                	li	s3,-1
    800029be:	b741                	j	8000293e <kwait+0x78>

00000000800029c0 <kwaitpid>:
{
    800029c0:	711d                	addi	sp,sp,-96
    800029c2:	ec86                	sd	ra,88(sp)
    800029c4:	e8a2                	sd	s0,80(sp)
    800029c6:	e4a6                	sd	s1,72(sp)
    800029c8:	e0ca                	sd	s2,64(sp)
    800029ca:	fc4e                	sd	s3,56(sp)
    800029cc:	f852                	sd	s4,48(sp)
    800029ce:	f456                	sd	s5,40(sp)
    800029d0:	f05a                	sd	s6,32(sp)
    800029d2:	ec5e                	sd	s7,24(sp)
    800029d4:	e862                	sd	s8,16(sp)
    800029d6:	e466                	sd	s9,8(sp)
    800029d8:	1080                	addi	s0,sp,96
    800029da:	8a2a                	mv	s4,a0
    800029dc:	8cae                	mv	s9,a1
  struct proc *p = myproc();
    800029de:	818ff0ef          	jal	800019f6 <myproc>
    800029e2:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800029e4:	00011517          	auipc	a0,0x11
    800029e8:	20c50513          	addi	a0,a0,524 # 80013bf0 <wait_lock>
    800029ec:	9e2fe0ef          	jal	80000bce <acquire>
    found = 0;
    800029f0:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800029f2:	4a95                	li	s5,5
        found = 1;
    800029f4:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800029f6:	00017997          	auipc	s3,0x17
    800029fa:	41298993          	addi	s3,s3,1042 # 80019e08 <tickslock>
    sleep(p, &wait_lock);
    800029fe:	00011c17          	auipc	s8,0x11
    80002a02:	1f2c0c13          	addi	s8,s8,498 # 80013bf0 <wait_lock>
    80002a06:	a04d                	j	80002aa8 <kwaitpid+0xe8>
            release(&pp->lock);
    80002a08:	8526                	mv	a0,s1
    80002a0a:	a5cfe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    80002a0e:	00011517          	auipc	a0,0x11
    80002a12:	1e250513          	addi	a0,a0,482 # 80013bf0 <wait_lock>
    80002a16:	a50fe0ef          	jal	80000c66 <release>
            return -1;
    80002a1a:	59fd                	li	s3,-1
    80002a1c:	a8b9                	j	80002a7a <kwaitpid+0xba>
        release(&pp->lock);
    80002a1e:	8526                	mv	a0,s1
    80002a20:	a46fe0ef          	jal	80000c66 <release>
        found = 1;
    80002a24:	875a                	mv	a4,s6
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a26:	17848493          	addi	s1,s1,376
    80002a2a:	07348663          	beq	s1,s3,80002a96 <kwaitpid+0xd6>
      if(pp->parent == p && pp->pid == wanted_pid){
    80002a2e:	60bc                	ld	a5,64(s1)
    80002a30:	ff279be3          	bne	a5,s2,80002a26 <kwaitpid+0x66>
    80002a34:	589c                	lw	a5,48(s1)
    80002a36:	ff4798e3          	bne	a5,s4,80002a26 <kwaitpid+0x66>
        acquire(&pp->lock);
    80002a3a:	8526                	mv	a0,s1
    80002a3c:	992fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    80002a40:	4c9c                	lw	a5,24(s1)
    80002a42:	fd579ee3          	bne	a5,s5,80002a1e <kwaitpid+0x5e>
          pid = pp->pid;
    80002a46:	0304a983          	lw	s3,48(s1)
          if(addr != 0 &&
    80002a4a:	000c8c63          	beqz	s9,80002a62 <kwaitpid+0xa2>
             copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002a4e:	4691                	li	a3,4
    80002a50:	02c48613          	addi	a2,s1,44
    80002a54:	85e6                	mv	a1,s9
    80002a56:	05893503          	ld	a0,88(s2)
    80002a5a:	b89fe0ef          	jal	800015e2 <copyout>
          if(addr != 0 &&
    80002a5e:	fa0545e3          	bltz	a0,80002a08 <kwaitpid+0x48>
          freeproc(pp);
    80002a62:	8526                	mv	a0,s1
    80002a64:	bccff0ef          	jal	80001e30 <freeproc>
          release(&pp->lock);
    80002a68:	8526                	mv	a0,s1
    80002a6a:	9fcfe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    80002a6e:	00011517          	auipc	a0,0x11
    80002a72:	18250513          	addi	a0,a0,386 # 80013bf0 <wait_lock>
    80002a76:	9f0fe0ef          	jal	80000c66 <release>
}
    80002a7a:	854e                	mv	a0,s3
    80002a7c:	60e6                	ld	ra,88(sp)
    80002a7e:	6446                	ld	s0,80(sp)
    80002a80:	64a6                	ld	s1,72(sp)
    80002a82:	6906                	ld	s2,64(sp)
    80002a84:	79e2                	ld	s3,56(sp)
    80002a86:	7a42                	ld	s4,48(sp)
    80002a88:	7aa2                	ld	s5,40(sp)
    80002a8a:	7b02                	ld	s6,32(sp)
    80002a8c:	6be2                	ld	s7,24(sp)
    80002a8e:	6c42                	ld	s8,16(sp)
    80002a90:	6ca2                	ld	s9,8(sp)
    80002a92:	6125                	addi	sp,sp,96
    80002a94:	8082                	ret
    if(!found || killed(p)){
    80002a96:	cf19                	beqz	a4,80002ab4 <kwaitpid+0xf4>
    80002a98:	854a                	mv	a0,s2
    80002a9a:	e03ff0ef          	jal	8000289c <killed>
    80002a9e:	e919                	bnez	a0,80002ab4 <kwaitpid+0xf4>
    sleep(p, &wait_lock);
    80002aa0:	85e2                	mv	a1,s8
    80002aa2:	854a                	mv	a0,s2
    80002aa4:	b2dff0ef          	jal	800025d0 <sleep>
    found = 0;
    80002aa8:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002aaa:	00011497          	auipc	s1,0x11
    80002aae:	55e48493          	addi	s1,s1,1374 # 80014008 <proc>
    80002ab2:	bfb5                	j	80002a2e <kwaitpid+0x6e>
      release(&wait_lock);
    80002ab4:	00011517          	auipc	a0,0x11
    80002ab8:	13c50513          	addi	a0,a0,316 # 80013bf0 <wait_lock>
    80002abc:	9aafe0ef          	jal	80000c66 <release>
      return -1;
    80002ac0:	59fd                	li	s3,-1
    80002ac2:	bf65                	j	80002a7a <kwaitpid+0xba>

0000000080002ac4 <kthread_join>:
{
    80002ac4:	715d                	addi	sp,sp,-80
    80002ac6:	e486                	sd	ra,72(sp)
    80002ac8:	e0a2                	sd	s0,64(sp)
    80002aca:	fc26                	sd	s1,56(sp)
    80002acc:	f84a                	sd	s2,48(sp)
    80002ace:	f44e                	sd	s3,40(sp)
    80002ad0:	f052                	sd	s4,32(sp)
    80002ad2:	ec56                	sd	s5,24(sp)
    80002ad4:	e85a                	sd	s6,16(sp)
    80002ad6:	e45e                	sd	s7,8(sp)
    80002ad8:	e062                	sd	s8,0(sp)
    80002ada:	0880                	addi	s0,sp,80
    80002adc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002ade:	f19fe0ef          	jal	800019f6 <myproc>
    80002ae2:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002ae4:	00011517          	auipc	a0,0x11
    80002ae8:	10c50513          	addi	a0,a0,268 # 80013bf0 <wait_lock>
    80002aec:	8e2fe0ef          	jal	80000bce <acquire>
    found = 0;
    80002af0:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002af2:	4a95                	li	s5,5
        found = 1;
    80002af4:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002af6:	00017997          	auipc	s3,0x17
    80002afa:	31298993          	addi	s3,s3,786 # 80019e08 <tickslock>
    sleep(p, &wait_lock);
    80002afe:	00011c17          	auipc	s8,0x11
    80002b02:	0f2c0c13          	addi	s8,s8,242 # 80013bf0 <wait_lock>
    80002b06:	a8a5                	j	80002b7e <kthread_join+0xba>
          int xstate = pp->xstate;
    80002b08:	02c4a903          	lw	s2,44(s1)
          freeproc(pp);
    80002b0c:	8526                	mv	a0,s1
    80002b0e:	b22ff0ef          	jal	80001e30 <freeproc>
          release(&pp->lock);
    80002b12:	8526                	mv	a0,s1
    80002b14:	952fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    80002b18:	00011517          	auipc	a0,0x11
    80002b1c:	0d850513          	addi	a0,a0,216 # 80013bf0 <wait_lock>
    80002b20:	946fe0ef          	jal	80000c66 <release>
}
    80002b24:	854a                	mv	a0,s2
    80002b26:	60a6                	ld	ra,72(sp)
    80002b28:	6406                	ld	s0,64(sp)
    80002b2a:	74e2                	ld	s1,56(sp)
    80002b2c:	7942                	ld	s2,48(sp)
    80002b2e:	79a2                	ld	s3,40(sp)
    80002b30:	7a02                	ld	s4,32(sp)
    80002b32:	6ae2                	ld	s5,24(sp)
    80002b34:	6b42                	ld	s6,16(sp)
    80002b36:	6ba2                	ld	s7,8(sp)
    80002b38:	6c02                	ld	s8,0(sp)
    80002b3a:	6161                	addi	sp,sp,80
    80002b3c:	8082                	ret
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002b3e:	17848493          	addi	s1,s1,376
    80002b42:	03348563          	beq	s1,s3,80002b6c <kthread_join+0xa8>
      if(pp->parent == p && pp->pid == tid && pp->is_thread){
    80002b46:	60bc                	ld	a5,64(s1)
    80002b48:	ff279be3          	bne	a5,s2,80002b3e <kthread_join+0x7a>
    80002b4c:	589c                	lw	a5,48(s1)
    80002b4e:	ff4798e3          	bne	a5,s4,80002b3e <kthread_join+0x7a>
    80002b52:	5c9c                	lw	a5,56(s1)
    80002b54:	d7ed                	beqz	a5,80002b3e <kthread_join+0x7a>
        acquire(&pp->lock);
    80002b56:	8526                	mv	a0,s1
    80002b58:	876fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    80002b5c:	4c9c                	lw	a5,24(s1)
    80002b5e:	fb5785e3          	beq	a5,s5,80002b08 <kthread_join+0x44>
        release(&pp->lock);
    80002b62:	8526                	mv	a0,s1
    80002b64:	902fe0ef          	jal	80000c66 <release>
        found = 1;
    80002b68:	875a                	mv	a4,s6
    80002b6a:	bfd1                	j	80002b3e <kthread_join+0x7a>
    if(!found || killed(p)){
    80002b6c:	cf19                	beqz	a4,80002b8a <kthread_join+0xc6>
    80002b6e:	854a                	mv	a0,s2
    80002b70:	d2dff0ef          	jal	8000289c <killed>
    80002b74:	e919                	bnez	a0,80002b8a <kthread_join+0xc6>
    sleep(p, &wait_lock);
    80002b76:	85e2                	mv	a1,s8
    80002b78:	854a                	mv	a0,s2
    80002b7a:	a57ff0ef          	jal	800025d0 <sleep>
    found = 0;
    80002b7e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002b80:	00011497          	auipc	s1,0x11
    80002b84:	48848493          	addi	s1,s1,1160 # 80014008 <proc>
    80002b88:	bf7d                	j	80002b46 <kthread_join+0x82>
      release(&wait_lock);
    80002b8a:	00011517          	auipc	a0,0x11
    80002b8e:	06650513          	addi	a0,a0,102 # 80013bf0 <wait_lock>
    80002b92:	8d4fe0ef          	jal	80000c66 <release>
      return -1;
    80002b96:	597d                	li	s2,-1
    80002b98:	b771                	j	80002b24 <kthread_join+0x60>

0000000080002b9a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002b9a:	7179                	addi	sp,sp,-48
    80002b9c:	f406                	sd	ra,40(sp)
    80002b9e:	f022                	sd	s0,32(sp)
    80002ba0:	ec26                	sd	s1,24(sp)
    80002ba2:	e84a                	sd	s2,16(sp)
    80002ba4:	e44e                	sd	s3,8(sp)
    80002ba6:	e052                	sd	s4,0(sp)
    80002ba8:	1800                	addi	s0,sp,48
    80002baa:	84aa                	mv	s1,a0
    80002bac:	892e                	mv	s2,a1
    80002bae:	89b2                	mv	s3,a2
    80002bb0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002bb2:	e45fe0ef          	jal	800019f6 <myproc>
  if(user_dst){
    80002bb6:	cc99                	beqz	s1,80002bd4 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002bb8:	86d2                	mv	a3,s4
    80002bba:	864e                	mv	a2,s3
    80002bbc:	85ca                	mv	a1,s2
    80002bbe:	6d28                	ld	a0,88(a0)
    80002bc0:	a23fe0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002bc4:	70a2                	ld	ra,40(sp)
    80002bc6:	7402                	ld	s0,32(sp)
    80002bc8:	64e2                	ld	s1,24(sp)
    80002bca:	6942                	ld	s2,16(sp)
    80002bcc:	69a2                	ld	s3,8(sp)
    80002bce:	6a02                	ld	s4,0(sp)
    80002bd0:	6145                	addi	sp,sp,48
    80002bd2:	8082                	ret
    memmove((char *)dst, src, len);
    80002bd4:	000a061b          	sext.w	a2,s4
    80002bd8:	85ce                	mv	a1,s3
    80002bda:	854a                	mv	a0,s2
    80002bdc:	922fe0ef          	jal	80000cfe <memmove>
    return 0;
    80002be0:	8526                	mv	a0,s1
    80002be2:	b7cd                	j	80002bc4 <either_copyout+0x2a>

0000000080002be4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002be4:	7179                	addi	sp,sp,-48
    80002be6:	f406                	sd	ra,40(sp)
    80002be8:	f022                	sd	s0,32(sp)
    80002bea:	ec26                	sd	s1,24(sp)
    80002bec:	e84a                	sd	s2,16(sp)
    80002bee:	e44e                	sd	s3,8(sp)
    80002bf0:	e052                	sd	s4,0(sp)
    80002bf2:	1800                	addi	s0,sp,48
    80002bf4:	892a                	mv	s2,a0
    80002bf6:	84ae                	mv	s1,a1
    80002bf8:	89b2                	mv	s3,a2
    80002bfa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002bfc:	dfbfe0ef          	jal	800019f6 <myproc>
  if(user_src){
    80002c00:	cc99                	beqz	s1,80002c1e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002c02:	86d2                	mv	a3,s4
    80002c04:	864e                	mv	a2,s3
    80002c06:	85ca                	mv	a1,s2
    80002c08:	6d28                	ld	a0,88(a0)
    80002c0a:	abdfe0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002c0e:	70a2                	ld	ra,40(sp)
    80002c10:	7402                	ld	s0,32(sp)
    80002c12:	64e2                	ld	s1,24(sp)
    80002c14:	6942                	ld	s2,16(sp)
    80002c16:	69a2                	ld	s3,8(sp)
    80002c18:	6a02                	ld	s4,0(sp)
    80002c1a:	6145                	addi	sp,sp,48
    80002c1c:	8082                	ret
    memmove(dst, (char*)src, len);
    80002c1e:	000a061b          	sext.w	a2,s4
    80002c22:	85ce                	mv	a1,s3
    80002c24:	854a                	mv	a0,s2
    80002c26:	8d8fe0ef          	jal	80000cfe <memmove>
    return 0;
    80002c2a:	8526                	mv	a0,s1
    80002c2c:	b7cd                	j	80002c0e <either_copyin+0x2a>

0000000080002c2e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002c2e:	715d                	addi	sp,sp,-80
    80002c30:	e486                	sd	ra,72(sp)
    80002c32:	e0a2                	sd	s0,64(sp)
    80002c34:	fc26                	sd	s1,56(sp)
    80002c36:	f84a                	sd	s2,48(sp)
    80002c38:	f44e                	sd	s3,40(sp)
    80002c3a:	f052                	sd	s4,32(sp)
    80002c3c:	ec56                	sd	s5,24(sp)
    80002c3e:	e85a                	sd	s6,16(sp)
    80002c40:	e45e                	sd	s7,8(sp)
    80002c42:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002c44:	00005517          	auipc	a0,0x5
    80002c48:	43450513          	addi	a0,a0,1076 # 80008078 <etext+0x78>
    80002c4c:	8affd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c50:	00011497          	auipc	s1,0x11
    80002c54:	51848493          	addi	s1,s1,1304 # 80014168 <proc+0x160>
    80002c58:	00017917          	auipc	s2,0x17
    80002c5c:	31090913          	addi	s2,s2,784 # 80019f68 <kmutexes+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c60:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002c62:	00005997          	auipc	s3,0x5
    80002c66:	6a698993          	addi	s3,s3,1702 # 80008308 <etext+0x308>
    printf("%d %s %s", p->pid, state, p->name);
    80002c6a:	00005a97          	auipc	s5,0x5
    80002c6e:	6a6a8a93          	addi	s5,s5,1702 # 80008310 <etext+0x310>
    printf("\n");
    80002c72:	00005a17          	auipc	s4,0x5
    80002c76:	406a0a13          	addi	s4,s4,1030 # 80008078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c7a:	00006b97          	auipc	s7,0x6
    80002c7e:	bf6b8b93          	addi	s7,s7,-1034 # 80008870 <states.0>
    80002c82:	a829                	j	80002c9c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002c84:	ed06a583          	lw	a1,-304(a3)
    80002c88:	8556                	mv	a0,s5
    80002c8a:	871fd0ef          	jal	800004fa <printf>
    printf("\n");
    80002c8e:	8552                	mv	a0,s4
    80002c90:	86bfd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c94:	17848493          	addi	s1,s1,376
    80002c98:	03248263          	beq	s1,s2,80002cbc <procdump+0x8e>
    if(p->state == UNUSED)
    80002c9c:	86a6                	mv	a3,s1
    80002c9e:	eb84a783          	lw	a5,-328(s1)
    80002ca2:	dbed                	beqz	a5,80002c94 <procdump+0x66>
      state = "???";
    80002ca4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ca6:	fcfb6fe3          	bltu	s6,a5,80002c84 <procdump+0x56>
    80002caa:	02079713          	slli	a4,a5,0x20
    80002cae:	01d75793          	srli	a5,a4,0x1d
    80002cb2:	97de                	add	a5,a5,s7
    80002cb4:	6390                	ld	a2,0(a5)
    80002cb6:	f679                	bnez	a2,80002c84 <procdump+0x56>
      state = "???";
    80002cb8:	864e                	mv	a2,s3
    80002cba:	b7e9                	j	80002c84 <procdump+0x56>
  }
}
    80002cbc:	60a6                	ld	ra,72(sp)
    80002cbe:	6406                	ld	s0,64(sp)
    80002cc0:	74e2                	ld	s1,56(sp)
    80002cc2:	7942                	ld	s2,48(sp)
    80002cc4:	79a2                	ld	s3,40(sp)
    80002cc6:	7a02                	ld	s4,32(sp)
    80002cc8:	6ae2                	ld	s5,24(sp)
    80002cca:	6b42                	ld	s6,16(sp)
    80002ccc:	6ba2                	ld	s7,8(sp)
    80002cce:	6161                	addi	sp,sp,80
    80002cd0:	8082                	ret

0000000080002cd2 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002cd2:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002cd6:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002cda:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002cdc:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002cde:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002ce2:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002ce6:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002cea:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002cee:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002cf2:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002cf6:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002cfa:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002cfe:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002d02:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002d06:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002d0a:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002d0e:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002d10:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002d12:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002d16:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002d1a:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002d1e:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002d22:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002d26:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002d2a:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002d2e:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002d32:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002d36:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002d3a:	8082                	ret

0000000080002d3c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002d3c:	1141                	addi	sp,sp,-16
    80002d3e:	e406                	sd	ra,8(sp)
    80002d40:	e022                	sd	s0,0(sp)
    80002d42:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002d44:	00005597          	auipc	a1,0x5
    80002d48:	60c58593          	addi	a1,a1,1548 # 80008350 <etext+0x350>
    80002d4c:	00017517          	auipc	a0,0x17
    80002d50:	0bc50513          	addi	a0,a0,188 # 80019e08 <tickslock>
    80002d54:	dfbfd0ef          	jal	80000b4e <initlock>
}
    80002d58:	60a2                	ld	ra,8(sp)
    80002d5a:	6402                	ld	s0,0(sp)
    80002d5c:	0141                	addi	sp,sp,16
    80002d5e:	8082                	ret

0000000080002d60 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002d60:	1141                	addi	sp,sp,-16
    80002d62:	e422                	sd	s0,8(sp)
    80002d64:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d66:	00003797          	auipc	a5,0x3
    80002d6a:	4ca78793          	addi	a5,a5,1226 # 80006230 <kernelvec>
    80002d6e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002d72:	6422                	ld	s0,8(sp)
    80002d74:	0141                	addi	sp,sp,16
    80002d76:	8082                	ret

0000000080002d78 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002d78:	1141                	addi	sp,sp,-16
    80002d7a:	e406                	sd	ra,8(sp)
    80002d7c:	e022                	sd	s0,0(sp)
    80002d7e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002d80:	c77fe0ef          	jal	800019f6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002d88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d8a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002d8e:	04000737          	lui	a4,0x4000
    80002d92:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002d94:	0732                	slli	a4,a4,0xc
    80002d96:	00004797          	auipc	a5,0x4
    80002d9a:	26a78793          	addi	a5,a5,618 # 80007000 <_trampoline>
    80002d9e:	00004697          	auipc	a3,0x4
    80002da2:	26268693          	addi	a3,a3,610 # 80007000 <_trampoline>
    80002da6:	8f95                	sub	a5,a5,a3
    80002da8:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002daa:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002dae:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002db0:	18002773          	csrr	a4,satp
    80002db4:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002db6:	7138                	ld	a4,96(a0)
    80002db8:	653c                	ld	a5,72(a0)
    80002dba:	6685                	lui	a3,0x1
    80002dbc:	97b6                	add	a5,a5,a3
    80002dbe:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002dc0:	713c                	ld	a5,96(a0)
    80002dc2:	00000717          	auipc	a4,0x0
    80002dc6:	0f870713          	addi	a4,a4,248 # 80002eba <usertrap>
    80002dca:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002dcc:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002dce:	8712                	mv	a4,tp
    80002dd0:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dd2:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002dd6:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002dda:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dde:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002de2:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002de4:	6f9c                	ld	a5,24(a5)
    80002de6:	14179073          	csrw	sepc,a5
}
    80002dea:	60a2                	ld	ra,8(sp)
    80002dec:	6402                	ld	s0,0(sp)
    80002dee:	0141                	addi	sp,sp,16
    80002df0:	8082                	ret

0000000080002df2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002df2:	1101                	addi	sp,sp,-32
    80002df4:	ec06                	sd	ra,24(sp)
    80002df6:	e822                	sd	s0,16(sp)
    80002df8:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002dfa:	bd1fe0ef          	jal	800019ca <cpuid>
    80002dfe:	cd11                	beqz	a0,80002e1a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002e00:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002e04:	000f4737          	lui	a4,0xf4
    80002e08:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002e0c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002e0e:	14d79073          	csrw	stimecmp,a5
}
    80002e12:	60e2                	ld	ra,24(sp)
    80002e14:	6442                	ld	s0,16(sp)
    80002e16:	6105                	addi	sp,sp,32
    80002e18:	8082                	ret
    80002e1a:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002e1c:	00017497          	auipc	s1,0x17
    80002e20:	fec48493          	addi	s1,s1,-20 # 80019e08 <tickslock>
    80002e24:	8526                	mv	a0,s1
    80002e26:	da9fd0ef          	jal	80000bce <acquire>
    ticks++;
    80002e2a:	00009517          	auipc	a0,0x9
    80002e2e:	b6e50513          	addi	a0,a0,-1170 # 8000b998 <ticks>
    80002e32:	411c                	lw	a5,0(a0)
    80002e34:	2785                	addiw	a5,a5,1
    80002e36:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002e38:	fe4ff0ef          	jal	8000261c <wakeup>
    release(&tickslock);
    80002e3c:	8526                	mv	a0,s1
    80002e3e:	e29fd0ef          	jal	80000c66 <release>
    80002e42:	64a2                	ld	s1,8(sp)
    80002e44:	bf75                	j	80002e00 <clockintr+0xe>

0000000080002e46 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002e46:	1101                	addi	sp,sp,-32
    80002e48:	ec06                	sd	ra,24(sp)
    80002e4a:	e822                	sd	s0,16(sp)
    80002e4c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e4e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002e52:	57fd                	li	a5,-1
    80002e54:	17fe                	slli	a5,a5,0x3f
    80002e56:	07a5                	addi	a5,a5,9
    80002e58:	00f70c63          	beq	a4,a5,80002e70 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002e5c:	57fd                	li	a5,-1
    80002e5e:	17fe                	slli	a5,a5,0x3f
    80002e60:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002e62:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002e64:	04f70763          	beq	a4,a5,80002eb2 <devintr+0x6c>
  }
}
    80002e68:	60e2                	ld	ra,24(sp)
    80002e6a:	6442                	ld	s0,16(sp)
    80002e6c:	6105                	addi	sp,sp,32
    80002e6e:	8082                	ret
    80002e70:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002e72:	46a030ef          	jal	800062dc <plic_claim>
    80002e76:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002e78:	47a9                	li	a5,10
    80002e7a:	00f50963          	beq	a0,a5,80002e8c <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002e7e:	4785                	li	a5,1
    80002e80:	00f50963          	beq	a0,a5,80002e92 <devintr+0x4c>
    return 1;
    80002e84:	4505                	li	a0,1
    } else if(irq){
    80002e86:	e889                	bnez	s1,80002e98 <devintr+0x52>
    80002e88:	64a2                	ld	s1,8(sp)
    80002e8a:	bff9                	j	80002e68 <devintr+0x22>
      uartintr();
    80002e8c:	b25fd0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002e90:	a819                	j	80002ea6 <devintr+0x60>
      virtio_disk_intr();
    80002e92:	111030ef          	jal	800067a2 <virtio_disk_intr>
    if(irq)
    80002e96:	a801                	j	80002ea6 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002e98:	85a6                	mv	a1,s1
    80002e9a:	00005517          	auipc	a0,0x5
    80002e9e:	4be50513          	addi	a0,a0,1214 # 80008358 <etext+0x358>
    80002ea2:	e58fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002ea6:	8526                	mv	a0,s1
    80002ea8:	454030ef          	jal	800062fc <plic_complete>
    return 1;
    80002eac:	4505                	li	a0,1
    80002eae:	64a2                	ld	s1,8(sp)
    80002eb0:	bf65                	j	80002e68 <devintr+0x22>
    clockintr();
    80002eb2:	f41ff0ef          	jal	80002df2 <clockintr>
    return 2;
    80002eb6:	4509                	li	a0,2
    80002eb8:	bf45                	j	80002e68 <devintr+0x22>

0000000080002eba <usertrap>:
{
    80002eba:	1101                	addi	sp,sp,-32
    80002ebc:	ec06                	sd	ra,24(sp)
    80002ebe:	e822                	sd	s0,16(sp)
    80002ec0:	e426                	sd	s1,8(sp)
    80002ec2:	e04a                	sd	s2,0(sp)
    80002ec4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ec6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002eca:	1007f793          	andi	a5,a5,256
    80002ece:	eba5                	bnez	a5,80002f3e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ed0:	00003797          	auipc	a5,0x3
    80002ed4:	36078793          	addi	a5,a5,864 # 80006230 <kernelvec>
    80002ed8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002edc:	b1bfe0ef          	jal	800019f6 <myproc>
    80002ee0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ee2:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ee4:	14102773          	csrr	a4,sepc
    80002ee8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002eea:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002eee:	47a1                	li	a5,8
    80002ef0:	04f70d63          	beq	a4,a5,80002f4a <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002ef4:	f53ff0ef          	jal	80002e46 <devintr>
    80002ef8:	892a                	mv	s2,a0
    80002efa:	e945                	bnez	a0,80002faa <usertrap+0xf0>
    80002efc:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002f00:	47bd                	li	a5,15
    80002f02:	08f70863          	beq	a4,a5,80002f92 <usertrap+0xd8>
    80002f06:	14202773          	csrr	a4,scause
    80002f0a:	47b5                	li	a5,13
    80002f0c:	08f70363          	beq	a4,a5,80002f92 <usertrap+0xd8>
    80002f10:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002f14:	5890                	lw	a2,48(s1)
    80002f16:	00005517          	auipc	a0,0x5
    80002f1a:	48250513          	addi	a0,a0,1154 # 80008398 <etext+0x398>
    80002f1e:	ddcfd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f22:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f26:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002f2a:	00005517          	auipc	a0,0x5
    80002f2e:	49e50513          	addi	a0,a0,1182 # 800083c8 <etext+0x3c8>
    80002f32:	dc8fd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002f36:	8526                	mv	a0,s1
    80002f38:	941ff0ef          	jal	80002878 <setkilled>
    80002f3c:	a035                	j	80002f68 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002f3e:	00005517          	auipc	a0,0x5
    80002f42:	43a50513          	addi	a0,a0,1082 # 80008378 <etext+0x378>
    80002f46:	89bfd0ef          	jal	800007e0 <panic>
    if(killed(p))
    80002f4a:	953ff0ef          	jal	8000289c <killed>
    80002f4e:	ed15                	bnez	a0,80002f8a <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002f50:	70b8                	ld	a4,96(s1)
    80002f52:	6f1c                	ld	a5,24(a4)
    80002f54:	0791                	addi	a5,a5,4
    80002f56:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f58:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002f5c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f60:	10079073          	csrw	sstatus,a5
    syscall();
    80002f64:	246000ef          	jal	800031aa <syscall>
  if(killed(p))
    80002f68:	8526                	mv	a0,s1
    80002f6a:	933ff0ef          	jal	8000289c <killed>
    80002f6e:	e139                	bnez	a0,80002fb4 <usertrap+0xfa>
  prepare_return();
    80002f70:	e09ff0ef          	jal	80002d78 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002f74:	6ca8                	ld	a0,88(s1)
    80002f76:	8131                	srli	a0,a0,0xc
    80002f78:	57fd                	li	a5,-1
    80002f7a:	17fe                	slli	a5,a5,0x3f
    80002f7c:	8d5d                	or	a0,a0,a5
}
    80002f7e:	60e2                	ld	ra,24(sp)
    80002f80:	6442                	ld	s0,16(sp)
    80002f82:	64a2                	ld	s1,8(sp)
    80002f84:	6902                	ld	s2,0(sp)
    80002f86:	6105                	addi	sp,sp,32
    80002f88:	8082                	ret
      kexit(-1);
    80002f8a:	557d                	li	a0,-1
    80002f8c:	f50ff0ef          	jal	800026dc <kexit>
    80002f90:	b7c1                	j	80002f50 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f92:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f96:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002f9a:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002f9c:	00163613          	seqz	a2,a2
    80002fa0:	6ca8                	ld	a0,88(s1)
    80002fa2:	dbefe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002fa6:	f169                	bnez	a0,80002f68 <usertrap+0xae>
    80002fa8:	b7a5                	j	80002f10 <usertrap+0x56>
  if(killed(p))
    80002faa:	8526                	mv	a0,s1
    80002fac:	8f1ff0ef          	jal	8000289c <killed>
    80002fb0:	c511                	beqz	a0,80002fbc <usertrap+0x102>
    80002fb2:	a011                	j	80002fb6 <usertrap+0xfc>
    80002fb4:	4901                	li	s2,0
    kexit(-1);
    80002fb6:	557d                	li	a0,-1
    80002fb8:	f24ff0ef          	jal	800026dc <kexit>
  if(which_dev == 2)
    80002fbc:	4789                	li	a5,2
    80002fbe:	faf919e3          	bne	s2,a5,80002f70 <usertrap+0xb6>
    yield();
    80002fc2:	de2ff0ef          	jal	800025a4 <yield>
    80002fc6:	b76d                	j	80002f70 <usertrap+0xb6>

0000000080002fc8 <kerneltrap>:
{
    80002fc8:	7179                	addi	sp,sp,-48
    80002fca:	f406                	sd	ra,40(sp)
    80002fcc:	f022                	sd	s0,32(sp)
    80002fce:	ec26                	sd	s1,24(sp)
    80002fd0:	e84a                	sd	s2,16(sp)
    80002fd2:	e44e                	sd	s3,8(sp)
    80002fd4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fd6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fda:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fde:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002fe2:	1004f793          	andi	a5,s1,256
    80002fe6:	c795                	beqz	a5,80003012 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fe8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002fec:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002fee:	eb85                	bnez	a5,8000301e <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002ff0:	e57ff0ef          	jal	80002e46 <devintr>
    80002ff4:	c91d                	beqz	a0,8000302a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002ff6:	4789                	li	a5,2
    80002ff8:	04f50a63          	beq	a0,a5,8000304c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ffc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003000:	10049073          	csrw	sstatus,s1
}
    80003004:	70a2                	ld	ra,40(sp)
    80003006:	7402                	ld	s0,32(sp)
    80003008:	64e2                	ld	s1,24(sp)
    8000300a:	6942                	ld	s2,16(sp)
    8000300c:	69a2                	ld	s3,8(sp)
    8000300e:	6145                	addi	sp,sp,48
    80003010:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003012:	00005517          	auipc	a0,0x5
    80003016:	3de50513          	addi	a0,a0,990 # 800083f0 <etext+0x3f0>
    8000301a:	fc6fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    8000301e:	00005517          	auipc	a0,0x5
    80003022:	3fa50513          	addi	a0,a0,1018 # 80008418 <etext+0x418>
    80003026:	fbafd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000302a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000302e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80003032:	85ce                	mv	a1,s3
    80003034:	00005517          	auipc	a0,0x5
    80003038:	40450513          	addi	a0,a0,1028 # 80008438 <etext+0x438>
    8000303c:	cbefd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80003040:	00005517          	auipc	a0,0x5
    80003044:	42050513          	addi	a0,a0,1056 # 80008460 <etext+0x460>
    80003048:	f98fd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000304c:	9abfe0ef          	jal	800019f6 <myproc>
    80003050:	d555                	beqz	a0,80002ffc <kerneltrap+0x34>
    yield();
    80003052:	d52ff0ef          	jal	800025a4 <yield>
    80003056:	b75d                	j	80002ffc <kerneltrap+0x34>

0000000080003058 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003058:	1101                	addi	sp,sp,-32
    8000305a:	ec06                	sd	ra,24(sp)
    8000305c:	e822                	sd	s0,16(sp)
    8000305e:	e426                	sd	s1,8(sp)
    80003060:	1000                	addi	s0,sp,32
    80003062:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003064:	993fe0ef          	jal	800019f6 <myproc>
  switch (n) {
    80003068:	4795                	li	a5,5
    8000306a:	0497e163          	bltu	a5,s1,800030ac <argraw+0x54>
    8000306e:	048a                	slli	s1,s1,0x2
    80003070:	00006717          	auipc	a4,0x6
    80003074:	83070713          	addi	a4,a4,-2000 # 800088a0 <states.0+0x30>
    80003078:	94ba                	add	s1,s1,a4
    8000307a:	409c                	lw	a5,0(s1)
    8000307c:	97ba                	add	a5,a5,a4
    8000307e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003080:	713c                	ld	a5,96(a0)
    80003082:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003084:	60e2                	ld	ra,24(sp)
    80003086:	6442                	ld	s0,16(sp)
    80003088:	64a2                	ld	s1,8(sp)
    8000308a:	6105                	addi	sp,sp,32
    8000308c:	8082                	ret
    return p->trapframe->a1;
    8000308e:	713c                	ld	a5,96(a0)
    80003090:	7fa8                	ld	a0,120(a5)
    80003092:	bfcd                	j	80003084 <argraw+0x2c>
    return p->trapframe->a2;
    80003094:	713c                	ld	a5,96(a0)
    80003096:	63c8                	ld	a0,128(a5)
    80003098:	b7f5                	j	80003084 <argraw+0x2c>
    return p->trapframe->a3;
    8000309a:	713c                	ld	a5,96(a0)
    8000309c:	67c8                	ld	a0,136(a5)
    8000309e:	b7dd                	j	80003084 <argraw+0x2c>
    return p->trapframe->a4;
    800030a0:	713c                	ld	a5,96(a0)
    800030a2:	6bc8                	ld	a0,144(a5)
    800030a4:	b7c5                	j	80003084 <argraw+0x2c>
    return p->trapframe->a5;
    800030a6:	713c                	ld	a5,96(a0)
    800030a8:	6fc8                	ld	a0,152(a5)
    800030aa:	bfe9                	j	80003084 <argraw+0x2c>
  panic("argraw");
    800030ac:	00005517          	auipc	a0,0x5
    800030b0:	3c450513          	addi	a0,a0,964 # 80008470 <etext+0x470>
    800030b4:	f2cfd0ef          	jal	800007e0 <panic>

00000000800030b8 <fetchaddr>:
{
    800030b8:	1101                	addi	sp,sp,-32
    800030ba:	ec06                	sd	ra,24(sp)
    800030bc:	e822                	sd	s0,16(sp)
    800030be:	e426                	sd	s1,8(sp)
    800030c0:	e04a                	sd	s2,0(sp)
    800030c2:	1000                	addi	s0,sp,32
    800030c4:	84aa                	mv	s1,a0
    800030c6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800030c8:	92ffe0ef          	jal	800019f6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800030cc:	693c                	ld	a5,80(a0)
    800030ce:	02f4f663          	bgeu	s1,a5,800030fa <fetchaddr+0x42>
    800030d2:	00848713          	addi	a4,s1,8
    800030d6:	02e7e463          	bltu	a5,a4,800030fe <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800030da:	46a1                	li	a3,8
    800030dc:	8626                	mv	a2,s1
    800030de:	85ca                	mv	a1,s2
    800030e0:	6d28                	ld	a0,88(a0)
    800030e2:	de4fe0ef          	jal	800016c6 <copyin>
    800030e6:	00a03533          	snez	a0,a0
    800030ea:	40a00533          	neg	a0,a0
}
    800030ee:	60e2                	ld	ra,24(sp)
    800030f0:	6442                	ld	s0,16(sp)
    800030f2:	64a2                	ld	s1,8(sp)
    800030f4:	6902                	ld	s2,0(sp)
    800030f6:	6105                	addi	sp,sp,32
    800030f8:	8082                	ret
    return -1;
    800030fa:	557d                	li	a0,-1
    800030fc:	bfcd                	j	800030ee <fetchaddr+0x36>
    800030fe:	557d                	li	a0,-1
    80003100:	b7fd                	j	800030ee <fetchaddr+0x36>

0000000080003102 <fetchstr>:
{
    80003102:	7179                	addi	sp,sp,-48
    80003104:	f406                	sd	ra,40(sp)
    80003106:	f022                	sd	s0,32(sp)
    80003108:	ec26                	sd	s1,24(sp)
    8000310a:	e84a                	sd	s2,16(sp)
    8000310c:	e44e                	sd	s3,8(sp)
    8000310e:	1800                	addi	s0,sp,48
    80003110:	892a                	mv	s2,a0
    80003112:	84ae                	mv	s1,a1
    80003114:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003116:	8e1fe0ef          	jal	800019f6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000311a:	86ce                	mv	a3,s3
    8000311c:	864a                	mv	a2,s2
    8000311e:	85a6                	mv	a1,s1
    80003120:	6d28                	ld	a0,88(a0)
    80003122:	b66fe0ef          	jal	80001488 <copyinstr>
    80003126:	00054c63          	bltz	a0,8000313e <fetchstr+0x3c>
  return strlen(buf);
    8000312a:	8526                	mv	a0,s1
    8000312c:	ce7fd0ef          	jal	80000e12 <strlen>
}
    80003130:	70a2                	ld	ra,40(sp)
    80003132:	7402                	ld	s0,32(sp)
    80003134:	64e2                	ld	s1,24(sp)
    80003136:	6942                	ld	s2,16(sp)
    80003138:	69a2                	ld	s3,8(sp)
    8000313a:	6145                	addi	sp,sp,48
    8000313c:	8082                	ret
    return -1;
    8000313e:	557d                	li	a0,-1
    80003140:	bfc5                	j	80003130 <fetchstr+0x2e>

0000000080003142 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003142:	1101                	addi	sp,sp,-32
    80003144:	ec06                	sd	ra,24(sp)
    80003146:	e822                	sd	s0,16(sp)
    80003148:	e426                	sd	s1,8(sp)
    8000314a:	1000                	addi	s0,sp,32
    8000314c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000314e:	f0bff0ef          	jal	80003058 <argraw>
    80003152:	c088                	sw	a0,0(s1)
}
    80003154:	60e2                	ld	ra,24(sp)
    80003156:	6442                	ld	s0,16(sp)
    80003158:	64a2                	ld	s1,8(sp)
    8000315a:	6105                	addi	sp,sp,32
    8000315c:	8082                	ret

000000008000315e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000315e:	1101                	addi	sp,sp,-32
    80003160:	ec06                	sd	ra,24(sp)
    80003162:	e822                	sd	s0,16(sp)
    80003164:	e426                	sd	s1,8(sp)
    80003166:	1000                	addi	s0,sp,32
    80003168:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000316a:	eefff0ef          	jal	80003058 <argraw>
    8000316e:	e088                	sd	a0,0(s1)
}
    80003170:	60e2                	ld	ra,24(sp)
    80003172:	6442                	ld	s0,16(sp)
    80003174:	64a2                	ld	s1,8(sp)
    80003176:	6105                	addi	sp,sp,32
    80003178:	8082                	ret

000000008000317a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000317a:	7179                	addi	sp,sp,-48
    8000317c:	f406                	sd	ra,40(sp)
    8000317e:	f022                	sd	s0,32(sp)
    80003180:	ec26                	sd	s1,24(sp)
    80003182:	e84a                	sd	s2,16(sp)
    80003184:	1800                	addi	s0,sp,48
    80003186:	84ae                	mv	s1,a1
    80003188:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000318a:	fd840593          	addi	a1,s0,-40
    8000318e:	fd1ff0ef          	jal	8000315e <argaddr>
  return fetchstr(addr, buf, max);
    80003192:	864a                	mv	a2,s2
    80003194:	85a6                	mv	a1,s1
    80003196:	fd843503          	ld	a0,-40(s0)
    8000319a:	f69ff0ef          	jal	80003102 <fetchstr>
}
    8000319e:	70a2                	ld	ra,40(sp)
    800031a0:	7402                	ld	s0,32(sp)
    800031a2:	64e2                	ld	s1,24(sp)
    800031a4:	6942                	ld	s2,16(sp)
    800031a6:	6145                	addi	sp,sp,48
    800031a8:	8082                	ret

00000000800031aa <syscall>:
[SYS_thread_id]     sys_thread_id,
};

void
syscall(void)
{
    800031aa:	1101                	addi	sp,sp,-32
    800031ac:	ec06                	sd	ra,24(sp)
    800031ae:	e822                	sd	s0,16(sp)
    800031b0:	e426                	sd	s1,8(sp)
    800031b2:	e04a                	sd	s2,0(sp)
    800031b4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800031b6:	841fe0ef          	jal	800019f6 <myproc>
    800031ba:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800031bc:	06053903          	ld	s2,96(a0)
    800031c0:	0a893783          	ld	a5,168(s2)
    800031c4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800031c8:	37fd                	addiw	a5,a5,-1
    800031ca:	02300713          	li	a4,35
    800031ce:	00f76f63          	bltu	a4,a5,800031ec <syscall+0x42>
    800031d2:	00369713          	slli	a4,a3,0x3
    800031d6:	00005797          	auipc	a5,0x5
    800031da:	6e278793          	addi	a5,a5,1762 # 800088b8 <syscalls>
    800031de:	97ba                	add	a5,a5,a4
    800031e0:	639c                	ld	a5,0(a5)
    800031e2:	c789                	beqz	a5,800031ec <syscall+0x42>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800031e4:	9782                	jalr	a5
    800031e6:	06a93823          	sd	a0,112(s2)
    800031ea:	a829                	j	80003204 <syscall+0x5a>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800031ec:	16048613          	addi	a2,s1,352
    800031f0:	588c                	lw	a1,48(s1)
    800031f2:	00005517          	auipc	a0,0x5
    800031f6:	28650513          	addi	a0,a0,646 # 80008478 <etext+0x478>
    800031fa:	b00fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800031fe:	70bc                	ld	a5,96(s1)
    80003200:	577d                	li	a4,-1
    80003202:	fbb8                	sd	a4,112(a5)
  }
}
    80003204:	60e2                	ld	ra,24(sp)
    80003206:	6442                	ld	s0,16(sp)
    80003208:	64a2                	ld	s1,8(sp)
    8000320a:	6902                	ld	s2,0(sp)
    8000320c:	6105                	addi	sp,sp,32
    8000320e:	8082                	ret

0000000080003210 <sys_exit>:
static struct kmutex kmutexes[NKMUTEX];
static struct ksem ksems[NKSEM];

uint64
sys_exit(void)
{
    80003210:	1101                	addi	sp,sp,-32
    80003212:	ec06                	sd	ra,24(sp)
    80003214:	e822                	sd	s0,16(sp)
    80003216:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003218:	fec40593          	addi	a1,s0,-20
    8000321c:	4501                	li	a0,0
    8000321e:	f25ff0ef          	jal	80003142 <argint>
  kexit(n);
    80003222:	fec42503          	lw	a0,-20(s0)
    80003226:	cb6ff0ef          	jal	800026dc <kexit>
  return 0;  // not reached
}
    8000322a:	4501                	li	a0,0
    8000322c:	60e2                	ld	ra,24(sp)
    8000322e:	6442                	ld	s0,16(sp)
    80003230:	6105                	addi	sp,sp,32
    80003232:	8082                	ret

0000000080003234 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003234:	1141                	addi	sp,sp,-16
    80003236:	e406                	sd	ra,8(sp)
    80003238:	e022                	sd	s0,0(sp)
    8000323a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000323c:	fbafe0ef          	jal	800019f6 <myproc>
}
    80003240:	5908                	lw	a0,48(a0)
    80003242:	60a2                	ld	ra,8(sp)
    80003244:	6402                	ld	s0,0(sp)
    80003246:	0141                	addi	sp,sp,16
    80003248:	8082                	ret

000000008000324a <sys_fork>:

uint64
sys_fork(void)
{
    8000324a:	1141                	addi	sp,sp,-16
    8000324c:	e406                	sd	ra,8(sp)
    8000324e:	e022                	sd	s0,0(sp)
    80003250:	0800                	addi	s0,sp,16
  return kfork();
    80003252:	e3dfe0ef          	jal	8000208e <kfork>
}
    80003256:	60a2                	ld	ra,8(sp)
    80003258:	6402                	ld	s0,0(sp)
    8000325a:	0141                	addi	sp,sp,16
    8000325c:	8082                	ret

000000008000325e <sys_wait>:

uint64
sys_wait(void)
{
    8000325e:	1101                	addi	sp,sp,-32
    80003260:	ec06                	sd	ra,24(sp)
    80003262:	e822                	sd	s0,16(sp)
    80003264:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003266:	fe840593          	addi	a1,s0,-24
    8000326a:	4501                	li	a0,0
    8000326c:	ef3ff0ef          	jal	8000315e <argaddr>
  return kwait(p);
    80003270:	fe843503          	ld	a0,-24(s0)
    80003274:	e52ff0ef          	jal	800028c6 <kwait>
}
    80003278:	60e2                	ld	ra,24(sp)
    8000327a:	6442                	ld	s0,16(sp)
    8000327c:	6105                	addi	sp,sp,32
    8000327e:	8082                	ret

0000000080003280 <sys_waitpid>:

uint64
sys_waitpid(void)
{
    80003280:	1101                	addi	sp,sp,-32
    80003282:	ec06                	sd	ra,24(sp)
    80003284:	e822                	sd	s0,16(sp)
    80003286:	1000                	addi	s0,sp,32
  int pid;
  uint64 addr;

  argint(0, &pid);
    80003288:	fec40593          	addi	a1,s0,-20
    8000328c:	4501                	li	a0,0
    8000328e:	eb5ff0ef          	jal	80003142 <argint>
  argaddr(1, &addr);
    80003292:	fe040593          	addi	a1,s0,-32
    80003296:	4505                	li	a0,1
    80003298:	ec7ff0ef          	jal	8000315e <argaddr>

  return kwaitpid(pid, addr);
    8000329c:	fe043583          	ld	a1,-32(s0)
    800032a0:	fec42503          	lw	a0,-20(s0)
    800032a4:	f1cff0ef          	jal	800029c0 <kwaitpid>
}
    800032a8:	60e2                	ld	ra,24(sp)
    800032aa:	6442                	ld	s0,16(sp)
    800032ac:	6105                	addi	sp,sp,32
    800032ae:	8082                	ret

00000000800032b0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800032b0:	7179                	addi	sp,sp,-48
    800032b2:	f406                	sd	ra,40(sp)
    800032b4:	f022                	sd	s0,32(sp)
    800032b6:	ec26                	sd	s1,24(sp)
    800032b8:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800032ba:	fd840593          	addi	a1,s0,-40
    800032be:	4501                	li	a0,0
    800032c0:	e83ff0ef          	jal	80003142 <argint>
  argint(1, &t);
    800032c4:	fdc40593          	addi	a1,s0,-36
    800032c8:	4505                	li	a0,1
    800032ca:	e79ff0ef          	jal	80003142 <argint>
  addr = myproc()->sz;
    800032ce:	f28fe0ef          	jal	800019f6 <myproc>
    800032d2:	6924                	ld	s1,80(a0)

  if(t == SBRK_EAGER || n < 0) {
    800032d4:	fdc42703          	lw	a4,-36(s0)
    800032d8:	4785                	li	a5,1
    800032da:	02f70763          	beq	a4,a5,80003308 <sys_sbrk+0x58>
    800032de:	fd842783          	lw	a5,-40(s0)
    800032e2:	0207c363          	bltz	a5,80003308 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800032e6:	97a6                	add	a5,a5,s1
    800032e8:	0297ee63          	bltu	a5,s1,80003324 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    800032ec:	02000737          	lui	a4,0x2000
    800032f0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    800032f2:	0736                	slli	a4,a4,0xd
    800032f4:	02f76a63          	bltu	a4,a5,80003328 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    800032f8:	efefe0ef          	jal	800019f6 <myproc>
    800032fc:	fd842703          	lw	a4,-40(s0)
    80003300:	693c                	ld	a5,80(a0)
    80003302:	97ba                	add	a5,a5,a4
    80003304:	e93c                	sd	a5,80(a0)
    80003306:	a039                	j	80003314 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80003308:	fd842503          	lw	a0,-40(s0)
    8000330c:	d21fe0ef          	jal	8000202c <growproc>
    80003310:	00054863          	bltz	a0,80003320 <sys_sbrk+0x70>
  }
  return addr;
}
    80003314:	8526                	mv	a0,s1
    80003316:	70a2                	ld	ra,40(sp)
    80003318:	7402                	ld	s0,32(sp)
    8000331a:	64e2                	ld	s1,24(sp)
    8000331c:	6145                	addi	sp,sp,48
    8000331e:	8082                	ret
      return -1;
    80003320:	54fd                	li	s1,-1
    80003322:	bfcd                	j	80003314 <sys_sbrk+0x64>
      return -1;
    80003324:	54fd                	li	s1,-1
    80003326:	b7fd                	j	80003314 <sys_sbrk+0x64>
      return -1;
    80003328:	54fd                	li	s1,-1
    8000332a:	b7ed                	j	80003314 <sys_sbrk+0x64>

000000008000332c <sys_pause>:

uint64
sys_pause(void)
{
    8000332c:	7139                	addi	sp,sp,-64
    8000332e:	fc06                	sd	ra,56(sp)
    80003330:	f822                	sd	s0,48(sp)
    80003332:	f04a                	sd	s2,32(sp)
    80003334:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003336:	fcc40593          	addi	a1,s0,-52
    8000333a:	4501                	li	a0,0
    8000333c:	e07ff0ef          	jal	80003142 <argint>
  if(n < 0)
    80003340:	fcc42783          	lw	a5,-52(s0)
    80003344:	0607c763          	bltz	a5,800033b2 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80003348:	00017517          	auipc	a0,0x17
    8000334c:	ac050513          	addi	a0,a0,-1344 # 80019e08 <tickslock>
    80003350:	87ffd0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    80003354:	00008917          	auipc	s2,0x8
    80003358:	64492903          	lw	s2,1604(s2) # 8000b998 <ticks>
  while(ticks - ticks0 < n){
    8000335c:	fcc42783          	lw	a5,-52(s0)
    80003360:	cf8d                	beqz	a5,8000339a <sys_pause+0x6e>
    80003362:	f426                	sd	s1,40(sp)
    80003364:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003366:	00017997          	auipc	s3,0x17
    8000336a:	aa298993          	addi	s3,s3,-1374 # 80019e08 <tickslock>
    8000336e:	00008497          	auipc	s1,0x8
    80003372:	62a48493          	addi	s1,s1,1578 # 8000b998 <ticks>
    if(killed(myproc())){
    80003376:	e80fe0ef          	jal	800019f6 <myproc>
    8000337a:	d22ff0ef          	jal	8000289c <killed>
    8000337e:	ed0d                	bnez	a0,800033b8 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80003380:	85ce                	mv	a1,s3
    80003382:	8526                	mv	a0,s1
    80003384:	a4cff0ef          	jal	800025d0 <sleep>
  while(ticks - ticks0 < n){
    80003388:	409c                	lw	a5,0(s1)
    8000338a:	412787bb          	subw	a5,a5,s2
    8000338e:	fcc42703          	lw	a4,-52(s0)
    80003392:	fee7e2e3          	bltu	a5,a4,80003376 <sys_pause+0x4a>
    80003396:	74a2                	ld	s1,40(sp)
    80003398:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    8000339a:	00017517          	auipc	a0,0x17
    8000339e:	a6e50513          	addi	a0,a0,-1426 # 80019e08 <tickslock>
    800033a2:	8c5fd0ef          	jal	80000c66 <release>
  return 0;
    800033a6:	4501                	li	a0,0
}
    800033a8:	70e2                	ld	ra,56(sp)
    800033aa:	7442                	ld	s0,48(sp)
    800033ac:	7902                	ld	s2,32(sp)
    800033ae:	6121                	addi	sp,sp,64
    800033b0:	8082                	ret
    n = 0;
    800033b2:	fc042623          	sw	zero,-52(s0)
    800033b6:	bf49                	j	80003348 <sys_pause+0x1c>
      release(&tickslock);
    800033b8:	00017517          	auipc	a0,0x17
    800033bc:	a5050513          	addi	a0,a0,-1456 # 80019e08 <tickslock>
    800033c0:	8a7fd0ef          	jal	80000c66 <release>
      return -1;
    800033c4:	557d                	li	a0,-1
    800033c6:	74a2                	ld	s1,40(sp)
    800033c8:	69e2                	ld	s3,24(sp)
    800033ca:	bff9                	j	800033a8 <sys_pause+0x7c>

00000000800033cc <sys_kill>:

uint64
sys_kill(void)
{
    800033cc:	1101                	addi	sp,sp,-32
    800033ce:	ec06                	sd	ra,24(sp)
    800033d0:	e822                	sd	s0,16(sp)
    800033d2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800033d4:	fec40593          	addi	a1,s0,-20
    800033d8:	4501                	li	a0,0
    800033da:	d69ff0ef          	jal	80003142 <argint>
  return kkill(pid);
    800033de:	fec42503          	lw	a0,-20(s0)
    800033e2:	c30ff0ef          	jal	80002812 <kkill>
}
    800033e6:	60e2                	ld	ra,24(sp)
    800033e8:	6442                	ld	s0,16(sp)
    800033ea:	6105                	addi	sp,sp,32
    800033ec:	8082                	ret

00000000800033ee <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800033ee:	1101                	addi	sp,sp,-32
    800033f0:	ec06                	sd	ra,24(sp)
    800033f2:	e822                	sd	s0,16(sp)
    800033f4:	e426                	sd	s1,8(sp)
    800033f6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800033f8:	00017517          	auipc	a0,0x17
    800033fc:	a1050513          	addi	a0,a0,-1520 # 80019e08 <tickslock>
    80003400:	fcefd0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80003404:	00008497          	auipc	s1,0x8
    80003408:	5944a483          	lw	s1,1428(s1) # 8000b998 <ticks>
  release(&tickslock);
    8000340c:	00017517          	auipc	a0,0x17
    80003410:	9fc50513          	addi	a0,a0,-1540 # 80019e08 <tickslock>
    80003414:	853fd0ef          	jal	80000c66 <release>
  return xticks;
}
    80003418:	02049513          	slli	a0,s1,0x20
    8000341c:	9101                	srli	a0,a0,0x20
    8000341e:	60e2                	ld	ra,24(sp)
    80003420:	6442                	ld	s0,16(sp)
    80003422:	64a2                	ld	s1,8(sp)
    80003424:	6105                	addi	sp,sp,32
    80003426:	8082                	ret

0000000080003428 <sys_shmget>:

uint64
sys_shmget(void)
{
    80003428:	1101                	addi	sp,sp,-32
    8000342a:	ec06                	sd	ra,24(sp)
    8000342c:	e822                	sd	s0,16(sp)
    8000342e:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80003430:	fec40593          	addi	a1,s0,-20
    80003434:	4501                	li	a0,0
    80003436:	d0dff0ef          	jal	80003142 <argint>
  return kshmget(key);
    8000343a:	fec42503          	lw	a0,-20(s0)
    8000343e:	deafe0ef          	jal	80001a28 <kshmget>
}
    80003442:	60e2                	ld	ra,24(sp)
    80003444:	6442                	ld	s0,16(sp)
    80003446:	6105                	addi	sp,sp,32
    80003448:	8082                	ret

000000008000344a <sys_shmdt>:

uint64
sys_shmdt(void)
{
    8000344a:	1101                	addi	sp,sp,-32
    8000344c:	ec06                	sd	ra,24(sp)
    8000344e:	e822                	sd	s0,16(sp)
    80003450:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80003452:	fec40593          	addi	a1,s0,-20
    80003456:	4501                	li	a0,0
    80003458:	cebff0ef          	jal	80003142 <argint>
  return kshmdt(key);
    8000345c:	fec42503          	lw	a0,-20(s0)
    80003460:	f0efe0ef          	jal	80001b6e <kshmdt>
}
    80003464:	60e2                	ld	ra,24(sp)
    80003466:	6442                	ld	s0,16(sp)
    80003468:	6105                	addi	sp,sp,32
    8000346a:	8082                	ret

000000008000346c <sys_mutex_init>:

//synchornization 
uint64
sys_mutex_init(void)
{
    8000346c:	7179                	addi	sp,sp,-48
    8000346e:	f406                	sd	ra,40(sp)
    80003470:	f022                	sd	s0,32(sp)
    80003472:	1800                	addi	s0,sp,48
  int id;

  argint(0, &id);
    80003474:	fdc40593          	addi	a1,s0,-36
    80003478:	4501                	li	a0,0
    8000347a:	cc9ff0ef          	jal	80003142 <argint>
  if(id < 0 || id >= NKMUTEX)
    8000347e:	fdc42783          	lw	a5,-36(s0)
    80003482:	0007869b          	sext.w	a3,a5
    80003486:	473d                	li	a4,15
    return -1;
    80003488:	557d                	li	a0,-1
  if(id < 0 || id >= NKMUTEX)
    8000348a:	04d76463          	bltu	a4,a3,800034d2 <sys_mutex_init+0x66>
    8000348e:	ec26                	sd	s1,24(sp)

  if(kmutexes[id].used == 0){
    80003490:	00579693          	slli	a3,a5,0x5
    80003494:	00017717          	auipc	a4,0x17
    80003498:	98c70713          	addi	a4,a4,-1652 # 80019e20 <kmutexes>
    8000349c:	9736                	add	a4,a4,a3
    8000349e:	4318                	lw	a4,0(a4)
    800034a0:	cf0d                	beqz	a4,800034da <sys_mutex_init+0x6e>
    initlock(&kmutexes[id].lk, "kmutex");
    kmutexes[id].used = 1;
  }

  acquire(&kmutexes[id].lk);
    800034a2:	00017497          	auipc	s1,0x17
    800034a6:	97e48493          	addi	s1,s1,-1666 # 80019e20 <kmutexes>
    800034aa:	fdc42503          	lw	a0,-36(s0)
    800034ae:	0516                	slli	a0,a0,0x5
    800034b0:	0521                	addi	a0,a0,8
    800034b2:	9526                	add	a0,a0,s1
    800034b4:	f1afd0ef          	jal	80000bce <acquire>
  kmutexes[id].locked = 0;
    800034b8:	fdc42503          	lw	a0,-36(s0)
    800034bc:	0516                	slli	a0,a0,0x5
    800034be:	00a487b3          	add	a5,s1,a0
    800034c2:	0007a223          	sw	zero,4(a5)
  release(&kmutexes[id].lk);
    800034c6:	0521                	addi	a0,a0,8
    800034c8:	9526                	add	a0,a0,s1
    800034ca:	f9cfd0ef          	jal	80000c66 <release>

  return 0;
    800034ce:	4501                	li	a0,0
    800034d0:	64e2                	ld	s1,24(sp)
}
    800034d2:	70a2                	ld	ra,40(sp)
    800034d4:	7402                	ld	s0,32(sp)
    800034d6:	6145                	addi	sp,sp,48
    800034d8:	8082                	ret
    initlock(&kmutexes[id].lk, "kmutex");
    800034da:	00017497          	auipc	s1,0x17
    800034de:	94648493          	addi	s1,s1,-1722 # 80019e20 <kmutexes>
    800034e2:	00868513          	addi	a0,a3,8 # 1008 <_entry-0x7fffeff8>
    800034e6:	00005597          	auipc	a1,0x5
    800034ea:	fb258593          	addi	a1,a1,-78 # 80008498 <etext+0x498>
    800034ee:	9526                	add	a0,a0,s1
    800034f0:	e5efd0ef          	jal	80000b4e <initlock>
    kmutexes[id].used = 1;
    800034f4:	fdc42783          	lw	a5,-36(s0)
    800034f8:	0796                	slli	a5,a5,0x5
    800034fa:	94be                	add	s1,s1,a5
    800034fc:	4785                	li	a5,1
    800034fe:	c09c                	sw	a5,0(s1)
    80003500:	b74d                	j	800034a2 <sys_mutex_init+0x36>

0000000080003502 <sys_mutex_acquire>:

uint64
sys_mutex_acquire(void)
{
    80003502:	7179                	addi	sp,sp,-48
    80003504:	f406                	sd	ra,40(sp)
    80003506:	f022                	sd	s0,32(sp)
    80003508:	1800                	addi	s0,sp,48
  int id;

  argint(0, &id);
    8000350a:	fdc40593          	addi	a1,s0,-36
    8000350e:	4501                	li	a0,0
    80003510:	c33ff0ef          	jal	80003142 <argint>
  if(id < 0 || id >= NKMUTEX || kmutexes[id].used == 0)
    80003514:	fdc42783          	lw	a5,-36(s0)
    80003518:	0007869b          	sext.w	a3,a5
    8000351c:	473d                	li	a4,15
    return -1;
    8000351e:	557d                	li	a0,-1
  if(id < 0 || id >= NKMUTEX || kmutexes[id].used == 0)
    80003520:	08d76463          	bltu	a4,a3,800035a8 <sys_mutex_acquire+0xa6>
    80003524:	00579693          	slli	a3,a5,0x5
    80003528:	00017717          	auipc	a4,0x17
    8000352c:	8f870713          	addi	a4,a4,-1800 # 80019e20 <kmutexes>
    80003530:	9736                	add	a4,a4,a3
    80003532:	4318                	lw	a4,0(a4)
    80003534:	cb35                	beqz	a4,800035a8 <sys_mutex_acquire+0xa6>
    80003536:	ec26                	sd	s1,24(sp)

  acquire(&kmutexes[id].lk);
    80003538:	00017497          	auipc	s1,0x17
    8000353c:	8e848493          	addi	s1,s1,-1816 # 80019e20 <kmutexes>
    80003540:	00868513          	addi	a0,a3,8
    80003544:	9526                	add	a0,a0,s1
    80003546:	e88fd0ef          	jal	80000bce <acquire>
  while(kmutexes[id].locked){
    8000354a:	fdc42703          	lw	a4,-36(s0)
    8000354e:	00571793          	slli	a5,a4,0x5
    80003552:	94be                	add	s1,s1,a5
    80003554:	40dc                	lw	a5,4(s1)
    80003556:	cb95                	beqz	a5,8000358a <sys_mutex_acquire+0x88>
    if(killed(myproc())){
      release(&kmutexes[id].lk);
      return -1;
    }
    sleep(&kmutexes[id], &kmutexes[id].lk);
    80003558:	00017497          	auipc	s1,0x17
    8000355c:	8c848493          	addi	s1,s1,-1848 # 80019e20 <kmutexes>
    if(killed(myproc())){
    80003560:	c96fe0ef          	jal	800019f6 <myproc>
    80003564:	b38ff0ef          	jal	8000289c <killed>
    80003568:	e521                	bnez	a0,800035b0 <sys_mutex_acquire+0xae>
    sleep(&kmutexes[id], &kmutexes[id].lk);
    8000356a:	fdc42503          	lw	a0,-36(s0)
    8000356e:	0516                	slli	a0,a0,0x5
    80003570:	00850593          	addi	a1,a0,8
    80003574:	95a6                	add	a1,a1,s1
    80003576:	9526                	add	a0,a0,s1
    80003578:	858ff0ef          	jal	800025d0 <sleep>
  while(kmutexes[id].locked){
    8000357c:	fdc42703          	lw	a4,-36(s0)
    80003580:	00571793          	slli	a5,a4,0x5
    80003584:	97a6                	add	a5,a5,s1
    80003586:	43dc                	lw	a5,4(a5)
    80003588:	ffe1                	bnez	a5,80003560 <sys_mutex_acquire+0x5e>
  }
  kmutexes[id].locked = 1;
    8000358a:	00017517          	auipc	a0,0x17
    8000358e:	89650513          	addi	a0,a0,-1898 # 80019e20 <kmutexes>
    80003592:	0716                	slli	a4,a4,0x5
    80003594:	00e507b3          	add	a5,a0,a4
    80003598:	4685                	li	a3,1
    8000359a:	c3d4                	sw	a3,4(a5)
  release(&kmutexes[id].lk);
    8000359c:	0721                	addi	a4,a4,8
    8000359e:	953a                	add	a0,a0,a4
    800035a0:	ec6fd0ef          	jal	80000c66 <release>

  return 0;
    800035a4:	4501                	li	a0,0
    800035a6:	64e2                	ld	s1,24(sp)
}
    800035a8:	70a2                	ld	ra,40(sp)
    800035aa:	7402                	ld	s0,32(sp)
    800035ac:	6145                	addi	sp,sp,48
    800035ae:	8082                	ret
      release(&kmutexes[id].lk);
    800035b0:	fdc42783          	lw	a5,-36(s0)
    800035b4:	0796                	slli	a5,a5,0x5
    800035b6:	00017517          	auipc	a0,0x17
    800035ba:	87250513          	addi	a0,a0,-1934 # 80019e28 <kmutexes+0x8>
    800035be:	953e                	add	a0,a0,a5
    800035c0:	ea6fd0ef          	jal	80000c66 <release>
      return -1;
    800035c4:	557d                	li	a0,-1
    800035c6:	64e2                	ld	s1,24(sp)
    800035c8:	b7c5                	j	800035a8 <sys_mutex_acquire+0xa6>

00000000800035ca <sys_mutex_release>:

uint64
sys_mutex_release(void)
{
    800035ca:	7179                	addi	sp,sp,-48
    800035cc:	f406                	sd	ra,40(sp)
    800035ce:	f022                	sd	s0,32(sp)
    800035d0:	1800                	addi	s0,sp,48
  int id;

  argint(0, &id);
    800035d2:	fdc40593          	addi	a1,s0,-36
    800035d6:	4501                	li	a0,0
    800035d8:	b6bff0ef          	jal	80003142 <argint>
  if(id < 0 || id >= NKMUTEX || kmutexes[id].used == 0)
    800035dc:	fdc42783          	lw	a5,-36(s0)
    800035e0:	0007869b          	sext.w	a3,a5
    800035e4:	473d                	li	a4,15
    return -1;
    800035e6:	557d                	li	a0,-1
  if(id < 0 || id >= NKMUTEX || kmutexes[id].used == 0)
    800035e8:	04d76f63          	bltu	a4,a3,80003646 <sys_mutex_release+0x7c>
    800035ec:	00579693          	slli	a3,a5,0x5
    800035f0:	00017717          	auipc	a4,0x17
    800035f4:	83070713          	addi	a4,a4,-2000 # 80019e20 <kmutexes>
    800035f8:	9736                	add	a4,a4,a3
    800035fa:	4318                	lw	a4,0(a4)
    800035fc:	c729                	beqz	a4,80003646 <sys_mutex_release+0x7c>
    800035fe:	ec26                	sd	s1,24(sp)

  acquire(&kmutexes[id].lk);
    80003600:	00017497          	auipc	s1,0x17
    80003604:	82048493          	addi	s1,s1,-2016 # 80019e20 <kmutexes>
    80003608:	00868513          	addi	a0,a3,8
    8000360c:	9526                	add	a0,a0,s1
    8000360e:	dc0fd0ef          	jal	80000bce <acquire>
  if(kmutexes[id].locked == 0){
    80003612:	fdc42503          	lw	a0,-36(s0)
    80003616:	00551793          	slli	a5,a0,0x5
    8000361a:	94be                	add	s1,s1,a5
    8000361c:	40dc                	lw	a5,4(s1)
    8000361e:	cb85                	beqz	a5,8000364e <sys_mutex_release+0x84>
    release(&kmutexes[id].lk);
    return -1;
  }

  kmutexes[id].locked = 0;
    80003620:	00017497          	auipc	s1,0x17
    80003624:	80048493          	addi	s1,s1,-2048 # 80019e20 <kmutexes>
    80003628:	0516                	slli	a0,a0,0x5
    8000362a:	9526                	add	a0,a0,s1
    8000362c:	00052223          	sw	zero,4(a0)
  wakeup(&kmutexes[id]);
    80003630:	fedfe0ef          	jal	8000261c <wakeup>
  release(&kmutexes[id].lk);
    80003634:	fdc42503          	lw	a0,-36(s0)
    80003638:	0516                	slli	a0,a0,0x5
    8000363a:	0521                	addi	a0,a0,8
    8000363c:	9526                	add	a0,a0,s1
    8000363e:	e28fd0ef          	jal	80000c66 <release>

  return 0;
    80003642:	4501                	li	a0,0
    80003644:	64e2                	ld	s1,24(sp)
}
    80003646:	70a2                	ld	ra,40(sp)
    80003648:	7402                	ld	s0,32(sp)
    8000364a:	6145                	addi	sp,sp,48
    8000364c:	8082                	ret
    release(&kmutexes[id].lk);
    8000364e:	0516                	slli	a0,a0,0x5
    80003650:	00016797          	auipc	a5,0x16
    80003654:	7d878793          	addi	a5,a5,2008 # 80019e28 <kmutexes+0x8>
    80003658:	953e                	add	a0,a0,a5
    8000365a:	e0cfd0ef          	jal	80000c66 <release>
    return -1;
    8000365e:	557d                	li	a0,-1
    80003660:	64e2                	ld	s1,24(sp)
    80003662:	b7d5                	j	80003646 <sys_mutex_release+0x7c>

0000000080003664 <sys_setp>:

//new setp function
uint64
sys_setp(void)
{
    80003664:	1101                	addi	sp,sp,-32
    80003666:	ec06                	sd	ra,24(sp)
    80003668:	e822                	sd	s0,16(sp)
    8000366a:	1000                	addi	s0,sp,32
  int pid, priority;

  argint(0, &pid);
    8000366c:	fec40593          	addi	a1,s0,-20
    80003670:	4501                	li	a0,0
    80003672:	ad1ff0ef          	jal	80003142 <argint>
  argint(1, &priority);
    80003676:	fe840593          	addi	a1,s0,-24
    8000367a:	4505                	li	a0,1
    8000367c:	ac7ff0ef          	jal	80003142 <argint>

  return setpriority(pid, priority);
    80003680:	fe842583          	lw	a1,-24(s0)
    80003684:	fec42503          	lw	a0,-20(s0)
    80003688:	e72fe0ef          	jal	80001cfa <setpriority>
}
    8000368c:	60e2                	ld	ra,24(sp)
    8000368e:	6442                	ld	s0,16(sp)
    80003690:	6105                	addi	sp,sp,32
    80003692:	8082                	ret

0000000080003694 <sys_ismyear>:
//new ismyear function

uint64
sys_ismyear(void)
{
    80003694:	1141                	addi	sp,sp,-16
    80003696:	e422                	sd	s0,8(sp)
    80003698:	0800                	addi	s0,sp,16
  return 1926;
}
    8000369a:	78600513          	li	a0,1926
    8000369e:	6422                	ld	s0,8(sp)
    800036a0:	0141                	addi	sp,sp,16
    800036a2:	8082                	ret

00000000800036a4 <sys_sem_init>:

uint64
sys_sem_init(void)
{
    800036a4:	7179                	addi	sp,sp,-48
    800036a6:	f406                	sd	ra,40(sp)
    800036a8:	f022                	sd	s0,32(sp)
    800036aa:	1800                	addi	s0,sp,48
  int id, value;

  argint(0, &id);
    800036ac:	fdc40593          	addi	a1,s0,-36
    800036b0:	4501                	li	a0,0
    800036b2:	a91ff0ef          	jal	80003142 <argint>
  argint(1, &value);
    800036b6:	fd840593          	addi	a1,s0,-40
    800036ba:	4505                	li	a0,1
    800036bc:	a87ff0ef          	jal	80003142 <argint>

  if(id < 0 || id >= NKSEM || value < 0)
    800036c0:	fdc42783          	lw	a5,-36(s0)
    800036c4:	0007869b          	sext.w	a3,a5
    800036c8:	473d                	li	a4,15
    return -1;
    800036ca:	557d                	li	a0,-1
  if(id < 0 || id >= NKSEM || value < 0)
    800036cc:	04d76e63          	bltu	a4,a3,80003728 <sys_sem_init+0x84>
    800036d0:	fd842703          	lw	a4,-40(s0)
    800036d4:	08074563          	bltz	a4,8000375e <sys_sem_init+0xba>
    800036d8:	ec26                	sd	s1,24(sp)

  if(ksems[id].used == 0){
    800036da:	00579693          	slli	a3,a5,0x5
    800036de:	00016717          	auipc	a4,0x16
    800036e2:	74270713          	addi	a4,a4,1858 # 80019e20 <kmutexes>
    800036e6:	9736                	add	a4,a4,a3
    800036e8:	20072703          	lw	a4,512(a4)
    800036ec:	c331                	beqz	a4,80003730 <sys_sem_init+0x8c>
    initlock(&ksems[id].lk, "ksem");
    ksems[id].used = 1;
  }

  acquire(&ksems[id].lk);
    800036ee:	00017497          	auipc	s1,0x17
    800036f2:	93248493          	addi	s1,s1,-1742 # 8001a020 <ksems>
    800036f6:	fdc42503          	lw	a0,-36(s0)
    800036fa:	0516                	slli	a0,a0,0x5
    800036fc:	0521                	addi	a0,a0,8
    800036fe:	9526                	add	a0,a0,s1
    80003700:	ccefd0ef          	jal	80000bce <acquire>
  ksems[id].count = value;
    80003704:	fdc42503          	lw	a0,-36(s0)
    80003708:	0516                	slli	a0,a0,0x5
    8000370a:	00016797          	auipc	a5,0x16
    8000370e:	71678793          	addi	a5,a5,1814 # 80019e20 <kmutexes>
    80003712:	97aa                	add	a5,a5,a0
    80003714:	fd842703          	lw	a4,-40(s0)
    80003718:	20e7a223          	sw	a4,516(a5)
  release(&ksems[id].lk);
    8000371c:	0521                	addi	a0,a0,8
    8000371e:	9526                	add	a0,a0,s1
    80003720:	d46fd0ef          	jal	80000c66 <release>

  return 0;
    80003724:	4501                	li	a0,0
    80003726:	64e2                	ld	s1,24(sp)
}
    80003728:	70a2                	ld	ra,40(sp)
    8000372a:	7402                	ld	s0,32(sp)
    8000372c:	6145                	addi	sp,sp,48
    8000372e:	8082                	ret
    initlock(&ksems[id].lk, "ksem");
    80003730:	00005597          	auipc	a1,0x5
    80003734:	d7058593          	addi	a1,a1,-656 # 800084a0 <etext+0x4a0>
    80003738:	00017517          	auipc	a0,0x17
    8000373c:	8f050513          	addi	a0,a0,-1808 # 8001a028 <ksems+0x8>
    80003740:	9536                	add	a0,a0,a3
    80003742:	c0cfd0ef          	jal	80000b4e <initlock>
    ksems[id].used = 1;
    80003746:	fdc42703          	lw	a4,-36(s0)
    8000374a:	0716                	slli	a4,a4,0x5
    8000374c:	00016797          	auipc	a5,0x16
    80003750:	6d478793          	addi	a5,a5,1748 # 80019e20 <kmutexes>
    80003754:	97ba                	add	a5,a5,a4
    80003756:	4705                	li	a4,1
    80003758:	20e7a023          	sw	a4,512(a5)
    8000375c:	bf49                	j	800036ee <sys_sem_init+0x4a>
    return -1;
    8000375e:	557d                	li	a0,-1
    80003760:	b7e1                	j	80003728 <sys_sem_init+0x84>

0000000080003762 <sys_sem_wait>:

uint64
sys_sem_wait(void)
{
    80003762:	7179                	addi	sp,sp,-48
    80003764:	f406                	sd	ra,40(sp)
    80003766:	f022                	sd	s0,32(sp)
    80003768:	1800                	addi	s0,sp,48
  int id;

  argint(0, &id);
    8000376a:	fdc40593          	addi	a1,s0,-36
    8000376e:	4501                	li	a0,0
    80003770:	9d3ff0ef          	jal	80003142 <argint>
  if(id < 0 || id >= NKSEM || ksems[id].used == 0)
    80003774:	fdc42783          	lw	a5,-36(s0)
    80003778:	0007869b          	sext.w	a3,a5
    8000377c:	473d                	li	a4,15
    return -1;
    8000377e:	557d                	li	a0,-1
  if(id < 0 || id >= NKSEM || ksems[id].used == 0)
    80003780:	0ad76263          	bltu	a4,a3,80003824 <sys_sem_wait+0xc2>
    80003784:	00579693          	slli	a3,a5,0x5
    80003788:	00016717          	auipc	a4,0x16
    8000378c:	69870713          	addi	a4,a4,1688 # 80019e20 <kmutexes>
    80003790:	9736                	add	a4,a4,a3
    80003792:	20072703          	lw	a4,512(a4)
    80003796:	c759                	beqz	a4,80003824 <sys_sem_wait+0xc2>

  acquire(&ksems[id].lk);
    80003798:	00017517          	auipc	a0,0x17
    8000379c:	89050513          	addi	a0,a0,-1904 # 8001a028 <ksems+0x8>
    800037a0:	9536                	add	a0,a0,a3
    800037a2:	c2cfd0ef          	jal	80000bce <acquire>
  while(ksems[id].count == 0){
    800037a6:	fdc42503          	lw	a0,-36(s0)
    800037aa:	00551713          	slli	a4,a0,0x5
    800037ae:	00016797          	auipc	a5,0x16
    800037b2:	67278793          	addi	a5,a5,1650 # 80019e20 <kmutexes>
    800037b6:	97ba                	add	a5,a5,a4
    800037b8:	2047a783          	lw	a5,516(a5)
    800037bc:	e3b9                	bnez	a5,80003802 <sys_sem_wait+0xa0>
    800037be:	ec26                	sd	s1,24(sp)
    800037c0:	e84a                	sd	s2,16(sp)
    if(killed(myproc())){
      release(&ksems[id].lk);
      return -1;
    }
    sleep(&ksems[id], &ksems[id].lk);
    800037c2:	00016917          	auipc	s2,0x16
    800037c6:	65e90913          	addi	s2,s2,1630 # 80019e20 <kmutexes>
    800037ca:	00017497          	auipc	s1,0x17
    800037ce:	85648493          	addi	s1,s1,-1962 # 8001a020 <ksems>
    if(killed(myproc())){
    800037d2:	a24fe0ef          	jal	800019f6 <myproc>
    800037d6:	8c6ff0ef          	jal	8000289c <killed>
    800037da:	e929                	bnez	a0,8000382c <sys_sem_wait+0xca>
    sleep(&ksems[id], &ksems[id].lk);
    800037dc:	fdc42503          	lw	a0,-36(s0)
    800037e0:	0516                	slli	a0,a0,0x5
    800037e2:	00850593          	addi	a1,a0,8
    800037e6:	95a6                	add	a1,a1,s1
    800037e8:	9526                	add	a0,a0,s1
    800037ea:	de7fe0ef          	jal	800025d0 <sleep>
  while(ksems[id].count == 0){
    800037ee:	fdc42503          	lw	a0,-36(s0)
    800037f2:	00551793          	slli	a5,a0,0x5
    800037f6:	97ca                	add	a5,a5,s2
    800037f8:	2047a783          	lw	a5,516(a5)
    800037fc:	dbf9                	beqz	a5,800037d2 <sys_sem_wait+0x70>
    800037fe:	64e2                	ld	s1,24(sp)
    80003800:	6942                	ld	s2,16(sp)
  }
  ksems[id].count--;
    80003802:	0516                	slli	a0,a0,0x5
    80003804:	00016717          	auipc	a4,0x16
    80003808:	61c70713          	addi	a4,a4,1564 # 80019e20 <kmutexes>
    8000380c:	972a                	add	a4,a4,a0
    8000380e:	37fd                	addiw	a5,a5,-1
    80003810:	20f72223          	sw	a5,516(a4)
  release(&ksems[id].lk);
    80003814:	00017797          	auipc	a5,0x17
    80003818:	81478793          	addi	a5,a5,-2028 # 8001a028 <ksems+0x8>
    8000381c:	953e                	add	a0,a0,a5
    8000381e:	c48fd0ef          	jal	80000c66 <release>

  return 0;
    80003822:	4501                	li	a0,0
}
    80003824:	70a2                	ld	ra,40(sp)
    80003826:	7402                	ld	s0,32(sp)
    80003828:	6145                	addi	sp,sp,48
    8000382a:	8082                	ret
      release(&ksems[id].lk);
    8000382c:	fdc42783          	lw	a5,-36(s0)
    80003830:	0796                	slli	a5,a5,0x5
    80003832:	00016517          	auipc	a0,0x16
    80003836:	7f650513          	addi	a0,a0,2038 # 8001a028 <ksems+0x8>
    8000383a:	953e                	add	a0,a0,a5
    8000383c:	c2afd0ef          	jal	80000c66 <release>
      return -1;
    80003840:	557d                	li	a0,-1
    80003842:	64e2                	ld	s1,24(sp)
    80003844:	6942                	ld	s2,16(sp)
    80003846:	bff9                	j	80003824 <sys_sem_wait+0xc2>

0000000080003848 <sys_sem_post>:

uint64
sys_sem_post(void)
{
    80003848:	7179                	addi	sp,sp,-48
    8000384a:	f406                	sd	ra,40(sp)
    8000384c:	f022                	sd	s0,32(sp)
    8000384e:	1800                	addi	s0,sp,48
  int id;

  argint(0, &id);
    80003850:	fdc40593          	addi	a1,s0,-36
    80003854:	4501                	li	a0,0
    80003856:	8edff0ef          	jal	80003142 <argint>
  if(id < 0 || id >= NKSEM || ksems[id].used == 0)
    8000385a:	fdc42783          	lw	a5,-36(s0)
    8000385e:	0007869b          	sext.w	a3,a5
    80003862:	473d                	li	a4,15
    return -1;
    80003864:	557d                	li	a0,-1
  if(id < 0 || id >= NKSEM || ksems[id].used == 0)
    80003866:	04d76f63          	bltu	a4,a3,800038c4 <sys_sem_post+0x7c>
    8000386a:	00579693          	slli	a3,a5,0x5
    8000386e:	00016717          	auipc	a4,0x16
    80003872:	5b270713          	addi	a4,a4,1458 # 80019e20 <kmutexes>
    80003876:	9736                	add	a4,a4,a3
    80003878:	20072703          	lw	a4,512(a4)
    8000387c:	c721                	beqz	a4,800038c4 <sys_sem_post+0x7c>
    8000387e:	ec26                	sd	s1,24(sp)

  acquire(&ksems[id].lk);
    80003880:	00016497          	auipc	s1,0x16
    80003884:	7a048493          	addi	s1,s1,1952 # 8001a020 <ksems>
    80003888:	00868513          	addi	a0,a3,8
    8000388c:	9526                	add	a0,a0,s1
    8000388e:	b40fd0ef          	jal	80000bce <acquire>
  ksems[id].count++;
    80003892:	fdc42503          	lw	a0,-36(s0)
    80003896:	0516                	slli	a0,a0,0x5
    80003898:	00016797          	auipc	a5,0x16
    8000389c:	58878793          	addi	a5,a5,1416 # 80019e20 <kmutexes>
    800038a0:	97aa                	add	a5,a5,a0
    800038a2:	2047a703          	lw	a4,516(a5)
    800038a6:	2705                	addiw	a4,a4,1
    800038a8:	20e7a223          	sw	a4,516(a5)
  wakeup(&ksems[id]);
    800038ac:	9526                	add	a0,a0,s1
    800038ae:	d6ffe0ef          	jal	8000261c <wakeup>
  release(&ksems[id].lk);
    800038b2:	fdc42503          	lw	a0,-36(s0)
    800038b6:	0516                	slli	a0,a0,0x5
    800038b8:	0521                	addi	a0,a0,8
    800038ba:	9526                	add	a0,a0,s1
    800038bc:	baafd0ef          	jal	80000c66 <release>

  return 0;
    800038c0:	4501                	li	a0,0
    800038c2:	64e2                	ld	s1,24(sp)
}
    800038c4:	70a2                	ld	ra,40(sp)
    800038c6:	7402                	ld	s0,32(sp)
    800038c8:	6145                	addi	sp,sp,48
    800038ca:	8082                	ret

00000000800038cc <sys_thread_create>:

uint64
sys_thread_create(void)
{
    800038cc:	7179                	addi	sp,sp,-48
    800038ce:	f406                	sd	ra,40(sp)
    800038d0:	f022                	sd	s0,32(sp)
    800038d2:	1800                	addi	s0,sp,48
  uint64 fcn, arg, stack;

  argaddr(0, &fcn);
    800038d4:	fe840593          	addi	a1,s0,-24
    800038d8:	4501                	li	a0,0
    800038da:	885ff0ef          	jal	8000315e <argaddr>
  argaddr(1, &arg);
    800038de:	fe040593          	addi	a1,s0,-32
    800038e2:	4505                	li	a0,1
    800038e4:	87bff0ef          	jal	8000315e <argaddr>
  argaddr(2, &stack);
    800038e8:	fd840593          	addi	a1,s0,-40
    800038ec:	4509                	li	a0,2
    800038ee:	871ff0ef          	jal	8000315e <argaddr>

  printf("sys_thread_create: fcn=%lx arg=%lx stack=%lx\n", fcn, arg, stack);
    800038f2:	fd843683          	ld	a3,-40(s0)
    800038f6:	fe043603          	ld	a2,-32(s0)
    800038fa:	fe843583          	ld	a1,-24(s0)
    800038fe:	00005517          	auipc	a0,0x5
    80003902:	baa50513          	addi	a0,a0,-1110 # 800084a8 <etext+0x4a8>
    80003906:	bf5fc0ef          	jal	800004fa <printf>

  return kthread_create(fcn, arg, stack);
    8000390a:	fd843603          	ld	a2,-40(s0)
    8000390e:	fe043583          	ld	a1,-32(s0)
    80003912:	fe843503          	ld	a0,-24(s0)
    80003916:	887fe0ef          	jal	8000219c <kthread_create>
}
    8000391a:	70a2                	ld	ra,40(sp)
    8000391c:	7402                	ld	s0,32(sp)
    8000391e:	6145                	addi	sp,sp,48
    80003920:	8082                	ret

0000000080003922 <sys_thread_join>:

uint64
sys_thread_join(void)
{
    80003922:	1101                	addi	sp,sp,-32
    80003924:	ec06                	sd	ra,24(sp)
    80003926:	e822                	sd	s0,16(sp)
    80003928:	1000                	addi	s0,sp,32
  int tid;
  argint(0, &tid);
    8000392a:	fec40593          	addi	a1,s0,-20
    8000392e:	4501                	li	a0,0
    80003930:	813ff0ef          	jal	80003142 <argint>
  return kthread_join(tid);
    80003934:	fec42503          	lw	a0,-20(s0)
    80003938:	98cff0ef          	jal	80002ac4 <kthread_join>
}
    8000393c:	60e2                	ld	ra,24(sp)
    8000393e:	6442                	ld	s0,16(sp)
    80003940:	6105                	addi	sp,sp,32
    80003942:	8082                	ret

0000000080003944 <sys_thread_exit>:

uint64
sys_thread_exit(void)
{
    80003944:	1101                	addi	sp,sp,-32
    80003946:	ec06                	sd	ra,24(sp)
    80003948:	e822                	sd	s0,16(sp)
    8000394a:	1000                	addi	s0,sp,32
  int status;
  argint(0, &status);
    8000394c:	fec40593          	addi	a1,s0,-20
    80003950:	4501                	li	a0,0
    80003952:	ff0ff0ef          	jal	80003142 <argint>
  kthread_exit(status);
    80003956:	fec42503          	lw	a0,-20(s0)
    8000395a:	e25fe0ef          	jal	8000277e <kthread_exit>

000000008000395e <sys_thread_id>:
  return 0;
}

uint64
sys_thread_id(void)
{
    8000395e:	1141                	addi	sp,sp,-16
    80003960:	e406                	sd	ra,8(sp)
    80003962:	e022                	sd	s0,0(sp)
    80003964:	0800                	addi	s0,sp,16
  return kthread_id();
    80003966:	a9ffe0ef          	jal	80002404 <kthread_id>
}
    8000396a:	60a2                	ld	ra,8(sp)
    8000396c:	6402                	ld	s0,0(sp)
    8000396e:	0141                	addi	sp,sp,16
    80003970:	8082                	ret

0000000080003972 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003972:	7179                	addi	sp,sp,-48
    80003974:	f406                	sd	ra,40(sp)
    80003976:	f022                	sd	s0,32(sp)
    80003978:	ec26                	sd	s1,24(sp)
    8000397a:	e84a                	sd	s2,16(sp)
    8000397c:	e44e                	sd	s3,8(sp)
    8000397e:	e052                	sd	s4,0(sp)
    80003980:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003982:	00005597          	auipc	a1,0x5
    80003986:	b5658593          	addi	a1,a1,-1194 # 800084d8 <etext+0x4d8>
    8000398a:	00017517          	auipc	a0,0x17
    8000398e:	89650513          	addi	a0,a0,-1898 # 8001a220 <bcache>
    80003992:	9bcfd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003996:	0001f797          	auipc	a5,0x1f
    8000399a:	88a78793          	addi	a5,a5,-1910 # 80022220 <bcache+0x8000>
    8000399e:	0001f717          	auipc	a4,0x1f
    800039a2:	aea70713          	addi	a4,a4,-1302 # 80022488 <bcache+0x8268>
    800039a6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800039aa:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800039ae:	00017497          	auipc	s1,0x17
    800039b2:	88a48493          	addi	s1,s1,-1910 # 8001a238 <bcache+0x18>
    b->next = bcache.head.next;
    800039b6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800039b8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800039ba:	00005a17          	auipc	s4,0x5
    800039be:	b26a0a13          	addi	s4,s4,-1242 # 800084e0 <etext+0x4e0>
    b->next = bcache.head.next;
    800039c2:	2b893783          	ld	a5,696(s2)
    800039c6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800039c8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800039cc:	85d2                	mv	a1,s4
    800039ce:	01048513          	addi	a0,s1,16
    800039d2:	322010ef          	jal	80004cf4 <initsleeplock>
    bcache.head.next->prev = b;
    800039d6:	2b893783          	ld	a5,696(s2)
    800039da:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800039dc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800039e0:	45848493          	addi	s1,s1,1112
    800039e4:	fd349fe3          	bne	s1,s3,800039c2 <binit+0x50>
  }
}
    800039e8:	70a2                	ld	ra,40(sp)
    800039ea:	7402                	ld	s0,32(sp)
    800039ec:	64e2                	ld	s1,24(sp)
    800039ee:	6942                	ld	s2,16(sp)
    800039f0:	69a2                	ld	s3,8(sp)
    800039f2:	6a02                	ld	s4,0(sp)
    800039f4:	6145                	addi	sp,sp,48
    800039f6:	8082                	ret

00000000800039f8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800039f8:	7179                	addi	sp,sp,-48
    800039fa:	f406                	sd	ra,40(sp)
    800039fc:	f022                	sd	s0,32(sp)
    800039fe:	ec26                	sd	s1,24(sp)
    80003a00:	e84a                	sd	s2,16(sp)
    80003a02:	e44e                	sd	s3,8(sp)
    80003a04:	1800                	addi	s0,sp,48
    80003a06:	892a                	mv	s2,a0
    80003a08:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003a0a:	00017517          	auipc	a0,0x17
    80003a0e:	81650513          	addi	a0,a0,-2026 # 8001a220 <bcache>
    80003a12:	9bcfd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003a16:	0001f497          	auipc	s1,0x1f
    80003a1a:	ac24b483          	ld	s1,-1342(s1) # 800224d8 <bcache+0x82b8>
    80003a1e:	0001f797          	auipc	a5,0x1f
    80003a22:	a6a78793          	addi	a5,a5,-1430 # 80022488 <bcache+0x8268>
    80003a26:	02f48b63          	beq	s1,a5,80003a5c <bread+0x64>
    80003a2a:	873e                	mv	a4,a5
    80003a2c:	a021                	j	80003a34 <bread+0x3c>
    80003a2e:	68a4                	ld	s1,80(s1)
    80003a30:	02e48663          	beq	s1,a4,80003a5c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003a34:	449c                	lw	a5,8(s1)
    80003a36:	ff279ce3          	bne	a5,s2,80003a2e <bread+0x36>
    80003a3a:	44dc                	lw	a5,12(s1)
    80003a3c:	ff3799e3          	bne	a5,s3,80003a2e <bread+0x36>
      b->refcnt++;
    80003a40:	40bc                	lw	a5,64(s1)
    80003a42:	2785                	addiw	a5,a5,1
    80003a44:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003a46:	00016517          	auipc	a0,0x16
    80003a4a:	7da50513          	addi	a0,a0,2010 # 8001a220 <bcache>
    80003a4e:	a18fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80003a52:	01048513          	addi	a0,s1,16
    80003a56:	2d4010ef          	jal	80004d2a <acquiresleep>
      return b;
    80003a5a:	a889                	j	80003aac <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003a5c:	0001f497          	auipc	s1,0x1f
    80003a60:	a744b483          	ld	s1,-1420(s1) # 800224d0 <bcache+0x82b0>
    80003a64:	0001f797          	auipc	a5,0x1f
    80003a68:	a2478793          	addi	a5,a5,-1500 # 80022488 <bcache+0x8268>
    80003a6c:	00f48863          	beq	s1,a5,80003a7c <bread+0x84>
    80003a70:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003a72:	40bc                	lw	a5,64(s1)
    80003a74:	cb91                	beqz	a5,80003a88 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003a76:	64a4                	ld	s1,72(s1)
    80003a78:	fee49de3          	bne	s1,a4,80003a72 <bread+0x7a>
  panic("bget: no buffers");
    80003a7c:	00005517          	auipc	a0,0x5
    80003a80:	a6c50513          	addi	a0,a0,-1428 # 800084e8 <etext+0x4e8>
    80003a84:	d5dfc0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80003a88:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003a8c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003a90:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003a94:	4785                	li	a5,1
    80003a96:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003a98:	00016517          	auipc	a0,0x16
    80003a9c:	78850513          	addi	a0,a0,1928 # 8001a220 <bcache>
    80003aa0:	9c6fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80003aa4:	01048513          	addi	a0,s1,16
    80003aa8:	282010ef          	jal	80004d2a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003aac:	409c                	lw	a5,0(s1)
    80003aae:	cb89                	beqz	a5,80003ac0 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003ab0:	8526                	mv	a0,s1
    80003ab2:	70a2                	ld	ra,40(sp)
    80003ab4:	7402                	ld	s0,32(sp)
    80003ab6:	64e2                	ld	s1,24(sp)
    80003ab8:	6942                	ld	s2,16(sp)
    80003aba:	69a2                	ld	s3,8(sp)
    80003abc:	6145                	addi	sp,sp,48
    80003abe:	8082                	ret
    virtio_disk_rw(b, 0);
    80003ac0:	4581                	li	a1,0
    80003ac2:	8526                	mv	a0,s1
    80003ac4:	2cd020ef          	jal	80006590 <virtio_disk_rw>
    b->valid = 1;
    80003ac8:	4785                	li	a5,1
    80003aca:	c09c                	sw	a5,0(s1)
  return b;
    80003acc:	b7d5                	j	80003ab0 <bread+0xb8>

0000000080003ace <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003ace:	1101                	addi	sp,sp,-32
    80003ad0:	ec06                	sd	ra,24(sp)
    80003ad2:	e822                	sd	s0,16(sp)
    80003ad4:	e426                	sd	s1,8(sp)
    80003ad6:	1000                	addi	s0,sp,32
    80003ad8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003ada:	0541                	addi	a0,a0,16
    80003adc:	2cc010ef          	jal	80004da8 <holdingsleep>
    80003ae0:	c911                	beqz	a0,80003af4 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003ae2:	4585                	li	a1,1
    80003ae4:	8526                	mv	a0,s1
    80003ae6:	2ab020ef          	jal	80006590 <virtio_disk_rw>
}
    80003aea:	60e2                	ld	ra,24(sp)
    80003aec:	6442                	ld	s0,16(sp)
    80003aee:	64a2                	ld	s1,8(sp)
    80003af0:	6105                	addi	sp,sp,32
    80003af2:	8082                	ret
    panic("bwrite");
    80003af4:	00005517          	auipc	a0,0x5
    80003af8:	a0c50513          	addi	a0,a0,-1524 # 80008500 <etext+0x500>
    80003afc:	ce5fc0ef          	jal	800007e0 <panic>

0000000080003b00 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003b00:	1101                	addi	sp,sp,-32
    80003b02:	ec06                	sd	ra,24(sp)
    80003b04:	e822                	sd	s0,16(sp)
    80003b06:	e426                	sd	s1,8(sp)
    80003b08:	e04a                	sd	s2,0(sp)
    80003b0a:	1000                	addi	s0,sp,32
    80003b0c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003b0e:	01050913          	addi	s2,a0,16
    80003b12:	854a                	mv	a0,s2
    80003b14:	294010ef          	jal	80004da8 <holdingsleep>
    80003b18:	c135                	beqz	a0,80003b7c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80003b1a:	854a                	mv	a0,s2
    80003b1c:	254010ef          	jal	80004d70 <releasesleep>

  acquire(&bcache.lock);
    80003b20:	00016517          	auipc	a0,0x16
    80003b24:	70050513          	addi	a0,a0,1792 # 8001a220 <bcache>
    80003b28:	8a6fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80003b2c:	40bc                	lw	a5,64(s1)
    80003b2e:	37fd                	addiw	a5,a5,-1
    80003b30:	0007871b          	sext.w	a4,a5
    80003b34:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003b36:	e71d                	bnez	a4,80003b64 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003b38:	68b8                	ld	a4,80(s1)
    80003b3a:	64bc                	ld	a5,72(s1)
    80003b3c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003b3e:	68b8                	ld	a4,80(s1)
    80003b40:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003b42:	0001e797          	auipc	a5,0x1e
    80003b46:	6de78793          	addi	a5,a5,1758 # 80022220 <bcache+0x8000>
    80003b4a:	2b87b703          	ld	a4,696(a5)
    80003b4e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003b50:	0001f717          	auipc	a4,0x1f
    80003b54:	93870713          	addi	a4,a4,-1736 # 80022488 <bcache+0x8268>
    80003b58:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003b5a:	2b87b703          	ld	a4,696(a5)
    80003b5e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003b60:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003b64:	00016517          	auipc	a0,0x16
    80003b68:	6bc50513          	addi	a0,a0,1724 # 8001a220 <bcache>
    80003b6c:	8fafd0ef          	jal	80000c66 <release>
}
    80003b70:	60e2                	ld	ra,24(sp)
    80003b72:	6442                	ld	s0,16(sp)
    80003b74:	64a2                	ld	s1,8(sp)
    80003b76:	6902                	ld	s2,0(sp)
    80003b78:	6105                	addi	sp,sp,32
    80003b7a:	8082                	ret
    panic("brelse");
    80003b7c:	00005517          	auipc	a0,0x5
    80003b80:	98c50513          	addi	a0,a0,-1652 # 80008508 <etext+0x508>
    80003b84:	c5dfc0ef          	jal	800007e0 <panic>

0000000080003b88 <bpin>:

void
bpin(struct buf *b) {
    80003b88:	1101                	addi	sp,sp,-32
    80003b8a:	ec06                	sd	ra,24(sp)
    80003b8c:	e822                	sd	s0,16(sp)
    80003b8e:	e426                	sd	s1,8(sp)
    80003b90:	1000                	addi	s0,sp,32
    80003b92:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003b94:	00016517          	auipc	a0,0x16
    80003b98:	68c50513          	addi	a0,a0,1676 # 8001a220 <bcache>
    80003b9c:	832fd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80003ba0:	40bc                	lw	a5,64(s1)
    80003ba2:	2785                	addiw	a5,a5,1
    80003ba4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003ba6:	00016517          	auipc	a0,0x16
    80003baa:	67a50513          	addi	a0,a0,1658 # 8001a220 <bcache>
    80003bae:	8b8fd0ef          	jal	80000c66 <release>
}
    80003bb2:	60e2                	ld	ra,24(sp)
    80003bb4:	6442                	ld	s0,16(sp)
    80003bb6:	64a2                	ld	s1,8(sp)
    80003bb8:	6105                	addi	sp,sp,32
    80003bba:	8082                	ret

0000000080003bbc <bunpin>:

void
bunpin(struct buf *b) {
    80003bbc:	1101                	addi	sp,sp,-32
    80003bbe:	ec06                	sd	ra,24(sp)
    80003bc0:	e822                	sd	s0,16(sp)
    80003bc2:	e426                	sd	s1,8(sp)
    80003bc4:	1000                	addi	s0,sp,32
    80003bc6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003bc8:	00016517          	auipc	a0,0x16
    80003bcc:	65850513          	addi	a0,a0,1624 # 8001a220 <bcache>
    80003bd0:	ffffc0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80003bd4:	40bc                	lw	a5,64(s1)
    80003bd6:	37fd                	addiw	a5,a5,-1
    80003bd8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003bda:	00016517          	auipc	a0,0x16
    80003bde:	64650513          	addi	a0,a0,1606 # 8001a220 <bcache>
    80003be2:	884fd0ef          	jal	80000c66 <release>
}
    80003be6:	60e2                	ld	ra,24(sp)
    80003be8:	6442                	ld	s0,16(sp)
    80003bea:	64a2                	ld	s1,8(sp)
    80003bec:	6105                	addi	sp,sp,32
    80003bee:	8082                	ret

0000000080003bf0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003bf0:	1101                	addi	sp,sp,-32
    80003bf2:	ec06                	sd	ra,24(sp)
    80003bf4:	e822                	sd	s0,16(sp)
    80003bf6:	e426                	sd	s1,8(sp)
    80003bf8:	e04a                	sd	s2,0(sp)
    80003bfa:	1000                	addi	s0,sp,32
    80003bfc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003bfe:	00d5d59b          	srliw	a1,a1,0xd
    80003c02:	0001f797          	auipc	a5,0x1f
    80003c06:	cfa7a783          	lw	a5,-774(a5) # 800228fc <sb+0x1c>
    80003c0a:	9dbd                	addw	a1,a1,a5
    80003c0c:	dedff0ef          	jal	800039f8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003c10:	0074f713          	andi	a4,s1,7
    80003c14:	4785                	li	a5,1
    80003c16:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003c1a:	14ce                	slli	s1,s1,0x33
    80003c1c:	90d9                	srli	s1,s1,0x36
    80003c1e:	00950733          	add	a4,a0,s1
    80003c22:	05874703          	lbu	a4,88(a4)
    80003c26:	00e7f6b3          	and	a3,a5,a4
    80003c2a:	c29d                	beqz	a3,80003c50 <bfree+0x60>
    80003c2c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003c2e:	94aa                	add	s1,s1,a0
    80003c30:	fff7c793          	not	a5,a5
    80003c34:	8f7d                	and	a4,a4,a5
    80003c36:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003c3a:	7f9000ef          	jal	80004c32 <log_write>
  brelse(bp);
    80003c3e:	854a                	mv	a0,s2
    80003c40:	ec1ff0ef          	jal	80003b00 <brelse>
}
    80003c44:	60e2                	ld	ra,24(sp)
    80003c46:	6442                	ld	s0,16(sp)
    80003c48:	64a2                	ld	s1,8(sp)
    80003c4a:	6902                	ld	s2,0(sp)
    80003c4c:	6105                	addi	sp,sp,32
    80003c4e:	8082                	ret
    panic("freeing free block");
    80003c50:	00005517          	auipc	a0,0x5
    80003c54:	8c050513          	addi	a0,a0,-1856 # 80008510 <etext+0x510>
    80003c58:	b89fc0ef          	jal	800007e0 <panic>

0000000080003c5c <balloc>:
{
    80003c5c:	711d                	addi	sp,sp,-96
    80003c5e:	ec86                	sd	ra,88(sp)
    80003c60:	e8a2                	sd	s0,80(sp)
    80003c62:	e4a6                	sd	s1,72(sp)
    80003c64:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003c66:	0001f797          	auipc	a5,0x1f
    80003c6a:	c7e7a783          	lw	a5,-898(a5) # 800228e4 <sb+0x4>
    80003c6e:	0e078f63          	beqz	a5,80003d6c <balloc+0x110>
    80003c72:	e0ca                	sd	s2,64(sp)
    80003c74:	fc4e                	sd	s3,56(sp)
    80003c76:	f852                	sd	s4,48(sp)
    80003c78:	f456                	sd	s5,40(sp)
    80003c7a:	f05a                	sd	s6,32(sp)
    80003c7c:	ec5e                	sd	s7,24(sp)
    80003c7e:	e862                	sd	s8,16(sp)
    80003c80:	e466                	sd	s9,8(sp)
    80003c82:	8baa                	mv	s7,a0
    80003c84:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003c86:	0001fb17          	auipc	s6,0x1f
    80003c8a:	c5ab0b13          	addi	s6,s6,-934 # 800228e0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c8e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003c90:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c92:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003c94:	6c89                	lui	s9,0x2
    80003c96:	a0b5                	j	80003d02 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003c98:	97ca                	add	a5,a5,s2
    80003c9a:	8e55                	or	a2,a2,a3
    80003c9c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003ca0:	854a                	mv	a0,s2
    80003ca2:	791000ef          	jal	80004c32 <log_write>
        brelse(bp);
    80003ca6:	854a                	mv	a0,s2
    80003ca8:	e59ff0ef          	jal	80003b00 <brelse>
  bp = bread(dev, bno);
    80003cac:	85a6                	mv	a1,s1
    80003cae:	855e                	mv	a0,s7
    80003cb0:	d49ff0ef          	jal	800039f8 <bread>
    80003cb4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003cb6:	40000613          	li	a2,1024
    80003cba:	4581                	li	a1,0
    80003cbc:	05850513          	addi	a0,a0,88
    80003cc0:	fe3fc0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80003cc4:	854a                	mv	a0,s2
    80003cc6:	76d000ef          	jal	80004c32 <log_write>
  brelse(bp);
    80003cca:	854a                	mv	a0,s2
    80003ccc:	e35ff0ef          	jal	80003b00 <brelse>
}
    80003cd0:	6906                	ld	s2,64(sp)
    80003cd2:	79e2                	ld	s3,56(sp)
    80003cd4:	7a42                	ld	s4,48(sp)
    80003cd6:	7aa2                	ld	s5,40(sp)
    80003cd8:	7b02                	ld	s6,32(sp)
    80003cda:	6be2                	ld	s7,24(sp)
    80003cdc:	6c42                	ld	s8,16(sp)
    80003cde:	6ca2                	ld	s9,8(sp)
}
    80003ce0:	8526                	mv	a0,s1
    80003ce2:	60e6                	ld	ra,88(sp)
    80003ce4:	6446                	ld	s0,80(sp)
    80003ce6:	64a6                	ld	s1,72(sp)
    80003ce8:	6125                	addi	sp,sp,96
    80003cea:	8082                	ret
    brelse(bp);
    80003cec:	854a                	mv	a0,s2
    80003cee:	e13ff0ef          	jal	80003b00 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003cf2:	015c87bb          	addw	a5,s9,s5
    80003cf6:	00078a9b          	sext.w	s5,a5
    80003cfa:	004b2703          	lw	a4,4(s6)
    80003cfe:	04eaff63          	bgeu	s5,a4,80003d5c <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003d02:	41fad79b          	sraiw	a5,s5,0x1f
    80003d06:	0137d79b          	srliw	a5,a5,0x13
    80003d0a:	015787bb          	addw	a5,a5,s5
    80003d0e:	40d7d79b          	sraiw	a5,a5,0xd
    80003d12:	01cb2583          	lw	a1,28(s6)
    80003d16:	9dbd                	addw	a1,a1,a5
    80003d18:	855e                	mv	a0,s7
    80003d1a:	cdfff0ef          	jal	800039f8 <bread>
    80003d1e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003d20:	004b2503          	lw	a0,4(s6)
    80003d24:	000a849b          	sext.w	s1,s5
    80003d28:	8762                	mv	a4,s8
    80003d2a:	fca4f1e3          	bgeu	s1,a0,80003cec <balloc+0x90>
      m = 1 << (bi % 8);
    80003d2e:	00777693          	andi	a3,a4,7
    80003d32:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003d36:	41f7579b          	sraiw	a5,a4,0x1f
    80003d3a:	01d7d79b          	srliw	a5,a5,0x1d
    80003d3e:	9fb9                	addw	a5,a5,a4
    80003d40:	4037d79b          	sraiw	a5,a5,0x3
    80003d44:	00f90633          	add	a2,s2,a5
    80003d48:	05864603          	lbu	a2,88(a2)
    80003d4c:	00c6f5b3          	and	a1,a3,a2
    80003d50:	d5a1                	beqz	a1,80003c98 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003d52:	2705                	addiw	a4,a4,1
    80003d54:	2485                	addiw	s1,s1,1
    80003d56:	fd471ae3          	bne	a4,s4,80003d2a <balloc+0xce>
    80003d5a:	bf49                	j	80003cec <balloc+0x90>
    80003d5c:	6906                	ld	s2,64(sp)
    80003d5e:	79e2                	ld	s3,56(sp)
    80003d60:	7a42                	ld	s4,48(sp)
    80003d62:	7aa2                	ld	s5,40(sp)
    80003d64:	7b02                	ld	s6,32(sp)
    80003d66:	6be2                	ld	s7,24(sp)
    80003d68:	6c42                	ld	s8,16(sp)
    80003d6a:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003d6c:	00004517          	auipc	a0,0x4
    80003d70:	7bc50513          	addi	a0,a0,1980 # 80008528 <etext+0x528>
    80003d74:	f86fc0ef          	jal	800004fa <printf>
  return 0;
    80003d78:	4481                	li	s1,0
    80003d7a:	b79d                	j	80003ce0 <balloc+0x84>

0000000080003d7c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003d7c:	7179                	addi	sp,sp,-48
    80003d7e:	f406                	sd	ra,40(sp)
    80003d80:	f022                	sd	s0,32(sp)
    80003d82:	ec26                	sd	s1,24(sp)
    80003d84:	e84a                	sd	s2,16(sp)
    80003d86:	e44e                	sd	s3,8(sp)
    80003d88:	1800                	addi	s0,sp,48
    80003d8a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003d8c:	47ad                	li	a5,11
    80003d8e:	02b7e663          	bltu	a5,a1,80003dba <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003d92:	02059793          	slli	a5,a1,0x20
    80003d96:	01e7d593          	srli	a1,a5,0x1e
    80003d9a:	00b504b3          	add	s1,a0,a1
    80003d9e:	0504a903          	lw	s2,80(s1)
    80003da2:	06091a63          	bnez	s2,80003e16 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003da6:	4108                	lw	a0,0(a0)
    80003da8:	eb5ff0ef          	jal	80003c5c <balloc>
    80003dac:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003db0:	06090363          	beqz	s2,80003e16 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003db4:	0524a823          	sw	s2,80(s1)
    80003db8:	a8b9                	j	80003e16 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003dba:	ff45849b          	addiw	s1,a1,-12
    80003dbe:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003dc2:	0ff00793          	li	a5,255
    80003dc6:	06e7ee63          	bltu	a5,a4,80003e42 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003dca:	08052903          	lw	s2,128(a0)
    80003dce:	00091d63          	bnez	s2,80003de8 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003dd2:	4108                	lw	a0,0(a0)
    80003dd4:	e89ff0ef          	jal	80003c5c <balloc>
    80003dd8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ddc:	02090d63          	beqz	s2,80003e16 <bmap+0x9a>
    80003de0:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003de2:	0929a023          	sw	s2,128(s3)
    80003de6:	a011                	j	80003dea <bmap+0x6e>
    80003de8:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003dea:	85ca                	mv	a1,s2
    80003dec:	0009a503          	lw	a0,0(s3)
    80003df0:	c09ff0ef          	jal	800039f8 <bread>
    80003df4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003df6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003dfa:	02049713          	slli	a4,s1,0x20
    80003dfe:	01e75593          	srli	a1,a4,0x1e
    80003e02:	00b784b3          	add	s1,a5,a1
    80003e06:	0004a903          	lw	s2,0(s1)
    80003e0a:	00090e63          	beqz	s2,80003e26 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003e0e:	8552                	mv	a0,s4
    80003e10:	cf1ff0ef          	jal	80003b00 <brelse>
    return addr;
    80003e14:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003e16:	854a                	mv	a0,s2
    80003e18:	70a2                	ld	ra,40(sp)
    80003e1a:	7402                	ld	s0,32(sp)
    80003e1c:	64e2                	ld	s1,24(sp)
    80003e1e:	6942                	ld	s2,16(sp)
    80003e20:	69a2                	ld	s3,8(sp)
    80003e22:	6145                	addi	sp,sp,48
    80003e24:	8082                	ret
      addr = balloc(ip->dev);
    80003e26:	0009a503          	lw	a0,0(s3)
    80003e2a:	e33ff0ef          	jal	80003c5c <balloc>
    80003e2e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003e32:	fc090ee3          	beqz	s2,80003e0e <bmap+0x92>
        a[bn] = addr;
    80003e36:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003e3a:	8552                	mv	a0,s4
    80003e3c:	5f7000ef          	jal	80004c32 <log_write>
    80003e40:	b7f9                	j	80003e0e <bmap+0x92>
    80003e42:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003e44:	00004517          	auipc	a0,0x4
    80003e48:	6fc50513          	addi	a0,a0,1788 # 80008540 <etext+0x540>
    80003e4c:	995fc0ef          	jal	800007e0 <panic>

0000000080003e50 <iget>:
{
    80003e50:	7179                	addi	sp,sp,-48
    80003e52:	f406                	sd	ra,40(sp)
    80003e54:	f022                	sd	s0,32(sp)
    80003e56:	ec26                	sd	s1,24(sp)
    80003e58:	e84a                	sd	s2,16(sp)
    80003e5a:	e44e                	sd	s3,8(sp)
    80003e5c:	e052                	sd	s4,0(sp)
    80003e5e:	1800                	addi	s0,sp,48
    80003e60:	89aa                	mv	s3,a0
    80003e62:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003e64:	0001f517          	auipc	a0,0x1f
    80003e68:	a9c50513          	addi	a0,a0,-1380 # 80022900 <itable>
    80003e6c:	d63fc0ef          	jal	80000bce <acquire>
  empty = 0;
    80003e70:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003e72:	0001f497          	auipc	s1,0x1f
    80003e76:	aa648493          	addi	s1,s1,-1370 # 80022918 <itable+0x18>
    80003e7a:	00020697          	auipc	a3,0x20
    80003e7e:	52e68693          	addi	a3,a3,1326 # 800243a8 <log>
    80003e82:	a039                	j	80003e90 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003e84:	02090963          	beqz	s2,80003eb6 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003e88:	08848493          	addi	s1,s1,136
    80003e8c:	02d48863          	beq	s1,a3,80003ebc <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003e90:	449c                	lw	a5,8(s1)
    80003e92:	fef059e3          	blez	a5,80003e84 <iget+0x34>
    80003e96:	4098                	lw	a4,0(s1)
    80003e98:	ff3716e3          	bne	a4,s3,80003e84 <iget+0x34>
    80003e9c:	40d8                	lw	a4,4(s1)
    80003e9e:	ff4713e3          	bne	a4,s4,80003e84 <iget+0x34>
      ip->ref++;
    80003ea2:	2785                	addiw	a5,a5,1
    80003ea4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003ea6:	0001f517          	auipc	a0,0x1f
    80003eaa:	a5a50513          	addi	a0,a0,-1446 # 80022900 <itable>
    80003eae:	db9fc0ef          	jal	80000c66 <release>
      return ip;
    80003eb2:	8926                	mv	s2,s1
    80003eb4:	a02d                	j	80003ede <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003eb6:	fbe9                	bnez	a5,80003e88 <iget+0x38>
      empty = ip;
    80003eb8:	8926                	mv	s2,s1
    80003eba:	b7f9                	j	80003e88 <iget+0x38>
  if(empty == 0)
    80003ebc:	02090a63          	beqz	s2,80003ef0 <iget+0xa0>
  ip->dev = dev;
    80003ec0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003ec4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003ec8:	4785                	li	a5,1
    80003eca:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003ece:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003ed2:	0001f517          	auipc	a0,0x1f
    80003ed6:	a2e50513          	addi	a0,a0,-1490 # 80022900 <itable>
    80003eda:	d8dfc0ef          	jal	80000c66 <release>
}
    80003ede:	854a                	mv	a0,s2
    80003ee0:	70a2                	ld	ra,40(sp)
    80003ee2:	7402                	ld	s0,32(sp)
    80003ee4:	64e2                	ld	s1,24(sp)
    80003ee6:	6942                	ld	s2,16(sp)
    80003ee8:	69a2                	ld	s3,8(sp)
    80003eea:	6a02                	ld	s4,0(sp)
    80003eec:	6145                	addi	sp,sp,48
    80003eee:	8082                	ret
    panic("iget: no inodes");
    80003ef0:	00004517          	auipc	a0,0x4
    80003ef4:	66850513          	addi	a0,a0,1640 # 80008558 <etext+0x558>
    80003ef8:	8e9fc0ef          	jal	800007e0 <panic>

0000000080003efc <iinit>:
{
    80003efc:	7179                	addi	sp,sp,-48
    80003efe:	f406                	sd	ra,40(sp)
    80003f00:	f022                	sd	s0,32(sp)
    80003f02:	ec26                	sd	s1,24(sp)
    80003f04:	e84a                	sd	s2,16(sp)
    80003f06:	e44e                	sd	s3,8(sp)
    80003f08:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003f0a:	00004597          	auipc	a1,0x4
    80003f0e:	65e58593          	addi	a1,a1,1630 # 80008568 <etext+0x568>
    80003f12:	0001f517          	auipc	a0,0x1f
    80003f16:	9ee50513          	addi	a0,a0,-1554 # 80022900 <itable>
    80003f1a:	c35fc0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003f1e:	0001f497          	auipc	s1,0x1f
    80003f22:	a0a48493          	addi	s1,s1,-1526 # 80022928 <itable+0x28>
    80003f26:	00020997          	auipc	s3,0x20
    80003f2a:	49298993          	addi	s3,s3,1170 # 800243b8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003f2e:	00004917          	auipc	s2,0x4
    80003f32:	64290913          	addi	s2,s2,1602 # 80008570 <etext+0x570>
    80003f36:	85ca                	mv	a1,s2
    80003f38:	8526                	mv	a0,s1
    80003f3a:	5bb000ef          	jal	80004cf4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003f3e:	08848493          	addi	s1,s1,136
    80003f42:	ff349ae3          	bne	s1,s3,80003f36 <iinit+0x3a>
}
    80003f46:	70a2                	ld	ra,40(sp)
    80003f48:	7402                	ld	s0,32(sp)
    80003f4a:	64e2                	ld	s1,24(sp)
    80003f4c:	6942                	ld	s2,16(sp)
    80003f4e:	69a2                	ld	s3,8(sp)
    80003f50:	6145                	addi	sp,sp,48
    80003f52:	8082                	ret

0000000080003f54 <ialloc>:
{
    80003f54:	7139                	addi	sp,sp,-64
    80003f56:	fc06                	sd	ra,56(sp)
    80003f58:	f822                	sd	s0,48(sp)
    80003f5a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f5c:	0001f717          	auipc	a4,0x1f
    80003f60:	99072703          	lw	a4,-1648(a4) # 800228ec <sb+0xc>
    80003f64:	4785                	li	a5,1
    80003f66:	06e7f063          	bgeu	a5,a4,80003fc6 <ialloc+0x72>
    80003f6a:	f426                	sd	s1,40(sp)
    80003f6c:	f04a                	sd	s2,32(sp)
    80003f6e:	ec4e                	sd	s3,24(sp)
    80003f70:	e852                	sd	s4,16(sp)
    80003f72:	e456                	sd	s5,8(sp)
    80003f74:	e05a                	sd	s6,0(sp)
    80003f76:	8aaa                	mv	s5,a0
    80003f78:	8b2e                	mv	s6,a1
    80003f7a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003f7c:	0001fa17          	auipc	s4,0x1f
    80003f80:	964a0a13          	addi	s4,s4,-1692 # 800228e0 <sb>
    80003f84:	00495593          	srli	a1,s2,0x4
    80003f88:	018a2783          	lw	a5,24(s4)
    80003f8c:	9dbd                	addw	a1,a1,a5
    80003f8e:	8556                	mv	a0,s5
    80003f90:	a69ff0ef          	jal	800039f8 <bread>
    80003f94:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003f96:	05850993          	addi	s3,a0,88
    80003f9a:	00f97793          	andi	a5,s2,15
    80003f9e:	079a                	slli	a5,a5,0x6
    80003fa0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003fa2:	00099783          	lh	a5,0(s3)
    80003fa6:	cb9d                	beqz	a5,80003fdc <ialloc+0x88>
    brelse(bp);
    80003fa8:	b59ff0ef          	jal	80003b00 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003fac:	0905                	addi	s2,s2,1
    80003fae:	00ca2703          	lw	a4,12(s4)
    80003fb2:	0009079b          	sext.w	a5,s2
    80003fb6:	fce7e7e3          	bltu	a5,a4,80003f84 <ialloc+0x30>
    80003fba:	74a2                	ld	s1,40(sp)
    80003fbc:	7902                	ld	s2,32(sp)
    80003fbe:	69e2                	ld	s3,24(sp)
    80003fc0:	6a42                	ld	s4,16(sp)
    80003fc2:	6aa2                	ld	s5,8(sp)
    80003fc4:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003fc6:	00004517          	auipc	a0,0x4
    80003fca:	5b250513          	addi	a0,a0,1458 # 80008578 <etext+0x578>
    80003fce:	d2cfc0ef          	jal	800004fa <printf>
  return 0;
    80003fd2:	4501                	li	a0,0
}
    80003fd4:	70e2                	ld	ra,56(sp)
    80003fd6:	7442                	ld	s0,48(sp)
    80003fd8:	6121                	addi	sp,sp,64
    80003fda:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003fdc:	04000613          	li	a2,64
    80003fe0:	4581                	li	a1,0
    80003fe2:	854e                	mv	a0,s3
    80003fe4:	cbffc0ef          	jal	80000ca2 <memset>
      dip->type = type;
    80003fe8:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003fec:	8526                	mv	a0,s1
    80003fee:	445000ef          	jal	80004c32 <log_write>
      brelse(bp);
    80003ff2:	8526                	mv	a0,s1
    80003ff4:	b0dff0ef          	jal	80003b00 <brelse>
      return iget(dev, inum);
    80003ff8:	0009059b          	sext.w	a1,s2
    80003ffc:	8556                	mv	a0,s5
    80003ffe:	e53ff0ef          	jal	80003e50 <iget>
    80004002:	74a2                	ld	s1,40(sp)
    80004004:	7902                	ld	s2,32(sp)
    80004006:	69e2                	ld	s3,24(sp)
    80004008:	6a42                	ld	s4,16(sp)
    8000400a:	6aa2                	ld	s5,8(sp)
    8000400c:	6b02                	ld	s6,0(sp)
    8000400e:	b7d9                	j	80003fd4 <ialloc+0x80>

0000000080004010 <iupdate>:
{
    80004010:	1101                	addi	sp,sp,-32
    80004012:	ec06                	sd	ra,24(sp)
    80004014:	e822                	sd	s0,16(sp)
    80004016:	e426                	sd	s1,8(sp)
    80004018:	e04a                	sd	s2,0(sp)
    8000401a:	1000                	addi	s0,sp,32
    8000401c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000401e:	415c                	lw	a5,4(a0)
    80004020:	0047d79b          	srliw	a5,a5,0x4
    80004024:	0001f597          	auipc	a1,0x1f
    80004028:	8d45a583          	lw	a1,-1836(a1) # 800228f8 <sb+0x18>
    8000402c:	9dbd                	addw	a1,a1,a5
    8000402e:	4108                	lw	a0,0(a0)
    80004030:	9c9ff0ef          	jal	800039f8 <bread>
    80004034:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004036:	05850793          	addi	a5,a0,88
    8000403a:	40d8                	lw	a4,4(s1)
    8000403c:	8b3d                	andi	a4,a4,15
    8000403e:	071a                	slli	a4,a4,0x6
    80004040:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80004042:	04449703          	lh	a4,68(s1)
    80004046:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000404a:	04649703          	lh	a4,70(s1)
    8000404e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80004052:	04849703          	lh	a4,72(s1)
    80004056:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000405a:	04a49703          	lh	a4,74(s1)
    8000405e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80004062:	44f8                	lw	a4,76(s1)
    80004064:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004066:	03400613          	li	a2,52
    8000406a:	05048593          	addi	a1,s1,80
    8000406e:	00c78513          	addi	a0,a5,12
    80004072:	c8dfc0ef          	jal	80000cfe <memmove>
  log_write(bp);
    80004076:	854a                	mv	a0,s2
    80004078:	3bb000ef          	jal	80004c32 <log_write>
  brelse(bp);
    8000407c:	854a                	mv	a0,s2
    8000407e:	a83ff0ef          	jal	80003b00 <brelse>
}
    80004082:	60e2                	ld	ra,24(sp)
    80004084:	6442                	ld	s0,16(sp)
    80004086:	64a2                	ld	s1,8(sp)
    80004088:	6902                	ld	s2,0(sp)
    8000408a:	6105                	addi	sp,sp,32
    8000408c:	8082                	ret

000000008000408e <idup>:
{
    8000408e:	1101                	addi	sp,sp,-32
    80004090:	ec06                	sd	ra,24(sp)
    80004092:	e822                	sd	s0,16(sp)
    80004094:	e426                	sd	s1,8(sp)
    80004096:	1000                	addi	s0,sp,32
    80004098:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000409a:	0001f517          	auipc	a0,0x1f
    8000409e:	86650513          	addi	a0,a0,-1946 # 80022900 <itable>
    800040a2:	b2dfc0ef          	jal	80000bce <acquire>
  ip->ref++;
    800040a6:	449c                	lw	a5,8(s1)
    800040a8:	2785                	addiw	a5,a5,1
    800040aa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800040ac:	0001f517          	auipc	a0,0x1f
    800040b0:	85450513          	addi	a0,a0,-1964 # 80022900 <itable>
    800040b4:	bb3fc0ef          	jal	80000c66 <release>
}
    800040b8:	8526                	mv	a0,s1
    800040ba:	60e2                	ld	ra,24(sp)
    800040bc:	6442                	ld	s0,16(sp)
    800040be:	64a2                	ld	s1,8(sp)
    800040c0:	6105                	addi	sp,sp,32
    800040c2:	8082                	ret

00000000800040c4 <ilock>:
{
    800040c4:	1101                	addi	sp,sp,-32
    800040c6:	ec06                	sd	ra,24(sp)
    800040c8:	e822                	sd	s0,16(sp)
    800040ca:	e426                	sd	s1,8(sp)
    800040cc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800040ce:	cd19                	beqz	a0,800040ec <ilock+0x28>
    800040d0:	84aa                	mv	s1,a0
    800040d2:	451c                	lw	a5,8(a0)
    800040d4:	00f05c63          	blez	a5,800040ec <ilock+0x28>
  acquiresleep(&ip->lock);
    800040d8:	0541                	addi	a0,a0,16
    800040da:	451000ef          	jal	80004d2a <acquiresleep>
  if(ip->valid == 0){
    800040de:	40bc                	lw	a5,64(s1)
    800040e0:	cf89                	beqz	a5,800040fa <ilock+0x36>
}
    800040e2:	60e2                	ld	ra,24(sp)
    800040e4:	6442                	ld	s0,16(sp)
    800040e6:	64a2                	ld	s1,8(sp)
    800040e8:	6105                	addi	sp,sp,32
    800040ea:	8082                	ret
    800040ec:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800040ee:	00004517          	auipc	a0,0x4
    800040f2:	4a250513          	addi	a0,a0,1186 # 80008590 <etext+0x590>
    800040f6:	eeafc0ef          	jal	800007e0 <panic>
    800040fa:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800040fc:	40dc                	lw	a5,4(s1)
    800040fe:	0047d79b          	srliw	a5,a5,0x4
    80004102:	0001e597          	auipc	a1,0x1e
    80004106:	7f65a583          	lw	a1,2038(a1) # 800228f8 <sb+0x18>
    8000410a:	9dbd                	addw	a1,a1,a5
    8000410c:	4088                	lw	a0,0(s1)
    8000410e:	8ebff0ef          	jal	800039f8 <bread>
    80004112:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004114:	05850593          	addi	a1,a0,88
    80004118:	40dc                	lw	a5,4(s1)
    8000411a:	8bbd                	andi	a5,a5,15
    8000411c:	079a                	slli	a5,a5,0x6
    8000411e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004120:	00059783          	lh	a5,0(a1)
    80004124:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004128:	00259783          	lh	a5,2(a1)
    8000412c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004130:	00459783          	lh	a5,4(a1)
    80004134:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004138:	00659783          	lh	a5,6(a1)
    8000413c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004140:	459c                	lw	a5,8(a1)
    80004142:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004144:	03400613          	li	a2,52
    80004148:	05b1                	addi	a1,a1,12
    8000414a:	05048513          	addi	a0,s1,80
    8000414e:	bb1fc0ef          	jal	80000cfe <memmove>
    brelse(bp);
    80004152:	854a                	mv	a0,s2
    80004154:	9adff0ef          	jal	80003b00 <brelse>
    ip->valid = 1;
    80004158:	4785                	li	a5,1
    8000415a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000415c:	04449783          	lh	a5,68(s1)
    80004160:	c399                	beqz	a5,80004166 <ilock+0xa2>
    80004162:	6902                	ld	s2,0(sp)
    80004164:	bfbd                	j	800040e2 <ilock+0x1e>
      panic("ilock: no type");
    80004166:	00004517          	auipc	a0,0x4
    8000416a:	43250513          	addi	a0,a0,1074 # 80008598 <etext+0x598>
    8000416e:	e72fc0ef          	jal	800007e0 <panic>

0000000080004172 <iunlock>:
{
    80004172:	1101                	addi	sp,sp,-32
    80004174:	ec06                	sd	ra,24(sp)
    80004176:	e822                	sd	s0,16(sp)
    80004178:	e426                	sd	s1,8(sp)
    8000417a:	e04a                	sd	s2,0(sp)
    8000417c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000417e:	c505                	beqz	a0,800041a6 <iunlock+0x34>
    80004180:	84aa                	mv	s1,a0
    80004182:	01050913          	addi	s2,a0,16
    80004186:	854a                	mv	a0,s2
    80004188:	421000ef          	jal	80004da8 <holdingsleep>
    8000418c:	cd09                	beqz	a0,800041a6 <iunlock+0x34>
    8000418e:	449c                	lw	a5,8(s1)
    80004190:	00f05b63          	blez	a5,800041a6 <iunlock+0x34>
  releasesleep(&ip->lock);
    80004194:	854a                	mv	a0,s2
    80004196:	3db000ef          	jal	80004d70 <releasesleep>
}
    8000419a:	60e2                	ld	ra,24(sp)
    8000419c:	6442                	ld	s0,16(sp)
    8000419e:	64a2                	ld	s1,8(sp)
    800041a0:	6902                	ld	s2,0(sp)
    800041a2:	6105                	addi	sp,sp,32
    800041a4:	8082                	ret
    panic("iunlock");
    800041a6:	00004517          	auipc	a0,0x4
    800041aa:	40250513          	addi	a0,a0,1026 # 800085a8 <etext+0x5a8>
    800041ae:	e32fc0ef          	jal	800007e0 <panic>

00000000800041b2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800041b2:	7179                	addi	sp,sp,-48
    800041b4:	f406                	sd	ra,40(sp)
    800041b6:	f022                	sd	s0,32(sp)
    800041b8:	ec26                	sd	s1,24(sp)
    800041ba:	e84a                	sd	s2,16(sp)
    800041bc:	e44e                	sd	s3,8(sp)
    800041be:	1800                	addi	s0,sp,48
    800041c0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800041c2:	05050493          	addi	s1,a0,80
    800041c6:	08050913          	addi	s2,a0,128
    800041ca:	a021                	j	800041d2 <itrunc+0x20>
    800041cc:	0491                	addi	s1,s1,4
    800041ce:	01248b63          	beq	s1,s2,800041e4 <itrunc+0x32>
    if(ip->addrs[i]){
    800041d2:	408c                	lw	a1,0(s1)
    800041d4:	dde5                	beqz	a1,800041cc <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800041d6:	0009a503          	lw	a0,0(s3)
    800041da:	a17ff0ef          	jal	80003bf0 <bfree>
      ip->addrs[i] = 0;
    800041de:	0004a023          	sw	zero,0(s1)
    800041e2:	b7ed                	j	800041cc <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800041e4:	0809a583          	lw	a1,128(s3)
    800041e8:	ed89                	bnez	a1,80004202 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800041ea:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800041ee:	854e                	mv	a0,s3
    800041f0:	e21ff0ef          	jal	80004010 <iupdate>
}
    800041f4:	70a2                	ld	ra,40(sp)
    800041f6:	7402                	ld	s0,32(sp)
    800041f8:	64e2                	ld	s1,24(sp)
    800041fa:	6942                	ld	s2,16(sp)
    800041fc:	69a2                	ld	s3,8(sp)
    800041fe:	6145                	addi	sp,sp,48
    80004200:	8082                	ret
    80004202:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004204:	0009a503          	lw	a0,0(s3)
    80004208:	ff0ff0ef          	jal	800039f8 <bread>
    8000420c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000420e:	05850493          	addi	s1,a0,88
    80004212:	45850913          	addi	s2,a0,1112
    80004216:	a021                	j	8000421e <itrunc+0x6c>
    80004218:	0491                	addi	s1,s1,4
    8000421a:	01248963          	beq	s1,s2,8000422c <itrunc+0x7a>
      if(a[j])
    8000421e:	408c                	lw	a1,0(s1)
    80004220:	dde5                	beqz	a1,80004218 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80004222:	0009a503          	lw	a0,0(s3)
    80004226:	9cbff0ef          	jal	80003bf0 <bfree>
    8000422a:	b7fd                	j	80004218 <itrunc+0x66>
    brelse(bp);
    8000422c:	8552                	mv	a0,s4
    8000422e:	8d3ff0ef          	jal	80003b00 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004232:	0809a583          	lw	a1,128(s3)
    80004236:	0009a503          	lw	a0,0(s3)
    8000423a:	9b7ff0ef          	jal	80003bf0 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000423e:	0809a023          	sw	zero,128(s3)
    80004242:	6a02                	ld	s4,0(sp)
    80004244:	b75d                	j	800041ea <itrunc+0x38>

0000000080004246 <iput>:
{
    80004246:	1101                	addi	sp,sp,-32
    80004248:	ec06                	sd	ra,24(sp)
    8000424a:	e822                	sd	s0,16(sp)
    8000424c:	e426                	sd	s1,8(sp)
    8000424e:	1000                	addi	s0,sp,32
    80004250:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004252:	0001e517          	auipc	a0,0x1e
    80004256:	6ae50513          	addi	a0,a0,1710 # 80022900 <itable>
    8000425a:	975fc0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000425e:	4498                	lw	a4,8(s1)
    80004260:	4785                	li	a5,1
    80004262:	02f70063          	beq	a4,a5,80004282 <iput+0x3c>
  ip->ref--;
    80004266:	449c                	lw	a5,8(s1)
    80004268:	37fd                	addiw	a5,a5,-1
    8000426a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000426c:	0001e517          	auipc	a0,0x1e
    80004270:	69450513          	addi	a0,a0,1684 # 80022900 <itable>
    80004274:	9f3fc0ef          	jal	80000c66 <release>
}
    80004278:	60e2                	ld	ra,24(sp)
    8000427a:	6442                	ld	s0,16(sp)
    8000427c:	64a2                	ld	s1,8(sp)
    8000427e:	6105                	addi	sp,sp,32
    80004280:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004282:	40bc                	lw	a5,64(s1)
    80004284:	d3ed                	beqz	a5,80004266 <iput+0x20>
    80004286:	04a49783          	lh	a5,74(s1)
    8000428a:	fff1                	bnez	a5,80004266 <iput+0x20>
    8000428c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000428e:	01048913          	addi	s2,s1,16
    80004292:	854a                	mv	a0,s2
    80004294:	297000ef          	jal	80004d2a <acquiresleep>
    release(&itable.lock);
    80004298:	0001e517          	auipc	a0,0x1e
    8000429c:	66850513          	addi	a0,a0,1640 # 80022900 <itable>
    800042a0:	9c7fc0ef          	jal	80000c66 <release>
    itrunc(ip);
    800042a4:	8526                	mv	a0,s1
    800042a6:	f0dff0ef          	jal	800041b2 <itrunc>
    ip->type = 0;
    800042aa:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800042ae:	8526                	mv	a0,s1
    800042b0:	d61ff0ef          	jal	80004010 <iupdate>
    ip->valid = 0;
    800042b4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800042b8:	854a                	mv	a0,s2
    800042ba:	2b7000ef          	jal	80004d70 <releasesleep>
    acquire(&itable.lock);
    800042be:	0001e517          	auipc	a0,0x1e
    800042c2:	64250513          	addi	a0,a0,1602 # 80022900 <itable>
    800042c6:	909fc0ef          	jal	80000bce <acquire>
    800042ca:	6902                	ld	s2,0(sp)
    800042cc:	bf69                	j	80004266 <iput+0x20>

00000000800042ce <iunlockput>:
{
    800042ce:	1101                	addi	sp,sp,-32
    800042d0:	ec06                	sd	ra,24(sp)
    800042d2:	e822                	sd	s0,16(sp)
    800042d4:	e426                	sd	s1,8(sp)
    800042d6:	1000                	addi	s0,sp,32
    800042d8:	84aa                	mv	s1,a0
  iunlock(ip);
    800042da:	e99ff0ef          	jal	80004172 <iunlock>
  iput(ip);
    800042de:	8526                	mv	a0,s1
    800042e0:	f67ff0ef          	jal	80004246 <iput>
}
    800042e4:	60e2                	ld	ra,24(sp)
    800042e6:	6442                	ld	s0,16(sp)
    800042e8:	64a2                	ld	s1,8(sp)
    800042ea:	6105                	addi	sp,sp,32
    800042ec:	8082                	ret

00000000800042ee <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800042ee:	0001e717          	auipc	a4,0x1e
    800042f2:	5fe72703          	lw	a4,1534(a4) # 800228ec <sb+0xc>
    800042f6:	4785                	li	a5,1
    800042f8:	0ae7ff63          	bgeu	a5,a4,800043b6 <ireclaim+0xc8>
{
    800042fc:	7139                	addi	sp,sp,-64
    800042fe:	fc06                	sd	ra,56(sp)
    80004300:	f822                	sd	s0,48(sp)
    80004302:	f426                	sd	s1,40(sp)
    80004304:	f04a                	sd	s2,32(sp)
    80004306:	ec4e                	sd	s3,24(sp)
    80004308:	e852                	sd	s4,16(sp)
    8000430a:	e456                	sd	s5,8(sp)
    8000430c:	e05a                	sd	s6,0(sp)
    8000430e:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004310:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004312:	00050a1b          	sext.w	s4,a0
    80004316:	0001ea97          	auipc	s5,0x1e
    8000431a:	5caa8a93          	addi	s5,s5,1482 # 800228e0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000431e:	00004b17          	auipc	s6,0x4
    80004322:	292b0b13          	addi	s6,s6,658 # 800085b0 <etext+0x5b0>
    80004326:	a099                	j	8000436c <ireclaim+0x7e>
    80004328:	85ce                	mv	a1,s3
    8000432a:	855a                	mv	a0,s6
    8000432c:	9cefc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80004330:	85ce                	mv	a1,s3
    80004332:	8552                	mv	a0,s4
    80004334:	b1dff0ef          	jal	80003e50 <iget>
    80004338:	89aa                	mv	s3,a0
    brelse(bp);
    8000433a:	854a                	mv	a0,s2
    8000433c:	fc4ff0ef          	jal	80003b00 <brelse>
    if (ip) {
    80004340:	00098f63          	beqz	s3,8000435e <ireclaim+0x70>
      begin_op();
    80004344:	76a000ef          	jal	80004aae <begin_op>
      ilock(ip);
    80004348:	854e                	mv	a0,s3
    8000434a:	d7bff0ef          	jal	800040c4 <ilock>
      iunlock(ip);
    8000434e:	854e                	mv	a0,s3
    80004350:	e23ff0ef          	jal	80004172 <iunlock>
      iput(ip);
    80004354:	854e                	mv	a0,s3
    80004356:	ef1ff0ef          	jal	80004246 <iput>
      end_op();
    8000435a:	7be000ef          	jal	80004b18 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000435e:	0485                	addi	s1,s1,1
    80004360:	00caa703          	lw	a4,12(s5)
    80004364:	0004879b          	sext.w	a5,s1
    80004368:	02e7fd63          	bgeu	a5,a4,800043a2 <ireclaim+0xb4>
    8000436c:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004370:	0044d593          	srli	a1,s1,0x4
    80004374:	018aa783          	lw	a5,24(s5)
    80004378:	9dbd                	addw	a1,a1,a5
    8000437a:	8552                	mv	a0,s4
    8000437c:	e7cff0ef          	jal	800039f8 <bread>
    80004380:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80004382:	05850793          	addi	a5,a0,88
    80004386:	00f9f713          	andi	a4,s3,15
    8000438a:	071a                	slli	a4,a4,0x6
    8000438c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000438e:	00079703          	lh	a4,0(a5)
    80004392:	c701                	beqz	a4,8000439a <ireclaim+0xac>
    80004394:	00679783          	lh	a5,6(a5)
    80004398:	dbc1                	beqz	a5,80004328 <ireclaim+0x3a>
    brelse(bp);
    8000439a:	854a                	mv	a0,s2
    8000439c:	f64ff0ef          	jal	80003b00 <brelse>
    if (ip) {
    800043a0:	bf7d                	j	8000435e <ireclaim+0x70>
}
    800043a2:	70e2                	ld	ra,56(sp)
    800043a4:	7442                	ld	s0,48(sp)
    800043a6:	74a2                	ld	s1,40(sp)
    800043a8:	7902                	ld	s2,32(sp)
    800043aa:	69e2                	ld	s3,24(sp)
    800043ac:	6a42                	ld	s4,16(sp)
    800043ae:	6aa2                	ld	s5,8(sp)
    800043b0:	6b02                	ld	s6,0(sp)
    800043b2:	6121                	addi	sp,sp,64
    800043b4:	8082                	ret
    800043b6:	8082                	ret

00000000800043b8 <fsinit>:
fsinit(int dev) {
    800043b8:	7179                	addi	sp,sp,-48
    800043ba:	f406                	sd	ra,40(sp)
    800043bc:	f022                	sd	s0,32(sp)
    800043be:	ec26                	sd	s1,24(sp)
    800043c0:	e84a                	sd	s2,16(sp)
    800043c2:	e44e                	sd	s3,8(sp)
    800043c4:	1800                	addi	s0,sp,48
    800043c6:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800043c8:	4585                	li	a1,1
    800043ca:	e2eff0ef          	jal	800039f8 <bread>
    800043ce:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800043d0:	0001e997          	auipc	s3,0x1e
    800043d4:	51098993          	addi	s3,s3,1296 # 800228e0 <sb>
    800043d8:	02000613          	li	a2,32
    800043dc:	05850593          	addi	a1,a0,88
    800043e0:	854e                	mv	a0,s3
    800043e2:	91dfc0ef          	jal	80000cfe <memmove>
  brelse(bp);
    800043e6:	854a                	mv	a0,s2
    800043e8:	f18ff0ef          	jal	80003b00 <brelse>
  if(sb.magic != FSMAGIC)
    800043ec:	0009a703          	lw	a4,0(s3)
    800043f0:	102037b7          	lui	a5,0x10203
    800043f4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800043f8:	02f71363          	bne	a4,a5,8000441e <fsinit+0x66>
  initlog(dev, &sb);
    800043fc:	0001e597          	auipc	a1,0x1e
    80004400:	4e458593          	addi	a1,a1,1252 # 800228e0 <sb>
    80004404:	8526                	mv	a0,s1
    80004406:	62a000ef          	jal	80004a30 <initlog>
  ireclaim(dev);
    8000440a:	8526                	mv	a0,s1
    8000440c:	ee3ff0ef          	jal	800042ee <ireclaim>
}
    80004410:	70a2                	ld	ra,40(sp)
    80004412:	7402                	ld	s0,32(sp)
    80004414:	64e2                	ld	s1,24(sp)
    80004416:	6942                	ld	s2,16(sp)
    80004418:	69a2                	ld	s3,8(sp)
    8000441a:	6145                	addi	sp,sp,48
    8000441c:	8082                	ret
    panic("invalid file system");
    8000441e:	00004517          	auipc	a0,0x4
    80004422:	1b250513          	addi	a0,a0,434 # 800085d0 <etext+0x5d0>
    80004426:	bbafc0ef          	jal	800007e0 <panic>

000000008000442a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000442a:	1141                	addi	sp,sp,-16
    8000442c:	e422                	sd	s0,8(sp)
    8000442e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004430:	411c                	lw	a5,0(a0)
    80004432:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004434:	415c                	lw	a5,4(a0)
    80004436:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004438:	04451783          	lh	a5,68(a0)
    8000443c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004440:	04a51783          	lh	a5,74(a0)
    80004444:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004448:	04c56783          	lwu	a5,76(a0)
    8000444c:	e99c                	sd	a5,16(a1)
}
    8000444e:	6422                	ld	s0,8(sp)
    80004450:	0141                	addi	sp,sp,16
    80004452:	8082                	ret

0000000080004454 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004454:	457c                	lw	a5,76(a0)
    80004456:	0ed7eb63          	bltu	a5,a3,8000454c <readi+0xf8>
{
    8000445a:	7159                	addi	sp,sp,-112
    8000445c:	f486                	sd	ra,104(sp)
    8000445e:	f0a2                	sd	s0,96(sp)
    80004460:	eca6                	sd	s1,88(sp)
    80004462:	e0d2                	sd	s4,64(sp)
    80004464:	fc56                	sd	s5,56(sp)
    80004466:	f85a                	sd	s6,48(sp)
    80004468:	f45e                	sd	s7,40(sp)
    8000446a:	1880                	addi	s0,sp,112
    8000446c:	8b2a                	mv	s6,a0
    8000446e:	8bae                	mv	s7,a1
    80004470:	8a32                	mv	s4,a2
    80004472:	84b6                	mv	s1,a3
    80004474:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004476:	9f35                	addw	a4,a4,a3
    return 0;
    80004478:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000447a:	0cd76063          	bltu	a4,a3,8000453a <readi+0xe6>
    8000447e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80004480:	00e7f463          	bgeu	a5,a4,80004488 <readi+0x34>
    n = ip->size - off;
    80004484:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004488:	080a8f63          	beqz	s5,80004526 <readi+0xd2>
    8000448c:	e8ca                	sd	s2,80(sp)
    8000448e:	f062                	sd	s8,32(sp)
    80004490:	ec66                	sd	s9,24(sp)
    80004492:	e86a                	sd	s10,16(sp)
    80004494:	e46e                	sd	s11,8(sp)
    80004496:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004498:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000449c:	5c7d                	li	s8,-1
    8000449e:	a80d                	j	800044d0 <readi+0x7c>
    800044a0:	020d1d93          	slli	s11,s10,0x20
    800044a4:	020ddd93          	srli	s11,s11,0x20
    800044a8:	05890613          	addi	a2,s2,88
    800044ac:	86ee                	mv	a3,s11
    800044ae:	963a                	add	a2,a2,a4
    800044b0:	85d2                	mv	a1,s4
    800044b2:	855e                	mv	a0,s7
    800044b4:	ee6fe0ef          	jal	80002b9a <either_copyout>
    800044b8:	05850763          	beq	a0,s8,80004506 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800044bc:	854a                	mv	a0,s2
    800044be:	e42ff0ef          	jal	80003b00 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800044c2:	013d09bb          	addw	s3,s10,s3
    800044c6:	009d04bb          	addw	s1,s10,s1
    800044ca:	9a6e                	add	s4,s4,s11
    800044cc:	0559f763          	bgeu	s3,s5,8000451a <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800044d0:	00a4d59b          	srliw	a1,s1,0xa
    800044d4:	855a                	mv	a0,s6
    800044d6:	8a7ff0ef          	jal	80003d7c <bmap>
    800044da:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800044de:	c5b1                	beqz	a1,8000452a <readi+0xd6>
    bp = bread(ip->dev, addr);
    800044e0:	000b2503          	lw	a0,0(s6)
    800044e4:	d14ff0ef          	jal	800039f8 <bread>
    800044e8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800044ea:	3ff4f713          	andi	a4,s1,1023
    800044ee:	40ec87bb          	subw	a5,s9,a4
    800044f2:	413a86bb          	subw	a3,s5,s3
    800044f6:	8d3e                	mv	s10,a5
    800044f8:	2781                	sext.w	a5,a5
    800044fa:	0006861b          	sext.w	a2,a3
    800044fe:	faf671e3          	bgeu	a2,a5,800044a0 <readi+0x4c>
    80004502:	8d36                	mv	s10,a3
    80004504:	bf71                	j	800044a0 <readi+0x4c>
      brelse(bp);
    80004506:	854a                	mv	a0,s2
    80004508:	df8ff0ef          	jal	80003b00 <brelse>
      tot = -1;
    8000450c:	59fd                	li	s3,-1
      break;
    8000450e:	6946                	ld	s2,80(sp)
    80004510:	7c02                	ld	s8,32(sp)
    80004512:	6ce2                	ld	s9,24(sp)
    80004514:	6d42                	ld	s10,16(sp)
    80004516:	6da2                	ld	s11,8(sp)
    80004518:	a831                	j	80004534 <readi+0xe0>
    8000451a:	6946                	ld	s2,80(sp)
    8000451c:	7c02                	ld	s8,32(sp)
    8000451e:	6ce2                	ld	s9,24(sp)
    80004520:	6d42                	ld	s10,16(sp)
    80004522:	6da2                	ld	s11,8(sp)
    80004524:	a801                	j	80004534 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004526:	89d6                	mv	s3,s5
    80004528:	a031                	j	80004534 <readi+0xe0>
    8000452a:	6946                	ld	s2,80(sp)
    8000452c:	7c02                	ld	s8,32(sp)
    8000452e:	6ce2                	ld	s9,24(sp)
    80004530:	6d42                	ld	s10,16(sp)
    80004532:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80004534:	0009851b          	sext.w	a0,s3
    80004538:	69a6                	ld	s3,72(sp)
}
    8000453a:	70a6                	ld	ra,104(sp)
    8000453c:	7406                	ld	s0,96(sp)
    8000453e:	64e6                	ld	s1,88(sp)
    80004540:	6a06                	ld	s4,64(sp)
    80004542:	7ae2                	ld	s5,56(sp)
    80004544:	7b42                	ld	s6,48(sp)
    80004546:	7ba2                	ld	s7,40(sp)
    80004548:	6165                	addi	sp,sp,112
    8000454a:	8082                	ret
    return 0;
    8000454c:	4501                	li	a0,0
}
    8000454e:	8082                	ret

0000000080004550 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004550:	457c                	lw	a5,76(a0)
    80004552:	10d7e063          	bltu	a5,a3,80004652 <writei+0x102>
{
    80004556:	7159                	addi	sp,sp,-112
    80004558:	f486                	sd	ra,104(sp)
    8000455a:	f0a2                	sd	s0,96(sp)
    8000455c:	e8ca                	sd	s2,80(sp)
    8000455e:	e0d2                	sd	s4,64(sp)
    80004560:	fc56                	sd	s5,56(sp)
    80004562:	f85a                	sd	s6,48(sp)
    80004564:	f45e                	sd	s7,40(sp)
    80004566:	1880                	addi	s0,sp,112
    80004568:	8aaa                	mv	s5,a0
    8000456a:	8bae                	mv	s7,a1
    8000456c:	8a32                	mv	s4,a2
    8000456e:	8936                	mv	s2,a3
    80004570:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004572:	00e687bb          	addw	a5,a3,a4
    80004576:	0ed7e063          	bltu	a5,a3,80004656 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000457a:	00043737          	lui	a4,0x43
    8000457e:	0cf76e63          	bltu	a4,a5,8000465a <writei+0x10a>
    80004582:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004584:	0a0b0f63          	beqz	s6,80004642 <writei+0xf2>
    80004588:	eca6                	sd	s1,88(sp)
    8000458a:	f062                	sd	s8,32(sp)
    8000458c:	ec66                	sd	s9,24(sp)
    8000458e:	e86a                	sd	s10,16(sp)
    80004590:	e46e                	sd	s11,8(sp)
    80004592:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004594:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004598:	5c7d                	li	s8,-1
    8000459a:	a825                	j	800045d2 <writei+0x82>
    8000459c:	020d1d93          	slli	s11,s10,0x20
    800045a0:	020ddd93          	srli	s11,s11,0x20
    800045a4:	05848513          	addi	a0,s1,88
    800045a8:	86ee                	mv	a3,s11
    800045aa:	8652                	mv	a2,s4
    800045ac:	85de                	mv	a1,s7
    800045ae:	953a                	add	a0,a0,a4
    800045b0:	e34fe0ef          	jal	80002be4 <either_copyin>
    800045b4:	05850a63          	beq	a0,s8,80004608 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800045b8:	8526                	mv	a0,s1
    800045ba:	678000ef          	jal	80004c32 <log_write>
    brelse(bp);
    800045be:	8526                	mv	a0,s1
    800045c0:	d40ff0ef          	jal	80003b00 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800045c4:	013d09bb          	addw	s3,s10,s3
    800045c8:	012d093b          	addw	s2,s10,s2
    800045cc:	9a6e                	add	s4,s4,s11
    800045ce:	0569f063          	bgeu	s3,s6,8000460e <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800045d2:	00a9559b          	srliw	a1,s2,0xa
    800045d6:	8556                	mv	a0,s5
    800045d8:	fa4ff0ef          	jal	80003d7c <bmap>
    800045dc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800045e0:	c59d                	beqz	a1,8000460e <writei+0xbe>
    bp = bread(ip->dev, addr);
    800045e2:	000aa503          	lw	a0,0(s5)
    800045e6:	c12ff0ef          	jal	800039f8 <bread>
    800045ea:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800045ec:	3ff97713          	andi	a4,s2,1023
    800045f0:	40ec87bb          	subw	a5,s9,a4
    800045f4:	413b06bb          	subw	a3,s6,s3
    800045f8:	8d3e                	mv	s10,a5
    800045fa:	2781                	sext.w	a5,a5
    800045fc:	0006861b          	sext.w	a2,a3
    80004600:	f8f67ee3          	bgeu	a2,a5,8000459c <writei+0x4c>
    80004604:	8d36                	mv	s10,a3
    80004606:	bf59                	j	8000459c <writei+0x4c>
      brelse(bp);
    80004608:	8526                	mv	a0,s1
    8000460a:	cf6ff0ef          	jal	80003b00 <brelse>
  }

  if(off > ip->size)
    8000460e:	04caa783          	lw	a5,76(s5)
    80004612:	0327fa63          	bgeu	a5,s2,80004646 <writei+0xf6>
    ip->size = off;
    80004616:	052aa623          	sw	s2,76(s5)
    8000461a:	64e6                	ld	s1,88(sp)
    8000461c:	7c02                	ld	s8,32(sp)
    8000461e:	6ce2                	ld	s9,24(sp)
    80004620:	6d42                	ld	s10,16(sp)
    80004622:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004624:	8556                	mv	a0,s5
    80004626:	9ebff0ef          	jal	80004010 <iupdate>

  return tot;
    8000462a:	0009851b          	sext.w	a0,s3
    8000462e:	69a6                	ld	s3,72(sp)
}
    80004630:	70a6                	ld	ra,104(sp)
    80004632:	7406                	ld	s0,96(sp)
    80004634:	6946                	ld	s2,80(sp)
    80004636:	6a06                	ld	s4,64(sp)
    80004638:	7ae2                	ld	s5,56(sp)
    8000463a:	7b42                	ld	s6,48(sp)
    8000463c:	7ba2                	ld	s7,40(sp)
    8000463e:	6165                	addi	sp,sp,112
    80004640:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004642:	89da                	mv	s3,s6
    80004644:	b7c5                	j	80004624 <writei+0xd4>
    80004646:	64e6                	ld	s1,88(sp)
    80004648:	7c02                	ld	s8,32(sp)
    8000464a:	6ce2                	ld	s9,24(sp)
    8000464c:	6d42                	ld	s10,16(sp)
    8000464e:	6da2                	ld	s11,8(sp)
    80004650:	bfd1                	j	80004624 <writei+0xd4>
    return -1;
    80004652:	557d                	li	a0,-1
}
    80004654:	8082                	ret
    return -1;
    80004656:	557d                	li	a0,-1
    80004658:	bfe1                	j	80004630 <writei+0xe0>
    return -1;
    8000465a:	557d                	li	a0,-1
    8000465c:	bfd1                	j	80004630 <writei+0xe0>

000000008000465e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000465e:	1141                	addi	sp,sp,-16
    80004660:	e406                	sd	ra,8(sp)
    80004662:	e022                	sd	s0,0(sp)
    80004664:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004666:	4639                	li	a2,14
    80004668:	f06fc0ef          	jal	80000d6e <strncmp>
}
    8000466c:	60a2                	ld	ra,8(sp)
    8000466e:	6402                	ld	s0,0(sp)
    80004670:	0141                	addi	sp,sp,16
    80004672:	8082                	ret

0000000080004674 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004674:	7139                	addi	sp,sp,-64
    80004676:	fc06                	sd	ra,56(sp)
    80004678:	f822                	sd	s0,48(sp)
    8000467a:	f426                	sd	s1,40(sp)
    8000467c:	f04a                	sd	s2,32(sp)
    8000467e:	ec4e                	sd	s3,24(sp)
    80004680:	e852                	sd	s4,16(sp)
    80004682:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004684:	04451703          	lh	a4,68(a0)
    80004688:	4785                	li	a5,1
    8000468a:	00f71a63          	bne	a4,a5,8000469e <dirlookup+0x2a>
    8000468e:	892a                	mv	s2,a0
    80004690:	89ae                	mv	s3,a1
    80004692:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004694:	457c                	lw	a5,76(a0)
    80004696:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004698:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000469a:	e39d                	bnez	a5,800046c0 <dirlookup+0x4c>
    8000469c:	a095                	j	80004700 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000469e:	00004517          	auipc	a0,0x4
    800046a2:	f4a50513          	addi	a0,a0,-182 # 800085e8 <etext+0x5e8>
    800046a6:	93afc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    800046aa:	00004517          	auipc	a0,0x4
    800046ae:	f5650513          	addi	a0,a0,-170 # 80008600 <etext+0x600>
    800046b2:	92efc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046b6:	24c1                	addiw	s1,s1,16
    800046b8:	04c92783          	lw	a5,76(s2)
    800046bc:	04f4f163          	bgeu	s1,a5,800046fe <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046c0:	4741                	li	a4,16
    800046c2:	86a6                	mv	a3,s1
    800046c4:	fc040613          	addi	a2,s0,-64
    800046c8:	4581                	li	a1,0
    800046ca:	854a                	mv	a0,s2
    800046cc:	d89ff0ef          	jal	80004454 <readi>
    800046d0:	47c1                	li	a5,16
    800046d2:	fcf51ce3          	bne	a0,a5,800046aa <dirlookup+0x36>
    if(de.inum == 0)
    800046d6:	fc045783          	lhu	a5,-64(s0)
    800046da:	dff1                	beqz	a5,800046b6 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800046dc:	fc240593          	addi	a1,s0,-62
    800046e0:	854e                	mv	a0,s3
    800046e2:	f7dff0ef          	jal	8000465e <namecmp>
    800046e6:	f961                	bnez	a0,800046b6 <dirlookup+0x42>
      if(poff)
    800046e8:	000a0463          	beqz	s4,800046f0 <dirlookup+0x7c>
        *poff = off;
    800046ec:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800046f0:	fc045583          	lhu	a1,-64(s0)
    800046f4:	00092503          	lw	a0,0(s2)
    800046f8:	f58ff0ef          	jal	80003e50 <iget>
    800046fc:	a011                	j	80004700 <dirlookup+0x8c>
  return 0;
    800046fe:	4501                	li	a0,0
}
    80004700:	70e2                	ld	ra,56(sp)
    80004702:	7442                	ld	s0,48(sp)
    80004704:	74a2                	ld	s1,40(sp)
    80004706:	7902                	ld	s2,32(sp)
    80004708:	69e2                	ld	s3,24(sp)
    8000470a:	6a42                	ld	s4,16(sp)
    8000470c:	6121                	addi	sp,sp,64
    8000470e:	8082                	ret

0000000080004710 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004710:	711d                	addi	sp,sp,-96
    80004712:	ec86                	sd	ra,88(sp)
    80004714:	e8a2                	sd	s0,80(sp)
    80004716:	e4a6                	sd	s1,72(sp)
    80004718:	e0ca                	sd	s2,64(sp)
    8000471a:	fc4e                	sd	s3,56(sp)
    8000471c:	f852                	sd	s4,48(sp)
    8000471e:	f456                	sd	s5,40(sp)
    80004720:	f05a                	sd	s6,32(sp)
    80004722:	ec5e                	sd	s7,24(sp)
    80004724:	e862                	sd	s8,16(sp)
    80004726:	e466                	sd	s9,8(sp)
    80004728:	1080                	addi	s0,sp,96
    8000472a:	84aa                	mv	s1,a0
    8000472c:	8b2e                	mv	s6,a1
    8000472e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004730:	00054703          	lbu	a4,0(a0)
    80004734:	02f00793          	li	a5,47
    80004738:	00f70e63          	beq	a4,a5,80004754 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000473c:	abafd0ef          	jal	800019f6 <myproc>
    80004740:	15853503          	ld	a0,344(a0)
    80004744:	94bff0ef          	jal	8000408e <idup>
    80004748:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000474a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000474e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004750:	4b85                	li	s7,1
    80004752:	a871                	j	800047ee <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80004754:	4585                	li	a1,1
    80004756:	4505                	li	a0,1
    80004758:	ef8ff0ef          	jal	80003e50 <iget>
    8000475c:	8a2a                	mv	s4,a0
    8000475e:	b7f5                	j	8000474a <namex+0x3a>
      iunlockput(ip);
    80004760:	8552                	mv	a0,s4
    80004762:	b6dff0ef          	jal	800042ce <iunlockput>
      return 0;
    80004766:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004768:	8552                	mv	a0,s4
    8000476a:	60e6                	ld	ra,88(sp)
    8000476c:	6446                	ld	s0,80(sp)
    8000476e:	64a6                	ld	s1,72(sp)
    80004770:	6906                	ld	s2,64(sp)
    80004772:	79e2                	ld	s3,56(sp)
    80004774:	7a42                	ld	s4,48(sp)
    80004776:	7aa2                	ld	s5,40(sp)
    80004778:	7b02                	ld	s6,32(sp)
    8000477a:	6be2                	ld	s7,24(sp)
    8000477c:	6c42                	ld	s8,16(sp)
    8000477e:	6ca2                	ld	s9,8(sp)
    80004780:	6125                	addi	sp,sp,96
    80004782:	8082                	ret
      iunlock(ip);
    80004784:	8552                	mv	a0,s4
    80004786:	9edff0ef          	jal	80004172 <iunlock>
      return ip;
    8000478a:	bff9                	j	80004768 <namex+0x58>
      iunlockput(ip);
    8000478c:	8552                	mv	a0,s4
    8000478e:	b41ff0ef          	jal	800042ce <iunlockput>
      return 0;
    80004792:	8a4e                	mv	s4,s3
    80004794:	bfd1                	j	80004768 <namex+0x58>
  len = path - s;
    80004796:	40998633          	sub	a2,s3,s1
    8000479a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000479e:	099c5063          	bge	s8,s9,8000481e <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800047a2:	4639                	li	a2,14
    800047a4:	85a6                	mv	a1,s1
    800047a6:	8556                	mv	a0,s5
    800047a8:	d56fc0ef          	jal	80000cfe <memmove>
    800047ac:	84ce                	mv	s1,s3
  while(*path == '/')
    800047ae:	0004c783          	lbu	a5,0(s1)
    800047b2:	01279763          	bne	a5,s2,800047c0 <namex+0xb0>
    path++;
    800047b6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800047b8:	0004c783          	lbu	a5,0(s1)
    800047bc:	ff278de3          	beq	a5,s2,800047b6 <namex+0xa6>
    ilock(ip);
    800047c0:	8552                	mv	a0,s4
    800047c2:	903ff0ef          	jal	800040c4 <ilock>
    if(ip->type != T_DIR){
    800047c6:	044a1783          	lh	a5,68(s4)
    800047ca:	f9779be3          	bne	a5,s7,80004760 <namex+0x50>
    if(nameiparent && *path == '\0'){
    800047ce:	000b0563          	beqz	s6,800047d8 <namex+0xc8>
    800047d2:	0004c783          	lbu	a5,0(s1)
    800047d6:	d7dd                	beqz	a5,80004784 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800047d8:	4601                	li	a2,0
    800047da:	85d6                	mv	a1,s5
    800047dc:	8552                	mv	a0,s4
    800047de:	e97ff0ef          	jal	80004674 <dirlookup>
    800047e2:	89aa                	mv	s3,a0
    800047e4:	d545                	beqz	a0,8000478c <namex+0x7c>
    iunlockput(ip);
    800047e6:	8552                	mv	a0,s4
    800047e8:	ae7ff0ef          	jal	800042ce <iunlockput>
    ip = next;
    800047ec:	8a4e                	mv	s4,s3
  while(*path == '/')
    800047ee:	0004c783          	lbu	a5,0(s1)
    800047f2:	01279763          	bne	a5,s2,80004800 <namex+0xf0>
    path++;
    800047f6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800047f8:	0004c783          	lbu	a5,0(s1)
    800047fc:	ff278de3          	beq	a5,s2,800047f6 <namex+0xe6>
  if(*path == 0)
    80004800:	cb8d                	beqz	a5,80004832 <namex+0x122>
  while(*path != '/' && *path != 0)
    80004802:	0004c783          	lbu	a5,0(s1)
    80004806:	89a6                	mv	s3,s1
  len = path - s;
    80004808:	4c81                	li	s9,0
    8000480a:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000480c:	01278963          	beq	a5,s2,8000481e <namex+0x10e>
    80004810:	d3d9                	beqz	a5,80004796 <namex+0x86>
    path++;
    80004812:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004814:	0009c783          	lbu	a5,0(s3)
    80004818:	ff279ce3          	bne	a5,s2,80004810 <namex+0x100>
    8000481c:	bfad                	j	80004796 <namex+0x86>
    memmove(name, s, len);
    8000481e:	2601                	sext.w	a2,a2
    80004820:	85a6                	mv	a1,s1
    80004822:	8556                	mv	a0,s5
    80004824:	cdafc0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80004828:	9cd6                	add	s9,s9,s5
    8000482a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000482e:	84ce                	mv	s1,s3
    80004830:	bfbd                	j	800047ae <namex+0x9e>
  if(nameiparent){
    80004832:	f20b0be3          	beqz	s6,80004768 <namex+0x58>
    iput(ip);
    80004836:	8552                	mv	a0,s4
    80004838:	a0fff0ef          	jal	80004246 <iput>
    return 0;
    8000483c:	4a01                	li	s4,0
    8000483e:	b72d                	j	80004768 <namex+0x58>

0000000080004840 <dirlink>:
{
    80004840:	7139                	addi	sp,sp,-64
    80004842:	fc06                	sd	ra,56(sp)
    80004844:	f822                	sd	s0,48(sp)
    80004846:	f04a                	sd	s2,32(sp)
    80004848:	ec4e                	sd	s3,24(sp)
    8000484a:	e852                	sd	s4,16(sp)
    8000484c:	0080                	addi	s0,sp,64
    8000484e:	892a                	mv	s2,a0
    80004850:	8a2e                	mv	s4,a1
    80004852:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004854:	4601                	li	a2,0
    80004856:	e1fff0ef          	jal	80004674 <dirlookup>
    8000485a:	e535                	bnez	a0,800048c6 <dirlink+0x86>
    8000485c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000485e:	04c92483          	lw	s1,76(s2)
    80004862:	c48d                	beqz	s1,8000488c <dirlink+0x4c>
    80004864:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004866:	4741                	li	a4,16
    80004868:	86a6                	mv	a3,s1
    8000486a:	fc040613          	addi	a2,s0,-64
    8000486e:	4581                	li	a1,0
    80004870:	854a                	mv	a0,s2
    80004872:	be3ff0ef          	jal	80004454 <readi>
    80004876:	47c1                	li	a5,16
    80004878:	04f51b63          	bne	a0,a5,800048ce <dirlink+0x8e>
    if(de.inum == 0)
    8000487c:	fc045783          	lhu	a5,-64(s0)
    80004880:	c791                	beqz	a5,8000488c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004882:	24c1                	addiw	s1,s1,16
    80004884:	04c92783          	lw	a5,76(s2)
    80004888:	fcf4efe3          	bltu	s1,a5,80004866 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    8000488c:	4639                	li	a2,14
    8000488e:	85d2                	mv	a1,s4
    80004890:	fc240513          	addi	a0,s0,-62
    80004894:	d10fc0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80004898:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000489c:	4741                	li	a4,16
    8000489e:	86a6                	mv	a3,s1
    800048a0:	fc040613          	addi	a2,s0,-64
    800048a4:	4581                	li	a1,0
    800048a6:	854a                	mv	a0,s2
    800048a8:	ca9ff0ef          	jal	80004550 <writei>
    800048ac:	1541                	addi	a0,a0,-16
    800048ae:	00a03533          	snez	a0,a0
    800048b2:	40a00533          	neg	a0,a0
    800048b6:	74a2                	ld	s1,40(sp)
}
    800048b8:	70e2                	ld	ra,56(sp)
    800048ba:	7442                	ld	s0,48(sp)
    800048bc:	7902                	ld	s2,32(sp)
    800048be:	69e2                	ld	s3,24(sp)
    800048c0:	6a42                	ld	s4,16(sp)
    800048c2:	6121                	addi	sp,sp,64
    800048c4:	8082                	ret
    iput(ip);
    800048c6:	981ff0ef          	jal	80004246 <iput>
    return -1;
    800048ca:	557d                	li	a0,-1
    800048cc:	b7f5                	j	800048b8 <dirlink+0x78>
      panic("dirlink read");
    800048ce:	00004517          	auipc	a0,0x4
    800048d2:	d4250513          	addi	a0,a0,-702 # 80008610 <etext+0x610>
    800048d6:	f0bfb0ef          	jal	800007e0 <panic>

00000000800048da <namei>:

struct inode*
namei(char *path)
{
    800048da:	1101                	addi	sp,sp,-32
    800048dc:	ec06                	sd	ra,24(sp)
    800048de:	e822                	sd	s0,16(sp)
    800048e0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800048e2:	fe040613          	addi	a2,s0,-32
    800048e6:	4581                	li	a1,0
    800048e8:	e29ff0ef          	jal	80004710 <namex>
}
    800048ec:	60e2                	ld	ra,24(sp)
    800048ee:	6442                	ld	s0,16(sp)
    800048f0:	6105                	addi	sp,sp,32
    800048f2:	8082                	ret

00000000800048f4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800048f4:	1141                	addi	sp,sp,-16
    800048f6:	e406                	sd	ra,8(sp)
    800048f8:	e022                	sd	s0,0(sp)
    800048fa:	0800                	addi	s0,sp,16
    800048fc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800048fe:	4585                	li	a1,1
    80004900:	e11ff0ef          	jal	80004710 <namex>
}
    80004904:	60a2                	ld	ra,8(sp)
    80004906:	6402                	ld	s0,0(sp)
    80004908:	0141                	addi	sp,sp,16
    8000490a:	8082                	ret

000000008000490c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000490c:	1101                	addi	sp,sp,-32
    8000490e:	ec06                	sd	ra,24(sp)
    80004910:	e822                	sd	s0,16(sp)
    80004912:	e426                	sd	s1,8(sp)
    80004914:	e04a                	sd	s2,0(sp)
    80004916:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004918:	00020917          	auipc	s2,0x20
    8000491c:	a9090913          	addi	s2,s2,-1392 # 800243a8 <log>
    80004920:	01892583          	lw	a1,24(s2)
    80004924:	02492503          	lw	a0,36(s2)
    80004928:	8d0ff0ef          	jal	800039f8 <bread>
    8000492c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000492e:	02892603          	lw	a2,40(s2)
    80004932:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004934:	00c05f63          	blez	a2,80004952 <write_head+0x46>
    80004938:	00020717          	auipc	a4,0x20
    8000493c:	a9c70713          	addi	a4,a4,-1380 # 800243d4 <log+0x2c>
    80004940:	87aa                	mv	a5,a0
    80004942:	060a                	slli	a2,a2,0x2
    80004944:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004946:	4314                	lw	a3,0(a4)
    80004948:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000494a:	0711                	addi	a4,a4,4
    8000494c:	0791                	addi	a5,a5,4
    8000494e:	fec79ce3          	bne	a5,a2,80004946 <write_head+0x3a>
  }
  bwrite(buf);
    80004952:	8526                	mv	a0,s1
    80004954:	97aff0ef          	jal	80003ace <bwrite>
  brelse(buf);
    80004958:	8526                	mv	a0,s1
    8000495a:	9a6ff0ef          	jal	80003b00 <brelse>
}
    8000495e:	60e2                	ld	ra,24(sp)
    80004960:	6442                	ld	s0,16(sp)
    80004962:	64a2                	ld	s1,8(sp)
    80004964:	6902                	ld	s2,0(sp)
    80004966:	6105                	addi	sp,sp,32
    80004968:	8082                	ret

000000008000496a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000496a:	00020797          	auipc	a5,0x20
    8000496e:	a667a783          	lw	a5,-1434(a5) # 800243d0 <log+0x28>
    80004972:	0af05e63          	blez	a5,80004a2e <install_trans+0xc4>
{
    80004976:	715d                	addi	sp,sp,-80
    80004978:	e486                	sd	ra,72(sp)
    8000497a:	e0a2                	sd	s0,64(sp)
    8000497c:	fc26                	sd	s1,56(sp)
    8000497e:	f84a                	sd	s2,48(sp)
    80004980:	f44e                	sd	s3,40(sp)
    80004982:	f052                	sd	s4,32(sp)
    80004984:	ec56                	sd	s5,24(sp)
    80004986:	e85a                	sd	s6,16(sp)
    80004988:	e45e                	sd	s7,8(sp)
    8000498a:	0880                	addi	s0,sp,80
    8000498c:	8b2a                	mv	s6,a0
    8000498e:	00020a97          	auipc	s5,0x20
    80004992:	a46a8a93          	addi	s5,s5,-1466 # 800243d4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004996:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004998:	00004b97          	auipc	s7,0x4
    8000499c:	c88b8b93          	addi	s7,s7,-888 # 80008620 <etext+0x620>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800049a0:	00020a17          	auipc	s4,0x20
    800049a4:	a08a0a13          	addi	s4,s4,-1528 # 800243a8 <log>
    800049a8:	a025                	j	800049d0 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800049aa:	000aa603          	lw	a2,0(s5)
    800049ae:	85ce                	mv	a1,s3
    800049b0:	855e                	mv	a0,s7
    800049b2:	b49fb0ef          	jal	800004fa <printf>
    800049b6:	a839                	j	800049d4 <install_trans+0x6a>
    brelse(lbuf);
    800049b8:	854a                	mv	a0,s2
    800049ba:	946ff0ef          	jal	80003b00 <brelse>
    brelse(dbuf);
    800049be:	8526                	mv	a0,s1
    800049c0:	940ff0ef          	jal	80003b00 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049c4:	2985                	addiw	s3,s3,1
    800049c6:	0a91                	addi	s5,s5,4
    800049c8:	028a2783          	lw	a5,40(s4)
    800049cc:	04f9d663          	bge	s3,a5,80004a18 <install_trans+0xae>
    if(recovering) {
    800049d0:	fc0b1de3          	bnez	s6,800049aa <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800049d4:	018a2583          	lw	a1,24(s4)
    800049d8:	013585bb          	addw	a1,a1,s3
    800049dc:	2585                	addiw	a1,a1,1
    800049de:	024a2503          	lw	a0,36(s4)
    800049e2:	816ff0ef          	jal	800039f8 <bread>
    800049e6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800049e8:	000aa583          	lw	a1,0(s5)
    800049ec:	024a2503          	lw	a0,36(s4)
    800049f0:	808ff0ef          	jal	800039f8 <bread>
    800049f4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800049f6:	40000613          	li	a2,1024
    800049fa:	05890593          	addi	a1,s2,88
    800049fe:	05850513          	addi	a0,a0,88
    80004a02:	afcfc0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80004a06:	8526                	mv	a0,s1
    80004a08:	8c6ff0ef          	jal	80003ace <bwrite>
    if(recovering == 0)
    80004a0c:	fa0b16e3          	bnez	s6,800049b8 <install_trans+0x4e>
      bunpin(dbuf);
    80004a10:	8526                	mv	a0,s1
    80004a12:	9aaff0ef          	jal	80003bbc <bunpin>
    80004a16:	b74d                	j	800049b8 <install_trans+0x4e>
}
    80004a18:	60a6                	ld	ra,72(sp)
    80004a1a:	6406                	ld	s0,64(sp)
    80004a1c:	74e2                	ld	s1,56(sp)
    80004a1e:	7942                	ld	s2,48(sp)
    80004a20:	79a2                	ld	s3,40(sp)
    80004a22:	7a02                	ld	s4,32(sp)
    80004a24:	6ae2                	ld	s5,24(sp)
    80004a26:	6b42                	ld	s6,16(sp)
    80004a28:	6ba2                	ld	s7,8(sp)
    80004a2a:	6161                	addi	sp,sp,80
    80004a2c:	8082                	ret
    80004a2e:	8082                	ret

0000000080004a30 <initlog>:
{
    80004a30:	7179                	addi	sp,sp,-48
    80004a32:	f406                	sd	ra,40(sp)
    80004a34:	f022                	sd	s0,32(sp)
    80004a36:	ec26                	sd	s1,24(sp)
    80004a38:	e84a                	sd	s2,16(sp)
    80004a3a:	e44e                	sd	s3,8(sp)
    80004a3c:	1800                	addi	s0,sp,48
    80004a3e:	892a                	mv	s2,a0
    80004a40:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004a42:	00020497          	auipc	s1,0x20
    80004a46:	96648493          	addi	s1,s1,-1690 # 800243a8 <log>
    80004a4a:	00004597          	auipc	a1,0x4
    80004a4e:	bf658593          	addi	a1,a1,-1034 # 80008640 <etext+0x640>
    80004a52:	8526                	mv	a0,s1
    80004a54:	8fafc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80004a58:	0149a583          	lw	a1,20(s3)
    80004a5c:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004a5e:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004a62:	854a                	mv	a0,s2
    80004a64:	f95fe0ef          	jal	800039f8 <bread>
  log.lh.n = lh->n;
    80004a68:	4d30                	lw	a2,88(a0)
    80004a6a:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004a6c:	00c05f63          	blez	a2,80004a8a <initlog+0x5a>
    80004a70:	87aa                	mv	a5,a0
    80004a72:	00020717          	auipc	a4,0x20
    80004a76:	96270713          	addi	a4,a4,-1694 # 800243d4 <log+0x2c>
    80004a7a:	060a                	slli	a2,a2,0x2
    80004a7c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004a7e:	4ff4                	lw	a3,92(a5)
    80004a80:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004a82:	0791                	addi	a5,a5,4
    80004a84:	0711                	addi	a4,a4,4
    80004a86:	fec79ce3          	bne	a5,a2,80004a7e <initlog+0x4e>
  brelse(buf);
    80004a8a:	876ff0ef          	jal	80003b00 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004a8e:	4505                	li	a0,1
    80004a90:	edbff0ef          	jal	8000496a <install_trans>
  log.lh.n = 0;
    80004a94:	00020797          	auipc	a5,0x20
    80004a98:	9207ae23          	sw	zero,-1732(a5) # 800243d0 <log+0x28>
  write_head(); // clear the log
    80004a9c:	e71ff0ef          	jal	8000490c <write_head>
}
    80004aa0:	70a2                	ld	ra,40(sp)
    80004aa2:	7402                	ld	s0,32(sp)
    80004aa4:	64e2                	ld	s1,24(sp)
    80004aa6:	6942                	ld	s2,16(sp)
    80004aa8:	69a2                	ld	s3,8(sp)
    80004aaa:	6145                	addi	sp,sp,48
    80004aac:	8082                	ret

0000000080004aae <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004aae:	1101                	addi	sp,sp,-32
    80004ab0:	ec06                	sd	ra,24(sp)
    80004ab2:	e822                	sd	s0,16(sp)
    80004ab4:	e426                	sd	s1,8(sp)
    80004ab6:	e04a                	sd	s2,0(sp)
    80004ab8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004aba:	00020517          	auipc	a0,0x20
    80004abe:	8ee50513          	addi	a0,a0,-1810 # 800243a8 <log>
    80004ac2:	90cfc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80004ac6:	00020497          	auipc	s1,0x20
    80004aca:	8e248493          	addi	s1,s1,-1822 # 800243a8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004ace:	4979                	li	s2,30
    80004ad0:	a029                	j	80004ada <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004ad2:	85a6                	mv	a1,s1
    80004ad4:	8526                	mv	a0,s1
    80004ad6:	afbfd0ef          	jal	800025d0 <sleep>
    if(log.committing){
    80004ada:	509c                	lw	a5,32(s1)
    80004adc:	fbfd                	bnez	a5,80004ad2 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004ade:	4cd8                	lw	a4,28(s1)
    80004ae0:	2705                	addiw	a4,a4,1
    80004ae2:	0027179b          	slliw	a5,a4,0x2
    80004ae6:	9fb9                	addw	a5,a5,a4
    80004ae8:	0017979b          	slliw	a5,a5,0x1
    80004aec:	5494                	lw	a3,40(s1)
    80004aee:	9fb5                	addw	a5,a5,a3
    80004af0:	00f95763          	bge	s2,a5,80004afe <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004af4:	85a6                	mv	a1,s1
    80004af6:	8526                	mv	a0,s1
    80004af8:	ad9fd0ef          	jal	800025d0 <sleep>
    80004afc:	bff9                	j	80004ada <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004afe:	00020517          	auipc	a0,0x20
    80004b02:	8aa50513          	addi	a0,a0,-1878 # 800243a8 <log>
    80004b06:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80004b08:	95efc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80004b0c:	60e2                	ld	ra,24(sp)
    80004b0e:	6442                	ld	s0,16(sp)
    80004b10:	64a2                	ld	s1,8(sp)
    80004b12:	6902                	ld	s2,0(sp)
    80004b14:	6105                	addi	sp,sp,32
    80004b16:	8082                	ret

0000000080004b18 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004b18:	7139                	addi	sp,sp,-64
    80004b1a:	fc06                	sd	ra,56(sp)
    80004b1c:	f822                	sd	s0,48(sp)
    80004b1e:	f426                	sd	s1,40(sp)
    80004b20:	f04a                	sd	s2,32(sp)
    80004b22:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004b24:	00020497          	auipc	s1,0x20
    80004b28:	88448493          	addi	s1,s1,-1916 # 800243a8 <log>
    80004b2c:	8526                	mv	a0,s1
    80004b2e:	8a0fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80004b32:	4cdc                	lw	a5,28(s1)
    80004b34:	37fd                	addiw	a5,a5,-1
    80004b36:	0007891b          	sext.w	s2,a5
    80004b3a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004b3c:	509c                	lw	a5,32(s1)
    80004b3e:	ef9d                	bnez	a5,80004b7c <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80004b40:	04091763          	bnez	s2,80004b8e <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004b44:	00020497          	auipc	s1,0x20
    80004b48:	86448493          	addi	s1,s1,-1948 # 800243a8 <log>
    80004b4c:	4785                	li	a5,1
    80004b4e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004b50:	8526                	mv	a0,s1
    80004b52:	914fc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004b56:	549c                	lw	a5,40(s1)
    80004b58:	04f04b63          	bgtz	a5,80004bae <end_op+0x96>
    acquire(&log.lock);
    80004b5c:	00020497          	auipc	s1,0x20
    80004b60:	84c48493          	addi	s1,s1,-1972 # 800243a8 <log>
    80004b64:	8526                	mv	a0,s1
    80004b66:	868fc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80004b6a:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004b6e:	8526                	mv	a0,s1
    80004b70:	aadfd0ef          	jal	8000261c <wakeup>
    release(&log.lock);
    80004b74:	8526                	mv	a0,s1
    80004b76:	8f0fc0ef          	jal	80000c66 <release>
}
    80004b7a:	a025                	j	80004ba2 <end_op+0x8a>
    80004b7c:	ec4e                	sd	s3,24(sp)
    80004b7e:	e852                	sd	s4,16(sp)
    80004b80:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004b82:	00004517          	auipc	a0,0x4
    80004b86:	ac650513          	addi	a0,a0,-1338 # 80008648 <etext+0x648>
    80004b8a:	c57fb0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80004b8e:	00020497          	auipc	s1,0x20
    80004b92:	81a48493          	addi	s1,s1,-2022 # 800243a8 <log>
    80004b96:	8526                	mv	a0,s1
    80004b98:	a85fd0ef          	jal	8000261c <wakeup>
  release(&log.lock);
    80004b9c:	8526                	mv	a0,s1
    80004b9e:	8c8fc0ef          	jal	80000c66 <release>
}
    80004ba2:	70e2                	ld	ra,56(sp)
    80004ba4:	7442                	ld	s0,48(sp)
    80004ba6:	74a2                	ld	s1,40(sp)
    80004ba8:	7902                	ld	s2,32(sp)
    80004baa:	6121                	addi	sp,sp,64
    80004bac:	8082                	ret
    80004bae:	ec4e                	sd	s3,24(sp)
    80004bb0:	e852                	sd	s4,16(sp)
    80004bb2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004bb4:	00020a97          	auipc	s5,0x20
    80004bb8:	820a8a93          	addi	s5,s5,-2016 # 800243d4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004bbc:	0001fa17          	auipc	s4,0x1f
    80004bc0:	7eca0a13          	addi	s4,s4,2028 # 800243a8 <log>
    80004bc4:	018a2583          	lw	a1,24(s4)
    80004bc8:	012585bb          	addw	a1,a1,s2
    80004bcc:	2585                	addiw	a1,a1,1
    80004bce:	024a2503          	lw	a0,36(s4)
    80004bd2:	e27fe0ef          	jal	800039f8 <bread>
    80004bd6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004bd8:	000aa583          	lw	a1,0(s5)
    80004bdc:	024a2503          	lw	a0,36(s4)
    80004be0:	e19fe0ef          	jal	800039f8 <bread>
    80004be4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004be6:	40000613          	li	a2,1024
    80004bea:	05850593          	addi	a1,a0,88
    80004bee:	05848513          	addi	a0,s1,88
    80004bf2:	90cfc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	ed7fe0ef          	jal	80003ace <bwrite>
    brelse(from);
    80004bfc:	854e                	mv	a0,s3
    80004bfe:	f03fe0ef          	jal	80003b00 <brelse>
    brelse(to);
    80004c02:	8526                	mv	a0,s1
    80004c04:	efdfe0ef          	jal	80003b00 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c08:	2905                	addiw	s2,s2,1
    80004c0a:	0a91                	addi	s5,s5,4
    80004c0c:	028a2783          	lw	a5,40(s4)
    80004c10:	faf94ae3          	blt	s2,a5,80004bc4 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004c14:	cf9ff0ef          	jal	8000490c <write_head>
    install_trans(0); // Now install writes to home locations
    80004c18:	4501                	li	a0,0
    80004c1a:	d51ff0ef          	jal	8000496a <install_trans>
    log.lh.n = 0;
    80004c1e:	0001f797          	auipc	a5,0x1f
    80004c22:	7a07a923          	sw	zero,1970(a5) # 800243d0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004c26:	ce7ff0ef          	jal	8000490c <write_head>
    80004c2a:	69e2                	ld	s3,24(sp)
    80004c2c:	6a42                	ld	s4,16(sp)
    80004c2e:	6aa2                	ld	s5,8(sp)
    80004c30:	b735                	j	80004b5c <end_op+0x44>

0000000080004c32 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004c32:	1101                	addi	sp,sp,-32
    80004c34:	ec06                	sd	ra,24(sp)
    80004c36:	e822                	sd	s0,16(sp)
    80004c38:	e426                	sd	s1,8(sp)
    80004c3a:	e04a                	sd	s2,0(sp)
    80004c3c:	1000                	addi	s0,sp,32
    80004c3e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004c40:	0001f917          	auipc	s2,0x1f
    80004c44:	76890913          	addi	s2,s2,1896 # 800243a8 <log>
    80004c48:	854a                	mv	a0,s2
    80004c4a:	f85fb0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004c4e:	02892603          	lw	a2,40(s2)
    80004c52:	47f5                	li	a5,29
    80004c54:	04c7cc63          	blt	a5,a2,80004cac <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004c58:	0001f797          	auipc	a5,0x1f
    80004c5c:	76c7a783          	lw	a5,1900(a5) # 800243c4 <log+0x1c>
    80004c60:	04f05c63          	blez	a5,80004cb8 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004c64:	4781                	li	a5,0
    80004c66:	04c05f63          	blez	a2,80004cc4 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004c6a:	44cc                	lw	a1,12(s1)
    80004c6c:	0001f717          	auipc	a4,0x1f
    80004c70:	76870713          	addi	a4,a4,1896 # 800243d4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004c74:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004c76:	4314                	lw	a3,0(a4)
    80004c78:	04b68663          	beq	a3,a1,80004cc4 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004c7c:	2785                	addiw	a5,a5,1
    80004c7e:	0711                	addi	a4,a4,4
    80004c80:	fef61be3          	bne	a2,a5,80004c76 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004c84:	0621                	addi	a2,a2,8
    80004c86:	060a                	slli	a2,a2,0x2
    80004c88:	0001f797          	auipc	a5,0x1f
    80004c8c:	72078793          	addi	a5,a5,1824 # 800243a8 <log>
    80004c90:	97b2                	add	a5,a5,a2
    80004c92:	44d8                	lw	a4,12(s1)
    80004c94:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004c96:	8526                	mv	a0,s1
    80004c98:	ef1fe0ef          	jal	80003b88 <bpin>
    log.lh.n++;
    80004c9c:	0001f717          	auipc	a4,0x1f
    80004ca0:	70c70713          	addi	a4,a4,1804 # 800243a8 <log>
    80004ca4:	571c                	lw	a5,40(a4)
    80004ca6:	2785                	addiw	a5,a5,1
    80004ca8:	d71c                	sw	a5,40(a4)
    80004caa:	a80d                	j	80004cdc <log_write+0xaa>
    panic("too big a transaction");
    80004cac:	00004517          	auipc	a0,0x4
    80004cb0:	9ac50513          	addi	a0,a0,-1620 # 80008658 <etext+0x658>
    80004cb4:	b2dfb0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80004cb8:	00004517          	auipc	a0,0x4
    80004cbc:	9b850513          	addi	a0,a0,-1608 # 80008670 <etext+0x670>
    80004cc0:	b21fb0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80004cc4:	00878693          	addi	a3,a5,8
    80004cc8:	068a                	slli	a3,a3,0x2
    80004cca:	0001f717          	auipc	a4,0x1f
    80004cce:	6de70713          	addi	a4,a4,1758 # 800243a8 <log>
    80004cd2:	9736                	add	a4,a4,a3
    80004cd4:	44d4                	lw	a3,12(s1)
    80004cd6:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004cd8:	faf60fe3          	beq	a2,a5,80004c96 <log_write+0x64>
  }
  release(&log.lock);
    80004cdc:	0001f517          	auipc	a0,0x1f
    80004ce0:	6cc50513          	addi	a0,a0,1740 # 800243a8 <log>
    80004ce4:	f83fb0ef          	jal	80000c66 <release>
}
    80004ce8:	60e2                	ld	ra,24(sp)
    80004cea:	6442                	ld	s0,16(sp)
    80004cec:	64a2                	ld	s1,8(sp)
    80004cee:	6902                	ld	s2,0(sp)
    80004cf0:	6105                	addi	sp,sp,32
    80004cf2:	8082                	ret

0000000080004cf4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004cf4:	1101                	addi	sp,sp,-32
    80004cf6:	ec06                	sd	ra,24(sp)
    80004cf8:	e822                	sd	s0,16(sp)
    80004cfa:	e426                	sd	s1,8(sp)
    80004cfc:	e04a                	sd	s2,0(sp)
    80004cfe:	1000                	addi	s0,sp,32
    80004d00:	84aa                	mv	s1,a0
    80004d02:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004d04:	00004597          	auipc	a1,0x4
    80004d08:	98c58593          	addi	a1,a1,-1652 # 80008690 <etext+0x690>
    80004d0c:	0521                	addi	a0,a0,8
    80004d0e:	e41fb0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80004d12:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004d16:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d1a:	0204a423          	sw	zero,40(s1)
}
    80004d1e:	60e2                	ld	ra,24(sp)
    80004d20:	6442                	ld	s0,16(sp)
    80004d22:	64a2                	ld	s1,8(sp)
    80004d24:	6902                	ld	s2,0(sp)
    80004d26:	6105                	addi	sp,sp,32
    80004d28:	8082                	ret

0000000080004d2a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004d2a:	1101                	addi	sp,sp,-32
    80004d2c:	ec06                	sd	ra,24(sp)
    80004d2e:	e822                	sd	s0,16(sp)
    80004d30:	e426                	sd	s1,8(sp)
    80004d32:	e04a                	sd	s2,0(sp)
    80004d34:	1000                	addi	s0,sp,32
    80004d36:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004d38:	00850913          	addi	s2,a0,8
    80004d3c:	854a                	mv	a0,s2
    80004d3e:	e91fb0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80004d42:	409c                	lw	a5,0(s1)
    80004d44:	c799                	beqz	a5,80004d52 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004d46:	85ca                	mv	a1,s2
    80004d48:	8526                	mv	a0,s1
    80004d4a:	887fd0ef          	jal	800025d0 <sleep>
  while (lk->locked) {
    80004d4e:	409c                	lw	a5,0(s1)
    80004d50:	fbfd                	bnez	a5,80004d46 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004d52:	4785                	li	a5,1
    80004d54:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004d56:	ca1fc0ef          	jal	800019f6 <myproc>
    80004d5a:	591c                	lw	a5,48(a0)
    80004d5c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004d5e:	854a                	mv	a0,s2
    80004d60:	f07fb0ef          	jal	80000c66 <release>
}
    80004d64:	60e2                	ld	ra,24(sp)
    80004d66:	6442                	ld	s0,16(sp)
    80004d68:	64a2                	ld	s1,8(sp)
    80004d6a:	6902                	ld	s2,0(sp)
    80004d6c:	6105                	addi	sp,sp,32
    80004d6e:	8082                	ret

0000000080004d70 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004d70:	1101                	addi	sp,sp,-32
    80004d72:	ec06                	sd	ra,24(sp)
    80004d74:	e822                	sd	s0,16(sp)
    80004d76:	e426                	sd	s1,8(sp)
    80004d78:	e04a                	sd	s2,0(sp)
    80004d7a:	1000                	addi	s0,sp,32
    80004d7c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004d7e:	00850913          	addi	s2,a0,8
    80004d82:	854a                	mv	a0,s2
    80004d84:	e4bfb0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80004d88:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d8c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004d90:	8526                	mv	a0,s1
    80004d92:	88bfd0ef          	jal	8000261c <wakeup>
  release(&lk->lk);
    80004d96:	854a                	mv	a0,s2
    80004d98:	ecffb0ef          	jal	80000c66 <release>
}
    80004d9c:	60e2                	ld	ra,24(sp)
    80004d9e:	6442                	ld	s0,16(sp)
    80004da0:	64a2                	ld	s1,8(sp)
    80004da2:	6902                	ld	s2,0(sp)
    80004da4:	6105                	addi	sp,sp,32
    80004da6:	8082                	ret

0000000080004da8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004da8:	7179                	addi	sp,sp,-48
    80004daa:	f406                	sd	ra,40(sp)
    80004dac:	f022                	sd	s0,32(sp)
    80004dae:	ec26                	sd	s1,24(sp)
    80004db0:	e84a                	sd	s2,16(sp)
    80004db2:	1800                	addi	s0,sp,48
    80004db4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004db6:	00850913          	addi	s2,a0,8
    80004dba:	854a                	mv	a0,s2
    80004dbc:	e13fb0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004dc0:	409c                	lw	a5,0(s1)
    80004dc2:	ef81                	bnez	a5,80004dda <holdingsleep+0x32>
    80004dc4:	4481                	li	s1,0
  release(&lk->lk);
    80004dc6:	854a                	mv	a0,s2
    80004dc8:	e9ffb0ef          	jal	80000c66 <release>
  return r;
}
    80004dcc:	8526                	mv	a0,s1
    80004dce:	70a2                	ld	ra,40(sp)
    80004dd0:	7402                	ld	s0,32(sp)
    80004dd2:	64e2                	ld	s1,24(sp)
    80004dd4:	6942                	ld	s2,16(sp)
    80004dd6:	6145                	addi	sp,sp,48
    80004dd8:	8082                	ret
    80004dda:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ddc:	0284a983          	lw	s3,40(s1)
    80004de0:	c17fc0ef          	jal	800019f6 <myproc>
    80004de4:	5904                	lw	s1,48(a0)
    80004de6:	413484b3          	sub	s1,s1,s3
    80004dea:	0014b493          	seqz	s1,s1
    80004dee:	69a2                	ld	s3,8(sp)
    80004df0:	bfd9                	j	80004dc6 <holdingsleep+0x1e>

0000000080004df2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004df2:	1141                	addi	sp,sp,-16
    80004df4:	e406                	sd	ra,8(sp)
    80004df6:	e022                	sd	s0,0(sp)
    80004df8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004dfa:	00004597          	auipc	a1,0x4
    80004dfe:	8a658593          	addi	a1,a1,-1882 # 800086a0 <etext+0x6a0>
    80004e02:	0001f517          	auipc	a0,0x1f
    80004e06:	6ee50513          	addi	a0,a0,1774 # 800244f0 <ftable>
    80004e0a:	d45fb0ef          	jal	80000b4e <initlock>
}
    80004e0e:	60a2                	ld	ra,8(sp)
    80004e10:	6402                	ld	s0,0(sp)
    80004e12:	0141                	addi	sp,sp,16
    80004e14:	8082                	ret

0000000080004e16 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004e16:	1101                	addi	sp,sp,-32
    80004e18:	ec06                	sd	ra,24(sp)
    80004e1a:	e822                	sd	s0,16(sp)
    80004e1c:	e426                	sd	s1,8(sp)
    80004e1e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004e20:	0001f517          	auipc	a0,0x1f
    80004e24:	6d050513          	addi	a0,a0,1744 # 800244f0 <ftable>
    80004e28:	da7fb0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e2c:	0001f497          	auipc	s1,0x1f
    80004e30:	6dc48493          	addi	s1,s1,1756 # 80024508 <ftable+0x18>
    80004e34:	00020717          	auipc	a4,0x20
    80004e38:	67470713          	addi	a4,a4,1652 # 800254a8 <disk>
    if(f->ref == 0){
    80004e3c:	40dc                	lw	a5,4(s1)
    80004e3e:	cf89                	beqz	a5,80004e58 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e40:	02848493          	addi	s1,s1,40
    80004e44:	fee49ce3          	bne	s1,a4,80004e3c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004e48:	0001f517          	auipc	a0,0x1f
    80004e4c:	6a850513          	addi	a0,a0,1704 # 800244f0 <ftable>
    80004e50:	e17fb0ef          	jal	80000c66 <release>
  return 0;
    80004e54:	4481                	li	s1,0
    80004e56:	a809                	j	80004e68 <filealloc+0x52>
      f->ref = 1;
    80004e58:	4785                	li	a5,1
    80004e5a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004e5c:	0001f517          	auipc	a0,0x1f
    80004e60:	69450513          	addi	a0,a0,1684 # 800244f0 <ftable>
    80004e64:	e03fb0ef          	jal	80000c66 <release>
}
    80004e68:	8526                	mv	a0,s1
    80004e6a:	60e2                	ld	ra,24(sp)
    80004e6c:	6442                	ld	s0,16(sp)
    80004e6e:	64a2                	ld	s1,8(sp)
    80004e70:	6105                	addi	sp,sp,32
    80004e72:	8082                	ret

0000000080004e74 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004e74:	1101                	addi	sp,sp,-32
    80004e76:	ec06                	sd	ra,24(sp)
    80004e78:	e822                	sd	s0,16(sp)
    80004e7a:	e426                	sd	s1,8(sp)
    80004e7c:	1000                	addi	s0,sp,32
    80004e7e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004e80:	0001f517          	auipc	a0,0x1f
    80004e84:	67050513          	addi	a0,a0,1648 # 800244f0 <ftable>
    80004e88:	d47fb0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004e8c:	40dc                	lw	a5,4(s1)
    80004e8e:	02f05063          	blez	a5,80004eae <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004e92:	2785                	addiw	a5,a5,1
    80004e94:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004e96:	0001f517          	auipc	a0,0x1f
    80004e9a:	65a50513          	addi	a0,a0,1626 # 800244f0 <ftable>
    80004e9e:	dc9fb0ef          	jal	80000c66 <release>
  return f;
}
    80004ea2:	8526                	mv	a0,s1
    80004ea4:	60e2                	ld	ra,24(sp)
    80004ea6:	6442                	ld	s0,16(sp)
    80004ea8:	64a2                	ld	s1,8(sp)
    80004eaa:	6105                	addi	sp,sp,32
    80004eac:	8082                	ret
    panic("filedup");
    80004eae:	00003517          	auipc	a0,0x3
    80004eb2:	7fa50513          	addi	a0,a0,2042 # 800086a8 <etext+0x6a8>
    80004eb6:	92bfb0ef          	jal	800007e0 <panic>

0000000080004eba <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004eba:	7139                	addi	sp,sp,-64
    80004ebc:	fc06                	sd	ra,56(sp)
    80004ebe:	f822                	sd	s0,48(sp)
    80004ec0:	f426                	sd	s1,40(sp)
    80004ec2:	0080                	addi	s0,sp,64
    80004ec4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ec6:	0001f517          	auipc	a0,0x1f
    80004eca:	62a50513          	addi	a0,a0,1578 # 800244f0 <ftable>
    80004ece:	d01fb0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004ed2:	40dc                	lw	a5,4(s1)
    80004ed4:	04f05a63          	blez	a5,80004f28 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004ed8:	37fd                	addiw	a5,a5,-1
    80004eda:	0007871b          	sext.w	a4,a5
    80004ede:	c0dc                	sw	a5,4(s1)
    80004ee0:	04e04e63          	bgtz	a4,80004f3c <fileclose+0x82>
    80004ee4:	f04a                	sd	s2,32(sp)
    80004ee6:	ec4e                	sd	s3,24(sp)
    80004ee8:	e852                	sd	s4,16(sp)
    80004eea:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004eec:	0004a903          	lw	s2,0(s1)
    80004ef0:	0094ca83          	lbu	s5,9(s1)
    80004ef4:	0104ba03          	ld	s4,16(s1)
    80004ef8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004efc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004f00:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004f04:	0001f517          	auipc	a0,0x1f
    80004f08:	5ec50513          	addi	a0,a0,1516 # 800244f0 <ftable>
    80004f0c:	d5bfb0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    80004f10:	4785                	li	a5,1
    80004f12:	04f90063          	beq	s2,a5,80004f52 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004f16:	3979                	addiw	s2,s2,-2
    80004f18:	4785                	li	a5,1
    80004f1a:	0527f563          	bgeu	a5,s2,80004f64 <fileclose+0xaa>
    80004f1e:	7902                	ld	s2,32(sp)
    80004f20:	69e2                	ld	s3,24(sp)
    80004f22:	6a42                	ld	s4,16(sp)
    80004f24:	6aa2                	ld	s5,8(sp)
    80004f26:	a00d                	j	80004f48 <fileclose+0x8e>
    80004f28:	f04a                	sd	s2,32(sp)
    80004f2a:	ec4e                	sd	s3,24(sp)
    80004f2c:	e852                	sd	s4,16(sp)
    80004f2e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004f30:	00003517          	auipc	a0,0x3
    80004f34:	78050513          	addi	a0,a0,1920 # 800086b0 <etext+0x6b0>
    80004f38:	8a9fb0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    80004f3c:	0001f517          	auipc	a0,0x1f
    80004f40:	5b450513          	addi	a0,a0,1460 # 800244f0 <ftable>
    80004f44:	d23fb0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004f48:	70e2                	ld	ra,56(sp)
    80004f4a:	7442                	ld	s0,48(sp)
    80004f4c:	74a2                	ld	s1,40(sp)
    80004f4e:	6121                	addi	sp,sp,64
    80004f50:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004f52:	85d6                	mv	a1,s5
    80004f54:	8552                	mv	a0,s4
    80004f56:	336000ef          	jal	8000528c <pipeclose>
    80004f5a:	7902                	ld	s2,32(sp)
    80004f5c:	69e2                	ld	s3,24(sp)
    80004f5e:	6a42                	ld	s4,16(sp)
    80004f60:	6aa2                	ld	s5,8(sp)
    80004f62:	b7dd                	j	80004f48 <fileclose+0x8e>
    begin_op();
    80004f64:	b4bff0ef          	jal	80004aae <begin_op>
    iput(ff.ip);
    80004f68:	854e                	mv	a0,s3
    80004f6a:	adcff0ef          	jal	80004246 <iput>
    end_op();
    80004f6e:	babff0ef          	jal	80004b18 <end_op>
    80004f72:	7902                	ld	s2,32(sp)
    80004f74:	69e2                	ld	s3,24(sp)
    80004f76:	6a42                	ld	s4,16(sp)
    80004f78:	6aa2                	ld	s5,8(sp)
    80004f7a:	b7f9                	j	80004f48 <fileclose+0x8e>

0000000080004f7c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004f7c:	715d                	addi	sp,sp,-80
    80004f7e:	e486                	sd	ra,72(sp)
    80004f80:	e0a2                	sd	s0,64(sp)
    80004f82:	fc26                	sd	s1,56(sp)
    80004f84:	f44e                	sd	s3,40(sp)
    80004f86:	0880                	addi	s0,sp,80
    80004f88:	84aa                	mv	s1,a0
    80004f8a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004f8c:	a6bfc0ef          	jal	800019f6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004f90:	409c                	lw	a5,0(s1)
    80004f92:	37f9                	addiw	a5,a5,-2
    80004f94:	4705                	li	a4,1
    80004f96:	04f76063          	bltu	a4,a5,80004fd6 <filestat+0x5a>
    80004f9a:	f84a                	sd	s2,48(sp)
    80004f9c:	892a                	mv	s2,a0
    ilock(f->ip);
    80004f9e:	6c88                	ld	a0,24(s1)
    80004fa0:	924ff0ef          	jal	800040c4 <ilock>
    stati(f->ip, &st);
    80004fa4:	fb840593          	addi	a1,s0,-72
    80004fa8:	6c88                	ld	a0,24(s1)
    80004faa:	c80ff0ef          	jal	8000442a <stati>
    iunlock(f->ip);
    80004fae:	6c88                	ld	a0,24(s1)
    80004fb0:	9c2ff0ef          	jal	80004172 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004fb4:	46e1                	li	a3,24
    80004fb6:	fb840613          	addi	a2,s0,-72
    80004fba:	85ce                	mv	a1,s3
    80004fbc:	05893503          	ld	a0,88(s2)
    80004fc0:	e22fc0ef          	jal	800015e2 <copyout>
    80004fc4:	41f5551b          	sraiw	a0,a0,0x1f
    80004fc8:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004fca:	60a6                	ld	ra,72(sp)
    80004fcc:	6406                	ld	s0,64(sp)
    80004fce:	74e2                	ld	s1,56(sp)
    80004fd0:	79a2                	ld	s3,40(sp)
    80004fd2:	6161                	addi	sp,sp,80
    80004fd4:	8082                	ret
  return -1;
    80004fd6:	557d                	li	a0,-1
    80004fd8:	bfcd                	j	80004fca <filestat+0x4e>

0000000080004fda <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004fda:	7179                	addi	sp,sp,-48
    80004fdc:	f406                	sd	ra,40(sp)
    80004fde:	f022                	sd	s0,32(sp)
    80004fe0:	e84a                	sd	s2,16(sp)
    80004fe2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004fe4:	00854783          	lbu	a5,8(a0)
    80004fe8:	cfd1                	beqz	a5,80005084 <fileread+0xaa>
    80004fea:	ec26                	sd	s1,24(sp)
    80004fec:	e44e                	sd	s3,8(sp)
    80004fee:	84aa                	mv	s1,a0
    80004ff0:	89ae                	mv	s3,a1
    80004ff2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ff4:	411c                	lw	a5,0(a0)
    80004ff6:	4705                	li	a4,1
    80004ff8:	04e78363          	beq	a5,a4,8000503e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ffc:	470d                	li	a4,3
    80004ffe:	04e78763          	beq	a5,a4,8000504c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005002:	4709                	li	a4,2
    80005004:	06e79a63          	bne	a5,a4,80005078 <fileread+0x9e>
    ilock(f->ip);
    80005008:	6d08                	ld	a0,24(a0)
    8000500a:	8baff0ef          	jal	800040c4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000500e:	874a                	mv	a4,s2
    80005010:	5094                	lw	a3,32(s1)
    80005012:	864e                	mv	a2,s3
    80005014:	4585                	li	a1,1
    80005016:	6c88                	ld	a0,24(s1)
    80005018:	c3cff0ef          	jal	80004454 <readi>
    8000501c:	892a                	mv	s2,a0
    8000501e:	00a05563          	blez	a0,80005028 <fileread+0x4e>
      f->off += r;
    80005022:	509c                	lw	a5,32(s1)
    80005024:	9fa9                	addw	a5,a5,a0
    80005026:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005028:	6c88                	ld	a0,24(s1)
    8000502a:	948ff0ef          	jal	80004172 <iunlock>
    8000502e:	64e2                	ld	s1,24(sp)
    80005030:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80005032:	854a                	mv	a0,s2
    80005034:	70a2                	ld	ra,40(sp)
    80005036:	7402                	ld	s0,32(sp)
    80005038:	6942                	ld	s2,16(sp)
    8000503a:	6145                	addi	sp,sp,48
    8000503c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000503e:	6908                	ld	a0,16(a0)
    80005040:	388000ef          	jal	800053c8 <piperead>
    80005044:	892a                	mv	s2,a0
    80005046:	64e2                	ld	s1,24(sp)
    80005048:	69a2                	ld	s3,8(sp)
    8000504a:	b7e5                	j	80005032 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000504c:	02451783          	lh	a5,36(a0)
    80005050:	03079693          	slli	a3,a5,0x30
    80005054:	92c1                	srli	a3,a3,0x30
    80005056:	4725                	li	a4,9
    80005058:	02d76863          	bltu	a4,a3,80005088 <fileread+0xae>
    8000505c:	0792                	slli	a5,a5,0x4
    8000505e:	0001f717          	auipc	a4,0x1f
    80005062:	3f270713          	addi	a4,a4,1010 # 80024450 <devsw>
    80005066:	97ba                	add	a5,a5,a4
    80005068:	639c                	ld	a5,0(a5)
    8000506a:	c39d                	beqz	a5,80005090 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000506c:	4505                	li	a0,1
    8000506e:	9782                	jalr	a5
    80005070:	892a                	mv	s2,a0
    80005072:	64e2                	ld	s1,24(sp)
    80005074:	69a2                	ld	s3,8(sp)
    80005076:	bf75                	j	80005032 <fileread+0x58>
    panic("fileread");
    80005078:	00003517          	auipc	a0,0x3
    8000507c:	64850513          	addi	a0,a0,1608 # 800086c0 <etext+0x6c0>
    80005080:	f60fb0ef          	jal	800007e0 <panic>
    return -1;
    80005084:	597d                	li	s2,-1
    80005086:	b775                	j	80005032 <fileread+0x58>
      return -1;
    80005088:	597d                	li	s2,-1
    8000508a:	64e2                	ld	s1,24(sp)
    8000508c:	69a2                	ld	s3,8(sp)
    8000508e:	b755                	j	80005032 <fileread+0x58>
    80005090:	597d                	li	s2,-1
    80005092:	64e2                	ld	s1,24(sp)
    80005094:	69a2                	ld	s3,8(sp)
    80005096:	bf71                	j	80005032 <fileread+0x58>

0000000080005098 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80005098:	00954783          	lbu	a5,9(a0)
    8000509c:	10078b63          	beqz	a5,800051b2 <filewrite+0x11a>
{
    800050a0:	715d                	addi	sp,sp,-80
    800050a2:	e486                	sd	ra,72(sp)
    800050a4:	e0a2                	sd	s0,64(sp)
    800050a6:	f84a                	sd	s2,48(sp)
    800050a8:	f052                	sd	s4,32(sp)
    800050aa:	e85a                	sd	s6,16(sp)
    800050ac:	0880                	addi	s0,sp,80
    800050ae:	892a                	mv	s2,a0
    800050b0:	8b2e                	mv	s6,a1
    800050b2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800050b4:	411c                	lw	a5,0(a0)
    800050b6:	4705                	li	a4,1
    800050b8:	02e78763          	beq	a5,a4,800050e6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800050bc:	470d                	li	a4,3
    800050be:	02e78863          	beq	a5,a4,800050ee <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800050c2:	4709                	li	a4,2
    800050c4:	0ce79c63          	bne	a5,a4,8000519c <filewrite+0x104>
    800050c8:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800050ca:	0ac05863          	blez	a2,8000517a <filewrite+0xe2>
    800050ce:	fc26                	sd	s1,56(sp)
    800050d0:	ec56                	sd	s5,24(sp)
    800050d2:	e45e                	sd	s7,8(sp)
    800050d4:	e062                	sd	s8,0(sp)
    int i = 0;
    800050d6:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800050d8:	6b85                	lui	s7,0x1
    800050da:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800050de:	6c05                	lui	s8,0x1
    800050e0:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800050e4:	a8b5                	j	80005160 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800050e6:	6908                	ld	a0,16(a0)
    800050e8:	1fc000ef          	jal	800052e4 <pipewrite>
    800050ec:	a04d                	j	8000518e <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800050ee:	02451783          	lh	a5,36(a0)
    800050f2:	03079693          	slli	a3,a5,0x30
    800050f6:	92c1                	srli	a3,a3,0x30
    800050f8:	4725                	li	a4,9
    800050fa:	0ad76e63          	bltu	a4,a3,800051b6 <filewrite+0x11e>
    800050fe:	0792                	slli	a5,a5,0x4
    80005100:	0001f717          	auipc	a4,0x1f
    80005104:	35070713          	addi	a4,a4,848 # 80024450 <devsw>
    80005108:	97ba                	add	a5,a5,a4
    8000510a:	679c                	ld	a5,8(a5)
    8000510c:	c7dd                	beqz	a5,800051ba <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000510e:	4505                	li	a0,1
    80005110:	9782                	jalr	a5
    80005112:	a8b5                	j	8000518e <filewrite+0xf6>
      if(n1 > max)
    80005114:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80005118:	997ff0ef          	jal	80004aae <begin_op>
      ilock(f->ip);
    8000511c:	01893503          	ld	a0,24(s2)
    80005120:	fa5fe0ef          	jal	800040c4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005124:	8756                	mv	a4,s5
    80005126:	02092683          	lw	a3,32(s2)
    8000512a:	01698633          	add	a2,s3,s6
    8000512e:	4585                	li	a1,1
    80005130:	01893503          	ld	a0,24(s2)
    80005134:	c1cff0ef          	jal	80004550 <writei>
    80005138:	84aa                	mv	s1,a0
    8000513a:	00a05763          	blez	a0,80005148 <filewrite+0xb0>
        f->off += r;
    8000513e:	02092783          	lw	a5,32(s2)
    80005142:	9fa9                	addw	a5,a5,a0
    80005144:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005148:	01893503          	ld	a0,24(s2)
    8000514c:	826ff0ef          	jal	80004172 <iunlock>
      end_op();
    80005150:	9c9ff0ef          	jal	80004b18 <end_op>

      if(r != n1){
    80005154:	029a9563          	bne	s5,s1,8000517e <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80005158:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000515c:	0149da63          	bge	s3,s4,80005170 <filewrite+0xd8>
      int n1 = n - i;
    80005160:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80005164:	0004879b          	sext.w	a5,s1
    80005168:	fafbd6e3          	bge	s7,a5,80005114 <filewrite+0x7c>
    8000516c:	84e2                	mv	s1,s8
    8000516e:	b75d                	j	80005114 <filewrite+0x7c>
    80005170:	74e2                	ld	s1,56(sp)
    80005172:	6ae2                	ld	s5,24(sp)
    80005174:	6ba2                	ld	s7,8(sp)
    80005176:	6c02                	ld	s8,0(sp)
    80005178:	a039                	j	80005186 <filewrite+0xee>
    int i = 0;
    8000517a:	4981                	li	s3,0
    8000517c:	a029                	j	80005186 <filewrite+0xee>
    8000517e:	74e2                	ld	s1,56(sp)
    80005180:	6ae2                	ld	s5,24(sp)
    80005182:	6ba2                	ld	s7,8(sp)
    80005184:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80005186:	033a1c63          	bne	s4,s3,800051be <filewrite+0x126>
    8000518a:	8552                	mv	a0,s4
    8000518c:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000518e:	60a6                	ld	ra,72(sp)
    80005190:	6406                	ld	s0,64(sp)
    80005192:	7942                	ld	s2,48(sp)
    80005194:	7a02                	ld	s4,32(sp)
    80005196:	6b42                	ld	s6,16(sp)
    80005198:	6161                	addi	sp,sp,80
    8000519a:	8082                	ret
    8000519c:	fc26                	sd	s1,56(sp)
    8000519e:	f44e                	sd	s3,40(sp)
    800051a0:	ec56                	sd	s5,24(sp)
    800051a2:	e45e                	sd	s7,8(sp)
    800051a4:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800051a6:	00003517          	auipc	a0,0x3
    800051aa:	52a50513          	addi	a0,a0,1322 # 800086d0 <etext+0x6d0>
    800051ae:	e32fb0ef          	jal	800007e0 <panic>
    return -1;
    800051b2:	557d                	li	a0,-1
}
    800051b4:	8082                	ret
      return -1;
    800051b6:	557d                	li	a0,-1
    800051b8:	bfd9                	j	8000518e <filewrite+0xf6>
    800051ba:	557d                	li	a0,-1
    800051bc:	bfc9                	j	8000518e <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800051be:	557d                	li	a0,-1
    800051c0:	79a2                	ld	s3,40(sp)
    800051c2:	b7f1                	j	8000518e <filewrite+0xf6>

00000000800051c4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800051c4:	7179                	addi	sp,sp,-48
    800051c6:	f406                	sd	ra,40(sp)
    800051c8:	f022                	sd	s0,32(sp)
    800051ca:	ec26                	sd	s1,24(sp)
    800051cc:	e052                	sd	s4,0(sp)
    800051ce:	1800                	addi	s0,sp,48
    800051d0:	84aa                	mv	s1,a0
    800051d2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800051d4:	0005b023          	sd	zero,0(a1)
    800051d8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800051dc:	c3bff0ef          	jal	80004e16 <filealloc>
    800051e0:	e088                	sd	a0,0(s1)
    800051e2:	c549                	beqz	a0,8000526c <pipealloc+0xa8>
    800051e4:	c33ff0ef          	jal	80004e16 <filealloc>
    800051e8:	00aa3023          	sd	a0,0(s4)
    800051ec:	cd25                	beqz	a0,80005264 <pipealloc+0xa0>
    800051ee:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800051f0:	90ffb0ef          	jal	80000afe <kalloc>
    800051f4:	892a                	mv	s2,a0
    800051f6:	c12d                	beqz	a0,80005258 <pipealloc+0x94>
    800051f8:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800051fa:	4985                	li	s3,1
    800051fc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005200:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005204:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005208:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000520c:	00003597          	auipc	a1,0x3
    80005210:	4d458593          	addi	a1,a1,1236 # 800086e0 <etext+0x6e0>
    80005214:	93bfb0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    80005218:	609c                	ld	a5,0(s1)
    8000521a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000521e:	609c                	ld	a5,0(s1)
    80005220:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005224:	609c                	ld	a5,0(s1)
    80005226:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000522a:	609c                	ld	a5,0(s1)
    8000522c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005230:	000a3783          	ld	a5,0(s4)
    80005234:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005238:	000a3783          	ld	a5,0(s4)
    8000523c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005240:	000a3783          	ld	a5,0(s4)
    80005244:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005248:	000a3783          	ld	a5,0(s4)
    8000524c:	0127b823          	sd	s2,16(a5)
  return 0;
    80005250:	4501                	li	a0,0
    80005252:	6942                	ld	s2,16(sp)
    80005254:	69a2                	ld	s3,8(sp)
    80005256:	a01d                	j	8000527c <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005258:	6088                	ld	a0,0(s1)
    8000525a:	c119                	beqz	a0,80005260 <pipealloc+0x9c>
    8000525c:	6942                	ld	s2,16(sp)
    8000525e:	a029                	j	80005268 <pipealloc+0xa4>
    80005260:	6942                	ld	s2,16(sp)
    80005262:	a029                	j	8000526c <pipealloc+0xa8>
    80005264:	6088                	ld	a0,0(s1)
    80005266:	c10d                	beqz	a0,80005288 <pipealloc+0xc4>
    fileclose(*f0);
    80005268:	c53ff0ef          	jal	80004eba <fileclose>
  if(*f1)
    8000526c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005270:	557d                	li	a0,-1
  if(*f1)
    80005272:	c789                	beqz	a5,8000527c <pipealloc+0xb8>
    fileclose(*f1);
    80005274:	853e                	mv	a0,a5
    80005276:	c45ff0ef          	jal	80004eba <fileclose>
  return -1;
    8000527a:	557d                	li	a0,-1
}
    8000527c:	70a2                	ld	ra,40(sp)
    8000527e:	7402                	ld	s0,32(sp)
    80005280:	64e2                	ld	s1,24(sp)
    80005282:	6a02                	ld	s4,0(sp)
    80005284:	6145                	addi	sp,sp,48
    80005286:	8082                	ret
  return -1;
    80005288:	557d                	li	a0,-1
    8000528a:	bfcd                	j	8000527c <pipealloc+0xb8>

000000008000528c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000528c:	1101                	addi	sp,sp,-32
    8000528e:	ec06                	sd	ra,24(sp)
    80005290:	e822                	sd	s0,16(sp)
    80005292:	e426                	sd	s1,8(sp)
    80005294:	e04a                	sd	s2,0(sp)
    80005296:	1000                	addi	s0,sp,32
    80005298:	84aa                	mv	s1,a0
    8000529a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000529c:	933fb0ef          	jal	80000bce <acquire>
  if(writable){
    800052a0:	02090763          	beqz	s2,800052ce <pipeclose+0x42>
    pi->writeopen = 0;
    800052a4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800052a8:	21848513          	addi	a0,s1,536
    800052ac:	b70fd0ef          	jal	8000261c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800052b0:	2204b783          	ld	a5,544(s1)
    800052b4:	e785                	bnez	a5,800052dc <pipeclose+0x50>
    release(&pi->lock);
    800052b6:	8526                	mv	a0,s1
    800052b8:	9affb0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    800052bc:	8526                	mv	a0,s1
    800052be:	f5efb0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    800052c2:	60e2                	ld	ra,24(sp)
    800052c4:	6442                	ld	s0,16(sp)
    800052c6:	64a2                	ld	s1,8(sp)
    800052c8:	6902                	ld	s2,0(sp)
    800052ca:	6105                	addi	sp,sp,32
    800052cc:	8082                	ret
    pi->readopen = 0;
    800052ce:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800052d2:	21c48513          	addi	a0,s1,540
    800052d6:	b46fd0ef          	jal	8000261c <wakeup>
    800052da:	bfd9                	j	800052b0 <pipeclose+0x24>
    release(&pi->lock);
    800052dc:	8526                	mv	a0,s1
    800052de:	989fb0ef          	jal	80000c66 <release>
}
    800052e2:	b7c5                	j	800052c2 <pipeclose+0x36>

00000000800052e4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800052e4:	711d                	addi	sp,sp,-96
    800052e6:	ec86                	sd	ra,88(sp)
    800052e8:	e8a2                	sd	s0,80(sp)
    800052ea:	e4a6                	sd	s1,72(sp)
    800052ec:	e0ca                	sd	s2,64(sp)
    800052ee:	fc4e                	sd	s3,56(sp)
    800052f0:	f852                	sd	s4,48(sp)
    800052f2:	f456                	sd	s5,40(sp)
    800052f4:	1080                	addi	s0,sp,96
    800052f6:	84aa                	mv	s1,a0
    800052f8:	8aae                	mv	s5,a1
    800052fa:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800052fc:	efafc0ef          	jal	800019f6 <myproc>
    80005300:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005302:	8526                	mv	a0,s1
    80005304:	8cbfb0ef          	jal	80000bce <acquire>
  while(i < n){
    80005308:	0b405a63          	blez	s4,800053bc <pipewrite+0xd8>
    8000530c:	f05a                	sd	s6,32(sp)
    8000530e:	ec5e                	sd	s7,24(sp)
    80005310:	e862                	sd	s8,16(sp)
  int i = 0;
    80005312:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005314:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005316:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000531a:	21c48b93          	addi	s7,s1,540
    8000531e:	a81d                	j	80005354 <pipewrite+0x70>
      release(&pi->lock);
    80005320:	8526                	mv	a0,s1
    80005322:	945fb0ef          	jal	80000c66 <release>
      return -1;
    80005326:	597d                	li	s2,-1
    80005328:	7b02                	ld	s6,32(sp)
    8000532a:	6be2                	ld	s7,24(sp)
    8000532c:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000532e:	854a                	mv	a0,s2
    80005330:	60e6                	ld	ra,88(sp)
    80005332:	6446                	ld	s0,80(sp)
    80005334:	64a6                	ld	s1,72(sp)
    80005336:	6906                	ld	s2,64(sp)
    80005338:	79e2                	ld	s3,56(sp)
    8000533a:	7a42                	ld	s4,48(sp)
    8000533c:	7aa2                	ld	s5,40(sp)
    8000533e:	6125                	addi	sp,sp,96
    80005340:	8082                	ret
      wakeup(&pi->nread);
    80005342:	8562                	mv	a0,s8
    80005344:	ad8fd0ef          	jal	8000261c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005348:	85a6                	mv	a1,s1
    8000534a:	855e                	mv	a0,s7
    8000534c:	a84fd0ef          	jal	800025d0 <sleep>
  while(i < n){
    80005350:	05495b63          	bge	s2,s4,800053a6 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80005354:	2204a783          	lw	a5,544(s1)
    80005358:	d7e1                	beqz	a5,80005320 <pipewrite+0x3c>
    8000535a:	854e                	mv	a0,s3
    8000535c:	d40fd0ef          	jal	8000289c <killed>
    80005360:	f161                	bnez	a0,80005320 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005362:	2184a783          	lw	a5,536(s1)
    80005366:	21c4a703          	lw	a4,540(s1)
    8000536a:	2007879b          	addiw	a5,a5,512
    8000536e:	fcf70ae3          	beq	a4,a5,80005342 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005372:	4685                	li	a3,1
    80005374:	01590633          	add	a2,s2,s5
    80005378:	faf40593          	addi	a1,s0,-81
    8000537c:	0589b503          	ld	a0,88(s3)
    80005380:	b46fc0ef          	jal	800016c6 <copyin>
    80005384:	03650e63          	beq	a0,s6,800053c0 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005388:	21c4a783          	lw	a5,540(s1)
    8000538c:	0017871b          	addiw	a4,a5,1
    80005390:	20e4ae23          	sw	a4,540(s1)
    80005394:	1ff7f793          	andi	a5,a5,511
    80005398:	97a6                	add	a5,a5,s1
    8000539a:	faf44703          	lbu	a4,-81(s0)
    8000539e:	00e78c23          	sb	a4,24(a5)
      i++;
    800053a2:	2905                	addiw	s2,s2,1
    800053a4:	b775                	j	80005350 <pipewrite+0x6c>
    800053a6:	7b02                	ld	s6,32(sp)
    800053a8:	6be2                	ld	s7,24(sp)
    800053aa:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800053ac:	21848513          	addi	a0,s1,536
    800053b0:	a6cfd0ef          	jal	8000261c <wakeup>
  release(&pi->lock);
    800053b4:	8526                	mv	a0,s1
    800053b6:	8b1fb0ef          	jal	80000c66 <release>
  return i;
    800053ba:	bf95                	j	8000532e <pipewrite+0x4a>
  int i = 0;
    800053bc:	4901                	li	s2,0
    800053be:	b7fd                	j	800053ac <pipewrite+0xc8>
    800053c0:	7b02                	ld	s6,32(sp)
    800053c2:	6be2                	ld	s7,24(sp)
    800053c4:	6c42                	ld	s8,16(sp)
    800053c6:	b7dd                	j	800053ac <pipewrite+0xc8>

00000000800053c8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800053c8:	715d                	addi	sp,sp,-80
    800053ca:	e486                	sd	ra,72(sp)
    800053cc:	e0a2                	sd	s0,64(sp)
    800053ce:	fc26                	sd	s1,56(sp)
    800053d0:	f84a                	sd	s2,48(sp)
    800053d2:	f44e                	sd	s3,40(sp)
    800053d4:	f052                	sd	s4,32(sp)
    800053d6:	ec56                	sd	s5,24(sp)
    800053d8:	0880                	addi	s0,sp,80
    800053da:	84aa                	mv	s1,a0
    800053dc:	892e                	mv	s2,a1
    800053de:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800053e0:	e16fc0ef          	jal	800019f6 <myproc>
    800053e4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800053e6:	8526                	mv	a0,s1
    800053e8:	fe6fb0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053ec:	2184a703          	lw	a4,536(s1)
    800053f0:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053f4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053f8:	02f71563          	bne	a4,a5,80005422 <piperead+0x5a>
    800053fc:	2244a783          	lw	a5,548(s1)
    80005400:	cb85                	beqz	a5,80005430 <piperead+0x68>
    if(killed(pr)){
    80005402:	8552                	mv	a0,s4
    80005404:	c98fd0ef          	jal	8000289c <killed>
    80005408:	ed19                	bnez	a0,80005426 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000540a:	85a6                	mv	a1,s1
    8000540c:	854e                	mv	a0,s3
    8000540e:	9c2fd0ef          	jal	800025d0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005412:	2184a703          	lw	a4,536(s1)
    80005416:	21c4a783          	lw	a5,540(s1)
    8000541a:	fef701e3          	beq	a4,a5,800053fc <piperead+0x34>
    8000541e:	e85a                	sd	s6,16(sp)
    80005420:	a809                	j	80005432 <piperead+0x6a>
    80005422:	e85a                	sd	s6,16(sp)
    80005424:	a039                	j	80005432 <piperead+0x6a>
      release(&pi->lock);
    80005426:	8526                	mv	a0,s1
    80005428:	83ffb0ef          	jal	80000c66 <release>
      return -1;
    8000542c:	59fd                	li	s3,-1
    8000542e:	a8b9                	j	8000548c <piperead+0xc4>
    80005430:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005432:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005434:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005436:	05505363          	blez	s5,8000547c <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    8000543a:	2184a783          	lw	a5,536(s1)
    8000543e:	21c4a703          	lw	a4,540(s1)
    80005442:	02f70d63          	beq	a4,a5,8000547c <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80005446:	1ff7f793          	andi	a5,a5,511
    8000544a:	97a6                	add	a5,a5,s1
    8000544c:	0187c783          	lbu	a5,24(a5)
    80005450:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005454:	4685                	li	a3,1
    80005456:	fbf40613          	addi	a2,s0,-65
    8000545a:	85ca                	mv	a1,s2
    8000545c:	058a3503          	ld	a0,88(s4)
    80005460:	982fc0ef          	jal	800015e2 <copyout>
    80005464:	03650e63          	beq	a0,s6,800054a0 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80005468:	2184a783          	lw	a5,536(s1)
    8000546c:	2785                	addiw	a5,a5,1
    8000546e:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005472:	2985                	addiw	s3,s3,1
    80005474:	0905                	addi	s2,s2,1
    80005476:	fd3a92e3          	bne	s5,s3,8000543a <piperead+0x72>
    8000547a:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000547c:	21c48513          	addi	a0,s1,540
    80005480:	99cfd0ef          	jal	8000261c <wakeup>
  release(&pi->lock);
    80005484:	8526                	mv	a0,s1
    80005486:	fe0fb0ef          	jal	80000c66 <release>
    8000548a:	6b42                	ld	s6,16(sp)
  return i;
}
    8000548c:	854e                	mv	a0,s3
    8000548e:	60a6                	ld	ra,72(sp)
    80005490:	6406                	ld	s0,64(sp)
    80005492:	74e2                	ld	s1,56(sp)
    80005494:	7942                	ld	s2,48(sp)
    80005496:	79a2                	ld	s3,40(sp)
    80005498:	7a02                	ld	s4,32(sp)
    8000549a:	6ae2                	ld	s5,24(sp)
    8000549c:	6161                	addi	sp,sp,80
    8000549e:	8082                	ret
      if(i == 0)
    800054a0:	fc099ee3          	bnez	s3,8000547c <piperead+0xb4>
        i = -1;
    800054a4:	89aa                	mv	s3,a0
    800054a6:	bfd9                	j	8000547c <piperead+0xb4>

00000000800054a8 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800054a8:	1141                	addi	sp,sp,-16
    800054aa:	e422                	sd	s0,8(sp)
    800054ac:	0800                	addi	s0,sp,16
    800054ae:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800054b0:	8905                	andi	a0,a0,1
    800054b2:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800054b4:	8b89                	andi	a5,a5,2
    800054b6:	c399                	beqz	a5,800054bc <flags2perm+0x14>
      perm |= PTE_W;
    800054b8:	00456513          	ori	a0,a0,4
    return perm;
}
    800054bc:	6422                	ld	s0,8(sp)
    800054be:	0141                	addi	sp,sp,16
    800054c0:	8082                	ret

00000000800054c2 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800054c2:	df010113          	addi	sp,sp,-528
    800054c6:	20113423          	sd	ra,520(sp)
    800054ca:	20813023          	sd	s0,512(sp)
    800054ce:	ffa6                	sd	s1,504(sp)
    800054d0:	fbca                	sd	s2,496(sp)
    800054d2:	0c00                	addi	s0,sp,528
    800054d4:	892a                	mv	s2,a0
    800054d6:	dea43c23          	sd	a0,-520(s0)
    800054da:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800054de:	d18fc0ef          	jal	800019f6 <myproc>
    800054e2:	84aa                	mv	s1,a0

  begin_op();
    800054e4:	dcaff0ef          	jal	80004aae <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800054e8:	854a                	mv	a0,s2
    800054ea:	bf0ff0ef          	jal	800048da <namei>
    800054ee:	c931                	beqz	a0,80005542 <kexec+0x80>
    800054f0:	f3d2                	sd	s4,480(sp)
    800054f2:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800054f4:	bd1fe0ef          	jal	800040c4 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800054f8:	04000713          	li	a4,64
    800054fc:	4681                	li	a3,0
    800054fe:	e5040613          	addi	a2,s0,-432
    80005502:	4581                	li	a1,0
    80005504:	8552                	mv	a0,s4
    80005506:	f4ffe0ef          	jal	80004454 <readi>
    8000550a:	04000793          	li	a5,64
    8000550e:	00f51a63          	bne	a0,a5,80005522 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80005512:	e5042703          	lw	a4,-432(s0)
    80005516:	464c47b7          	lui	a5,0x464c4
    8000551a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000551e:	02f70663          	beq	a4,a5,8000554a <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005522:	8552                	mv	a0,s4
    80005524:	dabfe0ef          	jal	800042ce <iunlockput>
    end_op();
    80005528:	df0ff0ef          	jal	80004b18 <end_op>
  }
  return -1;
    8000552c:	557d                	li	a0,-1
    8000552e:	7a1e                	ld	s4,480(sp)
}
    80005530:	20813083          	ld	ra,520(sp)
    80005534:	20013403          	ld	s0,512(sp)
    80005538:	74fe                	ld	s1,504(sp)
    8000553a:	795e                	ld	s2,496(sp)
    8000553c:	21010113          	addi	sp,sp,528
    80005540:	8082                	ret
    end_op();
    80005542:	dd6ff0ef          	jal	80004b18 <end_op>
    return -1;
    80005546:	557d                	li	a0,-1
    80005548:	b7e5                	j	80005530 <kexec+0x6e>
    8000554a:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000554c:	8526                	mv	a0,s1
    8000554e:	819fc0ef          	jal	80001d66 <proc_pagetable>
    80005552:	8b2a                	mv	s6,a0
    80005554:	2c050b63          	beqz	a0,8000582a <kexec+0x368>
    80005558:	f7ce                	sd	s3,488(sp)
    8000555a:	efd6                	sd	s5,472(sp)
    8000555c:	e7de                	sd	s7,456(sp)
    8000555e:	e3e2                	sd	s8,448(sp)
    80005560:	ff66                	sd	s9,440(sp)
    80005562:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005564:	e7042d03          	lw	s10,-400(s0)
    80005568:	e8845783          	lhu	a5,-376(s0)
    8000556c:	12078963          	beqz	a5,8000569e <kexec+0x1dc>
    80005570:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005572:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005574:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005576:	6c85                	lui	s9,0x1
    80005578:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000557c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005580:	6a85                	lui	s5,0x1
    80005582:	a085                	j	800055e2 <kexec+0x120>
      panic("loadseg: address should exist");
    80005584:	00003517          	auipc	a0,0x3
    80005588:	16450513          	addi	a0,a0,356 # 800086e8 <etext+0x6e8>
    8000558c:	a54fb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    80005590:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005592:	8726                	mv	a4,s1
    80005594:	012c06bb          	addw	a3,s8,s2
    80005598:	4581                	li	a1,0
    8000559a:	8552                	mv	a0,s4
    8000559c:	eb9fe0ef          	jal	80004454 <readi>
    800055a0:	2501                	sext.w	a0,a0
    800055a2:	24a49a63          	bne	s1,a0,800057f6 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800055a6:	012a893b          	addw	s2,s5,s2
    800055aa:	03397363          	bgeu	s2,s3,800055d0 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800055ae:	02091593          	slli	a1,s2,0x20
    800055b2:	9181                	srli	a1,a1,0x20
    800055b4:	95de                	add	a1,a1,s7
    800055b6:	855a                	mv	a0,s6
    800055b8:	9f9fb0ef          	jal	80000fb0 <walkaddr>
    800055bc:	862a                	mv	a2,a0
    if(pa == 0)
    800055be:	d179                	beqz	a0,80005584 <kexec+0xc2>
    if(sz - i < PGSIZE)
    800055c0:	412984bb          	subw	s1,s3,s2
    800055c4:	0004879b          	sext.w	a5,s1
    800055c8:	fcfcf4e3          	bgeu	s9,a5,80005590 <kexec+0xce>
    800055cc:	84d6                	mv	s1,s5
    800055ce:	b7c9                	j	80005590 <kexec+0xce>
    sz = sz1;
    800055d0:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055d4:	2d85                	addiw	s11,s11,1
    800055d6:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800055da:	e8845783          	lhu	a5,-376(s0)
    800055de:	08fdd063          	bge	s11,a5,8000565e <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800055e2:	2d01                	sext.w	s10,s10
    800055e4:	03800713          	li	a4,56
    800055e8:	86ea                	mv	a3,s10
    800055ea:	e1840613          	addi	a2,s0,-488
    800055ee:	4581                	li	a1,0
    800055f0:	8552                	mv	a0,s4
    800055f2:	e63fe0ef          	jal	80004454 <readi>
    800055f6:	03800793          	li	a5,56
    800055fa:	1cf51663          	bne	a0,a5,800057c6 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800055fe:	e1842783          	lw	a5,-488(s0)
    80005602:	4705                	li	a4,1
    80005604:	fce798e3          	bne	a5,a4,800055d4 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80005608:	e4043483          	ld	s1,-448(s0)
    8000560c:	e3843783          	ld	a5,-456(s0)
    80005610:	1af4ef63          	bltu	s1,a5,800057ce <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005614:	e2843783          	ld	a5,-472(s0)
    80005618:	94be                	add	s1,s1,a5
    8000561a:	1af4ee63          	bltu	s1,a5,800057d6 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    8000561e:	df043703          	ld	a4,-528(s0)
    80005622:	8ff9                	and	a5,a5,a4
    80005624:	1a079d63          	bnez	a5,800057de <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005628:	e1c42503          	lw	a0,-484(s0)
    8000562c:	e7dff0ef          	jal	800054a8 <flags2perm>
    80005630:	86aa                	mv	a3,a0
    80005632:	8626                	mv	a2,s1
    80005634:	85ca                	mv	a1,s2
    80005636:	855a                	mv	a0,s6
    80005638:	c51fb0ef          	jal	80001288 <uvmalloc>
    8000563c:	e0a43423          	sd	a0,-504(s0)
    80005640:	1a050363          	beqz	a0,800057e6 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005644:	e2843b83          	ld	s7,-472(s0)
    80005648:	e2042c03          	lw	s8,-480(s0)
    8000564c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005650:	00098463          	beqz	s3,80005658 <kexec+0x196>
    80005654:	4901                	li	s2,0
    80005656:	bfa1                	j	800055ae <kexec+0xec>
    sz = sz1;
    80005658:	e0843903          	ld	s2,-504(s0)
    8000565c:	bfa5                	j	800055d4 <kexec+0x112>
    8000565e:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005660:	8552                	mv	a0,s4
    80005662:	c6dfe0ef          	jal	800042ce <iunlockput>
  end_op();
    80005666:	cb2ff0ef          	jal	80004b18 <end_op>
  p = myproc();
    8000566a:	b8cfc0ef          	jal	800019f6 <myproc>
    8000566e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005670:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    80005674:	6985                	lui	s3,0x1
    80005676:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005678:	99ca                	add	s3,s3,s2
    8000567a:	77fd                	lui	a5,0xfffff
    8000567c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005680:	4691                	li	a3,4
    80005682:	6609                	lui	a2,0x2
    80005684:	964e                	add	a2,a2,s3
    80005686:	85ce                	mv	a1,s3
    80005688:	855a                	mv	a0,s6
    8000568a:	bfffb0ef          	jal	80001288 <uvmalloc>
    8000568e:	892a                	mv	s2,a0
    80005690:	e0a43423          	sd	a0,-504(s0)
    80005694:	e519                	bnez	a0,800056a2 <kexec+0x1e0>
  if(pagetable)
    80005696:	e1343423          	sd	s3,-504(s0)
    8000569a:	4a01                	li	s4,0
    8000569c:	aab1                	j	800057f8 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000569e:	4901                	li	s2,0
    800056a0:	b7c1                	j	80005660 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800056a2:	75f9                	lui	a1,0xffffe
    800056a4:	95aa                	add	a1,a1,a0
    800056a6:	855a                	mv	a0,s6
    800056a8:	db7fb0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800056ac:	7bfd                	lui	s7,0xfffff
    800056ae:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800056b0:	e0043783          	ld	a5,-512(s0)
    800056b4:	6388                	ld	a0,0(a5)
    800056b6:	cd39                	beqz	a0,80005714 <kexec+0x252>
    800056b8:	e9040993          	addi	s3,s0,-368
    800056bc:	f9040c13          	addi	s8,s0,-112
    800056c0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800056c2:	f50fb0ef          	jal	80000e12 <strlen>
    800056c6:	0015079b          	addiw	a5,a0,1
    800056ca:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800056ce:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800056d2:	11796e63          	bltu	s2,s7,800057ee <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800056d6:	e0043d03          	ld	s10,-512(s0)
    800056da:	000d3a03          	ld	s4,0(s10)
    800056de:	8552                	mv	a0,s4
    800056e0:	f32fb0ef          	jal	80000e12 <strlen>
    800056e4:	0015069b          	addiw	a3,a0,1
    800056e8:	8652                	mv	a2,s4
    800056ea:	85ca                	mv	a1,s2
    800056ec:	855a                	mv	a0,s6
    800056ee:	ef5fb0ef          	jal	800015e2 <copyout>
    800056f2:	10054063          	bltz	a0,800057f2 <kexec+0x330>
    ustack[argc] = sp;
    800056f6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800056fa:	0485                	addi	s1,s1,1
    800056fc:	008d0793          	addi	a5,s10,8
    80005700:	e0f43023          	sd	a5,-512(s0)
    80005704:	008d3503          	ld	a0,8(s10)
    80005708:	c909                	beqz	a0,8000571a <kexec+0x258>
    if(argc >= MAXARG)
    8000570a:	09a1                	addi	s3,s3,8
    8000570c:	fb899be3          	bne	s3,s8,800056c2 <kexec+0x200>
  ip = 0;
    80005710:	4a01                	li	s4,0
    80005712:	a0dd                	j	800057f8 <kexec+0x336>
  sp = sz;
    80005714:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005718:	4481                	li	s1,0
  ustack[argc] = 0;
    8000571a:	00349793          	slli	a5,s1,0x3
    8000571e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd99a8>
    80005722:	97a2                	add	a5,a5,s0
    80005724:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005728:	00148693          	addi	a3,s1,1
    8000572c:	068e                	slli	a3,a3,0x3
    8000572e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005732:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005736:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000573a:	f5796ee3          	bltu	s2,s7,80005696 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000573e:	e9040613          	addi	a2,s0,-368
    80005742:	85ca                	mv	a1,s2
    80005744:	855a                	mv	a0,s6
    80005746:	e9dfb0ef          	jal	800015e2 <copyout>
    8000574a:	0e054263          	bltz	a0,8000582e <kexec+0x36c>
  p->trapframe->a1 = sp;
    8000574e:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    80005752:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005756:	df843783          	ld	a5,-520(s0)
    8000575a:	0007c703          	lbu	a4,0(a5)
    8000575e:	cf11                	beqz	a4,8000577a <kexec+0x2b8>
    80005760:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005762:	02f00693          	li	a3,47
    80005766:	a039                	j	80005774 <kexec+0x2b2>
      last = s+1;
    80005768:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000576c:	0785                	addi	a5,a5,1
    8000576e:	fff7c703          	lbu	a4,-1(a5)
    80005772:	c701                	beqz	a4,8000577a <kexec+0x2b8>
    if(*s == '/')
    80005774:	fed71ce3          	bne	a4,a3,8000576c <kexec+0x2aa>
    80005778:	bfc5                	j	80005768 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    8000577a:	4641                	li	a2,16
    8000577c:	df843583          	ld	a1,-520(s0)
    80005780:	160a8513          	addi	a0,s5,352
    80005784:	e5cfb0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80005788:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    8000578c:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    80005790:	e0843783          	ld	a5,-504(s0)
    80005794:	04fab823          	sd	a5,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80005798:	060ab783          	ld	a5,96(s5)
    8000579c:	e6843703          	ld	a4,-408(s0)
    800057a0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800057a2:	060ab783          	ld	a5,96(s5)
    800057a6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800057aa:	85e6                	mv	a1,s9
    800057ac:	e3efc0ef          	jal	80001dea <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800057b0:	0004851b          	sext.w	a0,s1
    800057b4:	79be                	ld	s3,488(sp)
    800057b6:	7a1e                	ld	s4,480(sp)
    800057b8:	6afe                	ld	s5,472(sp)
    800057ba:	6b5e                	ld	s6,464(sp)
    800057bc:	6bbe                	ld	s7,456(sp)
    800057be:	6c1e                	ld	s8,448(sp)
    800057c0:	7cfa                	ld	s9,440(sp)
    800057c2:	7d5a                	ld	s10,432(sp)
    800057c4:	b3b5                	j	80005530 <kexec+0x6e>
    800057c6:	e1243423          	sd	s2,-504(s0)
    800057ca:	7dba                	ld	s11,424(sp)
    800057cc:	a035                	j	800057f8 <kexec+0x336>
    800057ce:	e1243423          	sd	s2,-504(s0)
    800057d2:	7dba                	ld	s11,424(sp)
    800057d4:	a015                	j	800057f8 <kexec+0x336>
    800057d6:	e1243423          	sd	s2,-504(s0)
    800057da:	7dba                	ld	s11,424(sp)
    800057dc:	a831                	j	800057f8 <kexec+0x336>
    800057de:	e1243423          	sd	s2,-504(s0)
    800057e2:	7dba                	ld	s11,424(sp)
    800057e4:	a811                	j	800057f8 <kexec+0x336>
    800057e6:	e1243423          	sd	s2,-504(s0)
    800057ea:	7dba                	ld	s11,424(sp)
    800057ec:	a031                	j	800057f8 <kexec+0x336>
  ip = 0;
    800057ee:	4a01                	li	s4,0
    800057f0:	a021                	j	800057f8 <kexec+0x336>
    800057f2:	4a01                	li	s4,0
  if(pagetable)
    800057f4:	a011                	j	800057f8 <kexec+0x336>
    800057f6:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800057f8:	e0843583          	ld	a1,-504(s0)
    800057fc:	855a                	mv	a0,s6
    800057fe:	decfc0ef          	jal	80001dea <proc_freepagetable>
  return -1;
    80005802:	557d                	li	a0,-1
  if(ip){
    80005804:	000a1b63          	bnez	s4,8000581a <kexec+0x358>
    80005808:	79be                	ld	s3,488(sp)
    8000580a:	7a1e                	ld	s4,480(sp)
    8000580c:	6afe                	ld	s5,472(sp)
    8000580e:	6b5e                	ld	s6,464(sp)
    80005810:	6bbe                	ld	s7,456(sp)
    80005812:	6c1e                	ld	s8,448(sp)
    80005814:	7cfa                	ld	s9,440(sp)
    80005816:	7d5a                	ld	s10,432(sp)
    80005818:	bb21                	j	80005530 <kexec+0x6e>
    8000581a:	79be                	ld	s3,488(sp)
    8000581c:	6afe                	ld	s5,472(sp)
    8000581e:	6b5e                	ld	s6,464(sp)
    80005820:	6bbe                	ld	s7,456(sp)
    80005822:	6c1e                	ld	s8,448(sp)
    80005824:	7cfa                	ld	s9,440(sp)
    80005826:	7d5a                	ld	s10,432(sp)
    80005828:	b9ed                	j	80005522 <kexec+0x60>
    8000582a:	6b5e                	ld	s6,464(sp)
    8000582c:	b9dd                	j	80005522 <kexec+0x60>
  sz = sz1;
    8000582e:	e0843983          	ld	s3,-504(s0)
    80005832:	b595                	j	80005696 <kexec+0x1d4>

0000000080005834 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005834:	7179                	addi	sp,sp,-48
    80005836:	f406                	sd	ra,40(sp)
    80005838:	f022                	sd	s0,32(sp)
    8000583a:	ec26                	sd	s1,24(sp)
    8000583c:	e84a                	sd	s2,16(sp)
    8000583e:	1800                	addi	s0,sp,48
    80005840:	892e                	mv	s2,a1
    80005842:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005844:	fdc40593          	addi	a1,s0,-36
    80005848:	8fbfd0ef          	jal	80003142 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000584c:	fdc42703          	lw	a4,-36(s0)
    80005850:	47bd                	li	a5,15
    80005852:	02e7e963          	bltu	a5,a4,80005884 <argfd+0x50>
    80005856:	9a0fc0ef          	jal	800019f6 <myproc>
    8000585a:	fdc42703          	lw	a4,-36(s0)
    8000585e:	01a70793          	addi	a5,a4,26
    80005862:	078e                	slli	a5,a5,0x3
    80005864:	953e                	add	a0,a0,a5
    80005866:	651c                	ld	a5,8(a0)
    80005868:	c385                	beqz	a5,80005888 <argfd+0x54>
    return -1;
  if(pfd)
    8000586a:	00090463          	beqz	s2,80005872 <argfd+0x3e>
    *pfd = fd;
    8000586e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005872:	4501                	li	a0,0
  if(pf)
    80005874:	c091                	beqz	s1,80005878 <argfd+0x44>
    *pf = f;
    80005876:	e09c                	sd	a5,0(s1)
}
    80005878:	70a2                	ld	ra,40(sp)
    8000587a:	7402                	ld	s0,32(sp)
    8000587c:	64e2                	ld	s1,24(sp)
    8000587e:	6942                	ld	s2,16(sp)
    80005880:	6145                	addi	sp,sp,48
    80005882:	8082                	ret
    return -1;
    80005884:	557d                	li	a0,-1
    80005886:	bfcd                	j	80005878 <argfd+0x44>
    80005888:	557d                	li	a0,-1
    8000588a:	b7fd                	j	80005878 <argfd+0x44>

000000008000588c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000588c:	1101                	addi	sp,sp,-32
    8000588e:	ec06                	sd	ra,24(sp)
    80005890:	e822                	sd	s0,16(sp)
    80005892:	e426                	sd	s1,8(sp)
    80005894:	1000                	addi	s0,sp,32
    80005896:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005898:	95efc0ef          	jal	800019f6 <myproc>
    8000589c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000589e:	0d850793          	addi	a5,a0,216
    800058a2:	4501                	li	a0,0
    800058a4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800058a6:	6398                	ld	a4,0(a5)
    800058a8:	cb19                	beqz	a4,800058be <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800058aa:	2505                	addiw	a0,a0,1
    800058ac:	07a1                	addi	a5,a5,8
    800058ae:	fed51ce3          	bne	a0,a3,800058a6 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800058b2:	557d                	li	a0,-1
}
    800058b4:	60e2                	ld	ra,24(sp)
    800058b6:	6442                	ld	s0,16(sp)
    800058b8:	64a2                	ld	s1,8(sp)
    800058ba:	6105                	addi	sp,sp,32
    800058bc:	8082                	ret
      p->ofile[fd] = f;
    800058be:	01a50793          	addi	a5,a0,26
    800058c2:	078e                	slli	a5,a5,0x3
    800058c4:	963e                	add	a2,a2,a5
    800058c6:	e604                	sd	s1,8(a2)
      return fd;
    800058c8:	b7f5                	j	800058b4 <fdalloc+0x28>

00000000800058ca <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800058ca:	715d                	addi	sp,sp,-80
    800058cc:	e486                	sd	ra,72(sp)
    800058ce:	e0a2                	sd	s0,64(sp)
    800058d0:	fc26                	sd	s1,56(sp)
    800058d2:	f84a                	sd	s2,48(sp)
    800058d4:	f44e                	sd	s3,40(sp)
    800058d6:	ec56                	sd	s5,24(sp)
    800058d8:	e85a                	sd	s6,16(sp)
    800058da:	0880                	addi	s0,sp,80
    800058dc:	8b2e                	mv	s6,a1
    800058de:	89b2                	mv	s3,a2
    800058e0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800058e2:	fb040593          	addi	a1,s0,-80
    800058e6:	80eff0ef          	jal	800048f4 <nameiparent>
    800058ea:	84aa                	mv	s1,a0
    800058ec:	10050a63          	beqz	a0,80005a00 <create+0x136>
    return 0;

  ilock(dp);
    800058f0:	fd4fe0ef          	jal	800040c4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800058f4:	4601                	li	a2,0
    800058f6:	fb040593          	addi	a1,s0,-80
    800058fa:	8526                	mv	a0,s1
    800058fc:	d79fe0ef          	jal	80004674 <dirlookup>
    80005900:	8aaa                	mv	s5,a0
    80005902:	c129                	beqz	a0,80005944 <create+0x7a>
    iunlockput(dp);
    80005904:	8526                	mv	a0,s1
    80005906:	9c9fe0ef          	jal	800042ce <iunlockput>
    ilock(ip);
    8000590a:	8556                	mv	a0,s5
    8000590c:	fb8fe0ef          	jal	800040c4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005910:	4789                	li	a5,2
    80005912:	02fb1463          	bne	s6,a5,8000593a <create+0x70>
    80005916:	044ad783          	lhu	a5,68(s5)
    8000591a:	37f9                	addiw	a5,a5,-2
    8000591c:	17c2                	slli	a5,a5,0x30
    8000591e:	93c1                	srli	a5,a5,0x30
    80005920:	4705                	li	a4,1
    80005922:	00f76c63          	bltu	a4,a5,8000593a <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005926:	8556                	mv	a0,s5
    80005928:	60a6                	ld	ra,72(sp)
    8000592a:	6406                	ld	s0,64(sp)
    8000592c:	74e2                	ld	s1,56(sp)
    8000592e:	7942                	ld	s2,48(sp)
    80005930:	79a2                	ld	s3,40(sp)
    80005932:	6ae2                	ld	s5,24(sp)
    80005934:	6b42                	ld	s6,16(sp)
    80005936:	6161                	addi	sp,sp,80
    80005938:	8082                	ret
    iunlockput(ip);
    8000593a:	8556                	mv	a0,s5
    8000593c:	993fe0ef          	jal	800042ce <iunlockput>
    return 0;
    80005940:	4a81                	li	s5,0
    80005942:	b7d5                	j	80005926 <create+0x5c>
    80005944:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005946:	85da                	mv	a1,s6
    80005948:	4088                	lw	a0,0(s1)
    8000594a:	e0afe0ef          	jal	80003f54 <ialloc>
    8000594e:	8a2a                	mv	s4,a0
    80005950:	cd15                	beqz	a0,8000598c <create+0xc2>
  ilock(ip);
    80005952:	f72fe0ef          	jal	800040c4 <ilock>
  ip->major = major;
    80005956:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000595a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000595e:	4905                	li	s2,1
    80005960:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005964:	8552                	mv	a0,s4
    80005966:	eaafe0ef          	jal	80004010 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000596a:	032b0763          	beq	s6,s2,80005998 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    8000596e:	004a2603          	lw	a2,4(s4)
    80005972:	fb040593          	addi	a1,s0,-80
    80005976:	8526                	mv	a0,s1
    80005978:	ec9fe0ef          	jal	80004840 <dirlink>
    8000597c:	06054563          	bltz	a0,800059e6 <create+0x11c>
  iunlockput(dp);
    80005980:	8526                	mv	a0,s1
    80005982:	94dfe0ef          	jal	800042ce <iunlockput>
  return ip;
    80005986:	8ad2                	mv	s5,s4
    80005988:	7a02                	ld	s4,32(sp)
    8000598a:	bf71                	j	80005926 <create+0x5c>
    iunlockput(dp);
    8000598c:	8526                	mv	a0,s1
    8000598e:	941fe0ef          	jal	800042ce <iunlockput>
    return 0;
    80005992:	8ad2                	mv	s5,s4
    80005994:	7a02                	ld	s4,32(sp)
    80005996:	bf41                	j	80005926 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005998:	004a2603          	lw	a2,4(s4)
    8000599c:	00003597          	auipc	a1,0x3
    800059a0:	d6c58593          	addi	a1,a1,-660 # 80008708 <etext+0x708>
    800059a4:	8552                	mv	a0,s4
    800059a6:	e9bfe0ef          	jal	80004840 <dirlink>
    800059aa:	02054e63          	bltz	a0,800059e6 <create+0x11c>
    800059ae:	40d0                	lw	a2,4(s1)
    800059b0:	00003597          	auipc	a1,0x3
    800059b4:	d6058593          	addi	a1,a1,-672 # 80008710 <etext+0x710>
    800059b8:	8552                	mv	a0,s4
    800059ba:	e87fe0ef          	jal	80004840 <dirlink>
    800059be:	02054463          	bltz	a0,800059e6 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800059c2:	004a2603          	lw	a2,4(s4)
    800059c6:	fb040593          	addi	a1,s0,-80
    800059ca:	8526                	mv	a0,s1
    800059cc:	e75fe0ef          	jal	80004840 <dirlink>
    800059d0:	00054b63          	bltz	a0,800059e6 <create+0x11c>
    dp->nlink++;  // for ".."
    800059d4:	04a4d783          	lhu	a5,74(s1)
    800059d8:	2785                	addiw	a5,a5,1
    800059da:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059de:	8526                	mv	a0,s1
    800059e0:	e30fe0ef          	jal	80004010 <iupdate>
    800059e4:	bf71                	j	80005980 <create+0xb6>
  ip->nlink = 0;
    800059e6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800059ea:	8552                	mv	a0,s4
    800059ec:	e24fe0ef          	jal	80004010 <iupdate>
  iunlockput(ip);
    800059f0:	8552                	mv	a0,s4
    800059f2:	8ddfe0ef          	jal	800042ce <iunlockput>
  iunlockput(dp);
    800059f6:	8526                	mv	a0,s1
    800059f8:	8d7fe0ef          	jal	800042ce <iunlockput>
  return 0;
    800059fc:	7a02                	ld	s4,32(sp)
    800059fe:	b725                	j	80005926 <create+0x5c>
    return 0;
    80005a00:	8aaa                	mv	s5,a0
    80005a02:	b715                	j	80005926 <create+0x5c>

0000000080005a04 <sys_dup>:
{
    80005a04:	7179                	addi	sp,sp,-48
    80005a06:	f406                	sd	ra,40(sp)
    80005a08:	f022                	sd	s0,32(sp)
    80005a0a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005a0c:	fd840613          	addi	a2,s0,-40
    80005a10:	4581                	li	a1,0
    80005a12:	4501                	li	a0,0
    80005a14:	e21ff0ef          	jal	80005834 <argfd>
    return -1;
    80005a18:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005a1a:	02054363          	bltz	a0,80005a40 <sys_dup+0x3c>
    80005a1e:	ec26                	sd	s1,24(sp)
    80005a20:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005a22:	fd843903          	ld	s2,-40(s0)
    80005a26:	854a                	mv	a0,s2
    80005a28:	e65ff0ef          	jal	8000588c <fdalloc>
    80005a2c:	84aa                	mv	s1,a0
    return -1;
    80005a2e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005a30:	00054d63          	bltz	a0,80005a4a <sys_dup+0x46>
  filedup(f);
    80005a34:	854a                	mv	a0,s2
    80005a36:	c3eff0ef          	jal	80004e74 <filedup>
  return fd;
    80005a3a:	87a6                	mv	a5,s1
    80005a3c:	64e2                	ld	s1,24(sp)
    80005a3e:	6942                	ld	s2,16(sp)
}
    80005a40:	853e                	mv	a0,a5
    80005a42:	70a2                	ld	ra,40(sp)
    80005a44:	7402                	ld	s0,32(sp)
    80005a46:	6145                	addi	sp,sp,48
    80005a48:	8082                	ret
    80005a4a:	64e2                	ld	s1,24(sp)
    80005a4c:	6942                	ld	s2,16(sp)
    80005a4e:	bfcd                	j	80005a40 <sys_dup+0x3c>

0000000080005a50 <sys_read>:
{
    80005a50:	7179                	addi	sp,sp,-48
    80005a52:	f406                	sd	ra,40(sp)
    80005a54:	f022                	sd	s0,32(sp)
    80005a56:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a58:	fd840593          	addi	a1,s0,-40
    80005a5c:	4505                	li	a0,1
    80005a5e:	f00fd0ef          	jal	8000315e <argaddr>
  argint(2, &n);
    80005a62:	fe440593          	addi	a1,s0,-28
    80005a66:	4509                	li	a0,2
    80005a68:	edafd0ef          	jal	80003142 <argint>
  if(argfd(0, 0, &f) < 0)
    80005a6c:	fe840613          	addi	a2,s0,-24
    80005a70:	4581                	li	a1,0
    80005a72:	4501                	li	a0,0
    80005a74:	dc1ff0ef          	jal	80005834 <argfd>
    80005a78:	87aa                	mv	a5,a0
    return -1;
    80005a7a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a7c:	0007ca63          	bltz	a5,80005a90 <sys_read+0x40>
  return fileread(f, p, n);
    80005a80:	fe442603          	lw	a2,-28(s0)
    80005a84:	fd843583          	ld	a1,-40(s0)
    80005a88:	fe843503          	ld	a0,-24(s0)
    80005a8c:	d4eff0ef          	jal	80004fda <fileread>
}
    80005a90:	70a2                	ld	ra,40(sp)
    80005a92:	7402                	ld	s0,32(sp)
    80005a94:	6145                	addi	sp,sp,48
    80005a96:	8082                	ret

0000000080005a98 <sys_write>:
{
    80005a98:	7179                	addi	sp,sp,-48
    80005a9a:	f406                	sd	ra,40(sp)
    80005a9c:	f022                	sd	s0,32(sp)
    80005a9e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005aa0:	fd840593          	addi	a1,s0,-40
    80005aa4:	4505                	li	a0,1
    80005aa6:	eb8fd0ef          	jal	8000315e <argaddr>
  argint(2, &n);
    80005aaa:	fe440593          	addi	a1,s0,-28
    80005aae:	4509                	li	a0,2
    80005ab0:	e92fd0ef          	jal	80003142 <argint>
  if(argfd(0, 0, &f) < 0)
    80005ab4:	fe840613          	addi	a2,s0,-24
    80005ab8:	4581                	li	a1,0
    80005aba:	4501                	li	a0,0
    80005abc:	d79ff0ef          	jal	80005834 <argfd>
    80005ac0:	87aa                	mv	a5,a0
    return -1;
    80005ac2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005ac4:	0007ca63          	bltz	a5,80005ad8 <sys_write+0x40>
  return filewrite(f, p, n);
    80005ac8:	fe442603          	lw	a2,-28(s0)
    80005acc:	fd843583          	ld	a1,-40(s0)
    80005ad0:	fe843503          	ld	a0,-24(s0)
    80005ad4:	dc4ff0ef          	jal	80005098 <filewrite>
}
    80005ad8:	70a2                	ld	ra,40(sp)
    80005ada:	7402                	ld	s0,32(sp)
    80005adc:	6145                	addi	sp,sp,48
    80005ade:	8082                	ret

0000000080005ae0 <sys_close>:
{
    80005ae0:	1101                	addi	sp,sp,-32
    80005ae2:	ec06                	sd	ra,24(sp)
    80005ae4:	e822                	sd	s0,16(sp)
    80005ae6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005ae8:	fe040613          	addi	a2,s0,-32
    80005aec:	fec40593          	addi	a1,s0,-20
    80005af0:	4501                	li	a0,0
    80005af2:	d43ff0ef          	jal	80005834 <argfd>
    return -1;
    80005af6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005af8:	02054063          	bltz	a0,80005b18 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005afc:	efbfb0ef          	jal	800019f6 <myproc>
    80005b00:	fec42783          	lw	a5,-20(s0)
    80005b04:	07e9                	addi	a5,a5,26
    80005b06:	078e                	slli	a5,a5,0x3
    80005b08:	953e                	add	a0,a0,a5
    80005b0a:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005b0e:	fe043503          	ld	a0,-32(s0)
    80005b12:	ba8ff0ef          	jal	80004eba <fileclose>
  return 0;
    80005b16:	4781                	li	a5,0
}
    80005b18:	853e                	mv	a0,a5
    80005b1a:	60e2                	ld	ra,24(sp)
    80005b1c:	6442                	ld	s0,16(sp)
    80005b1e:	6105                	addi	sp,sp,32
    80005b20:	8082                	ret

0000000080005b22 <sys_fstat>:
{
    80005b22:	1101                	addi	sp,sp,-32
    80005b24:	ec06                	sd	ra,24(sp)
    80005b26:	e822                	sd	s0,16(sp)
    80005b28:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005b2a:	fe040593          	addi	a1,s0,-32
    80005b2e:	4505                	li	a0,1
    80005b30:	e2efd0ef          	jal	8000315e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005b34:	fe840613          	addi	a2,s0,-24
    80005b38:	4581                	li	a1,0
    80005b3a:	4501                	li	a0,0
    80005b3c:	cf9ff0ef          	jal	80005834 <argfd>
    80005b40:	87aa                	mv	a5,a0
    return -1;
    80005b42:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b44:	0007c863          	bltz	a5,80005b54 <sys_fstat+0x32>
  return filestat(f, st);
    80005b48:	fe043583          	ld	a1,-32(s0)
    80005b4c:	fe843503          	ld	a0,-24(s0)
    80005b50:	c2cff0ef          	jal	80004f7c <filestat>
}
    80005b54:	60e2                	ld	ra,24(sp)
    80005b56:	6442                	ld	s0,16(sp)
    80005b58:	6105                	addi	sp,sp,32
    80005b5a:	8082                	ret

0000000080005b5c <sys_link>:
{
    80005b5c:	7169                	addi	sp,sp,-304
    80005b5e:	f606                	sd	ra,296(sp)
    80005b60:	f222                	sd	s0,288(sp)
    80005b62:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b64:	08000613          	li	a2,128
    80005b68:	ed040593          	addi	a1,s0,-304
    80005b6c:	4501                	li	a0,0
    80005b6e:	e0cfd0ef          	jal	8000317a <argstr>
    return -1;
    80005b72:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b74:	0c054e63          	bltz	a0,80005c50 <sys_link+0xf4>
    80005b78:	08000613          	li	a2,128
    80005b7c:	f5040593          	addi	a1,s0,-176
    80005b80:	4505                	li	a0,1
    80005b82:	df8fd0ef          	jal	8000317a <argstr>
    return -1;
    80005b86:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b88:	0c054463          	bltz	a0,80005c50 <sys_link+0xf4>
    80005b8c:	ee26                	sd	s1,280(sp)
  begin_op();
    80005b8e:	f21fe0ef          	jal	80004aae <begin_op>
  if((ip = namei(old)) == 0){
    80005b92:	ed040513          	addi	a0,s0,-304
    80005b96:	d45fe0ef          	jal	800048da <namei>
    80005b9a:	84aa                	mv	s1,a0
    80005b9c:	c53d                	beqz	a0,80005c0a <sys_link+0xae>
  ilock(ip);
    80005b9e:	d26fe0ef          	jal	800040c4 <ilock>
  if(ip->type == T_DIR){
    80005ba2:	04449703          	lh	a4,68(s1)
    80005ba6:	4785                	li	a5,1
    80005ba8:	06f70663          	beq	a4,a5,80005c14 <sys_link+0xb8>
    80005bac:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005bae:	04a4d783          	lhu	a5,74(s1)
    80005bb2:	2785                	addiw	a5,a5,1
    80005bb4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005bb8:	8526                	mv	a0,s1
    80005bba:	c56fe0ef          	jal	80004010 <iupdate>
  iunlock(ip);
    80005bbe:	8526                	mv	a0,s1
    80005bc0:	db2fe0ef          	jal	80004172 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005bc4:	fd040593          	addi	a1,s0,-48
    80005bc8:	f5040513          	addi	a0,s0,-176
    80005bcc:	d29fe0ef          	jal	800048f4 <nameiparent>
    80005bd0:	892a                	mv	s2,a0
    80005bd2:	cd21                	beqz	a0,80005c2a <sys_link+0xce>
  ilock(dp);
    80005bd4:	cf0fe0ef          	jal	800040c4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005bd8:	00092703          	lw	a4,0(s2)
    80005bdc:	409c                	lw	a5,0(s1)
    80005bde:	04f71363          	bne	a4,a5,80005c24 <sys_link+0xc8>
    80005be2:	40d0                	lw	a2,4(s1)
    80005be4:	fd040593          	addi	a1,s0,-48
    80005be8:	854a                	mv	a0,s2
    80005bea:	c57fe0ef          	jal	80004840 <dirlink>
    80005bee:	02054b63          	bltz	a0,80005c24 <sys_link+0xc8>
  iunlockput(dp);
    80005bf2:	854a                	mv	a0,s2
    80005bf4:	edafe0ef          	jal	800042ce <iunlockput>
  iput(ip);
    80005bf8:	8526                	mv	a0,s1
    80005bfa:	e4cfe0ef          	jal	80004246 <iput>
  end_op();
    80005bfe:	f1bfe0ef          	jal	80004b18 <end_op>
  return 0;
    80005c02:	4781                	li	a5,0
    80005c04:	64f2                	ld	s1,280(sp)
    80005c06:	6952                	ld	s2,272(sp)
    80005c08:	a0a1                	j	80005c50 <sys_link+0xf4>
    end_op();
    80005c0a:	f0ffe0ef          	jal	80004b18 <end_op>
    return -1;
    80005c0e:	57fd                	li	a5,-1
    80005c10:	64f2                	ld	s1,280(sp)
    80005c12:	a83d                	j	80005c50 <sys_link+0xf4>
    iunlockput(ip);
    80005c14:	8526                	mv	a0,s1
    80005c16:	eb8fe0ef          	jal	800042ce <iunlockput>
    end_op();
    80005c1a:	efffe0ef          	jal	80004b18 <end_op>
    return -1;
    80005c1e:	57fd                	li	a5,-1
    80005c20:	64f2                	ld	s1,280(sp)
    80005c22:	a03d                	j	80005c50 <sys_link+0xf4>
    iunlockput(dp);
    80005c24:	854a                	mv	a0,s2
    80005c26:	ea8fe0ef          	jal	800042ce <iunlockput>
  ilock(ip);
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	c98fe0ef          	jal	800040c4 <ilock>
  ip->nlink--;
    80005c30:	04a4d783          	lhu	a5,74(s1)
    80005c34:	37fd                	addiw	a5,a5,-1
    80005c36:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c3a:	8526                	mv	a0,s1
    80005c3c:	bd4fe0ef          	jal	80004010 <iupdate>
  iunlockput(ip);
    80005c40:	8526                	mv	a0,s1
    80005c42:	e8cfe0ef          	jal	800042ce <iunlockput>
  end_op();
    80005c46:	ed3fe0ef          	jal	80004b18 <end_op>
  return -1;
    80005c4a:	57fd                	li	a5,-1
    80005c4c:	64f2                	ld	s1,280(sp)
    80005c4e:	6952                	ld	s2,272(sp)
}
    80005c50:	853e                	mv	a0,a5
    80005c52:	70b2                	ld	ra,296(sp)
    80005c54:	7412                	ld	s0,288(sp)
    80005c56:	6155                	addi	sp,sp,304
    80005c58:	8082                	ret

0000000080005c5a <sys_unlink>:
{
    80005c5a:	7151                	addi	sp,sp,-240
    80005c5c:	f586                	sd	ra,232(sp)
    80005c5e:	f1a2                	sd	s0,224(sp)
    80005c60:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c62:	08000613          	li	a2,128
    80005c66:	f3040593          	addi	a1,s0,-208
    80005c6a:	4501                	li	a0,0
    80005c6c:	d0efd0ef          	jal	8000317a <argstr>
    80005c70:	16054063          	bltz	a0,80005dd0 <sys_unlink+0x176>
    80005c74:	eda6                	sd	s1,216(sp)
  begin_op();
    80005c76:	e39fe0ef          	jal	80004aae <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005c7a:	fb040593          	addi	a1,s0,-80
    80005c7e:	f3040513          	addi	a0,s0,-208
    80005c82:	c73fe0ef          	jal	800048f4 <nameiparent>
    80005c86:	84aa                	mv	s1,a0
    80005c88:	c945                	beqz	a0,80005d38 <sys_unlink+0xde>
  ilock(dp);
    80005c8a:	c3afe0ef          	jal	800040c4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005c8e:	00003597          	auipc	a1,0x3
    80005c92:	a7a58593          	addi	a1,a1,-1414 # 80008708 <etext+0x708>
    80005c96:	fb040513          	addi	a0,s0,-80
    80005c9a:	9c5fe0ef          	jal	8000465e <namecmp>
    80005c9e:	10050e63          	beqz	a0,80005dba <sys_unlink+0x160>
    80005ca2:	00003597          	auipc	a1,0x3
    80005ca6:	a6e58593          	addi	a1,a1,-1426 # 80008710 <etext+0x710>
    80005caa:	fb040513          	addi	a0,s0,-80
    80005cae:	9b1fe0ef          	jal	8000465e <namecmp>
    80005cb2:	10050463          	beqz	a0,80005dba <sys_unlink+0x160>
    80005cb6:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005cb8:	f2c40613          	addi	a2,s0,-212
    80005cbc:	fb040593          	addi	a1,s0,-80
    80005cc0:	8526                	mv	a0,s1
    80005cc2:	9b3fe0ef          	jal	80004674 <dirlookup>
    80005cc6:	892a                	mv	s2,a0
    80005cc8:	0e050863          	beqz	a0,80005db8 <sys_unlink+0x15e>
  ilock(ip);
    80005ccc:	bf8fe0ef          	jal	800040c4 <ilock>
  if(ip->nlink < 1)
    80005cd0:	04a91783          	lh	a5,74(s2)
    80005cd4:	06f05763          	blez	a5,80005d42 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005cd8:	04491703          	lh	a4,68(s2)
    80005cdc:	4785                	li	a5,1
    80005cde:	06f70963          	beq	a4,a5,80005d50 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005ce2:	4641                	li	a2,16
    80005ce4:	4581                	li	a1,0
    80005ce6:	fc040513          	addi	a0,s0,-64
    80005cea:	fb9fa0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005cee:	4741                	li	a4,16
    80005cf0:	f2c42683          	lw	a3,-212(s0)
    80005cf4:	fc040613          	addi	a2,s0,-64
    80005cf8:	4581                	li	a1,0
    80005cfa:	8526                	mv	a0,s1
    80005cfc:	855fe0ef          	jal	80004550 <writei>
    80005d00:	47c1                	li	a5,16
    80005d02:	08f51b63          	bne	a0,a5,80005d98 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005d06:	04491703          	lh	a4,68(s2)
    80005d0a:	4785                	li	a5,1
    80005d0c:	08f70d63          	beq	a4,a5,80005da6 <sys_unlink+0x14c>
  iunlockput(dp);
    80005d10:	8526                	mv	a0,s1
    80005d12:	dbcfe0ef          	jal	800042ce <iunlockput>
  ip->nlink--;
    80005d16:	04a95783          	lhu	a5,74(s2)
    80005d1a:	37fd                	addiw	a5,a5,-1
    80005d1c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005d20:	854a                	mv	a0,s2
    80005d22:	aeefe0ef          	jal	80004010 <iupdate>
  iunlockput(ip);
    80005d26:	854a                	mv	a0,s2
    80005d28:	da6fe0ef          	jal	800042ce <iunlockput>
  end_op();
    80005d2c:	dedfe0ef          	jal	80004b18 <end_op>
  return 0;
    80005d30:	4501                	li	a0,0
    80005d32:	64ee                	ld	s1,216(sp)
    80005d34:	694e                	ld	s2,208(sp)
    80005d36:	a849                	j	80005dc8 <sys_unlink+0x16e>
    end_op();
    80005d38:	de1fe0ef          	jal	80004b18 <end_op>
    return -1;
    80005d3c:	557d                	li	a0,-1
    80005d3e:	64ee                	ld	s1,216(sp)
    80005d40:	a061                	j	80005dc8 <sys_unlink+0x16e>
    80005d42:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005d44:	00003517          	auipc	a0,0x3
    80005d48:	9d450513          	addi	a0,a0,-1580 # 80008718 <etext+0x718>
    80005d4c:	a95fa0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d50:	04c92703          	lw	a4,76(s2)
    80005d54:	02000793          	li	a5,32
    80005d58:	f8e7f5e3          	bgeu	a5,a4,80005ce2 <sys_unlink+0x88>
    80005d5c:	e5ce                	sd	s3,200(sp)
    80005d5e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d62:	4741                	li	a4,16
    80005d64:	86ce                	mv	a3,s3
    80005d66:	f1840613          	addi	a2,s0,-232
    80005d6a:	4581                	li	a1,0
    80005d6c:	854a                	mv	a0,s2
    80005d6e:	ee6fe0ef          	jal	80004454 <readi>
    80005d72:	47c1                	li	a5,16
    80005d74:	00f51c63          	bne	a0,a5,80005d8c <sys_unlink+0x132>
    if(de.inum != 0)
    80005d78:	f1845783          	lhu	a5,-232(s0)
    80005d7c:	efa1                	bnez	a5,80005dd4 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d7e:	29c1                	addiw	s3,s3,16
    80005d80:	04c92783          	lw	a5,76(s2)
    80005d84:	fcf9efe3          	bltu	s3,a5,80005d62 <sys_unlink+0x108>
    80005d88:	69ae                	ld	s3,200(sp)
    80005d8a:	bfa1                	j	80005ce2 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005d8c:	00003517          	auipc	a0,0x3
    80005d90:	9a450513          	addi	a0,a0,-1628 # 80008730 <etext+0x730>
    80005d94:	a4dfa0ef          	jal	800007e0 <panic>
    80005d98:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005d9a:	00003517          	auipc	a0,0x3
    80005d9e:	9ae50513          	addi	a0,a0,-1618 # 80008748 <etext+0x748>
    80005da2:	a3ffa0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80005da6:	04a4d783          	lhu	a5,74(s1)
    80005daa:	37fd                	addiw	a5,a5,-1
    80005dac:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005db0:	8526                	mv	a0,s1
    80005db2:	a5efe0ef          	jal	80004010 <iupdate>
    80005db6:	bfa9                	j	80005d10 <sys_unlink+0xb6>
    80005db8:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005dba:	8526                	mv	a0,s1
    80005dbc:	d12fe0ef          	jal	800042ce <iunlockput>
  end_op();
    80005dc0:	d59fe0ef          	jal	80004b18 <end_op>
  return -1;
    80005dc4:	557d                	li	a0,-1
    80005dc6:	64ee                	ld	s1,216(sp)
}
    80005dc8:	70ae                	ld	ra,232(sp)
    80005dca:	740e                	ld	s0,224(sp)
    80005dcc:	616d                	addi	sp,sp,240
    80005dce:	8082                	ret
    return -1;
    80005dd0:	557d                	li	a0,-1
    80005dd2:	bfdd                	j	80005dc8 <sys_unlink+0x16e>
    iunlockput(ip);
    80005dd4:	854a                	mv	a0,s2
    80005dd6:	cf8fe0ef          	jal	800042ce <iunlockput>
    goto bad;
    80005dda:	694e                	ld	s2,208(sp)
    80005ddc:	69ae                	ld	s3,200(sp)
    80005dde:	bff1                	j	80005dba <sys_unlink+0x160>

0000000080005de0 <sys_open>:

uint64
sys_open(void)
{
    80005de0:	7131                	addi	sp,sp,-192
    80005de2:	fd06                	sd	ra,184(sp)
    80005de4:	f922                	sd	s0,176(sp)
    80005de6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005de8:	f4c40593          	addi	a1,s0,-180
    80005dec:	4505                	li	a0,1
    80005dee:	b54fd0ef          	jal	80003142 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005df2:	08000613          	li	a2,128
    80005df6:	f5040593          	addi	a1,s0,-176
    80005dfa:	4501                	li	a0,0
    80005dfc:	b7efd0ef          	jal	8000317a <argstr>
    80005e00:	87aa                	mv	a5,a0
    return -1;
    80005e02:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e04:	0a07c263          	bltz	a5,80005ea8 <sys_open+0xc8>
    80005e08:	f526                	sd	s1,168(sp)

  begin_op();
    80005e0a:	ca5fe0ef          	jal	80004aae <begin_op>

  if(omode & O_CREATE){
    80005e0e:	f4c42783          	lw	a5,-180(s0)
    80005e12:	2007f793          	andi	a5,a5,512
    80005e16:	c3d5                	beqz	a5,80005eba <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005e18:	4681                	li	a3,0
    80005e1a:	4601                	li	a2,0
    80005e1c:	4589                	li	a1,2
    80005e1e:	f5040513          	addi	a0,s0,-176
    80005e22:	aa9ff0ef          	jal	800058ca <create>
    80005e26:	84aa                	mv	s1,a0
    if(ip == 0){
    80005e28:	c541                	beqz	a0,80005eb0 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005e2a:	04449703          	lh	a4,68(s1)
    80005e2e:	478d                	li	a5,3
    80005e30:	00f71763          	bne	a4,a5,80005e3e <sys_open+0x5e>
    80005e34:	0464d703          	lhu	a4,70(s1)
    80005e38:	47a5                	li	a5,9
    80005e3a:	0ae7ed63          	bltu	a5,a4,80005ef4 <sys_open+0x114>
    80005e3e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005e40:	fd7fe0ef          	jal	80004e16 <filealloc>
    80005e44:	892a                	mv	s2,a0
    80005e46:	c179                	beqz	a0,80005f0c <sys_open+0x12c>
    80005e48:	ed4e                	sd	s3,152(sp)
    80005e4a:	a43ff0ef          	jal	8000588c <fdalloc>
    80005e4e:	89aa                	mv	s3,a0
    80005e50:	0a054a63          	bltz	a0,80005f04 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005e54:	04449703          	lh	a4,68(s1)
    80005e58:	478d                	li	a5,3
    80005e5a:	0cf70263          	beq	a4,a5,80005f1e <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005e5e:	4789                	li	a5,2
    80005e60:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005e64:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005e68:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005e6c:	f4c42783          	lw	a5,-180(s0)
    80005e70:	0017c713          	xori	a4,a5,1
    80005e74:	8b05                	andi	a4,a4,1
    80005e76:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005e7a:	0037f713          	andi	a4,a5,3
    80005e7e:	00e03733          	snez	a4,a4
    80005e82:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005e86:	4007f793          	andi	a5,a5,1024
    80005e8a:	c791                	beqz	a5,80005e96 <sys_open+0xb6>
    80005e8c:	04449703          	lh	a4,68(s1)
    80005e90:	4789                	li	a5,2
    80005e92:	08f70d63          	beq	a4,a5,80005f2c <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005e96:	8526                	mv	a0,s1
    80005e98:	adafe0ef          	jal	80004172 <iunlock>
  end_op();
    80005e9c:	c7dfe0ef          	jal	80004b18 <end_op>

  return fd;
    80005ea0:	854e                	mv	a0,s3
    80005ea2:	74aa                	ld	s1,168(sp)
    80005ea4:	790a                	ld	s2,160(sp)
    80005ea6:	69ea                	ld	s3,152(sp)
}
    80005ea8:	70ea                	ld	ra,184(sp)
    80005eaa:	744a                	ld	s0,176(sp)
    80005eac:	6129                	addi	sp,sp,192
    80005eae:	8082                	ret
      end_op();
    80005eb0:	c69fe0ef          	jal	80004b18 <end_op>
      return -1;
    80005eb4:	557d                	li	a0,-1
    80005eb6:	74aa                	ld	s1,168(sp)
    80005eb8:	bfc5                	j	80005ea8 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005eba:	f5040513          	addi	a0,s0,-176
    80005ebe:	a1dfe0ef          	jal	800048da <namei>
    80005ec2:	84aa                	mv	s1,a0
    80005ec4:	c11d                	beqz	a0,80005eea <sys_open+0x10a>
    ilock(ip);
    80005ec6:	9fefe0ef          	jal	800040c4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005eca:	04449703          	lh	a4,68(s1)
    80005ece:	4785                	li	a5,1
    80005ed0:	f4f71de3          	bne	a4,a5,80005e2a <sys_open+0x4a>
    80005ed4:	f4c42783          	lw	a5,-180(s0)
    80005ed8:	d3bd                	beqz	a5,80005e3e <sys_open+0x5e>
      iunlockput(ip);
    80005eda:	8526                	mv	a0,s1
    80005edc:	bf2fe0ef          	jal	800042ce <iunlockput>
      end_op();
    80005ee0:	c39fe0ef          	jal	80004b18 <end_op>
      return -1;
    80005ee4:	557d                	li	a0,-1
    80005ee6:	74aa                	ld	s1,168(sp)
    80005ee8:	b7c1                	j	80005ea8 <sys_open+0xc8>
      end_op();
    80005eea:	c2ffe0ef          	jal	80004b18 <end_op>
      return -1;
    80005eee:	557d                	li	a0,-1
    80005ef0:	74aa                	ld	s1,168(sp)
    80005ef2:	bf5d                	j	80005ea8 <sys_open+0xc8>
    iunlockput(ip);
    80005ef4:	8526                	mv	a0,s1
    80005ef6:	bd8fe0ef          	jal	800042ce <iunlockput>
    end_op();
    80005efa:	c1ffe0ef          	jal	80004b18 <end_op>
    return -1;
    80005efe:	557d                	li	a0,-1
    80005f00:	74aa                	ld	s1,168(sp)
    80005f02:	b75d                	j	80005ea8 <sys_open+0xc8>
      fileclose(f);
    80005f04:	854a                	mv	a0,s2
    80005f06:	fb5fe0ef          	jal	80004eba <fileclose>
    80005f0a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005f0c:	8526                	mv	a0,s1
    80005f0e:	bc0fe0ef          	jal	800042ce <iunlockput>
    end_op();
    80005f12:	c07fe0ef          	jal	80004b18 <end_op>
    return -1;
    80005f16:	557d                	li	a0,-1
    80005f18:	74aa                	ld	s1,168(sp)
    80005f1a:	790a                	ld	s2,160(sp)
    80005f1c:	b771                	j	80005ea8 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005f1e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005f22:	04649783          	lh	a5,70(s1)
    80005f26:	02f91223          	sh	a5,36(s2)
    80005f2a:	bf3d                	j	80005e68 <sys_open+0x88>
    itrunc(ip);
    80005f2c:	8526                	mv	a0,s1
    80005f2e:	a84fe0ef          	jal	800041b2 <itrunc>
    80005f32:	b795                	j	80005e96 <sys_open+0xb6>

0000000080005f34 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005f34:	7175                	addi	sp,sp,-144
    80005f36:	e506                	sd	ra,136(sp)
    80005f38:	e122                	sd	s0,128(sp)
    80005f3a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005f3c:	b73fe0ef          	jal	80004aae <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005f40:	08000613          	li	a2,128
    80005f44:	f7040593          	addi	a1,s0,-144
    80005f48:	4501                	li	a0,0
    80005f4a:	a30fd0ef          	jal	8000317a <argstr>
    80005f4e:	02054363          	bltz	a0,80005f74 <sys_mkdir+0x40>
    80005f52:	4681                	li	a3,0
    80005f54:	4601                	li	a2,0
    80005f56:	4585                	li	a1,1
    80005f58:	f7040513          	addi	a0,s0,-144
    80005f5c:	96fff0ef          	jal	800058ca <create>
    80005f60:	c911                	beqz	a0,80005f74 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f62:	b6cfe0ef          	jal	800042ce <iunlockput>
  end_op();
    80005f66:	bb3fe0ef          	jal	80004b18 <end_op>
  return 0;
    80005f6a:	4501                	li	a0,0
}
    80005f6c:	60aa                	ld	ra,136(sp)
    80005f6e:	640a                	ld	s0,128(sp)
    80005f70:	6149                	addi	sp,sp,144
    80005f72:	8082                	ret
    end_op();
    80005f74:	ba5fe0ef          	jal	80004b18 <end_op>
    return -1;
    80005f78:	557d                	li	a0,-1
    80005f7a:	bfcd                	j	80005f6c <sys_mkdir+0x38>

0000000080005f7c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f7c:	7135                	addi	sp,sp,-160
    80005f7e:	ed06                	sd	ra,152(sp)
    80005f80:	e922                	sd	s0,144(sp)
    80005f82:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f84:	b2bfe0ef          	jal	80004aae <begin_op>
  argint(1, &major);
    80005f88:	f6c40593          	addi	a1,s0,-148
    80005f8c:	4505                	li	a0,1
    80005f8e:	9b4fd0ef          	jal	80003142 <argint>
  argint(2, &minor);
    80005f92:	f6840593          	addi	a1,s0,-152
    80005f96:	4509                	li	a0,2
    80005f98:	9aafd0ef          	jal	80003142 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f9c:	08000613          	li	a2,128
    80005fa0:	f7040593          	addi	a1,s0,-144
    80005fa4:	4501                	li	a0,0
    80005fa6:	9d4fd0ef          	jal	8000317a <argstr>
    80005faa:	02054563          	bltz	a0,80005fd4 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005fae:	f6841683          	lh	a3,-152(s0)
    80005fb2:	f6c41603          	lh	a2,-148(s0)
    80005fb6:	458d                	li	a1,3
    80005fb8:	f7040513          	addi	a0,s0,-144
    80005fbc:	90fff0ef          	jal	800058ca <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005fc0:	c911                	beqz	a0,80005fd4 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005fc2:	b0cfe0ef          	jal	800042ce <iunlockput>
  end_op();
    80005fc6:	b53fe0ef          	jal	80004b18 <end_op>
  return 0;
    80005fca:	4501                	li	a0,0
}
    80005fcc:	60ea                	ld	ra,152(sp)
    80005fce:	644a                	ld	s0,144(sp)
    80005fd0:	610d                	addi	sp,sp,160
    80005fd2:	8082                	ret
    end_op();
    80005fd4:	b45fe0ef          	jal	80004b18 <end_op>
    return -1;
    80005fd8:	557d                	li	a0,-1
    80005fda:	bfcd                	j	80005fcc <sys_mknod+0x50>

0000000080005fdc <sys_chdir>:

uint64
sys_chdir(void)
{
    80005fdc:	7135                	addi	sp,sp,-160
    80005fde:	ed06                	sd	ra,152(sp)
    80005fe0:	e922                	sd	s0,144(sp)
    80005fe2:	e14a                	sd	s2,128(sp)
    80005fe4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005fe6:	a11fb0ef          	jal	800019f6 <myproc>
    80005fea:	892a                	mv	s2,a0
  
  begin_op();
    80005fec:	ac3fe0ef          	jal	80004aae <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ff0:	08000613          	li	a2,128
    80005ff4:	f6040593          	addi	a1,s0,-160
    80005ff8:	4501                	li	a0,0
    80005ffa:	980fd0ef          	jal	8000317a <argstr>
    80005ffe:	04054363          	bltz	a0,80006044 <sys_chdir+0x68>
    80006002:	e526                	sd	s1,136(sp)
    80006004:	f6040513          	addi	a0,s0,-160
    80006008:	8d3fe0ef          	jal	800048da <namei>
    8000600c:	84aa                	mv	s1,a0
    8000600e:	c915                	beqz	a0,80006042 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80006010:	8b4fe0ef          	jal	800040c4 <ilock>
  if(ip->type != T_DIR){
    80006014:	04449703          	lh	a4,68(s1)
    80006018:	4785                	li	a5,1
    8000601a:	02f71963          	bne	a4,a5,8000604c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000601e:	8526                	mv	a0,s1
    80006020:	952fe0ef          	jal	80004172 <iunlock>
  iput(p->cwd);
    80006024:	15893503          	ld	a0,344(s2)
    80006028:	a1efe0ef          	jal	80004246 <iput>
  end_op();
    8000602c:	aedfe0ef          	jal	80004b18 <end_op>
  p->cwd = ip;
    80006030:	14993c23          	sd	s1,344(s2)
  return 0;
    80006034:	4501                	li	a0,0
    80006036:	64aa                	ld	s1,136(sp)
}
    80006038:	60ea                	ld	ra,152(sp)
    8000603a:	644a                	ld	s0,144(sp)
    8000603c:	690a                	ld	s2,128(sp)
    8000603e:	610d                	addi	sp,sp,160
    80006040:	8082                	ret
    80006042:	64aa                	ld	s1,136(sp)
    end_op();
    80006044:	ad5fe0ef          	jal	80004b18 <end_op>
    return -1;
    80006048:	557d                	li	a0,-1
    8000604a:	b7fd                	j	80006038 <sys_chdir+0x5c>
    iunlockput(ip);
    8000604c:	8526                	mv	a0,s1
    8000604e:	a80fe0ef          	jal	800042ce <iunlockput>
    end_op();
    80006052:	ac7fe0ef          	jal	80004b18 <end_op>
    return -1;
    80006056:	557d                	li	a0,-1
    80006058:	64aa                	ld	s1,136(sp)
    8000605a:	bff9                	j	80006038 <sys_chdir+0x5c>

000000008000605c <sys_exec>:

uint64
sys_exec(void)
{
    8000605c:	7121                	addi	sp,sp,-448
    8000605e:	ff06                	sd	ra,440(sp)
    80006060:	fb22                	sd	s0,432(sp)
    80006062:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006064:	e4840593          	addi	a1,s0,-440
    80006068:	4505                	li	a0,1
    8000606a:	8f4fd0ef          	jal	8000315e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000606e:	08000613          	li	a2,128
    80006072:	f5040593          	addi	a1,s0,-176
    80006076:	4501                	li	a0,0
    80006078:	902fd0ef          	jal	8000317a <argstr>
    8000607c:	87aa                	mv	a5,a0
    return -1;
    8000607e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006080:	0c07c463          	bltz	a5,80006148 <sys_exec+0xec>
    80006084:	f726                	sd	s1,424(sp)
    80006086:	f34a                	sd	s2,416(sp)
    80006088:	ef4e                	sd	s3,408(sp)
    8000608a:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000608c:	10000613          	li	a2,256
    80006090:	4581                	li	a1,0
    80006092:	e5040513          	addi	a0,s0,-432
    80006096:	c0dfa0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000609a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000609e:	89a6                	mv	s3,s1
    800060a0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800060a2:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800060a6:	00391513          	slli	a0,s2,0x3
    800060aa:	e4040593          	addi	a1,s0,-448
    800060ae:	e4843783          	ld	a5,-440(s0)
    800060b2:	953e                	add	a0,a0,a5
    800060b4:	804fd0ef          	jal	800030b8 <fetchaddr>
    800060b8:	02054663          	bltz	a0,800060e4 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800060bc:	e4043783          	ld	a5,-448(s0)
    800060c0:	c3a9                	beqz	a5,80006102 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800060c2:	a3dfa0ef          	jal	80000afe <kalloc>
    800060c6:	85aa                	mv	a1,a0
    800060c8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800060cc:	cd01                	beqz	a0,800060e4 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800060ce:	6605                	lui	a2,0x1
    800060d0:	e4043503          	ld	a0,-448(s0)
    800060d4:	82efd0ef          	jal	80003102 <fetchstr>
    800060d8:	00054663          	bltz	a0,800060e4 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800060dc:	0905                	addi	s2,s2,1
    800060de:	09a1                	addi	s3,s3,8
    800060e0:	fd4913e3          	bne	s2,s4,800060a6 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060e4:	f5040913          	addi	s2,s0,-176
    800060e8:	6088                	ld	a0,0(s1)
    800060ea:	c931                	beqz	a0,8000613e <sys_exec+0xe2>
    kfree(argv[i]);
    800060ec:	931fa0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060f0:	04a1                	addi	s1,s1,8
    800060f2:	ff249be3          	bne	s1,s2,800060e8 <sys_exec+0x8c>
  return -1;
    800060f6:	557d                	li	a0,-1
    800060f8:	74ba                	ld	s1,424(sp)
    800060fa:	791a                	ld	s2,416(sp)
    800060fc:	69fa                	ld	s3,408(sp)
    800060fe:	6a5a                	ld	s4,400(sp)
    80006100:	a0a1                	j	80006148 <sys_exec+0xec>
      argv[i] = 0;
    80006102:	0009079b          	sext.w	a5,s2
    80006106:	078e                	slli	a5,a5,0x3
    80006108:	fd078793          	addi	a5,a5,-48
    8000610c:	97a2                	add	a5,a5,s0
    8000610e:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80006112:	e5040593          	addi	a1,s0,-432
    80006116:	f5040513          	addi	a0,s0,-176
    8000611a:	ba8ff0ef          	jal	800054c2 <kexec>
    8000611e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006120:	f5040993          	addi	s3,s0,-176
    80006124:	6088                	ld	a0,0(s1)
    80006126:	c511                	beqz	a0,80006132 <sys_exec+0xd6>
    kfree(argv[i]);
    80006128:	8f5fa0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000612c:	04a1                	addi	s1,s1,8
    8000612e:	ff349be3          	bne	s1,s3,80006124 <sys_exec+0xc8>
  return ret;
    80006132:	854a                	mv	a0,s2
    80006134:	74ba                	ld	s1,424(sp)
    80006136:	791a                	ld	s2,416(sp)
    80006138:	69fa                	ld	s3,408(sp)
    8000613a:	6a5a                	ld	s4,400(sp)
    8000613c:	a031                	j	80006148 <sys_exec+0xec>
  return -1;
    8000613e:	557d                	li	a0,-1
    80006140:	74ba                	ld	s1,424(sp)
    80006142:	791a                	ld	s2,416(sp)
    80006144:	69fa                	ld	s3,408(sp)
    80006146:	6a5a                	ld	s4,400(sp)
}
    80006148:	70fa                	ld	ra,440(sp)
    8000614a:	745a                	ld	s0,432(sp)
    8000614c:	6139                	addi	sp,sp,448
    8000614e:	8082                	ret

0000000080006150 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006150:	7139                	addi	sp,sp,-64
    80006152:	fc06                	sd	ra,56(sp)
    80006154:	f822                	sd	s0,48(sp)
    80006156:	f426                	sd	s1,40(sp)
    80006158:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000615a:	89dfb0ef          	jal	800019f6 <myproc>
    8000615e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006160:	fd840593          	addi	a1,s0,-40
    80006164:	4501                	li	a0,0
    80006166:	ff9fc0ef          	jal	8000315e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000616a:	fc840593          	addi	a1,s0,-56
    8000616e:	fd040513          	addi	a0,s0,-48
    80006172:	852ff0ef          	jal	800051c4 <pipealloc>
    return -1;
    80006176:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006178:	0a054463          	bltz	a0,80006220 <sys_pipe+0xd0>
  fd0 = -1;
    8000617c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006180:	fd043503          	ld	a0,-48(s0)
    80006184:	f08ff0ef          	jal	8000588c <fdalloc>
    80006188:	fca42223          	sw	a0,-60(s0)
    8000618c:	08054163          	bltz	a0,8000620e <sys_pipe+0xbe>
    80006190:	fc843503          	ld	a0,-56(s0)
    80006194:	ef8ff0ef          	jal	8000588c <fdalloc>
    80006198:	fca42023          	sw	a0,-64(s0)
    8000619c:	06054063          	bltz	a0,800061fc <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061a0:	4691                	li	a3,4
    800061a2:	fc440613          	addi	a2,s0,-60
    800061a6:	fd843583          	ld	a1,-40(s0)
    800061aa:	6ca8                	ld	a0,88(s1)
    800061ac:	c36fb0ef          	jal	800015e2 <copyout>
    800061b0:	00054e63          	bltz	a0,800061cc <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800061b4:	4691                	li	a3,4
    800061b6:	fc040613          	addi	a2,s0,-64
    800061ba:	fd843583          	ld	a1,-40(s0)
    800061be:	0591                	addi	a1,a1,4
    800061c0:	6ca8                	ld	a0,88(s1)
    800061c2:	c20fb0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800061c6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061c8:	04055c63          	bgez	a0,80006220 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800061cc:	fc442783          	lw	a5,-60(s0)
    800061d0:	07e9                	addi	a5,a5,26
    800061d2:	078e                	slli	a5,a5,0x3
    800061d4:	97a6                	add	a5,a5,s1
    800061d6:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800061da:	fc042783          	lw	a5,-64(s0)
    800061de:	07e9                	addi	a5,a5,26
    800061e0:	078e                	slli	a5,a5,0x3
    800061e2:	94be                	add	s1,s1,a5
    800061e4:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800061e8:	fd043503          	ld	a0,-48(s0)
    800061ec:	ccffe0ef          	jal	80004eba <fileclose>
    fileclose(wf);
    800061f0:	fc843503          	ld	a0,-56(s0)
    800061f4:	cc7fe0ef          	jal	80004eba <fileclose>
    return -1;
    800061f8:	57fd                	li	a5,-1
    800061fa:	a01d                	j	80006220 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800061fc:	fc442783          	lw	a5,-60(s0)
    80006200:	0007c763          	bltz	a5,8000620e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80006204:	07e9                	addi	a5,a5,26
    80006206:	078e                	slli	a5,a5,0x3
    80006208:	97a6                	add	a5,a5,s1
    8000620a:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    8000620e:	fd043503          	ld	a0,-48(s0)
    80006212:	ca9fe0ef          	jal	80004eba <fileclose>
    fileclose(wf);
    80006216:	fc843503          	ld	a0,-56(s0)
    8000621a:	ca1fe0ef          	jal	80004eba <fileclose>
    return -1;
    8000621e:	57fd                	li	a5,-1
}
    80006220:	853e                	mv	a0,a5
    80006222:	70e2                	ld	ra,56(sp)
    80006224:	7442                	ld	s0,48(sp)
    80006226:	74a2                	ld	s1,40(sp)
    80006228:	6121                	addi	sp,sp,64
    8000622a:	8082                	ret
    8000622c:	0000                	unimp
	...

0000000080006230 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80006230:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80006232:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80006234:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80006236:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80006238:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000623a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000623c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000623e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80006240:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80006242:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80006244:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80006246:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80006248:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000624a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000624c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000624e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80006250:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80006252:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80006254:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80006256:	d73fc0ef          	jal	80002fc8 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000625a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000625c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000625e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80006260:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80006262:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80006264:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80006266:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80006268:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000626a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000626c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000626e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80006270:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80006272:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80006274:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80006276:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80006278:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000627a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000627c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000627e:	10200073          	sret
	...

000000008000628e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000628e:	1141                	addi	sp,sp,-16
    80006290:	e422                	sd	s0,8(sp)
    80006292:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006294:	0c0007b7          	lui	a5,0xc000
    80006298:	4705                	li	a4,1
    8000629a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000629c:	0c0007b7          	lui	a5,0xc000
    800062a0:	c3d8                	sw	a4,4(a5)
}
    800062a2:	6422                	ld	s0,8(sp)
    800062a4:	0141                	addi	sp,sp,16
    800062a6:	8082                	ret

00000000800062a8 <plicinithart>:

void
plicinithart(void)
{
    800062a8:	1141                	addi	sp,sp,-16
    800062aa:	e406                	sd	ra,8(sp)
    800062ac:	e022                	sd	s0,0(sp)
    800062ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062b0:	f1afb0ef          	jal	800019ca <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062b4:	0085171b          	slliw	a4,a0,0x8
    800062b8:	0c0027b7          	lui	a5,0xc002
    800062bc:	97ba                	add	a5,a5,a4
    800062be:	40200713          	li	a4,1026
    800062c2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062c6:	00d5151b          	slliw	a0,a0,0xd
    800062ca:	0c2017b7          	lui	a5,0xc201
    800062ce:	97aa                	add	a5,a5,a0
    800062d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800062d4:	60a2                	ld	ra,8(sp)
    800062d6:	6402                	ld	s0,0(sp)
    800062d8:	0141                	addi	sp,sp,16
    800062da:	8082                	ret

00000000800062dc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062dc:	1141                	addi	sp,sp,-16
    800062de:	e406                	sd	ra,8(sp)
    800062e0:	e022                	sd	s0,0(sp)
    800062e2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062e4:	ee6fb0ef          	jal	800019ca <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062e8:	00d5151b          	slliw	a0,a0,0xd
    800062ec:	0c2017b7          	lui	a5,0xc201
    800062f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800062f2:	43c8                	lw	a0,4(a5)
    800062f4:	60a2                	ld	ra,8(sp)
    800062f6:	6402                	ld	s0,0(sp)
    800062f8:	0141                	addi	sp,sp,16
    800062fa:	8082                	ret

00000000800062fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800062fc:	1101                	addi	sp,sp,-32
    800062fe:	ec06                	sd	ra,24(sp)
    80006300:	e822                	sd	s0,16(sp)
    80006302:	e426                	sd	s1,8(sp)
    80006304:	1000                	addi	s0,sp,32
    80006306:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006308:	ec2fb0ef          	jal	800019ca <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000630c:	00d5151b          	slliw	a0,a0,0xd
    80006310:	0c2017b7          	lui	a5,0xc201
    80006314:	97aa                	add	a5,a5,a0
    80006316:	c3c4                	sw	s1,4(a5)
}
    80006318:	60e2                	ld	ra,24(sp)
    8000631a:	6442                	ld	s0,16(sp)
    8000631c:	64a2                	ld	s1,8(sp)
    8000631e:	6105                	addi	sp,sp,32
    80006320:	8082                	ret

0000000080006322 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006322:	1141                	addi	sp,sp,-16
    80006324:	e406                	sd	ra,8(sp)
    80006326:	e022                	sd	s0,0(sp)
    80006328:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000632a:	479d                	li	a5,7
    8000632c:	04a7ca63          	blt	a5,a0,80006380 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80006330:	0001f797          	auipc	a5,0x1f
    80006334:	17878793          	addi	a5,a5,376 # 800254a8 <disk>
    80006338:	97aa                	add	a5,a5,a0
    8000633a:	0187c783          	lbu	a5,24(a5)
    8000633e:	e7b9                	bnez	a5,8000638c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006340:	00451693          	slli	a3,a0,0x4
    80006344:	0001f797          	auipc	a5,0x1f
    80006348:	16478793          	addi	a5,a5,356 # 800254a8 <disk>
    8000634c:	6398                	ld	a4,0(a5)
    8000634e:	9736                	add	a4,a4,a3
    80006350:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006354:	6398                	ld	a4,0(a5)
    80006356:	9736                	add	a4,a4,a3
    80006358:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000635c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006360:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006364:	97aa                	add	a5,a5,a0
    80006366:	4705                	li	a4,1
    80006368:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000636c:	0001f517          	auipc	a0,0x1f
    80006370:	15450513          	addi	a0,a0,340 # 800254c0 <disk+0x18>
    80006374:	aa8fc0ef          	jal	8000261c <wakeup>
}
    80006378:	60a2                	ld	ra,8(sp)
    8000637a:	6402                	ld	s0,0(sp)
    8000637c:	0141                	addi	sp,sp,16
    8000637e:	8082                	ret
    panic("free_desc 1");
    80006380:	00002517          	auipc	a0,0x2
    80006384:	3d850513          	addi	a0,a0,984 # 80008758 <etext+0x758>
    80006388:	c58fa0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000638c:	00002517          	auipc	a0,0x2
    80006390:	3dc50513          	addi	a0,a0,988 # 80008768 <etext+0x768>
    80006394:	c4cfa0ef          	jal	800007e0 <panic>

0000000080006398 <virtio_disk_init>:
{
    80006398:	1101                	addi	sp,sp,-32
    8000639a:	ec06                	sd	ra,24(sp)
    8000639c:	e822                	sd	s0,16(sp)
    8000639e:	e426                	sd	s1,8(sp)
    800063a0:	e04a                	sd	s2,0(sp)
    800063a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800063a4:	00002597          	auipc	a1,0x2
    800063a8:	3d458593          	addi	a1,a1,980 # 80008778 <etext+0x778>
    800063ac:	0001f517          	auipc	a0,0x1f
    800063b0:	22450513          	addi	a0,a0,548 # 800255d0 <disk+0x128>
    800063b4:	f9afa0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063b8:	100017b7          	lui	a5,0x10001
    800063bc:	4398                	lw	a4,0(a5)
    800063be:	2701                	sext.w	a4,a4
    800063c0:	747277b7          	lui	a5,0x74727
    800063c4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063c8:	18f71063          	bne	a4,a5,80006548 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063cc:	100017b7          	lui	a5,0x10001
    800063d0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800063d2:	439c                	lw	a5,0(a5)
    800063d4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063d6:	4709                	li	a4,2
    800063d8:	16e79863          	bne	a5,a4,80006548 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063dc:	100017b7          	lui	a5,0x10001
    800063e0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800063e2:	439c                	lw	a5,0(a5)
    800063e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063e6:	16e79163          	bne	a5,a4,80006548 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800063ea:	100017b7          	lui	a5,0x10001
    800063ee:	47d8                	lw	a4,12(a5)
    800063f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063f2:	554d47b7          	lui	a5,0x554d4
    800063f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063fa:	14f71763          	bne	a4,a5,80006548 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063fe:	100017b7          	lui	a5,0x10001
    80006402:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006406:	4705                	li	a4,1
    80006408:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000640a:	470d                	li	a4,3
    8000640c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000640e:	10001737          	lui	a4,0x10001
    80006412:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006414:	c7ffe737          	lui	a4,0xc7ffe
    80006418:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd9177>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000641c:	8ef9                	and	a3,a3,a4
    8000641e:	10001737          	lui	a4,0x10001
    80006422:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006424:	472d                	li	a4,11
    80006426:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006428:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000642c:	439c                	lw	a5,0(a5)
    8000642e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006432:	8ba1                	andi	a5,a5,8
    80006434:	12078063          	beqz	a5,80006554 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006438:	100017b7          	lui	a5,0x10001
    8000643c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006440:	100017b7          	lui	a5,0x10001
    80006444:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006448:	439c                	lw	a5,0(a5)
    8000644a:	2781                	sext.w	a5,a5
    8000644c:	10079a63          	bnez	a5,80006560 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006450:	100017b7          	lui	a5,0x10001
    80006454:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006458:	439c                	lw	a5,0(a5)
    8000645a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000645c:	10078863          	beqz	a5,8000656c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80006460:	471d                	li	a4,7
    80006462:	10f77b63          	bgeu	a4,a5,80006578 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80006466:	e98fa0ef          	jal	80000afe <kalloc>
    8000646a:	0001f497          	auipc	s1,0x1f
    8000646e:	03e48493          	addi	s1,s1,62 # 800254a8 <disk>
    80006472:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006474:	e8afa0ef          	jal	80000afe <kalloc>
    80006478:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000647a:	e84fa0ef          	jal	80000afe <kalloc>
    8000647e:	87aa                	mv	a5,a0
    80006480:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006482:	6088                	ld	a0,0(s1)
    80006484:	10050063          	beqz	a0,80006584 <virtio_disk_init+0x1ec>
    80006488:	0001f717          	auipc	a4,0x1f
    8000648c:	02873703          	ld	a4,40(a4) # 800254b0 <disk+0x8>
    80006490:	0e070a63          	beqz	a4,80006584 <virtio_disk_init+0x1ec>
    80006494:	0e078863          	beqz	a5,80006584 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006498:	6605                	lui	a2,0x1
    8000649a:	4581                	li	a1,0
    8000649c:	807fa0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800064a0:	0001f497          	auipc	s1,0x1f
    800064a4:	00848493          	addi	s1,s1,8 # 800254a8 <disk>
    800064a8:	6605                	lui	a2,0x1
    800064aa:	4581                	li	a1,0
    800064ac:	6488                	ld	a0,8(s1)
    800064ae:	ff4fa0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    800064b2:	6605                	lui	a2,0x1
    800064b4:	4581                	li	a1,0
    800064b6:	6888                	ld	a0,16(s1)
    800064b8:	feafa0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800064bc:	100017b7          	lui	a5,0x10001
    800064c0:	4721                	li	a4,8
    800064c2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800064c4:	4098                	lw	a4,0(s1)
    800064c6:	100017b7          	lui	a5,0x10001
    800064ca:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800064ce:	40d8                	lw	a4,4(s1)
    800064d0:	100017b7          	lui	a5,0x10001
    800064d4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800064d8:	649c                	ld	a5,8(s1)
    800064da:	0007869b          	sext.w	a3,a5
    800064de:	10001737          	lui	a4,0x10001
    800064e2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800064e6:	9781                	srai	a5,a5,0x20
    800064e8:	10001737          	lui	a4,0x10001
    800064ec:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800064f0:	689c                	ld	a5,16(s1)
    800064f2:	0007869b          	sext.w	a3,a5
    800064f6:	10001737          	lui	a4,0x10001
    800064fa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800064fe:	9781                	srai	a5,a5,0x20
    80006500:	10001737          	lui	a4,0x10001
    80006504:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006508:	10001737          	lui	a4,0x10001
    8000650c:	4785                	li	a5,1
    8000650e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006510:	00f48c23          	sb	a5,24(s1)
    80006514:	00f48ca3          	sb	a5,25(s1)
    80006518:	00f48d23          	sb	a5,26(s1)
    8000651c:	00f48da3          	sb	a5,27(s1)
    80006520:	00f48e23          	sb	a5,28(s1)
    80006524:	00f48ea3          	sb	a5,29(s1)
    80006528:	00f48f23          	sb	a5,30(s1)
    8000652c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006530:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006534:	100017b7          	lui	a5,0x10001
    80006538:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000653c:	60e2                	ld	ra,24(sp)
    8000653e:	6442                	ld	s0,16(sp)
    80006540:	64a2                	ld	s1,8(sp)
    80006542:	6902                	ld	s2,0(sp)
    80006544:	6105                	addi	sp,sp,32
    80006546:	8082                	ret
    panic("could not find virtio disk");
    80006548:	00002517          	auipc	a0,0x2
    8000654c:	24050513          	addi	a0,a0,576 # 80008788 <etext+0x788>
    80006550:	a90fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006554:	00002517          	auipc	a0,0x2
    80006558:	25450513          	addi	a0,a0,596 # 800087a8 <etext+0x7a8>
    8000655c:	a84fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80006560:	00002517          	auipc	a0,0x2
    80006564:	26850513          	addi	a0,a0,616 # 800087c8 <etext+0x7c8>
    80006568:	a78fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000656c:	00002517          	auipc	a0,0x2
    80006570:	27c50513          	addi	a0,a0,636 # 800087e8 <etext+0x7e8>
    80006574:	a6cfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80006578:	00002517          	auipc	a0,0x2
    8000657c:	29050513          	addi	a0,a0,656 # 80008808 <etext+0x808>
    80006580:	a60fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80006584:	00002517          	auipc	a0,0x2
    80006588:	2a450513          	addi	a0,a0,676 # 80008828 <etext+0x828>
    8000658c:	a54fa0ef          	jal	800007e0 <panic>

0000000080006590 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006590:	7159                	addi	sp,sp,-112
    80006592:	f486                	sd	ra,104(sp)
    80006594:	f0a2                	sd	s0,96(sp)
    80006596:	eca6                	sd	s1,88(sp)
    80006598:	e8ca                	sd	s2,80(sp)
    8000659a:	e4ce                	sd	s3,72(sp)
    8000659c:	e0d2                	sd	s4,64(sp)
    8000659e:	fc56                	sd	s5,56(sp)
    800065a0:	f85a                	sd	s6,48(sp)
    800065a2:	f45e                	sd	s7,40(sp)
    800065a4:	f062                	sd	s8,32(sp)
    800065a6:	ec66                	sd	s9,24(sp)
    800065a8:	1880                	addi	s0,sp,112
    800065aa:	8a2a                	mv	s4,a0
    800065ac:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800065ae:	00c52c83          	lw	s9,12(a0)
    800065b2:	001c9c9b          	slliw	s9,s9,0x1
    800065b6:	1c82                	slli	s9,s9,0x20
    800065b8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800065bc:	0001f517          	auipc	a0,0x1f
    800065c0:	01450513          	addi	a0,a0,20 # 800255d0 <disk+0x128>
    800065c4:	e0afa0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800065c8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800065ca:	44a1                	li	s1,8
      disk.free[i] = 0;
    800065cc:	0001fb17          	auipc	s6,0x1f
    800065d0:	edcb0b13          	addi	s6,s6,-292 # 800254a8 <disk>
  for(int i = 0; i < 3; i++){
    800065d4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065d6:	0001fc17          	auipc	s8,0x1f
    800065da:	ffac0c13          	addi	s8,s8,-6 # 800255d0 <disk+0x128>
    800065de:	a8b9                	j	8000663c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800065e0:	00fb0733          	add	a4,s6,a5
    800065e4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800065e8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800065ea:	0207c563          	bltz	a5,80006614 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800065ee:	2905                	addiw	s2,s2,1
    800065f0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800065f2:	05590963          	beq	s2,s5,80006644 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800065f6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800065f8:	0001f717          	auipc	a4,0x1f
    800065fc:	eb070713          	addi	a4,a4,-336 # 800254a8 <disk>
    80006600:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006602:	01874683          	lbu	a3,24(a4)
    80006606:	fee9                	bnez	a3,800065e0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80006608:	2785                	addiw	a5,a5,1
    8000660a:	0705                	addi	a4,a4,1
    8000660c:	fe979be3          	bne	a5,s1,80006602 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80006610:	57fd                	li	a5,-1
    80006612:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006614:	01205d63          	blez	s2,8000662e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006618:	f9042503          	lw	a0,-112(s0)
    8000661c:	d07ff0ef          	jal	80006322 <free_desc>
      for(int j = 0; j < i; j++)
    80006620:	4785                	li	a5,1
    80006622:	0127d663          	bge	a5,s2,8000662e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006626:	f9442503          	lw	a0,-108(s0)
    8000662a:	cf9ff0ef          	jal	80006322 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000662e:	85e2                	mv	a1,s8
    80006630:	0001f517          	auipc	a0,0x1f
    80006634:	e9050513          	addi	a0,a0,-368 # 800254c0 <disk+0x18>
    80006638:	f99fb0ef          	jal	800025d0 <sleep>
  for(int i = 0; i < 3; i++){
    8000663c:	f9040613          	addi	a2,s0,-112
    80006640:	894e                	mv	s2,s3
    80006642:	bf55                	j	800065f6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006644:	f9042503          	lw	a0,-112(s0)
    80006648:	00451693          	slli	a3,a0,0x4

  if(write)
    8000664c:	0001f797          	auipc	a5,0x1f
    80006650:	e5c78793          	addi	a5,a5,-420 # 800254a8 <disk>
    80006654:	00a50713          	addi	a4,a0,10
    80006658:	0712                	slli	a4,a4,0x4
    8000665a:	973e                	add	a4,a4,a5
    8000665c:	01703633          	snez	a2,s7
    80006660:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006662:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006666:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000666a:	6398                	ld	a4,0(a5)
    8000666c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000666e:	0a868613          	addi	a2,a3,168
    80006672:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006674:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006676:	6390                	ld	a2,0(a5)
    80006678:	00d605b3          	add	a1,a2,a3
    8000667c:	4741                	li	a4,16
    8000667e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006680:	4805                	li	a6,1
    80006682:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006686:	f9442703          	lw	a4,-108(s0)
    8000668a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000668e:	0712                	slli	a4,a4,0x4
    80006690:	963a                	add	a2,a2,a4
    80006692:	058a0593          	addi	a1,s4,88
    80006696:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006698:	0007b883          	ld	a7,0(a5)
    8000669c:	9746                	add	a4,a4,a7
    8000669e:	40000613          	li	a2,1024
    800066a2:	c710                	sw	a2,8(a4)
  if(write)
    800066a4:	001bb613          	seqz	a2,s7
    800066a8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800066ac:	00166613          	ori	a2,a2,1
    800066b0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800066b4:	f9842583          	lw	a1,-104(s0)
    800066b8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066bc:	00250613          	addi	a2,a0,2
    800066c0:	0612                	slli	a2,a2,0x4
    800066c2:	963e                	add	a2,a2,a5
    800066c4:	577d                	li	a4,-1
    800066c6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066ca:	0592                	slli	a1,a1,0x4
    800066cc:	98ae                	add	a7,a7,a1
    800066ce:	03068713          	addi	a4,a3,48
    800066d2:	973e                	add	a4,a4,a5
    800066d4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800066d8:	6398                	ld	a4,0(a5)
    800066da:	972e                	add	a4,a4,a1
    800066dc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066e0:	4689                	li	a3,2
    800066e2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800066e6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066ea:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800066ee:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066f2:	6794                	ld	a3,8(a5)
    800066f4:	0026d703          	lhu	a4,2(a3)
    800066f8:	8b1d                	andi	a4,a4,7
    800066fa:	0706                	slli	a4,a4,0x1
    800066fc:	96ba                	add	a3,a3,a4
    800066fe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006702:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006706:	6798                	ld	a4,8(a5)
    80006708:	00275783          	lhu	a5,2(a4)
    8000670c:	2785                	addiw	a5,a5,1
    8000670e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006712:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006716:	100017b7          	lui	a5,0x10001
    8000671a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000671e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006722:	0001f917          	auipc	s2,0x1f
    80006726:	eae90913          	addi	s2,s2,-338 # 800255d0 <disk+0x128>
  while(b->disk == 1) {
    8000672a:	4485                	li	s1,1
    8000672c:	01079a63          	bne	a5,a6,80006740 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006730:	85ca                	mv	a1,s2
    80006732:	8552                	mv	a0,s4
    80006734:	e9dfb0ef          	jal	800025d0 <sleep>
  while(b->disk == 1) {
    80006738:	004a2783          	lw	a5,4(s4)
    8000673c:	fe978ae3          	beq	a5,s1,80006730 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006740:	f9042903          	lw	s2,-112(s0)
    80006744:	00290713          	addi	a4,s2,2
    80006748:	0712                	slli	a4,a4,0x4
    8000674a:	0001f797          	auipc	a5,0x1f
    8000674e:	d5e78793          	addi	a5,a5,-674 # 800254a8 <disk>
    80006752:	97ba                	add	a5,a5,a4
    80006754:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006758:	0001f997          	auipc	s3,0x1f
    8000675c:	d5098993          	addi	s3,s3,-688 # 800254a8 <disk>
    80006760:	00491713          	slli	a4,s2,0x4
    80006764:	0009b783          	ld	a5,0(s3)
    80006768:	97ba                	add	a5,a5,a4
    8000676a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000676e:	854a                	mv	a0,s2
    80006770:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006774:	bafff0ef          	jal	80006322 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006778:	8885                	andi	s1,s1,1
    8000677a:	f0fd                	bnez	s1,80006760 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000677c:	0001f517          	auipc	a0,0x1f
    80006780:	e5450513          	addi	a0,a0,-428 # 800255d0 <disk+0x128>
    80006784:	ce2fa0ef          	jal	80000c66 <release>
}
    80006788:	70a6                	ld	ra,104(sp)
    8000678a:	7406                	ld	s0,96(sp)
    8000678c:	64e6                	ld	s1,88(sp)
    8000678e:	6946                	ld	s2,80(sp)
    80006790:	69a6                	ld	s3,72(sp)
    80006792:	6a06                	ld	s4,64(sp)
    80006794:	7ae2                	ld	s5,56(sp)
    80006796:	7b42                	ld	s6,48(sp)
    80006798:	7ba2                	ld	s7,40(sp)
    8000679a:	7c02                	ld	s8,32(sp)
    8000679c:	6ce2                	ld	s9,24(sp)
    8000679e:	6165                	addi	sp,sp,112
    800067a0:	8082                	ret

00000000800067a2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067a2:	1101                	addi	sp,sp,-32
    800067a4:	ec06                	sd	ra,24(sp)
    800067a6:	e822                	sd	s0,16(sp)
    800067a8:	e426                	sd	s1,8(sp)
    800067aa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067ac:	0001f497          	auipc	s1,0x1f
    800067b0:	cfc48493          	addi	s1,s1,-772 # 800254a8 <disk>
    800067b4:	0001f517          	auipc	a0,0x1f
    800067b8:	e1c50513          	addi	a0,a0,-484 # 800255d0 <disk+0x128>
    800067bc:	c12fa0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067c0:	100017b7          	lui	a5,0x10001
    800067c4:	53b8                	lw	a4,96(a5)
    800067c6:	8b0d                	andi	a4,a4,3
    800067c8:	100017b7          	lui	a5,0x10001
    800067cc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800067ce:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800067d2:	689c                	ld	a5,16(s1)
    800067d4:	0204d703          	lhu	a4,32(s1)
    800067d8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800067dc:	04f70663          	beq	a4,a5,80006828 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800067e0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067e4:	6898                	ld	a4,16(s1)
    800067e6:	0204d783          	lhu	a5,32(s1)
    800067ea:	8b9d                	andi	a5,a5,7
    800067ec:	078e                	slli	a5,a5,0x3
    800067ee:	97ba                	add	a5,a5,a4
    800067f0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800067f2:	00278713          	addi	a4,a5,2
    800067f6:	0712                	slli	a4,a4,0x4
    800067f8:	9726                	add	a4,a4,s1
    800067fa:	01074703          	lbu	a4,16(a4)
    800067fe:	e321                	bnez	a4,8000683e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006800:	0789                	addi	a5,a5,2
    80006802:	0792                	slli	a5,a5,0x4
    80006804:	97a6                	add	a5,a5,s1
    80006806:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006808:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000680c:	e11fb0ef          	jal	8000261c <wakeup>

    disk.used_idx += 1;
    80006810:	0204d783          	lhu	a5,32(s1)
    80006814:	2785                	addiw	a5,a5,1
    80006816:	17c2                	slli	a5,a5,0x30
    80006818:	93c1                	srli	a5,a5,0x30
    8000681a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000681e:	6898                	ld	a4,16(s1)
    80006820:	00275703          	lhu	a4,2(a4)
    80006824:	faf71ee3          	bne	a4,a5,800067e0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006828:	0001f517          	auipc	a0,0x1f
    8000682c:	da850513          	addi	a0,a0,-600 # 800255d0 <disk+0x128>
    80006830:	c36fa0ef          	jal	80000c66 <release>
}
    80006834:	60e2                	ld	ra,24(sp)
    80006836:	6442                	ld	s0,16(sp)
    80006838:	64a2                	ld	s1,8(sp)
    8000683a:	6105                	addi	sp,sp,32
    8000683c:	8082                	ret
      panic("virtio_disk_intr status");
    8000683e:	00002517          	auipc	a0,0x2
    80006842:	00250513          	addi	a0,a0,2 # 80008840 <etext+0x840>
    80006846:	f9bf90ef          	jal	800007e0 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
