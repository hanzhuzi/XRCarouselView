//
//  XRCarouselView.swift
//  XRCarouselScrollView
//
//  Created by xuran on 17/3/31.
//  Copyright © 2017年 黯丶野火. All rights reserved.
//

/**
 * 图片无限轮播图
 *
 * 目前只支持图片轮播，后面会加入gif图片，视频功能.
 *
 * @by Ran Xu
 */

import UIKit

#if DEBUG
// 只打印信息
fileprivate func XRLog(message: String) {
    print(message)
}
#else
fileprivate func XRLog(message: String) {}
#endif

@objc public protocol XRCarouselViewDelegate: NSObjectProtocol {
    
    @objc func carouselViewSetImageResource(targetImageView: UIImageView, imgRes: Any)
    @objc optional func carouselViewClickImageView(index: Int)
    @objc optional func carouselViewDidScroll(index: Int)
    @objc optional func carouselViewDidEndDecelerating(index: Int)
}

public enum XRCarouselIndicatorType {
    
    case page_control // pagecontrol 样式
    case number_view  // 数字样式
}

open class XRCarouselView: UIView {
    
    fileprivate lazy var carouseScrollView: UIScrollView = UIScrollView()
    fileprivate lazy var leftImageView: UIImageView = UIImageView()
    fileprivate lazy var centerImageView: UIImageView = UIImageView()
    fileprivate lazy var rightImageView: UIImageView = UIImageView()
    
    fileprivate var pageControl: UIPageControl!
    fileprivate var numberLbl: UILabel = UILabel(frame: CGRect.zero)
    
    open var pageControlBackgroundColor: UIColor = UIColor.clear {
        didSet {
            pageControl.backgroundColor = pageControlBackgroundColor
        }
    }
    open var pageIndicatorTintColor: UIColor = UIColor.lightGray {
        didSet {
            pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        }
    }
    open var currentPageIndicatorTintColor: UIColor = UIColor.yellow {
        didSet {
            pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        }
    }
    
    // 当只有一个资源(图片)时是否启用滚动，默认不启用
    open var isScrollEnabledWhenOneResource: Bool = false
    
    // 是否自动轮播，也可调用`beginAutoScrollCarouselView`方法在合适的地方实现自动轮播
    public var isAutoCarousel: Bool = false
    // 轮播时间
    open var speedTime: Double = 1.0 {
        didSet {
            if isAutoCarousel {
                self.stopTimer()
                self.startTimer()
            }
        }
    }
    
    // 资源数组，可以为网络图片，本地图片，本地图片Data，map的数据模型...
    open var assetResArray: [Any] = [] {
        didSet {
            self.resetCarouselScroll()
        }
    }
    
    // 占位图片
    open var placeHolderImage: UIImage?
    // 滚动指示器类型，系统pageControl类型，数字显示类型
    open var indicatorType: XRCarouselIndicatorType = .page_control {
        
        didSet {
            if indicatorType == .page_control {
                self.pageControl.isHidden = false
                self.numberLbl.isHidden = true
            }
            else {
                self.pageControl.isHidden = true
                self.numberLbl.isHidden = false
            }
        }
    }
    open weak var delegate: XRCarouselViewDelegate?
    
    fileprivate var curPage: Int = 0
    fileprivate var timer: Timer?
    
    deinit {
        XRLog(message: "XRCarouselView is dealloc!")
        self.stopTimer()
    }
    
