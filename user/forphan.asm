
user/_forphan:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char buf[BUFSZ];

int
main(int argc, char **argv)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
  int fd = 0;
  char *s = argv[0];
   a:	6184                	ld	s1,0(a1)
  struct stat st;
  char *ff = "file0";
  
  if ((fd = open(ff, O_CREATE|O_WRONLY)) < 0) {
   c:	20100593          	li	a1,513
  10:	00001517          	auipc	a0,0x1
  14:	9a050513          	addi	a0,a0,-1632 # 9b0 <malloc+0xfa>
  18:	388000ef          	jal	3a0 <open>
  1c:	04054463          	bltz	a0,64 <main+0x64>
    printf("%s: open failed\n", s);
    exit(1);
  }
  if(fstat(fd, &st) < 0){
  20:	fc840593          	addi	a1,s0,-56
  24:	394000ef          	jal	3b8 <fstat>
  28:	04054863          	bltz	a0,78 <main+0x78>
    fprintf(2, "%s: cannot stat %s\n", s, "ff");
    exit(1);
  }
  if (unlink(ff) < 0) {
  2c:	00001517          	auipc	a0,0x1
  30:	98450513          	addi	a0,a0,-1660 # 9b0 <malloc+0xfa>
  34:	37c000ef          	jal	3b0 <unlink>
  38:	04054f63          	bltz	a0,96 <main+0x96>
    printf("%s: unlink failed\n", s);
    exit(1);
  }
  if (open(ff, O_RDONLY) != -1) {
  3c:	4581                	li	a1,0
  3e:	00001517          	auipc	a0,0x1
  42:	97250513          	addi	a0,a0,-1678 # 9b0 <malloc+0xfa>
  46:	35a000ef          	jal	3a0 <open>
  4a:	57fd                	li	a5,-1
  4c:	04f50f63          	beq	a0,a5,aa <main+0xaa>
    printf("%s: open successed\n", s);
  50:	85a6                	mv	a1,s1
  52:	00001517          	auipc	a0,0x1
  56:	9be50513          	addi	a0,a0,-1602 # a10 <malloc+0x15a>
  5a:	7a8000ef          	jal	802 <printf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	2f8000ef          	jal	358 <exit>
    printf("%s: open failed\n", s);
  64:	85a6                	mv	a1,s1
  66:	00001517          	auipc	a0,0x1
  6a:	95a50513          	addi	a0,a0,-1702 # 9c0 <malloc+0x10a>
  6e:	794000ef          	jal	802 <printf>
    exit(1);
  72:	4505                	li	a0,1
  74:	2e4000ef          	jal	358 <exit>
    fprintf(2, "%s: cannot stat %s\n", s, "ff");
  78:	00001697          	auipc	a3,0x1
  7c:	96068693          	addi	a3,a3,-1696 # 9d8 <malloc+0x122>
  80:	8626                	mv	a2,s1
  82:	00001597          	auipc	a1,0x1
  86:	95e58593          	addi	a1,a1,-1698 # 9e0 <malloc+0x12a>
  8a:	4509                	li	a0,2
  8c:	74c000ef          	jal	7d8 <fprintf>
    exit(1);
  90:	4505                	li	a0,1
  92:	2c6000ef          	jal	358 <exit>
    printf("%s: unlink failed\n", s);
  96:	85a6                	mv	a1,s1
  98:	00001517          	auipc	a0,0x1
  9c:	96050513          	addi	a0,a0,-1696 # 9f8 <malloc+0x142>
  a0:	762000ef          	jal	802 <printf>
    exit(1);
  a4:	4505                	li	a0,1
  a6:	2b2000ef          	jal	358 <exit>
  }
  printf("wait for kill and reclaim %d\n", st.ino);
  aa:	fcc42583          	lw	a1,-52(s0)
  ae:	00001517          	auipc	a0,0x1
  b2:	97a50513          	addi	a0,a0,-1670 # a28 <malloc+0x172>
  b6:	74c000ef          	jal	802 <printf>
  // sit around until killed
  for(;;) pause(1000);
  ba:	3e800513          	li	a0,1000
  be:	332000ef          	jal	3f0 <pause>
  c2:	bfe5                	j	ba <main+0xba>

00000000000000c4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e406                	sd	ra,8(sp)
  c8:	e022                	sd	s0,0(sp)
  ca:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  cc:	f35ff0ef          	jal	0 <main>
  exit(r);
  d0:	288000ef          	jal	358 <exit>

00000000000000d4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  da:	87aa                	mv	a5,a0
  dc:	0585                	addi	a1,a1,1
  de:	0785                	addi	a5,a5,1
  e0:	fff5c703          	lbu	a4,-1(a1)
  e4:	fee78fa3          	sb	a4,-1(a5)
  e8:	fb75                	bnez	a4,dc <strcpy+0x8>
    ;
  return os;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cb91                	beqz	a5,10e <strcmp+0x1e>
  fc:	0005c703          	lbu	a4,0(a1)
 100:	00f71763          	bne	a4,a5,10e <strcmp+0x1e>
    p++, q++;
 104:	0505                	addi	a0,a0,1
 106:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbe5                	bnez	a5,fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10e:	0005c503          	lbu	a0,0(a1)
}
 112:	40a7853b          	subw	a0,a5,a0
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strlen>:

