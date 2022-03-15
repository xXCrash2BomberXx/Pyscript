# Pyscript
A blend of all the major object-oriented languages put into python


a1.0 - Initial
	Python with Braces -> {}
	Increment and Decrement Operators
	Do-While-Loops
	Standard For-Loops
	Switch-Case testing
	Custom Sets built off of a blend of Dictionaries and Lists
	Inline comments with /*Comment*/ and <!--Comment--> notation
	else if == elif
	catch == except
	throw == raise
	typeof == type
	|| == or
	&& == and
	this == self

a1.1 - Terminal Build

a1.2 - List Indexing Fixes
	[1, 2, 3][::2] -> [1, 3]
	[1, 2, 3][1] -> 2
	WARNING: Empty lists cannot be created with [], use list()
	WARNING: [0] is not a list, this is an index. For a single-element list, be sure to use a comma as [0,]

a1.3 - Increment and Decrement Opperator Support for Non-Variables
	1++ -> 1
	++1 -> 2
	1-- -> 1
	--1 -> 0

a1.4 - Standard For-Loop Increment and Decrement Improvement
	x=0; for (;x++<5;) {print(x);} -> 1, 2, 3, 4, 5
	x=0; for (;++x<5;) {print(x);} -> 1, 2, 3, 4
	x=5; for (;x-->0;) {print(x);} -> 4, 3, 2, 1, 0
	x=5; for (;--x>0;) {print(x);} -> 4, 3, 2, 1

a1.5 - Enforced typing + Built-in Overwritability
	@annotate; def t(a: int, b:str = "abc", *args: bool, **kwargs: float){print(a, b, args, kwargs);} t(1, "1", True, c=3.0);

a1.6 - Execution time output, "Ctrl-Z plus Return to exit" support, and chaining tests in for loops
	for (x=0; -5<x<5; x++) {print(x);} 0, 1, 2, 3, 4

a1.7 - Copy function
	trial: bool = False
		try to clone sub-functions
		WARNING: will slow down code slower than copy.deepcopy
	quick: bool = False
		skip function surface copying
		WARNING: will speed up code faster than copy.deepcopy
	copy(func) is func -> False
	copy(func, trial=True) is func -> False
	copy(func, quick=True) is func -> True

a1.8 - Alpha Or-Typing and Switched to Python 3.10
	isinstance2([2, "2"], list[int|str,]) -> True
	isinstance2([2, "2", True], list[int|str,]) -> False

a1.85 - Beta Or-Trying w/ Deep Typing Support
	isinstance2({1: ["s", True], "s": [False,], "1": list()}, dict[int|str, list[str|bool]]) -> True

a1.9 - Added array class, fixed index assignment bug from 1.2, added tuple support to builtin typing2 methods, and fixed builtin type2 checking of empty containers
	array(1) -> [None] -> Each None slot can hold any typed object
	array(2)(int, 3) -> [[None, None, None], [None, None, None]] -> Each None slot can hold only an int typed object
	array(2)(3, int) -> [[None, None, None], [None, None, None]] -> Same as above; order doesn't matter
	array(int, 1)(2) -> [[None, None]] -> First type gets removed since there is a second depth making it work similar to first example
	[0, 1, 2][0] = 3 -> None -> [3, 1, 2]
	type2(list()) -> list[duck]
	type2(dict()) -> dict[duck]
	type2(set()) -> set[duck]
	type2(tuple()) -> tuple[duck]

a2.0 - Added optimized printing (with keyword output), rawinput for multiline support with no leading text, optimized builtin typing2 methods, fixed bugs with duck typing
	print(0,"a", b=1) -> 0 a 'b': 1
	rawinput(lines=3, sep="\n") -> 3 lines of input separated by the sep variable
	typing2({0:{1:{2:2}}}) -> dict[int, dict[int, dict[int, int]]]
	isinstance2(array(2), array) -> True
	isinstance2(list(), duck) -> True

a2.1 - Added until loop, added flatten function for list based objects, added ismutable and isimmutable functions, and fixed switch-case-default for python 3.10
	x=0; until x>5 {print(x++);} -> 0, 1, 2, 3, 4, 5
	flatten([0,[1,[2,[3,]]]] -> [0, 1, 2, 3]
	ismutable([0,]) -> True
	isimmutable(0) -> True

a2.2 - Added custom class copying

a2.25 - Added System.out.println to printing functions and System.in.read to input functions from Java and fixed empty line errors

KNOWN BUGS:
	Strings with the custom features
