
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
   a:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   c:	2b8000ef          	jal	2c4 <strlen>
  10:	02051793          	slli	a5,a0,0x20
  14:	9381                	srli	a5,a5,0x20
  16:	97a6                	add	a5,a5,s1
  18:	02f00693          	li	a3,47
  1c:	0097e963          	bltu	a5,s1,2e <fmtname+0x2e>
  20:	0007c703          	lbu	a4,0(a5)
  24:	00d70563          	beq	a4,a3,2e <fmtname+0x2e>
  28:	17fd                	addi	a5,a5,-1
  2a:	fe97fbe3          	bgeu	a5,s1,20 <fmtname+0x20>
    ;
  p++;
  2e:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  32:	8526                	mv	a0,s1
  34:	290000ef          	jal	2c4 <strlen>
  38:	2501                	sext.w	a0,a0
  3a:	47b5                	li	a5,13
  3c:	00a7f863          	bgeu	a5,a0,4c <fmtname+0x4c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';
  return buf;
}
  40:	8526                	mv	a0,s1
  42:	70a2                	ld	ra,40(sp)
  44:	7402                	ld	s0,32(sp)
  46:	64e2                	ld	s1,24(sp)
  48:	6145                	addi	sp,sp,48
  4a:	8082                	ret
  4c:	e84a                	sd	s2,16(sp)
  4e:	e44e                	sd	s3,8(sp)
  memmove(buf, p, strlen(p));
  50:	8526                	mv	a0,s1
  52:	272000ef          	jal	2c4 <strlen>
  56:	00002997          	auipc	s3,0x2
  5a:	fba98993          	addi	s3,s3,-70 # 2010 <buf.0>
  5e:	0005061b          	sext.w	a2,a0
  62:	85a6                	mv	a1,s1
  64:	854e                	mv	a0,s3
  66:	3c0000ef          	jal	426 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6a:	8526                	mv	a0,s1
  6c:	258000ef          	jal	2c4 <strlen>
  70:	0005091b          	sext.w	s2,a0
  74:	8526                	mv	a0,s1
  76:	24e000ef          	jal	2c4 <strlen>
  7a:	1902                	slli	s2,s2,0x20
  7c:	02095913          	srli	s2,s2,0x20
  80:	4639                	li	a2,14
  82:	9e09                	subw	a2,a2,a0
  84:	02000593          	li	a1,32
  88:	01298533          	add	a0,s3,s2
  8c:	262000ef          	jal	2ee <memset>
  buf[sizeof(buf)-1] = '\0';
  90:	00098723          	sb	zero,14(s3)
  return buf;
  94:	84ce                	mv	s1,s3
  96:	6942                	ld	s2,16(sp)
  98:	69a2                	ld	s3,8(sp)
  9a:	b75d                	j	40 <fmtname+0x40>

000000000000009c <ls>:

void
ls(char *path)
{
  9c:	d9010113          	addi	sp,sp,-624
  a0:	26113423          	sd	ra,616(sp)
  a4:	26813023          	sd	s0,608(sp)
  a8:	25213823          	sd	s2,592(sp)
  ac:	1c80                	addi	s0,sp,624
  ae:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, O_RDONLY)) < 0){
  b0:	4581                	li	a1,0
  b2:	496000ef          	jal	548 <open>
  b6:	06054363          	bltz	a0,11c <ls+0x80>
  ba:	24913c23          	sd	s1,600(sp)
  be:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  c0:	d9840593          	addi	a1,s0,-616
  c4:	49c000ef          	jal	560 <fstat>
  c8:	06054363          	bltz	a0,12e <ls+0x92>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  cc:	da041783          	lh	a5,-608(s0)
  d0:	4705                	li	a4,1
  d2:	06e78c63          	beq	a5,a4,14a <ls+0xae>
  d6:	37f9                	addiw	a5,a5,-2
  d8:	17c2                	slli	a5,a5,0x30
  da:	93c1                	srli	a5,a5,0x30
  dc:	02f76263          	bltu	a4,a5,100 <ls+0x64>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
  e0:	854a                	mv	a0,s2
  e2:	f1fff0ef          	jal	0 <fmtname>
  e6:	85aa                	mv	a1,a0
  e8:	da842703          	lw	a4,-600(s0)
  ec:	d9c42683          	lw	a3,-612(s0)
  f0:	da041603          	lh	a2,-608(s0)
  f4:	00001517          	auipc	a0,0x1
  f8:	a9c50513          	addi	a0,a0,-1380 # b90 <malloc+0x132>
  fc:	0af000ef          	jal	9aa <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
    }
    break;
  }
  close(fd);
 100:	8526                	mv	a0,s1
 102:	42e000ef          	jal	530 <close>
 106:	25813483          	ld	s1,600(sp)
}
 10a:	26813083          	ld	ra,616(sp)
 10e:	26013403          	ld	s0,608(sp)
 112:	25013903          	ld	s2,592(sp)
 116:	27010113          	addi	sp,sp,624
 11a:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 11c:	864a                	mv	a2,s2
 11e:	00001597          	auipc	a1,0x1
 122:	a4258593          	addi	a1,a1,-1470 # b60 <malloc+0x102>
 126:	4509                	li	a0,2
 128:	059000ef          	jal	980 <fprintf>
    return;
 12c:	bff9                	j	10a <ls+0x6e>
    fprintf(2, "ls: cannot stat %s\n", path);
 12e:	864a                	mv	a2,s2
 130:	00001597          	auipc	a1,0x1
 134:	a4858593          	addi	a1,a1,-1464 # b78 <malloc+0x11a>
 138:	4509                	li	a0,2
 13a:	047000ef          	jal	980 <fprintf>
    close(fd);
 13e:	8526                	mv	a0,s1
 140:	3f0000ef          	jal	530 <close>
    return;
 144:	25813483          	ld	s1,600(sp)
 148:	b7c9                	j	10a <ls+0x6e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 14a:	854a                	mv	a0,s2
 14c:	178000ef          	jal	2c4 <strlen>
 150:	2541                	addiw	a0,a0,16
 152:	20000793          	li	a5,512
 156:	00a7f963          	bgeu	a5,a0,168 <ls+0xcc>
      printf("ls: path too long\n");
 15a:	00001517          	auipc	a0,0x1
 15e:	a4650513          	addi	a0,a0,-1466 # ba0 <malloc+0x142>
 162:	049000ef          	jal	9aa <printf>
      break;
 166:	bf69                	j	100 <ls+0x64>
 168:	25313423          	sd	s3,584(sp)
 16c:	25413023          	sd	s4,576(sp)
 170:	23513c23          	sd	s5,568(sp)
    strcpy(buf, path);
 174:	85ca                	mv	a1,s2
 176:	dc040513          	addi	a0,s0,-576
 17a:	102000ef          	jal	27c <strcpy>
    p = buf+strlen(buf);
 17e:	dc040513          	addi	a0,s0,-576
 182:	142000ef          	jal	2c4 <strlen>
 186:	1502                	slli	a0,a0,0x20
 188:	9101                	srli	a0,a0,0x20
 18a:	dc040793          	addi	a5,s0,-576
 18e:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 192:	00190993          	addi	s3,s2,1
 196:	02f00793          	li	a5,47
 19a:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 19e:	00001a17          	auipc	s4,0x1
 1a2:	9f2a0a13          	addi	s4,s4,-1550 # b90 <malloc+0x132>
        printf("ls: cannot stat %s\n", buf);
 1a6:	00001a97          	auipc	s5,0x1
 1aa:	9d2a8a93          	addi	s5,s5,-1582 # b78 <malloc+0x11a>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ae:	a031                	j	1ba <ls+0x11e>
        printf("ls: cannot stat %s\n", buf);
 1b0:	dc040593          	addi	a1,s0,-576
 1b4:	8556                	mv	a0,s5
 1b6:	7f4000ef          	jal	9aa <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ba:	4641                	li	a2,16
 1bc:	db040593          	addi	a1,s0,-592
 1c0:	8526                	mv	a0,s1
 1c2:	35e000ef          	jal	520 <read>
 1c6:	47c1                	li	a5,16
 1c8:	04f51463          	bne	a0,a5,210 <ls+0x174>
      if(de.inum == 0)
 1cc:	db045783          	lhu	a5,-592(s0)
 1d0:	d7ed                	beqz	a5,1ba <ls+0x11e>
      memmove(p, de.name, DIRSIZ);
 1d2:	4639                	li	a2,14
 1d4:	db240593          	addi	a1,s0,-590
 1d8:	854e                	mv	a0,s3
 1da:	24c000ef          	jal	426 <memmove>
      p[DIRSIZ] = 0;
 1de:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 1e2:	d9840593          	addi	a1,s0,-616
 1e6:	dc040513          	addi	a0,s0,-576
 1ea:	1ba000ef          	jal	3a4 <stat>
 1ee:	fc0541e3          	bltz	a0,1b0 <ls+0x114>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 1f2:	dc040513          	addi	a0,s0,-576
 1f6:	e0bff0ef          	jal	0 <fmtname>
 1fa:	85aa                	mv	a1,a0
 1fc:	da842703          	lw	a4,-600(s0)
 200:	d9c42683          	lw	a3,-612(s0)
 204:	da041603          	lh	a2,-608(s0)
 208:	8552                	mv	a0,s4
 20a:	7a0000ef          	jal	9aa <printf>
 20e:	b775                	j	1ba <ls+0x11e>
 210:	24813983          	ld	s3,584(sp)
 214:	24013a03          	ld	s4,576(sp)
 218:	23813a83          	ld	s5,568(sp)
 21c:	b5d5                	j	100 <ls+0x64>

