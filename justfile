set export
set positional-arguments

buildx-version := "0.8.2"
name := "unbound"
plugins-dir := "~/.docker/cli-plugins"

USER := env_var_or_default("DOCKERHUB_USERNAME", "rsprta")
PASSWORD := env_var_or_default("DOCKERHUB_PASSWORD", "none")
REGISTRY := "docker.io"
REPOSITORY := env_var_or_default("DOCKERHUB_REPOSITORY", USER + "/" + name)

BUILD_DATE := `date -u +'%Y-%m-%dT%H:%M:%SZ'`
VCS_REF := `git describe --tags --always --dirty`


defaults:
    @just --list

build version platforms type="remote": _deps _qemu
    #!/usr/bin/env sh
    build="push"
    if [ "{{type}}" = "local" ]; then
        build="load"
    fi
    docker buildx create --use --driver docker-container --name builder
    docker buildx build \
        --build-arg version={{version}} \
        --cache-from {{REPOSITORY}} \
        --cache-to "type=inline" \
        --label "org.opencontainers.image.created=${BUILD_DATE}" \
        --label "org.opencontainers.image.revision=${VCS_REF}" \
        --platform {{platforms}} \
        --${build} \
        --tag {{REPOSITORY}}:{{version}} \
        --tag {{REPOSITORY}} \
        .
    docker buildx rm builder

_login:
    #!/usr/bin/env sh
    if ! grep -q {{REGISTRY}} ${HOME}/.docker/config.json; then
        echo "{{PASSWORD}}" | docker login -u "{{USER}}" --password-stdin {{REGISTRY}}
    fi

_deps:
    #!/usr/bin/env sh
    if [ ! -f {{plugins-dir}}/docker-buildx ]; then
        mkdir -p {{plugins-dir}}
        wget https://github.com/docker/buildx/releases/download/v{{buildx-version}}/buildx-v{{buildx-version}}.linux-amd64 -O {{plugins-dir}}/docker-buildx
        chmod a+x {{plugins-dir}}/docker-buildx
    fi

prune:
    docker system prune --all --volumes

_qemu:
    docker run --privileged multiarch/qemu-user-static --reset -p yes

run:
    docker run --rm -d --name {{name}} {{REPOSITORY}}

scan image:
    trivy image --ignore-unfixed --severity MEDIUM,HIGH,CRITICAL \
    --exit-code 1 --no-progress --security-checks vuln \
    {{image}}

test: (build "latest" "linux/amd64" "local") run
    docker stop {{name}}

_update_readme:
    @docker run -v ${PWD}:/workspace \
    -e DOCKERHUB_USERNAME={{USER}} \
    -e DOCKERHUB_PASSWORD={{PASSWORD}} \
    -e DOCKERHUB_REPOSITORY={{REPOSITORY}} \
    -e README_FILEPATH=/workspace/README.md peterevans/dockerhub-description

upload version platforms: _login (build version platforms)
    #!/usr/bin/env sh
    if [ "{{REGISTRY}}" = "docker.io" ]; then
        just _update_readme
    fi
