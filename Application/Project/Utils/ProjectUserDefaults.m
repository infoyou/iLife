
#import "ProjectUserDefaults.h"

#define APP_PROP_NAME @"ProjectProp"


@interface ProjectUserDefaults()
@property (nonatomic, retain) NSUserDefaults *defaults;
@end

@implementation ProjectUserDefaults{
    NSDictionary *_appProps;
}

- (id) init
{
	self = [super init];
	if(self) {
		NSString *p = [[NSBundle mainBundle] pathForResource:APP_PROP_NAME ofType:@"plist"];
		_appProps = [[NSDictionary dictionaryWithContentsOfFile:p] retain];
		assert(_appProps);
	}
	return self;
}

- (void) dealloc
{
	[_appProps release];
	[_defaults release];
	[super dealloc];
}

//system defaults
- (id) valueForAppProperty:(NSString *) key
{
	assert(_appProps);
	return [_appProps objectForKey:key];
}

- (NSString *) usernameRemembered
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
}

- (NSString *) passwordRemembered
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
}

- (NSString *) passwordStrRemembered
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"pswdStr"];
}

- (NSString *)customerNameRemembered {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"emailName"];
}

- (NSString *)getSaveUserId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
}

- (void)rememberUsername:(NSString *)username
			  andPassword:(NSString *)password
                 pswdStr:(NSString *)pswdStr
            emailName:(NSString *)emailName
                  userId:(NSString *)userId
{
	NSUserDefaults *_def = [NSUserDefaults standardUserDefaults];
    
	if(username == nil) {
		[_def removeObjectForKey:@"username"];
		[_def removeObjectForKey:@"password"];
        [_def removeObjectForKey:@"pswdStr"];
        [_def removeObjectForKey:@"emailName"];
        [_def removeObjectForKey:@"userId"];
	} else {
		[_def setObject:username forKey:@"username"];
		[_def setObject:password forKey:@"password"];
        [_def setObject:pswdStr forKey:@"pswdStr"];
        [_def setObject:emailName forKey:@"emailName"];
        [_def setObject:userId forKey:@"userId"];
	}
    
	[_def synchronize];
}

@end
