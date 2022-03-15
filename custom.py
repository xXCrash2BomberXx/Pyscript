function = type(lambda: 0)


class duck(type, metaclass=type("duck", (type,), {"__repr__": lambda self: self.__name__})):
    '''
    Custom type class for variable typing.
    '''
    pass


def input2(*args: str) -> duck:
    '''
    Parses input as typed by the predefined type annotations of a variable

    Parameters
    ----------
    string : str
        input print arguments.

    Raises
    ------
    ValueError
        invalid data to match type annotation.

    Returns
    -------
    duck
        data matching the type of type annotation.

    '''
    import __main__
    for key in __main__.__annotations__:
        if key not in dir(__main__):
            return __main__.__annotations__[key](input(*args))
    raise ValueError("annotations were not predefined")


def vars(func: type(lambda: 0), f: bool = True, r: bool = True) -> dict:
    '''
    Creates a dictionary of all arguments requested in a function with their names, types, and default values if given.

    Parameters
    ----------
    func : function
        function to find the argument names, types, and default values.
    f : bool, optional
        reorder the returned dictionary to match function argument ordering. The default is True.
    r : bool, optional
        include return typing in the returned dictionary.

    Returns
    -------
    dict
        dictionary of argument data from function.

    '''
    d = {i: {} for i in func.__code__.co_varnames}
    for i in func.__annotations__:
        try:
            if '[' in str(func.__annotations__[i]):
                d[i]["type"] = str(func.__annotations__[i])
            else:
                d[i]["type"] = func.__annotations__[i].__name__
        except KeyError:
            pass
    for i in d:
        if "type" not in d[i]:
            d[i]["type"] = duck.__name__
    try:
        for i in func.__kwdefaults__:
            d[i]["value"] = func.__kwdefaults__[i]
    except TypeError:
        pass

    CO_VARARGS = 4
    CO_VARKEYWORDS = 8
    if len(list(d)) >= 3 and "value" in d[list(d)[-3]] and "value" not in d[list(d)[-2]] and "value" not in d[list(d)[-1]]:  # Has both collection arguments
        d[list(d)[-2]]["collection"] = "*"
        d[list(d)[-1]]["collection"] = "**"
    elif func.__code__.co_flags & CO_VARARGS:  # *args
        d[list(d)[-1]]["collection"] = "*"
    elif func.__code__.co_flags & CO_VARKEYWORDS:  # **kwargs
        d[list(d)[-1]]["collection"] = "**"
    elif "value" in d[list(d)[-1]]:  # Exclude no collection arguments
        pass
    elif "value" not in d[list(d)[0]]:  # Exclude no keyword nor collection arguments
        pass

    if "return" in func.__annotations__:
        d["return"] = {}
        d["return"]["type"] = func.__annotations__["return"].__name__
    return d if not f else {
        **dict(filter(lambda i: "collection" not in i[1] and "value" not in i[1] and i[0] != "return", d.items())),
        **dict(filter(lambda i: i[1]["collection"] == "*", dict(filter(lambda i: "collection" in i[1] and "value" not in i[1] and i[0] != "return", d.items())).items())),
        ** dict(filter(lambda i: "collection" not in i[1] and "value" in i[1] and i[0] != "return", d.items())),
        **dict(filter(lambda i: i[1]["collection"] == "**", dict(filter(lambda i: "collection" in i[1] and "value" not in i[1] and i[0] != "return", d.items())).items())),
        **({} if "return" not in d or not r else {"return": d["return"]})
    }


