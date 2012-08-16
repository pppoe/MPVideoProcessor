MPVideoProcessor
================

Wrapper for Video Capture by AVFoundation 

# What's this?
I am working on some computer vison project, which need to process the each frame of the video captured by iPhone in realtime.
This is a wrapper for video capture. You setup your class as the delegate to get the video (as image) per frame and you can have your customized actions.

# How to use it?
The current version is fairly simple. I will add more options as my own work moves forward.
Draw two files MPVideoProcessor.h and MPVideoProcessor.m to your project.


``` Objective-C
    //< Create an instance        
    self.m_videoProcessor = [[MPVideoProcessor alloc] init];        
    
    //< Start Video Capture wherever and whenever you want
    ////< Setup it first
    [self.m_videoProcessor setupAVCaptureSession];
    ////< Add some customization, for example, switch to higher quality video recording
    [self.m_videoProcessor.m_avSession setSessionPreset:AVCaptureSessionPresetHigh];
    ////< Start it and setup the delegate (typically an UIViewController)
    [self.m_videoProcessor startAVSessionWithBufferDelegate:self];

    //< Wherever you should implement the delegate method like this:
    - (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
      //< Get the Image Buffer and Lock the address to prevent conflict
      CVImageBufferRef imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer);
      CVPixelBufferLockBaseAddress(imageBuffer, 0);
  
      //< MPVideoProcessor wraps the image creation from imageBuffer
      CGImageRef dstImage = [MPVideoProcessor createGrayScaleImageRefFromImageBuffer:imageBuffer];
      
      //< Unlock it :]
      CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
      
      //< Show the image from the main Thread
      dispatch_sync(dispatch_get_main_queue(), ^{
          self.m_imageView.layer.contents = (__bridge id)dstImage;
      });
    
      //< CleanUp
      CGImageRelease(dstImage);
    }
```

# Credits
I learned from this post http://invasivecode.tumblr.com/post/23153661857/a-quasi-real-time-video-processing-on-ios-in 
Thanks iNVASIVECODE.