import SwiftUI
import AppKit

struct FooterLinkView: View {
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 6) {
            Text("Diğer uygulamalarımız için")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
            
            Button(action: {
                if let url = URL(string: "https://www.example.com") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 10))
                    
                    Text("sitemizi ziyaret edebilirsiniz")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(isHovering ? .blue : .cyan.opacity(0.9))
                .underline(isHovering)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }
}

