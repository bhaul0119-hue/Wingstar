# Wingstar 프로그램 허브

> **WALK FOR ME, WALK FOR EARTH.**

Wingstar는 대학생 창업동아리에서 개발하는 **걷기 + 명상 + 플로깅 + ESG** 통합 앱 프로젝트입니다.

이 저장소는 하나의 Flutter 코드베이스에서 Android, iOS, Windows, macOS, Linux용 네이티브 앱을 만드는 소스와 공개 배포 자동화 설정을 담습니다.

## 핵심 구조
- **MIND** — 마음 체크와 걷기 명상
- **MOVE** — 걸음·시간·거리 기록
- **CARE** — 플로깅과 Green Mission
- **IMPACT** — ESG 활동 기록과 리워드 확장

## 걸음 감지 MVP
- 3~5초 가속도 센서 자동 보정
- magnitude 중앙값 baseline
- High/Low threshold peak 감지
- 300ms cooldown
- 흔들림 peak 1회당 1 step

## 지원 목표
Android APK/AAB · iPhone/iPad · Windows · macOS · Linux

브라우저 버전은 의도적으로 제외하며 설치 후에는 독립 네이티브 앱으로 실행합니다.

## 공개 다운로드
빌드가 완료되면 아래 Releases 페이지에서 기기별 설치 파일을 받을 수 있습니다.

- Android: `Wingstar-Android.apk`
- Windows: `Wingstar-Windows-x64.zip`
- macOS: `Wingstar-macOS.zip`
- Linux: `Wingstar-Linux-x64.tar.gz`
- iPhone/iPad: Apple 서명 및 TestFlight/App Store 배포 필요

Releases: https://github.com/bhaul0119-hue/Wingstar/releases

공개 릴리스는 **Actions → Wingstar Public Release**에서도 수동으로 다시 만들 수 있습니다.
