#!/bin/bash

usage() {
  echo "Usage: ${0} [-p|--Path] [-o|--OutPath]" 1>&2
  exit 1 
}
while [[ $# -gt 0 ]];do
  key=${1}
  case ${key} in
    -p|--Path)
      PATH=${2}
      shift 2
      ;;
    -o|--OutPath)
      OUTPATH=${2}
      shift 2
      ;;
    *)
      usage
      shift
      ;;
  esac
done
