
user/_mkdir:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7d763          	bge	a5,a0,38 <main+0x38>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: mkdir files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(mkdir(argv[i]) < 0){
  26:	6088                	ld	a0,0(s1)
  28:	342000ef          	jal	36a <mkdir>
  2c:	02054263          	bltz	a0,50 <main+0x50>
  for(i = 1; i < argc; i++){
  30:	04a1                	addi	s1,s1,8
  32:	ff249ae3          	bne	s1,s2,26 <main+0x26>
  36:	a02d                	j	60 <main+0x60>
  38:	e426                	sd	s1,8(sp)
  3a:	e04a                	sd	s2,0(sp)
    fprintf(2, "Usage: mkdir files...\n");
  3c:	00001597          	auipc	a1,0x1
  40:	91458593          	addi	a1,a1,-1772 # 950 <malloc+0xf8>
  44:	4509                	li	a0,2
  46:	734000ef          	jal	77a <fprintf>
    exit(1);
  4a:	4505                	li	a0,1
  4c:	2ae000ef          	jal	2fa <exit>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
  50:	6090                	ld	a2,0(s1)
  52:	00001597          	auipc	a1,0x1
  56:	91658593          	addi	a1,a1,-1770 # 968 <malloc+0x110>
  5a:	4509                	li	a0,2
  5c:	71e000ef          	jal	77a <fprintf>
      break;
    }
  }

  exit(0);
  60:	4501                	li	a0,0
  62:	298000ef          	jal	2fa <exit>

0000000000000066 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  66:	1141                	addi	sp,sp,-16
  68:	e406                	sd	ra,8(sp)
  6a:	e022                	sd	s0,0(sp)
  6c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  6e:	f93ff0ef          	jal	0 <main>
  exit(r);
  72:	288000ef          	jal	2fa <exit>

0000000000000076 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  76:	1141                	addi	sp,sp,-16
  78:	e422                	sd	s0,8(sp)
  7a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7c:	87aa                	mv	a5,a0
  7e:	0585                	addi	a1,a1,1
  80:	0785                	addi	a5,a5,1
  82:	fff5c703          	lbu	a4,-1(a1)
  86:	fee78fa3          	sb	a4,-1(a5)
  8a:	fb75                	bnez	a4,7e <strcpy+0x8>
    ;
  return os;
}
  8c:	6422                	ld	s0,8(sp)
  8e:	0141                	addi	sp,sp,16
  90:	8082                	ret

