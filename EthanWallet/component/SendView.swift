//
//  SendView.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/20.
//

import SwiftUI
import BigInt

struct SendView: View {
    // 获取环境中的dismiss动作
    @Environment(\.dismiss) var dismiss
    
    @State private var recipientAddress = ""
    @State private var amount = ""
    @State private var isValidating = false
    @State private var showConfirmAlert = false
    @State private var estimatedGasFee: String = "Calculation..."
    @State private var gasPrice: BigUInt = 0
    
    let currentBalance: String // 从 HomeView传进来
    let walletAddress: String
    
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
                    .font(.caption)
                    .foregroundStyle(.blue)
                }
                .padding(.horizontal)
                
                // GAS 费用展示区域
                HStack {
                    Image(systemName: "fuelpump.fill")
                        .foregroundStyle(.orange)
                    Text("Estimated Gas Fee:")
                        .font(.caption)
                    Spacer()
                    Text("\(estimatedGasFee) ETH")
                        .font(.caption)
                        .bold()
                }
                .padding()
                .background(Color.orange.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 输入区域
                VStack(alignment: .leading, spacing: 15) {
                    // 地址输入
                    VStack(alignment: .leading) {
                        Text("RECIPIENT ADDRESS")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        TextField("0x...", text: $recipientAddress)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // 金额输入
                    VStack(alignment: .leading) {
                        Text("AMOUNT (ETH)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        TextField("0.0", text: $amount)
                            .font(.system(.title2, design: .rounded))
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 发送按钮
                Button(action: {
                    if isValidAddress(recipientAddress) {
                        showConfirmAlert = true
                    }
                }) {
                    Text("Review Transaction")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                }
                .disabled(!isFormValid)
                .padding()
            }
            .navigationTitle("Send ETH")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Confirm Transaction", isPresented: $showConfirmAlert) {
                Button("Send", role: .none) {
                    sendTransaction()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You are sending \(amount) ETH to \(recipientAddress.prefix(6))...\(recipientAddress.suffix(4))")
            }
        }
        .onAppear {
            loadGasPrice()
        }
    }
    
    func loadGasPrice() {
        Task {
            do {
                let price = try await WalletService.fetchGasPrice()
                self.gasPrice = price
                // 假设普通转账消耗21000 GAS
                let totalGasWei = price * 21000
                let ethValue = Double(totalGasWei) / 1_000_000_000_000_000_000.0
                self.estimatedGasFee = String(format: "%.6f", ethValue)
            } catch {
                self.estimatedGasFee = "Error fetching gas"
            }
        }
    }
    
    var isFormValid: Bool {
        !recipientAddress.isEmpty && !amount.isEmpty && Double(amount) ?? 0 > 0
    }
    
    func sendTransaction() {
        guard let amountDouble = Double(amount) else { return }
        let mnemonic = WalletService.shared.loadMnemonic() ?? ""
        let amountInWei = BigUInt(amountDouble * 1_000_000_000_000_000_000.0)
        Task {
            do {
                let nonce = try await WalletService.fetchNonce(for: walletAddress)
                
                let signedTx =  WalletService.shared.signTransaction(
                    to: recipientAddress,
                    amount: amountInWei,
                    nonce: nonce,
                    gasPrice: self.gasPrice,
                    gasLimit: 21000,
                    mnemonic: mnemonic
                )
                
                // 1. 先安全地解包签名后的十六进制字符串
                if let txToBroadcast = signedTx {
                    
                    // 2. 直接调用函数，不需要赋值给 txHash（因为函数返回 Void）
                    WalletService.broadcastTransaction(signedHex: txToBroadcast) { result in
                        
                        // 这里的 result 包含了 "Success! hash: 0x..." 或者错误信息
                        print("Transaction Result: \(result)")
                        
                        if result.contains("Success") {
                            // 触发成功震动
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            
                            // 关闭弹窗
                            dismiss()
                        } else {
                            print("Failed to send: \(result)")
                        }
                    }
                } else {
                    // 如果 signedTx 为 nil，说明签名失败了
                    print("Error: Signed transaction is nil")
                }
                dismiss()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
