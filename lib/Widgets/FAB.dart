import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:simple_animated_icon/simple_animated_icon.dart';

class FAB extends StatefulWidget {
  final Function singlePageScanOnPresed;
  final Function multiPageScanOnPressed;
  final Function galleryOnPressed;
  final Function dialOpen;
  final Function dialClose;

  const FAB({
    Key key,
    this.singlePageScanOnPresed,
    this.multiPageScanOnPressed,
    this.galleryOnPressed,
    this.dialOpen,
    this.dialClose,
  });

  @override
  _FABState createState() => _FABState();
}

class _FABState extends State<FAB> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            setState(() {});
          });
    _progress =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      marginRight: 18,
      marginBottom: 20,
      child: SimpleAnimatedIcon(
        startIcon: Icons.add,
        endIcon: Icons.close,
        size: 30,
        progress: _progress,
      ),
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.white,
      overlayOpacity: 0.1,
      tooltip: 'Scan Options',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Theme.of(context).accentColor,
      foregroundColor: Theme.of(context).primaryColor,
      elevation: 0.0,
      shape: CircleBorder(),
      onOpen: () {
        _animationController.forward();
      },
      onClose: () {
        _animationController.reverse();
      },
      children: [
        SpeedDialChild(
          elevation: 0,
          child: Icon(Icons.camera_alt),
          backgroundColor: Theme.of(context).accentColor,
          label: 'Single Page',
          labelStyle: TextStyle(fontSize: 18.0, color: Colors.black),
          onTap: widget.singlePageScanOnPresed,
        ),
        SpeedDialChild(
          elevation: 0,
          child: Icon(Icons.timelapse),
          backgroundColor: Theme.of(context).accentColor,
          label: 'Multi Page',
          labelStyle: TextStyle(fontSize: 18.0, color: Colors.black),
          onTap: widget.multiPageScanOnPressed,
        ),
        SpeedDialChild(
          elevation: 0,
          child: Icon(Icons.image),
          backgroundColor: Theme.of(context).accentColor,
          label: 'Import from Gallery',
          labelStyle: TextStyle(fontSize: 18.0, color: Colors.black),
          onTap: widget.galleryOnPressed,
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}
