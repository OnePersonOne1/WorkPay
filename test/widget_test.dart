import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_app/app.dart';

void main() {
  testWidgets('앱이 3탭 하단 네비게이션과 함께 렌더링된다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SalaryApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('일정표'), findsWidgets);
    expect(find.text('월급'), findsWidgets);
    expect(find.text('설정'), findsWidgets);
  });
}
