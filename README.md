# 📖 바로북 
### 팀원🧑‍💻


- 백승효(숙명여대 20)
- 안호진(KAIST 22)

### 개발 환경⚡


- flutter
- flask + mysql

## 1️⃣ 바로북(borrowBook) ?

> **바로앱은 읽고 싶은 책을 공유하고, 동시에 다양한 책을 대여할 수 있는 편리한 서비스를 제공합니다.**
> 

### 🔍 **책을 찾다, 책을 빌리다, 함께 나누다**

1. **서재 등록하기**: 내가 좋아하는 책, 혹은 읽지 않는 책을 업로드해보세요. 다른 이웃주민들과 책 속 세계를 나누는 재미를 느낄 수 있습니다.
2. **책을 대여하다**: 다른 사용자들이 올린 책 중 마음에 드는 책이 있다면 채팅을 보내 원하는 책을 대여하세요. 새로운 책을 발견하고, 다양한 주제에 대한 지식을 넓힐 수 있습니다.
3. **내 주변 책 구경하기**: 지도 상에서 가까운 도서의 목록을 확인하세요. 접근성 편리한 독서를 통해 새로운 독서메이트와 소통하는 즐거움을 느낄 수 있습니다.

### 🌐 **어디서나, 언제나 독서의 즐거움을 누리다**

**바로북**은 어디서나 책을 찾고 대여할 수 있는 간편한 플랫폼으로 여러분의 독서 생활을 더욱 풍부하게 만들어 드립니다. 지식의 공유와 소통을 통해 함께 성장하는 지역 독서 커뮤니티에 참여하세요!

 함께 독서의 즐거움을 나누는 순간이 특별한 여행으로 이어질 것입니다. 📖🌈

## 2️⃣ 기능

### 로그인/회원가입/메인페이지

![login-ezgif com-video-to-gif-converter](https://github.com/hyo-4/madcamp_week03/assets/70904075/5507b941-f4da-41d5-b354-dc08e00cc327)


### 🗺️ 주변 책 보기


- 내 위치 주변의 책의 정보를 조회할 수 있습니다.
- 마커를 누르면 해당 책의 info가 표시되고, 지도상 center로 이동합니다.
- 지도 밑 리스트의 dropdown 버튼을 누르면 1:1 채팅방으로 이동할 수 있는 버튼이 display됩니다.
- 유저 자신이 등록한 책은 볼 수 없습니다.

### 💬 책 대여

![chat-ezgif com-video-to-gif-converter](https://github.com/hyo-4/madcamp_week03/assets/70904075/b22c3daf-c3c4-4e33-b1fe-73b51b024afd)


- 채팅을 보내 책 주인에게 메시지를 전송할 수 있습니다.
- 고유한 룸 번호를 db에 저장해 socket을 통한 실시간 채팅이 가능합니다.
- 채팅방 리스트에서 현재까지 나에게 채팅을 보내거나 받은 유저의 목록이 보여집니다.
- 채팅방 리스트에는 도서제목, 유저정보 등 세부 정보가 표시됩니다.

### 🗒️  책 등록

- 책의 이미지, 이름, 작가, 출판사명, 출판년도, 거래가능 위치를 등록하여 내가 가진 책을 등록할 수 있습니다.
- location 등록시 지도상에서 위치를 지정해 등록이 가능합니다.
- “대여 장소를 현재 위치로 설정” 버튼을 누르면 그 위치로 거래 가능 장소가 설정됩니다.
- 등록된 책은 다른 유저들이 “주변 책 보기” 지도 상에서 거래가능위치로 확인할 수 있습니다.


### 🔍 책 검색

- 원하는 책의 이름을 검색할 수 있습니다
- 사용자가 읽기 원하는 책의 제목을 검색하면 해당 단어가 포함된 책들이 나타나게 됩니다.
- 키보드를 입력할때마다 해당되는 책의 리스트가 Listview로 표시됩니다.
- 책의 저자, 출판사, 대여가능 여부 등 세부정보를 확인할 수 있습니다.
- 책을 거래할 수 있는 장소를 확인할 수 있습니다.
- 책을 빌리기 원한다면 바로 책 주인과의 채팅으로 연결됩니다.


## 3️⃣ 화면


- 로그인 화면/회원가입 화면
    - 사용자가 바로북에 첫 접속시 로그인/회원가입을 진행할 수 있는 화면입니다.
    - 회원가입의 경우 아이디, 비밀번호, 이름을 입력하면 비밀번호는 즉시 hashing(sha-256)되어 사용자 정보가 서버에 저장되게 됩니다.
    - 마찬가지로 로그인도 사용자가 아이디/비밀번호를 입력하면 즉시 hashing되어 유효한 로그인인지 판단하게 됩니다.
    
- 메인 화면
    - 메인화면에는 이주의 책 추천이 시간이 지남에 따라 순환하며 사용자에게 책을 추천합니다.
    - 사용자는 메인화면을 통해 주변 책 찾아보기, 책 등록하기, 원하는 책 검색을 할 수 있습니다.
- 마이페이지
    - 마이페이지에는 사용자에 대한 정보가 표시됩니다.
    - 로그아웃을 실행하는 버튼이 있습니다.
    - 사용자가 등록한 책을 관리할 수 있습니다.
        - 등록한 책의 개수, 각 책의 상태(대여중, 대여 가능, 대여 불가) 등을 이 화면에서 설정 할 수 있습니다.
- 주변 책 보기(지도)
    - 사용자의 현재 위치를 기준으로 사용자 주변에 있는 책을 보여줍니다.
    - 책의 거래장소로 설정된 곳에 마커를 통해 지도에 그려줍니다.
    - 책에 대한 자세한 정보와 책의 현재 상태를 지도에 보여줍니다.
    - 사용자가 책이 마음에 든다면 바로 채팅을 할 수 있습니다.
- 책 등록
    - 책의 표지를 핸드폰 갤러리에서 선택하여 추가할 수 있습니다.
    - 책의 제목,출판사, 출판년도를 입력할 수 있습니다.
    - 등록하는 사람이 책을 주고받기 원하는 장소를 선택할 수 있습니다.
