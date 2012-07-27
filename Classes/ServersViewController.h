//
//  ServersViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackViewController.h"

@class OpenStackAccount, AccountHomeViewController;

@interface ServersViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIBarButtonItem *refreshButton;
    BOOL loaded;
    BOOL serversLoaded;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) AccountHomeViewController *accountHomeViewController;
@property (nonatomic, assign) BOOL comingFromAccountHome;
@property (nonatomic, retain) NSMutableDictionary *servers;

- (void)refreshButtonPressed:(id)sender;

@end
