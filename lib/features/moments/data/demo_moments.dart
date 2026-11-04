import '../domain/entities/moment.dart';

const demoMoments = [
  Moment(
    id: 'p1',
    author: '笨笨',
    time: '09:05',
    place: '旧书店',
    text: '头一回自己生火。咸肉切得一片厚一片薄，锅盖一掀，白气把眼镜都糊住了。',
    photos: ['assets/media/book1.jpg', 'assets/media/book2.jpg'],
    likes: ['林叔', '张姨', '老赵'],
    comments: [
      MomentComment(author: '林叔', text: '火候还行，面没坨。', time: '09:18'),
      MomentComment(author: '张姨', text: '下回切肉前先冻一冻，好切。', time: '09:26'),
    ],
  ),
  Moment(
    id: 'p2',
    author: '笨笨',
    time: '08:42',
    place: '后院',
    text: '院子里晒满了书，人只能侧着身子走。翻到一本夹着旧车票的，1987 年。',
    photos: [
      'assets/media/book2.jpg',
      'assets/media/book3.jpg',
      'assets/media/book1.jpg',
    ],
    likes: ['林叔', '老赵'],
    comments: [MomentComment(author: '老赵', text: '车票留着，比书值钱。', time: '08:50')],
  ),
  Moment(
    id: 'p3',
    author: '林叔',
    time: '08:10',
    place: '旧书店',
    text: '今天晚开，门板一块块卸下来。门口那盏灯该换了。',
    photos: ['assets/media/book3.jpg'],
    likes: ['笨笨', '张姨'],
    comments: [MomentComment(author: '笨笨', text: '我下午带个灯泡过去。', time: '08:22')],
  ),
  Moment(
    id: 'p4',
    author: '笨笨',
    time: '07:54',
    place: '旧货市场',
    text: '锅是有灶的那只，外套深色的，八十块。摊主说再送两根葱。',
    photos: ['assets/media/book1.jpg', 'assets/media/book2.jpg'],
    likes: ['林叔', '老赵', '张姨', '阿海'],
    comments: [],
  ),
];
