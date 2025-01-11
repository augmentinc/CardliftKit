import SwiftUI

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
        let url = URL(string: "https://api.cardlift.co/v1/tenants/\(slug)")!

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

/**
 A view that prompts users to install the iOS extension.
 - Parameter appStoreURL: The URL to the App Store page for the iOS extension.
 - Parameter buttonConfig: The configuration for the button.
 - backgroundColor: The button background color.
 - foregroundColor: The button text color.
 - Returns: A button that, when tapped, opens a sheet with an upsell message.
 */
public struct Upsell: View {
    @State private var showSheet = false
    @StateObject var tenantViewModel = TenantViewModel()
    var slug: String
    var buttonConfig: UpsellButtonConfig

    public init( slug: String, buttonConfig: UpsellButtonConfig) {
        self.slug = slug
        self.buttonConfig = buttonConfig
    }

    public var body: some View {
        Button(action: {
            self.showSheet.toggle()
        }) {
            if tenantViewModel.tenant == nil {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: buttonConfig.foregroundColor))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(buttonConfig.foregroundColor)
            } else {
                Text("Add \(tenantViewModel.tenant?.name ?? "") to Safari")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(buttonConfig.foregroundColor)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 40)
        .background(buttonConfig.backgroundColor)
        .cornerRadius(40)
        .sheet(isPresented: $showSheet) {
            UpsellSheet()
                .environmentObject(tenantViewModel)
        }
        .onAppear {
            tenantViewModel.fetchTenant(slug: slug)
        }

    }

    struct UpsellSheet: View {
        @Environment(\.openURL) var openURL
        @EnvironmentObject var tenantViewModel: TenantViewModel

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

                AsyncImage(url: URL(string: tenantViewModel.tenant?.card ?? "")) { image in
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
                        openURL(URL(string:  "")!)
                    }) {
                        Text("Add \(tenantViewModel.tenant?.name ?? "") to your wallet")
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
