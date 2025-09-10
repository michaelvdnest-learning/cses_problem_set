// include the standard library (feature of g++)
#include <bits/stdc++.h>

using namespace std;

int main() {
    // use fast io
    ios::sync_with_stdio(0);
    cin.tie(0);

    long long n;
    cin >> n;

    long long expected_sum = (n * (n + 1)) / 2;

    // Subtract all given numbers from the expected sum
    for (int i = 0; i < n - 1; i++) {
        long long num;
        cin >> num;
        expected_sum -= num;
    }

    cout << expected_sum << "\n";

    return 0;
}