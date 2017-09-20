//
//  ViewController.m
//  Motion
//
//  Created by JunJie Li on 2016-03-14.
//  Copyright © 2017 JunJie Li. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    BOOL connected;
}

@property (weak, nonatomic) IBOutlet UIButton *browseButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;

/*peer x,y,z of acceleration and rottation */
@property (strong, nonatomic) IBOutlet UILabel *peer_accX;
@property (strong, nonatomic) IBOutlet UILabel *peer_accY;
@property (strong, nonatomic) IBOutlet UILabel *peer_accZ;
@property (strong, nonatomic) IBOutlet UILabel *peer_rotX;
@property (strong, nonatomic) IBOutlet UILabel *peer_rotY;
@property (strong, nonatomic) IBOutlet UILabel *peer_rotZ;

/*the device name of connected peer*/
@property (weak, nonatomic) IBOutlet UILabel *DeviceName;

/* local device name*/
@property (weak, nonatomic) IBOutlet UILabel *MyDeviceName;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCAdvertiserAssistant *assistant;
@property (strong, nonatomic) MCBrowserViewController *browserVC;



@property (strong, nonatomic) IBOutlet UIView *PeerViewRec;        // peer view frame


@property (strong, nonatomic) IBOutlet UIView *myViewRec;          // local view frame

- (IBAction)browseButtonTapped:(id)sender;

- (IBAction)disconnectButtonTapped:(id)sender;

- (void)setUIToNotConnectedState;

- (void)setUIToConnectedState;

@end


@implementation ViewController
@synthesize session;
@synthesize accX, accY, accZ;
@synthesize rotX,rotY,rotZ;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.MyDeviceName.text = [UIDevice currentDevice].name;
    // Do any additional setup after loading the view, typically from a nib.
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .1;
    self.motionManager.gyroUpdateInterval = .1;
    [self.disconnectButton sizeToFit];
    
    /* send the acceleration data to the local device and peer's device*/
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 [self sendAccDataToPeerWithX:accelerometerData.acceleration.x Y:accelerometerData.acceleration.y Z:accelerometerData.acceleration.z];
                                                 
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
    /*send the rotation data to the local and peer's device*/
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                       [self sendRotDataToPeerWithPitch:gyroData.rotationRate.x Roll:(gyroData.rotationRate.y) Yaw:gyroData.rotationRate.z];
                                        
                                    }];
    connected = NO;
    [self setUIToNotConnectedState ];
    
    self.myViewRec.backgroundColor = [UIColor colorWithRed:0 green:(0) blue:(10) alpha:0.2];
    
    self.PeerViewRec.backgroundColor = [UIColor colorWithRed:10 green:0 blue:0 alpha:0.5];
    
    /*Prepare session*/
    MCPeerID *myPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    self.session = [[MCSession alloc] initWithPeer:myPeerID];
    self.session.delegate = self;
    
    /*Start advertising*/
    self.assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:SERVICE_TYPE discoveryInfo:nil session:self.session];
    [self.assistant start];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


-(void)outputAccelertionData:(CMAcceleration)acceleration{      // prints out X,y,z
    
    
    self.accX.text = [NSString stringWithFormat:@" %.4fg",acceleration.x];
    self.accY.text = [NSString stringWithFormat:@" %.4fg",acceleration.y];
    self.accZ.text = [NSString stringWithFormat:@" %.4fg",acceleration.z];
    [self.accX sizeToFit];
    [self.accY sizeToFit];
    [self.accZ sizeToFit];
}



-(void)outputRotationData:(CMRotationRate)rotation {     // prints out X,y,z data of the rotation, local

    
    self.rotX.text = [NSString stringWithFormat:@" %.4fr",rotation.x];
    self.rotY.text = [NSString stringWithFormat:@" %.4fr",rotation.y];
    self.rotZ.text = [NSString stringWithFormat:@" %.4fr",rotation.z];
    [self.rotX sizeToFit];
    [self.rotY sizeToFit];
    [self.rotZ sizeToFit];
}


- (IBAction)browseButtonTapped:(id)sender {              // browse button for finding the peer
    self.browserVC = [[MCBrowserViewController alloc] initWithServiceType:SERVICE_TYPE session:self.session];
    self.browserVC.delegate = self;
    [self presentViewController:self.browserVC animated:YES completion:nil];
}


- (IBAction)disconnectButtonTapped:(id)sender {        // disconnect with the peer
    [self setUIToNotConnectedState];
    connected = NO;
    [self.session disconnect];
    self.DeviceName.text = @"disconnected";
}


