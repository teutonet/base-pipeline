ARG REGISTRY_MIRROR=""

FROM ${REGISTRY_MIRROR}aquasec/trivy:0.64.1 AS trivy
FROM gcr.io/go-containerregistry/crane/debug@sha256:94f61956845714bea3b788445454ae4827f49a90dcd9dac28255c4cccb6220ad AS crane
FROM ghcr.io/awesome-containers/static-git:2.40.1 AS git
FROM gcr.io/kaniko-project/executor:v1.24.0-debug

COPY --from=trivy /usr/local/bin/trivy /kaniko
COPY --from=crane /ko-app/crane /kaniko
COPY --from=git /bin/git /kaniko
