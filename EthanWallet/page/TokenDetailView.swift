//
//  TokenDetailView.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/28.
//

import SwiftUI

struct TokenDetailView: View {
    let token: Token;
    @Environment(\.dismiss) var dismiss;
    @State private var isShowingSend = false
    @State private var isShowingReceive = false
    @State private var address: String = ""
    @State private var balance: String = "0.0000 ETH"
    
    var body: some View {
        ScrollView {
            VStack (spacing: 30) {
                // 1.代币头部展示
                VStack(spacing: 10) {
                    Image(systemName: token.iconName)
                        .font(.system(size:60))
                        .foregroundStyle(.blue)
                    
                    Text("\(token.balance) \(token.symbol)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    
                    Text(token.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                // 2.快捷操作按钮
                HStack(spacing: 40) {
                    ActionButton(icon: "arrow.up.circle.fill", title: String(localized: "Send")) {
                        // 触发针对该代币的发送逻辑
                        isShowingSend = true
                    }
                    
                    ActionButton(icon: "arrow.down.circle.fill", title: String(localized: "Receive")) {
                        // 这里可以触发针对该代币的接收逻辑
                        isShowingReceive = true
                    }
                }
                
                // 3. 合约信息卡片
                VStack(alignment: .leading, spacing: 15) {
                    Text("Contract Info")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(label: "Contract Address", value: token.contractAddress)
                        InfoRow(label: "Decimals", value: "\(token.decimal)")
                        InfoRow(label: "Network", value: "Ethereum Mainnet")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $isShowingSend) {
            SendView(currentBalance: balance, walletAddress: self.address)
        }
        .sheet(isPresented: $isShowingReceive) {
            ReceiveView(address: address)
        }
        .navigationTitle(token.symbol)
        .navigationBarTitleDisplayMode(.inline)
    }
}


// 辅助组件
struct InfoRow: View {
    let label: String;
    let value: String;
    var body: some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).bold().font(.system(.body, design: .monospaced))
        }
    }
}
