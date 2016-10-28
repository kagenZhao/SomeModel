//
//  ViewController.m
//  ForRegexTest
//
//  Created by Kagen Zhao on 16/9/5.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import "ViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()<NSTextViewDelegate>
@property (unsafe_unretained) IBOutlet NSTextView *regexTextView;
@property (unsafe_unretained) IBOutlet NSTextView *replaceTextView;
@property (unsafe_unretained) IBOutlet NSTextView *sourceTextView;
@property (unsafe_unretained) IBOutlet NSTextView *replacedTextView;
@property (unsafe_unretained) IBOutlet NSTextView *matchedTextView;
@property NSArray <NSTextCheckingResult *>*currentMatchArr;
@property NSArray <NSValue *> *matchRangeArr;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.matchedTextView.delegate = self;
    self.regexTextView.font = [NSFont systemFontOfSize:17];
    self.replaceTextView.font = [NSFont systemFontOfSize:17];
    self.sourceTextView.font = [NSFont systemFontOfSize:17];
    self.replacedTextView.font = [NSFont systemFontOfSize:17];
    self.matchedTextView.font = [NSFont systemFontOfSize:17];
    @weakify(self)
    
    [self.regexTextView.rac_textSignal subscribeNext:^(id x) {
        @strongify(self)
        [self reloadRegex];
    }];
    
    [self.sourceTextView.rac_textSignal subscribeNext:^(NSString *x) {
        @strongify(self)
        [self reloadRegex];
    }];
    
    [self.replaceTextView.rac_textSignal subscribeNext:^(id x) {
        @strongify(self)
        [self reloadRegex];
    }];

    NSEvent * (^monitorHandler)(NSEvent *);
    monitorHandler = ^NSEvent * (NSEvent * theEvent){
        NSEvent *result = theEvent;
        NSArray <NSResponder *>*responderArr = @[self.regexTextView, self.replaceTextView, self.sourceTextView];
        NSResponder * firstResponder = [NSApplication sharedApplication].keyWindow.firstResponder;
        if (self.regexTextView == firstResponder ||
            self.replaceTextView == firstResponder ||
            self.sourceTextView == firstResponder) {
            if (theEvent.type == NSKeyDown) {
                if (theEvent.keyCode == 48) {
                    NSUInteger i = [responderArr indexOfObject:firstResponder];
                    i += 1;
                    if (i == responderArr.count) {
                        i = 0;
                    }
                    [[NSApplication sharedApplication].keyWindow makeFirstResponder:responderArr[i]];
                    result = nil;
                }
            }
        }
        return result;
    };
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:monitorHandler];
    
}


- (void)reloadRegex {
    NSString *regex = self.regexTextView.string;
    NSError *error = nil;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *match = [reg matchesInString:self.sourceTextView.string options:0 range:NSMakeRange(0, [self.sourceTextView.string length])];
    NSString *matchTextViewString = @"";
    self.matchedTextView.string = @"";
    self.replacedTextView.string = self.sourceTextView.string.copy;
    self.currentMatchArr = match;
    self.matchRangeArr = nil;
    NSInteger distenceLocation = 0;
    NSMutableArray *tempMatchArr = @[].mutableCopy;
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self.sourceTextView.string attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:17]}];
    for (NSTextCheckingResult *result in match) {
        NSRange range = result.range;
        [attString setAttributes:@{NSForegroundColorAttributeName:[NSColor redColor],
                                   NSFontAttributeName:[NSFont systemFontOfSize:17]} range:range];
        [self.sourceTextView.textStorage setAttributedString:attString];
        NSString *resultString = [self.sourceTextView.string substringWithRange:range];
        NSRange linkAttRange;
        if (matchTextViewString.length) {
            matchTextViewString = [matchTextViewString stringByAppendingString:@"\n"];
            linkAttRange = NSMakeRange(matchTextViewString.length, resultString.length);
            matchTextViewString = [matchTextViewString stringByAppendingString:resultString];
        } else {
            matchTextViewString = resultString;
            linkAttRange = NSMakeRange(0, resultString.length);
        }
        [tempMatchArr addObject:[NSValue valueWithRange:linkAttRange]];
        self.matchedTextView.string = matchTextViewString;
        [self.matchedTextView.textStorage addAttribute:NSLinkAttributeName value:resultString range:linkAttRange];
        
        [self.replacedTextView replaceCharactersInRange:NSMakeRange(range.location + distenceLocation, range.length) withString:self.replaceTextView.string];
        distenceLocation += self.replaceTextView.string.length - range.length;
    }
    self.matchRangeArr = tempMatchArr;
    if (self.replaceTextView.string.length) {
        self.replacedTextView.string = [reg stringByReplacingMatchesInString:self.sourceTextView.string options:0 range:NSMakeRange(0, self.sourceTextView.string.length) withTemplate:self.replaceTextView.string];
    }
}


- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    for (NSValue *rangeValue in self.matchRangeArr) {
        NSRange range = rangeValue.rangeValue;
        if (charIndex >= range.location && charIndex < range.location + range.length) {
            [self.sourceTextView setSelectedRange:self.currentMatchArr[[self.matchRangeArr indexOfObject:rangeValue]].range];
            return YES;
            break;
        }
    }
    return NO;
}

@end
