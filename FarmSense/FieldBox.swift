import SwiftUI

struct FieldBox: View {
    let name: String
    let status: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(.subheadline.bold())
            Text(status)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding()
        .background(color.opacity(0.25))
        .cornerRadius(12)
    }
}

#Preview {
    FieldBox(name: "Field A", status: "Good", color: .green)
}
