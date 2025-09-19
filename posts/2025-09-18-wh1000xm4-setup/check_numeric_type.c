#include <stdio.h>
#include <limits.h>
#include <float.h>

int main() {
    printf("%-20s %-6s %-22s %-22s\n", "Type", "Bytes", "Min", "Max");

    // 整数型
    printf("%-20s %-6zu %-22d %-22d\n", "int", sizeof(int), INT_MIN, INT_MAX);
    printf("%-20s %-6zu %-22d %-22d\n", "short", sizeof(short), SHRT_MIN, SHRT_MAX);
    printf("%-20s %-6zu %-22ld %-22ld\n", "long", sizeof(long), LONG_MIN, LONG_MAX);
    printf("%-20s %-6zu %-22u %-22u\n", "unsigned short", sizeof(unsigned short), 0U, USHRT_MAX);
    printf("%-20s %-6zu %-22lu %-22lu\n", "unsigned long", sizeof(unsigned long), 0UL, ULONG_MAX);
    printf("%-20s %-6zu %-22lld %-22lld\n", "long long", sizeof(long long), LLONG_MIN, LLONG_MAX);
    printf("%-20s %-6zu %-22llu %-22llu\n", "unsigned long long", sizeof(unsigned long long), 0ULL, ULLONG_MAX);

    // 浮動小数点型
    printf("%-20s %-6zu %-22e %-22e\n", "float", sizeof(float), -FLT_MAX, FLT_MAX);
    printf("%-20s %-6zu %-22e %-22e\n", "double", sizeof(double), -DBL_MAX, DBL_MAX);
    printf("%-20s %-6zu %-22Le %-22Le\n", "long double", sizeof(long double), -LDBL_MAX, LDBL_MAX);

    return 0;
}
