commit := env('COMMIT', `git rev-parse HEAD`)
registry := env('REGISTRY', 'localhost:5005/jared-prime')
version := env('VERSION', `cat version.txt`)

default: registry latest prune

prune:
    @docker system prune -f

registry:
    @docker run --rm -d -p 5005:5000 --name registry registry:2 || docker inspect registry | jq '.[] | .Id'

cleanup:
    @docker stop registry
    @docker system prune -f --volumes

tools:
    @docker buildx build --quiet --push --platform linux/amd64,linux/arm64 -f Dockerfile -t {{ registry }}/kit:{{ commit }} --metadata-file ./.cache/tools.metadata.json .
    @jq '."image.name" + "@" + ."containerimage.digest"' < .cache/tools.metadata.json

skills:
    @docker buildx build --quiet --push --platform linux/amd64,linux/arm64 -f skills/skills.yaml -t {{ registry }}/kit/skills:{{ commit }} --metadata-file ./.cache/skills.metadata.json ./skills
    @jq '."image.name" + "@" + ."containerimage.digest"' < ./.cache/skills.metadata.json

workload workload:
    @docker buildx build --quiet --push --platform linux/amd64,linux/arm64 -f {{ workload }}/{{ workload }}.yaml -t {{ registry }}/kit/workload/{{ workload }}:{{ commit }} --build-arg tools={{ registry }}/kit:{{ commit }} --metadata-file ./.cache/{{ workload }}.workload.metadata.json ./{{ workload }}
    @jq '."image.name" + "@" + ."containerimage.digest"' < ./.cache/{{ workload }}.workload.metadata.json

[parallel]
workloads: (workload "anomaly") (workload "anthropic") (workload "openai")

sandbox workload:
    @docker buildx build --quiet --push --platform linux/amd64,linux/arm64 -f sandbox.yaml -t {{registry}}/kit/sandbox/{{workload}}:{{commit}} --build-arg registry={{registry}} --build-arg workload={{workload}} --build-arg version={{version}} --build-arg tag={{commit}} --metadata-file ./.cache/{{workload}}.sandbox.metadata.json .

[parallel]
sandboxes: (sandbox "anomaly") (sandbox "anthropic") (sandbox "openai")

[parallel]
kit: tools skills

scan workload: (sandbox workload)
    @docker run --rm --network host -v .cache/trivy/cache:/root/.cache/ -v .cache/trivy/report:/out aquasec/trivy image --ignore-unfixed --no-progress --format sarif --output /out/trivy.sarif {{registry}}/kit/sandbox/{{workload}}:{{commit}}

trivy: (scan "anomaly") (scan "anthropic") (scan "openai")

latest: kit (workloads) (sandboxes) (trivy)
