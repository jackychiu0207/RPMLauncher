import 'dart:io';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rpmlauncher/config/config.dart';
import 'package:rpmlauncher/i18n/i18n.dart';
import 'package:rpmlauncher/model/Game/MinecraftNews.dart';
import 'package:rpmlauncher/model/Game/MinecraftSide.dart';
import 'package:rpmlauncher/route/PushTransitions.dart';
import 'package:rpmlauncher/screen/about.dart';
import 'package:rpmlauncher/screen/settings.dart';
import 'package:rpmlauncher/screen/version_selection.dart';
import 'package:rpmlauncher/util/data.dart';
import 'package:rpmlauncher/util/launcher_info.dart';
import 'package:rpmlauncher/util/updater.dart';
import 'package:rpmlauncher/util/util.dart';
import 'package:rpmlauncher/view/MinecraftNewsView.dart';
import 'package:rpmlauncher/view/instance_view.dart';
import 'package:rpmlauncher/view/row_scroll_view.dart';
import 'package:rpmlauncher/widget/AccountManageAction.dart';
import 'package:rpmlauncher/widget/dialog/UpdaterDialog.dart';
import 'package:rpmlauncher/widget/dialog/quick_setup.dart';
import 'package:rpmlauncher/widget/keep_alive_wrapper.dart';
import 'package:rpmlauncher/widget/rpmtw_design/NewFeaturesWidget.dart';
import 'package:rpmlauncher/widget/rpmtw_design/OkClose.dart';
import 'package:rpmlauncher/widget/rwl_loading.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';
  final int initialPage;

  const HomePage({Key? key, this.initialPage = 0}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!launcherConfig.isInit && mounted) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const QuickSetup());
      } else {
        Updater.checkForUpdate(Updater.fromConfig()).then((info) {
          if (info.needUpdate && mounted) {
            showDialog(
                context: context,
                builder: (context) => UpdaterDialog(info: info));
          }
        });
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return Dialog.fullscreen(
                    child: Center(
                        child: SingleChildScrollView(
                            child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '已不再支援 RPMLauncher',
                                      textScaleFactor: 3,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    const SingleChildScrollView(
                                        child: Text(
                                      "有鑑於當初 RPMLauncher 的設計問題，留下了許多技術債，導致目前的啟動器存在大量 bug 與穩定性問題。\n因此，我們決定重新設計，這次不僅僅是重新設計技術層面，我們也將大幅改進使用者介面與體驗。\n\n全新的啟動器將稱作 Era Connect，期望在未來帶給您最好的體驗!\n\n在 Era Connect 正式發布之前，我們強烈建議您以 Prism Launcher 作為替代方案，點選下方按紐即可前往其官方網站。\n\n如果您仍想要繼續使用 RPMLauncher，請按下方按鈕繼續，但請自行承擔風險，我們也不接受任何的技術支援。",
                                      textScaleFactor: 1.5,
                                    )),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: TextButton(
                                                onPressed: () {
                                                  exit(0);
                                                },
                                                child: const Text('關閉此程式',
                                                    textScaleFactor: 2))),
                                        Expanded(
                                            child: TextButton(
                                                onPressed: () {
                                                  Util.openUri(
                                                      'https://prismlauncher.org/');
                                                },
                                                child: const Text(
                                                    '前往 Prism Launcher 官網',
                                                    textScaleFactor: 2))),
                                        Expanded(
                                            child: TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  '已知風險，仍繼續使用',
                                                  textScaleFactor: 2,
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ))),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Divider(),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      "RPMTW 相關連結",
                                      textScaleFactor: 2,
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Util.openUri(
                                                  LauncherInfo.homePageUrl);
                                            },
                                            icon: const Icon(LineIcons.home,
                                                size: 50),
                                            tooltip:
                                                I18n.format('homepage.website'),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Util.openUri(
                                                  LauncherInfo.githubRepoUrl);
                                            },
                                            icon: const Icon(LineIcons.github,
                                                size: 50),
                                            tooltip:
                                                I18n.format('about.github'),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Util.openUri(
                                                  LauncherInfo.discordUrl);
                                            },
                                            icon: const Icon(
                                              LineIcons.discord,
                                              size: 50,
                                            ),
                                            tooltip:
                                                I18n.format('about.discord'),
                                          ),
                                        ]),
                                  ],
                                )))));
              });
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialPage,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leadingWidth: 250,
          leading: RowScrollView(
            center: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: I18n.format('homepage.website'),
                  onPressed: () {
                    Util.openUri(LauncherInfo.homePageUrl);
                  },
                  icon: Image.asset('assets/images/Logo.png', scale: 4),
                ),
                IconButton(
                  tooltip: I18n.format('gui.settings'),
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    navigator.pushNamed(SettingScreen.route);
                  },
                ),
                IconButton(
                  tooltip: I18n.format('homepage.data.folder.open'),
                  icon: const Icon(Icons.folder),
                  onPressed: () {
                    Util.openFileManager(dataHome);
                  },
                ),
                IconButton(
                  tooltip: I18n.format('homepage.about'),
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PushTransitions(builder: (context) => AboutScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.change_circle),
                  tooltip: I18n.format('homepage.update'),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => FutureBuilder<VersionInfo>(
                            future:
                                Updater.checkForUpdate(Updater.fromConfig()),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                VersionInfo info = snapshot.data!;
                                if (info.needUpdate) {
                                  return UpdaterDialog(info: snapshot.data!);
                                } else {
                                  return AlertDialog(
                                    title: I18nText.tipsInfoText(),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        I18nText('updater.check.none'),
                                        const Icon(Icons.done_outlined,
                                            size: 30),
                                      ],
                                    ),
                                    actions: const [OkClose()],
                                  );
                                }
                              } else {
                                return AlertDialog(
                                  title: I18nText.tipsInfoText(),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      I18nText('updater.check.checking'),
                                      const SizedBox(
                                        width: 30.0,
                                        height: 30.0,
                                        child: FittedBox(child: RWLLoading()),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }));
                  },
                ),
              ],
            ),
          ),
          title: Text(
            LauncherInfo.getUpperCaseName(),
          ),
          bottom: TabBar(tabs: [
            Tab(
                icon: const Icon(Icons.sports_esports),
                text: I18n.format('homepage.tabs.instance')),
            Tab(
                icon: const NewFeaturesWidget(child: Icon(LineIcons.server)),
                text: I18n.format('homepage.tabs.server')),
            Tab(
                icon: const Icon(Icons.notifications),
                text: I18n.format('homepage.tabs.news')),
          ]),
          actions: const [
            AccountManageButton(),
          ],
        ),
        body: TabBarView(
          children: [
            const KeepAliveWrapper(
                child: InstanceView(side: MinecraftSide.client)),
            const KeepAliveWrapper(
                child: InstanceView(side: MinecraftSide.server)),
            KeepAliveWrapper(
              child: FutureBuilder<MinecraftNews>(
                future: MinecraftNews.fromWeb(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final news = snapshot.data!;

                    return MinecraftNewsView(news: news);
                  } else {
                    return const RWLLoading();
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: const _FloatingAction(),
      ),
    );
  }
}

class _FloatingAction extends StatefulWidget {
  const _FloatingAction({
    Key? key,
  }) : super(key: key);

  @override
  State<_FloatingAction> createState() => _FloatingActionState();
}

class _FloatingActionState extends State<_FloatingAction> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      DefaultTabController.of(context).addListener(() {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int index = DefaultTabController.of(context).index;
    if (index == 0) {
      return FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(
              context,
              PushTransitions(
                  builder: (context) => const VersionSelection(
                        side: MinecraftSide.client,
                      )));
        },
        tooltip: I18n.format('version.list.instance.add'),
        child: const Icon(Icons.add),
      );
    } else if (index == 1) {
      return FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(
              context,
              PushTransitions(
                  builder: (context) => const VersionSelection(
                        side: MinecraftSide.server,
                      )));
        },
        tooltip: I18n.format('version.list.instance.add.server'),
        child: const Icon(Icons.add),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
