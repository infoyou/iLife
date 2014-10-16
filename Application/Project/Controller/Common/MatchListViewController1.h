//
//  MatchListViewController.h
//  DropDownList
//
//  Created by Adam on 14-7-9.
//

#import <UIKit/UIKit.h>

@protocol PassValueDelegate;

@interface MatchListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    
	NSString		*_searchText;
	NSString		*_selectedText;
	NSMutableArray	*_resultList;
	id <PassValueDelegate>	_delegate;
}

@property (nonatomic, copy) NSString		*_searchText;
@property (nonatomic, copy) NSString		*_selectedText;
@property (nonatomic, retain)   NSMutableArray	*_resultList;
@property (nonatomic, assign) id <PassValueDelegate> _delegate;

- (void)updateMatchData:(NSMutableArray*)listData;

@end

@protocol PassValueDelegate

- (void)passValue:(NSString *)value;

@end