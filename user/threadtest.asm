
user/_threadtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <acquire_print_lock>:
#define STACK_SIZE 100

// Simple mutex using atomic operations
volatile int print_lock = 0;

void acquire_print_lock() {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    while (__sync_lock_test_and_set(&print_lock, 1)) {
   6:	00001717          	auipc	a4,0x1
   a:	02a70713          	addi	a4,a4,42 # 1030 <print_lock>
   e:	4685                	li	a3,1
  10:	87b6                	mv	a5,a3
  12:	0cf727af          	amoswap.w.aq	a5,a5,(a4)
  16:	2781                	sext.w	a5,a5
  18:	ffe5                	bnez	a5,10 <acquire_print_lock+0x10>
        // Busy wait (spin)
    }
}
  1a:	6422                	ld	s0,8(sp)
  1c:	0141                	addi	sp,sp,16
  1e:	8082                	ret

0000000000000020 <release_print_lock>:

void release_print_lock() {
  20:	1141                	addi	sp,sp,-16
  22:	e422                	sd	s0,8(sp)
  24:	0800                	addi	s0,sp,16
    __sync_lock_release(&print_lock);
  26:	00001797          	auipc	a5,0x1
  2a:	00a78793          	addi	a5,a5,10 # 1030 <print_lock>
  2e:	0f50000f          	fence	iorw,ow
  32:	0807a02f          	amoswap.w	zero,zero,(a5)
}
  36:	6422                	ld	s0,8(sp)
  38:	0141                	addi	sp,sp,16
  3a:	8082                	ret

000000000000003c <my_thread>:
struct thread_data {
    int thread_id;
    uint64 start_number;
};