0000000000000092 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  92:	1141                	addi	sp,sp,-16
  94:	e422                	sd	s0,8(sp)
  96:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  98:	00054783          	lbu	a5,0(a0)
  9c:	cb91                	beqz	a5,b0 <strcmp+0x1e>
  9e:	0005c703          	lbu	a4,0(a1)
  a2:	00f71763          	bne	a4,a5,b0 <strcmp+0x1e>
    p++, q++;
  a6:	0505                	addi	a0,a0,1
  a8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	fbe5                	bnez	a5,9e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b0:	0005c503          	lbu	a0,0(a1)
}
  b4:	40a7853b          	subw	a0,a5,a0
  b8:	6422                	ld	s0,8(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret

00000000000000be <strlen>:

uint
strlen(const char *s)
{
  be:	1141                	addi	sp,sp,-16
  c0:	e422                	sd	s0,8(sp)
  c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c4:	00054783          	lbu	a5,0(a0)
  c8:	cf91                	beqz	a5,e4 <strlen+0x26>
  ca:	0505                	addi	a0,a0,1
  cc:	87aa                	mv	a5,a0
  ce:	86be                	mv	a3,a5
  d0:	0785                	addi	a5,a5,1
  d2:	fff7c703          	lbu	a4,-1(a5)
  d6:	ff65                	bnez	a4,ce <strlen+0x10>
  d8:	40a6853b          	subw	a0,a3,a0
  dc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  de:	6422                	ld	s0,8(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret
  for(n = 0; s[n]; n++)
  e4:	4501                	li	a0,0
  e6:	bfe5                	j	de <strlen+0x20>

00000000000000e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ee:	ca19                	beqz	a2,104 <memset+0x1c>
  f0:	87aa                	mv	a5,a0
  f2:	1602                	slli	a2,a2,0x20
  f4:	9201                	srli	a2,a2,0x20
  f6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  fa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  fe:	0785                	addi	a5,a5,1
 100:	fee79de3          	bne	a5,a4,fa <memset+0x12>
  }
  return dst;
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret

000000000000010a <strchr>:

char*
strchr(const char *s, char c)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 110:	00054783          	lbu	a5,0(a0)
 114:	cb99                	beqz	a5,12a <strchr+0x20>
    if(*s == c)
 116:	00f58763          	beq	a1,a5,124 <strchr+0x1a>
  for(; *s; s++)
 11a:	0505                	addi	a0,a0,1
 11c:	00054783          	lbu	a5,0(a0)
 120:	fbfd                	bnez	a5,116 <strchr+0xc>
      return (char*)s;
  return 0;
 122:	4501                	li	a0,0
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret
  return 0;
 12a:	4501                	li	a0,0
 12c:	bfe5                	j	124 <strchr+0x1a>

000000000000012e <gets>:

char*
gets(char *buf, int max)
{
 12e:	711d                	addi	sp,sp,-96
 130:	ec86                	sd	ra,88(sp)
 132:	e8a2                	sd	s0,80(sp)
 134:	e4a6                	sd	s1,72(sp)
 136:	e0ca                	sd	s2,64(sp)
 138:	fc4e                	sd	s3,56(sp)
 13a:	f852                	sd	s4,48(sp)
 13c:	f456                	sd	s5,40(sp)
 13e:	f05a                	sd	s6,32(sp)
 140:	ec5e                	sd	s7,24(sp)
 142:	1080                	addi	s0,sp,96
 144:	8baa                	mv	s7,a0
 146:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 148:	892a                	mv	s2,a0
 14a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 14c:	4aa9                	li	s5,10
 14e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 150:	89a6                	mv	s3,s1
 152:	2485                	addiw	s1,s1,1
 154:	0344d663          	bge	s1,s4,180 <gets+0x52>
    cc = read(0, &c, 1);
 158:	4605                	li	a2,1
 15a:	faf40593          	addi	a1,s0,-81
 15e:	4501                	li	a0,0
 160:	1ba000ef          	jal	31a <read>
    if(cc < 1)
 164:	00a05e63          	blez	a0,180 <gets+0x52>
    buf[i++] = c;
 168:	faf44783          	lbu	a5,-81(s0)
 16c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 170:	01578763          	beq	a5,s5,17e <gets+0x50>
 174:	0905                	addi	s2,s2,1
 176:	fd679de3          	bne	a5,s6,150 <gets+0x22>
    buf[i++] = c;
 17a:	89a6                	mv	s3,s1
 17c:	a011                	j	180 <gets+0x52>
 17e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 180:	99de                	add	s3,s3,s7
 182:	00098023          	sb	zero,0(s3)
  return buf;
}
 186:	855e                	mv	a0,s7
 188:	60e6                	ld	ra,88(sp)
 18a:	6446                	ld	s0,80(sp)
 18c:	64a6                	ld	s1,72(sp)
 18e:	6906                	ld	s2,64(sp)
 190:	79e2                	ld	s3,56(sp)
 192:	7a42                	ld	s4,48(sp)
 194:	7aa2                	ld	s5,40(sp)
 196:	7b02                	ld	s6,32(sp)
 198:	6be2                	ld	s7,24(sp)
 19a:	6125                	addi	sp,sp,96
 19c:	8082                	ret

000000000000019e <stat>:

int
stat(const char *n, struct stat *st)
{
 19e:	1101                	addi	sp,sp,-32
 1a0:	ec06                	sd	ra,24(sp)
 1a2:	e822                	sd	s0,16(sp)
 1a4:	e04a                	sd	s2,0(sp)
 1a6:	1000                	addi	s0,sp,32
 1a8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1aa:	4581                	li	a1,0
 1ac:	196000ef          	jal	342 <open>
  if(fd < 0)
 1b0:	02054263          	bltz	a0,1d4 <stat+0x36>
 1b4:	e426                	sd	s1,8(sp)
 1b6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1b8:	85ca                	mv	a1,s2
 1ba:	1a0000ef          	jal	35a <fstat>
 1be:	892a                	mv	s2,a0
  close(fd);
 1c0:	8526                	mv	a0,s1
 1c2:	168000ef          	jal	32a <close>
  return r;
 1c6:	64a2                	ld	s1,8(sp)
}
 1c8:	854a                	mv	a0,s2
 1ca:	60e2                	ld	ra,24(sp)
 1cc:	6442                	ld	s0,16(sp)
 1ce:	6902                	ld	s2,0(sp)
 1d0:	6105                	addi	sp,sp,32
 1d2:	8082                	ret
    return -1;
 1d4:	597d                	li	s2,-1
 1d6:	bfcd                	j	1c8 <stat+0x2a>

00000000000001d8 <atoi>:

int
atoi(const char *s)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1de:	00054683          	lbu	a3,0(a0)
 1e2:	fd06879b          	addiw	a5,a3,-48
 1e6:	0ff7f793          	zext.b	a5,a5
 1ea:	4625                	li	a2,9
 1ec:	02f66863          	bltu	a2,a5,21c <atoi+0x44>
 1f0:	872a                	mv	a4,a0
  n = 0;
 1f2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1f4:	0705                	addi	a4,a4,1
 1f6:	0025179b          	slliw	a5,a0,0x2
 1fa:	9fa9                	addw	a5,a5,a0
 1fc:	0017979b          	slliw	a5,a5,0x1
 200:	9fb5                	addw	a5,a5,a3
 202:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 206:	00074683          	lbu	a3,0(a4)
 20a:	fd06879b          	addiw	a5,a3,-48
 20e:	0ff7f793          	zext.b	a5,a5
 212:	fef671e3          	bgeu	a2,a5,1f4 <atoi+0x1c>
  return n;
}
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret
  n = 0;
 21c:	4501                	li	a0,0
 21e:	bfe5                	j	216 <atoi+0x3e>

0000000000000220 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 220:	1141                	addi	sp,sp,-16
 222:	e422                	sd	s0,8(sp)
 224:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 226:	02b57463          	bgeu	a0,a1,24e <memmove+0x2e>
    while(n-- > 0)
 22a:	00c05f63          	blez	a2,248 <memmove+0x28>
 22e:	1602                	slli	a2,a2,0x20
 230:	9201                	srli	a2,a2,0x20
 232:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 236:	872a                	mv	a4,a0
      *dst++ = *src++;
 238:	0585                	addi	a1,a1,1
 23a:	0705                	addi	a4,a4,1
 23c:	fff5c683          	lbu	a3,-1(a1)
 240:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 244:	fef71ae3          	bne	a4,a5,238 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
    dst += n;
 24e:	00c50733          	add	a4,a0,a2
    src += n;
 252:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 254:	fec05ae3          	blez	a2,248 <memmove+0x28>
 258:	fff6079b          	addiw	a5,a2,-1
 25c:	1782                	slli	a5,a5,0x20
 25e:	9381                	srli	a5,a5,0x20
 260:	fff7c793          	not	a5,a5
 264:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 266:	15fd                	addi	a1,a1,-1
 268:	177d                	addi	a4,a4,-1
 26a:	0005c683          	lbu	a3,0(a1)
 26e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 272:	fee79ae3          	bne	a5,a4,266 <memmove+0x46>
 276:	bfc9                	j	248 <memmove+0x28>

0000000000000278 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 27e:	ca05                	beqz	a2,2ae <memcmp+0x36>
 280:	fff6069b          	addiw	a3,a2,-1
 284:	1682                	slli	a3,a3,0x20
 286:	9281                	srli	a3,a3,0x20
 288:	0685                	addi	a3,a3,1
 28a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 28c:	00054783          	lbu	a5,0(a0)
 290:	0005c703          	lbu	a4,0(a1)
 294:	00e79863          	bne	a5,a4,2a4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 298:	0505                	addi	a0,a0,1
    p2++;
 29a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 29c:	fed518e3          	bne	a0,a3,28c <memcmp+0x14>
  }
  return 0;
 2a0:	4501                	li	a0,0
 2a2:	a019                	j	2a8 <memcmp+0x30>
      return *p1 - *p2;
 2a4:	40e7853b          	subw	a0,a5,a4
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
  return 0;
 2ae:	4501                	li	a0,0
 2b0:	bfe5                	j	2a8 <memcmp+0x30>

