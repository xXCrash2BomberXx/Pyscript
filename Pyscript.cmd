@echo off
echo class duck(type, metaclass=type("duck", (type,), {"__repr__": "duck"})): __module__, __name__, __type__ = "builtins", "duck", "duck" > custom.py
echo def rawinput(lines=1, sep="\n", endln="\n", default=[]): >> custom.py
echo     ins = []+[(i.__name__ if hasattr(i, "__name__") else str(i)) for i in default[:lines]] >> custom.py
echo     for i in range(lines-len(ins)): >> custom.py
echo         string = "" >> custom.py
echo         while len(string) == 0 or string[-1] != endln: >> custom.py
echo             string += sys.stdin.read(1) >> custom.py
echo         ins.append(string[:-1]) >> custom.py
echo     return sep.join(ins) if sep is not None else ins >> custom.py
echo def print(*args, sep=" ", end="\n", **kwargs): >> custom.py
echo     for i in args: >> custom.py
echo         sys.stdout.write(str(i)+sep) >> custom.py
echo     for i in kwargs: >> custom.py
echo         sys.stdout.write("'"+str(i)+"': "+str(kwargs[i])+sep) >> custom.py
echo     sys.stdout.write(end) >> custom.py
echo def ismutable(arg): >> custom.py
echo     if type(arg)(arg) is type(arg)(arg): >> custom.py
echo         return False >> custom.py
echo     return True >> custom.py
echo def isimmutable(arg): >> custom.py
echo     return not ismutable(arg) >> custom.py
echo def input2(*args): >> custom.py
echo     import __main__ >> custom.py
echo     for key in __main__.__annotations__: >> custom.py
echo         if key not in dir(__main__): >> custom.py
echo             return __main__.__annotations__[key](input(*args)) >> custom.py
echo     raise ValueError("annotations were not predefined") >> custom.py
echo def vars(func, f=True, r=True): >> custom.py
echo     d = {i: {} for i in func.__code__.co_varnames} >> custom.py
echo     for i in func.__annotations__: >> custom.py
echo         try: >> custom.py
echo             if '[' in str(func.__annotations__[i]): >> custom.py
echo                 d[i]["type"] = str(func.__annotations__[i]) >> custom.py
echo             else: >> custom.py
echo                 d[i]["type"] = func.__annotations__[i].__name__ >> custom.py
echo         except KeyError: >> custom.py
echo             pass >> custom.py
echo     for i in d: >> custom.py
echo         if "type" not in d[i]: >> custom.py
echo             d[i]["type"] = duck.__name__ >> custom.py
echo     try: >> custom.py
echo         for i in func.__kwdefaults__: >> custom.py
echo             d[i]["value"] = func.__kwdefaults__[i] >> custom.py
echo     except TypeError: >> custom.py
echo         pass >> custom.py
echo     CO_VARARGS = 4 >> custom.py
echo     CO_VARKEYWORDS = 8 >> custom.py
echo     if len(list(d)) >= 3 and "value" in d[list(d)[-3]] and "value" not in d[list(d)[-2]] and "value" not in d[list(d)[-1]]: >> custom.py
echo         d[list(d)[-2]]["collection"] = "*" >> custom.py
echo         d[list(d)[-1]]["collection"] = "**" >> custom.py
echo     elif func.__code__.co_flags ^& CO_VARARGS: >> custom.py
echo         d[list(d)[-1]]["collection"] = "*" >> custom.py
echo     elif func.__code__.co_flags ^& CO_VARKEYWORDS: >> custom.py
echo         d[list(d)[-1]]["collection"] = "**" >> custom.py
echo     elif "value" in d[list(d)[-1]]: >> custom.py
echo         pass >> custom.py
echo     elif "value" not in d[list(d)[0]]: >> custom.py
echo         pass >> custom.py
echo     if "return" in func.__annotations__: >> custom.py
echo         d["return"] = {} >> custom.py
echo         d["return"]["type"] = func.__annotations__["return"].__name__ >> custom.py
echo     return d if not f else { >> custom.py
echo         **dict(filter(lambda i: "collection" not in i[1] and "value" not in i[1] and i[0] != "return", d.items())), >> custom.py
echo         **dict(filter(lambda i: i[1]["collection"] == "*", dict(filter(lambda i: "collection" in i[1] and "value" not in i[1] and i[0] != "return", d.items())).items())), >> custom.py
echo         ** dict(filter(lambda i: "collection" not in i[1] and "value" in i[1] and i[0] != "return", d.items())), >> custom.py
echo         **dict(filter(lambda i: i[1]["collection"] == "**", dict(filter(lambda i: "collection" in i[1] and "value" not in i[1] and i[0] != "return", d.items())).items())), >> custom.py
echo         **({} if "return" not in d or not r else {"return": d["return"]}) >> custom.py
echo     } >> custom.py
echo def type2(arg, _duck=duck): >> custom.py
echo     if isinstance(arg, dict): >> custom.py
echo         s = type(arg).__name__+'[' >> custom.py
echo         try: >> custom.py
echo             if all(type2(i) == type2(list(arg)[0]) for i in arg): >> custom.py
echo                 s += type2(list(arg)[0]) >> custom.py
echo             elif isinstance(list(arg)[0], (list, set, tuple)): >> custom.py
echo                 return type(list(arg)[0]).__name__+'['+str(_duck)+']' >> custom.py
echo             elif isinstance(type(list(arg)[0]), dict): >> custom.py
echo                 return type(list(arg)[0]).__name__+'['+str(_duck)+', '+str(_duck)+']' >> custom.py
echo             else: >> custom.py
echo                 s += str(_duck) >> custom.py
echo             s += ', ' >> custom.py
echo             if all(type2(arg[i]) == type2(arg[list(arg)[0]]) for i in arg): >> custom.py
echo                 s += type2(arg[list(arg)[0]]) >> custom.py
echo             elif isinstance(arg[list(arg)[0]], (list, set, tuple)): >> custom.py
echo                 return type(arg[list(arg)[0]]).__name__+'['+str(_duck)+']' >> custom.py
echo             elif isinstance(arg[list(arg)[0]], dict): >> custom.py
echo                 return type(arg[list(arg)[0]]).__name__+'['+str(_duck)+', '+str(_duck)+']' >> custom.py
echo             else: >> custom.py
echo                 s += str(_duck) >> custom.py
echo             return s + ']' >> custom.py
echo         except IndexError: >> custom.py
echo             return s + str(_duck) + ']' >> custom.py
echo     elif isinstance(arg, (list, set, tuple)): >> custom.py
echo         try: >> custom.py
echo             if all(type2(i) == type2(list(arg)[0]) for i in list(arg)): >> custom.py
echo                 return type(arg).__name__+'['+type2(list(arg)[0])+']' >> custom.py
echo             elif isinstance(list(arg)[0], (list, set, tuple)): >> custom.py
echo                 return type(arg).__name__+'['+type(list(arg)[0]).__name__+'['+str(_duck)+']'+']' >> custom.py
echo             elif isinstance(type(list(arg)[0]), dict): >> custom.py
echo                 return type(arg).__name__+'['+type(list(arg)[0]).__name__+'['+str(_duck)+', '+str(_duck)+']'+']' >> custom.py
echo             return type(arg).__name__+'['+str(_duck)+']' >> custom.py
echo         except IndexError: >> custom.py
echo             return f'{type(arg).__name__}[{str(_duck)}]' >> custom.py
echo     return type(arg).__name__ >> custom.py
echo def isinstance2(arg, ty, _vars=[duck]): >> custom.py
echo     if "[" in str(ty) and "]" in str(ty): >> custom.py
echo         types = [eval(str(ty)[:str(ty).index("[")]), *[eval(i) for i in (str(ty)[str(ty).index("[")+1:str(ty).rfind("]")]).split(",")]] >> custom.py
echo     else: >> custom.py
echo         types = [ty] >> custom.py
echo     if types[0] in _vars: >> custom.py
echo         return True >> custom.py
echo     elif isinstance(arg, (list, set, tuple)) and type(arg) is types[0]: >> custom.py
echo         try: >> custom.py
echo             if len(types) == 2: >> custom.py
echo                 return all(isinstance2(i, types[1]) for i in arg) >> custom.py
echo             else: >> custom.py
echo                 return True >> custom.py
echo         except TypeError: >> custom.py
echo             return False >> custom.py
echo     elif isinstance(arg, (list, set, tuple)): >> custom.py
echo         return False >> custom.py
echo     elif isinstance(arg, dict) and type(arg) is types[0]: >> custom.py
echo         if len(types) == 3: >> custom.py
echo             try: >> custom.py
echo                 return all(isinstance2(i, types[1]) for i in arg.keys()) and all(isinstance2(i, types[2]) for i in arg.values()) >> custom.py
echo             except IndexError: >> custom.py
echo                 raise IndexError("dict type expected 0 or 2 subtypes") >> custom.py
echo         else: >> custom.py
echo             return True >> custom.py
echo     elif isinstance(arg, dict): >> custom.py
echo         return False >> custom.py
echo     else: >> custom.py
echo         try: >> custom.py
echo             if "|" in str(types[0]): >> custom.py
echo                 if not type(arg) in [eval(i) for i in str(types[0]).split("|")]: >> custom.py
echo                     return False >> custom.py
echo             else: >> custom.py
echo                 if not type(arg) is types[0] and types[0] not in _vars: >> custom.py
echo                     return False >> custom.py
echo         except SyntaxError: >> custom.py
echo             if not type(arg) is ty: >> custom.py
echo                 return False >> custom.py
echo     return True >> custom.py
echo def check(*args, _func=None, _args="args", _kwargs="kwargs", **kwargs): >> custom.py
echo     if _func is None: >> custom.py
echo         try: >> custom.py
echo             from inspect import stack >> custom.py
echo             func = eval(stack()[1][3]) >> custom.py
echo         except SyntaxError: >> custom.py
echo             import __main__ >> custom.py
echo             func = __main__ >> custom.py
echo     else: >> custom.py
echo         func = _func >> custom.py
echo     if _args in kwargs: >> custom.py
echo         args = kwargs[_args] >> custom.py
echo         kwargs.pop(_args) >> custom.py
echo     if _kwargs in kwargs: >> custom.py
echo         for i in kwargs[_kwargs]: >> custom.py
echo             kwargs[i] = kwargs[_kwargs][i] >> custom.py
echo         kwargs.pop(_kwargs) >> custom.py
echo     def err(name, ntype, gtype): >> custom.py
echo         import __main__ >> custom.py
echo         raise TypeError("Argument {} expected type '{}', got type '{}'".format(name, str(ntype).replace('__main__.', ''), gtype)) >> custom.py
echo     for i in range(len(args)): >> custom.py
echo         if not isinstance2(args[i], func.__annotations__[_args]): >> custom.py
echo             err(_args, (func.__annotations__[_args].__name__ if hasattr(func.__annotations__[_args], "__name__") else func.__annotations__[_args]), type2(args[i])) >> custom.py
echo     for i in kwargs: >> custom.py
echo         if i in func.__annotations__: >> custom.py
echo             if not isinstance2(kwargs[i], func.__annotations__[i]): >> custom.py
echo                 err(i, (func.__annotations__[i].__name__ if hasattr(func.__annotations__[i], "__name__") else func.__annotations__[i]), type2(kwargs[i])) >> custom.py
echo         else: >> custom.py
echo             try: >> custom.py
echo                 if not isinstance2(kwargs[i], func.__annotations__[_kwargs]): >> custom.py
echo                     err(i, (func.__annotations__[_kwargs].__name__ if hasattr(func.__annotations__[_kwargs], "__name__") else func.__annotations__[_kwargs]), type2(kwargs[i])) >> custom.py
echo             except KeyError: >> custom.py
echo                 pass >> custom.py
echo     return True >> custom.py
echo def annotate(func): >> custom.py
echo     def wrapper(*args, **kwargs): >> custom.py
echo         def err(name, ntype, gtype): >> custom.py
echo             import __main__ >> custom.py
echo             raise TypeError("Argument {} expected type '{}', got type '{}'".format(name, str(ntype).replace('__main__.', ''), gtype)) >> custom.py
echo         v = dict(filter(lambda i: "collection" in i[1] and "value" not in i[1] and i[0] != "return", vars(func, False, False).items())) >> custom.py
echo         try: >> custom.py
echo             _args = list(filter(lambda i: i[1]["collection"] == "*", v.items()))[0][0] >> custom.py
echo         except IndexError: >> custom.py
echo             _args = "args" >> custom.py
echo         try: >> custom.py
echo             _kwargs = list(filter(lambda i: i[1]["collection"] == "**", v.items()))[0][0] >> custom.py
echo         except IndexError: >> custom.py
echo             _kwargs = "kwargs" >> custom.py
echo         for i in range(len(args)): >> custom.py
echo             try: >> custom.py
echo                 if i ^< list(func.__annotations__).index(_args): >> custom.py
echo                     if not isinstance2(args[i], list(func.__annotations__.values())[i]): >> custom.py
echo                         err(list(func.__annotations__)[i], list(func.__annotations__.values())[i].__name__, type2(args[i])) >> custom.py
echo                 else: >> custom.py
echo                     if not isinstance2(args[i], func.__annotations__[_args]): >> custom.py
echo                         err(_args, list(func.__annotations__.values())[i].__name__, type2(args[i])) >> custom.py
echo             except ValueError: >> custom.py
echo                 if not isinstance2(args[i], list(func.__annotations__.values())[i]): >> custom.py
echo                     err(list(func.__annotations__)[i], list(func.__annotations__.values())[i].__name__, type2(args[i])) >> custom.py
echo         for i in kwargs: >> custom.py
echo             if i in func.__annotations__: >> custom.py
echo                 if not isinstance2(kwargs[i], func.__annotations__[i]): >> custom.py
echo                     err(i, (func.__annotations__[i].__name__ if hasattr(func.__annotations__[i], "__name__") else func.__annotations__[i]), type2(kwargs[i])) >> custom.py
echo             else: >> custom.py
echo                 if not isinstance2(kwargs[i], func.__annotations__[_kwargs]): >> custom.py
echo                     err(i, (func.__annotations__[_kwargs].__name__ if hasattr(func.__annotations__[_kwargs], "__name__") else func.__annotations__[_kwargs]), type2(kwargs[i])) >> custom.py
echo         ret = func(*args, **kwargs) >> custom.py
echo         if "return" in func.__annotations__: >> custom.py
echo             if not isinstance2(ret, func.__annotations__["return"]): >> custom.py
echo                 err("return", func.__annotations__["return"].__name__, type2(ret)) >> custom.py
echo         return ret >> custom.py
echo     return wrapper >> custom.py
echo import builtins >> custom.py
echo def copy(arg, trial=False, quick=False): >> custom.py
echo     if isinstance(arg, (builtins.list, builtins.set, builtins.tuple)): >> custom.py
echo         return type(arg)([copy(i) for i in arg]) >> custom.py
echo     elif isinstance(arg, builtins.dict): >> custom.py
echo         return type(arg)({i: copy(arg[i]) for i in arg}) >> custom.py
echo     elif isinstance(arg, type(lambda: 0)): >> custom.py
echo         if trial: >> custom.py
echo             d = {} >> custom.py
echo             for i in dir(arg): >> custom.py
echo                 try: >> custom.py
echo                     d[i] = copy(arg.__getattribute__(i)) >> custom.py
echo                 except TypeError: >> custom.py
echo                     d[i] = arg.__getattribute__(i) >> custom.py
echo             return type(arg.__name__, tuple(), d)() >> custom.py
echo         elif not quick: >> custom.py
echo             return type(arg.__name__, tuple(), {i: arg.__getattribute__(i) for i in dir(arg)})() >> custom.py
echo         else: >> custom.py
echo             return arg >> custom.py
echo     elif hasattr(arg, "__dict__") or hasattr(arg, "__slots__"): >> custom.py
echo         return type(type(arg).__name__, type(arg).__bases__, dict(copy(arg.__dict__)))() >> custom.py
echo     else: >> custom.py
echo         return arg >> custom.py
echo class array(list, metaclass=type("array", (type,), {"__repr__": "array"})): >> custom.py
echo     __module__, __name__, __type__ = "builtins", "array", "array" >> custom.py
echo     none = type("None", (object,), {"__name__": "none"})() >> custom.py
echo     def __init__(self, val: int, ty: type = none): >> custom.py
echo         if ty is not array.none and (type(ty) is not type or type(val) is not int): >> custom.py
echo             val, ty = ty, val >> custom.py
echo         super().__init__() >> custom.py
echo         super().__setattr__("type", ty) >> custom.py
echo         for i in range(val): >> custom.py
echo             self.append(None) >> custom.py
echo     def __call__(self, val: int, ty: type = none): >> custom.py
echo         def deep(arr): >> custom.py
echo             for i in range(len(arr)): >> custom.py
echo                 if isinstance(arr[i], list): >> custom.py
echo                     deep(arr[i]) >> custom.py
echo                 elif arr[i] is None: >> custom.py
echo                     arr[i] = array(val, ty) >> custom.py
echo                 else: >> custom.py
echo                     raise ValueError(arr[i]) >> custom.py
echo         super().__setattr__("type", array) >> custom.py
echo         deep(self) >> custom.py
echo         return self >> custom.py
echo     def __setitem__(self, name, value): >> custom.py
echo         if self.type is not array.none and type(value) is not self.type and value is not self.type: >> custom.py
echo             raise TypeError(f"{name} expected type "+str(self.type.__name__ if hasattr(self.type, '__name__') else self.type)+" but got type "+str(type(value).__name__ if hasattr(type(value), '__name__') else type(value))) >> custom.py
echo         else: >> custom.py
echo             super().__setitem__(name, value) >> custom.py
echo def flatten(array): >> custom.py
echo     for i in range(len(array)): >> custom.py
echo         if isinstance(array[i], list): >> custom.py
echo             array = array[:i]+flatten(array[i])+array[i+1:] >> custom.py
echo     return array >> custom.py
echo class set(dict, metaclass=type("name", (type,), {"__repr__": "set"})): >> custom.py
echo     __module__, __name__, __type__ = "builtins", "set", "set" >> custom.py
echo     def __init__(self, *args, duplicates: bool = False, strict: bool = False, **kwargs): >> custom.py
echo         super(set, self).__init__() >> custom.py
echo         self._strict = strict >> custom.py
echo         self._duplicates = duplicates >> custom.py
echo         for i in range(len(args if len(args) == 0 or (type(args[0]) != list and type(args[0]) != tuple) else args[0])): >> custom.py
echo             t = i >> custom.py
echo             while True: >> custom.py
echo                 if t not in self: >> custom.py
echo                     self[t] = (args if len(args) == 0 or (type(args[0]) != list and type(args[0]) != tuple) else args[0])[i] >> custom.py
echo                     break >> custom.py
echo                 else: >> custom.py
echo                     t += 1 >> custom.py
echo         for name in kwargs: >> custom.py
echo             self[name] = kwargs[name] >> custom.py
echo     def __setattr__(self, name, value): >> custom.py
echo         if (not any(i is value for i in self.list()) or self._duplicates) and name not in ("_duplicates", "_strict"): >> custom.py
echo             try: >> custom.py
echo                 self[name] = value >> custom.py
echo             except Exception: >> custom.py
echo                 return super(set, self).__setattr__(name, value) >> custom.py
echo         elif name in ("_duplicates", "_strict"): >> custom.py
echo             return super(set, self).__setattr__(name, value) >> custom.py
echo         else: >> custom.py
echo             if self._strict: >> custom.py
echo                 raise ValueError("Duplicate Value "+str(value)+" in set") >> custom.py
echo     def __getattr__(self, name): >> custom.py
echo         try: >> custom.py
echo             return self[name] >> custom.py
echo         except AttributeError: >> custom.py
echo             return super(set, self).__getattr__(name) >> custom.py
echo     def __setitem__(self, name, value): >> custom.py
echo         if (not any(i is value for i in self.list()) or self._duplicates) and name not in ("_duplicates", "_strict"): >> custom.py
echo             return super(set, self).__setitem__(name, value) >> custom.py
echo         elif name in ("_duplicates", "_strict"): >> custom.py
echo             return super(set, self).__setitem__(name, value) >> custom.py
echo         else: >> custom.py
echo             if self._strict: >> custom.py
echo                 raise ValueError("Duplicate Value "+str(value)+" in set") >> custom.py
echo     def __getitem__(self, key: (int,)): >> custom.py
echo         if type(key) is tuple: >> custom.py
echo             if key[-1] is dict or type(key[-1]) is dict: >> custom.py
echo                 return {list(self.keys())[key[0]]: self.list()[key[0]]} >> custom.py
echo             else: >> custom.py
echo                 return self.list()[key[0]] >> custom.py
echo         else: >> custom.py
echo             try: >> custom.py
echo                 return super(set, self).__getitem__(key) >> custom.py
echo             except KeyError: >> custom.py
echo                 if type(key) is int: >> custom.py
echo                     return self.__getitem__((key,)) >> custom.py
echo                 else: >> custom.py
echo                     raise KeyError(key) >> custom.py
echo     def __repr__(self): >> custom.py
echo         s = "{" >> custom.py
echo         keys = list(self.keys()) >> custom.py
echo         values = list(self.values()) >> custom.py
echo         for i in range(len(keys)): >> custom.py
echo             if keys[i] == values[i]: >> custom.py
echo                 s += (str(keys[i]) if type(keys[i]) != str else "'{}'".format(keys[i])) >> custom.py
echo             else: >> custom.py
echo                 s += (str(keys[i]) if type(keys[i]) != str else "'{}'".format(keys[i]))+": "+(str(values[i]) if type(values[i]) != str else "'{}'".format(values[i])) >> custom.py
echo             s += ", " >> custom.py
echo         return s[:-2]+"}" if len(s) ^> 1 else "{}" >> custom.py
echo     def set(self): >> custom.py
echo         return set(self.values()) >> custom.py
echo     def dict(self): >> custom.py
echo         return dict(self) >> custom.py
echo     def list(self): >> custom.py
echo         return list(self.values()) >> custom.py
echo     def copy(self, *args, **kwargs): >> custom.py
echo         c = set(*args, **kwargs) >> custom.py
echo         for i in range(len(list(self.keys()))): >> custom.py
echo             c[list(self.keys())[i]] = list(self.values())[i] >> custom.py
echo         return c >> custom.py
echo     def append(self, *args, **kwargs): >> custom.py
echo         for name in kwargs: >> custom.py
echo             self[name] = kwargs[name] >> custom.py
echo         for i in range(len(args)): >> custom.py
echo             t = i >> custom.py
echo             while True: >> custom.py
echo                 if t not in self: >> custom.py
echo                     self[t] = args[i] >> custom.py
echo                     break >> custom.py
echo                 else: >> custom.py
echo                     t += 1 >> custom.py
echo         return >> custom.py
echo     def count(self, val): >> custom.py
echo         return list(self.values()).count(val) >> custom.py
echo     def extend(self, *args: list): >> custom.py
echo         for i in args: >> custom.py
echo             self.append(*i) >> custom.py
echo     def index(self, val): >> custom.py
echo         return list(self.keys())[list(self.values()).index(val)] >> custom.py
echo     def insert(self, pos: int, elmnt): >> custom.py
echo         if pos not in self: >> custom.py
echo             self[pos] = elmnt >> custom.py
echo         else: >> custom.py
echo             s = pos+1 >> custom.py
echo             while True: >> custom.py
echo                 if s in self: >> custom.py
echo                     s += 1 >> custom.py
echo                 else: >> custom.py
echo                     for i in range(s, pos, -1): >> custom.py
echo                         self[i] = self[i-1] >> custom.py
echo                     self[pos] = elmnt >> custom.py
echo                     break >> custom.py
echo     def remove(self, val): >> custom.py
echo         self.pop(list(self.keys())[list(self.values()).index(val)]) >> custom.py
echo     def reverse(self): >> custom.py
echo         keys = list(self.keys()) >> custom.py
echo         values = list(self.values()) >> custom.py
echo         for i in range(len(keys)): >> custom.py
echo             self[keys[i]] = values[len(values)-1-i] >> custom.py
echo     @staticmethod >> custom.py
echo     def _sort(array): >> custom.py
echo         return sorted(list(filter(lambda i: type(i) == bool, array)))+sorted(list(filter(lambda i: type(i) == str and not i.isdigit(), array)))+sorted(list(filter(lambda i: type(i) == str and i.isdigit(), array)), key=lambda t: int(t))+sorted(list(filter(lambda i: type(i) == int or type(i) == float, array))) >> custom.py
echo     def sort(self, *args, **kwargs): >> custom.py
echo         keys = self._sort(list(self.keys())) >> custom.py
echo         values = self._sort(list(self.values())) >> custom.py
echo         self.clear() >> custom.py
echo         for i in range(len(keys)): >> custom.py
echo             self[keys[i]] = values[i] >> custom.py
echo     def ksort(self): >> custom.py
echo         keys = self._sort(list(self.keys())) >> custom.py
echo         values = list(self.values()) >> custom.py
echo         self.clear() >> custom.py
echo         for i in range(len(keys)): >> custom.py
echo             self[keys[i]] = values[i] >> custom.py
echo     def vsort(self): >> custom.py
echo         keys = list(self.keys()) >> custom.py
echo         values = self._sort(list(self.values())) >> custom.py
echo         self.clear() >> custom.py
echo         for i in range(len(keys)): >> custom.py
echo             self[keys[i]] = values[i] >> custom.py

