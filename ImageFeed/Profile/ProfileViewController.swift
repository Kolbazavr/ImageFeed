import UIKit
import Kingfisher

protocol ProfileViewProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    var coordinator: FeedCoordinatorProtocol? { get set }
    var loadingIndicator: SomeLoadingIndicator { get }
    
    func updateAvatar(from url: URL)
    func updateProfileDetails(profile: UnsplashUser)
    func confirmLogout() async -> Bool
}

final class ProfileViewController: UIViewController, CoordinatedByFeedProtocol, ProfileViewProtocol {
    weak var coordinator: FeedCoordinatorProtocol?
    var presenter: ProfilePresenterProtocol?
    let loadingIndicator: SomeLoadingIndicator = .shared
    
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    func updateAvatar(from url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "ev.plug.dc.nacs.fill"), options: [.processor(processor)])
    }
    
    func updateProfileDetails(profile: UnsplashUser) {
        loginNameLabel.text = "@\(profile.username)"
        nameLabel.text = profile.nameToDisplay
        descriptionLabel.text = profile.bio
    }
    
    func confirmLogout() async -> Bool {
        await showConfirmationAlert(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            cancelText: "Нет",
            confirmActionText: "Да")
    }
    
    @objc private func didTapLogoutButton() {
        presenter?.didTapLogout()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        avatarImageView.image = UIImage(resource: .avatar)
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.layer.masksToBounds = true
        
        nameLabel.text = ""
        nameLabel.textColor = .ypWhite
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        
        loginNameLabel.text = ""
        loginNameLabel.textColor = .ypGray
        loginNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        descriptionLabel.text = ""
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        logoutButton.setImage(.logoutButton, for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.accessibilityIdentifier = "logoutButton"
        
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
