# apps.json을 읽어 검색엔진용 정적 페이지를 만든다.
#  - apps/<id>/index.html : 앱마다 따로 있는 상세 페이지 (자바스크립트 없이도 내용이 보임)
#  - privacy/index.html   : 개인정보처리방침
#  - index.html의 <!--STATIC--> 구역 : 자바스크립트가 돌기 전에 보이는 앱 목록
#  - sitemap.xml          : 네이버·구글에 제출할 페이지 목록
# 사용법: powershell -ExecutionPolicy Bypass -File build.ps1
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$site = 'https://junghoon1118.github.io/HOONSTORE/'
$utf8 = New-Object Text.UTF8Encoding $false
$apps = [IO.File]::ReadAllText((Join-Path $root 'apps.json'), [Text.Encoding]::UTF8) | ConvertFrom-Json
function Enc([string]$t) { [System.Net.WebUtility]::HtmlEncode($t) }
function Save($rel, $text) {
  $p = Join-Path $root $rel
  New-Item -ItemType Directory -Force (Split-Path $p) | Out-Null
  [IO.File]::WriteAllText($p, $text, $utf8)
}

function Page($base, $title, $desc, $url, $image, $body) {
@"
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>$(Enc $title)</title>
<meta name="description" content="$(Enc $desc)">
<link rel="canonical" href="$url">
<meta property="og:type" content="website">
<meta property="og:site_name" content="HOONSTORE">
<meta property="og:title" content="$(Enc $title)">
<meta property="og:description" content="$(Enc $desc)">
<meta property="og:url" content="$url">
<meta property="og:image" content="$image">
<meta name="twitter:card" content="summary_large_image">
<meta name="theme-color" content="#14161b">
<link rel="icon" type="image/png" href="${base}icons/icon-192.png">
<link rel="manifest" href="${base}manifest.webmanifest">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Black+Han+Sans&family=IBM+Plex+Sans+KR:wght@400;500;600;700&display=swap">
<link rel="stylesheet" href="${base}assets/store.css">
</head>
<body>
<header class="top"><div class="wrap">
  <a class="logo" href="$base" aria-label="HOONSTORE 홈"><b>HOON</b><span>STORE</span></a>
</div></header>
<main class="wrap">
$body
</main>
<footer><div class="wrap">
  <span>HOONSTORE · junghoon1118이 만든 웹앱을 모아 둔 곳</span>
  <nav><a href="${base}privacy/">개인정보처리방침</a><a href="https://github.com/junghoon1118" target="_blank" rel="noopener">GitHub</a></nav>
</div></footer>
</body>
</html>
"@
}

# ── 앱 상세 페이지 ──
foreach ($a in $apps) {
  $b = '../../'
  $parts = @(); foreach ($sc in $a.screens) { $parts += ('<figure><img src="{0}{1}" alt="{2}" loading="lazy"><figcaption>{2}</figcaption></figure>' -f $b, $sc.src, (Enc $sc.cap)) }
  $shots = $parts -join "`n"
  $parts = @(); foreach ($t in $a.description) { $parts += ('<p>{0}</p>' -f (Enc $t)) }
  $desc = $parts -join "`n"
  $parts = @(); foreach ($t in $a.features) { $parts += ('<li>{0}</li>' -f (Enc $t)) }
  $feats = $parts -join "`n"
  $offline = if ($a.offline) { '지원' } else { '미지원' }
  $body = @"
<a class="back" href="$b">← 스토어로</a>
<section class="head">
  <img class="ico" src="$b$($a.icon)" alt="$(Enc $a.name) 아이콘" width="112" height="112">
  <div style="min-width:0">
    <h1>$(Enc $a.name)</h1>
    <p class="dev">$(Enc $a.developer)</p>
    <div class="acts"><a class="btn primary" href="$($a.url)">앱 열기</a><a class="btn" href="$b#app-$($a.id)">설치 도우미</a></div>
  </div>
</section>
<dl class="facts">
  <div><dt>가격</dt><dd>무료</dd></div>
  <div><dt>카테고리</dt><dd>$(Enc $a.category)</dd></div>
  <div><dt>오프라인</dt><dd>$offline</dd></div>
  <div><dt>기기</dt><dd>$(Enc $a.devices)</dd></div>
</dl>
<section class="sec"><div class="sec-h"><h2>미리 보기</h2></div><div class="shots-row">
$shots
</div></section>
<section class="sec"><div class="sec-h"><h2>앱 소개</h2></div><div class="prose">
<p><b>$(Enc $a.tagline)</b></p>
$desc
</div></section>
<section class="sec"><div class="sec-h"><h2>주요 기능</h2></div><ul class="feat">
$feats
</ul></section>
<section class="sec"><div class="sec-h"><h2>설치 방법</h2></div><div class="how">
  <div><b>안드로이드</b><p>Chrome에서 앱을 열고 오른쪽 위 ⋮ 메뉴의 '앱 설치' 또는 '홈 화면에 추가'를 누릅니다.</p></div>
  <div><b>아이폰 · 아이패드</b><p>Safari에서 앱을 열고 아래쪽 공유 버튼의 '홈 화면에 추가'를 누릅니다.</p></div>
  <div><b>PC</b><p>Chrome이나 Edge에서 앱을 열고 주소창 오른쪽의 설치 아이콘을 누릅니다.</p></div>
</div></section>
<section class="sec"><div class="sec-h"><h2>알아 두세요</h2></div><div class="note">$(Enc $a.notice)</div></section>
<section class="sec"><div class="sec-h"><h2>정보</h2></div>
<table class="info"><tbody>
<tr><th>개발자</th><td>$(Enc $a.developer)</td></tr>
<tr><th>업데이트</th><td>$(Enc $a.updated)</td></tr>
<tr><th>검색어</th><td>$(Enc $a.keywords)</td></tr>
<tr><th>개인정보</th><td>$(Enc $a.privacy)</td></tr>
<tr><th>주소</th><td><a href="$($a.url)">$(Enc $a.url)</a></td></tr>
</tbody></table></section>
"@
  $url = "${site}apps/$($a.id)/"
  $html = Page $b "$($a.name) · HOONSTORE" "$($a.tagline). $($a.description[0])" $url "${site}assets/og.png" $body
  Save "apps\$($a.id)\index.html" $html
}