uint
strlen(const char *s)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cf91                	beqz	a5,142 <strlen+0x26>
 128:	0505                	addi	a0,a0,1
 12a:	87aa                	mv	a5,a0
 12c:	86be                	mv	a3,a5
 12e:	0785                	addi	a5,a5,1
 130:	fff7c703          	lbu	a4,-1(a5)
 134:	ff65                	bnez	a4,12c <strlen+0x10>
 136:	40a6853b          	subw	a0,a3,a0
 13a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret
  for(n = 0; s[n]; n++)
 142:	4501                	li	a0,0
 144:	bfe5                	j	13c <strlen+0x20>

0000000000000146 <memset>:

void*
memset(void *dst, int c, uint n)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14c:	ca19                	beqz	a2,162 <memset+0x1c>
 14e:	87aa                	mv	a5,a0
 150:	1602                	slli	a2,a2,0x20
 152:	9201                	srli	a2,a2,0x20
 154:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 158:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15c:	0785                	addi	a5,a5,1
 15e:	fee79de3          	bne	a5,a4,158 <memset+0x12>
  }
  return dst;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strchr>:

char*
strchr(const char *s, char c)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb99                	beqz	a5,188 <strchr+0x20>
    if(*s == c)
 174:	00f58763          	beq	a1,a5,182 <strchr+0x1a>
  for(; *s; s++)
 178:	0505                	addi	a0,a0,1
 17a:	00054783          	lbu	a5,0(a0)
 17e:	fbfd                	bnez	a5,174 <strchr+0xc>
      return (char*)s;
  return 0;
 180:	4501                	li	a0,0
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret
  return 0;
 188:	4501                	li	a0,0
 18a:	bfe5                	j	182 <strchr+0x1a>

000000000000018c <gets>:

