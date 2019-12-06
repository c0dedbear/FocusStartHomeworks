//
//  Cell.swift
//  MarvelHeroes
//
//  Created by Stanislav on 06/12/2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//
import UIKit

final class Cell: UITableViewCell
{

	var cellImageView = UIImageView()
	var cellTitle = UILabel()
	var cellDetails = UILabel()
	var imageURL: URL? {
		didSet {
			cellImageView.image = nil
			updateImageOnCell()
		}
	}

	private var space: CGFloat = Constants.space

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupCell()
	}

	@available(*, unavailable) required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
	}

	private func setupCell() {
		let margins = self.layoutMarginsGuide
		self.accessoryType = .disclosureIndicator
		cellDetails.textColor = .gray
		cellDetails.font = UIFont.systemFont(ofSize: 15)
		cellImageView.contentMode = .scaleAspectFit
		self.addSubview(cellImageView)
		self.addSubview(cellTitle)
		self.addSubview(cellDetails)
		cellImageView.translatesAutoresizingMaskIntoConstraints = false
		cellTitle.translatesAutoresizingMaskIntoConstraints = false
		cellDetails.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			cellImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: space),
			cellImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -space),
			cellImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: space),
			cellImageView.widthAnchor.constraint(equalTo: cellImageView.heightAnchor),
			cellTitle.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: space),
			cellTitle.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -space * 2),
			cellTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: space),
			cellDetails.topAnchor.constraint(equalTo: cellTitle.bottomAnchor, constant: space),
			cellDetails.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: space),
			cellDetails.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -space * 2),
		])
	}

	private func updateImageOnCell() {
		if let url = imageURL {
			if let imageFromCache = Cache.imageCache.object(forKey: url as AnyObject) as? UIImage {
				self.cellImageView.image = imageFromCache
			}
			else {
				DispatchQueue.global(qos: .userInitiated).async {
					let contentsOfURL = try? Data(contentsOf: url)
					DispatchQueue.main.async {
						//Для того чтоб картинки не мелькали изза загрузки в разынх потоках
						//будем сранивать url и imageUrl
						if url == self.imageURL {
							if let imageData = contentsOfURL, let image = UIImage(data: imageData)  {
								self.cellImageView.image = image
								Cache.imageCache.setObject(image, forKey: url as AnyObject)
							}
						}
					}
				}
			}
		}
	}
}
