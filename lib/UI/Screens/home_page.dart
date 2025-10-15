import 'package:flutter/material.dart';
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
    builder: (context){
      return AlertDialog(
        title: Text('Add an Expense'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop;
            },
            child: Text('Add'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop;
            },
            child: Text('Add'),
          ),
        ],
      );
  }
  );
}
