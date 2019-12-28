#!/usr/bin/env zsh
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

function template(){
  if [[ "$#" -lt 1 ]]; then
    echo "Usage: template template args"
    return 1
  fi

  filename_orig="$(echo ${0:h}/templates/${1},*,*,*([1]))"
  shift
  template_dir="$(dirname ${filename_orig})"
  template_name="$(basename ${filename_orig} | awk -F',' '{print $1}')"
  args_length="$(basename ${filename_orig} | awk -F',' '{print $3}')"
  filename="$(basename ${filename_orig} | awk -F',' '{print $4}')"

  if [[ "$#" -lt $args_length ]]; then
    echo "Need ${args_length} arguments for template"
    if [[ -f "${template_dir}/${template_name},help.txt" ]]; then
      cat "${template_dir}/${template_name},help.txt"
    fi
    return 1
  fi

  for i in `seq 1 ${args_length}`; do
    filename="${filename/_${i}_/${(P)i}}"
  done

  if [[ -f "${template_dir}/${template_name},pre.sh" ]]; then
    bash "${template_dir}/${template_name},pre.sh" $filename $@
  fi

  cp "${filename_orig}" "${filename}"

  for i in `seq 1 ${args_length}`; do
    sed -i "s/__${i}__/${(P)i}/g" "${filename}"
  done

  if [[ -f "${template_dir}/${template_name},post.sh" ]]; then
    bash "${template_dir}/${template_name},post.sh" $filename $@
  fi

  echo "${c[cyan]}Created: ${c[yellow]}${filename}"

}

_templates_list=()
for ___template in ${0:h}/templates/*,*,*,*; do
  name="$(basename $___template | awk -F',' '{print $1}' )"
  description="$(basename $___template | awk -F',' '{print $2}' )"
  arg_length="$(basename $___template | awk -F',' '{print $3}' )"
  _templates_list+="${name}:${description}, ${arg_length} arg(s)"
done

_template(){
  _arguments \
  '*:: :->subcmds' && return 0

  if (( CURRENT == 1 )); then
    _describe -t commands 'Templates' _templates_list
    return
  fi
}

compdef _template template