def type2(arg: duck, _duck: str = 'duck') -> str:
    '''
    Creates typing string of value containers.

    Parameters
    ----------
    arg : duck
        Argument to return the typing string of.
    _duck : str, optional
        Name to use for variable types. The default is 'duck'.

    Returns
    -------
    str
        Typing string of arg.

    '''
    if isinstance(arg, dict):
        s = 'dict['
        if all(type2(i) == type2(list(arg)[0]) for i in arg):
            s += type2(list(arg)[0])
        elif type(list(arg)[0]) == list:
            return 'list['+_duck+']'
        elif type(list(arg)[0]) == set:
            return 'set['+_duck+']'
        elif type(list(arg)[0]) == dict:
            return 'dict['+_duck+', '+_duck+']'
        else:
            s += _duck
        s += ', '
        if all(type2(arg[i]) == type2(arg[list(arg)[0]]) for i in arg):
            s += type2(arg[list(arg)[0]])
        elif type(arg[list(arg)[0]]) == list:
            return 'list['+_duck+']'
        elif type(arg[list(arg)[0]]) == set:
            return 'set['+_duck+']'
        elif type(arg[list(arg)[0]]) == dict:
            return 'dict['+_duck+', '+_duck+']'
        else:
            s += _duck
        return s + ']'
    elif isinstance(arg, list):
        if all(type2(i) == type2(arg[0]) for i in arg):
            return 'list['+type2(arg[0])+']'
        elif type(arg[0]) == list:
            return 'list['+'list['+_duck+']'+']'
        elif type(arg[0]) == set:
            return 'list['+'set['+_duck+']'+']'
        elif type(arg[0]) == dict:
            return 'list['+'dict['+_duck+', '+_duck+']'+']'
        return 'list['+_duck+']'
    elif isinstance(arg, set):
        print(arg)
        if all(type2(i) == type2(list(arg)[0]) for i in list(arg)):
            return 'set['+type2(list(arg)[0])+']'
        elif type(list(arg)[0]) == list:
            return 'set['+'list['+_duck+']'+']'
        elif type(list(arg)[0]) == set:
            return 'set['+'set['+_duck+']'+']'
        elif type(list(arg)[0]) == dict:
            return 'set['+'dict['+_duck+', '+_duck+']'+']'
        return 'set['+_duck+']'
    return type(arg).__name__


def isinstance2(arg: duck, ty: type, _vars: list = [duck]) -> bool:
    '''
    Check value arg against type ty.

    Parameters
    ----------
    arg : duck
        arg for type ty to be tested against.
    ty : type
        type for the arg to be tested against.
    _vars : list, optional
        list of classes for any types. The default is [duck].

    Returns
    -------
    bool
        Whether or not the given arg is an instance of type ty.

    '''
    types = [t.strip().split(".")[-1] for t in list(filter(lambda i: i.strip(), str(ty).replace("[", ",").replace("]", ",").split(",")))]

    def test(arr: duck, ind: int) -> bool:
        '''
        Check value arr against type at types[ind].

        Parameters
        ----------
        arr : duck
            arr for type types[ind] to be tested against.
        ind : int
            types[ind] for the arr to be tested against.

        Returns
        -------
        bool
            Whether or not the given arr is an instance of type types[ind].
        '''
        if ((types[ind] == "list" or types[ind] == str(list)) and isinstance(arr, list)) or ((types[ind] == "set" or types[ind] == str(set)) and isinstance(arr, set)):
            try:
                if len(types) > ind+1:
                    return all(test(i, ind+1) for i in arr)
                else:
                    return True
            except TypeError:
                return False
        elif (types[ind] == "list" or isinstance(arr, list)) or (types[ind] == "set" or isinstance(arr, set)):
            return False
        elif (types[ind] == "dict" or types[ind] == str(dict)) and isinstance(arr, dict):
            if len(types) > ind+1:
                try:
                    return all(test(i, ind+1) for i in arr.keys()) and all(test(i, ind+2) for i in arr.values())
                except IndexError:
                    raise IndexError("dict type expected 0 or 2 subtypes")
            else:
                return True
        elif types[ind] == "dict" or isinstance(arr, dict):
            return False
        else:
            try:
                if not isinstance(arr, eval(types[ind])) and types[ind] not in [str(i) for i in _vars]:
                    return False
            except SyntaxError:
                if not isinstance(arr, ty) or not type(arr) == ty:
                    return False
        return True
    return test(arg, 0)


