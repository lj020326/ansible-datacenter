
rem set JUPYTER=D:\apps\python35\python-3.5.4.amd64\Scripts\jupyter.exe
rem set JUPYTER="D:\apps\python35\Jupyter Notebook"
set JUPYTER=D:\apps\python35\scripts\winipython_notebook.bat

set JUPYTER_ARGS=--config=%HOME%/.jupyter/jupyter_notebook_config.py --notebook-dir=%HOME%/repos/python/notebooks

rem %JUPYTER% notebook --config=%HOME%/.jupyter/jupyter_notebook_config.py --notebook-dir=%HOME%/repos/python/notebooks
%JUPYTER% %JUPYTER_ARGS%
rem %JUPYTER% notebook
