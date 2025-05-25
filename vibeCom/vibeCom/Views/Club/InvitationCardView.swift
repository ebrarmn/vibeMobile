import SwiftUI

struct InvitationCardView: View {
    let invitation: ClubInvitation
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "envelope.open.fill")
                .resizable()
                .frame(width: 36, height: 28)
                .foregroundColor(.orange)
                .padding(6)
                .background(Color.orange.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(invitation.senderName)
                    .font(.headline)
                Text("Bekleyen Davet")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            Spacer()
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        .padding(.vertical, 4)
    }
} 