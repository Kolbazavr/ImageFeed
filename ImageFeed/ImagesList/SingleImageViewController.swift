import UIKit

final class SingleImageViewController: UIViewController {
    
    let largeImageURL: String
    let image: UIImage
    let loadingIndicator: SomeLoadingIndicator = .shared
    
    init(largeImageURL: String, image: UIImage) {
        self.largeImageURL = largeImageURL
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .navBackButtonWhite), for: .normal)
        button.tintColor = .ypWhite
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .sharingButton), for: .normal)
        button.tintColor = .ypWhite
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setupUI()
        imageView.image = image
        imageView.frame.size = image.size
        fitImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        downloadFullSize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideLoadingIndicator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerImage()
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func downloadFullSize() {
        showLoadingIndicator()
        guard let largeImageURL = URL(string: largeImageURL) else { return }
        imageView.kf.setImage(with: largeImageURL, placeholder: image) { [weak self] result in
            guard let self else { return }
            self.hideLoadingIndicator()
            switch result {
            case .success:
                break
            case .failure:
                print(#function, "Failed to download full size image for \(largeImageURL)")
                showError()
            }
        }
    }
    
    @MainActor
    private func showLoadingIndicator() {
        loadingIndicator.show()
    }
    
    @MainActor
    private func hideLoadingIndicator() {
        loadingIndicator.hide()
    }
    
    @MainActor
    private func showError() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Не надо", style: .default))
        alertController.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { _ in
            self.downloadFullSize()
        }))
        present(alertController, animated: true)
    }
    
    private func fitImage() {
        view.layoutIfNeeded()
        let widthRatio = scrollView.bounds.width / imageView.frame.width
        let heightRatio = scrollView.bounds.height / imageView.frame.height
        let minRatio = min(widthRatio, heightRatio)
        scrollView.setZoomScale(minRatio, animated: false)
        scrollView.layoutIfNeeded()
    }
    
    private func centerImage() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        imageView.center = CGPoint(
            x: scrollView.contentSize.width * 0.5 + offsetX,
            y: scrollView.contentSize.height * 0.5 + offsetY
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        
        self.navigationController?.isNavigationBarHidden = true
        
        scrollView.addSubview(imageView)
        [scrollView, backButton, shareButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),
            
            shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

