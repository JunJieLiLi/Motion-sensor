//
//  ViewController.h
//  Motion
//
//  Created by JunJie Li on 2016-03-14.
//  Copyright © 2017 JunJie Li. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <AVFoundation/AVAudioSession.h>
#import <GameKit/GKPublicProtocols.h>
#define SERVICE_TYPE @"JunJIeLI"

@interface ViewController : UIViewController <UITextFieldDelegate,MCSessionDelegate, MCBrowserViewControllerDelegate>


/*local x,y,z of acceleration and rotation */
@property (strong, nonatomic) IBOutlet UILabel *accX;
@property (strong, nonatomic) IBOutlet UILabel *accY;
@property (strong, nonatomic) IBOutlet UILabel *accZ;
@property (strong, nonatomic) IBOutlet UILabel *rotX;
@property (strong, nonatomic) IBOutlet UILabel *rotY;
@property (strong, nonatomic) IBOutlet UILabel *rotZ;

/*motion*/
@property (strong, nonatomic) CMMotionManager *motionManager;

@end

