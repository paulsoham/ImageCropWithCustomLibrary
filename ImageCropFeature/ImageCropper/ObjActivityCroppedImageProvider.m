//
//  ObjActivityCroppedImageProvider.m
//
// Soham Paul

#import "ObjActivityCroppedImageProvider.h"
#import "UIImage+CropRotate.h"

@interface ObjActivityCroppedImageProvider ()

@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, assign, readwrite) CGRect cropFrame;
@property (nonatomic, assign, readwrite) NSInteger angle;
@property (nonatomic, assign, readwrite) BOOL circular;

@property (atomic, strong) UIImage *croppedImage;

@end

@implementation ObjActivityCroppedImageProvider

- (instancetype)initWithImage:(UIImage *)image cropFrame:(CGRect)cropFrame angle:(NSInteger)angle circular:(BOOL)circular
{
    if (self = [super initWithPlaceholderItem:[UIImage new]]) {
        _image = image;
        _cropFrame = cropFrame;
        _angle = angle;
        _circular = circular;
    }
    
    return self;
}

#pragma mark - UIActivity Protocols -
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return [[UIImage alloc] init];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    return self.croppedImage;
}

#pragma mark - Image Generation -
- (id)item
{
    //If the user didn't touch the image, just forward along the original
    if (self.angle == 0 && CGRectEqualToRect(self.cropFrame, (CGRect){CGPointZero, self.image.size})) {
        self.croppedImage = self.image;
        return self.croppedImage;
    }
    
    UIImage *image = [self.image croppedImageWithFrame:self.cropFrame angle:self.angle circularClip:self.circular];
    self.croppedImage = image;
    return self.croppedImage;
}

@end
