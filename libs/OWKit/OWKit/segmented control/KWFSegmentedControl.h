//
//  KWFSegmentedControl.h
//  KWFBooks
//
//  Created by  iMac001 on 12-11-9.
//
//

@class  UIStyleObject;

@interface KWFSegmentedControl : UISegmentedControl {
    	
	UIFont  *_font;
    UIColor  *borderColor, *normalTextColor, *selectedTextColor;
    NSArray   *unselectedItemColor, *selectedItemColor;
}

- (void)setNormalColor:(NSString *)normalColor
         selectedColor:(NSString *)selectedColor
           borderColor:(NSString *)_borderColor
       textNormalColor:(NSString *)tnColor
     textSelectedColor:(NSString *)tsColor
              fontSize:(float)fontSize
       frameSizeHeight:(float)height
                corner:(float)coner;

- (void)setStyle:(UIStyleObject *)style;

@end
