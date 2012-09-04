//
//  MPVideoProcessor.m
//  MotionPattern
//
//  Created by Haoxiang Li on 8/14/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "MPVideoProcessor.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

@interface MPVideoProcessor ()

+ (CGImageRef)createGrayScaleImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer;
+ (CGImageRef)createRGBImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer;

@end

@implementation MPVideoProcessor
@synthesize m_avSession;
@synthesize m_captureImageType;

- (id)init {
    if (self = [super init])
    {
        self.m_captureImageType = EnumCaptureGrayScaleImage;
    }
    return self;
}

- (void)setupAVCaptureSession {

    NSError *error;
    
    AVCaptureSession *avSession = [[AVCaptureSession alloc] init];
    [avSession setSessionPreset:AVCaptureSessionPresetLow];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice
                                                                              error:&error];
    if ([avSession canAddInput:deviceInput])
    {
        NSLog(@"avSession input added");
        [avSession addInput:deviceInput];
        
        //< Output Buffer
        AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        switch (self.m_captureImageType)
        {
            case EnumCaptureGrayScaleImage:
                dataOutput.videoSettings = [NSDictionary
                                            dictionaryWithObject:[NSNumber numberWithUnsignedInt:
                                                                  kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                            forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
                break;
            case EnumCaptureColorImageRGB:
                dataOutput.videoSettings = [NSDictionary
                                            dictionaryWithObject:[NSNumber numberWithUnsignedInt:
                                                                  kCVPixelFormatType_32BGRA]
                                            forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
                break;
            default:
                break;
        }
        if ([avSession canAddOutput:dataOutput])
        {
            [avSession addOutput:dataOutput];
            NSLog(@"avSession output added");
        }
    }

    self.m_avSession = avSession;
}

- (void)startAVSessionWithBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>) delegate {
    if (!self.m_avSession)
    {
        [self setupAVCaptureSession];
    }
    AVCaptureVideoDataOutput *dataOutput = [[self.m_avSession outputs] objectAtIndex:0];
    if ([dataOutput sampleBufferDelegate] == nil || [dataOutput sampleBufferDelegate] != delegate)
    {
        [dataOutput setSampleBufferDelegate:delegate queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [self.m_avSession startRunning];
    }
}

- (void)stopAVSession {
    [self.m_avSession stopRunning];
}

#pragma mark - Private
- (CGImageRef)createImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer {
    switch (self.m_captureImageType)
    {
        case EnumCaptureGrayScaleImage:
            return [MPVideoProcessor createGrayScaleImageRefFromImageBuffer:imageBuffer];
            break;
        case EnumCaptureColorImageRGB:
            return [MPVideoProcessor createRGBImageRefFromImageBuffer:imageBuffer];
            break;
        default:
            break;
    }    
}

+ (CGImageRef)createGrayScaleImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer {
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    Pixel_8 *lumaBuffer = (Pixel_8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, kCGImageAlphaNone);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);
    return imageRef;
}

+ (CGImageRef)createRGBImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer {
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    uint8_t *lumaBuffer = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, rgbColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    return imageRef;
}


@end
