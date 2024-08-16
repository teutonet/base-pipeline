ARG REGISTRY_MIRROR=""

FROM ${REGISTRY_MIRROR}aquasec/trivy:0.54.1 AS trivy
FROM gcr.io/go-containerregistry/crane/debug:v0.15.2 AS crane
FROM gcr.io/kaniko-project/executor:v1.23.2-debug

COPY --from=trivy /usr/local/bin/trivy /kaniko
COPY --from=crane /ko-app/crane /kaniko
