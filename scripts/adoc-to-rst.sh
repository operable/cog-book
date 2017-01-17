#!/bin/bash

source_path="${1}"

section_files=`find ${source_path} -name "*.adoc" | sort | grep -v introducing | grep text.adoc`
converted_files=""

function convert_file {
  asciidoc --backend docbook45 -o - ${1} | pandoc -f docbook -t rst > ${2}
  echo "${1} --> ${2}"
}

for section in ${section_files}
do
  rst_name=`basename $(dirname ${section})`
  rst_path="source/sections/${rst_name}.rst"
  convert_file ${section} ${rst_path}
  converted_files="${converted_files} ${rst_path}"
done

mkdir -p source/appendices

appendices=`find ${source_path} -name "*.adoc" | sort | grep appendices`

for appendix in ${appendices}
do
  rst_name=`basename ${appendix} | sed -e 's/\.adoc$/.rst/'`
  rst_path="source/appendices/${rst_name}"
  convert_file ${appendix} ${rst_path}
  converted_files="${converted_files} ${rst_path}"
done

mkdir -p source/references

references=`find ${source_path} -name "*.adoc" | grep reference | sort`
for ref in ${references}
do
  rst_name=`basename ${ref} | sed -e 's/\.adoc$/.rst/'`
  rst_path="source/references/${rst_name}"
  convert_file ${ref} ${rst_path}
  converted_files="${converted_files} ${rst_path}"
done

echo Cleaning up image links in converted files

# Cleans up funky asciidoc image refs with too many colons
sed --in-place -e 's/image:: :images/image:: ..\/images/g' ${converted_files}

# Prepends ../ to image links
sed --in-place -e 's/image:: images/image:: ..\/images/g' ${converted_files}

# Prepends ../ to figure links
sed --in-place -e 's/figure:: images/figure:: ..\/images/g' ${converted_files}

# Fixes borked path separators
sed --in-place -e 's/images\\/images\//g' ${converted_files}

cp -R ${source_path}/../images/* source/images
echo "All images updated"
