import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'Search.Dart';
import 'pages/home_page.dart';
import 'profile_page.dart';

void main(){
  runApp(const MaterialApp(debugShowCheckedModeBanner: false,
  home: ProfileEditPage(),),);
}

class ProfileEditPage extends StatefulWidget {
  final String initialName;
  final String initialBio;
  final DateTime? initialBirthday;

  // 保存時の処理
  final Function(
    String name,
    String bio,
    DateTime? birthday,
    Uint8List? iconImage,
    Uint8List? backgroundImage,
  )? onSave;

  // 下部メニューの遷移処理
  final Function(int)? onNavigate;

  const ProfileEditPage({
    super.key,
    this.initialName = '',
    this.initialBio = '',
    this.initialBirthday,
    this.onSave,
    this.onNavigate,
  });

  @override
  
  State<ProfileEditPage> createState() => _ProfileEditPageState();
  
  }

class _ProfileEditPageState extends State<ProfileEditPage> {
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _bioController;

  DateTime? _birthday;

  Uint8List? _iconImage;
  Uint8List? _backgroundImage;
Widget bottomIcon(IconData icon, double size, String name) {
  return IconButton(
    onPressed: () {
      if (name == '検索') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchPage(),
          ),
        );
      } else if (name == 'ホーム') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else if (name == 'マイページ') {
        Navigator.pop(context);
      }
    },
    icon: Icon(icon, size: size),
  );
}
  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName,
    );

    _bioController = TextEditingController(
      text: widget.initialBio,
    );

    _birthday = widget.initialBirthday;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  // 画像選択
  Future<void> _pickImage(bool isIcon) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    final Uint8List bytes = await image.readAsBytes();

    setState(() {
      if (isIcon) {
        _iconImage = bytes;
      } else {
        _backgroundImage = bytes;
      }
    });
  }

  // 生年月日選択
  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: '生年月日を選択',
    );

    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  // 生年月日の表示
  String _birthdayText() {
    if (_birthday == null) {
      return '生年月日を選択';
    }

    return '${_birthday!.year}年'
        '${_birthday!.month}月'
        '${_birthday!.day}日';
  }

  // 保存
  Future<void> _saveProfile() async {
    try{
      final success = await widget.onSave?.call(
      _nameController.text,
      _bioController.text,
      _birthday,
      _iconImage,
      _backgroundImage,
      );
      if(success == true){
        Navigator.pop(context,true);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールの保存に失敗しました'),),);
      }
    
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存中にエラーが発生しました'),),);
    }
    
      
  
    //メッセージ表示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プロフィールを保存しました'),
        duration:Duration(seconds: 2),
      ),
    );
    //マイページに戻る
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // プロフィール編集部分
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),

                    _buildNameField(),

                    _buildBioField(),

                    _buildBirthdayField(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 下部メニュー
     bottomNavigationBar: Container(
  height: 48,
  decoration: const BoxDecoration(
    border: Border(
      top: BorderSide(color: Colors.black, width: 1.5),
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      bottomIcon(Icons.search, 30, '検索'),
      bottomIcon(Icons.home, 32, 'ホーム'),
      bottomIcon(Icons.person, 30, 'マイページ'),
    ],
  ),
),
    );
  }

  // 上部背景・戻る・保存
  Widget _buildHeader() {
    return SizedBox(
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 背景画像
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),

              child: _backgroundImage != null
                  ? Image.memory(
                      _backgroundImage!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 75,
                      color: Colors.grey,
                    ),
            ),
          ),

          // 戻るボタン
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // 保存ボタン
          Positioned(
            top: 10,
            right: 10,
            child: TextButton(
              onPressed: _saveProfile,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('保存'),
            ),
          ),

          // 背景画像変更
          Positioned(
            top: 65,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _pickImage(false),
              child: const Icon(
                Icons.camera_alt,
                size: 75,
                color: Colors.grey,
              ),
            ),
          ),

          // プロフィールアイコン
          Positioned(
            top: 130,
            left: 10,
            child: GestureDetector(
              onTap: () => _pickImage(true),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),

                child: ClipOval(
                  child: _iconImage != null
                      ? Image.memory(
                          _iconImage!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 45,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 名前
  Widget _buildNameField() {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey),
          bottom: BorderSide(color: Colors.grey),
        ),
      ),

      child: Row(
        children: [
          const SizedBox(
            width: 60,
            child: Text('名前'),
          ),

          Expanded(
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '名前を入力',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 自己紹介
  Widget _buildBioField() {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 70,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('自己紹介'),
            ),
          ),

          Expanded(
            child: TextField(
              controller: _bioController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '自己紹介を入力',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 生年月日
  Widget _buildBirthdayField() {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),

      child: Row(
        children: [
          const SizedBox(
            width: 70,
            child: Text('生年月日'),
          ),

          Expanded(
            child: GestureDetector(
              onTap: _selectBirthday,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Text(_birthdayText()),

                    const SizedBox(width: 10),

                    const Icon(
                      Icons.calendar_month,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 下部メニュー
 // 下部メニュー
Widget _buildBottomNavigation() {
  return Container(
    height: 50,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(
          color: Colors.black,
          width: 1,
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 検索
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchPage(),
              ),
            );
          },
          icon: const Icon(
            Icons.search,
            size: 35,
            color: Colors.black,
          ),
        ),

        // ホーム
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
          icon: const Icon(
            Icons.home,
            size: 35,
            color: Colors.black,
          ),
        ),

        // マイページ
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.person,
            size: 35,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
}