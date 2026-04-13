
user/_shmtest:     file format elf64-littleriscv


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
  int pid;
  char *buf;

  pid = fork();
   8:	34a000ef          	jal	352 <fork>
  if(pid < 0){
   c:	04054563          	bltz	a0,56 <main+0x56>
    printf("fork failed\n");
    exit(1);
  }

  if(pid == 0){
  10:	e535                	bnez	a0,7c <main+0x7c>
  12:	e426                	sd	s1,8(sp)
    // child
    buf = shmget(0);
  14:	3ee000ef          	jal	402 <shmget>
  18:	84aa                	mv	s1,a0
    if(buf == 0){
  1a:	c921                	beqz	a0,6a <main+0x6a>
      printf("child: shmget failed\n");
      exit(1);
    }

    while(buf[0] == 0)
  1c:	00054783          	lbu	a5,0(a0)
  20:	e799                	bnez	a5,2e <main+0x2e>
      pause(1);
  22:	4505                	li	a0,1
  24:	3ce000ef          	jal	3f2 <pause>
    while(buf[0] == 0)
  28:	0004c783          	lbu	a5,0(s1)
  2c:	dbfd                	beqz	a5,22 <main+0x22>

    printf("child read: %s\n", buf);
  2e:	85a6                	mv	a1,s1
  30:	00001517          	auipc	a0,0x1
  34:	9a850513          	addi	a0,a0,-1624 # 9d8 <malloc+0x120>
  38:	7cc000ef          	jal	804 <printf>

    strcpy(buf, "ack from child");
  3c:	00001597          	auipc	a1,0x1
  40:	9ac58593          	addi	a1,a1,-1620 # 9e8 <malloc+0x130>
  44:	8526                	mv	a0,s1
  46:	090000ef          	jal	d6 <strcpy>

    shmdt(0);
  4a:	4501                	li	a0,0
  4c:	3be000ef          	jal	40a <shmdt>
    exit(0);
  50:	4501                	li	a0,0
  52:	308000ef          	jal	35a <exit>
  56:	e426                	sd	s1,8(sp)
    printf("fork failed\n");
  58:	00001517          	auipc	a0,0x1
  5c:	95850513          	addi	a0,a0,-1704 # 9b0 <malloc+0xf8>
  60:	7a4000ef          	jal	804 <printf>
    exit(1);
  64:	4505                	li	a0,1
  66:	2f4000ef          	jal	35a <exit>
      printf("child: shmget failed\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	95650513          	addi	a0,a0,-1706 # 9c0 <malloc+0x108>
  72:	792000ef          	jal	804 <printf>
      exit(1);
  76:	4505                	li	a0,1
  78:	2e2000ef          	jal	35a <exit>
  7c:	e426                	sd	s1,8(sp)
  }

  // parent
  buf = shmget(0);
  7e:	4501                	li	a0,0
  80:	382000ef          	jal	402 <shmget>
  84:	84aa                	mv	s1,a0
  if(buf == 0){
  86:	c51d                	beqz	a0,b4 <main+0xb4>
    printf("parent: shmget failed\n");
    exit(1);
  }

  strcpy(buf, "hello from parent");
  88:	00001597          	auipc	a1,0x1
  8c:	98858593          	addi	a1,a1,-1656 # a10 <malloc+0x158>
  90:	046000ef          	jal	d6 <strcpy>

  wait(0);
  94:	4501                	li	a0,0
  96:	2cc000ef          	jal	362 <wait>

  printf("parent sees after child: %s\n", buf);
  9a:	85a6                	mv	a1,s1
  9c:	00001517          	auipc	a0,0x1
  a0:	98c50513          	addi	a0,a0,-1652 # a28 <malloc+0x170>
  a4:	760000ef          	jal	804 <printf>

  shmdt(0);
  a8:	4501                	li	a0,0
  aa:	360000ef          	jal	40a <shmdt>
  exit(0);
  ae:	4501                	li	a0,0
  b0:	2aa000ef          	jal	35a <exit>
    printf("parent: shmget failed\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	94450513          	addi	a0,a0,-1724 # 9f8 <malloc+0x140>
  bc:	748000ef          	jal	804 <printf>
    exit(1);
  c0:	4505                	li	a0,1
  c2:	298000ef          	jal	35a <exit>

00000000000000c6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e406                	sd	ra,8(sp)
  ca:	e022                	sd	s0,0(sp)
  cc:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ce:	f33ff0ef          	jal	0 <main>
  exit(r);
  d2:	288000ef          	jal	35a <exit>

00000000000000d6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  dc:	87aa                	mv	a5,a0
  de:	0585                	addi	a1,a1,1
  e0:	0785                	addi	a5,a5,1
  e2:	fff5c703          	lbu	a4,-1(a1)
  e6:	fee78fa3          	sb	a4,-1(a5)
  ea:	fb75                	bnez	a4,de <strcpy+0x8>
    ;
  return os;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cb91                	beqz	a5,110 <strcmp+0x1e>
  fe:	0005c703          	lbu	a4,0(a1)
 102:	00f71763          	bne	a4,a5,110 <strcmp+0x1e>
    p++, q++;
 106:	0505                	addi	a0,a0,1
 108:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	fbe5                	bnez	a5,fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 110:	0005c503          	lbu	a0,0(a1)
}
 114:	40a7853b          	subw	a0,a5,a0
 118:	6422                	ld	s0,8(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <strlen>:

uint
strlen(const char *s)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 124:	00054783          	lbu	a5,0(a0)
 128:	cf91                	beqz	a5,144 <strlen+0x26>
 12a:	0505                	addi	a0,a0,1
 12c:	87aa                	mv	a5,a0
 12e:	86be                	mv	a3,a5
 130:	0785                	addi	a5,a5,1
 132:	fff7c703          	lbu	a4,-1(a5)
 136:	ff65                	bnez	a4,12e <strlen+0x10>
 138:	40a6853b          	subw	a0,a3,a0
 13c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret
  for(n = 0; s[n]; n++)
 144:	4501                	li	a0,0
 146:	bfe5                	j	13e <strlen+0x20>

0000000000000148 <memset>:

void*
memset(void *dst, int c, uint n)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14e:	ca19                	beqz	a2,164 <memset+0x1c>
 150:	87aa                	mv	a5,a0
 152:	1602                	slli	a2,a2,0x20
 154:	9201                	srli	a2,a2,0x20
 156:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 15a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15e:	0785                	addi	a5,a5,1
 160:	fee79de3          	bne	a5,a4,15a <memset+0x12>
  }
  return dst;
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret

000000000000016a <strchr>:

char*
strchr(const char *s, char c)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 170:	00054783          	lbu	a5,0(a0)
 174:	cb99                	beqz	a5,18a <strchr+0x20>
    if(*s == c)
 176:	00f58763          	beq	a1,a5,184 <strchr+0x1a>
  for(; *s; s++)
 17a:	0505                	addi	a0,a0,1
 17c:	00054783          	lbu	a5,0(a0)
 180:	fbfd                	bnez	a5,176 <strchr+0xc>
      return (char*)s;
  return 0;
 182:	4501                	li	a0,0
}
 184:	6422                	ld	s0,8(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret
  return 0;
 18a:	4501                	li	a0,0
 18c:	bfe5                	j	184 <strchr+0x1a>

000000000000018e <gets>:

char*
gets(char *buf, int max)
{
 18e:	711d                	addi	sp,sp,-96
 190:	ec86                	sd	ra,88(sp)
 192:	e8a2                	sd	s0,80(sp)
 194:	e4a6                	sd	s1,72(sp)
 196:	e0ca                	sd	s2,64(sp)
 198:	fc4e                	sd	s3,56(sp)
 19a:	f852                	sd	s4,48(sp)
 19c:	f456                	sd	s5,40(sp)
 19e:	f05a                	sd	s6,32(sp)
 1a0:	ec5e                	sd	s7,24(sp)
 1a2:	1080                	addi	s0,sp,96
 1a4:	8baa                	mv	s7,a0
 1a6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a8:	892a                	mv	s2,a0
 1aa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ac:	4aa9                	li	s5,10
 1ae:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b0:	89a6                	mv	s3,s1
 1b2:	2485                	addiw	s1,s1,1
 1b4:	0344d663          	bge	s1,s4,1e0 <gets+0x52>
    cc = read(0, &c, 1);
 1b8:	4605                	li	a2,1
 1ba:	faf40593          	addi	a1,s0,-81
 1be:	4501                	li	a0,0
 1c0:	1ba000ef          	jal	37a <read>
    if(cc < 1)
 1c4:	00a05e63          	blez	a0,1e0 <gets+0x52>
    buf[i++] = c;
 1c8:	faf44783          	lbu	a5,-81(s0)
 1cc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d0:	01578763          	beq	a5,s5,1de <gets+0x50>
 1d4:	0905                	addi	s2,s2,1
 1d6:	fd679de3          	bne	a5,s6,1b0 <gets+0x22>
    buf[i++] = c;
 1da:	89a6                	mv	s3,s1
 1dc:	a011                	j	1e0 <gets+0x52>
 1de:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e0:	99de                	add	s3,s3,s7
 1e2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e6:	855e                	mv	a0,s7
 1e8:	60e6                	ld	ra,88(sp)
 1ea:	6446                	ld	s0,80(sp)
 1ec:	64a6                	ld	s1,72(sp)
 1ee:	6906                	ld	s2,64(sp)
 1f0:	79e2                	ld	s3,56(sp)
 1f2:	7a42                	ld	s4,48(sp)
 1f4:	7aa2                	ld	s5,40(sp)
 1f6:	7b02                	ld	s6,32(sp)
 1f8:	6be2                	ld	s7,24(sp)
 1fa:	6125                	addi	sp,sp,96
 1fc:	8082                	ret

00000000000001fe <stat>:

int
stat(const char *n, struct stat *st)
{
 1fe:	1101                	addi	sp,sp,-32
 200:	ec06                	sd	ra,24(sp)
 202:	e822                	sd	s0,16(sp)
 204:	e04a                	sd	s2,0(sp)
 206:	1000                	addi	s0,sp,32
 208:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20a:	4581                	li	a1,0
 20c:	196000ef          	jal	3a2 <open>
  if(fd < 0)
 210:	02054263          	bltz	a0,234 <stat+0x36>
 214:	e426                	sd	s1,8(sp)
 216:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 218:	85ca                	mv	a1,s2
 21a:	1a0000ef          	jal	3ba <fstat>
 21e:	892a                	mv	s2,a0
  close(fd);
 220:	8526                	mv	a0,s1
 222:	168000ef          	jal	38a <close>
  return r;
 226:	64a2                	ld	s1,8(sp)
}
 228:	854a                	mv	a0,s2
 22a:	60e2                	ld	ra,24(sp)
 22c:	6442                	ld	s0,16(sp)
 22e:	6902                	ld	s2,0(sp)
 230:	6105                	addi	sp,sp,32
 232:	8082                	ret
    return -1;
 234:	597d                	li	s2,-1
 236:	bfcd                	j	228 <stat+0x2a>

0000000000000238 <atoi>:

int
atoi(const char *s)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23e:	00054683          	lbu	a3,0(a0)
 242:	fd06879b          	addiw	a5,a3,-48
 246:	0ff7f793          	zext.b	a5,a5
 24a:	4625                	li	a2,9
 24c:	02f66863          	bltu	a2,a5,27c <atoi+0x44>
 250:	872a                	mv	a4,a0
  n = 0;
 252:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 254:	0705                	addi	a4,a4,1
 256:	0025179b          	slliw	a5,a0,0x2
 25a:	9fa9                	addw	a5,a5,a0
 25c:	0017979b          	slliw	a5,a5,0x1
 260:	9fb5                	addw	a5,a5,a3
 262:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 266:	00074683          	lbu	a3,0(a4)
 26a:	fd06879b          	addiw	a5,a3,-48
 26e:	0ff7f793          	zext.b	a5,a5
 272:	fef671e3          	bgeu	a2,a5,254 <atoi+0x1c>
  return n;
}
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret
  n = 0;
 27c:	4501                	li	a0,0
 27e:	bfe5                	j	276 <atoi+0x3e>

0000000000000280 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 280:	1141                	addi	sp,sp,-16
 282:	e422                	sd	s0,8(sp)
 284:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 286:	02b57463          	bgeu	a0,a1,2ae <memmove+0x2e>
    while(n-- > 0)
 28a:	00c05f63          	blez	a2,2a8 <memmove+0x28>
 28e:	1602                	slli	a2,a2,0x20
 290:	9201                	srli	a2,a2,0x20
 292:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 296:	872a                	mv	a4,a0
      *dst++ = *src++;
 298:	0585                	addi	a1,a1,1
 29a:	0705                	addi	a4,a4,1
 29c:	fff5c683          	lbu	a3,-1(a1)
 2a0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a4:	fef71ae3          	bne	a4,a5,298 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
    dst += n;
 2ae:	00c50733          	add	a4,a0,a2
    src += n;
 2b2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b4:	fec05ae3          	blez	a2,2a8 <memmove+0x28>
 2b8:	fff6079b          	addiw	a5,a2,-1
 2bc:	1782                	slli	a5,a5,0x20
 2be:	9381                	srli	a5,a5,0x20
 2c0:	fff7c793          	not	a5,a5
 2c4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c6:	15fd                	addi	a1,a1,-1
 2c8:	177d                	addi	a4,a4,-1
 2ca:	0005c683          	lbu	a3,0(a1)
 2ce:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d2:	fee79ae3          	bne	a5,a4,2c6 <memmove+0x46>
 2d6:	bfc9                	j	2a8 <memmove+0x28>

00000000000002d8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e422                	sd	s0,8(sp)
 2dc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2de:	ca05                	beqz	a2,30e <memcmp+0x36>
 2e0:	fff6069b          	addiw	a3,a2,-1
 2e4:	1682                	slli	a3,a3,0x20
 2e6:	9281                	srli	a3,a3,0x20
 2e8:	0685                	addi	a3,a3,1
 2ea:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ec:	00054783          	lbu	a5,0(a0)
 2f0:	0005c703          	lbu	a4,0(a1)
 2f4:	00e79863          	bne	a5,a4,304 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f8:	0505                	addi	a0,a0,1
    p2++;
 2fa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fc:	fed518e3          	bne	a0,a3,2ec <memcmp+0x14>
  }
  return 0;
 300:	4501                	li	a0,0
 302:	a019                	j	308 <memcmp+0x30>
      return *p1 - *p2;
 304:	40e7853b          	subw	a0,a5,a4
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret
  return 0;
 30e:	4501                	li	a0,0
 310:	bfe5                	j	308 <memcmp+0x30>

