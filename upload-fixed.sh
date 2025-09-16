#!/bin/bash

# Nexus 配置
NEXUS_URL="http://146.0.74.15:8081/repository/maven-snapshots"
USERNAME="admin"
PASSWORD="780467asd"
GROUP_ID="com.pd"
VERSION="1.0-SNAPSHOT"
LIBS_DIR="./libs"

# pd-tools JAR 列表
ARTIFACTS=(
    "pd-auth-entity"
    "pd-tools-common"
    "pd-tools-core"
    "pd-tools-database"
    "pd-tools-dozer"
    "pd-tools-j2cache"
    "pd-tools-jwt"
    "pd-tools-log"
    "pd-tools-swagger"
    "pd-tools-user"
    "pd-tools-valid"
    "pd-tools-xss"
)

# 检查 libs 目录是否存在
if [ ! -d "$LIBS_DIR" ]; then
    echo "错误: $LIBS_DIR 目录不存在。请确保 JAR 文件在 $LIBS_DIR 中。"
    exit 1
fi

# 上传每个 JAR
for ARTIFACT_ID in "${ARTIFACTS[@]}"; do
    JAR_FILE="$LIBS_DIR/$ARTIFACT_ID-$VERSION.jar"

    if [ -f "$JAR_FILE" ]; then
        echo "上传 $ARTIFACT_ID..."

        # 构建正确的路径
        GROUP_PATH=$(echo "$GROUP_ID" | tr '.' '/')
        ARTIFACT_PATH="$GROUP_PATH/$ARTIFACT_ID/$VERSION/$ARTIFACT_ID-$VERSION.jar"
        UPLOAD_URL="$NEXUS_URL/$ARTIFACT_PATH"

        # 使用 curl PUT 请求上传
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
            -u "$USERNAME:$PASSWORD" \
            -X PUT \
            -T "$JAR_FILE" \
            -H "Content-Type: application/java-archive" \
            "$UPLOAD_URL")

        if [ "$RESPONSE" -eq 201 ] || [ "$RESPONSE" -eq 200 ]; then
            echo "$ARTIFACT_ID 上传成功 (HTTP $RESPONSE)。"
        else
            echo "错误: $ARTIFACT_ID 上传失败 (HTTP $RESPONSE)。"
            echo "上传 URL: $UPLOAD_URL"
        fi
    else
        echo "警告: $JAR_FILE 不存在，跳过 $ARTIFACT_ID。"
    fi
done

echo "所有上传完成。"