000000000000021e <main>:

int
main(int argc, char *argv[])
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 226:	4785                	li	a5,1
 228:	02a7d763          	bge	a5,a0,256 <main+0x38>
 22c:	e426                	sd	s1,8(sp)
 22e:	e04a                	sd	s2,0(sp)
 230:	00858493          	addi	s1,a1,8
 234:	ffe5091b          	addiw	s2,a0,-2
 238:	02091793          	slli	a5,s2,0x20
 23c:	01d7d913          	srli	s2,a5,0x1d
 240:	05c1                	addi	a1,a1,16
 242:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 244:	6088                	ld	a0,0(s1)
 246:	e57ff0ef          	jal	9c <ls>
  for(i=1; i<argc; i++)
 24a:	04a1                	addi	s1,s1,8
 24c:	ff249ce3          	bne	s1,s2,244 <main+0x26>
  exit(0);
 250:	4501                	li	a0,0
 252:	2ae000ef          	jal	500 <exit>
 256:	e426                	sd	s1,8(sp)
 258:	e04a                	sd	s2,0(sp)
    ls(".");
 25a:	00001517          	auipc	a0,0x1
 25e:	95e50513          	addi	a0,a0,-1698 # bb8 <malloc+0x15a>
 262:	e3bff0ef          	jal	9c <ls>
    exit(0);
 266:	4501                	li	a0,0
 268:	298000ef          	jal	500 <exit>

000000000000026c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 274:	fabff0ef          	jal	21e <main>
  exit(r);
 278:	288000ef          	jal	500 <exit>

000000000000027c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 282:	87aa                	mv	a5,a0
 284:	0585                	addi	a1,a1,1
 286:	0785                	addi	a5,a5,1
 288:	fff5c703          	lbu	a4,-1(a1)
 28c:	fee78fa3          	sb	a4,-1(a5)
 290:	fb75                	bnez	a4,284 <strcpy+0x8>
    ;
  return os;
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret

0000000000000298 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	cb91                	beqz	a5,2b6 <strcmp+0x1e>
 2a4:	0005c703          	lbu	a4,0(a1)
 2a8:	00f71763          	bne	a4,a5,2b6 <strcmp+0x1e>
    p++, q++;
 2ac:	0505                	addi	a0,a0,1
 2ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	fbe5                	bnez	a5,2a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b6:	0005c503          	lbu	a0,0(a1)
}
 2ba:	40a7853b          	subw	a0,a5,a0
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <strlen>:

uint
strlen(const char *s)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	cf91                	beqz	a5,2ea <strlen+0x26>
 2d0:	0505                	addi	a0,a0,1
 2d2:	87aa                	mv	a5,a0
 2d4:	86be                	mv	a3,a5
 2d6:	0785                	addi	a5,a5,1
 2d8:	fff7c703          	lbu	a4,-1(a5)
 2dc:	ff65                	bnez	a4,2d4 <strlen+0x10>
 2de:	40a6853b          	subw	a0,a3,a0
 2e2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  for(n = 0; s[n]; n++)
 2ea:	4501                	li	a0,0
 2ec:	bfe5                	j	2e4 <strlen+0x20>

