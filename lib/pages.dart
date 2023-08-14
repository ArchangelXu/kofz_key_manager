import 'dart:typed_data';
import 'dart:ui';

import 'package:charset/charset.dart';
import 'package:flutter/material.dart';
import 'package:kofz_key_manager/modules/config_keys/config_keys_view.dart';
import 'package:kofz_key_manager/modules/system/system_view.dart';
import 'package:kofz_key_manager/services/file.dart';
import 'package:starrail_ui/views/buttons/normal.dart';
import 'package:starrail_ui/views/card.dart';
import 'package:starrail_ui/views/misc/scroll.dart';
import 'package:universal_io/io.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildContainer(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SRCard(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "KOFZ按键管理",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
        _buildContainer(const SystemPage()),
        const SizedBox(height: 8),
        const Expanded(child: ConfigKeysPage()),
      ],
    );
    // return _TestEncodingPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets${Platform.pathSeparator}back.jpg",
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.25),
              colorBlendMode: BlendMode.srcOver,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}

class _TestEncodingPage extends StatefulWidget {
  const _TestEncodingPage({super.key});

  @override
  State<_TestEncodingPage> createState() => _TestEncodingPageState();
}

class _TestEncodingPageState extends State<_TestEncodingPage> {
  String text = "";

  Widget _buildContainer({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SRCard(
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SRButton.text(
              text: "select",
              highlightType: SRButtonHighlightType.highlightedPlus,
              onPress: () async {
                try {
                  File? file = await FileService.to.selectFile("cfg");
                  if (file == null) {
                    return;
                  }
                  Uint8List bytes = file.readAsBytesSync();
                  String decode = gbk.decode(bytes);
                  setState(() {
                    text = decode;
                  });
                } catch (e) {
                  print(e);
                  setState(() {
                    text = "$e";
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SRScrollView(children: [Text(text)]),
            ),
          ],
        ),
      ),
    );
  }
}
