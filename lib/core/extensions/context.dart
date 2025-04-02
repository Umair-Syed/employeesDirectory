import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension Context on BuildContext {
  void showSnackBarMessage(
    String message, {
    bool isError = false,
    bool isSuccess = false,
    bool isDarkThemed = false,
    int? duration,
    String? actionLabel,
    void Function()? actionCallback,
    ScaffoldMessengerState? messenger,
  }) {
    final theme = Theme.of(this);
    final Color? foregroundColor;
    final Color? backgroundColor;
    final BorderRadius borderRadius;
    final SnackBarBehavior behavior;

    if (isDarkThemed) {
      foregroundColor = Colors.white;
      backgroundColor = Colors.black87;
      borderRadius = BorderRadius.zero;
      behavior = SnackBarBehavior.fixed;
    } else if (isError) {
      foregroundColor = theme.colorScheme.onError;
      backgroundColor = theme.colorScheme.error;
      borderRadius = BorderRadius.circular(8);
      behavior = SnackBarBehavior.floating;
    } else if (isSuccess) {
      foregroundColor = theme.colorScheme.onSurface;
      backgroundColor = theme.colorScheme.primaryContainer;
      borderRadius = BorderRadius.circular(8);
      behavior = SnackBarBehavior.floating;
    } else {
      foregroundColor = theme.colorScheme.onPrimary;
      backgroundColor = theme.colorScheme.primaryContainer;
      borderRadius = BorderRadius.circular(8);
      behavior = SnackBarBehavior.floating;
    }

    FocusScope.of(this).unfocus();
    final scaffoldMessenger = messenger ?? ScaffoldMessenger.of(this);
    scaffoldMessenger.clearSnackBars();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: duration ?? 2000),
        backgroundColor: backgroundColor,
        behavior: behavior,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side:
              isDarkThemed
                  ? BorderSide.none
                  : BorderSide(
                    color:
                        isError
                            ? theme.colorScheme.onError
                            : isSuccess
                            ? Colors.green.shade700
                            : theme.colorScheme.onPrimaryContainer,
                    width: 0.7,
                  ),
        ),
        padding:
            isDarkThemed
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 0)
                : null,
        content: Row(
          mainAxisAlignment:
              isDarkThemed
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: foregroundColor),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (actionLabel != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextButton(
                  onPressed: () {
                    actionCallback?.call();
                    scaffoldMessenger.hideCurrentSnackBar();
                  },
                  child: Text(
                    actionLabel,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight:
                          isDarkThemed ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}
