//
//  Command.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 04.09.2025.
//

#import "Command.h"

@interface Command ()

@end

@implementation Command

- (id)initWithText:(NSString *)text type:(CommandType)type {
    self = [super init];
    if (self) {
        _text = text;
        _type = type;
    }
    return self;
}

@end
