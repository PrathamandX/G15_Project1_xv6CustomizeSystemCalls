
user/_ln:     file format elf64-littleriscv


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
  if(argc != 3){
   8:	478d                	li	a5,3
   a:	00f50d63          	beq	a0,a5,24 <main+0x24>
   e:	e426                	sd	s1,8(sp)
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	93058593          	addi	a1,a1,-1744 # 940 <malloc+0x100>
  18:	4509                	li	a0,2
  1a:	748000ef          	jal	762 <fprintf>
    exit(1);
  1e:	4505                	li	a0,1
  20:	2c2000ef          	jal	2e2 <exit>
  24:	e426                	sd	s1,8(sp)
  26:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  28:	698c                	ld	a1,16(a1)
  2a:	6488                	ld	a0,8(s1)
  2c:	31e000ef          	jal	34a <link>
  30:	00054563          	bltz	a0,3a <main+0x3a>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  34:	4501                	li	a0,0
  36:	2ac000ef          	jal	2e2 <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  3a:	6894                	ld	a3,16(s1)
  3c:	6490                	ld	a2,8(s1)
  3e:	00001597          	auipc	a1,0x1
  42:	91a58593          	addi	a1,a1,-1766 # 958 <malloc+0x118>
  46:	4509                	li	a0,2
  48:	71a000ef          	jal	762 <fprintf>
  4c:	b7e5                	j	34 <main+0x34>

000000000000004e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  4e:	1141                	addi	sp,sp,-16
  50:	e406                	sd	ra,8(sp)
  52:	e022                	sd	s0,0(sp)
  54:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  56:	fabff0ef          	jal	0 <main>
  exit(r);
  5a:	288000ef          	jal	2e2 <exit>

000000000000005e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  5e:	1141                	addi	sp,sp,-16
  60:	e422                	sd	s0,8(sp)
  62:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  64:	87aa                	mv	a5,a0
  66:	0585                	addi	a1,a1,1
  68:	0785                	addi	a5,a5,1
  6a:	fff5c703          	lbu	a4,-1(a1)
  6e:	fee78fa3          	sb	a4,-1(a5)
  72:	fb75                	bnez	a4,66 <strcpy+0x8>
    ;
  return os;
}
  74:	6422                	ld	s0,8(sp)
  76:	0141                	addi	sp,sp,16
  78:	8082                	ret

000000000000007a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  80:	00054783          	lbu	a5,0(a0)
  84:	cb91                	beqz	a5,98 <strcmp+0x1e>
  86:	0005c703          	lbu	a4,0(a1)
  8a:	00f71763          	bne	a4,a5,98 <strcmp+0x1e>
    p++, q++;
  8e:	0505                	addi	a0,a0,1
  90:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  92:	00054783          	lbu	a5,0(a0)
  96:	fbe5                	bnez	a5,86 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  98:	0005c503          	lbu	a0,0(a1)
}
  9c:	40a7853b          	subw	a0,a5,a0
  a0:	6422                	ld	s0,8(sp)
  a2:	0141                	addi	sp,sp,16
  a4:	8082                	ret

00000000000000a6 <strlen>:

uint
strlen(const char *s)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e422                	sd	s0,8(sp)
  aa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ac:	00054783          	lbu	a5,0(a0)
  b0:	cf91                	beqz	a5,cc <strlen+0x26>
  b2:	0505                	addi	a0,a0,1
  b4:	87aa                	mv	a5,a0
  b6:	86be                	mv	a3,a5
  b8:	0785                	addi	a5,a5,1
  ba:	fff7c703          	lbu	a4,-1(a5)
  be:	ff65                	bnez	a4,b6 <strlen+0x10>
  c0:	40a6853b          	subw	a0,a3,a0
  c4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret
  for(n = 0; s[n]; n++)
  cc:	4501                	li	a0,0
  ce:	bfe5                	j	c6 <strlen+0x20>

00000000000000d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d6:	ca19                	beqz	a2,ec <memset+0x1c>
  d8:	87aa                	mv	a5,a0
  da:	1602                	slli	a2,a2,0x20
  dc:	9201                	srli	a2,a2,0x20
  de:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e6:	0785                	addi	a5,a5,1
  e8:	fee79de3          	bne	a5,a4,e2 <memset+0x12>
  }
  return dst;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strchr>:

char*
strchr(const char *s, char c)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cb99                	beqz	a5,112 <strchr+0x20>
    if(*s == c)
  fe:	00f58763          	beq	a1,a5,10c <strchr+0x1a>
  for(; *s; s++)
 102:	0505                	addi	a0,a0,1
 104:	00054783          	lbu	a5,0(a0)
 108:	fbfd                	bnez	a5,fe <strchr+0xc>
      return (char*)s;
  return 0;
 10a:	4501                	li	a0,0
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret
  return 0;
 112:	4501                	li	a0,0
 114:	bfe5                	j	10c <strchr+0x1a>

0000000000000116 <gets>:

