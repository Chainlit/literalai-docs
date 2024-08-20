#!/bin/bash

pip3 install pydoc-markdown --break-system-packages

# ./run-docs.sh ../literal-docs/python-client/

# https://github.com/NiklasRosenstein/pydoc-markdown/blob/develop/src/pydoc_markdown/contrib/renderers/markdown.py#L52
# https://github.com/NiklasRosenstein/pydoc-markdown/blob/develop/src/pydoc_markdown/contrib/processors/filter.py#L31


SOURCE_DIR="../literalai-python"

# change the DOCS_DIR to output the generated files to a different directory
DOCS_DIR="python-client/api-reference"
CONFIG_FILE="pydoc-markdown.yaml"
BEAUTIFY=true


# same as above, but make the arguments switchable and add a --beautify flag
for i in "$@"
do
    case $i in
        -s=*|--source-dir=*)
        SOURCE_DIR="${i#*=}"
        shift # past argument=value
        ;;
        -b|--beautify)
        BEAUTIFY=true
        shift # past argument=value
        ;;
        -o=*|--output-dir=*)
        DOCS_DIR="${i#*=}"
        shift # past argument=value
        ;;
        -c=*|--config-file=*)
        CONFIG_FILE="${i#*=}"
        shift # past argument=value
        ;;
        *)
        # unknown option
        ;;
    esac
done


apiFiles=(
    "api.__init__"
    "client"
    "observability.message"
    "observability.step"
    "observability.thread"
    "evaluation.dataset"
    # "evaluation.dataset_item"
)

mkdir -p $DOCS_DIR


# read all the files in the api directory and generate the docs (read from the source directory)
for i in "${apiFiles[@]}"; do
    echo "Writing docs for $i in $DOCS_DIR/$i.mdx"
    
    # uncomment at your own risk
    # rm -f $DOCS_DIR/$i.*
    pydoc-markdown -I $SOURCE_DIR -m literalai.$i --no-render-toc "$CONFIG_FILE" > $DOCS_DIR/$i.mdx

    # remove the third line of the file
    sed "3d" $DOCS_DIR/$i.mdx > $DOCS_DIR/$i.tmp && mv $DOCS_DIR/$i.tmp $DOCS_DIR/$i.mdx


    if [ "$BEAUTIFY" = false ]; then
        continue
    fi

    echo "Beautifying $i.mdx"
    sed -r -E 's/- `([^`]+)` _([^_]+)_ - (.*)$/<ResponseField name="\1" type="\2">\3<\/ResponseField>/' $DOCS_DIR/$i.mdx > $DOCS_DIR/$i.tmp
    sed -r -E 's/- `([^`]+)` - (.*)$/<ResponseField name="\1">\2<\/ResponseField>/' $DOCS_DIR/$i.tmp > $DOCS_DIR/$i.mdx
    # delete the temporary files created for the sed beautification
    rm $DOCS_DIR/$i.tmp
done

# If the file is api.__init__, rename it to api.mdx after the loop
if [ -f "$DOCS_DIR/api.__init__.mdx" ]; then
    mv $DOCS_DIR/api.__init__.mdx $DOCS_DIR/api.mdx
    # change the api.__init__ to api in the file
    # sed -i 's/api.__init__/api/g' $DOCS_DIR/api.mdx
fi

# for each mdx file in the DOCS_DIR, keep only the last word (after the avant dernier point)
for file in $DOCS_DIR/*.mdx; do
    # get the last word of the file
    filename=$(basename $file)
    # get the last word of the filename
    last_word=$(echo $filename | awk -F. '{print $(NF-1)}')
    # rename the file to the last word
    mv $file $DOCS_DIR/$last_word.mdx
    
done

# for each file in the DOC_DIR, add its name without the extension to a files.txt file
for file in $DOCS_DIR/*.mdx; do
    echo $(basename $file .mdx) >> $DOCS_DIR/files.txt
done

# call the python script to add the files to the mint.json
python3 scripts/update_api_reference.py -py $DOCS_DIR/files.txt

# remove the files.txt file
rm $DOCS_DIR/files.txt