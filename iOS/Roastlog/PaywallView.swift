import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var purchases: PurchaseManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundStyle(RoastlogTheme.accentBright)
                Text("Roastlog Pro")
                    .font(RoastlogTheme.titleFont)
                Text("Roast curve notes, batch comparison stats")
                    .font(RoastlogTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                Button {
                    Task { await purchases.purchase() }
                } label: {
                    Text(purchases.product != nil ? "Unlock for \(purchases.product!.displayPrice)" : "Unlock Pro ($1.99/mo)")
                        .font(RoastlogTheme.headlineFont)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoastlogTheme.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityIdentifier("unlockButton")
                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .accessibilityIdentifier("restoreButton")
                Button("Not Now") { dismiss() }
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("dismissPaywallButton")
            }
            .padding()
            .task { await purchases.load() }
        }
    }
}
