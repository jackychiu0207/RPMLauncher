import 'dart:async';
import 'dart:io';

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:path/path.dart';
import 'package:rpmlauncher/config/config.dart';
import 'package:rpmlauncher/database/database.dart';
import 'package:rpmlauncher/function/analytics.dart';
import 'package:rpmlauncher/handler/window_handler.dart';
import 'package:rpmlauncher/i18n/i18n.dart';
import 'package:rpmlauncher/model/account/Account.dart';
import 'package:rpmlauncher/screen/main_screen.dart';
import 'package:rpmlauncher/util/data.dart';
import 'package:rpmlauncher/util/launcher_info.dart';
import 'package:rpmlauncher/util/logger.dart';
import 'package:rpmlauncher/util/theme.dart';
import 'package:rpmlauncher/util/util.dart';
import 'package:rpmlauncher/widget/dialog/CheckDialog.dart';
import 'package:rpmlauncher/widget/rwl_loading.dart';
import 'package:rpmlauncher_plugin/rpmlauncher_plugin.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loading();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return DynamicThemeBuilder(
          builder: (context, theme) => MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: theme,
                home: const Material(
                    child: RWLLoading(animations: true, logo: true)),
              ));
    } else {
      return const MainScreen();
    }
  }

  Future<void> loading() async {
    logger.info('Loading');
    await WindowHandler.init();
    await Data.argsInit();
    RPMTWApiClient.init();
    await Database.init();
    if (!kTestMode) {
      if (WindowHandler.isMainWindow) {
        try {
          DiscordRPC discordRPC = DiscordRPC(
              applicationId: 903883530822627370,
              libTempPath:
                  Directory(join(dataHome.path, 'discord-rpc-library')));
          await discordRPC.initialize();

          if (launcherConfig.discordRichPresence) {
            discordRPC.handler.start(autoRegister: true);
            discordRPC.handler.updatePresence(
              DiscordPresence(
                  state: 'https://www.rpmtw.com/RWL',
                  details: I18n.format('rpmlauncher.discord_rpc.details'),
                  startTimeStamp: LauncherInfo.startTime.millisecondsSinceEpoch,
                  largeImageKey: 'rwl_logo',
                  largeImageText:
                      I18n.format('rpmlauncher.discord_rpc.largeImageText'),
                  smallImageKey: 'minecraft',
                  smallImageText:
                      '${LauncherInfo.getFullVersion()} - ${LauncherInfo.getVersionType().name}'),
            );
          }
        } catch (e) {
          logger.error(ErrorType.io, 'failed to initialize discord rpc\n$e');
        }
      }

      googleAnalytics = Analytics();

      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        if (WindowHandler.isMainWindow) {
          return await showDialog(
              context: navigator.context,
              builder: (context) {
                return CheckDialog(
                  title: I18n.format('rpmlauncher.exit_confirm.title'),
                  onPressedOK: (context) {
                    WindowHandler.close()
                        .then((value) => Navigator.of(context).pop(true));
                  },
                  onPressedCancel: (context) {
                    Navigator.of(context).pop(false);
                  },
                );
              });
        } else {
          await WindowHandler.close();
          return true;
        }
      });
    }

    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      FlutterError.presentError(errorDetails);
      logger.error(ErrorType.flutter, errorDetails.exceptionAsString(),
          stackTrace: errorDetails.stack ?? StackTrace.current);
    };

    await SentryFlutter.init(
      (options) {
        options.release = 'rpmlauncher@${LauncherInfo.getFullVersion()}';
        options.dsn =
            'https://18a8e66bd35c444abc0a8fa5b55843d7@o1068024.ingest.sentry.io/6062176';
        options.tracesSampleRate = 1.0;
        FutureOr<SentryEvent?> beforeSend(SentryEvent event,
            {dynamic hint}) async {
          if (launcherConfig.isInit && kReleaseMode) {
            MediaQueryData data =
                MediaQueryData.fromWindow(WidgetsBinding.instance.window);
            Size size = data.size;
            String? userName = AccountStorage().getDefault()?.username ??
                Platform.environment['USERNAME'];

            SentryEvent newEvent;

            List<String> githubSourceMap = [];

            List<SentryException>? exceptions = event.exceptions;
            if (exceptions != null) {
              exceptions.forEach((SentryException exception) {
                exception.stackTrace?.frames.forEach((frames) {
                  if ((frames.inApp ?? false) &&
                      frames.package == 'rpmlauncher') {
                    githubSourceMap.add(
                        'https://github.com/RPMTW/RPMLauncher/blob/${LauncherInfo.isDebugMode ? 'develop' : LauncherInfo.getFullVersion()}/${frames.absPath?.replaceAll('package:rpmlauncher', 'lib/')}#L${frames.lineNo}');
                  }
                });
              });
            }
            newEvent = event.copyWith(
              user: SentryUser(
                  id: launcherConfig.googleAnalyticsClientId,
                  username: userName,
                  ipAddress: '{{auto}}',
                  data: {
                    'userOrigin': LauncherInfo.userOrigin,
                    'githubSourceMap': githubSourceMap,
                    'config': ConfigHelper.getAll(),
                  }),
              contexts: event.contexts.copyWith(
                  device: SentryDevice(
                    arch:
                        Util.getCPUArchitecture().replaceAll('AMD64', 'X86_64'),
                    memorySize:
                        ((await RPMLauncherPlugin.getTotalPhysicalMemory())
                                    .physical *
                                1024 *
                                1024)
                            .toInt(),
                    name: Platform.localHostname,
                    simulator: false,
                    screenHeightPixels: size.height.toInt(),
                    screenWidthPixels: size.width.toInt(),
                    screenDensity: data.devicePixelRatio,
                    online: true,
                    screenDpi: (data.devicePixelRatio * 160).toInt(),
                  ),
                  culture: SentryCulture(
                      timezone: DateTime.now().timeZoneName,
                      locale: Platform.localeName),
                  operatingSystem: SentryOperatingSystem(
                      theme:
                          ThemeUtil.getThemeByID(launcherConfig.themeId).name)),
              exceptions: exceptions,
            );

            return newEvent;
          } else {
            return null;
          }
        }

        options.beforeSend = beforeSend;
      },
    );

    logger.info('OS Version: ${await RPMLauncherPlugin.platformVersion}');

    if (launcherConfig.autoFullScreen) {
      await WindowHandler.setFullScreen(true);
    }

    await googleAnalytics?.ping();

    setState(() {
      isLoading = false;
    });
  }
}
