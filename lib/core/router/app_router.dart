import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/presentation/chat_view.dart';
import '../../features/diary/presentation/diary_view.dart';
import '../../features/moments/presentation/moments_view.dart';
import '../../features/profile/presentation/profile_view.dart';
import '../../features/shell/presentation/companion_shell.dart';
import '../../features/today/presentation/today_view.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/today',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            CompanionShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/today',
            builder: (context, state) => const TodayView(),
          ),
          GoRoute(
            path: '/moments',
            builder: (context, state) => const MomentsView(),
          ),
          GoRoute(
            path: '/diary',
            builder: (context, state) => const DiaryView(),
          ),
          GoRoute(
            path: '/me',
            builder: (context, state) => const ProfileView(),
          ),
          GoRoute(path: '/chat', builder: (context, state) => const ChatView()),
        ],
      ),
    ],
  );
});
