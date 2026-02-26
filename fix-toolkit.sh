#!/bin/bash

# Monitora o diretório /tmp/aws-toolkit-vscode e copia index.js quando necessário
while true; do
    for dir in /tmp/aws-toolkit-vscode/*/output/HelloWorldFunction; do
        if [ -d "$dir" ] && [ ! -f "$dir/index.js" ]; then
            echo "Copiando index.js para $dir"
            cp /home/leonardo/Documentos/Workspace/formacaoaws/12-25and01-26/Desafio5/sam-app/hello-world/index.js "$dir/"
            cp /home/leonardo/Documentos/Workspace/formacaoaws/12-25and01-26/Desafio5/sam-app/hello-world/package.json "$dir/"
        fi
    done
    sleep 0.5
done
