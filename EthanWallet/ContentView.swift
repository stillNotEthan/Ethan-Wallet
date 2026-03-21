//
//  ContentView.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/18.
//

import SwiftUI

struct ContentView: View {
    @State private var mnemonic: String = ""
    @State private var address: String = ""
    @State private var balance: String = "Checking..."
    @State private var recipient: String = ""
    @State private var amount: String = "0.01"
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Web3 Wallet Starter")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if !mnemonic.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Mnemonic (Keep it safe!):").font(.headline)
                    Text(mnemonic)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .contrast(10)
                    Text("Your Ethereum Address:")
                        .font(.headline)
                    Text(address)
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    
                    Text("Your Balance:")
                        .font(.headline)
                    Text(balance)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
                .padding()
            }
            
            Button(action: {
                let newMnemonic = WalletService.shared.generateMnemonic()
                let _newAddress = WalletService.shared.getEthereumAddress(from: newMnemonic)
                
                // 存入 Keychain
                WalletService.shared.saveMnemonic(newMnemonic)
                
                self.mnemonic = newMnemonic
                self.address = _newAddress ?? "Error"
                self.balance = "Fetching..."
                
                // 查询余额
                if let addr = _newAddress {
                    WalletService.shared.getBalance(address: addr) {result in self.balance = result}
                }
            }) {
                Text("Generate New Wallet")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            Spacer()
            
            TextField("Recipient Address (0x...)", text: $recipient)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                if let signedTx = WalletService.shared.signTransaction(
                    mnemonic: self.mnemonic,
                    toAddress: self.recipient,
                    amountInEth: Double(self.amount) ?? 0.0
                ) {
                    print("\(self.recipient)")
                    print("Signed Transaction: 0x\(signedTx)")
                    
                    WalletService.shared.broadcastTransaction(signedHex: signedTx) {result in
                        print("Broadcast Result: \(result)")
                        self.balance = result
                    }
                }
            }) {
                Text("Sign & Send Transaction")
                    .bold()
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            // App启动时检查是否有存过的钱包
            if let savedMnemonic = WalletService.shared.loadMnemonic() {
                self.mnemonic = savedMnemonic
                if let addr = WalletService.shared.getEthereumAddress(from: savedMnemonic) {
                    self.address = addr
                    // 自动查询余额
                    WalletService.shared.getBalance(address: addr) {
                        res in self.balance = res
                    }
                }
            }
        }
        .padding()
    }
}
