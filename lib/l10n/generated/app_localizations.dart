import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'월급이'**
  String get appTitle;

  /// No description provided for @actionSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get actionEdit;

  /// No description provided for @actionAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get actionAdd;

  /// No description provided for @actionClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get actionClose;

  /// No description provided for @actionOk.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get actionOk;

  /// No description provided for @actionBack.
  ///
  /// In ko, this message translates to:
  /// **'뒤로'**
  String get actionBack;

  /// No description provided for @actionYes.
  ///
  /// In ko, this message translates to:
  /// **'예'**
  String get actionYes;

  /// No description provided for @actionNo.
  ///
  /// In ko, this message translates to:
  /// **'아니오'**
  String get actionNo;

  /// No description provided for @actionUndo.
  ///
  /// In ko, this message translates to:
  /// **'되돌리기'**
  String get actionUndo;

  /// No description provided for @actionRedo.
  ///
  /// In ko, this message translates to:
  /// **'다시 실행'**
  String get actionRedo;

  /// No description provided for @actionTryAgain.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get actionTryAgain;

  /// No description provided for @actionConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get actionConfirm;

  /// No description provided for @actionLoad.
  ///
  /// In ko, this message translates to:
  /// **'불러오기'**
  String get actionLoad;

  /// No description provided for @actionReplace.
  ///
  /// In ko, this message translates to:
  /// **'교체'**
  String get actionReplace;

  /// No description provided for @navSchedule.
  ///
  /// In ko, this message translates to:
  /// **'일정표'**
  String get navSchedule;

  /// No description provided for @navSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get navSettings;

  /// No description provided for @scheduleTitle.
  ///
  /// In ko, this message translates to:
  /// **'일정표'**
  String get scheduleTitle;

  /// No description provided for @scheduleAddRecurring.
  ///
  /// In ko, this message translates to:
  /// **'반복 추가'**
  String get scheduleAddRecurring;

  /// No description provided for @scheduleViewPayroll.
  ///
  /// In ko, this message translates to:
  /// **'급여 명세'**
  String get scheduleViewPayroll;

  /// No description provided for @scheduleResetMonth.
  ///
  /// In ko, this message translates to:
  /// **'이번 달 근무 초기화'**
  String get scheduleResetMonth;

  /// No description provided for @scheduleAddShift.
  ///
  /// In ko, this message translates to:
  /// **'시프트 추가'**
  String get scheduleAddShift;

  /// No description provided for @scheduleBackToToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘로 돌아가기'**
  String get scheduleBackToToday;

  /// No description provided for @scheduleYearMonthMove.
  ///
  /// In ko, this message translates to:
  /// **'년월 이동'**
  String get scheduleYearMonthMove;

  /// No description provided for @schedulePrevMonth.
  ///
  /// In ko, this message translates to:
  /// **'이전 달'**
  String get schedulePrevMonth;

  /// No description provided for @scheduleNextMonth.
  ///
  /// In ko, this message translates to:
  /// **'다음 달'**
  String get scheduleNextMonth;

  /// No description provided for @scheduleNoShifts.
  ///
  /// In ko, this message translates to:
  /// **'이 날의 시프트가 없습니다.'**
  String get scheduleNoShifts;

  /// No description provided for @scheduleNoJobsTitle.
  ///
  /// In ko, this message translates to:
  /// **'근무처가 없습니다'**
  String get scheduleNoJobsTitle;

  /// No description provided for @scheduleNoJobsHint.
  ///
  /// In ko, this message translates to:
  /// **'시프트를 추가하려면 먼저 근무처를 등록하세요.'**
  String get scheduleNoJobsHint;

  /// No description provided for @scheduleNoJobsButton.
  ///
  /// In ko, this message translates to:
  /// **'근무처 추가'**
  String get scheduleNoJobsButton;

  /// No description provided for @scheduleNoJobsRegistered.
  ///
  /// In ko, this message translates to:
  /// **'등록된 근무처가 없어요'**
  String get scheduleNoJobsRegistered;

  /// No description provided for @scheduleJobsManage.
  ///
  /// In ko, this message translates to:
  /// **'관리'**
  String get scheduleJobsManage;

  /// No description provided for @scheduleDefaultJobNone.
  ///
  /// In ko, this message translates to:
  /// **'기본 근무지 미선택 — 시프트 추가 시 첫째 근무처가 자동 선택돼요'**
  String get scheduleDefaultJobNone;

  /// No description provided for @scheduleDefaultJobLabel.
  ///
  /// In ko, this message translates to:
  /// **'기본 근무지: {jobName} (시프트 추가 시 자동 선택, 변경 가능)'**
  String scheduleDefaultJobLabel(String jobName);

  /// No description provided for @scheduleVisDaily.
  ///
  /// In ko, this message translates to:
  /// **'일급'**
  String get scheduleVisDaily;

  /// No description provided for @scheduleVisWeekly.
  ///
  /// In ko, this message translates to:
  /// **'주급'**
  String get scheduleVisWeekly;

  /// No description provided for @scheduleVisMonthly.
  ///
  /// In ko, this message translates to:
  /// **'월급'**
  String get scheduleVisMonthly;

  /// No description provided for @scheduleWeeklySummary.
  ///
  /// In ko, this message translates to:
  /// **'주별 요약'**
  String get scheduleWeeklySummary;

  /// No description provided for @scheduleWeekNth.
  ///
  /// In ko, this message translates to:
  /// **'{n}주차'**
  String scheduleWeekNth(int n);

  /// No description provided for @scheduleMonthSummary.
  ///
  /// In ko, this message translates to:
  /// **'이 달 {hours}h · {amount}원'**
  String scheduleMonthSummary(String hours, String amount);

  /// No description provided for @scheduleGrossBefore.
  ///
  /// In ko, this message translates to:
  /// **'공제 전 {amount}원'**
  String scheduleGrossBefore(String amount);

  /// No description provided for @scheduleMonthCalcError.
  ///
  /// In ko, this message translates to:
  /// **'월 합계 계산 오류: {error}'**
  String scheduleMonthCalcError(String error);

  /// No description provided for @scheduleJobLoadError.
  ///
  /// In ko, this message translates to:
  /// **'근무처 로드 오류: {error}'**
  String scheduleJobLoadError(String error);

  /// No description provided for @scheduleNoShiftsThisMonth.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월에 시프트가 없어요'**
  String scheduleNoShiftsThisMonth(int year, int month);

  /// No description provided for @scheduleDeleteMonthTitle.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 시프트 전체 삭제'**
  String scheduleDeleteMonthTitle(int year, int month);

  /// No description provided for @scheduleDeleteMonthBody.
  ///
  /// In ko, this message translates to:
  /// **'이 달의 시프트 {count}개를 모두 삭제할까요?\n\n되돌리기로 복원할 수 있어요 (최근 5개 동작까지).'**
  String scheduleDeleteMonthBody(int count);

  /// No description provided for @scheduleDeleteMonthSnap.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 시프트 {count}개 삭제'**
  String scheduleDeleteMonthSnap(int year, int month, int count);

  /// No description provided for @scheduleDeletedCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 시프트 삭제됨'**
  String scheduleDeletedCount(int count);

  /// No description provided for @scheduleSingleShiftDeleted.
  ///
  /// In ko, this message translates to:
  /// **'삭제 완료. 되돌리기로 되돌릴 수 있어요.'**
  String get scheduleSingleShiftDeleted;

  /// No description provided for @scheduleShiftDeleteSnapshot.
  ///
  /// In ko, this message translates to:
  /// **'시프트 삭제'**
  String get scheduleShiftDeleteSnapshot;

  /// No description provided for @scheduleShiftDeleteSnapshotWithDate.
  ///
  /// In ko, this message translates to:
  /// **'{month}월 {day}일 시프트 삭제'**
  String scheduleShiftDeleteSnapshotWithDate(int month, int day);

  /// No description provided for @scheduleNothingToUndo.
  ///
  /// In ko, this message translates to:
  /// **'되돌릴 작업이 없어요'**
  String get scheduleNothingToUndo;

  /// No description provided for @scheduleNothingToRedo.
  ///
  /// In ko, this message translates to:
  /// **'다시 실행할 작업이 없어요'**
  String get scheduleNothingToRedo;

  /// No description provided for @scheduleUndoneLabel.
  ///
  /// In ko, this message translates to:
  /// **'되돌림: {description}'**
  String scheduleUndoneLabel(String description);

  /// No description provided for @scheduleRedoneLabel.
  ///
  /// In ko, this message translates to:
  /// **'다시 실행: {description}'**
  String scheduleRedoneLabel(String description);

  /// No description provided for @scheduleDateLabel.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 {day}일 ({weekday})'**
  String scheduleDateLabel(int year, int month, int day, String weekday);

  /// No description provided for @scheduleShiftDeleteTooltip.
  ///
  /// In ko, this message translates to:
  /// **'시프트 삭제'**
  String get scheduleShiftDeleteTooltip;

  /// No description provided for @scheduleBreakSuffix.
  ///
  /// In ko, this message translates to:
  /// **'(휴게 {minutes}분)'**
  String scheduleBreakSuffix(int minutes);

  /// No description provided for @scheduleNoMockHint.
  ///
  /// In ko, this message translates to:
  /// **'— 모의안으로 시뮬레이션 가능'**
  String get scheduleNoMockHint;

  /// No description provided for @weekMon.
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get weekMon;

  /// No description provided for @weekTue.
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get weekTue;

  /// No description provided for @weekWed.
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get weekWed;

  /// No description provided for @weekThu.
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get weekThu;

  /// No description provided for @weekFri.
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get weekFri;

  /// No description provided for @weekSat.
  ///
  /// In ko, this message translates to:
  /// **'토'**
  String get weekSat;

  /// No description provided for @weekSun.
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get weekSun;

  /// No description provided for @shiftSheetTitleNew.
  ///
  /// In ko, this message translates to:
  /// **'시프트 추가'**
  String get shiftSheetTitleNew;

  /// No description provided for @shiftSheetTitleEdit.
  ///
  /// In ko, this message translates to:
  /// **'시프트 편집'**
  String get shiftSheetTitleEdit;

  /// No description provided for @shiftSheetJob.
  ///
  /// In ko, this message translates to:
  /// **'근무처'**
  String get shiftSheetJob;

  /// No description provided for @shiftSheetStart.
  ///
  /// In ko, this message translates to:
  /// **'시작'**
  String get shiftSheetStart;

  /// No description provided for @shiftSheetEnd.
  ///
  /// In ko, this message translates to:
  /// **'종료'**
  String get shiftSheetEnd;

  /// No description provided for @shiftSheetBreak.
  ///
  /// In ko, this message translates to:
  /// **'휴게'**
  String get shiftSheetBreak;

  /// No description provided for @shiftSheetMemo.
  ///
  /// In ko, this message translates to:
  /// **'메모 (선택)'**
  String get shiftSheetMemo;

  /// No description provided for @shiftSheetMemoHint.
  ///
  /// In ko, this message translates to:
  /// **'예) 매출 마감'**
  String get shiftSheetMemoHint;

  /// No description provided for @shiftSheetBreakMin.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분'**
  String shiftSheetBreakMin(int minutes);

  /// No description provided for @shiftSheetWorkMin.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분'**
  String shiftSheetWorkMin(int minutes);

  /// No description provided for @shiftSheetWorkHours.
  ///
  /// In ko, this message translates to:
  /// **'근무시간 {hours}h'**
  String shiftSheetWorkHours(String hours);

  /// No description provided for @shiftSheetSelectStart.
  ///
  /// In ko, this message translates to:
  /// **'시작 시각을 먼저 골라주세요'**
  String get shiftSheetSelectStart;

  /// No description provided for @shiftSheetSelectEnd.
  ///
  /// In ko, this message translates to:
  /// **'종료 시각을 먼저 골라주세요'**
  String get shiftSheetSelectEnd;

  /// No description provided for @shiftSheetEndBeforeStart.
  ///
  /// In ko, this message translates to:
  /// **'종료 시각이 시작 시각보다 빠르면 안 돼요'**
  String get shiftSheetEndBeforeStart;

  /// No description provided for @shiftSheetBreakTooLong.
  ///
  /// In ko, this message translates to:
  /// **'휴게 시간이 근무 시간보다 길어요'**
  String get shiftSheetBreakTooLong;

  /// No description provided for @shiftSheetOverlapTitle.
  ///
  /// In ko, this message translates to:
  /// **'겹치는 시프트가 있어요'**
  String get shiftSheetOverlapTitle;

  /// No description provided for @shiftSheetOverlapBody.
  ///
  /// In ko, this message translates to:
  /// **'다음 시프트와 시간이 겹칩니다:'**
  String get shiftSheetOverlapBody;

  /// No description provided for @shiftSheetOverlapItem.
  ///
  /// In ko, this message translates to:
  /// **'{jobName} · {start} ~ {end}'**
  String shiftSheetOverlapItem(String jobName, String start, String end);

  /// No description provided for @shiftSheetOverlapSave.
  ///
  /// In ko, this message translates to:
  /// **'그래도 저장'**
  String get shiftSheetOverlapSave;

  /// No description provided for @shiftSheetSelectJob.
  ///
  /// In ko, this message translates to:
  /// **'근무처를 선택하세요'**
  String get shiftSheetSelectJob;

  /// No description provided for @shiftSheetDelete.
  ///
  /// In ko, this message translates to:
  /// **'이 시프트 삭제'**
  String get shiftSheetDelete;

  /// No description provided for @shiftSheetDeletedSnapshot.
  ///
  /// In ko, this message translates to:
  /// **'시프트 편집 전'**
  String get shiftSheetDeletedSnapshot;

  /// No description provided for @shiftSheetSavedSnapshot.
  ///
  /// In ko, this message translates to:
  /// **'시프트 저장 전'**
  String get shiftSheetSavedSnapshot;

  /// No description provided for @shiftSheetCreatedSnapshot.
  ///
  /// In ko, this message translates to:
  /// **'시프트 추가 전'**
  String get shiftSheetCreatedSnapshot;

  /// No description provided for @recurringTitle.
  ///
  /// In ko, this message translates to:
  /// **'반복 시프트 추가'**
  String get recurringTitle;

  /// No description provided for @recurringHelp.
  ///
  /// In ko, this message translates to:
  /// **'기간과 요일을 선택하면 그 범위의 해당 요일에 동일 시간/근무처로 시프트를 만들어요.'**
  String get recurringHelp;

  /// No description provided for @recurringPeriod.
  ///
  /// In ko, this message translates to:
  /// **'기간'**
  String get recurringPeriod;

  /// No description provided for @recurringPeriodFrom.
  ///
  /// In ko, this message translates to:
  /// **'시작일'**
  String get recurringPeriodFrom;

  /// No description provided for @recurringPeriodTo.
  ///
  /// In ko, this message translates to:
  /// **'종료일'**
  String get recurringPeriodTo;

  /// No description provided for @recurringWeekdays.
  ///
  /// In ko, this message translates to:
  /// **'요일'**
  String get recurringWeekdays;

  /// No description provided for @recurringJob.
  ///
  /// In ko, this message translates to:
  /// **'근무처'**
  String get recurringJob;

  /// No description provided for @recurringTimeBreak.
  ///
  /// In ko, this message translates to:
  /// **'시간 / 휴게'**
  String get recurringTimeBreak;

  /// No description provided for @recurringSelectWeekdays.
  ///
  /// In ko, this message translates to:
  /// **'요일을 1개 이상 선택해주세요'**
  String get recurringSelectWeekdays;

  /// No description provided for @recurringPeriodInvalid.
  ///
  /// In ko, this message translates to:
  /// **'종료일은 시작일과 같거나 이후여야 해요'**
  String get recurringPeriodInvalid;

  /// No description provided for @recurringPreview.
  ///
  /// In ko, this message translates to:
  /// **'총 {count}개 시프트 생성됩니다 ({overlapCount}개는 기존과 겹침)'**
  String recurringPreview(int count, int overlapCount);

  /// No description provided for @recurringOverlapConfirm.
  ///
  /// In ko, this message translates to:
  /// **'겹치는 시프트가 {count}개 있습니다. 그래도 만드시겠어요?'**
  String recurringOverlapConfirm(int count);

  /// No description provided for @recurringCreate.
  ///
  /// In ko, this message translates to:
  /// **'만들기'**
  String get recurringCreate;

  /// No description provided for @recurringCreatedCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 시프트 생성됨'**
  String recurringCreatedCount(int count);

  /// No description provided for @recurringSnapshot.
  ///
  /// In ko, this message translates to:
  /// **'반복 시프트 {count}개 추가'**
  String recurringSnapshot(int count);

  /// No description provided for @planMain.
  ///
  /// In ko, this message translates to:
  /// **'메인'**
  String get planMain;

  /// No description provided for @planSelectMock.
  ///
  /// In ko, this message translates to:
  /// **'모의안 선택'**
  String get planSelectMock;

  /// No description provided for @planLoadFromMain.
  ///
  /// In ko, this message translates to:
  /// **'메인에서 불러오기'**
  String get planLoadFromMain;

  /// No description provided for @planReplaceMain.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\"을 메인으로 교체'**
  String planReplaceMain(String name);

  /// No description provided for @planNewMock.
  ///
  /// In ko, this message translates to:
  /// **'{month}월 새 모의안 추가'**
  String planNewMock(int month);

  /// No description provided for @planNoneThisMonth.
  ///
  /// In ko, this message translates to:
  /// **'이 달의 모의안이 없어요'**
  String get planNoneThisMonth;

  /// No description provided for @planAutoName.
  ///
  /// In ko, this message translates to:
  /// **'{month}월 모의안 {n}'**
  String planAutoName(int month, int n);

  /// No description provided for @planLoadConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'메인에서 불러오기'**
  String get planLoadConfirmTitle;

  /// No description provided for @planLoadConfirmBody.
  ///
  /// In ko, this message translates to:
  /// **'메인의 {year}년 {month}월 시프트를 \"{name}\"으로\n복사합니다. 현재 \"{name}\"의 시프트는 모두 사라집니다.\n\n되돌리기로 복원할 수 있어요.'**
  String planLoadConfirmBody(int year, int month, String name);

  /// No description provided for @planLoadDone.
  ///
  /// In ko, this message translates to:
  /// **'메인에서 {count}개 시프트 불러옴'**
  String planLoadDone(int count);

  /// No description provided for @planLoadSnap.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\"에 메인 불러오기'**
  String planLoadSnap(String name);

  /// No description provided for @planReplaceConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\"을 메인으로 교체'**
  String planReplaceConfirmTitle(String name);

  /// No description provided for @planReplaceConfirmBody.
  ///
  /// In ko, this message translates to:
  /// **'메인의 {year}년 {month}월 시프트를\n\"{name}\"의 데이터로 교체합니다.\n메인의 해당 달 시프트는 모두 사라집니다.\n\n되돌리기로 복원할 수 있어요. 모의안 데이터는 그대로 유지됩니다.'**
  String planReplaceConfirmBody(int year, int month, String name);

  /// No description provided for @planReplaceDone.
  ///
  /// In ko, this message translates to:
  /// **'메인을 \"{name}\"({count}개)로 교체함'**
  String planReplaceDone(String name, int count);

  /// No description provided for @planReplaceSnap.
  ///
  /// In ko, this message translates to:
  /// **'메인 {year}년 {month}월을 \"{name}\"으로 교체'**
  String planReplaceSnap(int year, int month, String name);

  /// No description provided for @planMockCreated.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\" 생성 (메인에서 {count}개 복사)'**
  String planMockCreated(String name, int count);

  /// No description provided for @planMockDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'모의안 삭제'**
  String get planMockDeleteTitle;

  /// No description provided for @planMockDeleteBody.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\"을(를) 삭제하시겠습니까?\n\n되돌리기로 복원할 수 있어요.'**
  String planMockDeleteBody(String name);

  /// No description provided for @planMockDeleteTooltip.
  ///
  /// In ko, this message translates to:
  /// **'모의안 삭제'**
  String get planMockDeleteTooltip;

  /// No description provided for @planMockDeleted.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\" 삭제됨'**
  String planMockDeleted(String name);

  /// No description provided for @planMockDeleteSnap.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\" 삭제'**
  String planMockDeleteSnap(String name);

  /// No description provided for @planSelectTooltip.
  ///
  /// In ko, this message translates to:
  /// **'모의안 선택'**
  String get planSelectTooltip;

  /// No description provided for @jobsTitle.
  ///
  /// In ko, this message translates to:
  /// **'근무처 관리'**
  String get jobsTitle;

  /// No description provided for @jobsAdd.
  ///
  /// In ko, this message translates to:
  /// **'근무처 추가'**
  String get jobsAdd;

  /// No description provided for @jobsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'등록된 근무처가 없습니다'**
  String get jobsEmpty;

  /// No description provided for @jobsEmptyHint.
  ///
  /// In ko, this message translates to:
  /// **'+ 버튼으로 새 근무처를 추가하세요.'**
  String get jobsEmptyHint;

  /// No description provided for @jobsArchivedShow.
  ///
  /// In ko, this message translates to:
  /// **'보관된 근무처 표시'**
  String get jobsArchivedShow;

  /// No description provided for @jobsArchive.
  ///
  /// In ko, this message translates to:
  /// **'보관'**
  String get jobsArchive;

  /// No description provided for @jobsUnarchive.
  ///
  /// In ko, this message translates to:
  /// **'보관 해제'**
  String get jobsUnarchive;

  /// No description provided for @jobsDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get jobsDelete;

  /// No description provided for @jobsArchived.
  ///
  /// In ko, this message translates to:
  /// **'(보관됨)'**
  String get jobsArchived;

  /// No description provided for @jobsDeleteConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'근무처 삭제'**
  String get jobsDeleteConfirmTitle;

  /// No description provided for @jobsDeleteConfirmBody.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\"을(를) 정말 삭제할까요?\n\n주의: 이 근무처의 시프트가 있다면 삭제할 수 없어요. 먼저 시프트들을 정리하거나 \"보관\"을 사용하세요.'**
  String jobsDeleteConfirmBody(String name);

  /// No description provided for @jobsDeleteFailedHasShifts.
  ///
  /// In ko, this message translates to:
  /// **'이 근무처의 시프트가 있어 삭제할 수 없어요. \"보관\"을 대신 사용하세요.'**
  String get jobsDeleteFailedHasShifts;

  /// No description provided for @jobsDeleted.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\" 삭제됨'**
  String jobsDeleted(String name);

  /// No description provided for @jobsArchivedSnack.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\" 보관됨'**
  String jobsArchivedSnack(String name);

  /// No description provided for @jobsUnarchivedSnack.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\" 보관 해제됨'**
  String jobsUnarchivedSnack(String name);

  /// No description provided for @jobsWageLabel.
  ///
  /// In ko, this message translates to:
  /// **'{wage}원/시'**
  String jobsWageLabel(String wage);

  /// No description provided for @jobsAdvancedOptions.
  ///
  /// In ko, this message translates to:
  /// **'고급 옵션'**
  String get jobsAdvancedOptions;

  /// No description provided for @jobSheetTitleNew.
  ///
  /// In ko, this message translates to:
  /// **'근무처 추가'**
  String get jobSheetTitleNew;

  /// No description provided for @jobSheetTitleEdit.
  ///
  /// In ko, this message translates to:
  /// **'근무처 편집'**
  String get jobSheetTitleEdit;

  /// No description provided for @jobSheetName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get jobSheetName;

  /// No description provided for @jobSheetNameHint.
  ///
  /// In ko, this message translates to:
  /// **'예) 카페 알바, 편의점 등'**
  String get jobSheetNameHint;

  /// No description provided for @jobSheetWage.
  ///
  /// In ko, this message translates to:
  /// **'시급 (원)'**
  String get jobSheetWage;

  /// No description provided for @jobSheetIncomeType.
  ///
  /// In ko, this message translates to:
  /// **'소득 유형'**
  String get jobSheetIncomeType;

  /// No description provided for @jobSheetBusinessSize.
  ///
  /// In ko, this message translates to:
  /// **'사업장 규모'**
  String get jobSheetBusinessSize;

  /// No description provided for @jobSheetColor.
  ///
  /// In ko, this message translates to:
  /// **'표시 색상'**
  String get jobSheetColor;

  /// No description provided for @jobSheetNameRequired.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력하세요'**
  String get jobSheetNameRequired;

  /// No description provided for @jobSheetWageRequired.
  ///
  /// In ko, this message translates to:
  /// **'시급을 입력하세요'**
  String get jobSheetWageRequired;

  /// No description provided for @jobSheetWageInvalid.
  ///
  /// In ko, this message translates to:
  /// **'올바른 숫자를 입력하세요'**
  String get jobSheetWageInvalid;

  /// No description provided for @jobSheetSaved.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\" 저장됨'**
  String jobSheetSaved(String name);

  /// No description provided for @jobAdvNightPremium.
  ///
  /// In ko, this message translates to:
  /// **'야간 가산 (22:00~06:00 +50%)'**
  String get jobAdvNightPremium;

  /// No description provided for @jobAdvDailyOvertime.
  ///
  /// In ko, this message translates to:
  /// **'일 연장 (8h 초과 +50%)'**
  String get jobAdvDailyOvertime;

  /// No description provided for @jobAdvWeeklyOvertime.
  ///
  /// In ko, this message translates to:
  /// **'주 연장 (40h 초과 +50%)'**
  String get jobAdvWeeklyOvertime;

  /// No description provided for @jobAdvHolidayPremium.
  ///
  /// In ko, this message translates to:
  /// **'휴일근로 가산'**
  String get jobAdvHolidayPremium;

  /// No description provided for @jobAdvWeeklyHoliday.
  ///
  /// In ko, this message translates to:
  /// **'주휴수당 (주 15h+ 1일분)'**
  String get jobAdvWeeklyHoliday;

  /// No description provided for @jobAdvPreciseBreak.
  ///
  /// In ko, this message translates to:
  /// **'휴게 입력을 시각 단위로'**
  String get jobAdvPreciseBreak;

  /// No description provided for @jobAdvDeductionMode.
  ///
  /// In ko, this message translates to:
  /// **'공제 모드'**
  String get jobAdvDeductionMode;

  /// No description provided for @jobAdvFourInsuranceRate.
  ///
  /// In ko, this message translates to:
  /// **'4대보험 요율 (만분율)'**
  String get jobAdvFourInsuranceRate;

  /// No description provided for @deductionNone.
  ///
  /// In ko, this message translates to:
  /// **'비과세'**
  String get deductionNone;

  /// No description provided for @deductionBusiness33.
  ///
  /// In ko, this message translates to:
  /// **'사업소득 3.3%'**
  String get deductionBusiness33;

  /// No description provided for @deductionFourInsurance.
  ///
  /// In ko, this message translates to:
  /// **'4대보험'**
  String get deductionFourInsurance;

  /// No description provided for @incomePartTime.
  ///
  /// In ko, this message translates to:
  /// **'아르바이트'**
  String get incomePartTime;

  /// No description provided for @incomeWorkStudy.
  ///
  /// In ko, this message translates to:
  /// **'근로장학'**
  String get incomeWorkStudy;

  /// No description provided for @businessUnder5.
  ///
  /// In ko, this message translates to:
  /// **'5인 미만'**
  String get businessUnder5;

  /// No description provided for @businessFiveOrMore.
  ///
  /// In ko, this message translates to:
  /// **'5인 이상'**
  String get businessFiveOrMore;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따름'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageKo.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get settingsLanguageKo;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsSectionTheme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get settingsSectionTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get settingsThemeDark;

  /// No description provided for @settingsSectionTimeFormat.
  ///
  /// In ko, this message translates to:
  /// **'시간 표시'**
  String get settingsSectionTimeFormat;

  /// No description provided for @settingsUse24Hour.
  ///
  /// In ko, this message translates to:
  /// **'24시간 형식'**
  String get settingsUse24Hour;

  /// No description provided for @settingsUse12Hour.
  ///
  /// In ko, this message translates to:
  /// **'오전/오후 형식'**
  String get settingsUse12Hour;

  /// No description provided for @settingsSectionPayroll.
  ///
  /// In ko, this message translates to:
  /// **'급여 계산'**
  String get settingsSectionPayroll;

  /// No description provided for @settingsLaborLaw.
  ///
  /// In ko, this message translates to:
  /// **'한국 노동법 준수 모드'**
  String get settingsLaborLaw;

  /// No description provided for @settingsLaborLawHint.
  ///
  /// In ko, this message translates to:
  /// **'야간/연장/주휴/공제 등 한국 노동법 기반 옵션을 사용해요. 끄면 단순 시급 × 근무시간만 계산하고 관련 옵션이 숨겨집니다.'**
  String get settingsLaborLawHint;

  /// No description provided for @settingsAdvancedConstants.
  ///
  /// In ko, this message translates to:
  /// **'고고급 설정 (가산률·상수)'**
  String get settingsAdvancedConstants;

  /// No description provided for @settingsSectionBackup.
  ///
  /// In ko, this message translates to:
  /// **'백업'**
  String get settingsSectionBackup;

  /// No description provided for @settingsBackupAndRestore.
  ///
  /// In ko, this message translates to:
  /// **'백업 / 복원'**
  String get settingsBackupAndRestore;

  /// No description provided for @settingsLastBackup.
  ///
  /// In ko, this message translates to:
  /// **'마지막 백업: {at}'**
  String settingsLastBackup(String at);

  /// No description provided for @settingsNeverBackup.
  ///
  /// In ko, this message translates to:
  /// **'백업 기록 없음'**
  String get settingsNeverBackup;

  /// No description provided for @settingsSectionInfo.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get settingsSectionInfo;

  /// No description provided for @settingsVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get settingsVersion;

  /// No description provided for @settingsAppDescription.
  ///
  /// In ko, this message translates to:
  /// **'광고 없는 근무 일정·월급 계산 앱'**
  String get settingsAppDescription;

  /// No description provided for @advancedTitle.
  ///
  /// In ko, this message translates to:
  /// **'고고급 설정'**
  String get advancedTitle;

  /// No description provided for @advancedHelp.
  ///
  /// In ko, this message translates to:
  /// **'이 화면의 값은 기본적으로 한국 노동법 기준입니다. 변경 시 신중히 다루어주세요. 잘못된 값이 들어가면 계산이 어긋날 수 있습니다.'**
  String get advancedHelp;

  /// No description provided for @advancedReset.
  ///
  /// In ko, this message translates to:
  /// **'기본값으로 초기화'**
  String get advancedReset;

  /// No description provided for @advancedResetDone.
  ///
  /// In ko, this message translates to:
  /// **'기본값으로 초기화됨'**
  String get advancedResetDone;

  /// No description provided for @advancedSaved.
  ///
  /// In ko, this message translates to:
  /// **'설정이 저장되었습니다'**
  String get advancedSaved;

  /// No description provided for @advancedNightStart.
  ///
  /// In ko, this message translates to:
  /// **'야간 시작 시각 (시)'**
  String get advancedNightStart;

  /// No description provided for @advancedNightEnd.
  ///
  /// In ko, this message translates to:
  /// **'야간 종료 시각 (시)'**
  String get advancedNightEnd;

  /// No description provided for @advancedDailyOTThreshold.
  ///
  /// In ko, this message translates to:
  /// **'일 연장 기준 시간 (h)'**
  String get advancedDailyOTThreshold;

  /// No description provided for @advancedWeeklyOTThreshold.
  ///
  /// In ko, this message translates to:
  /// **'주 연장 기준 시간 (h)'**
  String get advancedWeeklyOTThreshold;

  /// No description provided for @advancedHolidayOTThreshold.
  ///
  /// In ko, this message translates to:
  /// **'휴일 가산 분기 시간 (h)'**
  String get advancedHolidayOTThreshold;

  /// No description provided for @advancedNightPremiumPct.
  ///
  /// In ko, this message translates to:
  /// **'야간 가산률 (%)'**
  String get advancedNightPremiumPct;

  /// No description provided for @advancedDailyOTPremiumPct.
  ///
  /// In ko, this message translates to:
  /// **'일 연장 가산률 (%)'**
  String get advancedDailyOTPremiumPct;

  /// No description provided for @advancedWeeklyOTPremiumPct.
  ///
  /// In ko, this message translates to:
  /// **'주 연장 가산률 (%)'**
  String get advancedWeeklyOTPremiumPct;

  /// No description provided for @advancedHolidayBasePct.
  ///
  /// In ko, this message translates to:
  /// **'휴일 기본 가산률 (%)'**
  String get advancedHolidayBasePct;

  /// No description provided for @advancedHolidayOverPct.
  ///
  /// In ko, this message translates to:
  /// **'휴일 초과 가산률 (%)'**
  String get advancedHolidayOverPct;

  /// No description provided for @advancedWeeklyHolidayHours.
  ///
  /// In ko, this message translates to:
  /// **'주휴수당 최소 시간 (h)'**
  String get advancedWeeklyHolidayHours;

  /// No description provided for @advancedWeeklyHolidayCap.
  ///
  /// In ko, this message translates to:
  /// **'주휴수당 시간 상한 (h)'**
  String get advancedWeeklyHolidayCap;

  /// No description provided for @advancedBusinessIncomePct.
  ///
  /// In ko, this message translates to:
  /// **'사업소득 원천징수율 (%)'**
  String get advancedBusinessIncomePct;

  /// No description provided for @advancedSectionThresholds.
  ///
  /// In ko, this message translates to:
  /// **'기준 시간'**
  String get advancedSectionThresholds;

  /// No description provided for @advancedSectionPremiums.
  ///
  /// In ko, this message translates to:
  /// **'가산률'**
  String get advancedSectionPremiums;

  /// No description provided for @advancedSectionWeeklyHoliday.
  ///
  /// In ko, this message translates to:
  /// **'주휴수당'**
  String get advancedSectionWeeklyHoliday;

  /// No description provided for @advancedSectionDeductions.
  ///
  /// In ko, this message translates to:
  /// **'공제율'**
  String get advancedSectionDeductions;

  /// No description provided for @backupTitle.
  ///
  /// In ko, this message translates to:
  /// **'백업 / 복원'**
  String get backupTitle;

  /// No description provided for @backupExport.
  ///
  /// In ko, this message translates to:
  /// **'백업 파일 만들기'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In ko, this message translates to:
  /// **'백업 파일에서 복원'**
  String get backupImport;

  /// No description provided for @backupExportSaved.
  ///
  /// In ko, this message translates to:
  /// **'{path}\n에 저장됨'**
  String backupExportSaved(String path);

  /// No description provided for @backupExportFailed.
  ///
  /// In ko, this message translates to:
  /// **'내보내기 실패: {error}'**
  String backupExportFailed(String error);

  /// No description provided for @backupImportConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'백업에서 복원'**
  String get backupImportConfirmTitle;

  /// No description provided for @backupImportConfirmBody.
  ///
  /// In ko, this message translates to:
  /// **'현재 모든 데이터가 백업 파일의 내용으로 교체됩니다. 계속할까요?'**
  String get backupImportConfirmBody;

  /// No description provided for @backupImportRestored.
  ///
  /// In ko, this message translates to:
  /// **'복원됨: 근무처 {jobs}개, 시프트 {shifts}개'**
  String backupImportRestored(int jobs, int shifts);

  /// No description provided for @backupImportFailed.
  ///
  /// In ko, this message translates to:
  /// **'복원 실패: {error}'**
  String backupImportFailed(String error);

  /// No description provided for @backupIncompatibleVersion.
  ///
  /// In ko, this message translates to:
  /// **'백업 파일의 스키마 버전({backup})이 현재 앱({current})과 달라 가져올 수 없어요.'**
  String backupIncompatibleVersion(int backup, int current);

  /// No description provided for @backupSectionWhat.
  ///
  /// In ko, this message translates to:
  /// **'백업되는 내용'**
  String get backupSectionWhat;

  /// No description provided for @backupSectionWhatBody.
  ///
  /// In ko, this message translates to:
  /// **'• 근무처 + 옵션\n• 모든 시프트(메인 + 모의안)\n• 모의안 메타데이터\n• 앱 설정 (테마, 시간 형식, 활성 plan 등)\n\n포함되지 않음: 되돌리기 스택 (사용자 액션 이력)'**
  String get backupSectionWhatBody;

  /// No description provided for @backupLastBackupNever.
  ///
  /// In ko, this message translates to:
  /// **'백업한 적이 없어요'**
  String get backupLastBackupNever;

  /// No description provided for @backupLastBackupAt.
  ///
  /// In ko, this message translates to:
  /// **'마지막 백업: {at}'**
  String backupLastBackupAt(String at);

  /// No description provided for @reportTitle.
  ///
  /// In ko, this message translates to:
  /// **'급여 명세'**
  String get reportTitle;

  /// No description provided for @reportViewPrefix.
  ///
  /// In ko, this message translates to:
  /// **'보기:'**
  String get reportViewPrefix;

  /// No description provided for @reportNoMockThisMonth.
  ///
  /// In ko, this message translates to:
  /// **'— 이 달에 모의안이 없어요'**
  String get reportNoMockThisMonth;

  /// No description provided for @reportTabAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get reportTabAll;

  /// No description provided for @reportAllJobsCombined.
  ///
  /// In ko, this message translates to:
  /// **'모든 근무처 합산'**
  String get reportAllJobsCombined;

  /// No description provided for @reportNoRecords.
  ///
  /// In ko, this message translates to:
  /// **'이 달에 근무 기록이 없어요'**
  String get reportNoRecords;

  /// No description provided for @reportNoRecordsJob.
  ///
  /// In ko, this message translates to:
  /// **'{job} — 이 달에 근무 기록이 없어요'**
  String reportNoRecordsJob(String job);

  /// No description provided for @reportPaymentItems.
  ///
  /// In ko, this message translates to:
  /// **'지급 항목'**
  String get reportPaymentItems;

  /// No description provided for @reportDeductionItems.
  ///
  /// In ko, this message translates to:
  /// **'공제 항목'**
  String get reportDeductionItems;

  /// No description provided for @reportItemBasePay.
  ///
  /// In ko, this message translates to:
  /// **'기본급'**
  String get reportItemBasePay;

  /// No description provided for @reportItemBasePayHint.
  ///
  /// In ko, this message translates to:
  /// **'근무 시간 × 시급'**
  String get reportItemBasePayHint;

  /// No description provided for @reportItemNight.
  ///
  /// In ko, this message translates to:
  /// **'야간 가산수당'**
  String get reportItemNight;

  /// No description provided for @reportItemNightHint.
  ///
  /// In ko, this message translates to:
  /// **'22:00~06:00 근무에 +50%'**
  String get reportItemNightHint;

  /// No description provided for @reportItemDailyOT.
  ///
  /// In ko, this message translates to:
  /// **'일 연장 가산수당'**
  String get reportItemDailyOT;

  /// No description provided for @reportItemDailyOTHint.
  ///
  /// In ko, this message translates to:
  /// **'하루 8h 초과분에 +50%'**
  String get reportItemDailyOTHint;

  /// No description provided for @reportItemWeeklyOT.
  ///
  /// In ko, this message translates to:
  /// **'주 연장 가산수당'**
  String get reportItemWeeklyOT;

  /// No description provided for @reportItemWeeklyOTHint.
  ///
  /// In ko, this message translates to:
  /// **'주 40h 초과분에 +50% (일 OT와 중복 안 됨)'**
  String get reportItemWeeklyOTHint;

  /// No description provided for @reportItemHolidayWithin.
  ///
  /// In ko, this message translates to:
  /// **'휴일근로 가산수당 (≤8h)'**
  String get reportItemHolidayWithin;

  /// No description provided for @reportItemHolidayWithinHint.
  ///
  /// In ko, this message translates to:
  /// **'휴일 근무 8시간 이내 +50%'**
  String get reportItemHolidayWithinHint;

  /// No description provided for @reportItemHolidayOver.
  ///
  /// In ko, this message translates to:
  /// **'휴일근로 가산수당 (>8h)'**
  String get reportItemHolidayOver;

  /// No description provided for @reportItemHolidayOverHint.
  ///
  /// In ko, this message translates to:
  /// **'휴일 근무 8시간 초과분 +100%'**
  String get reportItemHolidayOverHint;

  /// No description provided for @reportItemWeeklyHoliday.
  ///
  /// In ko, this message translates to:
  /// **'주휴수당'**
  String get reportItemWeeklyHoliday;

  /// No description provided for @reportItemWeeklyHolidayHint.
  ///
  /// In ko, this message translates to:
  /// **'주 15h+ 결근 없을 때 1일분'**
  String get reportItemWeeklyHolidayHint;

  /// No description provided for @reportItemBusinessIncome.
  ///
  /// In ko, this message translates to:
  /// **'사업소득 원천징수'**
  String get reportItemBusinessIncome;

  /// No description provided for @reportItemBusinessIncomeHint.
  ///
  /// In ko, this message translates to:
  /// **'3.3% (소득세 + 지방소득세)'**
  String get reportItemBusinessIncomeHint;

  /// No description provided for @reportItemFourInsurance.
  ///
  /// In ko, this message translates to:
  /// **'4대보험'**
  String get reportItemFourInsurance;

  /// No description provided for @reportItemFourInsuranceHint.
  ///
  /// In ko, this message translates to:
  /// **'국민연금 + 건강 + 고용 + 장기요양'**
  String get reportItemFourInsuranceHint;

  /// No description provided for @reportGrossLabel.
  ///
  /// In ko, this message translates to:
  /// **'총 지급 (gross)'**
  String get reportGrossLabel;

  /// No description provided for @reportTotalDeductionLabel.
  ///
  /// In ko, this message translates to:
  /// **'총 공제'**
  String get reportTotalDeductionLabel;

  /// No description provided for @reportNetLabel.
  ///
  /// In ko, this message translates to:
  /// **'실수령'**
  String get reportNetLabel;

  /// No description provided for @reportTotalAmount.
  ///
  /// In ko, this message translates to:
  /// **'{amount}원'**
  String reportTotalAmount(String amount);

  /// No description provided for @reportNegativeAmount.
  ///
  /// In ko, this message translates to:
  /// **'-{amount}원'**
  String reportNegativeAmount(String amount);

  /// No description provided for @reportWorkTimeLabel.
  ///
  /// In ko, this message translates to:
  /// **'실 근무 {h}시간{m}'**
  String reportWorkTimeLabel(int h, String m);

  /// No description provided for @reportWorkMinutesSuffix.
  ///
  /// In ko, this message translates to:
  /// **' {m}분'**
  String reportWorkMinutesSuffix(int m);

  /// No description provided for @reportFootnote.
  ///
  /// In ko, this message translates to:
  /// **'* 일급 표시는 기본급+야간+일OT+휴일 가산만 합산되며, 주OT·주휴·공제는 월 단위로만 적용됩니다.'**
  String get reportFootnote;

  /// No description provided for @reportCalcError.
  ///
  /// In ko, this message translates to:
  /// **'계산 오류: {error}'**
  String reportCalcError(String error);

  /// No description provided for @yearMonthPickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'년/월 선택'**
  String get yearMonthPickerTitle;

  /// No description provided for @yearLabel.
  ///
  /// In ko, this message translates to:
  /// **'년'**
  String get yearLabel;

  /// No description provided for @monthLabel.
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get monthLabel;

  /// No description provided for @amSuffix.
  ///
  /// In ko, this message translates to:
  /// **'오전'**
  String get amSuffix;

  /// No description provided for @pmSuffix.
  ///
  /// In ko, this message translates to:
  /// **'오후'**
  String get pmSuffix;

  /// No description provided for @deductionModeNone.
  ///
  /// In ko, this message translates to:
  /// **'공제 없음'**
  String get deductionModeNone;

  /// No description provided for @deductionModeBusiness.
  ///
  /// In ko, this message translates to:
  /// **'사업소득 3.3%'**
  String get deductionModeBusiness;

  /// No description provided for @deductionModeInsurance.
  ///
  /// In ko, this message translates to:
  /// **'4대보험'**
  String get deductionModeInsurance;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
