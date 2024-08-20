# npm install typedoc 0.25.13
# npm install     "typedoc-plugin-markdown": "^4.0.0-next.25",

# Generate the documentation

SRC_DIR=../literalai-typescript
OUTPUT_DIR=typescript-client/api-reference
TMP_DIR=typescript-client/api-reference/tmp

# keep the dir of this script to use it as a base dir
BASEDIR=$(pwd)

# switch flags to change the src and output directories
for i in "$@"
do
    case $i in
        -s=*|--source-dir=*)
        SRC_DIR="${i#*=}"
        shift # past argument=value
        ;;
        -o=*|--output-dir=*)
        OUTPUT_DIR="${i#*=}"
        shift # past argument=value
        ;;
        *)
        # unknown option
        ;;
    esac
done

FILES=(
    "api"
    "thread"
    "step"
)

# if output directory does not exist, create it
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p $OUTPUT_DIR
fi

# if tmp directory does not exist, create it
if [ ! -d "$TMP_DIR" ]; then
    mkdir -p $TMP_DIR
fi

# get the absolute path of the output directory
OUTPUT_DIR=$(realpath $OUTPUT_DIR)

# echo the output dir to the console in yellow bold
echo "\033[1;33mOutput directory: $OUTPUT_DIR\033[0m"

# move to the src directory
cd $SRC_DIR

# echo the current directory to the console in yellow bold
echo "\033[1;33mCurrent directory: $(pwd)\033[0m"

# install the dependencies
npm install

for i in "${FILES[@]}"; do
    echo "Writing docs for $i in $OUTPUT_DIR/$i.mdx"
    # Generate the documentation

    if [ "$i" = "api" ]; then
        npx typedoc --out $TMP_DIR --tsconfig tsconfig.json src/$i.ts --name $i
    else
        npx typedoc --out $TMP_DIR --tsconfig tsconfig.json src/observability/$i.ts
    fi
    cp $TMP_DIR/README.md $OUTPUT_DIR/$i.mdx
done

rm -rf $TMP_DIR/README.md

cd $BASEDIR

for i in "${FILES[@]}"; do

    # remove the 6 first lines (very bad solution, but removes useless auto-generated stuff)
    sed -i '' '1,2d' $OUTPUT_DIR/$i.mdx

    # remove the 2 last lines (very bad solution, but removes useless auto-generated stuff)
    sed -i '' '$d' $OUTPUT_DIR/$i.mdx
    sed -i '' '$d' $OUTPUT_DIR/$i.mdx

    # replace arguments and returns from title 6 to bold plain text
    sed -E -i '' -f "scripts/change_headers6_to_bold.txt" $OUTPUT_DIR/$i.mdx

    # replace title 5 with title 3
    sed -E -i '' -f "scripts/replace_title5_title3.txt" $OUTPUT_DIR/$i.mdx

    # zoom_subtitles_special
    sed -E -i '' -f "scripts/zoom_subtitles_special.txt" $OUTPUT_DIR/$i.mdx

    python3 scripts/make_returns_tables.py $OUTPUT_DIR/$i.mdx

done

# for each file in the DOC_DIR, add its name without the extension to a files.txt file
for file in $OUTPUT_DIR/*.mdx; do
    echo $(basename $file .mdx) >> $OUTPUT_DIR/files.txt
done

# call the python script to add the files to the mint.json
python3 scripts/update_api_reference.py -ts $OUTPUT_DIR/files.txt

# remove the files.txt file
rm $OUTPUT_DIR/files.txt