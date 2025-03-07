import 'dart:html';

import 'package:flutter/material.dart';
import 'package:seo_renderer/helpers/utils.dart';

/// This VM import stub does nothing and only returns the child.
class ImageRenderer extends StatefulWidget {
  /// Default [ImageRenderer] const constructor.
  const ImageRenderer({
    Key? key,
    this.controller,
    required this.child,
    required this.link,
    required this.alt,
  }) : super(key: key);

  ///Any Widget with image in it
  final Widget child;

  ///Image source
  final String link;

  ///Alternative to image
  final String alt;

  ///Optional : [RenderController] object if you want to perform certain actions.
  final RenderController? controller;

  @override
  _ImageRendererState createState() => _ImageRendererState();
}

class _ImageRendererState extends State<ImageRenderer> with RouteAware {
  final DivElement div = DivElement();
  final key = GlobalKey();

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    clear();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.refresh = refresh;
    widget.controller?.clear = clear;
  }

  @override
  void didPop() {
    clear();
    super.didPop();
  }

  @override
  void didPush() {
    addDivElement();
    super.didPush();
  }

  @override
  void didPopNext() {
    addDivElement();
    super.didPopNext();
  }

  @override
  void didPushNext() {
    clear();
    super.didPushNext();
  }

  void refresh() {
    div.style.position = 'absolute';
    div.style.top = '${key.globalPaintBounds?.top ?? 0}px';
    div.style.left = '${key.globalPaintBounds?.left ?? 0}px';
    var imageElement = new ImageElement()
      ..src = widget.link
      ..alt = widget.alt
      ..width = (key.globalPaintBounds?.width ?? 100).toInt()
      ..height = (key.globalPaintBounds?.height ?? 100).toInt();
    div.children.removeWhere((element) => true);
    div.append(imageElement);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        key: key,
        builder: (_, __) {
          return NotificationListener(
              onNotification: (SizeChangedLayoutNotification notification) {
                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  refresh();
                });
                return true;
              },
              child: SizeChangedLayoutNotifier(child: widget.child));
        });
  }

  addDivElement() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (!regExpBots.hasMatch(window.navigator.userAgent.toString())) {
        return;
      }
      refresh();
      if (!document.body!.contains(div)) document.body?.append(div);
    });
  }

  void clear() {
    div.remove();
  }
}