void *my_thread(void *arg) {
  3c:	7179                	addi	sp,sp,-48
  3e:	f406                	sd	ra,40(sp)
  40:	f022                	sd	s0,32(sp)
  42:	ec26                	sd	s1,24(sp)
  44:	e84a                	sd	s2,16(sp)
  46:	e44e                	sd	s3,8(sp)
  48:	1800                	addi	s0,sp,48
  4a:	84aa                	mv	s1,a0
  4c:	4929                	li	s2,10
    for (int i = 0; i < 10; ++i) {
        ((struct thread_data *) arg)->start_number++;
        
        // Acquire lock before printing
        acquire_print_lock();
        printf("thread %d: %lu\n", ((struct thread_data *) arg)->thread_id, ((struct thread_data *) arg)->start_number);
  4e:	00001997          	auipc	s3,0x1
  52:	96298993          	addi	s3,s3,-1694 # 9b0 <malloc+0xf8>
        ((struct thread_data *) arg)->start_number++;
  56:	649c                	ld	a5,8(s1)
  58:	0785                	addi	a5,a5,1
  5a:	e49c                	sd	a5,8(s1)
        acquire_print_lock();
  5c:	fa5ff0ef          	jal	0 <acquire_print_lock>
        printf("thread %d: %lu\n", ((struct thread_data *) arg)->thread_id, ((struct thread_data *) arg)->start_number);
  60:	6490                	ld	a2,8(s1)
  62:	408c                	lw	a1,0(s1)
  64:	854e                	mv	a0,s3
  66:	79e000ef          	jal	804 <printf>
        release_print_lock();
  6a:	fb7ff0ef          	jal	20 <release_print_lock>
        // Release lock after printing
        
        // Try to yield by calling a system call that trigger scheduling
        sleep(0);  // Sleep for 0 ticks - this should trigger thread scheduling
  6e:	4501                	li	a0,0
  70:	3fc000ef          	jal	46c <sleep>
    for (int i = 0; i < 10; ++i) {
  74:	397d                	addiw	s2,s2,-1
  76:	fe0910e3          	bnez	s2,56 <my_thread+0x1a>
    }
    return (void *) ((struct thread_data *) arg)->start_number;
}
  7a:	6488                	ld	a0,8(s1)
  7c:	70a2                	ld	ra,40(sp)
  7e:	7402                	ld	s0,32(sp)
  80:	64e2                	ld	s1,24(sp)
  82:	6942                	ld	s2,16(sp)
  84:	69a2                	ld	s3,8(sp)
  86:	6145                	addi	sp,sp,48
  88:	8082                	ret

000000000000008a <main>:


int main(int argc, char *argv[]) {
  8a:	b2010113          	addi	sp,sp,-1248
  8e:	4c113c23          	sd	ra,1240(sp)
  92:	4c813823          	sd	s0,1232(sp)
  96:	4c913423          	sd	s1,1224(sp)
  9a:	4d213023          	sd	s2,1216(sp)
  9e:	4b313c23          	sd	s3,1208(sp)
  a2:	4e010413          	addi	s0,sp,1248
    // Create thread data structures (static to ensure they persist)
    static struct thread_data data1 = {1, 100};
    static struct thread_data data2 = {2, 200};
    static struct thread_data data3 = {3, 300};
    
    int ta = thread(my_thread, sp1 + STACK_SIZE, (void *) &data1);
  a6:	00001617          	auipc	a2,0x1
  aa:	f5a60613          	addi	a2,a2,-166 # 1000 <data1.2>
  ae:	fd040593          	addi	a1,s0,-48
  b2:	00000517          	auipc	a0,0x0
  b6:	f8a50513          	addi	a0,a0,-118 # 3c <my_thread>
  ba:	3c2000ef          	jal	47c <thread>
  be:	89aa                	mv	s3,a0
    acquire_print_lock();
  c0:	f41ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 1\n");
  c4:	00001517          	auipc	a0,0x1
  c8:	8fc50513          	addi	a0,a0,-1796 # 9c0 <malloc+0x108>
  cc:	738000ef          	jal	804 <printf>
    release_print_lock();
  d0:	f51ff0ef          	jal	20 <release_print_lock>
    
    int tb = thread(my_thread, sp2 + STACK_SIZE, (void *) &data2);
  d4:	00001617          	auipc	a2,0x1
  d8:	f3c60613          	addi	a2,a2,-196 # 1010 <data2.1>
  dc:	e4040593          	addi	a1,s0,-448
  e0:	00000517          	auipc	a0,0x0
  e4:	f5c50513          	addi	a0,a0,-164 # 3c <my_thread>
  e8:	394000ef          	jal	47c <thread>
  ec:	892a                	mv	s2,a0
    acquire_print_lock();
  ee:	f13ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 2\n");
  f2:	00001517          	auipc	a0,0x1
  f6:	8e650513          	addi	a0,a0,-1818 # 9d8 <malloc+0x120>
  fa:	70a000ef          	jal	804 <printf>
    release_print_lock();
  fe:	f23ff0ef          	jal	20 <release_print_lock>
    
    int tc = thread(my_thread, sp3 + STACK_SIZE, (void *) &data3);
 102:	00001617          	auipc	a2,0x1
 106:	f1e60613          	addi	a2,a2,-226 # 1020 <data3.0>
 10a:	cb040593          	addi	a1,s0,-848
 10e:	00000517          	auipc	a0,0x0
 112:	f2e50513          	addi	a0,a0,-210 # 3c <my_thread>
 116:	366000ef          	jal	47c <thread>
 11a:	84aa                	mv	s1,a0
    acquire_print_lock();
 11c:	ee5ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 3\n");
 120:	00001517          	auipc	a0,0x1
 124:	8d050513          	addi	a0,a0,-1840 # 9f0 <malloc+0x138>
 128:	6dc000ef          	jal	804 <printf>
    release_print_lock();
 12c:	ef5ff0ef          	jal	20 <release_print_lock>
    
    jointhread(ta);
 130:	854e                	mv	a0,s3
 132:	352000ef          	jal	484 <jointhread>
    jointhread(tb);
 136:	854a                	mv	a0,s2
 138:	34c000ef          	jal	484 <jointhread>
    jointhread(tc);
 13c:	8526                	mv	a0,s1
 13e:	346000ef          	jal	484 <jointhread>
    
    acquire_print_lock();
 142:	ebfff0ef          	jal	0 <acquire_print_lock>
    printf("DONE\n");
 146:	00001517          	auipc	a0,0x1
 14a:	8c250513          	addi	a0,a0,-1854 # a08 <malloc+0x150>
 14e:	6b6000ef          	jal	804 <printf>
    release_print_lock();
 152:	ecfff0ef          	jal	20 <release_print_lock>
 156:	4501                	li	a0,0
 158:	4d813083          	ld	ra,1240(sp)
 15c:	4d013403          	ld	s0,1232(sp)
 160:	4c813483          	ld	s1,1224(sp)
 164:	4c013903          	ld	s2,1216(sp)
 168:	4b813983          	ld	s3,1208(sp)
 16c:	4e010113          	addi	sp,sp,1248
 170:	8082                	ret

0000000000000172 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 172:	1141                	addi	sp,sp,-16
 174:	e406                	sd	ra,8(sp)
 176:	e022                	sd	s0,0(sp)
 178:	0800                	addi	s0,sp,16
  extern int main();
  main();
 17a:	f11ff0ef          	jal	8a <main>
  exit(0);
 17e:	4501                	li	a0,0
 180:	25c000ef          	jal	3dc <exit>

0000000000000184 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 184:	1141                	addi	sp,sp,-16
 186:	e422                	sd	s0,8(sp)
 188:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 18a:	87aa                	mv	a5,a0
 18c:	0585                	addi	a1,a1,1
 18e:	0785                	addi	a5,a5,1
 190:	fff5c703          	lbu	a4,-1(a1)
 194:	fee78fa3          	sb	a4,-1(a5)
 198:	fb75                	bnez	a4,18c <strcpy+0x8>
    ;
  return os;
}
 19a:	6422                	ld	s0,8(sp)
 19c:	0141                	addi	sp,sp,16
 19e:	8082                	ret

00000000000001a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	cb91                	beqz	a5,1be <strcmp+0x1e>
 1ac:	0005c703          	lbu	a4,0(a1)
 1b0:	00f71763          	bne	a4,a5,1be <strcmp+0x1e>
    p++, q++;
 1b4:	0505                	addi	a0,a0,1
 1b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbe5                	bnez	a5,1ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1be:	0005c503          	lbu	a0,0(a1)
}
 1c2:	40a7853b          	subw	a0,a5,a0
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret

00000000000001cc <strlen>:

uint
strlen(const char *s)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cf91                	beqz	a5,1f2 <strlen+0x26>
 1d8:	0505                	addi	a0,a0,1
 1da:	87aa                	mv	a5,a0
 1dc:	86be                	mv	a3,a5
 1de:	0785                	addi	a5,a5,1
 1e0:	fff7c703          	lbu	a4,-1(a5)
 1e4:	ff65                	bnez	a4,1dc <strlen+0x10>
 1e6:	40a6853b          	subw	a0,a3,a0
 1ea:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret
  for(n = 0; s[n]; n++)
 1f2:	4501                	li	a0,0
 1f4:	bfe5                	j	1ec <strlen+0x20>

00000000000001f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1fc:	ca19                	beqz	a2,212 <memset+0x1c>
 1fe:	87aa                	mv	a5,a0
 200:	1602                	slli	a2,a2,0x20
 202:	9201                	srli	a2,a2,0x20
 204:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 208:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 20c:	0785                	addi	a5,a5,1
 20e:	fee79de3          	bne	a5,a4,208 <memset+0x12>
  }
  return dst;
}
 212:	6422                	ld	s0,8(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret

0000000000000218 <strchr>:

char*
strchr(const char *s, char c)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 21e:	00054783          	lbu	a5,0(a0)
 222:	cb99                	beqz	a5,238 <strchr+0x20>
    if(*s == c)
 224:	00f58763          	beq	a1,a5,232 <strchr+0x1a>
  for(; *s; s++)
 228:	0505                	addi	a0,a0,1
 22a:	00054783          	lbu	a5,0(a0)
 22e:	fbfd                	bnez	a5,224 <strchr+0xc>
      return (char*)s;
  return 0;
 230:	4501                	li	a0,0
}
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret
  return 0;
 238:	4501                	li	a0,0
 23a:	bfe5                	j	232 <strchr+0x1a>

000000000000023c <gets>:

char*
gets(char *buf, int max)
{
 23c:	711d                	addi	sp,sp,-96
 23e:	ec86                	sd	ra,88(sp)
 240:	e8a2                	sd	s0,80(sp)
 242:	e4a6                	sd	s1,72(sp)
 244:	e0ca                	sd	s2,64(sp)
 246:	fc4e                	sd	s3,56(sp)
 248:	f852                	sd	s4,48(sp)
 24a:	f456                	sd	s5,40(sp)
 24c:	f05a                	sd	s6,32(sp)
 24e:	ec5e                	sd	s7,24(sp)
 250:	1080                	addi	s0,sp,96
 252:	8baa                	mv	s7,a0
 254:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 256:	892a                	mv	s2,a0
 258:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 25a:	4aa9                	li	s5,10
 25c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 25e:	89a6                	mv	s3,s1
 260:	2485                	addiw	s1,s1,1
 262:	0344d663          	bge	s1,s4,28e <gets+0x52>
    cc = read(0, &c, 1);
 266:	4605                	li	a2,1
 268:	faf40593          	addi	a1,s0,-81
 26c:	4501                	li	a0,0
 26e:	186000ef          	jal	3f4 <read>
    if(cc < 1)
 272:	00a05e63          	blez	a0,28e <gets+0x52>
    buf[i++] = c;
 276:	faf44783          	lbu	a5,-81(s0)
 27a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27e:	01578763          	beq	a5,s5,28c <gets+0x50>
 282:	0905                	addi	s2,s2,1
 284:	fd679de3          	bne	a5,s6,25e <gets+0x22>
    buf[i++] = c;
 288:	89a6                	mv	s3,s1
 28a:	a011                	j	28e <gets+0x52>
 28c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28e:	99de                	add	s3,s3,s7
 290:	00098023          	sb	zero,0(s3)
  return buf;
}
 294:	855e                	mv	a0,s7
 296:	60e6                	ld	ra,88(sp)
 298:	6446                	ld	s0,80(sp)
 29a:	64a6                	ld	s1,72(sp)
 29c:	6906                	ld	s2,64(sp)
 29e:	79e2                	ld	s3,56(sp)
 2a0:	7a42                	ld	s4,48(sp)
 2a2:	7aa2                	ld	s5,40(sp)
 2a4:	7b02                	ld	s6,32(sp)
 2a6:	6be2                	ld	s7,24(sp)
 2a8:	6125                	addi	sp,sp,96
 2aa:	8082                	ret

