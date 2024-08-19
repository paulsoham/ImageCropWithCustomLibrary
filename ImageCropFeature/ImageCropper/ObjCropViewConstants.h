//
//  ObjCropViewConstants.h
//
// Soham Paul

#import <Foundation/Foundation.h>

/**
 The shape of the cropping region of this crop view controller
 */
typedef NS_ENUM(NSInteger, ObjCropViewCroppingStyle) {
    ObjCropViewCroppingStyleDefault,     // The regular, rectangular crop box
    ObjCropViewCroppingStyleCircular     // A fixed, circular crop box
};

/**
 Preset values of the most common aspect ratios that can be used to quickly configure
 the crop view controller.
 */
typedef NS_ENUM(NSInteger, ObjCropViewControllerAspectRatioPreset) {
    ObjCropViewControllerAspectRatioPresetOriginal,
    ObjCropViewControllerAspectRatioPresetSquare,
    ObjCropViewControllerAspectRatioPreset3x2,
    ObjCropViewControllerAspectRatioPreset5x3,
    ObjCropViewControllerAspectRatioPreset4x3,
    ObjCropViewControllerAspectRatioPreset5x4,
    ObjCropViewControllerAspectRatioPreset7x5,
    ObjCropViewControllerAspectRatioPreset16x9,
    ObjCropViewControllerAspectRatioPresetCustom
};

/**
 Whether the control toolbar is placed at the bottom or the top
 */
typedef NS_ENUM(NSInteger, ObjCropViewControllerToolbarPosition) {
    ObjCropViewControllerToolbarPositionBottom,  // Bar is placed along the bottom in portrait
    ObjCropViewControllerToolbarPositionTop     // Bar is placed along the top in portrait (Respects the status bar)
};

static inline NSBundle *TO_CROP_VIEW_RESOURCE_BUNDLE_FOR_OBJECT(NSObject *object) {
#if SWIFT_PACKAGE
    // SPM is supposed to support the keyword SWIFTPM_MODULE_BUNDLE
    // but I can't figure out how to make it work, so doing it manually
       NSString *bundleName = @"ObjCropViewController_ObjCropViewController";
#else
    NSString *bundleName = @"ObjCropViewControllerBundle";
#endif
    NSBundle *resourceBundle = nil;
    NSBundle *classBundle = [NSBundle bundleForClass:object.class];
    NSURL *resourceBundleURL = [classBundle URLForResource:bundleName withExtension:@"bundle"];
    if (resourceBundleURL) {
        resourceBundle = [[NSBundle alloc] initWithURL:resourceBundleURL];
        #ifndef NDEBUG
        if (resourceBundle == nil) {
            @throw [[NSException alloc] initWithName:@"BundleAccessor" reason:[NSString stringWithFormat:@"unable to find bundle named %@", bundleName] userInfo:nil];
        }
        #endif
    } else {
        resourceBundle = classBundle;
    }
    return resourceBundle;
}
