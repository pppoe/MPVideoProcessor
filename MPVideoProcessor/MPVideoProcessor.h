//
//  MPVideoProcessor.h
//  MotionPattern
//
//  Created by Haoxiang Li on 8/14/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVCaptureSession;
@protocol AVCaptureVideoDataOutputSampleBufferDelegate;

@interface MPVideoProcessor : NSObject

@property (strong, nonatomic) AVCaptureSession *m_avSession;

//< Start Steps, call setupAVCaptureSession first than startAVSessionWithBufferDelegate
//< One can add customization between these two methods
- (void)setupAVCaptureSession;
- (void)startAVSessionWithBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;

//< Stop
- (void)stopAVSession;

//< Utility function, typically used in the delegate function
+ (CGImageRef)createGrayScaleImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer;
+ (CGImageRef)createRGBImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer;


@end
