//
//  ObjCroppedImageAttributes.h
//
// Soham Paul

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOCroppedImageAttributes : NSObject

@property (nonatomic, readonly) NSInteger angle;
@property (nonatomic, readonly) CGRect croppedFrame;
@property (nonatomic, readonly) CGSize originalImageSize;

- (instancetype)initWithCroppedFrame:(CGRect)croppedFrame angle:(NSInteger)angle originalImageSize:(CGSize)originalSize;

@end

NS_ASSUME_NONNULL_END
