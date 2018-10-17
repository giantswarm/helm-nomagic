# Helm Plugin "No Magic"

- see [blog post] for background

[blog post]: https://blog.giantswarm.io/what-you-yaml-is-what-you-get/

## Installation

```bash
$ helm plugin install https://github.com/giantswarm/helm-nomagic
```


## Usage

```
helm nomagic fetch "$chart_repo/name#version" $release_name
```
`$release_name` is optional

```
helm nomagic render $release_name
```

TBD:
```
helm nomagic apply $release_name
```
