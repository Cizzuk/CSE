//
//  PurchaseView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/09/21.
//

#if !os(visionOS) && !targetEnvironment(macCatalyst)
import SwiftUI
import StoreKit

struct IconChangeView: View {
    @ObservedObject var storeManager = StoreManager()
    @AppStorage("haveIconChange", store: userDefaults) private var haveIconChange: Bool = false
    @State private var showSucAlert = false
    @State private var showFailAlert = false
    @State private var showRestoreSucAlert = false
    
    var body: some View {
        List {
            if haveIconChange {
                Section {
                    iconItem(iconName: "CSE", iconID: "appicon")
                    iconItem(iconName: "Red", iconID: "red-white")
                    iconItem(iconName: "Green", iconID: "green-white")
                    iconItem(iconName: "Mono", iconID: "gray-white")
                    iconItem(iconName: "Pride", iconID: "pride")
                    iconItem(iconName: "Pixel", iconID: "pixel")
                }
                
            } else {
//                // IMPORTANT: This code is not currently used, but it is kept here for future reference.
//                // Purchase Section
//                Section {
//                    HStack {
//                        Image(systemName: "checkmark.circle")
//                            .accessibilityHidden(true)
//                        Text("You will be able to change the application icon")
//                    }
//                    HStack {
//                        Image(systemName: "checkmark.circle")
//                            .accessibilityHidden(true)
//                        Text("Your purchase will support the development of CSE")
//                    }
//                    HStack {
//                        Image(systemName: "checkmark.circle")
//                            .accessibilityHidden(true)
//                        Text("More people will be able to continue using CSE for free")
//                    }
//                    
//                    // Purchase Button
//                    Button(action: {
//                        if let product = self.storeManager.products.first {
//                            self.storeManager.purchase(product: product)
//                        }
//                    }) {
//                        HStack {
//                            if !storeManager.products.isEmpty {
//                                Text("Purchase:")
//                                    .fontWeight(.bold)
//                                    .padding(10)
//                                ForEach(storeManager.products, id: \.self) { product in
//                                    Text(self.localizedPrice(for: product))
//                                }
//                            } else {
//                                Text("Purchase is currently not available.")
//                                    .padding(10)
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                    }
//                    .disabled(storeManager.products.isEmpty)
//                }
                
                // Restore Button
                Section {
                    Button(action: {
                        self.storeManager.restorePurchases()
                    }) {
                        Text("Restore Purchase")
                            .frame(maxWidth: .infinity)
                    }
                } footer: {
                    // TODO: Remove these texts if CTF issues are resolved. (issue#24)
                    VStack (alignment: .leading) {
                        Text("Purchase is currently not available.")
                        Text("Only available if you have previously purchased this.")
                    }
                }
                
                // Icon Preview Section
                Section {
                    iconItem(iconName: "CSE", iconID: "appicon")
                    iconItem(iconName: "Red", iconID: "red-white")
                    iconItem(iconName: "Green", iconID: "green-white")
                    iconItem(iconName: "Mono", iconID: "gray-white")
                    iconItem(iconName: "Pride", iconID: "pride")
                    iconItem(iconName: "Pixel", iconID: "pixel")
                } header: {
                    Text("Available Icons")
                } footer: {
                    Text("Available icons may change in the future.")
                }
            }
        }
        .navigationTitle("Change App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Purchase Success!", isPresented: $storeManager.purchaseCompleted, actions: {})
        .alert("Purchase Failed", isPresented: $storeManager.purchaseFailed, actions: {})
        .alert("Restore Success!", isPresented: $storeManager.restoreCompleted, actions: {})
    }
    
    private func iconItem(iconName: String, iconID: String) -> some View {
        HStack {
            Image(iconID + "-pre")
                .resizable()
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)
                .cornerRadius(14)
                .padding(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            Text(iconName)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Change App Icon
            if haveIconChange {
                if iconID == "appicon" {
                    UIApplication.shared.setAlternateIconName(nil)
                } else {
                    UIApplication.shared.setAlternateIconName(iconID)
                }
            }
        }
    }
    
    // Get Localized Price
    private func localizedPrice(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "\(product.price)"
    }
}

final class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var products = [SKProduct]()
    var presentationMode: Binding<PresentationMode>?
    @Published var purchaseCompleted = false
    @Published var purchaseFailed = false
    @Published var restoreCompleted = false
    
    override init() {
        super.init()
        fetchProducts()
        SKPaymentQueue.default().add(self)
    }
    
    func fetchProducts() {
        let productIdentifiers: Set<String> = ["cse.changeicon"]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // SKProductsRequestDelegate methods
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
    
    // SKPaymentTransactionObserver methods
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                userDefaults.set(true, forKey: "haveIconChange")
                purchaseCompleted = true
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                purchaseFailed = true
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                userDefaults.set(true, forKey: "haveIconChange")
                restoreCompleted = true
            default:
                break
            }
        }
    }
}
#endif