00000000000002ee <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f4:	ca19                	beqz	a2,30a <memset+0x1c>
 2f6:	87aa                	mv	a5,a0
 2f8:	1602                	slli	a2,a2,0x20
 2fa:	9201                	srli	a2,a2,0x20
 2fc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 300:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 304:	0785                	addi	a5,a5,1
 306:	fee79de3          	bne	a5,a4,300 <memset+0x12>
  }
  return dst;
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret

0000000000000310 <strchr>:

char*
strchr(const char *s, char c)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  for(; *s; s++)
 316:	00054783          	lbu	a5,0(a0)
 31a:	cb99                	beqz	a5,330 <strchr+0x20>
    if(*s == c)
 31c:	00f58763          	beq	a1,a5,32a <strchr+0x1a>
  for(; *s; s++)
 320:	0505                	addi	a0,a0,1
 322:	00054783          	lbu	a5,0(a0)
 326:	fbfd                	bnez	a5,31c <strchr+0xc>
      return (char*)s;
  return 0;
 328:	4501                	li	a0,0
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  return 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <strchr+0x1a>

0000000000000334 <gets>:

char*
gets(char *buf, int max)
{
 334:	711d                	addi	sp,sp,-96
 336:	ec86                	sd	ra,88(sp)
 338:	e8a2                	sd	s0,80(sp)
 33a:	e4a6                	sd	s1,72(sp)
 33c:	e0ca                	sd	s2,64(sp)
 33e:	fc4e                	sd	s3,56(sp)
 340:	f852                	sd	s4,48(sp)
 342:	f456                	sd	s5,40(sp)
 344:	f05a                	sd	s6,32(sp)
 346:	ec5e                	sd	s7,24(sp)
 348:	1080                	addi	s0,sp,96
 34a:	8baa                	mv	s7,a0
 34c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34e:	892a                	mv	s2,a0
 350:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 352:	4aa9                	li	s5,10
 354:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 356:	89a6                	mv	s3,s1
 358:	2485                	addiw	s1,s1,1
 35a:	0344d663          	bge	s1,s4,386 <gets+0x52>
    cc = read(0, &c, 1);
 35e:	4605                	li	a2,1
 360:	faf40593          	addi	a1,s0,-81
 364:	4501                	li	a0,0
 366:	1ba000ef          	jal	520 <read>
    if(cc < 1)
 36a:	00a05e63          	blez	a0,386 <gets+0x52>
    buf[i++] = c;
 36e:	faf44783          	lbu	a5,-81(s0)
 372:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 376:	01578763          	beq	a5,s5,384 <gets+0x50>
 37a:	0905                	addi	s2,s2,1
 37c:	fd679de3          	bne	a5,s6,356 <gets+0x22>
    buf[i++] = c;
 380:	89a6                	mv	s3,s1
 382:	a011                	j	386 <gets+0x52>
 384:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 386:	99de                	add	s3,s3,s7
 388:	00098023          	sb	zero,0(s3)
  return buf;
}
 38c:	855e                	mv	a0,s7
 38e:	60e6                	ld	ra,88(sp)
 390:	6446                	ld	s0,80(sp)
 392:	64a6                	ld	s1,72(sp)
 394:	6906                	ld	s2,64(sp)
 396:	79e2                	ld	s3,56(sp)
 398:	7a42                	ld	s4,48(sp)
 39a:	7aa2                	ld	s5,40(sp)
 39c:	7b02                	ld	s6,32(sp)
 39e:	6be2                	ld	s7,24(sp)
 3a0:	6125                	addi	sp,sp,96
 3a2:	8082                	ret

00000000000003a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	e04a                	sd	s2,0(sp)
 3ac:	1000                	addi	s0,sp,32
 3ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b0:	4581                	li	a1,0
 3b2:	196000ef          	jal	548 <open>
  if(fd < 0)
 3b6:	02054263          	bltz	a0,3da <stat+0x36>
 3ba:	e426                	sd	s1,8(sp)
 3bc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3be:	85ca                	mv	a1,s2
 3c0:	1a0000ef          	jal	560 <fstat>
 3c4:	892a                	mv	s2,a0
  close(fd);
 3c6:	8526                	mv	a0,s1
 3c8:	168000ef          	jal	530 <close>
  return r;
 3cc:	64a2                	ld	s1,8(sp)
}
 3ce:	854a                	mv	a0,s2
 3d0:	60e2                	ld	ra,24(sp)
 3d2:	6442                	ld	s0,16(sp)
 3d4:	6902                	ld	s2,0(sp)
 3d6:	6105                	addi	sp,sp,32
 3d8:	8082                	ret
    return -1;
 3da:	597d                	li	s2,-1
 3dc:	bfcd                	j	3ce <stat+0x2a>

00000000000003de <atoi>:

int
atoi(const char *s)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e4:	00054683          	lbu	a3,0(a0)
 3e8:	fd06879b          	addiw	a5,a3,-48
 3ec:	0ff7f793          	zext.b	a5,a5
 3f0:	4625                	li	a2,9
 3f2:	02f66863          	bltu	a2,a5,422 <atoi+0x44>
 3f6:	872a                	mv	a4,a0
  n = 0;
 3f8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3fa:	0705                	addi	a4,a4,1
 3fc:	0025179b          	slliw	a5,a0,0x2
 400:	9fa9                	addw	a5,a5,a0
 402:	0017979b          	slliw	a5,a5,0x1
 406:	9fb5                	addw	a5,a5,a3
 408:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 40c:	00074683          	lbu	a3,0(a4)
 410:	fd06879b          	addiw	a5,a3,-48
 414:	0ff7f793          	zext.b	a5,a5
 418:	fef671e3          	bgeu	a2,a5,3fa <atoi+0x1c>
  return n;
}
 41c:	6422                	ld	s0,8(sp)
 41e:	0141                	addi	sp,sp,16
 420:	8082                	ret
  n = 0;
 422:	4501                	li	a0,0
 424:	bfe5                	j	41c <atoi+0x3e>