def check(*args: tuple, _func: type(lambda: 0) = None, _args: str = "args", _kwargs: str = "kwargs", **kwargs: dict) -> bool:
    '''
    Function for annotated function type enforcing. Only use **locals() when all arguments are annotated.

    Parameters
    ----------
    args : tuple
        excess arguments that are given under the _args name in the function arguments.
    _func : function, optional
        caller function. The default is None.
    _args : str, optional
        args name to look for in caller function annotations. The default is "args".
    _kwargs : str, optional
        kwargs name to look for in caller function annotations. The default is "kwargs".
    **kwargs : dict
        unpacked locals() call.

    Raises
    ------
    TypeError
        The type of an argument given does not match the function's requested type.

    Returns
    -------
    bool : True
        All tested arguments of the function match their requested types by the function.

    '''
    if _func is None:
        try:
            from inspect import stack
            func = eval(stack()[1][3])
        except SyntaxError:
            import __main__
            func = __main__
    else:
        func = _func

    if _args in kwargs:
        args = kwargs[_args]
        kwargs.pop(_args)
    if _kwargs in kwargs:
        for i in kwargs[_kwargs]:
            kwargs[i] = kwargs[_kwargs][i]
        kwargs.pop(_kwargs)

    def err(name: str, ntype: str, gtype: str) -> TypeError:
        '''
        Raise error of invalid type given.

        Parameters
        ----------
        name : str
            Name of invalid argument.
        ntype : str
            Requested type of invalid argument.
        gtype : str
            Given type of invalid argument.

        Raises
        ------
        TypeError
            The type of an argument given does not match the function's requested type.

        Returns
        -------
        TypeError
            The type of an argument given does not match the function's requested type.

        '''
        raise TypeError("Argument {} expected type '{}', got type '{}'".format(name, str(ntype).replace('__main__.', ''), gtype))

    for i in range(len(args)):
        if not isinstance2(args[i], func.__annotations__[_args]):
            err(_args, (func.__annotations__[_args].__name__ if hasattr(func.__annotations__[_args], "__name__") else func.__annotations__[_args]), type2(args[i]))
    for i in kwargs:
        if i in func.__annotations__:
            if not isinstance2(kwargs[i], func.__annotations__[i]):
                err(i, (func.__annotations__[i].__name__ if hasattr(func.__annotations__[i], "__name__") else func.__annotations__[i]), type2(kwargs[i]))
        else:
            try:
                if not isinstance2(kwargs[i], func.__annotations__[_kwargs]):
                    err(i, (func.__annotations__[_kwargs].__name__ if hasattr(func.__annotations__[_kwargs], "__name__") else func.__annotations__[_kwargs]), type2(kwargs[i]))
            except KeyError:
                pass
    return True


def annotate(func: type(lambda: 0)) -> bool:
    '''
    Decorator for annotated function type enforcing. All arguments should be annotated when using this.

    Parameters
    ----------
    func : function
        Function decorated.

    Raises
    ------
    TypeError
        The type of an argument given does not match the function's requested type.

    Returns
    -------
    bool : True
        All tested arguments of the function match their requested types by the function.

    '''
    def wrapper(*args: tuple, **kwargs: dict) -> duck:
        '''
        Check all variables against their type annotations.

        Parameters
        ----------
        *args : tuple
            function arguments.
        **kwargs : dict
            function keyword arguments.

        Raises
        ------
        TypeError
            The type of an argument given does not match the function's requested type.

        Returns
        -------
        duck
            The output of the decorated function.

        '''
        def err(name: str, ntype: str, gtype: str) -> TypeError:
            '''
            Raise error of invalid type given.

            Parameters
            ----------
            name : str
                Name of invalid argument.
            ntype : str
                Requested type of invalid argument.
            gtype : str
                Given type of invalid argument.

            Raises
            ------
            TypeError
                The type of an argument given does not match the function's requested type.

            Returns
            -------
            TypeError
                The type of an argument given does not match the function's requested type.

            '''
            raise TypeError("Argument {} expected type '{}', got type '{}'".format(name, str(ntype).replace('__main__.', ''), gtype))

        v = dict(filter(lambda i: "collection" in i[1] and "value" not in i[1] and i[0] != "return", vars(func, False, False).items()))
        try:
            _args = list(filter(lambda i: i[1]["collection"] == "*", v.items()))[0][0]
        except IndexError:
            _args = "args"
        try:
            _kwargs = list(filter(lambda i: i[1]["collection"] == "**", v.items()))[0][0]
        except IndexError:
            _kwargs = "kwargs"

        for i in range(len(args)):
            try:
                if i < list(func.__annotations__).index(_args):
                    if not isinstance2(args[i], list(func.__annotations__.values())[i]):
                        err(list(func.__annotations__)[i], list(func.__annotations__.values())[i].__name__, type2(args[i]))
                else:
                    if not isinstance2(args[i], func.__annotations__[_args]):
                        err(_args, list(func.__annotations__.values())[i].__name__, type2(args[i]))
            except ValueError:
                if not isinstance2(args[i], list(func.__annotations__.values())[i]):
                    err(list(func.__annotations__)[i], list(func.__annotations__.values())[i].__name__, type2(args[i]))
        for i in kwargs:
            if i in func.__annotations__:
                if not isinstance2(kwargs[i], func.__annotations__[i]):
                    err(i, (func.__annotations__[i].__name__ if hasattr(func.__annotations__[i], "__name__") else func.__annotations__[i]), type2(kwargs[i]))
            else:
                if not isinstance2(kwargs[i], func.__annotations__[_kwargs]):
                    err(i, (func.__annotations__[_kwargs].__name__ if hasattr(func.__annotations__[_kwargs], "__name__") else func.__annotations__[_kwargs]), type2(kwargs[i]))
        ret = func(*args, **kwargs)
        if "return" in func.__annotations__:
            if not isinstance2(ret, func.__annotations__["return"]):
                err("return", func.__annotations__["return"].__name__, type2(ret))
        return ret
    return wrapper