char*
gets(char *buf, int max)
{
 116:	711d                	addi	sp,sp,-96
 118:	ec86                	sd	ra,88(sp)
 11a:	e8a2                	sd	s0,80(sp)
 11c:	e4a6                	sd	s1,72(sp)
 11e:	e0ca                	sd	s2,64(sp)
 120:	fc4e                	sd	s3,56(sp)
 122:	f852                	sd	s4,48(sp)
 124:	f456                	sd	s5,40(sp)
 126:	f05a                	sd	s6,32(sp)
 128:	ec5e                	sd	s7,24(sp)
 12a:	1080                	addi	s0,sp,96
 12c:	8baa                	mv	s7,a0
 12e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 130:	892a                	mv	s2,a0
 132:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 134:	4aa9                	li	s5,10
 136:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 138:	89a6                	mv	s3,s1
 13a:	2485                	addiw	s1,s1,1
 13c:	0344d663          	bge	s1,s4,168 <gets+0x52>
    cc = read(0, &c, 1);
 140:	4605                	li	a2,1
 142:	faf40593          	addi	a1,s0,-81
 146:	4501                	li	a0,0
 148:	1ba000ef          	jal	302 <read>
    if(cc < 1)
 14c:	00a05e63          	blez	a0,168 <gets+0x52>
    buf[i++] = c;
 150:	faf44783          	lbu	a5,-81(s0)
 154:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 158:	01578763          	beq	a5,s5,166 <gets+0x50>
 15c:	0905                	addi	s2,s2,1
 15e:	fd679de3          	bne	a5,s6,138 <gets+0x22>
    buf[i++] = c;
 162:	89a6                	mv	s3,s1
 164:	a011                	j	168 <gets+0x52>
 166:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 168:	99de                	add	s3,s3,s7
 16a:	00098023          	sb	zero,0(s3)
  return buf;
}
 16e:	855e                	mv	a0,s7
 170:	60e6                	ld	ra,88(sp)
 172:	6446                	ld	s0,80(sp)
 174:	64a6                	ld	s1,72(sp)
 176:	6906                	ld	s2,64(sp)
 178:	79e2                	ld	s3,56(sp)
 17a:	7a42                	ld	s4,48(sp)
 17c:	7aa2                	ld	s5,40(sp)
 17e:	7b02                	ld	s6,32(sp)
 180:	6be2                	ld	s7,24(sp)
 182:	6125                	addi	sp,sp,96
 184:	8082                	ret

0000000000000186 <stat>:

int
stat(const char *n, struct stat *st)
{
 186:	1101                	addi	sp,sp,-32
 188:	ec06                	sd	ra,24(sp)
 18a:	e822                	sd	s0,16(sp)
 18c:	e04a                	sd	s2,0(sp)
 18e:	1000                	addi	s0,sp,32
 190:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 192:	4581                	li	a1,0
 194:	196000ef          	jal	32a <open>
  if(fd < 0)
 198:	02054263          	bltz	a0,1bc <stat+0x36>
 19c:	e426                	sd	s1,8(sp)
 19e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a0:	85ca                	mv	a1,s2
 1a2:	1a0000ef          	jal	342 <fstat>
 1a6:	892a                	mv	s2,a0
  close(fd);
 1a8:	8526                	mv	a0,s1
 1aa:	168000ef          	jal	312 <close>
  return r;
 1ae:	64a2                	ld	s1,8(sp)
}
 1b0:	854a                	mv	a0,s2
 1b2:	60e2                	ld	ra,24(sp)
 1b4:	6442                	ld	s0,16(sp)
 1b6:	6902                	ld	s2,0(sp)
 1b8:	6105                	addi	sp,sp,32
 1ba:	8082                	ret
    return -1;
 1bc:	597d                	li	s2,-1
 1be:	bfcd                	j	1b0 <stat+0x2a>

00000000000001c0 <atoi>:

int
atoi(const char *s)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c6:	00054683          	lbu	a3,0(a0)
 1ca:	fd06879b          	addiw	a5,a3,-48
 1ce:	0ff7f793          	zext.b	a5,a5
 1d2:	4625                	li	a2,9
 1d4:	02f66863          	bltu	a2,a5,204 <atoi+0x44>
 1d8:	872a                	mv	a4,a0
  n = 0;
 1da:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1dc:	0705                	addi	a4,a4,1
 1de:	0025179b          	slliw	a5,a0,0x2
 1e2:	9fa9                	addw	a5,a5,a0
 1e4:	0017979b          	slliw	a5,a5,0x1
 1e8:	9fb5                	addw	a5,a5,a3
 1ea:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ee:	00074683          	lbu	a3,0(a4)
 1f2:	fd06879b          	addiw	a5,a3,-48
 1f6:	0ff7f793          	zext.b	a5,a5
 1fa:	fef671e3          	bgeu	a2,a5,1dc <atoi+0x1c>
  return n;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  n = 0;
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <atoi+0x3e>

