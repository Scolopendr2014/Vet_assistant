import 'dart:io';
import '../../../../core/config/app_config.dart';
import '../entities/stt_result.dart';
import '../interfaces/speech_recognizer.dart';
import '../../providers/cloud_recognizer.dart';
import '../../providers/private_server_recognizer.dart';
import '../../providers/on_device_recognizer.dart';
import 'dart:async';

/// Роутер для выбора провайдера STT
class SttRouter {
  final CloudRecognizer? cloudRecognizer;
  final PrivateServerRecognizer? privateServerRecognizer;
  final OnDeviceRecognizer? onDeviceRecognizer;
  
  SttRouter({
    this.cloudRecognizer,
    this.privateServerRecognizer,
    this.onDeviceRecognizer,
  });

  /// Распознать аудио с автоматическим выбором провайдера
  Future<SttResult> transcribe(
    String audioFilePath, {
    SttMode mode = SttMode.auto,
    bool preferOffline = false,
  }) async {
    final startTime = DateTime.now();
    
    // Проверка доступности интернета
    final hasInternet = await _checkInternetConnection();
    
    SpeechRecognizer? selectedProvider;
    
    switch (mode) {
      case SttMode.offlineOnly:
        selectedProvider = onDeviceRecognizer;
        break;
        
      case SttMode.cloudOnly:
        if (hasInternet && cloudRecognizer?.isAvailable() == true) {
          selectedProvider = cloudRecognizer;
        } else {
          throw Exception('Облачный STT недоступен');
        }
        break;
        
      case SttMode.privateOnly:
        if (hasInternet && privateServerRecognizer?.isAvailable() == true) {
          selectedProvider = privateServerRecognizer;
        } else {
          throw Exception('Приватный сервер STT недоступен');
        }
        break;
        
      case SttMode.auto:
        // Приоритет 1: Приватный сервер (если доступен)
        if (hasInternet && 
            privateServerRecognizer?.isAvailable() == true &&
            !preferOffline) {
          selectedProvider = privateServerRecognizer;
        }
        // Приоритет 2: Облако (если приватный недоступен)
        else if (hasInternet && 
                 cloudRecognizer?.isAvailable() == true &&
                 !preferOffline) {
          selectedProvider = cloudRecognizer;
        }
        // Приоритет 3: Офлайн
        else if (onDeviceRecognizer?.isAvailable() == true) {
          selectedProvider = onDeviceRecognizer;
        }
        break;
    }
    
    if (selectedProvider == null) {
      throw Exception('Нет доступных провайдеров STT');
    }
    
    try {
      final result = await selectedProvider.recognize(audioFilePath)
          .timeout(AppConfig.sttTimeout);
      
      final processingTime = DateTime.now().difference(startTime);
      
      return SttResult(
        text: result.text,
        confidence: result.confidence,
        wordConfidences: result.wordConfidences,
        timestamps: result.timestamps,
        provider: result.provider,
        modelVersion: result.modelVersion,
        processingTime: processingTime,
      );
    } catch (e) {
      // Fallback на офлайн, если облачный/приватный провайдер упал
      if (mode == SttMode.auto && 
          selectedProvider != onDeviceRecognizer &&
          onDeviceRecognizer?.isAvailable() == true) {
        return await onDeviceRecognizer!.recognize(audioFilePath);
      }
      rethrow;
    }
  }
  
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
