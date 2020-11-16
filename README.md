Docker container with Castle Game Engine, FPC cross-compilers and more. Based on Debian stable.

See [CGE Docker usage docs](https://github.com/castle-engine/castle-engine/wiki/Docker). This is also used by used by [Automatic Cloud Builds (Jenkins) for Castle Game Engine projects](https://github.com/castle-engine/castle-engine/wiki/Cloud-Builds-(Jenkins)).

Includes various prerequisites of Castle Game Engine:

- Multiple versions of [FPC (Free Pascal Compiler)](http://freepascal.org/), including stable FPC, and latest FPC trunk. All [FPC versions supported by Castle Game Engine](https://castle-engine.io/supported_compilers.php) should be available.

- Multiple Lazarus versions.

- The current FPC/Lazarus environment can be used by calling `. /usr/local/fpclazarus/bin/setup.sh 3.0.4` in shell. This is used in each particular Jenkins job, this way each Jenkins job can use different FPC/Lazarus version. This is useful for testing that your code (and CGE itself) works with different FPC/Lazarus versions.

- Android SDK and NDK, for building Android applications using Castle Game Engine.

- Tools to generate [compressed textures](https://castle-engine.io/creating_data_auto_generated_textures.php): NVidia Texture Tools, PowerVR Texture Tools, AMD Compressonator.

- Latest version of [PasDoc](https://github.com/pasdoc/pasdoc/wiki) from GitHub.

Note that this Docker image is not, and doesn't try to be, "slim". If you're looking for a small Docker image with FPC, this isn't it. This Docker image is packed with a lot of sofware, to have a full-featured environment for jobs inside [Automatic Cloud Builds for Castle Game Engine projects](https://jenkins.castle-engine.io/).

Author: Michalis Kamburelis

License: GPL >= 2.
