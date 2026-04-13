
user/_waitpidtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
  int st;
  int p1, p2, p3;
  int r;

  p1 = fork();
   8:	328000ef          	jal	330 <fork>
  if(p1 == 0){
   c:	e901                	bnez	a0,1c <main+0x1c>
   e:	ec26                	sd	s1,24(sp)
    pause(20);
  10:	4551                	li	a0,20
  12:	3be000ef          	jal	3d0 <pause>
    exit(11);
  16:	452d                	li	a0,11
  18:	320000ef          	jal	338 <exit>
  }

  p2 = fork();
  1c:	314000ef          	jal	330 <fork>
  if(p2 == 0){
  20:	e901                	bnez	a0,30 <main+0x30>
  22:	ec26                	sd	s1,24(sp)
    pause(5);
  24:	4515                	li	a0,5
  26:	3aa000ef          	jal	3d0 <pause>
    exit(22);
  2a:	4559                	li	a0,22
  2c:	30c000ef          	jal	338 <exit>
  30:	ec26                	sd	s1,24(sp)
  }

  p3 = fork();
  32:	2fe000ef          	jal	330 <fork>
  36:	84aa                	mv	s1,a0
  if(p3 == 0){
  38:	e901                	bnez	a0,48 <main+0x48>
    pause(10);
  3a:	4529                	li	a0,10
  3c:	394000ef          	jal	3d0 <pause>
    exit(33);
  40:	02100513          	li	a0,33
  44:	2f4000ef          	jal	338 <exit>
  }

  printf("Parent waiting specifically for child pid = %d\n", p3);
  48:	85aa                	mv	a1,a0
  4a:	00001517          	auipc	a0,0x1
  4e:	94650513          	addi	a0,a0,-1722 # 990 <malloc+0xfa>
  52:	790000ef          	jal	7e2 <printf>
  r = waitpid(p3, &st);
  56:	fdc40593          	addi	a1,s0,-36
  5a:	8526                	mv	a0,s1
  5c:	2ec000ef          	jal	348 <waitpid>
  60:	85aa                	mv	a1,a0
  printf("waitpid returned pid = %d, status = %d\n", r, st);
  62:	fdc42603          	lw	a2,-36(s0)
  66:	00001517          	auipc	a0,0x1
  6a:	95a50513          	addi	a0,a0,-1702 # 9c0 <malloc+0x12a>
  6e:	774000ef          	jal	7e2 <printf>

  printf("Now collecting remaining children using wait()\n");
  72:	00001517          	auipc	a0,0x1
  76:	97650513          	addi	a0,a0,-1674 # 9e8 <malloc+0x152>
  7a:	768000ef          	jal	7e2 <printf>
  while(wait(&st) > 0){
    printf("wait collected one child, status = %d\n", st);
  7e:	00001497          	auipc	s1,0x1
  82:	99a48493          	addi	s1,s1,-1638 # a18 <malloc+0x182>
  while(wait(&st) > 0){
  86:	a031                	j	92 <main+0x92>
    printf("wait collected one child, status = %d\n", st);
  88:	fdc42583          	lw	a1,-36(s0)
  8c:	8526                	mv	a0,s1
  8e:	754000ef          	jal	7e2 <printf>
  while(wait(&st) > 0){
  92:	fdc40513          	addi	a0,s0,-36
  96:	2aa000ef          	jal	340 <wait>
  9a:	fea047e3          	bgtz	a0,88 <main+0x88>
  }

  exit(0);
  9e:	4501                	li	a0,0
  a0:	298000ef          	jal	338 <exit>

00000000000000a4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e406                	sd	ra,8(sp)
  a8:	e022                	sd	s0,0(sp)
  aa:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ac:	f55ff0ef          	jal	0 <main>
  exit(r);
  b0:	288000ef          	jal	338 <exit>

00000000000000b4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e422                	sd	s0,8(sp)
  b8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ba:	87aa                	mv	a5,a0
  bc:	0585                	addi	a1,a1,1
  be:	0785                	addi	a5,a5,1
  c0:	fff5c703          	lbu	a4,-1(a1)
  c4:	fee78fa3          	sb	a4,-1(a5)
  c8:	fb75                	bnez	a4,bc <strcpy+0x8>
    ;
  return os;
}
  ca:	6422                	ld	s0,8(sp)
  cc:	0141                	addi	sp,sp,16
  ce:	8082                	ret

00000000000000d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  d6:	00054783          	lbu	a5,0(a0)
  da:	cb91                	beqz	a5,ee <strcmp+0x1e>
  dc:	0005c703          	lbu	a4,0(a1)
  e0:	00f71763          	bne	a4,a5,ee <strcmp+0x1e>
    p++, q++;
  e4:	0505                	addi	a0,a0,1
  e6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	fbe5                	bnez	a5,dc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ee:	0005c503          	lbu	a0,0(a1)
}
  f2:	40a7853b          	subw	a0,a5,a0
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	addi	sp,sp,16
  fa:	8082                	ret

00000000000000fc <strlen>:

