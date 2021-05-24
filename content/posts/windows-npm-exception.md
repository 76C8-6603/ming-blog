---
title: "Windows CMD 错误pngquant failed to build, make sure that libpng-dev is installed"
date: 2020-10-18
tags: ["windows","nodejs"]

---

##### 背景：windows npm install失败
##### 错误信息：`pngquant failed to build, make sure that libpng-dev is installed`
##### 解决方案
`npm install --global windows-build-tools` 如果仍然失败，参考[github回答](https://github.com/imagemin/imagemin-pngquant/issues/46#issuecomment-515808859)
