//
//  ViewController.m
//  DBDataChangeToFile
//
//  Created by roc on 16/12/15.
//  Copyright © 2016年 roc. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "CityModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UITextField *entityName;
@property (weak, nonatomic) IBOutlet UITextField *numTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *aliasTF;
@property (weak, nonatomic) IBOutlet UITextField *submitTF;

- (IBAction)addToDB:(UIButton *)sender;
- (IBAction)delFromDB:(UIButton *)sender;
- (IBAction)DBChangeToFile:(UIButton *)sender;
- (IBAction)ReadFromFile:(UIButton *)sender;

@end

@implementation ViewController {
    AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)addToDB:(UIButton *)sender {
    NSError *error;
    //判断数据的有效性
    if (_entityName.text == nil || _numTF.text == nil
            || _nameTF.text == nil || _aliasTF.text == nil
                 || _submitTF.text == nil) {
        [self showAlert:@"数据不能为空"];
        return;
    }
//    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:_nameTF.text ofType:@"png"]];
//    if (image == nil) {
//        [self showAlert:@"数据不存在"];
//        return;
//    }
    
    _iconView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:_nameTF.text ofType:@"png"]];
    
//    //获取core data 上下文
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
//    //构造一个查询请求(保证数据的唯一性)
    NSFetchRequest  *request=[NSFetchRequest fetchRequestWithEntityName:_entityName.text];
    request.predicate=[NSPredicate predicateWithFormat:@"alias=%@",_aliasTF.text];
//
//    //执行行查询请求
    NSArray *objs=[context executeFetchRequest:request error:&error];
    if(error){
        [self showAlert:[NSString stringWithFormat:@"query error:%@",error.localizedDescription]];
        return;
    }
    if (objs.count) {
        [self showAlert:@"该用户已存在"];
        return;
    }
//    //创建、获取实体<表>
    NSEntityDescription  *entity=[NSEntityDescription entityForName:_entityName.text inManagedObjectContext:context];
//    //构造托管对象<core data数据直接存储NSManagedObject对象 面像对象的数据库>
    NSManagedObject  *obj=[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    //将自已的数据加入NSManagedObject 注意:key必须为实体的字段名

    [obj setValue:_nameTF.text forKey:@"name"];
    [obj setValue:_aliasTF.text forKey:@"alias"];
//    [obj setValue:[NSNumber numberWithInteger:[_numTF.text integerValue]] forKey:@"num"];
//    [obj setValue:UIImagePNGRepresentation(_iconView.image) forKey:@"icon"];
//
//    //保存NSManagedObject到数据库本地文件
    [appDelegate saveContext];
}

- (IBAction)delFromDB:(UIButton *)sender {
    NSError *error;
    //    //获取core data 上下文
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    //    //构造一个查询请求(保证数据的唯一性)
    NSFetchRequest  *request=[NSFetchRequest fetchRequestWithEntityName:_entityName.text];
    request.predicate=[NSPredicate predicateWithFormat:@"alias=%@",_aliasTF.text];
    //
    //    //执行行查询请求
    NSArray *objs=[context executeFetchRequest:request error:&error];
    if(error){
        [self showAlert:[NSString stringWithFormat:@"query error:%@",error.localizedDescription]];
        return;
    }
    if (objs.count == 0) {
        [self showAlert:@"数据不存在"];
        return;
    }
    [context deleteObject:[objs objectAtIndex:0]];
 
    [appDelegate saveContext];
}

- (IBAction)DBChangeToFile:(UIButton *)sender {
    NSError *error;
    NSMutableArray *dataArray = [self getDataFromDBWith:_entityName.text];
    //创建一个空的可变缓存对象;
    NSMutableData *dataarea = [NSMutableData data];
    //创建归档对象, 并指定缓存为dataarea;
    NSKeyedArchiver *arch = [[NSKeyedArchiver alloc]initForWritingWithMutableData:dataarea];
    //往缓存dataarea中编码;
    [arch encodeObject:dataArray forKey:@"CityInfo"];
    [arch finishEncoding];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString * path = [[NSMutableString alloc]initWithString:documentsDirectory];
    [path appendString:@"/city.plist"];
    [dataarea writeToFile:path options:NSDataWritingFileProtectionComplete error:&error];
    if (error) {
        [self showAlert:[NSString stringWithFormat:@"%@",error.localizedDescription]];
        return;
    }
    // 去该文件地址下去找到生成的文件
    NSLog(@"%@",documentsDirectory);
}

- (IBAction)ReadFromFile:(UIButton *)sender {
    NSData *dataArea = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"city" ofType:@"plist"]];
    if (dataArea == nil) {
        NSLog(@"文件不存在");
    }
    
    NSKeyedUnarchiver *unarch = [[NSKeyedUnarchiver alloc]initForReadingWithData:dataArea];
    
    NSArray *General = [unarch decodeObjectForKey:@"CityInfo"];
    
    [unarch finishDecoding];
    //跳转添加功能
    [self writeDataToDBWith:_entityName.text AndArray:General];
    
}

-(void) showAlert:(NSString *)msg{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:(UIAlertActionStyleDefault) handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSMutableArray *) getDataFromDBWith:(NSString *) DBName {
    NSMutableArray *array = [NSMutableArray array] ;
    NSError *error;
    //    //获取core data 上下文
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    //    //构造一个查询请求(查询全部)
    NSFetchRequest  *request=[NSFetchRequest fetchRequestWithEntityName:_entityName.text];
    //
    //    //执行行查询请求
    NSArray *objs=[context executeFetchRequest:request error:&error];
    if(error){
        [self showAlert:[NSString stringWithFormat:@"query error:%@",error.localizedDescription]];
        return nil;
    }
    CityModel *model;
    for (NSManagedObject *obj in objs) {
        model = [[CityModel alloc]init];
        [model setValue:[obj valueForKey:@"name"]  forKey:@"name"];
        [model setValue:[obj valueForKey:@"alias"] forKey:@"alias"];
        [array addObject:model];
    }
    return array;
}

-(void) writeDataToDBWith:(NSString *)DBName AndArray:(NSArray *)array{
    for (CityModel *model in array) {
        //获取core data 上下文<创建数据库databasefile 及表>
        NSManagedObjectContext *context=[appDelegate managedObjectContext];
        
        //创建、获取实体<表>
        NSEntityDescription  *entity=[NSEntityDescription entityForName:DBName inManagedObjectContext:context];
        //构造托管对象<core data数据直接存储NSManagedObject对象 面像对象的数据库>
        NSManagedObject  *obj=[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        //将自已的数据加入NSManagedObject 注意:key必须为实体的字段名
        [obj setValue:model.name forKey:@"name"];
        [obj setValue:model.alias forKey:@"alias"];
        
        //保存NSManagedObject到数据库本地文件
        
        [appDelegate saveContext];
        
    }
}


@end