char*
gets(char *buf, int max)
{
 18c:	711d                	addi	sp,sp,-96
 18e:	ec86                	sd	ra,88(sp)
 190:	e8a2                	sd	s0,80(sp)
 192:	e4a6                	sd	s1,72(sp)
 194:	e0ca                	sd	s2,64(sp)
 196:	fc4e                	sd	s3,56(sp)
 198:	f852                	sd	s4,48(sp)
 19a:	f456                	sd	s5,40(sp)
 19c:	f05a                	sd	s6,32(sp)
 19e:	ec5e                	sd	s7,24(sp)
 1a0:	1080                	addi	s0,sp,96
 1a2:	8baa                	mv	s7,a0
 1a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a6:	892a                	mv	s2,a0
 1a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1aa:	4aa9                	li	s5,10
 1ac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ae:	89a6                	mv	s3,s1
 1b0:	2485                	addiw	s1,s1,1
 1b2:	0344d663          	bge	s1,s4,1de <gets+0x52>
    cc = read(0, &c, 1);
 1b6:	4605                	li	a2,1
 1b8:	faf40593          	addi	a1,s0,-81
 1bc:	4501                	li	a0,0
 1be:	1ba000ef          	jal	378 <read>
    if(cc < 1)
 1c2:	00a05e63          	blez	a0,1de <gets+0x52>
    buf[i++] = c;
 1c6:	faf44783          	lbu	a5,-81(s0)
 1ca:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ce:	01578763          	beq	a5,s5,1dc <gets+0x50>
 1d2:	0905                	addi	s2,s2,1
 1d4:	fd679de3          	bne	a5,s6,1ae <gets+0x22>
    buf[i++] = c;
 1d8:	89a6                	mv	s3,s1
 1da:	a011                	j	1de <gets+0x52>
 1dc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1de:	99de                	add	s3,s3,s7
 1e0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e4:	855e                	mv	a0,s7
 1e6:	60e6                	ld	ra,88(sp)
 1e8:	6446                	ld	s0,80(sp)
 1ea:	64a6                	ld	s1,72(sp)
 1ec:	6906                	ld	s2,64(sp)
 1ee:	79e2                	ld	s3,56(sp)
 1f0:	7a42                	ld	s4,48(sp)
 1f2:	7aa2                	ld	s5,40(sp)
 1f4:	7b02                	ld	s6,32(sp)
 1f6:	6be2                	ld	s7,24(sp)
 1f8:	6125                	addi	sp,sp,96
 1fa:	8082                	ret

00000000000001fc <stat>:

int
stat(const char *n, struct stat *st)
{
 1fc:	1101                	addi	sp,sp,-32
 1fe:	ec06                	sd	ra,24(sp)
 200:	e822                	sd	s0,16(sp)
 202:	e04a                	sd	s2,0(sp)
 204:	1000                	addi	s0,sp,32
 206:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 208:	4581                	li	a1,0
 20a:	196000ef          	jal	3a0 <open>
  if(fd < 0)
 20e:	02054263          	bltz	a0,232 <stat+0x36>
 212:	e426                	sd	s1,8(sp)
 214:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 216:	85ca                	mv	a1,s2
 218:	1a0000ef          	jal	3b8 <fstat>
 21c:	892a                	mv	s2,a0
  close(fd);
 21e:	8526                	mv	a0,s1
 220:	168000ef          	jal	388 <close>
  return r;
 224:	64a2                	ld	s1,8(sp)
}
 226:	854a                	mv	a0,s2
 228:	60e2                	ld	ra,24(sp)
 22a:	6442                	ld	s0,16(sp)
 22c:	6902                	ld	s2,0(sp)
 22e:	6105                	addi	sp,sp,32
 230:	8082                	ret
    return -1;
 232:	597d                	li	s2,-1
 234:	bfcd                	j	226 <stat+0x2a>

0000000000000236 <atoi>:

int
atoi(const char *s)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23c:	00054683          	lbu	a3,0(a0)
 240:	fd06879b          	addiw	a5,a3,-48
 244:	0ff7f793          	zext.b	a5,a5
 248:	4625                	li	a2,9
 24a:	02f66863          	bltu	a2,a5,27a <atoi+0x44>
 24e:	872a                	mv	a4,a0
  n = 0;
 250:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 252:	0705                	addi	a4,a4,1
 254:	0025179b          	slliw	a5,a0,0x2
 258:	9fa9                	addw	a5,a5,a0
 25a:	0017979b          	slliw	a5,a5,0x1
 25e:	9fb5                	addw	a5,a5,a3
 260:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 264:	00074683          	lbu	a3,0(a4)
 268:	fd06879b          	addiw	a5,a3,-48
 26c:	0ff7f793          	zext.b	a5,a5
 270:	fef671e3          	bgeu	a2,a5,252 <atoi+0x1c>
  return n;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
  n = 0;
 27a:	4501                	li	a0,0
 27c:	bfe5                	j	274 <atoi+0x3e>

000000000000027e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e422                	sd	s0,8(sp)
 282:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 284:	02b57463          	bgeu	a0,a1,2ac <memmove+0x2e>
    while(n-- > 0)
 288:	00c05f63          	blez	a2,2a6 <memmove+0x28>
 28c:	1602                	slli	a2,a2,0x20
 28e:	9201                	srli	a2,a2,0x20
 290:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 294:	872a                	mv	a4,a0
      *dst++ = *src++;
 296:	0585                	addi	a1,a1,1
 298:	0705                	addi	a4,a4,1
 29a:	fff5c683          	lbu	a3,-1(a1)
 29e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a2:	fef71ae3          	bne	a4,a5,296 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
    dst += n;
 2ac:	00c50733          	add	a4,a0,a2
    src += n;
 2b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b2:	fec05ae3          	blez	a2,2a6 <memmove+0x28>
 2b6:	fff6079b          	addiw	a5,a2,-1
 2ba:	1782                	slli	a5,a5,0x20
 2bc:	9381                	srli	a5,a5,0x20
 2be:	fff7c793          	not	a5,a5
 2c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c4:	15fd                	addi	a1,a1,-1
 2c6:	177d                	addi	a4,a4,-1
 2c8:	0005c683          	lbu	a3,0(a1)
 2cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d0:	fee79ae3          	bne	a5,a4,2c4 <memmove+0x46>
 2d4:	bfc9                	j	2a6 <memmove+0x28>

00000000000002d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2dc:	ca05                	beqz	a2,30c <memcmp+0x36>
 2de:	fff6069b          	addiw	a3,a2,-1
 2e2:	1682                	slli	a3,a3,0x20
 2e4:	9281                	srli	a3,a3,0x20
 2e6:	0685                	addi	a3,a3,1
 2e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ea:	00054783          	lbu	a5,0(a0)
 2ee:	0005c703          	lbu	a4,0(a1)
 2f2:	00e79863          	bne	a5,a4,302 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f6:	0505                	addi	a0,a0,1
    p2++;
 2f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fa:	fed518e3          	bne	a0,a3,2ea <memcmp+0x14>
  }
  return 0;
 2fe:	4501                	li	a0,0
 300:	a019                	j	306 <memcmp+0x30>
      return *p1 - *p2;
 302:	40e7853b          	subw	a0,a5,a4
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  return 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <memcmp+0x30>

