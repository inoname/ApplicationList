//
//  ViewController.m
//  加载网络图片
//
//  Created by kouliang on 15/1/10.
//  Copyright (c) 2015年 kouliang. All rights reserved.
//

#import "ViewController.h"
#import "App.h"
#import "NSString+Dir.h"

@interface ViewController ()
@property(nonatomic,strong)NSOperationQueue *opQueue;
@property(nonatomic,strong)NSArray *apps;
@property(nonatomic,strong)NSMutableDictionary *operationCache;
@property(nonatomic,strong)NSCache *imageCache;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(NSOperationQueue *)opQueue{
    if (_opQueue==nil) {
        _opQueue=[[NSOperationQueue alloc]init];
    }
    return _opQueue;
}

-(NSArray *)apps{
    if (_apps==nil) {
        NSURL *url=[[NSBundle mainBundle]URLForResource:@"apps.plist" withExtension:nil];
        NSArray *dictArray=[NSArray arrayWithContentsOfURL:url];
        NSMutableArray *arrayM=[NSMutableArray arrayWithCapacity:dictArray.count];
        
        [dictArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            App *app=[App appWithDict:obj];
            [arrayM addObject:app];
        }];
        _apps=[arrayM copy];
        
    }
    return _apps;
}

-(NSMutableDictionary *)operationCache{
    if (_operationCache==nil) {
        _operationCache=[NSMutableDictionary dictionary];
    }
    return _operationCache;
}

-(NSCache *)imageCache{
    if (_imageCache==nil) {
        _imageCache=[[NSCache alloc]init];
    }
    return _imageCache;
}

#pragma mark - 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    //清空缓存
    [self.imageCache removeAllObjects];
    [self.operationCache removeAllObjects];
    
    //如果有正在进行的下载操作，也一起取消
    [self.opQueue cancelAllOperations];
}

#pragma mark - tableview代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.apps.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    App *app=self.apps[indexPath.row];
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"appCell"];
    
    cell.textLabel.text=app.name;
    cell.detailTextLabel.text=app.download;
    
    if ([self.imageCache objectForKey:app.icon]) {
        NSLog(@"没有下载图像");
        cell.imageView.image=[self.imageCache objectForKey:app.icon];
    }else{
        //判断沙盒中是否存在图像
        UIImage *image=[UIImage imageWithContentsOfFile:[app.icon cacheDir]];
        if (image!=nil) {
            NSLog(@"从磁盘加载");
            //设置图片缓存
            [self.imageCache setObject:image forKey:app.icon];
            //这几设置cell
            cell.imageView.image=image;
        }else{
            //设置默认图片，解决cell需要交互才能显示图片的问题
            cell.imageView.image=[UIImage imageNamed:@"user_default"];
            [self downloadImage:indexPath];
        }
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",self.operationCache);
}

-(void)dealloc{
    NSLog(@"哥走了！");
}



-(void)downloadImage:(NSIndexPath *)indexPath{
    
    App *app=self.apps[indexPath.row];
    
    //如果缓存池中没有操作
    if (!self.operationCache[app.icon]) {
        //定义操作
        NSBlockOperation *op=[NSBlockOperation blockOperationWithBlock:^{
            
            NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:app.icon]];
            
            if (data!=nil) {
                NSLog(@"下载成功");
                //写入沙盒
                [data writeToFile:[app.icon cacheDir] atomically:YES];
                UIImage *icon=[UIImage imageWithData:data];
                //加入图像缓存
                [self.imageCache setObject:icon forKey:app.icon];
                //主线程更新UI
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }];
                //操作从缓存中移除
                //只有下载成功后才移除
                //[self.operationCache removeObjectForKey:app.icon];
            }
            else{
                NSLog(@"图像下载失败");
           }
            
            //不管现在有没有成功都会移除操作。
            [self.operationCache removeObjectForKey:app.icon];
        }];
        
        //操作加入缓存
        [self.operationCache setObject:op forKey:app.icon];
        //操作加入队列
        [self.opQueue addOperation:op];
    }

}
@end
