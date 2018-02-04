//
//  AXViewController.m
//  AXReachability
//
//  Created by ansari.ahmad@gmail.com on 02/04/2018.
//  Copyright (c) 2018 ansari.ahmad@gmail.com. All rights reserved.
//

#import "AXViewController.h"
#import <AXReachability/AXReachability.h>

@interface AXViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@end

@implementation AXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetworkConnectivityChanged:) name:kNotifConnectivityChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetworkDisconnected:) name:kNotifNoConnectivity object:nil];
    [self loadNetworkInformation];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network Information
- (void)loadNetworkInformation {
    if(![[AXReachability sharedReachability] isConnectedToInternet]) {
        [self showNoConnectivityAlert];
    }
}

#pragma mark - Network Connectivity Notifications
- (void) onNetworkDisconnected:(id)notification {
    NSLog(@"Network Disconnected");
    [self showNoConnectivityAlert];
    [self checkInternetConnectivity];
}

- (void) onNetworkConnectivityChanged:(id)notification {
    NSLog(@"Network Connectivity Changed");
    [self checkInternetConnectivity];
}

- (void) checkInternetConnectivity {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([[AXReachability sharedReachability] isConnectedToInternet]) {
            self.statusLabel.text = @"Internet Connected";
            self.statusLabel.textColor = [UIColor colorWithRed:49/255.0
                                                         green:200/255.0
                                                          blue:107/255.0
                                                         alpha:1];
            self.typeLabel.hidden = NO;
            
            AXNetworkType networkType = [[AXReachability sharedReachability] networkType];
            NSString *networkDescription = [[AXReachability sharedReachability] descriptionForNetworkType:networkType];
            self.typeLabel.text = [NSString stringWithFormat:@"Connected Via: %@",  networkDescription];
        } else {
            self.statusLabel.text = @"No Internet Connection";
            self.statusLabel.textColor = [UIColor redColor];
            self.typeLabel.hidden = YES;
        }
    });
    
}

#pragma mark - Alert Methods

- (void)showNoConnectivityAlert {
    [self showAlertWithTitle:@"Error"
                     message:@"No Internet Connectivity"
           cancelButtonTitle:@"Cancel"];
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:title
                                                  message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController
             addAction:[UIAlertAction actionWithTitle:cancelButtonTitle
                                                style:UIAlertActionStyleCancel
                                              handler:nil]];
            [self presentViewController:alertController
                               animated:YES
                             completion:nil];
        }
    });
}

@end
