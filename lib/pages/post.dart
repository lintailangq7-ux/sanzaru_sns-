import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';



class PostData{
  final String text;
  final String visibility;
  final List<XFile> images;
  final List<PlatformFile> audios;

  PostData({
    required this.text,
    required this.visibility,
    required this.images,
    required this.audios,
  });
}



class PostPage extends StatefulWidget {
  const PostPage({super.key});
  
 


  @override
  State<PostPage> createState() => _PostPageState();

}
  
  //公開範囲
  class _PostPageState extends State<PostPage>{
    String visibility = '全体に公開';
  
   // テキスト入力
  final TextEditingController postController =
      TextEditingController();
  
// 選択した画像
final List<XFile> selectedImages = [];

// 選択した音声
final List<PlatformFile> selectedAudios = [];

// 音声再生
final AudioPlayer audioPlayer = AudioPlayer();

int? playingAudioIndex;
bool isPlaying = false;
 // ハッシュタグ追加
  void addHashtag() {
    final hashtagController = TextEditingController();
 showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ハッシュタグを追加'),
          content: TextField(
            controller: hashtagController,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: 'ハッシュタグを入力',
              hintText: '例：旅行',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                String tag = hashtagController.text.trim();

                if (tag.isEmpty) {
                  return;
                }

                tag = '#${tag.replaceAll(RegExp(r'^#+'), '')}';

                final currentText = postController.text;
                final separator =
                    currentText.isNotEmpty &&
                    !currentText.endsWith('\n')
                        ? '\n'
                        : '';

                postController.text =
                    '$currentText$separator$tag ';

                Navigator.pop(context);
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }
  // 画像追加
Future<void> addImage() async {
  final images = await ImagePicker().pickMultiImage();

  if (images.isNotEmpty) {
    setState(() {
      selectedImages.addAll(images);
    });
  }
}

// 画像削除
void removeImage(int index) {
  setState(() {
    selectedImages.removeAt(index);
  });
}

// 音声追加
Future<void> addAudio() async {
  final files = await FilePicker.pickFiles(
    type: FileType.audio,

  );

  if (files.isNotEmpty) {
    setState(() {
      selectedAudios.addAll(files);
    });
  }
}


// 音声削除
Future<void> removeAudio(int index) async {
  if (playingAudioIndex == index) {
    await audioPlayer.stop();
    playingAudioIndex = null;
    isPlaying = false;
  }

  setState(() {
    selectedAudios.removeAt(index);
  });
}
// 音声再生
Future<void> toggleAudio(int index) async {
  if (playingAudioIndex == index && isPlaying) {
    await audioPlayer.pause();

    setState(() {
     isPlaying = false;
  });
  return;
  }
//音声ファイルを読み込む
  final audio = selectedAudios[index];
  final bytes = await audio.readAsBytes();

 

  await audioPlayer.stop();
  await audioPlayer.setSourceBytes(bytes);
  await audioPlayer.resume();

  setState(() {
    playingAudioIndex = index;
    isPlaying = true;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //上部メニュー
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('投稿作成',style: TextStyle(color:Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: (){
            if(postController.text.trim().isEmpty &&
            selectedImages.isEmpty &&
            selectedAudios.isEmpty){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('投稿内容を入力してください'),
              ),);
              return;
            }
            //投稿データを作成
            final newPost = PostData(
              text: postController.text.trim(),
              visibility: visibility, 
              images: List<XFile>.from(selectedImages), 
              audios: List<PlatformFile>.from(selectedAudios),
            );
            //ホーム画面に戻り、投稿データを渡す
            Navigator.pop(context,newPost);
          },
          child: const Text('投稿',
          style: TextStyle(
            color:Colors.blue,
            fontSize:16,
          ),
          ),
          ),
        ],

      ),
        // 画面本体
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // アカウント表示
            const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'ユーザー名',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 公開範囲
            DropdownButton<String>(
              value: visibility,
              items: const [
                DropdownMenuItem(
                  value: '全体に公開',
                  child: Text('全体に公開'),
                ),
                DropdownMenuItem(
                  value: 'フォロワーのみ',
                  child: Text('フォロワーのみ'),
                ),
                DropdownMenuItem(
                  value: '自分のみ',
                  child: Text('自分のみ'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    visibility = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),
          

          
            // テキスト入力欄
            SizedBox(
              width: double.infinity,
              height: 180,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // テキスト入力
                    Expanded(
                      child: TextField(
                        controller: postController,
                        minLines: 3,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: '今何をしていますか？',
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    // ハッシュタグ追加ボタン
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: TextButton.icon(
                        onPressed: addHashtag,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.blue,
                        ),
                        label: const Text(
                          'ハッシュタグ追加',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 画像追加エリア
            const SizedBox(height: 15),

            
                  
           
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade400),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 画像追加ボタン
      SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton.icon(
          onPressed: addImage,
          icon: const Icon(
            Icons.add_photo_alternate,
            color: Colors.blue,
          ),
          label: const Text(
            '画像を追加',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),

      // 選択した画像の表示
      if (selectedImages.isNotEmpty) ...[
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: selectedImages.asMap().entries.map((entry) {
            final index = entry.key;
            final image = entry.value;

            return Stack(
              children: [
                FutureBuilder(
                  future: image.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          snapshot.data!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    }

                    return const SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),

                // 画像削除
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => removeImage(index),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    ],
  ),
),


            // 音声追加エリア
            

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade400),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Column(
    children: [
      // 音声追加ボタン
      SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton.icon(
          onPressed: addAudio,
          icon: const Icon(
            Icons.add,
            color: Colors.blue,
          ),
          label: const Text(
            '音声を追加',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),

      // 選択した音声の表示
      ...selectedAudios.asMap().entries.map((entry) {
        final index = entry.key;
        final audio = entry.value;

        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // 再生・一時停止
              IconButton(
                onPressed: () => toggleAudio(index),
                icon: Icon(
                  playingAudioIndex == index && isPlaying
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  color: Colors.blue,
                  size: 30,
                ),
              ),

              // 音声ファイル名
              Expanded(
                child: Text(
                  audio.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 削除
              IconButton(
                onPressed: () => removeAudio(index),
                icon: const Icon(
                  Icons.close,
                  color: Colors.grey,
                ),
               ),
            ],
          ),
        );
       }),
    ],
  ),
),
],
 ),
),
);

}

@override
  void dispose() {
    postController.dispose();
    audioPlayer.dispose();
    super.dispose();
} 
}    