uint
strlen(const char *s)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 102:	00054783          	lbu	a5,0(a0)
 106:	cf91                	beqz	a5,122 <strlen+0x26>
 108:	0505                	addi	a0,a0,1
 10a:	87aa                	mv	a5,a0
 10c:	86be                	mv	a3,a5
 10e:	0785                	addi	a5,a5,1
 110:	fff7c703          	lbu	a4,-1(a5)
 114:	ff65                	bnez	a4,10c <strlen+0x10>
 116:	40a6853b          	subw	a0,a3,a0
 11a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 11c:	6422                	ld	s0,8(sp)
 11e:	0141                	addi	sp,sp,16
 120:	8082                	ret
  for(n = 0; s[n]; n++)
 122:	4501                	li	a0,0
 124:	bfe5                	j	11c <strlen+0x20>

0000000000000126 <memset>:

void*
memset(void *dst, int c, uint n)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 12c:	ca19                	beqz	a2,142 <memset+0x1c>
 12e:	87aa                	mv	a5,a0
 130:	1602                	slli	a2,a2,0x20
 132:	9201                	srli	a2,a2,0x20
 134:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 138:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 13c:	0785                	addi	a5,a5,1
 13e:	fee79de3          	bne	a5,a4,138 <memset+0x12>
  }
  return dst;
}
 142:	6422                	ld	s0,8(sp)
 144:	0141                	addi	sp,sp,16
 146:	8082                	ret

0000000000000148 <strchr>:

char*
strchr(const char *s, char c)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 14e:	00054783          	lbu	a5,0(a0)
 152:	cb99                	beqz	a5,168 <strchr+0x20>
    if(*s == c)
 154:	00f58763          	beq	a1,a5,162 <strchr+0x1a>
  for(; *s; s++)
 158:	0505                	addi	a0,a0,1
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbfd                	bnez	a5,154 <strchr+0xc>
      return (char*)s;
  return 0;
 160:	4501                	li	a0,0
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret
  return 0;
 168:	4501                	li	a0,0
 16a:	bfe5                	j	162 <strchr+0x1a>

000000000000016c <gets>:

