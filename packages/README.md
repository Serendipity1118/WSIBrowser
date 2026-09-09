# packages/

| ディレクトリ | 内容 |
|---|---|
| `wsi_sdk/` | SDK コア (JS)。Chrome 版 WSI と WSI Browser で共有し、アダプタごとに結合する |
| `wsi_plugin_tools/` | プラグイン開発 CLI `wsi-plugin` (create / validate / build / pack / dev-serve / publish) |

両方とも npm workspace。ルートで `npm install` すると依存が入る。
