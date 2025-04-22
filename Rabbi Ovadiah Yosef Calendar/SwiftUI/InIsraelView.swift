//
//  InIsraelView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 4/7/25.
//

import SwiftUI

struct InIsraelView: View {
    @State private var isInIsrael: Bool? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Are you currently in Israel?")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 40) {
                Button(action: {
                    isInIsrael = true
                    // handle "Yes" logic here
                }) {
                    Text("Yes")
                        .frame(width: 100, height: 44)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    isInIsrael = false
                    // handle "No" logic here
                }) {
                    Text("No")
                        .frame(width: 100, height: 44)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            if let answer = isInIsrael {
                Text("You answered: \(answer ? "Yes" : "No")")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }

            Spacer()
        }
        .padding()
    }
}


#Preview {
    InIsraelView()
}
