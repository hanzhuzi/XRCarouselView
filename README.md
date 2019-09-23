# **XRCarouselView**

- 无限滚动轮播视图。Infinite scrolling carousel view.

## How to Use `XRCarouselView`(如何使用？)

### Manual import

Download XRCarouselView` project add the files in the `Source` directory to your project files.

### Supports(系统，语言支持)

- Swift 4.2+
- iOS 9.0+
- Xcode 10.0+
- ARC
- Adaptation iPhoneX, iPhone XS, iPhone XS Max, iPhone XR
  iPhone，iPad，Screen anyway.

## Usage

```swift
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
                                  "http://seopic.699pic.com/photo/50035/0520.jpg_wh1200.jpg"]

mainCarouselView.beginAutoScrollCarouselView()
```

### Under the hood(实现原理)

Use three images to achieve infinite loop scrolling by switching the `UIScrollView`'s `contentOffset`.

### LICENSE

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
