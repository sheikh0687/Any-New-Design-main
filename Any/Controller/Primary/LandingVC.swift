
import UIKit

class LandingCell: UICollectionViewCell {
    @IBOutlet weak var bottom_Lead: NSLayoutConstraint!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_Detail: UILabel!
}

class LandingVC: UIViewController {

    @IBOutlet weak var btn_GetSS: UIButton!
    //@IBOutlet weak var pageControl: CustomPageControl!
    @IBOutlet weak var collectionViewOt: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var arr_Image: [String] = ["logo","location_pin","slidewatch","slidesearch"]
    var arr_Name: [String] = ["Welcome to ANY","ANY Place","ANY Time","ANY WORK"]
    var arr_Descr: [String] = ["Find jobs and get workers\nINSTANTLY","We will help you find the best available jobs in your location for your convenience","You can find jobs while drinking your morning coffee or while sipping your tea before bed","You can find jobs while drinking your morning coffee or while sipping your tea before bed"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true

    }
    
    @IBAction func Login(_ sender: Any) {
        let vc = Mainboard.instantiateViewController(withIdentifier: "LoginTypeVC") as! LoginTypeVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func btnGetStarted(_ sender: UIButton) {
        let vc = Mainboard.instantiateViewController(withIdentifier: "LoginTypeVC") as! LoginTypeVC
        self.navigationController?.pushViewController(vc, animated: false)

    }
}

extension LandingVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LandingCell", for: indexPath) as! LandingCell
        cell.img.image = UIImage.init(named: arr_Image[indexPath.row])
        cell.lbl_title.text = arr_Name[indexPath.row]
        cell.lbl_Detail.text = arr_Descr[indexPath.row]
     
        return cell
    }
}

extension LandingVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widths = UIScreen.main.bounds.width // 414
        return CGSize(width: widths, height: self.collectionViewOt.frame.height)
    }
}

extension LandingVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.pageControl.currentPage = indexPath.row
    }
}
class CustomPageControl: UIPageControl {

@IBInspectable var currentPageImage: UIImage?

@IBInspectable var otherPagesImage: UIImage?

override var numberOfPages: Int {
    didSet {
        updateDots()
    }
}

override var currentPage: Int {
    didSet {
        updateDots()
    }
}

override func awakeFromNib() {
    super.awakeFromNib()
    pageIndicatorTintColor = .clear
    currentPageIndicatorTintColor = .clear
    clipsToBounds = false
}

private func updateDots() {

    for (index, subview) in subviews.enumerated() {
        let imageView: UIImageView
        if let existingImageview = getImageView(forSubview: subview) {
            imageView = existingImageview
        } else {
            imageView = UIImageView(image: otherPagesImage)

            imageView.center = subview.center
            subview.addSubview(imageView)
            subview.clipsToBounds = false
        }
        imageView.image = currentPage == index ? currentPageImage : otherPagesImage
    }
}

private func getImageView(forSubview view: UIView) -> UIImageView? {
    if let imageView = view as? UIImageView {
        return imageView
    } else {
        let view = view.subviews.first { (view) -> Bool in
            return view is UIImageView
        } as? UIImageView

        return view
    }
}
}
