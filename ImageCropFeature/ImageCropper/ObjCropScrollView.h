//
//  ObjCropScrollView
//
// Soham Paul

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*
 Subclassing UIScrollView was necessary in order to directly capture
 touch events that weren't otherwise accessible via UIGestureRecognizer objects.
 */
@interface ObjCropScrollView : UIScrollView

@property (nullable, nonatomic, copy) void (^touchesBegan)(void);
@property (nullable, nonatomic, copy) void (^touchesCancelled)(void);
@property (nullable, nonatomic, copy) void (^touchesEnded)(void);

@end

NS_ASSUME_NONNULL_END