0000000000000208 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 20e:	02b57463          	bgeu	a0,a1,236 <memmove+0x2e>
    while(n-- > 0)
 212:	00c05f63          	blez	a2,230 <memmove+0x28>
 216:	1602                	slli	a2,a2,0x20
 218:	9201                	srli	a2,a2,0x20
 21a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 21e:	872a                	mv	a4,a0
      *dst++ = *src++;
 220:	0585                	addi	a1,a1,1
 222:	0705                	addi	a4,a4,1
 224:	fff5c683          	lbu	a3,-1(a1)
 228:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 22c:	fef71ae3          	bne	a4,a5,220 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
    dst += n;
 236:	00c50733          	add	a4,a0,a2
    src += n;
 23a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 23c:	fec05ae3          	blez	a2,230 <memmove+0x28>
 240:	fff6079b          	addiw	a5,a2,-1
 244:	1782                	slli	a5,a5,0x20
 246:	9381                	srli	a5,a5,0x20
 248:	fff7c793          	not	a5,a5
 24c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 24e:	15fd                	addi	a1,a1,-1
 250:	177d                	addi	a4,a4,-1
 252:	0005c683          	lbu	a3,0(a1)
 256:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 25a:	fee79ae3          	bne	a5,a4,24e <memmove+0x46>
 25e:	bfc9                	j	230 <memmove+0x28>

0000000000000260 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 266:	ca05                	beqz	a2,296 <memcmp+0x36>
 268:	fff6069b          	addiw	a3,a2,-1
 26c:	1682                	slli	a3,a3,0x20
 26e:	9281                	srli	a3,a3,0x20
 270:	0685                	addi	a3,a3,1
 272:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 274:	00054783          	lbu	a5,0(a0)
 278:	0005c703          	lbu	a4,0(a1)
 27c:	00e79863          	bne	a5,a4,28c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 280:	0505                	addi	a0,a0,1
    p2++;
 282:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 284:	fed518e3          	bne	a0,a3,274 <memcmp+0x14>
  }
  return 0;
 288:	4501                	li	a0,0
 28a:	a019                	j	290 <memcmp+0x30>
      return *p1 - *p2;
 28c:	40e7853b          	subw	a0,a5,a4
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
  return 0;
 296:	4501                	li	a0,0
 298:	bfe5                	j	290 <memcmp+0x30>

