import 'package:go_router/go_router.dart';

import '../../core/di/di_container.dart';
import '../vet_profile/domain/repositories/vet_profile_repository.dart';
import '../patients/presentation/pages/patients_list_page.dart';
import '../patients/presentation/pages/patient_detail_page.dart';
import '../patients/presentation/pages/patient_form_page.dart';
import '../examinations/presentation/pages/examination_create_page.dart';
import '../examinations/presentation/pages/examination_detail_page.dart';
import '../admin/presentation/pages/admin_login_page.dart';
import '../admin/presentation/pages/admin_dashboard_page.dart';
import '../admin/presentation/pages/template_edit_page.dart';
import '../admin/presentation/pages/references_list_page.dart';
import '../admin/presentation/pages/validation_settings_page.dart';
import '../vet_profile/presentation/pages/vet_profile_form_page.dart';
import '../vet_profile/presentation/pages/clinic_select_page.dart';
import '../vet_profile/presentation/pages/vet_clinic_form_page.dart';

class AppRouter {
  late final GoRouter config;
  
  AppRouter() {
    config = GoRouter(
      initialLocation: '/',
      redirect: (context, state) async {
        final location = state.uri.path;
        if (location.startsWith('/profile/edit') ||
            location.startsWith('/profile/clinics') ||
            location == '/clinic-select') {
          return null;
        }
        if (location == '/' || location.isEmpty) {
          final profileRepo = getIt<VetProfileRepository>();
          final profile = await profileRepo.get();
          if (profile == null) return '/profile/edit';
          return '/clinic-select';
        }
        final profileRepo = getIt<VetProfileRepository>();
        final profile = await profileRepo.get();
        if (profile == null) return '/profile/edit';
        return null;
      },
      routes: [
        GoRoute(
          path: '/patients',
          name: 'patients',
          builder: (context, state) => const PatientsListPage(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'patient-new',
              builder: (context, state) => const PatientFormPage(),
            ),
            GoRoute(
              path: ':id',
              name: 'patient-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return PatientDetailPage(patientId: id);
              },
            ),
            GoRoute(
              path: ':id/edit',
              name: 'patient-edit',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return PatientFormPage(patientId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/examinations/create',
          name: 'examination-create',
          builder: (context, state) {
            final patientId = state.uri.queryParameters['patientId'];
            return ExaminationCreatePage(patientId: patientId);
          },
        ),
        GoRoute(
          path: '/examinations/:id',
          name: 'examination-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ExaminationDetailPage(examinationId: id);
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: 'examination-edit',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ExaminationCreatePage(examinationId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/profile/edit',
          name: 'profile-edit',
          builder: (context, state) => const VetProfileFormPage(),
          routes: [
            GoRoute(
              path: 'clinics/new',
              name: 'profile-clinic-new',
              builder: (context, state) {
                final profileId = state.uri.queryParameters['profileId'] ?? '';
                return VetClinicFormPage(vetProfileId: profileId, clinicId: null);
              },
            ),
            GoRoute(
              path: 'clinics/:id/edit',
              name: 'profile-clinic-edit',
              builder: (context, state) {
                final profileId = state.uri.queryParameters['profileId'] ?? '';
                final clinicId = state.pathParameters['id'] ?? '';
                return VetClinicFormPage(
                  vetProfileId: profileId,
                  clinicId: clinicId,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/clinic-select',
          name: 'clinic-select',
          builder: (context, state) => const ClinicSelectPage(),
        ),
        GoRoute(
          path: '/admin/login',
          name: 'admin-login',
          builder: (context, state) => const AdminLoginPage(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboardPage(),
          routes: [
            GoRoute(
              path: 'templates/:id',
              name: 'admin-template-edit',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return TemplateEditPage(templateId: id);
              },
            ),
            GoRoute(
              path: 'references',
              name: 'admin-references',
              builder: (context, state) => const ReferencesListPage(),
            ),
            GoRoute(
              path: 'validation',
              name: 'admin-validation',
              builder: (context, state) => const ValidationSettingsPage(),
            ),
          ],
        ),
      ],
    );
  }
}
