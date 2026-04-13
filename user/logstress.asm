
user/_logstress:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
main(int argc, char **argv)
{
  int fd, n;
  enum { N = 250, SZ=2000 };
  
  for (int i = 1; i < argc; i++){
   0:	4785                	li	a5,1
   2:	0ea7df63          	bge	a5,a0,100 <main+0x100>
{
   6:	7139                	addi	sp,sp,-64
   8:	fc06                	sd	ra,56(sp)
   a:	f822                	sd	s0,48(sp)
   c:	f426                	sd	s1,40(sp)
   e:	f04a                	sd	s2,32(sp)
  10:	ec4e                	sd	s3,24(sp)
  12:	0080                	addi	s0,sp,64
  14:	892a                	mv	s2,a0
  16:	89ae                	mv	s3,a1
  for (int i = 1; i < argc; i++){
  18:	4485                	li	s1,1
  1a:	a011                	j	1e <main+0x1e>
  1c:	84be                	mv	s1,a5
    int pid1 = fork();
  1e:	372000ef          	jal	390 <fork>
    if(pid1 < 0){
  22:	00054963          	bltz	a0,34 <main+0x34>
      printf("%s: fork failed\n", argv[0]);
      exit(1);
    }
    if(pid1 == 0) {
  26:	c11d                	beqz	a0,4c <main+0x4c>
  for (int i = 1; i < argc; i++){
  28:	0014879b          	addiw	a5,s1,1
  2c:	fef918e3          	bne	s2,a5,1c <main+0x1c>
      }
      exit(0);
    }
  }
  int xstatus;
  for(int i = 1; i < argc; i++){
  30:	4905                	li	s2,1
  32:	a04d                	j	d4 <main+0xd4>
  34:	e852                	sd	s4,16(sp)
      printf("%s: fork failed\n", argv[0]);
  36:	0009b583          	ld	a1,0(s3)
  3a:	00001517          	auipc	a0,0x1
  3e:	9b650513          	addi	a0,a0,-1610 # 9f0 <malloc+0xfa>
  42:	001000ef          	jal	842 <printf>
      exit(1);
  46:	4505                	li	a0,1
  48:	350000ef          	jal	398 <exit>
  4c:	e852                	sd	s4,16(sp)
      fd = open(argv[i], O_CREATE | O_RDWR);
  4e:	00349a13          	slli	s4,s1,0x3
  52:	9a4e                	add	s4,s4,s3
  54:	20200593          	li	a1,514
  58:	000a3503          	ld	a0,0(s4)
  5c:	384000ef          	jal	3e0 <open>
  60:	892a                	mv	s2,a0
      if(fd < 0){
  62:	04054163          	bltz	a0,a4 <main+0xa4>
      memset(buf, '0'+i, SZ);
  66:	7d000613          	li	a2,2000
  6a:	0304859b          	addiw	a1,s1,48
  6e:	00001517          	auipc	a0,0x1
  72:	fa250513          	addi	a0,a0,-94 # 1010 <buf>
  76:	110000ef          	jal	186 <memset>
  7a:	0fa00493          	li	s1,250
        if((n = write(fd, buf, SZ)) != SZ){
  7e:	00001997          	auipc	s3,0x1
  82:	f9298993          	addi	s3,s3,-110 # 1010 <buf>
  86:	7d000613          	li	a2,2000
  8a:	85ce                	mv	a1,s3
  8c:	854a                	mv	a0,s2
  8e:	332000ef          	jal	3c0 <write>
  92:	7d000793          	li	a5,2000
  96:	02f51463          	bne	a0,a5,be <main+0xbe>
      for(i = 0; i < N; i++){
  9a:	34fd                	addiw	s1,s1,-1
  9c:	f4ed                	bnez	s1,86 <main+0x86>
      exit(0);
  9e:	4501                	li	a0,0
  a0:	2f8000ef          	jal	398 <exit>
        printf("%s: create %s failed\n", argv[0], argv[i]);
  a4:	000a3603          	ld	a2,0(s4)
  a8:	0009b583          	ld	a1,0(s3)
  ac:	00001517          	auipc	a0,0x1
  b0:	95c50513          	addi	a0,a0,-1700 # a08 <malloc+0x112>
  b4:	78e000ef          	jal	842 <printf>
        exit(1);
  b8:	4505                	li	a0,1
  ba:	2de000ef          	jal	398 <exit>
          printf("write failed %d\n", n);
  be:	85aa                	mv	a1,a0
  c0:	00001517          	auipc	a0,0x1
  c4:	96050513          	addi	a0,a0,-1696 # a20 <malloc+0x12a>
  c8:	77a000ef          	jal	842 <printf>
          exit(1);
  cc:	4505                	li	a0,1
  ce:	2ca000ef          	jal	398 <exit>
  d2:	893e                	mv	s2,a5
    wait(&xstatus);
  d4:	fcc40513          	addi	a0,s0,-52
  d8:	2c8000ef          	jal	3a0 <wait>
    if(xstatus != 0)
  dc:	fcc42503          	lw	a0,-52(s0)
  e0:	ed09                	bnez	a0,fa <main+0xfa>
  for(int i = 1; i < argc; i++){
  e2:	0019079b          	addiw	a5,s2,1
  e6:	ff2496e3          	bne	s1,s2,d2 <main+0xd2>
      exit(xstatus);
  }
  return 0;
}
  ea:	4501                	li	a0,0
  ec:	70e2                	ld	ra,56(sp)
  ee:	7442                	ld	s0,48(sp)
  f0:	74a2                	ld	s1,40(sp)
  f2:	7902                	ld	s2,32(sp)
  f4:	69e2                	ld	s3,24(sp)
  f6:	6121                	addi	sp,sp,64
  f8:	8082                	ret
  fa:	e852                	sd	s4,16(sp)
      exit(xstatus);
  fc:	29c000ef          	jal	398 <exit>
}
 100:	4501                	li	a0,0
 102:	8082                	ret

0000000000000104 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 104:	1141                	addi	sp,sp,-16
 106:	e406                	sd	ra,8(sp)
 108:	e022                	sd	s0,0(sp)
 10a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 10c:	ef5ff0ef          	jal	0 <main>
  exit(r);
 110:	288000ef          	jal	398 <exit>

0000000000000114 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11a:	87aa                	mv	a5,a0
 11c:	0585                	addi	a1,a1,1
 11e:	0785                	addi	a5,a5,1
 120:	fff5c703          	lbu	a4,-1(a1)
 124:	fee78fa3          	sb	a4,-1(a5)
 128:	fb75                	bnez	a4,11c <strcpy+0x8>
    ;
  return os;
}
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret

0000000000000130 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 130:	1141                	addi	sp,sp,-16
 132:	e422                	sd	s0,8(sp)
 134:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 136:	00054783          	lbu	a5,0(a0)
 13a:	cb91                	beqz	a5,14e <strcmp+0x1e>
 13c:	0005c703          	lbu	a4,0(a1)
 140:	00f71763          	bne	a4,a5,14e <strcmp+0x1e>
    p++, q++;
 144:	0505                	addi	a0,a0,1
 146:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 148:	00054783          	lbu	a5,0(a0)
 14c:	fbe5                	bnez	a5,13c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 14e:	0005c503          	lbu	a0,0(a1)
}
 152:	40a7853b          	subw	a0,a5,a0
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret

000000000000015c <strlen>:

uint
strlen(const char *s)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e422                	sd	s0,8(sp)
 160:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 162:	00054783          	lbu	a5,0(a0)
 166:	cf91                	beqz	a5,182 <strlen+0x26>
 168:	0505                	addi	a0,a0,1
 16a:	87aa                	mv	a5,a0
 16c:	86be                	mv	a3,a5
 16e:	0785                	addi	a5,a5,1
 170:	fff7c703          	lbu	a4,-1(a5)
 174:	ff65                	bnez	a4,16c <strlen+0x10>
 176:	40a6853b          	subw	a0,a3,a0
 17a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret
  for(n = 0; s[n]; n++)
 182:	4501                	li	a0,0
 184:	bfe5                	j	17c <strlen+0x20>

0000000000000186 <memset>:

void*
memset(void *dst, int c, uint n)
{
 186:	1141                	addi	sp,sp,-16
 188:	e422                	sd	s0,8(sp)
 18a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18c:	ca19                	beqz	a2,1a2 <memset+0x1c>
 18e:	87aa                	mv	a5,a0
 190:	1602                	slli	a2,a2,0x20
 192:	9201                	srli	a2,a2,0x20
 194:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 198:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19c:	0785                	addi	a5,a5,1
 19e:	fee79de3          	bne	a5,a4,198 <memset+0x12>
  }
  return dst;
}
 1a2:	6422                	ld	s0,8(sp)
 1a4:	0141                	addi	sp,sp,16
 1a6:	8082                	ret

00000000000001a8 <strchr>:

char*
strchr(const char *s, char c)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	cb99                	beqz	a5,1c8 <strchr+0x20>
    if(*s == c)
 1b4:	00f58763          	beq	a1,a5,1c2 <strchr+0x1a>
  for(; *s; s++)
 1b8:	0505                	addi	a0,a0,1
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	fbfd                	bnez	a5,1b4 <strchr+0xc>
      return (char*)s;
  return 0;
 1c0:	4501                	li	a0,0
}
 1c2:	6422                	ld	s0,8(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret
  return 0;
 1c8:	4501                	li	a0,0
 1ca:	bfe5                	j	1c2 <strchr+0x1a>

00000000000001cc <gets>:

char*
gets(char *buf, int max)
{
 1cc:	711d                	addi	sp,sp,-96
 1ce:	ec86                	sd	ra,88(sp)
 1d0:	e8a2                	sd	s0,80(sp)
 1d2:	e4a6                	sd	s1,72(sp)
 1d4:	e0ca                	sd	s2,64(sp)
 1d6:	fc4e                	sd	s3,56(sp)
 1d8:	f852                	sd	s4,48(sp)
 1da:	f456                	sd	s5,40(sp)
 1dc:	f05a                	sd	s6,32(sp)
 1de:	ec5e                	sd	s7,24(sp)
 1e0:	1080                	addi	s0,sp,96
 1e2:	8baa                	mv	s7,a0
 1e4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e6:	892a                	mv	s2,a0
 1e8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ea:	4aa9                	li	s5,10
 1ec:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ee:	89a6                	mv	s3,s1
 1f0:	2485                	addiw	s1,s1,1
 1f2:	0344d663          	bge	s1,s4,21e <gets+0x52>
    cc = read(0, &c, 1);
 1f6:	4605                	li	a2,1
 1f8:	faf40593          	addi	a1,s0,-81
 1fc:	4501                	li	a0,0
 1fe:	1ba000ef          	jal	3b8 <read>
    if(cc < 1)
 202:	00a05e63          	blez	a0,21e <gets+0x52>
    buf[i++] = c;
 206:	faf44783          	lbu	a5,-81(s0)
 20a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20e:	01578763          	beq	a5,s5,21c <gets+0x50>
 212:	0905                	addi	s2,s2,1
 214:	fd679de3          	bne	a5,s6,1ee <gets+0x22>
    buf[i++] = c;
 218:	89a6                	mv	s3,s1
 21a:	a011                	j	21e <gets+0x52>
 21c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 21e:	99de                	add	s3,s3,s7
 220:	00098023          	sb	zero,0(s3)
  return buf;
}
 224:	855e                	mv	a0,s7
 226:	60e6                	ld	ra,88(sp)
 228:	6446                	ld	s0,80(sp)
 22a:	64a6                	ld	s1,72(sp)
 22c:	6906                	ld	s2,64(sp)
 22e:	79e2                	ld	s3,56(sp)
 230:	7a42                	ld	s4,48(sp)
 232:	7aa2                	ld	s5,40(sp)
 234:	7b02                	ld	s6,32(sp)
 236:	6be2                	ld	s7,24(sp)
 238:	6125                	addi	sp,sp,96
 23a:	8082                	ret

000000000000023c <stat>:

int
stat(const char *n, struct stat *st)
{
 23c:	1101                	addi	sp,sp,-32
 23e:	ec06                	sd	ra,24(sp)
 240:	e822                	sd	s0,16(sp)
 242:	e04a                	sd	s2,0(sp)
 244:	1000                	addi	s0,sp,32
 246:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 248:	4581                	li	a1,0
 24a:	196000ef          	jal	3e0 <open>
  if(fd < 0)
 24e:	02054263          	bltz	a0,272 <stat+0x36>
 252:	e426                	sd	s1,8(sp)
 254:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 256:	85ca                	mv	a1,s2
 258:	1a0000ef          	jal	3f8 <fstat>
 25c:	892a                	mv	s2,a0
  close(fd);
 25e:	8526                	mv	a0,s1
 260:	168000ef          	jal	3c8 <close>
  return r;
 264:	64a2                	ld	s1,8(sp)
}
 266:	854a                	mv	a0,s2
 268:	60e2                	ld	ra,24(sp)
 26a:	6442                	ld	s0,16(sp)
 26c:	6902                	ld	s2,0(sp)
 26e:	6105                	addi	sp,sp,32
 270:	8082                	ret
    return -1;
 272:	597d                	li	s2,-1
 274:	bfcd                	j	266 <stat+0x2a>

0000000000000276 <atoi>:

int
atoi(const char *s)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 27c:	00054683          	lbu	a3,0(a0)
 280:	fd06879b          	addiw	a5,a3,-48
 284:	0ff7f793          	zext.b	a5,a5
 288:	4625                	li	a2,9
 28a:	02f66863          	bltu	a2,a5,2ba <atoi+0x44>
 28e:	872a                	mv	a4,a0
  n = 0;
 290:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 292:	0705                	addi	a4,a4,1
 294:	0025179b          	slliw	a5,a0,0x2
 298:	9fa9                	addw	a5,a5,a0
 29a:	0017979b          	slliw	a5,a5,0x1
 29e:	9fb5                	addw	a5,a5,a3
 2a0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a4:	00074683          	lbu	a3,0(a4)
 2a8:	fd06879b          	addiw	a5,a3,-48
 2ac:	0ff7f793          	zext.b	a5,a5
 2b0:	fef671e3          	bgeu	a2,a5,292 <atoi+0x1c>
  return n;
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret
  n = 0;
 2ba:	4501                	li	a0,0
 2bc:	bfe5                	j	2b4 <atoi+0x3e>

00000000000002be <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c4:	02b57463          	bgeu	a0,a1,2ec <memmove+0x2e>
    while(n-- > 0)
 2c8:	00c05f63          	blez	a2,2e6 <memmove+0x28>
 2cc:	1602                	slli	a2,a2,0x20
 2ce:	9201                	srli	a2,a2,0x20
 2d0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d6:	0585                	addi	a1,a1,1
 2d8:	0705                	addi	a4,a4,1
 2da:	fff5c683          	lbu	a3,-1(a1)
 2de:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e2:	fef71ae3          	bne	a4,a5,2d6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
    dst += n;
 2ec:	00c50733          	add	a4,a0,a2
    src += n;
 2f0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2f2:	fec05ae3          	blez	a2,2e6 <memmove+0x28>
 2f6:	fff6079b          	addiw	a5,a2,-1
 2fa:	1782                	slli	a5,a5,0x20
 2fc:	9381                	srli	a5,a5,0x20
 2fe:	fff7c793          	not	a5,a5
 302:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 304:	15fd                	addi	a1,a1,-1
 306:	177d                	addi	a4,a4,-1
 308:	0005c683          	lbu	a3,0(a1)
 30c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 310:	fee79ae3          	bne	a5,a4,304 <memmove+0x46>
 314:	bfc9                	j	2e6 <memmove+0x28>

0000000000000316 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 31c:	ca05                	beqz	a2,34c <memcmp+0x36>
 31e:	fff6069b          	addiw	a3,a2,-1
 322:	1682                	slli	a3,a3,0x20
 324:	9281                	srli	a3,a3,0x20
 326:	0685                	addi	a3,a3,1
 328:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 32a:	00054783          	lbu	a5,0(a0)
 32e:	0005c703          	lbu	a4,0(a1)
 332:	00e79863          	bne	a5,a4,342 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 336:	0505                	addi	a0,a0,1
    p2++;
 338:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 33a:	fed518e3          	bne	a0,a3,32a <memcmp+0x14>
  }
  return 0;
 33e:	4501                	li	a0,0
 340:	a019                	j	346 <memcmp+0x30>
      return *p1 - *p2;
 342:	40e7853b          	subw	a0,a5,a4
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret
  return 0;
 34c:	4501                	li	a0,0
 34e:	bfe5                	j	346 <memcmp+0x30>

0000000000000350 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 350:	1141                	addi	sp,sp,-16
 352:	e406                	sd	ra,8(sp)
 354:	e022                	sd	s0,0(sp)
 356:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 358:	f67ff0ef          	jal	2be <memmove>
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret

0000000000000364 <sbrk>:

char *
sbrk(int n) {
 364:	1141                	addi	sp,sp,-16
 366:	e406                	sd	ra,8(sp)
 368:	e022                	sd	s0,0(sp)
 36a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 36c:	4585                	li	a1,1
 36e:	0ba000ef          	jal	428 <sys_sbrk>
}
 372:	60a2                	ld	ra,8(sp)
 374:	6402                	ld	s0,0(sp)
 376:	0141                	addi	sp,sp,16
 378:	8082                	ret

000000000000037a <sbrklazy>:

char *
sbrklazy(int n) {
 37a:	1141                	addi	sp,sp,-16
 37c:	e406                	sd	ra,8(sp)
 37e:	e022                	sd	s0,0(sp)
 380:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 382:	4589                	li	a1,2
 384:	0a4000ef          	jal	428 <sys_sbrk>
}
 388:	60a2                	ld	ra,8(sp)
 38a:	6402                	ld	s0,0(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret

0000000000000390 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 390:	4885                	li	a7,1
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <exit>:
.global exit
exit:
 li a7, SYS_exit
 398:	4889                	li	a7,2
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a0:	488d                	li	a7,3
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3a8:	48d9                	li	a7,22
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b0:	4891                	li	a7,4
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <read>:
.global read
read:
 li a7, SYS_read
 3b8:	4895                	li	a7,5
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <write>:
.global write
write:
 li a7, SYS_write
 3c0:	48c1                	li	a7,16
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <close>:
.global close
close:
 li a7, SYS_close
 3c8:	48d5                	li	a7,21
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d0:	4899                	li	a7,6
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d8:	489d                	li	a7,7
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <open>:
.global open
open:
 li a7, SYS_open
 3e0:	48bd                	li	a7,15
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e8:	48c5                	li	a7,17
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f0:	48c9                	li	a7,18
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f8:	48a1                	li	a7,8
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <link>:
.global link
link:
 li a7, SYS_link
 400:	48cd                	li	a7,19
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 408:	48d1                	li	a7,20
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 410:	48a5                	li	a7,9
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <dup>:
.global dup
dup:
 li a7, SYS_dup
 418:	48a9                	li	a7,10
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 420:	48ad                	li	a7,11
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 428:	48b1                	li	a7,12
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <pause>:
.global pause
pause:
 li a7, SYS_pause
 430:	48b5                	li	a7,13
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 438:	48b9                	li	a7,14
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 440:	48dd                	li	a7,23
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 448:	48e1                	li	a7,24
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <mutex_init>:
.global mutex_init
mutex_init:
 li a7, SYS_mutex_init
 450:	48e5                	li	a7,25
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <mutex_acquire>:
.global mutex_acquire
mutex_acquire:
 li a7, SYS_mutex_acquire
 458:	48e9                	li	a7,26
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <mutex_release>:
.global mutex_release
mutex_release:
 li a7, SYS_mutex_release
 460:	48ed                	li	a7,27
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 468:	48f1                	li	a7,28
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 470:	48f5                	li	a7,29
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 478:	48f9                	li	a7,30
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <setp>:
.global setp
setp:
 li a7, SYS_setp
 480:	48fd                	li	a7,31
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <ismyear>:
.global ismyear
ismyear:
 li a7, SYS_ismyear
 488:	02000893          	li	a7,32
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 492:	02100893          	li	a7,33
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 49c:	02200893          	li	a7,34
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <thread_exit>:
.global thread_exit
thread_exit:
 li a7, SYS_thread_exit
 4a6:	02300893          	li	a7,35
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <thread_id>:
.global thread_id
thread_id:
 li a7, SYS_thread_id
 4b0:	02400893          	li	a7,36
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ba:	1101                	addi	sp,sp,-32
 4bc:	ec06                	sd	ra,24(sp)
 4be:	e822                	sd	s0,16(sp)
 4c0:	1000                	addi	s0,sp,32
 4c2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c6:	4605                	li	a2,1
 4c8:	fef40593          	addi	a1,s0,-17
 4cc:	ef5ff0ef          	jal	3c0 <write>
}
 4d0:	60e2                	ld	ra,24(sp)
 4d2:	6442                	ld	s0,16(sp)
 4d4:	6105                	addi	sp,sp,32
 4d6:	8082                	ret

00000000000004d8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4d8:	715d                	addi	sp,sp,-80
 4da:	e486                	sd	ra,72(sp)
 4dc:	e0a2                	sd	s0,64(sp)
 4de:	f84a                	sd	s2,48(sp)
 4e0:	0880                	addi	s0,sp,80
 4e2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4e4:	c299                	beqz	a3,4ea <printint+0x12>
 4e6:	0805c363          	bltz	a1,56c <printint+0x94>
  neg = 0;
 4ea:	4881                	li	a7,0
 4ec:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4f0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4f2:	00000517          	auipc	a0,0x0
 4f6:	54e50513          	addi	a0,a0,1358 # a40 <digits>
 4fa:	883e                	mv	a6,a5
 4fc:	2785                	addiw	a5,a5,1
 4fe:	02c5f733          	remu	a4,a1,a2
 502:	972a                	add	a4,a4,a0
 504:	00074703          	lbu	a4,0(a4)
 508:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 50c:	872e                	mv	a4,a1
 50e:	02c5d5b3          	divu	a1,a1,a2
 512:	0685                	addi	a3,a3,1
 514:	fec773e3          	bgeu	a4,a2,4fa <printint+0x22>
  if(neg)
 518:	00088b63          	beqz	a7,52e <printint+0x56>
    buf[i++] = '-';
 51c:	fd078793          	addi	a5,a5,-48
 520:	97a2                	add	a5,a5,s0
 522:	02d00713          	li	a4,45
 526:	fee78423          	sb	a4,-24(a5)
 52a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 52e:	02f05a63          	blez	a5,562 <printint+0x8a>
 532:	fc26                	sd	s1,56(sp)
 534:	f44e                	sd	s3,40(sp)
 536:	fb840713          	addi	a4,s0,-72
 53a:	00f704b3          	add	s1,a4,a5
 53e:	fff70993          	addi	s3,a4,-1
 542:	99be                	add	s3,s3,a5
 544:	37fd                	addiw	a5,a5,-1
 546:	1782                	slli	a5,a5,0x20
 548:	9381                	srli	a5,a5,0x20
 54a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 54e:	fff4c583          	lbu	a1,-1(s1)
 552:	854a                	mv	a0,s2
 554:	f67ff0ef          	jal	4ba <putc>
  while(--i >= 0)
 558:	14fd                	addi	s1,s1,-1
 55a:	ff349ae3          	bne	s1,s3,54e <printint+0x76>
 55e:	74e2                	ld	s1,56(sp)
 560:	79a2                	ld	s3,40(sp)
}
 562:	60a6                	ld	ra,72(sp)
 564:	6406                	ld	s0,64(sp)
 566:	7942                	ld	s2,48(sp)
 568:	6161                	addi	sp,sp,80
 56a:	8082                	ret
    x = -xx;
 56c:	40b005b3          	neg	a1,a1
    neg = 1;
 570:	4885                	li	a7,1
    x = -xx;
 572:	bfad                	j	4ec <printint+0x14>

