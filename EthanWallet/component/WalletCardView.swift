//
//  WalletCardView.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/20.
//

import SwiftUI


struct WalletCardView: View {
    let address: String
    let balance: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.title)
                Text("Ethereum Network")
                    .font(.headline)
                Spacer()
                Image(systemName: "network")
            }
            
            Spacer()
            
            Text(balance)
                .font(.system(size: 34, weight: .bold, design: .rounded))
            
            Text(shortenAddress(address))
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
        }
        .padding(25)
        .frame(height: 200)
        .foregroundStyle(Theme.primaryGradient)
        .cornerRadius(25)
        .shadow(color: Color.purple.opacity(0.3), radius: 15, x: 0, y: 10)
    }
}
