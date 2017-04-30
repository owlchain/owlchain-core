libInputVisitor - ChangeLog
===========================

(Dates below are YYYY/MM/DD)

v1.2.2 - 2016/09/19
-------------------
- **Fixed:** For certain element types (such as [TaggedAlgebraic](https://github.com/s-ludwig/taggedalgebraic)), got a compile error: "Error: field _front must be initialized in constructor"

v1.2.1 - 2016/09/19
-------------------
- **New:**: Added optional param `size_t stackSize` to constructor.
- **Fixed:** [#1](https://github.com/Abscissa/libInputVisitor/issues/1): Workaround for: Call to Fiber crashes an application. [Windows x86_64]

v1.2.0 - 2015/03/17
-------------------
- **Breaking change:** *Don't* take the original object as a ref parameter. That was a bad idea - it made it too easy to [accidentally escape a stack reference](https://github.com/Abscissa/SDLang-D/issues/16). Just don't forget that structs are pass-by-value, and you'll be fine. If you're using InputVisitor on a struct, and you need to access the copy of struct that's *actually* being iterated, remember that it's available as InputVisitor's ```.obj``` member.

v1.1.0 - 2014/09/10
-------------------
- Take the original object as a ref parameter.

v1.0.2 - 2014/09/10
-------------------
- Fixed [dub.json](https://github.com/Abscissa/libInputVisitor/blob/master/dub.json) to work in [DUB repository](http://code.dlang.org).

v1.0.1 - 2014/09/10
-------------------
- Misc documentation improvements

v1.0.0 - 2014/09/10
-------------------
- Initial GitHub/[DUB](http://code.dlang.org) release

(not versioned) - 2012/05/01
-------------------
- Initial release [over here](http://semitwist.com/articles/article/view/combine-coroutines-and-input-ranges-for-dead-simple-d-iteration)
