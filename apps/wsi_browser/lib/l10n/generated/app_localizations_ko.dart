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

  @override
  String get pluginsTitle => '플러그인';

  @override
  String get pluginsEmpty => '플러그인이 없습니다. ZIP을 가져오세요.';

  @override
  String get pluginsGlobalToggle => '플러그인 사용';

  @override
  String get pluginsGlobalToggleOff => '모든 플러그인이 중지되어 있습니다';

  @override
  String get pluginsImport => '가져오기';

  @override
  String pluginsCurrentHost(String host) {
    return '이 사이트: $host';
  }

  @override
  String pluginVersion(String version) {
    return 'v$version';
  }

  @override
  String pluginUpdateAvailable(String version) {
    return '업데이트 있음: v$version';
  }

  @override
  String get pluginUpdate => '업데이트';

  @override
  String get pluginDelete => '삭제';

  @override
  String pluginDeleteConfirm(String name) {
    return '$name을(를) 삭제할까요? 저장된 데이터와 설정도 모두 삭제됩니다.';
  }

  @override
  String get pluginDeleted => '삭제했습니다';

  @override
  String get pluginSettings => '설정';

  @override
  String get pluginExport => 'ZIP 내보내기';

  @override
  String get pluginDetails => '상세';

  @override
  String get pluginDomains => '대상 도메인';

  @override
  String get pluginPermissions => '권한';

  @override
  String get pluginAuthor => '작성자';

  @override
  String get pluginInstalledAt => '설치';

  @override
  String get pluginCheckUpdates => '업데이트 확인';

  @override
  String get pluginLogs => '로그';

  @override
  String get importTitle => '플러그인 가져오기';

  @override
  String get importFromFile => '파일 선택';

  @override
  String get importFromUrl => 'URL에서';

  @override
  String get importFromQr => 'QR 코드 스캔';

  @override
  String get importUrlHint => 'https://.../plugin.zip';

  @override
  String get importPreviewTitle => '가져오기 확인';

  @override
  String importOverwrite(String version) {
    return '같은 ID의 플러그인(v$version)을 덮어씁니다. 저장된 데이터는 유지됩니다.';
  }

  @override
  String get importSensitive => '이 플러그인은 다음 권한을 요청합니다';

  @override
  String get importConsent => '위 권한을 허용';

  @override
  String get importInstall => '설치';

  @override
  String importDone(String name) {
    return '$name을(를) 설치했습니다';
  }

  @override
  String importFailed(String reason) {
    return '가져올 수 없습니다: $reason';
  }

  @override
  String get importDownloading => '다운로드 중...';

  @override
  String get importInsecureUrl => 'https 이외의 URL은 개발자 모드에서만 사용할 수 있습니다';

  @override
  String get qrScanHint => 'wsi://install 또는 ZIP URL의 QR 코드를 스캔합니다';

  @override
  String get logsTitle => '로그';

  @override
  String get logsEmpty => '로그가 없습니다';

  @override
  String get logsClear => '지우기';

  @override
  String get logsShare => '내보내기';

  @override
  String get logsFilterAll => '전체';

  @override
  String settingsPluginTitle(String name) {
    return '$name 설정';
  }

  @override
  String get settingsPluginEmpty => '이 플러그인에는 설정 항목이 없습니다';

  @override
  String get permissionDesc_storage => '데이터 저장';

  @override
  String get permissionDesc_fetch => '네트워크 접근';

  @override
  String get permissionDesc_credentials => '로그인 정보 저장 (Keychain / Keystore)';

  @override
  String get permissionDesc_device => '기기 ID 읽기';

  @override
  String get permissionDesc_share => '공유 시트';

  @override
  String get permissionDesc_files => '파일 저장 및 선택';

  @override
  String get permissionDesc_clipboard => '클립보드 쓰기';

  @override
  String get permissionDesc_wakeLock => '화면 꺼짐 방지';

  @override
  String get permissionDesc_pip => 'PIP(화면 속 화면)';

  @override
  String get permissionDesc_blockResources => '이미지·동영상 로드 차단';

  @override
  String get permissionDesc_tabs => '백그라운드 탭 제어';

  @override
  String get permissionDesc_pages => '자체 화면 표시';

  @override
  String get permissionDesc_menu => '메뉴 항목 추가';

  @override
  String get permissionDesc_navigation => '페이지 이동 가로채기';

  @override
  String get permissionDesc_policy => '서버에서 정책 값 가져오기';
}
