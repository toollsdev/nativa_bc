import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';
import 'package:nativa_bc/home_page.dart';

/// Um Fake handler mínimo só para não quebrar o teste.
class FakeAudioHandler extends Fake implements AudioHandler {
  @override
  Stream<PlaybackState> get playbackState =>
      Stream.value(const PlaybackState(false, Duration.zero, 1.0));
  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {}
}

void main() {
  late AudioHandler fakeHandler;

  setUpAll(() {
    fakeHandler = FakeAudioHandler();
  });

  testWidgets('HomePage renderiza sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(audioHandler: fakeHandler),
      ),
    );
    expect(find.byType(HomePage), findsOneWidget);
  });
}
