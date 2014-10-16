//
//  JILOptionPicker.m
//  JITIPhoneQudao
//
//  Created by user on 13-9-27.
//  Copyright (c) 2013年 jit. All rights reserved.
//

#import "JILOptionPicker.h"

@interface JILOptionPicker () <UIGestureRecognizerDelegate>
@property (retain, nonatomic) NSArray *compnent1Options;
@property (assign, nonatomic) NSArray *compnent2Options;
@property (retain, nonatomic) NSArray *categoryOptions;

@end

@implementation JILOptionPicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubview];
    }
    return self;
}

- (void) awakeFromNib
{
	[super awakeFromNib];
	[self initSubview];
		
}

- (void) initSubview
{
    self.tapToDismiss = YES;
    if(self.pickerView) {
		self.pickerView.delegate = self;
		self.pickerView.dataSource = self;
	}
    UITapGestureRecognizer *r = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnBackground:)];
    [self addGestureRecognizer:r];
    r.cancelsTouchesInView = NO;
    r.delegate = self;
    [r release];
}

- (void) dealloc
{
	[_compnent1Options release];
	[_categoryOptions release];
	[_titleLabel release];
	[super dealloc];
}

- (void) setOptions:(NSArray *) options
{
	self.compnent1Options = options;
	self.compnent2Options = nil;
	self.categoryOptions = nil;
	[self.pickerView reloadAllComponents];
}

- (void) setCategories:(NSArray *) categories options:(NSArray *) options
{
	self.compnent1Options = categories;
	self.categoryOptions = options;
	self.compnent2Options = options[0];
	[self.pickerView reloadAllComponents];
}

- (void) setCategories:(NSArray *) categories
               options:(NSArray *) options
         categoryIndex:(NSInteger) categoryIndex
            optionIndex:(NSInteger) optionIndex
{
	self.compnent1Options = categories;
	self.categoryOptions = options;
	self.compnent2Options = options[categoryIndex];
	[self.pickerView reloadAllComponents];
    [self setSelectedIndex:categoryIndex];
    [self setSelectedIndex2:optionIndex];
}

- (void) setSelectedIndex:(NSInteger) index
{
	_selecttedIndex = index;
	if(index >= 0 && index < self.compnent1Options.count)
		[self.pickerView selectRow:index inComponent:0 animated:NO];
}

- (void) setSelectedIndex2:(NSInteger) index
{
	_selecttedIndex2 = index;
	if(index >= 0 && index < self.compnent2Options.count)
		[self.pickerView selectRow:index inComponent:1 animated:NO];
}

- (NSString *) selectedOption
{
    if(self.compnent2Options) {
        return _selecttedIndex2 >= 0 && _selecttedIndex2 < self.compnent2Options.count ? self.compnent2Options[_selecttedIndex2] : nil;
    } else {
        return _selecttedIndex >= 0 && _selecttedIndex < self.compnent1Options.count ? self.compnent1Options[_selecttedIndex] : nil;
    }
}

- (NSString *) selectedOption1
{
    return self.compnent1Options[_selecttedIndex];
}

- (NSString *) selectedOption2
{
    return self.compnent2Options[_selecttedIndex2];
}

- (void) setTitle:(NSString *) title
{
	[self.titleLabel setText:title];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return self.compnent2Options ? 2 : 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return component == 0 ? self.compnent1Options.count : self.compnent2Options.count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return component == 0 ? self.compnent1Options[row] : self.compnent2Options[row];
}

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return self.categoryOptions ? (component == 0 ? 110 : 190) : 300;
}

//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
//{
//    return 35.0f;
//}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if(self.categoryOptions) {
		if(component == 0) {
            _selecttedIndex = row;
			self.compnent2Options = self.categoryOptions[row];
			_selecttedIndex2 = 0;
			[pickerView reloadComponent:1];
		} else {
			_selecttedIndex2 = row;
		}
	} else {
		_selecttedIndex = row;
	}
}

- (void) presentOnView:(UIView *) view
{
    CGRect f = self.frame;
    f.size = view.frame.size;
    f.origin.y = 0;
    self.frame = f;
	[view addSubview:self];
}

- (void) dismiss
{
    [self removeFromSuperview];
}

- (void) handleTapOnBackground:(id) sender
{
    if(self.tapToDismiss)
        [self dismiss];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    UIView *v = touch.view;
    return  ![v isDescendantOfView:self.pickerView] && ![v isKindOfClass:[UIButton class]];
}
@end
