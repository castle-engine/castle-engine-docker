# Docker images with Castle Game Engine, FPC and more

Scripts to make Docker images with [Castle Game Engine](https://castle-engine.io/), [FPC](https://www.freepascal.org/) cross-compilers and more. Based on Debian stable.

See [CGE Docker usage docs](https://castle-engine.io/docker).

The images made by this are available on [Docker Hub](https://hub.docker.com/repository/docker/kambi/castle-engine-cloud-builds-tools/general).

These images include various prerequisites of Castle Game Engine:

- [FPC (Free Pascal Compiler)](http://freepascal.org/). Multiple versions, including last stable FPC (always most advised), and latest FPC trunk. All [FPC versions supported by Castle Game Engine](https://castle-engine.io/supported_compilers.php) should be available.

- Multiple Lazarus versions.

- Android SDK and NDK, for building Android applications using Castle Game Engine.

- Tools to generate [compressed textures](https://castle-engine.io/creating_data_auto_generated_textures.php): NVidia Texture Tools, PowerVR Texture Tools, AMD Compressonator.

- Latest version of [PasDoc](https://github.com/pasdoc/pasdoc/wiki) from GitHub.

Author: Michalis Kamburelis

License: GPL >= 2.