    // for code
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialzitionCarouseScrollView()
        self.initialzitionPageControl()
        self.initlzationNumberLabel()
    }
    
    // for xib
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialzitionCarouseScrollView()
        self.initialzitionPageControl()
        self.initlzationNumberLabel()
    }
    
    // convenience method
    convenience init(frame: CGRect, delegate: XRCarouselViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        self.superview?.setNeedsLayout()
        self.superview?.layoutIfNeeded()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        carouseScrollView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        carouseScrollView.contentSize = CGSize(width: self.frame.size.width * 3.0, height: 0)
        carouseScrollView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        leftImageView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: carouseScrollView.frame.size.height)
        centerImageView.frame = CGRect(x: self.frame.size.width, y: 0, width: self.frame.size.width, height: carouseScrollView.frame.size.height)
        rightImageView.frame = CGRect(x: self.frame.size.width * 2.0, y: 0, width: self.frame.size.width, height: carouseScrollView.frame.size.height)
        
        pageControl.frame = CGRect(x: 0, y: self.frame.size.height - 40.0, width: self.frame.size.width, height: 40.0)
        numberLbl.frame = CGRect(x: self.frame.size.width - 60, y: self.frame.size.height - 28, width: 42, height: 20)
        
        carouseScrollView.setContentOffset(CGPoint(x: self.frame.size.width, y: 0), animated: false)
    }
    
    fileprivate func initialzitionCarouseScrollView() {
        
        carouseScrollView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        carouseScrollView.backgroundColor = UIColor.white
        carouseScrollView.showsHorizontalScrollIndicator = false
        carouseScrollView.showsVerticalScrollIndicator = false
        carouseScrollView.isPagingEnabled = true
        carouseScrollView.decelerationRate = UIScrollView.DecelerationRate.normal
        carouseScrollView.bounces = true
        carouseScrollView.delegate = self
        
        self.addSubview(carouseScrollView)
        
        leftImageView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: carouseScrollView.frame.size.height)
        centerImageView.frame = CGRect(x: self.frame.size.width, y: 0, width: self.frame.size.width, height: carouseScrollView.frame.size.height)
        rightImageView.frame = CGRect(x: self.frame.size.width * 2.0, y: 0, width: self.frame.size.width, height: carouseScrollView.frame.size.height)
        
        leftImageView.isUserInteractionEnabled = true
        centerImageView.isUserInteractionEnabled = true
        rightImageView.isUserInteractionEnabled = true
        
        leftImageView.backgroundColor = UIColor.white
        centerImageView.backgroundColor = UIColor.white
        rightImageView.backgroundColor = UIColor.white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageViewClick(tap:)))
        tapGesture.numberOfTapsRequired = 1
        carouseScrollView.addGestureRecognizer(tapGesture)
        
        carouseScrollView.addSubview(leftImageView)
        carouseScrollView.addSubview(centerImageView)
        carouseScrollView.addSubview(rightImageView)
        
        carouseScrollView.contentSize = CGSize(width: self.frame.size.width * 3.0, height: 0)
    }
    
    fileprivate func initialzitionPageControl() {
        
        pageControl = UIPageControl(frame: CGRect(x: 0, y: self.frame.size.height - 40.0, width: self.frame.size.width, height: 40.0))
        pageControl.isUserInteractionEnabled = false
        pageControl.backgroundColor = pageControlBackgroundColor
        pageControl.numberOfPages = self.assetResArray.count
        pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        pageControl.defersCurrentPageDisplay = false
        
        self.addSubview(pageControl)
    }
    
    fileprivate func initlzationNumberLabel() {
        
        self.addSubview(numberLbl)
        numberLbl.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        numberLbl.frame = CGRect(x: self.frame.size.width - 60, y: self.frame.size.height - 28, width: 42, height: 20)
        numberLbl.layer.masksToBounds = true
        numberLbl.layer.cornerRadius = 10
        
        numberLbl.textAlignment = .center
        numberLbl.textColor = UIColor.white
        numberLbl.font = UIFont.systemFont(ofSize: 10)
        numberLbl.numberOfLines = 1
        
        numberLbl.text = "0/0"
    }
    
    // MARK: - methods
    @objc fileprivate func imageViewClick(tap: UITapGestureRecognizer) {
        
        if delegate != nil && delegate!.responds(to: #selector(XRCarouselViewDelegate.carouselViewClickImageView(index:))) {
            delegate!.carouselViewClickImageView!(index: curPage)
        }
    }
    
    fileprivate func resetCarouselScroll() {
        
        if assetResArray.count == 0 { return }
        
        pageControl.numberOfPages = self.assetResArray.count
        numberLbl.text = "1/\(self.assetResArray.count)"
        
        if assetResArray.count == 1 {
            if isScrollEnabledWhenOneResource {
                carouseScrollView.isScrollEnabled = true
                if indicatorType == .page_control {
                    self.pageControl.isHidden = false
                    self.numberLbl.isHidden = true
                }
                else {
                    self.pageControl.isHidden = true
                    self.numberLbl.isHidden = false
                }
            }
            else {
                carouseScrollView.isScrollEnabled = false
                pageControl.isHidden = true
                numberLbl.isHidden = false
            }
        }
        else {
            carouseScrollView.isScrollEnabled = true
            if indicatorType == .page_control {
                self.pageControl.isHidden = false
                self.numberLbl.isHidden = true
            }
            else {
                self.pageControl.isHidden = true
                self.numberLbl.isHidden = false
            }
        }
        
        let leftIndex = (curPage - 1 + assetResArray.count) % assetResArray.count
        let centerIndex = curPage
        let rightIndex = (curPage + 1 + assetResArray.count) % assetResArray.count
        
        if leftIndex >= assetResArray.count {
            return
        }
        
        if centerIndex >= assetResArray.count {
            return
        }
        
        if rightIndex >= assetResArray.count {
            return
        }
        
        let leftAnyRes = assetResArray[leftIndex]
        let centerAnyRes = assetResArray[centerIndex]
        let rightAnyRes = assetResArray[rightIndex]
        
        if delegate != nil && delegate!.responds(to: #selector(XRCarouselViewDelegate.carouselViewSetImageResource(targetImageView:imgRes:))) {
            delegate!.carouselViewSetImageResource(targetImageView: leftImageView, imgRes: leftAnyRes)
            delegate!.carouselViewSetImageResource(targetImageView: centerImageView, imgRes: centerAnyRes)
            delegate!.carouselViewSetImageResource(targetImageView: rightImageView, imgRes: rightAnyRes)
        }
        
        carouseScrollView.setContentOffset(CGPoint(x: carouseScrollView.frame.width, y: 0), animated: false)
    }
    
    // MARK: - private method
    fileprivate func startTimer() {
        
        if timer != nil { return }
        if speedTime <= 0.01 { return }
        timer = Timer.scheduledTimer(timeInterval: speedTime,
                                     target: self,
                                     selector: #selector(XRCarouselView.scrollToNextPage),
                                     userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func scrollToNextPage() {
        
        if assetResArray.count == 0 {
            return
        }
        
        if carouseScrollView.isDragging || carouseScrollView.isDecelerating {
            return
        }
        
        carouseScrollView.setContentOffset(CGPoint(x: carouseScrollView.frame.width * 2.0, y: 0), animated: true)
    }
    
    // MARK: - Public Methods
    // 销毁定时器
    // MARK: 为了使‘XRCarouselView’释放，需要在ViewController的deinit中调用此方法
    open func stopTimer() {
        
        if let tm = timer, tm.isValid {
            tm.invalidate()
            timer = nil
        }
    }
    
    // MARK: - 调用该方法开始循环滚动轮播图
    open func beginAutoScrollCarouselView() {
        
        if self.assetResArray.count > 0 {
            isAutoCarousel = true
            self.startTimer()
        }
    }
    
}

// MARK: - UIScrollViewDelegate
extension XRCarouselView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if assetResArray.count == 0 {
            return
        }
        
        let offSetX = scrollView.contentOffset.x
        
        if offSetX <= 0 {
            curPage = (curPage - 1 + assetResArray.count) % assetResArray.count
            self.resetCarouselScroll()
        }
        else if offSetX >= scrollView.frame.width * 2.0 {
            curPage = (curPage + 1 + assetResArray.count) % assetResArray.count
            self.resetCarouselScroll()
        }
        
        if delegate != nil && delegate!.responds(to: #selector(XRCarouselViewDelegate.carouselViewDidScroll(index:))) {
            delegate!.carouselViewDidScroll!(index: curPage)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopTimer()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        numberLbl.text = "\(curPage + 1)/\(assetResArray.count)"
        if curPage < self.assetResArray.count && self.pageControl.currentPage != curPage {
            self.pageControl.currentPage = curPage
        } 
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutoCarousel {
            self.startTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isAutoCarousel {
            self.startTimer()
        }
        
        let offSetX = scrollView.contentOffset.x
        if curPage < self.assetResArray.count {
            self.pageControl.currentPage = curPage
            self.numberLbl.text = "\(curPage + 1)/\(assetResArray.count)"
        }
        if offSetX > scrollView.frame.width && offSetX < scrollView.frame.width * 2.0 {
            self.scrollToNextPage()
        }
        
        if delegate != nil && delegate!.responds(to: #selector(XRCarouselViewDelegate.carouselViewDidEndDecelerating(index:))) {
            delegate?.carouselViewDidEndDecelerating!(index: curPage)
        }
    }
    
}



