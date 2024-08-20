import json
import argparse
import os

def delete_group(navigation, group_name, base_path):
    return [
        item for item in navigation
        if not (
            item.get('group') == group_name and
            any(page.startswith(base_path) for page in item.get('pages', []))
        )
    ]

def add_api_reference_group(navigation, group_name, base_path, pages):
    navigation.append({
        "group": group_name,
        "pages": [f"{base_path}{page.strip()}" for page in pages]
    })

def load_pages(file):
    with open(file, 'r') as f:
        # return values for each line in the file (remove empty lines)
        return [line.strip() for line in f.readlines() if line.strip()]

def update_mint_json(ts_file, py_file, json_file):
    # Load existing JSON file
    with open(json_file, 'r') as f:
        data = json.load(f)

    # Load pages from the provided files
    ts_pages = load_pages(ts_file) if ts_file else []
    py_pages = load_pages(py_file) if py_file else []

    # Delete existing "API Reference" groups if new pages are provided
    if py_pages:
        data['navigation'] = delete_group(data['navigation'], 'API Reference', 'python-client/api-reference/')
        add_api_reference_group(data['navigation'], 'API Reference', 'python-client/api-reference/', py_pages)
    
    if ts_pages:
        data['navigation'] = delete_group(data['navigation'], 'API Reference', 'typescript-client/api-reference/')
        add_api_reference_group(data['navigation'], 'API Reference', 'typescript-client/api-reference/', ts_pages)

    # Save the updated JSON file
    with open(json_file, 'w') as f:
        json.dump(data, f, indent=2)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Update API Reference groups in mint.json')
    parser.add_argument('-ts', '--typescript', help='File containing TypeScript API references (comma-separated)')
    parser.add_argument('-py', '--python', help='File containing Python API references (comma-separated)')
    
    # The path to mint.json is the parent directory of the scripts directory
    # get the path of this script file and then get the parent directory
    json_file = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../mint.json')

    args = parser.parse_args()

    update_mint_json(args.typescript, args.python, json_file)
