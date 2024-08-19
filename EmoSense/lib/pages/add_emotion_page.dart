import 'package:flutter/material.dart';

class AddEmotionRecordPage extends StatefulWidget {
  static String routeName = '/AddEmotionRecordPage';

  const AddEmotionRecordPage({Key? key}) : super(key: key);

  @override
  State<AddEmotionRecordPage> createState() => _AddEmotionRecordPageState();
}

class _AddEmotionRecordPageState extends State<AddEmotionRecordPage> {
  // TextEditingController _usernameTextController = TextEditingController();
  // TextEditingController _emailTextController = TextEditingController();
  // TextEditingController _passwordTextController = TextEditingController();
  // TextEditingController _confirmTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text('AddEmotionRecordPage')),
          body: Center(
            child: Text('AddEmotionRecordPage'),
          ),
        ),
      ],
    );
  }
}
