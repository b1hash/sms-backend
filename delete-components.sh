#!/bin/bash

# 获取所有 pd-tools 组件的 ID
COMPONENTS=$(curl -s -u admin:780467asd http://146.0.74.15:8081/service/rest/v1/components?repository=maven-snapshots | grep -o '"id" : "[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')

echo "找到的组件 ID:"
echo "$COMPONENTS"

# 删除每个组件
for ID in $COMPONENTS; do
    echo "删除组件 $ID..."
    curl -s -u admin:780467asd -X DELETE "http://146.0.74.15:8081/service/rest/v1/components/$ID"
    echo "已删除 $ID"
done

echo "所有组件删除完成。"