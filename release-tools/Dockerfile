FROM registry.gitlab.com/gitlab-org/release-cli:v0.19.0 as releaseCli
FROM orhunp/git-cliff:2.6.1 as base

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

FROM base
COPY --from=releaseCli /usr/local/bin/release-cli /usr/local/bin/release-cli