0000000000000312 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 312:	1141                	addi	sp,sp,-16
 314:	e406                	sd	ra,8(sp)
 316:	e022                	sd	s0,0(sp)
 318:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31a:	f67ff0ef          	jal	280 <memmove>
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <sbrk>:

char *
sbrk(int n) {
 326:	1141                	addi	sp,sp,-16
 328:	e406                	sd	ra,8(sp)
 32a:	e022                	sd	s0,0(sp)
 32c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 32e:	4585                	li	a1,1
 330:	0ba000ef          	jal	3ea <sys_sbrk>
}
 334:	60a2                	ld	ra,8(sp)
 336:	6402                	ld	s0,0(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret

000000000000033c <sbrklazy>:

char *
sbrklazy(int n) {
 33c:	1141                	addi	sp,sp,-16
 33e:	e406                	sd	ra,8(sp)
 340:	e022                	sd	s0,0(sp)
 342:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 344:	4589                	li	a1,2
 346:	0a4000ef          	jal	3ea <sys_sbrk>
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 352:	4885                	li	a7,1
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <exit>:
.global exit
exit:
 li a7, SYS_exit
 35a:	4889                	li	a7,2
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <wait>:
.global wait
wait:
 li a7, SYS_wait
 362:	488d                	li	a7,3
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 36a:	48d9                	li	a7,22
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 372:	4891                	li	a7,4
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <read>:
.global read
read:
 li a7, SYS_read
 37a:	4895                	li	a7,5
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <write>:
.global write
write:
 li a7, SYS_write
 382:	48c1                	li	a7,16
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <close>:
.global close
close:
 li a7, SYS_close
 38a:	48d5                	li	a7,21
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <kill>:
.global kill
kill:
 li a7, SYS_kill
 392:	4899                	li	a7,6
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <exec>:
.global exec
exec:
 li a7, SYS_exec
 39a:	489d                	li	a7,7
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <open>:
.global open
open:
 li a7, SYS_open
 3a2:	48bd                	li	a7,15
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3aa:	48c5                	li	a7,17
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b2:	48c9                	li	a7,18
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ba:	48a1                	li	a7,8
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <link>:
.global link
link:
 li a7, SYS_link
 3c2:	48cd                	li	a7,19
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ca:	48d1                	li	a7,20
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d2:	48a5                	li	a7,9
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <dup>:
.global dup
dup:
 li a7, SYS_dup
 3da:	48a9                	li	a7,10
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e2:	48ad                	li	a7,11
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3ea:	48b1                	li	a7,12
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3f2:	48b5                	li	a7,13
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3fa:	48b9                	li	a7,14
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 402:	48dd                	li	a7,23
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 40a:	48e1                	li	a7,24
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <mutex_init>:
.global mutex_init
mutex_init:
 li a7, SYS_mutex_init
 412:	48e5                	li	a7,25
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <mutex_acquire>:
.global mutex_acquire
mutex_acquire:
 li a7, SYS_mutex_acquire
 41a:	48e9                	li	a7,26
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <mutex_release>:
.global mutex_release
mutex_release:
 li a7, SYS_mutex_release
 422:	48ed                	li	a7,27
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 42a:	48f1                	li	a7,28
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 432:	48f5                	li	a7,29
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 43a:	48f9                	li	a7,30
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <setp>:
.global setp
setp:
 li a7, SYS_setp
 442:	48fd                	li	a7,31
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <ismyear>:
.global ismyear
ismyear:
 li a7, SYS_ismyear
 44a:	02000893          	li	a7,32
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 454:	02100893          	li	a7,33
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 45e:	02200893          	li	a7,34
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <thread_exit>:
.global thread_exit
thread_exit:
 li a7, SYS_thread_exit
 468:	02300893          	li	a7,35
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <thread_id>:
.global thread_id
thread_id:
 li a7, SYS_thread_id
 472:	02400893          	li	a7,36
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 47c:	1101                	addi	sp,sp,-32
 47e:	ec06                	sd	ra,24(sp)
 480:	e822                	sd	s0,16(sp)
 482:	1000                	addi	s0,sp,32
 484:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 488:	4605                	li	a2,1
 48a:	fef40593          	addi	a1,s0,-17
 48e:	ef5ff0ef          	jal	382 <write>
}
 492:	60e2                	ld	ra,24(sp)
 494:	6442                	ld	s0,16(sp)
 496:	6105                	addi	sp,sp,32
 498:	8082                	ret

000000000000049a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 49a:	715d                	addi	sp,sp,-80
 49c:	e486                	sd	ra,72(sp)
 49e:	e0a2                	sd	s0,64(sp)
 4a0:	f84a                	sd	s2,48(sp)
 4a2:	0880                	addi	s0,sp,80
 4a4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4a6:	c299                	beqz	a3,4ac <printint+0x12>
 4a8:	0805c363          	bltz	a1,52e <printint+0x94>
  neg = 0;
 4ac:	4881                	li	a7,0
 4ae:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4b2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4b4:	00000517          	auipc	a0,0x0
 4b8:	59c50513          	addi	a0,a0,1436 # a50 <digits>
 4bc:	883e                	mv	a6,a5
 4be:	2785                	addiw	a5,a5,1
 4c0:	02c5f733          	remu	a4,a1,a2
 4c4:	972a                	add	a4,a4,a0
 4c6:	00074703          	lbu	a4,0(a4)
 4ca:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4ce:	872e                	mv	a4,a1
 4d0:	02c5d5b3          	divu	a1,a1,a2
 4d4:	0685                	addi	a3,a3,1
 4d6:	fec773e3          	bgeu	a4,a2,4bc <printint+0x22>
  if(neg)
 4da:	00088b63          	beqz	a7,4f0 <printint+0x56>
    buf[i++] = '-';
 4de:	fd078793          	addi	a5,a5,-48
 4e2:	97a2                	add	a5,a5,s0
 4e4:	02d00713          	li	a4,45
 4e8:	fee78423          	sb	a4,-24(a5)
 4ec:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4f0:	02f05a63          	blez	a5,524 <printint+0x8a>
 4f4:	fc26                	sd	s1,56(sp)
 4f6:	f44e                	sd	s3,40(sp)
 4f8:	fb840713          	addi	a4,s0,-72
 4fc:	00f704b3          	add	s1,a4,a5
 500:	fff70993          	addi	s3,a4,-1
 504:	99be                	add	s3,s3,a5
 506:	37fd                	addiw	a5,a5,-1
 508:	1782                	slli	a5,a5,0x20
 50a:	9381                	srli	a5,a5,0x20
 50c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 510:	fff4c583          	lbu	a1,-1(s1)
 514:	854a                	mv	a0,s2
 516:	f67ff0ef          	jal	47c <putc>
  while(--i >= 0)
 51a:	14fd                	addi	s1,s1,-1
 51c:	ff349ae3          	bne	s1,s3,510 <printint+0x76>
 520:	74e2                	ld	s1,56(sp)
 522:	79a2                	ld	s3,40(sp)
}
 524:	60a6                	ld	ra,72(sp)
 526:	6406                	ld	s0,64(sp)
 528:	7942                	ld	s2,48(sp)
 52a:	6161                	addi	sp,sp,80
 52c:	8082                	ret
    x = -xx;
 52e:	40b005b3          	neg	a1,a1
    neg = 1;
 532:	4885                	li	a7,1
    x = -xx;
 534:	bfad                	j	4ae <printint+0x14>

