
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	9a250513          	addi	a0,a0,-1630 # 9b0 <malloc+0x102>
  16:	382000ef          	jal	398 <open>
  1a:	04054563          	bltz	a0,64 <main+0x64>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  1e:	4501                	li	a0,0
  20:	3b0000ef          	jal	3d0 <dup>
  dup(0);  // stderr
  24:	4501                	li	a0,0
  26:	3aa000ef          	jal	3d0 <dup>

  for(;;){
    printf("init: starting sh\n");
  2a:	00001917          	auipc	s2,0x1
  2e:	98e90913          	addi	s2,s2,-1650 # 9b8 <malloc+0x10a>
  32:	854a                	mv	a0,s2
  34:	7c6000ef          	jal	7fa <printf>
    pid = fork();
  38:	310000ef          	jal	348 <fork>
  3c:	84aa                	mv	s1,a0
    if(pid < 0){
  3e:	04054363          	bltz	a0,84 <main+0x84>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  42:	c931                	beqz	a0,96 <main+0x96>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  44:	4501                	li	a0,0
  46:	312000ef          	jal	358 <wait>
      if(wpid == pid){
  4a:	fea484e3          	beq	s1,a0,32 <main+0x32>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  4e:	fe055be3          	bgez	a0,44 <main+0x44>
        printf("init: wait returned an error\n");
  52:	00001517          	auipc	a0,0x1
  56:	9b650513          	addi	a0,a0,-1610 # a08 <malloc+0x15a>
  5a:	7a0000ef          	jal	7fa <printf>
        exit(1);
  5e:	4505                	li	a0,1
  60:	2f0000ef          	jal	350 <exit>
    mknod("console", CONSOLE, 0);
  64:	4601                	li	a2,0
  66:	4585                	li	a1,1
  68:	00001517          	auipc	a0,0x1
  6c:	94850513          	addi	a0,a0,-1720 # 9b0 <malloc+0x102>
  70:	330000ef          	jal	3a0 <mknod>
    open("console", O_RDWR);
  74:	4589                	li	a1,2
  76:	00001517          	auipc	a0,0x1
  7a:	93a50513          	addi	a0,a0,-1734 # 9b0 <malloc+0x102>
  7e:	31a000ef          	jal	398 <open>
  82:	bf71                	j	1e <main+0x1e>
      printf("init: fork failed\n");
  84:	00001517          	auipc	a0,0x1
  88:	94c50513          	addi	a0,a0,-1716 # 9d0 <malloc+0x122>
  8c:	76e000ef          	jal	7fa <printf>
      exit(1);
  90:	4505                	li	a0,1
  92:	2be000ef          	jal	350 <exit>
      exec("sh", argv);
  96:	00001597          	auipc	a1,0x1
  9a:	f6a58593          	addi	a1,a1,-150 # 1000 <argv>
  9e:	00001517          	auipc	a0,0x1
  a2:	94a50513          	addi	a0,a0,-1718 # 9e8 <malloc+0x13a>
  a6:	2ea000ef          	jal	390 <exec>
      printf("init: exec sh failed\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	94650513          	addi	a0,a0,-1722 # 9f0 <malloc+0x142>
  b2:	748000ef          	jal	7fa <printf>
      exit(1);
  b6:	4505                	li	a0,1
  b8:	298000ef          	jal	350 <exit>

00000000000000bc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e406                	sd	ra,8(sp)
  c0:	e022                	sd	s0,0(sp)
  c2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  c4:	f3dff0ef          	jal	0 <main>
  exit(r);
  c8:	288000ef          	jal	350 <exit>

00000000000000cc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d2:	87aa                	mv	a5,a0
  d4:	0585                	addi	a1,a1,1
  d6:	0785                	addi	a5,a5,1
  d8:	fff5c703          	lbu	a4,-1(a1)
  dc:	fee78fa3          	sb	a4,-1(a5)
  e0:	fb75                	bnez	a4,d4 <strcpy+0x8>
    ;
  return os;
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret

00000000000000e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cb91                	beqz	a5,106 <strcmp+0x1e>
  f4:	0005c703          	lbu	a4,0(a1)
  f8:	00f71763          	bne	a4,a5,106 <strcmp+0x1e>
    p++, q++;
  fc:	0505                	addi	a0,a0,1
  fe:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 100:	00054783          	lbu	a5,0(a0)
 104:	fbe5                	bnez	a5,f4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 106:	0005c503          	lbu	a0,0(a1)
}
 10a:	40a7853b          	subw	a0,a5,a0
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strlen>:

uint
strlen(const char *s)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cf91                	beqz	a5,13a <strlen+0x26>
 120:	0505                	addi	a0,a0,1
 122:	87aa                	mv	a5,a0
 124:	86be                	mv	a3,a5
 126:	0785                	addi	a5,a5,1
 128:	fff7c703          	lbu	a4,-1(a5)
 12c:	ff65                	bnez	a4,124 <strlen+0x10>
 12e:	40a6853b          	subw	a0,a3,a0
 132:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret
  for(n = 0; s[n]; n++)
 13a:	4501                	li	a0,0
 13c:	bfe5                	j	134 <strlen+0x20>

000000000000013e <memset>:

void*
memset(void *dst, int c, uint n)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 144:	ca19                	beqz	a2,15a <memset+0x1c>
 146:	87aa                	mv	a5,a0
 148:	1602                	slli	a2,a2,0x20
 14a:	9201                	srli	a2,a2,0x20
 14c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 150:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 154:	0785                	addi	a5,a5,1
 156:	fee79de3          	bne	a5,a4,150 <memset+0x12>
  }
  return dst;
}
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strchr>:

char*
strchr(const char *s, char c)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  for(; *s; s++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cb99                	beqz	a5,180 <strchr+0x20>
    if(*s == c)
 16c:	00f58763          	beq	a1,a5,17a <strchr+0x1a>
  for(; *s; s++)
 170:	0505                	addi	a0,a0,1
 172:	00054783          	lbu	a5,0(a0)
 176:	fbfd                	bnez	a5,16c <strchr+0xc>
      return (char*)s;
  return 0;
 178:	4501                	li	a0,0
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  return 0;
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strchr+0x1a>

0000000000000184 <gets>:

char*
gets(char *buf, int max)
{
 184:	711d                	addi	sp,sp,-96
 186:	ec86                	sd	ra,88(sp)
 188:	e8a2                	sd	s0,80(sp)
 18a:	e4a6                	sd	s1,72(sp)
 18c:	e0ca                	sd	s2,64(sp)
 18e:	fc4e                	sd	s3,56(sp)
 190:	f852                	sd	s4,48(sp)
 192:	f456                	sd	s5,40(sp)
 194:	f05a                	sd	s6,32(sp)
 196:	ec5e                	sd	s7,24(sp)
 198:	1080                	addi	s0,sp,96
 19a:	8baa                	mv	s7,a0
 19c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19e:	892a                	mv	s2,a0
 1a0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a2:	4aa9                	li	s5,10
 1a4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1a6:	89a6                	mv	s3,s1
 1a8:	2485                	addiw	s1,s1,1
 1aa:	0344d663          	bge	s1,s4,1d6 <gets+0x52>
    cc = read(0, &c, 1);
 1ae:	4605                	li	a2,1
 1b0:	faf40593          	addi	a1,s0,-81
 1b4:	4501                	li	a0,0
 1b6:	1ba000ef          	jal	370 <read>
    if(cc < 1)
 1ba:	00a05e63          	blez	a0,1d6 <gets+0x52>
    buf[i++] = c;
 1be:	faf44783          	lbu	a5,-81(s0)
 1c2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c6:	01578763          	beq	a5,s5,1d4 <gets+0x50>
 1ca:	0905                	addi	s2,s2,1
 1cc:	fd679de3          	bne	a5,s6,1a6 <gets+0x22>
    buf[i++] = c;
 1d0:	89a6                	mv	s3,s1
 1d2:	a011                	j	1d6 <gets+0x52>
 1d4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d6:	99de                	add	s3,s3,s7
 1d8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1dc:	855e                	mv	a0,s7
 1de:	60e6                	ld	ra,88(sp)
 1e0:	6446                	ld	s0,80(sp)
 1e2:	64a6                	ld	s1,72(sp)
 1e4:	6906                	ld	s2,64(sp)
 1e6:	79e2                	ld	s3,56(sp)
 1e8:	7a42                	ld	s4,48(sp)
 1ea:	7aa2                	ld	s5,40(sp)
 1ec:	7b02                	ld	s6,32(sp)
 1ee:	6be2                	ld	s7,24(sp)
 1f0:	6125                	addi	sp,sp,96
 1f2:	8082                	ret

00000000000001f4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f4:	1101                	addi	sp,sp,-32
 1f6:	ec06                	sd	ra,24(sp)
 1f8:	e822                	sd	s0,16(sp)
 1fa:	e04a                	sd	s2,0(sp)
 1fc:	1000                	addi	s0,sp,32
 1fe:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 200:	4581                	li	a1,0
 202:	196000ef          	jal	398 <open>
  if(fd < 0)
 206:	02054263          	bltz	a0,22a <stat+0x36>
 20a:	e426                	sd	s1,8(sp)
 20c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20e:	85ca                	mv	a1,s2
 210:	1a0000ef          	jal	3b0 <fstat>
 214:	892a                	mv	s2,a0
  close(fd);
 216:	8526                	mv	a0,s1
 218:	168000ef          	jal	380 <close>
  return r;
 21c:	64a2                	ld	s1,8(sp)
}
 21e:	854a                	mv	a0,s2
 220:	60e2                	ld	ra,24(sp)
 222:	6442                	ld	s0,16(sp)
 224:	6902                	ld	s2,0(sp)
 226:	6105                	addi	sp,sp,32
 228:	8082                	ret
    return -1;
 22a:	597d                	li	s2,-1
 22c:	bfcd                	j	21e <stat+0x2a>

000000000000022e <atoi>:

int
atoi(const char *s)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 234:	00054683          	lbu	a3,0(a0)
 238:	fd06879b          	addiw	a5,a3,-48
 23c:	0ff7f793          	zext.b	a5,a5
 240:	4625                	li	a2,9
 242:	02f66863          	bltu	a2,a5,272 <atoi+0x44>
 246:	872a                	mv	a4,a0
  n = 0;
 248:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 24a:	0705                	addi	a4,a4,1
 24c:	0025179b          	slliw	a5,a0,0x2
 250:	9fa9                	addw	a5,a5,a0
 252:	0017979b          	slliw	a5,a5,0x1
 256:	9fb5                	addw	a5,a5,a3
 258:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25c:	00074683          	lbu	a3,0(a4)
 260:	fd06879b          	addiw	a5,a3,-48
 264:	0ff7f793          	zext.b	a5,a5
 268:	fef671e3          	bgeu	a2,a5,24a <atoi+0x1c>
  return n;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  n = 0;
 272:	4501                	li	a0,0
 274:	bfe5                	j	26c <atoi+0x3e>

0000000000000276 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 27c:	02b57463          	bgeu	a0,a1,2a4 <memmove+0x2e>
    while(n-- > 0)
 280:	00c05f63          	blez	a2,29e <memmove+0x28>
 284:	1602                	slli	a2,a2,0x20
 286:	9201                	srli	a2,a2,0x20
 288:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 28c:	872a                	mv	a4,a0
      *dst++ = *src++;
 28e:	0585                	addi	a1,a1,1
 290:	0705                	addi	a4,a4,1
 292:	fff5c683          	lbu	a3,-1(a1)
 296:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29a:	fef71ae3          	bne	a4,a5,28e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
    dst += n;
 2a4:	00c50733          	add	a4,a0,a2
    src += n;
 2a8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2aa:	fec05ae3          	blez	a2,29e <memmove+0x28>
 2ae:	fff6079b          	addiw	a5,a2,-1
 2b2:	1782                	slli	a5,a5,0x20
 2b4:	9381                	srli	a5,a5,0x20
 2b6:	fff7c793          	not	a5,a5
 2ba:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2bc:	15fd                	addi	a1,a1,-1
 2be:	177d                	addi	a4,a4,-1
 2c0:	0005c683          	lbu	a3,0(a1)
 2c4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c8:	fee79ae3          	bne	a5,a4,2bc <memmove+0x46>
 2cc:	bfc9                	j	29e <memmove+0x28>

00000000000002ce <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d4:	ca05                	beqz	a2,304 <memcmp+0x36>
 2d6:	fff6069b          	addiw	a3,a2,-1
 2da:	1682                	slli	a3,a3,0x20
 2dc:	9281                	srli	a3,a3,0x20
 2de:	0685                	addi	a3,a3,1
 2e0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e2:	00054783          	lbu	a5,0(a0)
 2e6:	0005c703          	lbu	a4,0(a1)
 2ea:	00e79863          	bne	a5,a4,2fa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ee:	0505                	addi	a0,a0,1
    p2++;
 2f0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f2:	fed518e3          	bne	a0,a3,2e2 <memcmp+0x14>
  }
  return 0;
 2f6:	4501                	li	a0,0
 2f8:	a019                	j	2fe <memcmp+0x30>
      return *p1 - *p2;
 2fa:	40e7853b          	subw	a0,a5,a4
}
 2fe:	6422                	ld	s0,8(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
  return 0;
 304:	4501                	li	a0,0
 306:	bfe5                	j	2fe <memcmp+0x30>

0000000000000308 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 310:	f67ff0ef          	jal	276 <memmove>
}
 314:	60a2                	ld	ra,8(sp)
 316:	6402                	ld	s0,0(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <sbrk>:

char *
sbrk(int n) {
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 324:	4585                	li	a1,1
 326:	0ba000ef          	jal	3e0 <sys_sbrk>
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret

0000000000000332 <sbrklazy>:

char *
sbrklazy(int n) {
 332:	1141                	addi	sp,sp,-16
 334:	e406                	sd	ra,8(sp)
 336:	e022                	sd	s0,0(sp)
 338:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 33a:	4589                	li	a1,2
 33c:	0a4000ef          	jal	3e0 <sys_sbrk>
}
 340:	60a2                	ld	ra,8(sp)
 342:	6402                	ld	s0,0(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret

0000000000000348 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 348:	4885                	li	a7,1
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <exit>:
.global exit
exit:
 li a7, SYS_exit
 350:	4889                	li	a7,2
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <wait>:
.global wait
wait:
 li a7, SYS_wait
 358:	488d                	li	a7,3
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 360:	48d9                	li	a7,22
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 368:	4891                	li	a7,4
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <read>:
.global read
read:
 li a7, SYS_read
 370:	4895                	li	a7,5
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <write>:
.global write
write:
 li a7, SYS_write
 378:	48c1                	li	a7,16
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <close>:
.global close
close:
 li a7, SYS_close
 380:	48d5                	li	a7,21
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <kill>:
.global kill
kill:
 li a7, SYS_kill
 388:	4899                	li	a7,6
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exec>:
.global exec
exec:
 li a7, SYS_exec
 390:	489d                	li	a7,7
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <open>:
.global open
open:
 li a7, SYS_open
 398:	48bd                	li	a7,15
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a0:	48c5                	li	a7,17
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a8:	48c9                	li	a7,18
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b0:	48a1                	li	a7,8
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <link>:
.global link
link:
 li a7, SYS_link
 3b8:	48cd                	li	a7,19
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c0:	48d1                	li	a7,20
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c8:	48a5                	li	a7,9
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d0:	48a9                	li	a7,10
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d8:	48ad                	li	a7,11
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e0:	48b1                	li	a7,12
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3e8:	48b5                	li	a7,13
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f0:	48b9                	li	a7,14
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3f8:	48dd                	li	a7,23
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 400:	48e1                	li	a7,24
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <mutex_init>:
.global mutex_init
mutex_init:
 li a7, SYS_mutex_init
 408:	48e5                	li	a7,25
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <mutex_acquire>:
.global mutex_acquire
mutex_acquire:
 li a7, SYS_mutex_acquire
 410:	48e9                	li	a7,26
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <mutex_release>:
.global mutex_release
mutex_release:
 li a7, SYS_mutex_release
 418:	48ed                	li	a7,27
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 420:	48f1                	li	a7,28
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 428:	48f5                	li	a7,29
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 430:	48f9                	li	a7,30
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <setp>:
.global setp
setp:
 li a7, SYS_setp
 438:	48fd                	li	a7,31
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <ismyear>:
.global ismyear
ismyear:
 li a7, SYS_ismyear
 440:	02000893          	li	a7,32
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 44a:	02100893          	li	a7,33
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 454:	02200893          	li	a7,34
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <thread_exit>:
.global thread_exit
thread_exit:
 li a7, SYS_thread_exit
 45e:	02300893          	li	a7,35
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <thread_id>:
.global thread_id
thread_id:
 li a7, SYS_thread_id
 468:	02400893          	li	a7,36
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 472:	1101                	addi	sp,sp,-32
 474:	ec06                	sd	ra,24(sp)
 476:	e822                	sd	s0,16(sp)
 478:	1000                	addi	s0,sp,32
 47a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 47e:	4605                	li	a2,1
 480:	fef40593          	addi	a1,s0,-17
 484:	ef5ff0ef          	jal	378 <write>
}
 488:	60e2                	ld	ra,24(sp)
 48a:	6442                	ld	s0,16(sp)
 48c:	6105                	addi	sp,sp,32
 48e:	8082                	ret

0000000000000490 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 490:	715d                	addi	sp,sp,-80
 492:	e486                	sd	ra,72(sp)
 494:	e0a2                	sd	s0,64(sp)
 496:	f84a                	sd	s2,48(sp)
 498:	0880                	addi	s0,sp,80
 49a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 49c:	c299                	beqz	a3,4a2 <printint+0x12>
 49e:	0805c363          	bltz	a1,524 <printint+0x94>
  neg = 0;
 4a2:	4881                	li	a7,0
 4a4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4a8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4aa:	00000517          	auipc	a0,0x0
 4ae:	58650513          	addi	a0,a0,1414 # a30 <digits>
 4b2:	883e                	mv	a6,a5
 4b4:	2785                	addiw	a5,a5,1
 4b6:	02c5f733          	remu	a4,a1,a2
 4ba:	972a                	add	a4,a4,a0
 4bc:	00074703          	lbu	a4,0(a4)
 4c0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4c4:	872e                	mv	a4,a1
 4c6:	02c5d5b3          	divu	a1,a1,a2
 4ca:	0685                	addi	a3,a3,1
 4cc:	fec773e3          	bgeu	a4,a2,4b2 <printint+0x22>
  if(neg)
 4d0:	00088b63          	beqz	a7,4e6 <printint+0x56>
    buf[i++] = '-';
 4d4:	fd078793          	addi	a5,a5,-48
 4d8:	97a2                	add	a5,a5,s0
 4da:	02d00713          	li	a4,45
 4de:	fee78423          	sb	a4,-24(a5)
 4e2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4e6:	02f05a63          	blez	a5,51a <printint+0x8a>
 4ea:	fc26                	sd	s1,56(sp)
 4ec:	f44e                	sd	s3,40(sp)
 4ee:	fb840713          	addi	a4,s0,-72
 4f2:	00f704b3          	add	s1,a4,a5
 4f6:	fff70993          	addi	s3,a4,-1
 4fa:	99be                	add	s3,s3,a5
 4fc:	37fd                	addiw	a5,a5,-1
 4fe:	1782                	slli	a5,a5,0x20
 500:	9381                	srli	a5,a5,0x20
 502:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 506:	fff4c583          	lbu	a1,-1(s1)
 50a:	854a                	mv	a0,s2
 50c:	f67ff0ef          	jal	472 <putc>
  while(--i >= 0)
 510:	14fd                	addi	s1,s1,-1
 512:	ff349ae3          	bne	s1,s3,506 <printint+0x76>
 516:	74e2                	ld	s1,56(sp)
 518:	79a2                	ld	s3,40(sp)
}
 51a:	60a6                	ld	ra,72(sp)
 51c:	6406                	ld	s0,64(sp)
 51e:	7942                	ld	s2,48(sp)
 520:	6161                	addi	sp,sp,80
 522:	8082                	ret
    x = -xx;
 524:	40b005b3          	neg	a1,a1
    neg = 1;
 528:	4885                	li	a7,1
    x = -xx;
 52a:	bfad                	j	4a4 <printint+0x14>

000000000000052c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 52c:	711d                	addi	sp,sp,-96
 52e:	ec86                	sd	ra,88(sp)
 530:	e8a2                	sd	s0,80(sp)
 532:	e0ca                	sd	s2,64(sp)
 534:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 536:	0005c903          	lbu	s2,0(a1)
 53a:	28090663          	beqz	s2,7c6 <vprintf+0x29a>
 53e:	e4a6                	sd	s1,72(sp)
 540:	fc4e                	sd	s3,56(sp)
 542:	f852                	sd	s4,48(sp)
 544:	f456                	sd	s5,40(sp)
 546:	f05a                	sd	s6,32(sp)
 548:	ec5e                	sd	s7,24(sp)
 54a:	e862                	sd	s8,16(sp)
 54c:	e466                	sd	s9,8(sp)
 54e:	8b2a                	mv	s6,a0
 550:	8a2e                	mv	s4,a1
 552:	8bb2                	mv	s7,a2
  state = 0;
 554:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 556:	4481                	li	s1,0
 558:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 55a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 55e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 562:	06c00c93          	li	s9,108
 566:	a005                	j	586 <vprintf+0x5a>
        putc(fd, c0);
 568:	85ca                	mv	a1,s2
 56a:	855a                	mv	a0,s6
 56c:	f07ff0ef          	jal	472 <putc>
 570:	a019                	j	576 <vprintf+0x4a>
    } else if(state == '%'){
 572:	03598263          	beq	s3,s5,596 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 576:	2485                	addiw	s1,s1,1
 578:	8726                	mv	a4,s1
 57a:	009a07b3          	add	a5,s4,s1
 57e:	0007c903          	lbu	s2,0(a5)
 582:	22090a63          	beqz	s2,7b6 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 586:	0009079b          	sext.w	a5,s2
    if(state == 0){
 58a:	fe0994e3          	bnez	s3,572 <vprintf+0x46>
      if(c0 == '%'){
 58e:	fd579de3          	bne	a5,s5,568 <vprintf+0x3c>
        state = '%';
 592:	89be                	mv	s3,a5
 594:	b7cd                	j	576 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 596:	00ea06b3          	add	a3,s4,a4
 59a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 59e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5a0:	c681                	beqz	a3,5a8 <vprintf+0x7c>
 5a2:	9752                	add	a4,a4,s4
 5a4:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5a8:	05878363          	beq	a5,s8,5ee <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5ac:	05978d63          	beq	a5,s9,606 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5b0:	07500713          	li	a4,117
 5b4:	0ee78763          	beq	a5,a4,6a2 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5b8:	07800713          	li	a4,120
 5bc:	12e78963          	beq	a5,a4,6ee <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5c0:	07000713          	li	a4,112
 5c4:	14e78e63          	beq	a5,a4,720 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5c8:	06300713          	li	a4,99
 5cc:	18e78e63          	beq	a5,a4,768 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5d0:	07300713          	li	a4,115
 5d4:	1ae78463          	beq	a5,a4,77c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5d8:	02500713          	li	a4,37
 5dc:	04e79563          	bne	a5,a4,626 <vprintf+0xfa>
        putc(fd, '%');
 5e0:	02500593          	li	a1,37
 5e4:	855a                	mv	a0,s6
 5e6:	e8dff0ef          	jal	472 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b769                	j	576 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	4685                	li	a3,1
 5f4:	4629                	li	a2,10
 5f6:	000ba583          	lw	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	e95ff0ef          	jal	490 <printint>
 600:	8bca                	mv	s7,s2
      state = 0;
 602:	4981                	li	s3,0
 604:	bf8d                	j	576 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 606:	06400793          	li	a5,100
 60a:	02f68963          	beq	a3,a5,63c <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 60e:	06c00793          	li	a5,108
 612:	04f68263          	beq	a3,a5,656 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 616:	07500793          	li	a5,117
 61a:	0af68063          	beq	a3,a5,6ba <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 61e:	07800793          	li	a5,120
 622:	0ef68263          	beq	a3,a5,706 <vprintf+0x1da>
        putc(fd, '%');
 626:	02500593          	li	a1,37
 62a:	855a                	mv	a0,s6
 62c:	e47ff0ef          	jal	472 <putc>
        putc(fd, c0);
 630:	85ca                	mv	a1,s2
 632:	855a                	mv	a0,s6
 634:	e3fff0ef          	jal	472 <putc>
      state = 0;
 638:	4981                	li	s3,0
 63a:	bf35                	j	576 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 63c:	008b8913          	addi	s2,s7,8
 640:	4685                	li	a3,1
 642:	4629                	li	a2,10
 644:	000bb583          	ld	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	e47ff0ef          	jal	490 <printint>
        i += 1;
 64e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 650:	8bca                	mv	s7,s2
      state = 0;
 652:	4981                	li	s3,0
        i += 1;
 654:	b70d                	j	576 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 656:	06400793          	li	a5,100
 65a:	02f60763          	beq	a2,a5,688 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 65e:	07500793          	li	a5,117
 662:	06f60963          	beq	a2,a5,6d4 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 666:	07800793          	li	a5,120
 66a:	faf61ee3          	bne	a2,a5,626 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 66e:	008b8913          	addi	s2,s7,8
 672:	4681                	li	a3,0
 674:	4641                	li	a2,16
 676:	000bb583          	ld	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	e15ff0ef          	jal	490 <printint>
        i += 2;
 680:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 682:	8bca                	mv	s7,s2
      state = 0;
 684:	4981                	li	s3,0
        i += 2;
 686:	bdc5                	j	576 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 688:	008b8913          	addi	s2,s7,8
 68c:	4685                	li	a3,1
 68e:	4629                	li	a2,10
 690:	000bb583          	ld	a1,0(s7)
 694:	855a                	mv	a0,s6
 696:	dfbff0ef          	jal	490 <printint>
        i += 2;
 69a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 69c:	8bca                	mv	s7,s2
      state = 0;
 69e:	4981                	li	s3,0
        i += 2;
 6a0:	bdd9                	j	576 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6a2:	008b8913          	addi	s2,s7,8
 6a6:	4681                	li	a3,0
 6a8:	4629                	li	a2,10
 6aa:	000be583          	lwu	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	de1ff0ef          	jal	490 <printint>
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bd7d                	j	576 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ba:	008b8913          	addi	s2,s7,8
 6be:	4681                	li	a3,0
 6c0:	4629                	li	a2,10
 6c2:	000bb583          	ld	a1,0(s7)
 6c6:	855a                	mv	a0,s6
 6c8:	dc9ff0ef          	jal	490 <printint>
        i += 1;
 6cc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ce:	8bca                	mv	s7,s2
      state = 0;
 6d0:	4981                	li	s3,0
        i += 1;
 6d2:	b555                	j	576 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d4:	008b8913          	addi	s2,s7,8
 6d8:	4681                	li	a3,0
 6da:	4629                	li	a2,10
 6dc:	000bb583          	ld	a1,0(s7)
 6e0:	855a                	mv	a0,s6
 6e2:	dafff0ef          	jal	490 <printint>
        i += 2;
 6e6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e8:	8bca                	mv	s7,s2
      state = 0;
 6ea:	4981                	li	s3,0
        i += 2;
 6ec:	b569                	j	576 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ee:	008b8913          	addi	s2,s7,8
 6f2:	4681                	li	a3,0
 6f4:	4641                	li	a2,16
 6f6:	000be583          	lwu	a1,0(s7)
 6fa:	855a                	mv	a0,s6
 6fc:	d95ff0ef          	jal	490 <printint>
 700:	8bca                	mv	s7,s2
      state = 0;
 702:	4981                	li	s3,0
 704:	bd8d                	j	576 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 706:	008b8913          	addi	s2,s7,8
 70a:	4681                	li	a3,0
 70c:	4641                	li	a2,16
 70e:	000bb583          	ld	a1,0(s7)
 712:	855a                	mv	a0,s6
 714:	d7dff0ef          	jal	490 <printint>
        i += 1;
 718:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 71a:	8bca                	mv	s7,s2
      state = 0;
 71c:	4981                	li	s3,0
        i += 1;
 71e:	bda1                	j	576 <vprintf+0x4a>
 720:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 722:	008b8d13          	addi	s10,s7,8
 726:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 72a:	03000593          	li	a1,48
 72e:	855a                	mv	a0,s6
 730:	d43ff0ef          	jal	472 <putc>
  putc(fd, 'x');
 734:	07800593          	li	a1,120
 738:	855a                	mv	a0,s6
 73a:	d39ff0ef          	jal	472 <putc>
 73e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 740:	00000b97          	auipc	s7,0x0
 744:	2f0b8b93          	addi	s7,s7,752 # a30 <digits>
 748:	03c9d793          	srli	a5,s3,0x3c
 74c:	97de                	add	a5,a5,s7
 74e:	0007c583          	lbu	a1,0(a5)
 752:	855a                	mv	a0,s6
 754:	d1fff0ef          	jal	472 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 758:	0992                	slli	s3,s3,0x4
 75a:	397d                	addiw	s2,s2,-1
 75c:	fe0916e3          	bnez	s2,748 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 760:	8bea                	mv	s7,s10
      state = 0;
 762:	4981                	li	s3,0
 764:	6d02                	ld	s10,0(sp)
 766:	bd01                	j	576 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 768:	008b8913          	addi	s2,s7,8
 76c:	000bc583          	lbu	a1,0(s7)
 770:	855a                	mv	a0,s6
 772:	d01ff0ef          	jal	472 <putc>
 776:	8bca                	mv	s7,s2
      state = 0;
 778:	4981                	li	s3,0
 77a:	bbf5                	j	576 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 77c:	008b8993          	addi	s3,s7,8
 780:	000bb903          	ld	s2,0(s7)
 784:	00090f63          	beqz	s2,7a2 <vprintf+0x276>
        for(; *s; s++)
 788:	00094583          	lbu	a1,0(s2)
 78c:	c195                	beqz	a1,7b0 <vprintf+0x284>
          putc(fd, *s);
 78e:	855a                	mv	a0,s6
 790:	ce3ff0ef          	jal	472 <putc>
        for(; *s; s++)
 794:	0905                	addi	s2,s2,1
 796:	00094583          	lbu	a1,0(s2)
 79a:	f9f5                	bnez	a1,78e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 79c:	8bce                	mv	s7,s3
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	bbd9                	j	576 <vprintf+0x4a>
          s = "(null)";
 7a2:	00000917          	auipc	s2,0x0
 7a6:	28690913          	addi	s2,s2,646 # a28 <malloc+0x17a>
        for(; *s; s++)
 7aa:	02800593          	li	a1,40
 7ae:	b7c5                	j	78e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7b0:	8bce                	mv	s7,s3
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	b3c9                	j	576 <vprintf+0x4a>
 7b6:	64a6                	ld	s1,72(sp)
 7b8:	79e2                	ld	s3,56(sp)
 7ba:	7a42                	ld	s4,48(sp)
 7bc:	7aa2                	ld	s5,40(sp)
 7be:	7b02                	ld	s6,32(sp)
 7c0:	6be2                	ld	s7,24(sp)
 7c2:	6c42                	ld	s8,16(sp)
 7c4:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7c6:	60e6                	ld	ra,88(sp)
 7c8:	6446                	ld	s0,80(sp)
 7ca:	6906                	ld	s2,64(sp)
 7cc:	6125                	addi	sp,sp,96
 7ce:	8082                	ret

00000000000007d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d0:	715d                	addi	sp,sp,-80
 7d2:	ec06                	sd	ra,24(sp)
 7d4:	e822                	sd	s0,16(sp)
 7d6:	1000                	addi	s0,sp,32
 7d8:	e010                	sd	a2,0(s0)
 7da:	e414                	sd	a3,8(s0)
 7dc:	e818                	sd	a4,16(s0)
 7de:	ec1c                	sd	a5,24(s0)
 7e0:	03043023          	sd	a6,32(s0)
 7e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ec:	8622                	mv	a2,s0
 7ee:	d3fff0ef          	jal	52c <vprintf>
}
 7f2:	60e2                	ld	ra,24(sp)
 7f4:	6442                	ld	s0,16(sp)
 7f6:	6161                	addi	sp,sp,80
 7f8:	8082                	ret

00000000000007fa <printf>:

void
printf(const char *fmt, ...)
{
 7fa:	711d                	addi	sp,sp,-96
 7fc:	ec06                	sd	ra,24(sp)
 7fe:	e822                	sd	s0,16(sp)
 800:	1000                	addi	s0,sp,32
 802:	e40c                	sd	a1,8(s0)
 804:	e810                	sd	a2,16(s0)
 806:	ec14                	sd	a3,24(s0)
 808:	f018                	sd	a4,32(s0)
 80a:	f41c                	sd	a5,40(s0)
 80c:	03043823          	sd	a6,48(s0)
 810:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 814:	00840613          	addi	a2,s0,8
 818:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 81c:	85aa                	mv	a1,a0
 81e:	4505                	li	a0,1
 820:	d0dff0ef          	jal	52c <vprintf>
}
 824:	60e2                	ld	ra,24(sp)
 826:	6442                	ld	s0,16(sp)
 828:	6125                	addi	sp,sp,96
 82a:	8082                	ret

000000000000082c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82c:	1141                	addi	sp,sp,-16
 82e:	e422                	sd	s0,8(sp)
 830:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 832:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 836:	00000797          	auipc	a5,0x0
 83a:	7da7b783          	ld	a5,2010(a5) # 1010 <freep>
 83e:	a02d                	j	868 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 840:	4618                	lw	a4,8(a2)
 842:	9f2d                	addw	a4,a4,a1
 844:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 848:	6398                	ld	a4,0(a5)
 84a:	6310                	ld	a2,0(a4)
 84c:	a83d                	j	88a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 84e:	ff852703          	lw	a4,-8(a0)
 852:	9f31                	addw	a4,a4,a2
 854:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 856:	ff053683          	ld	a3,-16(a0)
 85a:	a091                	j	89e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85c:	6398                	ld	a4,0(a5)
 85e:	00e7e463          	bltu	a5,a4,866 <free+0x3a>
 862:	00e6ea63          	bltu	a3,a4,876 <free+0x4a>
{
 866:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 868:	fed7fae3          	bgeu	a5,a3,85c <free+0x30>
 86c:	6398                	ld	a4,0(a5)
 86e:	00e6e463          	bltu	a3,a4,876 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 872:	fee7eae3          	bltu	a5,a4,866 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 876:	ff852583          	lw	a1,-8(a0)
 87a:	6390                	ld	a2,0(a5)
 87c:	02059813          	slli	a6,a1,0x20
 880:	01c85713          	srli	a4,a6,0x1c
 884:	9736                	add	a4,a4,a3
 886:	fae60de3          	beq	a2,a4,840 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 88a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 88e:	4790                	lw	a2,8(a5)
 890:	02061593          	slli	a1,a2,0x20
 894:	01c5d713          	srli	a4,a1,0x1c
 898:	973e                	add	a4,a4,a5
 89a:	fae68ae3          	beq	a3,a4,84e <free+0x22>
    p->s.ptr = bp->s.ptr;
 89e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a0:	00000717          	auipc	a4,0x0
 8a4:	76f73823          	sd	a5,1904(a4) # 1010 <freep>
}
 8a8:	6422                	ld	s0,8(sp)
 8aa:	0141                	addi	sp,sp,16
 8ac:	8082                	ret

00000000000008ae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ae:	7139                	addi	sp,sp,-64
 8b0:	fc06                	sd	ra,56(sp)
 8b2:	f822                	sd	s0,48(sp)
 8b4:	f426                	sd	s1,40(sp)
 8b6:	ec4e                	sd	s3,24(sp)
 8b8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ba:	02051493          	slli	s1,a0,0x20
 8be:	9081                	srli	s1,s1,0x20
 8c0:	04bd                	addi	s1,s1,15
 8c2:	8091                	srli	s1,s1,0x4
 8c4:	0014899b          	addiw	s3,s1,1
 8c8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ca:	00000517          	auipc	a0,0x0
 8ce:	74653503          	ld	a0,1862(a0) # 1010 <freep>
 8d2:	c915                	beqz	a0,906 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d6:	4798                	lw	a4,8(a5)
 8d8:	08977a63          	bgeu	a4,s1,96c <malloc+0xbe>
 8dc:	f04a                	sd	s2,32(sp)
 8de:	e852                	sd	s4,16(sp)
 8e0:	e456                	sd	s5,8(sp)
 8e2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8e4:	8a4e                	mv	s4,s3
 8e6:	0009871b          	sext.w	a4,s3
 8ea:	6685                	lui	a3,0x1
 8ec:	00d77363          	bgeu	a4,a3,8f2 <malloc+0x44>
 8f0:	6a05                	lui	s4,0x1
 8f2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8fa:	00000917          	auipc	s2,0x0
 8fe:	71690913          	addi	s2,s2,1814 # 1010 <freep>
  if(p == SBRK_ERROR)
 902:	5afd                	li	s5,-1
 904:	a081                	j	944 <malloc+0x96>
 906:	f04a                	sd	s2,32(sp)
 908:	e852                	sd	s4,16(sp)
 90a:	e456                	sd	s5,8(sp)
 90c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 90e:	00000797          	auipc	a5,0x0
 912:	71278793          	addi	a5,a5,1810 # 1020 <base>
 916:	00000717          	auipc	a4,0x0
 91a:	6ef73d23          	sd	a5,1786(a4) # 1010 <freep>
 91e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 920:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 924:	b7c1                	j	8e4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 926:	6398                	ld	a4,0(a5)
 928:	e118                	sd	a4,0(a0)
 92a:	a8a9                	j	984 <malloc+0xd6>
  hp->s.size = nu;
 92c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 930:	0541                	addi	a0,a0,16
 932:	efbff0ef          	jal	82c <free>
  return freep;
 936:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 93a:	c12d                	beqz	a0,99c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 93e:	4798                	lw	a4,8(a5)
 940:	02977263          	bgeu	a4,s1,964 <malloc+0xb6>
    if(p == freep)
 944:	00093703          	ld	a4,0(s2)
 948:	853e                	mv	a0,a5
 94a:	fef719e3          	bne	a4,a5,93c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 94e:	8552                	mv	a0,s4
 950:	9cdff0ef          	jal	31c <sbrk>
  if(p == SBRK_ERROR)
 954:	fd551ce3          	bne	a0,s5,92c <malloc+0x7e>
        return 0;
 958:	4501                	li	a0,0
 95a:	7902                	ld	s2,32(sp)
 95c:	6a42                	ld	s4,16(sp)
 95e:	6aa2                	ld	s5,8(sp)
 960:	6b02                	ld	s6,0(sp)
 962:	a03d                	j	990 <malloc+0xe2>
 964:	7902                	ld	s2,32(sp)
 966:	6a42                	ld	s4,16(sp)
 968:	6aa2                	ld	s5,8(sp)
 96a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 96c:	fae48de3          	beq	s1,a4,926 <malloc+0x78>
        p->s.size -= nunits;
 970:	4137073b          	subw	a4,a4,s3
 974:	c798                	sw	a4,8(a5)
        p += p->s.size;
 976:	02071693          	slli	a3,a4,0x20
 97a:	01c6d713          	srli	a4,a3,0x1c
 97e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 980:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 984:	00000717          	auipc	a4,0x0
 988:	68a73623          	sd	a0,1676(a4) # 1010 <freep>
      return (void*)(p + 1);
 98c:	01078513          	addi	a0,a5,16
  }
}
 990:	70e2                	ld	ra,56(sp)
 992:	7442                	ld	s0,48(sp)
 994:	74a2                	ld	s1,40(sp)
 996:	69e2                	ld	s3,24(sp)
 998:	6121                	addi	sp,sp,64
 99a:	8082                	ret
 99c:	7902                	ld	s2,32(sp)
 99e:	6a42                	ld	s4,16(sp)
 9a0:	6aa2                	ld	s5,8(sp)
 9a2:	6b02                	ld	s6,0(sp)
 9a4:	b7f5                	j	990 <malloc+0xe2>
