import SwiftUI
import PhotosUI

/// 星際旅行社：填寫太空旅程條件，即時計算票價並產生登機證
struct ContentView: View {
    // 旅客資料
    @State private var travelerName = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var avatar: Image?
    @State private var suitColor = Color.orange

    // 航程設定
    @State private var destination = Destination.mars
    @State private var cabin = CabinClass.economy
    @State private var spaceship = Spaceship.falcon
    @State private var launchDate = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    @State private var passengers = 1
    @State private var luggage = 20.0
    @State private var isRoundTrip = true

    // 加購項目
    @State private var spacewalkDays: Set<DateComponents> = []
    @State private var hasInsurance = true
    @State private var hasZeroGDining = false
    @State private var messageToEarth = ""

    // Alert 狀態
    @State private var showMissingName = false
    @State private var showConfirm = false
    @State private var showBooked = false
    @State private var boardingCode = ""

    private let freeLuggage = 20.0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    BoardingPassView(
                        name: travelerName,
                        avatar: avatar,
                        suitColor: suitColor,
                        destination: destination,
                        cabin: cabin,
                        spaceship: spaceship,
                        launchDate: launchDate,
                        passengers: passengers,
                        price: totalPrice
                    )
                    .listRowInsets(EdgeInsets())
                    .contextMenu {
                        Button("隨機目的地", systemImage: "dice") {
                            withAnimation { randomize() }
                        }
                        Button("升級為艦長套房", systemImage: "crown") {
                            withAnimation { cabin = .captain }
                        }
                        Button("重設所有條件", systemImage: "arrow.counterclockwise", role: .destructive) {
                            withAnimation { reset() }
                        }
                    }
                } footer: {
                    Text("長按登機證可以開啟更多選項")
                }

                travelerSection
                voyageSection
                extrasSection
                messageSection
                priceSection
            }
            .navigationTitle("🚀 星際旅行社")
            .safeAreaInset(edge: .bottom) {
                Button {
                    if travelerName.trimmingCharacters(in: .whitespaces).isEmpty {
                        showMissingName = true
                    } else {
                        showConfirm = true
                    }
                } label: {
                    Label("預訂太空旅程", systemImage: "airplane.departure")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.glassProminent)
                .tint(destination.gradient.last)
                .padding()
            }
            .alert("缺少旅客姓名", isPresented: $showMissingName) {
                Button("好") {}
            } message: {
                Text("太空總署需要知道你是誰，請先填寫姓名。")
            }
            .alert("確認預訂？", isPresented: $showConfirm) {
                Button("取消", role: .cancel) {}
                Button("確認升空") { book() }
            } message: {
                Text(confirmMessage)
            }
            .alert("預訂成功 🎉", isPresented: $showBooked) {
                Button("出發吧！") {}
            } message: {
                Text("\(travelerName)，你的登機代碼是 \(boardingCode)。\n請於發射前 3 天抵達太空港報到。")
            }
            .onChange(of: photoItem) {
                Task { await loadAvatar() }
            }
            .onChange(of: launchDate) {
                // 發射日改變後，清掉不在停留期間內的太空漫步日
                spacewalkDays = spacewalkDays.filter { stayRange.contains(date(from: $0)) }
            }
            .onChange(of: destination) {
                spacewalkDays = spacewalkDays.filter { stayRange.contains(date(from: $0)) }
            }
        }
    }

    // MARK: - 表單區塊

    private var travelerSection: some View {
        Section("旅客資料") {
            TextField("旅客姓名", text: $travelerName)
                .textContentType(.name)

            PhotosPicker(selection: $photoItem, matching: .images) {
                HStack {
                    Label("選擇登機證大頭照", systemImage: "person.crop.circle.badge.plus")
                    Spacer()
                    if let avatar {
                        avatar
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(.circle)
                    }
                }
            }

            ColorPicker("太空衣顏色", selection: $suitColor, supportsOpacity: false)
        }
    }

    private var voyageSection: some View {
        Section("航程設定") {
            Picker("目的地", selection: $destination) {
                ForEach(Destination.allCases) { place in
                    Text("\(place.emoji) \(place.rawValue)").tag(place)
                }
            }

            Picker("艙等", selection: $cabin) {
                ForEach(CabinClass.allCases) { cabin in
                    Text(cabin.rawValue).tag(cabin)
                }
            }
            .pickerStyle(.segmented)

            Picker("太空船", selection: $spaceship) {
                ForEach(Spaceship.allCases) { ship in
                    Text(ship.rawValue).tag(ship)
                }
            }
            .pickerStyle(.menu)

            DatePicker("發射日期", selection: $launchDate, in: Date.now..., displayedComponents: .date)

            Stepper("旅客人數：\(passengers) 人", value: $passengers, in: 1...8)

            VStack(alignment: .leading) {
                Text("每人行李：\(luggage, format: .number.precision(.fractionLength(0))) 公斤")
                Slider(value: $luggage, in: 5...60, step: 1) {
                    Text("行李重量")
                } minimumValueLabel: {
                    Text("5")
                } maximumValueLabel: {
                    Text("60")
                }
                Text("免費額度 20 公斤，超重每公斤加收 5 萬元")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Toggle("購買回程票", isOn: $isRoundTrip)
        }
    }

    private var extrasSection: some View {
        Section {
            Toggle("太空旅遊保險（+8%）", isOn: $hasInsurance)
            Toggle("無重力美食套餐（每人 30 萬）", isOn: $hasZeroGDining)

            VStack(alignment: .leading) {
                Text("太空漫步日（每天每人 50 萬）")
                MultiDatePicker("太空漫步日", selection: $spacewalkDays, in: stayRange)
                    .labelsHidden()
            }
        } header: {
            Text("加購項目")
        } footer: {
            Text("抵達\(destination.rawValue)後可停留 \(destination.stayDays) 天，已選 \(spacewalkDays.count) 天太空漫步。")
        }
    }

    private var messageSection: some View {
        Section("給地球的留言") {
            TextEditor(text: $messageToEarth)
                .frame(minHeight: 90)
                .overlay(alignment: .topLeading) {
                    if messageToEarth.isEmpty {
                        Text("寫下想對地球上的家人說的話…")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    private var priceSection: some View {
        Section("費用明細") {
            LabeledContent("基本票價", value: wan(ticketPrice))
            if overweightFee > 0 {
                LabeledContent("行李超重費", value: wan(overweightFee))
            }
            if hasZeroGDining {
                LabeledContent("無重力美食", value: wan(diningFee))
            }
            if spacewalkFee > 0 {
                LabeledContent("太空漫步", value: wan(spacewalkFee))
            }
            if hasInsurance {
                LabeledContent("旅遊保險", value: wan(insuranceFee))
            }
            LabeledContent("總計", value: wan(totalPrice))
                .fontWeight(.bold)
            LabeledContent("預計返回地球", value: returnDateText)
        }
    }

    // MARK: - 計算

    /// 抵達目的地後的停留期間
    private var stayRange: Range<Date> {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: destination.travelDays, to: launchDate) ?? launchDate)
        let end = calendar.date(byAdding: .day, value: destination.stayDays, to: start) ?? start
        // MultiDatePicker 會把結束日當天也列為可選，往前退一秒讓可選天數剛好等於停留天數
        return start..<end.addingTimeInterval(-1)
    }

    private var ticketPrice: Double {
        destination.basePrice * cabin.multiplier * Double(passengers) * (isRoundTrip ? 1.8 : 1)
    }

    private var overweightFee: Double {
        max(0, luggage - freeLuggage) * 5 * Double(passengers)
    }

    private var diningFee: Double {
        hasZeroGDining ? 30 * Double(passengers) : 0
    }

    private var spacewalkFee: Double {
        Double(spacewalkDays.count) * 50 * Double(passengers)
    }

    private var insuranceFee: Double {
        hasInsurance ? (ticketPrice + overweightFee + diningFee + spacewalkFee) * 0.08 : 0
    }

    private var totalPrice: Double {
        ticketPrice + overweightFee + diningFee + spacewalkFee + insuranceFee
    }

    private var returnDateText: String {
        guard isRoundTrip else { return "單程，不回來了 👋" }
        let days = destination.travelDays * 2 + destination.stayDays
        let date = Calendar.current.date(byAdding: .day, value: days, to: launchDate) ?? launchDate
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private var confirmMessage: String {
        """
        \(destination.emoji) \(destination.rawValue)・\(cabin.rawValue)・\(passengers) 人
        搭乘 \(spaceship.rawValue)，\(launchDate.formatted(date: .abbreviated, time: .omitted)) 發射
        總計 \(wan(totalPrice))
        """
    }

    private func wan(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(0)))) 萬元"
    }

    private func date(from components: DateComponents) -> Date {
        Calendar.current.date(from: components) ?? .distantPast
    }

    // MARK: - 動作

    private func loadAvatar() async {
        guard let photoItem,
              let data = try? await photoItem.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }
        avatar = Image(uiImage: uiImage)
    }

    private func book() {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let prefix = String((0..<2).compactMap { _ in letters.randomElement() })
        boardingCode = "\(prefix)-\(Int.random(in: 1000...9999))"
        showBooked = true
    }

    private func randomize() {
        destination = Destination.allCases.randomElement() ?? .moon
        cabin = CabinClass.allCases.randomElement() ?? .economy
        spaceship = Spaceship.allCases.randomElement() ?? .falcon
        passengers = Int.random(in: 1...4)
        luggage = Double(Int.random(in: 10...40))
        suitColor = Color(hue: .random(in: 0...1), saturation: 0.8, brightness: 0.9)
    }

    private func reset() {
        travelerName = ""
        photoItem = nil
        avatar = nil
        suitColor = .orange
        destination = .mars
        cabin = .economy
        spaceship = .falcon
        launchDate = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
        passengers = 1
        luggage = 20
        isRoundTrip = true
        spacewalkDays = []
        hasInsurance = true
        hasZeroGDining = false
        messageToEarth = ""
    }
}

#Preview {
    ContentView()
}
