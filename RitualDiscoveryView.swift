import AVFoundation
import Combine
import SwiftUI
import Vision

// MARK: - RitualDiscoveryView (Home Tab)

struct RitualDiscoveryView: View {
    enum HomeSheet: Identifiable {
        case settings
        case notifications
        
        var id: String {
            switch self {
            case .settings: return "settings"
            case .notifications: return "notifications"
            }
        }
    }

    @State private var isShowingScanner = false
    @State private var activeSheet: HomeSheet? = nil
    @EnvironmentObject var store: UserDataStore
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"


    var ritualsToday: [AnnualRitual] {
        let calendar = Calendar(identifier: .gregorian)
        let todayComps = calendar.dateComponents([.month, .day], from: Date())
        guard let month = todayComps.month, let day = todayComps.day else { return [] }
        return AnnualRitualDatabase.rituals.filter { $0.approximateMonth == month && $0.approximateDay == day }
    }

    var homeItems: [RitualInfo] {
        let keys = ["diya", "kalash", "agarbatti", "camphor", "coconut", "flowers"]
        return keys.compactMap { RitualDatabase.allRituals[$0] }
    }

    var hasRitualsToday: Bool {
        let calendar = Calendar(identifier: .gregorian)
        let todayComps = calendar.dateComponents([.month, .day], from: Date())
        guard let month = todayComps.month, let day = todayComps.day else { return false }
        return AnnualRitualDatabase.rituals.contains { $0.approximateMonth == month && $0.approximateDay == day }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppTheme.pageBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        HeaderSection()

                        // Hero scanner card
                        FeaturedHeroCard { isShowingScanner = true }
                            .padding(.horizontal)

                        // MARK: - Saved section
                        if !store.favoriteRituals.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                AppSectionHeader(
                                    title: "Saved Rituals",
                                    count: store.favoriteRituals.count
                                )
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppTheme.gridSpacing) {
                                        ForEach(store.favoriteRituals) { ritual in
                                            NavigationLink(destination: DetailView(ritual: ritual))
                                            {
                                                AppRitualCardFixed(
                                                    name: LocalizedStringKey(ritual.name), image: ritual.image)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, AppTheme.sectionPadding)
                                }
                            }
                        }

                        // MARK: - Most common rituals
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                AppSectionHeader(title: "Common Ritual Objects")
                                Spacer()
                                NavigationLink(destination: FullExploreView()) {
                                    Text("See All")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(AppTheme.accent)
                                }
                                .padding(.trailing, AppTheme.sectionPadding)
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppTheme.gridSpacing) {
                                    ForEach(homeItems.prefix(3)) { ritual in
                                        NavigationLink(destination: DetailView(ritual: ritual)) {
                                            AppRitualCardFixed(
                                                name: LocalizedStringKey(ritual.name), image: ritual.image)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, AppTheme.sectionPadding)
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppTheme.gridSpacing) {
                                    ForEach(homeItems.suffix(3)) { ritual in
                                        NavigationLink(destination: DetailView(ritual: ritual)) {
                                            AppRitualCardFixed(
                                                name: LocalizedStringKey(ritual.name), image: ritual.image)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, AppTheme.sectionPadding)
                            }
                        }

                        Spacer(minLength: 100)
                    }
                }
                .navigationTitle("Pavitra")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            // Notification Icon
                            Button {
                                activeSheet = .notifications
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(AppTheme.accent)

                                    if hasRitualsToday {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 2, y: -2)
                                    }
                                }
                            }
                            .accessibilityLabel(hasRitualsToday ? "Notifications, new rituals today" : "Notifications")

                            // Settings Icon
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                activeSheet = .settings
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(AppTheme.accent)
                            }
                            .accessibilityLabel("Settings")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingScanner) {
                ScannerView()
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .settings:
                    SettingsSheetView(selectedLanguage: $selectedLanguage)
                case .notifications:
                    NotificationView()
                }
            }
        }
    }

}

// MARK: - Settings Sheet

struct SettingsSheetView: View {

    @Binding var selectedLanguage: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private let languages: [(code: String, name: String, native: String, flag: String)] = [
        ("en", "English", "English", "🇬🇧"),
        ("hi", "Hindi",   "हिन्दी",  "🇮🇳"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // ── App icon area ──────────────────────────────
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppTheme.accent,
                                                AppTheme.accent.opacity(0.6)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 72, height: 72)
                                    .shadow(color: AppTheme.accent.opacity(0.4), radius: 12, x: 0, y: 6)
                                Text("🪔")
                                    .font(.system(size: 36))
                            }
                            Text("Pavitra")
                                .font(.system(.title3, design: .serif, weight: .bold))
                                .foregroundStyle(AppTheme.primaryText)
                            Text("Sacred Ritual Guide")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        // ── Language section ───────────────────────────
                        settingsSection(title: "Language", icon: "globe") {
                            ForEach(Array(languages.enumerated()), id: \.offset) { idx, lang in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedLanguage = lang.code
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    HStack(spacing: 14) {
                                        Text(lang.flag)
                                            .font(.title3)
                                            .frame(width: 32)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(lang.name)
                                                .font(.system(.subheadline, design: .serif, weight: .semibold))
                                                .foregroundStyle(AppTheme.primaryText)
                                            Text(lang.native)
                                                .font(.caption)
                                                .foregroundStyle(AppTheme.secondaryText)
                                        }
                                        Spacer()
                                        if selectedLanguage == lang.code {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(AppTheme.accent)
                                                .font(.system(size: 20))
                                                .transition(.scale.combined(with: .opacity))
                                        } else {
                                            Circle()
                                                .strokeBorder(AppTheme.accent.opacity(0.25), lineWidth: 1.5)
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 13)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                if idx < languages.count - 1 {
                                    Divider()
                                        .padding(.leading, 62)
                                        .padding(.trailing, 16)
                                }
                            }
                        }

