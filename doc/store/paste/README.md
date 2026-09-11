# 貼り付け用のテキスト

Play Console の入力欄へそのまま貼るための平文。改行は CRLF。
`doc/store/listing-ja.md` と `listing-en.md` から機械的に抜き出したもので、内容は同じ。

| ファイル | 貼る先 |
| --- | --- |
| `short-ja.txt` | 簡単な説明 (日本語) |
| `description-ja.txt` | 詳しい説明 (日本語) |
| `short-en.txt` | Short description (English) |
| `description-en.txt` | Full description (English) |

メモ帳などで開き、Ctrl+A と Ctrl+C で全選択してから貼る。
チャットや Markdown 表示からコピーすると文字が落ちることがある。

## 作り直し

`listing-*.md` を直したら、次で再生成する。

```
python - <<'PY'
import io
def extract(md, heading):
    s = io.open(md, encoding='utf-8').read()
    i = s.index(heading)
    start = s.index('```', i) + 3
    start = s.index('\n', start) + 1
    return s[start:s.index('```', start)].rstrip('\n') + '\n'
for md, h, out in [
    ('doc/store/listing-ja.md', '## 詳しい説明', 'doc/store/paste/description-ja.txt'),
    ('doc/store/listing-en.md', '## Full description', 'doc/store/paste/description-en.txt'),
    ('doc/store/listing-ja.md', '## 簡単な説明', 'doc/store/paste/short-ja.txt'),
    ('doc/store/listing-en.md', '## Short description', 'doc/store/paste/short-en.txt'),
]:
    io.open(out, 'w', encoding='utf-8', newline='\r\n').write(extract(md, h))
PY
```
