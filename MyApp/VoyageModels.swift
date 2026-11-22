import SwiftUI

/// 可選擇的太空目的地
enum Destination: String, CaseIterable, Identifiable {
    case moon = "月球"
    case mars = "火星"
    case europa = "木衛二"
    case saturn = "土星環"

    var id: Self { self }

    var emoji: String {
        switch self {
        case .moon: "🌕"
        case .mars: "🔴"
        case .europa: "🧊"
        case .saturn: "🪐"
        }
    }

    /// 每人基本票價（萬元）
    var basePrice: Double {
        switch self {
        case .moon: 300
        case .mars: 1200
        case .europa: 3500
        case .saturn: 5000
        }
    }

    /// 單程航行天數
    var travelDays: Int {
        switch self {
        case .moon: 3
        case .mars: 210
        case .europa: 600
        case .saturn: 900
        }
    }

    /// 停留期間（可安排太空漫步）的天數
    var stayDays: Int {
        switch self {
        case .moon: 14
        case .mars: 30
        case .europa: 21
        case .saturn: 10
        }
    }

    var gradient: [Color] {
        switch self {
        case .moon: [.gray, .indigo]
        case .mars: [.orange, .red]
        case .europa: [.cyan, .blue]
        case .saturn: [.yellow, .brown]
        }
    }
}

/// 艙等
enum CabinClass: String, CaseIterable, Identifiable {
    case economy = "經濟艙"
    case business = "商務艙"
    case captain = "艦長套房"

    var id: Self { self }

    var multiplier: Double {
        switch self {
        case .economy: 1.0
        case .business: 1.6
        case .captain: 2.5
        }
    }
}

/// 太空船
enum Spaceship: String, CaseIterable, Identifiable {
    case falcon = "獵鷹號"
    case aurora = "極光號"
    case nebula = "星雲號"

    var id: Self { self }
}
