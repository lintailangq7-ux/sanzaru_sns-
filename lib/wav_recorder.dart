import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'api_client.dart';

/// マイクで録音して、WAV(16bit・16000Hz・モノラル)にする
class WavRecorder {
  static const int sampleRate = 16000;

  final AudioRecorder _rec = AudioRecorder();
  final List<int> _pcm = [];
  StreamSubscription<Uint8List>? _sub;

  /// 録音を始める。マイクの許可がもらえなければ false
  Future<bool> start() async {
    if (!await _rec.hasPermission()) return false;
    _pcm.clear();
    final stream = await _rec.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: sampleRate,
      numChannels: 1,
    ));
    _sub = stream.listen(_pcm.addAll);
    return true;
  }

  /// 録音を止めて WAV を返す。1秒未満なら null
  Future<UploadFile?> stop() async {
    await _rec.stop();
    await _sub?.cancel();
    _sub = null;
    if (_pcm.length < sampleRate * 2) return null; // 1秒 = 32000バイト
    return UploadFile(_toWav(Uint8List.fromList(_pcm)), 'voice.wav');
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _rec.dispose();
  }

  /// 生の音の前に、44バイトのWAVのヘッダーを付ける
  static Uint8List _toWav(Uint8List pcm) {
    final header = ByteData(44);
    void text(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    text(0, 'RIFF');
    header.setUint32(4, 36 + pcm.length, Endian.little);
    text(8, 'WAVE');
    text(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // モノラル
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little); // 16bit
    text(36, 'data');
    header.setUint32(40, pcm.length, Endian.little);

    final out = BytesBuilder();
    out.add(header.buffer.asUint8List());
    out.add(pcm);
    return out.toBytes();
  }
}