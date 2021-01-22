#ifndef TRIETREE_H
#define TRIETREE_H

#include <iostream>
#include <string>
#include <vector>
using namespace std;

// 定义R为常量
const int R = 256;

// 重定义树节点，便于操作
typedef struct TreeNode *Position;

/* color枚举,储存元素:Red, Black*/
enum Color {Red, Black};

/* TrieTree节点
 * 储存元素:
 * coloe:节点颜色,红色代表有此单词，黑色代表没有
 * Next:下一层次节点
 */
struct TreeNode {
	Color color;
	Position Next[R];
};

/* TrieTree类(前缀树)
 * 接口:
 * MakeEmpty:重置功能，重置整颗前缀树
 * keys:获取功能，获取TrieTree中的所有单词，并储存在一个向量中
 * Insert:插入功能，向单词树中插入新的单词
 * Delete:删除功能，删除单词树的指定单词
 * IsEmpty:空函数，判断单词树是否为空
 * Find:查找函数，查找对应的单词，并返回查找情况:查找到返回true，否则返回false
 * LongestPrefixOf:查找指定字符串的最长前缀单词；
 * KeysWithPrefix:查找以指定字符串为前缀的单词；
 * KeysThatMatch:查找匹配对应字符串形式的单词，"."表示任意单词
 */
class TrieTree
{
public:
	// 构造函数
	TrieTree();
	// 析构函数
	~TrieTree();

	// 接口函数
	void MakeEmpty();
	vector <string> keys();
	void Insert(string);
	void Delete(string);

	bool IsEmpty();
	bool Find(string) const;
	string LongestPrefixOf(string) const;
	vector <string> KeysWithPrefix(string) const;
	vector <string> KeysThatMatch(string) const;

private:
	// 辅助功能函数
	void MakeEmpty(Position);
	void Insert(string, Position &, int);
	void Delete(string, Position &, int);

	Position Find(string, Position, int) const;
	int Search(string, Position, int, int) const;
	void Collect(string, Position, vector <string> &) const; // 对应KeysWithPrefix()
	void Collect(string, string, Position, vector <string> &) const; // 对应KeysThatMatch()

	// 数据成员
	Position Root; // 储存根节点
};

#endif