//
//  ImageCropViewController.swift
//  ImageCropFeature
//  Created by sohamp on 22/07/24.
//

#if canImport(ObjCropViewController)
import ObjCropViewController
#endif

import UIKit

public typealias CropViewControllerAspectRatioPreset = ObjCropViewControllerAspectRatioPreset

/**
 An enum denoting whether the control tool bar is drawn at the top, or the bottom of the screen in portrait mode
 */
public typealias CropViewControllerToolbarPosition = ObjCropViewControllerToolbarPosition

/**
 The type of cropping style for this view controller (ie a square or a circle cropping region)
 */
public typealias CropViewCroppingStyle = ObjCropViewCroppingStyle

@MainActor @objc protocol CropViewControllerDelegate: NSObjectProtocol {
    /**
     Called when the user has committed the crop action, and provides
     just the cropping rectangle.
     
     @param cropRect A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
     @param angle The angle of the image when it was cropped
     */
    @objc optional func cropViewController(_ cropViewController: ImageCropViewController, didCropImageToRect cropRect: CGRect, angle: Int)
    
    /**
     Called when the user has committed the crop action, and provides
     both the original image with crop co-ordinates.
     
     @param image The newly cropped image.
     @param cropRect A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
     @param angle The angle of the image when it was cropped
     */
    @objc optional func cropViewController(_ cropViewController: ImageCropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int)
    
    /**
     If the cropping style is set to circular, implementing this delegate will return a circle-cropped version of the selected
     image, as well as it's cropping co-ordinates
     
     @param image The newly cropped image, clipped to a circle shape
     @param cropRect A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
     @param angle The angle of the image when it was cropped
     */
    @objc optional func cropViewController(_ cropViewController: ImageCropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int)
    
    /**
     If implemented, when the user hits cancel, or completes a
     UIActivityViewController operation, this delegate will be called,
     giving you a chance to manually dismiss the view controller
     
     @param cancelled Whether a cropping action was actually performed, or if the user explicitly hit 'Cancel'
     
     */
    @objc optional func cropViewController(_ cropViewController: ImageCropViewController, didFinishCancelled cancelled: Bool)
}

class ImageCropViewController: UIViewController,ObjCropViewControllerDelegate {
    
    /**
     The original, uncropped image that was passed to this controller.
     */
    public var image: UIImage { return self.objCropViewController.image }
    
    /**
     The minimum croping aspect ratio. If set, user is prevented from
     setting cropping rectangle to lower aspect ratio than defined by the parameter.
     */
    public var minimumAspectRatio: CGFloat {
        set { objCropViewController.minimumAspectRatio = newValue }
        get { return objCropViewController.minimumAspectRatio }
    }

    /**
     The view controller's delegate that will receive the resulting
     cropped image, as well as crop information.
    */
    public weak var delegate: (any CropViewControllerDelegate)? {
        didSet { self.setUpDelegateHandlers() }
    }
    
    /**
     Set the title text that appears at the top of the view controller
    */
    override open var title: String? {
        set { objCropViewController.title = newValue }
        get { return objCropViewController.title }
    }
    
    /**
     If true, when the user hits 'Done', a UIActivityController will appear
     before the view controller ends.
     */
    public var showActivitySheetOnDone: Bool {
        set { objCropViewController.showActivitySheetOnDone = newValue }
        get { return objCropViewController.showActivitySheetOnDone }
    }
    
    /**
     In the coordinate space of the image itself, the region that is currently
     being highlighted by the crop box.
     
     This property can be set before the controller is presented to have
     the image 'restored' to a previous cropping layout.
     */
    public var imageCropFrame: CGRect {
        set { objCropViewController.imageCropFrame = newValue }
        get { return objCropViewController.imageCropFrame }
    }
    
    /**
     The angle in which the image is rotated in the crop view.
     This can only be in 90 degree increments (eg, 0, 90, 180, 270).
     
     This property can be set before the controller is presented to have
     the image 'restored' to a previous cropping layout.
     */
    public var angle: Int {
        set { objCropViewController.angle = newValue }
        get { return objCropViewController.angle }
    }
    