class set(dict, metaclass=type("name", (type,), {"__repr__": lambda self: self.__name__})):
    def __init__(self, *args, duplicates: bool = False, strict: bool = False, **kwargs):
        super(set, self).__init__()
        self._strict = strict
        self._duplicates = duplicates
        for i in range(len(args if len(args) == 0 or (type(args[0]) != list and type(args[0]) != tuple) else args[0])):
            t = i
            while True:
                if t not in self:
                    self[t] = (args if len(args) == 0 or (type(args[0]) != list and type(args[0]) != tuple) else args[0])[i]
                    break
                else:
                    t += 1
        for name in kwargs:
            self[name] = kwargs[name]

    def __setattr__(self, name, value):
        if (value not in self.list() or self._duplicates) and name not in ("_duplicates", "_strict"):
            try:
                self[name] = value
            except Exception:
                return super(set, self).__setattr__(name, value)
        elif name in ("_duplicates", "_strict"):
            return super(set, self).__setattr__(name, value)
        else:
            if self._strict:
                raise ValueError("Duplicate Value "+str(value)+" in set")
            else:
                return

    def __getattr__(self, name):
        try:
            return self[name]
        except AttributeError:
            return super(set, self).__getattr__(name)

    def __setitem__(self, name, value):
        if (value not in self.list() or self._duplicates) and name not in ("_duplicates", "_strict"):
            return super(set, self).__setitem__(name, value)
        elif name in ("_duplicates", "_strict"):
            return super(set, self).__setitem__(name, value)
        else:
            if self._strict:
                raise ValueError("Duplicate Value "+str(value)+" in set")
            else:
                return

    def __getitem__(self, key: (int,)):
        '''int: Use Dictionary Key Values (Default)
        tuple: Use List Indexing (ValueError)'''
        if type(key) is tuple:
            if key[-1] is dict or type(key[-1]) is dict:
                return {list(self.keys())[key[0]]: self.list()[key[0]]}  # self[-1,{}] or self[-1, dict]
            else:
                return self.list()[key[0]]  # self[-1,]
        else:
            try:
                return super(set, self).__getitem__(key)  # self[-1]
            except KeyError:
                if type(key) is int:
                    return self.__getitem__((key,))  # self[-1,]
                else:
                    raise KeyError(key)

    def __repr__(self):
        s = "{"
        keys = list(self.keys())
        values = list(self.values())
        for i in range(len(keys)):
            if keys[i] == values[i]:
                s += str(keys[i])
            else:
                s += str(keys[i])+": "+str(values[i])
            s += ", "
        return s[:-2]+"}" if len(s) > 1 else "{}"

    def set(self):
        '''Set of Values'''
        return set(self.values())

    def dict(self):
        '''Full Dictionary Output'''
        return dict(self)

    def list(self):
        '''List of Values'''
        return list(self.values())

    def copy(self, *args, **kwargs):
        c = set(*args, **kwargs)
        for i in range(len(list(self.keys()))):
            c[list(self.keys())[i]] = list(self.values())[i]
        return c

    def append(self, *args, **kwargs):
        for name in kwargs:
            self[name] = kwargs[name]
        for i in range(len(args)):
            t = i
            while True:
                if t not in self:
                    self[t] = args[i]
                    break
                else:
                    t += 1
        return

    def count(self, val):
        return list(self.values()).count(val)

    def extend(self, *args: list):
        for i in args:
            self.append(*i)
        return

    def index(self, val):
        return list(self.keys())[list(self.values()).index(val)]

    def insert(self, pos: int, elmnt):
        if pos not in self:
            self[pos] = elmnt
        else:
            s = pos+1
            while True:
                if s in self:
                    s += 1
                else:
                    for i in range(s, pos, -1):
                        self[i] = self[i-1]
                    self[pos] = elmnt
                    break
        return

    def remove(self, val):
        self.pop(list(self.keys())[list(self.values()).index(val)])
        return

    def reverse(self):
        keys = list(self.keys())
        values = list(self.values())
        for i in range(len(keys)):
            self[keys[i]] = values[len(values)-1-i]
        return

    def sort(self, *args, **kwargs):
        '''0-9A-Za-z'''
        keys = list(self.keys())
        keys.sort(*args, key=lambda i: str(i), **kwargs)
        values = list(self.values())
        values.sort(*args, key=lambda i: str(i), **kwargs)
        self.clear()
        for i in range(len(keys)):
            self[keys[i]] = values[i]
        return