00000000000002ac <stat>:

int
stat(const char *n, struct stat *st)
{
 2ac:	1101                	addi	sp,sp,-32
 2ae:	ec06                	sd	ra,24(sp)
 2b0:	e822                	sd	s0,16(sp)
 2b2:	e04a                	sd	s2,0(sp)
 2b4:	1000                	addi	s0,sp,32
 2b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b8:	4581                	li	a1,0
 2ba:	162000ef          	jal	41c <open>
  if(fd < 0)
 2be:	02054263          	bltz	a0,2e2 <stat+0x36>
 2c2:	e426                	sd	s1,8(sp)
 2c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c6:	85ca                	mv	a1,s2
 2c8:	16c000ef          	jal	434 <fstat>
 2cc:	892a                	mv	s2,a0
  close(fd);
 2ce:	8526                	mv	a0,s1
 2d0:	134000ef          	jal	404 <close>
  return r;
 2d4:	64a2                	ld	s1,8(sp)
}
 2d6:	854a                	mv	a0,s2
 2d8:	60e2                	ld	ra,24(sp)
 2da:	6442                	ld	s0,16(sp)
 2dc:	6902                	ld	s2,0(sp)
 2de:	6105                	addi	sp,sp,32
 2e0:	8082                	ret
    return -1;
 2e2:	597d                	li	s2,-1
 2e4:	bfcd                	j	2d6 <stat+0x2a>

00000000000002e6 <atoi>:

