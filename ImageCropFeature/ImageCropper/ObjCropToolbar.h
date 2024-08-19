//
//  ObjCropToolbar.h
//
// Soham Paul

#import <UIKit/UIKit.h>

#if !__has_include(<ObjCropViewController/ObjCropViewConstants.h>)
#import "ObjCropViewConstants.h"
#else
#import <ObjCropViewController/ObjCropViewConstants.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ObjCropToolbar : UIView

/* In horizontal mode, offsets all of the buttons vertically by height of status bar. */
@property (nonatomic, assign) CGFloat statusBarHeightInset;

/* Set an inset that will expand the background view beyond the bounds. */
@property (nonatomic, assign) UIEdgeInsets backgroundViewOutsets;

/* The 'Done' buttons to commit the crop. The text button is displayed
 in portrait mode and the icon one, in landscape. */
@property (nonatomic, strong, readonly) UIButton *doneTextButton;
@property (nonatomic, strong, readonly) UIButton *doneIconButton;
@property (nonatomic, copy) NSString *doneTextButtonTitle;
@property (null_resettable, nonatomic, copy) UIColor *doneButtonColor;

/* The 'Cancel' buttons to cancel the crop. The text button is displayed
 in portrait mode and the icon one, in landscape. */
@property (nonatomic, strong, readonly) UIButton *cancelTextButton;
@property (nonatomic, strong, readonly) UIButton *cancelIconButton;
@property (nonatomic, readonly) UIView *visibleCancelButton;
@property (nonatomic, copy) NSString *cancelTextButtonTitle;
@property (nullable, nonatomic, copy) UIColor *cancelButtonColor;

@property (nonatomic, assign) BOOL showOnlyIcons;

/* The cropper control buttons */
@property (nonatomic, strong, readonly)  UIButton *rotateCounterclockwiseButton;
@property (nonatomic, strong, readonly)  UIButton *resetButton;
@property (nonatomic, strong, readonly)  UIButton *clampButton;
@property (nullable, nonatomic, strong, readonly) UIButton *rotateClockwiseButton;

@property (nonatomic, readonly) UIButton *rotateButton; // Points to `rotateCounterClockwiseButton`

/* Button feedback handler blocks */
@property (nullable, nonatomic, copy) void (^cancelButtonTapped)(void);
@property (nullable, nonatomic, copy) void (^doneButtonTapped)(void);
@property (nullable, nonatomic, copy) void (^rotateCounterclockwiseButtonTapped)(void);
@property (nullable, nonatomic, copy) void (^rotateClockwiseButtonTapped)(void);
@property (nullable, nonatomic, copy) void (^clampButtonTapped)(void);
@property (nullable, nonatomic, copy) void (^resetButtonTapped)(void);

/* State management for the 'clamp' button */
@property (nonatomic, assign) BOOL clampButtonGlowing;
@property (nonatomic, readonly) CGRect clampButtonFrame;

/* Aspect ratio button visibility settings */
@property (nonatomic, assign) BOOL clampButtonHidden;
@property (nonatomic, assign) BOOL rotateCounterclockwiseButtonHidden;
@property (nonatomic, assign) BOOL rotateClockwiseButtonHidden;
@property (nonatomic, assign) BOOL resetButtonHidden;
@property (nonatomic, assign) BOOL doneButtonHidden;
@property (nonatomic, assign) BOOL cancelButtonHidden;

/* For languages like Arabic where they natively present content flipped from English */
@property (nonatomic, assign) BOOL reverseContentLayout;

/* Enable the reset button */
@property (nonatomic, assign) BOOL resetButtonEnabled;

/* Done button frame for popover controllers */
@property (nonatomic, readonly) CGRect doneButtonFrame;

@end

NS_ASSUME_NONNULL_END
