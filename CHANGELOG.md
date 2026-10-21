# Changelog

## [1.6.0](https://github.com/Jared-Prime/kit/compare/v1.5.3...v1.6.0) (2026-10-21)


### Features

* **skills:** add commit-message skill ([#69](https://github.com/Jared-Prime/kit/issues/69)) ([c63d532](https://github.com/Jared-Prime/kit/commit/c63d5326812a4bb6680b70fa3cf26bcac180d50e))


### Bug Fixes

* **actions:** include commit sha ([#63](https://github.com/Jared-Prime/kit/issues/63)) ([80f6b7d](https://github.com/Jared-Prime/kit/commit/80f6b7d1d29069ad03fbab05a0eabc922a0e0d28))
* **dev:** use strict semvar in the generated sandbox set yaml ([#64](https://github.com/Jared-Prime/kit/issues/64)) ([cce84fc](https://github.com/Jared-Prime/kit/commit/cce84fcc04d24966889f64e16370f658f2204494))
* distrust the compromised emSign ECC Root CA - G3 and patch pip/certifi ([#73](https://github.com/Jared-Prime/kit/issues/73)) ([d22d26e](https://github.com/Jared-Prime/kit/commit/d22d26ec19a3e52ff849fa36de5d66bc9c152a22))
* **openai:** make codex's sandboxed shell see the mixin toolchains ([#72](https://github.com/Jared-Prime/kit/issues/72)) ([89d1094](https://github.com/Jared-Prime/kit/commit/89d1094168caa1d0a60f007cb4a91bcf3ac82fec))
* **openai:** use Alpine ripgrep and allow working directory edits ([#66](https://github.com/Jared-Prime/kit/issues/66)) ([3662afa](https://github.com/Jared-Prime/kit/commit/3662afae14cd1e0d185eab7c98381f61fc39f45a))
* **proxy:** trust the egress proxy's MITM CA in agent kits ([#67](https://github.com/Jared-Prime/kit/issues/67)) ([3eaa0d9](https://github.com/Jared-Prime/kit/commit/3eaa0d92510a5e4f9d4aaadc2505b2c3a9ea635c))
* **proxy:** trust the egress proxy's MITM CA without writing system cert stores ([#70](https://github.com/Jared-Prime/kit/issues/70)) ([3509c0c](https://github.com/Jared-Prime/kit/commit/3509c0c153303d93045ba73f2d81a8abb0fb26b5))
* python uv installation ([#60](https://github.com/Jared-Prime/kit/issues/60)) ([29d3bdf](https://github.com/Jared-Prime/kit/commit/29d3bdf59ac1fec1f2a082fd6d0d908784a8b75c))
* use valid semver for dev kits ([#62](https://github.com/Jared-Prime/kit/issues/62)) ([c4bb38f](https://github.com/Jared-Prime/kit/commit/c4bb38f8455f4990fff49bd72995fa6d0e76cc69))
* wire agent context into each workload's entrypoint ([#65](https://github.com/Jared-Prime/kit/issues/65)) ([ec62272](https://github.com/Jared-Prime/kit/commit/ec622722d6faa11731a6aaf43efc9a62809a35be))


### Reverts

* do not patch the certificate directly ([#74](https://github.com/Jared-Prime/kit/issues/74)) ([e1ba90f](https://github.com/Jared-Prime/kit/commit/e1ba90fd2437ce66262359f22d818233b414af82))

## [1.5.3](https://github.com/Jared-Prime/kit/compare/v1.5.2...v1.5.3) (2026-10-20)


### Bug Fixes

* OCI artifacts must not conflict with official release names ([#58](https://github.com/Jared-Prime/kit/issues/58)) ([2cc6a06](https://github.com/Jared-Prime/kit/commit/2cc6a06b904e89eb4cb7893acf08f6b321672b9d))

## [1.5.2](https://github.com/Jared-Prime/kit/compare/v1.5.1...v1.5.2) (2026-10-20)


### Bug Fixes

* rebundle harness and publish OCI ([#56](https://github.com/Jared-Prime/kit/issues/56)) ([f7b9d94](https://github.com/Jared-Prime/kit/commit/f7b9d94fffb43f15d6609c7546b1039acaca7eca))

## [1.5.1](https://github.com/Jared-Prime/kit/compare/v1.5.0...v1.5.1) (2026-10-20)


### Bug Fixes

* decouple workloads from typescript kit ([#54](https://github.com/Jared-Prime/kit/issues/54)) ([0dc6990](https://github.com/Jared-Prime/kit/commit/0dc69907bb1fa54cc45bf422fee7d3a263c6fd95))

## [1.5.0](https://github.com/Jared-Prime/kit/compare/v1.4.2...v1.5.0) (2026-10-20)


### Features

* prepare harness-specific sandbox sets ([#51](https://github.com/Jared-Prime/kit/issues/51)) ([5d2791f](https://github.com/Jared-Prime/kit/commit/5d2791f3f76f2bef63f8152c8f1874fbd28c0f66))
* **python:** create a python mixin ([#49](https://github.com/Jared-Prime/kit/issues/49)) ([dfe8e41](https://github.com/Jared-Prime/kit/commit/dfe8e41a6fdf2b7f0166bfc6d93034d2ab8915c2))

## [1.4.2](https://github.com/Jared-Prime/kit/compare/v1.4.1...v1.4.2) (2026-10-19)


### Bug Fixes

* **typescript:** must be a workload to use effectively as a base ([#46](https://github.com/Jared-Prime/kit/issues/46)) ([c24064e](https://github.com/Jared-Prime/kit/commit/c24064ecc5070f3ef9060afffd0b7eca60340771))

## [1.4.1](https://github.com/Jared-Prime/kit/compare/v1.4.0...v1.4.1) (2026-10-19)


### Bug Fixes

* **github:** skip over intermediate typescript layer ([#44](https://github.com/Jared-Prime/kit/issues/44)) ([8b0c17a](https://github.com/Jared-Prime/kit/commit/8b0c17a4ac87cd52a9999886fe7b6b1c8332a237))

## [1.4.0](https://github.com/Jared-Prime/kit/compare/v1.3.0...v1.4.0) (2026-10-19)


### Features

* **anomaly:** create opencode harness workflow ([#36](https://github.com/Jared-Prime/kit/issues/36)) ([410932f](https://github.com/Jared-Prime/kit/commit/410932f563c1034c4acef7a27a3155cb9bff6e08))


### Bug Fixes

* conform to gid 1000 and chown corepack ([#42](https://github.com/Jared-Prime/kit/issues/42)) ([a939250](https://github.com/Jared-Prime/kit/commit/a939250189cbbae2a80abb1e76df6d891149a1de))

## [1.3.0](https://github.com/Jared-Prime/kit/compare/v1.2.0...v1.3.0) (2026-10-16)


### Features

* build typescript kit ([#34](https://github.com/Jared-Prime/kit/issues/34)) ([f38dd6d](https://github.com/Jared-Prime/kit/commit/f38dd6d026e2f8ec46d7899dcf8b23460b6b9359))

## [1.2.0](https://github.com/Jared-Prime/kit/compare/v1.1.2...v1.2.0) (2026-10-15)


### Features

* **openai:** switch openai to use device auth login ([#33](https://github.com/Jared-Prime/kit/issues/33)) ([250981e](https://github.com/Jared-Prime/kit/commit/250981eea2cd01a70daf5e8a66a0557100c2d5e9))
* **sonnet:** prepare sonnet workflow kit ([#31](https://github.com/Jared-Prime/kit/issues/31)) ([bd76729](https://github.com/Jared-Prime/kit/commit/bd767291cc0c143c6d4be2df5840e6d54bdacdbc))

## [1.1.2](https://github.com/Jared-Prime/kit/compare/v1.1.1...v1.1.2) (2026-10-15)


### Bug Fixes

* **github:** replace nix ([#23](https://github.com/Jared-Prime/kit/issues/23)) ([4669f01](https://github.com/Jared-Prime/kit/commit/4669f01ed5426d484af453a12f545d69d249b7df))

## [1.1.1](https://github.com/Jared-Prime/kit/compare/v1.1.0...v1.1.1) (2026-10-15)


### Bug Fixes

* **oci:** better oci setup ([#21](https://github.com/Jared-Prime/kit/issues/21)) ([b4b97b6](https://github.com/Jared-Prime/kit/commit/b4b97b6bdf1f57a59efd61ad4311be9e4e731efa))

## [1.1.0](https://github.com/Jared-Prime/kit/compare/v1.0.0...v1.1.0) (2026-10-15)


### Features

* **ci:** build OCI images ([#17](https://github.com/Jared-Prime/kit/issues/17)) ([7ae2f50](https://github.com/Jared-Prime/kit/commit/7ae2f50c5231dba3ce656b5f48d134a7ff5c02b4))

## 1.0.0 (2026-10-14)


### Features

* **github:** add GitHub CLI read-only mixin ([1a35737](https://github.com/Jared-Prime/kit/commit/1a3573790081d711757a601f4b9edb849b60e805))
* **skills:** create a skills collection ([#6](https://github.com/Jared-Prime/kit/issues/6)) ([6750946](https://github.com/Jared-Prime/kit/commit/675094612f3656fb350c85fd58b5af74f29b8e57))
* **skills:** inspect pre-selected PR and other fixes ([#11](https://github.com/Jared-Prime/kit/issues/11)) ([e98b732](https://github.com/Jared-Prime/kit/commit/e98b732ee9e60d2e8ece16700f12eedff21ec1ca))
* **sol:** add codex workflow ([#1](https://github.com/Jared-Prime/kit/issues/1)) ([a334b4f](https://github.com/Jared-Prime/kit/commit/a334b4fb3278895921e0b0d8d7c26a8db8f01126))


### Bug Fixes

* **actions:** use pinned SHA for action references ([#12](https://github.com/Jared-Prime/kit/issues/12)) ([e93a889](https://github.com/Jared-Prime/kit/commit/e93a889079c74507fc91ecf3e1a1e3c202caa5fd))
* **skills:** allow capability to load agent skill ([#9](https://github.com/Jared-Prime/kit/issues/9)) ([3ee785b](https://github.com/Jared-Prime/kit/commit/3ee785bb290cf1c39043150aa6644e0722e191b1))