int
atoi(const char *s)
{
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e422                	sd	s0,8(sp)
 2ea:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ec:	00054683          	lbu	a3,0(a0)
 2f0:	fd06879b          	addiw	a5,a3,-48
 2f4:	0ff7f793          	zext.b	a5,a5
 2f8:	4625                	li	a2,9
 2fa:	02f66863          	bltu	a2,a5,32a <atoi+0x44>
 2fe:	872a                	mv	a4,a0
  n = 0;
 300:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 302:	0705                	addi	a4,a4,1
 304:	0025179b          	slliw	a5,a0,0x2
 308:	9fa9                	addw	a5,a5,a0
 30a:	0017979b          	slliw	a5,a5,0x1
 30e:	9fb5                	addw	a5,a5,a3
 310:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 314:	00074683          	lbu	a3,0(a4)
 318:	fd06879b          	addiw	a5,a3,-48
 31c:	0ff7f793          	zext.b	a5,a5
 320:	fef671e3          	bgeu	a2,a5,302 <atoi+0x1c>
  return n;
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret
  n = 0;
 32a:	4501                	li	a0,0
 32c:	bfe5                	j	324 <atoi+0x3e>

000000000000032e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e422                	sd	s0,8(sp)
 332:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 334:	02b57463          	bgeu	a0,a1,35c <memmove+0x2e>
    while(n-- > 0)
 338:	00c05f63          	blez	a2,356 <memmove+0x28>
 33c:	1602                	slli	a2,a2,0x20
 33e:	9201                	srli	a2,a2,0x20
 340:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 344:	872a                	mv	a4,a0
      *dst++ = *src++;
 346:	0585                	addi	a1,a1,1
 348:	0705                	addi	a4,a4,1
 34a:	fff5c683          	lbu	a3,-1(a1)
 34e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 352:	fef71ae3          	bne	a4,a5,346 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret
    dst += n;
 35c:	00c50733          	add	a4,a0,a2
    src += n;
 360:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 362:	fec05ae3          	blez	a2,356 <memmove+0x28>
 366:	fff6079b          	addiw	a5,a2,-1
 36a:	1782                	slli	a5,a5,0x20
 36c:	9381                	srli	a5,a5,0x20
 36e:	fff7c793          	not	a5,a5
 372:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 374:	15fd                	addi	a1,a1,-1
 376:	177d                	addi	a4,a4,-1
 378:	0005c683          	lbu	a3,0(a1)
 37c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 380:	fee79ae3          	bne	a5,a4,374 <memmove+0x46>
 384:	bfc9                	j	356 <memmove+0x28>

0000000000000386 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e422                	sd	s0,8(sp)
 38a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 38c:	ca05                	beqz	a2,3bc <memcmp+0x36>
 38e:	fff6069b          	addiw	a3,a2,-1
 392:	1682                	slli	a3,a3,0x20
 394:	9281                	srli	a3,a3,0x20
 396:	0685                	addi	a3,a3,1
 398:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 39a:	00054783          	lbu	a5,0(a0)
 39e:	0005c703          	lbu	a4,0(a1)
 3a2:	00e79863          	bne	a5,a4,3b2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a6:	0505                	addi	a0,a0,1
    p2++;
 3a8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3aa:	fed518e3          	bne	a0,a3,39a <memcmp+0x14>
  }
  return 0;
 3ae:	4501                	li	a0,0
 3b0:	a019                	j	3b6 <memcmp+0x30>
      return *p1 - *p2;
 3b2:	40e7853b          	subw	a0,a5,a4
}
 3b6:	6422                	ld	s0,8(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret
  return 0;
 3bc:	4501                	li	a0,0
 3be:	bfe5                	j	3b6 <memcmp+0x30>

00000000000003c0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c8:	f67ff0ef          	jal	32e <memmove>
}
 3cc:	60a2                	ld	ra,8(sp)
 3ce:	6402                	ld	s0,0(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret

00000000000003d4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d4:	4885                	li	a7,1
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3dc:	4889                	li	a7,2
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e4:	488d                	li	a7,3
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ec:	4891                	li	a7,4
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <read>:
.global read
read:
 li a7, SYS_read
 3f4:	4895                	li	a7,5
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <write>:
.global write
write:
 li a7, SYS_write
 3fc:	48c1                	li	a7,16
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <close>:
.global close
close:
 li a7, SYS_close
 404:	48d5                	li	a7,21
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <kill>:
.global kill
kill:
 li a7, SYS_kill
 40c:	4899                	li	a7,6
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <exec>:
.global exec
exec:
 li a7, SYS_exec
 414:	489d                	li	a7,7
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <open>:
.global open
open:
 li a7, SYS_open
 41c:	48bd                	li	a7,15
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 424:	48c5                	li	a7,17
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 42c:	48c9                	li	a7,18
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 434:	48a1                	li	a7,8
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <link>:
.global link
link:
 li a7, SYS_link
 43c:	48cd                	li	a7,19
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 444:	48d1                	li	a7,20
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 44c:	48a5                	li	a7,9
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <dup>:
.global dup
dup:
 li a7, SYS_dup
 454:	48a9                	li	a7,10
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 45c:	48ad                	li	a7,11
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 464:	48b1                	li	a7,12
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 46c:	48b5                	li	a7,13
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 474:	48b9                	li	a7,14
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <thread>:
.global thread
thread:
 li a7, SYS_thread
 47c:	48d9                	li	a7,22
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <jointhread>:
.global jointhread
jointhread:
 li a7, SYS_jointhread
 484:	48dd                	li	a7,23
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 48c:	1101                	addi	sp,sp,-32
 48e:	ec06                	sd	ra,24(sp)
 490:	e822                	sd	s0,16(sp)
 492:	1000                	addi	s0,sp,32
 494:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 498:	4605                	li	a2,1
 49a:	fef40593          	addi	a1,s0,-17
 49e:	f5fff0ef          	jal	3fc <write>
}
 4a2:	60e2                	ld	ra,24(sp)
 4a4:	6442                	ld	s0,16(sp)
 4a6:	6105                	addi	sp,sp,32
 4a8:	8082                	ret

