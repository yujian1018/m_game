#include "erl_nif.h"
#include "cppjieba/Jieba.hpp"

using namespace std;


const char* const DICT_PATH = "../../DB/dict/jieba.dict.utf8";
const char* const HMM_PATH = "../../DB/dict/hmm_model.utf8";
const char* const USER_DICT_PATH = "../../DB/dict/user.dict.utf8";
const char* const IDF_PATH = "../../DB/dict/idf.utf8";
const char* const STOP_WORD_PATH = "../../DB/dict/stop_words.utf8";


cppjieba::Jieba app(
    DICT_PATH,
    HMM_PATH,
    USER_DICT_PATH,
    IDF_PATH,
    STOP_WORD_PATH);


extern "C"{
static ERL_NIF_TERM cut(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary bin;
    enif_inspect_binary(env, argv[0], &bin);

    int type;
    enif_get_int(env, argv[1], &type);
    char *s = new char[bin.size + 1];
    memcpy(s, bin.data, bin.size);
    s[bin.size] = '\0';

    std::vector<std::string> words;

    if(type == 1){app.CutSmall(s, words, 512);}
    if(type == 2){app.CutHMM(s, words);}
    if(type == 3){app.Cut(s, words, false);}
    if(type == 4){app.CutAll(s, words);}
    if(type == 5){app.CutForSearch(s, words);}

    ERL_NIF_TERM r = enif_make_list(env, 0);
    ErlNifBinary h;
    size_t len;

    for(std::vector<std::string>::iterator i = words.begin(); i != words.end(); ++i) {
        len = strlen(i->c_str());
        enif_alloc_binary(len, &h);
        memcpy(h.data, i->c_str(), len);
        r = enif_make_list_cell(env, enif_make_binary(env, &h), r);
    }

    ERL_NIF_TERM result;
    enif_make_reverse_list(env, r, &result);

    delete [] s;

    return result;
}

static ERL_NIF_TERM target(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary bin;
    enif_inspect_binary(env, argv[0], &bin);

    char *s = new char[bin.size + 1];
    memcpy(s, bin.data, bin.size);
    s[bin.size] = '\0';

    vector<pair<string, string> > tagres;

    app.Tag(s, tagres);

    ERL_NIF_TERM r = enif_make_list(env, 0);
    ErlNifBinary h;
    size_t len;

    string item;

    for(vector<pair<string, string> > ::iterator i = tagres.begin(); i != tagres.end(); ++i) {
        item = i->first+":"+i->second;
        len = item.length();
        enif_alloc_binary(len, &h);
        memcpy(h.data, item.c_str(), len);
        r = enif_make_list_cell(env, enif_make_binary(env, &h), r);
    }

    ERL_NIF_TERM result;
    enif_make_reverse_list(env, r, &result);

    delete [] s;

    return result;
}

static ERL_NIF_TERM keyword(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary bin;
    enif_inspect_binary(env, argv[0], &bin);

    char *s = new char[bin.size + 1];
    memcpy(s, bin.data, bin.size);
    s[bin.size] = '\0';

    vector<pair<string, double> > keywordres;

    app.extractor.Extract(s, keywordres, 6);

    ERL_NIF_TERM r = enif_make_list(env, 0);
    ErlNifBinary h;
    size_t len;

    string item;
    char str[100];

    for(vector<pair<string, double> >::iterator i = keywordres.begin(); i != keywordres.end(); ++i) {
        sprintf(str,"%.8lf",i->second);
        item = i->first+":"+str;
        len = item.length();
        enif_alloc_binary(len, &h);
        memcpy(h.data, item.c_str(), len);
        r = enif_make_list_cell(env, enif_make_binary(env, &h), r);
    }

    ERL_NIF_TERM result;
    enif_make_reverse_list(env, r, &result);

    delete [] s;

    return result;
}


static ERL_NIF_TERM add_word(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary word, tag;
    enif_inspect_binary(env, argv[0], &word);
    enif_inspect_binary(env, argv[1], &tag);

    char *s = new char[word.size + 1];
    char *tagStr = new char[tag.size + 1];

    memcpy(s, word.data, word.size);
    memcpy(tagStr, tag.data, tag.size);
    s[word.size] = '\0';
    tagStr[tag.size] = '\0';

    bool isSet = app.InsertUserWord(s, tagStr);
    delete [] s;
    delete [] tagStr;
    if(isSet){
        return  enif_make_atom(env, "true");
    }else{
        return  enif_make_atom(env, "false");
    }
}

static ErlNifFunc nif_funcs[] =
{
    {"cut", 2, cut},
    {"target", 1, target},
    {"keyword", 1, keyword},
    {"add_word", 2, add_word}
};
}
ERL_NIF_INIT(ejieba,nif_funcs,NULL,NULL,NULL,NULL)
