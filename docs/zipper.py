import os
from zipfile import ZipFile
import toml
from pathlib import Path

cur_path = Path(__file__).resolve()
html_path = str(cur_path.parent.joinpath('_build', 'html'))
pyproject = toml.load(cur_path.parents[1].joinpath('pyproject.toml'))
file_name = str(cur_path.parent.joinpath('_build')) + os.sep +\
            pyproject['tool']['poetry']['name'] + '-html-doc-' +\
            pyproject['tool']['poetry']['version'] + '.zip'

if __name__ == "__main__":
    with ZipFile(file_name, 'w') as zipObj:
        for folderName, subfolders, filenames in os.walk(html_path):
            for filename in filenames:
                filePath = os.path.join(folderName, filename)
                zipObj.write(filePath, f'{folderName[len(html_path):]}{os.sep}{filename}')
