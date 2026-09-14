import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                MysticBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        // Server Connection Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "server.rack")
                                    .foregroundColor(.yellow)
                                Text("LangGraph バックエンド接続")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text("ローカルで起動している langgraph_sample の FastAPI サーバーURLを指定します。")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))

                            VStack(alignment: .leading, spacing: 8) {
                                Text("APIベースURL")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))

                                TextField("http://127.0.0.1:8000", text: $viewModel.apiBaseURL)
                                    .keyboardType(.URL)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding()
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            }

                            HStack(spacing: 12) {
                                Button(action: {
                                    Task {
                                        await viewModel.checkConnection()
                                    }
                                }) {
                                    HStack {
                                        if viewModel.isChecking {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "network")
                                        }
                                        Text("接続テスト")
                                    }
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.purple)
                                    .cornerRadius(10)
                                }
                                .disabled(viewModel.isChecking)

                                Button(action: {
                                    viewModel.resetURL()
                                }) {
                                    Text("初期値に戻す")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Color.white.opacity(0.08))
                                        .cornerRadius(10)
                                }
                            }

                            // Connection Status Result
                            if let health = viewModel.healthStatus {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(health)
                                        .font(.system(size: 12))
                                        .foregroundColor(.green)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            } else if let err = viewModel.errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(err)
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Backend Guide Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("バックエンドサーバーの起動方法")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text("ターミナルで以下のコマンドを実行して FastAPI サーバーを起動してください：")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))

                            VStack(alignment: .leading, spacing: 6) {
                                Text("cd /Users/masuda/Projects/langgraph_sample")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.yellow.opacity(0.9))
                                Text("uv run uvicorn src.api.app:app --host 127.0.0.1 --port 8000")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.yellow.opacity(0.9))
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(10)

                            Text("※ 実機iOS端末から接続する場合は、--host 0.0.0.0 で起動し、MacのローカルIPアドレス（例: http://192.168.x.x:8000）を上記URLに設定してください。")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)

                        // App Info
                        VStack(spacing: 6) {
                            Text("Tubeworm - 星詠みAI 西洋占星術アプリ")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                            Text("Version 1.0.0 (Powered by LangGraph & Swift)")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
