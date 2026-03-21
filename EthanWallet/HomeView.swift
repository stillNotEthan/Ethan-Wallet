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
    
    var body: some View {
        NavigationView {
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
                        }
                    }
                    
                    // 3. 最近活动列表（模拟）
                    VStack(alignment: .leading) {
                        Text("Recent Activity")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ForEach(0..<3) {
                            _ in
                            ActivityRow()
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("My Wallet")
            .toolbar {
                Button(action: {}) {
                    Image(systemName: "gearshape.fill")
                }
            }
            .sheet(isPresented: $isShowingSend) {
                SendView()
            }
            .sheet(isPresented: $isShowingReceive) {
                ReceiveView(address: address)
            }
        }
        .onAppear {
            loadWallet()
        }
    }
    
    func loadWallet() {
        if let saved = WalletService.shared.loadMnemonic() {
            self.mnemonic = saved
            self.address = WalletService.shared.getEthereumAddress(from: saved) ?? ""
            WalletService.shared.getBalance(address: self.address) { self.balance = $0 }
        }
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
