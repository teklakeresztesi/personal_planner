//
//  ListeningViewController.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 04.09.2025.
//

#import "ListeningViewController.h"
#import "SpeechManager.h"
#import "CommandParser.h"
#import "CommandCell.h"

@interface ListeningViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UITableView *commandTableView;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;


@property (nonatomic, weak) SpeechManager *speechManager;
@property (nonatomic, assign) BOOL isListening;

@property (nonatomic, strong) NSMutableArray *commands;

@end

@implementation ListeningViewController

- (void)setIsListening:(BOOL)isListening {
    if (isListening) {
        [self.activityIndicator setHidden:NO];
        [self.activityIndicator startAnimating];
        [self.stopButton setTitle:@"Stop listening" forState:UIControlStateNormal];
    } else {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
        [self.stopButton setTitle:@"Start listening" forState:UIControlStateNormal];
    }
    _isListening = isListening;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.commands = [[NSMutableArray alloc] init];
    
    self.speechManager = [SpeechManager sharedInstance];
    self.speechManager.delegate = self;
    [self.speechManager addObserver:self forKeyPath:@"isListening" options:NSKeyValueObservingOptionNew context:nil];
    [self.speechManager startListening];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"isListening"]) {
        BOOL isListening = [change[NSKeyValueChangeNewKey] boolValue];
        NSLog(@"KVO observed status change: %d", isListening);
        self.isListening = isListening;
    }
}

-(void)dealloc {
    [self.speechManager removeObserver:self forKeyPath:@"isListening"];
}

- (IBAction)stopButtonPressed:(id)sender {
    if (_isListening) {
        NSLog(@"Stop button pressed");
        [self.speechManager stopListening];
    } else {
        NSLog(@"Start button pressed");
        [self.speechManager startListening];
    }
}

#pragma mark - SpeechManagerDelegate methods

- (void)speechManager:(id)sender handleText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Got text: %@", text);
    });
}

- (void)speechManager:(id)sender handleFinalText:(NSString *)text {
    Command * command = [CommandParser getCommand:text];
    NSLog(@"Got command: %@ type: %@", command.text, NSStringFromCommandType(command.type));
    
    if (command.type == CommandTypeStop) {
        [self stopButtonPressed:self.stopButton];
        return;
    }
    
    if (command.type != CommandTypeUnknown) {
        [self.commands addObject:command];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.commandTableView reloadData];
    });
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CommandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommandCell"];
    Command *command = self.commands[indexPath.row];
    cell.title.text = command.text;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return self.commands.count;
}


@end
