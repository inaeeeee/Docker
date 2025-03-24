#!/bin/bash

# 출력 파일 초기화
OUTPUT_FILE="docker_env.sh"
> "$OUTPUT_FILE"

# 모든 컨테이너 이름 가져오기 (중지된 것도 포함)
CONTAINERS=$(docker ps -a --format '{{.Names}}')

for CONTAINER in $CONTAINERS; do
    # 변수 이름용 접두사 (대문자 + _ 로 구분)
    PREFIX=$(echo "$CONTAINER" | tr '[:lower:]' '[:upper:]' | tr '-' '_' )

    # 정보 수집
    ID=$(docker inspect -f '{{.Id}}' "$CONTAINER")
    STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER")
    CREATED=$(docker inspect -f '{{.Created}}' "$CONTAINER" | cut -d'.' -f1 | sed 's/T/ /')
    NETWORK=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' "$CONTAINER")
    IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER")

    # 볼륨 관련 정보
    VOLUME_NAME=$(docker inspect -f '{{range .Mounts}}{{.Name}}{{end}}' "$CONTAINER")
    VOLUME_SOURCE=$(docker inspect -f '{{range .Mounts}}{{.Source}}{{end}}' "$CONTAINER")
    VOLUME_DEST=$(docker inspect -f '{{range .Mounts}}{{.Destination}}{{end}}' "$CONTAINER")

    # 파일에 쓰기
    {
        echo "${PREFIX}_STATUS=$STATUS"
        echo "${PREFIX}_ID=$ID"
        echo "${PREFIX}_CREATED=\"$CREATED\""
        echo "${PREFIX}_NETWORK=$NETWORK"
        echo "${PREFIX}_IP=$IP"
        echo "${PREFIX}_VOLUME_NAME=$VOLUME_NAME"
        echo "${PREFIX}_VOLUME_SOURCE=$VOLUME_SOURCE"
        echo "${PREFIX}_VOLUME_DEST=$VOLUME_DEST"
        echo
    } >> "$OUTPUT_FILE"
done

echo "[+] docker_env.sh 파일 생성 완료!"

