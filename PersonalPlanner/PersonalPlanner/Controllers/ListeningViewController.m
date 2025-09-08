//
//  ListeningViewController.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 04.09.2025.
//

#import "ListeningViewController.h"
#import "SpeechManager.h"

@interface ListeningViewController ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;

@property (nonatomic, weak) SpeechManager *speechManager;
@end

@implementation ListeningViewController

- (void)setIsListening:(BOOL)isListening {
    if (isListening) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.speechManager = [SpeechManager sharedInstance];
    self.speechManager.delegate = self;
    
    self.isListening = [self.speechManager startListening];
}

- (IBAction)stopButtonPressed:(id)sender {
    NSLog(@"Stop button pressed");
    [self.speechManager stopListening];
    self.isListening = false;
}

- (void)speechManager:(id)sender handleCommand:(NSString *)command { 
    NSLog(@"Handle command: %@", command);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textLabel.text = command;
    });
}

@end
