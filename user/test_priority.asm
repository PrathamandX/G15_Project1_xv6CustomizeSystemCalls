
user/_test_priority:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int st;
  int i;

  if(fork() == 0){
   8:	344000ef          	jal	34c <fork>
   c:	e905                	bnez	a0,3c <main+0x3c>
    setp(getpid(), 10);
   e:	3ce000ef          	jal	3dc <getpid>
  12:	45a9                	li	a1,10
  14:	428000ef          	jal	43c <setp>
  18:	02faf7b7          	lui	a5,0x2faf
  1c:	08078793          	addi	a5,a5,128 # 2faf080 <base+0x2fae070>
    for(i = 0; i < 50000000; i++);
  20:	37fd                	addiw	a5,a5,-1
  22:	fffd                	bnez	a5,20 <main+0x20>
    pause(20);
  24:	4551                	li	a0,20
  26:	3c6000ef          	jal	3ec <pause>
    printf("Child with priority 10 finished\n");
  2a:	00001517          	auipc	a0,0x1
  2e:	98650513          	addi	a0,a0,-1658 # 9b0 <malloc+0xfe>
  32:	7cc000ef          	jal	7fe <printf>
    exit(0);
  36:	4501                	li	a0,0
  38:	31c000ef          	jal	354 <exit>
  }

  if(fork() == 0){
  3c:	310000ef          	jal	34c <fork>
  40:	e90d                	bnez	a0,72 <main+0x72>
    setp(getpid(), 50);
  42:	39a000ef          	jal	3dc <getpid>
  46:	03200593          	li	a1,50
  4a:	3f2000ef          	jal	43c <setp>
  4e:	02faf7b7          	lui	a5,0x2faf
  52:	08078793          	addi	a5,a5,128 # 2faf080 <base+0x2fae070>
    for(i = 0; i < 50000000; i++);
  56:	37fd                	addiw	a5,a5,-1
  58:	fffd                	bnez	a5,56 <main+0x56>
    pause(10);
  5a:	4529                	li	a0,10
  5c:	390000ef          	jal	3ec <pause>
    printf("Child with priority 50 finished\n");
  60:	00001517          	auipc	a0,0x1
  64:	97850513          	addi	a0,a0,-1672 # 9d8 <malloc+0x126>
  68:	796000ef          	jal	7fe <printf>
    exit(0);
  6c:	4501                	li	a0,0
  6e:	2e6000ef          	jal	354 <exit>
  }

  if(fork() == 0){
  72:	2da000ef          	jal	34c <fork>
  76:	e515                	bnez	a0,a2 <main+0xa2>
    setp(getpid(), 100);
  78:	364000ef          	jal	3dc <getpid>
  7c:	06400593          	li	a1,100
  80:	3bc000ef          	jal	43c <setp>
  84:	02faf7b7          	lui	a5,0x2faf
  88:	08078793          	addi	a5,a5,128 # 2faf080 <base+0x2fae070>
    for(i = 0; i < 50000000; i++);
  8c:	37fd                	addiw	a5,a5,-1
  8e:	fffd                	bnez	a5,8c <main+0x8c>
    printf("Child with priority 100 finished\n");
  90:	00001517          	auipc	a0,0x1
  94:	97050513          	addi	a0,a0,-1680 # a00 <malloc+0x14e>
  98:	766000ef          	jal	7fe <printf>
    exit(0);
  9c:	4501                	li	a0,0
  9e:	2b6000ef          	jal	354 <exit>
  }

  wait(&st);
  a2:	fec40513          	addi	a0,s0,-20
  a6:	2b6000ef          	jal	35c <wait>
  wait(&st);
  aa:	fec40513          	addi	a0,s0,-20
  ae:	2ae000ef          	jal	35c <wait>
  wait(&st);
  b2:	fec40513          	addi	a0,s0,-20
  b6:	2a6000ef          	jal	35c <wait>
  exit(0);
  ba:	4501                	li	a0,0
  bc:	298000ef          	jal	354 <exit>

00000000000000c0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e406                	sd	ra,8(sp)
  c4:	e022                	sd	s0,0(sp)
  c6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  c8:	f39ff0ef          	jal	0 <main>
  exit(r);
  cc:	288000ef          	jal	354 <exit>

00000000000000d0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d6:	87aa                	mv	a5,a0
  d8:	0585                	addi	a1,a1,1
  da:	0785                	addi	a5,a5,1
  dc:	fff5c703          	lbu	a4,-1(a1)
  e0:	fee78fa3          	sb	a4,-1(a5)
  e4:	fb75                	bnez	a4,d8 <strcpy+0x8>
    ;
  return os;
}
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret

00000000000000ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f2:	00054783          	lbu	a5,0(a0)
  f6:	cb91                	beqz	a5,10a <strcmp+0x1e>
  f8:	0005c703          	lbu	a4,0(a1)
  fc:	00f71763          	bne	a4,a5,10a <strcmp+0x1e>
    p++, q++;
 100:	0505                	addi	a0,a0,1
 102:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 104:	00054783          	lbu	a5,0(a0)
 108:	fbe5                	bnez	a5,f8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10a:	0005c503          	lbu	a0,0(a1)
}
 10e:	40a7853b          	subw	a0,a5,a0
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strlen>:

