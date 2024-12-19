ARG REGISTRY_MIRROR="" \
    REGISTRY_MIRROR_LIB="" \
    REGISTRY_MIRROR="" \
    USER_ID=1000 \
    GROUP_ID=1000

# renovate: datasource=github-tags depName=kubernetes/kubectl
ARG KUBECTL_VERSION=v1.24.7
# renovate: datasource=github-tags depName=helm/helm
ARG HELM_VERSION=v3.16.4
# renovate: datasource=github-tags depName=mozilla/sops
ARG SOPS_VERSION=v3.9.2
# renovate: datasource=github-tags depName=mikefarah/yq
ARG YQ_VERSION=v4.44.6
# renovate: datasource=github-tags depName=grafana/tanka
ARG TANKA_VERSION=v0.31.0


FROM ${REGISTRY_MIRROR}fluxcd/flux-cli:v2.4.0 as flux
FROM ${REGISTRY_MIRROR_LIB}alpine:3.21 AS base

LABEL maintainer="oc@teuto.net"
LABEL tools="kubectl,sops,tanka,flux,envsubst,docker,helm,yq,jq"

ARG HELM_VERSION \
    KUBECTL_VERSION \
    SOPS_VERSION \
    USER_ID \
    GROUP_ID

RUN apk update && \
  apk  add  --no-cache \
  bash \
  ca-certificates \
  curl \
  docker \
  gettext \
  git \
  jq \
  python3 \
  py3-yaml \
  gnupg \
  multipath-tools \
  shadow-uidmap \
  coreutils

RUN addgroup -g ${GROUP_ID} user \
   && adduser -h /home/user -s /bin/bash -G user -D -u ${USER_ID} user \
   && addgroup user docker

FROM base AS binaries

ARG HELM_VERSION \
    KUBECTL_VERSION \
    SOPS_VERSION \
    YQ_VERSION \
    TANKA_VERSION \
    USER_ID \
    GROUP_ID

WORKDIR /usr/local/bin

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
   chmod +x kubectl && \
  curl -sSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar xz && \
  curl -sL https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -o /usr/local/bin/yq && \
  chmod +x /usr/local/bin/yq && \
  curl -sL https://github.com/stedolan/jq/releases/latest/download/jq-linux64 -o /usr/local/bin/jq && \ 
  chmod +x /usr/local/bin/jq && \
  curl -fSL -o "/usr/local/bin/tk" "https://github.com/grafana/tanka/releases/download/${TANKA_VERSION}/tk-linux-amd64" && \
  chmod a+x "/usr/local/bin/tk" && \
  curl -LO https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64 && \
  mv sops-${SOPS_VERSION}.linux.amd64 sops && \
  chmod a+x sops

# final stage
FROM base as final

WORKDIR /home/user

RUN chown -R user:user /home/user \
  # shell für den benutzer root auf bash umstellenm
  &&  sed -e 's;/bin/ash$;/bin/bash;g' -i /etc/passwd

COPY --from=flux /usr/local/bin/flux /usr/local/bin/flux
COPY --from=binaries /usr/local/bin/kubectl \
      /usr/local/bin/linux-amd64/helm \
      /usr/local/bin/yq \
      /usr/local/bin/jq \
      /usr/local/bin/tk \
      /usr/local/bin/sops /usr/local/bin/

USER user

RUN helm plugin install https://github.com/jkroepke/helm-secrets

ENV HELM_PLUGINS=/home/user/.local/share/helm/plugins/

#ENTRYPOINT entfernt un ddurch CMD ersetzt, damit man mit docker run das binary angeben kann und nicht automatisch der entrypoint gestartet wird
CMD /bin/bash
