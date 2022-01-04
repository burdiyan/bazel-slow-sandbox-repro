## Introduction

This repository is a showcase for Bazel's slow sandbox on Darwin. See the [corresponding issue](https://github.com/bazelbuild/bazel/issues/8230#issuecomment-1005013584) for more details.

## Background

This is an attempt to demonstrate a Bazel build being almost 40 times slower within the sandbox compared to the local spawn strategy on macOS. It's quite unconventional use of Bazel, because targets are not very fine-grained, and it's not very hermetic because it reuses the build cache of the Go toolchain (by detecting the real `$HOME` from within the sandbox). Although it shouldn't affect the actual purpose of demonstrating the slow sandbox.

The code includes a vendored SQLite library (inside `third_party/sqlite`) so that we force the build to use CGO and compile some C code so that it could actually take enough time to demonstrate the issue.

Specs of the machine this was tested on:

```
MacBook Pro
16 GB RAM
2,6 GHz 6-Core Intel Core i7
MacOS BigSur 11.6.1
bazel 4.2.2
```

## How To Reproduce

1. Make sure Bazel and Go are installed.
2. Run `bazel build //:build`. It should take quite some time. Make sure the build was using `darwin-sandbox` strategy.
3. Do something to force the rebuild. The easiest for me is to edit `./BUILD.bazel` file, e.g. add an empty line in the `cmd` of the rule declaration.
4. Run `bazel build //:build` again and see how it takes almost the same amount of time as the first time.
5. Force the rebuild again. You can remove the empty line, or add some more. It doesn't matter, as long as you change the `cmd` string.
6. Run `bazel build //:build --spawn_strategy=local`. It could take almost the same amount of time as the first time. But the difference will be seen next.
7. Force the rebuild again.
8. Run `bazel build //:build --spawn_strategy=local`. This time the build should be way faster (almost instant on my machine).
9. Play around with forcing rebuilds and using local and sandbox strategies as you wish. You should be able to see a clear difference.

## Preliminary Conclusions

Bazel sandbox slowness was often attributed to the fact that Bazel creates a lot of symlinks and it often can be slow. But this example doesn't have lots of files, assumes no parallelism, and overall is very simple.

I assume that the cause of the slowdown is `sandbox-exec` (built-in sandboxing tool for macOS, although deprecated).

I would personally use `local` strategy if only it would provide input files isolation. That's the main thing I'm interested in the sandbox anyway, and I assume many people do too. I think it would be great if Bazel had a strategy similar to local, but that would offer a lightweight "sandbox" by building the symlink forest of the input files.
