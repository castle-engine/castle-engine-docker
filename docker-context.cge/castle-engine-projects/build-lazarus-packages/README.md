Cause rebuild of CGE Lazarus packages.

This makes them registered and ready to use, so users (and CI jobs) of this Docker image
an just do "lazbuild xxx.lpi"
and xxx.lpi can use `castle_engine_window` or `castle_engine_lcl` and it will just compile.

Note that for actual applications, you shall never use `castle_engine_window` and `castle_engine_lcl`
in one application, as `castle_engine_window` and LCL conflict, as they both try to talk
with window manager.
