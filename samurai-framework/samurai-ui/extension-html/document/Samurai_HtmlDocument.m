//
//     ____    _                        __     _      _____
//    / ___\  /_\     /\/\    /\ /\    /__\   /_\     \_   \
//    \ \    //_\\   /    \  / / \ \  / \//  //_\\     / /\/
//  /\_\ \  /  _  \ / /\/\ \ \ \_/ / / _  \ /  _  \ /\/ /_
//  \____/  \_/ \_/ \/    \/  \___/  \/ \_/ \_/ \_/ \____/
//
//	Copyright Samurai development team and other contributors
//
//	http://www.samurai-framework.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import "Samurai_HtmlDocument.h"

#import "_pragma_push.h"

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "Samurai_HtmlDocumentWorkflow.h"
#import "Samurai_HtmlMediaQuery.h"

#import "Samurai_CssParser.h"
#import "Samurai_CssStyleSheet.h"

#import "Samurai_HtmlRenderObject.h"
#import "Samurai_HtmlRenderObjectContainer.h"
#import "Samurai_HtmlRenderObjectElement.h"
#import "Samurai_HtmlRenderObjectText.h"
#import "Samurai_HtmlRenderObjectViewport.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation SamuraiHtmlDocument
{
	SamuraiHtmlDocumentWorkflow_Parser *	_reparse;
	SamuraiHtmlDocumentWorkflow_Render *	_reflow;
}

- (id)init
{
	self = [super init];
	if ( self )
	{
		self.rootTag = @"html";
		self.headTag = @"head";
		self.bodyTag = @"body";
	}
	return self;
}

- (void)dealloc
{
	_reparse = nil;
	_reflow = nil;
}

#pragma mark -

+ (NSArray *)supportedExtensions
{
	return [NSArray arrayWithObjects:@"html", @"htm", nil];
}

+ (NSArray *)supportedTypes
{
	return [NSArray arrayWithObjects:@"text/html", nil];
}

+ (NSString *)baseDirectory
{
	return @"/www/html";
}

#pragma mark -

- (BOOL)parse
{
	if ( nil == _reparse )
	{
		_reparse = [SamuraiHtmlDocumentWorkflow_Parser workflowWithContext:self];
	}
	
	return [_reparse process];
}

- (BOOL)reflow
{
	if ( nil == _reflow )
	{
		_reflow = [SamuraiHtmlDocumentWorkflow_Render workflowWithContext:self];
	}

	return [_reflow process];
}

#pragma mark -

- (void)configuringForView:(UIView *)view
{
	// TODO:
}

- (void)configuringForViewController:(UIViewController *)viewController
{
	SamuraiDomNode * head = [self getHead];
	
	UIImage *	navbarBgImage = nil;
	UIColor *	navbarBgColor = nil;
	UIColor *	navbarTintColor = nil;
	UIColor *	navbarTextColor = nil;
	NSString *	navbarTitle = nil;

	if ( head )
	{
		for ( SamuraiDomNode * child in head.childs )
		{
			if ( NSOrderedSame == [child.domTag compare:@"meta" options:NSCaseInsensitiveSearch] )
			{
				NSString * name = [child.domAttributes objectForKey:@"name"];
				NSString * content = [child.domAttributes objectForKey:@"content"];
				
				if ( name && content )
				{
					if ( [name isEqualToString:@"navbar-bg-color"] )
					{
						navbarBgColor = [SamuraiHtmlColor parseColor:content];
					}
					else if ( [name isEqualToString:@"navbar-bg-image"] )
					{
						navbarBgImage = [UIImage imageNamed:content];
					}
					else if ( [name isEqualToString:@"navbar-tint-color"] )
					{
						navbarTintColor = [SamuraiHtmlColor parseColor:content];
					}
					else if ( [name isEqualToString:@"navbar-text-color"] )
					{
						navbarTextColor = [SamuraiHtmlColor parseColor:content];
					}
				}
			}
			else if ( NSOrderedSame == [child.domTag compare:@"title" options:NSCaseInsensitiveSearch] )
			{
				navbarTitle = [child computeInnerText];
			}
		}
	}

	CGSize navigationBarSize = CGSizeMake( [UIScreen mainScreen].bounds.size.width, 64.0f );

	if ( navbarBgColor )
	{
		navbarBgImage = navbarBgImage ?: [UIImage imageWithColor:navbarBgColor size:navigationBarSize];
	}

	UINavigationBar * navigationBar = viewController.navigationController.navigationBar;

	if ( navbarTintColor )
	{
		[navigationBar setTintColor:navbarTintColor];
	}
	
	if ( navbarTintColor )
	{
		[navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: navbarTintColor }];
	}
	
	if ( navbarBgColor )
	{
		[navigationBar setBackgroundColor:navbarBgColor];
	}
	
	if ( navbarBgImage )
	{
		[navigationBar setBackgroundImage:navbarBgImage forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
	}
	
	if ( navbarTitle )
	{
		viewController.title = navbarTitle;
	}
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if __SAMURAI_TESTING__

TEST_CASE( UI, HtmlDocument )

DESCRIBE( before )
{
}

DESCRIBE( after )
{
}

TEST_CASE_END

#endif	// #if __SAMURAI_TESTING__

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "_pragma_pop.h"
