import SwiftUI

/// 依照目前條件即時更新的太空登機證
struct BoardingPassView: View {
    let name: String
    let avatar: Image?
    let suitColor: Color
    let destination: Destination
    let cabin: CabinClass
    let spaceship: Spaceship
    let launchDate: Date
    let passengers: Int
    let price: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("SPACE BOARDING PASS")
                    .font(.caption.bold())
                    .tracking(2)
                Spacer()
                Text(spaceship.rawValue)
                    .font(.caption.bold())
            }
            .foregroundStyle(.white.opacity(0.85))

            HStack(spacing: 16) {
                avatarView

                VStack(alignment: .leading, spacing: 4) {
                    Text(name.isEmpty ? "未命名旅客" : name)
                        .font(.title2.bold())
                    Text("\(cabin.rawValue)・\(passengers) 人")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
            }

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading) {
                    Text("FROM").font(.caption2)
                    Text("🌍 地球").font(.headline)
                }
                Spacer()
                Image(systemName: "airplane")
                    .font(.title3)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("TO").font(.caption2)
                    Text("\(destination.emoji) \(destination.rawValue)").font(.headline)
                }
            }

            Divider().overlay(.white.opacity(0.5))

            HStack {
                VStack(alignment: .leading) {
                    Text("LAUNCH").font(.caption2)
                    Text(launchDate, format: .dateTime.year().month().day())
                        .font(.subheadline.bold())
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("TOTAL").font(.caption2)
                    Text("\(price.formatted(.number.precision(.fractionLength(0)))) 萬")
                        .font(.subheadline.bold())
                        .contentTransition(.numericText())
                }
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .background(
            LinearGradient(colors: destination.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .animation(.default, value: price)
    }

    /// 大頭照外框使用太空衣顏色
    private var avatarView: some View {
        Group {
            if let avatar {
                avatar
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(suitColor.opacity(0.6))
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(.circle)
        .overlay(Circle().stroke(suitColor, lineWidth: 4))
    }
}
