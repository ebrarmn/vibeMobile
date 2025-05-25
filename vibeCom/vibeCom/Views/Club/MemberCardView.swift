import SwiftUI

struct MemberCardView: View {
    let user: AppUser
    let showRemove: Bool
    var onRemove: (() -> Void)? = nil
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 40, height: 40)
                AsyncImage(url: URL(string: user.photoURL)) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.fill")
                        .resizable()
                        .foregroundColor(.blue)
                        .opacity(0.7)
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(user.email)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if showRemove, let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red)
                        .padding(6)
                        .background(Color.red.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Üyeyi kulüpten çıkar")
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue.opacity(0.08), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        .animation(.easeInOut(duration: 0.12), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .padding(.vertical, 3)
    }
} 