0000000000000426 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42c:	02b57463          	bgeu	a0,a1,454 <memmove+0x2e>
    while(n-- > 0)
 430:	00c05f63          	blez	a2,44e <memmove+0x28>
 434:	1602                	slli	a2,a2,0x20
 436:	9201                	srli	a2,a2,0x20
 438:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43c:	872a                	mv	a4,a0
      *dst++ = *src++;
 43e:	0585                	addi	a1,a1,1
 440:	0705                	addi	a4,a4,1
 442:	fff5c683          	lbu	a3,-1(a1)
 446:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 44a:	fef71ae3          	bne	a4,a5,43e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44e:	6422                	ld	s0,8(sp)
 450:	0141                	addi	sp,sp,16
 452:	8082                	ret
    dst += n;
 454:	00c50733          	add	a4,a0,a2
    src += n;
 458:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 45a:	fec05ae3          	blez	a2,44e <memmove+0x28>
 45e:	fff6079b          	addiw	a5,a2,-1
 462:	1782                	slli	a5,a5,0x20
 464:	9381                	srli	a5,a5,0x20
 466:	fff7c793          	not	a5,a5
 46a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46c:	15fd                	addi	a1,a1,-1
 46e:	177d                	addi	a4,a4,-1
 470:	0005c683          	lbu	a3,0(a1)
 474:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 478:	fee79ae3          	bne	a5,a4,46c <memmove+0x46>
 47c:	bfc9                	j	44e <memmove+0x28>

000000000000047e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 484:	ca05                	beqz	a2,4b4 <memcmp+0x36>
 486:	fff6069b          	addiw	a3,a2,-1
 48a:	1682                	slli	a3,a3,0x20
 48c:	9281                	srli	a3,a3,0x20
 48e:	0685                	addi	a3,a3,1
 490:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 492:	00054783          	lbu	a5,0(a0)
 496:	0005c703          	lbu	a4,0(a1)
 49a:	00e79863          	bne	a5,a4,4aa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 49e:	0505                	addi	a0,a0,1
    p2++;
 4a0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a2:	fed518e3          	bne	a0,a3,492 <memcmp+0x14>
  }
  return 0;
 4a6:	4501                	li	a0,0
 4a8:	a019                	j	4ae <memcmp+0x30>
      return *p1 - *p2;
 4aa:	40e7853b          	subw	a0,a5,a4
}
 4ae:	6422                	ld	s0,8(sp)
 4b0:	0141                	addi	sp,sp,16
 4b2:	8082                	ret
  return 0;
 4b4:	4501                	li	a0,0
 4b6:	bfe5                	j	4ae <memcmp+0x30>

00000000000004b8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4b8:	1141                	addi	sp,sp,-16
 4ba:	e406                	sd	ra,8(sp)
 4bc:	e022                	sd	s0,0(sp)
 4be:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4c0:	f67ff0ef          	jal	426 <memmove>
}
 4c4:	60a2                	ld	ra,8(sp)
 4c6:	6402                	ld	s0,0(sp)
 4c8:	0141                	addi	sp,sp,16
 4ca:	8082                	ret

00000000000004cc <sbrk>:

char *
sbrk(int n) {
 4cc:	1141                	addi	sp,sp,-16
 4ce:	e406                	sd	ra,8(sp)
 4d0:	e022                	sd	s0,0(sp)
 4d2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d4:	4585                	li	a1,1
 4d6:	0ba000ef          	jal	590 <sys_sbrk>
}
 4da:	60a2                	ld	ra,8(sp)
 4dc:	6402                	ld	s0,0(sp)
 4de:	0141                	addi	sp,sp,16
 4e0:	8082                	ret

00000000000004e2 <sbrklazy>:

char *
sbrklazy(int n) {
 4e2:	1141                	addi	sp,sp,-16
 4e4:	e406                	sd	ra,8(sp)
 4e6:	e022                	sd	s0,0(sp)
 4e8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ea:	4589                	li	a1,2
 4ec:	0a4000ef          	jal	590 <sys_sbrk>
}
 4f0:	60a2                	ld	ra,8(sp)
 4f2:	6402                	ld	s0,0(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret

00000000000004f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f8:	4885                	li	a7,1
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <exit>:
.global exit
exit:
 li a7, SYS_exit
 500:	4889                	li	a7,2
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <wait>:
.global wait
wait:
 li a7, SYS_wait
 508:	488d                	li	a7,3
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 510:	48d9                	li	a7,22
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 518:	4891                	li	a7,4
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <read>:
.global read
read:
 li a7, SYS_read
 520:	4895                	li	a7,5
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <write>:
.global write
write:
 li a7, SYS_write
 528:	48c1                	li	a7,16
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <close>:
.global close
close:
 li a7, SYS_close
 530:	48d5                	li	a7,21
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <kill>:
.global kill
kill:
 li a7, SYS_kill
 538:	4899                	li	a7,6
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <exec>:
.global exec
exec:
 li a7, SYS_exec
 540:	489d                	li	a7,7
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <open>:
.global open
open:
 li a7, SYS_open
 548:	48bd                	li	a7,15
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 550:	48c5                	li	a7,17
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 558:	48c9                	li	a7,18
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 560:	48a1                	li	a7,8
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <link>:
.global link
link:
 li a7, SYS_link
 568:	48cd                	li	a7,19
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 570:	48d1                	li	a7,20
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 578:	48a5                	li	a7,9
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <dup>:
.global dup
dup:
 li a7, SYS_dup
 580:	48a9                	li	a7,10
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 588:	48ad                	li	a7,11
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 590:	48b1                	li	a7,12
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <pause>:
.global pause
pause:
 li a7, SYS_pause
 598:	48b5                	li	a7,13
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5a0:	48b9                	li	a7,14
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 5a8:	48dd                	li	a7,23
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 5b0:	48e1                	li	a7,24
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <mutex_init>:
.global mutex_init
mutex_init:
 li a7, SYS_mutex_init
 5b8:	48e5                	li	a7,25
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <mutex_acquire>:
.global mutex_acquire
mutex_acquire:
 li a7, SYS_mutex_acquire
 5c0:	48e9                	li	a7,26
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <mutex_release>:
.global mutex_release
mutex_release:
 li a7, SYS_mutex_release
 5c8:	48ed                	li	a7,27
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 5d0:	48f1                	li	a7,28
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 5d8:	48f5                	li	a7,29
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 5e0:	48f9                	li	a7,30
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <setp>:
.global setp
setp:
 li a7, SYS_setp
 5e8:	48fd                	li	a7,31
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <ismyear>:
.global ismyear
ismyear:
 li a7, SYS_ismyear
 5f0:	02000893          	li	a7,32
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 5fa:	02100893          	li	a7,33
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 604:	02200893          	li	a7,34
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <thread_exit>:
.global thread_exit
thread_exit:
 li a7, SYS_thread_exit
 60e:	02300893          	li	a7,35
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <thread_id>:
.global thread_id
thread_id:
 li a7, SYS_thread_id
 618:	02400893          	li	a7,36
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 622:	1101                	addi	sp,sp,-32
 624:	ec06                	sd	ra,24(sp)
 626:	e822                	sd	s0,16(sp)
 628:	1000                	addi	s0,sp,32
 62a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 62e:	4605                	li	a2,1
 630:	fef40593          	addi	a1,s0,-17
 634:	ef5ff0ef          	jal	528 <write>
}
 638:	60e2                	ld	ra,24(sp)
 63a:	6442                	ld	s0,16(sp)
 63c:	6105                	addi	sp,sp,32
 63e:	8082                	ret

