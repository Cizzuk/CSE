//
//  SettingView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/03/13.
//

import SwiftUI
import StoreKit

@main

struct MainView: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    
    //Load app settings
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    @State private var urltop = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "urltop") ?? "https://archive.org/search?query="
    @State private var urlsuffix = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "urlsuffix") ?? ""
    @State private var searchengine = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "searchengine") ?? "duckduckgo"
    @State private var isIconSettingView: Bool = false
    var alternateIconName: String? {
        UIApplication.shared.alternateIconName
    }
    
    @ObservedObject var storeManager = StoreManager()
    var linkDestination: some View {
        if UserDefaults().bool(forKey: "haveIconChange") {
            return AnyView(IconSettingView())
        } else {
            return AnyView(PurchaseView())
        }
    }
    
    var body: some View {
        @ObservedObject var storeManager = StoreManager()
        NavigationView {
            List {
                // Top Section
                Section {
                    TextField("", text: $urltop)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onChange(of: urltop) { entered in
                            userDefaults!.set(entered, forKey: "urltop")
                        }
                    
                } header: {
                    Text("TopUrl")
                } footer: {
                    Text("TopUrl-Desc")
                        .tint(.secondary)
                }
                
                // Suffix Section
                Section {
                    TextField("", text: $urlsuffix)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onChange(of: urlsuffix) { entered in
                            userDefaults!.set(entered, forKey: "urlsuffix")
                        }
                } header: {
                    Text("SuffixUrl")
                } footer: {
                    Text("SuffixUrl-Desc")
                        .tint(.secondary)
                }
                
                // Default SE Section
                Section {
                    Picker("DefaultSE", selection: $searchengine) {
                        Text("DuckDuckGo").tag("duckduckgo")
                        Text("Sogou").tag("sogou")
                        Text("Yandex").tag("yandex")
                    }
                    .onChange(of: searchengine) { entered in
                        userDefaults!.set(entered, forKey: "searchengine")
                    }
                } header: {
                    Text("SafariSetting")
                } footer: {
                    VStack (alignment : .leading) {
                        Text("DefaultSE-Desc")
                        Spacer()
                        Text("SafariSetting-Desc")
                    }
                }
                
                Section {
                    NavigationLink(destination: linkDestination, isActive: $isIconSettingView) {
                        Image((alternateIconName ?? "appicon") + "-pre")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .id(isIconSettingView)
                        Text("ChangeAppIcon")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                } header: {
                    Text("AppIcon")
                }
                
                // Support Section
                Section {
                    // Contact Link
                    Link(destination:URL(string: "https://cizzuk.net/contact/")!, label: {
                        HStack {
                            Image(systemName: "message")
                                .frame(width: 20.0)
                            Text("ContactLink")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    })
                    // Privacy Policy
                    Link(destination:URL(string: "https://tsg0o0.com/privacy/")!, label: {
                        HStack {
                            Image(systemName: "hand.raised")
                                .frame(width: 20.0)
                            Text("PrivacyPolicyLink")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    })
                    // License Link
                    Link(destination:URL(string: "https://www.mozilla.org/en-US/MPL/2.0/")!, label: {
                        HStack {
                            Image(systemName: "book.closed")
                                .frame(width: 20.0)
                            Text("LicenseLink")
                            Spacer()
                            Text("MPL 2.0")
                            Image(systemName: "chevron.right")
                        }
                    })
                    // GitHub Source Link
                    Link(destination:URL(string: "https://github.com/tsg0o0/CSE-iOS")!, label: {
                        HStack {
                            Image(systemName: "ladybug")
                                .frame(width: 20.0)
                            Text("SourceLink")
                            Spacer()
                            Text("GitHub")
                            Image(systemName: "chevron.right")
                        }
                    })
                } header: {
                    Text("SupportLink")
                } footer: {
                    HStack {
                        Text("© Cizzuk")
                        Spacer()
                        Text("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("CSESetting")
        }
        .navigationViewStyle(.stack)
    }
}

struct IconSettingView: View {
    var body: some View {
        List {
            Section {
                iconItem(iconName: "CSE", iconID: "appicon")
                iconItem(iconName: "Red", iconID: "red-white")
                iconItem(iconName: "Green", iconID: "green-white")
                iconItem(iconName: "White", iconID: "gray-white")
                iconItem(iconName: "Light", iconID: "light")
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
                iconItem(iconName: "Light", iconID: "light")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
