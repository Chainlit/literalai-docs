![Literal AI](/images/logoliteralai.png)

# Literal AI Docs

### Development

Install the [Mintlify CLI](https://www.npmjs.com/package/mintlify) to preview the documentation changes locally. To install, use the following command

```
npm i -g mintlify
```

Run the following command at the root of your documentation (where mint.json is)

```
mintlify dev
```

Run the following command to check broken links. 

```
mintlify broken-links
```

### SDKs Documentation

#### Python SDK

The python SDK documentation is generated using ```generate-py-doc.sh``` script. The script uses the python docstrings to generate the documentation. The script relies on pydoc-markdown to generate the markdown files. The script can be run using the following arguments:
- ```-s``` or ```--source-dir``` : The source directory where the python files are located. The default value is ```../literalai-python```.
- ```o``` or ```--output-dir``` : The output directory where the markdown files will be generated. The default value is ```python-client/api-reference```.
- ```b``` or ```--beautify``` : Uses some mintlify flags for a prettier result.
- ```c``` or ```--config-file``` : The config file to be used for the generation. The default value is ```pydoc-markdown.yml```.

The script generates the markdown files in the output directory. The markdown files are then copied to the ```python-client/api-reference``` directory. Note that all the generated mdx files should be documented in the mint.json file.

#### TypeScript SDK

The TypeScript SDK documentation is generated using ```generate-ts-doc.sh``` script. The script uses the TypeDoc to generate the documentation. The script can be run using the following arguments:
- ```-s``` or ```--source-dir``` : The source directory where the TypeScript files are located. The default value is ```../literalai-typescript```.
- ```o``` or ```--output-dir``` : The output directory where the markdown files will be generated. The default value is ```typescript-client/api-reference```.

Note that this script only generates one file, ```README.md```, and do not dispose of much options at the moment. WIP !


### Publishing Changes

Changes will be deployed to production automatically after pushing to the default branch.

#### Troubleshooting

- Mintlify dev isn't running - Run `mintlify install` it'll re-install dependencies.
- Page loads as a 404 - Make sure you are running in a folder with `mint.json`
