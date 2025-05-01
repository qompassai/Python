#!/usr/bin/env python3
import json
import re
import subprocess
import requests
import sys

ORGANIZATION = "qompassai"
CATEGORIES = ["Equator", "Nautilus", "Sojourn", "WaveRunner"]
PROGRAMMING_LANGUAGES = [
    "Python", "Rust", "Mojo", "Zig", "C", "C++", "JavaScript", "TypeScript", 
    "Java", "Go", "Ruby", "PHP", "Swift", "Lua", "Kotlin", "R", "Julia", "Dart"
]

def get_repo_url():
    """Get the remote origin URL from the local git repository."""
    try:
        result = subprocess.run(
            ["git", "config", "--get", "remote.origin.url"],
            capture_output=True, text=True, check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        print("Error: Not a git repository or no remote 'origin' set")
        sys.exit(1)

def extract_repo_info(url):
    """Extract owner and repo name from GitHub URL."""
    patterns = [
        r"git@github\.com:([^/]+)/([^\.]+)\.git",
        r"https://github\.com/([^/]+)/([^\.]+)(?:\.git)?",
        r"git://github\.com/([^/]+)/([^\.]+)\.git"
    ]
    
    for pattern in patterns:
        match = re.match(pattern, url)
        if match:
            return match.group(1), match.group(2)
    
    print(f"Error: Could not parse GitHub URL: {url}")
    sys.exit(1)

def get_repo_metadata(owner, repo):
    """Fetch repository metadata from GitHub API."""
    url = f"https://api.github.com/repos/{owner}/{repo}"
    headers = {
        "Accept": "application/vnd.github.mercy-preview+json"
    }
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"Error: Failed to fetch repository data: {response.status_code}")
        print(f"Response: {response.text}")
        sys.exit(1)
    return response.json()

def detect_programming_language(metadata):
    """Detect the programming language from repository metadata."""
    for lang in PROGRAMMING_LANGUAGES:
        if lang.lower() in metadata['name'].lower():
            return lang
    
    if 'topics' in metadata and metadata['topics']:
        for topic in metadata['topics']:
            for lang in PROGRAMMING_LANGUAGES:
                if topic.lower() == lang.lower():
                    return lang
    if metadata.get('description'):
        for lang in PROGRAMMING_LANGUAGES:
            if lang.lower() in metadata['description'].lower():
                return lang
    print("Warning: Could not automatically detect programming language.")
    language = input("Please enter the programming language (or press Enter for generic): ")
    return language if language else "Programming"
def detect_category(metadata):
    """Detect the category (Equator, Nautilus, etc.) from metadata."""
    if 'topics' in metadata and metadata['topics']:
        for topic in metadata['topics']:
            for category in CATEGORIES:
                if topic.lower() == category.lower():
                    return category
    for category in CATEGORIES:
        if category.lower() in metadata['name'].lower():
            return category
    
    print("Warning: Could not automatically detect project category.")
    print(f"Available categories: {', '.join(CATEGORIES)}")
    category = input("Please enter the category: ")
    if category and category in CATEGORIES:
        return category
    else:
        print(f"Invalid category. Using default: Equator")
        return "Equator"

def update_metadata_template(template_path, metadata, language, category):
    """Update the metadata template with repo info."""
    try:
        with open(template_path, 'r') as f:
            data = json.load(f)
        
        
        if metadata.get('description'):
            data["description"] = metadata['description']
        else:
            data["description"] = f"Educational Content on the {language} Programming Language"
        
        keywords = []
        if 'topics' in metadata and metadata['topics']:
            keywords.extend(metadata['topics'])
        
        if category.lower() not in [k.lower() for k in keywords]:
            keywords.append(category)
        if language.lower() not in [k.lower() for k in keywords]:
            keywords.append(language)
        
        if "ai" not in [k.lower() for k in keywords]:
            keywords.append("AI")
        if "education" not in [k.lower() for k in keywords]:
            keywords.append("Education")
        
        data["keywords"] = keywords
        
        for idx, related in enumerate(data.get("related_identifiers", [])):
            if related.get("relation") == "isSupplementTo":
                data["related_identifiers"][idx]["identifier"] = metadata['html_url']
        
        output_path = "CITATION.cff"
        with open(output_path, 'w') as f:
            json.dump(data, f, indent=2)
        
        print(f"Metadata written to {output_path}")
        
        print("\nConsider updating GitHub topics with:")
        print(f"gh repo edit {metadata['full_name']} --add-topic {','.join(keywords)}")
        
    except FileNotFoundError:
        print(f"Error: Template file not found: {template_path}")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in template file: {template_path}")
        sys.exit(1)

def main():
    repo_url = get_repo_url()
    owner, repo = extract_repo_info(repo_url)
    print(f"Repository: {owner}/{repo}")
    
    if owner.lower() != ORGANIZATION.lower():
        print(f"Note: Using organization {ORGANIZATION} instead of {owner}")
        owner = ORGANIZATION
    
    metadata = get_repo_metadata(owner, repo)
    
    language = detect_programming_language(metadata)
    category = detect_category(metadata)
    
    print(f"Detected Language: {language}")
    print(f"Detected Category: {category}")
    
    template_path = "metadata_template.json"
    update_metadata_template(template_path, metadata, language, category)
    
    if 'topics' in metadata and metadata['topics']:
        current_topics = ','.join(metadata['topics'])
        print(f"\nCurrent topics: {current_topics}")

if __name__ == "__main__":
    main()
