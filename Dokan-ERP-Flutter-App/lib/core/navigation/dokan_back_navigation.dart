import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> showDokanExitConfirmationDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('NO'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('YES'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<void> handleDokanBackNavigation(BuildContext context) async {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
    return;
  }

  final shouldExit = await showDokanExitConfirmationDialog(context);
  if (shouldExit && context.mounted) {
    SystemNavigator.pop();
  }
}
