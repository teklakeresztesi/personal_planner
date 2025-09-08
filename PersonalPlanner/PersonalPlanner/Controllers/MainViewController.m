//
//  ViewController.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 03.09.2025.
//

#import "MainViewController.h"
#import "SpeechManager.h"
#import "SpeechManagerDelegate.h"
#import <Speech/Speech.h>


@interface MainViewController ()<SpeechManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) SpeechManager *speechManager;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.speechManager = [SpeechManager sharedInstance];
    self.speechManager.delegate = self;
    
    [self updateViewStatus];
}

- (IBAction)startButtonPressed:(id)sender {
    if ([self.speechManager isAllApproved]) {
        [self performSegueWithIdentifier:@"StartListening" sender: self];
    } else {
        // open settings to app
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [application openURL:settingsURL options:@{} completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"Opened url");
            }
        }];
    }
}

#pragma mark - SpeechManagerDelegate

- (void)permissionsUpdated:(id)sender {
    [self updateViewStatus];
}

#pragma mark - Private

- (void)updateViewStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.speechManager isAllApproved]) {
            self.statusLabel.text = @"Ready for voice commands";
            [self.startButton setTitle:@"Start listening" forState: UIControlStateNormal];
        } else if ([self.speechManager isAnyDenied]) {
            self.statusLabel.text = @"Check your settings";
            [self.startButton setTitle:@"Go to Settings" forState: UIControlStateNormal];
        } else {
            self.statusLabel.text = @"Trying to request permissions";
            [self.startButton setTitle:@"" forState: UIControlStateNormal];
            [self.speechManager requestPermissions];
        }
    });
}

@end