0000000000000640 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 640:	715d                	addi	sp,sp,-80
 642:	e486                	sd	ra,72(sp)
 644:	e0a2                	sd	s0,64(sp)
 646:	f84a                	sd	s2,48(sp)
 648:	0880                	addi	s0,sp,80
 64a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 64c:	c299                	beqz	a3,652 <printint+0x12>
 64e:	0805c363          	bltz	a1,6d4 <printint+0x94>
  neg = 0;
 652:	4881                	li	a7,0
 654:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 658:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 65a:	00000517          	auipc	a0,0x0
 65e:	56e50513          	addi	a0,a0,1390 # bc8 <digits>
 662:	883e                	mv	a6,a5
 664:	2785                	addiw	a5,a5,1
 666:	02c5f733          	remu	a4,a1,a2
 66a:	972a                	add	a4,a4,a0
 66c:	00074703          	lbu	a4,0(a4)
 670:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 674:	872e                	mv	a4,a1
 676:	02c5d5b3          	divu	a1,a1,a2
 67a:	0685                	addi	a3,a3,1
 67c:	fec773e3          	bgeu	a4,a2,662 <printint+0x22>
  if(neg)
 680:	00088b63          	beqz	a7,696 <printint+0x56>
    buf[i++] = '-';
 684:	fd078793          	addi	a5,a5,-48
 688:	97a2                	add	a5,a5,s0
 68a:	02d00713          	li	a4,45
 68e:	fee78423          	sb	a4,-24(a5)
 692:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 696:	02f05a63          	blez	a5,6ca <printint+0x8a>
 69a:	fc26                	sd	s1,56(sp)
 69c:	f44e                	sd	s3,40(sp)
 69e:	fb840713          	addi	a4,s0,-72
 6a2:	00f704b3          	add	s1,a4,a5
 6a6:	fff70993          	addi	s3,a4,-1
 6aa:	99be                	add	s3,s3,a5
 6ac:	37fd                	addiw	a5,a5,-1
 6ae:	1782                	slli	a5,a5,0x20
 6b0:	9381                	srli	a5,a5,0x20
 6b2:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 6b6:	fff4c583          	lbu	a1,-1(s1)
 6ba:	854a                	mv	a0,s2
 6bc:	f67ff0ef          	jal	622 <putc>
  while(--i >= 0)
 6c0:	14fd                	addi	s1,s1,-1
 6c2:	ff349ae3          	bne	s1,s3,6b6 <printint+0x76>
 6c6:	74e2                	ld	s1,56(sp)
 6c8:	79a2                	ld	s3,40(sp)
}
 6ca:	60a6                	ld	ra,72(sp)
 6cc:	6406                	ld	s0,64(sp)
 6ce:	7942                	ld	s2,48(sp)
 6d0:	6161                	addi	sp,sp,80
 6d2:	8082                	ret
    x = -xx;
 6d4:	40b005b3          	neg	a1,a1
    neg = 1;
 6d8:	4885                	li	a7,1
    x = -xx;
 6da:	bfad                	j	654 <printint+0x14>

