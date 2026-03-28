//
//  SettingsView.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/28.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var securityService = SecurityService()
    @State private var isShowingMnemonic = false
    @State private var isShowingResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // 第一组：安全与备份
                Section(header: Text("Security")) {
                    Button(action: {
                        // 1. 先触发 FaceID 验证
                        securityService.authenticate { success in
                            if success { isShowingMnemonic = true }
                        }
                    }) {
                        HStack {
                            Image(systemName: "key.fill").foregroundColor(.blue)
                            Text("Backup Mnemonic")
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                
                // 第二组：网络设置
                Section(header: Text("Network")) {
                    HStack {
                        Image(systemName: "network").foregroundColor(.green)
                        Text("Current Network")
                        Spacer()
                        Text("Ethereum Mainnet").foregroundColor(.secondary)
                    }
                }
                
                // 第三组：关于与支持
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary)
                    }
                }
                
                // 第四组：危险操作
                Section {
                    Button(role: .destructive, action: { isShowingResetAlert = true }) {
                        HStack {
                            Spacer()
                            Text("Reset Wallet")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            // 备份助记词的弹窗
            .sheet(isPresented: $isShowingMnemonic) {
                MnemonicBackupView()
            }
            // 重置钱包的二次确认
            .alert("Reset Wallet?", isPresented: $isShowingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset Everything", role: .destructive) {
                    // 这里执行清空 Keychain 的逻辑
                }
            } message: {
                Text("This will permanently delete your private key and mnemonic from this device. Make sure you have a backup!")
            }
        }
    }
}
