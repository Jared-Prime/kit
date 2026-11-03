commit := env('COMMIT', `git rev-parse HEAD`)
registry := env('REGISTRY', 'localhost:5005/jared-prime')
version := env('VERSION', `cat version.txt`)

default: registry buildx prune

prune:
    @docker system prune -f

buildx: kit (workloads) (sandboxes) (trivy)

[group('buildx')]
tools:
    @docker buildx build --quiet --push --platform linux/amd64,linux/arm64 -f Dockerfile -t {{ registry }}/kit:{{ commit }} --metadata-file ./.cache/tools.metadata.json .
    @jq '."image.name" + "@" + ."containerimage.digest"' < .cache/tools.metadata.json

[group('buildx')]
skills:
    @docker buildx build --quiet --push --platform linux/amd64,linux/arm64 -f skills/skills.yaml -t {{ registry }}/kit/skills:{{ commit }} --metadata-file ./.cache/skills.metadata.json ./skills
    @jq '."image.name" + "@" + ."containerimage.digest"' < ./.cache/skills.metadata.json

[group('buildx')]
workload workload:
    @docker buildx build --quiet --push --platform linux/amd64,linux/arm64 -f {{ workload }}/{{ workload }}.yaml -t {{ registry }}/kit/workload/{{ workload }}:{{ commit }} --build-arg tools={{ registry }}/kit:{{ commit }} --metadata-file ./.cache/{{ workload }}.workload.metadata.json ./{{ workload }}
    @jq '."image.name" + "@" + ."containerimage.digest"' < ./.cache/{{ workload }}.workload.metadata.json

[parallel]
[group('buildx')]
workloads: (workload "anomaly") (workload "anthropic") (workload "openai")

[group('buildx')]
sandbox workload:
    @docker buildx build --quiet --push --platform linux/amd64,linux/arm64 -f sandbox.yaml -t {{registry}}/kit/sandbox/{{workload}}:{{commit}} --build-arg registry={{registry}} --build-arg workload={{workload}} --build-arg version={{version}} --build-arg tag={{commit}} --metadata-file ./.cache/{{workload}}.sandbox.metadata.json .

[parallel]
[group('buildx')]
sandboxes: (sandbox "anomaly") (sandbox "anthropic") (sandbox "openai")

[parallel]
[group('buildx')]
kit: tools skills

trivy: (scan "anomaly") (scan "anthropic") (scan "openai")

[group('trivy')]
scan workload:
    @docker run --rm --network host -v .cache/trivy/cache:/root/.cache/ -v .cache/trivy/report:/out aquasec/trivy image --ignore-unfixed --no-progress --format sarif --output /out/trivy.sarif {{registry}}/kit/sandbox/{{workload}}:{{commit}}

k3d: registry create helmfile

[group('k3d')]
registry:
    @k3d registry create registry --port 5005 || echo "registry already exists"

[group('k3d')]
delete: prune
    @k3d cluster delete kit

[group('k3d')]
create:
    @k3d cluster create kit --config k3d/config.yaml

[group('k3d')]
helmfile:
    @helmfile sync -f k3d/helmfile.yaml
