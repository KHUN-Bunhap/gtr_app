import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ViewModel>();
          return Scaffold(
            appBar: AppBar(title: const Text('Template')),
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ViewModel extends ChangeNotifier {
  //
  final formKey = GlobalKey<FormState>();
}

void main() => runApp(const MaterialApp(title: 'Template', home: View()));