000000000000029a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e406                	sd	ra,8(sp)
 29e:	e022                	sd	s0,0(sp)
 2a0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a2:	f67ff0ef          	jal	208 <memmove>
}
 2a6:	60a2                	ld	ra,8(sp)
 2a8:	6402                	ld	s0,0(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret

00000000000002ae <sbrk>:

char *
sbrk(int n) {
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e406                	sd	ra,8(sp)
 2b2:	e022                	sd	s0,0(sp)
 2b4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2b6:	4585                	li	a1,1
 2b8:	0ba000ef          	jal	372 <sys_sbrk>
}
 2bc:	60a2                	ld	ra,8(sp)
 2be:	6402                	ld	s0,0(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <sbrklazy>:

char *
sbrklazy(int n) {
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2cc:	4589                	li	a1,2
 2ce:	0a4000ef          	jal	372 <sys_sbrk>
}
 2d2:	60a2                	ld	ra,8(sp)
 2d4:	6402                	ld	s0,0(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2da:	4885                	li	a7,1
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e2:	4889                	li	a7,2
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ea:	488d                	li	a7,3
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 2f2:	48d9                	li	a7,22
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fa:	4891                	li	a7,4
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <read>:
.global read
read:
 li a7, SYS_read
 302:	4895                	li	a7,5
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <write>:
.global write
write:
 li a7, SYS_write
 30a:	48c1                	li	a7,16
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <close>:
.global close
close:
 li a7, SYS_close
 312:	48d5                	li	a7,21
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <kill>:
.global kill
kill:
 li a7, SYS_kill
 31a:	4899                	li	a7,6
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <exec>:
.global exec
exec:
 li a7, SYS_exec
 322:	489d                	li	a7,7
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <open>:
.global open
open:
 li a7, SYS_open
 32a:	48bd                	li	a7,15
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 332:	48c5                	li	a7,17
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33a:	48c9                	li	a7,18
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 342:	48a1                	li	a7,8
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <link>:
.global link
link:
 li a7, SYS_link
 34a:	48cd                	li	a7,19
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 352:	48d1                	li	a7,20
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35a:	48a5                	li	a7,9
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <dup>:
.global dup
dup:
 li a7, SYS_dup
 362:	48a9                	li	a7,10
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36a:	48ad                	li	a7,11
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 372:	48b1                	li	a7,12
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <pause>:
.global pause
pause:
 li a7, SYS_pause
 37a:	48b5                	li	a7,13
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 382:	48b9                	li	a7,14
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 38a:	48dd                	li	a7,23
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 392:	48e1                	li	a7,24
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <mutex_init>:
.global mutex_init
mutex_init:
 li a7, SYS_mutex_init
 39a:	48e5                	li	a7,25
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <mutex_acquire>:
.global mutex_acquire
mutex_acquire:
 li a7, SYS_mutex_acquire
 3a2:	48e9                	li	a7,26
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <mutex_release>:
.global mutex_release
mutex_release:
 li a7, SYS_mutex_release
 3aa:	48ed                	li	a7,27
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 3b2:	48f1                	li	a7,28
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 3ba:	48f5                	li	a7,29
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3c2:	48f9                	li	a7,30
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <setp>:
.global setp
setp:
 li a7, SYS_setp
 3ca:	48fd                	li	a7,31
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <ismyear>:
.global ismyear
ismyear:
 li a7, SYS_ismyear
 3d2:	02000893          	li	a7,32
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 3dc:	02100893          	li	a7,33
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 3e6:	02200893          	li	a7,34
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <thread_exit>:
.global thread_exit
thread_exit:
 li a7, SYS_thread_exit
 3f0:	02300893          	li	a7,35
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <thread_id>:
.global thread_id
thread_id:
 li a7, SYS_thread_id
 3fa:	02400893          	li	a7,36
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 404:	1101                	addi	sp,sp,-32
 406:	ec06                	sd	ra,24(sp)
 408:	e822                	sd	s0,16(sp)
 40a:	1000                	addi	s0,sp,32
 40c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 410:	4605                	li	a2,1
 412:	fef40593          	addi	a1,s0,-17
 416:	ef5ff0ef          	jal	30a <write>
}
 41a:	60e2                	ld	ra,24(sp)
 41c:	6442                	ld	s0,16(sp)
 41e:	6105                	addi	sp,sp,32
 420:	8082                	ret

0000000000000422 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 422:	715d                	addi	sp,sp,-80
 424:	e486                	sd	ra,72(sp)
 426:	e0a2                	sd	s0,64(sp)
 428:	f84a                	sd	s2,48(sp)
 42a:	0880                	addi	s0,sp,80
 42c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 42e:	c299                	beqz	a3,434 <printint+0x12>
 430:	0805c363          	bltz	a1,4b6 <printint+0x94>
  neg = 0;
 434:	4881                	li	a7,0
 436:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 43a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 43c:	00000517          	auipc	a0,0x0
 440:	53c50513          	addi	a0,a0,1340 # 978 <digits>
 444:	883e                	mv	a6,a5
 446:	2785                	addiw	a5,a5,1
 448:	02c5f733          	remu	a4,a1,a2
 44c:	972a                	add	a4,a4,a0
 44e:	00074703          	lbu	a4,0(a4)
 452:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 456:	872e                	mv	a4,a1
 458:	02c5d5b3          	divu	a1,a1,a2
 45c:	0685                	addi	a3,a3,1
 45e:	fec773e3          	bgeu	a4,a2,444 <printint+0x22>
  if(neg)
 462:	00088b63          	beqz	a7,478 <printint+0x56>
    buf[i++] = '-';
 466:	fd078793          	addi	a5,a5,-48
 46a:	97a2                	add	a5,a5,s0
 46c:	02d00713          	li	a4,45
 470:	fee78423          	sb	a4,-24(a5)
 474:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 478:	02f05a63          	blez	a5,4ac <printint+0x8a>
 47c:	fc26                	sd	s1,56(sp)
 47e:	f44e                	sd	s3,40(sp)
 480:	fb840713          	addi	a4,s0,-72
 484:	00f704b3          	add	s1,a4,a5
 488:	fff70993          	addi	s3,a4,-1
 48c:	99be                	add	s3,s3,a5
 48e:	37fd                	addiw	a5,a5,-1
 490:	1782                	slli	a5,a5,0x20
 492:	9381                	srli	a5,a5,0x20
 494:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 498:	fff4c583          	lbu	a1,-1(s1)
 49c:	854a                	mv	a0,s2
 49e:	f67ff0ef          	jal	404 <putc>
  while(--i >= 0)
 4a2:	14fd                	addi	s1,s1,-1
 4a4:	ff349ae3          	bne	s1,s3,498 <printint+0x76>
 4a8:	74e2                	ld	s1,56(sp)
 4aa:	79a2                	ld	s3,40(sp)
}
 4ac:	60a6                	ld	ra,72(sp)
 4ae:	6406                	ld	s0,64(sp)
 4b0:	7942                	ld	s2,48(sp)
 4b2:	6161                	addi	sp,sp,80
 4b4:	8082                	ret
    x = -xx;
 4b6:	40b005b3          	neg	a1,a1
    neg = 1;
 4ba:	4885                	li	a7,1
    x = -xx;
 4bc:	bfad                	j	436 <printint+0x14>

00000000000004be <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4be:	711d                	addi	sp,sp,-96
 4c0:	ec86                	sd	ra,88(sp)
 4c2:	e8a2                	sd	s0,80(sp)
 4c4:	e0ca                	sd	s2,64(sp)
 4c6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4c8:	0005c903          	lbu	s2,0(a1)
 4cc:	28090663          	beqz	s2,758 <vprintf+0x29a>
 4d0:	e4a6                	sd	s1,72(sp)
 4d2:	fc4e                	sd	s3,56(sp)
 4d4:	f852                	sd	s4,48(sp)
 4d6:	f456                	sd	s5,40(sp)
 4d8:	f05a                	sd	s6,32(sp)
 4da:	ec5e                	sd	s7,24(sp)
 4dc:	e862                	sd	s8,16(sp)
 4de:	e466                	sd	s9,8(sp)
 4e0:	8b2a                	mv	s6,a0
 4e2:	8a2e                	mv	s4,a1
 4e4:	8bb2                	mv	s7,a2
  state = 0;
 4e6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4e8:	4481                	li	s1,0
 4ea:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4ec:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4f0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4f4:	06c00c93          	li	s9,108
 4f8:	a005                	j	518 <vprintf+0x5a>
        putc(fd, c0);
 4fa:	85ca                	mv	a1,s2
 4fc:	855a                	mv	a0,s6
 4fe:	f07ff0ef          	jal	404 <putc>
 502:	a019                	j	508 <vprintf+0x4a>
    } else if(state == '%'){
 504:	03598263          	beq	s3,s5,528 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 508:	2485                	addiw	s1,s1,1
 50a:	8726                	mv	a4,s1
 50c:	009a07b3          	add	a5,s4,s1
 510:	0007c903          	lbu	s2,0(a5)
 514:	22090a63          	beqz	s2,748 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 518:	0009079b          	sext.w	a5,s2
    if(state == 0){
 51c:	fe0994e3          	bnez	s3,504 <vprintf+0x46>
      if(c0 == '%'){
 520:	fd579de3          	bne	a5,s5,4fa <vprintf+0x3c>
        state = '%';
 524:	89be                	mv	s3,a5
 526:	b7cd                	j	508 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 528:	00ea06b3          	add	a3,s4,a4
 52c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 530:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 532:	c681                	beqz	a3,53a <vprintf+0x7c>
 534:	9752                	add	a4,a4,s4
 536:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 53a:	05878363          	beq	a5,s8,580 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 53e:	05978d63          	beq	a5,s9,598 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 542:	07500713          	li	a4,117
 546:	0ee78763          	beq	a5,a4,634 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 54a:	07800713          	li	a4,120
 54e:	12e78963          	beq	a5,a4,680 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 552:	07000713          	li	a4,112
 556:	14e78e63          	beq	a5,a4,6b2 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 55a:	06300713          	li	a4,99
 55e:	18e78e63          	beq	a5,a4,6fa <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 562:	07300713          	li	a4,115
 566:	1ae78463          	beq	a5,a4,70e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 56a:	02500713          	li	a4,37
 56e:	04e79563          	bne	a5,a4,5b8 <vprintf+0xfa>
        putc(fd, '%');
 572:	02500593          	li	a1,37
 576:	855a                	mv	a0,s6
 578:	e8dff0ef          	jal	404 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 57c:	4981                	li	s3,0
 57e:	b769                	j	508 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 580:	008b8913          	addi	s2,s7,8
 584:	4685                	li	a3,1
 586:	4629                	li	a2,10
 588:	000ba583          	lw	a1,0(s7)
 58c:	855a                	mv	a0,s6
 58e:	e95ff0ef          	jal	422 <printint>
 592:	8bca                	mv	s7,s2
      state = 0;
 594:	4981                	li	s3,0
 596:	bf8d                	j	508 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 598:	06400793          	li	a5,100
 59c:	02f68963          	beq	a3,a5,5ce <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a0:	06c00793          	li	a5,108
 5a4:	04f68263          	beq	a3,a5,5e8 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5a8:	07500793          	li	a5,117
 5ac:	0af68063          	beq	a3,a5,64c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5b0:	07800793          	li	a5,120
 5b4:	0ef68263          	beq	a3,a5,698 <vprintf+0x1da>
        putc(fd, '%');
 5b8:	02500593          	li	a1,37
 5bc:	855a                	mv	a0,s6
 5be:	e47ff0ef          	jal	404 <putc>
        putc(fd, c0);
 5c2:	85ca                	mv	a1,s2
 5c4:	855a                	mv	a0,s6
 5c6:	e3fff0ef          	jal	404 <putc>
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	bf35                	j	508 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4685                	li	a3,1
 5d4:	4629                	li	a2,10
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	e47ff0ef          	jal	422 <printint>
        i += 1;
 5e0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
        i += 1;
 5e6:	b70d                	j	508 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5e8:	06400793          	li	a5,100
 5ec:	02f60763          	beq	a2,a5,61a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5f0:	07500793          	li	a5,117
 5f4:	06f60963          	beq	a2,a5,666 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5f8:	07800793          	li	a5,120
 5fc:	faf61ee3          	bne	a2,a5,5b8 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 600:	008b8913          	addi	s2,s7,8
 604:	4681                	li	a3,0
 606:	4641                	li	a2,16
 608:	000bb583          	ld	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	e15ff0ef          	jal	422 <printint>
        i += 2;
 612:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
        i += 2;
 618:	bdc5                	j	508 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4685                	li	a3,1
 620:	4629                	li	a2,10
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	dfbff0ef          	jal	422 <printint>
        i += 2;
 62c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 62e:	8bca                	mv	s7,s2
      state = 0;
 630:	4981                	li	s3,0
        i += 2;
 632:	bdd9                	j	508 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 634:	008b8913          	addi	s2,s7,8
 638:	4681                	li	a3,0
 63a:	4629                	li	a2,10
 63c:	000be583          	lwu	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	de1ff0ef          	jal	422 <printint>
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
 64a:	bd7d                	j	508 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64c:	008b8913          	addi	s2,s7,8
 650:	4681                	li	a3,0
 652:	4629                	li	a2,10
 654:	000bb583          	ld	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	dc9ff0ef          	jal	422 <printint>
        i += 1;
 65e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 660:	8bca                	mv	s7,s2
      state = 0;
 662:	4981                	li	s3,0
        i += 1;
 664:	b555                	j	508 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 666:	008b8913          	addi	s2,s7,8
 66a:	4681                	li	a3,0
 66c:	4629                	li	a2,10
 66e:	000bb583          	ld	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	dafff0ef          	jal	422 <printint>
        i += 2;
 678:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	8bca                	mv	s7,s2
      state = 0;
 67c:	4981                	li	s3,0
        i += 2;
 67e:	b569                	j	508 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 680:	008b8913          	addi	s2,s7,8
 684:	4681                	li	a3,0
 686:	4641                	li	a2,16
 688:	000be583          	lwu	a1,0(s7)
 68c:	855a                	mv	a0,s6
 68e:	d95ff0ef          	jal	422 <printint>
 692:	8bca                	mv	s7,s2
      state = 0;
 694:	4981                	li	s3,0
 696:	bd8d                	j	508 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 698:	008b8913          	addi	s2,s7,8
 69c:	4681                	li	a3,0
 69e:	4641                	li	a2,16
 6a0:	000bb583          	ld	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	d7dff0ef          	jal	422 <printint>
        i += 1;
 6aa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ac:	8bca                	mv	s7,s2
      state = 0;
 6ae:	4981                	li	s3,0
        i += 1;
 6b0:	bda1                	j	508 <vprintf+0x4a>
 6b2:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6b4:	008b8d13          	addi	s10,s7,8
 6b8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6bc:	03000593          	li	a1,48
 6c0:	855a                	mv	a0,s6
 6c2:	d43ff0ef          	jal	404 <putc>
  putc(fd, 'x');
 6c6:	07800593          	li	a1,120
 6ca:	855a                	mv	a0,s6
 6cc:	d39ff0ef          	jal	404 <putc>
 6d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6d2:	00000b97          	auipc	s7,0x0
 6d6:	2a6b8b93          	addi	s7,s7,678 # 978 <digits>
 6da:	03c9d793          	srli	a5,s3,0x3c
 6de:	97de                	add	a5,a5,s7
 6e0:	0007c583          	lbu	a1,0(a5)
 6e4:	855a                	mv	a0,s6
 6e6:	d1fff0ef          	jal	404 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ea:	0992                	slli	s3,s3,0x4
 6ec:	397d                	addiw	s2,s2,-1
 6ee:	fe0916e3          	bnez	s2,6da <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6f2:	8bea                	mv	s7,s10
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	6d02                	ld	s10,0(sp)
 6f8:	bd01                	j	508 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6fa:	008b8913          	addi	s2,s7,8
 6fe:	000bc583          	lbu	a1,0(s7)
 702:	855a                	mv	a0,s6
 704:	d01ff0ef          	jal	404 <putc>
 708:	8bca                	mv	s7,s2
      state = 0;
 70a:	4981                	li	s3,0
 70c:	bbf5                	j	508 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 70e:	008b8993          	addi	s3,s7,8
 712:	000bb903          	ld	s2,0(s7)
 716:	00090f63          	beqz	s2,734 <vprintf+0x276>
        for(; *s; s++)
 71a:	00094583          	lbu	a1,0(s2)
 71e:	c195                	beqz	a1,742 <vprintf+0x284>
          putc(fd, *s);
 720:	855a                	mv	a0,s6
 722:	ce3ff0ef          	jal	404 <putc>
        for(; *s; s++)
 726:	0905                	addi	s2,s2,1
 728:	00094583          	lbu	a1,0(s2)
 72c:	f9f5                	bnez	a1,720 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 72e:	8bce                	mv	s7,s3
      state = 0;
 730:	4981                	li	s3,0
 732:	bbd9                	j	508 <vprintf+0x4a>
          s = "(null)";
 734:	00000917          	auipc	s2,0x0
 738:	23c90913          	addi	s2,s2,572 # 970 <malloc+0x130>
        for(; *s; s++)
 73c:	02800593          	li	a1,40
 740:	b7c5                	j	720 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 742:	8bce                	mv	s7,s3
      state = 0;
 744:	4981                	li	s3,0
 746:	b3c9                	j	508 <vprintf+0x4a>
 748:	64a6                	ld	s1,72(sp)
 74a:	79e2                	ld	s3,56(sp)
 74c:	7a42                	ld	s4,48(sp)
 74e:	7aa2                	ld	s5,40(sp)
 750:	7b02                	ld	s6,32(sp)
 752:	6be2                	ld	s7,24(sp)
 754:	6c42                	ld	s8,16(sp)
 756:	6ca2                	ld	s9,8(sp)
    }
  }
}
 758:	60e6                	ld	ra,88(sp)
 75a:	6446                	ld	s0,80(sp)
 75c:	6906                	ld	s2,64(sp)
 75e:	6125                	addi	sp,sp,96
 760:	8082                	ret

