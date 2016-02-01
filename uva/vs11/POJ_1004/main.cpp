
#define USE_FILE_TEST
#define SHOW_PASSED_LINES

#include "../../cpp/POJ_1004.h"

int main() {

#ifdef USE_FILE_TEST
    FILE *finput = freopen("../../test/POJ_1004_input.txt", "r", stdin);
    FILE *foutput = freopen("test.txt", "w", stdout);
#endif

    Solver solver;
    solver.run();

#ifdef USE_FILE_TEST
    freopen("CON", "r", stdin);
    freopen("CON", "w", stdout);

    bool success = false;
    int lineErr = 0;

    FILE *fileOutput = fopen("../../test/POJ_1004_output.txt", "r");

    if (fileOutput) {

        FILE *fileTest = fopen("test.txt", "r");

        if (fileTest) {

            char lineTest[1024];
            char lineOutput[1024];

            while (fgets(lineOutput, sizeof(lineOutput), fileOutput)) {
                if (fgets(lineTest, sizeof(lineTest), fileTest)) {
                    lineErr++;
                    if (strcmp(lineTest, lineOutput) != 0) {
                        cout << "FAIL in line: " << lineErr << endl;
                        cout << "  yours : " << lineTest;
                        cout << "  theirs: " << lineOutput;
                        break;
                    }
#ifdef SHOW_PASSED_LINES
                    else {
                        cout << "PASS: " << lineTest;
                    }
#endif
                }
                else { 
                    cout << "FAIL in line (trunk): " << lineErr << endl;
                    break;
                }
            }
            if (fgets(lineTest, sizeof(lineTest), fileTest)) {
                cout << "FAIL in line (more): " << lineErr << endl;
            }
            fclose(fileTest);
        }
        fclose(fileOutput);
    }
#endif
    system("PAUSE");
    return 0;
}
