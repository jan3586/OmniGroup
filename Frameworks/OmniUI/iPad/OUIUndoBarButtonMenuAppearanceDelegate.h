// Copyright 2015-2017 Omni Development, Inc. All rights reserved.
//  Copyright 2015 The Omni Group. All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//
// $Id$

#import <Foundation/NSObject.h>

@protocol OUIUndoBarButtonMenuAppearanceDelegate <NSObject>

- (nullable UIColor *)undoBarButtonMenuBackgroundColor;
- (nullable UIColor *)undoBarButtonMenuOptionBackgroundColor;
- (nullable UIColor *)undoBarButtonMenuOptionSelectionColor;
- (nullable UIColor *)undoBarButtonMenuPopoverBackgroundColor;

@end


