//
//  SendView.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/20.
//

import SwiftUI

struct SendView: View {
    // 获取环境中的dismiss动作
    @Environment(\.dismiss) var dismiss
    
    @State private var recipientAddress = ""
    @State private var amount = ""
    @State private var isValidating = false
    @State private var showConfirmAlert = false
    
    let currentBalance: String // 从 HomeView传进来
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 余额展示
                HStack {
                    Text("Balance: \(currentBalance) ETH")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Max") {
                        // 简单处理： 填入全部余额（实际需扣除Gas）
                        amount = currentBalance
                    }
                }
            }
        }
    }
}
