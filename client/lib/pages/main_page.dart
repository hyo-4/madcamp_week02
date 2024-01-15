import 'package:client/pages/book_add_page.dart';
import 'package:client/pages/map_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String userId = ''; // Initialize with an empty string
  @override
  void initState() {
    super.initState();
    loadUserId(); // Load the user ID when the widget is initialized
  }
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? ''; // Assign the user ID or an empty string if it's not available
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      width: 220,
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
                      onPressed: () {},
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
                InfiniteSlider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$userId 님 환영합니다.'),
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
                          text: '주변 대여가능 책 보기',
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
                          // Navigate to 'SearchBooks' page
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
  final List<String> imageList = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpg',
    'assets/images/image3.jpg',
    'assets/images/image4.jpg',
    'assets/images/image5.jpg',
  ];

  InfiniteSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 230.0,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayInterval: const Duration(seconds: 2),
        viewportFraction: 1,
        scrollDirection: Axis.horizontal,
      ),
      items: imageList.map((String imagePath) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: const BoxDecoration(
                color: Colors.amber,
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
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
      margin: const EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
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
          style: const TextStyle(fontSize: 25, color: Colors.white),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: MainPage(),
    ),
  );
}
