//
//  PurchaseView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/09/21.
//

import SwiftUI
import StoreKit

#if iOS
struct IconSettingView: View {
    var body: some View {
        List {
            Section {
                iconItem(iconName: "CSE", iconID: "appicon")
                iconItem(iconName: "Red", iconID: "red-white")
                iconItem(iconName: "Green", iconID: "green-white")
                iconItem(iconName: "White", iconID: "gray-white")
                iconItem(iconName: "Pride", iconID: "pride")
                iconItem(iconName: "General", iconID: "light")
                iconItem(iconName: "Pixel", iconID: "pixel")
                iconItem(iconName: "Dark Blue", iconID: "blue-dark")
                iconItem(iconName: "Dark Red", iconID: "red-dark")
                iconItem(iconName: "Dark Green", iconID: "green-dark")
                iconItem(iconName: "Black", iconID: "gray-dark")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Change App Icon")
        .navigationBarTitleDisplayMode(.inline)
    }
    func iconItem(iconName: String, iconID: String) -> some View {
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
            if iconID == "appicon" {
                UIApplication.shared.setAlternateIconName(nil)
            }else{
                UIApplication.shared.setAlternateIconName(iconID)
            }
        }
    }
}

struct PurchaseView: View {
    @ObservedObject var storeManager = StoreManager()
    @State private var showSucAlert = false
    @State private var showFailAlert = false
    @State private var showRestoreSucAlert = false
    var body: some View {
        List {
            // Purchase Section
            Section {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .accessibilityHidden(true)
                    Text("You will be able to change the application icon")
                }
                HStack {
                    Image(systemName: "checkmark.circle")
                        .accessibilityHidden(true)
                    Text("Your purchase will support the development of CSE")
                }
                HStack {
                    Image(systemName: "checkmark.circle")
                        .accessibilityHidden(true)
                    Text("More people will be able to continue using CSE for free")
                }
                
                // Purchase Button
                Button(action: {
                    if let product = self.storeManager.products.first {
                        self.storeManager.purchase(product: product)
                    }
                }) {
                    HStack {
                        if !storeManager.products.isEmpty {
                            Text("Purchase:")
                                .fontWeight(.bold)
                                .padding(10)
                            ForEach(storeManager.products, id: \.self) { product in
                                Text(self.localizedPrice(for: product))
                            }
                        } else {
                            Text("Purchase is currently not available.")
                                .padding(10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .alert("Purchase Success!", isPresented: $showSucAlert, actions: {})
                .onReceive(storeManager.$purchaseCompleted) { purchaseCompleted in
                    if purchaseCompleted {
                        showSucAlert = true
                    }
                }
                .alert("Purchase Failed", isPresented: $showFailAlert, actions: {})
                .onReceive(storeManager.$purchaseFailed) { purchaseFailed in
                    if purchaseFailed {
                        showFailAlert = true
                    }
                }
                .disabled(storeManager.products.isEmpty)
            }
            
            // Restore Button
            Section {
                Button(action: {
                    self.storeManager.restorePurchases()
                }) {
                    Text("Restore Purchase")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
                .alert("Restore Success!", isPresented: $showRestoreSucAlert, actions: {})
                .onReceive(storeManager.$restoreCompleted) { restoreCompleted in
                    if restoreCompleted {
                        showRestoreSucAlert = true
                    }
                }
            }
            
            // Icon Preview Section
            Section {
                iconItem(iconName: "CSE", iconID: "appicon")
                iconItem(iconName: "Red", iconID: "red-white")
                iconItem(iconName: "Green", iconID: "green-white")
                iconItem(iconName: "White", iconID: "gray-white")
                iconItem(iconName: "Pride", iconID: "pride")
                iconItem(iconName: "General", iconID: "light")
                iconItem(iconName: "Pixel", iconID: "pixel")
                iconItem(iconName: "Dark Blue", iconID: "blue-dark")
                iconItem(iconName: "Dark Red", iconID: "red-dark")
                iconItem(iconName: "Dark Green", iconID: "green-dark")
                iconItem(iconName: "Black", iconID: "gray-dark")
            } header: {
                Text("Available Icons")
            } footer: {
                Text("Available icons may change in the future.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Change App Icon")
        .navigationBarTitleDisplayMode(.inline)
    }
    func iconItem(iconName: String, iconID: String) -> some View {
        HStack {
            Image(iconID + "-pre")
                .resizable()
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)
                .cornerRadius(14)
                .padding(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            Text(iconName)
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

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
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
                // Success!!!
                handlePurchaseSuccess()
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                // Failed...
                handlePurchaseFailure()
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                // Success!!!
                handleRestoreSuccess()
            default:
                break
            }
        }
    }
    
    // Handlers
    func handlePurchaseSuccess() {
        UserDefaults.standard.set(true, forKey: "haveIconChange")
        purchaseCompleted = true
    }
    func handlePurchaseFailure() {
        purchaseFailed = true
    }
    func handleRestoreSuccess() {
        UserDefaults.standard.set(true, forKey: "haveIconChange")
        restoreCompleted = true
    }
}
#endif