00000000000006dc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6dc:	711d                	addi	sp,sp,-96
 6de:	ec86                	sd	ra,88(sp)
 6e0:	e8a2                	sd	s0,80(sp)
 6e2:	e0ca                	sd	s2,64(sp)
 6e4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6e6:	0005c903          	lbu	s2,0(a1)
 6ea:	28090663          	beqz	s2,976 <vprintf+0x29a>
 6ee:	e4a6                	sd	s1,72(sp)
 6f0:	fc4e                	sd	s3,56(sp)
 6f2:	f852                	sd	s4,48(sp)
 6f4:	f456                	sd	s5,40(sp)
 6f6:	f05a                	sd	s6,32(sp)
 6f8:	ec5e                	sd	s7,24(sp)
 6fa:	e862                	sd	s8,16(sp)
 6fc:	e466                	sd	s9,8(sp)
 6fe:	8b2a                	mv	s6,a0
 700:	8a2e                	mv	s4,a1
 702:	8bb2                	mv	s7,a2
  state = 0;
 704:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 706:	4481                	li	s1,0
 708:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 70a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 70e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 712:	06c00c93          	li	s9,108
 716:	a005                	j	736 <vprintf+0x5a>
        putc(fd, c0);
 718:	85ca                	mv	a1,s2
 71a:	855a                	mv	a0,s6
 71c:	f07ff0ef          	jal	622 <putc>
 720:	a019                	j	726 <vprintf+0x4a>
    } else if(state == '%'){
 722:	03598263          	beq	s3,s5,746 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 726:	2485                	addiw	s1,s1,1
 728:	8726                	mv	a4,s1
 72a:	009a07b3          	add	a5,s4,s1
 72e:	0007c903          	lbu	s2,0(a5)
 732:	22090a63          	beqz	s2,966 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 736:	0009079b          	sext.w	a5,s2
    if(state == 0){
 73a:	fe0994e3          	bnez	s3,722 <vprintf+0x46>
      if(c0 == '%'){
 73e:	fd579de3          	bne	a5,s5,718 <vprintf+0x3c>
        state = '%';
 742:	89be                	mv	s3,a5
 744:	b7cd                	j	726 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 746:	00ea06b3          	add	a3,s4,a4
 74a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 74e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 750:	c681                	beqz	a3,758 <vprintf+0x7c>
 752:	9752                	add	a4,a4,s4
 754:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 758:	05878363          	beq	a5,s8,79e <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 75c:	05978d63          	beq	a5,s9,7b6 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 760:	07500713          	li	a4,117
 764:	0ee78763          	beq	a5,a4,852 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 768:	07800713          	li	a4,120
 76c:	12e78963          	beq	a5,a4,89e <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 770:	07000713          	li	a4,112
 774:	14e78e63          	beq	a5,a4,8d0 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 778:	06300713          	li	a4,99
 77c:	18e78e63          	beq	a5,a4,918 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 780:	07300713          	li	a4,115
 784:	1ae78463          	beq	a5,a4,92c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 788:	02500713          	li	a4,37
 78c:	04e79563          	bne	a5,a4,7d6 <vprintf+0xfa>
        putc(fd, '%');
 790:	02500593          	li	a1,37
 794:	855a                	mv	a0,s6
 796:	e8dff0ef          	jal	622 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 79a:	4981                	li	s3,0
 79c:	b769                	j	726 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 79e:	008b8913          	addi	s2,s7,8
 7a2:	4685                	li	a3,1
 7a4:	4629                	li	a2,10
 7a6:	000ba583          	lw	a1,0(s7)
 7aa:	855a                	mv	a0,s6
 7ac:	e95ff0ef          	jal	640 <printint>
 7b0:	8bca                	mv	s7,s2
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	bf8d                	j	726 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 7b6:	06400793          	li	a5,100
 7ba:	02f68963          	beq	a3,a5,7ec <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7be:	06c00793          	li	a5,108
 7c2:	04f68263          	beq	a3,a5,806 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 7c6:	07500793          	li	a5,117
 7ca:	0af68063          	beq	a3,a5,86a <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 7ce:	07800793          	li	a5,120
 7d2:	0ef68263          	beq	a3,a5,8b6 <vprintf+0x1da>
        putc(fd, '%');
 7d6:	02500593          	li	a1,37
 7da:	855a                	mv	a0,s6
 7dc:	e47ff0ef          	jal	622 <putc>
        putc(fd, c0);
 7e0:	85ca                	mv	a1,s2
 7e2:	855a                	mv	a0,s6
 7e4:	e3fff0ef          	jal	622 <putc>
      state = 0;
 7e8:	4981                	li	s3,0
 7ea:	bf35                	j	726 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ec:	008b8913          	addi	s2,s7,8
 7f0:	4685                	li	a3,1
 7f2:	4629                	li	a2,10
 7f4:	000bb583          	ld	a1,0(s7)
 7f8:	855a                	mv	a0,s6
 7fa:	e47ff0ef          	jal	640 <printint>
        i += 1;
 7fe:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 800:	8bca                	mv	s7,s2
      state = 0;
 802:	4981                	li	s3,0
        i += 1;
 804:	b70d                	j	726 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 806:	06400793          	li	a5,100
 80a:	02f60763          	beq	a2,a5,838 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 80e:	07500793          	li	a5,117
 812:	06f60963          	beq	a2,a5,884 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 816:	07800793          	li	a5,120
 81a:	faf61ee3          	bne	a2,a5,7d6 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 81e:	008b8913          	addi	s2,s7,8
 822:	4681                	li	a3,0
 824:	4641                	li	a2,16
 826:	000bb583          	ld	a1,0(s7)
 82a:	855a                	mv	a0,s6
 82c:	e15ff0ef          	jal	640 <printint>
        i += 2;
 830:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 832:	8bca                	mv	s7,s2
      state = 0;
 834:	4981                	li	s3,0
        i += 2;
 836:	bdc5                	j	726 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 838:	008b8913          	addi	s2,s7,8
 83c:	4685                	li	a3,1
 83e:	4629                	li	a2,10
 840:	000bb583          	ld	a1,0(s7)
 844:	855a                	mv	a0,s6
 846:	dfbff0ef          	jal	640 <printint>
        i += 2;
 84a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 84c:	8bca                	mv	s7,s2
      state = 0;
 84e:	4981                	li	s3,0
        i += 2;
 850:	bdd9                	j	726 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 852:	008b8913          	addi	s2,s7,8
 856:	4681                	li	a3,0
 858:	4629                	li	a2,10
 85a:	000be583          	lwu	a1,0(s7)
 85e:	855a                	mv	a0,s6
 860:	de1ff0ef          	jal	640 <printint>
 864:	8bca                	mv	s7,s2
      state = 0;
 866:	4981                	li	s3,0
 868:	bd7d                	j	726 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 86a:	008b8913          	addi	s2,s7,8
 86e:	4681                	li	a3,0
 870:	4629                	li	a2,10
 872:	000bb583          	ld	a1,0(s7)
 876:	855a                	mv	a0,s6
 878:	dc9ff0ef          	jal	640 <printint>
        i += 1;
 87c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 87e:	8bca                	mv	s7,s2
      state = 0;
 880:	4981                	li	s3,0
        i += 1;
 882:	b555                	j	726 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 884:	008b8913          	addi	s2,s7,8
 888:	4681                	li	a3,0
 88a:	4629                	li	a2,10
 88c:	000bb583          	ld	a1,0(s7)
 890:	855a                	mv	a0,s6
 892:	dafff0ef          	jal	640 <printint>
        i += 2;
 896:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 898:	8bca                	mv	s7,s2
      state = 0;
 89a:	4981                	li	s3,0
        i += 2;
 89c:	b569                	j	726 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 89e:	008b8913          	addi	s2,s7,8
 8a2:	4681                	li	a3,0
 8a4:	4641                	li	a2,16
 8a6:	000be583          	lwu	a1,0(s7)
 8aa:	855a                	mv	a0,s6
 8ac:	d95ff0ef          	jal	640 <printint>
 8b0:	8bca                	mv	s7,s2
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	bd8d                	j	726 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8b6:	008b8913          	addi	s2,s7,8
 8ba:	4681                	li	a3,0
 8bc:	4641                	li	a2,16
 8be:	000bb583          	ld	a1,0(s7)
 8c2:	855a                	mv	a0,s6
 8c4:	d7dff0ef          	jal	640 <printint>
        i += 1;
 8c8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 8ca:	8bca                	mv	s7,s2
      state = 0;
 8cc:	4981                	li	s3,0
        i += 1;
 8ce:	bda1                	j	726 <vprintf+0x4a>
 8d0:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 8d2:	008b8d13          	addi	s10,s7,8
 8d6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8da:	03000593          	li	a1,48
 8de:	855a                	mv	a0,s6
 8e0:	d43ff0ef          	jal	622 <putc>
  putc(fd, 'x');
 8e4:	07800593          	li	a1,120
 8e8:	855a                	mv	a0,s6
 8ea:	d39ff0ef          	jal	622 <putc>
 8ee:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8f0:	00000b97          	auipc	s7,0x0
 8f4:	2d8b8b93          	addi	s7,s7,728 # bc8 <digits>
 8f8:	03c9d793          	srli	a5,s3,0x3c
 8fc:	97de                	add	a5,a5,s7
 8fe:	0007c583          	lbu	a1,0(a5)
 902:	855a                	mv	a0,s6
 904:	d1fff0ef          	jal	622 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 908:	0992                	slli	s3,s3,0x4
 90a:	397d                	addiw	s2,s2,-1
 90c:	fe0916e3          	bnez	s2,8f8 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 910:	8bea                	mv	s7,s10
      state = 0;
 912:	4981                	li	s3,0
 914:	6d02                	ld	s10,0(sp)
 916:	bd01                	j	726 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 918:	008b8913          	addi	s2,s7,8
 91c:	000bc583          	lbu	a1,0(s7)
 920:	855a                	mv	a0,s6
 922:	d01ff0ef          	jal	622 <putc>
 926:	8bca                	mv	s7,s2
      state = 0;
 928:	4981                	li	s3,0
 92a:	bbf5                	j	726 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 92c:	008b8993          	addi	s3,s7,8
 930:	000bb903          	ld	s2,0(s7)
 934:	00090f63          	beqz	s2,952 <vprintf+0x276>
        for(; *s; s++)
 938:	00094583          	lbu	a1,0(s2)
 93c:	c195                	beqz	a1,960 <vprintf+0x284>
          putc(fd, *s);
 93e:	855a                	mv	a0,s6
 940:	ce3ff0ef          	jal	622 <putc>
        for(; *s; s++)
 944:	0905                	addi	s2,s2,1
 946:	00094583          	lbu	a1,0(s2)
 94a:	f9f5                	bnez	a1,93e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 94c:	8bce                	mv	s7,s3
      state = 0;
 94e:	4981                	li	s3,0
 950:	bbd9                	j	726 <vprintf+0x4a>
          s = "(null)";
 952:	00000917          	auipc	s2,0x0
 956:	26e90913          	addi	s2,s2,622 # bc0 <malloc+0x162>
        for(; *s; s++)
 95a:	02800593          	li	a1,40
 95e:	b7c5                	j	93e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 960:	8bce                	mv	s7,s3
      state = 0;
 962:	4981                	li	s3,0
 964:	b3c9                	j	726 <vprintf+0x4a>
 966:	64a6                	ld	s1,72(sp)
 968:	79e2                	ld	s3,56(sp)
 96a:	7a42                	ld	s4,48(sp)
 96c:	7aa2                	ld	s5,40(sp)
 96e:	7b02                	ld	s6,32(sp)
 970:	6be2                	ld	s7,24(sp)
 972:	6c42                	ld	s8,16(sp)
 974:	6ca2                	ld	s9,8(sp)
    }
  }
}
 976:	60e6                	ld	ra,88(sp)
 978:	6446                	ld	s0,80(sp)
 97a:	6906                	ld	s2,64(sp)
 97c:	6125                	addi	sp,sp,96
 97e:	8082                	ret

