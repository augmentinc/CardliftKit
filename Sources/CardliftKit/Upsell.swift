import SwiftUI
import AVKit
import AVFoundation

// MARK: - View Model

/**
 A view model that fetches and holds tenant data.
 `TenantViewModel` is an observable object that fetches tenant data from a remote server and publishes it.
 - Properties:
 - tenant: The tenant data fetched from the server. It is an optional `Tenant` object.
 - Methods:
 - fetchTenant(): Fetches tenant data from a predefined URL and updates the `tenant` property. Handles network errors and JSON decoding errors.
 */
public class TenantViewModel: ObservableObject {
    @Published var tenant: Tenant?
    
    func fetchTenant(slug: String = "acme") {
        let url = URL(string: "https://api.cardlift.co/v1/tenants/\(slug)/ios")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data returned from server")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let tenant = try decoder.decode(Tenant.self, from: data)
                DispatchQueue.main.async {
                    self.tenant = tenant
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                print("Failed data: \(String(data: data, encoding: .utf8) ?? "Unreadable data")")
            }
        }.resume()
    }
}

// MARK: - Main Viewer

/**
 A view that prompts users to install the iOS extension.
 - Parameter appStoreURL: The URL to the App Store page for the iOS extension.
 - Parameter buttonConfig: The configuration for the button.
 - backgroundColor: The button background color.
 - foregroundColor: The button text color.
 - Returns: A button that, when tapped, opens a sheet with an upsell message.
 */
public struct Upsell: View {
    var slug: String
    @Binding var isPresented: Bool
    @StateObject var tenantViewModel = TenantViewModel()
    
    private var isPresentedBinding: Binding<Bool> {
        Binding(
            get: {
                NSLog("Debug: Upsell isPresented: \(isPresented)");
                NSLog("Debug: Upsell Tenant: \(String(describing: tenantViewModel.tenant))");
                return isPresented && tenantViewModel.tenant != nil
            },
            set: { newValue in
                isPresented = newValue
            }
        )
    }
    
    public init(slug: String, isPresented: Binding<Bool>) {
        self.slug = slug
        self._isPresented = isPresented
    }
    
    public var body: some View {
        EmptyView()
            .sheet(isPresented: isPresentedBinding) {
                UpsellSheet(tenant: tenantViewModel.tenant!)
            }
            .onAppear {
                tenantViewModel.fetchTenant(slug: slug)
            }
        
    }
}

/**
Sheet view that presents the multi-step upsell flow.
*/
struct UpsellSheet: View {
    @Environment(\.openURL) var openURL
    @State private var currentStep = 1
    var tenant: Tenant
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            StepContent(step: currentStep, tenant: tenant)
            Spacer()
                .frame(height: 40)
            BottomButton(
                currentStep: $currentStep,
                tenant: tenant,
                openURL: openURL
            )
            .padding()
        }
        .padding(currentStep == 2 ? 0 : 16)
    }
}

// MARK: - Step Views

/**
 A view that displays the content for a given step in the upsell flow.
 - Parameter step: The current step number.
 - Parameter tenant: The tenant data.
 - Returns: A view that displays the content for the current step.
 */
private struct StepContent: View {
    let step: Int
    let tenant: Tenant
    
    var body: some View {
        switch step {
        case 1:
            WelcomeStep(tenant: tenant)
        case 2:
            VideoStep()
        case 3:
            SuccessStep()
        default:
            EmptyView()
        }
    }
}

// MARK: - Step 1 - Welcome

/**
 A view that displays the welcome step in the upsell flow.
 - Parameter tenant: The tenant data.
 - Returns: A view that displays the welcome step.
 */
private struct WelcomeStep: View {
    let tenant: Tenant
    
    var body: some View {
        VStack {
            Text(tenant.title)
                .font(.system(size: 32, weight: .bold))
                .tracking(0.3)
                .lineSpacing(0.8)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300, alignment: .center)
                .padding()
            
            CardImage(imageURL: tenant.cardImage)
            FeatureList(features: tenant.features)
        }
    }
}

/**
 A view that displays a card image.
 - Parameter imageURL: The URL of the image to display.
 - Returns: A view that displays the card image.
 */
private struct CardImage: View {
    let imageURL: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width - 80)
                .padding()
                .cornerRadius(8)
        } placeholder: {
            Shimmer()
                .frame(width: UIScreen.main.bounds.width - 80, height: 190)
                .padding()
        }
    }
}

/**
 A view that displays a list of features.
 - Parameter features: An array of strings representing the features to display.
 - Returns: A view that displays the list of features.
 */
private struct FeatureList: View {
    let features: [String]
    
    var body: some View {
        ForEach(features, id: \.self) { feature in
            HStack {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .frame(width: 4, height: 4)
                Text(feature)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.leading, 6)
                    .foregroundColor(Color(red: 140/255, green: 140/255, blue: 140/255))
                Spacer()
            }
        }
    }
}

/**
 A view that wraps a UIView and displays it in SwiftUI.
 - Parameter view: The UIView to display.
 - Returns: A view that displays the UIView.
 */
struct UIViewWrapper: UIViewRepresentable {
    let view: UIView
    
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Step 2 - Video 

/**
Manages video playback and Picture-in-Picture functionality.
*/
class VideoPlayerManager: ObservableObject {
    static let shared = VideoPlayerManager()
    var pip: AVPictureInPictureController?
    var player: AVPlayer?
    var timeObserver: Any?
    var loopObserver: Any?
    
    private init() {}
    
