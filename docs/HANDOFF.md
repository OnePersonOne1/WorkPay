# 월급이 / WorkPay — 작업 인수인계 문서

> 마지막 정리: 2026-06-09 · 버전 `1.0.0+1` · 브랜치 `main` (워킹트리 clean)
> 오랜만에 다시 시작할 때 **이 문서부터** 읽으세요.

---

## 0. 한 줄 요약 — 지금 어디까지 왔나
앱 개발·빌드·서명·아이콘·스토어 자료까지 **전부 완료**. Google Play **비공개 테스트(Closed testing) 단계에서 멈춤** — 신규 개인 계정의 "테스터 12명 + 14일" 요건 때문에 나중에 진행 예정. **남은 건 코드가 아니라 Play 콘솔 절차.**

---

## 1. 앱 개요
- **이름**: 월급이(한국어) / WorkPay(영어) — 로케일에 따라 자동 표시
- **무엇**: 광고 없는 **오프라인** 근무 일정 + 월급 계산 앱. 타깃 = 알바·근로장학 시급 노동자.
- **원칙(불변)**: 광고 없음, 추적/분석 없음, 네트워크 전송 없음, 계정 없음. 모든 데이터 기기 로컬.
- **플랫폼**: Android(주력, Play 출시 대상) + Windows(MSIX). iOS/macOS 폴더는 제거됨(SwiftPM 버그 회피 — Mac에서 `flutter create --platforms=ios,macos .`로 복구 가능).
- **패키지명(영구·변경불가)**: `io.github.onepersonone1.salary_app`
- **라이선스**: GPL-3.0-only (전 소스에 SPDX 헤더 + LICENSE). ⚠️ 배포 시 소스 공개 의무 → 공개 GitHub 저장소 권장(아직 안 함).

## 2. 기술 스택 / 환경
- **Flutter 3.44.0** @ `C:\src\flutter` (User PATH 등록됨). 도구 셸에선 PATH 미로딩 → 전체경로 `C:\src\flutter\bin\flutter.bat` 사용.
- Riverpod 3.x (Notifier 패턴), **drift**(SQLite, **스키마 v7**), 순수 Dart payroll 엔진, table_calendar, intl.
- 파일/공유: **file_selector + share_plus** (file_picker는 제거 — 아래 5번 참고).
- 패키징: **msix**, **flutter_launcher_icons**.
- Android toolchain: **AGP 9.0.1 / Gradle 9.1.0 / Kotlin 2.3.20** (최신/공격적). VS 2022 + C++ 워크로드(Windows 빌드), Android Studio(cmdline-tools 설치됨).

