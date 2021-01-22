
#include "include/TrieTree.h"

/* 构造函数:初始化对象
 * 参数:无
 * 返回值:无
 */
TrieTree::TrieTree() {
	Root = new TreeNode();
	if (Root == NULL) {
		cout << "TrieTree申请失败!" << endl;
		return;
	}  

	// 根节点为黑色节点
	Root->color = Black;
	for (int i = 0; i < R; i++)
		Root->Next[i] = NULL;
}

/* 析构函数:对象消亡时回收储存空间
 * 参数:无
 * 返回值:无
 */
TrieTree::~TrieTree() {
	MakeEmpty(Root); // 调用重置函数，从树根开始置空
}

/* 重置函数:重置TrieTree
 * 参数:无
 * 返回值:无
 */
void TrieTree::MakeEmpty() {
	// 将根节点的下一层节点置空
	for (char c = 0; c < R; c++)
		if (Root->Next[c] != NULL)
			MakeEmpty(Root->Next[c]);
}

/* 重置函数:重置指定节点
 * 参数:tree:想要进行重置额节点
 * 返回值:无
 */
void TrieTree::MakeEmpty(Position tree) {
	// 置空下一层节点
	for (char c = 0; c < R; c++)
		if (tree->Next[c] != NULL)
			MakeEmpty(tree->Next[c]);

	// 删除当前节点
	delete tree;
	tree = NULL;
}

/* 获取函数:获单词树中的所有单词，并返回储存的向量
 * 参数:无
 * 返回值:vector<string>:储存单词树中所有单词的向量
 */
vector <string> TrieTree::keys() {
	// 返回所有以""为前缀的单词，即所有单词
	return KeysWithPrefix("");
}

/* 插入函数:向TrieTree中插入指定的单词
 * 参数:key:想要进行插入的字符串
 * 返回值:无
 */
void TrieTree::Insert(string key) {
	// 从根节点开始递归插入
	Insert(key, Root, 0);
}

/* 插入驱动函数:将指定的单词进行递归插入
 * 参数:key:想要进行插入的单词，tree:当前递归节点，d:当前检索的字符索引
 * 返回值:无
 */
void TrieTree::Insert(string key, Position &tree, int d) {
	// 若没有节点则生成新节点
	if (tree == NULL) {
		tree = new TreeNode();
		if (tree == NULL) {
			cout << "新节点申请失败!" << endl;
			return;
		}

		tree->color = Black;
		for (int i = 0; i < R; i++)
			tree->Next[i] = NULL;
	}

	// 若检索到最后一位，则改变节点颜色
	if (d == key.length()) {
		tree->color = Red;
		return;
	}

	// 检索下一层节点
	char c = key[d];
	Insert(key, tree->Next[c], d + 1);
}

/* 删除函数:删除TrieTree中的指定单词
 * 参数:key:想要删除的指定元素
 * 返回值:无
 */
void TrieTree::Delete(string key) {
	// 从根节点开始递归删除
	Delete(key, Root, 0);
}

/* 删除驱动函数:将指定单词进行递归删除
 * 参数:key:想要进行删除的单词，tree:当前树节点，d:当前的索引下标
 * 返回值:无
 */
void TrieTree::Delete(string key, Position &tree, int d) {
	// 若未空树则返回
	if (tree == NULL)
		return;

	// 检索到指定单词，将其颜色变黑
	if (d == key.length())
		tree->color = Black;

	// 检索下一层节点
	else {
		char c = key[d];
		Delete(key, tree->Next[c], d + 1);
	}

	// 红节点直接返回
	if (tree->color == Red)
		return;
	
	// 若未黑节点，且无下层节点则删除该节点
	for (int i = 0; i < R; i++)
		if (tree->Next[i] != NULL)
			return;

	delete tree;
	tree = NULL;
}

/* 空函数:判断TrieTree是否为空
 * 参数:无
 * 返回值:bool:空树返回true，非空返回false
 */
bool TrieTree::IsEmpty() {
	for (int i = 0; i < R; i++)
		if (Root->Next[i] != NULL)
			return false;
	return true;
}

/* 查找函数:在TrieTree中查找对应的单词，并返回查找结果
 * 参数:key:想要查找的单词
 * 返回值:bool:TrieTree中有key返回true，否则返回false
 */
