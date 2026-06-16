import os
import re

lib_dir = r"d:\flutter\Zeffa\lib"
translation_file = os.path.join(lib_dir, "core", "localizations", "Translation.dart")

with open(translation_file, 'r', encoding='utf-8') as f:
    translation_content = f.read()

# Extract mappings
pattern = re.compile(r'"(auto_str_\d+)":\s*"(.*?)"', re.DOTALL)
mappings = dict(pattern.findall(translation_content))

# Find ones with variables
with open(r"d:\flutter\Zeffa\vars_output.txt", "w", encoding="utf-8") as out:
    for k, v in mappings.items():
        if '$' in v:
            out.write(f"{k}: {v}\n")
