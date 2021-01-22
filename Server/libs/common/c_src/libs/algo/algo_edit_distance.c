#include<stdio.h>
#include <string.h>

#define min(x,y)  ( x<y?x:y )
int abs( int num );

int EditDistance(char* src, char* dest){
    if(strlen(src) == 0 || strlen(dest) == 0)
        return abs((int)strlen(src) - (int)strlen(dest));
    if(src[0] == dest[0])
        return EditDistance(src + 1, dest + 1);
    int edIns = EditDistance(src, dest + 1) + 1;
    int edDel = EditDistance(src + 1, dest) + 1;
    int edRep = EditDistance(src + 1, dest + 1) + 1;

    return min(min(edIns,edDel),edRep);
}

int main(){
    printf("%d\n", EditDistance("aaa", "aaa"));
}