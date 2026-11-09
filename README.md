# HOONSTORE

junghoon1118이 만든 웹앱(PWA)을 모아 둔 웹 스토어입니다. 스토어 등록비 없이, 사용자가 브라우저에서 "홈 화면에 추가"로 앱을 설치하도록 안내합니다.

- 주소: https://junghoon1118.github.io/HOONSTORE/
- 오늘의 앱, 카테고리, 검색, 앱 상세(스크린샷·기능·정보), 기기별 설치 안내(안드로이드·아이폰·PC)
- 카카오톡 등 앱 안 브라우저에서 열었을 때 '다른 브라우저로 열기' 안내
- 스토어 자체도 PWA라서 설치할 수 있음
- 검색엔진용 정적 페이지(`apps/<id>/`, `privacy/`), `sitemap.xml`, 링크 미리 보기 이미지

## 새 앱 올리는 방법

1. 앱을 먼저 GitHub Pages에 배포하고 PWA로 만들어 둡니다. (예: `junghoon1118/SQLD` → `https://junghoon1118.github.io/SQLD/`)
2. `assets/apps/<앱아이디>/`에 `icon.png`(512×512)와 스크린샷(세로 375×812 비율 권장)을 넣습니다.
3. `apps.json`에 항목을 하나 추가합니다. 맨 앞 항목이 '오늘의 앱'으로 나옵니다.
4. `build.ps1`을 실행해 앱 페이지와 사이트맵을 다시 만듭니다.
   ```powershell
   powershell -ExecutionPolicy Bypass -File build.ps1
   ```
5. 커밋하고 push하면 1~2분 뒤 반영됩니다.

## 파일

| 파일 | 역할 |
| --- | --- |
| `apps.json` | 앱 목록 데이터 (여기만 고치면 됨) |
| `index.html` | 스토어 화면과 동작. `apps.json`을 불러와 그림. `<!--STATIC-->` 구역은 build가 채움 |
| `assets/store.css` | 스토어와 정적 페이지가 함께 쓰는 스타일 |
| `build.ps1` | `apps/<id>/index.html`, `privacy/index.html`, `sitemap.xml`, `index.html` 정적 목록 생성 |
| `manifest.webmanifest`, `sw.js` | 스토어 설치 정보와 오프라인 캐시. `sw.js`는 스토어 경로만 처리하고 `/SQLD/` 같은 다른 앱 경로는 건드리지 않음 |
| `make-icons.ps1`, `make-og.ps1` | 스토어 아이콘과 링크 미리 보기 이미지(`assets/og.png`) 생성 |

검색 등록용 `robots.txt`와 네이버·구글 소유 확인 파일은 사이트 최상위 저장소(`junghoon1118.github.io`)에 둡니다.
