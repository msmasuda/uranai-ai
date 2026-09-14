# Tubeworm - 星詠みAI 西洋占星術 iOSアプリ 🔮✨

LangGraph 自律型エージェント（FastAPI + Ollama/PostgreSQL）をバックエンドにした、SwiftUIによる西洋占星術・生年月日パーソナライズ運勢鑑定 iOS アプリケーションです。

---

## 🌟 特徴

- **西洋占星術エンジン (Zodiac Engine)**:
  - 入力された生年月日から12星座（太陽星座）、エレメント（火・地・風・水）、守護星（ルーラー）、キーワードを自動算出。
- **LangGraph 自律型エージェント連携**:
  - バックエンド (`langgraph_sample` / FastAPI) の `/v1/conversations` および `/v1/conversations/{id}/messages/stream` (SSE) と連携。
  - AIエージェントが日時取得ツール (`get_current_datetime`) などを自律的に活用し、本日の星回りに即した臨場感のある鑑定文を生成。
- **リアルタイム SSE ストリーミング表示**:
  - `URLSession.AsyncBytes` を活用した Server-Sent Events パーサーにより、鑑定テキストのタイピング風逐次描画と、エージェントのツール実行ログ（「🔭 天体運行日時を観測中...」）をリアルタイムにカード表示。
- **リッチな鑑定結果 & 占い師アストリアとの対話**:
  - 運勢指数スコアゲージ、星の神託（キャッチコピー）、4大ラッキー要素（カラー・アイテム・ナンバー・アクション）、運気のバイオリズム（恋愛・仕事・金運）を構造化して視覚化。
  - 鑑定結果について気になる点をさらに質問できる、AI占い師とのフォローアップチャット機能を搭載。
- **鑑定の記憶（履歴管理）**:
  - 過去に行った鑑定結果をローカルに自動保存し、いつでも再確認・振り返りが可能。
- **接続設定 & ヘルスチェック**:
  - バックエンドサーバーのURL設定変更（シミュレータ用 `127.0.0.1` または実機用のローカルIP）と、`/health`・`/ready` による即時接続テスト機能。

---

## 📁 ディレクトリ構成

```
tubeworm/
├── project.yml                 # XcodeGen プロジェクト定義
├── Tubeworm.xcodeproj          # 生成された Xcode プロジェクト
├── README.md                   # 本ドキュメント
├── docs/                       # 設計・仕様・検証ドキュメント群
│   ├── README.md               # ドキュメント目次
│   ├── architecture.md         # アーキテクチャ設計・MVVM・シーケンス
│   ├── api_integration.md      # FastAPI / SSE 通信仕様
│   ├── plan.md                 # 実装計画書
│   ├── walkthrough.md          # 成果報告・検証結果
│   └── images/                 # スクリーンショット画像
├── Tubeworm/
│   ├── App/
│   │   └── TubewormApp.swift   # アプリエントリーポイント (@main)
│   ├── Models/
│   │   ├── ZodiacSign.swift    # 12星座の定義・エレメント・生年月日判定
│   │   ├── UserProfile.swift   # ユーザープロフィール・関心テーマ
│   │   ├── FortuneCategory.swift # 鑑定テーマ（総合・恋愛・仕事・金運等）
│   │   ├── FortuneResult.swift # 鑑定結果・スコア・ラッキー要素モデル
│   │   └── APIEvent.swift      # FastAPI / LangGraph SSE イベントモデル
│   ├── Services/
│   │   ├── LangGraphAPIClient.swift # HTTP / SSE ストリーミング通信クライアント
│   │   ├── FortunePromptBuilder.swift # 西洋占星術エージェント用プロンプト生成
│   │   ├── FortuneParser.swift # LLM出力からの構造化データ抽出
│   │   ├── FortuneStorageService.swift # 鑑定履歴・プロフィールの永続化
│   │   └── SettingsService.swift # API接続先設定の管理
│   ├── ViewModels/
│   │   ├── FortuneViewModel.swift # 鑑定フロー・SSE購読・チャット状態管理
│   │   ├── HistoryViewModel.swift # 過去の鑑定履歴一覧管理
│   │   └── SettingsViewModel.swift # サーバー接続テスト・設定管理
│   ├── Views/
│   │   ├── MainTabView.swift   # 3タブ構成（鑑定・記憶・設定）
│   │   ├── Components/
│   │   │   └── MysticBackground.swift # 星空グラデーション背景
│   │   ├── Fortune/
│   │   │   ├── FortuneHomeView.swift # 状態別画面切り替えコンテナ
│   │   │   ├── FortuneInputView.swift # 生年月日・テーマ入力画面
│   │   │   ├── FortuneReadingView.swift # 鑑定中ストリーミング演出画面
│   │   │   ├── FortuneResultView.swift # 鑑定結果・ラッキー要素・チャット画面
│   │   │   └── ZodiacBadgeView.swift # 星座シンボルバッジ
│   │   ├── History/
│   │   │   └── HistoryView.swift # 過去の鑑定履歴一覧画面
│   │   └── Settings/
│   │       └── SettingsView.swift # サーバー接続設定画面
│   └── Resources/
│       └── Info.plist          # ATS設定（ローカルHTTP通信許可）
└── TubewormTests/
    └── TubewormTests.swift     # 星座判定、プロンプト生成、パース、ライブAPI接続テスト
```

---

## 🚀 起動・開発手順

### 1. 前提環境
- macOS Sonoma / Sequoia 以降
- Xcode 15 / 16 / 27 (Swift 6)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- Python バックエンド: `/Users/masuda/Projects/langgraph_sample`

### 2. バックエンドサーバーの起動
```bash
cd /Users/masuda/Projects/langgraph_sample
uv run uvicorn src.api.app:app --host 127.0.0.1 --port 8000
```
- API仕様確認: `http://127.0.0.1:8000/docs`
- ヘルスチェック: `http://127.0.0.1:8000/health`

### 3. プロジェクトのビルド & 実行

```bash
cd /Users/masuda/Projects/uranai-ai/tubeworm

# Xcodeプロジェクトの生成
xcodegen generate

# ビルド実行
xcodebuild -project Tubeworm.xcodeproj -scheme Tubeworm -destination 'generic/platform=iOS Simulator' build

# 起動中シミュレータへのインストール & 起動
xcrun simctl install booted /Users/masuda/Library/Developer/Xcode/DerivedData/Tubeworm-*/Build/Products/Debug-iphonesimulator/Tubeworm.app
xcrun simctl launch booted com.uranai.tubeworm
```

### 4. テストの実行
```bash
xcodebuild test -project Tubeworm.xcodeproj -scheme Tubeworm -destination 'platform=iOS Simulator,name=iPhone 17'
```
