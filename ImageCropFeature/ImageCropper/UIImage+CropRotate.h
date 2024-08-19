//
//  UIImage+CropRotate.h
//
// Soham Paul

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TOCropRotate)

/// Crops a portion of an existing image object and returns it as a new image
/// @param frame The region inside the image (In image pixel space) to crop
/// @param angle If any, the angle the image is rotated at as well
/// @param circular Whether the resulting image is returned as a square or a circle
- (nonnull UIImage *)croppedImageWithFrame:(CGRect)frame
                                     angle:(NSInteger)angle
                              circularClip:(BOOL)circular;

@end

NS_ASSUME_NONNULL_END
