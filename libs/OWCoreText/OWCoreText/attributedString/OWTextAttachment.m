//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#import "OWTextAttachment.h"

@implementation OWTextAttachment{
    OWTextAttachmentVerticalAlignment _verticalAlignment;
	id contents;
    NSDictionary *_attributes;
    
    OWTextAttachmentType contentType;
	CGSize _originalSize;
	CGSize _displaySize;
    
	NSURL *_contentURL;
	NSURL *_hyperLinkURL;
	
	CGFloat _fontLeading;
	CGFloat _fontAscent;
	CGFloat _fontDescent;
}


- (CGFloat)ascentForLayout
{
	switch (_verticalAlignment) 
	{
		case OWTextAttachmentVerticalAlignmentBaseline:
		{
			return _displaySize.height;
		}
		case OWTextAttachmentVerticalAlignmentTop:
		{
			return _fontAscent;
		}	
		case OWTextAttachmentVerticalAlignmentCenter:
		{
			CGFloat halfHeight = (_fontAscent + _fontDescent) / 2.0f;
			
			return halfHeight - _fontDescent + _displaySize.height/2.0f;
		}
		case OWTextAttachmentVerticalAlignmentBottom:
		{
			return _displaySize.height - _fontDescent;
		}
	}
}

- (CGFloat)descentForLayout
{
	switch (_verticalAlignment) 
	{
		case OWTextAttachmentVerticalAlignmentBaseline:
		{
			return 0;
		}	
		case OWTextAttachmentVerticalAlignmentTop:
		{
			return _displaySize.height - _fontAscent;
		}	
		case OWTextAttachmentVerticalAlignmentCenter:
		{
			CGFloat halfHeight = (_fontAscent + _fontDescent) / 2.0f;
			
			return halfHeight - _fontAscent + _displaySize.height/2.0f;
		}	
		case OWTextAttachmentVerticalAlignmentBottom:
		{
			return _fontDescent;
		}
	}
}

@synthesize originalSize = _originalSize;
@synthesize displaySize = _displaySize;
@synthesize contents;
@synthesize contentType;
@synthesize contentURL = _contentURL;
@synthesize hyperLinkURL = _hyperLinkURL;
@synthesize attributes = _attributes;
@synthesize verticalAlignment = _verticalAlignment;
@synthesize positionCenter;
@end
