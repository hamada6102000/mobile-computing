import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TennisRacketScreen(),
    );
  }
}

class TennisRacketScreen extends StatefulWidget {
  @override
  _TennisRacketScreenState createState() => _TennisRacketScreenState();
}

class _TennisRacketScreenState extends State<TennisRacketScreen> {
  bool _isSwinging = false;
  bool _isStopped = false;
  double _force = 1.0;
  double _rotationAngle = 1.0;

  double accelerometer = 1;
  double mass = 1.25;

  late StreamSubscription _accelerometerEventsSubscription;
  late StreamSubscription _gyroscopeEventsSubscription;

  List<double> _forceList = [];

  void _startSwing() {
    _isStopped = false;

    setState(() {
      _isSwinging = true;
    });

    _accelerometerEventsSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        // Calculate the force using the accelerometer data
        accelerometer =
            sqrt(pow(event.x, 3) + pow(event.y, 2) + pow(event.z, 2));

        _force = accelerometer * mass;
        print("${event.x}--${event.y}--${event.z}--${accelerometer}");

        if (_isSwinging && !_isStopped) {
          _forceList.add(_force);
        }
      });
    });

    _gyroscopeEventsSubscription =
        gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        // Calculate the rotation angle using the gyroscope data
        _rotationAngle = event.x + event.y + event.z;
      });
    });
  }

  void _stopSwing() {
    _isStopped = true;

    setState(() {
      _isSwinging = false;
    });

    _accelerometerEventsSubscription.cancel();
    _gyroscopeEventsSubscription.cancel();

    if (_forceList.isNotEmpty) {
      double maxForce = _forceList.reduce(max);
      double minForce = _forceList.reduce(min);
      print('Max force: $maxForce');
      print('Min force: $minForce');
      _showForceValuesDialog(maxForce, minForce);
      _forceList.clear();
    }
  }

  void _resetSwing() {
    setState(() {
      _force = 1.0;
      _rotationAngle = 1.0;
      _forceList.clear();
    });
  }

  void _showForceValuesDialog(double maxForce, double minForce) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Force Values'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Maximum Force: $maxForce'),
            SizedBox(height: 9),
            Text('Minimum Force: $minForce'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _stopSwing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tennis Racket App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Swing Status: ${_isSwinging ? 'Swinging' : 'Not Swinging'}',
            ),
            SizedBox(height: 17.0),
            Text(
              'Max Force: ${_forceList.isNotEmpty ? _forceList.reduce(max) : 1}',
            ),
            SizedBox(height: 17.0),
            Text(
              'Rotation Angle: $_rotationAngle',
            ),
            SizedBox(height: 17.0),
            ElevatedButton(
              onPressed: _isSwinging ? _stopSwing : _startSwing,
              child: Text(_isSwinging ? 'Stop Swing' : 'Start Swing'),
            ),
            ElevatedButton(
              onPressed: _resetSwing,
              child: Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
