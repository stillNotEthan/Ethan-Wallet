//
//  AssetListView.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/28.
//

import SwiftUI

struct AssetListView: View {
    let tokens: [Token]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Tokens List")
                .font(.title3)
                .bold()
                .padding(.horizontal)
            
            ForEach(tokens) { token in
                NavigationLink(value: token) {
                    TokenRow(token: token)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// 进一步拆分每一行
struct TokenRow: View {
    let token: Token
    
    var body: some View {
        HStack {
            Image(systemName: token.iconName)
                .font(.title)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(token.symbol).bold()
                Text(token.name).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text("\(token.balance) \(token.symbol)").bold()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
