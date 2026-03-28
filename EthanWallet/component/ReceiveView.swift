//
//  ReceiveView.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/20.
//

import SwiftUI

struct ReceiveView: View {
    let address: String
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Scan to receive funds")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // 1. 二维码卡片
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("AppBackground"))
                        .shadow(color: .black.opacity(0.1), radius: 10)
                    
                    if let qrImage = generateQRCode(from: address) {
                        Image(uiImage: qrImage)
                            .interpolation(.none) // 保持二维码清晰
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                    }
                }
                .frame(width: 250, height: 250)
                
                // 2. 地址展示与点击复制
                VStack(spacing: 10) {
                    Text("Your Ethereum Address")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.secondary)
                    
                    Button(action: copyToClipboard) {
                        Text(address)
                            .font(.system(.callout, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                
                if showCopyToast {
                    Text("Address Copied!")
                        .font(.caption)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.8))
                        .foregroundStyle(.white)
                        .cornerRadius(20)
                        .transition(.opacity)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Receive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    func copyToClipboard() {
        UIPasteboard.general.string = address
        
        // 触发触感反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            showCopyToast = true
        }
        
        // 2秒后隐藏提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopyToast = false
            }
        }
    }
}
