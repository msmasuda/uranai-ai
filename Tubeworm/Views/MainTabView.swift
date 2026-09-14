import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: Int = 0

    public init() {
        // TabBar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.04, blue: 0.15, alpha: 0.95)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            FortuneHomeView()
                .tabItem {
                    Label("鑑定", systemImage: "sparkles")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("記憶", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.yellow)
    }
}
