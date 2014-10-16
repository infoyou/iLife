//
//  MatchListViewController.m
//  DropDownList
//
//  Created by Adam on 14-7-9.
//

#import "MatchListViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation MatchListViewController

@synthesize _searchText, _selectedText, _resultList, _delegate, toMatchView;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.layer.borderWidth = 1;
	self.tableView.layer.borderColor = [[UIColor blackColor] CGColor];
	self.tableView.delegate = self;
    self.tableView.canCancelContentTouches = NO;

	_searchText = nil;
	_selectedText = nil;
//    toMatchView = nil;
	_resultList = [[NSMutableArray alloc] initWithCapacity:5];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)updateMatchData:(NSMutableArray*)listData {
    
	[_resultList removeAllObjects];
    
    // Demo
//	[_resultList addObject:_searchText];
    
//	for (int i = 1; i<10; i++) {
//		[_resultList addObject:[NSString stringWithFormat:@"%@%d", _searchText, i]];
//	}
    
    [_resultList addObjectsFromArray:listData];
    
	[self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_resultList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MatchListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [_resultList objectAtIndex:row];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedText = [_resultList objectAtIndex:[indexPath row]];
    if (toMatchView != nil) {
        [_delegate passValue:_selectedText toMatchView:toMatchView];
    }else
    {
        [_delegate passValue:_selectedText];
    }
}

- (void)dealloc {
    [super dealloc];
}

@end

