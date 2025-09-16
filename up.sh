#!/bin/bash

# Nexus 配置
NEXUS_URL="http://146.0.74.15:8081/repository/maven-releases/"
REPOSITORY_ID="releases"
USERNAME="admin"
PASSWORD="780467asd"  # 替换为实际密码
GROUP_ID="com.pd"
VERSION="1.0-SNAPSHOT"
LIBS_DIR="./libs"  # JAR 文件所在目录，相对于脚本位置

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
        mvn deploy:deploy-file \
            -DgroupId="$GROUP_ID" \
            -DartifactId="$ARTIFACT_ID" \
            -Dversion="$VERSION" \
            -Dpackaging=jar \
            -Dfile="$JAR_FILE" \
            -DrepositoryId="$REPOSITORY_ID" \
            -Durl="$NEXUS_URL" \
            -Dusername="$USERNAME" \
            -Dpassword="$PASSWORD"
        
        if [ $? -eq 0 ]; then
            echo "$ARTIFACT_ID 上传成功。"
        else
            echo "错误: $ARTIFACT_ID 上传失败。"
        fi
    else
        echo "警告: $JAR_FILE 不存在，跳过 $ARTIFACT_ID。"
    fi
done

echo "所有上传完成。"