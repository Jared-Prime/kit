commit := env('COMMIT', `git rev-parse HEAD`)
registry := env('REGISTRY', 'localhost:5005/jared-prime')
version := env('VERSION', `cat version.txt`)

default: latest

prune:
    @docker system prune -f

registry:
    @docker run --rm -d -p 5005:5000 --name registry registry:2 || docker inspect registry | jq '.[] | .Id'

cleanup:
    @docker stop registry
    @docker system prune -f

tools:
    @docker buildx build --quiet --push -f Dockerfile -t {{ registry }}/kit:{{ commit }} --metadata-file ./.cache/tools.metadata.json .
    @jq '."image.name" + "@" + ."containerimage.digest"' < .cache/tools.metadata.json

skills:
    @docker buildx build --quiet --push -f skills/skills.yaml -t {{ registry }}/kit/skills:{{ commit }} --metadata-file ./.cache/skills.metadata.json ./skills
    @jq '."image.name" + "@" + ."containerimage.digest"' < ./.cache/skills.metadata.json

workload name:
    @docker buildx build --quiet --push -f {{ name }}/{{ name }}.yaml -t {{ registry }}/kit/workload/{{ name }}:{{ commit }} --build-arg tools={{ registry }}/kit:{{ commit }} --metadata-file ./.cache/{{ name }}.workload.metadata.json ./{{ name }}
    @jq '."image.name" + "@" + ."containerimage.digest"' < ./.cache/{{ name }}.workload.metadata.json

[parallel]
workloads: (workload "anomaly") (workload "anthropic") (workload "openai")

sandbox name harness tag:
    @docker buildx build --quiet --push -f {{ name }}/{{ harness }}.yaml -t {{ registry }}/kit/sandbox/{{ harness }}:{{ commit }} --build-arg registry={{ registry }} --build-arg version={{ version }} --build-arg tag={{ tag }} --metadata-file ./.cache/{{ harness }}.harness.metadata.json ./{{ name }}

[parallel]
sandboxes tag: (sandbox "anomaly" "opencode" tag) (sandbox "anthropic" "claude" tag) (sandbox "openai" "codex" tag)

[parallel]
kit: tools skills

latest: kit (workloads) (sandboxes commit)
