---

    title: "brew Could Not Resolve HEAD to a Revision"
    date: 2021-05-15
    tags: ["linux"]

---
# 背景
brew安装任何软件提示找不到
```log
~ % brew install hugo
fatal: Could not resolve HEAD to a revision
==> Searching for similarly named formulae...
Error: No similarly named formulae found.
Error: No available formula or cask with the name "hugo".
==> Searching for a previously deleted formula (in the last month)...
Error: No previously deleted formula found.
==> Searching taps on GitHub...
Error: No formulae found in taps.
```

brew update报错
```log
fatal: Could not resolve HEAD to a revision
```

# 解决方案
```shell
git -C $(brew --repository homebrew/core) checkout master
```

> 参考[stackoverflow](https://stackoverflow.com/questions/65605282/trying-to-install-hugo-via-homebrew-could-not-resolve-head-to-a-revision)
