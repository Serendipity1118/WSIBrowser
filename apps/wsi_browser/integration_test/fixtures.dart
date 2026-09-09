// Fixture pages, copied from packages/wsi_sdk/test/fixtures (keep in sync).

const String kArticleHtml = r'''
<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>WSI Fixture Article</title>
<style>body{font-family:sans-serif;max-width:720px;margin:40px auto;line-height:1.6}</style>
</head>
<body>
<h1 id="top">WSI 契約テスト用の記事</h1>
<p id="intro">これは <strong>Web System Injection</strong> の契約テストで使う固定ページです。日本語の<span id="jp-word">辞書</span>を選択して検索できます。</p>
<h2 id="sec-1">第 1 章 ストレージ</h2>
<p id="para-1">ハイライトしたいテキストはここにあります。ハイライト対象の文章。</p>
<h3 id="sec-1-1">1.1 永続化</h3>
<p>ページを再読み込みしてもハイライトは残ります。</p>
<h2 id="sec-2">第 2 章 リンク</h2>
<p>短縮 URL: <a id="short-link" href="https://bit.ly/wsi-fixture">bit.ly/wsi-fixture</a> と通常リンク <a id="normal-link" href="https://example.com/normal">example.com/normal</a></p>
<h2 id="sec-3">第 3 章 Markdown</h2>
<p id="md-source">選択して <em>Markdown</em> にコピーする段落です。</p>
</body>
</html>
''';

const String kDijaw40Html = r'''
<!doctype html>
<html lang="ja">
<head><meta charset="utf-8"><title>DijAW40 fixture</title></head>
<body>
<div id="Pane1">
  <div id="DijAW40100201KomokuListUserControl">
    <div class="ControlHeader"><span>明細登録可能商談一覧</span></div>
    <div id="DijAW40100201KomokuListUserControlGrid"></div>
  </div>
</div>
</body>
</html>
''';
