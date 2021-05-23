Cause rebuild of CGE Lazarus packages.

This makes them registered and ready to use, so users (and Jenkins jobs) of this Docker image
an just do "lazbuild xxx.lpi"
and xxx.lpi can use `castle_window` or `castle_components` and it will just compile.

Note that for actual applications, you shall never use `castle_window` and `castle_components`
in one application, as `castle_window` and LCL conflict, as they both try to talk
with window manager.