00000000000002b2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e406                	sd	ra,8(sp)
 2b6:	e022                	sd	s0,0(sp)
 2b8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ba:	f67ff0ef          	jal	220 <memmove>
}
 2be:	60a2                	ld	ra,8(sp)
 2c0:	6402                	ld	s0,0(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret

00000000000002c6 <sbrk>:

char *
sbrk(int n) {
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e406                	sd	ra,8(sp)
 2ca:	e022                	sd	s0,0(sp)
 2cc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2ce:	4585                	li	a1,1
 2d0:	0ba000ef          	jal	38a <sys_sbrk>
}
 2d4:	60a2                	ld	ra,8(sp)
 2d6:	6402                	ld	s0,0(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret

00000000000002dc <sbrklazy>:

char *
sbrklazy(int n) {
 2dc:	1141                	addi	sp,sp,-16
 2de:	e406                	sd	ra,8(sp)
 2e0:	e022                	sd	s0,0(sp)
 2e2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2e4:	4589                	li	a1,2
 2e6:	0a4000ef          	jal	38a <sys_sbrk>
}
 2ea:	60a2                	ld	ra,8(sp)
 2ec:	6402                	ld	s0,0(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret

00000000000002f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f2:	4885                	li	a7,1
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 2fa:	4889                	li	a7,2
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <wait>:
.global wait
wait:
 li a7, SYS_wait
 302:	488d                	li	a7,3
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 30a:	48d9                	li	a7,22
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 312:	4891                	li	a7,4
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <read>:
.global read
read:
 li a7, SYS_read
 31a:	4895                	li	a7,5
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <write>:
.global write
write:
 li a7, SYS_write
 322:	48c1                	li	a7,16
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <close>:
.global close
close:
 li a7, SYS_close
 32a:	48d5                	li	a7,21
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <kill>:
.global kill
kill:
 li a7, SYS_kill
 332:	4899                	li	a7,6
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <exec>:
.global exec
exec:
 li a7, SYS_exec
 33a:	489d                	li	a7,7
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <open>:
.global open
open:
 li a7, SYS_open
 342:	48bd                	li	a7,15
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 34a:	48c5                	li	a7,17
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 352:	48c9                	li	a7,18
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 35a:	48a1                	li	a7,8
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <link>:
.global link
link:
 li a7, SYS_link
 362:	48cd                	li	a7,19
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 36a:	48d1                	li	a7,20
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 372:	48a5                	li	a7,9
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <dup>:
.global dup
dup:
 li a7, SYS_dup
 37a:	48a9                	li	a7,10
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 382:	48ad                	li	a7,11
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 38a:	48b1                	li	a7,12
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <pause>:
.global pause
pause:
 li a7, SYS_pause
 392:	48b5                	li	a7,13
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 39a:	48b9                	li	a7,14
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3a2:	48dd                	li	a7,23
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 3aa:	48e1                	li	a7,24
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <mutex_init>:
.global mutex_init
mutex_init:
 li a7, SYS_mutex_init
 3b2:	48e5                	li	a7,25
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <mutex_acquire>:
.global mutex_acquire
mutex_acquire:
 li a7, SYS_mutex_acquire
 3ba:	48e9                	li	a7,26
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <mutex_release>:
.global mutex_release
mutex_release:
 li a7, SYS_mutex_release
 3c2:	48ed                	li	a7,27
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 3ca:	48f1                	li	a7,28
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 3d2:	48f5                	li	a7,29
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3da:	48f9                	li	a7,30
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <setp>:
.global setp
setp:
 li a7, SYS_setp
 3e2:	48fd                	li	a7,31
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <ismyear>:
.global ismyear
ismyear:
 li a7, SYS_ismyear
 3ea:	02000893          	li	a7,32
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 3f4:	02100893          	li	a7,33
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 3fe:	02200893          	li	a7,34
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <thread_exit>:
.global thread_exit
thread_exit:
 li a7, SYS_thread_exit
 408:	02300893          	li	a7,35
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <thread_id>:
.global thread_id
thread_id:
 li a7, SYS_thread_id
 412:	02400893          	li	a7,36
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 41c:	1101                	addi	sp,sp,-32
 41e:	ec06                	sd	ra,24(sp)
 420:	e822                	sd	s0,16(sp)
 422:	1000                	addi	s0,sp,32
 424:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 428:	4605                	li	a2,1
 42a:	fef40593          	addi	a1,s0,-17
 42e:	ef5ff0ef          	jal	322 <write>
}
 432:	60e2                	ld	ra,24(sp)
 434:	6442                	ld	s0,16(sp)
 436:	6105                	addi	sp,sp,32
 438:	8082                	ret

000000000000043a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 43a:	715d                	addi	sp,sp,-80
 43c:	e486                	sd	ra,72(sp)
 43e:	e0a2                	sd	s0,64(sp)
 440:	f84a                	sd	s2,48(sp)
 442:	0880                	addi	s0,sp,80
 444:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 446:	c299                	beqz	a3,44c <printint+0x12>
 448:	0805c363          	bltz	a1,4ce <printint+0x94>
  neg = 0;
 44c:	4881                	li	a7,0
 44e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 452:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 454:	00000517          	auipc	a0,0x0
 458:	53c50513          	addi	a0,a0,1340 # 990 <digits>
 45c:	883e                	mv	a6,a5
 45e:	2785                	addiw	a5,a5,1
 460:	02c5f733          	remu	a4,a1,a2
 464:	972a                	add	a4,a4,a0
 466:	00074703          	lbu	a4,0(a4)
 46a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 46e:	872e                	mv	a4,a1
 470:	02c5d5b3          	divu	a1,a1,a2
 474:	0685                	addi	a3,a3,1
 476:	fec773e3          	bgeu	a4,a2,45c <printint+0x22>
  if(neg)
 47a:	00088b63          	beqz	a7,490 <printint+0x56>
    buf[i++] = '-';
 47e:	fd078793          	addi	a5,a5,-48
 482:	97a2                	add	a5,a5,s0
 484:	02d00713          	li	a4,45
 488:	fee78423          	sb	a4,-24(a5)
 48c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 490:	02f05a63          	blez	a5,4c4 <printint+0x8a>
 494:	fc26                	sd	s1,56(sp)
 496:	f44e                	sd	s3,40(sp)
 498:	fb840713          	addi	a4,s0,-72
 49c:	00f704b3          	add	s1,a4,a5
 4a0:	fff70993          	addi	s3,a4,-1
 4a4:	99be                	add	s3,s3,a5
 4a6:	37fd                	addiw	a5,a5,-1
 4a8:	1782                	slli	a5,a5,0x20
 4aa:	9381                	srli	a5,a5,0x20
 4ac:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4b0:	fff4c583          	lbu	a1,-1(s1)
 4b4:	854a                	mv	a0,s2
 4b6:	f67ff0ef          	jal	41c <putc>
  while(--i >= 0)
 4ba:	14fd                	addi	s1,s1,-1
 4bc:	ff349ae3          	bne	s1,s3,4b0 <printint+0x76>
 4c0:	74e2                	ld	s1,56(sp)
 4c2:	79a2                	ld	s3,40(sp)
}
 4c4:	60a6                	ld	ra,72(sp)
 4c6:	6406                	ld	s0,64(sp)
 4c8:	7942                	ld	s2,48(sp)
 4ca:	6161                	addi	sp,sp,80
 4cc:	8082                	ret
    x = -xx;
 4ce:	40b005b3          	neg	a1,a1
    neg = 1;
 4d2:	4885                	li	a7,1
    x = -xx;
 4d4:	bfad                	j	44e <printint+0x14>

00000000000004d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d6:	711d                	addi	sp,sp,-96
 4d8:	ec86                	sd	ra,88(sp)
 4da:	e8a2                	sd	s0,80(sp)
 4dc:	e0ca                	sd	s2,64(sp)
 4de:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e0:	0005c903          	lbu	s2,0(a1)
 4e4:	28090663          	beqz	s2,770 <vprintf+0x29a>
 4e8:	e4a6                	sd	s1,72(sp)
 4ea:	fc4e                	sd	s3,56(sp)
 4ec:	f852                	sd	s4,48(sp)
 4ee:	f456                	sd	s5,40(sp)
 4f0:	f05a                	sd	s6,32(sp)
 4f2:	ec5e                	sd	s7,24(sp)
 4f4:	e862                	sd	s8,16(sp)
 4f6:	e466                	sd	s9,8(sp)
 4f8:	8b2a                	mv	s6,a0
 4fa:	8a2e                	mv	s4,a1
 4fc:	8bb2                	mv	s7,a2
  state = 0;
 4fe:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 500:	4481                	li	s1,0
 502:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 504:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 508:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 50c:	06c00c93          	li	s9,108
 510:	a005                	j	530 <vprintf+0x5a>
        putc(fd, c0);
 512:	85ca                	mv	a1,s2
 514:	855a                	mv	a0,s6
 516:	f07ff0ef          	jal	41c <putc>
 51a:	a019                	j	520 <vprintf+0x4a>
    } else if(state == '%'){
 51c:	03598263          	beq	s3,s5,540 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 520:	2485                	addiw	s1,s1,1
 522:	8726                	mv	a4,s1
 524:	009a07b3          	add	a5,s4,s1
 528:	0007c903          	lbu	s2,0(a5)
 52c:	22090a63          	beqz	s2,760 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 530:	0009079b          	sext.w	a5,s2
    if(state == 0){
 534:	fe0994e3          	bnez	s3,51c <vprintf+0x46>
      if(c0 == '%'){
 538:	fd579de3          	bne	a5,s5,512 <vprintf+0x3c>
        state = '%';
 53c:	89be                	mv	s3,a5
 53e:	b7cd                	j	520 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 540:	00ea06b3          	add	a3,s4,a4
 544:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 548:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 54a:	c681                	beqz	a3,552 <vprintf+0x7c>
 54c:	9752                	add	a4,a4,s4
 54e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 552:	05878363          	beq	a5,s8,598 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 556:	05978d63          	beq	a5,s9,5b0 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 55a:	07500713          	li	a4,117
 55e:	0ee78763          	beq	a5,a4,64c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 562:	07800713          	li	a4,120
 566:	12e78963          	beq	a5,a4,698 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 56a:	07000713          	li	a4,112
 56e:	14e78e63          	beq	a5,a4,6ca <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 572:	06300713          	li	a4,99
 576:	18e78e63          	beq	a5,a4,712 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 57a:	07300713          	li	a4,115
 57e:	1ae78463          	beq	a5,a4,726 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 582:	02500713          	li	a4,37
 586:	04e79563          	bne	a5,a4,5d0 <vprintf+0xfa>
        putc(fd, '%');
 58a:	02500593          	li	a1,37
 58e:	855a                	mv	a0,s6
 590:	e8dff0ef          	jal	41c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 594:	4981                	li	s3,0
 596:	b769                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 598:	008b8913          	addi	s2,s7,8
 59c:	4685                	li	a3,1
 59e:	4629                	li	a2,10
 5a0:	000ba583          	lw	a1,0(s7)
 5a4:	855a                	mv	a0,s6
 5a6:	e95ff0ef          	jal	43a <printint>
 5aa:	8bca                	mv	s7,s2
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	bf8d                	j	520 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5b0:	06400793          	li	a5,100
 5b4:	02f68963          	beq	a3,a5,5e6 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5b8:	06c00793          	li	a5,108
 5bc:	04f68263          	beq	a3,a5,600 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5c0:	07500793          	li	a5,117
 5c4:	0af68063          	beq	a3,a5,664 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5c8:	07800793          	li	a5,120
 5cc:	0ef68263          	beq	a3,a5,6b0 <vprintf+0x1da>
        putc(fd, '%');
 5d0:	02500593          	li	a1,37
 5d4:	855a                	mv	a0,s6
 5d6:	e47ff0ef          	jal	41c <putc>
        putc(fd, c0);
 5da:	85ca                	mv	a1,s2
 5dc:	855a                	mv	a0,s6
 5de:	e3fff0ef          	jal	41c <putc>
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	bf35                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	4685                	li	a3,1
 5ec:	4629                	li	a2,10
 5ee:	000bb583          	ld	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	e47ff0ef          	jal	43a <printint>
        i += 1;
 5f8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fa:	8bca                	mv	s7,s2
      state = 0;
 5fc:	4981                	li	s3,0
        i += 1;
 5fe:	b70d                	j	520 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 600:	06400793          	li	a5,100
 604:	02f60763          	beq	a2,a5,632 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 608:	07500793          	li	a5,117
 60c:	06f60963          	beq	a2,a5,67e <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 610:	07800793          	li	a5,120
 614:	faf61ee3          	bne	a2,a5,5d0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 618:	008b8913          	addi	s2,s7,8
 61c:	4681                	li	a3,0
 61e:	4641                	li	a2,16
 620:	000bb583          	ld	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	e15ff0ef          	jal	43a <printint>
        i += 2;
 62a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
        i += 2;
 630:	bdc5                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 632:	008b8913          	addi	s2,s7,8
 636:	4685                	li	a3,1
 638:	4629                	li	a2,10
 63a:	000bb583          	ld	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	dfbff0ef          	jal	43a <printint>
        i += 2;
 644:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
        i += 2;
 64a:	bdd9                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 64c:	008b8913          	addi	s2,s7,8
 650:	4681                	li	a3,0
 652:	4629                	li	a2,10
 654:	000be583          	lwu	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	de1ff0ef          	jal	43a <printint>
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
 662:	bd7d                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 664:	008b8913          	addi	s2,s7,8
 668:	4681                	li	a3,0
 66a:	4629                	li	a2,10
 66c:	000bb583          	ld	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	dc9ff0ef          	jal	43a <printint>
        i += 1;
 676:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
        i += 1;
 67c:	b555                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67e:	008b8913          	addi	s2,s7,8
 682:	4681                	li	a3,0
 684:	4629                	li	a2,10
 686:	000bb583          	ld	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	dafff0ef          	jal	43a <printint>
        i += 2;
 690:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 692:	8bca                	mv	s7,s2
      state = 0;
 694:	4981                	li	s3,0
        i += 2;
 696:	b569                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 698:	008b8913          	addi	s2,s7,8
 69c:	4681                	li	a3,0
 69e:	4641                	li	a2,16
 6a0:	000be583          	lwu	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	d95ff0ef          	jal	43a <printint>
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	bd8d                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b0:	008b8913          	addi	s2,s7,8
 6b4:	4681                	li	a3,0
 6b6:	4641                	li	a2,16
 6b8:	000bb583          	ld	a1,0(s7)
 6bc:	855a                	mv	a0,s6
 6be:	d7dff0ef          	jal	43a <printint>
        i += 1;
 6c2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c4:	8bca                	mv	s7,s2
      state = 0;
 6c6:	4981                	li	s3,0
        i += 1;
 6c8:	bda1                	j	520 <vprintf+0x4a>
 6ca:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6cc:	008b8d13          	addi	s10,s7,8
 6d0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6d4:	03000593          	li	a1,48
 6d8:	855a                	mv	a0,s6
 6da:	d43ff0ef          	jal	41c <putc>
  putc(fd, 'x');
 6de:	07800593          	li	a1,120
 6e2:	855a                	mv	a0,s6
 6e4:	d39ff0ef          	jal	41c <putc>
 6e8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ea:	00000b97          	auipc	s7,0x0
 6ee:	2a6b8b93          	addi	s7,s7,678 # 990 <digits>
 6f2:	03c9d793          	srli	a5,s3,0x3c
 6f6:	97de                	add	a5,a5,s7
 6f8:	0007c583          	lbu	a1,0(a5)
 6fc:	855a                	mv	a0,s6
 6fe:	d1fff0ef          	jal	41c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 702:	0992                	slli	s3,s3,0x4
 704:	397d                	addiw	s2,s2,-1
 706:	fe0916e3          	bnez	s2,6f2 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 70a:	8bea                	mv	s7,s10
      state = 0;
 70c:	4981                	li	s3,0
 70e:	6d02                	ld	s10,0(sp)
 710:	bd01                	j	520 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 712:	008b8913          	addi	s2,s7,8
 716:	000bc583          	lbu	a1,0(s7)
 71a:	855a                	mv	a0,s6
 71c:	d01ff0ef          	jal	41c <putc>
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
 724:	bbf5                	j	520 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 726:	008b8993          	addi	s3,s7,8
 72a:	000bb903          	ld	s2,0(s7)
 72e:	00090f63          	beqz	s2,74c <vprintf+0x276>
        for(; *s; s++)
 732:	00094583          	lbu	a1,0(s2)
 736:	c195                	beqz	a1,75a <vprintf+0x284>
          putc(fd, *s);
 738:	855a                	mv	a0,s6
 73a:	ce3ff0ef          	jal	41c <putc>
        for(; *s; s++)
 73e:	0905                	addi	s2,s2,1
 740:	00094583          	lbu	a1,0(s2)
 744:	f9f5                	bnez	a1,738 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 746:	8bce                	mv	s7,s3
      state = 0;
 748:	4981                	li	s3,0
 74a:	bbd9                	j	520 <vprintf+0x4a>
          s = "(null)";
 74c:	00000917          	auipc	s2,0x0
 750:	23c90913          	addi	s2,s2,572 # 988 <malloc+0x130>
        for(; *s; s++)
 754:	02800593          	li	a1,40
 758:	b7c5                	j	738 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 75a:	8bce                	mv	s7,s3
      state = 0;
 75c:	4981                	li	s3,0
 75e:	b3c9                	j	520 <vprintf+0x4a>
 760:	64a6                	ld	s1,72(sp)
 762:	79e2                	ld	s3,56(sp)
 764:	7a42                	ld	s4,48(sp)
 766:	7aa2                	ld	s5,40(sp)
 768:	7b02                	ld	s6,32(sp)
 76a:	6be2                	ld	s7,24(sp)
 76c:	6c42                	ld	s8,16(sp)
 76e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 770:	60e6                	ld	ra,88(sp)
 772:	6446                	ld	s0,80(sp)
 774:	6906                	ld	s2,64(sp)
 776:	6125                	addi	sp,sp,96
 778:	8082                	ret

000000000000077a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 77a:	715d                	addi	sp,sp,-80
 77c:	ec06                	sd	ra,24(sp)
 77e:	e822                	sd	s0,16(sp)
 780:	1000                	addi	s0,sp,32
 782:	e010                	sd	a2,0(s0)
 784:	e414                	sd	a3,8(s0)
 786:	e818                	sd	a4,16(s0)
 788:	ec1c                	sd	a5,24(s0)
 78a:	03043023          	sd	a6,32(s0)
 78e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 792:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 796:	8622                	mv	a2,s0
 798:	d3fff0ef          	jal	4d6 <vprintf>
}
 79c:	60e2                	ld	ra,24(sp)
 79e:	6442                	ld	s0,16(sp)
 7a0:	6161                	addi	sp,sp,80
 7a2:	8082                	ret

00000000000007a4 <printf>:

void
printf(const char *fmt, ...)
{
 7a4:	711d                	addi	sp,sp,-96
 7a6:	ec06                	sd	ra,24(sp)
 7a8:	e822                	sd	s0,16(sp)
 7aa:	1000                	addi	s0,sp,32
 7ac:	e40c                	sd	a1,8(s0)
 7ae:	e810                	sd	a2,16(s0)
 7b0:	ec14                	sd	a3,24(s0)
 7b2:	f018                	sd	a4,32(s0)
 7b4:	f41c                	sd	a5,40(s0)
 7b6:	03043823          	sd	a6,48(s0)
 7ba:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7be:	00840613          	addi	a2,s0,8
 7c2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c6:	85aa                	mv	a1,a0
 7c8:	4505                	li	a0,1
 7ca:	d0dff0ef          	jal	4d6 <vprintf>
}
 7ce:	60e2                	ld	ra,24(sp)
 7d0:	6442                	ld	s0,16(sp)
 7d2:	6125                	addi	sp,sp,96
 7d4:	8082                	ret

00000000000007d6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d6:	1141                	addi	sp,sp,-16
 7d8:	e422                	sd	s0,8(sp)
 7da:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7dc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e0:	00001797          	auipc	a5,0x1
 7e4:	8207b783          	ld	a5,-2016(a5) # 1000 <freep>
 7e8:	a02d                	j	812 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ea:	4618                	lw	a4,8(a2)
 7ec:	9f2d                	addw	a4,a4,a1
 7ee:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f2:	6398                	ld	a4,0(a5)
 7f4:	6310                	ld	a2,0(a4)
 7f6:	a83d                	j	834 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f8:	ff852703          	lw	a4,-8(a0)
 7fc:	9f31                	addw	a4,a4,a2
 7fe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 800:	ff053683          	ld	a3,-16(a0)
 804:	a091                	j	848 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 806:	6398                	ld	a4,0(a5)
 808:	00e7e463          	bltu	a5,a4,810 <free+0x3a>
 80c:	00e6ea63          	bltu	a3,a4,820 <free+0x4a>
{
 810:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 812:	fed7fae3          	bgeu	a5,a3,806 <free+0x30>
 816:	6398                	ld	a4,0(a5)
 818:	00e6e463          	bltu	a3,a4,820 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	fee7eae3          	bltu	a5,a4,810 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 820:	ff852583          	lw	a1,-8(a0)
 824:	6390                	ld	a2,0(a5)
 826:	02059813          	slli	a6,a1,0x20
 82a:	01c85713          	srli	a4,a6,0x1c
 82e:	9736                	add	a4,a4,a3
 830:	fae60de3          	beq	a2,a4,7ea <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 834:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 838:	4790                	lw	a2,8(a5)
 83a:	02061593          	slli	a1,a2,0x20
 83e:	01c5d713          	srli	a4,a1,0x1c
 842:	973e                	add	a4,a4,a5
 844:	fae68ae3          	beq	a3,a4,7f8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 848:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 84a:	00000717          	auipc	a4,0x0
 84e:	7af73b23          	sd	a5,1974(a4) # 1000 <freep>
}
 852:	6422                	ld	s0,8(sp)
 854:	0141                	addi	sp,sp,16
 856:	8082                	ret

0000000000000858 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 858:	7139                	addi	sp,sp,-64
 85a:	fc06                	sd	ra,56(sp)
 85c:	f822                	sd	s0,48(sp)
 85e:	f426                	sd	s1,40(sp)
 860:	ec4e                	sd	s3,24(sp)
 862:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 864:	02051493          	slli	s1,a0,0x20
 868:	9081                	srli	s1,s1,0x20
 86a:	04bd                	addi	s1,s1,15
 86c:	8091                	srli	s1,s1,0x4
 86e:	0014899b          	addiw	s3,s1,1
 872:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 874:	00000517          	auipc	a0,0x0
 878:	78c53503          	ld	a0,1932(a0) # 1000 <freep>
 87c:	c915                	beqz	a0,8b0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 880:	4798                	lw	a4,8(a5)
 882:	08977a63          	bgeu	a4,s1,916 <malloc+0xbe>
 886:	f04a                	sd	s2,32(sp)
 888:	e852                	sd	s4,16(sp)
 88a:	e456                	sd	s5,8(sp)
 88c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 88e:	8a4e                	mv	s4,s3
 890:	0009871b          	sext.w	a4,s3
 894:	6685                	lui	a3,0x1
 896:	00d77363          	bgeu	a4,a3,89c <malloc+0x44>
 89a:	6a05                	lui	s4,0x1
 89c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a4:	00000917          	auipc	s2,0x0
 8a8:	75c90913          	addi	s2,s2,1884 # 1000 <freep>
  if(p == SBRK_ERROR)
 8ac:	5afd                	li	s5,-1
 8ae:	a081                	j	8ee <malloc+0x96>
 8b0:	f04a                	sd	s2,32(sp)
 8b2:	e852                	sd	s4,16(sp)
 8b4:	e456                	sd	s5,8(sp)
 8b6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8b8:	00000797          	auipc	a5,0x0
 8bc:	75878793          	addi	a5,a5,1880 # 1010 <base>
 8c0:	00000717          	auipc	a4,0x0
 8c4:	74f73023          	sd	a5,1856(a4) # 1000 <freep>
 8c8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ca:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ce:	b7c1                	j	88e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8d0:	6398                	ld	a4,0(a5)
 8d2:	e118                	sd	a4,0(a0)
 8d4:	a8a9                	j	92e <malloc+0xd6>
  hp->s.size = nu;
 8d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8da:	0541                	addi	a0,a0,16
 8dc:	efbff0ef          	jal	7d6 <free>
  return freep;
 8e0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e4:	c12d                	beqz	a0,946 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e8:	4798                	lw	a4,8(a5)
 8ea:	02977263          	bgeu	a4,s1,90e <malloc+0xb6>
    if(p == freep)
 8ee:	00093703          	ld	a4,0(s2)
 8f2:	853e                	mv	a0,a5
 8f4:	fef719e3          	bne	a4,a5,8e6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8f8:	8552                	mv	a0,s4
 8fa:	9cdff0ef          	jal	2c6 <sbrk>
  if(p == SBRK_ERROR)
 8fe:	fd551ce3          	bne	a0,s5,8d6 <malloc+0x7e>
        return 0;
 902:	4501                	li	a0,0
 904:	7902                	ld	s2,32(sp)
 906:	6a42                	ld	s4,16(sp)
 908:	6aa2                	ld	s5,8(sp)
 90a:	6b02                	ld	s6,0(sp)
 90c:	a03d                	j	93a <malloc+0xe2>
 90e:	7902                	ld	s2,32(sp)
 910:	6a42                	ld	s4,16(sp)
 912:	6aa2                	ld	s5,8(sp)
 914:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 916:	fae48de3          	beq	s1,a4,8d0 <malloc+0x78>
        p->s.size -= nunits;
 91a:	4137073b          	subw	a4,a4,s3
 91e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 920:	02071693          	slli	a3,a4,0x20
 924:	01c6d713          	srli	a4,a3,0x1c
 928:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 92a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 92e:	00000717          	auipc	a4,0x0
 932:	6ca73923          	sd	a0,1746(a4) # 1000 <freep>
      return (void*)(p + 1);
 936:	01078513          	addi	a0,a5,16
  }
}
 93a:	70e2                	ld	ra,56(sp)
 93c:	7442                	ld	s0,48(sp)
 93e:	74a2                	ld	s1,40(sp)
 940:	69e2                	ld	s3,24(sp)
 942:	6121                	addi	sp,sp,64
 944:	8082                	ret
 946:	7902                	ld	s2,32(sp)
 948:	6a42                	ld	s4,16(sp)
 94a:	6aa2                	ld	s5,8(sp)
 94c:	6b02                	ld	s6,0(sp)
 94e:	b7f5                	j	93a <malloc+0xe2>
