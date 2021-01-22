#include <codecvt>
#include <iostream>
#include <locale>
#include <string>

std::u16string to_utf16(std::string str) // utf-8 to utf16
{
    return std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t>{}.from_bytes(str);
}

std::string to_utf8(std::u16string str16)
{
    return std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t>{}.to_bytes(str16);
}

std::u32string to_utf32(std::string str)
{
    return std::wstring_convert<std::codecvt_utf8<char32_t>, char32_t>{}.from_bytes(str);
}

std::string to_utf8(std::u32string str32)
{
    return std::wstring_convert<std::codecvt_utf8<char32_t>, char32_t>{}.to_bytes(str32);
}

std::wstring to_wchar_t(std::string str)
{
    return std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t>{}.from_bytes(str);
}

std::string to_utf8(std::wstring wstr)
{
    return std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t>{}.to_bytes(wstr);
}