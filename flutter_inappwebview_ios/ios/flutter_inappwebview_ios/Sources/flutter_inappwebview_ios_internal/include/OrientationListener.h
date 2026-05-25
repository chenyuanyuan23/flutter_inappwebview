
#ifndef OrientationListener_h
#define OrientationListener_h

#import <Foundation/Foundation.h>


extern NSString* const PORTRAIT_UP;
extern NSString* const PORTRAIT_DOWN;
extern NSString* const LANDSCAPE_LEFT;
extern NSString* const LANDSCAPE_RIGHT;
extern NSString* const UNKNOWN;


@protocol IOrientationListener <NSObject>

- (void) startOrientationListener:(void (^)(NSString* orientation)) orientationRetrieved;
- (void) stopOrientationListener;
- (void) getOrientation:(void (^)(NSString* orientation)) orientationRetrieved;

@end


@interface OrientationListener : NSObject <IOrientationListener>

@property id observer;

@end

#endif /* OrientationListener_h */
