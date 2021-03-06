//
//  WSTableViewController.m
//  UISearchDisplayController
//
//  Created by sw on 16/3/20.
//  Copyright © 2016年 sw. All rights reserved.
//

#import "WSTableViewController.h"
#import "WSSearchController.h" // UISearchDisplayController在IOS8已经被废弃！取而代之的是UISearchController

#define SEARCH_RECORDS @"searchRecords"

@interface WSTableViewController ()<UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate>
/** 所有数据 */
@property(nonatomic,strong) NSMutableArray *dataArray;
/** 搜索结果集 */
@property(nonatomic,strong) NSMutableArray *searchResults;
/** 搜索记录 */
@property(nonatomic,strong) NSMutableArray *searchRecords;
/** 搜索控制器 */
@property(nonatomic,strong) WSSearchController *searchVC;
/** 清除搜索历史记录的按钮 */
@property(nonatomic,strong) UIButton *deleteSearchRecordsButton;
@end

@implementation WSTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 30;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    _searchVC = [[WSSearchController alloc] initWithSearchResultsController:nil]; // nil代表直接在当前控制器显示搜索结果
    _searchVC.searchResultsUpdater = self;
    _searchVC.searchBar.delegate = self;
    _searchVC.definesPresentationContext = YES;
    _searchVC.dimsBackgroundDuringPresentation = NO; // 如果为YES，那么会有蒙版改在搜索结果上面，导致搜索结果无法选中；如果为NO，那么就可以选中搜索结果，可以根据实际需求而设置，默认为YES
    _searchVC.hidesNavigationBarDuringPresentation = YES; // 当搜索时，是否隐藏导航条
    _searchVC.searchBar.placeholder = @"支持网站账号搜索，客户名称，手机号等关键词搜索";
    self.tableView.tableHeaderView = self.searchVC.searchBar;
    self.tableView.sectionFooterHeight = 0; // 默认是10，如果想让“清除搜索历史”和tableview紧挨着，那么需要把这个属性设置为0.
    self.tableView.sectionHeaderHeight = 0; // 默认是10
    
//    self.tableView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0);
    // 加载偏好设置中的搜索记录
    [self loadSearchRecords];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchVC.active && _searchVC.searchBar.text.length == 0) {
        return self.searchRecords.count;
    } else if (_searchVC.active && _searchVC.searchBar.text.length){
        return self.searchResults.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    if (_searchVC.active && self.searchVC.searchBar.text.length == 0) {
        if (self.searchRecords.count == 0) {
            return cell;
        }
        cell.textLabel.text = self.searchRecords[indexPath.row];
        return cell;
    }
    if (_searchVC.active && self.searchVC.searchBar.text.length) {
        cell.textLabel.text = self.searchResults[indexPath.row];
        return cell;
    }
    
//    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_searchVC.active && self.searchRecords.count && _searchVC.searchBar.text.length == 0) {
        return @"搜索历史";
    } else if (_searchVC.active && _searchVC.searchBar.text.length) {
        return nil;
    }
    return nil;
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 80, 40)];
//    [label sizeToFit];
//    label.text = @"搜索历史";
//    label.backgroundColor = [UIColor redColor];
//    return label;
//}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    //定义过滤条件
    //beginWith endWith like constains
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains %@", searchController.searchBar.text];
    if (self.searchResults) {
        
    }
    //开始过滤
    NSMutableArray *searchResults = [NSMutableArray arrayWithArray:[_searchRecords filteredArrayUsingPredicate:predicate]];
//    NSMutableArray *searchResults = [_dataArray filteredArrayUsingPredicate:predicate];
    
    if (self.searchResults) {
        [self.searchResults removeAllObjects];
    }
    //将过滤的内容显示
    self.searchResults = searchResults;
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate
// 点击键盘上的search按钮调用
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    NSLog(@"点击了search按钮");
    // 在这里拿到搜索框的关键字
    NSString *searchBarText = searchBar.text;
    // 把关键字存储到偏好设置中
    // 判断关键字是否已经存在
    for (NSString *searchRecord in self.searchRecords) {
        if ([searchBarText isEqualToString:searchRecord]) {
            return;
        }
    }
    // 不存在则存储到偏好设置
    [self.searchRecords addObject:searchBarText];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.searchRecords forKey:SEARCH_RECORDS];
    NSLog(@"%@,%@",self.searchRecords,[self.searchRecords class]);

}

