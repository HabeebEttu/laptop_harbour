import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class Stats extends StatelessWidget {
  const Stats({super.key, required this.statData});

  final List<Map<String, dynamic>> statData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(statData.length, (index) {
        dynamic stat = statData[index];

        return ListTile(
          leading: FaIcon(stat['icon'], color: Colors.blueGrey),
          title: Text(
            stat['title'],
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(stat['subtitle']),
        );
      }),
    );
  }
}
