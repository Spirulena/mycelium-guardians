import re
import subprocess

filename = 'export_presets.cfg'

tag = subprocess.check_output(['git', 'describe', '--tags', '--abbrev=0']).decode().strip() 
git_hash = subprocess.check_output(['git', 'rev-parse', '--short', 'HEAD']).decode().strip()

with open(filename, 'r') as f:
  lines = f.readlines()

regex = r'([\d.]+_[a-f0-9]+)'
for i, line in enumerate(lines):
  if 'export_path="../../builds/f87b81b/' in line:
    m = re.search(regex, line)
    if m:
      version_hash = m.group(1)
      lines[i] = line.replace(version_hash, f'{tag}_{git_hash}')
      print(lines[i])
    else:
      print(f"No match: {line.strip()}")
      
#with open(filename, 'w') as f:
#  f.writelines(lines)

# git tag -a 0.0.49 -m "version 0.0.49"
with open('version.txt', 'w') as f:
  f.writelines(f"{tag}_{git_hash}")