                        // ── App info section ───────────────────────────
                        settingsSection(title: "About", icon: "info.circle") {
                            infoRow(label: "Version", value: "1.0")
                            Divider().padding(.leading, 16).padding(.trailing, 16)
                            infoRow(label: "Content", value: "Vedic & Puranic Texts")
                            Divider().padding(.leading, 16).padding(.trailing, 16)
                            infoRow(label: "Ritual Objects", value: "\(RitualDatabase.allRituals.count)")
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }

    // ── Helpers ────────────────────────────────────────────────────────────

    @ViewBuilder
    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.system(.caption, design: .serif, weight: .bold))
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.leading, 4)
                .textCase(.uppercase)
                .tracking(0.8)

            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.accent.opacity(0.15), lineWidth: 1)
            )
            .shadow(
                color: .black.opacity(colorScheme == .dark ? 0.25 : 0.06),
                radius: 8, x: 0, y: 4
            )
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(AppTheme.primaryText)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

//////////////////////////////////////////////////////////

// MARK: - Scanner View
struct ScannerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scanner = RitualScannerManager()

    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var identifiedRitual: RitualInfo?
    @State private var showResultSheet = false
    @State private var isProcessing = false

    @State private var sheetDetent: PresentationDetent = .medium
    @State private var showDetailView = false

    var body: some View {
        ZStack {
            CameraPreview(session: scanner.captureSession)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .padding()
                    Spacer()
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 2, dash: [10])
                        )
                        .frame(width: 250, height: 250)

                    Text("Put your Ritual object into this box to Know the meaning of that object")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .offset(y: 190)
                }

                Spacer()

                HStack(spacing: 60) {
                    Button {
                        showImagePicker = true
                    } label: {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Library").font(.caption2)
                        }
                        .foregroundColor(.white)
                    }

                    Button {
                        isProcessing = true
                        scanner.capturePhoto { image in processImage(image) }
                    } label: {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 3).frame(
                                    width: 82, height: 82))
                    }

                    Spacer().frame(width: 44)
                }
                .padding(.bottom, 50)
            }

            if isProcessing {
                Color.black.opacity(0.6).ignoresSafeArea()
                ProgressView("Identifying Ritual...")
                    .tint(.white)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage) { image in processImage(image) }
        }
        .sheet(isPresented: $showResultSheet) {
            if let ritual = identifiedRitual {
                ResultSheetContainer(
                    ritual: ritual, image: selectedImage,
                    showDetailView: $showDetailView,
                    sheetDetent: $sheetDetent,
                    onDismiss: { showResultSheet = false }
                )
                .presentationDetents([.medium, .large], selection: $sheetDetent)
                .interactiveDismissDisabled(showDetailView)
            }
        }
        .onAppear { scanner.start() }
        .onDisappear { scanner.stop() }
    }

    private func processImage(_ image: UIImage) {
        selectedImage = image
        scanner.analyzeImage(image) { ritual in
            identifiedRitual = ritual
            isProcessing = false
            showDetailView = false
            sheetDetent = .medium
            showResultSheet = true
        }
    }
}

struct ResultSheetContainer: View {
    let ritual: RitualInfo
    let image: UIImage?
    @Binding var showDetailView: Bool
    @Binding var sheetDetent: PresentationDetent
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if showDetailView {
                DetailView(ritual: ritual)
            } else {
                ResultSummarySheet(
                    ritual: ritual, image: image,
                    onLearnMore: {
                        showDetailView = true
                        sheetDetent = .large
                    })
            }
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

struct ResultSummarySheet: View {
    let ritual: RitualInfo
    let image: UIImage?
    let onLearnMore: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.secondary.opacity(0.3))

            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
            }

            Text(LocalizedStringKey(ritual.name))
                .font(AppTheme.titleFont)

            Text(LocalizedStringKey(ritual.meaning))
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button {
                onLearnMore()
            } label: {
                Text("Learn More")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.accent)
                    .cornerRadius(14)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
}

//////////////////////////////////////////////////////////