from re import split, match, finditer, search
console = type('console', (), {'log': lambda *args: print(*args)})
Debug = type('Debug', (), {'log': lambda *args: print(*args)})
System = type('System', (), {'out': type('out', (), {'println': lambda *args: print(*args)})})
Console = type('Console', (), {'ReadLine': lambda *args: input(*args), 'WriteLine': lambda *args: print(*args)})
fmt = type('fmt', (), {'Println': lambda *args: print(*args)})
IO = type('IO', (), {'puts': lambda *args: print(*args), 'fwrite': lambda *args: print(*args)})
Transcript = type('Transcript', (), {'show': lambda *args: print(*args)})
raw_input = lambda *args: input(*args)
alert = lambda *args: print(*args)
prompt = lambda *args: input(*args)
print_endline = lambda *args: print(*args)
print_string = lambda *args: print(*args)
print_newline = lambda *args: print(*args)
output = lambda *args: print(*args)
input_line = lambda *args: input(*args)
read_line = lambda *args: input(*args)
DISPLAY = lambda *args: print(*args)
ShowMessage = lambda *args: print(*args)
inputbox = lambda *args: input(*args)
printf = lambda *args: print(*args)
scanf = lambda *args: input(*args)
cout = lambda *args: print(*args)
cin = lambda *args: input(*args)
CloudDeploy = lambda *args: print(*args)
Input = lambda *args: input(*args)
PRINT = lambda *args: print(*args)
INPUT = lambda *args: input(*args)
disp = lambda *args: print(*args)
puts = lambda *args: print(*args)
gets = lambda *args: input(*args)
write = lambda *args: print(*args)
writeLn = lambda *args: print(*args)
read = lambda *args: input(*args)
readLn = lambda *args: input(*args)
echo = lambda *args: print(*args)
readline = lambda *args: input(*args)
cat = lambda *args: print(*args)
dsply = lambda *args: print(*args)
display = lambda *args: print(*args)
println = lambda *args: print(*args)
readLine = lambda *args: input(*args)
getline = lambda *args: input(*args)
parseInt = lambda *args: int(*args)
parseFloat = lambda *args: float(*args)
say = lambda *args: print(*args)
ask = lambda *args: input(*args)
dialog = lambda *args: input(*args)
putStrLn = lambda *args: print(*args)
getLine = lambda *args: print(*args)
out = lambda *args, **kwargs: print(*args, *[str(i)+": "+str(kwargs[i]) for i in kwargs.keys()], end="")
log = lambda *args, **kwargs: print(*args, *[str(i)+": "+str(kwargs[i]) for i in kwargs.keys()], end=", ")
write = lambda *args, **kwargs: print(*args, *[str(i)+": "+str(kwargs[i]) for i in kwargs.keys()], end=" ")
expr = lambda *args: exec(*args)
none = None
null = None
Null = None
void = None
Void = None
true = True
false = False
t = True
f = False
char = lambda *args: args[0][0] if type(args[0]) == str and len(args) == 1 else (-1 if sum(args) < 0 else 1)*int(("-" if sum(args) < 0 else "")+"0b"+bin(sum(args))[(2 if bin(sum(args))[0] == "b" else 3)][-1*8:], 2)
uchar = lambda *args: char(*args)+(2**(1*8)-1)
schar = lambda *args: char(*args)-(2**(1*8)-1)
short = lambda *args: int(("-" if sum(args) < 0 else "")+"0b"+bin(sum(args))[(2 if bin(sum(args))[0] == "b" else 3):][-2*8:], 2)
ushort = lambda *args: short(*args)+(2**(2*8)-1)
sshort = lambda *args: short(*args)-(2**(2*8)-1)
cint = lambda *args: int(("-" if sum(args) < 0 else "")+"0b"+bin(sum(args))[(2 if bin(sum(args))[0] == "b" else 3):][-4*8:], 2)
uint = lambda *args: cint(*args)+(2**(4*8)-1)
sint = lambda *args: cint(*args)-(2**(4*8)-1)
lint = lambda *args: int(("-" if sum(args) < 0 else "")+"0b"+bin(sum(args))[(2 if bin(sum(args))[0] == "b" else 3):][-8*8:], 2)
ulint = lambda *args: lint(*args)+(2**(8*8)-1)
slint = lambda *args: lint(*args)-(2**(8*8)-1)
llint = lambda *args: int(("-" if sum(args) < 0 else "")+"0b"+bin(sum(args))[(2 if bin(sum(args))[0] == "b" else 3):][-12*8:], 2)
ullint = lambda *args: llint(*args)+(2**(12*8)-1)
sllint = lambda *args: llint(*args)-(2**(12*8)-1)
point = lambda *args: float(str(int(("-" if sum(args) < 0 else "")+"0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):][-1*8:], 2))+"."+("0"*([m.start(0) for m in finditer("[123456789]", str(sum(args)).split(".")[1])][0]) +
                            str(int("0b"+bin(int(str(sum(args)).split(".")[1]))[2:][-1*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]):], 2)) if -1*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]) < 0 else ""))
