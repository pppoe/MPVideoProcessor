//
//  MPMainViewController.m
//  MotionPattern
//
//  Created by Haoxiang Li on 8/14/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "MPMainViewController.h"
#import "MPVideoProcessor.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

#define kControlButtonStatusWaitForStart 0x100
#define kControlButtonStatusWaitForStop 0x101
#define kControlButtonCaptionStart @"Start"
#define kControlButtonCaptionStop @"Stop"

@interface MPMainViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

//< As a demo, process each frame here
- (CGImageRef)postProcessing:(CVImageBufferRef)imageRef;

@end

@implementation MPMainViewController
@synthesize m_imageView, m_controlButton, m_switchProcessingOnOff;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.m_videoProcessor = [[MPVideoProcessor alloc] init];
        self.m_videoProcessor.m_captureImageType = MPVideoProcessorCaptureColorImageRGB;
//        self.m_videoProcessor.m_captureImageType = MPVideoProcessorCaptureColorImageGrayScale;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.m_controlButton setTag:kControlButtonStatusWaitForStart];
    [self.m_controlButton setTitle:kControlButtonCaptionStart forState:UIControlStateNormal];
    
    //< Something Tricky here
    self.m_imageView.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGImageRef)postProcessing:(CVImageBufferRef)imageBuffer
{
    //< Demo: Map the Image to a Circle Image, for Color Image Only
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

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CVImageBufferRef imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    
        
    CGImageRef dstImage = (m_switchProcessingOnOff.on ?
                           [self postProcessing:imageBuffer]
                           :
                           [self.m_videoProcessor createImageRefFromImageBuffer:imageBuffer]);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.m_imageView.layer.contents = (__bridge id)dstImage;
    });
    
    CGImageRelease(dstImage);
}

#pragma IBAction
- (IBAction)controlButtonTapped:(UIButton *)controlBtn {
    if (controlBtn.tag == kControlButtonStatusWaitForStart)
    {
        NSLog(@"Start Tapped");
        [self.m_controlButton setTag:kControlButtonStatusWaitForStop];
        [self.m_controlButton setTitle:kControlButtonCaptionStop forState:UIControlStateNormal];
        
        [self.m_videoProcessor setupAVCaptureSession];
        //< higher quality
        [self.m_videoProcessor.m_avSession setSessionPreset:AVCaptureSessionPresetHigh];
        [self.m_videoProcessor startAVSessionWithBufferDelegate:self];
    }
    else
    {
        NSLog(@"Stop Tapped");
        [self.m_controlButton setTag:kControlButtonStatusWaitForStart];
        [self.m_controlButton setTitle:kControlButtonCaptionStart forState:UIControlStateNormal];
        [self.m_videoProcessor stopAVSession];
    }
}

@end