0000000000000310 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 318:	f67ff0ef          	jal	27e <memmove>
}
 31c:	60a2                	ld	ra,8(sp)
 31e:	6402                	ld	s0,0(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <sbrk>:

char *
sbrk(int n) {
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 32c:	4585                	li	a1,1
 32e:	0ba000ef          	jal	3e8 <sys_sbrk>
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <sbrklazy>:

char *
sbrklazy(int n) {
 33a:	1141                	addi	sp,sp,-16
 33c:	e406                	sd	ra,8(sp)
 33e:	e022                	sd	s0,0(sp)
 340:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 342:	4589                	li	a1,2
 344:	0a4000ef          	jal	3e8 <sys_sbrk>
}
 348:	60a2                	ld	ra,8(sp)
 34a:	6402                	ld	s0,0(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret

0000000000000350 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 350:	4885                	li	a7,1
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exit>:
.global exit
exit:
 li a7, SYS_exit
 358:	4889                	li	a7,2
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <wait>:
.global wait
wait:
 li a7, SYS_wait
 360:	488d                	li	a7,3
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 368:	48d9                	li	a7,22
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 370:	4891                	li	a7,4
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <read>:
.global read
read:
 li a7, SYS_read
 378:	4895                	li	a7,5
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <write>:
.global write
write:
 li a7, SYS_write
 380:	48c1                	li	a7,16
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <close>:
.global close
close:
 li a7, SYS_close
 388:	48d5                	li	a7,21
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <kill>:
.global kill
kill:
 li a7, SYS_kill
 390:	4899                	li	a7,6
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <exec>:
.global exec
exec:
 li a7, SYS_exec
 398:	489d                	li	a7,7
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <open>:
.global open
open:
 li a7, SYS_open
 3a0:	48bd                	li	a7,15
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a8:	48c5                	li	a7,17
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b0:	48c9                	li	a7,18
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b8:	48a1                	li	a7,8
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <link>:
.global link
link:
 li a7, SYS_link
 3c0:	48cd                	li	a7,19
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c8:	48d1                	li	a7,20
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d0:	48a5                	li	a7,9
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d8:	48a9                	li	a7,10
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e0:	48ad                	li	a7,11
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e8:	48b1                	li	a7,12
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3f0:	48b5                	li	a7,13
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f8:	48b9                	li	a7,14
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 400:	48dd                	li	a7,23
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 408:	48e1                	li	a7,24
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <mutex_init>:
.global mutex_init
mutex_init:
 li a7, SYS_mutex_init
 410:	48e5                	li	a7,25
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <mutex_acquire>:
.global mutex_acquire
mutex_acquire:
 li a7, SYS_mutex_acquire
 418:	48e9                	li	a7,26
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <mutex_release>:
.global mutex_release
mutex_release:
 li a7, SYS_mutex_release
 420:	48ed                	li	a7,27
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 428:	48f1                	li	a7,28
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 430:	48f5                	li	a7,29
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 438:	48f9                	li	a7,30
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <setp>:
.global setp
setp:
 li a7, SYS_setp
 440:	48fd                	li	a7,31
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <ismyear>:
.global ismyear
ismyear:
 li a7, SYS_ismyear
 448:	02000893          	li	a7,32
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 452:	02100893          	li	a7,33
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 45c:	02200893          	li	a7,34
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <thread_exit>:
.global thread_exit
thread_exit:
 li a7, SYS_thread_exit
 466:	02300893          	li	a7,35
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <thread_id>:
.global thread_id
thread_id:
 li a7, SYS_thread_id
 470:	02400893          	li	a7,36
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 47a:	1101                	addi	sp,sp,-32
 47c:	ec06                	sd	ra,24(sp)
 47e:	e822                	sd	s0,16(sp)
 480:	1000                	addi	s0,sp,32
 482:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 486:	4605                	li	a2,1
 488:	fef40593          	addi	a1,s0,-17
 48c:	ef5ff0ef          	jal	380 <write>
}
 490:	60e2                	ld	ra,24(sp)
 492:	6442                	ld	s0,16(sp)
 494:	6105                	addi	sp,sp,32
 496:	8082                	ret

0000000000000498 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 498:	715d                	addi	sp,sp,-80
 49a:	e486                	sd	ra,72(sp)
 49c:	e0a2                	sd	s0,64(sp)
 49e:	f84a                	sd	s2,48(sp)
 4a0:	0880                	addi	s0,sp,80
 4a2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4a4:	c299                	beqz	a3,4aa <printint+0x12>
 4a6:	0805c363          	bltz	a1,52c <printint+0x94>
  neg = 0;
 4aa:	4881                	li	a7,0
 4ac:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4b0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4b2:	00000517          	auipc	a0,0x0
 4b6:	59e50513          	addi	a0,a0,1438 # a50 <digits>
 4ba:	883e                	mv	a6,a5
 4bc:	2785                	addiw	a5,a5,1
 4be:	02c5f733          	remu	a4,a1,a2
 4c2:	972a                	add	a4,a4,a0
 4c4:	00074703          	lbu	a4,0(a4)
 4c8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4cc:	872e                	mv	a4,a1
 4ce:	02c5d5b3          	divu	a1,a1,a2
 4d2:	0685                	addi	a3,a3,1
 4d4:	fec773e3          	bgeu	a4,a2,4ba <printint+0x22>
  if(neg)
 4d8:	00088b63          	beqz	a7,4ee <printint+0x56>
    buf[i++] = '-';
 4dc:	fd078793          	addi	a5,a5,-48
 4e0:	97a2                	add	a5,a5,s0
 4e2:	02d00713          	li	a4,45
 4e6:	fee78423          	sb	a4,-24(a5)
 4ea:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4ee:	02f05a63          	blez	a5,522 <printint+0x8a>
 4f2:	fc26                	sd	s1,56(sp)
 4f4:	f44e                	sd	s3,40(sp)
 4f6:	fb840713          	addi	a4,s0,-72
 4fa:	00f704b3          	add	s1,a4,a5
 4fe:	fff70993          	addi	s3,a4,-1
 502:	99be                	add	s3,s3,a5
 504:	37fd                	addiw	a5,a5,-1
 506:	1782                	slli	a5,a5,0x20
 508:	9381                	srli	a5,a5,0x20
 50a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 50e:	fff4c583          	lbu	a1,-1(s1)
 512:	854a                	mv	a0,s2
 514:	f67ff0ef          	jal	47a <putc>
  while(--i >= 0)
 518:	14fd                	addi	s1,s1,-1
 51a:	ff349ae3          	bne	s1,s3,50e <printint+0x76>
 51e:	74e2                	ld	s1,56(sp)
 520:	79a2                	ld	s3,40(sp)
}
 522:	60a6                	ld	ra,72(sp)
 524:	6406                	ld	s0,64(sp)
 526:	7942                	ld	s2,48(sp)
 528:	6161                	addi	sp,sp,80
 52a:	8082                	ret
    x = -xx;
 52c:	40b005b3          	neg	a1,a1
    neg = 1;
 530:	4885                	li	a7,1
    x = -xx;
 532:	bfad                	j	4ac <printint+0x14>

0000000000000534 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 534:	711d                	addi	sp,sp,-96
 536:	ec86                	sd	ra,88(sp)
 538:	e8a2                	sd	s0,80(sp)
 53a:	e0ca                	sd	s2,64(sp)
 53c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 53e:	0005c903          	lbu	s2,0(a1)
 542:	28090663          	beqz	s2,7ce <vprintf+0x29a>
 546:	e4a6                	sd	s1,72(sp)
 548:	fc4e                	sd	s3,56(sp)
 54a:	f852                	sd	s4,48(sp)
 54c:	f456                	sd	s5,40(sp)
 54e:	f05a                	sd	s6,32(sp)
 550:	ec5e                	sd	s7,24(sp)
 552:	e862                	sd	s8,16(sp)
 554:	e466                	sd	s9,8(sp)
 556:	8b2a                	mv	s6,a0
 558:	8a2e                	mv	s4,a1
 55a:	8bb2                	mv	s7,a2
  state = 0;
 55c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 55e:	4481                	li	s1,0
 560:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 562:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 566:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 56a:	06c00c93          	li	s9,108
 56e:	a005                	j	58e <vprintf+0x5a>
        putc(fd, c0);
 570:	85ca                	mv	a1,s2
 572:	855a                	mv	a0,s6
 574:	f07ff0ef          	jal	47a <putc>
 578:	a019                	j	57e <vprintf+0x4a>
    } else if(state == '%'){
 57a:	03598263          	beq	s3,s5,59e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 57e:	2485                	addiw	s1,s1,1
 580:	8726                	mv	a4,s1
 582:	009a07b3          	add	a5,s4,s1
 586:	0007c903          	lbu	s2,0(a5)
 58a:	22090a63          	beqz	s2,7be <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 58e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 592:	fe0994e3          	bnez	s3,57a <vprintf+0x46>
      if(c0 == '%'){
 596:	fd579de3          	bne	a5,s5,570 <vprintf+0x3c>
        state = '%';
 59a:	89be                	mv	s3,a5
 59c:	b7cd                	j	57e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 59e:	00ea06b3          	add	a3,s4,a4
 5a2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5a6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5a8:	c681                	beqz	a3,5b0 <vprintf+0x7c>
 5aa:	9752                	add	a4,a4,s4
 5ac:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5b0:	05878363          	beq	a5,s8,5f6 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5b4:	05978d63          	beq	a5,s9,60e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5b8:	07500713          	li	a4,117
 5bc:	0ee78763          	beq	a5,a4,6aa <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5c0:	07800713          	li	a4,120
 5c4:	12e78963          	beq	a5,a4,6f6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5c8:	07000713          	li	a4,112
 5cc:	14e78e63          	beq	a5,a4,728 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5d0:	06300713          	li	a4,99
 5d4:	18e78e63          	beq	a5,a4,770 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5d8:	07300713          	li	a4,115
 5dc:	1ae78463          	beq	a5,a4,784 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5e0:	02500713          	li	a4,37
 5e4:	04e79563          	bne	a5,a4,62e <vprintf+0xfa>
        putc(fd, '%');
 5e8:	02500593          	li	a1,37
 5ec:	855a                	mv	a0,s6
 5ee:	e8dff0ef          	jal	47a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b769                	j	57e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5f6:	008b8913          	addi	s2,s7,8
 5fa:	4685                	li	a3,1
 5fc:	4629                	li	a2,10
 5fe:	000ba583          	lw	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	e95ff0ef          	jal	498 <printint>
 608:	8bca                	mv	s7,s2
      state = 0;
 60a:	4981                	li	s3,0
 60c:	bf8d                	j	57e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 60e:	06400793          	li	a5,100
 612:	02f68963          	beq	a3,a5,644 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 616:	06c00793          	li	a5,108
 61a:	04f68263          	beq	a3,a5,65e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 61e:	07500793          	li	a5,117
 622:	0af68063          	beq	a3,a5,6c2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 626:	07800793          	li	a5,120
 62a:	0ef68263          	beq	a3,a5,70e <vprintf+0x1da>
        putc(fd, '%');
 62e:	02500593          	li	a1,37
 632:	855a                	mv	a0,s6
 634:	e47ff0ef          	jal	47a <putc>
        putc(fd, c0);
 638:	85ca                	mv	a1,s2
 63a:	855a                	mv	a0,s6
 63c:	e3fff0ef          	jal	47a <putc>
      state = 0;
 640:	4981                	li	s3,0
 642:	bf35                	j	57e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 644:	008b8913          	addi	s2,s7,8
 648:	4685                	li	a3,1
 64a:	4629                	li	a2,10
 64c:	000bb583          	ld	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	e47ff0ef          	jal	498 <printint>
        i += 1;
 656:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 658:	8bca                	mv	s7,s2
      state = 0;
 65a:	4981                	li	s3,0
        i += 1;
 65c:	b70d                	j	57e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 65e:	06400793          	li	a5,100
 662:	02f60763          	beq	a2,a5,690 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 666:	07500793          	li	a5,117
 66a:	06f60963          	beq	a2,a5,6dc <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 66e:	07800793          	li	a5,120
 672:	faf61ee3          	bne	a2,a5,62e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 676:	008b8913          	addi	s2,s7,8
 67a:	4681                	li	a3,0
 67c:	4641                	li	a2,16
 67e:	000bb583          	ld	a1,0(s7)
 682:	855a                	mv	a0,s6
 684:	e15ff0ef          	jal	498 <printint>
        i += 2;
 688:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
        i += 2;
 68e:	bdc5                	j	57e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 690:	008b8913          	addi	s2,s7,8
 694:	4685                	li	a3,1
 696:	4629                	li	a2,10
 698:	000bb583          	ld	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	dfbff0ef          	jal	498 <printint>
        i += 2;
 6a2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
        i += 2;
 6a8:	bdd9                	j	57e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4629                	li	a2,10
 6b2:	000be583          	lwu	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	de1ff0ef          	jal	498 <printint>
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bd7d                	j	57e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	4681                	li	a3,0
 6c8:	4629                	li	a2,10
 6ca:	000bb583          	ld	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	dc9ff0ef          	jal	498 <printint>
        i += 1;
 6d4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d6:	8bca                	mv	s7,s2
      state = 0;
 6d8:	4981                	li	s3,0
        i += 1;
 6da:	b555                	j	57e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6dc:	008b8913          	addi	s2,s7,8
 6e0:	4681                	li	a3,0
 6e2:	4629                	li	a2,10
 6e4:	000bb583          	ld	a1,0(s7)
 6e8:	855a                	mv	a0,s6
 6ea:	dafff0ef          	jal	498 <printint>
        i += 2;
 6ee:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f0:	8bca                	mv	s7,s2
      state = 0;
 6f2:	4981                	li	s3,0
        i += 2;
 6f4:	b569                	j	57e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6f6:	008b8913          	addi	s2,s7,8
 6fa:	4681                	li	a3,0
 6fc:	4641                	li	a2,16
 6fe:	000be583          	lwu	a1,0(s7)
 702:	855a                	mv	a0,s6
 704:	d95ff0ef          	jal	498 <printint>
 708:	8bca                	mv	s7,s2
      state = 0;
 70a:	4981                	li	s3,0
 70c:	bd8d                	j	57e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 70e:	008b8913          	addi	s2,s7,8
 712:	4681                	li	a3,0
 714:	4641                	li	a2,16
 716:	000bb583          	ld	a1,0(s7)
 71a:	855a                	mv	a0,s6
 71c:	d7dff0ef          	jal	498 <printint>
        i += 1;
 720:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 722:	8bca                	mv	s7,s2
      state = 0;
 724:	4981                	li	s3,0
        i += 1;
 726:	bda1                	j	57e <vprintf+0x4a>
 728:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 72a:	008b8d13          	addi	s10,s7,8
 72e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 732:	03000593          	li	a1,48
 736:	855a                	mv	a0,s6
 738:	d43ff0ef          	jal	47a <putc>
  putc(fd, 'x');
 73c:	07800593          	li	a1,120
 740:	855a                	mv	a0,s6
 742:	d39ff0ef          	jal	47a <putc>
 746:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 748:	00000b97          	auipc	s7,0x0
 74c:	308b8b93          	addi	s7,s7,776 # a50 <digits>
 750:	03c9d793          	srli	a5,s3,0x3c
 754:	97de                	add	a5,a5,s7
 756:	0007c583          	lbu	a1,0(a5)
 75a:	855a                	mv	a0,s6
 75c:	d1fff0ef          	jal	47a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 760:	0992                	slli	s3,s3,0x4
 762:	397d                	addiw	s2,s2,-1
 764:	fe0916e3          	bnez	s2,750 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 768:	8bea                	mv	s7,s10
      state = 0;
 76a:	4981                	li	s3,0
 76c:	6d02                	ld	s10,0(sp)
 76e:	bd01                	j	57e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 770:	008b8913          	addi	s2,s7,8
 774:	000bc583          	lbu	a1,0(s7)
 778:	855a                	mv	a0,s6
 77a:	d01ff0ef          	jal	47a <putc>
 77e:	8bca                	mv	s7,s2
      state = 0;
 780:	4981                	li	s3,0
 782:	bbf5                	j	57e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 784:	008b8993          	addi	s3,s7,8
 788:	000bb903          	ld	s2,0(s7)
 78c:	00090f63          	beqz	s2,7aa <vprintf+0x276>
        for(; *s; s++)
 790:	00094583          	lbu	a1,0(s2)
 794:	c195                	beqz	a1,7b8 <vprintf+0x284>
          putc(fd, *s);
 796:	855a                	mv	a0,s6
 798:	ce3ff0ef          	jal	47a <putc>
        for(; *s; s++)
 79c:	0905                	addi	s2,s2,1
 79e:	00094583          	lbu	a1,0(s2)
 7a2:	f9f5                	bnez	a1,796 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7a4:	8bce                	mv	s7,s3
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	bbd9                	j	57e <vprintf+0x4a>
          s = "(null)";
 7aa:	00000917          	auipc	s2,0x0
 7ae:	29e90913          	addi	s2,s2,670 # a48 <malloc+0x192>
        for(; *s; s++)
 7b2:	02800593          	li	a1,40
 7b6:	b7c5                	j	796 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7b8:	8bce                	mv	s7,s3
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	b3c9                	j	57e <vprintf+0x4a>
 7be:	64a6                	ld	s1,72(sp)
 7c0:	79e2                	ld	s3,56(sp)
 7c2:	7a42                	ld	s4,48(sp)
 7c4:	7aa2                	ld	s5,40(sp)
 7c6:	7b02                	ld	s6,32(sp)
 7c8:	6be2                	ld	s7,24(sp)
 7ca:	6c42                	ld	s8,16(sp)
 7cc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7ce:	60e6                	ld	ra,88(sp)
 7d0:	6446                	ld	s0,80(sp)
 7d2:	6906                	ld	s2,64(sp)
 7d4:	6125                	addi	sp,sp,96
 7d6:	8082                	ret

00000000000007d8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d8:	715d                	addi	sp,sp,-80
 7da:	ec06                	sd	ra,24(sp)
 7dc:	e822                	sd	s0,16(sp)
 7de:	1000                	addi	s0,sp,32
 7e0:	e010                	sd	a2,0(s0)
 7e2:	e414                	sd	a3,8(s0)
 7e4:	e818                	sd	a4,16(s0)
 7e6:	ec1c                	sd	a5,24(s0)
 7e8:	03043023          	sd	a6,32(s0)
 7ec:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7f0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f4:	8622                	mv	a2,s0
 7f6:	d3fff0ef          	jal	534 <vprintf>
}
 7fa:	60e2                	ld	ra,24(sp)
 7fc:	6442                	ld	s0,16(sp)
 7fe:	6161                	addi	sp,sp,80
 800:	8082                	ret

0000000000000802 <printf>:

void
printf(const char *fmt, ...)
{
 802:	711d                	addi	sp,sp,-96
 804:	ec06                	sd	ra,24(sp)
 806:	e822                	sd	s0,16(sp)
 808:	1000                	addi	s0,sp,32
 80a:	e40c                	sd	a1,8(s0)
 80c:	e810                	sd	a2,16(s0)
 80e:	ec14                	sd	a3,24(s0)
 810:	f018                	sd	a4,32(s0)
 812:	f41c                	sd	a5,40(s0)
 814:	03043823          	sd	a6,48(s0)
 818:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 81c:	00840613          	addi	a2,s0,8
 820:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 824:	85aa                	mv	a1,a0
 826:	4505                	li	a0,1
 828:	d0dff0ef          	jal	534 <vprintf>
}
 82c:	60e2                	ld	ra,24(sp)
 82e:	6442                	ld	s0,16(sp)
 830:	6125                	addi	sp,sp,96
 832:	8082                	ret

0000000000000834 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 834:	1141                	addi	sp,sp,-16
 836:	e422                	sd	s0,8(sp)
 838:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83e:	00000797          	auipc	a5,0x0
 842:	7c27b783          	ld	a5,1986(a5) # 1000 <freep>
 846:	a02d                	j	870 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 848:	4618                	lw	a4,8(a2)
 84a:	9f2d                	addw	a4,a4,a1
 84c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 850:	6398                	ld	a4,0(a5)
 852:	6310                	ld	a2,0(a4)
 854:	a83d                	j	892 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 856:	ff852703          	lw	a4,-8(a0)
 85a:	9f31                	addw	a4,a4,a2
 85c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 85e:	ff053683          	ld	a3,-16(a0)
 862:	a091                	j	8a6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 864:	6398                	ld	a4,0(a5)
 866:	00e7e463          	bltu	a5,a4,86e <free+0x3a>
 86a:	00e6ea63          	bltu	a3,a4,87e <free+0x4a>
{
 86e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 870:	fed7fae3          	bgeu	a5,a3,864 <free+0x30>
 874:	6398                	ld	a4,0(a5)
 876:	00e6e463          	bltu	a3,a4,87e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87a:	fee7eae3          	bltu	a5,a4,86e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 87e:	ff852583          	lw	a1,-8(a0)
 882:	6390                	ld	a2,0(a5)
 884:	02059813          	slli	a6,a1,0x20
 888:	01c85713          	srli	a4,a6,0x1c
 88c:	9736                	add	a4,a4,a3
 88e:	fae60de3          	beq	a2,a4,848 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 892:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 896:	4790                	lw	a2,8(a5)
 898:	02061593          	slli	a1,a2,0x20
 89c:	01c5d713          	srli	a4,a1,0x1c
 8a0:	973e                	add	a4,a4,a5
 8a2:	fae68ae3          	beq	a3,a4,856 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8a6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a8:	00000717          	auipc	a4,0x0
 8ac:	74f73c23          	sd	a5,1880(a4) # 1000 <freep>
}
 8b0:	6422                	ld	s0,8(sp)
 8b2:	0141                	addi	sp,sp,16
 8b4:	8082                	ret

00000000000008b6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b6:	7139                	addi	sp,sp,-64
 8b8:	fc06                	sd	ra,56(sp)
 8ba:	f822                	sd	s0,48(sp)
 8bc:	f426                	sd	s1,40(sp)
 8be:	ec4e                	sd	s3,24(sp)
 8c0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c2:	02051493          	slli	s1,a0,0x20
 8c6:	9081                	srli	s1,s1,0x20
 8c8:	04bd                	addi	s1,s1,15
 8ca:	8091                	srli	s1,s1,0x4
 8cc:	0014899b          	addiw	s3,s1,1
 8d0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d2:	00000517          	auipc	a0,0x0
 8d6:	72e53503          	ld	a0,1838(a0) # 1000 <freep>
 8da:	c915                	beqz	a0,90e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8de:	4798                	lw	a4,8(a5)
 8e0:	08977a63          	bgeu	a4,s1,974 <malloc+0xbe>
 8e4:	f04a                	sd	s2,32(sp)
 8e6:	e852                	sd	s4,16(sp)
 8e8:	e456                	sd	s5,8(sp)
 8ea:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8ec:	8a4e                	mv	s4,s3
 8ee:	0009871b          	sext.w	a4,s3
 8f2:	6685                	lui	a3,0x1
 8f4:	00d77363          	bgeu	a4,a3,8fa <malloc+0x44>
 8f8:	6a05                	lui	s4,0x1
 8fa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8fe:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 902:	00000917          	auipc	s2,0x0
 906:	6fe90913          	addi	s2,s2,1790 # 1000 <freep>
  if(p == SBRK_ERROR)
 90a:	5afd                	li	s5,-1
 90c:	a081                	j	94c <malloc+0x96>
 90e:	f04a                	sd	s2,32(sp)
 910:	e852                	sd	s4,16(sp)
 912:	e456                	sd	s5,8(sp)
 914:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 916:	00001797          	auipc	a5,0x1
 91a:	8f278793          	addi	a5,a5,-1806 # 1208 <base>
 91e:	00000717          	auipc	a4,0x0
 922:	6ef73123          	sd	a5,1762(a4) # 1000 <freep>
 926:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 928:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92c:	b7c1                	j	8ec <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 92e:	6398                	ld	a4,0(a5)
 930:	e118                	sd	a4,0(a0)
 932:	a8a9                	j	98c <malloc+0xd6>
  hp->s.size = nu;
 934:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 938:	0541                	addi	a0,a0,16
 93a:	efbff0ef          	jal	834 <free>
  return freep;
 93e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 942:	c12d                	beqz	a0,9a4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 944:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 946:	4798                	lw	a4,8(a5)
 948:	02977263          	bgeu	a4,s1,96c <malloc+0xb6>
    if(p == freep)
 94c:	00093703          	ld	a4,0(s2)
 950:	853e                	mv	a0,a5
 952:	fef719e3          	bne	a4,a5,944 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 956:	8552                	mv	a0,s4
 958:	9cdff0ef          	jal	324 <sbrk>
  if(p == SBRK_ERROR)
 95c:	fd551ce3          	bne	a0,s5,934 <malloc+0x7e>
        return 0;
 960:	4501                	li	a0,0
 962:	7902                	ld	s2,32(sp)
 964:	6a42                	ld	s4,16(sp)
 966:	6aa2                	ld	s5,8(sp)
 968:	6b02                	ld	s6,0(sp)
 96a:	a03d                	j	998 <malloc+0xe2>
 96c:	7902                	ld	s2,32(sp)
 96e:	6a42                	ld	s4,16(sp)
 970:	6aa2                	ld	s5,8(sp)
 972:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 974:	fae48de3          	beq	s1,a4,92e <malloc+0x78>
        p->s.size -= nunits;
 978:	4137073b          	subw	a4,a4,s3
 97c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 97e:	02071693          	slli	a3,a4,0x20
 982:	01c6d713          	srli	a4,a3,0x1c
 986:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 988:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98c:	00000717          	auipc	a4,0x0
 990:	66a73a23          	sd	a0,1652(a4) # 1000 <freep>
      return (void*)(p + 1);
 994:	01078513          	addi	a0,a5,16
  }
}
 998:	70e2                	ld	ra,56(sp)
 99a:	7442                	ld	s0,48(sp)
 99c:	74a2                	ld	s1,40(sp)
 99e:	69e2                	ld	s3,24(sp)
 9a0:	6121                	addi	sp,sp,64
 9a2:	8082                	ret
 9a4:	7902                	ld	s2,32(sp)
 9a6:	6a42                	ld	s4,16(sp)
 9a8:	6aa2                	ld	s5,8(sp)
 9aa:	6b02                	ld	s6,0(sp)
 9ac:	b7f5                	j	998 <malloc+0xe2>
