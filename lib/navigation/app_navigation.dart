
import 'package:aupulse/login/auth.dart';
import 'package:aupulse/login/login_view.dart';
import 'package:aupulse/views/home/attendance/add_attendace.dart';
import 'package:aupulse/views/home/attendance/attendance_view.dart';
import 'package:aupulse/views/home/attendance/update_attendance.dart';
import 'package:aupulse/views/home/batches/add_batch.dart';
import 'package:aupulse/views/home/batches/edit_batch.dart';
import 'package:aupulse/views/home/branches/add_branch.dart';
import 'package:aupulse/views/home/branches/edit_branch.dart';
import 'package:aupulse/views/home/branches_view.dart';
import 'package:aupulse/views/home/faculty/add_faculty.dart';
import 'package:aupulse/views/home/faculty/details_faculty.dart';
import 'package:aupulse/views/home/faculty/edit_faculty.dart';
import 'package:aupulse/views/home/faculty/faculty_view.dart';
import 'package:aupulse/views/home/sections/add_section.dart';
import 'package:aupulse/views/home/sections/edit_section.dart';
import 'package:aupulse/views/home/sections_view.dart';
import 'package:aupulse/views/home/semesters/add_semester.dart';
import 'package:aupulse/views/home/semesters/edit_semester.dart';
import 'package:aupulse/views/home/semesters_view.dart';
import 'package:aupulse/views/home/subjects/add_subject.dart';
import 'package:aupulse/views/home/subjects/edit_subject.dart';
import 'package:aupulse/views/home/subjects/subjects_view.dart';
import 'package:aupulse/views/home/timetable/add_timetable.dart';
import 'package:aupulse/views/home/timetable/edit_timetable.dart';
import 'package:aupulse/views/home/timetable/generate_report.dart';
import 'package:aupulse/views/home/timetable/time_table.dart';
import 'package:aupulse/views/home/timing/add_timing.dart';
import 'package:aupulse/views/home/timing/edit_timing.dart';
import 'package:aupulse/views/home/timing/timing_view.dart';
import 'package:aupulse/views/students/add_student.dart';
import 'package:aupulse/views/students/details_student.dart';
import 'package:aupulse/views/students/edit_student.dart';
import 'package:aupulse/views/students/students_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aupulse/views/home/home_view.dart';
import 'package:aupulse/views/player/player_view.dart';
import 'package:aupulse/views/settings/settings_view.dart';

import 'package:aupulse/views/wrapper/main_wrapper.dart';

class AppNavigation {
  AppNavigation._();

  static String initial = "/login"; // Set initial route to login

  // Private navigators
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _shellNavigatorSettings =
      GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

