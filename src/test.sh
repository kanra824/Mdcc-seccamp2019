echo "#include <stdint.h>\n int64_t data[4]; void alloc4(int64_t **p, int64_t a, int64_t b, int64_t c, int64_t d) {*p = &data[0]; **p = a; *(*p + 1) = b; *(*p + 2) = c; *(*p + 3) = d;}" | gcc -xc -c -o tmp2.o -

try() {
    expected="$1"
    input="$2"

    ./mdcc "$input" > tmp.s
    gcc -o tmp tmp.s tmp2.o
    ./tmp
    actual="$?"

    if [ "$actual" = "$expected" ]; then
        echo "$input => $actual"
    else
        echo "$input => $actual"
        echo "$expected expected, but got $actual"
        exit 1
    fi
}

err() {
    input="$1"
    ./mdcc "$input" > tmp.s
    actual="$?"
    if [ "$actual" = "1" ]; then
        echo "$input => <error>"
    else
        gcc -o tmp tmp.s tmp2.o
        ./tmp
        actual = "$?"
        echo "$input => $actual"
        echo "<error> expected, but got $actual"
        exit 1
    fi
}


# try arith
try 0 "int main() {return 0;}"
try 42 "int main() {return 42;}"
try 21 "int main() {return 5+20-4;}"
try 41 "int main() {return 12 + 34 - 5;}"
try 49 "int main() {return 1 + 2 * 24;}"
try 47 "int main() {return 5+6*7;}"
try 15 "int main() {return 5*(9-6);}"
try 4 "int main() {return (3+5)/2;}"
try 2 "int main() {return 1 + -2 + 3;}"
try 1 "int main() {return 7 + 3 * -2;}"

# err arith
err "0"
err "int main() {return +;}";
err "int main() {return *+;}";
err "int main() {return 0+;}"
err "int main() {return 0++;}"
err "int main() {return 0 += 1;}"
err "int main() {return 0 -= 1;}"
err "int main() {return 0 *= 1;}"
err "int main() {return 0 /= 1;}"
err "int main() {return i = 5 % 2;}"
# err "foo;"

# try compare
try 1 "int main() {return 0 == 0;}"
try 0 "int main() {return 0 == 1;}"
try 1 "int main() {return 0 != 1;}"
try 0 "int main() {return 0 != 0;}"
try 1 "int main() {return 0 < 1;}"
try 0 "int main() {return 0 < 0;}"
try 1 "int main() {return 1 <= 1;}"
try 0 "int main() {return 1 <= 0;}"
try 1 "int main() {return 1 > 0;}"
try 0 "int main() {return 0 > 0;}"
try 1 "int main() {return 1 >= 1;}"
try 0 "int main() {return 0 >= 1;}"

# try 
try 2 "int main() {int a; a = 1; return a + 1;}"
try 7 "int main() {int a; a = 1; int b; b = 2 * 3 + 1; return a * b;}"
try 2 "int main() {int foo; foo = 1; return foo + 1;}"
try 7 "int main() {int foo; foo = 1; int bar; bar = 2 * 3 + 1; return foo * bar;}"

try 1 "int main() {if(1 == 1) return 1; else return 0;}"
try 0 "int main() {if(0 == 1) return 1; else return 0;}"

try 5 "int main() {int i; i = 1; while(i < 5) i = i + 1; return i;}"

try 10 "int main() {int sum; sum = 0; int i; for(i = 0; i < 5; i = i + 1) sum = sum + i; return sum;}"

try 0 "int main() {if(1 == 0) {int i; i = 1;return i + 2;} else {int sum; sum = 0; int i;for(i = 1; i <= 0; i = i + 1) {sum = sum + i;}return sum;}}"

try 3 "int add(int x, int y) {return x + y;} int main() {return add(1, 2);}"
try 3 "int add(int x, int y) {return x + y;} int main() {int a; a = 1; int b; b = 2; int c; c = 3; return add(a, 2);}"

try 1 "int main() {int x; x = 1; int y; y = &x; return *y;}"

try 3 "int main() {int x; int *y; y = &x; x = 3; return *y;}"
try 3 "int main() {int x; int *y; y = &x; *y = 3; return x;}"

try 8 "int main() {int *p; alloc4(&p, 1, 2, 4, 8); int *q; q = p + 3; return *q;}"

echo OK