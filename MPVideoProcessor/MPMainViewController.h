//
//  MPMainViewController.h
//  MotionPattern
//
//  Created by Haoxiang Li on 8/14/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPVideoProcessor;

@interface MPMainViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISwitch *m_switchProcessingOnOff;
@property (strong, nonatomic) IBOutlet UIButton *m_controlButton;
@property (strong, nonatomic) IBOutlet UIImageView *m_imageView;

@property (strong, nonatomic) MPVideoProcessor *m_videoProcessor;

- (IBAction)controlButtonTapped:(id)sender;

@end