char*
gets(char *buf, int max)
{
 16c:	711d                	addi	sp,sp,-96
 16e:	ec86                	sd	ra,88(sp)
 170:	e8a2                	sd	s0,80(sp)
 172:	e4a6                	sd	s1,72(sp)
 174:	e0ca                	sd	s2,64(sp)
 176:	fc4e                	sd	s3,56(sp)
 178:	f852                	sd	s4,48(sp)
 17a:	f456                	sd	s5,40(sp)
 17c:	f05a                	sd	s6,32(sp)
 17e:	ec5e                	sd	s7,24(sp)
 180:	1080                	addi	s0,sp,96
 182:	8baa                	mv	s7,a0
 184:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 186:	892a                	mv	s2,a0
 188:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 18a:	4aa9                	li	s5,10
 18c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 18e:	89a6                	mv	s3,s1
 190:	2485                	addiw	s1,s1,1
 192:	0344d663          	bge	s1,s4,1be <gets+0x52>
    cc = read(0, &c, 1);
 196:	4605                	li	a2,1
 198:	faf40593          	addi	a1,s0,-81
 19c:	4501                	li	a0,0
 19e:	1ba000ef          	jal	358 <read>
    if(cc < 1)
 1a2:	00a05e63          	blez	a0,1be <gets+0x52>
    buf[i++] = c;
 1a6:	faf44783          	lbu	a5,-81(s0)
 1aa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ae:	01578763          	beq	a5,s5,1bc <gets+0x50>
 1b2:	0905                	addi	s2,s2,1
 1b4:	fd679de3          	bne	a5,s6,18e <gets+0x22>
    buf[i++] = c;
 1b8:	89a6                	mv	s3,s1
 1ba:	a011                	j	1be <gets+0x52>
 1bc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1be:	99de                	add	s3,s3,s7
 1c0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1c4:	855e                	mv	a0,s7
 1c6:	60e6                	ld	ra,88(sp)
 1c8:	6446                	ld	s0,80(sp)
 1ca:	64a6                	ld	s1,72(sp)
 1cc:	6906                	ld	s2,64(sp)
 1ce:	79e2                	ld	s3,56(sp)
 1d0:	7a42                	ld	s4,48(sp)
 1d2:	7aa2                	ld	s5,40(sp)
 1d4:	7b02                	ld	s6,32(sp)
 1d6:	6be2                	ld	s7,24(sp)
 1d8:	6125                	addi	sp,sp,96
 1da:	8082                	ret

00000000000001dc <stat>:

int
stat(const char *n, struct stat *st)
{
 1dc:	1101                	addi	sp,sp,-32
 1de:	ec06                	sd	ra,24(sp)
 1e0:	e822                	sd	s0,16(sp)
 1e2:	e04a                	sd	s2,0(sp)
 1e4:	1000                	addi	s0,sp,32
 1e6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e8:	4581                	li	a1,0
 1ea:	196000ef          	jal	380 <open>
  if(fd < 0)
 1ee:	02054263          	bltz	a0,212 <stat+0x36>
 1f2:	e426                	sd	s1,8(sp)
 1f4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f6:	85ca                	mv	a1,s2
 1f8:	1a0000ef          	jal	398 <fstat>
 1fc:	892a                	mv	s2,a0
  close(fd);
 1fe:	8526                	mv	a0,s1
 200:	168000ef          	jal	368 <close>
  return r;
 204:	64a2                	ld	s1,8(sp)
}
 206:	854a                	mv	a0,s2
 208:	60e2                	ld	ra,24(sp)
 20a:	6442                	ld	s0,16(sp)
 20c:	6902                	ld	s2,0(sp)
 20e:	6105                	addi	sp,sp,32
 210:	8082                	ret
    return -1;
 212:	597d                	li	s2,-1
 214:	bfcd                	j	206 <stat+0x2a>

0000000000000216 <atoi>:

int
atoi(const char *s)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21c:	00054683          	lbu	a3,0(a0)
 220:	fd06879b          	addiw	a5,a3,-48
 224:	0ff7f793          	zext.b	a5,a5
 228:	4625                	li	a2,9
 22a:	02f66863          	bltu	a2,a5,25a <atoi+0x44>
 22e:	872a                	mv	a4,a0
  n = 0;
 230:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 232:	0705                	addi	a4,a4,1
 234:	0025179b          	slliw	a5,a0,0x2
 238:	9fa9                	addw	a5,a5,a0
 23a:	0017979b          	slliw	a5,a5,0x1
 23e:	9fb5                	addw	a5,a5,a3
 240:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 244:	00074683          	lbu	a3,0(a4)
 248:	fd06879b          	addiw	a5,a3,-48
 24c:	0ff7f793          	zext.b	a5,a5
 250:	fef671e3          	bgeu	a2,a5,232 <atoi+0x1c>
  return n;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret
  n = 0;
 25a:	4501                	li	a0,0
 25c:	bfe5                	j	254 <atoi+0x3e>

000000000000025e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 264:	02b57463          	bgeu	a0,a1,28c <memmove+0x2e>
    while(n-- > 0)
 268:	00c05f63          	blez	a2,286 <memmove+0x28>
 26c:	1602                	slli	a2,a2,0x20
 26e:	9201                	srli	a2,a2,0x20
 270:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 274:	872a                	mv	a4,a0
      *dst++ = *src++;
 276:	0585                	addi	a1,a1,1
 278:	0705                	addi	a4,a4,1
 27a:	fff5c683          	lbu	a3,-1(a1)
 27e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 282:	fef71ae3          	bne	a4,a5,276 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret
    dst += n;
 28c:	00c50733          	add	a4,a0,a2
    src += n;
 290:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 292:	fec05ae3          	blez	a2,286 <memmove+0x28>
 296:	fff6079b          	addiw	a5,a2,-1
 29a:	1782                	slli	a5,a5,0x20
 29c:	9381                	srli	a5,a5,0x20
 29e:	fff7c793          	not	a5,a5
 2a2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a4:	15fd                	addi	a1,a1,-1
 2a6:	177d                	addi	a4,a4,-1
 2a8:	0005c683          	lbu	a3,0(a1)
 2ac:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b0:	fee79ae3          	bne	a5,a4,2a4 <memmove+0x46>
 2b4:	bfc9                	j	286 <memmove+0x28>

00000000000002b6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e422                	sd	s0,8(sp)
 2ba:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2bc:	ca05                	beqz	a2,2ec <memcmp+0x36>
 2be:	fff6069b          	addiw	a3,a2,-1
 2c2:	1682                	slli	a3,a3,0x20
 2c4:	9281                	srli	a3,a3,0x20
 2c6:	0685                	addi	a3,a3,1
 2c8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	0005c703          	lbu	a4,0(a1)
 2d2:	00e79863          	bne	a5,a4,2e2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2d6:	0505                	addi	a0,a0,1
    p2++;
 2d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2da:	fed518e3          	bne	a0,a3,2ca <memcmp+0x14>
  }
  return 0;
 2de:	4501                	li	a0,0
 2e0:	a019                	j	2e6 <memcmp+0x30>
      return *p1 - *p2;
 2e2:	40e7853b          	subw	a0,a5,a4
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
  return 0;
 2ec:	4501                	li	a0,0
 2ee:	bfe5                	j	2e6 <memcmp+0x30>

