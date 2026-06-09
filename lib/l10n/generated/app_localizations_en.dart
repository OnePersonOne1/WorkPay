// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WorkPay';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionClose => 'Close';

  @override
  String get actionOk => 'OK';

  @override
  String get actionBack => 'Back';

  @override
  String get actionYes => 'Yes';

  @override
  String get actionNo => 'No';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionRedo => 'Redo';

  @override
  String get actionTryAgain => 'Try Again';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionLoad => 'Load';

  @override
  String get actionReplace => 'Replace';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navSettings => 'Settings';

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get scheduleAddRecurring => 'Recurring';

  @override
  String get scheduleViewPayroll => 'Pay Slip';

  @override
  String get scheduleResetMonth => 'Clear This Month';

  @override
  String get scheduleAddShift => 'Add Shift';

  @override
  String get scheduleBackToToday => 'Back to Today';

  @override
  String get scheduleYearMonthMove => 'Pick Year / Month';

  @override
  String get schedulePrevMonth => 'Prev Month';

  @override
  String get scheduleNextMonth => 'Next Month';

  @override
  String get scheduleNoShifts => 'No shifts on this day.';

  @override
  String get scheduleNoJobsTitle => 'No jobs yet';

  @override
  String get scheduleNoJobsHint => 'To add a shift, register a job first.';

  @override
  String get scheduleNoJobsButton => 'Add Job';

  @override
  String get scheduleNoJobsRegistered => 'No jobs registered';

  @override
  String get scheduleJobsManage => 'Manage';

  @override
  String get scheduleDefaultJobNone =>
      'No default job — first job auto-selected when adding a shift';

  @override
  String scheduleDefaultJobLabel(String jobName) {
    return 'Default job: $jobName (auto-selected when adding a shift, changeable)';
  }

  @override
  String get scheduleVisDaily => 'Daily';

  @override
  String get scheduleVisWeekly => 'Weekly';

  @override
  String get scheduleVisMonthly => 'Monthly';

  @override
  String get scheduleWeeklySummary => 'Weekly Summary';

  @override
  String scheduleWeekNth(int n) {
    return 'Week $n';
  }

  @override
  String scheduleMonthSummary(String hours, String amount) {
    return 'This month: ${hours}h · $amount';
  }

  @override
  String scheduleGrossBefore(String amount) {
    return 'Gross $amount';
  }

  @override
  String scheduleMonthCalcError(String error) {
    return 'Monthly total error: $error';
  }

  @override
  String scheduleJobLoadError(String error) {
    return 'Failed to load jobs: $error';
  }

  @override
  String scheduleNoShiftsThisMonth(int year, int month) {
    return 'No shifts in $year-$month';
  }

  @override
  String scheduleDeleteMonthTitle(int year, int month) {
    return 'Delete all shifts in $year-$month';
  }

  @override
  String scheduleDeleteMonthBody(int count) {
    return 'Delete all $count shifts this month?\n\nYou can undo (up to last 5 actions).';
  }

  @override
  String scheduleDeleteMonthSnap(int year, int month, int count) {
    return 'Delete $count shifts in $year-$month';
  }

  @override
  String scheduleDeletedCount(int count) {
    return '$count shifts deleted';
  }

  @override
  String get scheduleSingleShiftDeleted => 'Deleted. You can undo.';

  @override
  String get scheduleShiftDeleteSnapshot => 'Delete shift';

  @override
  String scheduleShiftDeleteSnapshotWithDate(int month, int day) {
    return 'Delete shift on $month/$day';
  }

  @override
  String get scheduleNothingToUndo => 'Nothing to undo';

  @override
  String get scheduleNothingToRedo => 'Nothing to redo';

  @override
  String scheduleUndoneLabel(String description) {
    return 'Undone: $description';
  }

  @override
  String scheduleRedoneLabel(String description) {
    return 'Redone: $description';
  }

  @override
  String scheduleDateLabel(int year, int month, int day, String weekday) {
    return '$year-$month-$day ($weekday)';
  }

  @override
  String get scheduleShiftDeleteTooltip => 'Delete shift';

  @override
  String scheduleBreakSuffix(int minutes) {
    return '(break ${minutes}m)';
  }

  @override
  String get weekMon => 'Mon';

  @override
  String get weekTue => 'Tue';

  @override
  String get weekWed => 'Wed';

  @override
  String get weekThu => 'Thu';

  @override
  String get weekFri => 'Fri';

  @override
  String get weekSat => 'Sat';

  @override
  String get weekSun => 'Sun';

  @override
  String get shiftSheetTitleNew => 'Add Shift';

  @override
  String get shiftSheetTitleEdit => 'Edit Shift';

  @override
  String get shiftSheetJob => 'Job';

  @override
  String get shiftSheetStart => 'Start';

  @override
  String get shiftSheetEnd => 'End';

  @override
  String get shiftSheetBreak => 'Break';

  @override
  String get shiftSheetMemo => 'Note (optional)';

  @override
  String get shiftSheetMemoHint => 'e.g. closing shift';

  @override
  String shiftSheetBreakMin(int minutes) {
    return '${minutes}m';
  }

  @override
  String shiftSheetWorkMin(int minutes) {
    return '${minutes}m';
  }

  @override
  String shiftSheetWorkHours(String hours) {
    return 'Work ${hours}h';
  }

  @override
  String get shiftSheetSelectStart => 'Please pick a start time first';

  @override
  String get shiftSheetSelectEnd => 'Please pick an end time first';

  @override
  String get shiftSheetEndBeforeStart => 'End cannot be before start';

  @override
  String get shiftSheetBreakTooLong => 'Break cannot exceed work time';

  @override
  String get shiftSheetOverlapTitle => 'Overlapping shifts';

  @override
  String get shiftSheetOverlapBody =>
      'This conflicts with the following shifts:';

  @override
  String shiftSheetOverlapItem(String jobName, String start, String end) {
    return '$jobName · $start ~ $end';
  }

  @override
  String get shiftSheetOverlapSave => 'Save Anyway';

  @override
  String get shiftSheetSelectJob => 'Pick a job';

  @override
  String get shiftSheetDelete => 'Delete this shift';

  @override
  String get shiftSheetDeletedSnapshot => 'Delete shift';

  @override
  String get shiftSheetSavedSnapshot => 'Edit shift';

  @override
  String get shiftSheetCreatedSnapshot => 'Add shift';

  @override
  String get recurringTitle => 'Add Recurring Shifts';

  @override
  String get recurringHelp =>
      'Pick a date range and weekdays. Shifts with the same time/job will be created on matching days.';

  @override
  String get recurringPeriod => 'Period';

  @override
  String get recurringPeriodFrom => 'From';

  @override
  String get recurringPeriodTo => 'To';

  @override
  String get recurringWeekdays => 'Weekdays';

  @override
  String get recurringJob => 'Job';

  @override
  String get recurringTimeBreak => 'Time / Break';

  @override
  String get recurringSelectWeekdays => 'Pick at least one weekday';

  @override
  String get recurringPeriodInvalid =>
      'End date must be on or after start date';

  @override
  String recurringPreview(int count, int overlapCount) {
    return '$count shifts will be created ($overlapCount overlap existing)';
  }

  @override
  String recurringOverlapConfirm(int count) {
    return '$count overlap existing shifts. Create anyway?';
  }

  @override
  String get recurringCreate => 'Create';

  @override
  String recurringCreatedCount(int count) {
    return '$count shifts created';
  }

  @override
  String recurringSnapshot(int count) {
    return 'Add $count recurring shifts';
  }

  @override
  String get planMain => 'Main';

  @override
  String get planSelectMock => 'Pick Mock';

  @override
  String get planLoadFromMain => 'Load from Main';

  @override
  String planReplaceMain(String name) {
    return 'Replace Main with \"$name\"';
  }

  @override
  String planNewMock(int month) {
    return 'Add Mock for Month $month';
  }

  @override
  String get planNoneThisMonth => 'No mocks this month';

  @override
  String planAutoName(int month, int n) {
    return 'Mock $n ($month)';
  }

  @override
  String get planLoadConfirmTitle => 'Load from Main';

  @override
  String planLoadConfirmBody(int year, int month, String name) {
    return 'Copy Main\'s $year-$month shifts into \"$name\".\nCurrent shifts in \"$name\" will be removed.\n\nYou can undo this.';
  }

  @override
  String planLoadDone(int count) {
    return 'Loaded $count shifts from Main';
  }

  @override
  String planLoadSnap(String name) {
    return 'Load Main into \"$name\"';
  }

  @override
  String planReplaceConfirmTitle(String name) {
    return 'Replace Main with \"$name\"';
  }

  @override
  String planReplaceConfirmBody(int year, int month, String name) {
    return 'Replace Main\'s $year-$month shifts with data from \"$name\".\nMain\'s shifts for this month will be removed.\n\nYou can undo. The mock data stays intact.';
  }

  @override
  String planReplaceDone(String name, int count) {
    return 'Replaced Main with \"$name\" ($count shifts)';
  }

  @override
  String planReplaceSnap(int year, int month, String name) {
    return 'Replace Main $year-$month with \"$name\"';
  }

  @override
  String planMockCreated(String name, int count) {
    return 'Created \"$name\" (copied $count from Main)';
  }

  @override
  String get planMockDeleteTitle => 'Delete Mock';

  @override
  String planMockDeleteBody(String name) {
    return 'Delete \"$name\"?\n\nYou can undo.';
  }

  @override
  String get planMockDeleteTooltip => 'Delete mock';

  @override
  String planMockDeleted(String name) {
    return '\"$name\" deleted';
  }

  @override
  String planMockDeleteSnap(String name) {
    return 'Delete \"$name\"';
  }

  @override
  String get planSelectTooltip => 'Pick mock plan';

  @override
  String get jobsTitle => 'Jobs';

  @override
  String get jobsAdd => 'Add Job';

  @override
  String get jobsEmpty => 'No jobs registered';

  @override
  String get jobsEmptyHint => 'Tap + to add a new job.';

  @override
  String get jobsArchivedShow => 'Show archived jobs';

  @override
  String get jobsArchive => 'Archive';

  @override
  String get jobsUnarchive => 'Unarchive';

  @override
  String get jobsDelete => 'Delete';

  @override
  String get jobsArchived => '(archived)';

  @override
  String get jobsDeleteConfirmTitle => 'Delete Job';

  @override
  String jobsDeleteConfirmBody(String name) {
    return 'Delete \"$name\"?\n\nNote: If this job has shifts, deletion is blocked. Clear the shifts first, or use Archive instead.';
  }

  @override
  String get jobsDeleteFailedHasShifts =>
      'Cannot delete — this job has shifts. Use Archive instead.';

  @override
  String jobsDeleted(String name) {
    return '\"$name\" deleted';
  }

  @override
  String jobsArchivedSnack(String name) {
    return '\"$name\" archived';
  }

  @override
  String jobsUnarchivedSnack(String name) {
    return '\"$name\" unarchived';
  }

  @override
  String jobsWageLabel(String wage) {
    return '$wage/hr';
  }

  @override
  String get jobsAdvancedOptions => 'Advanced Options';

  @override
  String get jobSheetTitleNew => 'Add Job';

  @override
  String get jobSheetTitleEdit => 'Edit Job';

  @override
  String get jobSheetName => 'Name';

  @override
  String get jobSheetNameHint => 'e.g. Cafe, Convenience Store';

  @override
  String jobSheetWage(String unit) {
    return 'Hourly Wage ($unit)';
  }

  @override
  String get jobSheetIncomeType => 'Income Type';

  @override
  String get jobSheetBusinessSize => 'Business Size';

  @override
  String get jobSheetColor => 'Color';

  @override
  String get jobSheetNameRequired => 'Name is required';

  @override
  String get jobSheetWageRequired => 'Wage is required';

  @override
  String get jobSheetWageInvalid => 'Enter a valid number';

  @override
  String jobSheetSaved(String name) {
    return '\"$name\" saved';
  }

  @override
  String get jobAdvNightPremium => 'Night premium (22:00–06:00 +50%)';

  @override
  String get jobAdvDailyOvertime => 'Daily overtime (>8h +50%)';

  @override
  String get jobAdvWeeklyOvertime => 'Weekly overtime (>40h +50%)';

  @override
  String get jobAdvHolidayPremium => 'Holiday work premium';

  @override
  String get jobAdvWeeklyHoliday => 'Weekly paid holiday (15h+/wk → 1 day)';

  @override
  String get jobAdvPreciseBreak => 'Break input as time-of-day';

  @override
  String get jobAdvDeductionMode => 'Deduction mode';

  @override
  String get jobAdvFourInsuranceRate => '4 Insurances rate (per 10,000)';

  @override
  String get jobAdvPresetSection => 'Presets';

  @override
  String get jobAdvPresetCaption => 'Automatically turns options on/off.';

  @override
  String get jobAdvDisableAll => 'Turn off all options';

  @override
  String get jobAdvAllowanceSection => 'Allowances';

  @override
  String get jobAdvTaxSection => 'Tax & deductions';

  @override
  String get jobAdvInputSection => 'Input options';

  @override
  String get deductionNone => 'No deduction';

  @override
  String get deductionBusiness33 => 'Business income 3.3%';

  @override
  String get deductionFourInsurance => '4 Insurances';

  @override
  String get incomePartTime => 'Part-time';

  @override
  String get incomeWorkStudy => 'Work-study';

  @override
  String get businessUnder5 => 'Under 5';

  @override
  String get businessFiveOrMore => '5 or more';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Follow system';

  @override
  String get settingsLanguageKo => '한국어';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsSectionTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSectionTimeFormat => 'Time Format';

  @override
  String get settingsUse24Hour => '24-hour';

  @override
  String get settingsUse12Hour => '12-hour (AM/PM)';

  @override
  String get settingsSectionPayroll => 'Payroll Calculation';

  @override
  String get settingsCurrencyUnit => 'Currency unit';

  @override
  String get settingsCurrencyUnitHint =>
      'A label shown after amounts. It does not affect any calculation. (e.g. 원, \$, USD)';

  @override
  String get settingsCurrencyUnitDialogTitle => 'Currency unit';

  @override
  String get settingsCurrencyUnitFieldHint => 'e.g. 원, \$, USD';

  @override
  String get settingsLaborLaw => 'Korean labor law compliance';

  @override
  String get settingsLaborLawHint =>
      'Enables Korean labor-law items and key constants (night/overtime/weekly holiday/deductions). Whether they actually apply is set per workplace in \'Manage workplaces\'. When off, only simple wage × hours is calculated and related options are hidden.';

  @override
  String get settingsAllowOverlap => 'Allow overlapping shifts';

  @override
  String get settingsAllowOverlapHint =>
      'Lets you save time-overlapping shifts without a warning.';

  @override
  String get settingsAdvancedConstants => 'Advanced constants (rates)';

  @override
  String get settingsSectionBackup => 'Backup';

  @override
  String get settingsBackupAndRestore => 'Backup / Restore';

  @override
  String settingsLastBackup(String at) {
    return 'Last backup: $at';
  }

  @override
  String get settingsNeverBackup => 'No backup yet';

  @override
  String get settingsSectionInfo => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsAppDescription =>
      'Ad-free shift schedule & wage calculator';

  @override
  String get advancedTitle => 'Advanced Constants';

  @override
  String get advancedHelp =>
      'Values here default to Korean labor law. Change with care — wrong values can throw off the calculation.';

  @override
  String get advancedReset => 'Reset to defaults';

  @override
  String get advancedResetDone => 'Reset to defaults';

  @override
  String get advancedSaved => 'Settings saved';

  @override
  String get advancedNightStart => 'Night start hour';

  @override
  String get advancedNightEnd => 'Night end hour';

  @override
  String get advancedDailyOTThreshold => 'Daily OT threshold (h)';

  @override
  String get advancedWeeklyOTThreshold => 'Weekly OT threshold (h)';

  @override
  String get advancedHolidayOTThreshold => 'Holiday OT threshold (h)';

  @override
  String get advancedNightPremiumPct => 'Night premium (%)';

  @override
  String get advancedDailyOTPremiumPct => 'Daily OT premium (%)';

  @override
  String get advancedWeeklyOTPremiumPct => 'Weekly OT premium (%)';

  @override
  String get advancedHolidayBasePct => 'Holiday base premium (%)';

  @override
  String get advancedHolidayOverPct => 'Holiday over-threshold premium (%)';

  @override
  String get advancedWeeklyHolidayHours => 'Weekly paid holiday min hours';

  @override
  String get advancedWeeklyHolidayCap => 'Weekly paid holiday cap hours';

  @override
  String get advancedBusinessIncomePct => 'Business income withholding (%)';

  @override
  String get advancedSectionThresholds => 'Thresholds';

  @override
  String get advancedSectionPremiums => 'Premiums';

  @override
  String get advancedSectionWeeklyHoliday => 'Weekly Paid Holiday';

  @override
  String get advancedSectionDeductions => 'Deductions';

  @override
  String get backupTitle => 'Backup / Restore';

  @override
  String get backupExport => 'Create Backup File';

  @override
  String get backupImport => 'Restore from Backup';

  @override
  String backupExportSaved(String path) {
    return 'Saved to\n$path';
  }

  @override
  String backupExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get backupImportConfirmTitle => 'Restore from Backup';

  @override
  String get backupImportConfirmBody =>
      'All current data will be replaced with the backup contents. Continue?';

  @override
  String backupImportRestored(int jobs, int shifts) {
    return 'Restored: $jobs jobs, $shifts shifts';
  }

  @override
  String backupImportFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String backupIncompatibleVersion(int backup, int current) {
    return 'Backup schema version ($backup) does not match the current app ($current).';
  }

  @override
  String get backupSectionWhat => 'What is backed up';

  @override
  String get backupSectionWhatBody =>
      '• Jobs + options\n• All shifts (Main + mocks)\n• Mock plan metadata\n• App settings (theme, time format, active plan, etc.)\n\nNot included: undo stack (user action history)';

  @override
  String get backupLastBackupNever => 'No backup yet';

  @override
  String backupLastBackupAt(String at) {
    return 'Last backup: $at';
  }

  @override
  String get reportTitle => 'Pay Slip';

  @override
  String get reportViewPrefix => 'View:';

  @override
  String get reportNoMockThisMonth => '— no mocks this month';

  @override
  String get reportTabAll => 'All';

  @override
  String get reportAllJobsCombined => 'All jobs combined';

  @override
  String get reportNoRecords => 'No work records this month';

  @override
  String reportNoRecordsJob(String job) {
    return '$job — no work records this month';
  }

  @override
  String get reportPaymentItems => 'Payments';

  @override
  String get reportDeductionItems => 'Deductions';

  @override
  String get reportItemBasePay => 'Base pay';

  @override
  String get reportItemBasePayHint => 'Hours × wage';

  @override
  String get reportItemNight => 'Night premium';

  @override
  String get reportItemNightHint => '+50% for 22:00–06:00 work';

  @override
  String get reportItemDailyOT => 'Daily overtime';

  @override
  String get reportItemDailyOTHint => '+50% for hours over 8/day';

  @override
  String get reportItemWeeklyOT => 'Weekly overtime';

  @override
  String get reportItemWeeklyOTHint =>
      '+50% for hours over 40/week (no overlap with daily OT)';

  @override
  String get reportItemHolidayWithin => 'Holiday work (≤8h)';

  @override
  String get reportItemHolidayWithinHint => '+50% for first 8h of holiday work';

  @override
  String get reportItemHolidayOver => 'Holiday work (>8h)';

  @override
  String get reportItemHolidayOverHint => '+100% beyond 8h of holiday work';

  @override
  String get reportItemWeeklyHoliday => 'Weekly paid holiday';

  @override
  String get reportItemWeeklyHolidayHint =>
      '1 day pay when 15h+/wk with no absence';

  @override
  String get reportItemBusinessIncome => 'Business income withholding';

  @override
  String get reportItemBusinessIncomeHint => '3.3% (income + local tax)';

  @override
  String get reportItemFourInsurance => '4 Insurances';

  @override
  String get reportItemFourInsuranceHint =>
      'Pension + Health + Employment + LTC';

  @override
  String get reportGrossLabel => 'Gross';

  @override
  String get reportTotalDeductionLabel => 'Total Deductions';

  @override
  String get reportNetLabel => 'Net';

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
    return 'Worked ${h}h$m';
  }

  @override
  String reportWorkMinutesSuffix(int m) {
    return ' ${m}m';
  }

  @override
  String get reportFootnote =>
      '* Daily display sums base + night + daily OT + holiday only. Weekly OT, weekly holiday, and deductions apply monthly.';

  @override
  String reportCalcError(String error) {
    return 'Calculation error: $error';
  }

  @override
  String get yearMonthPickerTitle => 'Pick year / month';

  @override
  String get yearLabel => 'Year';

  @override
  String get monthLabel => 'Month';

  @override
  String get amSuffix => 'AM';

  @override
  String get pmSuffix => 'PM';

  @override
  String get deductionModeNone => 'No deduction';

  @override
  String get deductionModeBusiness => 'Business income 3.3%';

  @override
  String get deductionModeInsurance => '4 Insurances';
}
