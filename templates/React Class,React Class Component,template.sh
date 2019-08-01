if [[ "$#" -lt 1 ]]; then
  echo "Need file name"
  return 1
fi

cp "${${(%):-%x}:a:h}/files/React.Class.jsx" "${1}.jsx"

sed -i "s/@1@/${1}/g" "${1}.jsx"

filename_created="${1}.jsx"