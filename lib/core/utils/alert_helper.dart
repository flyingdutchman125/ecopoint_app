import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppAlerts {
  static void showSuccess(BuildContext context, String message, {String title = 'Berhasil'}) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: false,
    );
  }

  static void showError(BuildContext context, String message, {String title = 'Terjadi Kesalahan'}) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: false,
    );
  }

  static void showWarning(BuildContext context, String message, {String title = 'Perhatian'}) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: false,
    );
  }

  static void showInfo(BuildContext context, String message, {String title = 'Info'}) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: false,
    );
  }
}
