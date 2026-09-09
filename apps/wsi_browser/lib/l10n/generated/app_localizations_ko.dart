// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'WSI Browser';

  @override
  String get startPageTitle => 'WSI Browser';

  @override
  String get startPageSubtitle => '플러그인으로 확장하는 브라우저';

  @override
  String get startPageUrlHint => 'URL 입력';

  @override
  String get startPageOpen => '열기';

  @override
  String get startPagePlugins => '플러그인';

  @override
  String get startPageSettings => '설정';

  @override
  String get startPageNoPlugins => '설치된 플러그인이 없습니다';

  @override
  String get urlBarHint => 'URL 또는 검색어';

  @override
  String urlBarBadgeTooltip(int count) {
    return '플러그인 $count개 활성';
  }

  @override
  String get actionBack => '뒤로';

  @override
  String get actionForward => '앞으로';

  @override
  String get actionReload => '새로고침';

  @override
  String get actionStop => '중지';

  @override
  String get actionShare => '공유';

  @override
  String get actionNewTab => '새 탭';

  @override
  String get actionCloseTab => '탭 닫기';

  @override
  String get actionTabs => '탭';

  @override
  String get actionHome => '홈';

  @override
  String get actionOpenExternal => '외부 브라우저에서 열기';

  @override
  String get actionCopyUrl => 'URL 복사';

  @override
  String get tabsTitle => '탭';

  @override
  String tabsLimitReached(int limit) {
    return '탭은 최대 $limit개까지 열 수 있습니다';
  }

  @override
  String get tabUntitled => '(제목 없음)';

  @override
  String get dialogOk => '확인';

  @override
  String get dialogCancel => '취소';

  @override
  String get dialogClose => '닫기';

  @override
  String jsDialogTitle(String host) {
    return '$host의 메시지';
  }

  @override
  String downloadStarted(String name) {
    return '다운로드 중: $name';
  }

  @override
  String downloadDone(String name) {
    return '저장했습니다: $name';
  }

  @override
  String downloadFailed(String reason) {
    return '다운로드 실패: $reason';
  }

  @override
  String get externalLinkOpened => '외부 브라우저에서 열었습니다';

  @override
  String navigationBlocked(String url) {
    return '이 URL은 열 수 없습니다: $url';
  }

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSectionBrowser => '브라우저';

  @override
  String get settingsSectionPlugins => '플러그인';

  @override
  String get settingsSectionDeveloper => '개발자';

  @override
  String get settingsInitialUrl => '초기 URL';

  @override
  String get settingsInitialUrlDesc => '실행 시 여는 페이지. 비워 두면 시작 페이지';

  @override
  String get settingsTabLimit => '탭 상한';

  @override
  String get settingsExternalLinks => '외부 링크 처리';

  @override
  String get settingsExternalLinksDesc => '플러그인이 담당하지 않는 사이트로의 링크';

  @override
  String get settingsExternalLinksInApp => '앱 안에서 열기';

  @override
  String get settingsExternalLinksExternal => '외부 브라우저에서 열기';

  @override
  String get settingsUserAgent => 'User-Agent';

  @override
  String get settingsUserAgentDesc => '비워 두면 OS 기본 브라우저와 동일';

  @override
  String get settingsClearCookies => '쿠키 삭제';

  @override
  String get settingsClearCookiesDesc => '모든 사이트에서 로그아웃됩니다';

  @override
  String get settingsClearCookiesConfirm => '모든 쿠키를 삭제할까요?';

  @override
  String get settingsClearCookiesDone => '쿠키를 삭제했습니다';

  @override
  String get settingsUpdateCheck => '플러그인 업데이트 확인';

  @override
  String get settingsUpdateCheckDesc => '실행 시 및 하루 1회';

  @override
  String get settingsLogRetention => '로그 보관 건수';

  @override
  String get settingsDeveloperMode => '개발자 모드';

  @override
  String get settingsDeveloperModeDesc => 'URL 라이브 리로드와 웹 인스펙터를 사용';

  @override
  String get settingsWebInspector => '웹 인스펙터';

  @override
  String get settingsWebInspectorDesc =>
      'iOS는 Safari, Android는 chrome://inspect';

  @override
  String get settingsAbout => '버전';

  @override
  String get settingsSaved => '저장했습니다';

  @override
  String get settingsEdit => '편집';

  @override
  String get settingsUseDefault => '기본값';

  @override
  String commonError(String message) {
    return '오류: $message';
  }
}