00000000000002f0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2f8:	f67ff0ef          	jal	25e <memmove>
}
 2fc:	60a2                	ld	ra,8(sp)
 2fe:	6402                	ld	s0,0(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret

0000000000000304 <sbrk>:

char *
sbrk(int n) {
 304:	1141                	addi	sp,sp,-16
 306:	e406                	sd	ra,8(sp)
 308:	e022                	sd	s0,0(sp)
 30a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 30c:	4585                	li	a1,1
 30e:	0ba000ef          	jal	3c8 <sys_sbrk>
}
 312:	60a2                	ld	ra,8(sp)
 314:	6402                	ld	s0,0(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret

000000000000031a <sbrklazy>:

char *
sbrklazy(int n) {
 31a:	1141                	addi	sp,sp,-16
 31c:	e406                	sd	ra,8(sp)
 31e:	e022                	sd	s0,0(sp)
 320:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 322:	4589                	li	a1,2
 324:	0a4000ef          	jal	3c8 <sys_sbrk>
}
 328:	60a2                	ld	ra,8(sp)
 32a:	6402                	ld	s0,0(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret

0000000000000330 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 330:	4885                	li	a7,1
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <exit>:
.global exit
exit:
 li a7, SYS_exit
 338:	4889                	li	a7,2
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <wait>:
.global wait
wait:
 li a7, SYS_wait
 340:	488d                	li	a7,3
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 348:	48d9                	li	a7,22
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 350:	4891                	li	a7,4
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <read>:
.global read
read:
 li a7, SYS_read
 358:	4895                	li	a7,5
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <write>:
.global write
write:
 li a7, SYS_write
 360:	48c1                	li	a7,16
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <close>:
.global close
close:
 li a7, SYS_close
 368:	48d5                	li	a7,21
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <kill>:
.global kill
kill:
 li a7, SYS_kill
 370:	4899                	li	a7,6
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <exec>:
.global exec
exec:
 li a7, SYS_exec
 378:	489d                	li	a7,7
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <open>:
.global open
open:
 li a7, SYS_open
 380:	48bd                	li	a7,15
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 388:	48c5                	li	a7,17
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 390:	48c9                	li	a7,18
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 398:	48a1                	li	a7,8
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <link>:
.global link
link:
 li a7, SYS_link
 3a0:	48cd                	li	a7,19
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a8:	48d1                	li	a7,20
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b0:	48a5                	li	a7,9
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b8:	48a9                	li	a7,10
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c0:	48ad                	li	a7,11
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3c8:	48b1                	li	a7,12
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3d0:	48b5                	li	a7,13
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d8:	48b9                	li	a7,14
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3e0:	48dd                	li	a7,23
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 3e8:	48e1                	li	a7,24
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <mutex_init>:
.global mutex_init
mutex_init:
 li a7, SYS_mutex_init
 3f0:	48e5                	li	a7,25
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <mutex_acquire>:
.global mutex_acquire
mutex_acquire:
 li a7, SYS_mutex_acquire
 3f8:	48e9                	li	a7,26
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <mutex_release>:
.global mutex_release
mutex_release:
 li a7, SYS_mutex_release
 400:	48ed                	li	a7,27
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 408:	48f1                	li	a7,28
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 410:	48f5                	li	a7,29
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 418:	48f9                	li	a7,30
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <setp>:
.global setp
setp:
 li a7, SYS_setp
 420:	48fd                	li	a7,31
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <ismyear>:
.global ismyear
ismyear:
 li a7, SYS_ismyear
 428:	02000893          	li	a7,32
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 432:	02100893          	li	a7,33
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 43c:	02200893          	li	a7,34
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <thread_exit>:
.global thread_exit
thread_exit:
 li a7, SYS_thread_exit
 446:	02300893          	li	a7,35
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <thread_id>:
.global thread_id
thread_id:
 li a7, SYS_thread_id
 450:	02400893          	li	a7,36
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 45a:	1101                	addi	sp,sp,-32
 45c:	ec06                	sd	ra,24(sp)
 45e:	e822                	sd	s0,16(sp)
 460:	1000                	addi	s0,sp,32
 462:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 466:	4605                	li	a2,1
 468:	fef40593          	addi	a1,s0,-17
 46c:	ef5ff0ef          	jal	360 <write>
}
 470:	60e2                	ld	ra,24(sp)
 472:	6442                	ld	s0,16(sp)
 474:	6105                	addi	sp,sp,32
 476:	8082                	ret

0000000000000478 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 478:	715d                	addi	sp,sp,-80
 47a:	e486                	sd	ra,72(sp)
 47c:	e0a2                	sd	s0,64(sp)
 47e:	f84a                	sd	s2,48(sp)
 480:	0880                	addi	s0,sp,80
 482:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 484:	c299                	beqz	a3,48a <printint+0x12>
 486:	0805c363          	bltz	a1,50c <printint+0x94>
  neg = 0;
 48a:	4881                	li	a7,0
 48c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 490:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 492:	00000517          	auipc	a0,0x0
 496:	5b650513          	addi	a0,a0,1462 # a48 <digits>
 49a:	883e                	mv	a6,a5
 49c:	2785                	addiw	a5,a5,1
 49e:	02c5f733          	remu	a4,a1,a2
 4a2:	972a                	add	a4,a4,a0
 4a4:	00074703          	lbu	a4,0(a4)
 4a8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4ac:	872e                	mv	a4,a1
 4ae:	02c5d5b3          	divu	a1,a1,a2
 4b2:	0685                	addi	a3,a3,1
 4b4:	fec773e3          	bgeu	a4,a2,49a <printint+0x22>
  if(neg)
 4b8:	00088b63          	beqz	a7,4ce <printint+0x56>
    buf[i++] = '-';
 4bc:	fd078793          	addi	a5,a5,-48
 4c0:	97a2                	add	a5,a5,s0
 4c2:	02d00713          	li	a4,45
 4c6:	fee78423          	sb	a4,-24(a5)
 4ca:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4ce:	02f05a63          	blez	a5,502 <printint+0x8a>
 4d2:	fc26                	sd	s1,56(sp)
 4d4:	f44e                	sd	s3,40(sp)
 4d6:	fb840713          	addi	a4,s0,-72
 4da:	00f704b3          	add	s1,a4,a5
 4de:	fff70993          	addi	s3,a4,-1
 4e2:	99be                	add	s3,s3,a5
 4e4:	37fd                	addiw	a5,a5,-1
 4e6:	1782                	slli	a5,a5,0x20
 4e8:	9381                	srli	a5,a5,0x20
 4ea:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4ee:	fff4c583          	lbu	a1,-1(s1)
 4f2:	854a                	mv	a0,s2
 4f4:	f67ff0ef          	jal	45a <putc>
  while(--i >= 0)
 4f8:	14fd                	addi	s1,s1,-1
 4fa:	ff349ae3          	bne	s1,s3,4ee <printint+0x76>
 4fe:	74e2                	ld	s1,56(sp)
 500:	79a2                	ld	s3,40(sp)
}
 502:	60a6                	ld	ra,72(sp)
 504:	6406                	ld	s0,64(sp)
 506:	7942                	ld	s2,48(sp)
 508:	6161                	addi	sp,sp,80
 50a:	8082                	ret
    x = -xx;
 50c:	40b005b3          	neg	a1,a1
    neg = 1;
 510:	4885                	li	a7,1
    x = -xx;
 512:	bfad                	j	48c <printint+0x14>

0000000000000514 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 514:	711d                	addi	sp,sp,-96
 516:	ec86                	sd	ra,88(sp)
 518:	e8a2                	sd	s0,80(sp)
 51a:	e0ca                	sd	s2,64(sp)
 51c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 51e:	0005c903          	lbu	s2,0(a1)
 522:	28090663          	beqz	s2,7ae <vprintf+0x29a>
 526:	e4a6                	sd	s1,72(sp)
 528:	fc4e                	sd	s3,56(sp)
 52a:	f852                	sd	s4,48(sp)
 52c:	f456                	sd	s5,40(sp)
 52e:	f05a                	sd	s6,32(sp)
 530:	ec5e                	sd	s7,24(sp)
 532:	e862                	sd	s8,16(sp)
 534:	e466                	sd	s9,8(sp)
 536:	8b2a                	mv	s6,a0
 538:	8a2e                	mv	s4,a1
 53a:	8bb2                	mv	s7,a2
  state = 0;
 53c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 53e:	4481                	li	s1,0
 540:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 542:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 546:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 54a:	06c00c93          	li	s9,108
 54e:	a005                	j	56e <vprintf+0x5a>
        putc(fd, c0);
 550:	85ca                	mv	a1,s2
 552:	855a                	mv	a0,s6
 554:	f07ff0ef          	jal	45a <putc>
 558:	a019                	j	55e <vprintf+0x4a>
    } else if(state == '%'){
 55a:	03598263          	beq	s3,s5,57e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 55e:	2485                	addiw	s1,s1,1
 560:	8726                	mv	a4,s1
 562:	009a07b3          	add	a5,s4,s1
 566:	0007c903          	lbu	s2,0(a5)
 56a:	22090a63          	beqz	s2,79e <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 56e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 572:	fe0994e3          	bnez	s3,55a <vprintf+0x46>
      if(c0 == '%'){
 576:	fd579de3          	bne	a5,s5,550 <vprintf+0x3c>
        state = '%';
 57a:	89be                	mv	s3,a5
 57c:	b7cd                	j	55e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 57e:	00ea06b3          	add	a3,s4,a4
 582:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 586:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 588:	c681                	beqz	a3,590 <vprintf+0x7c>
 58a:	9752                	add	a4,a4,s4
 58c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 590:	05878363          	beq	a5,s8,5d6 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 594:	05978d63          	beq	a5,s9,5ee <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 598:	07500713          	li	a4,117
 59c:	0ee78763          	beq	a5,a4,68a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5a0:	07800713          	li	a4,120
 5a4:	12e78963          	beq	a5,a4,6d6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5a8:	07000713          	li	a4,112
 5ac:	14e78e63          	beq	a5,a4,708 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5b0:	06300713          	li	a4,99
 5b4:	18e78e63          	beq	a5,a4,750 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5b8:	07300713          	li	a4,115
 5bc:	1ae78463          	beq	a5,a4,764 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5c0:	02500713          	li	a4,37
 5c4:	04e79563          	bne	a5,a4,60e <vprintf+0xfa>
        putc(fd, '%');
 5c8:	02500593          	li	a1,37
 5cc:	855a                	mv	a0,s6
 5ce:	e8dff0ef          	jal	45a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b769                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4685                	li	a3,1
 5dc:	4629                	li	a2,10
 5de:	000ba583          	lw	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	e95ff0ef          	jal	478 <printint>
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	bf8d                	j	55e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ee:	06400793          	li	a5,100
 5f2:	02f68963          	beq	a3,a5,624 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f6:	06c00793          	li	a5,108
 5fa:	04f68263          	beq	a3,a5,63e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5fe:	07500793          	li	a5,117
 602:	0af68063          	beq	a3,a5,6a2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 606:	07800793          	li	a5,120
 60a:	0ef68263          	beq	a3,a5,6ee <vprintf+0x1da>
        putc(fd, '%');
 60e:	02500593          	li	a1,37
 612:	855a                	mv	a0,s6
 614:	e47ff0ef          	jal	45a <putc>
        putc(fd, c0);
 618:	85ca                	mv	a1,s2
 61a:	855a                	mv	a0,s6
 61c:	e3fff0ef          	jal	45a <putc>
      state = 0;
 620:	4981                	li	s3,0
 622:	bf35                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 624:	008b8913          	addi	s2,s7,8
 628:	4685                	li	a3,1
 62a:	4629                	li	a2,10
 62c:	000bb583          	ld	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	e47ff0ef          	jal	478 <printint>
        i += 1;
 636:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
        i += 1;
 63c:	b70d                	j	55e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 63e:	06400793          	li	a5,100
 642:	02f60763          	beq	a2,a5,670 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 646:	07500793          	li	a5,117
 64a:	06f60963          	beq	a2,a5,6bc <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 64e:	07800793          	li	a5,120
 652:	faf61ee3          	bne	a2,a5,60e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 656:	008b8913          	addi	s2,s7,8
 65a:	4681                	li	a3,0
 65c:	4641                	li	a2,16
 65e:	000bb583          	ld	a1,0(s7)
 662:	855a                	mv	a0,s6
 664:	e15ff0ef          	jal	478 <printint>
        i += 2;
 668:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 66a:	8bca                	mv	s7,s2
      state = 0;
 66c:	4981                	li	s3,0
        i += 2;
 66e:	bdc5                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 670:	008b8913          	addi	s2,s7,8
 674:	4685                	li	a3,1
 676:	4629                	li	a2,10
 678:	000bb583          	ld	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	dfbff0ef          	jal	478 <printint>
        i += 2;
 682:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
        i += 2;
 688:	bdd9                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 68a:	008b8913          	addi	s2,s7,8
 68e:	4681                	li	a3,0
 690:	4629                	li	a2,10
 692:	000be583          	lwu	a1,0(s7)
 696:	855a                	mv	a0,s6
 698:	de1ff0ef          	jal	478 <printint>
 69c:	8bca                	mv	s7,s2
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	bd7d                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a2:	008b8913          	addi	s2,s7,8
 6a6:	4681                	li	a3,0
 6a8:	4629                	li	a2,10
 6aa:	000bb583          	ld	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	dc9ff0ef          	jal	478 <printint>
        i += 1;
 6b4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b6:	8bca                	mv	s7,s2
      state = 0;
 6b8:	4981                	li	s3,0
        i += 1;
 6ba:	b555                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6bc:	008b8913          	addi	s2,s7,8
 6c0:	4681                	li	a3,0
 6c2:	4629                	li	a2,10
 6c4:	000bb583          	ld	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	dafff0ef          	jal	478 <printint>
        i += 2;
 6ce:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
        i += 2;
 6d4:	b569                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6d6:	008b8913          	addi	s2,s7,8
 6da:	4681                	li	a3,0
 6dc:	4641                	li	a2,16
 6de:	000be583          	lwu	a1,0(s7)
 6e2:	855a                	mv	a0,s6
 6e4:	d95ff0ef          	jal	478 <printint>
 6e8:	8bca                	mv	s7,s2
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bd8d                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ee:	008b8913          	addi	s2,s7,8
 6f2:	4681                	li	a3,0
 6f4:	4641                	li	a2,16
 6f6:	000bb583          	ld	a1,0(s7)
 6fa:	855a                	mv	a0,s6
 6fc:	d7dff0ef          	jal	478 <printint>
        i += 1;
 700:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 702:	8bca                	mv	s7,s2
      state = 0;
 704:	4981                	li	s3,0
        i += 1;
 706:	bda1                	j	55e <vprintf+0x4a>
 708:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 70a:	008b8d13          	addi	s10,s7,8
 70e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 712:	03000593          	li	a1,48
 716:	855a                	mv	a0,s6
 718:	d43ff0ef          	jal	45a <putc>
  putc(fd, 'x');
 71c:	07800593          	li	a1,120
 720:	855a                	mv	a0,s6
 722:	d39ff0ef          	jal	45a <putc>
 726:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 728:	00000b97          	auipc	s7,0x0
 72c:	320b8b93          	addi	s7,s7,800 # a48 <digits>
 730:	03c9d793          	srli	a5,s3,0x3c
 734:	97de                	add	a5,a5,s7
 736:	0007c583          	lbu	a1,0(a5)
 73a:	855a                	mv	a0,s6
 73c:	d1fff0ef          	jal	45a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 740:	0992                	slli	s3,s3,0x4
 742:	397d                	addiw	s2,s2,-1
 744:	fe0916e3          	bnez	s2,730 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 748:	8bea                	mv	s7,s10
      state = 0;
 74a:	4981                	li	s3,0
 74c:	6d02                	ld	s10,0(sp)
 74e:	bd01                	j	55e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 750:	008b8913          	addi	s2,s7,8
 754:	000bc583          	lbu	a1,0(s7)
 758:	855a                	mv	a0,s6
 75a:	d01ff0ef          	jal	45a <putc>
 75e:	8bca                	mv	s7,s2
      state = 0;
 760:	4981                	li	s3,0
 762:	bbf5                	j	55e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 764:	008b8993          	addi	s3,s7,8
 768:	000bb903          	ld	s2,0(s7)
 76c:	00090f63          	beqz	s2,78a <vprintf+0x276>
        for(; *s; s++)
 770:	00094583          	lbu	a1,0(s2)
 774:	c195                	beqz	a1,798 <vprintf+0x284>
          putc(fd, *s);
 776:	855a                	mv	a0,s6
 778:	ce3ff0ef          	jal	45a <putc>
        for(; *s; s++)
 77c:	0905                	addi	s2,s2,1
 77e:	00094583          	lbu	a1,0(s2)
 782:	f9f5                	bnez	a1,776 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 784:	8bce                	mv	s7,s3
      state = 0;
 786:	4981                	li	s3,0
 788:	bbd9                	j	55e <vprintf+0x4a>
          s = "(null)";
 78a:	00000917          	auipc	s2,0x0
 78e:	2b690913          	addi	s2,s2,694 # a40 <malloc+0x1aa>
        for(; *s; s++)
 792:	02800593          	li	a1,40
 796:	b7c5                	j	776 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 798:	8bce                	mv	s7,s3
      state = 0;
 79a:	4981                	li	s3,0
 79c:	b3c9                	j	55e <vprintf+0x4a>
 79e:	64a6                	ld	s1,72(sp)
 7a0:	79e2                	ld	s3,56(sp)
 7a2:	7a42                	ld	s4,48(sp)
 7a4:	7aa2                	ld	s5,40(sp)
 7a6:	7b02                	ld	s6,32(sp)
 7a8:	6be2                	ld	s7,24(sp)
 7aa:	6c42                	ld	s8,16(sp)
 7ac:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7ae:	60e6                	ld	ra,88(sp)
 7b0:	6446                	ld	s0,80(sp)
 7b2:	6906                	ld	s2,64(sp)
 7b4:	6125                	addi	sp,sp,96
 7b6:	8082                	ret

00000000000007b8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b8:	715d                	addi	sp,sp,-80
 7ba:	ec06                	sd	ra,24(sp)
 7bc:	e822                	sd	s0,16(sp)
 7be:	1000                	addi	s0,sp,32
 7c0:	e010                	sd	a2,0(s0)
 7c2:	e414                	sd	a3,8(s0)
 7c4:	e818                	sd	a4,16(s0)
 7c6:	ec1c                	sd	a5,24(s0)
 7c8:	03043023          	sd	a6,32(s0)
 7cc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d4:	8622                	mv	a2,s0
 7d6:	d3fff0ef          	jal	514 <vprintf>
}
 7da:	60e2                	ld	ra,24(sp)
 7dc:	6442                	ld	s0,16(sp)
 7de:	6161                	addi	sp,sp,80
 7e0:	8082                	ret

00000000000007e2 <printf>:

void
printf(const char *fmt, ...)
{
 7e2:	711d                	addi	sp,sp,-96
 7e4:	ec06                	sd	ra,24(sp)
 7e6:	e822                	sd	s0,16(sp)
 7e8:	1000                	addi	s0,sp,32
 7ea:	e40c                	sd	a1,8(s0)
 7ec:	e810                	sd	a2,16(s0)
 7ee:	ec14                	sd	a3,24(s0)
 7f0:	f018                	sd	a4,32(s0)
 7f2:	f41c                	sd	a5,40(s0)
 7f4:	03043823          	sd	a6,48(s0)
 7f8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fc:	00840613          	addi	a2,s0,8
 800:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 804:	85aa                	mv	a1,a0
 806:	4505                	li	a0,1
 808:	d0dff0ef          	jal	514 <vprintf>
}
 80c:	60e2                	ld	ra,24(sp)
 80e:	6442                	ld	s0,16(sp)
 810:	6125                	addi	sp,sp,96
 812:	8082                	ret

0000000000000814 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 814:	1141                	addi	sp,sp,-16
 816:	e422                	sd	s0,8(sp)
 818:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81e:	00000797          	auipc	a5,0x0
 822:	7e27b783          	ld	a5,2018(a5) # 1000 <freep>
 826:	a02d                	j	850 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 828:	4618                	lw	a4,8(a2)
 82a:	9f2d                	addw	a4,a4,a1
 82c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	6398                	ld	a4,0(a5)
 832:	6310                	ld	a2,0(a4)
 834:	a83d                	j	872 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 836:	ff852703          	lw	a4,-8(a0)
 83a:	9f31                	addw	a4,a4,a2
 83c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 83e:	ff053683          	ld	a3,-16(a0)
 842:	a091                	j	886 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 844:	6398                	ld	a4,0(a5)
 846:	00e7e463          	bltu	a5,a4,84e <free+0x3a>
 84a:	00e6ea63          	bltu	a3,a4,85e <free+0x4a>
{
 84e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 850:	fed7fae3          	bgeu	a5,a3,844 <free+0x30>
 854:	6398                	ld	a4,0(a5)
 856:	00e6e463          	bltu	a3,a4,85e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85a:	fee7eae3          	bltu	a5,a4,84e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 85e:	ff852583          	lw	a1,-8(a0)
 862:	6390                	ld	a2,0(a5)
 864:	02059813          	slli	a6,a1,0x20
 868:	01c85713          	srli	a4,a6,0x1c
 86c:	9736                	add	a4,a4,a3
 86e:	fae60de3          	beq	a2,a4,828 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 872:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 876:	4790                	lw	a2,8(a5)
 878:	02061593          	slli	a1,a2,0x20
 87c:	01c5d713          	srli	a4,a1,0x1c
 880:	973e                	add	a4,a4,a5
 882:	fae68ae3          	beq	a3,a4,836 <free+0x22>
    p->s.ptr = bp->s.ptr;
 886:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 888:	00000717          	auipc	a4,0x0
 88c:	76f73c23          	sd	a5,1912(a4) # 1000 <freep>
}
 890:	6422                	ld	s0,8(sp)
 892:	0141                	addi	sp,sp,16
 894:	8082                	ret

0000000000000896 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 896:	7139                	addi	sp,sp,-64
 898:	fc06                	sd	ra,56(sp)
 89a:	f822                	sd	s0,48(sp)
 89c:	f426                	sd	s1,40(sp)
 89e:	ec4e                	sd	s3,24(sp)
 8a0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a2:	02051493          	slli	s1,a0,0x20
 8a6:	9081                	srli	s1,s1,0x20
 8a8:	04bd                	addi	s1,s1,15
 8aa:	8091                	srli	s1,s1,0x4
 8ac:	0014899b          	addiw	s3,s1,1
 8b0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8b2:	00000517          	auipc	a0,0x0
 8b6:	74e53503          	ld	a0,1870(a0) # 1000 <freep>
 8ba:	c915                	beqz	a0,8ee <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8be:	4798                	lw	a4,8(a5)
 8c0:	08977a63          	bgeu	a4,s1,954 <malloc+0xbe>
 8c4:	f04a                	sd	s2,32(sp)
 8c6:	e852                	sd	s4,16(sp)
 8c8:	e456                	sd	s5,8(sp)
 8ca:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8cc:	8a4e                	mv	s4,s3
 8ce:	0009871b          	sext.w	a4,s3
 8d2:	6685                	lui	a3,0x1
 8d4:	00d77363          	bgeu	a4,a3,8da <malloc+0x44>
 8d8:	6a05                	lui	s4,0x1
 8da:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8de:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e2:	00000917          	auipc	s2,0x0
 8e6:	71e90913          	addi	s2,s2,1822 # 1000 <freep>
  if(p == SBRK_ERROR)
 8ea:	5afd                	li	s5,-1
 8ec:	a081                	j	92c <malloc+0x96>
 8ee:	f04a                	sd	s2,32(sp)
 8f0:	e852                	sd	s4,16(sp)
 8f2:	e456                	sd	s5,8(sp)
 8f4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8f6:	00000797          	auipc	a5,0x0
 8fa:	71a78793          	addi	a5,a5,1818 # 1010 <base>
 8fe:	00000717          	auipc	a4,0x0
 902:	70f73123          	sd	a5,1794(a4) # 1000 <freep>
 906:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 908:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 90c:	b7c1                	j	8cc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 90e:	6398                	ld	a4,0(a5)
 910:	e118                	sd	a4,0(a0)
 912:	a8a9                	j	96c <malloc+0xd6>
  hp->s.size = nu;
 914:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 918:	0541                	addi	a0,a0,16
 91a:	efbff0ef          	jal	814 <free>
  return freep;
 91e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 922:	c12d                	beqz	a0,984 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 924:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 926:	4798                	lw	a4,8(a5)
 928:	02977263          	bgeu	a4,s1,94c <malloc+0xb6>
    if(p == freep)
 92c:	00093703          	ld	a4,0(s2)
 930:	853e                	mv	a0,a5
 932:	fef719e3          	bne	a4,a5,924 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 936:	8552                	mv	a0,s4
 938:	9cdff0ef          	jal	304 <sbrk>
  if(p == SBRK_ERROR)
 93c:	fd551ce3          	bne	a0,s5,914 <malloc+0x7e>
        return 0;
 940:	4501                	li	a0,0
 942:	7902                	ld	s2,32(sp)
 944:	6a42                	ld	s4,16(sp)
 946:	6aa2                	ld	s5,8(sp)
 948:	6b02                	ld	s6,0(sp)
 94a:	a03d                	j	978 <malloc+0xe2>
 94c:	7902                	ld	s2,32(sp)
 94e:	6a42                	ld	s4,16(sp)
 950:	6aa2                	ld	s5,8(sp)
 952:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 954:	fae48de3          	beq	s1,a4,90e <malloc+0x78>
        p->s.size -= nunits;
 958:	4137073b          	subw	a4,a4,s3
 95c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 95e:	02071693          	slli	a3,a4,0x20
 962:	01c6d713          	srli	a4,a3,0x1c
 966:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 968:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 96c:	00000717          	auipc	a4,0x0
 970:	68a73a23          	sd	a0,1684(a4) # 1000 <freep>
      return (void*)(p + 1);
 974:	01078513          	addi	a0,a5,16
  }
}
 978:	70e2                	ld	ra,56(sp)
 97a:	7442                	ld	s0,48(sp)
 97c:	74a2                	ld	s1,40(sp)
 97e:	69e2                	ld	s3,24(sp)
 980:	6121                	addi	sp,sp,64
 982:	8082                	ret
 984:	7902                	ld	s2,32(sp)
 986:	6a42                	ld	s4,16(sp)
 988:	6aa2                	ld	s5,8(sp)
 98a:	6b02                	ld	s6,0(sp)
 98c:	b7f5                	j	978 <malloc+0xe2>
