import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'api_client.dart';
import 'pages/home_page.dart' show PostActions;

/// 投稿1件のカード(ホーム画面と同じ見た目)。検索結果などで使う
class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final mediaList =
        ((post['media'] as List?) ?? []).cast<Map<String, dynamic>>();
    final images = mediaList.where((m) => m['type'] == 'image').toList();
    final audios = mediaList.where((m) => m['type'] == 'audio').toList();

    final userName = post['authorName']?.toString() ?? '不明';
    final content =
        post['content']?.toString() ?? post['text']?.toString() ?? '';
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
        (post['createdAt'] as num?)?.toInt() ?? 0);
    final textHidden = post['textHidden'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ユーザー名
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 10),
                Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // 本文
            if (textHidden) ...[
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '🙊 あなたは本文を見ることができません',
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ] else if (content.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(content),
            ],

            // 画像
            if (images.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: images.map((img) {
                  if (img['blocked'] == true) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        '🙈 あなたは画像を見ることができません',
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    );
                  }
                  final url =
                      '$baseUrl/api/media/${img['id']}?token=${ApiClient.token}';
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                        width: 100,
                        height: 100,
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // 音声
            if (audios.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...audios.asMap().entries.map((e) {
                if (e.value['blocked'] == true) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '🙉 あなたは音声を聞くことができません',
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  );
                }
                return PostAudioTile(
                  fileName: '音声 ${e.key + 1}',
                  audioUrl:
                      '$baseUrl/api/media/${e.value['id']}?token=${ApiClient.token}',
                );
              }),
            ],

            const SizedBox(height: 8),
            PostActions(
              createdAt: createdAt,
              initialLikeCount: (post['likeCount'] as num?)?.toInt() ?? 0,
            ),
          ],
        ),
      ),
    );
  }
}

/// 音声の再生ボタン
class PostAudioTile extends StatefulWidget {
  final String fileName;
  final String audioUrl;
  const PostAudioTile({
    super.key,
    required this.fileName,
    required this.audioUrl,
  });

  @override
  State<PostAudioTile> createState() => _PostAudioTileState();
}

class _PostAudioTileState extends State<PostAudioTile> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _player.setSource(UrlSource(widget.audioUrl));
      await _player.resume();
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('音声の再生に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: IconButton(
        icon: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Colors.blue,
                size: 32,
              ),
        onPressed: _isLoading ? null : _togglePlay,
      ),
      title: Text(widget.fileName, overflow: TextOverflow.ellipsis),
    );
  }
}