echo from functools import cache >> custom.py
echo @cache >> custom.py
echo def parse(string, e=True, space=4): >> custom.py
echo     from re import split, match, finditer, search >> custom.py
echo     while True: >> custom.py
echo         try: >> custom.py
echo             string = string[:string.index("/*")]+string[string.index("*/")+len("*/"):] >> custom.py
echo         except ValueError: >> custom.py
echo             break >> custom.py
echo     while True: >> custom.py
echo         try: >> custom.py
echo             string = string[:string.index("<!--")]+string[string.index("-->")+len("-->"):] >> custom.py
echo         except ValueError: >> custom.py
echo             break >> custom.py
echo     string = string.replace("else if", "elif").replace("catch", "except").replace("throw", "raise").replace("typeof", "type").replace("||", " or ").replace("&&", " and ").replace("until", "while not").replace("switch", "match").replace("default", "case _") >> custom.py
echo     string = string.split("for") >> custom.py
echo     for i in range(1, len(string)): >> custom.py
echo         string[i] = "for"+string[i] >> custom.py
echo         if match(r"[\n\t\s]*for[\s]*\([\s]*[\+\-a-zA-Z0-9_]*[\s]*[=]*[\s]*[\+\-a-zA-Z0-9_]*[\s]*;[\s]*[\+\-a-zA-Z0-9_<>=]*[\s]*;[\s]*[\+\-a-zA-Z0-9_]*[\s]*[\+\-=a-zA-Z0-9_]*[\s]*\)", string[i]): >> custom.py
echo             formatted = [char for char in string[i][:string[i].index("for")]+string[i][string[i].index("(")+1:string[i].index(";")]+";"+string[i][:string[i].index("for")]+"while "+string[i][string[i].index(";")+1:string[i].replace(";", "_", 1).index(";")]+string[i][:string[i].index("for")]+string[i][string[i].index(")")+1:]] >> custom.py
echo             formatted.insert(formatted.index("}"), string[i][string[i].replace(";", "_", 1).index(";")+1:string[i].index(")")].strip()+";") >> custom.py
echo             string[i] = "".join(formatted) >> custom.py
echo     string = "".join(string) >> custom.py
echo     while True: >> custom.py
echo         try: >> custom.py
echo             temp = search(r"\[([\s]*[\+\-a-zA-Z0-9]*[\s]*)*\][\s]*=[\s]*[\+\-a-zA-Z0-9]*", string).group() >> custom.py
echo             string = string.replace(temp, ".__setitem__("+temp[1:].split("]")[0]+","+temp[1:].split("=")[1]+")") >> custom.py
echo         except AttributeError: >> custom.py
echo             break >> custom.py
echo     while True: >> custom.py
echo         try: >> custom.py
echo             temp = search(r"\[([\s]*[\+\-a-zA-Z0-9]*[\s]*)*(:[\s]*[\+\-a-zA-Z0-9]*[\s]*)*\]", string).group() >> custom.py
echo             if ((temp.count(":") == 2 and len(list(filter(lambda i: i, temp[1:-1].split(":")))) == 3) or >> custom.py
echo                 (temp.count(":") == 1 and len(list(filter(lambda i: i, temp[1:-1].split(":")))) == 2)): >> custom.py
echo                 string = string[:string.index(temp)]+temp.replace("[", ".__getitem__(slice(", 1).replace("]", ")", 1).replace(":", ",", 2)+")"+string[string.index(temp)+len(temp):] >> custom.py
echo             elif temp.count(":") == 2 or temp.count(":") == 1: >> custom.py
echo                 temp2 = temp[1:-1].split(":") >> custom.py
echo                 for i in range(len(temp2)): >> custom.py
echo                     if not temp2[i].strip(): >> custom.py
echo                         temp2[i] = "None" >> custom.py
echo                 temp2 = "["+":".join(temp2)+"]" >> custom.py
echo                 string = string[:string.index(temp)]+temp2.replace("[", ".__getitem__(slice(", 1).replace("]", ")", 1).replace(":", ",", 2)+")"+string[string.index(temp)+len(temp):] >> custom.py
echo             elif temp.count(":") == 0: >> custom.py
echo                 string = string[:string.index(temp)]+temp.replace("[", ".__getitem__(", 1).replace("]", ")", 1)+string[string.index(temp)+len(temp):] >> custom.py
echo         except AttributeError: >> custom.py
echo             break >> custom.py
echo     while True: >> custom.py
echo         try: >> custom.py
echo             temp = search(r"\.slice\(([\s]*[\+\-a-zA-Z0-9]*[\s]*)*(,[\s]*[\+\-a-zA-Z0-9]*[\s]*)*\)", string).group() >> custom.py
echo             string = string[:string.index(temp)+len(temp)]+")"+string[string.index(temp)+len(temp):] >> custom.py
echo             string = string.replace(".slice(", ".__getitem__(slice(", 1) >> custom.py
echo         except AttributeError: >> custom.py
echo             break >> custom.py
echo     while True: >> custom.py
echo         try: >> custom.py
echo             temp = list(filter(lambda i: string[string.index("do"):i+1].count("{") == string[string.index("do"):i+1].count("}"), [m.start()+string.index("do") for m in finditer(r"}", string[string.index("do"):])]))[0] >> custom.py
echo             string = (string[:temp]+" if not "+string[string[temp+1:].index("while")+temp+1+len("while"):string[temp+1:].index(";")+temp+1]+" {break;}} "+string[string[temp+1:].index(";")+temp+1+1:]).replace("do", " while True ", 1) >> custom.py
echo         except ValueError: >> custom.py
echo             break >> custom.py
echo     string = "".join([i.strip(" ") for i in split(r"({|}|;)", string)]) >> custom.py
echo     ind = -1 >> custom.py
echo     while True: >> custom.py
echo         try: >> custom.py
echo             ind = string.index("{", ind+1) >> custom.py
echo             temp = list(filter(lambda i: string[string.index("{", ind):i+1].count("{") == string[string.index("{", ind):i+1].count("}"), [m.start()+string.index("{", ind) for m in finditer(r"}", string[string.index("{", ind):])]))[0] >> custom.py
echo             if ":" in string[ind:temp]: >> custom.py
echo                 tempInd = -1 >> custom.py
echo                 while True: >> custom.py
echo                     try: >> custom.py
echo                         tempInd = string[ind:temp].index(":", tempInd+1)+ind >> custom.py
echo                         if string[ind+1:tempInd].count("{") ^> string[ind+1:tempInd].count("}"): >> custom.py
echo                             tabs = string[string[:ind].rindex("\n"):ind] >> custom.py
echo                             tabs = tabs.count("\t")+tabs.count(" "*space)+1 >> custom.py
echo                             string = string[:ind]+":\n"+"\t"*tabs+("pass" if len(string[ind+1:temp]) == 0 else string[ind+1:temp]).replace(";", "\n"+"\t"*tabs)+"\n"+"\t"*(tabs-1)+string[temp+1:] >> custom.py
echo                             ind = -1 >> custom.py
echo                             break >> custom.py
echo                     except ValueError: >> custom.py
echo                         break >> custom.py
echo             else: >> custom.py
echo                 tabs = string[string[:ind].rindex("\n"):ind] >> custom.py
echo                 tabs = tabs.count("\t")+tabs.count(" "*space)+1 >> custom.py
echo                 string = string[:ind]+":\n"+"\t"*tabs+("pass" if len(string[ind+1:temp]) == 0 else string[ind+1:temp]).replace(";", "\n"+"\t"*tabs)+"\n"+"\t"*(tabs-1)+string[temp+1:] >> custom.py
echo                 ind = -1 >> custom.py
echo         except ValueError: >> custom.py
echo             break >> custom.py
echo     string = string.replace(";", "\n") >> custom.py
echo     while True: >> custom.py
echo         try: >> custom.py
echo             temp = string[string.index("++")+2:string.index("++")+2+[m.start(0) for m in finditer(r'[^^a-zA-Z0-9_]', string[string.index("++")+2:])][0]] >> custom.py
echo             if temp == "": >> custom.py
echo                 temp = string[[m.start(0) for m in finditer(r'[^^a-zA-Z0-9_]', string[:string.index("++")])][-1]+1:string.index("++")] >> custom.py
echo                 if temp == "": >> custom.py
echo                     raise ValueError >> custom.py
echo                 else: >> custom.py
echo                     if temp.isnumeric() or temp.count(".") == 1 and temp.split(".")[0].isnumeric() and temp.split(".")[1].isnumeric(): >> custom.py
echo                        string = string.replace("++", "", 1) >> custom.py
echo                     else: >> custom.py
echo                         copy = list(string) >> custom.py
echo                         copy.insert([m.start(0) for m in finditer(r'[^^a-zA-Z0-9_]', string[:string.index("++")])][-1]+1, "((") >> custom.py
echo                         string = "".join(copy) >> custom.py
echo                         string = string.replace("++", ":=1+"+temp+")-1)", 1) >> custom.py
echo             else: >> custom.py
echo                 if temp.isnumeric() or temp.count(".") == 1 and temp.split(".")[0].isnumeric() and temp.split(".")[1].isnumeric(): >> custom.py
echo                     string = string.replace("++", "1+", 1) >> custom.py
echo                 else: >> custom.py
echo                     copy = list(string) >> custom.py
echo                     copy.insert(string[string.index("++"):].index(temp)+string.index("++")+len(temp), ")") >> custom.py
echo                     string = "".join(copy) >> custom.py
echo                     string = string.replace("++", "("+temp + ":=1+", 1) >> custom.py
echo         except ValueError: >> custom.py
echo             break >> custom.py
echo     while True: >> custom.py
echo         try: >> custom.py
echo             temp = string[string.index("--")+2:string.index("--")+2+[m.start(0) for m in finditer(r'[^^a-zA-Z0-9_]', string[string.index("--")+2:])][0]] >> custom.py
echo             if temp == "": >> custom.py
echo                 temp = string[[m.start(0) for m in finditer(r'[^^a-zA-Z0-9_]', string[:string.index("--")])][-1]+1:string.index("--")] >> custom.py
echo                 if temp == "": >> custom.py
echo                     raise ValueError >> custom.py
echo                 else: >> custom.py
echo                     if temp.isnumeric() or temp.count(".") == 1 and temp.split(".")[0].isnumeric() and temp.split(".")[1].isnumeric(): >> custom.py
echo                        string = string.replace("--", "", 1) >> custom.py
echo                     else: >> custom.py
echo                         copy = list(string) >> custom.py
echo                         copy.insert([m.start(0) for m in finditer(r'[^^a-zA-Z0-9_]', string[:string.index("--")])][-1]+1, "((") >> custom.py
echo                         string = "".join(copy) >> custom.py
echo                         string = string.replace("--", ":=-1+"+temp+")+1)", 1) >> custom.py
echo             else: >> custom.py
echo                 if temp.isnumeric() or temp.count(".") == 1 and temp.split(".")[0].isnumeric() and temp.split(".")[1].isnumeric(): >> custom.py
echo                     string = string.replace("--", "-1+", 1) >> custom.py
echo                 else: >> custom.py
echo                     copy = list(string) >> custom.py
echo                     copy.insert(string[string.index("--"):].index(temp)+string.index("--")+len(temp), ")") >> custom.py
echo                     string = "".join(copy) >> custom.py
echo                     string = string.replace("--", "("+temp + ":=-1+", 1) >> custom.py
echo         except ValueError: >> custom.py
echo             break >> custom.py
echo     return exec(string, globals(), locals()) if e else string >> custom.py

