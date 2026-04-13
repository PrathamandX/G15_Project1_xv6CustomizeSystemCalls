
user/_test_thread:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <worker>:
volatile int counter = 0;
int lockid;

void
worker(void *arg)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int id = (int)(uint64)arg;
  10:	00050a1b          	sext.w	s4,a0
  14:	7d000493          	li	s1,2000
  int i;

  for(i = 0; i < ITERS; i++){
    mutex_acquire(lockid);
  18:	00001997          	auipc	s3,0x1
  1c:	fe898993          	addi	s3,s3,-24 # 1000 <lockid>
    counter++;
  20:	00001917          	auipc	s2,0x1
  24:	fe490913          	addi	s2,s2,-28 # 1004 <counter>
    mutex_acquire(lockid);
  28:	0009a503          	lw	a0,0(s3)
  2c:	488000ef          	jal	4b4 <mutex_acquire>
    counter++;
  30:	00092783          	lw	a5,0(s2)
  34:	2785                	addiw	a5,a5,1
  36:	00f92023          	sw	a5,0(s2)
    mutex_release(lockid);
  3a:	0009a503          	lw	a0,0(s3)
  3e:	47e000ef          	jal	4bc <mutex_release>
  for(i = 0; i < ITERS; i++){
  42:	34fd                	addiw	s1,s1,-1
  44:	f0f5                	bnez	s1,28 <worker+0x28>
  }

  printf("thread %d tid=%d finished\n", id, thread_id());
  46:	4c6000ef          	jal	50c <thread_id>
  4a:	862a                	mv	a2,a0
  4c:	85d2                	mv	a1,s4
  4e:	00001517          	auipc	a0,0x1
  52:	a0250513          	addi	a0,a0,-1534 # a50 <malloc+0xfe>
  56:	049000ef          	jal	89e <printf>
  thread_exit(id);
  5a:	8552                	mv	a0,s4
  5c:	4a6000ef          	jal	502 <thread_exit>

0000000000000060 <main>:
}

