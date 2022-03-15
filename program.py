for (i=6; i>4; i-=1) {log(list(range(10))[i:]);} print();

x = prompt("Input: ");
try {x = eval(x);} catch NameError {}
if type(x) == int {print(x);} else if typeof(x) == float {print("float");}
elif typeof(x) == str {if x == "hello" {print("world");} else {print(x);}} else {print(true);}

inc = 0; log(inc--);print(inc);

dict = {0: [0, 1, 2, 3].append(4), 1: {0:1, 2:3}};
print(dict);

for (i=6; i>4; i-=1) {log(i);} print();

y = int(input("Switch-Y: "));
z = int(input("Switch-Z: "));
print();
switch (y, z) {case (1, 1) {print(1);} case (1, 2) {print(1,2);} default {print(None);}}

print("\n+inc");
inc=0; while ++inc < 5 {log(inc);} print();
print("\ninc+");
inc=0; while inc++ < 5 {log(inc);} print();
print("\n-inc");
inc=5; while --inc > 0 {log(inc);} print();
print("\ninc-");
inc=5; while inc-- > 0 {log(inc);} print();
print();

print((2==1 || 3==3) && 2==2);print();

log(x:=0); --x; print(x);

i=5; do {if True {log(i);} i++;} while i < 1;

print(/*comment*/"comment"<!--comment-->);

def start(){print(True);}
start();

print(set(0, 1, 3, a=5));
