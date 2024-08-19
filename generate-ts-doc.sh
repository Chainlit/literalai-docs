# npm install typedoc 0.25.13
# npm install     "typedoc-plugin-markdown": "^4.0.0-next.25",

# Generate the documentation

SRC_DIR=../literalai-typescript
OUTPUT_DIR=typescript-client/api-reference

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

# if output directory does not exist, create it
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p $OUTPUT_DIR
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

# Generate the documentation
npx typedoc --out $OUTPUT_DIR --tsconfig tsconfig.json src/api.ts

# rename the generated file api-reference.mdx
mv $OUTPUT_DIR/README.md $OUTPUT_DIR/api-reference.mdx