0000000000000980 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 980:	715d                	addi	sp,sp,-80
 982:	ec06                	sd	ra,24(sp)
 984:	e822                	sd	s0,16(sp)
 986:	1000                	addi	s0,sp,32
 988:	e010                	sd	a2,0(s0)
 98a:	e414                	sd	a3,8(s0)
 98c:	e818                	sd	a4,16(s0)
 98e:	ec1c                	sd	a5,24(s0)
 990:	03043023          	sd	a6,32(s0)
 994:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 998:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 99c:	8622                	mv	a2,s0
 99e:	d3fff0ef          	jal	6dc <vprintf>
}
 9a2:	60e2                	ld	ra,24(sp)
 9a4:	6442                	ld	s0,16(sp)
 9a6:	6161                	addi	sp,sp,80
 9a8:	8082                	ret

00000000000009aa <printf>:

void
printf(const char *fmt, ...)
{
 9aa:	711d                	addi	sp,sp,-96
 9ac:	ec06                	sd	ra,24(sp)
 9ae:	e822                	sd	s0,16(sp)
 9b0:	1000                	addi	s0,sp,32
 9b2:	e40c                	sd	a1,8(s0)
 9b4:	e810                	sd	a2,16(s0)
 9b6:	ec14                	sd	a3,24(s0)
 9b8:	f018                	sd	a4,32(s0)
 9ba:	f41c                	sd	a5,40(s0)
 9bc:	03043823          	sd	a6,48(s0)
 9c0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9c4:	00840613          	addi	a2,s0,8
 9c8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9cc:	85aa                	mv	a1,a0
 9ce:	4505                	li	a0,1
 9d0:	d0dff0ef          	jal	6dc <vprintf>
}
 9d4:	60e2                	ld	ra,24(sp)
 9d6:	6442                	ld	s0,16(sp)
 9d8:	6125                	addi	sp,sp,96
 9da:	8082                	ret

