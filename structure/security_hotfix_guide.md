# 보안 핫픽스 가이드 (서비스 계정/환경변수)

프로덕션 보안을 위해 즉시 수행해야 할 작업과 권장 구성입니다.

## 1) Firebase 서비스 계정 키 유출 대응
- 유출 파일: `sherpa-app-production-firebase-adminsdk-fbsvc-778f28a3f1.json`

### 1-1. GCP 콘솔에서 키 폐기/재발급
1) IAM & Admin → Service Accounts → 해당 서비스 계정 선택.
2) Keys 탭 → 유출된 키 `Disable` → `Delete`.
3) 필요한 경우 새 키 발급(가능하면 키 발급 제한/Workload Identity 사용 고려).
4) 서비스 계정 권한 최소화(원치 않는 리소스 권한 제거).

### 1-2. Git 이력에서 완전 제거
- BFG Repo-Cleaner 예시:
```
java -jar bfg.jar --delete-files sherpa-app-production-firebase-adminsdk-fbsvc-*.json
# 또는 키 패턴 마스킹
java -jar bfg.jar --replace-text banned-patterns.txt

git reflog expire --expire=now --all && \
  git gc --prune=now --aggressive
# 강제 푸시(공유 리포라면 팀 공지 필수)
# git push --force
```
- 대안: `git filter-repo` 사용.

## 2) 환경변수/키 주입 정책
- 운영 빌드에서 `.env`를 앱에 포함하지 않기(클라이언트 탈취 리스크).
- 권장 플로우:
  - 개발: `.env.development`를 `flutter_dotenv`로 로컬에서만 로드.
  - 운영: CI에서 `--dart-define`로 필요한 값만 주입. 예)
```
flutter build apk \
  --dart-define=OPENAI_API_KEY=@secure_ref@ \
  --dart-define=GEMINI_API_KEY=@secure_ref@
```
- 디버그 전용 로그/스위치로 `ApiConfig.debugApiKeyStatus()` 호출 여부 제어.

## 3) 시크릿 재발급 이후 점검
- 키 회전 후 다음 확인:
  - 서버/클라우드 함수/백엔드에서 새 키로 정상 동작.
  - 모바일/웹 클라이언트에는 비밀이 포함되지 않는지(번들 스캔/리버스 확인).
  - CI에 비밀 스캐너(`gitleaks`) 추가:
```
gitleaks detect --redact
```

## 4) 재발 방지 조치
- `.gitignore`에 서비스 계정/시크릿 패턴 추가 (예: `*.service-account.json`, `*.secret.json`).
- pre-commit/pre-push 훅으로 특정 패턴 커밋 차단.
- 팀 내 보안 운영 수칙 문서화(누가/언제/어디서 키를 발급·보관하는지).

필요 시 위 작업을 자동화하는 스크립트와 CI 파이프라인 템플릿을 제공할 수 있습니다.

