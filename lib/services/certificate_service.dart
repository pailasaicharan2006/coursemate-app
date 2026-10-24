import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/models/certificate.dart';

class CertificateService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Local in-memory cache to guarantee functionality and resilient fallback
  final List<Certificate> _localCache = [];

  Future<List<Certificate>> getCertificates(String userId) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final remoteList =
          (response as List).map((e) => Certificate.fromJson(e)).toList();
      _localCache.clear();
      _localCache.addAll(remoteList);
      return remoteList;
    } catch (_) {
      // Return user-filtered local cache if remote table isn't migrated yet or offline
      return _localCache.where((c) => c.userId == userId).toList();
    }
  }

  Future<Certificate> addCertificate({
    required String userId,
    required String title,
    required String issuer,
    String? courseId,
    String? courseTitle,
    DateTime? issueDate,
    String? fileUrl,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    String? storagePath;
    String? finalFileUrl = fileUrl;

    if (fileBytes != null && fileName != null) {
      final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      storagePath = '$userId/${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';

      try {
        await _supabase.storage.from('certificates').uploadBinary(
              storagePath,
              fileBytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
            );

        final signedUrl = await _supabase.storage
            .from('certificates')
            .createSignedUrl(storagePath, 60 * 60 * 24 * 30); // 30 days
        finalFileUrl = signedUrl;
      } catch (storageError) {
        // If storage bucket isn't created or fails, still proceed with URL if present
        storagePath = null;
      }
    }

    final newCertMap = {
      'user_id': userId,
      'course_id': courseId,
      'course_title': courseTitle,
      'title': title,
      'issuer': issuer,
      'issue_date': issueDate != null
          ? "${issueDate.year.toString().padLeft(4, '0')}-${issueDate.month.toString().padLeft(2, '0')}-${issueDate.day.toString().padLeft(2, '0')}"
          : null,
      'file_url': finalFileUrl,
      'storage_path': storagePath,
    };

    try {
      final response = await _supabase
          .from('certificates')
          .insert(newCertMap)
          .select()
          .single();

      final created = Certificate.fromJson(response);
      _localCache.insert(0, created);
      return created;
    } catch (_) {
      // Local fallback
      final fallbackCert = Certificate(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        courseId: courseId,
        courseTitle: courseTitle,
        title: title,
        issuer: issuer,
        issueDate: issueDate,
        fileUrl: finalFileUrl,
        storagePath: storagePath,
      );
      _localCache.insert(0, fallbackCert);
      return fallbackCert;
    }
  }

  Future<Certificate> updateCertificate(Certificate certificate) async {
    final updateMap = {
      'title': certificate.title,
      'issuer': certificate.issuer,
      'course_id': certificate.courseId,
      'course_title': certificate.courseTitle,
      'issue_date': certificate.issueDate != null
          ? "${certificate.issueDate!.year.toString().padLeft(4, '0')}-${certificate.issueDate!.month.toString().padLeft(2, '0')}-${certificate.issueDate!.day.toString().padLeft(2, '0')}"
          : null,
      'file_url': certificate.fileUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      final response = await _supabase
          .from('certificates')
          .update(updateMap)
          .eq('id', certificate.id)
          .select()
          .single();

      final updated = Certificate.fromJson(response);
      final index = _localCache.indexWhere((c) => c.id == certificate.id);
      if (index != -1) {
        _localCache[index] = updated;
      }
      return updated;
    } catch (_) {
      final index = _localCache.indexWhere((c) => c.id == certificate.id);
      if (index != -1) {
        _localCache[index] = certificate;
      }
      return certificate;
    }
  }

  Future<void> deleteCertificate(String id, {String? storagePath}) async {
    if (storagePath != null && storagePath.isNotEmpty) {
      try {
        await _supabase.storage.from('certificates').remove([storagePath]);
      } catch (_) {}
    }

    try {
      await _supabase.from('certificates').delete().eq('id', id);
    } catch (_) {}

    _localCache.removeWhere((c) => c.id == id);
  }

  Future<String?> resolveViewUrl(Certificate cert) async {
    if (cert.storagePath != null && cert.storagePath!.isNotEmpty) {
      try {
        final signed = await _supabase.storage
            .from('certificates')
            .createSignedUrl(cert.storagePath!, 3600);
        return signed;
      } catch (_) {
        return cert.fileUrl;
      }
    }
    return cert.fileUrl;
  }
}