// 点击了searchBar上的cancel按钮调用
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // 点击取消的时候，重写设置tableFooterView
    self.tableView.tableFooterView = [UIView new];
    NSLog(@"点击了取消按钮");
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"rESULTSlISTbUTTONcLICKED");
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"开始编辑了");
    // 也就是UISearchBar聚焦的时候会调用该方法
    // UISearchBar中文本改变的时候不会调用该方法
    // 如果有搜索历史才显示"清除搜索历史"
    if (self.searchRecords.count && self.searchVC.searchBar.text.length == 0) {
        self.tableView.tableFooterView = self.deleteSearchRecordsButton;
        self.deleteSearchRecordsButton.hidden = NO; // 如果清除过搜索历史，那么按钮被隐藏了，重新添加按钮的时候需要把按钮显示出来
    } else if (self.searchRecords.count && self.searchVC.searchBar.text.length) {
        self.deleteSearchRecordsButton.hidden = YES; // 有这么一种情况：如果我在搜索框中输入了一个关键字然后点击了“search”，那么此时搜索框失去焦点，再次点击搜索框使其聚焦，又会调用这个方法。也就是说，此时虽然这个文本框中有内容，当再次使其聚焦时，依然回调这个方法，所以我们需要判断搜索框中的内容的长度，如果长度为0，需要显示“清除搜索历史按钮”，如果长度不为0，则隐藏“清除搜索历史按钮”。
    } else { // 没有历史纪录
        self.tableView.tableFooterView = [UIView new]; // 没有历史纪录不显示“清除搜索历史”按钮；点击“取消”，tableView仍然会有那个“清除搜索历史”按钮，所以需要在取消的回调方法中，做同样设置
        [self.tableView reloadData];
    }
    
    searchBar.showsCancelButton = YES;
    for (id subView in [searchBar.subviews[0] subviews]) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            UIButton *cancelButton = (UIButton *)subView;
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            NSLog(@"...");
        }
    }

//    for (id obj in [searchBar subviews]) {
//        if ([obj isKindOfClass:[UIView class]]) {
//            for (id obj2 in [obj subviews]) {
//                if ([obj2 isKindOfClass:[UIButton class]]) {
//                    UIButton *btn = (UIButton *)obj2;
//                    [btn setTitle:@"取消" forState:UIControlStateNormal];
//                }
//            }
//        }
//    }
//    for(id cc in [searchBar subviews])
//    {
//        if([cc isKindOfClass:[UIButton class]])
//        {
//            UIButton *btn = (UIButton *)cc;
//            [btn setTitle:@"取消" forState:UIControlStateNormal];
//
////            [btn setTitle:[AppLanguageProcess getLanguageWithKey:@"TEXT_CANCEL"]  forState:UIControlStateNormal];
//            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        }
//    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
//    NSString *title = [self tableView:self.tableView titleForHeaderInSection:1];
    // 搜索框正在输入并且搜索框内有内容的时候隐藏“清除搜索历史”按钮；否则显示“清除搜索历史”按钮
    if (searchBar.text.length) {
        self.deleteSearchRecordsButton.hidden = YES;
    } else {
        self.deleteSearchRecordsButton.hidden = NO;
    }
}

// 点击键盘上的search按钮不会调用下面的方法
//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
//{
//    return YES;
//}

#pragma mark - private methord
// 加载偏好设置中的搜索记录
- (void)loadSearchRecords
{
    // 清除原来缓存的搜索记录
//    if (self.searchRecords.count) {
//        [self.searchRecords removeAllObjects];
//    }
    
    // 缓存最新的搜索记录
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *searchRecords = (NSMutableArray *)[defaults objectForKey:SEARCH_RECORDS];
    [self.searchRecords addObjectsFromArray:searchRecords];

    NSLog(@"%@,%@",self.searchRecords,[[defaults objectForKey:SEARCH_RECORDS] class]);
}

- (void)didClickDeleteSearchRecordsButton:(UIButton *)button
{
    NSLog(@"点击了清除搜索历史按钮");
    // 清除缓存的搜索记录
    [self.searchRecords removeAllObjects];
    // 更新偏好设置的搜索记录
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_searchRecords forKey:SEARCH_RECORDS];
    
    // 隐藏“清除搜索记录”按钮 和 “搜索历史”标题
    self.deleteSearchRecordsButton.hidden = YES;
    
    // 刷新表格
    [self.tableView reloadData];
    
}
#pragma mark - getter AND setter

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@"belive",
                                                        @"live",
                                                        @"love",
                                                        @"i love you",
                                                        @"like",
                                                        @"just",
                                                         nil
                      ];
    }
    
    return _dataArray;
}

- (NSMutableArray *)searchRecords
{
    if (!_searchRecords) {
        _searchRecords = [NSMutableArray array];
    }
    return _searchRecords;
}

- (UIButton *)deleteSearchRecordsButton
{
    if (!_deleteSearchRecordsButton) {
        // 创建一个按钮作为tableView尾部视图
        _deleteSearchRecordsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        [_deleteSearchRecordsButton setTitle:@"清除搜索历史" forState:UIControlStateNormal];
        [_deleteSearchRecordsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_deleteSearchRecordsButton setBackgroundColor:[UIColor clearColor]];
//        [_deleteSearchRecordsButton setTintColor:[UIColor blackColor]]; // 不能设置button 的 title颜色
        [_deleteSearchRecordsButton addTarget:self action:@selector(didClickDeleteSearchRecordsButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteSearchRecordsButton;
}
@end
