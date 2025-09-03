//
//  ViewController.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 03.09.2025.
//

#import "ViewController.h"
#import <Speech/Speech.h>

@interface ViewController ()
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, weak) IBOutlet UILabel * statusLabel;
@end

@implementation ViewController

// https://developer.apple.com/documentation/speech/asking-permission-to-use-speech-recognition

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSString * statusText;
        if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
         //    [self startListening];
            statusText = @"Authorized";
        } else if (status == SFSpeechRecognizerAuthorizationStatusDenied) {
            statusText = @"Denied";
        } else if (status == SFSpeechRecognizerAuthorizationStatusRestricted) {
            statusText = @"Restricted";
        } else if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
            statusText = @"NotDetermined";
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = statusText;
        });
    }];
    // TODO: animate something to show the microphone is listening
}


@end
