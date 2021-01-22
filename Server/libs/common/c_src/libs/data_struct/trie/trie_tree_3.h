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
