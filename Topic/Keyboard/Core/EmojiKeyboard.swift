//
//  EmojiKeyboard.swift
//  Topic
//
//  Created by youzy01 on 2019/11/12.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

private let Screen_Width = UIScreen.main.bounds.width

protocol EmojiKeyboardDelegate: class {
    func emojikeyboard(_ emojikeyboard: EmojiKeyboard, didCheckItem emoji: Emoji)
    func emojikeyboardDidSelectDelete(_ emojikeyboard: EmojiKeyboard)
    func emojikeyboardDidSelectSend(_ emojikeyboard: EmojiKeyboard)
}

class EmojiKeyboard: UIView, NibLoadable {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!

    var dataSource: [Emoji] = []

    weak var delegate: EmojiKeyboardDelegate?

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 370)
    }

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 370))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViewFromNib()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViewFromNib()
        setup()
    }

    @IBAction func deleteAction() {
        delegate?.emojikeyboardDidSelectDelete(self)
    }

    @IBAction func sendAction() {
        delegate?.emojikeyboardDidSelectSend(self)
    }
}

extension EmojiKeyboard {
    func setup() {
        if let path = Bundle.main.url(forResource: "EmojiInfo.plist", withExtension: nil) {
            do {
                let data = try Data(contentsOf: path)
                dataSource = try PropertyListDecoder().decode([Emoji].self, from: data)
            } catch {
                print(error)
            }
        }
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 30, right: 16)
        let width = (Screen_Width - 32) / 7
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.register(EmojiCell.nib, forCellWithReuseIdentifier: EmojiCell.reuseableIdentifier)
    }
}

extension EmojiKeyboard: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 2
//    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseableIdentifier, for: indexPath) as! EmojiCell
        let emoji = dataSource[indexPath.item]
        cell.imageView.image = emoji.image
        return cell
    }
}

extension EmojiKeyboard: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = dataSource[indexPath.item]
        delegate?.emojikeyboard(self, didCheckItem: emoji)
    }
}
