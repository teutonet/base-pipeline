# Deployment Pipeline and End-to-End Testing for Web Platforms

## Motivation

Reliable and consistent deployments are crucial for ensuring high software quality and reducing the risk of integration issues. To achieve this goal, we ensure that both frontend and backend components of combined applications can be deployed together within a Kubernetes cluster.

To facilitate this, we manage our projects within a single Git repository (Monorepo). This approach allows us to version all components simultaneously.

Under the term **web platform** we include not only the frontend and backend but also all additional resources necessary for operation, particularly the required databases.

The web platform is always treated as a unified entity, allowing all processes—local development, quality checks, and updates—to be executed simultaneously for all components.

Each code change automatically triggers an end-to-end integration test. To perform these tests, we implement a complete deployment of the platform, including provisioning of test data, within the base pipeline.

Using [Playwright](https://playwright.dev/) *(a superior alternative to Selenium)*, critical frontend paths and features are automatically tested, and the status of these end-to-end tests is documented in the pipeline.

We utilize a multi-stage configuration mechanism based on Kubernetes Helm templating for configuring platform components and their environments. If credentials need to be stored, we use encryption via **[SOPS](https://github.com/getsops/sops)**.

The Kubernetes operations team supports configuring and operating databases and deployments, as well as maintaining the installation script for the local Minikube environment on developer workstations.

During the development process, each code change passes through various deployment phases:

#### Phase A: Local Development, Merge Request, Feature Environment

In the initial phase, multiple parallel branches and merge requests often exist. To automate dependencies between merge requests and the rebase process, we developed the Merge Request Bot as part of our Urban-Stack project ([https://gitlab.com/hxtmdev/mrbot](https://gitlab.com/hxtmdev/mrbot)).

1. Developer implements changes in a local Kubernetes environment (Minikube).
2. Pre-commit checks, such as validating "Conventional Commit Messages" using [https://github.com/siderolabs/conform](https://github.com/siderolabs/conform).
3. Developer commits new code and creates a merge request.
4. Pipeline deployment into a new **feature environment**.
5. Perform an upgrade test from main version to feature version
6. Execution of an end-to-end test via the pipeline.

#### Phase B: Integration into Staging and Production Release

7. Approval of the merge request by another developer and, if necessary, a security officer.
8. Merge of the merge request after all criterias *(approvals, successful pipeline and e2e-tests)* are met
9. Deployment to the **staging environment**.
10. Final manual review of the staging environment by the product owner.
11. Product owner initiates the automated release process.
12. Automatically generates a tag and a release with release notes, incorporating new features extracted from commit logs.
13. Deployment of the release into the **production environment**.

This schematic description provides an overview of the functionality. Numerous minor features have been integrated into this pipeline process over the past three years through a continuous improvement process.


![Diagram Base Pipeline](base-pipeline.svg)

### Troubleshooting

#### Pipeline stuck/deployment failing

The pipeline can potentially get stuck if previously the images couldn't be built on the main branch and the pipeline couldn't run on the main branch either. In that case, feature pipelines will also get stuck, because as described in the diagram above, the latest main will be installed in feature pipelines before they're updated with the feature branch, and if main fails, this will also fail.

Should that occur, pipelines for a fix for the problem that caused main to fail can run without installing main first by adding `--trailer=skip-upgrade-test=true` to the commit command. This will then allow the pipeline of the fix MR to run and thus allow main to be fixed.