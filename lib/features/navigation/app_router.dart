import 'package:go_router/go_router.dart';
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

class AppRouter {
  late final GoRouter config;
  
  AppRouter() {
    config = GoRouter(
      initialLocation: '/patients',
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
