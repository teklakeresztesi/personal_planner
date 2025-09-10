//
//  CommandParserTests.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 10.09.2025.
//

#import <XCTest/XCTest.h>
#import "CommandParser.h"
#import "Command.h"

@interface CommandParserTests : XCTestCase
@end

@implementation CommandParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testGetCommand_expectSchedule_whenTextContainsSchedule {
    // Arrange
    NSString *text = @"Schedule a meeting at 4";
    // Act
    Command *command = [CommandParser getCommand:text];
    // Assert
    XCTAssertEqual(command.type, CommandTypeSchedule);
    XCTAssertEqual(command.text, text);
}

- (void)testGetCommand_expectReminder_whenTextContainsRemind {
    NSString *text = @"Remind me to buy milk";
    Command *command = [CommandParser getCommand:text];
    XCTAssertEqual(command.type, CommandTypeReminder);
    XCTAssertEqual(command.text, text);
}

- (void)testGetCommand_expectToDo_whenTextContainsList {
    NSString *text = @"Add bread to my shopping list";
    Command *command = [CommandParser getCommand:text];
    XCTAssertEqual(command.type, CommandTypeToDo);
    XCTAssertEqual(command.text, text);
}

- (void)testGetCommand_expectStop_whenTextContainsStop {
    NSString *text = @"Stop";
    Command *command = [CommandParser getCommand:text];
    XCTAssertEqual(command.type, CommandTypeStop);
    XCTAssertEqual(command.text, text);
}

- (void)testGetCommand_expectReminder_whenReminderPresedesStop {
    NSString *text = @"Remind me to stop by the store on my way home";
    Command *command = [CommandParser getCommand:text];
    XCTAssertEqual(command.type, CommandTypeReminder);
    XCTAssertEqual(command.text, text);
}


@end