upoint = lambda *args: ldouble(*args)+(2**(1*8)-1)
spoint = lambda *args: ldouble(*args)+(2**(1*8)-1)
index = lambda *args: float(str(int(("-" if sum(args) < 0 else "")+"0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):][-2*8:], 2))+"."+("0"*([m.start(0) for m in finditer("[123456789]", str(sum(args)).split(".")[1])][0]) +
                            str(int("0b"+bin(int(str(sum(args)).split(".")[1]))[2:][-2*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]):], 2)) if -2*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]) < 0 else ""))
uindex = lambda *args: ldouble(*args)+(2**(2*8)-1)
sindex = lambda *args: ldouble(*args)+(2**(2*8)-1)
cfloat = lambda *args: float(str(int(("-" if sum(args) < 0 else "")+"0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):][-4*8:], 2))+"."+("0"*([m.start(0) for m in finditer("[123456789]", str(sum(args)).split(".")[1])][0]) +
                             str(int("0b"+bin(int(str(sum(args)).split(".")[1]))[2:][-4*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]):], 2)) if -4*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]) < 0 else ""))
ufloat = lambda *args: cfloat(*args)+(2**(4*8)-1)
sfloat = lambda *args: cfloat(*args)+(2**(4*8)-1)
double = lambda *args: float(str(int(("-" if sum(args) < 0 else "")+"0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):][-8*8:], 2))+"."+("0"*([m.start(0) for m in finditer("[123456789]", str(sum(args)).split(".")[1])][0]) +
                             str(int("0b"+bin(int(str(sum(args)).split(".")[1]))[2:][-8*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]):], 2)) if -8*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]) < 0 else ""))
udouble = lambda *args: double(*args)+(2**(8*8)-1)
sdouble = lambda *args: double(*args)+(2**(8*8)-1)
ldouble = lambda *args: float(str(int(("-" if sum(args) < 0 else "")+"0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):][-12*8:], 2))+"."+("0"*([m.start(0) for m in finditer("[123456789]", str(sum(args)).split(".")[1])][0]) +
                              str(int("0b"+bin(int(str(sum(args)).split(".")[1]))[2:][-12*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]):], 2)) if -12*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]) < 0 else ""))
uldouble = lambda *args: ldouble(*args)+(2**(12*8)-1)
sldouble = lambda *args: ldouble(*args)+(2**(12*8)-1)