int
main(void)
{
  60:	7175                	addi	sp,sp,-144
  62:	e506                	sd	ra,136(sp)
  64:	e122                	sd	s0,128(sp)
  66:	fca6                	sd	s1,120(sp)
  68:	f8ca                	sd	s2,112(sp)
  6a:	f4ce                	sd	s3,104(sp)
  6c:	f0d2                	sd	s4,96(sp)
  6e:	ecd6                	sd	s5,88(sp)
  70:	e8da                	sd	s6,80(sp)
  72:	e4de                	sd	s7,72(sp)
  74:	e0e2                	sd	s8,64(sp)
  76:	fc66                	sd	s9,56(sp)
  78:	0900                	addi	s0,sp,144
  int tids[NTHREADS];
  char *stacks[NTHREADS];
  int i, ret;

  lockid = mutex_init(0);
  7a:	4501                	li	a0,0
  7c:	430000ef          	jal	4ac <mutex_init>
  80:	00001797          	auipc	a5,0x1
  84:	f8a7a023          	sw	a0,-128(a5) # 1000 <lockid>

  printf("creating %d threads\n", NTHREADS);
  88:	4591                	li	a1,4
  8a:	00001517          	auipc	a0,0x1
  8e:	9e650513          	addi	a0,a0,-1562 # a70 <malloc+0x11e>
  92:	00d000ef          	jal	89e <printf>

  for(i = 0; i < NTHREADS; i++){
  96:	f7040993          	addi	s3,s0,-144
  9a:	f9040913          	addi	s2,s0,-112
  printf("creating %d threads\n", NTHREADS);
  9e:	8aca                	mv	s5,s2
  a0:	8a4e                	mv	s4,s3
  a2:	4481                	li	s1,0
    if(stacks[i] == 0){
      printf("malloc failed\n");
      exit(1);
    }

    tids[i] = thread_create(worker, (void *)(uint64)i, stacks[i]);
  a4:	00000b97          	auipc	s7,0x0
  a8:	f5cb8b93          	addi	s7,s7,-164 # 0 <worker>
    if(tids[i] < 0){
      printf("thread_create failed\n");
      exit(1);
    }

    printf("spawned thread %d with tid=%d\n", i, tids[i]);
  ac:	00001c97          	auipc	s9,0x1
  b0:	a04c8c93          	addi	s9,s9,-1532 # ab0 <malloc+0x15e>
  for(i = 0; i < NTHREADS; i++){
  b4:	4c11                	li	s8,4
  b6:	00048b1b          	sext.w	s6,s1
    stacks[i] = malloc(STACKSZ);
  ba:	6505                	lui	a0,0x1
  bc:	097000ef          	jal	952 <malloc>
  c0:	862a                	mv	a2,a0
  c2:	00aa3023          	sd	a0,0(s4)
    if(stacks[i] == 0){
  c6:	c93d                	beqz	a0,13c <main+0xdc>
    tids[i] = thread_create(worker, (void *)(uint64)i, stacks[i]);
  c8:	85a6                	mv	a1,s1
  ca:	855e                	mv	a0,s7
  cc:	422000ef          	jal	4ee <thread_create>
  d0:	862a                	mv	a2,a0
  d2:	00aaa023          	sw	a0,0(s5)
    if(tids[i] < 0){
  d6:	06054c63          	bltz	a0,14e <main+0xee>
    printf("spawned thread %d with tid=%d\n", i, tids[i]);
  da:	85da                	mv	a1,s6
  dc:	8566                	mv	a0,s9
  de:	7c0000ef          	jal	89e <printf>
  for(i = 0; i < NTHREADS; i++){
  e2:	0485                	addi	s1,s1,1
  e4:	0a21                	addi	s4,s4,8
  e6:	0a91                	addi	s5,s5,4
  e8:	fd8497e3          	bne	s1,s8,b6 <main+0x56>
  ec:	01090a93          	addi	s5,s2,16
  }

  for(i = 0; i < NTHREADS; i++){
    ret = thread_join(tids[i]);
    printf("joined tid=%d exit=%d\n", tids[i], ret);
  f0:	00001a17          	auipc	s4,0x1
  f4:	9e0a0a13          	addi	s4,s4,-1568 # ad0 <malloc+0x17e>
    ret = thread_join(tids[i]);
  f8:	00092483          	lw	s1,0(s2)
  fc:	8526                	mv	a0,s1
  fe:	3fa000ef          	jal	4f8 <thread_join>
 102:	862a                	mv	a2,a0
    printf("joined tid=%d exit=%d\n", tids[i], ret);
 104:	85a6                	mv	a1,s1
 106:	8552                	mv	a0,s4
 108:	796000ef          	jal	89e <printf>
    free(stacks[i]);
 10c:	0009b503          	ld	a0,0(s3)
 110:	7c0000ef          	jal	8d0 <free>
  for(i = 0; i < NTHREADS; i++){
 114:	0911                	addi	s2,s2,4
 116:	09a1                	addi	s3,s3,8
 118:	ff5910e3          	bne	s2,s5,f8 <main+0x98>
  }

  printf("final counter = %d expected = %d\n", counter, NTHREADS * ITERS);
 11c:	6609                	lui	a2,0x2
 11e:	f4060613          	addi	a2,a2,-192 # 1f40 <base+0xf30>
 122:	00001597          	auipc	a1,0x1
 126:	ee25a583          	lw	a1,-286(a1) # 1004 <counter>
 12a:	00001517          	auipc	a0,0x1
 12e:	9be50513          	addi	a0,a0,-1602 # ae8 <malloc+0x196>
 132:	76c000ef          	jal	89e <printf>

  exit(0);
 136:	4501                	li	a0,0
 138:	2bc000ef          	jal	3f4 <exit>
      printf("malloc failed\n");
 13c:	00001517          	auipc	a0,0x1
 140:	94c50513          	addi	a0,a0,-1716 # a88 <malloc+0x136>
 144:	75a000ef          	jal	89e <printf>
      exit(1);
 148:	4505                	li	a0,1
 14a:	2aa000ef          	jal	3f4 <exit>
      printf("thread_create failed\n");
 14e:	00001517          	auipc	a0,0x1
 152:	94a50513          	addi	a0,a0,-1718 # a98 <malloc+0x146>
 156:	748000ef          	jal	89e <printf>
      exit(1);
 15a:	4505                	li	a0,1
 15c:	298000ef          	jal	3f4 <exit>

0000000000000160 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 160:	1141                	addi	sp,sp,-16
 162:	e406                	sd	ra,8(sp)
 164:	e022                	sd	s0,0(sp)
 166:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 168:	ef9ff0ef          	jal	60 <main>
  exit(r);
 16c:	288000ef          	jal	3f4 <exit>

0000000000000170 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 170:	1141                	addi	sp,sp,-16
 172:	e422                	sd	s0,8(sp)
 174:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 176:	87aa                	mv	a5,a0
 178:	0585                	addi	a1,a1,1
 17a:	0785                	addi	a5,a5,1
 17c:	fff5c703          	lbu	a4,-1(a1)
 180:	fee78fa3          	sb	a4,-1(a5)
 184:	fb75                	bnez	a4,178 <strcpy+0x8>
    ;
  return os;
}
 186:	6422                	ld	s0,8(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret

000000000000018c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e422                	sd	s0,8(sp)
 190:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 192:	00054783          	lbu	a5,0(a0)
 196:	cb91                	beqz	a5,1aa <strcmp+0x1e>
 198:	0005c703          	lbu	a4,0(a1)
 19c:	00f71763          	bne	a4,a5,1aa <strcmp+0x1e>
    p++, q++;
 1a0:	0505                	addi	a0,a0,1
 1a2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	fbe5                	bnez	a5,198 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1aa:	0005c503          	lbu	a0,0(a1)
}
 1ae:	40a7853b          	subw	a0,a5,a0
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret

00000000000001b8 <strlen>:

uint
strlen(const char *s)
{
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e422                	sd	s0,8(sp)
 1bc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	cf91                	beqz	a5,1de <strlen+0x26>
 1c4:	0505                	addi	a0,a0,1
 1c6:	87aa                	mv	a5,a0
 1c8:	86be                	mv	a3,a5
 1ca:	0785                	addi	a5,a5,1
 1cc:	fff7c703          	lbu	a4,-1(a5)
 1d0:	ff65                	bnez	a4,1c8 <strlen+0x10>
 1d2:	40a6853b          	subw	a0,a3,a0
 1d6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1d8:	6422                	ld	s0,8(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret
  for(n = 0; s[n]; n++)
 1de:	4501                	li	a0,0
 1e0:	bfe5                	j	1d8 <strlen+0x20>

00000000000001e2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e422                	sd	s0,8(sp)
 1e6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e8:	ca19                	beqz	a2,1fe <memset+0x1c>
 1ea:	87aa                	mv	a5,a0
 1ec:	1602                	slli	a2,a2,0x20
 1ee:	9201                	srli	a2,a2,0x20
 1f0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f8:	0785                	addi	a5,a5,1
 1fa:	fee79de3          	bne	a5,a4,1f4 <memset+0x12>
  }
  return dst;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret

0000000000000204 <strchr>:

char*
strchr(const char *s, char c)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  for(; *s; s++)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	cb99                	beqz	a5,224 <strchr+0x20>
    if(*s == c)
 210:	00f58763          	beq	a1,a5,21e <strchr+0x1a>
  for(; *s; s++)
 214:	0505                	addi	a0,a0,1
 216:	00054783          	lbu	a5,0(a0)
 21a:	fbfd                	bnez	a5,210 <strchr+0xc>
      return (char*)s;
  return 0;
 21c:	4501                	li	a0,0
}
 21e:	6422                	ld	s0,8(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret
  return 0;
 224:	4501                	li	a0,0
 226:	bfe5                	j	21e <strchr+0x1a>

0000000000000228 <gets>:

char*
gets(char *buf, int max)
{
 228:	711d                	addi	sp,sp,-96
 22a:	ec86                	sd	ra,88(sp)
 22c:	e8a2                	sd	s0,80(sp)
 22e:	e4a6                	sd	s1,72(sp)
 230:	e0ca                	sd	s2,64(sp)
 232:	fc4e                	sd	s3,56(sp)
 234:	f852                	sd	s4,48(sp)
 236:	f456                	sd	s5,40(sp)
 238:	f05a                	sd	s6,32(sp)
 23a:	ec5e                	sd	s7,24(sp)
 23c:	1080                	addi	s0,sp,96
 23e:	8baa                	mv	s7,a0
 240:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 242:	892a                	mv	s2,a0
 244:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 246:	4aa9                	li	s5,10
 248:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 24a:	89a6                	mv	s3,s1
 24c:	2485                	addiw	s1,s1,1
 24e:	0344d663          	bge	s1,s4,27a <gets+0x52>
    cc = read(0, &c, 1);
 252:	4605                	li	a2,1
 254:	faf40593          	addi	a1,s0,-81
 258:	4501                	li	a0,0
 25a:	1ba000ef          	jal	414 <read>
    if(cc < 1)
 25e:	00a05e63          	blez	a0,27a <gets+0x52>
    buf[i++] = c;
 262:	faf44783          	lbu	a5,-81(s0)
 266:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 26a:	01578763          	beq	a5,s5,278 <gets+0x50>
 26e:	0905                	addi	s2,s2,1
 270:	fd679de3          	bne	a5,s6,24a <gets+0x22>
    buf[i++] = c;
 274:	89a6                	mv	s3,s1
 276:	a011                	j	27a <gets+0x52>
 278:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 27a:	99de                	add	s3,s3,s7
 27c:	00098023          	sb	zero,0(s3)
  return buf;
}
 280:	855e                	mv	a0,s7
 282:	60e6                	ld	ra,88(sp)
 284:	6446                	ld	s0,80(sp)
 286:	64a6                	ld	s1,72(sp)
 288:	6906                	ld	s2,64(sp)
 28a:	79e2                	ld	s3,56(sp)
 28c:	7a42                	ld	s4,48(sp)
 28e:	7aa2                	ld	s5,40(sp)
 290:	7b02                	ld	s6,32(sp)
 292:	6be2                	ld	s7,24(sp)
 294:	6125                	addi	sp,sp,96
 296:	8082                	ret

0000000000000298 <stat>:

int
stat(const char *n, struct stat *st)
{
 298:	1101                	addi	sp,sp,-32
 29a:	ec06                	sd	ra,24(sp)
 29c:	e822                	sd	s0,16(sp)
 29e:	e04a                	sd	s2,0(sp)
 2a0:	1000                	addi	s0,sp,32
 2a2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a4:	4581                	li	a1,0
 2a6:	196000ef          	jal	43c <open>
  if(fd < 0)
 2aa:	02054263          	bltz	a0,2ce <stat+0x36>
 2ae:	e426                	sd	s1,8(sp)
 2b0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b2:	85ca                	mv	a1,s2
 2b4:	1a0000ef          	jal	454 <fstat>
 2b8:	892a                	mv	s2,a0
  close(fd);
 2ba:	8526                	mv	a0,s1
 2bc:	168000ef          	jal	424 <close>
  return r;
 2c0:	64a2                	ld	s1,8(sp)
}
 2c2:	854a                	mv	a0,s2
 2c4:	60e2                	ld	ra,24(sp)
 2c6:	6442                	ld	s0,16(sp)
 2c8:	6902                	ld	s2,0(sp)
 2ca:	6105                	addi	sp,sp,32
 2cc:	8082                	ret
    return -1;
 2ce:	597d                	li	s2,-1
 2d0:	bfcd                	j	2c2 <stat+0x2a>

00000000000002d2 <atoi>:

int
atoi(const char *s)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d8:	00054683          	lbu	a3,0(a0)
 2dc:	fd06879b          	addiw	a5,a3,-48
 2e0:	0ff7f793          	zext.b	a5,a5
 2e4:	4625                	li	a2,9
 2e6:	02f66863          	bltu	a2,a5,316 <atoi+0x44>
 2ea:	872a                	mv	a4,a0
  n = 0;
 2ec:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ee:	0705                	addi	a4,a4,1
 2f0:	0025179b          	slliw	a5,a0,0x2
 2f4:	9fa9                	addw	a5,a5,a0
 2f6:	0017979b          	slliw	a5,a5,0x1
 2fa:	9fb5                	addw	a5,a5,a3
 2fc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 300:	00074683          	lbu	a3,0(a4)
 304:	fd06879b          	addiw	a5,a3,-48
 308:	0ff7f793          	zext.b	a5,a5
 30c:	fef671e3          	bgeu	a2,a5,2ee <atoi+0x1c>
  return n;
}
 310:	6422                	ld	s0,8(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret
  n = 0;
 316:	4501                	li	a0,0
 318:	bfe5                	j	310 <atoi+0x3e>

000000000000031a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e422                	sd	s0,8(sp)
 31e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 320:	02b57463          	bgeu	a0,a1,348 <memmove+0x2e>
    while(n-- > 0)
 324:	00c05f63          	blez	a2,342 <memmove+0x28>
 328:	1602                	slli	a2,a2,0x20
 32a:	9201                	srli	a2,a2,0x20
 32c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 330:	872a                	mv	a4,a0
      *dst++ = *src++;
 332:	0585                	addi	a1,a1,1
 334:	0705                	addi	a4,a4,1
 336:	fff5c683          	lbu	a3,-1(a1)
 33a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33e:	fef71ae3          	bne	a4,a5,332 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 342:	6422                	ld	s0,8(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret
    dst += n;
 348:	00c50733          	add	a4,a0,a2
    src += n;
 34c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34e:	fec05ae3          	blez	a2,342 <memmove+0x28>
 352:	fff6079b          	addiw	a5,a2,-1
 356:	1782                	slli	a5,a5,0x20
 358:	9381                	srli	a5,a5,0x20
 35a:	fff7c793          	not	a5,a5
 35e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 360:	15fd                	addi	a1,a1,-1
 362:	177d                	addi	a4,a4,-1
 364:	0005c683          	lbu	a3,0(a1)
 368:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 36c:	fee79ae3          	bne	a5,a4,360 <memmove+0x46>
 370:	bfc9                	j	342 <memmove+0x28>

0000000000000372 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 372:	1141                	addi	sp,sp,-16
 374:	e422                	sd	s0,8(sp)
 376:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 378:	ca05                	beqz	a2,3a8 <memcmp+0x36>
 37a:	fff6069b          	addiw	a3,a2,-1
 37e:	1682                	slli	a3,a3,0x20
 380:	9281                	srli	a3,a3,0x20
 382:	0685                	addi	a3,a3,1
 384:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 386:	00054783          	lbu	a5,0(a0)
 38a:	0005c703          	lbu	a4,0(a1)
 38e:	00e79863          	bne	a5,a4,39e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 392:	0505                	addi	a0,a0,1
    p2++;
 394:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 396:	fed518e3          	bne	a0,a3,386 <memcmp+0x14>
  }
  return 0;
 39a:	4501                	li	a0,0
 39c:	a019                	j	3a2 <memcmp+0x30>
      return *p1 - *p2;
 39e:	40e7853b          	subw	a0,a5,a4
}
 3a2:	6422                	ld	s0,8(sp)
 3a4:	0141                	addi	sp,sp,16
 3a6:	8082                	ret
  return 0;
 3a8:	4501                	li	a0,0
 3aa:	bfe5                	j	3a2 <memcmp+0x30>

00000000000003ac <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ac:	1141                	addi	sp,sp,-16
 3ae:	e406                	sd	ra,8(sp)
 3b0:	e022                	sd	s0,0(sp)
 3b2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b4:	f67ff0ef          	jal	31a <memmove>
}
 3b8:	60a2                	ld	ra,8(sp)
 3ba:	6402                	ld	s0,0(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret

00000000000003c0 <sbrk>:

char *
sbrk(int n) {
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3c8:	4585                	li	a1,1
 3ca:	0ba000ef          	jal	484 <sys_sbrk>
}
 3ce:	60a2                	ld	ra,8(sp)
 3d0:	6402                	ld	s0,0(sp)
 3d2:	0141                	addi	sp,sp,16
 3d4:	8082                	ret

00000000000003d6 <sbrklazy>:

char *
sbrklazy(int n) {
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e406                	sd	ra,8(sp)
 3da:	e022                	sd	s0,0(sp)
 3dc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3de:	4589                	li	a1,2
 3e0:	0a4000ef          	jal	484 <sys_sbrk>
}
 3e4:	60a2                	ld	ra,8(sp)
 3e6:	6402                	ld	s0,0(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret

00000000000003ec <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ec:	4885                	li	a7,1
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f4:	4889                	li	a7,2
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3fc:	488d                	li	a7,3
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 404:	48d9                	li	a7,22
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 40c:	4891                	li	a7,4
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <read>:
.global read
read:
 li a7, SYS_read
 414:	4895                	li	a7,5
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <write>:
.global write
write:
 li a7, SYS_write
 41c:	48c1                	li	a7,16
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <close>:
.global close
close:
 li a7, SYS_close
 424:	48d5                	li	a7,21
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <kill>:
.global kill
kill:
 li a7, SYS_kill
 42c:	4899                	li	a7,6
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <exec>:
.global exec
exec:
 li a7, SYS_exec
 434:	489d                	li	a7,7
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <open>:
.global open
open:
 li a7, SYS_open
 43c:	48bd                	li	a7,15
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 444:	48c5                	li	a7,17
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 44c:	48c9                	li	a7,18
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 454:	48a1                	li	a7,8
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <link>:
.global link
link:
 li a7, SYS_link
 45c:	48cd                	li	a7,19
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 464:	48d1                	li	a7,20
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 46c:	48a5                	li	a7,9
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <dup>:
.global dup
dup:
 li a7, SYS_dup
 474:	48a9                	li	a7,10
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 47c:	48ad                	li	a7,11
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 484:	48b1                	li	a7,12
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <pause>:
.global pause
pause:
 li a7, SYS_pause
 48c:	48b5                	li	a7,13
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 494:	48b9                	li	a7,14
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 49c:	48dd                	li	a7,23
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 4a4:	48e1                	li	a7,24
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <mutex_init>:
.global mutex_init
mutex_init:
 li a7, SYS_mutex_init
 4ac:	48e5                	li	a7,25
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <mutex_acquire>:
.global mutex_acquire
mutex_acquire:
 li a7, SYS_mutex_acquire
 4b4:	48e9                	li	a7,26
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <mutex_release>:
.global mutex_release
mutex_release:
 li a7, SYS_mutex_release
 4bc:	48ed                	li	a7,27
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 4c4:	48f1                	li	a7,28
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 4cc:	48f5                	li	a7,29
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 4d4:	48f9                	li	a7,30
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <setp>:
.global setp
setp:
 li a7, SYS_setp
 4dc:	48fd                	li	a7,31
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <ismyear>:
.global ismyear
ismyear:
 li a7, SYS_ismyear
 4e4:	02000893          	li	a7,32
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 4ee:	02100893          	li	a7,33
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 4f8:	02200893          	li	a7,34
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <thread_exit>:
.global thread_exit
thread_exit:
 li a7, SYS_thread_exit
 502:	02300893          	li	a7,35
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <thread_id>:
.global thread_id
thread_id:
 li a7, SYS_thread_id
 50c:	02400893          	li	a7,36
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 516:	1101                	addi	sp,sp,-32
 518:	ec06                	sd	ra,24(sp)
 51a:	e822                	sd	s0,16(sp)
 51c:	1000                	addi	s0,sp,32
 51e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 522:	4605                	li	a2,1
 524:	fef40593          	addi	a1,s0,-17
 528:	ef5ff0ef          	jal	41c <write>
}
 52c:	60e2                	ld	ra,24(sp)
 52e:	6442                	ld	s0,16(sp)
 530:	6105                	addi	sp,sp,32
 532:	8082                	ret

0000000000000534 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 534:	715d                	addi	sp,sp,-80
 536:	e486                	sd	ra,72(sp)
 538:	e0a2                	sd	s0,64(sp)
 53a:	f84a                	sd	s2,48(sp)
 53c:	0880                	addi	s0,sp,80
 53e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 540:	c299                	beqz	a3,546 <printint+0x12>
 542:	0805c363          	bltz	a1,5c8 <printint+0x94>
  neg = 0;
 546:	4881                	li	a7,0
 548:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 54c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 54e:	00000517          	auipc	a0,0x0
 552:	5ca50513          	addi	a0,a0,1482 # b18 <digits>
 556:	883e                	mv	a6,a5
 558:	2785                	addiw	a5,a5,1
 55a:	02c5f733          	remu	a4,a1,a2
 55e:	972a                	add	a4,a4,a0
 560:	00074703          	lbu	a4,0(a4)
 564:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 568:	872e                	mv	a4,a1
 56a:	02c5d5b3          	divu	a1,a1,a2
 56e:	0685                	addi	a3,a3,1
 570:	fec773e3          	bgeu	a4,a2,556 <printint+0x22>
  if(neg)
 574:	00088b63          	beqz	a7,58a <printint+0x56>
    buf[i++] = '-';
 578:	fd078793          	addi	a5,a5,-48
 57c:	97a2                	add	a5,a5,s0
 57e:	02d00713          	li	a4,45
 582:	fee78423          	sb	a4,-24(a5)
 586:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 58a:	02f05a63          	blez	a5,5be <printint+0x8a>
 58e:	fc26                	sd	s1,56(sp)
 590:	f44e                	sd	s3,40(sp)
 592:	fb840713          	addi	a4,s0,-72
 596:	00f704b3          	add	s1,a4,a5
 59a:	fff70993          	addi	s3,a4,-1
 59e:	99be                	add	s3,s3,a5
 5a0:	37fd                	addiw	a5,a5,-1
 5a2:	1782                	slli	a5,a5,0x20
 5a4:	9381                	srli	a5,a5,0x20
 5a6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5aa:	fff4c583          	lbu	a1,-1(s1)
 5ae:	854a                	mv	a0,s2
 5b0:	f67ff0ef          	jal	516 <putc>
  while(--i >= 0)
 5b4:	14fd                	addi	s1,s1,-1
 5b6:	ff349ae3          	bne	s1,s3,5aa <printint+0x76>
 5ba:	74e2                	ld	s1,56(sp)
 5bc:	79a2                	ld	s3,40(sp)
}
 5be:	60a6                	ld	ra,72(sp)
 5c0:	6406                	ld	s0,64(sp)
 5c2:	7942                	ld	s2,48(sp)
 5c4:	6161                	addi	sp,sp,80
 5c6:	8082                	ret
    x = -xx;
 5c8:	40b005b3          	neg	a1,a1
    neg = 1;
 5cc:	4885                	li	a7,1
    x = -xx;
 5ce:	bfad                	j	548 <printint+0x14>

00000000000005d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d0:	711d                	addi	sp,sp,-96
 5d2:	ec86                	sd	ra,88(sp)
 5d4:	e8a2                	sd	s0,80(sp)
 5d6:	e0ca                	sd	s2,64(sp)
 5d8:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5da:	0005c903          	lbu	s2,0(a1)
 5de:	28090663          	beqz	s2,86a <vprintf+0x29a>
 5e2:	e4a6                	sd	s1,72(sp)
 5e4:	fc4e                	sd	s3,56(sp)
 5e6:	f852                	sd	s4,48(sp)
 5e8:	f456                	sd	s5,40(sp)
 5ea:	f05a                	sd	s6,32(sp)
 5ec:	ec5e                	sd	s7,24(sp)
 5ee:	e862                	sd	s8,16(sp)
 5f0:	e466                	sd	s9,8(sp)
 5f2:	8b2a                	mv	s6,a0
 5f4:	8a2e                	mv	s4,a1
 5f6:	8bb2                	mv	s7,a2
  state = 0;
 5f8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5fa:	4481                	li	s1,0
 5fc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5fe:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 602:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 606:	06c00c93          	li	s9,108
 60a:	a005                	j	62a <vprintf+0x5a>
        putc(fd, c0);
 60c:	85ca                	mv	a1,s2
 60e:	855a                	mv	a0,s6
 610:	f07ff0ef          	jal	516 <putc>
 614:	a019                	j	61a <vprintf+0x4a>
    } else if(state == '%'){
 616:	03598263          	beq	s3,s5,63a <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 61a:	2485                	addiw	s1,s1,1
 61c:	8726                	mv	a4,s1
 61e:	009a07b3          	add	a5,s4,s1
 622:	0007c903          	lbu	s2,0(a5)
 626:	22090a63          	beqz	s2,85a <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 62a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 62e:	fe0994e3          	bnez	s3,616 <vprintf+0x46>
      if(c0 == '%'){
 632:	fd579de3          	bne	a5,s5,60c <vprintf+0x3c>
        state = '%';
 636:	89be                	mv	s3,a5
 638:	b7cd                	j	61a <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 63a:	00ea06b3          	add	a3,s4,a4
 63e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 642:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 644:	c681                	beqz	a3,64c <vprintf+0x7c>
 646:	9752                	add	a4,a4,s4
 648:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 64c:	05878363          	beq	a5,s8,692 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 650:	05978d63          	beq	a5,s9,6aa <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 654:	07500713          	li	a4,117
 658:	0ee78763          	beq	a5,a4,746 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 65c:	07800713          	li	a4,120
 660:	12e78963          	beq	a5,a4,792 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 664:	07000713          	li	a4,112
 668:	14e78e63          	beq	a5,a4,7c4 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 66c:	06300713          	li	a4,99
 670:	18e78e63          	beq	a5,a4,80c <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 674:	07300713          	li	a4,115
 678:	1ae78463          	beq	a5,a4,820 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 67c:	02500713          	li	a4,37
 680:	04e79563          	bne	a5,a4,6ca <vprintf+0xfa>
        putc(fd, '%');
 684:	02500593          	li	a1,37
 688:	855a                	mv	a0,s6
 68a:	e8dff0ef          	jal	516 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 68e:	4981                	li	s3,0
 690:	b769                	j	61a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 692:	008b8913          	addi	s2,s7,8
 696:	4685                	li	a3,1
 698:	4629                	li	a2,10
 69a:	000ba583          	lw	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	e95ff0ef          	jal	534 <printint>
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bf8d                	j	61a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 6aa:	06400793          	li	a5,100
 6ae:	02f68963          	beq	a3,a5,6e0 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b2:	06c00793          	li	a5,108
 6b6:	04f68263          	beq	a3,a5,6fa <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 6ba:	07500793          	li	a5,117
 6be:	0af68063          	beq	a3,a5,75e <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 6c2:	07800793          	li	a5,120
 6c6:	0ef68263          	beq	a3,a5,7aa <vprintf+0x1da>
        putc(fd, '%');
 6ca:	02500593          	li	a1,37
 6ce:	855a                	mv	a0,s6
 6d0:	e47ff0ef          	jal	516 <putc>
        putc(fd, c0);
 6d4:	85ca                	mv	a1,s2
 6d6:	855a                	mv	a0,s6
 6d8:	e3fff0ef          	jal	516 <putc>
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	bf35                	j	61a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	4685                	li	a3,1
 6e6:	4629                	li	a2,10
 6e8:	000bb583          	ld	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	e47ff0ef          	jal	534 <printint>
        i += 1;
 6f2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
        i += 1;
 6f8:	b70d                	j	61a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6fa:	06400793          	li	a5,100
 6fe:	02f60763          	beq	a2,a5,72c <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 702:	07500793          	li	a5,117
 706:	06f60963          	beq	a2,a5,778 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 70a:	07800793          	li	a5,120
 70e:	faf61ee3          	bne	a2,a5,6ca <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 712:	008b8913          	addi	s2,s7,8
 716:	4681                	li	a3,0
 718:	4641                	li	a2,16
 71a:	000bb583          	ld	a1,0(s7)
 71e:	855a                	mv	a0,s6
 720:	e15ff0ef          	jal	534 <printint>
        i += 2;
 724:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 726:	8bca                	mv	s7,s2
      state = 0;
 728:	4981                	li	s3,0
        i += 2;
 72a:	bdc5                	j	61a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 72c:	008b8913          	addi	s2,s7,8
 730:	4685                	li	a3,1
 732:	4629                	li	a2,10
 734:	000bb583          	ld	a1,0(s7)
 738:	855a                	mv	a0,s6
 73a:	dfbff0ef          	jal	534 <printint>
        i += 2;
 73e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 740:	8bca                	mv	s7,s2
      state = 0;
 742:	4981                	li	s3,0
        i += 2;
 744:	bdd9                	j	61a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 746:	008b8913          	addi	s2,s7,8
 74a:	4681                	li	a3,0
 74c:	4629                	li	a2,10
 74e:	000be583          	lwu	a1,0(s7)
 752:	855a                	mv	a0,s6
 754:	de1ff0ef          	jal	534 <printint>
 758:	8bca                	mv	s7,s2
      state = 0;
 75a:	4981                	li	s3,0
 75c:	bd7d                	j	61a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 75e:	008b8913          	addi	s2,s7,8
 762:	4681                	li	a3,0
 764:	4629                	li	a2,10
 766:	000bb583          	ld	a1,0(s7)
 76a:	855a                	mv	a0,s6
 76c:	dc9ff0ef          	jal	534 <printint>
        i += 1;
 770:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 772:	8bca                	mv	s7,s2
      state = 0;
 774:	4981                	li	s3,0
        i += 1;
 776:	b555                	j	61a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 778:	008b8913          	addi	s2,s7,8
 77c:	4681                	li	a3,0
 77e:	4629                	li	a2,10
 780:	000bb583          	ld	a1,0(s7)
 784:	855a                	mv	a0,s6
 786:	dafff0ef          	jal	534 <printint>
        i += 2;
 78a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 78c:	8bca                	mv	s7,s2
      state = 0;
 78e:	4981                	li	s3,0
        i += 2;
 790:	b569                	j	61a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 792:	008b8913          	addi	s2,s7,8
 796:	4681                	li	a3,0
 798:	4641                	li	a2,16
 79a:	000be583          	lwu	a1,0(s7)
 79e:	855a                	mv	a0,s6
 7a0:	d95ff0ef          	jal	534 <printint>
 7a4:	8bca                	mv	s7,s2
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	bd8d                	j	61a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7aa:	008b8913          	addi	s2,s7,8
 7ae:	4681                	li	a3,0
 7b0:	4641                	li	a2,16
 7b2:	000bb583          	ld	a1,0(s7)
 7b6:	855a                	mv	a0,s6
 7b8:	d7dff0ef          	jal	534 <printint>
        i += 1;
 7bc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7be:	8bca                	mv	s7,s2
      state = 0;
 7c0:	4981                	li	s3,0
        i += 1;
 7c2:	bda1                	j	61a <vprintf+0x4a>
 7c4:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7c6:	008b8d13          	addi	s10,s7,8
 7ca:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7ce:	03000593          	li	a1,48
 7d2:	855a                	mv	a0,s6
 7d4:	d43ff0ef          	jal	516 <putc>
  putc(fd, 'x');
 7d8:	07800593          	li	a1,120
 7dc:	855a                	mv	a0,s6
 7de:	d39ff0ef          	jal	516 <putc>
 7e2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7e4:	00000b97          	auipc	s7,0x0
 7e8:	334b8b93          	addi	s7,s7,820 # b18 <digits>
 7ec:	03c9d793          	srli	a5,s3,0x3c
 7f0:	97de                	add	a5,a5,s7
 7f2:	0007c583          	lbu	a1,0(a5)
 7f6:	855a                	mv	a0,s6
 7f8:	d1fff0ef          	jal	516 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7fc:	0992                	slli	s3,s3,0x4
 7fe:	397d                	addiw	s2,s2,-1
 800:	fe0916e3          	bnez	s2,7ec <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 804:	8bea                	mv	s7,s10
      state = 0;
 806:	4981                	li	s3,0
 808:	6d02                	ld	s10,0(sp)
 80a:	bd01                	j	61a <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 80c:	008b8913          	addi	s2,s7,8
 810:	000bc583          	lbu	a1,0(s7)
 814:	855a                	mv	a0,s6
 816:	d01ff0ef          	jal	516 <putc>
 81a:	8bca                	mv	s7,s2
      state = 0;
 81c:	4981                	li	s3,0
 81e:	bbf5                	j	61a <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 820:	008b8993          	addi	s3,s7,8
 824:	000bb903          	ld	s2,0(s7)
 828:	00090f63          	beqz	s2,846 <vprintf+0x276>
        for(; *s; s++)
 82c:	00094583          	lbu	a1,0(s2)
 830:	c195                	beqz	a1,854 <vprintf+0x284>
          putc(fd, *s);
 832:	855a                	mv	a0,s6
 834:	ce3ff0ef          	jal	516 <putc>
        for(; *s; s++)
 838:	0905                	addi	s2,s2,1
 83a:	00094583          	lbu	a1,0(s2)
 83e:	f9f5                	bnez	a1,832 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 840:	8bce                	mv	s7,s3
      state = 0;
 842:	4981                	li	s3,0
 844:	bbd9                	j	61a <vprintf+0x4a>
          s = "(null)";
 846:	00000917          	auipc	s2,0x0
 84a:	2ca90913          	addi	s2,s2,714 # b10 <malloc+0x1be>
        for(; *s; s++)
 84e:	02800593          	li	a1,40
 852:	b7c5                	j	832 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 854:	8bce                	mv	s7,s3
      state = 0;
 856:	4981                	li	s3,0
 858:	b3c9                	j	61a <vprintf+0x4a>
 85a:	64a6                	ld	s1,72(sp)
 85c:	79e2                	ld	s3,56(sp)
 85e:	7a42                	ld	s4,48(sp)
 860:	7aa2                	ld	s5,40(sp)
 862:	7b02                	ld	s6,32(sp)
 864:	6be2                	ld	s7,24(sp)
 866:	6c42                	ld	s8,16(sp)
 868:	6ca2                	ld	s9,8(sp)
    }
  }
}
 86a:	60e6                	ld	ra,88(sp)
 86c:	6446                	ld	s0,80(sp)
 86e:	6906                	ld	s2,64(sp)
 870:	6125                	addi	sp,sp,96
 872:	8082                	ret

0000000000000874 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 874:	715d                	addi	sp,sp,-80
 876:	ec06                	sd	ra,24(sp)
 878:	e822                	sd	s0,16(sp)
 87a:	1000                	addi	s0,sp,32
 87c:	e010                	sd	a2,0(s0)
 87e:	e414                	sd	a3,8(s0)
 880:	e818                	sd	a4,16(s0)
 882:	ec1c                	sd	a5,24(s0)
 884:	03043023          	sd	a6,32(s0)
 888:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 88c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 890:	8622                	mv	a2,s0
 892:	d3fff0ef          	jal	5d0 <vprintf>
}
 896:	60e2                	ld	ra,24(sp)
 898:	6442                	ld	s0,16(sp)
 89a:	6161                	addi	sp,sp,80
 89c:	8082                	ret

000000000000089e <printf>:

void
printf(const char *fmt, ...)
{
 89e:	711d                	addi	sp,sp,-96
 8a0:	ec06                	sd	ra,24(sp)
 8a2:	e822                	sd	s0,16(sp)
 8a4:	1000                	addi	s0,sp,32
 8a6:	e40c                	sd	a1,8(s0)
 8a8:	e810                	sd	a2,16(s0)
 8aa:	ec14                	sd	a3,24(s0)
 8ac:	f018                	sd	a4,32(s0)
 8ae:	f41c                	sd	a5,40(s0)
 8b0:	03043823          	sd	a6,48(s0)
 8b4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8b8:	00840613          	addi	a2,s0,8
 8bc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8c0:	85aa                	mv	a1,a0
 8c2:	4505                	li	a0,1
 8c4:	d0dff0ef          	jal	5d0 <vprintf>
}
 8c8:	60e2                	ld	ra,24(sp)
 8ca:	6442                	ld	s0,16(sp)
 8cc:	6125                	addi	sp,sp,96
 8ce:	8082                	ret

00000000000008d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8d0:	1141                	addi	sp,sp,-16
 8d2:	e422                	sd	s0,8(sp)
 8d4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8d6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8da:	00000797          	auipc	a5,0x0
 8de:	72e7b783          	ld	a5,1838(a5) # 1008 <freep>
 8e2:	a02d                	j	90c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8e4:	4618                	lw	a4,8(a2)
 8e6:	9f2d                	addw	a4,a4,a1
 8e8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ec:	6398                	ld	a4,0(a5)
 8ee:	6310                	ld	a2,0(a4)
 8f0:	a83d                	j	92e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8f2:	ff852703          	lw	a4,-8(a0)
 8f6:	9f31                	addw	a4,a4,a2
 8f8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8fa:	ff053683          	ld	a3,-16(a0)
 8fe:	a091                	j	942 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 900:	6398                	ld	a4,0(a5)
 902:	00e7e463          	bltu	a5,a4,90a <free+0x3a>
 906:	00e6ea63          	bltu	a3,a4,91a <free+0x4a>
{
 90a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90c:	fed7fae3          	bgeu	a5,a3,900 <free+0x30>
 910:	6398                	ld	a4,0(a5)
 912:	00e6e463          	bltu	a3,a4,91a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 916:	fee7eae3          	bltu	a5,a4,90a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 91a:	ff852583          	lw	a1,-8(a0)
 91e:	6390                	ld	a2,0(a5)
 920:	02059813          	slli	a6,a1,0x20
 924:	01c85713          	srli	a4,a6,0x1c
 928:	9736                	add	a4,a4,a3
 92a:	fae60de3          	beq	a2,a4,8e4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 92e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 932:	4790                	lw	a2,8(a5)
 934:	02061593          	slli	a1,a2,0x20
 938:	01c5d713          	srli	a4,a1,0x1c
 93c:	973e                	add	a4,a4,a5
 93e:	fae68ae3          	beq	a3,a4,8f2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 942:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 944:	00000717          	auipc	a4,0x0
 948:	6cf73223          	sd	a5,1732(a4) # 1008 <freep>
}
 94c:	6422                	ld	s0,8(sp)
 94e:	0141                	addi	sp,sp,16
 950:	8082                	ret

0000000000000952 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 952:	7139                	addi	sp,sp,-64
 954:	fc06                	sd	ra,56(sp)
 956:	f822                	sd	s0,48(sp)
 958:	f426                	sd	s1,40(sp)
 95a:	ec4e                	sd	s3,24(sp)
 95c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 95e:	02051493          	slli	s1,a0,0x20
 962:	9081                	srli	s1,s1,0x20
 964:	04bd                	addi	s1,s1,15
 966:	8091                	srli	s1,s1,0x4
 968:	0014899b          	addiw	s3,s1,1
 96c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 96e:	00000517          	auipc	a0,0x0
 972:	69a53503          	ld	a0,1690(a0) # 1008 <freep>
 976:	c915                	beqz	a0,9aa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 978:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 97a:	4798                	lw	a4,8(a5)
 97c:	08977a63          	bgeu	a4,s1,a10 <malloc+0xbe>
 980:	f04a                	sd	s2,32(sp)
 982:	e852                	sd	s4,16(sp)
 984:	e456                	sd	s5,8(sp)
 986:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 988:	8a4e                	mv	s4,s3
 98a:	0009871b          	sext.w	a4,s3
 98e:	6685                	lui	a3,0x1
 990:	00d77363          	bgeu	a4,a3,996 <malloc+0x44>
 994:	6a05                	lui	s4,0x1
 996:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 99a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 99e:	00000917          	auipc	s2,0x0
 9a2:	66a90913          	addi	s2,s2,1642 # 1008 <freep>
  if(p == SBRK_ERROR)
 9a6:	5afd                	li	s5,-1
 9a8:	a081                	j	9e8 <malloc+0x96>
 9aa:	f04a                	sd	s2,32(sp)
 9ac:	e852                	sd	s4,16(sp)
 9ae:	e456                	sd	s5,8(sp)
 9b0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9b2:	00000797          	auipc	a5,0x0
 9b6:	65e78793          	addi	a5,a5,1630 # 1010 <base>
 9ba:	00000717          	auipc	a4,0x0
 9be:	64f73723          	sd	a5,1614(a4) # 1008 <freep>
 9c2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9c4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9c8:	b7c1                	j	988 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9ca:	6398                	ld	a4,0(a5)
 9cc:	e118                	sd	a4,0(a0)
 9ce:	a8a9                	j	a28 <malloc+0xd6>
  hp->s.size = nu;
 9d0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9d4:	0541                	addi	a0,a0,16
 9d6:	efbff0ef          	jal	8d0 <free>
  return freep;
 9da:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9de:	c12d                	beqz	a0,a40 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e2:	4798                	lw	a4,8(a5)
 9e4:	02977263          	bgeu	a4,s1,a08 <malloc+0xb6>
    if(p == freep)
 9e8:	00093703          	ld	a4,0(s2)
 9ec:	853e                	mv	a0,a5
 9ee:	fef719e3          	bne	a4,a5,9e0 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9f2:	8552                	mv	a0,s4
 9f4:	9cdff0ef          	jal	3c0 <sbrk>
  if(p == SBRK_ERROR)
 9f8:	fd551ce3          	bne	a0,s5,9d0 <malloc+0x7e>
        return 0;
 9fc:	4501                	li	a0,0
 9fe:	7902                	ld	s2,32(sp)
 a00:	6a42                	ld	s4,16(sp)
 a02:	6aa2                	ld	s5,8(sp)
 a04:	6b02                	ld	s6,0(sp)
 a06:	a03d                	j	a34 <malloc+0xe2>
 a08:	7902                	ld	s2,32(sp)
 a0a:	6a42                	ld	s4,16(sp)
 a0c:	6aa2                	ld	s5,8(sp)
 a0e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a10:	fae48de3          	beq	s1,a4,9ca <malloc+0x78>
        p->s.size -= nunits;
 a14:	4137073b          	subw	a4,a4,s3
 a18:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a1a:	02071693          	slli	a3,a4,0x20
 a1e:	01c6d713          	srli	a4,a3,0x1c
 a22:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a24:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a28:	00000717          	auipc	a4,0x0
 a2c:	5ea73023          	sd	a0,1504(a4) # 1008 <freep>
      return (void*)(p + 1);
 a30:	01078513          	addi	a0,a5,16
  }
}
 a34:	70e2                	ld	ra,56(sp)
 a36:	7442                	ld	s0,48(sp)
 a38:	74a2                	ld	s1,40(sp)
 a3a:	69e2                	ld	s3,24(sp)
 a3c:	6121                	addi	sp,sp,64
 a3e:	8082                	ret
 a40:	7902                	ld	s2,32(sp)
 a42:	6a42                	ld	s4,16(sp)
 a44:	6aa2                	ld	s5,8(sp)
 a46:	6b02                	ld	s6,0(sp)
 a48:	b7f5                	j	a34 <malloc+0xe2>
