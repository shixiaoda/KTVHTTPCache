//
//  ViewController.m
//  KTVHTTPCacheDemo
//
//  Created by Single on 2017/8/10.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "ViewController.h"
#import "MediaPlayerViewController.h"
#import "MediaItem.h"
#import "MediaCell.h"
#import <KTVHTTPCache/KTVHTTPCache.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic, strong) NSArray <MediaItem *> * medaiItems;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%@",NSHomeDirectory());
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupHTTPCache];
    });
    [self reloadData];
}

- (void)setupHTTPCache
{
//    [KTVHTTPCache logSetConsoleLogEnable:YES];
    [self startHTTPServer];
    [self configurationFilters];
}

- (void)startHTTPServer
{
    NSError * error;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
        NSLog(@"Proxy Start Failure, %@", error);
    } else {
        NSLog(@"Proxy Start Success");
    }
}

- (void)configurationFilters
{
#if 0
    // URL Filter
    [KTVHTTPCache cacheSetURLFilterForArchive:^NSString *(NSString * originalURLString) {
        NSLog(@"URL Filter reviced URL, %@", originalURLString);
        return originalURLString;
    }];
#endif
    
#if 0
    // Content-Type Filter
    [KTVHTTPCache cacheSetContentTypeFilterForResponseVerify:^BOOL(NSString * URLString,
                                                                   NSString * contentType,
                                                                   NSArray<NSString *> * defaultAcceptContentTypes) {
        NSLog(@"Content-Type Filter reviced Content-Type, %@", contentType);
        if ([defaultAcceptContentTypes containsObject:contentType]) {
            return YES;
        }
        return NO;
    }];
#endif
}

- (void)reloadData
{
    MediaItem * item1 = [[MediaItem alloc] initWithTitle:@"萧亚轩 - 冲动"
                                               URLString:@"http://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4"];
    MediaItem * item2 = [[MediaItem alloc] initWithTitle:@"张惠妹 - 你是爱我的"
                                               URLString:@"http://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4"];
    MediaItem * item3 = [[MediaItem alloc] initWithTitle:@"hush! - 都是你害的"
                                               URLString:@"http://cache.m.iqiyi.com/mus/8236947609/831cff3f0caa4d8745dc8015cf3b587b/afbe8fd3d73448c9//20170710/02/a2/98e65e9e1355abb1de53fe4f1185e4b5.m3u8?qd_originate=tmts_py&tvid=8236947609&bossStatus=0&qd_vip=0&px=&qd_src=null&prv=&previewType=&previewTime=&from=&qd_time=1515660548697&qd_p=7f000001&qd_asc=22dcf44a16c6896dd6fa0b7da0b56fc6&qypid=8236947609_04000000001000000000_2&qd_k=eff157d9477aa13d41e3a6ce456fbb14&isdol=0&code=2&vf=3f1aced0529e3afe81ca81f60b0a5888&np_tag=nginx_part_tag&v=528544833&qypid=8236947609_-102109"];
    MediaItem * item4 = [[MediaItem alloc] initWithTitle:@"张学友 - 我真的受伤了"
                                               URLString:@"http://res.pmit.cn/F3Video/hls/a5814959235386e4e7126573030c4d79/list.m3u8"];
    self.medaiItems = @[item1, item2, item3, item4];
    [self.tableView reloadData];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.medaiItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MediaCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MediaCell"];
    [cell configureWithTitle:[self.medaiItems objectAtIndex:indexPath.row].title];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * URLString = [self.medaiItems objectAtIndex:indexPath.row].URLString;
    
    if (URLString.length <= 0) {
        return;
    }
    
    NSString * proxyURLString = [KTVHTTPCache proxyURLStringWithOriginalURLString:URLString];
    
    MediaPlayerViewController * viewController = [[MediaPlayerViewController alloc] initWithURLString:proxyURLString];
    [self presentViewController:viewController animated:YES completion:nil];
}


@end