    func cleanUp() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        if let loopObserver = loopObserver {
            NotificationCenter.default.removeObserver(loopObserver)
        }
        player?.pause()
        player = nil
        pip = nil
        timeObserver = nil
        loopObserver = nil
    }
}

/**
 A view that displays the video step in the upsell flow.
 - Returns: A view that displays the video step.
 */
private struct VideoStep: View {
    @State private var playerView = UIView()
    @State private var isVideoLoading = true
    
    var body: some View {
        GeometryReader { geometry in
            let contentWidth = geometry.size.width - 40
            let contentHeight = geometry.size.height
            
            ZStack {
                if isVideoLoading {
                    Shimmer()
                        .frame(width: contentWidth, height: contentHeight)
                        .cornerRadius(8)
                }
                
                UIViewWrapper(view: playerView)
                    .frame(width: contentWidth, height: contentHeight)
                    .opacity(isVideoLoading ? 0 : 1)
                    .onAppear {
                        let videoURL = URL(string: "https://cardlift.s3.us-east-1.amazonaws.com/brand/cardvault/enable-extension.mp4")!
                        
                        // Set audio session category
                        do {
                            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
                        } catch {
                            debugPrint("Error in setting audio session category. Error -\(error.localizedDescription)")
                        }
                        
                        let player = AVPlayer(url: videoURL)
                        VideoPlayerManager.shared.player = player
                        let playerLayer = AVPlayerLayer(player: player)
                        
                        // Set the frame to match the view's bounds
                        playerLayer.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
                        playerLayer.videoGravity = .resizeAspectFill
                        playerLayer.cornerRadius = 8
                        playerLayer.masksToBounds = true
                        playerView.layer.addSublayer(playerLayer)
                        
                        // Handle video ready to play
                        let loopObserver = NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: player.currentItem,
                            queue: .main) { _ in
                                player.seek(to: .zero)
                                player.play()
                        }
                        
                        // Add periodic time observer to check loading status
                        let timeObserver = player.addPeriodicTimeObserver(
                            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
                            queue: .main) { _ in
                                if player.currentItem?.status == .readyToPlay && player.timeControlStatus == .playing {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        isVideoLoading = false
                                    }
                                }
                        }
                        
                        // Store observers for cleanup
                        VideoPlayerManager.shared.timeObserver = timeObserver
                        VideoPlayerManager.shared.loopObserver = loopObserver
                        
                        VideoPlayerManager.shared.pip = AVPictureInPictureController(playerLayer: playerLayer)
                        player.play()
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Step 3 - Success

/**
 A view that displays the success step in the upsell flow.
 - Returns: A view that displays the success step.
 */
private struct SuccessStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)

                Text("You're All Set!")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Click below to get started")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
    }
}

// MARK: - Common components

/**
 A view that displays a button for navigating through the upsell flow.
 - Parameter currentStep: A binding to the current step number.
 - Parameter tenant: The tenant data.
 - Parameter openURL: The action to open a URL.
 - Returns: A view that displays the bottom button.
 */
private struct BottomButton: View {
    @Binding var currentStep: Int
    let tenant: Tenant
    let openURL: OpenURLAction
    
    var body: some View {
        VStack {
            Button(action: handleButtonTap) {
                Group {
                    if currentStep == 3 {
                        Text(buttonText)
                            .font(.system(size: 20, weight: .semibold))
                    } else {
                        HStack {
                            Text(buttonText)
                                .font(.system(size: 20, weight: .semibold))
                            Spacer()
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 1, height: 24)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .padding(.leading, 8)
                        }
                        .padding(.horizontal, 10)
                    }
                }
                .padding()
                .frame(maxWidth: UIScreen.main.bounds.width - 40)
                .background(buttonBackground)
                .foregroundColor(.white)
                .cornerRadius(tenant.buttonRadius)
            }
            
            if currentStep == 1 {
                EncryptionMessage()
            }
        }
    }
    
    private var buttonText: String {
        currentStep == 3 ? tenant.upsellLabel : currentStep == 2 ? "Enable Extension" : "Get Started"
    }
    
    private var buttonBackground: Color {
        let bGColor = tenant.backgroundColor
        return Color(
            red: Double(bGColor.r/255),
            green: Double(bGColor.g/255),
            blue: Double(bGColor.b/255)
        )
    }
    
    private func handleButtonTap() {
        if currentStep < 3 {
            if currentStep == 2 {
                VideoPlayerManager.shared.pip?.startPictureInPicture()
                if let settingsUrl = URL(string: "App-Prefs:root=SAFARI&path=EXTENSIONS") {
                    openURL(settingsUrl)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                }
            } else {
                currentStep += 1
            }
        } else {
            VideoPlayerManager.shared.cleanUp()
            openURL(URL(string: tenant.appStoreLink)!)
        }
    }
}

/**
 A view that displays an encryption message.
 - Returns: A view that displays the encryption message.
 */
private struct EncryptionMessage: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "lock.fill")
                .foregroundColor(.gray)
            Text("End to end encrypted on your device")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.top, 4)
    }
}

/**
 A view that displays a shimmering effect using a rounded rectangle.
 The shimmer effect animates the opacity of the rectangle between 0.1 and 0.5.
 
 The `Shimmer` view uses a `State` property `isAnimating` to control the animation.
 When the view appears, it starts an infinite linear animation that toggles the `isAnimating`
 state, creating a shimmering effect.
 */
struct Shimmer: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(UIColor.lightGray))
            .opacity(isAnimating ? 0.5 : 0.1)
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}
