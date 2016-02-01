/*############################################################################*\
 *  Wedding Shopping                                                          * 
 *                                                                            * 
 *  One of our best friends is getting married and we all                     * 
 *  are nervous because he is the first of us who is doing                    * 
 *  something similar.  In fact, we have never assisted                       * 
 *  to a wedding, so we have no clothes or accessories,                       * 
 *  and to solve the problem we are going to a famous                         * 
 *  department store of our city to buy all we need: a                        * 
 *  shirt, a belt, some shoes, a tie, etcetera.                               * 
 *  We are offered different models for each class of                         * 
 *  garment (for example, three shirts, two belts, four                       * 
 *  shoes, ...). We have to buy one model of each class of                    * 
 *  garment, and just one.                                                    * 
 *  As our budget is limited, we cannot spend more                            * 
 *  money than it, but we want to spend the maximum possible.                 * 
 *  It's possible that we cannot buy one                                      * 
 *  model of each class of garment due to the short amount of money we have.  * 
 *  ============================= INPUT ===================================== * 
 *  The first line of the input contains an integer,                          * 
 *  N, indicating the number of test cases. For each test case,               * 
 *  some lines appear, the first one contains two integers, M and C,          * 
 *  separated by blanks (1 <= M <= 200, and 1 <= C <= 20),                    * 
 *  where M is the available amount of money and C                            * 
 *  is the number of garments you                                             * 
 *  have to buy. Following this line, there are C                             * 
 *  lines, each one with some integers separated by blanks; in                * 
 *  each of these lines the first integer, K (1 <= K <= 20),                  * 
 *  indicates the number of different models for each                         * 
 *  garment and it is followed by K                                           * 
 *  integers indicating the price of each model of that garment.              * 
 *                                                                            * 
 *  ============================= OUTPUT ==================================== * 
 *  For each test case, the output should consist of one integer              * 
 *  indicating the maximum amount of money                                    * 
 *  necessary to buy one element of each garment without exceeding the        * 
 *  initial amount of money. If there                                         * 
 *  is no solution, you must print 'no solution'.                             * 
 *                                                                            * 
 *  SAMPLE INPUT                                                              * 
 *  3                                                                         * 
 *  100 4                                                                     * 
 *  3 8 6 4                                                                   * 
 *  2 5 10                                                                    * 
 *  4 1 3 3 7                                                                 * 
 *  4 50 14 23 8                                                              * 
 *  20 3                                                                      * 
 *  3 4 6 8                                                                   * 
 *  2 5 10                                                                    * 
 *  4 1 3 5 5                                                                 * 
 *  5 3                                                                       * 
 *  3 6 4 8                                                                   * 
 *  2 10 6                                                                    * 
 *  4 7 3 1 7                                                                 * 
 *                                                                            * 
 *  SAMPLE OUTPUT                                                             * 
 *  75                                                                        * 
 *  19                                                                        * 
 *  no solution                                                               * 
\*############################################################################*/

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#define _CRT_SECURE_NO_DEPRECATE
#define _CRT_SECURE_NO_WARNINGS

using namespace std;

//#define TOP_DOWN

class Solver
{
    int M, C, price[25][25];
#ifdef TOP_DOWN
    int memo[210][25];
    int shop( int money, int g )
    {
        if ( money < 0 ) return -1000000000;
        if ( g == C ) return M - money;
        if ( memo[money][g] != -1 ) return memo[money][g];
        int ans = -1;
        for ( int model = 1; model <= price[g][0]; model++ )
            ans = std::max( ans, shop( money - price[g][model], g + 1 ) );
        return memo[money][g] = ans;
    }
#endif
public:
    void run()
    {
        int i, j, TC, money;
#ifndef TOP_DOWN
        bool reachable[25][210];
#endif
        scanf( "%d", &TC );

        while ( TC-- )
        {
            scanf( "%d %d", &M, &C );
            for ( i = 0; i < C; i++ )
            {
                scanf( "%d", &price[i][0] );
                for ( j = 1; j <= price[i][0]; j++ )
                    scanf( "%d", &price[i][j] );
            }
#ifdef TOP_DOWN
            memset( memo, -1, sizeof memo );
            money = shop( M, 0 );
            ( money < 0 ) ? printf( "no solution\n" ) : printf( "%d\n", money );
#else
            memset( reachable, false, sizeof reachable );
            for ( i = 1; i < price[0][0]; i++ )
                if ( M - price[0][i] >= 0 )
                    reachable[0][M - price[0][i]] = true;

            for ( i = 1; i < C; i++ )
                for ( money = 0; money < M; money++ )
                    if ( reachable[i - 1][money] )
                        for ( j = 1; j <= price[i][0]; j++ )
                            if ( money - price[i][j] >= 0 )
                                reachable[i][money - price[i][j]] = true;

            for ( money = 0; money <= M && !reachable[C - 1][money]; money++ );

            ( money == M + 1 ) ? printf( "no solution\n" ) : printf( "%d\n" , M - money );
                 
#endif
        }
    }
};