    /**
     The cropping style of this particular crop view controller
     */
    public var croppingStyle: CropViewCroppingStyle {
        return objCropViewController.croppingStyle
    }
    
    /**
      A choice from one of the pre-defined aspect ratio presets
    */
    public var aspectRatioPreset: CropViewControllerAspectRatioPreset {
        set { objCropViewController.aspectRatioPreset = newValue }
        get { return objCropViewController.aspectRatioPreset }
    }
    
    /**
     A CGSize value representing a custom aspect ratio, not listed in the presets.
     E.g. A ratio of 4:3 would be represented as (CGSize){4.0f, 3.0f}
     */
    public var customAspectRatio: CGSize {
        set { objCropViewController.customAspectRatio = newValue }
        get { return objCropViewController.customAspectRatio }
    }
    
    /**
     If this is set alongside `customAspectRatio`, the custom aspect ratio
     will be shown as a selectable choice in the list of aspect ratios. (Default is `nil`)
     */
    public var customAspectRatioName: String? {
        set { objCropViewController.customAspectRatioName = newValue }
        get { return objCropViewController.customAspectRatioName }
    }
    
    /**
     Title label which can be used to show instruction on the top of the crop view controller
     */
    public var titleLabel: UILabel? {
        return objCropViewController.titleLabel
    }
    
    /**
     If true, while it can still be resized, the crop box will be locked to its current aspect ratio.
     
     If this is set to YES, and `resetAspectRatioEnabled` is set to NO, then the aspect ratio
     button will automatically be hidden from the toolbar.
     
     Default is false.
     */
    public var aspectRatioLockEnabled: Bool {
        set { objCropViewController.aspectRatioLockEnabled = newValue }
        get { return objCropViewController.aspectRatioLockEnabled }
    }
    
    /**
     If true, a custom aspect ratio is set, and the aspectRatioLockEnabled is set to true, the crop box will swap it's dimensions depending on portrait or landscape sized images.  This value also controls whether the dimensions can swap when the image is rotated.
     
     Default is false.
     */
    public var aspectRatioLockDimensionSwapEnabled: Bool {
        set { objCropViewController.aspectRatioLockDimensionSwapEnabled = newValue }
        get { return objCropViewController.aspectRatioLockDimensionSwapEnabled }
    }
    
    /**
     If true, tapping the reset button will also reset the aspect ratio back to the image
     default ratio. Otherwise, the reset will just zoom out to the current aspect ratio.
     
     If this is set to false, and `aspectRatioLockEnabled` is set to YES, then the aspect ratio
     button will automatically be hidden from the toolbar.
     
     Default is true
     */
    public var resetAspectRatioEnabled: Bool {
        set { objCropViewController.resetAspectRatioEnabled = newValue }
        get { return objCropViewController.resetAspectRatioEnabled }
    }
    
    /**
     The position of the Toolbar the default value is `ObjCropViewControllerToolbarPositionBottom`.
     */
    public var toolbarPosition: CropViewControllerToolbarPosition {
        set { objCropViewController.toolbarPosition = newValue }
        get { return objCropViewController.toolbarPosition }
    }
    
    /**
     When disabled, an additional rotation button that rotates the canvas in
     90-degree segments in a clockwise direction is shown in the toolbar.
     
     Default is false.
     */
    public var rotateClockwiseButtonHidden: Bool {
        set { objCropViewController.rotateClockwiseButtonHidden = newValue }
        get { return objCropViewController.rotateClockwiseButtonHidden }
    }
    
    /**
     When enabled, hides the rotation button, as well as the alternative rotation
     button visible when `showClockwiseRotationButton` is set to true.
     
     Default is false.
     */
    public var rotateButtonsHidden: Bool {
        set { objCropViewController.rotateButtonsHidden = newValue }
        get { return objCropViewController.rotateButtonsHidden }
    }
    /**
     When enabled, hides the 'Reset' button on the toolbar.

     Default is false.
     */
    public var resetButtonHidden: Bool {
        set { objCropViewController.resetButtonHidden = newValue }
        get { return objCropViewController.resetButtonHidden }
    }
    
