# Bash completion for run_docker_image.sh.

_run_docker_image_list_images() {
  command -v docker >/dev/null 2>&1 || return 0

  docker image ls --format '{{.Repository}}:{{.Tag}}' 2>/dev/null |
    awk '$0 !~ /<none>/ { print }'
}

_run_docker_image_list_containers() {
  command -v docker >/dev/null 2>&1 || return 0

  docker ps -a --format '{{.Names}}' 2>/dev/null
}

_run_docker_image_positional_count() {
  local i=""
  local word=""
  local count=0
  local skip_next=0

  for ((i = 1; i < COMP_CWORD; i++)); do
    word="${COMP_WORDS[i]}"

    if ((skip_next)); then
      skip_next=0
      continue
    fi

    case "$word" in
      -n|--name|-w|--workspace|-v|--volume|--shm-size|--network|--entrypoint|--proxy)
        skip_next=1
        ;;
      --*)
        ;;
      -*)
        ;;
      *)
        ((count++))
        ;;
    esac
  done

  printf '%s\n' "$count"
}

_run_docker_image_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD - 1]}"
  local options="-n --name -w --workspace -v --volume --shm-size --network --entrypoint --proxy --no-gpu --no-privileged --replace --dry-run -h --help"
  local positional_count=""

  COMPREPLY=()

  case "$prev" in
    -n|--name)
      COMPREPLY=($(compgen -W "$(_run_docker_image_list_containers)" -- "$cur"))
      return 0
      ;;
    -w|--workspace|-v|--volume)
      COMPREPLY=($(compgen -d -- "$cur"))
      return 0
      ;;
    --shm-size)
      COMPREPLY=($(compgen -W "1g 2g 4g 8g 16g 32g" -- "$cur"))
      return 0
      ;;
    --network)
      COMPREPLY=($(compgen -W "host bridge none" -- "$cur"))
      return 0
      ;;
    --entrypoint)
      COMPREPLY=($(compgen -W "bash sh zsh" -- "$cur"))
      return 0
      ;;
    --proxy)
      COMPREPLY=($(compgen -W "7897 auto none 7890 10809 127.0.0.1:7897 localhost:7897" -- "$cur"))
      return 0
      ;;
  esac

  if [[ "$cur" == -* ]]; then
    COMPREPLY=($(compgen -W "$options" -- "$cur"))
    return 0
  fi

  positional_count="$(_run_docker_image_positional_count)"

  case "$positional_count" in
    0)
      COMPREPLY=($(compgen -W "$(_run_docker_image_list_images)" -- "$cur"))
      ;;
    1)
      COMPREPLY=($(compgen -W "$(_run_docker_image_list_containers)" -- "$cur"))
      ;;
  esac
}

complete -F _run_docker_image_complete run_docker_image.sh
