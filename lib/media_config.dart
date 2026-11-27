import 'api_client.dart';

// ================================================================
// ★【サーバー版の設定】サーバーのIPアドレスを書く
//   Apacheで配信している画像・音声の置き場所(/var/www/html/media/)
// ================================================================
const mediaBase = String.fromEnvironment(
  'MEDIA_BASE',
  defaultValue: 'http://10.22.107.227/media/',
);

/// media 1件分のURLを作る。
/// ・APIが file_path(filePath)を返している → サーバー版: mediaBase + パス
/// ・返していない(ローカルDBなど)       → 元どおり: API経由のURL
String mediaUrlOf(Map<String, dynamic> m, dynamic mediaId) {
  print('★media要素: $m');
  final path = (m['filePath'] ?? m['file_path'] ?? m['path'])?.toString();
    if (path != null && path.isNotEmpty) {
    print('★サーバー版URL: $mediaBase$path');
    return '$mediaBase$path';
  }
  // ▼▼▼【ローカルDB版】元のURL(APIが filePath を返さないときはこちらになる) ▼▼▼
  print('★API経由URL: $baseUrl/api/media/$mediaId');   // ← 追加
  return '$baseUrl/api/media/$mediaId?token=${ApiClient.token}';
  // ▲▲▲【ローカルDB版】ここまで ▲▲▲
}