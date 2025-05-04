import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let currentDate = DateFormatter.defaultDateTime.string(from: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollViewDidScroll(tableView)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return }

        cell.cellImage.image = image
        cell.cellImage.layer.cornerRadius = 16
        cell.dateLabel.text = currentDate

        let likeImage = indexPath.row % 2 == 0 ? UIImage(resource: .likeButtonOff) : UIImage(resource: .likeButtonOn)
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return 0 }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells = tableView.visibleCells.compactMap { $0 as? ImagesListCell }
        for cell in visibleCells {
            let cellCenter = scrollView.convert(cell.center, to: view)
            let scrollCenter = view.bounds.midY
            let maxOffset = view.bounds.height
            let relativeOffsetY = (cellCenter.y - scrollCenter) / maxOffset
            cell.parallax(offset: relativeOffsetY)
        }
    }
}
