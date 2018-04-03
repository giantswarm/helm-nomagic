#!/bin/bash

set -eu

charts_directory='./charts'
values_directory='./values'
manifests_directory='./manifests'

usage() {
cat << EOF
This allows storing and rendering Helm Charts in a deterministic way. No Tiller required.
Available Commands:
  fetch     Fetches a chart and stores it in $charts_directory.
  render    Renders a chart from $charts_directory with values from $values_directory. Result is stored in $manifests_directory.
  apply     FIXME to be done
EOF
}


fetch() {
  local chart_url=$1

  [[ $chart_url =~ (.*)\/(.*)-(.*) ]]
  chart_repo="${BASH_REMATCH[1]}"
  chart_name="${BASH_REMATCH[2]}"
  chart_version="${BASH_REMATCH[3]}"

  if [ -z "$2" ]; then
    local release_name=$chart_name
  else
    local release_name=$2
  fi

  echo "Writing chart to $charts_directory/$chart_name"
  helm fetch \
    --repo "$chart_repo" \
    --untar \
    --untardir "$charts_directory" \
    --version "$chart_version" \
      "$chart_name"

  mkdir -p $values_directory
  if [ ! -f "$values_directory/$release_name.yaml" ] ; then

    echo "Creating default values file at $values_directory/$release_name.yaml"
    cp "$charts_directory/$chart_name/values.yaml" \
      "$values_directory/$release_name.yaml"

    echo -e "\nx-nomagic_chart_url: $chart_url" >> "$values_directory/$release_name.yaml"
  fi
}


render() {
  local release_name=$1
  local chart_url=$(cat "$values_directory/$release_name.yaml" | grep -F "x-nomagic_chart_url: " | awk -F " " '{print $NF}')

  [[ $chart_url =~ (.*)\/(.*)-(.*) ]]
  chart_repo="${BASH_REMATCH[1]}"
  chart_name="${BASH_REMATCH[2]}"
  chart_version="${BASH_REMATCH[3]}"

  echo -e "Rendering chart: \"$chart_repo/$chart_name-$chart_version\"\nwith values from: $values_directory/$release_name.yaml"
  mkdir -p "$manifests_directory/$release_name"
  helm template \
    --name "$release_name" \
    --values "$values_directory/$release_name.yaml" \
    --output-dir "$manifests_directory" \
      "$charts_directory/$release_name"

  # reorder directory structure
  mv "$manifests_directory/$release_name/templates/." "$manifests_directory/$release_name"
  rmdir "$manifests_directory/$release_name/templates"

}


if [[ $# < 1 ]]; then
  usage
  exit 1
fi

case "${1:-"help"}" in
  "fetch"):
    fetch $2
    ;;
  "init"):
    init $2 $3
    ;;
  "help")
    usage
    ;;
  "--help")
    usage
    ;;
  "-h")
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac

exit 0
