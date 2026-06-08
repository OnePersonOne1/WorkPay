// SPDX-License-Identifier: GPL-3.0-only
import '../domain/entity/business_size.dart';
import '../domain/entity/deduction_mode.dart';
import '../domain/entity/income_type.dart';
import 'generated/app_localizations.dart';

/// enum 값에 대한 localized label 헬퍼.
/// enum 자체에서 분리해 i18n로 일원화.

String incomeTypeLabel(IncomeType v, AppLocalizations l) {
  return switch (v) {
    IncomeType.partTime => l.incomePartTime,
    IncomeType.workStudy => l.incomeWorkStudy,
  };
}

String businessSizeLabel(BusinessSize v, AppLocalizations l) {
  return switch (v) {
    BusinessSize.under5 => l.businessUnder5,
    BusinessSize.fiveOrMore => l.businessFiveOrMore,
  };
}

String deductionModeLabel(DeductionMode v, AppLocalizations l) {
  return switch (v) {
    DeductionMode.none => l.deductionNone,
    DeductionMode.businessIncome3_3 => l.deductionBusiness33,
    DeductionMode.fourInsurance => l.deductionFourInsurance,
  };
}
