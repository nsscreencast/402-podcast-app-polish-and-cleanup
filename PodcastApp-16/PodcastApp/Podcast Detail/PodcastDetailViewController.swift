//
//  PodcastDetailViewController.swift
//  PodcastApp
//
//  Created by Ben Scheirman on 5/14/19.
//  Copyright © 2019 NSScreencast. All rights reserved.
//

import UIKit

class PodcastDetailViewController : UITableViewController {
    var podcastLookupInfo: PodcastLookupInfo!

    var podcast: Podcast? {
        didSet {
            headerViewController.podcast = podcast
            tableView.reloadData()
        }
    }

    var headerViewController: PodcastDetailHeaderViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = Theme.Colors.gray5
        tableView.separatorColor = Theme.Colors.gray4

        headerViewController = children.compactMap { $0 as? PodcastDetailHeaderViewController }.first

        loadPodcast()
    }

    private func loadPodcast() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PodcastFeedLoader().fetch(lookupInfo: podcastLookupInfo) { result in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch result {
            case .success(let podcast):
                self.podcast = podcast
            case .failure(let error):
                self.headerViewController.clearUI()
                print("Error with feed: \(self.podcastLookupInfo.feedURL.absoluteString)")
                let alert = UIAlertController(title: "Failed to Load Podcast", message: "Error loading feed: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                    self.loadPodcast()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcast?.episodes.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EpisodeCell = tableView.dequeueReusableCell(for: indexPath)

        if let episode = podcast?.episodes[indexPath.row] {
            let viewModel = EpisodeCellViewModel(episode: episode)
            cell.configure(with: viewModel)
        }

        return cell
    }

    // MARK: - Scrolling

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adjustHeaderParallax(scrollView)
    }

    private func adjustHeaderParallax(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let headerView = headerViewController.view
        if offsetY < 0 {
            headerView?.superview?.clipsToBounds = false
            headerView?.transform = CGAffineTransform(translationX: 0, y: offsetY/10)
            headerView?.alpha = 1.0
        } else {
            headerView?.superview?.clipsToBounds = true
            headerView?.transform = CGAffineTransform(translationX: 0, y: offsetY/3)
            headerView?.alpha = 1 - (offsetY / headerView!.frame.height * 0.9)
        }
    }

}
