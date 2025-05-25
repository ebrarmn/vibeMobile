import SwiftUI

struct CircularTabBarProfileImageView: UIViewRepresentable {
    let image: UIImage?
    let size: CGFloat

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = size / 2
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.systemGray6
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.image = image
        uiView.layer.cornerRadius = size / 2
    }
} 