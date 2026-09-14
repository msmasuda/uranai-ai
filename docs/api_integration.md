# API 連携仕様書 (API Integration Specification)

本ドキュメントでは、iOS クライアント（Tubeworm）とバックエンド（`langgraph_sample` / FastAPI）間の HTTP / Server-Sent Events (SSE) 通信仕様について説明します。

---

## 1. 接続先情報

- **デフォルトURL**: `http://127.0.0.1:8000` (iOSシミュレータ環境)
- **実機検証時**: `http://<MacのローカルIP>:8000`
- **認証**: ローカル環境では `AUTH_MODE=disabled`

---

## 2. エンドポイント一覧

| メソッド | パス | 用途 |
|---|---|---|
| GET | `/health` | APIサーバーの生存確認 |
| GET | `/ready` | OllamaおよびDB（PostgreSQL）の準備確認 |
| POST | `/v1/conversations` | 鑑定セッション（会話ID）の作成 |
| POST | `/v1/conversations/{id}/messages/stream` | 鑑定リクエスト（SSEストリーミング） |
| POST | `/v1/conversations/{id}/messages` | 追加相談（JSON同期レスポンス） |

---

## 3. リクエスト / レスポンス詳細

### 3.1 ヘルスチェック (`GET /health`)
- **Response**:
```json
{
  "status": "ok"
}
```

### 3.2 レディネスチェック (`GET /ready`)
- **Response**:
```json
{
  "status": "ready",
  "ollama": true,
  "database": true
}
```

### 3.3 会話セッション作成 (`POST /v1/conversations`)
- **Headers**: `Content-Type: application/json`
- **Request Body**:
```json
{
  "title": "西洋占星術鑑定: 旅人 (山羊座)"
}
```
- **Response**:
```json
{
  "id": "c6204c3f-7f72-4680-bc42-fca12f9b233a",
  "title": "西洋占星術鑑定: 旅人 (山羊座)",
  "status": "active",
  "created_at": "2026-09-14T07:55:45.334469Z"
}
```

### 3.4 鑑定メッセージ送信 (SSEストリーミング) (`POST /v1/conversations/{id}/messages/stream`)
- **Headers**:
  - `Content-Type: application/json`
  - `Accept: text/event-stream`
  - `Idempotency-Key: <UUID>`
  - `X-Request-ID: <UUID>`
- **Request Body**:
```json
{
  "content": "【西洋占星術 運勢鑑定依頼】\nお名前: 旅人\n太陽星座: 山羊座..."
}
```

#### SSE イベント仕様
| イベント名 (`event:`) | ペイロード概要 (`data:`) | アプリ側の対応 |
|---|---|---|
| `message.started` | `{"message_id": "...", "conversation_id": "..."}` | 処理開始インジケーター表示 |
| `assistant.delta` | `{"message_id": "...", "delta": "今日..."}` | 鑑定文の逐次追記・描画 |
| `tool.started` | `{"name": "get_current_datetime", "args": {...}}` | 観測中ログカード表示（「🔭 天体運行日時を観測中...」） |
| `tool.completed` | `{"name": "get_current_datetime", "output": "..."}` | 観測完了の表示更新 |
| `message.completed` | `{"content": "..."}` | 最終テキスト受領・パース・完了画面へ遷移 |
| `message.failed` | `{"detail": "..."}` | エラーハンドリング・再試行誘導 |
| `: stream-heartbeat` | SSEコメント行 | コネクション維持用（クライアント側でスキップ） |

### 3.5 追加相談チャット (`POST /v1/conversations/{id}/messages`)
- **Headers**:
  - `Content-Type: application/json`
  - `Idempotency-Key: <UUID>`
  - `X-Request-ID: <UUID>`
- **Request Body**:
```json
{
  "content": "【相談者からの追加の質問】\n今日気をつけるべき行動はありますか？"
}
```
- **Response**:
```json
{
  "id": "e83893da-1234-4567-890a-bcdef0123456",
  "conversation_id": "c6204c3f-7f72-4680-bc42-fca12f9b233a",
  "content": "アストリアです。今日の山羊座の方は...",
  "tool_events": []
}
```