from functools import cache
@cache
def parse(string, e=True, space=4):
    from re import split, match, finditer, search
    while True:
        try:
            string = string[:string.index("/*")]+string[string.index("*/")+len("*/"):]
        except ValueError:
            break
    while True:
        try:
            string = string[:string.index("<!--")]+string[string.index("-->")+len("-->"):]
        except ValueError:
            break
    string = string.replace("else if", "elif").replace("catch", "except").replace("throw", "raise").replace("typeof", "type").replace("||", " or ").replace("&&", " and ").replace("this", "self")
    string = string.split("for")
    for i in range(1, len(string)):
        string[i] = "for"+string[i]
        if match(r"[\n\t\s]*for[\s]*\([\s]*[\+\-a-zA-Z0-9_]*[\s]*[=]*[\s]*[\+\-a-zA-Z0-9_]*[\s]*;[\s]*[\+\-a-zA-Z0-9_]*[\s]*[<>=]+[\s]*[\+\-a-zA-Z0-9_]*[\s]*;[\s]*[\+\-a-zA-Z0-9_]*[\s]*[\+\+\-=a-zA-Z0-9_]*[\s]*\)", string[i]):
            formatted = [char for char in string[i][:string[i].index("for")]+string[i][string[i].index("(")+1:string[i].index(";")]+";"+string[i][:string[i].index("for")]+"while "+string[i][string[i].index(";")+1:string[i].replace(";", "_", 1).index(";")]+string[i][:string[i].index("for")]+string[i][string[i].index(")")+1:]]
            formatted.insert(formatted.index("}"), string[i][string[i].replace(";", "_", 1).index(";")+1:string[i].index(")")].strip()+";")
            string[i] = "".join(formatted)
    string = "".join(string)
    while True:
        try:
            temp = search(r"\[([\s]*[\+\-a-zA-Z0-9]*[\s]*)*\][\s]*=[\s]*[\+\-a-zA-Z0-9]*", string).group()
            string = string.replace(temp, ".__setitem__("+temp[1:].split("]")[0]+","+temp[1:].split("=")[1]+")")
        except AttributeError:
            break
    while True:
        try:
            temp = search(r"\[([\s]*[\+\-a-zA-Z0-9]*[\s]*)*(:[\s]*[\+\-a-zA-Z0-9]*[\s]*)*\]", string).group()
            if ((temp.count(":") == 2 and len(list(filter(lambda i: i, temp[1:-1].split(":")))) == 3) or
                (temp.count(":") == 1 and len(list(filter(lambda i: i, temp[1:-1].split(":")))) == 2)):
                string = string[:string.index(temp)]+temp.replace("[", ".__getitem__(slice(", 1).replace("]", ")", 1).replace(":", ",", 2)+")"+string[string.index(temp)+len(temp):]
            elif temp.count(":") == 2 or temp.count(":") == 1:
                temp2 = temp[1:-1].split(":")
                for i in range(len(temp2)):
                    if not temp2[i].strip():
                        temp2[i] = "None"
                temp2 = "["+":".join(temp2)+"]"
                string = string[:string.index(temp)]+temp2.replace("[", ".__getitem__(slice(", 1).replace("]", ")", 1).replace(":", ",", 2)+")"+string[string.index(temp)+len(temp):]
            elif temp.count(":") == 0:
                string = string[:string.index(temp)]+temp.replace("[", ".__getitem__(", 1).replace("]", ")", 1)+string[string.index(temp)+len(temp):]
        except AttributeError:
            break
    while True:
        try:
            temp = search(r"\.slice\(([\s]*[\+\-a-zA-Z0-9]*[\s]*)*(,[\s]*[\+\-a-zA-Z0-9]*[\s]*)*\)", string).group()
            string = string[:string.index(temp)+len(temp)]+")"+string[string.index(temp)+len(temp):]
            string = string.replace(".slice(", ".__getitem__(slice(", 1)
        except AttributeError:
            break
    while True:
        try:
            temp = list(filter(lambda i: string[string.index("do"):i+1].count("{") == string[string.index("do"):i+1].count("}"), [m.start()+string.index("do") for m in finditer(r"}", string[string.index("do"):])]))[0]
            string = (string[:temp]+" if not "+string[string[temp+1:].index("while")+temp+1+len("while"):string[temp+1:].index(";")+temp+1]+" {break;}} "+string[string[temp+1:].index(";")+temp+1+1:]).replace("do", " while True ", 1)
        except ValueError:
            break
    string = "".join([i.strip(" ") for i in split(r"({|}|;)", string)])
    ind = -1
    while True:
        try:
            ind = string.index("{", ind+1)
            temp = list(filter(lambda i: string[string.index("{", ind):i+1].count("{") == string[string.index("{", ind):i+1].count("}"), [m.start()+string.index("{", ind) for m in finditer(r"}", string[string.index("{", ind):])]))[0]
            if ":" in string[ind:temp]:
                tempInd = -1
                while True:
                    try:
                        tempInd = string[ind:temp].index(":", tempInd+1)+ind
                        if string[ind+1:tempInd].count("{") > string[ind+1:tempInd].count("}"):
                            tabs = string[string[:ind].rindex("\n"):ind]
                            tabs = tabs.count("\t")+tabs.count(" "*space)+1
                            string = string[:ind]+":\n"+"\t"*tabs+("pass" if len(string[ind+1:temp]) == 0 else string[ind+1:temp]).replace(";", "\n"+"\t"*tabs)+"\n"+"\t"*(tabs-1)+string[temp+1:]
                            ind = -1
                            break
                    except ValueError:
                        break
            else:
                tabs = string[string[:ind].rindex("\n"):ind]
                tabs = tabs.count("\t")+tabs.count(" "*space)+1
                string = string[:ind]+":\n"+"\t"*tabs+("pass" if len(string[ind+1:temp]) == 0 else string[ind+1:temp]).replace(";", "\n"+"\t"*tabs)+"\n"+"\t"*(tabs-1)+string[temp+1:]
                ind = -1
        except ValueError:
            break
    string = string.replace(";", "\n")
    while True:
        try:
            temp = string[string.index("++")+2:string.index("++")+2+[m.start(0) for m in finditer(r'[^a-zA-Z0-9_]', string[string.index("++")+2:])][0]]
            if temp == "":
                temp = string[[m.start(0) for m in finditer(r'[^a-zA-Z0-9_]', string[:string.index("++")])][-1]+1:string.index("++")]
                if temp == "":
                    raise ValueError
                else:
                    if temp.isnumeric() or temp.count(".") == 1 and temp.split(".")[0].isnumeric() and temp.split(".")[1].isnumeric():
                        string = string.replace("++", "", 1)
                    else:
                        copy = list(string)
                        copy.insert([m.start(0) for m in finditer(r'[^a-zA-Z0-9_]', string[:string.index("++")])][-1]+1, "((")
                        string = "".join(copy)
                        string = string.replace("++", ":=1+"+temp+")-1)", 1)
            else:
                if temp.isnumeric() or temp.count(".") == 1 and temp.split(".")[0].isnumeric() and temp.split(".")[1].isnumeric():
                    string = string.replace("++", "1+", 1)
                else:
                    copy = list(string)
                    copy.insert(string[string.index("++"):].index(temp)+string.index("++")+len(temp), ")")
                    string = "".join(copy)
                    string = string.replace("++", "("+temp + ":=1+", 1)
        except ValueError:
            break
    while True:
        try:
            temp = string[string.index("--")+2:string.index("--")+2+[m.start(0) for m in finditer(r'[^a-zA-Z0-9_]', string[string.index("--")+2:])][0]]
            if temp == "":
                temp = string[[m.start(0) for m in finditer(r'[^a-zA-Z0-9_]', string[:string.index("--")])][-1]+1:string.index("--")]
                if temp == "":
                    raise ValueError
                else:
                    if temp.isnumeric() or temp.count(".") == 1 and temp.split(".")[0].isnumeric() and temp.split(".")[1].isnumeric():
                        string = string.replace("--", "", 1)
                    else:
                        copy = list(string)
                        copy.insert([m.start(0) for m in finditer(r'[^a-zA-Z0-9_]', string[:string.index("--")])][-1]+1, "((")
                        string = "".join(copy)
                        string = string.replace("--", ":=-1+"+temp+")+1)", 1)
            else:
                if temp.isnumeric() or temp.count(".") == 1 and temp.split(".")[0].isnumeric() and temp.split(".")[1].isnumeric():
                    string = string.replace("--", "-1+", 1)
                else:
                    copy = list(string)
                    copy.insert(string[string.index("--"):].index(temp)+string.index("--")+len(temp), ")")
                    string = "".join(copy)
                    string = string.replace("--", "("+temp + ":=-1+", 1)
        except ValueError:
            break
    try:
        string = string.replace("default", "if True").replace("case", "if "+string[string.index("switch")+6:string[string.index("switch"):].index(":")+string.index("switch")]+"==").replace("switch", "while True or ")
    except ValueError:
        pass
    return exec(string) if e else string