0000000000000574 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 574:	711d                	addi	sp,sp,-96
 576:	ec86                	sd	ra,88(sp)
 578:	e8a2                	sd	s0,80(sp)
 57a:	e0ca                	sd	s2,64(sp)
 57c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 57e:	0005c903          	lbu	s2,0(a1)
 582:	28090663          	beqz	s2,80e <vprintf+0x29a>
 586:	e4a6                	sd	s1,72(sp)
 588:	fc4e                	sd	s3,56(sp)
 58a:	f852                	sd	s4,48(sp)
 58c:	f456                	sd	s5,40(sp)
 58e:	f05a                	sd	s6,32(sp)
 590:	ec5e                	sd	s7,24(sp)
 592:	e862                	sd	s8,16(sp)
 594:	e466                	sd	s9,8(sp)
 596:	8b2a                	mv	s6,a0
 598:	8a2e                	mv	s4,a1
 59a:	8bb2                	mv	s7,a2
  state = 0;
 59c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 59e:	4481                	li	s1,0
 5a0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5a2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5a6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5aa:	06c00c93          	li	s9,108
 5ae:	a005                	j	5ce <vprintf+0x5a>
        putc(fd, c0);
 5b0:	85ca                	mv	a1,s2
 5b2:	855a                	mv	a0,s6
 5b4:	f07ff0ef          	jal	4ba <putc>
 5b8:	a019                	j	5be <vprintf+0x4a>
    } else if(state == '%'){
 5ba:	03598263          	beq	s3,s5,5de <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5be:	2485                	addiw	s1,s1,1
 5c0:	8726                	mv	a4,s1
 5c2:	009a07b3          	add	a5,s4,s1
 5c6:	0007c903          	lbu	s2,0(a5)
 5ca:	22090a63          	beqz	s2,7fe <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5ce:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5d2:	fe0994e3          	bnez	s3,5ba <vprintf+0x46>
      if(c0 == '%'){
 5d6:	fd579de3          	bne	a5,s5,5b0 <vprintf+0x3c>
        state = '%';
 5da:	89be                	mv	s3,a5
 5dc:	b7cd                	j	5be <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5de:	00ea06b3          	add	a3,s4,a4
 5e2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5e6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5e8:	c681                	beqz	a3,5f0 <vprintf+0x7c>
 5ea:	9752                	add	a4,a4,s4
 5ec:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5f0:	05878363          	beq	a5,s8,636 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5f4:	05978d63          	beq	a5,s9,64e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5f8:	07500713          	li	a4,117
 5fc:	0ee78763          	beq	a5,a4,6ea <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 600:	07800713          	li	a4,120
 604:	12e78963          	beq	a5,a4,736 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 608:	07000713          	li	a4,112
 60c:	14e78e63          	beq	a5,a4,768 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 610:	06300713          	li	a4,99
 614:	18e78e63          	beq	a5,a4,7b0 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 618:	07300713          	li	a4,115
 61c:	1ae78463          	beq	a5,a4,7c4 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 620:	02500713          	li	a4,37
 624:	04e79563          	bne	a5,a4,66e <vprintf+0xfa>
        putc(fd, '%');
 628:	02500593          	li	a1,37
 62c:	855a                	mv	a0,s6
 62e:	e8dff0ef          	jal	4ba <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 632:	4981                	li	s3,0
 634:	b769                	j	5be <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 636:	008b8913          	addi	s2,s7,8
 63a:	4685                	li	a3,1
 63c:	4629                	li	a2,10
 63e:	000ba583          	lw	a1,0(s7)
 642:	855a                	mv	a0,s6
 644:	e95ff0ef          	jal	4d8 <printint>
 648:	8bca                	mv	s7,s2
      state = 0;
 64a:	4981                	li	s3,0
 64c:	bf8d                	j	5be <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 64e:	06400793          	li	a5,100
 652:	02f68963          	beq	a3,a5,684 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 656:	06c00793          	li	a5,108
 65a:	04f68263          	beq	a3,a5,69e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 65e:	07500793          	li	a5,117
 662:	0af68063          	beq	a3,a5,702 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 666:	07800793          	li	a5,120
 66a:	0ef68263          	beq	a3,a5,74e <vprintf+0x1da>
        putc(fd, '%');
 66e:	02500593          	li	a1,37
 672:	855a                	mv	a0,s6
 674:	e47ff0ef          	jal	4ba <putc>
        putc(fd, c0);
 678:	85ca                	mv	a1,s2
 67a:	855a                	mv	a0,s6
 67c:	e3fff0ef          	jal	4ba <putc>
      state = 0;
 680:	4981                	li	s3,0
 682:	bf35                	j	5be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 684:	008b8913          	addi	s2,s7,8
 688:	4685                	li	a3,1
 68a:	4629                	li	a2,10
 68c:	000bb583          	ld	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	e47ff0ef          	jal	4d8 <printint>
        i += 1;
 696:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
        i += 1;
 69c:	b70d                	j	5be <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 69e:	06400793          	li	a5,100
 6a2:	02f60763          	beq	a2,a5,6d0 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6a6:	07500793          	li	a5,117
 6aa:	06f60963          	beq	a2,a5,71c <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6ae:	07800793          	li	a5,120
 6b2:	faf61ee3          	bne	a2,a5,66e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b6:	008b8913          	addi	s2,s7,8
 6ba:	4681                	li	a3,0
 6bc:	4641                	li	a2,16
 6be:	000bb583          	ld	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	e15ff0ef          	jal	4d8 <printint>
        i += 2;
 6c8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ca:	8bca                	mv	s7,s2
      state = 0;
 6cc:	4981                	li	s3,0
        i += 2;
 6ce:	bdc5                	j	5be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d0:	008b8913          	addi	s2,s7,8
 6d4:	4685                	li	a3,1
 6d6:	4629                	li	a2,10
 6d8:	000bb583          	ld	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	dfbff0ef          	jal	4d8 <printint>
        i += 2;
 6e2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e4:	8bca                	mv	s7,s2
      state = 0;
 6e6:	4981                	li	s3,0
        i += 2;
 6e8:	bdd9                	j	5be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6ea:	008b8913          	addi	s2,s7,8
 6ee:	4681                	li	a3,0
 6f0:	4629                	li	a2,10
 6f2:	000be583          	lwu	a1,0(s7)
 6f6:	855a                	mv	a0,s6
 6f8:	de1ff0ef          	jal	4d8 <printint>
 6fc:	8bca                	mv	s7,s2
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bd7d                	j	5be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 702:	008b8913          	addi	s2,s7,8
 706:	4681                	li	a3,0
 708:	4629                	li	a2,10
 70a:	000bb583          	ld	a1,0(s7)
 70e:	855a                	mv	a0,s6
 710:	dc9ff0ef          	jal	4d8 <printint>
        i += 1;
 714:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 716:	8bca                	mv	s7,s2
      state = 0;
 718:	4981                	li	s3,0
        i += 1;
 71a:	b555                	j	5be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 71c:	008b8913          	addi	s2,s7,8
 720:	4681                	li	a3,0
 722:	4629                	li	a2,10
 724:	000bb583          	ld	a1,0(s7)
 728:	855a                	mv	a0,s6
 72a:	dafff0ef          	jal	4d8 <printint>
        i += 2;
 72e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 730:	8bca                	mv	s7,s2
      state = 0;
 732:	4981                	li	s3,0
        i += 2;
 734:	b569                	j	5be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 736:	008b8913          	addi	s2,s7,8
 73a:	4681                	li	a3,0
 73c:	4641                	li	a2,16
 73e:	000be583          	lwu	a1,0(s7)
 742:	855a                	mv	a0,s6
 744:	d95ff0ef          	jal	4d8 <printint>
 748:	8bca                	mv	s7,s2
      state = 0;
 74a:	4981                	li	s3,0
 74c:	bd8d                	j	5be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 74e:	008b8913          	addi	s2,s7,8
 752:	4681                	li	a3,0
 754:	4641                	li	a2,16
 756:	000bb583          	ld	a1,0(s7)
 75a:	855a                	mv	a0,s6
 75c:	d7dff0ef          	jal	4d8 <printint>
        i += 1;
 760:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 762:	8bca                	mv	s7,s2
      state = 0;
 764:	4981                	li	s3,0
        i += 1;
 766:	bda1                	j	5be <vprintf+0x4a>
 768:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 76a:	008b8d13          	addi	s10,s7,8
 76e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 772:	03000593          	li	a1,48
 776:	855a                	mv	a0,s6
 778:	d43ff0ef          	jal	4ba <putc>
  putc(fd, 'x');
 77c:	07800593          	li	a1,120
 780:	855a                	mv	a0,s6
 782:	d39ff0ef          	jal	4ba <putc>
 786:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 788:	00000b97          	auipc	s7,0x0
 78c:	2b8b8b93          	addi	s7,s7,696 # a40 <digits>
 790:	03c9d793          	srli	a5,s3,0x3c
 794:	97de                	add	a5,a5,s7
 796:	0007c583          	lbu	a1,0(a5)
 79a:	855a                	mv	a0,s6
 79c:	d1fff0ef          	jal	4ba <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7a0:	0992                	slli	s3,s3,0x4
 7a2:	397d                	addiw	s2,s2,-1
 7a4:	fe0916e3          	bnez	s2,790 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7a8:	8bea                	mv	s7,s10
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	6d02                	ld	s10,0(sp)
 7ae:	bd01                	j	5be <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7b0:	008b8913          	addi	s2,s7,8
 7b4:	000bc583          	lbu	a1,0(s7)
 7b8:	855a                	mv	a0,s6
 7ba:	d01ff0ef          	jal	4ba <putc>
 7be:	8bca                	mv	s7,s2
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	bbf5                	j	5be <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7c4:	008b8993          	addi	s3,s7,8
 7c8:	000bb903          	ld	s2,0(s7)
 7cc:	00090f63          	beqz	s2,7ea <vprintf+0x276>
        for(; *s; s++)
 7d0:	00094583          	lbu	a1,0(s2)
 7d4:	c195                	beqz	a1,7f8 <vprintf+0x284>
          putc(fd, *s);
 7d6:	855a                	mv	a0,s6
 7d8:	ce3ff0ef          	jal	4ba <putc>
        for(; *s; s++)
 7dc:	0905                	addi	s2,s2,1
 7de:	00094583          	lbu	a1,0(s2)
 7e2:	f9f5                	bnez	a1,7d6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7e4:	8bce                	mv	s7,s3
      state = 0;
 7e6:	4981                	li	s3,0
 7e8:	bbd9                	j	5be <vprintf+0x4a>
          s = "(null)";
 7ea:	00000917          	auipc	s2,0x0
 7ee:	24e90913          	addi	s2,s2,590 # a38 <malloc+0x142>
        for(; *s; s++)
 7f2:	02800593          	li	a1,40
 7f6:	b7c5                	j	7d6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7f8:	8bce                	mv	s7,s3
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	b3c9                	j	5be <vprintf+0x4a>
 7fe:	64a6                	ld	s1,72(sp)
 800:	79e2                	ld	s3,56(sp)
 802:	7a42                	ld	s4,48(sp)
 804:	7aa2                	ld	s5,40(sp)
 806:	7b02                	ld	s6,32(sp)
 808:	6be2                	ld	s7,24(sp)
 80a:	6c42                	ld	s8,16(sp)
 80c:	6ca2                	ld	s9,8(sp)
    }
  }
}
 80e:	60e6                	ld	ra,88(sp)
 810:	6446                	ld	s0,80(sp)
 812:	6906                	ld	s2,64(sp)
 814:	6125                	addi	sp,sp,96
 816:	8082                	ret

