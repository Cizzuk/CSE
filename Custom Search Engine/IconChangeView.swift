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
                iconItem(iconName: "Glitch", iconID: "glitch")
                iconItem(iconName: "Dark Blue", iconID: "blue-dark")
                iconItem(iconName: "Dark Red", iconID: "red-dark")
                iconItem(iconName: "Dark Green", iconID: "green-dark")
                iconItem(iconName: "Black", iconID: "gray-dark")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("ChangeAppIcon")
        .navigationBarTitleDisplayMode(.inline)
    }
    func iconItem(iconName: String, iconID: String) -> some View {
        HStack {
            Image(iconID + "-pre")
                .resizable()
                .frame(width: 80, height: 80)
                .accessibilityHidden(true)
                .accessibilityIgnoresInvertColors(true)
            Text(iconName)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
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
    var body: some View {
        List {
            //Purchase Section
            Section {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .accessibilityHidden(true)
                    Text("Purchase-Desc1")
                }
                HStack {
                    Image(systemName: "checkmark.circle")
                        .accessibilityHidden(true)
                    Text("Purchase-Desc2")
                }
                HStack {
                    Image(systemName: "checkmark.circle")
                        .accessibilityHidden(true)
                    Text("Purchase-Desc3")
                }
                //Purchase Button
                Button(action: {
                    if let product = self.storeManager.products.first {
                        self.storeManager.purchase(product: product)
                    }
                }) {
                    HStack {
                        Text("PurchaseButton")
                            .fontWeight(.bold)
                            .padding(10)
                        ForEach(storeManager.products, id: \.self) { product in
                            Text(self.localizedPrice(for: product))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .alert(isPresented: $showSucAlert) {
                    Alert(title: Text("Purchase Success!"))
                }
                .onReceive(storeManager.$purchaseCompleted) { purchaseCompleted in
                    if purchaseCompleted {
                        showSucAlert = true
                    }
                }
                .alert(isPresented: $showFailAlert) {
                    Alert(title: Text("Purchase Failed"
                                     ))
                }
                .onReceive(storeManager.$purchaseFailed) { purchaseFailed in
                    if purchaseFailed {
                        showFailAlert = true
                    }
                }
                .disabled(storeManager.products.isEmpty)
            }
            Section {
                //Restore Button
                Button(action: {
                    self.storeManager.restorePurchases()
                }) {
                    Text("RestorePurchase")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
            }
            
            //Icon Preview Section
            Section {
                iconItem(iconName: "CSE", iconID: "appicon")
                iconItem(iconName: "Red", iconID: "red-white")
                iconItem(iconName: "Green", iconID: "green-white")
                iconItem(iconName: "White", iconID: "gray-white")
                iconItem(iconName: "Pride", iconID: "pride")
                iconItem(iconName: "General", iconID: "light")
                iconItem(iconName: "Glitch", iconID: "glitch")
                iconItem(iconName: "Dark Blue", iconID: "blue-dark")
                iconItem(iconName: "Dark Red", iconID: "red-dark")
                iconItem(iconName: "Dark Green", iconID: "green-dark")
                iconItem(iconName: "Black", iconID: "gray-dark")
            } header: {
                Text("AvailableIcon")
            } footer: {
                Text("ChangeAppIcon-Desc")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("ChangeAppIcon")
        .navigationBarTitleDisplayMode(.inline)
    }
    func iconItem(iconName: String, iconID: String) -> some View {
        HStack {
            Image(iconID + "-pre")
                .resizable()
                .frame(width: 80, height: 80)
                .accessibilityHidden(true)
            Text(iconName)
        }
    }
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
            case .purchased, .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                // Success!!!
                handlePurchaseSuccess()
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                // Failed...
                handlePurchaseFailure()
            default:
                break
            }
        }
    }
    
    func handlePurchaseSuccess() {
        UserDefaults.standard.set(true, forKey: "haveIconChange")
        purchaseCompleted = true
    }
    func handlePurchaseFailure() {
        purchaseFailed = true
    }
}
#endif