echo import ast >> custom.py
echo from copy import deepcopy >> custom.py
echo def convertExpr2Expression(Expr): >> custom.py
echo     Expr.lineno = 0 >> custom.py
echo     Expr.col_offset = 0 >> custom.py
echo     result = ast.Expression(Expr.value, lineno=0, col_offset = 0) >> custom.py
echo     return result >> custom.py
echo def exec_with_return(code): >> custom.py
echo     code_ast = ast.parse("\n"+code) >> custom.py
echo     init_ast = deepcopy(code_ast) >> custom.py
echo     init_ast.body = code_ast.body[:-1] >> custom.py
echo     last_ast = deepcopy(code_ast) >> custom.py
echo     last_ast.body = code_ast.body[-1:] >> custom.py
echo     exec(compile(init_ast, "<ast>", "exec"), globals()) >> custom.py
echo     if type(last_ast.body[0]) == ast.Expr: >> custom.py
echo         return eval(compile(convertExpr2Expression(last_ast.body[0]), "<ast>", "eval"), globals()) >> custom.py
echo     else: >> custom.py
echo         exec(compile(last_ast, "<ast>", "exec"), globals()) >> custom.py

echo import sys >> custom.py
echo from re import split, match, finditer, search >> custom.py
echo g = ^"^"^" >> custom.py
echo function = type(lambda: 0) >> custom.py
echo console = type('console', (), {'log': lambda *args: print(*args)}) >> custom.py
echo Debug = type('Debug', (), {'log': lambda *args: print(*args)}) >> custom.py
echo System = type('System', (), {'out': type('out', (), {'println': lambda *args: print(*args)}), 'in': type('in', (), {'read': lambda *args: input(*args)})}) >> custom.py
echo Console = type('Console', (), {'ReadLine': lambda *args: input(*args), 'WriteLine': lambda *args: print(*args)}) >> custom.py
echo fmt = type('fmt', (), {'Println': lambda *args: print(*args)}) >> custom.py
echo IO = type('IO', (), {'puts': lambda *args: print(*args), 'fwrite': lambda *args: print(*args)}) >> custom.py
echo Transcript = type('Transcript', (), {'show': lambda *args: print(*args)}) >> custom.py
echo raw_input = lambda *args: input(*args) >> custom.py
echo alert = lambda *args: print(*args) >> custom.py
echo prompt = lambda *args: input(*args) >> custom.py
echo print_endline = lambda *args: print(*args) >> custom.py
echo print_string = lambda *args: print(*args) >> custom.py
echo print_newline = lambda *args: print(*args) >> custom.py
echo output = lambda *args: print(*args) >> custom.py
echo input_line = lambda *args: input(*args) >> custom.py
echo read_line = lambda *args: input(*args) >> custom.py
echo DISPLAY = lambda *args: print(*args) >> custom.py
echo ShowMessage = lambda *args: print(*args) >> custom.py
echo inputbox = lambda *args: input(*args) >> custom.py
echo printf = lambda *args: print(*args) >> custom.py
echo scanf = lambda *args: input(*args) >> custom.py
echo cout = lambda *args: print(*args) >> custom.py
echo cin = lambda *args: input(*args) >> custom.py
echo CloudDeploy = lambda *args: print(*args) >> custom.py
echo Input = lambda *args: input(*args) >> custom.py
echo PRINT = lambda *args: print(*args) >> custom.py
echo INPUT = lambda *args: input(*args) >> custom.py
echo disp = lambda *args: print(*args) >> custom.py
echo puts = lambda *args: print(*args) >> custom.py
echo gets = lambda *args: input(*args) >> custom.py
echo write = lambda *args: print(*args) >> custom.py
echo writeLn = lambda *args: print(*args) >> custom.py
echo read = lambda *args: input(*args) >> custom.py
echo readLn = lambda *args: input(*args) >> custom.py
echo echo = lambda *args: print(*args) >> custom.py
echo readline = lambda *args: input(*args) >> custom.py
echo cat = lambda *args: print(*args) >> custom.py
echo dsply = lambda *args: print(*args) >> custom.py
echo display = lambda *args: print(*args) >> custom.py
echo println = lambda *args: print(*args) >> custom.py
echo readLine = lambda *args: input(*args) >> custom.py
echo getline = lambda *args: input(*args) >> custom.py
echo parseInt = lambda *args: int(*args) >> custom.py
echo parseFloat = lambda *args: float(*args) >> custom.py
echo say = lambda *args: print(*args) >> custom.py
echo ask = lambda *args: input(*args) >> custom.py
echo dialog = lambda *args: input(*args) >> custom.py
echo putStrLn = lambda *args: print(*args) >> custom.py
echo getLine = lambda *args: input(*args) >> custom.py
echo out = lambda *args, **kwargs: print(*args, *[str(i)+": "+str(kwargs[i]) for i in kwargs.keys()], end="") >> custom.py
echo log = lambda *args, **kwargs: print(*args, *[str(i)+": "+str(kwargs[i]) for i in kwargs.keys()], end=", ") >> custom.py
echo write = lambda *args, **kwargs: print(*args, *[str(i)+": "+str(kwargs[i]) for i in kwargs.keys()], end=" ") >> custom.py
echo expr = lambda *args: exec(*args) >> custom.py
echo none = None >> custom.py
echo null = None >> custom.py
echo Null = None >> custom.py
echo void = None >> custom.py
echo Void = None >> custom.py
echo true = True >> custom.py
echo false = False >> custom.py
echo t = True >> custom.py
echo f = False >> custom.py
echo char = lambda *args: args[0][0] if type(args[0]) == str and len(args) == 1 else (-1 if sum(args) ^< 0 else 1)*int(("-" if sum(args) ^< 0 else "")+"0b"+bin(sum(args))[(2 if bin(sum(args))[0] == "b" else 3)][-1*8:], 2) >> custom.py
echo uchar = lambda *args: char(*args)+(2**(1*8)-1) >> custom.py
echo schar = lambda *args: char(*args)-(2**(1*8)-1) >> custom.py
echo short = lambda *args: int(("-" if sum(args) ^< 0 else "")+"0b"+bin(sum(args))[(2 if bin(sum(args))[0] == "b" else 3):][-2*8:], 2) >> custom.py
echo ushort = lambda *args: short(*args)+(2**(2*8)-1) >> custom.py
echo sshort = lambda *args: short(*args)-(2**(2*8)-1) >> custom.py
echo cint = lambda *args: int(("-" if sum(args) ^< 0 else "")+"0b"+bin(sum(args))[(2 if bin(sum(args))[0] == "b" else 3):][-4*8:], 2) >> custom.py
echo uint = lambda *args: cint(*args)+(2**(4*8)-1) >> custom.py
echo sint = lambda *args: cint(*args)-(2**(4*8)-1) >> custom.py
echo lint = lambda *args: int(("-" if sum(args) ^< 0 else "")+"0b"+bin(sum(args))[(2 if bin(sum(args))[0] == "b" else 3):][-8*8:], 2) >> custom.py
echo ulint = lambda *args: lint(*args)+(2**(8*8)-1) >> custom.py
echo slint = lambda *args: lint(*args)-(2**(8*8)-1) >> custom.py
echo llint = lambda *args: int(("-" if sum(args) ^< 0 else "")+"0b"+bin(sum(args))[(2 if bin(sum(args))[0] == "b" else 3):][-12*8:], 2) >> custom.py
echo ullint = lambda *args: llint(*args)+(2**(12*8)-1) >> custom.py
echo sllint = lambda *args: llint(*args)-(2**(12*8)-1) >> custom.py
echo point = lambda *args: float(str(int(("-" if sum(args) ^< 0 else "")+"0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):][-1*8:], 2))+"."+("0"*([m.start(0) for m in finditer("[123456789]", str(sum(args)).split(".")[1])][0])+str(int("0b"+bin(int(str(sum(args)).split(".")[1]))[2:][-1*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]):], 2)) if -1*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]) ^< 0 else "")) >> custom.py
echo upoint = lambda *args: ldouble(*args)+(2**(1*8)-1) >> custom.py
echo spoint = lambda *args: ldouble(*args)+(2**(1*8)-1) >> custom.py
echo index = lambda *args: float(str(int(("-" if sum(args) ^< 0 else "")+"0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):][-2*8:], 2))+"."+("0"*([m.start(0) for m in finditer("[123456789]", str(sum(args)).split(".")[1])][0])+str(int("0b"+bin(int(str(sum(args)).split(".")[1]))[2:][-2*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]):], 2)) if -2*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]) ^< 0 else "")) >> custom.py
echo uindex = lambda *args: ldouble(*args)+(2**(2*8)-1) >> custom.py
echo sindex = lambda *args: ldouble(*args)+(2**(2*8)-1) >> custom.py
echo cfloat = lambda *args: float(str(int(("-" if sum(args) ^< 0 else "")+"0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):][-4*8:], 2))+"."+("0"*([m.start(0) for m in finditer("[123456789]", str(sum(args)).split(".")[1])][0])+str(int("0b"+bin(int(str(sum(args)).split(".")[1]))[2:][-4*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]):], 2)) if -4*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]) ^< 0 else "")) >> custom.py
echo ufloat = lambda *args: cfloat(*args)+(2**(4*8)-1) >> custom.py
echo sfloat = lambda *args: cfloat(*args)+(2**(4*8)-1) >> custom.py
echo double = lambda *args: float(str(int(("-" if sum(args) ^< 0 else "")+"0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):][-8*8:], 2))+"."+("0"*([m.start(0) for m in finditer("[123456789]", str(sum(args)).split(".")[1])][0])+str(int("0b"+bin(int(str(sum(args)).split(".")[1]))[2:][-8*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]):], 2)) if -8*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]) ^< 0 else "")) >> custom.py
echo udouble = lambda *args: double(*args)+(2**(8*8)-1) >> custom.py
echo sdouble = lambda *args: double(*args)+(2**(8*8)-1) >> custom.py
echo ldouble = lambda *args: float(str(int(("-" if sum(args) ^< 0 else "")+"0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):][-12*8:], 2))+"."+("0"*([m.start(0) for m in finditer("[123456789]", str(sum(args)).split(".")[1])][0])+str(int("0b"+bin(int(str(sum(args)).split(".")[1]))[2:][-12*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]):], 2)) if -12*8+len("0b"+bin(int(str(sum(args)).split(".")[0]))[(2 if bin(int(str(sum(args)).split(".")[0]))[0] == "b" else 3):]) ^< 0 else "")) >> custom.py
echo uldouble = lambda *args: ldouble(*args)+(2**(12*8)-1) >> custom.py
echo sldouble = lambda *args: ldouble(*args)+(2**(12*8)-1) >> custom.py
echo ^"^"^" >> custom.py
echo exec_with_return(g) >> custom.py
echo from timeit import default_timer >> custom.py
echo if len(sys.argv) != 1: >> custom.py
echo     with open(sys.argv[-1], 'r') as f: >> custom.py
echo         var = exec_with_return(parse("\n"+f.read()+"\n", e=False)) >> custom.py
echo         if var != None: >> custom.py
echo             print("\n<", var) >> custom.py
echo     print() >> custom.py
echo print("Pyscript a2.25 (Dec 17 2021)\nType \"help\", \"copyright\", \"credits\" or \"license\" for more information.") >> custom.py
echo while True: >> custom.py
echo     try: >> custom.py
echo         total = "" >> custom.py
echo         inp = builtins.input(">>> ") >> custom.py
echo         total += inp+";" >> custom.py
echo         while inp != "" and inp != "quit()" and inp != "^Z": >> custom.py
echo             inp = builtins.input("... ") >> custom.py
echo             total += inp+";" >> custom.py
echo         timeit = default_timer() >> custom.py
echo         if inp == "quit()" or inp == "^Z": >> custom.py
echo             break >> custom.py
echo         elif not total.strip("\n; "): >> custom.py
echo             pass >> custom.py
echo         else: >> custom.py
echo             var = exec_with_return(parse("\n"+total.replace("System.in", "System.__getattribute__(System, 'in')")+"\n", e=False)) >> custom.py
echo             if var != None: >> custom.py
echo                 print(f"< {var!r}") >> custom.py
echo             print(f"<< {default_timer()-timeit}s") >> custom.py
echo     except Exception as e: >> custom.py
echo         print(f"< {e}") >> custom.py
echo         print(f"<< {default_timer()-timeit}s") >> custom.py

python custom.py %1

del /f custom.py
