# GMQCC
_An Improved Quake C Compiler_

> For an enduring period of time, the options for a decent compiler for the QuakeC programming language were confined to a specific compiler known as QCC. Attempts were made to extend and improve upon the design of QCC, but many foresaw the consequences of building on a broken foundation. The solution was obvious, a new compiler; one born from the NIH realm of sarcastic wit. We welcome you. You won't find a better QuakeC compiler.

---

## Key Features

*   **Modern Compiler Design**
    GMQCC employs several modern strategies for lexing, parsing, understanding, and generating executable bytecode. These strategies are unlike anything present in any existing QuakeC compiler.

*   **Optimal & Correct Code**
    With its modern architecture, GMQCC is capable of generating correct, optimal bytecode while helping prevent you from writing broken code in the first place.

*   **Backwards Compatibility**
    GMQCC is committed to maintaining backwards compatibility with your existing QuakeC code. To do this, we support the oddities and otherwise broken or incorrect behavior of existing compilers such as QCC and FTEQCC, so that you can rest easy knowing your code will work.

## Documentation

**Full documentation is available at: [https://graphitemaster.github.io/gmqcc/index.html](https://graphitemaster.github.io/gmqcc/index.html)**

## Building from Source

If you're interested in using the latest development version, you can obtain and build the repository as follows:

```bash
# Clone the repository
git clone git://github.com/graphitemaster/gmqcc.git

# Navigate into the project directory
cd gmqcc

# Build the compiler
make
```

## About QuakeC

QuakeC is the scripting language created in 1996 by John Carmack of id Software to program the logic for the video game *Quake*. You can learn more about its history and design on [Wikipedia](https://en.wikipedia.org/wiki/QuakeC).
