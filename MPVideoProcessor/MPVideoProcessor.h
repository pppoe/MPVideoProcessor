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

typedef enum {
    MPVideoProcessorCaptureColorImageRGB,
    MPVideoProcessorCaptureColorImageGrayScale
} CaptureImageType;

@interface MPVideoProcessor : NSObject

@property (strong, nonatomic) AVCaptureSession *m_avSession;

//< By Default: EnumCaptureGrayScaleImage
@property (assign, nonatomic) CaptureImageType m_captureImageType;


//< Start Steps, call setupAVCaptureSession first than startAVSessionWithBufferDelegate
//< One can add customization between these two methods
- (void)setupAVCaptureSession;
- (void)startAVSessionWithBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;

//< Stop
- (void)stopAVSession;

//< Utility function, typically used in the delegate function
- (CGImageRef)createImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer;

@end
