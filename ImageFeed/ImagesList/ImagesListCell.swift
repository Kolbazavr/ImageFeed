import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    let cellImage: ParallaxImageView = {
        let imageView = ParallaxImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .likeButtonOff), for: .normal)
        button.setImage(UIImage(resource: .likeButtonOn), for: .selected)
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func loadPhoto(photo: UnsplashPhoto?, isLiked: Bool) throws {
        guard let photo, let url = URL(string: photo.urls.small) else {
            cellImage.image = UIImage(systemName: "bandage")
            print("Bad Photo URL")
            throw URLError.invalidURL
        }
        
        setPhotoDate(from: photo)
        likeButton.isSelected = isLiked
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url, placeholder: UIImage(), options: [.transition(.flipFromLeft(0.3))]) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                break
            case .failure:
                self.cellImage.image = UIImage(systemName: "bandage")
                print("KF failed to download image")
            }
        }
    }
    
    func parallax(offset: CGFloat) {
        cellImage.parallaxEffect(offset: offset)
    }
    
    private func setPhotoDate(from photo: UnsplashPhoto) {
        guard let date = ISO8601DateFormatter().date(from: photo.createdAt ?? "") else { return }
        dateLabel.text = DateFormatter.defaultDateTime.string(from: date)
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cellImage)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor, constant: 0),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 0),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(greaterThanOrEqualTo: cellImage.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8),
            ])
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func likeButtonTapped() {
        likeButton.isSelected.toggle()
    }
}
