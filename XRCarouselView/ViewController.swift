//
//  ViewController.swift
//  XRCarouselView
//
//  Created by 徐冉 on 2019/9/23.
//  Copyright © 2019 QK. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    private lazy var mainCarouselView: XRCarouselView = XRCarouselView(frame: CGRect.zero)
    
    deinit {
        mainCarouselView.stopTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(mainCarouselView)
        mainCarouselView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: mainCarouselView,
                                                 attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil,
                                                 attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 0,
                                                 constant: UIScreen.main.bounds.size.width)
        
        let heightConstraint = NSLayoutConstraint(item: mainCarouselView,
                                                 attribute: NSLayoutConstraint.Attribute.height,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil,
                                                 attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 0,
                                                 constant: UIScreen.main.bounds.size.width / 375 * 186.0)
        
        mainCarouselView.addConstraints([widthConstraint, heightConstraint])
        
        let topConstraint = NSLayoutConstraint(item: mainCarouselView,
                                               attribute: NSLayoutConstraint.Attribute.top,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: self.view,
                                               attribute: NSLayoutConstraint.Attribute.topMargin,
                                               multiplier: 1.0,
                                               constant: 0)
        
        let centerXConstraint = NSLayoutConstraint(item: mainCarouselView,
                                                   attribute: NSLayoutConstraint.Attribute.centerX,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view,
                                                   attribute: NSLayoutConstraint.Attribute.centerX,
                                                   multiplier: 1.0, constant: 0)
        
        self.view.addConstraints([topConstraint, centerXConstraint])
        
        
        mainCarouselView.delegate = self
        
        mainCarouselView.speedTime = 2.0
        mainCarouselView.indicatorType = .page_control
        mainCarouselView.pageIndicatorTintColor = UIColor.lightGray
        mainCarouselView.currentPageIndicatorTintColor = UIColor.white
        
        mainCarouselView.assetResArray = ["https://uploadfile.huiyi8.com/2014/0705/20140705042540704.jpg",
                                          "https://p.ssl.qhimg.com/dmfd/400_300_/t0120b2f23b554b8402.jpg",
                                          "http://seopic.699pic.com/photo/50035/0520.jpg_wh1200.jpg",
                                          "http://static.runoob.com/images/demo/demo4.jpg",
                                          "http://b4-q.mafengwo.net/s9/M00/3C/CE/wKgBs1e2fn2APHx8AAsH-anXLUU29.jpeg"]
        
        mainCarouselView.beginAutoScrollCarouselView()
    }
    

}

// MARK: - XRCarouselViewDelegate
extension ViewController: XRCarouselViewDelegate {
    
    // 设置图片
    func carouselViewSetImageResource(targetImageView: UIImageView, imgRes: Any) {
        
        if let urlStr = imgRes as? String {
            let url = URL(string: urlStr)
            
            let processor = DownsamplingImageProcessor(size: targetImageView.bounds.size) >> RoundCornerImageProcessor(cornerRadius: 0)
            
            targetImageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor),
                .transition(.fade(0.3)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage], progressBlock: { (_, _) in
                
            }) { (result) in
                
            }
        }
        else if let url = imgRes as? URL {
            // ...
        }
    }
    
    func carouselViewClickImageView(index: Int) {
        
        let detailsViewCtrl = DetailsViewController()
        self.navigationController?.pushViewController(detailsViewCtrl, animated: true)
        
        debugPrint("点击了'\(index)'张图片")
    }
    
    func carouselViewDidScroll(index: Int) {
        
    }
}

