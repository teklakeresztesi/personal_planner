//
//  ViewController.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 03.09.2025.
//

#import "MainViewController.h"
#import <Speech/Speech.h>

typedef NS_ENUM(NSUInteger, Status) {
    kApproved,
    kDenied,
    kUnknown
};

@interface MainViewController ()

@property (nonatomic, assign) Status status;

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@end

@implementation MainViewController

// https://developer.apple.com/documentation/speech/asking-permission-to-use-speech-recognition

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSString * statusText;
        
        if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
            statusText = @"Authorized";
            self.status = kApproved;
        } else if (status == SFSpeechRecognizerAuthorizationStatusDenied) {
            statusText = @"Denied";
            self.status = kDenied;
        } else if (status == SFSpeechRecognizerAuthorizationStatusRestricted) {
            statusText = @"Restricted";
            self.status = kDenied;
        } else if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
            statusText = @"NotDetermined";
            self.status = kUnknown;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = statusText;
            switch (self.status) {
                case kApproved:
                    self.startButton.titleLabel.text = @"Start listening";
                    break;
                case kDenied:
                case kUnknown:
                    self.startButton.titleLabel.text = @"Go to Settings";
                    break;
            }
        });
    }];
}

- (IBAction)startButtonPressed:(id)sender {
    if (self.status == kApproved) {
        [self performSegueWithIdentifier:@"StartListening" sender: self];
    } else {
        // TODO: open settings to app
    }
}

@end