0000000000000818 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 818:	715d                	addi	sp,sp,-80
 81a:	ec06                	sd	ra,24(sp)
 81c:	e822                	sd	s0,16(sp)
 81e:	1000                	addi	s0,sp,32
 820:	e010                	sd	a2,0(s0)
 822:	e414                	sd	a3,8(s0)
 824:	e818                	sd	a4,16(s0)
 826:	ec1c                	sd	a5,24(s0)
 828:	03043023          	sd	a6,32(s0)
 82c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 830:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 834:	8622                	mv	a2,s0
 836:	d3fff0ef          	jal	574 <vprintf>
}
 83a:	60e2                	ld	ra,24(sp)
 83c:	6442                	ld	s0,16(sp)
 83e:	6161                	addi	sp,sp,80
 840:	8082                	ret

0000000000000842 <printf>:

void
printf(const char *fmt, ...)
{
 842:	711d                	addi	sp,sp,-96
 844:	ec06                	sd	ra,24(sp)
 846:	e822                	sd	s0,16(sp)
 848:	1000                	addi	s0,sp,32
 84a:	e40c                	sd	a1,8(s0)
 84c:	e810                	sd	a2,16(s0)
 84e:	ec14                	sd	a3,24(s0)
 850:	f018                	sd	a4,32(s0)
 852:	f41c                	sd	a5,40(s0)
 854:	03043823          	sd	a6,48(s0)
 858:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 85c:	00840613          	addi	a2,s0,8
 860:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 864:	85aa                	mv	a1,a0
 866:	4505                	li	a0,1
 868:	d0dff0ef          	jal	574 <vprintf>
}
 86c:	60e2                	ld	ra,24(sp)
 86e:	6442                	ld	s0,16(sp)
 870:	6125                	addi	sp,sp,96
 872:	8082                	ret

