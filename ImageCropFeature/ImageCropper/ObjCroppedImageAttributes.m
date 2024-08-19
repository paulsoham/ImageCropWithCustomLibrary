//
//  ObjCroppedImageAttributes.m
//
// Soham Paul

#import "ObjCroppedImageAttributes.h"

@interface TOCroppedImageAttributes ()

@property (nonatomic, assign, readwrite) NSInteger angle;
@property (nonatomic, assign, readwrite) CGRect croppedFrame;
@property (nonatomic, assign, readwrite) CGSize originalImageSize;

@end

@implementation TOCroppedImageAttributes

- (instancetype)initWithCroppedFrame:(CGRect)croppedFrame angle:(NSInteger)angle originalImageSize:(CGSize)originalSize
{
    if (self = [super init]) {
        _angle = angle;
        _croppedFrame = croppedFrame;
        _originalImageSize = originalSize;
    }
    
    return self;
}

@end
