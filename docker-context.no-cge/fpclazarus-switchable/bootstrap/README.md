# Minimal FPC binaries to "bootstrap" (compile next FPC versions)

To compile FPC, you to start from last stable FPC (before the version you want to build). See

- https://wiki.freepascal.org/Debugging_Compiler
- https://www.math.uni-leipzig.de/pool/tuts/FreePascal/prog/node20.html

Luckily (esp. since we want to conserve disk space usage in this Docker image), this can be just the compiler binary (`ppcXX` is sufficient), nothing else (no need for RTL and other files). As we start this on Linux/x86_64, we need `ppcx64`. We just copy it from existing FPC installation with the proper version.
