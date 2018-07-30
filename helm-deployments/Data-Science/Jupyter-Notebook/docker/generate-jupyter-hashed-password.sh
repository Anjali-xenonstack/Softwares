
#!/bin/bash

git clone https://github.com/xmavrck/jupyter-lessons.git /home/jovyan/work/stacklabs

jpassword="$JUPYTERPWD"
salt=$(openssl rand -hex 6)
hashed_passw=$(echo -n "$jpassword$salt" | openssl dgst -sha1 | sed 's/^.* //')
jupyter_format_hash="sha1:$salt:$hashed_passw"
echo $jupyter_format_hash

jupyter notebook --NotebookApp.password=$jupyter_format_hash
