// include the standard library (feature of g++)
#include <bits/stdc++.h>

using namespace std;

int main() {
    // use fast io
    ios::sync_with_stdio(0);
    cin.tie(0);

    long long n;
    cin >> n;
    while (true) {
        cout << n << " ";
        if (n == 1) break;
        if (n%2 == 0)
            n /= 2;
        else
            n = n*3+1;
    }
    cout << "\n";
}