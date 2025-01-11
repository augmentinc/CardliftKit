import SwiftUI

/**
 A view that prompts users to install the iOS extension.
 - Parameter appStoreURL: The URL to the App Store page for the iOS extension.
 - Parameter buttonConfig: The configuration for the button.
 - text: The button text.
 - backgroundColor: The button background color.
 - foregroundColor: The button text color.
 - cornerRadius: The button corner radius.
 - Returns: A button that, when tapped, opens a sheet with an upsell message.
 */
public struct Upsell: View {
    @State private var showSheet = false
    var appStoreURL: URL
    var buttonConfig: UpsellButtonConfig
    
    public init( appStoreURL: URL, buttonConfig: UpsellButtonConfig) {
        self.appStoreURL = appStoreURL
        self.buttonConfig = buttonConfig
    }
    
    public var body: some View {
        Button(action: {
            self.showSheet.toggle()
        }) {
            Text(buttonConfig.text)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(buttonConfig.foregroundColor)
        }
        .frame(width: UIScreen.main.bounds.width - 40)
        .background(buttonConfig.backgroundColor)
        .cornerRadius(40)
        .sheet(isPresented: $showSheet) {
            UpsellSheet(appStoreURL: appStoreURL)
        }
        
    }
    
    struct UpsellSheet: View {
        @Environment(\.openURL) var openURL
        
        var appStoreURL: URL
        
        init(appStoreURL: URL) {
            self.appStoreURL = appStoreURL
        }
        
        var body: some View {
            VStack {
                Spacer()
                
                Text("Simplify your checkout with our Safari Extension")
                    .foregroundColor(Color(red: 55/255, green: 55/255, blue: 55/255))
                    .font(.system(size: 32, weight: .bold))
                    .tracking(0.3)
                    .lineSpacing(0.8)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300, alignment: .center)
                    .padding()
                
                AsyncImage(url: URL(string: "https://cardlift.s3.amazonaws.com/brand/heb/heb-card.png")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width - 80)
                        .padding()
                } placeholder: {
                    Shimmer()
                        .frame(width: UIScreen.main.bounds.width - 80, height: 190)
                        .padding()
                }
                
                Group {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 110/255, green: 100/255, blue: 100/255))
                            .frame(width: 4, height: 4)
                        Text("Checkout 2x quicker")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.leading, 6)
                            .foregroundColor(Color(red: 140/255, green: 140/255, blue: 140/255))
                        Spacer()
                    }.padding(.top, 12)
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 110/255, green: 100/255, blue: 100/255))
                            .frame(width: 4, height: 4)
                        Text("Change your card at frequent sites")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.leading, 6)
                            .foregroundColor(Color(red: 140/255, green: 140/255, blue: 140/255))
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 110/255, green: 100/255, blue: 100/255))
                            .frame(width: 4, height: 4)
                        Text("Earn more points by using this card more")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.leading, 6)
                            .foregroundColor(Color(red: 140/255, green: 140/255, blue: 140/255))
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                VStack {
                    Button(action: {
                        openURL(appStoreURL)
                    }) {
                        Text("Add to Safari")
                            .font(.system(size: 20, weight: .semibold))
                            .padding()
                            .frame(maxWidth: UIScreen.main.bounds.width - 40)
                            .background(Color(red: 218/255, green: 41/255, blue: 36/255))
                            .foregroundColor(.white)
                            .cornerRadius(40)
                    }
                    
                    HStack {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                        Text("End to end encrypted on your device")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        Spacer()
                    }.padding(.top, 4)
                }
                
            }
            .padding()
        }
    }
}



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