  // GoRouter configuration
  static final GoRouter router = GoRouter(
      initialLocation: initial,
      debugLogDiagnostics: true,
      navigatorKey: _rootNavigatorKey,
      routes: [
        /// Login Route
        GoRoute(
          path: '/login',
          name: 'Login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginPage(),
        ),

        /// MainWrapper
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainWrapper(
              navigationShell: navigationShell,
            );
          },
          branches: <StatefulShellBranch>[
            /// Branch Home
            StatefulShellBranch(
              navigatorKey: _shellNavigatorHome,
              routes: <RouteBase>[
                GoRoute(
                    path: "/home",
                    name: "Home",
                    builder: (BuildContext context, GoRouterState state) =>
                        const HomeView(),
                    routes: [
                      GoRoute(
                          path: "faculty",
                          name: "Faculty",
                          pageBuilder: (context, state) {
                            return CustomTransitionPage<void>(
                              key: state.pageKey,
                              child: const FacultyView(),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                            );
                          },
                          routes: [
                            GoRoute(
                              path: "add",
                              name: "addFaculty",
                              pageBuilder: (context, state) {
                                return CustomTransitionPage<void>(
                                  key: state.pageKey,
                                  child:  AddFacultyView(), 
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) =>
                                      FadeTransition(
                                          opacity: animation, child: child),
               
                                );
                              },
                            ),
                            GoRoute(
                              path: "edit/:facultyid",
                              name: "editFaculty",
                              pageBuilder: (context, state) {
                                final data =
                                    state.extra as Map<String, dynamic>;

                                return CustomTransitionPage<void>(
                                  key: state.pageKey,
                                  child: EditFacultyView(
                                    id: state.pathParameters["facultyid"] ?? '',
                                    data:
                                        data, // Pass the dictionary to the BranchView
                                  ),
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) =>
                                      FadeTransition(
                                          opacity: animation, child: child),
                                );
                              },
                            ),
                            GoRoute(
                              path: "view/:facultyid",
                              name: "viewFaculty",
                              pageBuilder: (context, state) {
                                final data =
                                    state.extra as Map<String, dynamic>;

                                return CustomTransitionPage<void>(
                                  key: state.pageKey,
                                  child: DetailsFacultyView(
                                    id: state.pathParameters["facultyid"] ?? '',
                                    data:
                                        data, // Pass the dictionary to the BranchView
                                  ),
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) =>
                                      FadeTransition(
                                          opacity: animation, child: child),
                                );
                              },
                            ),
                          ]),
                      GoRoute(
                        path: "add",
                        name: "addBatch",
                        pageBuilder: (context, state) {
                          return CustomTransitionPage<void>(
                            key: state.pageKey,
                            child: const AddBatchView(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                          );
                        },
                      ),
                      GoRoute(
                        path: "edit/:batchid",
                        name: "editBatch",
                        pageBuilder: (context, state) {
                          final data = state.extra as Map<String, dynamic>;

                          return CustomTransitionPage<void>(
                            key: state.pageKey,
                            child: EditBatchView(
                              id: state.pathParameters["batchid"] ?? '',
                              data:
                                  data, // Pass the dictionary to the BranchView
                            ),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                          );
                        },
                      ),
                      GoRoute(
                          path: 'semesters/:batchid',
                          name: 'semesters',
                          pageBuilder: (context, state) {
                            return CustomTransitionPage<void>(
                              key: state.pageKey,
                              child: SemesterView(
                                  id: state.pathParameters["batchid"] ?? ''),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                            );
                          },
                          routes: [
                            GoRoute(
                              path: "add",
                              name: "addSemester",
                              pageBuilder: (context, state) {
                                return CustomTransitionPage<void>(
                                  key: state.pageKey,
                                  child: const AddSemesterView(),
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) =>
                                      FadeTransition(
                                          opacity: animation, child: child),
                                );
                              },
                            ),
                            GoRoute(
                              path: "edit/:semesterid",
                              name: "editSemester",
                              pageBuilder: (context, state) {
                                final data =
                                    state.extra as Map<String, dynamic>;

                                return CustomTransitionPage<void>(
                                  key: state.pageKey,
                                  child: EditSemesterView(
                                    id: state.pathParameters["semesterid"] ??
                                        '',
                                    data:
                                        data, // Pass the dictionary to the BranchView
                                  ),
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) =>
                                      FadeTransition(
                                          opacity: animation, child: child),
                                );
                              },
                            ),
                            GoRoute(
                              path: 'branches/:semesterid',
                              name: 'branches',
                              pageBuilder: (context, state) {
                                return CustomTransitionPage<void>(
                                  key: state.pageKey,
                                  child: BranchView(
                                      id: state.pathParameters["semesterid"] ??
                                          ''),
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) =>
                                      FadeTransition(
                                          opacity: animation, child: child),
                                );
                              },
                              routes: [
                                GoRoute(
                                  path: "add",
                                  name: "addBranch",
                                  pageBuilder: (context, state) {
                                    return CustomTransitionPage<void>(
                                      key: state.pageKey,
                                      child: const AddBranchView(),
                                      transitionsBuilder: (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) =>
                                          FadeTransition(
                                              opacity: animation, child: child),
                                    );
                                  },
                                ),
                                GoRoute(
                                  path: "edit/:branchid",
                                  name: "editBranch",
                                  pageBuilder: (context, state) {
                                    final data =
                                        state.extra as Map<String, dynamic>;

                                    return CustomTransitionPage<void>(
                                      key: state.pageKey,
                                      child: EditBranchView(
                                        id: state.pathParameters["branchid"] ??
                                            '',
                                        data:
                                            data, // Pass the dictionary to the BranchView
                                      ),
                                      transitionsBuilder: (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) =>
                                          FadeTransition(
                                              opacity: animation, child: child),
                                    );
                                  },
                                ),
                                GoRoute(
                                    path: 'sections/:branchid',
                                    name: 'sections',
                                    pageBuilder: (context, state) {
                                      return CustomTransitionPage<void>(
                                        key: state.pageKey,
                                        child: SectionView(
                                            id: state.pathParameters[
                                                    "branchid"] ??
                                                ''),
                                        transitionsBuilder: (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) =>
                                            FadeTransition(
                                                opacity: animation,
                                                child: child),
                                      );
                                    },
                                    routes: [
                                      
                                      GoRoute(
                                        path: "add",
                                        name: "addSection",
                                        pageBuilder: (context, state) {
                                          return CustomTransitionPage<void>(
                                            key: state.pageKey,
                                            child: const AddSectionView(),
                                            transitionsBuilder: (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                              child,
                                            ) =>
                                                FadeTransition(
                                                    opacity: animation,
                                                    child: child),
                                          );
                                        },
                                      ),
                                      GoRoute(
                                        path: "edit/:sectionid",
                                        name: "editSection",
                                        pageBuilder: (context, state) {
                                          final data = state.extra
                                              as Map<String, dynamic>;

                                          return CustomTransitionPage<void>(
                                            key: state.pageKey,
                                            child: EditSectionView(
                                              id: state.pathParameters[
                                                      "sectionid"] ??
                                                  '',
                                              data:
                                                  data, // Pass the dictionary to the BranchView
                                            ),
                                            transitionsBuilder: (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                              child,
                                            ) =>
                                                FadeTransition(
                                                    opacity: animation,
                                                    child: child),
                                          );
                                        },
                                      ),

                                      GoRoute(
                                          path: "timetable/:sectionid",
                                          name: "TimeTable",
                                          pageBuilder: (context, state) {
                                            return CustomTransitionPage<void>(
                                              key: state.pageKey,
                                              child: TimeTableView(
                                                id: state.pathParameters[
                                                        "sectionid"] ??
                                                    '',
                                                // Pass the dictionary to the BranchView
                                              ),
                                              transitionsBuilder: (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) =>
                                                  FadeTransition(
                                                      opacity: animation,
                                                      child: child),
                                            );
                                          },
                                          routes: [
                                            GoRoute(
                                          path: "subjects",
                                          name: "Subjects",
                                          pageBuilder: (context, state) {
                                            return CustomTransitionPage<void>(
                                              key: state.pageKey,
                                              child: const SubjectView(),
                                              transitionsBuilder: (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) =>
                                                  FadeTransition(
                                                      opacity: animation,
                                                      child: child),
                                            );
                                          },
                                          routes: [
                                            GoRoute(
                                              path: "add",
                                              name: "addSubject",
                                              pageBuilder: (context, state) {
                                                return CustomTransitionPage<
                                                    void>(
                                                  key: state.pageKey,
                                                  child: const AddSubjectView(),
                                                  transitionsBuilder: (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) =>
                                                      FadeTransition(
                                                          opacity: animation,
                                                          child: child),
                                                );
                                              },
                                            ),
                                            GoRoute(
                                              path: "edit/:subjectid",
                                              name: "editSubject",
                                              pageBuilder: (context, state) {
                                                final data = state.extra
                                                    as Map<String, dynamic>;

                                                return CustomTransitionPage<
                                                    void>(
                                                  key: state.pageKey,
                                                  child: EditSubjectView(
                                                    id: state.pathParameters[
                                                            "subjectid"] ??
                                                        '',
                                                    data:
                                                        data, // Pass the dictionary to the BranchView
                                                  ),
                                                  transitionsBuilder: (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) =>
                                                      FadeTransition(
                                                          opacity: animation,
                                                          child: child),
                                                );
                                              },
                                            ),
                                          ]),
                                            GoRoute(
                                                path: "attendance/:periodid",
                                                name: "Attendance",
                                                pageBuilder: (context, state) {
                                                  return CustomTransitionPage<
                                                      void>(
                                                    key: state.pageKey,
                                                    child: AttendanceView(
                                                        id: state.pathParameters[
                                                                "periodid"] ??
                                                            ''),
                                                    transitionsBuilder: (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child,
                                                    ) =>
                                                        FadeTransition(
                                                            opacity: animation,
                                                            child: child),
                                                  );
                                                },
                                                routes: [
                                                  GoRoute(
                                                    path: "add",
                                                    name: "addAttendance",
                                                    pageBuilder:
                                                        (context, state) {
                                                      return CustomTransitionPage<
                                                          void>(
                                                        key: state.pageKey,
                                                        child:
                                                            const AddAttendanceView(),
                                                        transitionsBuilder: (
                                                          context,
                                                          animation,
                                                          secondaryAnimation,
                                                          child,
                                                        ) =>
                                                            FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: child),
                                                      );
                                                    },
                                                  ),
                                                  GoRoute(
                                                    path: "update",
                                                    name: "updateAttendance",
                                                    pageBuilder:
                                                        (context, state) {
                                                      final data = state.extra
                                                          as List<dynamic>;
                                                      return CustomTransitionPage<
                                                          void>(
                                                        key: state.pageKey,
                                                        child:
                                                            UpdateAttendanceView(
                                                                data: data),
                                                        transitionsBuilder: (
                                                          context,
                                                          animation,
                                                          secondaryAnimation,
                                                          child,
                                                        ) =>
                                                            FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: child),
                                                      );
                                                    },
                                                  ),
                                                ]),
                                            GoRoute(
                                                path: "students",
                                                name: "Students",
                                                pageBuilder: (context, state) {
                                                  return CustomTransitionPage<
                                                      void>(
                                                    key: state.pageKey,
                                                    child: const StudentView(),
                                                    transitionsBuilder: (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child,
                                                    ) =>
                                                        FadeTransition(
                                                            opacity: animation,
                                                            child: child),
                                                  );
                                                },
                                                routes: [
                                                  GoRoute(
                                                    path: "add",
                                                    name: "addStudent",
                                                    pageBuilder:
                                                        (context, state) {
                                                      return CustomTransitionPage<
                                                          void>(
                                                        key: state.pageKey,
                                                        child:
                                                            const AddStudentView(),
                                                        transitionsBuilder: (
                                                          context,
                                                          animation,
                                                          secondaryAnimation,
                                                          child,
                                                        ) =>
                                                            FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: child),
                                                      );
                                                    },
                                                  ),
                                                  GoRoute(
                                                    path: "edit/:studentid",
                                                    name: "editStudent",
                                                    pageBuilder:
                                                        (context, state) {
                                                      final data = state.extra
                                                          as Map<String,
                                                              dynamic>;

                                                      return CustomTransitionPage<
                                                          void>(
                                                        key: state.pageKey,
                                                        child: EditStudentView(
                                                          id: state.pathParameters[
                                                                  "studentid"] ??
                                                              '',
                                                          data:
                                                              data, // Pass the dictionary to the BranchView
                                                        ),
                                                        transitionsBuilder: (
                                                          context,
                                                          animation,
                                                          secondaryAnimation,
                                                          child,
                                                        ) =>
                                                            FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: child),
                                                      );
                                                    },
                                                  ),
                                                  GoRoute(
                                                    path: "view/:studentid",
                                                    name: "viewStudent",
                                                    pageBuilder:
                                                        (context, state) {
                                                      final data = state.extra
                                                          as Map<String,
                                                              dynamic>;

                                                      return CustomTransitionPage<
                                                          void>(
                                                        key: state.pageKey,
                                                        child:
                                                            DetailsStudentView(
                                                          id: state.pathParameters[
                                                                  "studentid"] ??
                                                              '',
                                                          data:
                                                              data, // Pass the dictionary to the BranchView
                                                        ),
                                                        transitionsBuilder: (
                                                          context,
                                                          animation,
                                                          secondaryAnimation,
                                                          child,
                                                        ) =>
                                                            FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: child),
                                                      );
                                                    },
                                                  ),
                                                ]),
                                            GoRoute(
                                              path: "add",
                                              name: "addTimetable",
                                              pageBuilder: (context, state) {
                                                return CustomTransitionPage<
                                                    void>(
                                                  key: state.pageKey,
                                                  child:
                                                      const AddTimetableView(),
                                                  transitionsBuilder: (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) =>
                                                      FadeTransition(
                                                          opacity: animation,
                                                          child: child),
                                                );
                                              },
                                            ),
                                            GoRoute(
                                              path: "generatereport",
                                              name: "generateReport",
                                              pageBuilder: (context, state) {
                                                return CustomTransitionPage<
                                                    void>(
                                                  key: state.pageKey,
                                                  child:
                                                      const GenerateReportView(),
                                                  transitionsBuilder: (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) =>
                                                      FadeTransition(
                                                          opacity: animation,
                                                          child: child),
                                                );
                                              },
                                            ),
                                            GoRoute(
                                              path: "edit/:timetableid",
                                              name: "editTimetable",
                                              pageBuilder: (context, state) {
                                                final data = state.extra
                                                    as Map<String, dynamic>;

                                                return CustomTransitionPage<
                                                    void>(
                                                  key: state.pageKey,
                                                  child: EditTimetableView(
                                                    id: state.pathParameters[
                                                            "timetableid"] ??
                                                        '',
                                                    data:
                                                        data, // Pass the dictionary to the BranchView
                                                  ),
                                                  transitionsBuilder: (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) =>
                                                      FadeTransition(
                                                          opacity: animation,
                                                          child: child),
                                                );
                                              },
                                            ),
                                            GoRoute(
                                                path: "timing",
                                                name: "Timing",
                                                pageBuilder: (context, state) {
                                                  return CustomTransitionPage<
                                                      void>(
                                                    key: state.pageKey,
                                                    child: const TimingView(),
                                                    transitionsBuilder: (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child,
                                                    ) =>
                                                        FadeTransition(
                                                            opacity: animation,
                                                            child: child),
                                                  );
                                                },
                                                routes: [
                                                  GoRoute(
                                                    path: "add",
                                                    name: "addTiming",
                                                    pageBuilder:
                                                        (context, state) {
                                                      return CustomTransitionPage<
                                                          void>(
                                                        key: state.pageKey,
                                                        child:
                                                            const AddTimingView(),
                                                        transitionsBuilder: (
                                                          context,
                                                          animation,
                                                          secondaryAnimation,
                                                          child,
                                                        ) =>
                                                            FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: child),
                                                      );
                                                    },
                                                  ),
                                                  GoRoute(
                                                    path: "edit/:timingid",
                                                    name: "editTiming",
                                                    pageBuilder:
                                                        (context, state) {
                                                      final data = state.extra
                                                          as Map<String,
                                                              dynamic>;

                                                      return CustomTransitionPage<
                                                          void>(
                                                        key: state.pageKey,
                                                        child: EditTimingView(
                                                          id: state.pathParameters[
                                                                  "timingid"] ??
                                                              '',
                                                          data:
                                                              data, // Pass the dictionary to the BranchView
                                                        ),
                                                        transitionsBuilder: (
                                                          context,
                                                          animation,
                                                          secondaryAnimation,
                                                          child,
                                                        ) =>
                                                            FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: child),
                                                      );
                                                    },
                                                  ),
                                                ]),
                                          ]),
                                    ]),
                              ],
                            ),
                          ])
                    ])
              ],
            ),

            /// Branch Setting
            StatefulShellBranch(
              navigatorKey: _shellNavigatorSettings,
              routes: <RouteBase>[
                GoRoute(
                  path: "/settings",
                  name: "Settings",
                  builder: (BuildContext context, GoRouterState state) =>
                      const SettingsView(),
                  routes: [],
                ),
              ],
            ),
          ],
        ),

        /// Player
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/player',
          name: "Player",
          builder: (context, state) => PlayerView(
            key: state.pageKey,
          ),
        )
      ],
      redirect: (context, state) async {
        final isLoggedin = await AuthService.isLogged();

        // Redirect logic based on login status
        if (!isLoggedin && state.uri.path != '/login') {
          return '/login'; // Redirect to login if not logged in and not already on the login page
        } else if (isLoggedin && state.uri.path == '/login') {
          return '/home'; // Redirect to home if logged in and on the login page
        }

        return null; // No redirect needed
      });
}
