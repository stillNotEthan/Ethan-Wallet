//
//  HomeView.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/20.
//

import SwiftUI

struct HomeView: View {
    @State private var mnemonic: String = ""
    @State private var address: String = ""
    @State private var balance: String = "0.0000 ETH"
    @State private var isShowingSend = false
    @State private var isShowingReceive = false
    @State private var tokens: [Token] = Token.mockTokens
    @State private var transactions: [Transaction] = []
    @State private var isLoadingTransactions = false
    @State private var isShowingScanner = false
    @State private var scannedAddress = ""
    @State private var isSHowingSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // 1. property card
                    WalletCardView(address: address, balance: balance)
                        .padding(.horizontal)
                    
                    // 2. fast oper btn
                    HStack(spacing: 40) {
                        ActionButton(icon: "arrow.up.circle.fill", title: "Send") {
                            isShowingSend = true
                        }
                        ActionButton(icon: "arrow.down.circle.fill", title: "Receive") {
                            // 接收逻辑
                            isShowingReceive = true
                        }
                        ActionButton(icon: "qrcode.viewfinder", title: "Scan") {
                            // 扫码逻辑
                            isShowingScanner = true
                        }
                    }
                    
                    AssetListView(tokens: tokens)
                    
                    // 4.交易历史列表
                    if isLoadingTransactions {
                        ProgressView()
                            .padding()
                    } else {
                        TransactionListView(transactions: transactions, walletAddress: address)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
            .navigationTitle("My Wallet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isSHowingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $isShowingSend) {
                SendView(currentBalance: balance, walletAddress: self.address)
            }
            .sheet(isPresented: $isShowingReceive) {
                ReceiveView(address: address)
            }
            .sheet(isPresented: $isShowingScanner) {
                ScannerView(scannedCode: $scannedAddress)
                    .onDisappear {
                        if !scannedAddress.isEmpty {
                            // 扫码成功后，自动弹出发送页面
                            isShowingSend = true
                        }
                    }
            }
            .sheet(isPresented: $isSHowingSettings) {
                SettingsView()
            }
            .navigationDestination(for: Token.self) { token in
                TokenDetailView(token: token)
            }
        }
        .onAppear {
            loadWallet()
            loadData()
        }
    }
    
    func loadWallet() {
        if let saved = WalletService.shared.loadMnemonic() {
            self.mnemonic = saved
            self.address = WalletService.shared.getEthereumAddress(from: saved) ?? ""
            WalletService.getBalance(address: self.address) { self.balance = $0 }
        }
    }
    
    func loadAllTokenBalances() {
        for index in tokens.indices {
            Task {
                do {
                    let balance = try await WalletService.fetchTokenBalance(contractAddress: tokens[index].contractAddress, walletAddress: address, decimals: tokens[index].decimal)
                    DispatchQueue.main.async {
                        tokens[index].balance = balance
                    }
                } catch {
                    print("Error Loading \(tokens[index].symbol): \(error)")
                }
            }
        }
    }
    
    func loadTransactions() {
        isLoadingTransactions = true
        Task {
            do {
                let history = try await WalletService.fetchTransactionHistory(for: address)
                DispatchQueue.main.async {
                    self.transactions = history
                    self.isLoadingTransactions = false
                }
            } catch {
                print("Error loading transactions: \(error)")
                DispatchQueue.main.async {
                    self.isLoadingTransactions = false
                }
            }
        }
    }
    
    func loadData() {
        loadAllTokenBalances();
        
        
    }
}

// 辅助组件：圆形按钮
struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                Text(title)
                    .font(.caption)
                    .bold()
            }
            .foregroundStyle(.blue)
        }
    }
}


// 模拟行
struct ActivityRow: View {
    var body: some View {
        HStack {
            Image(systemName: "arrow.up.right.circle.fill")
                .foregroundStyle(.gray)
                .font(.title2)
            VStack(alignment: .leading) {
                Text("Sent ETH")
                    .font(.headline)
                Text("To: 0x71C...9778")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text("-0.01 ETH")
                .font(.headline)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
