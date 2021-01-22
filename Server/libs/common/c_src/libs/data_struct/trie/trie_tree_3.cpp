#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace std;

//字典树节点
class trieNode
{
  public:
    trieNode() : count(0){};
    //以当前节点结尾的字符串的个数
    int count;
    map<char16_t, trieNode *> child;
};
//字典树
class Trie
{
  public:
    Trie() { root = new trieNode(); };
    void insert_string(const u16string &str);
    vector<u16string> get_str_pre(const u16string &str);

  private:
    //辅助函数
    void add_str(trieNode *preNode, u16string str, vector<u16string> &ret);
    trieNode *search_str_pre(const u16string &str);

    trieNode *root;
};
//插入字符串，构建字典树
void Trie::insert_string(const u16string &str)
{
    if (!root || str.empty())
        return;

    trieNode *currentNode = root;

    for (auto &chr : str)
    {
        auto Iter = currentNode->child.find(chr);
        if (Iter == currentNode->child.end())
        {
            //如果当前字符不在字典树中，新建一个节点插入
            trieNode *newNode = new trieNode();
            currentNode->child.insert(make_pair(chr, newNode));
            currentNode = newNode;
        }
        else
        {
            //如果当前字符在字典书中，则将当前节点指向它的孩子
            currentNode = Iter->second;
        }
    }
    currentNode->count++;
}
//查找以str为前缀的节点
trieNode *Trie::search_str_pre(const u16string &str)
{
    if (!root || str.empty())
        return nullptr;

    trieNode *currentNode = root;
    for (auto &chr : str)
    {
        auto Iter = currentNode->child.find(chr);
        if (Iter != currentNode->child.end())
        {
            currentNode = Iter->second;
        }
        else
            return nullptr;
    }

    return currentNode;
}
//查找以str为前缀的所有字符串，保存在vector中返回
vector<u16string> Trie::get_str_pre(const u16string &str)
{
    vector<u16string> ret;
    trieNode *pre = search_str_pre(str);
    if (pre)
    {
        add_str(pre, str, ret);
    }
    return ret;
}
//将preNode的所有子节点中字符串加入str前缀，然后插入到vector中
void Trie::add_str(trieNode *preNode, u16string str, vector<u16string> &ret)
{
    for (auto Iter = preNode->child.begin(); Iter != preNode->child.end(); ++Iter)
    {
        add_str(Iter->second, str + Iter->first, ret);
    }
    if (preNode->count != 0)
        ret.push_back(str);
}

int main()
{
    //为了终端能打印出中文
    setlocale(LC_ALL, "");
    //测试字符串用于构建字典树，utf-16编码，能同时保存中英文
    vector<u16string> hotworlds = {u"杨文婷", u"联系", u"杨洋洋", u"杨sir大警官", u"杨y文w婷t", u"杨文婷是小学生",
                                   u"杨钰莹", u"杨文婷ywt是小学生", u"联系a群众", u"阳光么", u"阳光明媚", u"ywt是小学生", u"联系ywt", u"杨文t爱吃面", u"杨文婷妹妹",
                                   u"杨光明眉", u"小学生", u"杨文婷爱吃面", u"我是小学生", u"我是中国人", u"ywt要吃面", u"y杨文婷", u"有问题"};
    Trie trie;
    for (auto &maString : hotworlds)
    {
        trie.insert_string(maString);
    }

    //输入“杨文婷”，返回所有以“杨文婷”为前缀的词
    vector<u16string> res = trie.get_str_pre(u"ywt要");

    //打印结果
    for (auto &resString : res)
    {
        for (auto &chr : resString)
        {
            printf("%lc", chr);
        }
        printf("\n");
    }

    return 0;
}
