# The owlchain coding style guide

## D Style

The D Style is a set of style conventions for writing D programs. The D Style is not enforced by the compiler. It is purely cosmetic and a matter of choice. Adhering to the D Style, however, will make it easier for others to work with your code and easier for you to work with others' code. The D Style can form the starting point for a project style guide customized for your project team.

Submissions to Phobos and other official D source code will follow these guidelines.

### Whitespace

- One statement per line.
- Use spaces instead of hardware tabs.
- Each indentation level will be four columns.

### Naming Conventions

##### General

Unless listed otherwise below, names should be camelCased (this includes all variables). So, names formed by joining multiple words have each word other than the first word capitalized. Also, names do not begin with an underscore ‘_’ unless they are private.

```D
int myFunc();
string myLocalVar;
```

##### Modules

Module and package names should be all lowercase, and only contain the characters [a..z][0..9][_]. This avoids problems when dealing with case-insensitive file systems.

```D
import std.algorithm;
```

##### Classes, Interfaces, Structs, Unions, Enums, Non-Eponymous Templates
The names of user-defined types should be PascalCased, which is the same as camelCased except that the first letter is uppercase.

```D
class Foo;
struct FooAndBar;
```

##### Eponymous Templates

Templates which have the same name as a symbol within that template (and instantiations of that template are therefore replaced with that symbol) should be capitalized in the same way that that inner symbol would be capitalized if it weren't in a template - e.g. types should be PascalCased and values should be camelCased.

```D
template GetSomeType(T) { alias GetSomeType = T; }
template isSomeType(T) { enum isSomeType = is(T == SomeType); }
template MyType(T) { struct MyType { ... } }
template map(fun...) { auto map(Range r) { ... } }
```

##### Functions

Function names should be camelCased, so their first letter is lowercase. This includes properties and member functions.

```D
int done();
int doneProcessing();
```

##### Constants

The names of constants should be camelCased just like normal variables.

```D
enum secondsPerMinute = 60;
immutable hexDigits = "0123456789ABCDEF";
```

##### Enum members

The members of enums should be camelCased, so their first letter is lowercase.

```D
enum Direction { bwd, fwd, both }
enum OpenRight { no, yes }
```

##### Keywords

If a name would conflict with a keyword, and it is desirable to use the keyword rather than pick a different name, a single underscore ‘_’ should be appended to it. Names should not be capitalized differently in order to avoid conflicting with keywords.

```D
enum Attribute { nothrow_, pure_, safe }
```

##### Acronyms

When acronyms are used in symbol names, all letters in the acronym should have the same case. So, if the first letter in the acronym is lowercase, then all of the letters in the acronym are lowercase, and if the first letter in the acronym is uppercase, then all of the letters in the acronym are uppercase.

```D
class UTFException;
ubyte asciiChar;
```

### Type Aliases

The D programming languages offers two functionally equivalent syntaxes for type aliases, but ...

```D
alias size_t = uint;
```

... is preferred over ...

```D
alias uint size_t;
```

... because ...

- It follows the already familiar assignment syntax instead of the inverted typedef syntax from C
- In verbose declarations, it is easier to see what is being declared

```D
alias important = someTemplateDetail!(withParameters, andValues);
alias Callback = ReturnType function(Arg1, Arg2) pure nothrow;
```

vs.

```D
alias someTemplateDetail!(withParameters, andValues) important;
alias ReturnType function(Arg1, Arg2) pure nothrow Callback;
```

Meaningless type aliases like ...

```D
alias VOID = void;
alias INT = int;
alias pint = int*;
```
... should be avoided.

### Declaration Style

Since the declarations are left-associative, left justify them:

```D
int[] x, y; // makes it clear that x and y are the same type
int** p, q; // makes it clear that p and q are the same type
```

to emphasize their relationship. Do not use the C style:

```D
int []x, y; // confusing since y is also an int[]
int **p, q; // confusing since q is also an int**
```

### Operator Overloading

Operator overloading is a powerful tool to extend the basic types supported by the language. But being powerful, it has great potential for creating obfuscated code. In particular, the existing D operators have conventional meanings, such as ‘+’ means ‘add’ and ‘<<’ means ‘shift left’. Overloading operator ‘+’ with a meaning different from ‘add’ is arbitrarily confusing and should be avoided.

### Hungarian Notation

Using hungarian notation to denote the type of a variable is a bad idea. However, using notation to denote the purpose of a variable (that cannot be expressed by its type) is often a good practice.

### Properties

Functions should be property functions whenever appropriate. In particular, getters and setters should generally be avoided in favor of property functions. And in general, whereas functions should be verbs, properties should be nouns, just like if they were member variables. Getter properties should not alter state.

### Documentation

All public declarations will be documented in Ddoc format and should have at least Params and Returns sections.

### Unit Tests

As much as practical, all functions will be exercised by unit tests using unittest blocks immediately following the function to be tested. Every path of code should be executed at least once, verified by the code coverage analyzer.

## Additional Requirements for Phobos

In general, this guide does not try to recommend or require that code conform to any particular formatting guidelines. The small section on whitespace at the top contains its only formatting guidelines. However, for Phobos and other official D source code, there are additional requirements:

- Braces should be on their own line. There are a few exceptions to this (such as when declaring lambda functions), but with any normal function block or type definition, the braces should be on their own line.

```D
void func(int param)
{
    if (param < 0)
    {
        ...
    }
    else
    {
        ...
    }
}
```

- Lines have a soft limit of 80 characters and a hard limit of 120 characters. This means that most lines of code should be no longer than 80 characters long but that they can exceed 80 characters when appropriate. However, they can never exceed 120 characters.
- Put a space after for, foreach, if, and while:

```D
for (…) { … }
foreach (…) { … }
if (x) { … }
static if (x) { … }
while (…) { … }
do { … } while (…);
```

- Chains containing else if (…) or else static if (…) should set the keywords on the same line:

```D
if (…)
{
    …
}
else if (…)
{
    …
}
```

- unittest blocks should be avoided in templates. They will generate a new unittest for each instance, hence tests should be put outside of the template.

### Imports

- Local, selective imports should be preferred over global imports
- Selective imports should have a space before and after the colon (:) like import std.range : zip

### Return type

- The return type should be stated explicitly wherever possible, as it makes the documentation and source code easier to read.
- Function-nested structs (aka Voldemort types) should be preferred over public structs.

### Attributes

- Non-templated functions should be annotated with matching attributes (@nogc, @safe, pure, nothrow).
- Templated functions should not be annotated with attributes as the compiler can infer them.
- Every unittest should be annotated (e.g. pure nothrow @nogc @safe unittest { ... }) to ensure the existence of attributes on the templated function.

Constraints on declarations should have the same indentation level as their declaration:

```D
void foo(R)
if (R == 1)
```

We are not necessarily recommending that all code follow these rules. They're likely to be controversial in any discussion on coding standards. However, they are required in submissions to Phobos and other official D source code.