0000000000000874 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 874:	1141                	addi	sp,sp,-16
 876:	e422                	sd	s0,8(sp)
 878:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87e:	00000797          	auipc	a5,0x0
 882:	7827b783          	ld	a5,1922(a5) # 1000 <freep>
 886:	a02d                	j	8b0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 888:	4618                	lw	a4,8(a2)
 88a:	9f2d                	addw	a4,a4,a1
 88c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 890:	6398                	ld	a4,0(a5)
 892:	6310                	ld	a2,0(a4)
 894:	a83d                	j	8d2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 896:	ff852703          	lw	a4,-8(a0)
 89a:	9f31                	addw	a4,a4,a2
 89c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 89e:	ff053683          	ld	a3,-16(a0)
 8a2:	a091                	j	8e6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a4:	6398                	ld	a4,0(a5)
 8a6:	00e7e463          	bltu	a5,a4,8ae <free+0x3a>
 8aa:	00e6ea63          	bltu	a3,a4,8be <free+0x4a>
{
 8ae:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b0:	fed7fae3          	bgeu	a5,a3,8a4 <free+0x30>
 8b4:	6398                	ld	a4,0(a5)
 8b6:	00e6e463          	bltu	a3,a4,8be <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ba:	fee7eae3          	bltu	a5,a4,8ae <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8be:	ff852583          	lw	a1,-8(a0)
 8c2:	6390                	ld	a2,0(a5)
 8c4:	02059813          	slli	a6,a1,0x20
 8c8:	01c85713          	srli	a4,a6,0x1c
 8cc:	9736                	add	a4,a4,a3
 8ce:	fae60de3          	beq	a2,a4,888 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8d2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8d6:	4790                	lw	a2,8(a5)
 8d8:	02061593          	slli	a1,a2,0x20
 8dc:	01c5d713          	srli	a4,a1,0x1c
 8e0:	973e                	add	a4,a4,a5
 8e2:	fae68ae3          	beq	a3,a4,896 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8e6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8e8:	00000717          	auipc	a4,0x0
 8ec:	70f73c23          	sd	a5,1816(a4) # 1000 <freep>
}
 8f0:	6422                	ld	s0,8(sp)
 8f2:	0141                	addi	sp,sp,16
 8f4:	8082                	ret