0000000000000762 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 762:	715d                	addi	sp,sp,-80
 764:	ec06                	sd	ra,24(sp)
 766:	e822                	sd	s0,16(sp)
 768:	1000                	addi	s0,sp,32
 76a:	e010                	sd	a2,0(s0)
 76c:	e414                	sd	a3,8(s0)
 76e:	e818                	sd	a4,16(s0)
 770:	ec1c                	sd	a5,24(s0)
 772:	03043023          	sd	a6,32(s0)
 776:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 77a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 77e:	8622                	mv	a2,s0
 780:	d3fff0ef          	jal	4be <vprintf>
}
 784:	60e2                	ld	ra,24(sp)
 786:	6442                	ld	s0,16(sp)
 788:	6161                	addi	sp,sp,80
 78a:	8082                	ret

000000000000078c <printf>:

void
printf(const char *fmt, ...)
{
 78c:	711d                	addi	sp,sp,-96
 78e:	ec06                	sd	ra,24(sp)
 790:	e822                	sd	s0,16(sp)
 792:	1000                	addi	s0,sp,32
 794:	e40c                	sd	a1,8(s0)
 796:	e810                	sd	a2,16(s0)
 798:	ec14                	sd	a3,24(s0)
 79a:	f018                	sd	a4,32(s0)
 79c:	f41c                	sd	a5,40(s0)
 79e:	03043823          	sd	a6,48(s0)
 7a2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7a6:	00840613          	addi	a2,s0,8
 7aa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ae:	85aa                	mv	a1,a0
 7b0:	4505                	li	a0,1
 7b2:	d0dff0ef          	jal	4be <vprintf>
}
 7b6:	60e2                	ld	ra,24(sp)
 7b8:	6442                	ld	s0,16(sp)
 7ba:	6125                	addi	sp,sp,96
 7bc:	8082                	ret

