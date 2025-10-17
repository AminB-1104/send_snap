import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:send_snap/UI/Components/appbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showMyDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<void> _showMyDialog(BuildContext context) {
  return showDialog(
    context: context,
    useRootNavigator: true,
    builder: (context) {
      return AlertDialog(
        title: Text('Add an Expense'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.pushNamed('/imagegallery');
            },
            child: Text('Pick From Gallery'),
          ),
          TextButton(
            onPressed: () {
              context.pushNamed('/imagecamera');
            },
            child: Text('Take Photo'),
          ),
        ],
      );
    },
  );
}
