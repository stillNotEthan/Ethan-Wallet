//
//  MnemonicBackupVIew.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/28.
//

import SwiftUI

struct MnemonicBackupView: View {
    @Environment(\.dismiss) var dismiss
    // 假设你已经从 Keychain 中读取到了助记词
    let mnemonic = "apple banana cherry dog elephant fox grape hat ice jacket kite lemon"
    
    var body: some View {
        VStack(spacing: 30) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top)
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Never share your mnemonic!")
                .font(.title2).bold()
            
            Text("Anyone with these 12 words can steal your funds. Write them down on paper and keep them safe.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 助记词展示网格
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                let words = mnemonic.components(separatedBy: " ")
                ForEach(0..<words.count, id: \.self) { index in
                    HStack {
                        Text("\(index + 1).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(words[index])
                            .bold()
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
            
            Spacer()
            
            Button("I've backed it up") { dismiss() }
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
                .padding()
        }
    }
}