00000000000007be <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7be:	1141                	addi	sp,sp,-16
 7c0:	e422                	sd	s0,8(sp)
 7c2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c8:	00001797          	auipc	a5,0x1
 7cc:	8387b783          	ld	a5,-1992(a5) # 1000 <freep>
 7d0:	a02d                	j	7fa <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7d2:	4618                	lw	a4,8(a2)
 7d4:	9f2d                	addw	a4,a4,a1
 7d6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7da:	6398                	ld	a4,0(a5)
 7dc:	6310                	ld	a2,0(a4)
 7de:	a83d                	j	81c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e0:	ff852703          	lw	a4,-8(a0)
 7e4:	9f31                	addw	a4,a4,a2
 7e6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7e8:	ff053683          	ld	a3,-16(a0)
 7ec:	a091                	j	830 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ee:	6398                	ld	a4,0(a5)
 7f0:	00e7e463          	bltu	a5,a4,7f8 <free+0x3a>
 7f4:	00e6ea63          	bltu	a3,a4,808 <free+0x4a>
{
 7f8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fa:	fed7fae3          	bgeu	a5,a3,7ee <free+0x30>
 7fe:	6398                	ld	a4,0(a5)
 800:	00e6e463          	bltu	a3,a4,808 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 804:	fee7eae3          	bltu	a5,a4,7f8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 808:	ff852583          	lw	a1,-8(a0)
 80c:	6390                	ld	a2,0(a5)
 80e:	02059813          	slli	a6,a1,0x20
 812:	01c85713          	srli	a4,a6,0x1c
 816:	9736                	add	a4,a4,a3
 818:	fae60de3          	beq	a2,a4,7d2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 81c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 820:	4790                	lw	a2,8(a5)
 822:	02061593          	slli	a1,a2,0x20
 826:	01c5d713          	srli	a4,a1,0x1c
 82a:	973e                	add	a4,a4,a5
 82c:	fae68ae3          	beq	a3,a4,7e0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 830:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 832:	00000717          	auipc	a4,0x0
 836:	7cf73723          	sd	a5,1998(a4) # 1000 <freep>
}
 83a:	6422                	ld	s0,8(sp)
 83c:	0141                	addi	sp,sp,16
 83e:	8082                	ret

