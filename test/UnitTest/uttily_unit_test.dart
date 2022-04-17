import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:desktop_multi_window/src/channels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:rpmlauncher/handler/window_handler.dart';
import 'package:rpmlauncher/util/util.dart';
import '../util/test_util.dart';

void main() async {
  setUpAll(() => TestUtil.init());

  group('Uttily Class -', () {
    test("Minecraft Version Parse", () {
      expect(Util.parseMCComparableVersion("1.18-pre1"), Version(1, 18, 0));
      expect(Util.parseMCComparableVersion("21w20a"), Version(1, 17, 0));
      expect(Util.parseMCComparableVersion("18w22c"), Version(1, 13, 0));
      expect(Util.parseMCComparableVersion("11w47a"), Version(1, 1, 0));
      expect(Util.parseMCComparableVersion("1.16.5-rc1"),
          Version(1, 16, 5, pre: "rc1"));
    });
    test("Check NetWork", () async {
      expect(await Util.hasNetWork(), true);
    });

    test("Get library separator", () async {
      expect(Util.getLibrarySeparator(), ":");
    }, skip: !(Platform.isLinux || Platform.isMacOS));
    test("Get library separator", () async {
      expect(Util.getLibrarySeparator(), ";");
    }, skip: !(Platform.isWindows));
    test("Open new window", () async {
      miltiWindowChannel.setMockMethodCallHandler((call) async {
        switch (call.method) {
          case "createWindow":
            return 1;
        }
      });
      WindowController window = await WindowHandler.create("/");
      expect(window.windowId, 1);
    });
  });
}