- (void) setPeerAccelerationLabelsWithX: (float) x Y: (float) y Z: (float) z {   // set Peer's acceleration x ,y,z to the string format
    self.peer_accX.text = [NSString stringWithFormat:@" %.4fg",x];
    self.peer_accY.text = [NSString stringWithFormat:@" %.4fg",y];
    self.peer_accZ.text = [NSString stringWithFormat:@" %.4fg",z];
    [self.peer_accX sizeToFit];
    [self.peer_accY sizeToFit];
    [self.peer_accZ sizeToFit];
}



- (void) setPeerRotationLabelsWithPitch: (float) pitch Roll: (float) roll Yaw: (float) yaw {   // set Peer's rotation pitch,roll,yaw to the string format
    self.peer_rotX.text = [NSString stringWithFormat:@" %.4fr",pitch];
    self.peer_rotY.text = [NSString stringWithFormat:@" %.4fr",roll];
    self.peer_rotZ.text = [NSString stringWithFormat:@" %.4fr",yaw];
    [self.peer_rotX sizeToFit];
    [self.peer_rotY sizeToFit];
    [self.peer_rotZ sizeToFit];
}

#pragma mark
#pragma mark <MCSessionDelegate> methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{         // Remote peer changed state
    if (state == MCSessionStateConnected)
    {   dispatch_async(dispatch_get_main_queue(), ^
        {
        [self setUIToConnectedState];
        self.disconnectButton.enabled = YES;
        connected = YES;
        });
    }
    else if (state == MCSessionStateNotConnected)
    {   dispatch_async(dispatch_get_main_queue(), ^
        {
        [self setUIToNotConnectedState];
            self.DeviceName.text = @"disconnected";
            connected = NO;});
                       
        };
    }

  // initialize the data array which for each one has 3 data, and add a flag to indicate which is acceleration or rotation.
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{     // Received data from remote peer
    
    float receivedData[4] = {0.0f, 0.0f, 0.0f, 0.0f};
    
    [data getBytes:receivedData length:4* sizeof(float)];
    
    float flag = receivedData[0];
    float x = receivedData[1];
    float y = receivedData[2];
    float z = receivedData[3];
    
    NSString * name = peerID.displayName;
    
    
    if (flag == 0.0) {             // 0.0 is the flag of the Acceleration
        dispatch_async(dispatch_get_main_queue(), ^{
           
            self.DeviceName.text = name;     // prints out device name
            [self setPeerAccelerationLabelsWithX:x Y:y Z:z];
        });
    }
   
    else if (flag == 1.0) {       // 1.0 is the flag of the Rotation
        dispatch_async(dispatch_get_main_queue(), ^{
            self.DeviceName.text = name;
            [self setPeerRotationLabelsWithPitch:x Roll:y Yaw:z];
        });
    }
    
    NSLog(@"Received %0.4f %0.4f %0.4f", x, y, z);
}

- (void) sendAccDataToPeerWithX:(float)x Y: (float) y Z: (float)z {
    
    /*Make a byte array for 3 floats, plus a FLAG at the beginning to indicate
     that this is acceleration data*/
    float flag = 0.0;
    
    float floatArray[4] = { flag, x, y, z };      // 0 means ACCELERATION
    
   
    NSData * dataToSend = [NSData dataWithBytes:floatArray length:4 * sizeof(float)];
    
    
    NSArray *peerIDs = session.connectedPeers;    //Send to peers
    
    if ([peerIDs count] > 0) {
        int success = [session sendData:dataToSend toPeers:peerIDs withMode:MCSessionSendDataReliable error:nil];
        
        NSLog(@"Sent acceleration data success? %d", success);
    }

}

- (void) sendRotDataToPeerWithPitch:(float)pitch Roll: (float) roll Yaw: (float)yaw {
    
    /*Make a byte array for 3 floats, plus a FLAG at the beginning to indicate
     that this is acceleration data*/
    float flag = 1.0;
    float floatArray[4] = { flag, pitch, roll, yaw }; // 1 means rotation
    
    
    NSData * dataToSend = [NSData dataWithBytes:floatArray length: 4 * sizeof(float)];
    
   
    NSArray *peerIDs = session.connectedPeers;
    
    if ([peerIDs count] > 0) {
        int success = [session sendData:dataToSend toPeers:peerIDs withMode:MCSessionSendDataReliable error:nil];
        
        NSLog(@"Sent rotation data success? %d", success);
    }
    
}

/* Received a byte stream from remote peer*/
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

/* Start receiving a resource from remote peer*/
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

/* Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox*/
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

#pragma mark
#pragma mark <MCBrowserViewControllerDelegate> methods

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}



- (NSString *)participantID
{
    return self.session.myPeerID.displayName;
}

#pragma mark
#pragma mark helpers

- (void)setUIToNotConnectedState
{
    self.disconnectButton.enabled = NO;
    self.browseButton.enabled = YES;
}

- (void)setUIToConnectedState
{
    self.disconnectButton.enabled = YES;
    self.browseButton.enabled = NO;
}

@end