0000000000000840 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 840:	7139                	addi	sp,sp,-64
 842:	fc06                	sd	ra,56(sp)
 844:	f822                	sd	s0,48(sp)
 846:	f426                	sd	s1,40(sp)
 848:	ec4e                	sd	s3,24(sp)
 84a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 84c:	02051493          	slli	s1,a0,0x20
 850:	9081                	srli	s1,s1,0x20
 852:	04bd                	addi	s1,s1,15
 854:	8091                	srli	s1,s1,0x4
 856:	0014899b          	addiw	s3,s1,1
 85a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 85c:	00000517          	auipc	a0,0x0
 860:	7a453503          	ld	a0,1956(a0) # 1000 <freep>
 864:	c915                	beqz	a0,898 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 868:	4798                	lw	a4,8(a5)
 86a:	08977a63          	bgeu	a4,s1,8fe <malloc+0xbe>
 86e:	f04a                	sd	s2,32(sp)
 870:	e852                	sd	s4,16(sp)
 872:	e456                	sd	s5,8(sp)
 874:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 876:	8a4e                	mv	s4,s3
 878:	0009871b          	sext.w	a4,s3
 87c:	6685                	lui	a3,0x1
 87e:	00d77363          	bgeu	a4,a3,884 <malloc+0x44>
 882:	6a05                	lui	s4,0x1
 884:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 888:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 88c:	00000917          	auipc	s2,0x0
 890:	77490913          	addi	s2,s2,1908 # 1000 <freep>
  if(p == SBRK_ERROR)
 894:	5afd                	li	s5,-1
 896:	a081                	j	8d6 <malloc+0x96>
 898:	f04a                	sd	s2,32(sp)
 89a:	e852                	sd	s4,16(sp)
 89c:	e456                	sd	s5,8(sp)
 89e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8a0:	00000797          	auipc	a5,0x0
 8a4:	77078793          	addi	a5,a5,1904 # 1010 <base>
 8a8:	00000717          	auipc	a4,0x0
 8ac:	74f73c23          	sd	a5,1880(a4) # 1000 <freep>
 8b0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8b2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8b6:	b7c1                	j	876 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8b8:	6398                	ld	a4,0(a5)
 8ba:	e118                	sd	a4,0(a0)
 8bc:	a8a9                	j	916 <malloc+0xd6>
  hp->s.size = nu;
 8be:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c2:	0541                	addi	a0,a0,16
 8c4:	efbff0ef          	jal	7be <free>
  return freep;
 8c8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8cc:	c12d                	beqz	a0,92e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ce:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d0:	4798                	lw	a4,8(a5)
 8d2:	02977263          	bgeu	a4,s1,8f6 <malloc+0xb6>
    if(p == freep)
 8d6:	00093703          	ld	a4,0(s2)
 8da:	853e                	mv	a0,a5
 8dc:	fef719e3          	bne	a4,a5,8ce <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8e0:	8552                	mv	a0,s4
 8e2:	9cdff0ef          	jal	2ae <sbrk>
  if(p == SBRK_ERROR)
 8e6:	fd551ce3          	bne	a0,s5,8be <malloc+0x7e>
        return 0;
 8ea:	4501                	li	a0,0
 8ec:	7902                	ld	s2,32(sp)
 8ee:	6a42                	ld	s4,16(sp)
 8f0:	6aa2                	ld	s5,8(sp)
 8f2:	6b02                	ld	s6,0(sp)
 8f4:	a03d                	j	922 <malloc+0xe2>
 8f6:	7902                	ld	s2,32(sp)
 8f8:	6a42                	ld	s4,16(sp)
 8fa:	6aa2                	ld	s5,8(sp)
 8fc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8fe:	fae48de3          	beq	s1,a4,8b8 <malloc+0x78>
        p->s.size -= nunits;
 902:	4137073b          	subw	a4,a4,s3
 906:	c798                	sw	a4,8(a5)
        p += p->s.size;
 908:	02071693          	slli	a3,a4,0x20
 90c:	01c6d713          	srli	a4,a3,0x1c
 910:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 912:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 916:	00000717          	auipc	a4,0x0
 91a:	6ea73523          	sd	a0,1770(a4) # 1000 <freep>
      return (void*)(p + 1);
 91e:	01078513          	addi	a0,a5,16
  }
}
 922:	70e2                	ld	ra,56(sp)
 924:	7442                	ld	s0,48(sp)
 926:	74a2                	ld	s1,40(sp)
 928:	69e2                	ld	s3,24(sp)
 92a:	6121                	addi	sp,sp,64
 92c:	8082                	ret
 92e:	7902                	ld	s2,32(sp)
 930:	6a42                	ld	s4,16(sp)
 932:	6aa2                	ld	s5,8(sp)
 934:	6b02                	ld	s6,0(sp)
 936:	b7f5                	j	922 <malloc+0xe2>
