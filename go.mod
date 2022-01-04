module github.com/burdiyan/bazel-slow-sandbox-repro

go 1.17

require crawshaw.io/sqlite v0.0.0

replace crawshaw.io/sqlite => ./third_party/sqlite
