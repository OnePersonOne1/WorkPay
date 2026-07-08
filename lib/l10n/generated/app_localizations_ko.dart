// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '월급이';

  @override
  String get actionSave => '저장';

  @override
  String get actionCancel => '취소';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionEdit => '편집';

  @override
  String get actionAdd => '추가';

  @override
  String get actionClose => '닫기';

  @override
  String get actionOk => '확인';

  @override
  String get actionBack => '뒤로';

  @override
  String get actionYes => '예';

  @override
  String get actionNo => '아니오';

  @override
  String get actionUndo => '되돌리기';

  @override
  String get actionRedo => '다시 실행';

  @override
  String get actionTryAgain => '다시 시도';

  @override
  String get actionConfirm => '확인';

  @override
  String get actionLoad => '불러오기';

  @override
  String get actionReplace => '교체';

  @override
  String get navSchedule => '일정표';

  @override
  String get navSettings => '설정';

  @override
  String get scheduleTitle => '일정표';

  @override
  String get scheduleAddRecurring => '반복 추가';

  @override
  String get scheduleViewPayroll => '급여 명세';

  @override
  String get scheduleResetMonth => '이번 달 근무 초기화';

  @override
  String get scheduleToolbarReset => '초기화';

  @override
  String get scheduleAddShift => '시프트 추가';

  @override
  String get scheduleBackToToday => '오늘로 돌아가기';

  @override
  String get scheduleYearMonthMove => '년월 이동';

  @override
  String get schedulePrevMonth => '이전 달';

  @override
  String get scheduleNextMonth => '다음 달';

  @override
  String get scheduleNoShifts => '이날은 시프트가 없어요.';

  @override
  String get scheduleNoJobsTitle => '근무처가 없어요';

  @override
  String get scheduleNoJobsHint => '시프트를 추가하려면 먼저 근무처를 등록하세요.';

  @override
  String get scheduleNoJobsButton => '근무처 추가';

  @override
  String get scheduleNoJobsRegistered => '등록된 근무처가 없어요';

  @override
  String get scheduleJobsManage => '관리';

  @override
  String get scheduleDefaultJobNone =>
      '기본 근무처 미선택 — 시프트 추가 시 첫 번째 근무처가 자동 선택돼요';

  @override
  String scheduleDefaultJobLabel(String jobName) {
    return '기본 근무처: $jobName (시프트 추가 시 자동 선택, 변경 가능)';
  }

  @override
  String get scheduleVisDaily => '일급';

  @override
  String get scheduleVisWeekly => '주급';

  @override
  String get scheduleVisMonthly => '월급';

  @override
  String get scheduleWeeklySummary => '주별 요약';

  @override
  String scheduleWeekNth(int n) {
    return '$n주차';
  }

  @override
  String scheduleMonthSummary(String hours, String amount) {
    return '이번 달 ${hours}h · $amount';
  }

  @override
  String scheduleGrossBefore(String amount) {
    return '공제 전 $amount';
  }

  @override
  String scheduleMonthCalcError(String error) {
    return '월 합계 계산 오류: $error';
  }

  @override
  String scheduleJobLoadError(String error) {
    return '근무처 로드 오류: $error';
  }

  @override
  String scheduleNoShiftsThisMonth(int year, int month) {
    return '$year년 $month월에 시프트가 없어요';
  }

  @override
  String scheduleDeleteMonthTitle(int year, int month) {
    return '$year년 $month월 시프트 전체 삭제';
  }

  @override
  String scheduleDeleteMonthBody(int count) {
    return '이번 달 시프트 $count개를 모두 삭제할까요?\n\n되돌리기로 복원할 수 있어요 (최근 5개 동작까지).';
  }

  @override
  String scheduleDeleteMonthSnap(int year, int month, int count) {
    return '$year년 $month월 시프트 $count개 삭제';
  }

  @override
  String scheduleDeletedCount(int count) {
    return '$count개 시프트 삭제됨';
  }

  @override
  String get scheduleSingleShiftDeleted => '삭제 완료. 되돌리기로 되돌릴 수 있어요.';

  @override
  String get scheduleShiftDeleteSnapshot => '시프트 삭제';

  @override
  String scheduleShiftDeleteSnapshotWithDate(int month, int day) {
    return '$month월 $day일 시프트 삭제';
  }

  @override
  String get scheduleNothingToUndo => '되돌릴 작업이 없어요';

  @override
  String get scheduleNothingToRedo => '다시 실행할 작업이 없어요';

  @override
  String scheduleUndoneLabel(String description) {
    return '되돌림: $description';
  }

  @override
  String scheduleRedoneLabel(String description) {
    return '다시 실행: $description';
  }

  @override
  String scheduleDateLabel(int year, int month, int day, String weekday) {
    return '$year년 $month월 $day일 ($weekday)';
  }

  @override
  String get scheduleShiftDeleteTooltip => '시프트 삭제';

  @override
  String scheduleBreakSuffix(int minutes) {
    return '(휴게 $minutes분)';
  }

  @override
  String get weekMon => '월';

  @override
  String get weekTue => '화';

  @override
  String get weekWed => '수';

  @override
  String get weekThu => '목';

  @override
  String get weekFri => '금';

  @override
  String get weekSat => '토';

  @override
  String get weekSun => '일';

  @override
  String get shiftSheetTitleNew => '시프트 추가';

  @override
  String get shiftSheetTitleEdit => '시프트 편집';

  @override
  String get shiftSheetJob => '근무처';

  @override
  String get shiftSheetStart => '시작';

  @override
  String get shiftSheetEnd => '종료';

  @override
  String get shiftSheetBreak => '휴게';

  @override
  String get shiftSheetBreakUnit => '단위: 분';

  @override
  String get shiftSheetMemo => '메모 (선택)';

  @override
  String get shiftSheetMemoHint => '예) 매출 마감';

  @override
  String shiftSheetBreakMin(int minutes) {
    return '$minutes분';
  }

  @override
  String shiftSheetWorkMin(int minutes) {
    return '$minutes분';
  }

  @override
  String shiftSheetWorkHours(String hours) {
    return '근무시간 ${hours}h';
  }

  @override
  String get shiftSheetSelectStart => '시작 시각을 먼저 골라주세요';

  @override
  String get shiftSheetSelectEnd => '종료 시각을 먼저 골라주세요';

  @override
  String get shiftSheetEndBeforeStart => '종료 시각이 시작 시각보다 빠르면 안 돼요';

  @override
  String get shiftSheetBreakTooLong => '휴게 시간이 근무 시간보다 길어요';

  @override
  String get shiftSheetOverlapTitle => '겹치는 시프트가 있어요';

  @override
  String get shiftSheetOverlapBody => '다음 시프트와 시간이 겹쳐요:';

  @override
  String shiftSheetOverlapItem(String jobName, String start, String end) {
    return '$jobName · $start ~ $end';
  }

  @override
  String get shiftSheetOverlapSave => '그래도 저장';

  @override
  String get shiftSheetSelectJob => '근무처를 선택하세요';

  @override
  String get shiftSheetDelete => '이 시프트 삭제';

  @override
  String get shiftSheetDeletedSnapshot => '시프트 삭제';

  @override
  String get shiftSheetSavedSnapshot => '시프트 편집';

  @override
  String get shiftSheetCreatedSnapshot => '시프트 추가';

  @override
  String get recurringTitle => '반복 시프트 추가';

  @override
  String get recurringHelp => '기간과 요일을 선택하면 그 범위의 해당 요일에 동일 시간/근무처로 시프트를 만들어요.';

  @override
  String get recurringPeriod => '기간';

  @override
  String get recurringPeriodFrom => '시작일';

  @override
  String get recurringPeriodTo => '종료일';

  @override
  String get recurringWeekdays => '요일';

  @override
  String get recurringJob => '근무처';

  @override
  String get recurringTimeBreak => '시간 / 휴게';

  @override
  String get recurringSelectWeekdays => '요일을 1개 이상 선택해주세요';

  @override
  String get recurringPeriodInvalid => '종료일은 시작일과 같거나 이후여야 해요';

  @override
  String recurringPreview(int count, int overlapCount) {
    return '총 $count개 시프트가 생성돼요 ($overlapCount개는 기존과 겹침)';
  }

  @override
  String recurringOverlapConfirm(int count) {
    return '겹치는 시프트가 $count개 있어요. 그래도 만들까요?';
  }

  @override
  String get recurringCreate => '만들기';

  @override
  String recurringCreatedCount(int count) {
    return '$count개 시프트 생성됨';
  }

  @override
  String recurringSnapshot(int count) {
    return '반복 시프트 $count개 추가';
  }

  @override
  String get planMain => '메인';

  @override
  String get planSelectMock => '가안 선택';

  @override
  String get planLoadFromMain => '메인에서 불러오기';

  @override
  String planReplaceMain(String name) {
    return '\"$name\"을(를) 메인으로 교체';
  }

  @override
  String planNewMock(int month) {
    return '$month월 새 가안 추가';
  }

  @override
  String get planNoneThisMonth => '이번 달 가안이 없어요';

  @override
  String planAutoName(int month, int n) {
    return '$month월 가안 $n';
  }

  @override
  String get planLoadConfirmTitle => '메인에서 불러오기';

  @override
  String planLoadConfirmBody(int year, int month, String name) {
    return '메인의 $year년 $month월 시프트를 \"$name\"으로\n복사해요. 현재 \"$name\"의 시프트는 모두 사라져요.\n\n되돌리기로 복원할 수 있어요.';
  }

  @override
  String planLoadDone(int count) {
    return '메인에서 $count개 시프트 불러옴';
  }

  @override
  String planLoadSnap(String name) {
    return '\"$name\"에 메인 불러오기';
  }

  @override
  String planReplaceConfirmTitle(String name) {
    return '\"$name\"을(를) 메인으로 교체';
  }

  @override
  String planReplaceConfirmBody(int year, int month, String name) {
    return '메인의 $year년 $month월 시프트를\n\"$name\"의 데이터로 교체해요.\n메인의 해당 달 시프트는 모두 사라져요.\n\n되돌리기로 복원할 수 있어요. 가안 데이터는 그대로 유지돼요.';
  }

  @override
  String planReplaceDone(String name, int count) {
    return '메인을 \"$name\"($count개)로 교체함';
  }

  @override
  String planReplaceSnap(int year, int month, String name) {
    return '메인 $year년 $month월을 \"$name\"으로 교체';
  }

  @override
  String planMockCreated(String name, int count) {
    return '\"$name\" 생성 (메인에서 $count개 복사)';
  }

  @override
  String get planMockDeleteTitle => '가안 삭제';

  @override
  String planMockDeleteBody(String name) {
    return '\"$name\"을(를) 삭제할까요?\n\n되돌리기로 복원할 수 있어요.';
  }

  @override
  String get planMockDeleteTooltip => '가안 삭제';

  @override
  String planMockDeleted(String name) {
    return '\"$name\" 삭제됨';
  }

  @override
  String planMockDeleteSnap(String name) {
    return '\"$name\" 삭제';
  }

  @override
  String get planSelectTooltip => '가안 선택';

  @override
  String get jobsTitle => '근무처 관리';

  @override
  String get jobsAdd => '근무처 추가';

  @override
  String get jobsEmpty => '등록된 근무처가 없어요';

  @override
  String get jobsEmptyHint => '+ 버튼으로 새 근무처를 추가하세요.';

  @override
  String get jobsArchivedShow => '보관된 근무처 표시';

  @override
  String get jobsArchive => '보관';

  @override
  String get jobsUnarchive => '보관 해제';

  @override
  String get jobsDelete => '삭제';

  @override
  String get jobsArchived => '(보관됨)';

  @override
  String get jobsDeleteConfirmTitle => '근무처 삭제';

  @override
  String jobsDeleteConfirmBody(String name) {
    return '\"$name\"을(를) 정말 삭제할까요?\n\n주의: 이 근무처의 시프트가 있다면 삭제할 수 없어요. 먼저 시프트들을 정리하거나 \"보관\"을 사용하세요.';
  }

  @override
  String get jobsDeleteFailedHasShifts =>
      '이 근무처의 시프트가 있어 삭제할 수 없어요. \"보관\"을 대신 사용하세요.';

  @override
  String jobsDeleted(String name) {
    return '\"$name\" 삭제됨';
  }

  @override
  String jobsArchivedSnack(String name) {
    return '\"$name\" 보관됨';
  }

  @override
  String jobsUnarchivedSnack(String name) {
    return '\"$name\" 보관 해제됨';
  }

  @override
  String jobsWageLabel(String wage) {
    return '$wage/시';
  }

  @override
  String get jobsAdvancedOptions => '고급 옵션';

  @override
  String get jobSheetTitleNew => '근무처 추가';

  @override
  String get jobSheetTitleEdit => '근무처 편집';

  @override
  String get jobSheetName => '이름';

  @override
  String get jobSheetNameHint => '예) 카페 알바, 편의점 등';

  @override
  String jobSheetWage(String unit) {
    return '시급 ($unit)';
  }

  @override
  String get jobSheetIncomeType => '소득 유형';

  @override
  String get jobSheetBusinessSize => '사업장 규모';

  @override
  String get jobSheetColor => '표시 색상';

  @override
  String get jobSheetNameRequired => '이름을 입력하세요';

  @override
  String get jobSheetWageRequired => '시급을 입력하세요';

  @override
  String get jobSheetWageInvalid => '올바른 숫자를 입력하세요';

  @override
  String jobSheetSaved(String name) {
    return '\"$name\" 저장됨';
  }

  @override
  String get jobAdvNightPremium => '야간 가산 (22:00~06:00 +50%)';

  @override
  String get jobAdvDailyOvertime => '일 연장 (8h 초과 +50%)';

  @override
  String get jobAdvWeeklyOvertime => '주 연장 (40h 초과 +50%)';

  @override
  String get jobAdvHolidayPremium => '휴일근로 가산';

  @override
  String get jobAdvWeeklyHoliday => '주휴수당 (주 15h+ 1일분)';

  @override
  String get jobAdvPreciseBreak => '휴게 입력을 시각 단위로';

  @override
  String get jobAdvDeductionMode => '공제 모드';

  @override
  String get jobAdvFourInsuranceRate => '4대보험 요율 (만분율)';

  @override
  String get jobAdvPresetSection => '프리셋';

  @override
  String get jobAdvPresetCaption => '자동으로 옵션을 끄고 켜줘요.';

  @override
  String get jobAdvDisableAll => '옵션 전부 비활성화';

  @override
  String get jobAdvAllowanceSection => '수당';

  @override
  String get jobAdvTaxSection => '세금·공제';

  @override
  String get jobAdvInputSection => '입력 옵션';

  @override
  String get deductionNone => '비과세';

  @override
  String get deductionBusiness33 => '사업소득 3.3%';

  @override
  String get deductionFourInsurance => '4대보험';

  @override
  String get incomePartTime => '아르바이트';

  @override
  String get incomeWorkStudy => '근로장학';

  @override
  String get businessUnder5 => '5인 미만';

  @override
  String get businessFiveOrMore => '5인 이상';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSectionLanguage => '언어';

  @override
  String get settingsLanguageSystem => '시스템 설정 따름';

  @override
  String get settingsLanguageKo => '한국어';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsSectionTheme => '테마';

  @override
  String get settingsThemeSystem => '시스템';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get settingsSectionTimeFormat => '시간 표시';

  @override
  String get settingsUse24Hour => '24시간 형식';

  @override
  String get settingsUse12Hour => '오전/오후 형식';

  @override
  String get settingsSectionPayroll => '급여 계산';

  @override
  String get settingsCurrencyUnit => '통화 단위';

  @override
  String get settingsCurrencyUnitHint =>
      '금액 뒤에 표시되는 라벨이에요. 계산에는 영향을 주지 않아요. (예: 원, \$, USD)';

  @override
  String get settingsCurrencyUnitDialogTitle => '통화 단위';

  @override
  String get settingsCurrencyUnitFieldHint => '예) 원, \$, USD';

  @override
  String get settingsHolidayCountry => '공휴일 기준 국가';

  @override
  String get settingsHolidayCountryHint => '공휴일 색 표시와 휴일근로 가산 계산에 사용해요.';

  @override
  String get settingsHolidayCountryKR => '대한민국';

  @override
  String get settingsHolidayCountryNone => '표시 안 함';

  @override
  String get settingsLaborLaw => '한국 노동법 준수 모드';

  @override
  String get settingsLaborLawHint =>
      '야간·연장·주휴·공제 등 한국 노동법 관련 항목과 주요 상수를 켜요. 실제 적용 여부는 근무처별로 \'근무처 관리\'에서 정해요. 끄면 단순 시급 × 근무시간만 계산하고 관련 옵션이 숨겨져요.';

  @override
  String get settingsAllowOverlap => '겹치는 시프트 허용';

  @override
  String get settingsAllowOverlapHint => '시간이 겹치는 시프트도 경고 없이 저장할 수 있어요.';

  @override
  String get settingsAdvancedConstants => '전문가 설정 (가산률·상수)';

  @override
  String get settingsSectionBackup => '백업';

  @override
  String get settingsBackupAndRestore => '백업 / 복원';

  @override
  String settingsLastBackup(String at) {
    return '마지막 백업: $at';
  }

  @override
  String get settingsNeverBackup => '백업 기록 없음';

  @override
  String get settingsSectionInfo => '정보';

  @override
  String get settingsVersion => '버전';

  @override
  String get settingsAppDescription => '광고 없는 근무 일정·월급 계산 앱';

  @override
  String get advancedTitle => '전문가 설정';

  @override
  String get advancedHelp =>
      '이 화면의 값은 기본적으로 한국 노동법 기준이에요. 변경 시 신중히 다뤄주세요. 잘못된 값이 들어가면 계산이 어긋날 수 있어요.';

  @override
  String get advancedReset => '기본값으로 초기화';

  @override
  String get advancedResetDone => '기본값으로 초기화됨';

  @override
  String get advancedSaved => '설정을 저장했어요';

  @override
  String get advancedNightStart => '야간 시작 시각 (시)';

  @override
  String get advancedNightEnd => '야간 종료 시각 (시)';

  @override
  String get advancedDailyOTThreshold => '일 연장 기준 시간 (h)';

  @override
  String get advancedWeeklyOTThreshold => '주 연장 기준 시간 (h)';

  @override
  String get advancedHolidayOTThreshold => '휴일 가산 분기 시간 (h)';

  @override
  String get advancedNightPremiumPct => '야간 가산률 (%)';

  @override
  String get advancedDailyOTPremiumPct => '일 연장 가산률 (%)';

  @override
  String get advancedWeeklyOTPremiumPct => '주 연장 가산률 (%)';

  @override
  String get advancedHolidayBasePct => '휴일 기본 가산률 (%)';

  @override
  String get advancedHolidayOverPct => '휴일 초과 가산률 (%)';

  @override
  String get advancedWeeklyHolidayHours => '주휴수당 최소 시간 (h)';

  @override
  String get advancedWeeklyHolidayCap => '주휴수당 시간 상한 (h)';

  @override
  String get advancedBusinessIncomePct => '사업소득 원천징수율 (%)';

  @override
  String get advancedSectionThresholds => '기준 시간';

  @override
  String get advancedSectionPremiums => '가산률';

  @override
  String get advancedSectionWeeklyHoliday => '주휴수당';

  @override
  String get advancedSectionDeductions => '공제율';

  @override
  String get backupTitle => '백업 / 복원';

  @override
  String get backupExport => '백업 파일 만들기';

  @override
  String get backupImport => '백업 파일에서 복원';

  @override
  String backupExportSaved(String path) {
    return '저장 위치:\n$path';
  }

  @override
  String backupExportFailed(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String get backupImportConfirmTitle => '백업에서 복원';

  @override
  String get backupImportConfirmBody => '현재 모든 데이터가 백업 파일의 내용으로 교체돼요. 계속할까요?';

  @override
  String backupImportRestored(int jobs, int shifts) {
    return '복원됨: 근무처 $jobs개, 시프트 $shifts개';
  }

  @override
  String backupImportFailed(String error) {
    return '복원 실패: $error';
  }

  @override
  String backupIncompatibleVersion(int backup, int current) {
    return '백업 파일의 스키마 버전($backup)이 현재 앱($current)과 달라 가져올 수 없어요.';
  }

  @override
  String get backupSectionWhat => '백업되는 내용';

  @override
  String get backupSectionWhatBody =>
      '• 근무처 + 옵션\n• 모든 시프트(메인 + 가안)\n• 가안 메타데이터\n• 앱 설정 (테마, 시간 형식, 활성 plan 등)\n\n포함되지 않음: 되돌리기 스택 (사용자 액션 이력)';

  @override
  String get backupLastBackupNever => '백업한 적이 없어요';

  @override
  String backupLastBackupAt(String at) {
    return '마지막 백업: $at';
  }

  @override
  String get reportTitle => '급여 명세';

  @override
  String get reportViewPrefix => '보기:';

  @override
  String get reportNoMockThisMonth => '이번 달에 가안이 없어요';

  @override
  String get reportTabAll => '전체';

  @override
  String get reportAllJobsCombined => '모든 근무처 합산';

  @override
  String get reportNoRecords => '이번 달에 근무 기록이 없어요';

  @override
  String reportNoRecordsJob(String job) {
    return '$job — 이번 달에 근무 기록이 없어요';
  }

  @override
  String get reportPaymentItems => '지급 항목';

  @override
  String get reportDeductionItems => '공제 항목';

  @override
  String get reportItemBasePay => '기본급';

  @override
  String get reportItemBasePayHint => '근무 시간 × 시급';

  @override
  String get reportItemNight => '야간 가산수당';

  @override
  String get reportItemNightHint => '22:00~06:00 근무에 +50%';

  @override
  String get reportItemDailyOT => '일 연장 가산수당';

  @override
  String get reportItemDailyOTHint => '하루 8h 초과분에 +50%';

  @override
  String get reportItemWeeklyOT => '주 연장 가산수당';

  @override
  String get reportItemWeeklyOTHint => '주 40h 초과분에 +50% (일 OT와 중복 안 됨)';

  @override
  String get reportItemHolidayWithin => '휴일근로 가산수당 (≤8h)';

  @override
  String get reportItemHolidayWithinHint => '휴일 근무 8시간 이내 +50%';

  @override
  String get reportItemHolidayOver => '휴일근로 가산수당 (>8h)';

  @override
  String get reportItemHolidayOverHint => '휴일 근무 8시간 초과분 +100%';

  @override
  String get reportItemWeeklyHoliday => '주휴수당';

  @override
  String get reportItemWeeklyHolidayHint => '주 15h+ 결근 없을 때 1일분';

  @override
  String get reportItemBusinessIncome => '사업소득 원천징수';

  @override
  String get reportItemBusinessIncomeHint => '3.3% (소득세 + 지방소득세)';

  @override
  String get reportItemFourInsurance => '4대보험';

  @override
  String get reportItemFourInsuranceHint => '국민연금 + 건강 + 고용 + 장기요양';

  @override
  String get reportGrossLabel => '총 지급액';

  @override
  String get reportTotalDeductionLabel => '총 공제';

  @override
  String get reportNetLabel => '실수령';

  @override
  String reportTotalAmount(String amount) {
    return '$amount';
  }

  @override
  String reportNegativeAmount(String amount) {
    return '-$amount';
  }

  @override
  String reportWorkTimeLabel(int h, String m) {
    return '실 근무 $h시간$m';
  }

  @override
  String reportWorkMinutesSuffix(int m) {
    return ' $m분';
  }

  @override
  String get reportFootnote =>
      '* 일급 표시는 기본급+야간+일 연장+휴일 가산만 합산되며, 주 연장·주휴·공제는 월 단위로만 적용돼요.';

  @override
  String reportCalcError(String error) {
    return '계산 오류: $error';
  }

  @override
  String get yearMonthPickerTitle => '년/월 선택';

  @override
  String get yearLabel => '년';

  @override
  String get monthLabel => '월';

  @override
  String get amSuffix => '오전';

  @override
  String get pmSuffix => '오후';

  @override
  String get deductionModeNone => '공제 없음';

  @override
  String get deductionModeBusiness => '사업소득 3.3%';

  @override
  String get deductionModeInsurance => '4대보험';

  @override
  String get calExportTitle => '구글 캘린더로 보내기';

  @override
  String get calExportToolbarLabel => '캘린더 공유';

  @override
  String get settingsSectionCalendar => '캘린더 연동';

  @override
  String get settingsCalendarExportHint => '로그인 없이 캘린더 파일(.ics)로 근무 일정을 옮겨요';

  @override
  String calExportMonthShiftCount(int count) {
    return '이 달의 근무 $count건이 캘린더 일정으로 만들어져요.';
  }

  @override
  String get calExportNoShifts => '이 달에는 근무가 없어요. 위에서 다른 달을 선택해 주세요.';

  @override
  String get calExportButton => '캘린더 파일(.ics) 만들기';

  @override
  String get calExportFirstTimeTitle => '처음이신가요? 이렇게 동작해요';

  @override
  String get calExportFirstTimeBody =>
      '구글 계정 로그인이나 인터넷 연동 없이, 어느 캘린더 앱에서나 읽을 수 있는 표준 일정 파일(.ics)을 만들어 드려요.\n만든 파일을 구글 캘린더에서 \'가져오기\' 하면 이 달의 근무가 일정으로 등록돼요. 애플·네이버 캘린더에서도 같은 방법으로 쓸 수 있어요.';

  @override
  String get calExportHowToTitle => '구글 캘린더에 넣는 방법';

  @override
  String get calExportHowToMobile =>
      '📱 스마트폰\n1. 아래 \'캘린더 파일 만들기\' 버튼을 눌러요.\n2. \'캘린더 앱으로 열기\'를 선택해요.\n3. 열리는 화면에서 \'추가\' 또는 \'저장\'을 누르면 끝!\n   (캘린더 앱이 안 열리면 \'파일로 저장\'을 누른 뒤, 파일 앱에서 저장한 .ics 파일을 눌러 열어요)';

  @override
  String get calExportOpenCalendarApp => '캘린더 앱으로 열기';

  @override
  String get calExportOpenCalendarAppDesc => '구글 캘린더 등에서 바로 일정으로 추가해요';

  @override
  String get calExportSaveToFile => '파일로 저장';

  @override
  String get calExportSaveToFileDesc => '원하는 위치에 .ics 파일을 저장해요';

  @override
  String get calExportShareOther => '다른 앱으로 공유';

  @override
  String get calExportShareOtherDesc => '메일·메신저 등으로 파일을 보내요';

  @override
  String get calExportNoCalendarApp =>
      '.ics 파일을 열 수 있는 캘린더 앱이 없어요. \'파일로 저장\' 후 컴퓨터에서 calendar.google.com 가져오기를 이용해 주세요.';

  @override
  String get calExportHowToPc =>
      '💻 컴퓨터\n1. 파일을 컴퓨터에 저장해요.\n2. calendar.google.com 접속 → 오른쪽 위 ⚙(설정) → \'가져오기 및 내보내기\'를 열어요.\n3. 저장한 파일을 선택하고 \'가져오기\'를 누르면 끝!';

  @override
  String get calExportNotesTitle => '알아두면 좋아요';

  @override
  String get calExportNotesBody =>
      '• 파일에는 근무처 이름·근무 시간·메모만 들어가요. 시급이나 월급 금액은 포함되지 않아요.\n• 같은 달을 두 번 가져오면 일정이 중복될 수 있어요. 근무를 수정했다면 구글 캘린더에서 이전에 가져온 일정을 지운 뒤 다시 가져오는 걸 추천해요.\n• 앱에서 근무를 바꿔도 구글 캘린더에 자동으로 반영되지는 않아요. 바뀐 달의 파일을 다시 보내 주세요.';

  @override
  String get calExportUnknownJob => '근무';

  @override
  String calExportSaved(String path) {
    return '캘린더 파일이 만들어졌어요:\n$path';
  }

  @override
  String calExportFailed(String error) {
    return '캘린더 내보내기 실패: $error';
  }
}
