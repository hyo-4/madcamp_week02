import 'package:client/pages/book_add_page.dart';
import 'package:client/pages/book_search_page.dart';
import 'package:client/pages/map_page.dart';
import 'package:client/pages/my_page.dart';
import 'package:flutter/material.dart';
import 'package:client/pages/profile_page.dart';
import 'package:carousel_slider/carousel_slider.dart';

class NewMainPage extends StatefulWidget {
  const NewMainPage({Key? key}) : super(key: key);

  @override
  State<NewMainPage> createState() => _NewMainPageState();
}

class Book {
  final String title;
  final String imagePath;
  final String description;

  Book(
      {required this.title,
      required this.imagePath,
      required this.description});
}

class _NewMainPageState extends State<NewMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEE9E0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: const Color(0xFFEEE9E0), // AppBar 색상
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      width: 210,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: InkWell(
                  onTap: () {
                    // 채팅 아이콘 클릭 시 수행할 작업 추가
                  },
                  child: Ink.image(
                    image: const AssetImage('assets/images/chat.png'),
                    width: 38,
                    height: 38,
                    child: IconButton(
                      onPressed: () {},
                      icon: const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0), // 오른쪽 여백을 조절합니다
                child: InkWell(
                  onTap: () {
                    // 프로필 아이콘 클릭 시 수행할 작업 추가
                  },
                  child: Ink.image(
                    image: const AssetImage('assets/images/profile.png'),
                    width: 38,
                    height: 38,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyprofilePage(),
                          ),
                        );
                      },
                      icon: const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(
                  height: 20,
                ),
                const Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      '이 주 베스트',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                InfiniteSlider(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'oo 님 환영합니다. ',
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapPage(),
                            ),
                          );
                        },
                        child: const RoundedContainerWithBackground(
                          backgroundImage:
                              'assets/images/nearby_books_background.jpg',
                          text: '주변 책 보기',
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookAdd(),
                            ),
                          );
                        },
                        child: const RoundedContainerWithBackground(
                          backgroundImage:
                              'assets/images/register_books_background.jpg',
                          text: '책 등록하기',
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookSearchScreen(),
                            ),
                          );
                        },
                        child: const RoundedContainerWithBackground(
                          backgroundImage:
                              'assets/images/search_books_background.jpg',
                          text: '책 검색',
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class InfiniteSlider extends StatelessWidget {
  final List<Book> bookList = [
    Book(
      title: '[시/에세이]읽을,거리',
      description:
          '난다의 시의적절, 시인 김민정이 매일매일 그러모은 1월의, 1월에 의한, 1월을 위한 단 한 권의 읽을거리',
      imagePath: 'assets/images/image1.jpeg',
    ),
    Book(
      title: '남에게 보여주려고 인생을 낭비하지 마라',
      description: '“얄팍한 행복 대신 단단한 외로움을 선택하라!” 니체, 톨스토이, 삶과 지혜에 대한 격언',
      imagePath: 'assets/images/image2.jpeg',
    ),
    Book(
      title: '오늘도 딴생각에 빠진 당신에게',
      description:
          '도파민과 검색의 덫에 갇혀버린 집중력 점점 산만해지는 우리의 멘탈초 단위로 흩어지는 마음을 한곳으로 모으기',
      imagePath: 'assets/images/image3.jpeg',
    ),
    Book(
      title: '죽음이 물었다, 어떻게 살 거냐고',
      description: '찬란한 생의 끝에 만난 마지막 문장들',
      imagePath: 'assets/images/image4.jpeg',
    ),
    Book(
      title: '맡겨진 소녀',
      description:
          '『맡겨진 소녀』는 2009년 데이비 번스 문학상을 수상한 작품으로, 애정 없는 부모로부터 낯선 친척 집에 맡겨진 한 소녀의 이야기를 그린다. ',
      imagePath: 'assets/images/image5.jpeg',
    ),
  ];

  InfiniteSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 190.0,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayInterval: const Duration(seconds: 2),
        viewportFraction: 1,
        scrollDirection: Axis.horizontal,
      ),
      items: bookList.map((Book book) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          book.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        book.imagePath,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class RoundedContainerWithBackground extends StatelessWidget {
  final String backgroundImage;
  final String text;

  const RoundedContainerWithBackground({
    Key? key,
    required this.backgroundImage,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width,
      height: 250,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