0000000000000536 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 536:	711d                	addi	sp,sp,-96
 538:	ec86                	sd	ra,88(sp)
 53a:	e8a2                	sd	s0,80(sp)
 53c:	e0ca                	sd	s2,64(sp)
 53e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 540:	0005c903          	lbu	s2,0(a1)
 544:	28090663          	beqz	s2,7d0 <vprintf+0x29a>
 548:	e4a6                	sd	s1,72(sp)
 54a:	fc4e                	sd	s3,56(sp)
 54c:	f852                	sd	s4,48(sp)
 54e:	f456                	sd	s5,40(sp)
 550:	f05a                	sd	s6,32(sp)
 552:	ec5e                	sd	s7,24(sp)
 554:	e862                	sd	s8,16(sp)
 556:	e466                	sd	s9,8(sp)
 558:	8b2a                	mv	s6,a0
 55a:	8a2e                	mv	s4,a1
 55c:	8bb2                	mv	s7,a2
  state = 0;
 55e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 560:	4481                	li	s1,0
 562:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 564:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 568:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 56c:	06c00c93          	li	s9,108
 570:	a005                	j	590 <vprintf+0x5a>
        putc(fd, c0);
 572:	85ca                	mv	a1,s2
 574:	855a                	mv	a0,s6
 576:	f07ff0ef          	jal	47c <putc>
 57a:	a019                	j	580 <vprintf+0x4a>
    } else if(state == '%'){
 57c:	03598263          	beq	s3,s5,5a0 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 580:	2485                	addiw	s1,s1,1
 582:	8726                	mv	a4,s1
 584:	009a07b3          	add	a5,s4,s1
 588:	0007c903          	lbu	s2,0(a5)
 58c:	22090a63          	beqz	s2,7c0 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 590:	0009079b          	sext.w	a5,s2
    if(state == 0){
 594:	fe0994e3          	bnez	s3,57c <vprintf+0x46>
      if(c0 == '%'){
 598:	fd579de3          	bne	a5,s5,572 <vprintf+0x3c>
        state = '%';
 59c:	89be                	mv	s3,a5
 59e:	b7cd                	j	580 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5a0:	00ea06b3          	add	a3,s4,a4
 5a4:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5a8:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5aa:	c681                	beqz	a3,5b2 <vprintf+0x7c>
 5ac:	9752                	add	a4,a4,s4
 5ae:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5b2:	05878363          	beq	a5,s8,5f8 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5b6:	05978d63          	beq	a5,s9,610 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5ba:	07500713          	li	a4,117
 5be:	0ee78763          	beq	a5,a4,6ac <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5c2:	07800713          	li	a4,120
 5c6:	12e78963          	beq	a5,a4,6f8 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ca:	07000713          	li	a4,112
 5ce:	14e78e63          	beq	a5,a4,72a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5d2:	06300713          	li	a4,99
 5d6:	18e78e63          	beq	a5,a4,772 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5da:	07300713          	li	a4,115
 5de:	1ae78463          	beq	a5,a4,786 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5e2:	02500713          	li	a4,37
 5e6:	04e79563          	bne	a5,a4,630 <vprintf+0xfa>
        putc(fd, '%');
 5ea:	02500593          	li	a1,37
 5ee:	855a                	mv	a0,s6
 5f0:	e8dff0ef          	jal	47c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b769                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5f8:	008b8913          	addi	s2,s7,8
 5fc:	4685                	li	a3,1
 5fe:	4629                	li	a2,10
 600:	000ba583          	lw	a1,0(s7)
 604:	855a                	mv	a0,s6
 606:	e95ff0ef          	jal	49a <printint>
 60a:	8bca                	mv	s7,s2
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bf8d                	j	580 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 610:	06400793          	li	a5,100
 614:	02f68963          	beq	a3,a5,646 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 618:	06c00793          	li	a5,108
 61c:	04f68263          	beq	a3,a5,660 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 620:	07500793          	li	a5,117
 624:	0af68063          	beq	a3,a5,6c4 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 628:	07800793          	li	a5,120
 62c:	0ef68263          	beq	a3,a5,710 <vprintf+0x1da>
        putc(fd, '%');
 630:	02500593          	li	a1,37
 634:	855a                	mv	a0,s6
 636:	e47ff0ef          	jal	47c <putc>
        putc(fd, c0);
 63a:	85ca                	mv	a1,s2
 63c:	855a                	mv	a0,s6
 63e:	e3fff0ef          	jal	47c <putc>
      state = 0;
 642:	4981                	li	s3,0
 644:	bf35                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 646:	008b8913          	addi	s2,s7,8
 64a:	4685                	li	a3,1
 64c:	4629                	li	a2,10
 64e:	000bb583          	ld	a1,0(s7)
 652:	855a                	mv	a0,s6
 654:	e47ff0ef          	jal	49a <printint>
        i += 1;
 658:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
        i += 1;
 65e:	b70d                	j	580 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 660:	06400793          	li	a5,100
 664:	02f60763          	beq	a2,a5,692 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 668:	07500793          	li	a5,117
 66c:	06f60963          	beq	a2,a5,6de <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 670:	07800793          	li	a5,120
 674:	faf61ee3          	bne	a2,a5,630 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 678:	008b8913          	addi	s2,s7,8
 67c:	4681                	li	a3,0
 67e:	4641                	li	a2,16
 680:	000bb583          	ld	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	e15ff0ef          	jal	49a <printint>
        i += 2;
 68a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
        i += 2;
 690:	bdc5                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 692:	008b8913          	addi	s2,s7,8
 696:	4685                	li	a3,1
 698:	4629                	li	a2,10
 69a:	000bb583          	ld	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	dfbff0ef          	jal	49a <printint>
        i += 2;
 6a4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
        i += 2;
 6aa:	bdd9                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	4681                	li	a3,0
 6b2:	4629                	li	a2,10
 6b4:	000be583          	lwu	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	de1ff0ef          	jal	49a <printint>
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	bd7d                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c4:	008b8913          	addi	s2,s7,8
 6c8:	4681                	li	a3,0
 6ca:	4629                	li	a2,10
 6cc:	000bb583          	ld	a1,0(s7)
 6d0:	855a                	mv	a0,s6
 6d2:	dc9ff0ef          	jal	49a <printint>
        i += 1;
 6d6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d8:	8bca                	mv	s7,s2
      state = 0;
 6da:	4981                	li	s3,0
        i += 1;
 6dc:	b555                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6de:	008b8913          	addi	s2,s7,8
 6e2:	4681                	li	a3,0
 6e4:	4629                	li	a2,10
 6e6:	000bb583          	ld	a1,0(s7)
 6ea:	855a                	mv	a0,s6
 6ec:	dafff0ef          	jal	49a <printint>
        i += 2;
 6f0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f2:	8bca                	mv	s7,s2
      state = 0;
 6f4:	4981                	li	s3,0
        i += 2;
 6f6:	b569                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6f8:	008b8913          	addi	s2,s7,8
 6fc:	4681                	li	a3,0
 6fe:	4641                	li	a2,16
 700:	000be583          	lwu	a1,0(s7)
 704:	855a                	mv	a0,s6
 706:	d95ff0ef          	jal	49a <printint>
 70a:	8bca                	mv	s7,s2
      state = 0;
 70c:	4981                	li	s3,0
 70e:	bd8d                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 710:	008b8913          	addi	s2,s7,8
 714:	4681                	li	a3,0
 716:	4641                	li	a2,16
 718:	000bb583          	ld	a1,0(s7)
 71c:	855a                	mv	a0,s6
 71e:	d7dff0ef          	jal	49a <printint>
        i += 1;
 722:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 724:	8bca                	mv	s7,s2
      state = 0;
 726:	4981                	li	s3,0
        i += 1;
 728:	bda1                	j	580 <vprintf+0x4a>
 72a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 72c:	008b8d13          	addi	s10,s7,8
 730:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 734:	03000593          	li	a1,48
 738:	855a                	mv	a0,s6
 73a:	d43ff0ef          	jal	47c <putc>
  putc(fd, 'x');
 73e:	07800593          	li	a1,120
 742:	855a                	mv	a0,s6
 744:	d39ff0ef          	jal	47c <putc>
 748:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 74a:	00000b97          	auipc	s7,0x0
 74e:	306b8b93          	addi	s7,s7,774 # a50 <digits>
 752:	03c9d793          	srli	a5,s3,0x3c
 756:	97de                	add	a5,a5,s7
 758:	0007c583          	lbu	a1,0(a5)
 75c:	855a                	mv	a0,s6
 75e:	d1fff0ef          	jal	47c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 762:	0992                	slli	s3,s3,0x4
 764:	397d                	addiw	s2,s2,-1
 766:	fe0916e3          	bnez	s2,752 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 76a:	8bea                	mv	s7,s10
      state = 0;
 76c:	4981                	li	s3,0
 76e:	6d02                	ld	s10,0(sp)
 770:	bd01                	j	580 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 772:	008b8913          	addi	s2,s7,8
 776:	000bc583          	lbu	a1,0(s7)
 77a:	855a                	mv	a0,s6
 77c:	d01ff0ef          	jal	47c <putc>
 780:	8bca                	mv	s7,s2
      state = 0;
 782:	4981                	li	s3,0
 784:	bbf5                	j	580 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 786:	008b8993          	addi	s3,s7,8
 78a:	000bb903          	ld	s2,0(s7)
 78e:	00090f63          	beqz	s2,7ac <vprintf+0x276>
        for(; *s; s++)
 792:	00094583          	lbu	a1,0(s2)
 796:	c195                	beqz	a1,7ba <vprintf+0x284>
          putc(fd, *s);
 798:	855a                	mv	a0,s6
 79a:	ce3ff0ef          	jal	47c <putc>
        for(; *s; s++)
 79e:	0905                	addi	s2,s2,1
 7a0:	00094583          	lbu	a1,0(s2)
 7a4:	f9f5                	bnez	a1,798 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7a6:	8bce                	mv	s7,s3
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bbd9                	j	580 <vprintf+0x4a>
          s = "(null)";
 7ac:	00000917          	auipc	s2,0x0
 7b0:	29c90913          	addi	s2,s2,668 # a48 <malloc+0x190>
        for(; *s; s++)
 7b4:	02800593          	li	a1,40
 7b8:	b7c5                	j	798 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7ba:	8bce                	mv	s7,s3
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	b3c9                	j	580 <vprintf+0x4a>
 7c0:	64a6                	ld	s1,72(sp)
 7c2:	79e2                	ld	s3,56(sp)
 7c4:	7a42                	ld	s4,48(sp)
 7c6:	7aa2                	ld	s5,40(sp)
 7c8:	7b02                	ld	s6,32(sp)
 7ca:	6be2                	ld	s7,24(sp)
 7cc:	6c42                	ld	s8,16(sp)
 7ce:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7d0:	60e6                	ld	ra,88(sp)
 7d2:	6446                	ld	s0,80(sp)
 7d4:	6906                	ld	s2,64(sp)
 7d6:	6125                	addi	sp,sp,96
 7d8:	8082                	ret

00000000000007da <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7da:	715d                	addi	sp,sp,-80
 7dc:	ec06                	sd	ra,24(sp)
 7de:	e822                	sd	s0,16(sp)
 7e0:	1000                	addi	s0,sp,32
 7e2:	e010                	sd	a2,0(s0)
 7e4:	e414                	sd	a3,8(s0)
 7e6:	e818                	sd	a4,16(s0)
 7e8:	ec1c                	sd	a5,24(s0)
 7ea:	03043023          	sd	a6,32(s0)
 7ee:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7f2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f6:	8622                	mv	a2,s0
 7f8:	d3fff0ef          	jal	536 <vprintf>
}
 7fc:	60e2                	ld	ra,24(sp)
 7fe:	6442                	ld	s0,16(sp)
 800:	6161                	addi	sp,sp,80
 802:	8082                	ret

0000000000000804 <printf>:

void
printf(const char *fmt, ...)
{
 804:	711d                	addi	sp,sp,-96
 806:	ec06                	sd	ra,24(sp)
 808:	e822                	sd	s0,16(sp)
 80a:	1000                	addi	s0,sp,32
 80c:	e40c                	sd	a1,8(s0)
 80e:	e810                	sd	a2,16(s0)
 810:	ec14                	sd	a3,24(s0)
 812:	f018                	sd	a4,32(s0)
 814:	f41c                	sd	a5,40(s0)
 816:	03043823          	sd	a6,48(s0)
 81a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 81e:	00840613          	addi	a2,s0,8
 822:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 826:	85aa                	mv	a1,a0
 828:	4505                	li	a0,1
 82a:	d0dff0ef          	jal	536 <vprintf>
}
 82e:	60e2                	ld	ra,24(sp)
 830:	6442                	ld	s0,16(sp)
 832:	6125                	addi	sp,sp,96
 834:	8082                	ret

0000000000000836 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 836:	1141                	addi	sp,sp,-16
 838:	e422                	sd	s0,8(sp)
 83a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 840:	00000797          	auipc	a5,0x0
 844:	7c07b783          	ld	a5,1984(a5) # 1000 <freep>
 848:	a02d                	j	872 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 84a:	4618                	lw	a4,8(a2)
 84c:	9f2d                	addw	a4,a4,a1
 84e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 852:	6398                	ld	a4,0(a5)
 854:	6310                	ld	a2,0(a4)
 856:	a83d                	j	894 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 858:	ff852703          	lw	a4,-8(a0)
 85c:	9f31                	addw	a4,a4,a2
 85e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 860:	ff053683          	ld	a3,-16(a0)
 864:	a091                	j	8a8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 866:	6398                	ld	a4,0(a5)
 868:	00e7e463          	bltu	a5,a4,870 <free+0x3a>
 86c:	00e6ea63          	bltu	a3,a4,880 <free+0x4a>
{
 870:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 872:	fed7fae3          	bgeu	a5,a3,866 <free+0x30>
 876:	6398                	ld	a4,0(a5)
 878:	00e6e463          	bltu	a3,a4,880 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87c:	fee7eae3          	bltu	a5,a4,870 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 880:	ff852583          	lw	a1,-8(a0)
 884:	6390                	ld	a2,0(a5)
 886:	02059813          	slli	a6,a1,0x20
 88a:	01c85713          	srli	a4,a6,0x1c
 88e:	9736                	add	a4,a4,a3
 890:	fae60de3          	beq	a2,a4,84a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 894:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 898:	4790                	lw	a2,8(a5)
 89a:	02061593          	slli	a1,a2,0x20
 89e:	01c5d713          	srli	a4,a1,0x1c
 8a2:	973e                	add	a4,a4,a5
 8a4:	fae68ae3          	beq	a3,a4,858 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8a8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8aa:	00000717          	auipc	a4,0x0
 8ae:	74f73b23          	sd	a5,1878(a4) # 1000 <freep>
}
 8b2:	6422                	ld	s0,8(sp)
 8b4:	0141                	addi	sp,sp,16
 8b6:	8082                	ret

00000000000008b8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b8:	7139                	addi	sp,sp,-64
 8ba:	fc06                	sd	ra,56(sp)
 8bc:	f822                	sd	s0,48(sp)
 8be:	f426                	sd	s1,40(sp)
 8c0:	ec4e                	sd	s3,24(sp)
 8c2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c4:	02051493          	slli	s1,a0,0x20
 8c8:	9081                	srli	s1,s1,0x20
 8ca:	04bd                	addi	s1,s1,15
 8cc:	8091                	srli	s1,s1,0x4
 8ce:	0014899b          	addiw	s3,s1,1
 8d2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d4:	00000517          	auipc	a0,0x0
 8d8:	72c53503          	ld	a0,1836(a0) # 1000 <freep>
 8dc:	c915                	beqz	a0,910 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e0:	4798                	lw	a4,8(a5)
 8e2:	08977a63          	bgeu	a4,s1,976 <malloc+0xbe>
 8e6:	f04a                	sd	s2,32(sp)
 8e8:	e852                	sd	s4,16(sp)
 8ea:	e456                	sd	s5,8(sp)
 8ec:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8ee:	8a4e                	mv	s4,s3
 8f0:	0009871b          	sext.w	a4,s3
 8f4:	6685                	lui	a3,0x1
 8f6:	00d77363          	bgeu	a4,a3,8fc <malloc+0x44>
 8fa:	6a05                	lui	s4,0x1
 8fc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 900:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 904:	00000917          	auipc	s2,0x0
 908:	6fc90913          	addi	s2,s2,1788 # 1000 <freep>
  if(p == SBRK_ERROR)
 90c:	5afd                	li	s5,-1
 90e:	a081                	j	94e <malloc+0x96>
 910:	f04a                	sd	s2,32(sp)
 912:	e852                	sd	s4,16(sp)
 914:	e456                	sd	s5,8(sp)
 916:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 918:	00000797          	auipc	a5,0x0
 91c:	6f878793          	addi	a5,a5,1784 # 1010 <base>
 920:	00000717          	auipc	a4,0x0
 924:	6ef73023          	sd	a5,1760(a4) # 1000 <freep>
 928:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 92a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92e:	b7c1                	j	8ee <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 930:	6398                	ld	a4,0(a5)
 932:	e118                	sd	a4,0(a0)
 934:	a8a9                	j	98e <malloc+0xd6>
  hp->s.size = nu;
 936:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 93a:	0541                	addi	a0,a0,16
 93c:	efbff0ef          	jal	836 <free>
  return freep;
 940:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 944:	c12d                	beqz	a0,9a6 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 946:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 948:	4798                	lw	a4,8(a5)
 94a:	02977263          	bgeu	a4,s1,96e <malloc+0xb6>
    if(p == freep)
 94e:	00093703          	ld	a4,0(s2)
 952:	853e                	mv	a0,a5
 954:	fef719e3          	bne	a4,a5,946 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 958:	8552                	mv	a0,s4
 95a:	9cdff0ef          	jal	326 <sbrk>
  if(p == SBRK_ERROR)
 95e:	fd551ce3          	bne	a0,s5,936 <malloc+0x7e>
        return 0;
 962:	4501                	li	a0,0
 964:	7902                	ld	s2,32(sp)
 966:	6a42                	ld	s4,16(sp)
 968:	6aa2                	ld	s5,8(sp)
 96a:	6b02                	ld	s6,0(sp)
 96c:	a03d                	j	99a <malloc+0xe2>
 96e:	7902                	ld	s2,32(sp)
 970:	6a42                	ld	s4,16(sp)
 972:	6aa2                	ld	s5,8(sp)
 974:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 976:	fae48de3          	beq	s1,a4,930 <malloc+0x78>
        p->s.size -= nunits;
 97a:	4137073b          	subw	a4,a4,s3
 97e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 980:	02071693          	slli	a3,a4,0x20
 984:	01c6d713          	srli	a4,a3,0x1c
 988:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 98a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98e:	00000717          	auipc	a4,0x0
 992:	66a73923          	sd	a0,1650(a4) # 1000 <freep>
      return (void*)(p + 1);
 996:	01078513          	addi	a0,a5,16
  }
}
 99a:	70e2                	ld	ra,56(sp)
 99c:	7442                	ld	s0,48(sp)
 99e:	74a2                	ld	s1,40(sp)
 9a0:	69e2                	ld	s3,24(sp)
 9a2:	6121                	addi	sp,sp,64
 9a4:	8082                	ret
 9a6:	7902                	ld	s2,32(sp)
 9a8:	6a42                	ld	s4,16(sp)
 9aa:	6aa2                	ld	s5,8(sp)
 9ac:	6b02                	ld	s6,0(sp)
 9ae:	b7f5                	j	99a <malloc+0xe2>