# ── 개인정보처리방침 ──
$privacyBody = @"
<a class="back" href="../">← 스토어로</a>
<div class="prose">
<h1 style="font-size:26px;margin:0 0 6px">개인정보처리방침</h1>
<p class="meta">시행일 2026년 11월 9일</p>
<p>HOONSTORE와 HOONSTORE에 올라온 앱(이하 '앱')은 개인정보를 수집하지 않습니다.</p>
<p><b>수집하는 정보</b><br>없습니다. 회원가입, 로그인, 광고, 방문자 분석 도구를 쓰지 않습니다.</p>
<p><b>기기에 저장되는 정보</b><br>앱을 빠르게 열고 오프라인에서도 쓸 수 있도록 앱 파일을 브라우저 캐시에 저장합니다. 이 정보는 사용자의 기기 안에만 있으며, 브라우저 설정에서 사이트 데이터를 지우면 함께 삭제됩니다.</p>
<p><b>사용자가 입력하는 정보</b><br>앱 안에서 입력한 이름 같은 내용은 화면에 보여 주는 데만 쓰이고 서버로 보내지 않습니다.</p>
<p><b>외부 서비스</b><br>사이트는 GitHub Pages에서 제공되고, 글꼴은 Google Fonts에서 불러옵니다. 이 과정에서 각 서비스가 접속 기록(IP 주소 등)을 처리할 수 있으며, 이는 해당 서비스의 정책을 따릅니다.</p>
<p><b>문의</b><br><a href="https://github.com/junghoon1118">github.com/junghoon1118</a></p>
</div>
"@
Save 'privacy\index.html' (Page '../' '개인정보처리방침 · HOONSTORE' 'HOONSTORE와 HOONSTORE 앱의 개인정보처리방침' "${site}privacy/" "${site}assets/og.png" $privacyBody)

# ── index.html 정적 목록 ──
$parts = @(); foreach ($x in $apps) { $parts += ('<li><a href="apps/{0}/"><b>{1}</b></a> · {2} · {3}</li>' -f $x.id, (Enc $x.name), (Enc $x.category), (Enc $x.tagline)) }
$items = $parts -join "`n"
$static = @"
<!--STATIC-->
<section class="prose" style="padding-block:10px">
<h1 style="font-size:24px;margin:0 0 6px">HOONSTORE</h1>
<p>junghoon1118이 만든 웹앱을 모아 둔 스토어입니다. 설치비나 계정 없이, 브라우저에서 홈 화면에 추가해서 앱처럼 쓸 수 있습니다.</p>
<ul>
$items
</ul>
</section>
<!--/STATIC-->
"@
$ip = Join-Path $root 'index.html'
$idx = [IO.File]::ReadAllText($ip, [Text.Encoding]::UTF8)
$s = $idx.IndexOf('<!--STATIC-->'); $e = $idx.IndexOf('<!--/STATIC-->') + '<!--/STATIC-->'.Length
$idx = $idx.Substring(0, $s) + $static.Trim() + $idx.Substring($e)
[IO.File]::WriteAllText($ip, $idx, $utf8)

# ── sitemap.xml ──
$today = (Get-Date).ToString('yyyy-MM-dd')
$urls = @("<url><loc>$site</loc><lastmod>$today</lastmod></url>")
foreach ($x in $apps) { $urls += ('<url><loc>{0}apps/{1}/</loc><lastmod>{2}</lastmod></url>' -f $site, $x.id, $x.updated) }
$urls += "<url><loc>${site}privacy/</loc><lastmod>2026-11-09</lastmod></url>"
Save 'sitemap.xml' ("<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n" + ($urls -join "`n") + "`n</urlset>`n")

Write-Output ("built: " + $apps.Count + " app page(s), privacy, sitemap")