    /**
     When enabled, hides the 'Aspect Ratio Picker' button on the toolbar.
     
     Default is false.
     */
    public var aspectRatioPickerButtonHidden: Bool {
        set { objCropViewController.aspectRatioPickerButtonHidden = newValue }
        get { return objCropViewController.aspectRatioPickerButtonHidden }
    }
    
    /**
     When enabled, hides the 'Done' button on the toolbar.

     Default is false.
     */
    public var doneButtonHidden: Bool {
        set { objCropViewController.doneButtonHidden = newValue }
        get { return objCropViewController.doneButtonHidden }
    }
    
    /**
     When enabled, hides the 'Cancel' button on the toolbar.

     Default is false.
     */
    public var cancelButtonHidden: Bool {
        set { objCropViewController.cancelButtonHidden = newValue }
        get { return objCropViewController.cancelButtonHidden }
    }

    /**
     If `showActivitySheetOnDone` is true, then these activity items will
     be supplied to that UIActivityViewController in addition to the
     `ObjActivityCroppedImageProvider` object.
     */
    public var activityItems: [Any]? {
        set { objCropViewController.activityItems = newValue }
        get { return objCropViewController.activityItems }
    }
    
    /**
     If `showActivitySheetOnDone` is true, then you may specify any
     custom activities your app implements in this array. If your activity requires
     access to the cropping information, it can be accessed in the supplied
     `ObjActivityCroppedImageProvider` object
     */
    public var applicationActivities: [UIActivity]? {
        set { objCropViewController.applicationActivities = newValue }
        get { return objCropViewController.applicationActivities }
    }
    
    /**
     If `showActivitySheetOnDone` is true, then you may expliclty
     set activities that won't appear in the share sheet here.
     */
    public var excludedActivityTypes: [UIActivity.ActivityType]? {
        set { objCropViewController.excludedActivityTypes = newValue }
        get { return objCropViewController.excludedActivityTypes }
    }
    
    /**
     An array of `ObjCropViewControllerAspectRatioPreset` enum values denoting which
     aspect ratios the crop view controller may display (Default is nil. All are shown)
     */
    public var allowedAspectRatios: [CropViewControllerAspectRatioPreset]? {
        set { objCropViewController.allowedAspectRatios = newValue?.map { NSNumber(value: $0.rawValue) } }
        get { return objCropViewController.allowedAspectRatios?.compactMap { CropViewControllerAspectRatioPreset(rawValue: $0.intValue) } }
    }
    
    /**
     When the user hits cancel, or completes a
     UIActivityViewController operation, this block will be called,
     giving you a chance to manually dismiss the view controller
     */
    public var onDidFinishCancelled: ((Bool) -> (Void))? {
        set { objCropViewController.onDidFinishCancelled = newValue }
        get { return objCropViewController.onDidFinishCancelled }
    }
    
    /**
     Called when the user has committed the crop action, and provides
     just the cropping rectangle.
     
     @param cropRect A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
     @param angle The angle of the image when it was cropped
     */
    public var onDidCropImageToRect: ((CGRect, Int) -> (Void))? {
        set { objCropViewController.onDidCropImageToRect = newValue }
        get { return objCropViewController.onDidCropImageToRect }
    }
    
    /**
     Called when the user has committed the crop action, and provides
     both the cropped image with crop co-ordinates.
     
     @param image The newly cropped image.
     @param cropRect A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
     @param angle The angle of the image when it was cropped
     */
    public var onDidCropToRect: ((UIImage, CGRect, NSInteger) -> (Void))? {
        set { objCropViewController.onDidCropToRect = newValue }
        get { return objCropViewController.onDidCropToRect }
    }
    
