import re
import argparse

def replace_format(filename):
    # Define the regular expression pattern with capture groups
    pattern = re.compile(
        r'\*\*Returns\*\*\n\n(.*?)\n\n(.*?)\.\n\n',
        re.MULTILINE
    )
    
    # Define a replacement function that injects the section title into the table
    def replacement(match):
        section_title = match.group(1)
        description = match.group(2)
        # print(f'Found section title: {section_title}')
        # print(f'Found description: {description}')
        return (
            '**Returns**\n'
            '| type | description |\n'
            '| :------ | :------ |\n'
            f'| {section_title} | {description} |\n\n'
        )
    
    # Read the file content
    with open(filename, 'r') as file:
        content = file.read()
    
    # Perform the replacement (replace all occurrences)
    while True:
        if not pattern.search(content):
            break
        # print('Found match')
        content = pattern.sub(replacement, content)
        


    # Write the modified content back to the file
    with open(filename, 'w') as file:
        file.write(content)
    
    print(f'Processed file: {filename}')

def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description='Replace specific Markdown format with a table.')
    parser.add_argument('filename', type=str, help='The path to the Markdown file to process')
    
    # Parse arguments
    args = parser.parse_args()
    
    replace_format(args.filename)

if __name__ == "__main__":
    main()
