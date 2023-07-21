
FROM registry.gitlab.com/gitlab-org/release-cli:v0.15.0 as releaseCli
FROM orhunp/git-cliff:1.2.0

COPY --from=releaseCli /usr/local/bin/release-cli /usr/local/bin/release-cli