version := `cat version.txt`

prune:
    @docker system prune -f

registry:
    @docker run --rm -d -p 5005:5000 --name registry registry:2 || docker inspect registry | jq '.[] | .Id'

image registry:
    @docker buildx build --quiet --push -t {{registry}}/kit:v{{version}} -f Dockerfile --metadata-file image.metadata.json .
    @jq '."image.name" + "@" + ."containerimage.digest"' < image.metadata.json

kit registry harness:
    @docker buildx build --quiet --push --target {{harness}} -t {{registry}}/kit/{{harness}}:v{{version}} -f Dockerfile --metadata-file {{harness}}.kit.metadata.json .
    @jq '."image.name" + "@" + ."containerimage.digest"' < {{harness}}.kit.metadata.json

workload registry workload:
    @docker buildx build --quiet --push -t {{registry}}/kit/workload/{{workload}}:v{{version}} -f {{workload}}/{{workload}}.yaml --metadata-file {{workload}}.workload.metadata.json --build-arg registry={{registry}} --build-arg version={{version}} {{workload}}
    @jq '."image.name" + "@" + ."containerimage.digest"' < {{workload}}.workload.metadata.json

mixin registry mixin:
    @docker buildx build --quiet --push -t {{registry}}/kit/mixin/{{mixin}}:v{{version}} -f {{mixin}}/{{mixin}}.yaml --metadata-file {{mixin}}.mixin.metadata.json {{mixin}}
    @jq '."image.name" + "@" + ."containerimage.digest"' < {{mixin}}.mixin.metadata.json

sandbox registry workload harness: (kit registry harness) (workload registry workload)
    @docker buildx build --quiet --push -t {{registry}}/sandbox/{{harness}}:v{{version}} -f sandbox.yaml --metadata-file {{harness}}.sandbox.metadata.json --build-arg registry={{registry}} --build-arg workload={{workload}} --build-arg harness={{harness}} --build-arg version={{version}} .
    @jq '."image.name" + "@" + ."containerimage.digest"' < {{harness}}.sandbox.metadata.json

opencode registry: (sandbox registry "anomaly" "opencode")
claude registry: (sandbox registry "anthropic" "claude")
codex registry: (sandbox registry "openai" "codex")

[parallel]
sandboxes registry: (opencode registry) (claude registry) (codex registry)

build registry: (image registry)  (mixin registry "skills") (sandboxes registry)

clean: prune
    @docker rm -f registry
    @rm *.metadata.json

local: registry (build "localhost:5005/jared-prime") trivy

[parallel]
trivy: (scan "localhost:5005/jared-prime" "sandbox/opencode") (scan "localhost:5005/jared-prime" "sandbox/claude") (scan "localhost:5005/jared-prime" "sandbox/codex")
    @echo "✅"

scan registry image:
    @docker run --rm -v "$(pwd)/.trivyignore":/scan/.trivyignore:ro -v "$(pwd)/.cache/trivy":/scan/cache dhi.io/trivy:0-alpine@sha256:f04db25a4dbc544a40e7a3e25c6134007fdebdc213dc0ee8e1899e0a8a54390d image --image-src remote --insecure --platform linux/arm64 --format table --quiet --no-progress --exit-code 1 --cache-dir /scan/cache --ignorefile /scan/.trivyignore --severity HIGH,CRITICAL {{replace(registry, "localhost", "host.docker.internal")}}/{{image}}:v{{version}}

default: clean local