00000000000004aa <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4aa:	715d                	addi	sp,sp,-80
 4ac:	e486                	sd	ra,72(sp)
 4ae:	e0a2                	sd	s0,64(sp)
 4b0:	fc26                	sd	s1,56(sp)
 4b2:	0880                	addi	s0,sp,80
 4b4:	84aa                	mv	s1,a0
  char buf[20];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b6:	c299                	beqz	a3,4bc <printint+0x12>
 4b8:	0805c963          	bltz	a1,54a <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4bc:	2581                	sext.w	a1,a1
  neg = 0;
 4be:	4881                	li	a7,0
 4c0:	fb840693          	addi	a3,s0,-72
  }

  i = 0;
 4c4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c6:	2601                	sext.w	a2,a2
 4c8:	00000517          	auipc	a0,0x0
 4cc:	55050513          	addi	a0,a0,1360 # a18 <digits>
 4d0:	883a                	mv	a6,a4
 4d2:	2705                	addiw	a4,a4,1
 4d4:	02c5f7bb          	remuw	a5,a1,a2
 4d8:	1782                	slli	a5,a5,0x20
 4da:	9381                	srli	a5,a5,0x20
 4dc:	97aa                	add	a5,a5,a0
 4de:	0007c783          	lbu	a5,0(a5)
 4e2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e6:	0005879b          	sext.w	a5,a1
 4ea:	02c5d5bb          	divuw	a1,a1,a2
 4ee:	0685                	addi	a3,a3,1
 4f0:	fec7f0e3          	bgeu	a5,a2,4d0 <printint+0x26>
  if(neg)
 4f4:	00088c63          	beqz	a7,50c <printint+0x62>
    buf[i++] = '-';
 4f8:	fd070793          	addi	a5,a4,-48
 4fc:	00878733          	add	a4,a5,s0
 500:	02d00793          	li	a5,45
 504:	fef70423          	sb	a5,-24(a4)
 508:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 50c:	02e05a63          	blez	a4,540 <printint+0x96>
 510:	f84a                	sd	s2,48(sp)
 512:	f44e                	sd	s3,40(sp)
 514:	fb840793          	addi	a5,s0,-72
 518:	00e78933          	add	s2,a5,a4
 51c:	fff78993          	addi	s3,a5,-1
 520:	99ba                	add	s3,s3,a4
 522:	377d                	addiw	a4,a4,-1
 524:	1702                	slli	a4,a4,0x20
 526:	9301                	srli	a4,a4,0x20
 528:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 52c:	fff94583          	lbu	a1,-1(s2)
 530:	8526                	mv	a0,s1
 532:	f5bff0ef          	jal	48c <putc>
  while(--i >= 0)
 536:	197d                	addi	s2,s2,-1
 538:	ff391ae3          	bne	s2,s3,52c <printint+0x82>
 53c:	7942                	ld	s2,48(sp)
 53e:	79a2                	ld	s3,40(sp)
}
 540:	60a6                	ld	ra,72(sp)
 542:	6406                	ld	s0,64(sp)
 544:	74e2                	ld	s1,56(sp)
 546:	6161                	addi	sp,sp,80
 548:	8082                	ret
    x = -xx;
 54a:	40b005bb          	negw	a1,a1
    neg = 1;
 54e:	4885                	li	a7,1
    x = -xx;
 550:	bf85                	j	4c0 <printint+0x16>

