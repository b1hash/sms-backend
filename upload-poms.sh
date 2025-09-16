#!/bin/bash

# Nexus 配置
NEXUS_URL="http://146.0.74.15:8081/repository/maven-snapshots"
USERNAME="admin"
PASSWORD="780467asd"
GROUP_ID="com.pd"
VERSION="1.0-SNAPSHOT"

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

# 为每个 artifact 创建和上传 POM
for ARTIFACT_ID in "${ARTIFACTS[@]}"; do
    echo "创建和上传 $ARTIFACT_ID 的 POM 文件..."

    # 创建 POM 文件内容
    POM_CONTENT="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<project xmlns=\"http://maven.apache.org/POM/4.0.0\"
         xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
         xsi:schemaLocation=\"http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd\">
    <modelVersion>4.0.0</modelVersion>

    <groupId>${GROUP_ID}</groupId>
    <artifactId>${ARTIFACT_ID}</artifactId>
    <version>${VERSION}</version>
    <packaging>jar</packaging>

    <name>${ARTIFACT_ID}</name>
    <description>PD Tools ${ARTIFACT_ID} Library</description>

    <dependencies>
        <!-- Add any dependencies that ${ARTIFACT_ID} has -->
    </dependencies>
</project>"

    # 创建临时 POM 文件
    POM_FILE="${ARTIFACT_ID}.pom"
    echo "$POM_CONTENT" > "$POM_FILE"

    # 构建上传路径
    GROUP_PATH=$(echo "$GROUP_ID" | tr '.' '/')
    POM_UPLOAD_URL="$NEXUS_URL/$GROUP_PATH/$ARTIFACT_ID/$VERSION/$ARTIFACT_ID-$VERSION.pom"

    # 上传 POM 文件
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
        -u "$USERNAME:$PASSWORD" \
        -X PUT \
        -T "$POM_FILE" \
        -H "Content-Type: application/xml" \
        "$POM_UPLOAD_URL")

    if [ "$RESPONSE" -eq 201 ] || [ "$RESPONSE" -eq 200 ]; then
        echo "$ARTIFACT_ID POM 上传成功 (HTTP $RESPONSE)。"
    else
        echo "错误: $ARTIFACT_ID POM 上传失败 (HTTP $RESPONSE)。"
        echo "上传 URL: $POM_UPLOAD_URL"
    fi

    # 清理临时文件
    rm "$POM_FILE"
done

echo "所有 POM 文件上传完成。"