00000000000009dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9dc:	1141                	addi	sp,sp,-16
 9de:	e422                	sd	s0,8(sp)
 9e0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9e2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9e6:	00001797          	auipc	a5,0x1
 9ea:	61a7b783          	ld	a5,1562(a5) # 2000 <freep>
 9ee:	a02d                	j	a18 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9f0:	4618                	lw	a4,8(a2)
 9f2:	9f2d                	addw	a4,a4,a1
 9f4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9f8:	6398                	ld	a4,0(a5)
 9fa:	6310                	ld	a2,0(a4)
 9fc:	a83d                	j	a3a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9fe:	ff852703          	lw	a4,-8(a0)
 a02:	9f31                	addw	a4,a4,a2
 a04:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a06:	ff053683          	ld	a3,-16(a0)
 a0a:	a091                	j	a4e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a0c:	6398                	ld	a4,0(a5)
 a0e:	00e7e463          	bltu	a5,a4,a16 <free+0x3a>
 a12:	00e6ea63          	bltu	a3,a4,a26 <free+0x4a>
{
 a16:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a18:	fed7fae3          	bgeu	a5,a3,a0c <free+0x30>
 a1c:	6398                	ld	a4,0(a5)
 a1e:	00e6e463          	bltu	a3,a4,a26 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a22:	fee7eae3          	bltu	a5,a4,a16 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a26:	ff852583          	lw	a1,-8(a0)
 a2a:	6390                	ld	a2,0(a5)
 a2c:	02059813          	slli	a6,a1,0x20
 a30:	01c85713          	srli	a4,a6,0x1c
 a34:	9736                	add	a4,a4,a3
 a36:	fae60de3          	beq	a2,a4,9f0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a3a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a3e:	4790                	lw	a2,8(a5)
 a40:	02061593          	slli	a1,a2,0x20
 a44:	01c5d713          	srli	a4,a1,0x1c
 a48:	973e                	add	a4,a4,a5
 a4a:	fae68ae3          	beq	a3,a4,9fe <free+0x22>
    p->s.ptr = bp->s.ptr;
 a4e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a50:	00001717          	auipc	a4,0x1
 a54:	5af73823          	sd	a5,1456(a4) # 2000 <freep>
}
 a58:	6422                	ld	s0,8(sp)
 a5a:	0141                	addi	sp,sp,16
 a5c:	8082                	ret

0000000000000a5e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a5e:	7139                	addi	sp,sp,-64
 a60:	fc06                	sd	ra,56(sp)
 a62:	f822                	sd	s0,48(sp)
 a64:	f426                	sd	s1,40(sp)
 a66:	ec4e                	sd	s3,24(sp)
 a68:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a6a:	02051493          	slli	s1,a0,0x20
 a6e:	9081                	srli	s1,s1,0x20
 a70:	04bd                	addi	s1,s1,15
 a72:	8091                	srli	s1,s1,0x4
 a74:	0014899b          	addiw	s3,s1,1
 a78:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a7a:	00001517          	auipc	a0,0x1
 a7e:	58653503          	ld	a0,1414(a0) # 2000 <freep>
 a82:	c915                	beqz	a0,ab6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a84:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a86:	4798                	lw	a4,8(a5)
 a88:	08977a63          	bgeu	a4,s1,b1c <malloc+0xbe>
 a8c:	f04a                	sd	s2,32(sp)
 a8e:	e852                	sd	s4,16(sp)
 a90:	e456                	sd	s5,8(sp)
 a92:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a94:	8a4e                	mv	s4,s3
 a96:	0009871b          	sext.w	a4,s3
 a9a:	6685                	lui	a3,0x1
 a9c:	00d77363          	bgeu	a4,a3,aa2 <malloc+0x44>
 aa0:	6a05                	lui	s4,0x1
 aa2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 aa6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 aaa:	00001917          	auipc	s2,0x1
 aae:	55690913          	addi	s2,s2,1366 # 2000 <freep>
  if(p == SBRK_ERROR)
 ab2:	5afd                	li	s5,-1
 ab4:	a081                	j	af4 <malloc+0x96>
 ab6:	f04a                	sd	s2,32(sp)
 ab8:	e852                	sd	s4,16(sp)
 aba:	e456                	sd	s5,8(sp)
 abc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 abe:	00001797          	auipc	a5,0x1
 ac2:	56278793          	addi	a5,a5,1378 # 2020 <base>
 ac6:	00001717          	auipc	a4,0x1
 aca:	52f73d23          	sd	a5,1338(a4) # 2000 <freep>
 ace:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ad0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ad4:	b7c1                	j	a94 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 ad6:	6398                	ld	a4,0(a5)
 ad8:	e118                	sd	a4,0(a0)
 ada:	a8a9                	j	b34 <malloc+0xd6>
  hp->s.size = nu;
 adc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ae0:	0541                	addi	a0,a0,16
 ae2:	efbff0ef          	jal	9dc <free>
  return freep;
 ae6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 aea:	c12d                	beqz	a0,b4c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aee:	4798                	lw	a4,8(a5)
 af0:	02977263          	bgeu	a4,s1,b14 <malloc+0xb6>
    if(p == freep)
 af4:	00093703          	ld	a4,0(s2)
 af8:	853e                	mv	a0,a5
 afa:	fef719e3          	bne	a4,a5,aec <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 afe:	8552                	mv	a0,s4
 b00:	9cdff0ef          	jal	4cc <sbrk>
  if(p == SBRK_ERROR)
 b04:	fd551ce3          	bne	a0,s5,adc <malloc+0x7e>
        return 0;
 b08:	4501                	li	a0,0
 b0a:	7902                	ld	s2,32(sp)
 b0c:	6a42                	ld	s4,16(sp)
 b0e:	6aa2                	ld	s5,8(sp)
 b10:	6b02                	ld	s6,0(sp)
 b12:	a03d                	j	b40 <malloc+0xe2>
 b14:	7902                	ld	s2,32(sp)
 b16:	6a42                	ld	s4,16(sp)
 b18:	6aa2                	ld	s5,8(sp)
 b1a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b1c:	fae48de3          	beq	s1,a4,ad6 <malloc+0x78>
        p->s.size -= nunits;
 b20:	4137073b          	subw	a4,a4,s3
 b24:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b26:	02071693          	slli	a3,a4,0x20
 b2a:	01c6d713          	srli	a4,a3,0x1c
 b2e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b30:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b34:	00001717          	auipc	a4,0x1
 b38:	4ca73623          	sd	a0,1228(a4) # 2000 <freep>
      return (void*)(p + 1);
 b3c:	01078513          	addi	a0,a5,16
  }
}
 b40:	70e2                	ld	ra,56(sp)
 b42:	7442                	ld	s0,48(sp)
 b44:	74a2                	ld	s1,40(sp)
 b46:	69e2                	ld	s3,24(sp)
 b48:	6121                	addi	sp,sp,64
 b4a:	8082                	ret
 b4c:	7902                	ld	s2,32(sp)
 b4e:	6a42                	ld	s4,16(sp)
 b50:	6aa2                	ld	s5,8(sp)
 b52:	6b02                	ld	s6,0(sp)
 b54:	b7f5                	j	b40 <malloc+0xe2>
