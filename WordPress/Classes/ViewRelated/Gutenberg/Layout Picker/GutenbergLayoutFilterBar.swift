import UIKit

protocol FilterBarDelegate {
    func numberOfFilters() -> Int
    func filter(forIndex: Int) -> GutenbergLayoutSection
    func willSelectFilter(forIndex: Int)
    func didSelectFilter(forIndex: Int)
    func didDeselectFilter(forIndex: Int)
}

class GutenbergLayoutFilterBar: UICollectionView {
    var filterDelegate: FilterBarDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(LayoutPickerFilterCollectionViewCell.nib, forCellWithReuseIdentifier: LayoutPickerFilterCollectionViewCell.cellReuseIdentifier)
        self.delegate = self
        self.dataSource = self
    }

    private func deselectItem(_ indexPath: IndexPath) {
        deselectItem(at: indexPath, animated: true)
        collectionView(self, didDeselectItemAt: indexPath)
    }
}

extension GutenbergLayoutFilterBar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.cellForItem(at: indexPath)?.isSelected ?? false {
            deselectItem(indexPath)
            return false
        }
        filterDelegate?.willSelectFilter(forIndex: indexPath.item)
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterDelegate?.didSelectFilter(forIndex: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        filterDelegate?.didDeselectFilter(forIndex: indexPath.item)
    }
}

extension GutenbergLayoutFilterBar: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let filter = filterDelegate?.filter(forIndex: indexPath.item) else {
            return CGSize(width: 105.0, height: 44.0)
        }

        let width = LayoutPickerFilterCollectionViewCell.estimatedWidth(forFilter: filter)
        return CGSize(width: width, height: 44.0)
     }
}

extension GutenbergLayoutFilterBar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterDelegate?.numberOfFilters() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LayoutPickerFilterCollectionViewCell.cellReuseIdentifier, for: indexPath) as! LayoutPickerFilterCollectionViewCell
        cell.filter = filterDelegate?.filter(forIndex: indexPath.item)
        return cell
    }
}