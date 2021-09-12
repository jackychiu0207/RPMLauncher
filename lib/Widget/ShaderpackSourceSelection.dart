import 'dart:io';

import 'package:rpmlauncher/Launcher/InstanceRepository.dart';
import 'package:rpmlauncher/Utility/i18n.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class ShaderpackSourceSelection_ extends State<ShaderpackSourceSelection> {
  late String InstanceDirName;
  late Directory ModDir =
      InstanceRepository.getInstanceModRootDir(InstanceDirName);

  ShaderpackSourceSelection_(InstanceDirName_) {
    InstanceDirName = InstanceDirName_;
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Center(
        child: AlertDialog(
      scrollable: true,
      title: Text("請選擇光影來源", textAlign: TextAlign.center),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              FloatingActionButton(
                backgroundColor: Colors.deepPurpleAccent,
                onPressed: () async {
                  final files = await FileSelectorPlatform.instance
                      .openFiles(acceptedTypeGroups: [
                    XTypeGroup(
                        label: '光影檔案', mimeTypes: [], extensions: ['zip']),
                  ]);
                  if (files.length == 0) return;
                  for (XFile file in files) {
                    File(file.path)
                        .copySync(join(ModDir.absolute.path, file.name));
                  }
                  Navigator.pop(context);
                },
                child: Icon(Icons.computer),
              ),
              SizedBox(
                height: 12,
              ),
              Text(i18n.Format("source.local"))
            ],
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.close_sharp),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: i18n.Format("gui.close"),
        )
      ],
    ));
  }
}

class ShaderpackSourceSelection extends StatefulWidget {
  late String InstanceDirName;

  ShaderpackSourceSelection(InstanceDirName_) {
    InstanceDirName = InstanceDirName_;
  }

  @override
  ShaderpackSourceSelection_ createState() =>
      ShaderpackSourceSelection_(InstanceDirName);
}