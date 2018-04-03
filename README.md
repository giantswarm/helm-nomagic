# Helm Plugin "No Magic"

- see blog post for background


## Installation

```bash
$ helm plugin install https://github.com/giantswarm/helm-nomagic
```

## Usage

FIXME fetch instead of init?
```
helm nomagic init "$chart_repo/name:version"
```
optional $release_name

```
helm nomagic render $release_name
```

```
helm nomagic apply $release_name
```