bool TrieTree::Find(string key) const {
	// 查找key最后字符所在节点
	Position P = Find(key, Root, 0);

	// 无节点则返回false
	if (P == NULL)
		return false;

	// 根据节点颜色返回
	if (P->color == Red)
		return true;
	else
		return false;
}

/* 查找驱动函数:在TrieTree中查找指定的单词并返回其最后的字符所在节点
 * 参数:key:想要进行查找的单词，tree:当前递归查找的树节点，d:当前检索的索引
 * 返回值:Position:单词最后字符所在的节点
 */
Position TrieTree::Find(string key, Position tree, int d) const {
	// 节点不存在则返回空
	if (tree == NULL)
		return NULL;

	// 若检索完成，返回该节点
	if (d == key.length())
		return tree;

	// 检索下一层
	char c = key[d];
	return Find(key, tree->Next[c], d + 1);
}

/* 最长前缀驱动:获取最长前缀在指定字符串中的所有下标
 * 参数:key:用于查找的字符串，tree:当前的递归节点，d:当前检索的索引，length:当前最长前缀的长度
 * 返回值:int:最长前缀的长度
 */
int TrieTree::Search(string key, Position tree, int d, int length) const {
	// 空树则返回当前前缀的长度
	if (tree == NULL)
		return length;

	// 更新前缀长度
	if (tree->color == Red)
		length = d;

	// 检索到末尾则返回长度
	if (d == key.length())
		return length;

	// 检索下一层
	char c = key[d];
	return Search(key, tree->Next[c], d + 1, length);
}

/* 最长前缀函数:获取指定字符串中，在TrieTree中存在的最长前缀
 * 参数:key:想要进行查找的字符串
 * 返回值:string:最长的前缀单词
 */
string TrieTree::LongestPrefixOf(string key) const {
	// 获取最长前缀的下标
	int Length = Search(key, Root, 0, 0);
	return key.substr(0, Length);
}

/* 前缀查找驱动:将当前层次所有符合前缀要求的单词存入向量
 * 参数:key:指定的前缀，tree:当前的节点层次，V:用于储存的向量
 * 返回值:无
 */
void TrieTree::Collect(string key, Position tree, vector <string> &V) const{
	// 空节点直接返回
	if (tree == NULL)
		return;

	// 红节点则压入单词
	if (tree->color == Red)
		V.push_back(key);

	// 检索下一层节点
	for (char i = 0; i < R; i++)
		Collect(key + i, tree->Next[i], V);
}

/* 前缀查找:查找TrieTree中所有以指定字符串为前缀的单词
 * 参数:key:指定的前缀
 * 返回值:vector<string>:储存了所有目标单词的向量
 */
vector <string> TrieTree::KeysWithPrefix(string key) const {
	vector <string> V;
	// 搜集目标单词到向量V
	Collect(key, Find(key, Root, 0), V);
	return V;
}

/* 单词匹配驱动:搜集当前层次中所有匹配成功的单词
 * 参数:pre:匹配前缀单词，pat:用于指定形式的字符串，tree:当前的检索层次，V:用于储存匹配成功单词的向量
 * 返回值:无
 */
void TrieTree::Collect(string pre, string pat, Position tree, vector <string> &V) const {
	// 获取前缀的长度
	int d = pre.length();
	
	// 空树直接返回
	if (tree == NULL)
		return;

	// 若前缀长度与指定单词相同且当前节点为红色，则压入前缀
	if (d == pat.length() && tree->color == Red)
		V.push_back(pre);

	// 若只是长度相同直接返回
	if (d == pat.length())
		return;

	// 检索下一层节点
	char next = pat[d];
	for (char c = 0; c < R; c++)
		if (next == '.' || next == c)
			Collect(pre + c, pat, tree->Next[c], V);
}

/* 单词匹配函数:搜集TrieTree中所以匹配指定字符串形式的单词
 * 参数:pat:用于指定形式的字符串
 * 返回值:vector<string>:储存所有目标单词的向量
 */
vector <string> TrieTree::KeysThatMatch(string pat) const {
	vector <string> V;
	// 搜集所有匹配的单词到向量V
	Collect("", pat, Root, V);
	return V;
}