00000000000008f6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8f6:	7139                	addi	sp,sp,-64
 8f8:	fc06                	sd	ra,56(sp)
 8fa:	f822                	sd	s0,48(sp)
 8fc:	f426                	sd	s1,40(sp)
 8fe:	ec4e                	sd	s3,24(sp)
 900:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 902:	02051493          	slli	s1,a0,0x20
 906:	9081                	srli	s1,s1,0x20
 908:	04bd                	addi	s1,s1,15
 90a:	8091                	srli	s1,s1,0x4
 90c:	0014899b          	addiw	s3,s1,1
 910:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 912:	00000517          	auipc	a0,0x0
 916:	6ee53503          	ld	a0,1774(a0) # 1000 <freep>
 91a:	c915                	beqz	a0,94e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 91e:	4798                	lw	a4,8(a5)
 920:	08977a63          	bgeu	a4,s1,9b4 <malloc+0xbe>
 924:	f04a                	sd	s2,32(sp)
 926:	e852                	sd	s4,16(sp)
 928:	e456                	sd	s5,8(sp)
 92a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 92c:	8a4e                	mv	s4,s3
 92e:	0009871b          	sext.w	a4,s3
 932:	6685                	lui	a3,0x1
 934:	00d77363          	bgeu	a4,a3,93a <malloc+0x44>
 938:	6a05                	lui	s4,0x1
 93a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 93e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 942:	00000917          	auipc	s2,0x0
 946:	6be90913          	addi	s2,s2,1726 # 1000 <freep>
  if(p == SBRK_ERROR)
 94a:	5afd                	li	s5,-1
 94c:	a081                	j	98c <malloc+0x96>
 94e:	f04a                	sd	s2,32(sp)
 950:	e852                	sd	s4,16(sp)
 952:	e456                	sd	s5,8(sp)
 954:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 956:	00001797          	auipc	a5,0x1
 95a:	8b278793          	addi	a5,a5,-1870 # 1208 <base>
 95e:	00000717          	auipc	a4,0x0
 962:	6af73123          	sd	a5,1698(a4) # 1000 <freep>
 966:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 968:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 96c:	b7c1                	j	92c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 96e:	6398                	ld	a4,0(a5)
 970:	e118                	sd	a4,0(a0)
 972:	a8a9                	j	9cc <malloc+0xd6>
  hp->s.size = nu;
 974:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 978:	0541                	addi	a0,a0,16
 97a:	efbff0ef          	jal	874 <free>
  return freep;
 97e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 982:	c12d                	beqz	a0,9e4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 984:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 986:	4798                	lw	a4,8(a5)
 988:	02977263          	bgeu	a4,s1,9ac <malloc+0xb6>
    if(p == freep)
 98c:	00093703          	ld	a4,0(s2)
 990:	853e                	mv	a0,a5
 992:	fef719e3          	bne	a4,a5,984 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 996:	8552                	mv	a0,s4
 998:	9cdff0ef          	jal	364 <sbrk>
  if(p == SBRK_ERROR)
 99c:	fd551ce3          	bne	a0,s5,974 <malloc+0x7e>
        return 0;
 9a0:	4501                	li	a0,0
 9a2:	7902                	ld	s2,32(sp)
 9a4:	6a42                	ld	s4,16(sp)
 9a6:	6aa2                	ld	s5,8(sp)
 9a8:	6b02                	ld	s6,0(sp)
 9aa:	a03d                	j	9d8 <malloc+0xe2>
 9ac:	7902                	ld	s2,32(sp)
 9ae:	6a42                	ld	s4,16(sp)
 9b0:	6aa2                	ld	s5,8(sp)
 9b2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9b4:	fae48de3          	beq	s1,a4,96e <malloc+0x78>
        p->s.size -= nunits;
 9b8:	4137073b          	subw	a4,a4,s3
 9bc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9be:	02071693          	slli	a3,a4,0x20
 9c2:	01c6d713          	srli	a4,a3,0x1c
 9c6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9c8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9cc:	00000717          	auipc	a4,0x0
 9d0:	62a73a23          	sd	a0,1588(a4) # 1000 <freep>
      return (void*)(p + 1);
 9d4:	01078513          	addi	a0,a5,16
  }
}
 9d8:	70e2                	ld	ra,56(sp)
 9da:	7442                	ld	s0,48(sp)
 9dc:	74a2                	ld	s1,40(sp)
 9de:	69e2                	ld	s3,24(sp)
 9e0:	6121                	addi	sp,sp,64
 9e2:	8082                	ret
 9e4:	7902                	ld	s2,32(sp)
 9e6:	6a42                	ld	s4,16(sp)
 9e8:	6aa2                	ld	s5,8(sp)
 9ea:	6b02                	ld	s6,0(sp)
 9ec:	b7f5                	j	9d8 <malloc+0xe2>