uint
strlen(const char *s)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 11e:	00054783          	lbu	a5,0(a0)
 122:	cf91                	beqz	a5,13e <strlen+0x26>
 124:	0505                	addi	a0,a0,1
 126:	87aa                	mv	a5,a0
 128:	86be                	mv	a3,a5
 12a:	0785                	addi	a5,a5,1
 12c:	fff7c703          	lbu	a4,-1(a5)
 130:	ff65                	bnez	a4,128 <strlen+0x10>
 132:	40a6853b          	subw	a0,a3,a0
 136:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 138:	6422                	ld	s0,8(sp)
 13a:	0141                	addi	sp,sp,16
 13c:	8082                	ret
  for(n = 0; s[n]; n++)
 13e:	4501                	li	a0,0
 140:	bfe5                	j	138 <strlen+0x20>

0000000000000142 <memset>:

void*
memset(void *dst, int c, uint n)
{
 142:	1141                	addi	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 148:	ca19                	beqz	a2,15e <memset+0x1c>
 14a:	87aa                	mv	a5,a0
 14c:	1602                	slli	a2,a2,0x20
 14e:	9201                	srli	a2,a2,0x20
 150:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 154:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 158:	0785                	addi	a5,a5,1
 15a:	fee79de3          	bne	a5,a4,154 <memset+0x12>
  }
  return dst;
}
 15e:	6422                	ld	s0,8(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret

0000000000000164 <strchr>:

char*
strchr(const char *s, char c)
{
 164:	1141                	addi	sp,sp,-16
 166:	e422                	sd	s0,8(sp)
 168:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	cb99                	beqz	a5,184 <strchr+0x20>
    if(*s == c)
 170:	00f58763          	beq	a1,a5,17e <strchr+0x1a>
  for(; *s; s++)
 174:	0505                	addi	a0,a0,1
 176:	00054783          	lbu	a5,0(a0)
 17a:	fbfd                	bnez	a5,170 <strchr+0xc>
      return (char*)s;
  return 0;
 17c:	4501                	li	a0,0
}
 17e:	6422                	ld	s0,8(sp)
 180:	0141                	addi	sp,sp,16
 182:	8082                	ret
  return 0;
 184:	4501                	li	a0,0
 186:	bfe5                	j	17e <strchr+0x1a>

0000000000000188 <gets>:

char*
gets(char *buf, int max)
{
 188:	711d                	addi	sp,sp,-96
 18a:	ec86                	sd	ra,88(sp)
 18c:	e8a2                	sd	s0,80(sp)
 18e:	e4a6                	sd	s1,72(sp)
 190:	e0ca                	sd	s2,64(sp)
 192:	fc4e                	sd	s3,56(sp)
 194:	f852                	sd	s4,48(sp)
 196:	f456                	sd	s5,40(sp)
 198:	f05a                	sd	s6,32(sp)
 19a:	ec5e                	sd	s7,24(sp)
 19c:	1080                	addi	s0,sp,96
 19e:	8baa                	mv	s7,a0
 1a0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a2:	892a                	mv	s2,a0
 1a4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a6:	4aa9                	li	s5,10
 1a8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1aa:	89a6                	mv	s3,s1
 1ac:	2485                	addiw	s1,s1,1
 1ae:	0344d663          	bge	s1,s4,1da <gets+0x52>
    cc = read(0, &c, 1);
 1b2:	4605                	li	a2,1
 1b4:	faf40593          	addi	a1,s0,-81
 1b8:	4501                	li	a0,0
 1ba:	1ba000ef          	jal	374 <read>
    if(cc < 1)
 1be:	00a05e63          	blez	a0,1da <gets+0x52>
    buf[i++] = c;
 1c2:	faf44783          	lbu	a5,-81(s0)
 1c6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ca:	01578763          	beq	a5,s5,1d8 <gets+0x50>
 1ce:	0905                	addi	s2,s2,1
 1d0:	fd679de3          	bne	a5,s6,1aa <gets+0x22>
    buf[i++] = c;
 1d4:	89a6                	mv	s3,s1
 1d6:	a011                	j	1da <gets+0x52>
 1d8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1da:	99de                	add	s3,s3,s7
 1dc:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e0:	855e                	mv	a0,s7
 1e2:	60e6                	ld	ra,88(sp)
 1e4:	6446                	ld	s0,80(sp)
 1e6:	64a6                	ld	s1,72(sp)
 1e8:	6906                	ld	s2,64(sp)
 1ea:	79e2                	ld	s3,56(sp)
 1ec:	7a42                	ld	s4,48(sp)
 1ee:	7aa2                	ld	s5,40(sp)
 1f0:	7b02                	ld	s6,32(sp)
 1f2:	6be2                	ld	s7,24(sp)
 1f4:	6125                	addi	sp,sp,96
 1f6:	8082                	ret

00000000000001f8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f8:	1101                	addi	sp,sp,-32
 1fa:	ec06                	sd	ra,24(sp)
 1fc:	e822                	sd	s0,16(sp)
 1fe:	e04a                	sd	s2,0(sp)
 200:	1000                	addi	s0,sp,32
 202:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 204:	4581                	li	a1,0
 206:	196000ef          	jal	39c <open>
  if(fd < 0)
 20a:	02054263          	bltz	a0,22e <stat+0x36>
 20e:	e426                	sd	s1,8(sp)
 210:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 212:	85ca                	mv	a1,s2
 214:	1a0000ef          	jal	3b4 <fstat>
 218:	892a                	mv	s2,a0
  close(fd);
 21a:	8526                	mv	a0,s1
 21c:	168000ef          	jal	384 <close>
  return r;
 220:	64a2                	ld	s1,8(sp)
}
 222:	854a                	mv	a0,s2
 224:	60e2                	ld	ra,24(sp)
 226:	6442                	ld	s0,16(sp)
 228:	6902                	ld	s2,0(sp)
 22a:	6105                	addi	sp,sp,32
 22c:	8082                	ret
    return -1;
 22e:	597d                	li	s2,-1
 230:	bfcd                	j	222 <stat+0x2a>

0000000000000232 <atoi>:

int
atoi(const char *s)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 238:	00054683          	lbu	a3,0(a0)
 23c:	fd06879b          	addiw	a5,a3,-48
 240:	0ff7f793          	zext.b	a5,a5
 244:	4625                	li	a2,9
 246:	02f66863          	bltu	a2,a5,276 <atoi+0x44>
 24a:	872a                	mv	a4,a0
  n = 0;
 24c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 24e:	0705                	addi	a4,a4,1
 250:	0025179b          	slliw	a5,a0,0x2
 254:	9fa9                	addw	a5,a5,a0
 256:	0017979b          	slliw	a5,a5,0x1
 25a:	9fb5                	addw	a5,a5,a3
 25c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 260:	00074683          	lbu	a3,0(a4)
 264:	fd06879b          	addiw	a5,a3,-48
 268:	0ff7f793          	zext.b	a5,a5
 26c:	fef671e3          	bgeu	a2,a5,24e <atoi+0x1c>
  return n;
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret
  n = 0;
 276:	4501                	li	a0,0
 278:	bfe5                	j	270 <atoi+0x3e>

000000000000027a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 280:	02b57463          	bgeu	a0,a1,2a8 <memmove+0x2e>
    while(n-- > 0)
 284:	00c05f63          	blez	a2,2a2 <memmove+0x28>
 288:	1602                	slli	a2,a2,0x20
 28a:	9201                	srli	a2,a2,0x20
 28c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 290:	872a                	mv	a4,a0
      *dst++ = *src++;
 292:	0585                	addi	a1,a1,1
 294:	0705                	addi	a4,a4,1
 296:	fff5c683          	lbu	a3,-1(a1)
 29a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29e:	fef71ae3          	bne	a4,a5,292 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a2:	6422                	ld	s0,8(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret
    dst += n;
 2a8:	00c50733          	add	a4,a0,a2
    src += n;
 2ac:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ae:	fec05ae3          	blez	a2,2a2 <memmove+0x28>
 2b2:	fff6079b          	addiw	a5,a2,-1
 2b6:	1782                	slli	a5,a5,0x20
 2b8:	9381                	srli	a5,a5,0x20
 2ba:	fff7c793          	not	a5,a5
 2be:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c0:	15fd                	addi	a1,a1,-1
 2c2:	177d                	addi	a4,a4,-1
 2c4:	0005c683          	lbu	a3,0(a1)
 2c8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2cc:	fee79ae3          	bne	a5,a4,2c0 <memmove+0x46>
 2d0:	bfc9                	j	2a2 <memmove+0x28>

00000000000002d2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d8:	ca05                	beqz	a2,308 <memcmp+0x36>
 2da:	fff6069b          	addiw	a3,a2,-1
 2de:	1682                	slli	a3,a3,0x20
 2e0:	9281                	srli	a3,a3,0x20
 2e2:	0685                	addi	a3,a3,1
 2e4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e6:	00054783          	lbu	a5,0(a0)
 2ea:	0005c703          	lbu	a4,0(a1)
 2ee:	00e79863          	bne	a5,a4,2fe <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f2:	0505                	addi	a0,a0,1
    p2++;
 2f4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f6:	fed518e3          	bne	a0,a3,2e6 <memcmp+0x14>
  }
  return 0;
 2fa:	4501                	li	a0,0
 2fc:	a019                	j	302 <memcmp+0x30>
      return *p1 - *p2;
 2fe:	40e7853b          	subw	a0,a5,a4
}
 302:	6422                	ld	s0,8(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret
  return 0;
 308:	4501                	li	a0,0
 30a:	bfe5                	j	302 <memcmp+0x30>

000000000000030c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e406                	sd	ra,8(sp)
 310:	e022                	sd	s0,0(sp)
 312:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 314:	f67ff0ef          	jal	27a <memmove>
}
 318:	60a2                	ld	ra,8(sp)
 31a:	6402                	ld	s0,0(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret

0000000000000320 <sbrk>:

char *
sbrk(int n) {
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 328:	4585                	li	a1,1
 32a:	0ba000ef          	jal	3e4 <sys_sbrk>
}
 32e:	60a2                	ld	ra,8(sp)
 330:	6402                	ld	s0,0(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret

0000000000000336 <sbrklazy>:

char *
sbrklazy(int n) {
 336:	1141                	addi	sp,sp,-16
 338:	e406                	sd	ra,8(sp)
 33a:	e022                	sd	s0,0(sp)
 33c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 33e:	4589                	li	a1,2
 340:	0a4000ef          	jal	3e4 <sys_sbrk>
}
 344:	60a2                	ld	ra,8(sp)
 346:	6402                	ld	s0,0(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret

000000000000034c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 34c:	4885                	li	a7,1
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <exit>:
.global exit
exit:
 li a7, SYS_exit
 354:	4889                	li	a7,2
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <wait>:
.global wait
wait:
 li a7, SYS_wait
 35c:	488d                	li	a7,3
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 364:	48d9                	li	a7,22
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36c:	4891                	li	a7,4
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <read>:
.global read
read:
 li a7, SYS_read
 374:	4895                	li	a7,5
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <write>:
.global write
write:
 li a7, SYS_write
 37c:	48c1                	li	a7,16
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <close>:
.global close
close:
 li a7, SYS_close
 384:	48d5                	li	a7,21
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <kill>:
.global kill
kill:
 li a7, SYS_kill
 38c:	4899                	li	a7,6
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <exec>:
.global exec
exec:
 li a7, SYS_exec
 394:	489d                	li	a7,7
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <open>:
.global open
open:
 li a7, SYS_open
 39c:	48bd                	li	a7,15
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a4:	48c5                	li	a7,17
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ac:	48c9                	li	a7,18
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b4:	48a1                	li	a7,8
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <link>:
.global link
link:
 li a7, SYS_link
 3bc:	48cd                	li	a7,19
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c4:	48d1                	li	a7,20
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3cc:	48a5                	li	a7,9
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d4:	48a9                	li	a7,10
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3dc:	48ad                	li	a7,11
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e4:	48b1                	li	a7,12
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ec:	48b5                	li	a7,13
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f4:	48b9                	li	a7,14
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3fc:	48dd                	li	a7,23
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 404:	48e1                	li	a7,24
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <mutex_init>:
.global mutex_init
mutex_init:
 li a7, SYS_mutex_init
 40c:	48e5                	li	a7,25
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <mutex_acquire>:
.global mutex_acquire
mutex_acquire:
 li a7, SYS_mutex_acquire
 414:	48e9                	li	a7,26
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <mutex_release>:
.global mutex_release
mutex_release:
 li a7, SYS_mutex_release
 41c:	48ed                	li	a7,27
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 424:	48f1                	li	a7,28
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 42c:	48f5                	li	a7,29
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 434:	48f9                	li	a7,30
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <setp>:
.global setp
setp:
 li a7, SYS_setp
 43c:	48fd                	li	a7,31
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <ismyear>:
.global ismyear
ismyear:
 li a7, SYS_ismyear
 444:	02000893          	li	a7,32
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 44e:	02100893          	li	a7,33
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 458:	02200893          	li	a7,34
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <thread_exit>:
.global thread_exit
thread_exit:
 li a7, SYS_thread_exit
 462:	02300893          	li	a7,35
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <thread_id>:
.global thread_id
thread_id:
 li a7, SYS_thread_id
 46c:	02400893          	li	a7,36
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 476:	1101                	addi	sp,sp,-32
 478:	ec06                	sd	ra,24(sp)
 47a:	e822                	sd	s0,16(sp)
 47c:	1000                	addi	s0,sp,32
 47e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 482:	4605                	li	a2,1
 484:	fef40593          	addi	a1,s0,-17
 488:	ef5ff0ef          	jal	37c <write>
}
 48c:	60e2                	ld	ra,24(sp)
 48e:	6442                	ld	s0,16(sp)
 490:	6105                	addi	sp,sp,32
 492:	8082                	ret

0000000000000494 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 494:	715d                	addi	sp,sp,-80
 496:	e486                	sd	ra,72(sp)
 498:	e0a2                	sd	s0,64(sp)
 49a:	f84a                	sd	s2,48(sp)
 49c:	0880                	addi	s0,sp,80
 49e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4a0:	c299                	beqz	a3,4a6 <printint+0x12>
 4a2:	0805c363          	bltz	a1,528 <printint+0x94>
  neg = 0;
 4a6:	4881                	li	a7,0
 4a8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4ac:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4ae:	00000517          	auipc	a0,0x0
 4b2:	58250513          	addi	a0,a0,1410 # a30 <digits>
 4b6:	883e                	mv	a6,a5
 4b8:	2785                	addiw	a5,a5,1
 4ba:	02c5f733          	remu	a4,a1,a2
 4be:	972a                	add	a4,a4,a0
 4c0:	00074703          	lbu	a4,0(a4)
 4c4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4c8:	872e                	mv	a4,a1
 4ca:	02c5d5b3          	divu	a1,a1,a2
 4ce:	0685                	addi	a3,a3,1
 4d0:	fec773e3          	bgeu	a4,a2,4b6 <printint+0x22>
  if(neg)
 4d4:	00088b63          	beqz	a7,4ea <printint+0x56>
    buf[i++] = '-';
 4d8:	fd078793          	addi	a5,a5,-48
 4dc:	97a2                	add	a5,a5,s0
 4de:	02d00713          	li	a4,45
 4e2:	fee78423          	sb	a4,-24(a5)
 4e6:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4ea:	02f05a63          	blez	a5,51e <printint+0x8a>
 4ee:	fc26                	sd	s1,56(sp)
 4f0:	f44e                	sd	s3,40(sp)
 4f2:	fb840713          	addi	a4,s0,-72
 4f6:	00f704b3          	add	s1,a4,a5
 4fa:	fff70993          	addi	s3,a4,-1
 4fe:	99be                	add	s3,s3,a5
 500:	37fd                	addiw	a5,a5,-1
 502:	1782                	slli	a5,a5,0x20
 504:	9381                	srli	a5,a5,0x20
 506:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 50a:	fff4c583          	lbu	a1,-1(s1)
 50e:	854a                	mv	a0,s2
 510:	f67ff0ef          	jal	476 <putc>
  while(--i >= 0)
 514:	14fd                	addi	s1,s1,-1
 516:	ff349ae3          	bne	s1,s3,50a <printint+0x76>
 51a:	74e2                	ld	s1,56(sp)
 51c:	79a2                	ld	s3,40(sp)
}
 51e:	60a6                	ld	ra,72(sp)
 520:	6406                	ld	s0,64(sp)
 522:	7942                	ld	s2,48(sp)
 524:	6161                	addi	sp,sp,80
 526:	8082                	ret
    x = -xx;
 528:	40b005b3          	neg	a1,a1
    neg = 1;
 52c:	4885                	li	a7,1
    x = -xx;
 52e:	bfad                	j	4a8 <printint+0x14>

0000000000000530 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 530:	711d                	addi	sp,sp,-96
 532:	ec86                	sd	ra,88(sp)
 534:	e8a2                	sd	s0,80(sp)
 536:	e0ca                	sd	s2,64(sp)
 538:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 53a:	0005c903          	lbu	s2,0(a1)
 53e:	28090663          	beqz	s2,7ca <vprintf+0x29a>
 542:	e4a6                	sd	s1,72(sp)
 544:	fc4e                	sd	s3,56(sp)
 546:	f852                	sd	s4,48(sp)
 548:	f456                	sd	s5,40(sp)
 54a:	f05a                	sd	s6,32(sp)
 54c:	ec5e                	sd	s7,24(sp)
 54e:	e862                	sd	s8,16(sp)
 550:	e466                	sd	s9,8(sp)
 552:	8b2a                	mv	s6,a0
 554:	8a2e                	mv	s4,a1
 556:	8bb2                	mv	s7,a2
  state = 0;
 558:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 55a:	4481                	li	s1,0
 55c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 55e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 562:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 566:	06c00c93          	li	s9,108
 56a:	a005                	j	58a <vprintf+0x5a>
        putc(fd, c0);
 56c:	85ca                	mv	a1,s2
 56e:	855a                	mv	a0,s6
 570:	f07ff0ef          	jal	476 <putc>
 574:	a019                	j	57a <vprintf+0x4a>
    } else if(state == '%'){
 576:	03598263          	beq	s3,s5,59a <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 57a:	2485                	addiw	s1,s1,1
 57c:	8726                	mv	a4,s1
 57e:	009a07b3          	add	a5,s4,s1
 582:	0007c903          	lbu	s2,0(a5)
 586:	22090a63          	beqz	s2,7ba <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 58a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 58e:	fe0994e3          	bnez	s3,576 <vprintf+0x46>
      if(c0 == '%'){
 592:	fd579de3          	bne	a5,s5,56c <vprintf+0x3c>
        state = '%';
 596:	89be                	mv	s3,a5
 598:	b7cd                	j	57a <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 59a:	00ea06b3          	add	a3,s4,a4
 59e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5a2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5a4:	c681                	beqz	a3,5ac <vprintf+0x7c>
 5a6:	9752                	add	a4,a4,s4
 5a8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5ac:	05878363          	beq	a5,s8,5f2 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5b0:	05978d63          	beq	a5,s9,60a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5b4:	07500713          	li	a4,117
 5b8:	0ee78763          	beq	a5,a4,6a6 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5bc:	07800713          	li	a4,120
 5c0:	12e78963          	beq	a5,a4,6f2 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5c4:	07000713          	li	a4,112
 5c8:	14e78e63          	beq	a5,a4,724 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5cc:	06300713          	li	a4,99
 5d0:	18e78e63          	beq	a5,a4,76c <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5d4:	07300713          	li	a4,115
 5d8:	1ae78463          	beq	a5,a4,780 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5dc:	02500713          	li	a4,37
 5e0:	04e79563          	bne	a5,a4,62a <vprintf+0xfa>
        putc(fd, '%');
 5e4:	02500593          	li	a1,37
 5e8:	855a                	mv	a0,s6
 5ea:	e8dff0ef          	jal	476 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	b769                	j	57a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5f2:	008b8913          	addi	s2,s7,8
 5f6:	4685                	li	a3,1
 5f8:	4629                	li	a2,10
 5fa:	000ba583          	lw	a1,0(s7)
 5fe:	855a                	mv	a0,s6
 600:	e95ff0ef          	jal	494 <printint>
 604:	8bca                	mv	s7,s2
      state = 0;
 606:	4981                	li	s3,0
 608:	bf8d                	j	57a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 60a:	06400793          	li	a5,100
 60e:	02f68963          	beq	a3,a5,640 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 612:	06c00793          	li	a5,108
 616:	04f68263          	beq	a3,a5,65a <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 61a:	07500793          	li	a5,117
 61e:	0af68063          	beq	a3,a5,6be <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 622:	07800793          	li	a5,120
 626:	0ef68263          	beq	a3,a5,70a <vprintf+0x1da>
        putc(fd, '%');
 62a:	02500593          	li	a1,37
 62e:	855a                	mv	a0,s6
 630:	e47ff0ef          	jal	476 <putc>
        putc(fd, c0);
 634:	85ca                	mv	a1,s2
 636:	855a                	mv	a0,s6
 638:	e3fff0ef          	jal	476 <putc>
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bf35                	j	57a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 640:	008b8913          	addi	s2,s7,8
 644:	4685                	li	a3,1
 646:	4629                	li	a2,10
 648:	000bb583          	ld	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e47ff0ef          	jal	494 <printint>
        i += 1;
 652:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
        i += 1;
 658:	b70d                	j	57a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 65a:	06400793          	li	a5,100
 65e:	02f60763          	beq	a2,a5,68c <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 662:	07500793          	li	a5,117
 666:	06f60963          	beq	a2,a5,6d8 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 66a:	07800793          	li	a5,120
 66e:	faf61ee3          	bne	a2,a5,62a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 672:	008b8913          	addi	s2,s7,8
 676:	4681                	li	a3,0
 678:	4641                	li	a2,16
 67a:	000bb583          	ld	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	e15ff0ef          	jal	494 <printint>
        i += 2;
 684:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
        i += 2;
 68a:	bdc5                	j	57a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 68c:	008b8913          	addi	s2,s7,8
 690:	4685                	li	a3,1
 692:	4629                	li	a2,10
 694:	000bb583          	ld	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	dfbff0ef          	jal	494 <printint>
        i += 2;
 69e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
        i += 2;
 6a4:	bdd9                	j	57a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000be583          	lwu	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	de1ff0ef          	jal	494 <printint>
 6b8:	8bca                	mv	s7,s2
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	bd7d                	j	57a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6be:	008b8913          	addi	s2,s7,8
 6c2:	4681                	li	a3,0
 6c4:	4629                	li	a2,10
 6c6:	000bb583          	ld	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	dc9ff0ef          	jal	494 <printint>
        i += 1;
 6d0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
        i += 1;
 6d6:	b555                	j	57a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d8:	008b8913          	addi	s2,s7,8
 6dc:	4681                	li	a3,0
 6de:	4629                	li	a2,10
 6e0:	000bb583          	ld	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	dafff0ef          	jal	494 <printint>
        i += 2;
 6ea:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ec:	8bca                	mv	s7,s2
      state = 0;
 6ee:	4981                	li	s3,0
        i += 2;
 6f0:	b569                	j	57a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6f2:	008b8913          	addi	s2,s7,8
 6f6:	4681                	li	a3,0
 6f8:	4641                	li	a2,16
 6fa:	000be583          	lwu	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	d95ff0ef          	jal	494 <printint>
 704:	8bca                	mv	s7,s2
      state = 0;
 706:	4981                	li	s3,0
 708:	bd8d                	j	57a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 70a:	008b8913          	addi	s2,s7,8
 70e:	4681                	li	a3,0
 710:	4641                	li	a2,16
 712:	000bb583          	ld	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	d7dff0ef          	jal	494 <printint>
        i += 1;
 71c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 71e:	8bca                	mv	s7,s2
      state = 0;
 720:	4981                	li	s3,0
        i += 1;
 722:	bda1                	j	57a <vprintf+0x4a>
 724:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 726:	008b8d13          	addi	s10,s7,8
 72a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 72e:	03000593          	li	a1,48
 732:	855a                	mv	a0,s6
 734:	d43ff0ef          	jal	476 <putc>
  putc(fd, 'x');
 738:	07800593          	li	a1,120
 73c:	855a                	mv	a0,s6
 73e:	d39ff0ef          	jal	476 <putc>
 742:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 744:	00000b97          	auipc	s7,0x0
 748:	2ecb8b93          	addi	s7,s7,748 # a30 <digits>
 74c:	03c9d793          	srli	a5,s3,0x3c
 750:	97de                	add	a5,a5,s7
 752:	0007c583          	lbu	a1,0(a5)
 756:	855a                	mv	a0,s6
 758:	d1fff0ef          	jal	476 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 75c:	0992                	slli	s3,s3,0x4
 75e:	397d                	addiw	s2,s2,-1
 760:	fe0916e3          	bnez	s2,74c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 764:	8bea                	mv	s7,s10
      state = 0;
 766:	4981                	li	s3,0
 768:	6d02                	ld	s10,0(sp)
 76a:	bd01                	j	57a <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 76c:	008b8913          	addi	s2,s7,8
 770:	000bc583          	lbu	a1,0(s7)
 774:	855a                	mv	a0,s6
 776:	d01ff0ef          	jal	476 <putc>
 77a:	8bca                	mv	s7,s2
      state = 0;
 77c:	4981                	li	s3,0
 77e:	bbf5                	j	57a <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 780:	008b8993          	addi	s3,s7,8
 784:	000bb903          	ld	s2,0(s7)
 788:	00090f63          	beqz	s2,7a6 <vprintf+0x276>
        for(; *s; s++)
 78c:	00094583          	lbu	a1,0(s2)
 790:	c195                	beqz	a1,7b4 <vprintf+0x284>
          putc(fd, *s);
 792:	855a                	mv	a0,s6
 794:	ce3ff0ef          	jal	476 <putc>
        for(; *s; s++)
 798:	0905                	addi	s2,s2,1
 79a:	00094583          	lbu	a1,0(s2)
 79e:	f9f5                	bnez	a1,792 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7a0:	8bce                	mv	s7,s3
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	bbd9                	j	57a <vprintf+0x4a>
          s = "(null)";
 7a6:	00000917          	auipc	s2,0x0
 7aa:	28290913          	addi	s2,s2,642 # a28 <malloc+0x176>
        for(; *s; s++)
 7ae:	02800593          	li	a1,40
 7b2:	b7c5                	j	792 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7b4:	8bce                	mv	s7,s3
      state = 0;
 7b6:	4981                	li	s3,0
 7b8:	b3c9                	j	57a <vprintf+0x4a>
 7ba:	64a6                	ld	s1,72(sp)
 7bc:	79e2                	ld	s3,56(sp)
 7be:	7a42                	ld	s4,48(sp)
 7c0:	7aa2                	ld	s5,40(sp)
 7c2:	7b02                	ld	s6,32(sp)
 7c4:	6be2                	ld	s7,24(sp)
 7c6:	6c42                	ld	s8,16(sp)
 7c8:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7ca:	60e6                	ld	ra,88(sp)
 7cc:	6446                	ld	s0,80(sp)
 7ce:	6906                	ld	s2,64(sp)
 7d0:	6125                	addi	sp,sp,96
 7d2:	8082                	ret

00000000000007d4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d4:	715d                	addi	sp,sp,-80
 7d6:	ec06                	sd	ra,24(sp)
 7d8:	e822                	sd	s0,16(sp)
 7da:	1000                	addi	s0,sp,32
 7dc:	e010                	sd	a2,0(s0)
 7de:	e414                	sd	a3,8(s0)
 7e0:	e818                	sd	a4,16(s0)
 7e2:	ec1c                	sd	a5,24(s0)
 7e4:	03043023          	sd	a6,32(s0)
 7e8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f0:	8622                	mv	a2,s0
 7f2:	d3fff0ef          	jal	530 <vprintf>
}
 7f6:	60e2                	ld	ra,24(sp)
 7f8:	6442                	ld	s0,16(sp)
 7fa:	6161                	addi	sp,sp,80
 7fc:	8082                	ret

00000000000007fe <printf>:

void
printf(const char *fmt, ...)
{
 7fe:	711d                	addi	sp,sp,-96
 800:	ec06                	sd	ra,24(sp)
 802:	e822                	sd	s0,16(sp)
 804:	1000                	addi	s0,sp,32
 806:	e40c                	sd	a1,8(s0)
 808:	e810                	sd	a2,16(s0)
 80a:	ec14                	sd	a3,24(s0)
 80c:	f018                	sd	a4,32(s0)
 80e:	f41c                	sd	a5,40(s0)
 810:	03043823          	sd	a6,48(s0)
 814:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 818:	00840613          	addi	a2,s0,8
 81c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 820:	85aa                	mv	a1,a0
 822:	4505                	li	a0,1
 824:	d0dff0ef          	jal	530 <vprintf>
}
 828:	60e2                	ld	ra,24(sp)
 82a:	6442                	ld	s0,16(sp)
 82c:	6125                	addi	sp,sp,96
 82e:	8082                	ret

0000000000000830 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 830:	1141                	addi	sp,sp,-16
 832:	e422                	sd	s0,8(sp)
 834:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 836:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83a:	00000797          	auipc	a5,0x0
 83e:	7c67b783          	ld	a5,1990(a5) # 1000 <freep>
 842:	a02d                	j	86c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 844:	4618                	lw	a4,8(a2)
 846:	9f2d                	addw	a4,a4,a1
 848:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 84c:	6398                	ld	a4,0(a5)
 84e:	6310                	ld	a2,0(a4)
 850:	a83d                	j	88e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 852:	ff852703          	lw	a4,-8(a0)
 856:	9f31                	addw	a4,a4,a2
 858:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 85a:	ff053683          	ld	a3,-16(a0)
 85e:	a091                	j	8a2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 860:	6398                	ld	a4,0(a5)
 862:	00e7e463          	bltu	a5,a4,86a <free+0x3a>
 866:	00e6ea63          	bltu	a3,a4,87a <free+0x4a>
{
 86a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86c:	fed7fae3          	bgeu	a5,a3,860 <free+0x30>
 870:	6398                	ld	a4,0(a5)
 872:	00e6e463          	bltu	a3,a4,87a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 876:	fee7eae3          	bltu	a5,a4,86a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 87a:	ff852583          	lw	a1,-8(a0)
 87e:	6390                	ld	a2,0(a5)
 880:	02059813          	slli	a6,a1,0x20
 884:	01c85713          	srli	a4,a6,0x1c
 888:	9736                	add	a4,a4,a3
 88a:	fae60de3          	beq	a2,a4,844 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 88e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 892:	4790                	lw	a2,8(a5)
 894:	02061593          	slli	a1,a2,0x20
 898:	01c5d713          	srli	a4,a1,0x1c
 89c:	973e                	add	a4,a4,a5
 89e:	fae68ae3          	beq	a3,a4,852 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8a2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a4:	00000717          	auipc	a4,0x0
 8a8:	74f73e23          	sd	a5,1884(a4) # 1000 <freep>
}
 8ac:	6422                	ld	s0,8(sp)
 8ae:	0141                	addi	sp,sp,16
 8b0:	8082                	ret

00000000000008b2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b2:	7139                	addi	sp,sp,-64
 8b4:	fc06                	sd	ra,56(sp)
 8b6:	f822                	sd	s0,48(sp)
 8b8:	f426                	sd	s1,40(sp)
 8ba:	ec4e                	sd	s3,24(sp)
 8bc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8be:	02051493          	slli	s1,a0,0x20
 8c2:	9081                	srli	s1,s1,0x20
 8c4:	04bd                	addi	s1,s1,15
 8c6:	8091                	srli	s1,s1,0x4
 8c8:	0014899b          	addiw	s3,s1,1
 8cc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ce:	00000517          	auipc	a0,0x0
 8d2:	73253503          	ld	a0,1842(a0) # 1000 <freep>
 8d6:	c915                	beqz	a0,90a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8da:	4798                	lw	a4,8(a5)
 8dc:	08977a63          	bgeu	a4,s1,970 <malloc+0xbe>
 8e0:	f04a                	sd	s2,32(sp)
 8e2:	e852                	sd	s4,16(sp)
 8e4:	e456                	sd	s5,8(sp)
 8e6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8e8:	8a4e                	mv	s4,s3
 8ea:	0009871b          	sext.w	a4,s3
 8ee:	6685                	lui	a3,0x1
 8f0:	00d77363          	bgeu	a4,a3,8f6 <malloc+0x44>
 8f4:	6a05                	lui	s4,0x1
 8f6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8fa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8fe:	00000917          	auipc	s2,0x0
 902:	70290913          	addi	s2,s2,1794 # 1000 <freep>
  if(p == SBRK_ERROR)
 906:	5afd                	li	s5,-1
 908:	a081                	j	948 <malloc+0x96>
 90a:	f04a                	sd	s2,32(sp)
 90c:	e852                	sd	s4,16(sp)
 90e:	e456                	sd	s5,8(sp)
 910:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 912:	00000797          	auipc	a5,0x0
 916:	6fe78793          	addi	a5,a5,1790 # 1010 <base>
 91a:	00000717          	auipc	a4,0x0
 91e:	6ef73323          	sd	a5,1766(a4) # 1000 <freep>
 922:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 924:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 928:	b7c1                	j	8e8 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 92a:	6398                	ld	a4,0(a5)
 92c:	e118                	sd	a4,0(a0)
 92e:	a8a9                	j	988 <malloc+0xd6>
  hp->s.size = nu;
 930:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 934:	0541                	addi	a0,a0,16
 936:	efbff0ef          	jal	830 <free>
  return freep;
 93a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 93e:	c12d                	beqz	a0,9a0 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 940:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 942:	4798                	lw	a4,8(a5)
 944:	02977263          	bgeu	a4,s1,968 <malloc+0xb6>
    if(p == freep)
 948:	00093703          	ld	a4,0(s2)
 94c:	853e                	mv	a0,a5
 94e:	fef719e3          	bne	a4,a5,940 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 952:	8552                	mv	a0,s4
 954:	9cdff0ef          	jal	320 <sbrk>
  if(p == SBRK_ERROR)
 958:	fd551ce3          	bne	a0,s5,930 <malloc+0x7e>
        return 0;
 95c:	4501                	li	a0,0
 95e:	7902                	ld	s2,32(sp)
 960:	6a42                	ld	s4,16(sp)
 962:	6aa2                	ld	s5,8(sp)
 964:	6b02                	ld	s6,0(sp)
 966:	a03d                	j	994 <malloc+0xe2>
 968:	7902                	ld	s2,32(sp)
 96a:	6a42                	ld	s4,16(sp)
 96c:	6aa2                	ld	s5,8(sp)
 96e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 970:	fae48de3          	beq	s1,a4,92a <malloc+0x78>
        p->s.size -= nunits;
 974:	4137073b          	subw	a4,a4,s3
 978:	c798                	sw	a4,8(a5)
        p += p->s.size;
 97a:	02071693          	slli	a3,a4,0x20
 97e:	01c6d713          	srli	a4,a3,0x1c
 982:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 984:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 988:	00000717          	auipc	a4,0x0
 98c:	66a73c23          	sd	a0,1656(a4) # 1000 <freep>
      return (void*)(p + 1);
 990:	01078513          	addi	a0,a5,16
  }
}
 994:	70e2                	ld	ra,56(sp)
 996:	7442                	ld	s0,48(sp)
 998:	74a2                	ld	s1,40(sp)
 99a:	69e2                	ld	s3,24(sp)
 99c:	6121                	addi	sp,sp,64
 99e:	8082                	ret
 9a0:	7902                	ld	s2,32(sp)
 9a2:	6a42                	ld	s4,16(sp)
 9a4:	6aa2                	ld	s5,8(sp)
 9a6:	6b02                	ld	s6,0(sp)
 9a8:	b7f5                	j	994 <malloc+0xe2>