// MARK: - Scanner Manager
class RitualScannerManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let captureSession = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var callback: ((UIImage) -> Void)?

    override init() {
        super.init()
        setup()
    }

    private func setup() {
        guard let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device)
        else { return }
        captureSession.beginConfiguration()
        captureSession.addInput(input)
        captureSession.addOutput(output)
        captureSession.commitConfiguration()
    }

    func start() { DispatchQueue.global().async { self.captureSession.startRunning() } }
    func stop() { captureSession.stopRunning() }

    func capturePhoto(completion: @escaping (UIImage) -> Void) {
        callback = completion
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            return
        }
        callback?(image)
    }

    func analyzeImage(_ image: UIImage, completion: @escaping (RitualInfo) -> Void) {
        guard let ciImage = CIImage(image: image),
            let model = try? VNCoreMLModel(
                for: IndianRitualObjectScannerDataset(configuration: MLModelConfiguration()).model
            )
        else { return }
        let request = VNCoreMLRequest(model: model) { req, _ in
            if let result = (req.results as? [VNClassificationObservation])?.first,
                let ritual = RitualDatabase.allRituals[result.identifier.lowercased()]
            {
                DispatchQueue.main.async { completion(ritual) }
            }
        }
        try? VNImageRequestHandler(ciImage: ciImage).perform([request])
    }
}

//////////////////////////////////////////////////////////

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onSelect: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
                parent.onSelect(img)
            }
            parent.dismiss()
        }
    }
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = UIScreen.main.bounds
        view.layer.addSublayer(layer)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Full Explore View
struct FullExploreView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppTheme.gridSpacing),
                    GridItem(.flexible(), spacing: AppTheme.gridSpacing),
                ],
                spacing: AppTheme.gridSpacing
            ) {
                ForEach(RitualDatabase.allRituals.values.sorted { $0.name < $1.name }) { ritual in
                    NavigationLink(destination: DetailView(ritual: ritual)) {
                        AppRitualCard(name: LocalizedStringKey(ritual.name), image: ritual.image)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppTheme.sectionPadding)
        }
        .background(AppTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("All Ritual Objects")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Notification View
struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Use the same logic present in calendar view to stay consistent
    var todayEvents: [AnnualRitual] {
        let calendar = Calendar.current
        let todayComps = calendar.dateComponents([.month, .day], from: Date())
        guard let month = todayComps.month, let day = todayComps.day else { return [] }
        return AnnualRitualDatabase.rituals.filter { $0.approximateMonth == month && $0.approximateDay == day }
    }
    
    var upcomingEvents: [AnnualRitual] {
        let calendar = Calendar.current
        let todayComps = calendar.dateComponents([.month, .day], from: Date())
        guard let month = todayComps.month, let day = todayComps.day else { return [] }
        
        return AnnualRitualDatabase.rituals.filter { ritual in
            if ritual.approximateMonth > month { return true }
            if ritual.approximateMonth == month && ritual.approximateDay > day { return true }
            return false
        }
        .sorted {
            if $0.approximateMonth != $1.approximateMonth {
                return $0.approximateMonth < $1.approximateMonth
            }
            return $0.approximateDay < $1.approximateDay
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // - Today's Rituals -
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(AppTheme.accent)
                            Text("Today's Ritual")
                                .font(AppTheme.titleFont)
                        }
                        .padding(.horizontal)
                        
                        if todayEvents.isEmpty {
                            // Empty State
                            HStack(spacing: 14) {
                                Image(systemName: "moon.zzz")
                                    .font(.system(size: 28))
                                    .foregroundColor(AppTheme.accent.opacity(0.7))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("No Ritual Today")
                                        .font(AppTheme.headingFont)
                                        .foregroundColor(AppTheme.primaryText)
                                    Text("Enjoy your peaceful day 🙏")
                                        .font(AppTheme.subheadingFont)
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                                Spacer()
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                            .overlay(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius).stroke(AppTheme.accent.opacity(0.1), lineWidth: 1))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                            .padding(.horizontal)
                            
                        } else {
                            ForEach(todayEvents) { ritual in
                                NavigationLink(destination: AnnualRitualDetailView(ritual: ritual)) {
                                    TodayFullWidthCard(ritual: ritual)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 16)
                    
                    Divider().padding(.horizontal)
                    
                    // - Upcoming Rituals -
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(AppTheme.accent)
                            Text("Upcoming Rituals")
                                .font(AppTheme.titleFont)
                        }
                        .padding(.horizontal)
                        
                        if upcomingEvents.isEmpty {
                            Text("No upcoming rituals this year.")
                                .font(AppTheme.bodyFont)
                                .foregroundColor(AppTheme.secondaryText)
                                .padding()
                        } else {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ],
                                spacing: 16
                            ) {
                                ForEach(upcomingEvents.prefix(6)) { ritual in
                                    NavigationLink(destination: AnnualRitualDetailView(ritual: ritual)) {
                                        PremiumGridRitualCard(ritual: ritual)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .background(AppTheme.pageBackground)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(AppTheme.uiActionFont)
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
    }
}


