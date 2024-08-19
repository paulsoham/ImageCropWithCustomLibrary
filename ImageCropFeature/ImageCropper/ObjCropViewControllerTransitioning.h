//
//  ObjCropViewControllerTransitioning.h
//
// Soham Paul

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjCropViewControllerTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

/* State Tracking */
@property (nonatomic, assign) BOOL isDismissing; // Whether this animation is presenting or dismissing
@property (nullable, nonatomic, strong) UIImage *image;    // The image that will be used in this animation

/* Destination/Origin points */
@property (nullable, nonatomic, strong) UIView *fromView;  // The origin view who's frame the image will be animated from
@property (nullable, nonatomic, strong) UIView *toView;    // The destination view who's frame the image will animate to

@property (nonatomic, assign) CGRect fromFrame;  // An origin frame that the image will be animated from
@property (nonatomic, assign) CGRect toFrame;    // A destination frame the image will aniamte to

/* A block called just before the transition to perform any last-second UI configuration */
@property (nullable, nonatomic, copy) void (^prepareForTransitionHandler)(void);

/* Empties all of the properties in this object */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