    /**
     If the cropping style is set to circular, this block will return a circle-cropped version of the selected
     image, as well as it's cropping co-ordinates
     
     @param image The newly cropped image, clipped to a circle shape
     @param cropRect A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
     @param angle The angle of the image when it was cropped
     */
    public var onDidCropToCircleImage: ((UIImage, CGRect, NSInteger) -> (Void))? {
        set { objCropViewController.onDidCropToCircleImage = newValue }
        get { return objCropViewController.onDidCropToCircleImage }
    }

    /**
     The crop view managed by this view controller.
     */
    public var cropView: ObjCropView {
        return objCropViewController.cropView
    }
    
    /**
     The toolbar managed by this view controller.
     */
    public var toolbar: ObjCropToolbar {
        return objCropViewController.toolbar
    }

    /*
     If this controller is embedded in UINavigationController its navigation bar is hidden by default. Set this property to false to show the navigation bar. This must be set before this controller is presented.
     */
    public var hidesNavigationBar: Bool {
        set { objCropViewController.hidesNavigationBar = newValue }
        get { return objCropViewController.hidesNavigationBar }
    }
    
    /**
     Title for the 'Done' button.
     Setting this will override the Default which is a localized string for "Done".
     */
    public var doneButtonTitle: String! {
        set { objCropViewController.doneButtonTitle = newValue }
        get { return objCropViewController.doneButtonTitle }
    }
    
    /**
     Title for the 'Cancel' button.
     Setting this will override the Default which is a localized string for "Cancel".
     */
    public var cancelButtonTitle: String! {
        set { objCropViewController.cancelButtonTitle = newValue }
        get { return objCropViewController.cancelButtonTitle }
    }

    /**
    If true, button icons are visible in portairt instead button text.

    Default is NO.
    */
    public var showOnlyIcons: Bool {
        set { objCropViewController.showOnlyIcons = newValue }
        get { return objCropViewController.showOnlyIcons }
    }

    /**
     Shows a confirmation dialog when the user hits 'Cancel' and there are pending changes.
     (Default is NO)
     */
    public var showCancelConfirmationDialog: Bool {
        set { objCropViewController.showCancelConfirmationDialog = newValue }
        get { return objCropViewController.showCancelConfirmationDialog }
    }
    
    /**
    Color for the 'Done' button.
    Setting this will override the default color.
    */
    public var doneButtonColor: UIColor? {
        set { objCropViewController.doneButtonColor = newValue }
        get { return objCropViewController.doneButtonColor }
    }
    
    /**
    Color for the 'Cancel' button.
    Setting this will override the default color.
    */
    public var cancelButtonColor: UIColor? {
        set { objCropViewController.cancelButtonColor = newValue }
        get { return objCropViewController.cancelButtonColor }
    }

    /**
    A computed property to get or set the reverse layout on toolbar.
    By setting this property, you can control the direction in which the toolbar is laid out.

    Default is NO.
    */
    public var reverseContentLayout: Bool {
        set { objCropViewController.reverseContentLayout = newValue }
        get { objCropViewController.reverseContentLayout }
    }

    /**
     This class internally manages and abstracts access to a `ObjCropViewController` instance
     :nodoc:
     */
    internal let objCropViewController: ObjCropViewController!
    
    /**
     Forward status bar status style changes to the crop view controller
     :nodoc:
     */
    open override var childForStatusBarStyle: UIViewController? {
        return objCropViewController
    }
    
