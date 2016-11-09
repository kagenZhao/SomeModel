//
//  DXViewController.m
//  DXRouter
//
//  Created by tomcat2088 on 09/19/2016.
//  Copyright (c) 2016 tomcat2088. All rights reserved.
//

#import "DXHomeViewController.h"
#import "DXRouter/DXRouter.h"

@interface DXHomeViewController () <DXRouterViewControllerInstantiation>

@end

@implementation DXHomeViewController

DXRouterInitPageFromStoryboard(@"Main", @"DXHomeViewController")

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [[DXRouter shared] navigateTo:@"DXA" arguments:nil];
            break;
        case 1:
            [[DXRouter shared] navigateWithArguments:nil fullRouter:@[@"DXHome",@"DXTab:DXA",@"DXHome"]];
            break;
        case 2:
            [[DXRouter shared] presentAsDialog:@"DXDialog" arguments:nil];
            break;
        case 3:
            [[DXRouter shared] navigateWithArguments:nil fullRouter:@[@"DXHome",@"#DXDialog"]];
            break;
        case 4:
            [[DXRouter shared] navigateWithArguments:nil fullRouter:@[@"DXHome",@"DXTab:DXRed"]];
            break;
        case 5:
            [[DXRouter shared] goBackToFirstOf:@"DXTab:DXRed"];
            [[DXRouter shared] presentAsDialog:@"DXDialog"];
//            [[DXRouter shared] navigateWithArguments:nil fullRouter:@[@"DXTab:DXA",@"#DXDialog"]];
            break;
        default:
            break;
    }
}


@end
