import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coursemate_app/models/certificate.dart';
import 'package:coursemate_app/models/user_course.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/learning_provider.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';

class CertificatesLockerScreen extends ConsumerStatefulWidget {
  final String? initialCourseId;
  final String? initialCourseTitle;

  const CertificatesLockerScreen({
    super.key,
    this.initialCourseId,
    this.initialCourseTitle,
  });

  @override
  ConsumerState<CertificatesLockerScreen> createState() =>
      _CertificatesLockerScreenState();
}

class _CertificatesLockerScreenState
    extends ConsumerState<CertificatesLockerScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialCourseId != null || widget.initialCourseTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddCertificateDialog(
          prefilledCourseId: widget.initialCourseId,
          prefilledCourseTitle: widget.initialCourseTitle,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(certificatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceColor = AppTheme.darkTextPrimary;
    final cardBg = AppTheme.darkCardBg;
    final borderColor = AppTheme.darkBorderCyan;
    final subTextColor =
        AppTheme.darkTextSecondary;

    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Certificates Locker',
          style: TextStyle(
            color: onSurfaceColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurfaceColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.cyanPrimary),
            tooltip: 'Add Certificate',
            onPressed: () => _showAddCertificateDialog(),
          ),
        ],
      ),
      body: certificatesAsync.when(
        data: (certificates) {
          if (certificates.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cyanPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_outlined,
                        size: 64,
                        color: AppTheme.cyanPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Certificates Added Yet',
                      style: TextStyle(
                        color: onSurfaceColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your course completion certificates or store external certification links securely in your personal locker.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddCertificateDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyanPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Add First Certificate',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(certificatesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return _buildCertificateCard(
                  cert: cert,
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  onSurfaceColor: onSurfaceColor,
                  subTextColor: subTextColor,
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.cyanPrimary),
        ),
        error: (err, _) => Center(
          child: Text('Error loading certificates: $err',
              style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.cyanPrimary,
        foregroundColor: Colors.white,
        tooltip: 'Add Certificate',
        onPressed: () => _showAddCertificateDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCertificateCard({
    required Certificate cert,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color onSurfaceColor,
    required Color subTextColor,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate =
        cert.issueDate != null ? dateFormat.format(cert.issueDate!) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cyanPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: AppTheme.cyanPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.title,
                      style: TextStyle(
                        color: onSurfaceColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cert.issuer.isNotEmpty ? cert.issuer : 'Official Credential',
                      style: const TextStyle(
                        color: AppTheme.cyanSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: subTextColor),
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditCertificateDialog(cert);
                  } else if (value == 'delete') {
                    _confirmDeleteCertificate(cert);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: onSurfaceColor),
                        const SizedBox(width: 10),
                        Text('Edit Metadata', style: TextStyle(color: onSurfaceColor)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        SizedBox(width: 10),
                        Text('Delete', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (formattedDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFECEFF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: subTextColor),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              if (cert.courseTitle != null && cert.courseTitle!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cyanSecondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school, size: 12, color: AppTheme.cyanSecondary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          cert.courseTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.cyanSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openCertificate(cert),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.cyanPrimary,
                side: const BorderSide(color: AppTheme.cyanPrimary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(
                cert.storagePath != null
                    ? Icons.visibility_outlined
                    : Icons.open_in_new,
                size: 18,
              ),
              label: Text(
                cert.storagePath != null ? 'View / Download File' : 'Open Certificate URL',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCertificate(Certificate cert) async {
    final service = ref.read(certificateServiceProvider);
    final url = await service.resolveViewUrl(cert);

    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No certificate URL or file attached.')),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $url')),
      );
    }
  }

  Future<void> _showAddCertificateDialog({
    String? prefilledCourseId,
    String? prefilledCourseTitle,
  }) async {
    final titleController = TextEditingController();
    final issuerController = TextEditingController();
    final urlController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    String? selectedCourseId = prefilledCourseId;
    String? selectedCourseTitle = prefilledCourseTitle;

    Uint8List? selectedFileBytes;
    String? selectedFileName;
    bool isUploading = false;

    final userCoursesAsync = ref.read(userCoursesLearningProvider);
    final userCourses = userCoursesAsync.value ?? <UserCourse>[];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            const onSurfaceColor = AppTheme.darkTextPrimary;
            final cardBg = AppTheme.darkCardBg;
            final inputBg = AppTheme.darkInputBg;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                top: 24,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Certificate',
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: onSurfaceColor),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: onSurfaceColor),
                      decoration: InputDecoration(
                        labelText: 'Certificate Title *',
                        hintText: 'e.g. Deep Learning Specialization',
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: issuerController,
                      style: TextStyle(color: onSurfaceColor),
                      decoration: InputDecoration(
                        labelText: 'Issuer / Organization *',
                        hintText: 'e.g. Coursera, DeepLearning.AI',
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Linked Course Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedCourseId,
                      dropdownColor: cardBg,
                      style: TextStyle(color: onSurfaceColor),
                      decoration: InputDecoration(
                        labelText: 'Linked Course (Optional)',
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('None', style: TextStyle(color: onSurfaceColor)),
                        ),
                        ...userCourses.map((uc) {
                          final cTitle = uc.course?.title ?? 'Enrolled Course';
                          return DropdownMenuItem<String>(
                            value: uc.courseId,
                            child: Text(
                              cTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: onSurfaceColor),
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          selectedCourseId = val;
                          if (val != null) {
                            final found = userCourses
                                .where((uc) => uc.courseId == val)
                                .firstOrNull;
                            selectedCourseTitle = found?.course?.title;
                          } else {
                            selectedCourseTitle = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Issue date picker tile
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      tileColor: inputBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        selectedDate == null
                            ? 'Issue Date (Optional)'
                            : 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                        style: TextStyle(color: onSurfaceColor, fontSize: 14),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: AppTheme.cyanPrimary),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: sheetContext,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Attach File or URL',
                      style: TextStyle(
                        color: onSurfaceColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // File Picker Button
                    OutlinedButton.icon(
                      onPressed: () async {
                        final file = await FilePicker.pickFile(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                        );
                        if (file != null) {
                          final bytes = await file.readAsBytes();
                          setModalState(() {
                            selectedFileName = file.name;
                            selectedFileBytes = bytes;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.cyanSecondary,
                        side: const BorderSide(color: AppTheme.cyanSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        selectedFileName ?? 'Upload PDF or Image Certificate',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      style: TextStyle(color: onSurfaceColor),
                      decoration: InputDecoration(
                        labelText: 'Or Certificate URL (Optional)',
                        hintText: 'https://credentials.example.com/...',
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isUploading
                            ? null
                            : () async {
                                final title = titleController.text.trim();
                                final issuer = issuerController.text.trim();
                                if (title.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Please enter certificate title.')),
                                  );
                                  return;
                                }

                                final user = ref.read(currentUserProvider);
                                if (user == null) return;

                                setModalState(() => isUploading = true);

                                try {
                                  final certService = ref.read(certificateServiceProvider);
                                  await certService.addCertificate(
                                    userId: user.id,
                                    title: title,
                                    issuer: issuer.isNotEmpty ? issuer : 'Self-issued',
                                    courseId: selectedCourseId,
                                    courseTitle: selectedCourseTitle,
                                    issueDate: selectedDate,
                                    fileUrl: urlController.text.trim().isNotEmpty
                                        ? urlController.text.trim()
                                        : null,
                                    fileBytes: selectedFileBytes,
                                    fileName: selectedFileName,
                                  );

                                  ref.invalidate(certificatesProvider);

                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                } catch (e) {
                                  setModalState(() => isUploading = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to save certificate: $e')),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cyanPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Certificate',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditCertificateDialog(Certificate cert) async {
    final titleController = TextEditingController(text: cert.title);
    final issuerController = TextEditingController(text: cert.issuer);
    final urlController = TextEditingController(text: cert.fileUrl ?? '');
    DateTime? selectedDate = cert.issueDate;
    String? selectedCourseId = cert.courseId;
    String? selectedCourseTitle = cert.courseTitle;
    bool isSaving = false;

    final userCoursesAsync = ref.read(userCoursesLearningProvider);
    final userCourses = userCoursesAsync.value ?? <UserCourse>[];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            const onSurfaceColor = AppTheme.darkTextPrimary;
            final cardBg = AppTheme.darkCardBg;
            final inputBg = AppTheme.darkInputBg;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                top: 24,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Certificate',
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: onSurfaceColor),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: onSurfaceColor),
                      decoration: InputDecoration(
                        labelText: 'Certificate Title *',
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: issuerController,
                      style: TextStyle(color: onSurfaceColor),
                      decoration: InputDecoration(
                        labelText: 'Issuer / Organization *',
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCourseId,
                      dropdownColor: cardBg,
                      style: TextStyle(color: onSurfaceColor),
                      decoration: InputDecoration(
                        labelText: 'Linked Course (Optional)',
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('None', style: TextStyle(color: onSurfaceColor)),
                        ),
                        ...userCourses.map((uc) {
                          final cTitle = uc.course?.title ?? 'Enrolled Course';
                          return DropdownMenuItem<String>(
                            value: uc.courseId,
                            child: Text(
                              cTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: onSurfaceColor),
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          selectedCourseId = val;
                          if (val != null) {
                            final found = userCourses
                                .where((uc) => uc.courseId == val)
                                .firstOrNull;
                            selectedCourseTitle = found?.course?.title;
                          } else {
                            selectedCourseTitle = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      tileColor: inputBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        selectedDate == null
                            ? 'Issue Date (Optional)'
                            : 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                        style: TextStyle(color: onSurfaceColor, fontSize: 14),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: AppTheme.cyanPrimary),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: sheetContext,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      style: TextStyle(color: onSurfaceColor),
                      decoration: InputDecoration(
                        labelText: 'Certificate URL',
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final title = titleController.text.trim();
                                final issuer = issuerController.text.trim();
                                if (title.isEmpty) return;

                                setModalState(() => isSaving = true);

                                try {
                                  final certService = ref.read(certificateServiceProvider);
                                  final updated = cert.copyWith(
                                    title: title,
                                    issuer: issuer.isNotEmpty ? issuer : cert.issuer,
                                    courseId: selectedCourseId,
                                    courseTitle: selectedCourseTitle,
                                    issueDate: selectedDate,
                                    fileUrl: urlController.text.trim().isNotEmpty
                                        ? urlController.text.trim()
                                        : null,
                                  );

                                  await certService.updateCertificate(updated);
                                  ref.invalidate(certificatesProvider);

                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                } catch (e) {
                                  setModalState(() => isSaving = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to update: $e')),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cyanPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteCertificate(Certificate cert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Certificate'),
        content: Text(
          'Are you sure you want to delete "${cert.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final certService = ref.read(certificateServiceProvider);
      await certService.deleteCertificate(cert.id, storagePath: cert.storagePath);
      ref.invalidate(certificatesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate deleted.')),
        );
      }
    }
  }
}
