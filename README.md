# `cli-docs.el` --- 一些 CLI 命令的文档

[![Build Status](https://travis-ci.org/xuchunyang/cli-docs.el.svg?branch=master)](https://travis-ci.org/xuchunyang/cli-docs.el)

数据来自于 [jaywcjlove/linux-command: Linux命令大全搜索工具，内容包含Linux命令手册、详解、学习、搜集。https://git.io/linux](https://github.com/jaywcjlove/linux-command)

## 依赖

- Emacs 25 (with HTTPS support, e.g., `M-x eww https://example.com/` must work)

## 使用

### `M-x cli-docs grep`

查看 `grep(1)` 的文档，使用 Markdown Mode 渲染。

### `M-x cli-docs-helm`

Helm 版本的 `M-x cli-docs`。

## 定制

### `cli-docs-directory`

数据保存在哪里？如果该目录不存在，`cli-docs.el` 会自动创建。

## 心愿单

- [x] Helm 界面
- [ ] 更新 Cache ([If-Modified-Since - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since))
