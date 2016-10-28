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
@property (weak) IBOutlet NSButton *regexTips;
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
//        self.replacedTextView.string = self.sourceTextView.string.copy;
//        NSInteger distenceLocation = 0;
//        for (NSTextCheckingResult *result in self.currentMatchArr) {
//            NSRange range = result.range;
//            [self.replacedTextView replaceCharactersInRange:NSMakeRange(range.location + distenceLocation, range.length) withString:self.replaceTextView.string];
//            distenceLocation += self.replaceTextView.string.length - range.length;
//        }
    }];
//    
//    self.regexTips.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            [subscriber sendNext:@YES];
//            [subscriber sendCompleted];
//            return nil;
//        }];
//    }];
//    
//    
//    [[[self.regexTips.rac_command executionSignals] switchToLatest] subscribeNext:^(id x) {
//        @strongify(self)
//       
//    }];
//    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:NSWindowDidMoveNotification object:nil] subscribeNext:^(id x) {
        
    }];
    
}


- (void)reloadRegex {
    NSString *regex = self.regexTextView.string;
    NSError *error = nil;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *match = [reg matchesInString:self.sourceTextView.string options:0 range:NSMakeRange(0, [self.sourceTextView.string length])];
    NSString *matchTextViewString = @"";
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
        [self.matchedTextView.textStorage addAttribute:NSLinkAttributeName value:resultString range:linkAttRange];
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