0000000000000552 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 552:	711d                	addi	sp,sp,-96
 554:	ec86                	sd	ra,88(sp)
 556:	e8a2                	sd	s0,80(sp)
 558:	e0ca                	sd	s2,64(sp)
 55a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 55c:	0005c903          	lbu	s2,0(a1)
 560:	26090863          	beqz	s2,7d0 <vprintf+0x27e>
 564:	e4a6                	sd	s1,72(sp)
 566:	fc4e                	sd	s3,56(sp)
 568:	f852                	sd	s4,48(sp)
 56a:	f456                	sd	s5,40(sp)
 56c:	f05a                	sd	s6,32(sp)
 56e:	ec5e                	sd	s7,24(sp)
 570:	e862                	sd	s8,16(sp)
 572:	e466                	sd	s9,8(sp)
 574:	8b2a                	mv	s6,a0
 576:	8a2e                	mv	s4,a1
 578:	8bb2                	mv	s7,a2
  state = 0;
 57a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 57c:	4481                	li	s1,0
 57e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 580:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 584:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 588:	06c00c93          	li	s9,108
 58c:	a005                	j	5ac <vprintf+0x5a>
        putc(fd, c0);
 58e:	85ca                	mv	a1,s2
 590:	855a                	mv	a0,s6
 592:	efbff0ef          	jal	48c <putc>
 596:	a019                	j	59c <vprintf+0x4a>
    } else if(state == '%'){
 598:	03598263          	beq	s3,s5,5bc <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 59c:	2485                	addiw	s1,s1,1
 59e:	8726                	mv	a4,s1
 5a0:	009a07b3          	add	a5,s4,s1
 5a4:	0007c903          	lbu	s2,0(a5)
 5a8:	20090c63          	beqz	s2,7c0 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 5ac:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5b0:	fe0994e3          	bnez	s3,598 <vprintf+0x46>
      if(c0 == '%'){
 5b4:	fd579de3          	bne	a5,s5,58e <vprintf+0x3c>
        state = '%';
 5b8:	89be                	mv	s3,a5
 5ba:	b7cd                	j	59c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5bc:	00ea06b3          	add	a3,s4,a4
 5c0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5c4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5c6:	c681                	beqz	a3,5ce <vprintf+0x7c>
 5c8:	9752                	add	a4,a4,s4
 5ca:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5ce:	03878f63          	beq	a5,s8,60c <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 5d2:	05978963          	beq	a5,s9,624 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5d6:	07500713          	li	a4,117
 5da:	0ee78363          	beq	a5,a4,6c0 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5de:	07800713          	li	a4,120
 5e2:	12e78563          	beq	a5,a4,70c <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5e6:	07000713          	li	a4,112
 5ea:	14e78a63          	beq	a5,a4,73e <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 5ee:	07300713          	li	a4,115
 5f2:	18e78a63          	beq	a5,a4,786 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5f6:	02500713          	li	a4,37
 5fa:	04e79563          	bne	a5,a4,644 <vprintf+0xf2>
        putc(fd, '%');
 5fe:	02500593          	li	a1,37
 602:	855a                	mv	a0,s6
 604:	e89ff0ef          	jal	48c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 608:	4981                	li	s3,0
 60a:	bf49                	j	59c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 60c:	008b8913          	addi	s2,s7,8
 610:	4685                	li	a3,1
 612:	4629                	li	a2,10
 614:	000ba583          	lw	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	e91ff0ef          	jal	4aa <printint>
 61e:	8bca                	mv	s7,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	bfad                	j	59c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 624:	06400793          	li	a5,100
 628:	02f68963          	beq	a3,a5,65a <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 62c:	06c00793          	li	a5,108
 630:	04f68263          	beq	a3,a5,674 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 634:	07500793          	li	a5,117
 638:	0af68063          	beq	a3,a5,6d8 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 63c:	07800793          	li	a5,120
 640:	0ef68263          	beq	a3,a5,724 <vprintf+0x1d2>
        putc(fd, '%');
 644:	02500593          	li	a1,37
 648:	855a                	mv	a0,s6
 64a:	e43ff0ef          	jal	48c <putc>
        putc(fd, c0);
 64e:	85ca                	mv	a1,s2
 650:	855a                	mv	a0,s6
 652:	e3bff0ef          	jal	48c <putc>
      state = 0;
 656:	4981                	li	s3,0
 658:	b791                	j	59c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4685                	li	a3,1
 660:	4629                	li	a2,10
 662:	000bb583          	ld	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	e43ff0ef          	jal	4aa <printint>
        i += 1;
 66c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
        i += 1;
 672:	b72d                	j	59c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 674:	06400793          	li	a5,100
 678:	02f60763          	beq	a2,a5,6a6 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 67c:	07500793          	li	a5,117
 680:	06f60963          	beq	a2,a5,6f2 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 684:	07800793          	li	a5,120
 688:	faf61ee3          	bne	a2,a5,644 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 68c:	008b8913          	addi	s2,s7,8
 690:	4681                	li	a3,0
 692:	4641                	li	a2,16
 694:	000bb583          	ld	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	e11ff0ef          	jal	4aa <printint>
        i += 2;
 69e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
        i += 2;
 6a4:	bde5                	j	59c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4685                	li	a3,1
 6ac:	4629                	li	a2,10
 6ae:	000bb583          	ld	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	df7ff0ef          	jal	4aa <printint>
        i += 2;
 6b8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
        i += 2;
 6be:	bdf9                	j	59c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4629                	li	a2,10
 6c8:	000ba583          	lw	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	dddff0ef          	jal	4aa <printint>
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b5d9                	j	59c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d8:	008b8913          	addi	s2,s7,8
 6dc:	4681                	li	a3,0
 6de:	4629                	li	a2,10
 6e0:	000bb583          	ld	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	dc5ff0ef          	jal	4aa <printint>
        i += 1;
 6ea:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ec:	8bca                	mv	s7,s2
      state = 0;
 6ee:	4981                	li	s3,0
        i += 1;
 6f0:	b575                	j	59c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f2:	008b8913          	addi	s2,s7,8
 6f6:	4681                	li	a3,0
 6f8:	4629                	li	a2,10
 6fa:	000bb583          	ld	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	dabff0ef          	jal	4aa <printint>
        i += 2;
 704:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
        i += 2;
 70a:	bd49                	j	59c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 70c:	008b8913          	addi	s2,s7,8
 710:	4681                	li	a3,0
 712:	4641                	li	a2,16
 714:	000ba583          	lw	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	d91ff0ef          	jal	4aa <printint>
 71e:	8bca                	mv	s7,s2
      state = 0;
 720:	4981                	li	s3,0
 722:	bdad                	j	59c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 724:	008b8913          	addi	s2,s7,8
 728:	4681                	li	a3,0
 72a:	4641                	li	a2,16
 72c:	000bb583          	ld	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	d79ff0ef          	jal	4aa <printint>
        i += 1;
 736:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 738:	8bca                	mv	s7,s2
      state = 0;
 73a:	4981                	li	s3,0
        i += 1;
 73c:	b585                	j	59c <vprintf+0x4a>
 73e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 740:	008b8d13          	addi	s10,s7,8
 744:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 748:	03000593          	li	a1,48
 74c:	855a                	mv	a0,s6
 74e:	d3fff0ef          	jal	48c <putc>
  putc(fd, 'x');
 752:	07800593          	li	a1,120
 756:	855a                	mv	a0,s6
 758:	d35ff0ef          	jal	48c <putc>
 75c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 75e:	00000b97          	auipc	s7,0x0
 762:	2bab8b93          	addi	s7,s7,698 # a18 <digits>
 766:	03c9d793          	srli	a5,s3,0x3c
 76a:	97de                	add	a5,a5,s7
 76c:	0007c583          	lbu	a1,0(a5)
 770:	855a                	mv	a0,s6
 772:	d1bff0ef          	jal	48c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 776:	0992                	slli	s3,s3,0x4
 778:	397d                	addiw	s2,s2,-1
 77a:	fe0916e3          	bnez	s2,766 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 77e:	8bea                	mv	s7,s10
      state = 0;
 780:	4981                	li	s3,0
 782:	6d02                	ld	s10,0(sp)
 784:	bd21                	j	59c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 786:	008b8993          	addi	s3,s7,8
 78a:	000bb903          	ld	s2,0(s7)
 78e:	00090f63          	beqz	s2,7ac <vprintf+0x25a>
        for(; *s; s++)
 792:	00094583          	lbu	a1,0(s2)
 796:	c195                	beqz	a1,7ba <vprintf+0x268>
          putc(fd, *s);
 798:	855a                	mv	a0,s6
 79a:	cf3ff0ef          	jal	48c <putc>
        for(; *s; s++)
 79e:	0905                	addi	s2,s2,1
 7a0:	00094583          	lbu	a1,0(s2)
 7a4:	f9f5                	bnez	a1,798 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7a6:	8bce                	mv	s7,s3
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bbcd                	j	59c <vprintf+0x4a>
          s = "(null)";
 7ac:	00000917          	auipc	s2,0x0
 7b0:	26490913          	addi	s2,s2,612 # a10 <malloc+0x158>
        for(; *s; s++)
 7b4:	02800593          	li	a1,40
 7b8:	b7c5                	j	798 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7ba:	8bce                	mv	s7,s3
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	bbf9                	j	59c <vprintf+0x4a>
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
 7f8:	d5bff0ef          	jal	552 <vprintf>
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
 82a:	d29ff0ef          	jal	552 <vprintf>
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
 844:	7f87b783          	ld	a5,2040(a5) # 1038 <freep>
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
 8ae:	78f73723          	sd	a5,1934(a4) # 1038 <freep>
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
 8d8:	76453503          	ld	a0,1892(a0) # 1038 <freep>
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
 908:	73490913          	addi	s2,s2,1844 # 1038 <freep>
  if(p == (char*)-1)
 90c:	5afd                	li	s5,-1
 90e:	a081                	j	94e <malloc+0x96>
 910:	f04a                	sd	s2,32(sp)
 912:	e852                	sd	s4,16(sp)
 914:	e456                	sd	s5,8(sp)
 916:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 918:	00000797          	auipc	a5,0x0
 91c:	72878793          	addi	a5,a5,1832 # 1040 <base>
 920:	00000717          	auipc	a4,0x0
 924:	70f73c23          	sd	a5,1816(a4) # 1038 <freep>
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
 95a:	b0bff0ef          	jal	464 <sbrk>
  if(p == (char*)-1)
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
 992:	6aa73523          	sd	a0,1706(a4) # 1038 <freep>
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