## 3. 빌드 방법 (커맨드)
> 본인 터미널은 `flutter`/`dart`로 충분. (도구 셸이면 `C:\src\flutter\bin\` 붙이기)

```powershell
# 의존성
flutter pub get

# 코드 생성 (drift 스키마/엔티티 바꿨을 때만)
dart run build_runner build

# l10n 재생성 (arb 문자열 바꿨을 때) — 보통 build 시 자동, 수동은:
flutter gen-l10n

# 정적 분석
flutter analyze

# Android — Play 업로드용 AAB (release 키 자동 서명)
flutter build appbundle --release
#  → build\app\outputs\bundle\release\app-release.aab

# Android — 폰 사이드로드용 APK (스크린샷 등)
flutter build apk --release
#  → build\app\outputs\flutter-apk\app-release.apk

# Windows — MSIX  ⚠️ 플래그 필수!
dart run msix:create --install-certificate false
#  → build\windows\x64\runner\Release\salary_app.msix
#  (--install-certificate false 없으면 인증서 설치 프롬프트에서 멈춰 미서명 실패)

# 아이콘 재생성 (assets/icon/*.png 교체 후)
dart run flutter_launcher_icons
```

## 4. 서명 / 키 (중요)
- **업로드 키스토어**: `C:/Users/Han/salary_app-upload.jks` (alias `upload`)
- **비밀번호**: `android/key.properties`에 저장 (**`.gitignore`됨, 커밋 안 됨**). 이 파일 없으면 빌드는 debug 키로 폴백.
- ⚠️ **`.jks` 파일과 비밀번호를 반드시 백업**. Play App Signing 사용 시 업로드 키는 분실해도 콘솔에서 재설정 가능하지만, 그래도 보관할 것.
- MSIX는 매 빌드 **자체서명 테스트 인증서**(CN=OnePersonOne1)로 서명 → 설치하려면 .msix 우클릭→속성→디지털 서명→인증서 보기→설치→"신뢰할 수 있는 사람".

## 5. 핵심 결정·주의사항 (왜 이렇게 했나)
- **file_picker 제거**: 11.0.2가 AGP9/Gradle9/내장Kotlin과 비호환(자기 buildscript에 AGP 8.5.1 고정 → 구 Kotlin 1.8.22 적용 → Gradle9에서 컴파일 실패). → `file_selector`(열기) + `share_plus`(Android 내보내기 공유)로 backup_page.dart 재작성. **데스크톱=getSaveLocation 저장 다이얼로그 / Android=임시파일+SharePlus 공유**로 분기.
- **앱 이름 현지화**: Android는 `res/values/strings.xml`=WorkPay(기본) / `res/values-ko/strings.xml`=월급이. Windows는 `/WX`(경고=에러) 때문에 한글 리터럴 불가 → ASCII "WorkPay". 인앱 제목은 l10n `appTitle`.
- **기본 로케일 = 시스템 따름**: `AppSettings.locale` 기본 `''` → `localeProvider`가 null → 기기 로케일 따름(영어권=영어). 설정에 시스템/한국어/English.
- **통화 단위(표시용)**: `AppSettings.currencyUnit`(기본 '원', 스키마 v6→v7 마이그레이션). 계산 무관, 금액 뒤 라벨만. 설정에서 자유 입력. 금액 l10n에서 '원' 분리 후 호출부에서 단위 주입. 캘린더 일급 셀의 '만' 압축은 원화 전용.
- **용어/톤**: 해요체 통일, 모의안→**가안**, 고고급→**전문가 설정**. 되돌리기 스냅샷은 행동형("시프트 추가").
- **아이콘**: 마스터 `assets/icon/app_icon.png`(정사각). 적응형은 `app_icon_foreground.png`(흰 배경 flood-fill 제거→투명, 안전영역 위해 ~60% 축소) + 적응형 배경 흰색 `#FFFFFF`.

## 6. 알려진 함정
- **`flutter test` 실패**: flutter_tester 좀비가 `sqlite3.dll`을 잠금. → `Get-Process flutter_tester,dart | Stop-Process -Force` 후 재시도. `flutter analyze`는 항상 정상.
- **KGP 경고(share_plus)**: "future Flutter will fail…" — 비치명적. share_plus가 Kotlin 2.2라 현재 빌드는 정상. file_picker와 달리 빌드를 막지 않음.
- **커밋 메시지에 큰따옴표**: PowerShell here-string(`@'...'@`)에 `"`가 있으면 파싱 깨짐 → 메시지를 파일로 쓰고 `git commit -F <file>` 사용.
- **git author**: 로컬 config `OnePersonOne1 / noreply@anthropic.com`로 설정됨.

## 7. 산출물 위치 (모두 최신, 1.0.0+1)
| 파일 | 용도 |
|---|---|
| `build/app/outputs/bundle/release/app-release.aab` | **Play 업로드** (서명됨) |
| `build/app/outputs/flutter-apk/app-release.apk` | 폰 사이드로드(스크린샷) |
| `build/windows/x64/runner/Release/salary_app.msix` | Windows 설치 패키지(자체서명) |
| `assets/icon/play_store_icon_512.png` | Play 앱 아이콘 512 |
| `assets/icon/play_feature_graphic_1024x500.png` | Play 피처 그래픽 |
> `build/`는 보통 .gitignore. 다시 빌드하면 재생성됨.

## 8. Play 출시 자료 (작성 완료, 위치)
- `docs/privacy-policy.md` — 개인정보처리방침(한/영, 이메일 채워짐). **공개 URL로 호스팅 필요**(GitHub Pages 등).
- `store/play-listing.md` — 앱 제목/짧은·전체 설명(한/영), 카테고리, 키워드.
  - 확정 제목(KO): **월급이 - 알바 근무표·월급 계산기** / (EN) WorkPay: Shift & Wage Calc
- `store/play-submission-checklist.md` — 데이터 보안(=수집 안 함), 콘텐츠 등급(=전체이용가), 광고(없음), 그래픽 규격, 출시 트랙, 체크리스트.
- 출시 노트 초안(첫 출시용)은 이 문서 11번 참고.

## 9. Play 콘솔 진행 상황 (여기서 멈춤)
- ✅ 앱 만들기, 패키지명 인식, 내부/비공개 테스트 트랙에 **AAB 업로드까지** 진행.
- ⛔ **막힌 지점: 비공개 테스트(Closed testing)** — 2023.11 이후 신규 개인 계정은 **테스터 12명 이상 + 14일 유지** 후에야 프로덕션 출시 신청 가능.
- 출시명/출시노트 입력 단계까지 안내받음.

## 10. 다음에 할 일 (체크리스트)
- [ ] 개인정보처리방침 `docs/privacy-policy.md`를 **공개 URL로 호스팅** → 콘솔에 입력
  - GitHub Pages: 저장소 Settings → Pages → Source `/docs` (단, 저장소 공개 필요)
- [ ] **스크린샷 4~6장** 촬영: APK를 폰에 설치 → 샘플 근무처/근무 입력 → 일정표/월급명세/근무처편집/주·일급/설정 캡처
- [ ] 피처 그래픽 업로드(`play_feature_graphic_1024x500.png`)
- [ ] **비공개 테스트: 테스터 12명+ 이메일 등록 → 옵트인 → 14일 유지**
- [ ] 14일 후 **프로덕션 출시 액세스 신청** → 검토 → 정식 출시
- [ ] (GPL 준수) 소스 공개 저장소 결정 — 공개 GitHub or 라이선스 변경
- [ ] (선택) Windows MSIX 배포 방식 — 자체서명 사이드로드 vs MS Store
- [ ] (선택) iOS — Mac에서 `flutter create --platforms=ios .` 후 빌드

## 11. 첫 출시 노트(복사용)
**한국어:**
```
월급이 첫 출시 🎉
· 캘린더로 근무 일정 관리 (근무처별 색상)
· 시급 기반 일급·주급·월급 자동 계산
· 여러 근무처, 반복 근무 일괄 추가, 백업/복원
· 광고 없음 · 오프라인 · 데이터 수집 없음
```
**영어:**
```
First release of WorkPay 🎉
· Calendar-based shift scheduling (color-coded jobs)
· Automatic daily/weekly/monthly pay from your hourly wage
· Multiple jobs, bulk recurring shifts, backup & restore
· No ads · offline · no data collection
```

## 12. 최근 주요 커밋
```
1fc5356 Play 피처 그래픽 + 스토어 제목 확정
eea4d2c Play 출시 자료(개인정보처리방침/등록정보/체크리스트)
5a9ce81 앱 아이콘 재교체(흰/초록) + 정사각·적응형 정리
b5dc12d 표시용 통화 단위 설정(스키마 v7)
c84879e UI 문구 다듬기(해요체/가안/전문가 설정)
6536a98 앱 이름 현지화 WorkPay/월급이 + 시스템 로케일 기본
d593b57 출시 설정: Android 서명 + Windows MSIX
894a91d file_picker → file_selector + share_plus (AGP9 호환)
1329379 UI 통합 + 다중 plan + l10n + 라이선스 헤더
```
