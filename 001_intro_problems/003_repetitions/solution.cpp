// include the standard library (feature of g++)
#include <bits/stdc++.h>

using namespace std;

int main() {
    // use fast io
    ios::sync_with_stdio(0);
    cin.tie(0);

    string str;
    cin >> str;

    long long n, longest;
    n = 1;
    longest = 0;

    char prev_ch = '\0';
    for (auto &ch : str) {
        if (ch == prev_ch) {
            n++;
        }
        else {
            if (n > longest) {
                longest = n;
            }
            n = 1;
        }
        prev_ch = ch;
    }

    if (longest < n) {
        longest = n;
    }

    cout << longest << "\n";
}