    /**
     Forward status bar status visibility changes to the crop view controller
     :nodoc:
     */
    open override var childForStatusBarHidden: UIViewController? {
        return objCropViewController
    }
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return objCropViewController.preferredStatusBarStyle
    }
    
    open override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        if #available(iOS 11.0, *) {
            return objCropViewController.preferredScreenEdgesDeferringSystemGestures
        }
        
        return UIRectEdge.all
    }
    
    // ------------------------------------------------
    /// @name Object Creation
    // ------------------------------------------------
    
    /**
     Creates a new instance of a crop view controller with the supplied image
     
     @param image The image that will be used to crop.
     */
    public init(image: UIImage) {
        self.objCropViewController = ObjCropViewController(image: image)
        super.init(nibName: nil, bundle: nil)
        setUpCropController()
    }
    
    /**
     Creates a new instance of a crop view controller with the supplied image and cropping style
     
     @param style The cropping style that will be used with this view controller (eg, rectangular, or circular)
     @param image The image that will be cropped
     */
    public init(croppingStyle: CropViewCroppingStyle, image: UIImage) {
        self.objCropViewController = ObjCropViewController(croppingStyle: croppingStyle, image: image)
        super.init(nibName: nil, bundle: nil)
        setUpCropController()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Defer adding the view until we're about to be presented
        if objCropViewController.view.superview == nil {
            view.addSubview(objCropViewController.view)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        objCropViewController.view.frame = view.bounds
        objCropViewController.viewDidLayoutSubviews()
    }

    /**
     Commits the crop action as if user pressed done button in the bottom bar themself
     */
    public func commitCurrentCrop() {
        objCropViewController.commitCurrentCrop()
    }
    
    /**
    Resets object of ObjCropViewController class as if user pressed reset button in the bottom bar themself
    */
    public func resetCropViewLayout() {
        objCropViewController.resetCropViewLayout()
    }

    /**
    Set the aspect ratio to be one of the available preset options. These presets have specific behaviour
    such as swapping their dimensions depending on portrait or landscape sized images.

    @param aspectRatioPreset The aspect ratio preset
    @param animated Whether the transition to the aspect ratio is animated
    */
    public func setAspectRatioPreset(_ aspectRatio: CropViewControllerAspectRatioPreset, animated: Bool) {
        objCropViewController.setAspectRatioPreset(aspectRatio, animated: animated)
    }
    
    /**
    Play a custom animation of the target image zooming to its position in
    the crop controller while the background fades in.

    @param viewController The parent controller that this view controller would be presenting from.
    @param fromView A view that's frame will be used as the origin for this animation. Optional if `fromFrame` has a value.
    @param fromFrame In the screen's coordinate space, the frame from which the image should animate from. Optional if `fromView` has a value.
    @param setup A block that is called just before the transition starts. Recommended for hiding any necessary image views.
    @param completion A block that is called once the transition animation is completed.
    */
    public func presentAnimatedFrom(_ viewController: UIViewController, fromView view: UIView?, fromFrame frame: CGRect,
                                    setup: (() -> (Void))?, completion: (() -> (Void))?)
    {
        objCropViewController.presentAnimatedFrom(viewController, view: view, frame: frame, setup: setup, completion: completion)
    }
    
    /**
     Play a custom animation of the target image zooming to its position in
     the crop controller while the background fades in. Additionally, if you're
     'restoring' to a previous crop setup, this method lets you provide a previously
     cropped copy of the image, and the previous crop settings to transition back to
     where the user would have left off.

     @param viewController The parent controller that this view controller would be presenting from.
     @param image The previously cropped image that can be used in the transition animation.
     @param fromView A view that's frame will be used as the origin for this animation. Optional if `fromFrame` has a value.
     @param fromFrame In the screen's coordinate space, the frame from which the image should animate from.
     @param angle The rotation angle in which the image was rotated when it was originally cropped.
     @param toFrame In the image's coordinate space, the previous crop frame that created the previous crop
     @param setup A block that is called just before the transition starts. Recommended for hiding any necessary image views.
     @param completion A block that is called once the transition animation is completed.
    */
    public func presentAnimatedFrom(_ viewController: UIViewController, fromImage image: UIImage?,
                                    fromView: UIView?, fromFrame: CGRect, angle: Int, toImageFrame toFrame: CGRect,
                                    setup: (() -> (Void))?, completion:(() -> (Void))?)
    {
        objCropViewController.presentAnimatedFrom(viewController, fromImage: image, fromView: fromView,
                                                 fromFrame: fromFrame, angle: angle, toFrame: toFrame,
                                                 setup: setup, completion: completion)
    }
    
    /**
     Play a custom animation of the supplied cropped image zooming out from
     the cropped frame to the specified frame as the rest of the content fades out.
     If any view configurations need to be done before the animation starts,

     @param viewController The parent controller that this view controller would be presenting from.
     @param toView A view who's frame will be used to establish the destination frame
     @param frame The target frame that the image will animate to
     @param setup A block that is called just before the transition starts. Recommended for hiding any necessary image views.
     @param completion A block that is called once the transition animation is completed.
    */
    public func dismissAnimatedFrom(_ viewController: UIViewController, toView: UIView?, toFrame: CGRect,
                                    setup: (() -> (Void))?, completion:(() -> (Void))?)
    {
        objCropViewController.dismissAnimatedFrom(viewController, toView: toView, toFrame: toFrame, setup: setup, completion: completion)
    }
    
    /**
     Play a custom animation of the supplied cropped image zooming out from
     the cropped frame to the specified frame as the rest of the content fades out.
     If any view configurations need to be done before the animation starts,

     @param viewController The parent controller that this view controller would be presenting from.
     @param image The resulting 'cropped' image. If supplied, will animate out of the crop box zone. If nil, the default image will entirely zoom out
     @param toView A view who's frame will be used to establish the destination frame
     @param frame The target frame that the image will animate to
     @param setup A block that is called just before the transition starts. Recommended for hiding any necessary image views.
     @param completion A block that is called once the transition animation is completed.
     */
    public func dismissAnimatedFrom(_ viewController: UIViewController, withCroppedImage croppedImage: UIImage?, toView: UIView?,
                                    toFrame: CGRect, setup: (() -> (Void))?, completion:(() -> (Void))?)
    {
        objCropViewController.dismissAnimatedFrom(viewController, croppedImage: croppedImage, toView: toView,
                                                 toFrame: toFrame, setup: setup, completion: completion)
    }
}

