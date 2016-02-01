/*############################################################################*\
 *  Financial Management                                                      * 
 *  Time Limit: 1000MS        Memory Limit: 10000K                            * 
 *                                                                            * 
 *  ========================== DESCRIPTION ================================== * 
 *  Larry graduated this year and finally has a job. He's making a lot        * 
 *  of money, but somehow never seems to have enough. Larry has decided       * 
 *  that he needs to grab hold of his financial portfolio and solve his       * 
 *  financing problems. The first step is to figure out what's been           * 
 *  going on with his money. Larry has his bank account statements and        * 
 *  wants to see how much money he has. Help Larry by writing a program       * 
 *  to take his closing balance from each of the past twelve months and       * 
 *  calculate his average account balance.                                    * 
 *                                                                            * 
 *  ============================= INPUT ===================================== * 
 *  The input will be twelve lines. Each line will contain the closing        * 
 *  balance of his bank account for a particular month. Each number will      * 
 *  be positive and displayed to the penny. No dollar sign will be            * 
 *  included.                                                                 * 
 *                                                                            * 
 *  ============================= OUTPUT ==================================== * 
 *  The output will be a single number, the average (mean) of the             * 
 *  closing balances for the twelve months. It will be rounded to the         * 
 *  nearest penny, preceded immediately by a dollar sign, and followed        * 
 *  by the end-of-line. There will be no other spaces or characters in        * 
 *  the output.                                                               * 
 *                                                                            * 
 *  SAMPLE INPUT                                                              * 
 *                                                                            * 
 *  100.00                                                                    * 
 *  489.12                                                                    * 
 *  12454.12                                                                  * 
 *  1234.10                                                                   * 
 *  823.05                                                                    * 
 *  109.20                                                                    * 
 *  5.27                                                                      * 
 *  1542.25                                                                   * 
 *  839.18                                                                    * 
 *  83.99                                                                     * 
 *  1295.01                                                                   * 
 *  1.75                                                                      * 
 *                                                                            * 
 *  SAMPLE OUTPUT                                                             * 
 *                                                                            * 
 *  $1581.42                                                                  * 
\*############################################################################*/

#include <iostream>
#include <vector>
#include <algorithm>
#include <string>
#include <sstream>

using namespace std;

class Solver {
public:
    void run() {
        int average, dollars, cents, total = 0;
        for (int k = 0; k < 12; ++k) {
            scanf("%d.%d", &dollars, &cents);
            total += 100 * dollars + cents;
        }
        average = (int)(total / 12.0f + 0.5f);
        printf("$%0d.%00d\n", average / 100, average % 100);
    }
};