if __name__ == "__main__":
    var = parse("""
x = prompt("Input: ");
try {x = eval(x);} catch NameError {}
if type(x) == int {print(x);} else if typeof(x) == float {print("float");}
elif typeof(x) == str {if x == "hello" {print("world");} else {print(x);}} else {print(true);}

inc = 0; log(inc--);print(inc);

dict = {0: [0, 1, 2, 3].append(4), 1: {0:1, 2:3}};
print(dict);

for (i=6; i>4; i-=1) {log(i);} print();
x=0; for (;x++<5;) {log(x)} print();

y = int(input("Switch-Y: "));
z = int(input("Switch-Z: "));
print();
switch (y, z) {case (1, 1) {print(1); break;} case (1, 2) {print(1,2); break;} default {print(None); break;}}

print("+inc");
inc=0; while ++inc < 5 {log(inc);} print();
print("inc+");
inc=0; while inc++ < 5 {log(inc);} print();
print("-inc");
inc=5; while --inc > 0 {log(inc);} print();
print("inc-");
inc=5; while inc-- > 0 {log(inc);} print();
print();

print((2==1 || 3==3) && 2==2);print();

log(x:=0); --x; print(x);

i=5; do {if True {log(i);} i++;} while i < 1;

print(/*comment*/"comment"<!--comment-->);

def start(){print(True);}
start();
""")