extension ImageCropViewController {
    fileprivate func setUpCropController() {
        modalPresentationStyle = .fullScreen
        addChild(objCropViewController)
        transitioningDelegate = (objCropViewController as! (any UIViewControllerTransitioningDelegate))
        objCropViewController.delegate = self
        objCropViewController.didMove(toParent: self)
    }
    
    fileprivate func setUpDelegateHandlers() {
        guard let delegate = self.delegate else {
            onDidCropToRect = nil
            onDidCropImageToRect = nil
            onDidCropToCircleImage = nil
            onDidFinishCancelled = nil
            return
        }
        
        if delegate.responds(to: #selector((any CropViewControllerDelegate).cropViewController(_:didCropImageToRect:angle:))) {
            self.onDidCropImageToRect = {[weak self] rect, angle in
                guard let strongSelf = self else { return }
                delegate.cropViewController!(strongSelf, didCropImageToRect: rect, angle: angle)
            }
        }
        
        if delegate.responds(to: #selector((any CropViewControllerDelegate).cropViewController(_:didCropToImage:withRect:angle:))) {
            self.onDidCropToRect = {[weak self] image, rect, angle in
                guard let strongSelf = self else { return }
                delegate.cropViewController!(strongSelf, didCropToImage: image, withRect: rect, angle: angle)
            }
        }
        
        if delegate.responds(to: #selector((any CropViewControllerDelegate).cropViewController(_:didCropToCircularImage:withRect:angle:))) {
            self.onDidCropToCircleImage = {[weak self] image, rect, angle in
                guard let strongSelf = self else { return }
                delegate.cropViewController!(strongSelf, didCropToCircularImage: image, withRect: rect, angle: angle)
            }
        }
        
        if delegate.responds(to: #selector((any CropViewControllerDelegate).cropViewController(_:didFinishCancelled:))) {
            self.onDidFinishCancelled = {[weak self] finished in
                guard let strongSelf = self else { return }
                delegate.cropViewController!(strongSelf, didFinishCancelled: finished)
            }
        }
    }
    
}
