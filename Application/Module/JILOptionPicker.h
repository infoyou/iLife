//
//  JILOptionPicker.h
//  JITIPhoneQudao
//
//  Created by user on 13-9-27.
//  Copyright (c) 2013年 jit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JILOptionPicker : UIView<UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic) BOOL tapToDismiss;
@property (nonatomic) NSInteger selecttedIndex;
@property (nonatomic) NSInteger selecttedIndex2;

- (void) setOptions:(NSArray *) options;
- (void) setCategories:(NSArray *) categories options:(NSArray *) options;
- (void) setCategories:(NSArray *) categories
               options:(NSArray *) options
         categoryIndex:(NSInteger) categoryIndex
            optionIndex:(NSInteger) optionIndex;
- (void) setSelectedIndex:(NSInteger) index;
- (void) setSelectedIndex2:(NSInteger) index;
- (NSString *) selectedOption;
- (NSString *) selectedOption1;
- (NSString *) selectedOption2;
- (void) setTitle:(NSString *) title;
- (void) presentOnView:(UIView *) view;
- (void) dismiss;
@end
